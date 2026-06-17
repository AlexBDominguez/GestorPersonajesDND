package sync.aurora;

import entities.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import repositories.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Maps Aurora "Race" and "Sub Race" elements to Race/Subrace/RacialTrait JPA entities.
 *
 * Strategy:
 *  - PHB content is skipped (already in DB from dnd5eapi.co).
 *  - Only elements from sources present in the content_sources table are persisted.
 *  - Upsert by Aurora element ID stored as indexName (safe to run multiple times).
 */
@Service
public class AuroraRaceMapper {

    private static final Map<String, String> ABILITY_KEYS = Map.of(
        "strength",     "str",
        "dexterity",    "dex",
        "constitution", "con",
        "intelligence", "int",
        "wisdom",       "wis",
        "charisma",     "cha"
    );

    private final AuroraRegistry registry;
    private final RaceRepository raceRepo;
    private final SubraceRepository subraceRepo;
    private final RacialTraitRepository traitRepo;
    private final ContentSourceRepository sourceRepo;
    private final AuroraSpellResolver spellResolver;
    private final RacialTraitSpellRepository traitSpellRepo;

    public AuroraRaceMapper(AuroraRegistry registry, RaceRepository raceRepo,
                            SubraceRepository subraceRepo, RacialTraitRepository traitRepo,
                            ContentSourceRepository sourceRepo, AuroraSpellResolver spellResolver,
                            RacialTraitSpellRepository traitSpellRepo) {
        this.registry = registry;
        this.raceRepo = raceRepo;
        this.subraceRepo = subraceRepo;
        this.traitRepo = traitRepo;
        this.sourceRepo = sourceRepo;
        this.spellResolver = spellResolver;
        this.traitSpellRepo = traitSpellRepo;
    }

    @Transactional
    public Map<String, Object> sync() {
        if (registry.isEmpty()) {
            return Map.of("error", "Registry is empty — run POST /api/sync/aurora/fetch first.");
        }
        Set<String> allowed = allowedSources();
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("races", syncRaces(allowed));
        result.put("subraces", syncSubRaces(allowed));
        return result;
    }

    // ── Races ──────────────────────────────────────────────────────────────────

    private Map<String, Object> syncRaces(Set<String> allowed) {
        int created = 0, updated = 0, skipped = 0;

        for (AuroraElement el : registry.getByType("Race")) {
            String src = AuroraSourceMapper.toShortName(el.getSource());
            if ("PHB".equals(src) || !allowed.contains(src)) { skipped++; continue; }

            Race race = raceRepo.findByIndexName(el.getId()).orElse(new Race());
            boolean isNew = race.getId() == null;

            race.setIndexName(el.getId());
            race.setName(el.getName());
            race.setSource(src);
            race.setDescription(el.getDescription());
            race.setSpeed(extractSpeed(el));
            race.setSize(extractSize(el));

            // Update @ElementCollection in-place so Hibernate dirty-tracking works correctly
            // for both new (persist) and existing (managed within @Transactional) entities.
            Map<String, Integer> newBonuses = extractAbilityBonuses(el);
            if (race.getAbilityBonuses() == null) {
                race.setAbilityBonuses(new LinkedHashMap<>(newBonuses));
            } else {
                race.getAbilityBonuses().clear();
                race.getAbilityBonuses().putAll(newBonuses);
            }

            race.setFlexibleAsi(hasFlexibleAsi(el));
            race.setTraits(extractTraits(el));

            raceRepo.save(race);
            if (isNew) created++; else updated++;
        }

        System.out.printf("[Aurora] Races: created=%d, updated=%d, skipped=%d%n", created, updated, skipped);
        return statsMap(created, updated, skipped);
    }

    // ── Sub Races ──────────────────────────────────────────────────────────────

    private Map<String, Object> syncSubRaces(Set<String> allowed) {
        int created = 0, updated = 0, skipped = 0;

        for (AuroraElement el : registry.getByType("Sub Race")) {
            String src = AuroraSourceMapper.toShortName(el.getSource());
            if ("PHB".equals(src) || !allowed.contains(src)) { skipped++; continue; }

            Race parent = findParentRace(el.getSupports());
            if (parent == null) {
                System.out.printf("[Aurora] Sub Race '%s' (%s): parent race not found for supports='%s'%n",
                    el.getName(), src, el.getSupports());
                skipped++;
                continue;
            }

            Subrace sub = subraceRepo.findByIndexName(el.getId()).orElse(new Subrace());
            boolean isNew = sub.getId() == null;

            sub.setIndexName(el.getId());
            sub.setName(el.getName());
            sub.setSource(src);
            sub.setDescription(el.getDescription());
            sub.setRace(parent);

            Map<String, Integer> subBonuses = extractAbilityBonuses(el);
            if (sub.getAbilityBonuses() == null) {
                sub.setAbilityBonuses(new LinkedHashMap<>(subBonuses));
            } else {
                sub.getAbilityBonuses().clear();
                sub.getAbilityBonuses().putAll(subBonuses);
            }

            sub.setTraits(extractTraits(el));

            subraceRepo.save(sub);
            if (isNew) created++; else updated++;
        }

        System.out.printf("[Aurora] Subraces: created=%d, updated=%d, skipped=%d%n", created, updated, skipped);
        return statsMap(created, updated, skipped);
    }

    // ── Extraction helpers ─────────────────────────────────────────────────────

    private int extractSpeed(AuroraElement el) {
        return el.getRules().stream()
            .filter(r -> r.getRuleType() == AuroraRule.RuleType.STAT
                      && "innate speed".equals(r.getName()))
            .findFirst()
            .map(r -> parseInt(r.getValue(), 30))
            .orElse(30);
    }

    private String extractSize(AuroraElement el) {
        return el.getRules().stream()
            .filter(r -> r.getRuleType() == AuroraRule.RuleType.GRANT
                      && "Size".equals(r.getType())
                      && r.getId() != null)
            .findFirst()
            .map(r -> {
                int i = r.getId().lastIndexOf('_');
                if (i < 0) return "Medium";
                String raw = r.getId().substring(i + 1); // "MEDIUM" → "Medium"
                return raw.charAt(0) + raw.substring(1).toLowerCase();
            })
            .orElse("Medium");
    }

    /**
     * Ability bonuses come from two places in Aurora:
     * 1. Direct <stat name="strength" value="2"/> on the race element itself.
     * 2. A granted Racial Trait named "Ability Score Increase" that has stat rules inside it.
     * Both sources are merged.
     */
    private Map<String, Integer> extractAbilityBonuses(AuroraElement el) {
        Map<String, Integer> bonuses = new LinkedHashMap<>();
        collectAbilityStats(el, bonuses);
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Racial Trait".equals(rule.getType()) || rule.getId() == null) continue;
            registry.resolve(rule.getId()).ifPresent(traitEl -> {
                if (traitEl.getName().contains("Ability Score")) {
                    collectAbilityStats(traitEl, bonuses);
                }
            });
        }
        return bonuses;
    }

    /**
     * True only when a race has NO fixed ability stat rules and instead relies entirely on a
     * player-choice ASI select (MoTM-style). VGtM/ERLW races have fixed <stat> rules AND an
     * optional Tasha's select — those must NOT be treated as flexible.
     */
    private boolean hasFlexibleAsi(AuroraElement el) {
        boolean hasAsiSelect = el.getRules().stream().anyMatch(r ->
            r.getRuleType() == AuroraRule.RuleType.SELECT
            && "Ability Score Improvement".equals(r.getType()));
        if (!hasAsiSelect) return false;
        boolean hasFixedAbilityBonus = el.getRules().stream().anyMatch(r ->
            r.getRuleType() == AuroraRule.RuleType.STAT
            && ABILITY_KEYS.containsKey(r.getName())
            && parseInt(r.getValue(), 0) > 0);
        return !hasFixedAbilityBonus;
    }

    private void collectAbilityStats(AuroraElement el, Map<String, Integer> bonuses) {
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.STAT) continue;
            String key = ABILITY_KEYS.get(rule.getName());
            if (key == null || rule.getValue() == null) continue;
            int val = parseInt(rule.getValue(), 0);
            if (val > 0) bonuses.merge(key, val, Integer::sum);
        }
    }

    private List<RacialTrait> extractTraits(AuroraElement el) {
        List<RacialTrait> traits = new ArrayList<>();
        Set<String> seen = new HashSet<>();

        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Racial Trait".equals(rule.getType()) || rule.getId() == null) continue;
            if (!seen.add(rule.getId())) continue; // same trait referenced twice

            // Reuse if already persisted, otherwise resolve from registry and save
            RacialTrait trait = traitRepo.findByIndexName(rule.getId())
                .orElseGet(() -> registry.resolve(rule.getId())
                    .map(this::buildAndSaveTrait)
                    .orElse(null));
            if (trait != null) traits.add(trait);
        }
        return traits;
    }

    private RacialTrait buildAndSaveTrait(AuroraElement el) {
        RacialTrait t = new RacialTrait();
        t.setIndexName(el.getId());
        t.setName(el.getName());
        String desc = (el.getDescription() != null && !el.getDescription().isBlank())
            ? el.getDescription() : el.getSheetDescription();
        t.setDescription(desc);
        t.setTraitType(classifyTrait(el));
        RacialTrait saved = traitRepo.save(t);
        grantTraitSpells(el, saved);
        return saved;
    }

    /**
     * Resolves any &lt;grant type="Spell"&gt; rule on the trait itself (e.g. Drow Magic's
     * Dancing Lights at 1st / Faerie Fire at 3rd / Darkness at 5th, Forest Gnome's Natural
     * Illusionist). Previously these were silently dropped for any non-PHB race — see
     * RacialTraitService.applyAutomaticRacialTraits for the generic fallback that now
     * consumes these rows.
     */
    private void grantTraitSpells(AuroraElement el, RacialTrait trait) {
        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.GRANT) continue;
            if (!"Spell".equals(rule.getType()) || rule.getId() == null) continue;

            Spell spell = spellResolver.resolve(rule.getId());
            if (spell == null) continue;

            int level = rule.getLevel() != null ? rule.getLevel() : 1;
            if (!traitSpellRepo.existsByRacialTraitAndSpell(trait, spell)) {
                traitSpellRepo.save(new RacialTraitSpell(trait, spell, level));
            }
        }
    }

    private String classifyTrait(AuroraElement el) {
        boolean hasChoice = el.getRules().stream()
            .anyMatch(r -> r.getRuleType() == AuroraRule.RuleType.SELECT);
        if (hasChoice) return "CHOICE_REQUIRED";
        String name = el.getName().toLowerCase();
        if (name.contains("attack") || name.contains("breath weapon")
            || name.contains("resistance") && !name.contains("poison resistance")) {
            return "COMBAT";
        }
        return "PASSIVE";
    }

    // ── Parent race lookup for Sub Races ───────────────────────────────────────

    private Race findParentRace(String supports) {
        if (supports == null || supports.isBlank()) return null;
        // Aurora "supports" on Sub Race = parent race name (e.g. "Elf", "Dwarf")
        // May be comma-separated: take first token
        String name = supports.split(",")[0].trim();
        List<Race> matches = raceRepo.findByName(name);
        if (matches.isEmpty()) return null;
        // Prefer the PHB race (existing DB) as parent when there are multiple (e.g. "Orc" from VGtM + MoTM)
        return matches.stream()
            .filter(r -> "PHB".equals(r.getSource()))
            .findFirst()
            .orElse(matches.get(0));
    }

    // ── Utilities ──────────────────────────────────────────────────────────────

    private Set<String> allowedSources() {
        return sourceRepo.findAll().stream()
            .map(ContentSource::getShortName)
            .filter(s -> !"PHB".equals(s))
            .collect(Collectors.toSet());
    }

    private int parseInt(String s, int def) {
        if (s == null || s.isBlank()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private Map<String, Object> statsMap(int created, int updated, int skipped) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("created", created);
        m.put("updated", updated);
        m.put("skipped", skipped);
        return m;
    }
}
