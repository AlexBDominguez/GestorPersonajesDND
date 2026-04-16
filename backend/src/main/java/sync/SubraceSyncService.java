package sync;

import entities.Race;
import entities.Subrace;
import repositories.RaceRepository;
import repositories.SubraceRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class SubraceSyncService {

    private final SubraceRepository subraceRepository;
    private final RaceRepository raceRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    public SubraceSyncService(SubraceRepository subraceRepository, RaceRepository raceRepository) {
        this.subraceRepository = subraceRepository;
        this.raceRepository = raceRepository;
    }

    @SuppressWarnings("unchecked")
    public void syncSubraces() {
        String listUrl = "https://www.dnd5eapi.co/api/subraces";
        Map<String, Object> listResponse = restTemplate.getForObject(listUrl, Map.class);
        if (listResponse == null) return;

        List<Map<String, String>> results = (List<Map<String, String>>) listResponse.get("results");
        if (results == null) return;

        System.out.println("  Syncing " + results.size() + " subraces...");

        for (Map<String, String> info : results) {
            String indexName = info.get("index");
            ApiRateLimiter.waitBetweenRequests();

            try {
                Map<String, Object> detailed = restTemplate.getForObject(
                        "https://www.dnd5eapi.co/api/subraces/" + indexName, Map.class);
                if (detailed == null) continue;

                // Find parent race
                Map<String, Object> raceRef = (Map<String, Object>) detailed.get("race");
                if (raceRef == null) continue;
                String raceIndex = (String) raceRef.get("index");
                Optional<Race> raceOpt = raceRepository.findByIndexName(raceIndex);
                if (raceOpt.isEmpty()) {
                    System.out.println("  Skipping subrace " + indexName + ": race '" + raceIndex + "' not found in DB");
                    continue;
                }

                Subrace subrace = subraceRepository.findByIndexName(indexName)
                        .orElse(new Subrace());

                subrace.setIndexName(indexName);
                subrace.setName((String) detailed.get("name"));
                subrace.setRace(raceOpt.get());

                // Description is a plain string in the API (v2014)
                Object descRaw = detailed.get("desc");
                String description = "";
                if (descRaw instanceof String) {
                    description = (String) descRaw;
                } else if (descRaw instanceof List) {
                    description = String.join("\n", (List<String>) descRaw);
                }
                subrace.setDescription(description);

                // Ability bonuses: [{ability_score: {index: "str"}, bonus: 2}, ...]
                List<Map<String, Object>> bonuses = (List<Map<String, Object>>) detailed.get("ability_bonuses");
                Map<String, Integer> bonusMap = new HashMap<>();
                if (bonuses != null) {
                    for (Map<String, Object> b : bonuses) {
                        Map<String, Object> ability = (Map<String, Object>) b.get("ability_score");
                        if (ability != null) {
                            bonusMap.put((String) ability.get("index"), ((Number) b.get("bonus")).intValue());
                        }
                    }
                }
                subrace.setAbilityBonuses(bonusMap);

                // Racial traits: [{index, name, url}, ...]
                List<Map<String, Object>> traits = (List<Map<String, Object>>) detailed.get("racial_traits");
                List<String> traitNames = new ArrayList<>();
                if (traits != null) {
                    for (Map<String, Object> t : traits) {
                        String tName = (String) t.get("name");
                        if (tName != null) traitNames.add(tName);
                    }
                }
                subrace.setTraits(traitNames);

                subraceRepository.save(subrace);
                System.out.println("  Saved subrace: " + subrace.getName());

            } catch (Exception e) {
                System.err.println("  Error syncing subrace " + indexName + ": " + e.getMessage());
            }
        }

        System.out.println("  Subrace sync complete.");
    }
}
