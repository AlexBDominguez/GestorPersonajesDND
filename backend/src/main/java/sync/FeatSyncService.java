package sync;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import entities.Feat;
import repositories.FeatRepository;

@Service
public class FeatSyncService {

    private final FeatRepository featRepository;
    public final RestTemplate restTemplate;

    private final String BASE_URL = "https://www.dnd5eapi.co/api/feats";

    public FeatSyncService(FeatRepository featRepository, RestTemplate restTemplate) {
        this.featRepository = featRepository;
        this.restTemplate = restTemplate;
    }

    public void syncFeats() {
        System.out.println("Starting feat synchronization...");

        // Obtener lista de todos los feats
        Map<String, Object> response = restTemplate.getForObject(BASE_URL, Map.class);
        List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");

        for (Map<String, Object> featSummary: results) {
            String index = (String) featSummary.get("index");

            //Verificar si ya existe
            if (featRepository.findByIndexName(index).isPresent()) {
                System.out.println("Feat already exists, skipping: " + index);
                continue;
            }

            ApiRateLimiter.waitBetweenRequests();

            //Obtener detalles del feat
            Map<String, Object> detail = restTemplate.getForObject(BASE_URL + "/" + index, Map.class);

            Feat feat = new Feat();
            feat.setIndexName(index);
            feat.setName((String) detail.get("name"));

            //Descripción (array de strings)
            List<String> descList = (List<String>) detail.get("desc");
            if(descList != null && !descList.isEmpty()) {
                feat.setDescription(String.join("\n", descList));
            }

            //Prerequisites (array de strings o de objetos)
            List<String> prerequisites = new ArrayList<>();
            Object prereqObject = detail.get("prerequisites");

            if(prereqObject instanceof List) {
                List<Object> prereqList = (List<Object>) prereqObject;
                for(Object prereq : prereqList) {
                    if(prereq instanceof Map) {
                        Map<String, Object> prereqMap = (Map<String, Object>) prereq;

                        // Puede tener "ability_score" con "minimum"
                        if (prereqMap.containsKey("ability_score")) {
                            Map<String, Object> abilityScore = (Map<String, Object>) prereqMap.get("ability_score");
                            String abilityName = (String) abilityScore.get("name");
                            Integer minimum = (Integer) prereqMap.get("minimum_score");
                            prerequisites.add(abilityName + " " + minimum + " or higher");
                        }

                        // Puede tener "proficiency" o "level"
                        if (prereqMap.containsKey("type")) {
                            String type = (String) prereqMap.get("type");
                            prerequisites.add(type);
                        }
                    } else if (prereq instanceof String) {
                        prerequisites.add((String) prereq);
                    }
                }
            }
            
            if (!prerequisites.isEmpty()) {
                feat.setPrerequisites(prerequisites);
            }

            featRepository.save(feat);
            System.out.println("Saved feat: " + feat.getName());
        }

        System.out.println("Feat synchronization completed.");
    }
}
