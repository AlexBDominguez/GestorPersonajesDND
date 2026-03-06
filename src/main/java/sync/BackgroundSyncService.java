package sync;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import entities.Background;
import repositories.BackgroundRepository;

@Service
public class BackgroundSyncService {
    
    private final RestTemplate restTemplate;
    private final BackgroundRepository backgroundRepository;

    private static final String API_URL = "https://www.dnd5eapi.co/api/backgrounds";

    public BackgroundSyncService(RestTemplate restTemplate, BackgroundRepository backgroundRepository) {
        this.restTemplate = restTemplate;
        this.backgroundRepository = backgroundRepository;
    }

    public void syncBackgrounds() {
        System.out.println("=== Starting background synchronization ===");

        Map response = restTemplate.getForObject(API_URL, Map.class);
        List<Map<String, String>> results = (List<Map<String, String>>) response.get("results");

        for (Map<String, String> bgInfo : results) {
            String indexName = bgInfo.get("index");
            String detailUrl = "https://www.dnd5eapi.co" + bgInfo.get("url");

            ApiRateLimiter.waitBetweenRequests();

            Map detailed = restTemplate.getForObject(detailUrl, Map.class);

            if (detailed == null) {
                System.out.println("Failed to fetch details for background: " + indexName);
                continue;
            }

            String name = (String) detailed.get("name");

            //Skill proficiencies
            List<String> skillProficiencies = new ArrayList<>();
            if (detailed.containsKey("starting_proficiencies")) {
                List<Map<String, String>> profList = (List<Map<String, String>>) detailed.get("starting_proficiencies");
                for (Map<String, String> prof : profList) {
                    skillProficiencies.add(prof.get("index"));
                }
            }

            //Language options
            int languageOptions = 0;
            List<String> languages = new ArrayList<>();
            if (detailed.containsKey("languages_options")) {
                Map langOptions = (Map) detailed.get("languages_options");
                if(langOptions.containsKey("choose")){
                    languageOptions = (int) langOptions.get("choose");
                }
            }

            //Feature
            String feature = "";
            String featureDescription = null;
            if (detailed.containsKey("feature")){
                Map featureData = (Map) detailed.get("feature");
                feature = (String) featureData.get("name");
                if (featureData.containsKey("desc")){
                    List<String> descList = (List<String>) featureData.get("desc");
                    featureDescription = String.join("\n", descList);
                }
            }

            //Personality traits
            List<String> personalityTraits = extractCharacteristics(detailed, "personality_traits");
            List<String> ideals = extractCharacteristics(detailed, "ideals");
            List<String> bonds = extractCharacteristics(detailed, "bonds");
            List<String> flaws = extractCharacteristics(detailed, "flaws");

            //Guardar o actualizar
            Background background = backgroundRepository.findByIndexName(indexName)
                    .orElseGet(() -> new Background());
            
            background.setIndexName(indexName);
            background.setName(name);
            background.setSkillProficiencies(skillProficiencies);
            background.setLanguages(languages);
            background.setLanguageOptions(languageOptions);
            background.setFeature(feature);
            background.setFeatureDescription(featureDescription);
            background.setPersonalityTraits(personalityTraits);
            background.setIdeals(ideals);
            background.setBonds(bonds);
            background.setFlaws(flaws);
            background.setDescription("Imported from D&D 5e API");

            backgroundRepository.save(background);

            System.out.println("Synchronized background: " + name);
        }

        System.out.println("=== Backgrounds synchronization completed ===");
    }

   private List<String> extractCharacteristics(Map detailed, String key) {
        List<String> result = new ArrayList<>();

        if (detailed.containsKey(key)) {
            Map characteristics = (Map) detailed.get(key);
            if (characteristics.containsKey("from")) {
                Map fromData = (Map) characteristics.get("from");
                if (fromData.containsKey("options")) {
                    List<Map<String, Object>> options = (List<Map<String, Object>>) fromData.get("options");
                    for (Map<String, Object> option : options) {
                        if (option.containsKey("string")) {
                            result.add((String) option.get("string"));
                        } else if (option.containsKey("desc")) {
                            result.add((String) option.get("desc"));
                        }
                    }
                }
            }
        }

        return result;
    }
}