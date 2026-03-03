package sync;

import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import entities.DndClass;
import repositories.DndClassRepository;
import repositories.SpellSlotProgressionRepository;

@Service
public class SpellSlotSyncService {
    
    private final RestTemplate restTemplate;
    private final SpellSlotProgressionRepository progressionRepository;
    private final DndClassRepository classRepository;

    private final String BASE_URL = "https://www.dnd5eapi.co/api/classes/";


    public SpellSlotSyncService(RestTemplate restTemplate,
                                SpellSlotProgressionRepository progressionRepository,
                                DndClassRepository classRepository) {
        
        this.restTemplate = restTemplate;
        this.progressionRepository = progressionRepository;
        this.classRepository = classRepository;
    }
    
    public void syncSpellSlotForClass(String classIndex){
        DndClass dndClass = classRepository.findByIndexApi(classIndex);
        if(dndClass == null){
            throw new RuntimeException("Class not found: " + classIndex);
        }

        String url = BASE_URL + classIndex + "levels";

        Object[] levels = restTemplate.getForObject(url, Object[].class);

        for (Object levelObj: levels){
            Map<String, Object> levelMap = (Map<String, Object>) levelObj;

            Integer characterLevel = (Integer) levelMap.get("level");

            if(levelMap.containsKey("spellcasting")){
                Map<String, Object> spellcasting = 
                    (Map<String, Object>) levelMap.get("spellcasting");

                for (int spellLevel = 1, spellLevel <= 9; spellLevel++){
                    String key = "spell_slots_level_" + spellLevel;
                    if (spellcasting.containsKey(key){

                        Integer slots = (Integer) spellcasting.get(key);

                        if (slots != null && slots > 0){
                            // Guardar en la base de datos
                            SpellSlotProgression progression = new SpellSlotProgression();
                            progression.setDndClass(dndClass);
                            progression.setCharacterLevel(characterLevel);
                            progression.setSpellLevel(spellLevel);
                            progression.setSlots(slots);

                            progressionRepository.save(progression);
                        }
                    }
                }
            }
        }
    }
}
