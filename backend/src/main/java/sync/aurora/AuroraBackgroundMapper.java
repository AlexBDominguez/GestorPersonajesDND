package sync.aurora;

import entities.*;
import org.springframework.stereotype.Service;
import repositories.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Maps Aurora "Background" elements to Background JPA entities.
 * PHB backgrounds are skipped (already in DB from dnd5eapi.co).
 * Personality/ideal/bond/flaw suggestion tables are intentionally left empty
 * — they are roleplay flavour that does not affect the character sheet.
 */
@Service
public class AuroraBackgroundMapper {

    private final AuroraRegistry registry;
    private final BackgroundRepository backgroundRepo;
    private final ContentSourceRepository sourceRepo;

    public AuroraBackgroundMapper(AuroraRegistry registry,
                                  BackgroundRepository backgroundRepo,
                                  ContentSourceRepository sourceRepo) {
        this.registry = registry;
        this.backgroundRepo = backgroundRepo;
        this.sourceRepo = sourceRepo;
    }

    public Map<String, Object> sync() {
        if (registry.isEmpty()) {
            return Map.of("error", "Registry is empty — run POST /api/sync/aurora/fetch first.");
        }
        Set<String> allowed = allowedSources();
        int created = 0, updated = 0, skipped = 0;

        for (AuroraElement el : registry.getByType("Background")) {
            String src = AuroraSourceMapper.toShortName(el.getSource());
            if ("PHB".equals(src) || !allowed.contains(src)) { skipped++; continue; }

            try {
                Background bg = backgroundRepo.findByIndexName(el.getId()).orElse(new Background());
                boolean isNew = bg.getId() == null;

                bg.setIndexName(el.getId());
                bg.setName(el.getName());
                bg.setSource(src);
                bg.setDescription(el.getDescription());
                bg.setSkillProficiencies(extractSkills(el));
                bg.setToolProficiencies(extractTools(el));
                bg.setLanguageOptions(extractLanguageOptions(el));
                applyFeature(el, bg);

                backgroundRepo.save(bg);
                if (isNew) created++; else updated++;
            } catch (Exception e) {
                System.err.printf("[Aurora] Background '%s' (%s): %s%n", el.getName(), src, e.getMessage());
                skipped++;
            }
        }

        System.out.printf("[Aurora] Backgrounds: created=%d, updated=%d, skipped=%d%n", created, updated, skipped);
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("created", created); r.put("updated", updated); r.put("skipped", skipped);
        return r;
    }

    // ── Skill proficiencies ────────────────────────────────────────────────────

    private List<String> extractSkills(AuroraElement el) {
        List<String> skills = new ArrayList<>();
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Proficiency".equals(rule.getType()) || rule.getId() == null) continue;
            if (!rule.getId().contains("_SKILL_")) continue;
            int idx = rule.getId().indexOf("_SKILL_") + 7;
            // e.g. ID_PROFICIENCY_SKILL_ANIMAL_HANDLING → animal-handling
            skills.add(rule.getId().substring(idx).toLowerCase().replace('_', '-'));
        }
        return skills;
    }

    // ── Tool proficiencies ─────────────────────────────────────────────────────

    private static final List<String> TOOL_PREFIXES = List.of(
        "ID_PROFICIENCY_TOOL_",
        "ID_PROFICIENCY_ARTISANS_TOOLS_",
        "ID_PROFICIENCY_GAMING_SET_",
        "ID_PROFICIENCY_MUSICAL_INSTRUMENT_",
        "ID_PROFICIENCY_KIT_"
    );
    private static final Set<String> SKIP_PROF_KEYWORDS =
        Set.of("_SKILL_", "_ARMOR_", "_WEAPON_", "_WEAPON_CATEGORY_", "_SAVING_THROW_");

    private List<String> extractTools(AuroraElement el) {
        List<String> tools = new ArrayList<>();
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Proficiency".equals(rule.getType()) || rule.getId() == null) continue;
            String id = rule.getId();
            if (SKIP_PROF_KEYWORDS.stream().anyMatch(id::contains)) continue;
            String name = toolName(id);
            if (name != null && !tools.contains(name)) tools.add(name);
        }
        return tools;
    }

    private String toolName(String id) {
        for (String prefix : TOOL_PREFIXES) {
            if (id.startsWith(prefix)) {
                return toTitleCase(id.substring(prefix.length()).replace('_', ' '));
            }
        }
        if (id.startsWith("ID_PROFICIENCY_")) {
            return toTitleCase(id.substring("ID_PROFICIENCY_".length()).replace('_', ' '));
        }
        return null;
    }

    // ── Language options count ─────────────────────────────────────────────────

    private int extractLanguageOptions(AuroraElement el) {
        int count = 0;
        for (AuroraRule rule : el.getRules()) {
            boolean isLanguageGrant = rule.getRuleType() == AuroraRule.RuleType.GRANT
                && "Language".equals(rule.getType())
                && rule.getId() != null
                && rule.getId().toUpperCase().contains("CHOICE");
            boolean isLanguageSelect = rule.getRuleType() == AuroraRule.RuleType.SELECT
                && "Language".equals(rule.getType());
            if (isLanguageGrant || isLanguageSelect) count++;
        }
        return count;
    }

    // ── Background feature ─────────────────────────────────────────────────────

    private void applyFeature(AuroraElement el, Background bg) {
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Background Feature".equals(rule.getType()) || rule.getId() == null) continue;
            registry.resolve(rule.getId()).ifPresent(featureEl -> {
                bg.setFeature(featureEl.getName());
                String desc = featureEl.getDescription();
                if (desc == null || desc.isBlank()) desc = featureEl.getSheetDescription();
                bg.setFeatureDescription(desc);
            });
            return; // only first feature grant
        }
    }

    // ── Utilities ──────────────────────────────────────────────────────────────

    private String toTitleCase(String s) {
        StringBuilder sb = new StringBuilder();
        for (String word : s.split(" ")) {
            if (!word.isEmpty()) {
                sb.append(Character.toUpperCase(word.charAt(0)))
                  .append(word.substring(1).toLowerCase())
                  .append(' ');
            }
        }
        return sb.toString().trim();
    }

    private Set<String> allowedSources() {
        return sourceRepo.findAll().stream()
            .map(ContentSource::getShortName)
            .filter(s -> !"PHB".equals(s))
            .collect(Collectors.toSet());
    }
}
