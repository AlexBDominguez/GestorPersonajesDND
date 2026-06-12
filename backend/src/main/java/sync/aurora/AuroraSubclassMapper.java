package sync.aurora;

import entities.*;
import org.springframework.stereotype.Service;
import repositories.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Maps Aurora "Archetype" elements to Subclass + SubclassFeature JPA entities.
 *
 * Aurora model:
 *   - Archetype element  → Subclass (supports="Fighter", "Wizard", etc.)
 *   - Archetype Feature elements granted via GRANT rules at specific levels
 *     → SubclassFeature rows linked to their Subclass
 *
 * PHB subclasses are skipped (already in DB from dnd5eapi.co).
 * spellcastingAbility is detected from stat rules; left null when not found.
 */
@Service
public class AuroraSubclassMapper {

    private final AuroraRegistry registry;
    private final SubclassRepository subclassRepo;
    private final SubclassFeatureRepository featureRepo;
    private final DndClassRepository classRepo;
    private final ContentSourceRepository sourceRepo;

    // Aurora ability stat name → short ability key used elsewhere in the app
    private static final Map<String, String> ABILITY_STAT = Map.of(
        "intelligence",  "INT",
        "wisdom",        "WIS",
        "charisma",      "CHA",
        "strength",      "STR",
        "dexterity",     "DEX",
        "constitution",  "CON"
    );

    /**
     * Aurora stores archetype category names in the <supports> element, not class names.
     * E.g. "Primal Path" (Barbarian), "Martial Archetype" (Fighter), "Arcane Tradition" (Wizard).
     * Map every known variant to its parent class name.
     */
    private static final Map<String, String> CATEGORY_TO_CLASS = Map.ofEntries(
        Map.entry("Primal Path",           "Barbarian"),
        Map.entry("Bard College",          "Bard"),
        Map.entry("College",               "Bard"),
        Map.entry("Divine Domain",         "Cleric"),
        Map.entry("Cleric Domain",         "Cleric"),
        Map.entry("Domain",                "Cleric"),
        Map.entry("Druid Circle",          "Druid"),
        Map.entry("Circle",                "Druid"),
        Map.entry("Martial Archetype",     "Fighter"),
        Map.entry("Monastic Tradition",    "Monk"),
        Map.entry("Monastic Order",        "Monk"),
        Map.entry("Sacred Oath",           "Paladin"),
        Map.entry("Paladin Archetype",     "Paladin"),
        Map.entry("Ranger Archetype",      "Ranger"),
        Map.entry("Ranger Conclave",       "Ranger"),
        Map.entry("Ranger Subclass",       "Ranger"),
        Map.entry("Roguish Archetype",     "Rogue"),
        Map.entry("Sorcerous Origin",      "Sorcerer"),
        Map.entry("Sorcerer Subclass",     "Sorcerer"),
        Map.entry("Otherworldly Patron",   "Warlock"),
        Map.entry("Eldritch Invocation",   "Warlock"),
        Map.entry("Arcane Tradition",      "Wizard"),
        Map.entry("Artificer Specialist",  "Artificer"),
        Map.entry("Artificer Subclass",    "Artificer")
    );

    public AuroraSubclassMapper(AuroraRegistry registry,
                                SubclassRepository subclassRepo,
                                SubclassFeatureRepository featureRepo,
                                DndClassRepository classRepo,
                                ContentSourceRepository sourceRepo) {
        this.registry = registry;
        this.subclassRepo = subclassRepo;
        this.featureRepo = featureRepo;
        this.classRepo = classRepo;
        this.sourceRepo = sourceRepo;
    }

    public Map<String, Object> sync() {
        if (registry.isEmpty()) {
            return Map.of("error", "Registry is empty — run POST /api/sync/aurora/fetch first.");
        }
        Set<String> allowed = allowedSources();
        int subCreated = 0, subUpdated = 0, subSkipped = 0;
        int featCreated = 0, featUpdated = 0;

        // Cache of class lookups to avoid repeated DB hits
        Map<String, Optional<DndClass>> classCache = new HashMap<>();

        for (AuroraElement el : registry.getByType("Archetype")) {
            String src = AuroraSourceMapper.toShortName(el.getSource());
            if ("PHB".equals(src) || !allowed.contains(src)) { subSkipped++; continue; }

            try {
                DndClass parentClass = resolveParentClass(el, classCache);
                if (parentClass == null) {
                    System.err.printf("[Aurora] Archetype '%s': parent class '%s' not found in DB%n",
                        el.getName(), el.getSupports());
                    subSkipped++;
                    continue;
                }

                Subclass sub = subclassRepo.findByIndexName(el.getId()).orElse(new Subclass());
                boolean isNew = sub.getId() == null;

                sub.setIndexName(el.getId());
                sub.setName(el.getName());
                sub.setDndClass(parentClass);
                sub.setSource(src);
                sub.setSubclassFlavor(el.getSupports() != null ? el.getSupports().trim() : null);
                sub.setDescription(el.getDescription());
                sub.setSpellcastingAbility(detectSpellcastingAbility(el));

                subclassRepo.save(sub);
                if (isNew) subCreated++; else subUpdated++;

                // Persist subclass features from GRANT rules that carry a level
                int[] counts = persistFeatures(el, sub);
                featCreated += counts[0];
                featUpdated += counts[1];

            } catch (Exception e) {
                System.err.printf("[Aurora] Archetype '%s' (%s): %s%n", el.getName(), src, e.getMessage());
                subSkipped++;
            }
        }

        System.out.printf("[Aurora] Subclasses: created=%d, updated=%d, skipped=%d | Features: created=%d, updated=%d%n",
            subCreated, subUpdated, subSkipped, featCreated, featUpdated);
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("subclassesCreated", subCreated);
        r.put("subclassesUpdated", subUpdated);
        r.put("subclassesSkipped", subSkipped);
        r.put("featuresCreated", featCreated);
        r.put("featuresUpdated", featUpdated);
        return r;
    }

    // ── Parent class resolution ────────────────────────────────────────────────

    /**
     * Aurora stores an archetype category name in supports (e.g. "Primal Path", "Martial Archetype").
     * Resolve it via CATEGORY_TO_CLASS first; fall back to treating it as a direct class name
     * (handles edge cases where some files already use the class name directly).
     */
    private DndClass resolveParentClass(AuroraElement el, Map<String, Optional<DndClass>> cache) {
        if (el.getSupports() == null || el.getSupports().isBlank()) return null;
        String resolved = CATEGORY_TO_CLASS.getOrDefault(el.getSupports().trim(), el.getSupports().trim());
        for (String candidate : resolved.split(",")) {
            String name = candidate.trim();
            Optional<DndClass> found = cache.computeIfAbsent(name,
                k -> classRepo.findByNameIgnoreCase(k));
            if (found.isPresent()) return found.get();
        }
        return null;
    }

    // ── Subclass features ──────────────────────────────────────────────────────

    /**
     * For each GRANT rule of type "Archetype Feature" that carries a level,
     * resolves the feature element from the registry and upserts a SubclassFeature.
     * Returns [created, updated].
     */
    private int[] persistFeatures(AuroraElement archetypeEl, Subclass sub) {
        int created = 0, updated = 0;
        for (AuroraRule rule : archetypeEl.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Archetype Feature".equals(rule.getType())) continue;
            if (rule.getId() == null) continue;
            int level = rule.getLevel() != null ? rule.getLevel() : 0;

            Optional<AuroraElement> featureEl = registry.resolve(rule.getId());
            if (featureEl.isEmpty()) continue;

            AuroraElement feat = featureEl.get();
            try {
                SubclassFeature sf = featureRepo.findByIndexName(feat.getId())
                    .orElse(new SubclassFeature());
                boolean isNew = sf.getId() == null;

                sf.setIndexName(feat.getId());
                sf.setName(feat.getName());
                sf.setSubclass(sub);
                sf.setLevel(level > 0 ? level : deriveLevel(feat));
                String desc = feat.getDescription();
                if (desc == null || desc.isBlank()) desc = feat.getSheetDescription();
                sf.setDescription(desc);
                sf.setApiUrl(null);

                featureRepo.save(sf);
                if (isNew) created++; else updated++;
            } catch (Exception e) {
                System.err.printf("[Aurora] Feature '%s': %s%n", feat.getName(), e.getMessage());
            }
        }
        return new int[]{created, updated};
    }

    /**
     * Fallback: try to read the level from the feature element's own setters or
     * sheet description. Returns 0 if not determinable.
     */
    private int deriveLevel(AuroraElement feat) {
        String levelStr = feat.getSetters().get("level");
        if (levelStr != null) {
            try { return Integer.parseInt(levelStr.trim()); } catch (NumberFormatException ignored) {}
        }
        return 0;
    }

    // ── Spellcasting ability detection ─────────────────────────────────────────

    /**
     * Looks for a stat rule whose name matches "spellcasting:ability:<ability>".
     * Examples in Aurora: `<stat name="spellcasting:ability:cha" value="1"/>`.
     * Returns the short ability key ("INT", "WIS", "CHA", …) or null.
     */
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

    // ── Helpers ────────────────────────────────────────────────────────────────

    private Set<String> allowedSources() {
        return sourceRepo.findAll().stream()
            .map(ContentSource::getShortName)
            .filter(s -> !"PHB".equals(s))
            .collect(Collectors.toSet());
    }
}
