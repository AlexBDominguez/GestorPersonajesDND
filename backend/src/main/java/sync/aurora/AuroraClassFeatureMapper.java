package sync.aurora;

import entities.ClassFeature;
import entities.ClassSpell;
import entities.DndClass;
import entities.Spell;
import org.springframework.stereotype.Service;
import repositories.ClassFeatureRepository;
import repositories.ClassSpellRepository;
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
    private final AuroraSpellResolver spellResolver;
    private final ClassSpellRepository classSpellRepo;

    public AuroraClassFeatureMapper(AuroraRegistry registry,
                                    ClassFeatureRepository featureRepo,
                                    DndClassRepository classRepo,
                                    AuroraSpellResolver spellResolver,
                                    ClassSpellRepository classSpellRepo) {
        this.registry = registry;
        this.featureRepo = featureRepo;
        this.classRepo = classRepo;
        this.spellResolver = spellResolver;
        this.classSpellRepo = classSpellRepo;
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

    /** Removes Aurora's redundant level header line, e.g. "3rd-level artificer feature". */
    private String stripLevelHeader(String desc) {
        if (desc == null || desc.isBlank()) return desc;
        // Match "Nth-level <word(s)> feature" at the very start, followed by newline or end
        String stripped = desc.replaceFirst("(?i)^\\d+(st|nd|rd|th)-level [\\w ]+ feature\\.?\\n?", "").trim();
        return stripped.isEmpty() ? desc : stripped;
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
                cf.setDescription(desc != null ? stripLevelHeader(desc.trim()) : "");
                cf.setApiUrl(null);

                featureRepo.save(cf);
                if (isNew) created++; else updated++;

                grantFeatureSpells(feat, dndClass, level);
            } catch (Exception e) {
                System.err.printf("[Aurora] ClassFeature '%s' for class '%s': %s%n",
                    feat.getName(), dndClass.getName(), e.getMessage());
            }
        }
        return new int[]{created, updated};
    }

    /**
     * Some base Class Feature elements grant a spell directly via
     * &lt;grant type="Spell" .../&gt; (e.g. Bard's Magical Secrets-style features).
     * These were previously ignored — see AuroraSubclassMapper.grantFeatureSpells
     * for the equivalent subclass-level fix and rationale.
     */
    private void grantFeatureSpells(AuroraElement feat, DndClass dndClass, int featureLevel) {
        for (AuroraRule rule : feat.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Spell".equals(rule.getType()) || rule.getId() == null) continue;

            Spell spell = spellResolver.resolve(rule.getId());
            if (spell == null) {
                System.err.printf("[Aurora] Could not resolve spell grant '%s' on feature '%s'%n",
                    rule.getId(), feat.getName());
                continue;
            }

            int level = rule.getLevel() != null ? rule.getLevel() : featureLevel;
            if (classSpellRepo.findByDndClassAndSpell(dndClass, spell).isEmpty()) {
                classSpellRepo.save(new ClassSpell(dndClass, spell, level));
            }
        }
    }
}
