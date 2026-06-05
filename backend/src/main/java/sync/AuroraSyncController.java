package sync;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sync.aurora.AuroraBackgroundMapper;
import sync.aurora.AuroraFeatMapper;
import sync.aurora.AuroraRaceMapper;
import sync.aurora.AuroraRegistry;

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

    public AuroraSyncController(AuroraSyncService auroraSync,
                                AuroraRaceMapper raceMapper,
                                AuroraBackgroundMapper backgroundMapper,
                                AuroraFeatMapper featMapper) {
        this.auroraSync = auroraSync;
        this.raceMapper = raceMapper;
        this.backgroundMapper = backgroundMapper;
        this.featMapper = featMapper;
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
     * Returns all currently indexed elements of a given Aurora type.
     * Useful for inspecting the parsed data before committing to mappers.
     *
     * GET /api/sync/aurora/elements?type=Race
     */
    @GetMapping("/elements")
    public ResponseEntity<List<Map<String, Object>>> elements(@RequestParam String type) {
        AuroraRegistry registry = auroraSync.getRegistry();
        List<Map<String, Object>> result = registry.getByType(type).stream()
            .map(el -> {
                Map<String, Object> m = new java.util.LinkedHashMap<>();
                m.put("id", el.getId());
                m.put("name", el.getName());
                m.put("type", el.getType());
                m.put("source", el.getSource());
                m.put("supports", el.getSupports());
                m.put("requirements", el.getRequirements());
                m.put("ruleCount", el.getRules().size());
                m.put("setters", el.getSetters());
                return m;
            })
            .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }
}
