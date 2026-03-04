package sync;


import entities.Spell;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.SpellRepository;
import java.util.List; 
import java.util.Map;

@Service
public class SpellSyncService {

    private final SpellRepository spellRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    private final String BASE_URL = "https://www.dnd5eapi.co/api/spells";

    public SpellSyncService(SpellRepository spellRepository) {
        this.spellRepository = spellRepository;
    }

    public void syncSpells() {

        Map<String, Object> response = restTemplate.getForObject(BASE_URL, Map.class);
        List<Map<String, Object>> results =
                (List<Map<String, Object>>) response.get("results");

        for (Map<String, Object> spellSummary : results) {

            String index = (String) spellSummary.get("index");

            if (spellRepository.findByIndexApi(index).isPresent()) {
                continue;
            }

            // Llamada detalle
            Map<String, Object> detail =
                    restTemplate.getForObject(BASE_URL + "/" + index, Map.class);

            Spell spell = new Spell();

            spell.setIndexApi(index);
            spell.setName((String) detail.get("name"));
            spell.setLevel((Integer) detail.get("level"));

            // School
            Map<String, Object> school =
                    (Map<String, Object>) detail.get("school");
            if (school != null) {
                spell.setSchool((String) school.get("name"));
            }

            spell.setCastingTime((String) detail.get("casting_time"));
            spell.setRange((String) detail.get("range"));
            spell.setDuration((String) detail.get("duration"));

            // Components (array → string)
            List<String> components =
                    (List<String>) detail.get("components");
            if (components != null) {
                spell.setComponents(String.join(", ", components));
            }

            // Description (array → texto largo)
            List<String> descList =
                    (List<String>) detail.get("desc");
            if (descList != null) {
                spell.setDescription(String.join("\n", descList));
            }

            spellRepository.save(spell);
        }

        System.out.println("Spells synchronized correctly.");
    }
}


