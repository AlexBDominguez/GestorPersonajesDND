package sync.aurora;

import entities.*;
import org.springframework.stereotype.Service;
import repositories.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Maps Aurora "Class" elements to DndClass JPA entities.
 *
 * PHB classes are skipped (already in DB from dnd5eapi.co).
 *
 * skillChoiceOptions is left empty — Aurora encodes the available skills via
 * Proficiency elements filtered by class-specific supports tags, which requires
 * a separate resolution pass. numSkillChoices IS populated from the SELECT rule.
 *
 * The spells ManyToMany join is not populated here; spell-class linking requires
 * the spell registry to be fully persisted first (future work).
 */
@Service
public class AuroraClassMapper {

    private static final Map<String, String> SAVING_THROW_IDS = Map.of(
        "ID_PROFICIENCY_SAVING_THROW_STRENGTH",     "strength",
        "ID_PROFICIENCY_SAVING_THROW_DEXTERITY",    "dexterity",
        "ID_PROFICIENCY_SAVING_THROW_CONSTITUTION",  "constitution",
        "ID_PROFICIENCY_SAVING_THROW_INTELLIGENCE",  "intelligence",
        "ID_PROFICIENCY_SAVING_THROW_WISDOM",        "wisdom",
        "ID_PROFICIENCY_SAVING_THROW_CHARISMA",      "charisma"
    );

    private static final Map<String, String> ARMOR_WEAPON_IDS = Map.ofEntries(
        Map.entry("ID_PROFICIENCY_ARMOR_LIGHT",          "Light Armor"),
        Map.entry("ID_PROFICIENCY_ARMOR_MEDIUM",         "Medium Armor"),
        Map.entry("ID_PROFICIENCY_ARMOR_HEAVY",          "Heavy Armor"),
        Map.entry("ID_PROFICIENCY_ARMOR_SHIELDS",        "Shields"),
        Map.entry("ID_PROFICIENCY_ARMOR_SHIELD",         "Shields"),
        Map.entry("ID_PROFICIENCY_WEAPON_SIMPLE",        "Simple Weapons"),
        Map.entry("ID_PROFICIENCY_WEAPON_MARTIAL",       "Martial Weapons"),
        Map.entry("ID_PROFICIENCY_WEAPON_SIMPLE_MELEE",  "Simple Melee Weapons"),
        Map.entry("ID_PROFICIENCY_WEAPON_SIMPLE_RANGED", "Simple Ranged Weapons")
    );

    private static final Map<String, String> ABILITY_STAT = Map.of(
        "intelligence", "INT", "wisdom", "WIS", "charisma", "CHA",
        "strength", "STR", "dexterity", "DEX", "constitution", "CON"
    );

    private final AuroraRegistry registry;
    private final DndClassRepository classRepo;
    private final ContentSourceRepository sourceRepo;

    public AuroraClassMapper(AuroraRegistry registry,
                             DndClassRepository classRepo,
                             ContentSourceRepository sourceRepo) {
        this.registry = registry;
        this.classRepo = classRepo;
        this.sourceRepo = sourceRepo;
    }

    public Map<String, Object> sync() {
        if (registry.isEmpty()) {
            return Map.of("error", "Registry is empty — run POST /api/sync/aurora/fetch first.");
        }
        Set<String> allowed = allowedSources();
        int created = 0, updated = 0, skipped = 0;

        // Collect allowed elements first so we can detect name collisions in memory
        List<AuroraElement> toProcess = new ArrayList<>();
        for (AuroraElement el : registry.getByType("Class")) {
            String src = AuroraSourceMapper.toShortName(el.getSource());
            if ("PHB".equals(src) || !allowed.contains(src)) { skipped++; continue; }
            toProcess.add(el);
        }

        // Names that appear more than once across allowed Aurora Class elements
        Map<String, Long> nameCount = toProcess.stream()
            .collect(Collectors.groupingBy(el -> el.getName().toLowerCase(), Collectors.counting()));

        for (AuroraElement el : toProcess) {
            String src = AuroraSourceMapper.toShortName(el.getSource());

            try {
                DndClass cls = classRepo.findByIndexName(el.getId()).orElse(new DndClass());
                boolean isNew = cls.getId() == null;

                cls.setIndexName(el.getId());
                // When multiple Aurora sources provide the same class name, disambiguate with source abbreviation
                boolean isDuplicate = nameCount.getOrDefault(el.getName().toLowerCase(), 0L) > 1;
                cls.setName(isDuplicate ? el.getName() + " (" + src + ")" : el.getName());
                cls.setSource(src);
                cls.setDescription(extractFlavorDescription(el.getDescription()));
                cls.setHitDie(parseHitDie(el));
                cls.setSavingThrows(extractSavingThrows(el));
                cls.setProficiencies(extractArmorWeaponProficiencies(el));
                cls.setNumSkillChoices(extractNumSkillChoices(el));
                cls.setSpellcastingAbility(detectSpellcastingAbility(el));
                cls.setSubclassLevel(extractSubclassLevel(el));

                classRepo.save(cls);
                if (isNew) created++; else updated++;
            } catch (Exception e) {
                System.err.printf("[Aurora] Class '%s' (%s): %s%n", el.getName(), src, e.getMessage());
                skipped++;
            }
        }

        System.out.printf("[Aurora] Classes: created=%d, updated=%d, skipped=%d%n", created, updated, skipped);
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("created", created); r.put("updated", updated); r.put("skipped", skipped);
        return r;
    }

    // ── Field extractors ───────────────────────────────────────────────────────

    private int parseHitDie(AuroraElement el) {
        String faces = el.getSetters().get("hd:faces");
        if (faces != null) {
            try { return Integer.parseInt(faces.trim()); } catch (NumberFormatException ignored) {}
        }
        return 8; // D&D default
    }

    private List<String> extractSavingThrows(AuroraElement el) {
        List<String> throws_ = new ArrayList<>();
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Proficiency".equals(rule.getType()) || rule.getId() == null) continue;
            String ability = SAVING_THROW_IDS.get(rule.getId());
            if (ability != null && !throws_.contains(ability)) throws_.add(ability);
        }
        return throws_;
    }

    private List<String> extractArmorWeaponProficiencies(AuroraElement el) {
        List<String> profs = new ArrayList<>();
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Proficiency".equals(rule.getType()) || rule.getId() == null) continue;
            String prof = ARMOR_WEAPON_IDS.get(rule.getId());
            if (prof != null && !profs.contains(prof)) profs.add(prof);
        }
        return profs;
    }

    /** Reads the `number` attribute from the first SELECT Skill Proficiency rule. */
    private int extractNumSkillChoices(AuroraElement el) {
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.SELECT) continue;
            if (!"Proficiency".equals(rule.getType())) continue;
            String sup = rule.getSupports();
            if (sup != null && sup.toLowerCase().contains("skill")) {
                return rule.getNumber() != null ? rule.getNumber() : 2;
            }
        }
        return 2; // sensible default
    }

    private String detectSpellcastingAbility(AuroraElement el) {
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.STAT) continue;
            String name = rule.getName();
            if (name == null) continue;
            String lower = name.toLowerCase();
            if (lower.startsWith("spellcasting:ability:")) {
                String ability = lower.replace("spellcasting:ability:", "");
                return ABILITY_STAT.getOrDefault(ability, ability.toUpperCase());
            }
        }
        return null;
    }

    /** The level at which a subclass is chosen = level on the SELECT Archetype rule. */
    private Integer extractSubclassLevel(AuroraElement el) {
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.SELECT) continue;
            if ("Archetype".equals(rule.getType()) && rule.getLevel() != null) {
                return rule.getLevel();
            }
        }
        return null;
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    /**
     * Extracts only the flavor/intro paragraphs from an Aurora class description,
     * discarding structural sections (all-caps headers, proficiency lines, equipment lists).
     * Aurora class descriptions embed the full rulebook chapter; we only want the intro.
     */
    private String extractFlavorDescription(String full) {
        if (full == null || full.isBlank()) return "";
        String[] paragraphs = full.split("\n");
        List<String> result = new ArrayList<>();
        for (String p : paragraphs) {
            String trimmed = p.trim();
            if (trimmed.isEmpty()) continue;
            // All-caps section headers like "EQUIPMENT" or "THE ARTIFICER" mark end of flavor text
            if (trimmed.length() > 2 && trimmed.equals(trimmed.toUpperCase())
                    && trimmed.matches("[A-Z][A-Z ]+")) break;
            // Structural proficiency/equipment lines like "Weapons: ...", "Tools: ..."
            if (trimmed.matches("^(Weapons|Tools|Armor|Skills|Saving Throws?|Equipment|Proficiencies):.*")) {
                if (!result.isEmpty()) break;
                continue; // skip if we haven't found flavor text yet
            }
            result.add(trimmed);
            if (result.size() >= 4) break; // cap at 4 flavor paragraphs
        }
        return String.join("\n", result);
    }

    private Set<String> allowedSources() {
        return sourceRepo.findAll().stream()
            .map(ContentSource::getShortName)
            .filter(s -> !"PHB".equals(s))
            .collect(Collectors.toSet());
    }
}
