package sync.aurora;

import entities.*;
import org.springframework.stereotype.Service;
import repositories.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Maps Aurora "Spell" elements to Spell JPA entities.
 * PHB spells are skipped (already in DB from dnd5eapi.co).
 *
 * Combat fields (attackType, dcType, damageType, damageBase) are left null —
 * they require per-spell analysis and can be populated later via the
 * existing extended-data sync mechanism.
 *
 * DndClass linking: Aurora's `supports` field mixes class names with other tags
 * (e.g. "Sorcerer, Warlock, Wizard" or "Druid, Sorcerer, Wizard, Spell Saving Throw"),
 * and subclass-qualified entries like "Rogue (Arcane Trickster)". We resolve each
 * comma-separated token against known class names (prefix match, so "Artificer"
 * matches both "Artificer (ERLW)" and "Artificer (TCE)"); tokens that don't match
 * any class (tags like "Ranged", "Spell Attack") are silently ignored.
 */
@Service
public class AuroraSpellMapper {

    private final AuroraRegistry registry;
    private final SpellRepository spellRepo;
    private final ContentSourceRepository sourceRepo;
    private final DndClassRepository classRepo;

    public AuroraSpellMapper(AuroraRegistry registry,
                             SpellRepository spellRepo,
                             ContentSourceRepository sourceRepo,
                             DndClassRepository classRepo) {
        this.registry = registry;
        this.spellRepo = spellRepo;
        this.sourceRepo = sourceRepo;
        this.classRepo = classRepo;
    }

    public Map<String, Object> sync() {
        if (registry.isEmpty()) {
            return Map.of("error", "Registry is empty — run POST /api/sync/aurora/fetch first.");
        }
        Set<String> allowed = allowedSources();
        List<DndClass> allClasses = classRepo.findAll();
        int created = 0, updated = 0, skipped = 0, linked = 0;

        for (AuroraElement el : registry.getByType("Spell")) {
            String src = AuroraSourceMapper.toShortName(el.getSource());
            if ("PHB".equals(src) || !allowed.contains(src)) { skipped++; continue; }

            try {
                Spell spell = spellRepo.findByIndexApi(el.getId()).orElse(new Spell());
                boolean isNew = spell.getId() == null;

                spell.setIndexApi(el.getId());
                spell.setName(el.getName());
                spell.setSource(src);
                spell.setDescription(el.getDescription());
                spell.setLevel(parseLevel(el));
                spell.setSchool(el.getSetters().getOrDefault("school", ""));
                spell.setCastingTime(el.getSetters().getOrDefault("time", ""));
                spell.setRange(el.getSetters().getOrDefault("range", ""));
                spell.setDuration(buildDuration(el));
                spell.setComponents(buildComponents(el));

                spellRepo.save(spell);
                if (isNew) created++; else updated++;

                linked += linkClasses(spell, el.getSupports(), allClasses);
            } catch (Exception e) {
                System.err.printf("[Aurora] Spell '%s' (%s): %s%n", el.getName(), src, e.getMessage());
                skipped++;
            }
        }

        System.out.printf("[Aurora] Spells: created=%d, updated=%d, skipped=%d, classLinks=%d%n",
                created, updated, skipped, linked);
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("created", created); r.put("updated", updated); r.put("skipped", skipped); r.put("classLinks", linked);
        return r;
    }

    /**
     * Resolves the class names embedded in Aurora's `supports` field and links the
     * spell to each matching class via class_spells. Returns how many links were
     * attempted (INSERT IGNORE makes re-running the sync safe).
     */
    private int linkClasses(Spell spell, String supports, List<DndClass> allClasses) {
        if (supports == null || supports.isBlank()) return 0;
        int count = 0;
        for (String token : supports.split(",")) {
            String name = token.trim();
            int paren = name.indexOf('(');
            if (paren > 0) name = name.substring(0, paren).trim(); // "Rogue (Arcane Trickster)" -> "Rogue"
            if (name.isEmpty()) continue;
            final String lname = name.toLowerCase();
            for (DndClass dc : allClasses) {
                if (dc.getName().toLowerCase().startsWith(lname)) {
                    classRepo.linkSpell(dc.getId(), spell.getId());
                    count++;
                }
            }
        }
        return count;
    }

    // ── Field builders ─────────────────────────────────────────────────────────

    private int parseLevel(AuroraElement el) {
        try { return Integer.parseInt(el.getSetters().getOrDefault("level", "0").trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    /**
     * Prefixes duration with "Concentration, " when the setter is present and true.
     * Example: "Concentration, up to 1 minute"
     */
    private String buildDuration(AuroraElement el) {
        String duration = el.getSetters().getOrDefault("duration", "");
        boolean conc = "true".equalsIgnoreCase(el.getSetters().getOrDefault("isConcentration", "false").trim());
        if (conc && !duration.toLowerCase().startsWith("concentration")) {
            return "Concentration, " + duration;
        }
        return duration;
    }

    /**
     * Builds the components string from the three boolean setters plus the
     * optional material component description.
     * Examples: "V, S", "V, S, M (a tiny ball of bat guano and sulfur)"
     */
    private String buildComponents(AuroraElement el) {
        Map<String, String> s = el.getSetters();
        List<String> parts = new ArrayList<>();
        if ("true".equalsIgnoreCase(s.getOrDefault("verbal",   "false").trim())) parts.add("V");
        if ("true".equalsIgnoreCase(s.getOrDefault("somatic",  "false").trim())) parts.add("S");
        if ("true".equalsIgnoreCase(s.getOrDefault("material", "false").trim())) {
            String mat = s.getOrDefault("materials", "").trim();
            parts.add(mat.isEmpty() ? "M" : "M (" + mat + ")");
        }
        return String.join(", ", parts);
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    private Set<String> allowedSources() {
        return sourceRepo.findAll().stream()
            .map(ContentSource::getShortName)
            .filter(s -> !"PHB".equals(s))
            .collect(Collectors.toSet());
    }
}
