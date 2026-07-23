package sync;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sync.aurora.AuroraBackgroundMapper;
import sync.aurora.AuroraClassFeatureMapper;
import sync.aurora.AuroraClassMapper;
import sync.aurora.AuroraFeatMapper;
import sync.aurora.AuroraItemMapper;
import sync.aurora.AuroraRaceMapper;
import sync.aurora.AuroraRegistry;
import sync.aurora.AuroraSpellMapper;
import sync.aurora.AuroraSubclassMapper;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Public endpoints (whitelisted via /api/sync/** in SecurityConfig) for driving
 * the Aurora Legacy Elements sync pipeline.
 */
@RestController
@RequestMapping("/api/sync/aurora")
public class AuroraSyncController {

    private final AuroraSyncService auroraSync;
    private final AuroraRaceMapper raceMapper;
    private final AuroraBackgroundMapper backgroundMapper;
    private final AuroraFeatMapper featMapper;
    private final AuroraSpellMapper spellMapper;
    private final AuroraSubclassMapper subclassMapper;
    private final AuroraClassMapper classMapper;
    private final AuroraClassFeatureMapper classFeatureMapper;
    private final AuroraItemMapper itemMapper;

    public AuroraSyncController(AuroraSyncService auroraSync,
                                AuroraRaceMapper raceMapper,
                                AuroraBackgroundMapper backgroundMapper,
                                AuroraFeatMapper featMapper,
                                AuroraSpellMapper spellMapper,
                                AuroraSubclassMapper subclassMapper,
                                AuroraClassMapper classMapper,
                                AuroraClassFeatureMapper classFeatureMapper,
                                AuroraItemMapper itemMapper) {
        this.auroraSync = auroraSync;
        this.raceMapper = raceMapper;
        this.backgroundMapper = backgroundMapper;
        this.featMapper = featMapper;
        this.spellMapper = spellMapper;
        this.subclassMapper = subclassMapper;
        this.classMapper = classMapper;
        this.classFeatureMapper = classFeatureMapper;
        this.itemMapper = itemMapper;
    }

    /**
     * Fetch all XML files from AuroraLegacy/elements on GitHub, parse them, and
     * index every element in the in-memory registry.  Runs synchronously (~30-90s).
     *
     * POST /api/sync/aurora/fetch
     */
    @PostMapping("/fetch")
    public ResponseEntity<Map<String, Object>> fetch() {
        return ResponseEntity.ok(auroraSync.fetchAndIndex());
    }

    /**
     * Returns statistics from the last completed fetch: element counts by type and
     * by source book.  Returns immediately from in-memory state.
     *
     * GET /api/sync/aurora/status
     */
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> status() {
        return ResponseEntity.ok(auroraSync.getStatus());
    }

    /**
     * Persists all non-PHB races and subraces from the in-memory registry to the database.
     * Requires a prior call to POST /fetch to populate the registry.
     *
     * POST /api/sync/aurora/persist/races
     */
    @PostMapping("/persist/races")
    public ResponseEntity<Map<String, Object>> persistRaces() {
        return ResponseEntity.ok(raceMapper.sync());
    }

    /**
     * Persists all non-PHB backgrounds from the in-memory registry to the database.
     *
     * POST /api/sync/aurora/persist/backgrounds
     */
    @PostMapping("/persist/backgrounds")
    public ResponseEntity<Map<String, Object>> persistBackgrounds() {
        return ResponseEntity.ok(backgroundMapper.sync());
    }

    /**
     * Persists all non-PHB feats from the in-memory registry to the database.
     *
     * POST /api/sync/aurora/persist/feats
     */
    @PostMapping("/persist/feats")
    public ResponseEntity<Map<String, Object>> persistFeats() {
        return ResponseEntity.ok(featMapper.sync());
    }

    /**
     * Persists all non-PHB spells from the in-memory registry to the database.
     *
     * POST /api/sync/aurora/persist/spells
     */
    @PostMapping("/persist/spells")
    public ResponseEntity<Map<String, Object>> persistSpells() {
        return ResponseEntity.ok(spellMapper.sync());
    }

    /**
     * Persists all non-PHB subclasses and their features from the in-memory registry.
     *
     * POST /api/sync/aurora/persist/subclasses
     */
    @PostMapping("/persist/subclasses")
    public ResponseEntity<Map<String, Object>> persistSubclasses() {
        return ResponseEntity.ok(subclassMapper.sync());
    }

    /**
     * Persists all non-PHB classes (e.g. Artificer) from the in-memory registry.
     *
     * POST /api/sync/aurora/persist/classes
     */
    @PostMapping("/persist/classes")
    public ResponseEntity<Map<String, Object>> persistClasses() {
        return ResponseEntity.ok(classMapper.sync());
    }

    /**
     * Persists class features for non-PHB classes (e.g. Artificer levels 1-20).
     * Requires persist/classes to have run first so the parent DndClass rows exist.
     *
     * POST /api/sync/aurora/persist/class-features
     */
    @PostMapping("/persist/class-features")
    public ResponseEntity<Map<String, Object>> persistClassFeatures() {
        return ResponseEntity.ok(classFeatureMapper.sync());
    }

    /**
     * Persists all non-PHB weapons, armor, magic items and adventuring gear.
     *
     * POST /api/sync/aurora/persist/items
     */
    @PostMapping("/persist/items")
    public ResponseEntity<Map<String, Object>> persistItems() {
        return ResponseEntity.ok(itemMapper.sync());
    }

    /**
     * Returns all currently indexed elements of a given Aurora type.
     * Useful for inspecting the parsed data before committing to mappers.
     * Optional "name" filters to elements whose name contains it (case-insensitive).
     *
     * GET /api/sync/aurora/elements?type=Race
     * GET /api/sync/aurora/elements?type=Magic Item&name=blade
     */
    @GetMapping("/elements")
    public ResponseEntity<List<Map<String, Object>>> elements(@RequestParam String type,
                                                               @RequestParam(required = false) String name) {
        AuroraRegistry registry = auroraSync.getRegistry();
        List<Map<String, Object>> result = registry.getByType(type).stream()
            .filter(el -> name == null || (el.getName() != null && el.getName().toLowerCase().contains(name.toLowerCase())))
            .map(el -> {
                Map<String, Object> m = new java.util.LinkedHashMap<>();
                m.put("id", el.getId());
                m.put("name", el.getName());
                m.put("type", el.getType());
                m.put("source", el.getSource());
                m.put("supports", el.getSupports());
                m.put("requirements", el.getRequirements());
                m.put("setters", el.getSetters());
                m.put("rules", el.getRules());
                return m;
            })
            .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }
}
