package sync;

import entities.Race;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.RaceRepository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class RaceSyncService {

    private final RaceRepository raceRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    public RaceSyncService(RaceRepository raceRepository) {
        this.raceRepository = raceRepository;
    }

    public void syncRaces() {
        String url = "https://www.dnd5eapi.co/api/races";
        Map response = restTemplate.getForObject(url, Map.class);

        List<Map<String, String>> results = (List<Map<String, String>>) response.get("results");

        for (Map<String, String> raceInfo : results) {
            String indexName = raceInfo.get("index");

            Map detailed = restTemplate.getForObject(
                    "https://www.dnd5eapi.co/api/races/" + indexName,
                    Map.class
            );

            Race race = raceRepository.findByIndexName(indexName)
                    .orElse(new Race());

            race.setIndexName(indexName);
            race.setName((String) detailed.get("name"));
            race.setSize((String) detailed.get("size"));
            race.setSpeed((int) detailed.get("speed"));

            // ability bonuses
            List<Map<String, Object>> bonuses = (List<Map<String, Object>>) detailed.get("ability_bonuses");
            Map<String, Integer> bonusMap = new HashMap<>();
            for (Map<String, Object> b : bonuses) {
                Map ability = (Map) b.get("ability_score");
                bonusMap.put((String) ability.get("index"), (Integer) b.get("bonus"));
            }
            race.setAbilityBonuses(bonusMap);

            // description
            List<String> desc = (List<String>) detailed.get("desc");
            race.setDescription(String.join("\n", desc));

            raceRepository.save(race);
        }
    }
}