package sync;

import entities.Skill;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.SkillRepository;
import java.util.List;
import java.util.Map;


@Service
public class SkillSyncService {

    private final RestTemplate restTemplate;
    private final SkillRepository skillRepository;

    private static final String API_URL = "https://www.dnd5eapi.co/api/skills";

    public SkillSyncService(RestTemplate restTemplate, SkillRepository skillRepository) {
        this.restTemplate = restTemplate;
        this.skillRepository = skillRepository;
    }

    public void syncSkills() {
        System.out.println("=== Starting skill synchronization ===");

        Map response= restTemplate.getForObject(API_URL, Map.class);
        List<Map<String, String>> results = (List<Map<String, String>>) response.get("results");   

        for (Map<String, String> skillInfo : results) {
            String indexName = skillInfo.get("index");
            String detailUrl = "https://www.dnd5eapi.co" + skillInfo.get("url");

            ApiRateLimiter.waitBetweenRequests();

            Map detailed = restTemplate.getForObject(detailUrl, Map.class);

            if(detailed == null) {
                System.err.println("Failed to fetch details for skill: " + indexName);
                continue;
            }

            String name = (String) detailed.get("name");
            Map abilityScore = (Map) detailed.get("ability_score");
            String abilityScoreIndex = (String) abilityScore.get("index");

            List<String> descList = (List<String>) detailed.get("desc");
            String description = descList != null ? String.join("\n", descList) : "";

            Skill skill = skillRepository.findByIndexName(indexName)
                    .orElse(new Skill());

            skill.setIndexName(indexName);
            skill.setName(name);
            skill.setAbilityScore(abilityScoreIndex);
            skill.setDescription(description);

            skillRepository.save(skill);

            System.out.println("✓ Synced skill: " + name + " (" + abilityScoreIndex.toUpperCase() + ")");
        }

        System.out.println("=== Skill synchronization complete ===");


    }
    
}
