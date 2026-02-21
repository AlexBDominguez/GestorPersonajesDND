package sync;


import entities.Spell;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.SpellRepository;

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

        Map response = restTemplate.getForObject(BASE_URL, Map.class);

        var results = (java.util.List<Map<String, Object>>) response.get("results");

        for (Map<String, Object> spellData : results) {

            String index = (String) spellData.get("index");

            if (spellRepository.findByIndexApi(index).isEmpty()) {

                Spell spell = new Spell();
                spell.setIndexApi(index);
                spell.setName((String) spellData.get("name"));
                spell.setLevel(0); // De momento simplificado

                spellRepository.save(spell);
            }
        }
    }
}
