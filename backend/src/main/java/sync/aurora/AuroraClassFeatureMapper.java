package sync.aurora;

import entities.ClassFeature;
import entities.DndClass;
import org.springframework.stereotype.Service;
import repositories.ClassFeatureRepository;
import repositories.DndClassRepository;

import java.util.*;

/**
 * Imports ClassFeature records for non-PHB classes (e.g. Artificer) from the Aurora registry.
 *
 * For each Aurora Class element, reads GRANT rules of type "Class Feature" and resolves
 * the target element from the registry. Each resolved element becomes a ClassFeature row
 * linked to the parent DndClass.
 *
 * Requires:
 *  1. POST /api/sync/aurora/fetch  — registry populated
 *  2. POST /api/sync/aurora/persist/classes — DndClass rows present in DB
 */
@Service
public class AuroraClassFeatureMapper {

    private final AuroraRegistry registry;
    private final ClassFeatureRepository featureRepo;
    private final DndClassRepository classRepo;

    public AuroraClassFeatureMapper(AuroraRegistry registry,
                                    ClassFeatureRepository featureRepo,
                                    DndClassRepository classRepo) {
        this.registry = registry;
        this.featureRepo = featureRepo;
        this.classRepo = classRepo;
    }

    public Map<String, Object> sync() {
        if (registry.isEmpty()) {
            return Map.of("error", "Registry is empty — run POST /api/sync/aurora/fetch first.");
        }

        int featCreated = 0, featUpdated = 0, classesProcessed = 0, classesSkipped = 0;

        for (AuroraElement el : registry.getByType("Class")) {
            String src = AuroraSourceMapper.toShortName(el.getSource());
            // PHB classes already have features from the D&D 5e API
            if ("PHB".equals(src)) { classesSkipped++; continue; }

            Optional<DndClass> dndClass = classRepo.findByIndexName(el.getId());
            if (dndClass.isEmpty()) {
                // Class not persisted yet — run persist/classes first
                System.err.printf("[Aurora] ClassFeature: DndClass not found for '%s' (%s) — run persist/classes first%n",
                    el.getName(), el.getId());
                classesSkipped++;
                continue;
            }

            int[] counts = persistFeatures(el, dndClass.get());
            featCreated += counts[0];
            featUpdated += counts[1];
            classesProcessed++;
        }

        System.out.printf("[Aurora] ClassFeatures: created=%d, updated=%d | classes processed=%d, skipped=%d%n",
            featCreated, featUpdated, classesProcessed, classesSkipped);

        Map<String, Object> r = new LinkedHashMap<>();
        r.put("featuresCreated", featCreated);
        r.put("featuresUpdated", featUpdated);
        r.put("classesProcessed", classesProcessed);
        r.put("classesSkipped", classesSkipped);
        return r;
    }

    private int[] persistFeatures(AuroraElement classEl, DndClass dndClass) {
        int created = 0, updated = 0;

        for (AuroraRule rule : classEl.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Class Feature".equals(rule.getType())) continue;
            if (rule.getId() == null || rule.getId().isBlank()) continue;

            int level = rule.getLevel() != null ? rule.getLevel() : 1;

            Optional<AuroraElement> featureEl = registry.resolve(rule.getId());
            if (featureEl.isEmpty()) continue;

            AuroraElement feat = featureEl.get();
            try {
                ClassFeature cf = featureRepo.findByIndexName(feat.getId())
                    .orElse(new ClassFeature());
                boolean isNew = cf.getId() == null;

                cf.setIndexName(feat.getId());
                cf.setName(feat.getName());
                cf.setDndClass(dndClass);
                cf.setLevel(level);

                String desc = feat.getDescription();
                if (desc == null || desc.isBlank()) desc = feat.getSheetDescription();
                cf.setDescription(desc != null ? desc.trim() : "");
                cf.setApiUrl(null);

                featureRepo.save(cf);
                if (isNew) created++; else updated++;
            } catch (Exception e) {
                System.err.printf("[Aurora] ClassFeature '%s' for class '%s': %s%n",
                    feat.getName(), dndClass.getName(), e.getMessage());
            }
        }
        return new int[]{created, updated};
    }
}
