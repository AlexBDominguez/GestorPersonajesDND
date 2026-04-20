package sync;

import entities.Race;
import entities.RacialTrait;
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
    private final RaceSyncService raceSyncService; // reutilizamos syncTrait()
    private final RestTemplate restTemplate = new RestTemplate();

    public SubraceSyncService(SubraceRepository subraceRepository,
                              RaceRepository raceRepository,
                              RaceSyncService raceSyncService) {
        this.subraceRepository = subraceRepository;
        this.raceRepository = raceRepository;
        this.raceSyncService = raceSyncService;
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

                Map<String, Object> raceRef = (Map<String, Object>) detailed.get("race");
                if (raceRef == null) continue;
                String raceIndex = (String) raceRef.get("index");
                Optional<Race> raceOpt = raceRepository.findByIndexName(raceIndex);
                if (raceOpt.isEmpty()) {
                    System.out.println("  Skipping subrace " + indexName + ": race '" + raceIndex + "' not found");
                    continue;
                }

                Subrace subrace = subraceRepository.findByIndexName(indexName).orElse(new Subrace());
                subrace.setIndexName(indexName);
                subrace.setName((String) detailed.get("name"));
                subrace.setRace(raceOpt.get());

                Object descRaw = detailed.get("desc");
                if (descRaw instanceof String) subrace.setDescription((String) descRaw);
                else if (descRaw instanceof List) subrace.setDescription(String.join("\n", (List<String>) descRaw));
                else subrace.setDescription("");

                // Ability bonuses
                List<Map<String, Object>> bonuses = (List<Map<String, Object>>) detailed.get("ability_bonuses");
                Map<String, Integer> bonusMap = new HashMap<>();
                if (bonuses != null) {
                    for (Map<String, Object> b : bonuses) {
                        Map<String, Object> ability = (Map<String, Object>) b.get("ability_score");
                        if (ability != null)
                            bonusMap.put((String) ability.get("index"), ((Number) b.get("bonus")).intValue());
                    }
                }
                subrace.setAbilityBonuses(bonusMap);

                // Racial traits — reutilizamos syncTrait del RaceSyncService
                List<Map<String, Object>> traitRefs = (List<Map<String, Object>>) detailed.get("racial_traits");
                List<RacialTrait> traitEntities = new ArrayList<>();
                if (traitRefs != null) {
                    for (Map<String, Object> ref : traitRefs) {
                        String traitIndex = (String) ref.get("index");
                        RacialTrait trait = raceSyncService.syncTrait(traitIndex);
                        if (trait != null) traitEntities.add(trait);
                    }
                }
                subrace.setTraits(traitEntities);

                subraceRepository.save(subrace);
                System.out.println("  Synced subrace: " + indexName + " with " + traitEntities.size() + " traits");

            } catch (Exception e) {
                System.out.println("  Error syncing subrace " + indexName + ": " + e.getMessage());
            }
        }
    }
}