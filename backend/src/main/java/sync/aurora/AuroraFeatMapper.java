package sync.aurora;

import entities.*;
import org.springframework.stereotype.Service;
import repositories.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Maps Aurora "Feat" elements to Feat JPA entities.
 * PHB feats are skipped (already in DB from SQL scripts).
 * grantedSpells is left empty — spell linking requires the spell registry,
 * which will be wired when AuroraSpellMapper runs.
 */
@Service
public class AuroraFeatMapper {

    private final AuroraRegistry registry;
    private final FeatRepository featRepo;
    private final ContentSourceRepository sourceRepo;

    public AuroraFeatMapper(AuroraRegistry registry,
                            FeatRepository featRepo,
                            ContentSourceRepository sourceRepo) {
        this.registry = registry;
        this.featRepo = featRepo;
        this.sourceRepo = sourceRepo;
    }

    public Map<String, Object> sync() {
        if (registry.isEmpty()) {
            return Map.of("error", "Registry is empty — run POST /api/sync/aurora/fetch first.");
        }
        Set<String> allowed = allowedSources();
        int created = 0, updated = 0, skipped = 0;

        for (AuroraElement el : registry.getByType("Feat")) {
            String src = AuroraSourceMapper.toShortName(el.getSource());
            if ("PHB".equals(src) || !allowed.contains(src)) { skipped++; continue; }

            try {
                Feat feat = featRepo.findByIndexName(el.getId()).orElse(new Feat());
                boolean isNew = feat.getId() == null;

                feat.setIndexName(el.getId());
                feat.setName(el.getName());
                feat.setSource(src);
                feat.setDescription(el.getDescription());
                feat.setPrerequisites(extractPrerequisites(el));

                featRepo.save(feat);
                if (isNew) created++; else updated++;
            } catch (Exception e) {
                System.err.printf("[Aurora] Feat '%s' (%s): %s%n", el.getName(), src, e.getMessage());
                skipped++;
            }
        }

        System.out.printf("[Aurora] Feats: created=%d, updated=%d, skipped=%d%n", created, updated, skipped);
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("created", created); r.put("updated", updated); r.put("skipped", skipped);
        return r;
    }

    /**
     * Extracts prerequisite text from multiple Aurora sources:
     * 1. Lines starting with "Prerequisite" in the description.
     * 2. The element's requirements field if it's human-readable (not just IDs).
     */
    private List<String> extractPrerequisites(AuroraElement el) {
        List<String> prereqs = new ArrayList<>();

        // Check description for "Prerequisite: ..." lines
        if (el.getDescription() != null) {
            for (String line : el.getDescription().split("\n")) {
                String trimmed = line.trim();
                if (trimmed.toLowerCase().startsWith("prerequisite")) {
                    prereqs.add(trimmed);
                    break;
                }
            }
        }

        // Fallback: sheetDescription if no description hit
        if (prereqs.isEmpty() && el.getSheetDescription() != null) {
            for (String line : el.getSheetDescription().split("\n")) {
                String trimmed = line.trim();
                if (trimmed.toLowerCase().startsWith("prerequisite")) {
                    prereqs.add(trimmed);
                    break;
                }
            }
        }

        // Also check the requirements field if it looks like plain text (not just IDs)
        String req = el.getRequirements();
        if (req != null && !req.isBlank() && !req.startsWith("ID_") && prereqs.isEmpty()) {
            prereqs.add("Prerequisite: " + req.trim());
        }

        return prereqs;
    }

    private Set<String> allowedSources() {
        return sourceRepo.findAll().stream()
            .map(ContentSource::getShortName)
            .filter(s -> !"PHB".equals(s))
            .collect(Collectors.toSet());
    }
}
