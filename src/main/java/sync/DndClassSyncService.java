package sync;

import entities.ClassFeature;
import entities.DndClass;
import entities.SpellSlotProgression;
import jakarta.transaction.Transactional;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import repositories.ClassFeatureRepository;
import repositories.DndClassRepository;
import repositories.SpellSlotProgressionRepository;

import java.util.List;
import java.util.Map;

@Service
public class DndClassSyncService {

    private final RestTemplate restTemplate;
    private final DndClassRepository repository;
    private final SpellSlotProgressionRepository slotProgressionRepository;
    private final ClassFeatureRepository classFeatureRepository;

    private static final String API_URL = "https://www.dnd5eapi.co/api/classes";

    public DndClassSyncService(RestTemplate restTemplate, 
                                DndClassRepository repository,
                                SpellSlotProgressionRepository slotProgressionRepository,
                                ClassFeatureRepository classFeatureRepository) {
        this.restTemplate = restTemplate;
        this.repository = repository;
        this.slotProgressionRepository = slotProgressionRepository;
        this.classFeatureRepository = classFeatureRepository;
    }

    @Service
public class DndClassSyncService {

    private final RestTemplate restTemplate;
    private final DndClassRepository repository;
    private final SpellSlotProgressionRepository slotProgressionRepository;
    private final ClassFeatureRepository classFeatureRepository;

    private static final String API_URL = "https://www.dnd5eapi.co/api/classes";

    public DndClassSyncService(RestTemplate restTemplate, 
                                DndClassRepository repository,
                                SpellSlotProgressionRepository slotProgressionRepository,
                                ClassFeatureRepository classFeatureRepository) {
        this.restTemplate = restTemplate;
        this.repository = repository;
        this.slotProgressionRepository = slotProgressionRepository;
        this.classFeatureRepository = classFeatureRepository;
    }

    @Transactional
    public void syncClasses(){
        // Obtener lista de clases
        Map response = restTemplate.getForObject(API_URL, Map.class);
        List<Map<String, String>> results = (List<Map<String, String>>) response.get("results");

        for (Map<String, String> cls : results){
            String indexName = cls.get("index");
            
            String detailUrl = "https://www.dnd5eapi.co/api/classes/" + indexName;

            // Obtener datos detallados
            Map detailed = restTemplate.getForObject(detailUrl, Map.class);

            if (detailed == null) continue;

            String name = (String) detailed.get("name");
            int hitDie = (int) detailed.get("hit_die");

            // Proficiencies
            List<Map<String, String>> proficienciesRaw = 
                (List<Map<String, String>>) detailed.get("proficiencies");
            List<String> proficiencies = proficienciesRaw.stream()
                    .map(p -> p.get("name"))
                    .toList();

            // Saving throws
            List<Map<String, String>> savingThrowsRaw = 
                (List<Map<String, String>>) detailed.get("saving_throws");
            List<String> savingThrows = savingThrowsRaw.stream()
                    .map(st -> st.get("index"))
                    .toList();

            // Spellcasting ability
            String spellcastingAbility = null;
            Integer subclassLevel = null;
            
            if (detailed.containsKey("spellcasting")) {
                Map spellcastingData = (Map) detailed.get("spellcasting");
                Map abilityScore = (Map) spellcastingData.get("spellcasting_ability");
                if (abilityScore != null) {
                    spellcastingAbility = (String) abilityScore.get("index");
                }
            }

            // Subclass level
            if (detailed.containsKey("subclasses")) {
                List subclassList = (List) detailed.get("subclasses");
                if (!subclassList.isEmpty()) {
                    subclassLevel = 3;
                }
            }

            // Guardar o actualizar en la base de datos
            DndClass existing = repository.findByIndexName(indexName)
                    .orElse(new DndClass());

            existing.setIndexName(indexName);
            existing.setName(name);
            existing.setHitDie(hitDie);
            existing.setProficiencies(proficiencies);
            existing.setSavingThrows(savingThrows);
            existing.setSpellcastingAbility(spellcastingAbility);
            existing.setSubclassLevel(subclassLevel);
            existing.setDescription("Imported from D&D 5e API");

            DndClass savedClass = repository.save(existing);

            // Sincronizar spell slot progression
            if (spellcastingAbility != null) {
                syncSpellSlotProgression(savedClass, indexName);
            }

            // NUEVO: Sincronizar class features
            syncClassFeatures(savedClass, indexName);
        }
        
        System.out.println("Classes synchronized successfully!");
    }

    private void syncSpellSlotProgression(DndClass dndClass, String indexName) {
        String levelsUrl = "https://www.dnd5eapi.co/api/classes/" + indexName + "/levels";
        List<Map> levels = restTemplate.getForObject(levelsUrl, List.class);

        if (levels == null) return;

        for (Map levelData : levels) {
            int characterLevel = (int) levelData.get("level");
            
            if (!levelData.containsKey("spellcasting")) continue;
            
            Map spellcasting = (Map) levelData.get("spellcasting");
            
            // Limpiar progresiones anteriores de este nivel
            slotProgressionRepository.deleteByDndClassAndCharacterLevel(dndClass, characterLevel);
            
            // Guardar slots por cada nivel de hechizo (1-9)
            for (int spellLevel = 1; spellLevel <= 9; spellLevel++) {
                String slotKey = "spell_slots_level_" + spellLevel;
                
                if (spellcasting.containsKey(slotKey)) {
                    int slots = (int) spellcasting.get(slotKey);
                    
                    if (slots > 0) {
                        SpellSlotProgression progression = new SpellSlotProgression();
                        progression.setDndClass(dndClass);
                        progression.setCharacterLevel(characterLevel);
                        progression.setSpellLevel(spellLevel);
                        progression.setSlots(slots);
                        
                        slotProgressionRepository.save(progression);
                    }
                }
            }
        }
    }

    private void syncClassFeatures(DndClass dndClass, String indexName) {
        String levelsUrl = "https://www.dnd5eapi.co/api/classes/" + indexName + "/levels";
        List<Map> levels = restTemplate.getForObject(levelsUrl, List.class);

        if (levels == null) return;

        for (Map levelData : levels) {
            int characterLevel = (int) levelData.get("level");
            
            // Obtener features de este nivel
            if (!levelData.containsKey("features")) continue;
            
            List<Map<String, String>> features = (List<Map<String, String>>) levelData.get("features");
            
            for (Map<String, String> featureRef : features) {
                String featureIndex = featureRef.get("index");
                String featureName = featureRef.get("name");
                String featureUrl = featureRef.get("url");
                
                // Comprobar si ya existe esta feature
                ClassFeature existing = classFeatureRepository.findByIndexName(featureIndex)
                        .orElse(new ClassFeature());
                
                existing.setDndClass(dndClass);
                existing.setIndexName(featureIndex);
                existing.setName(featureName);
                existing.setLevel(characterLevel);
                existing.setApiUrl("https://www.dnd5eapi.co" + featureUrl);
                
                // Obtener descripción detallada (opcional, puede ser lento)
                try {
                    Map featureDetail = restTemplate.getForObject(
                        "https://www.dnd5eapi.co" + featureUrl, 
                        Map.class
                    );
                    
                    if (featureDetail != null && featureDetail.containsKey("desc")) {
                        List<String> descLines = (List<String>) featureDetail.get("desc");
                        existing.setDescription(String.join("\n", descLines));
                    }
                } catch (Exception e) {
                    System.err.println("Error fetching feature detail for: " + featureName);
                    existing.setDescription("Feature obtained at level " + characterLevel);
                }
                
                classFeatureRepository.save(existing);
            }
        }
        
        System.out.println("Features synced for class: " + dndClass.getName());
    }
}
