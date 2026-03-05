package sync;

import entities.ClassFeature;
import entities.ClassLevelFeature;
import entities.ClassLevelProgression;
import entities.DndClass;
import entities.SpellSlotProgression;
import enumeration.FeatureType;
import jakarta.transaction.Transactional;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.ClassFeatureRepository;
import repositories.ClassLevelFeatureRepository;
import repositories.ClassLevelProgressionRepository;
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
    private final ClassLevelProgressionRepository classLevelProgressionRepository;
    private final ClassLevelFeatureRepository classLevelFeatureRepository;

    private static final String API_URL = "https://www.dnd5eapi.co/api/classes";

    public DndClassSyncService(RestTemplate restTemplate, 
                                DndClassRepository repository,
                                SpellSlotProgressionRepository slotProgressionRepository,
                                ClassFeatureRepository classFeatureRepository,
                                ClassLevelProgressionRepository classLevelProgressionRepository,
                                ClassLevelFeatureRepository classLevelFeatureRepository) {
        this.restTemplate = restTemplate;
        this.repository = repository;
        this.slotProgressionRepository = slotProgressionRepository;
        this.classFeatureRepository = classFeatureRepository;
        this.classLevelProgressionRepository = classLevelProgressionRepository;
        this.classLevelFeatureRepository = classLevelFeatureRepository;
    }

    @Transactional
    public void syncClasses(){
        System.out.println("=== Starting class synchronization ===");
        
        // Obtener lista de clases
        Map response = restTemplate.getForObject(API_URL, Map.class);
        List<Map<String, String>> results = (List<Map<String, String>>) response.get("results");

        for (Map<String, String> cls : results){
            String indexName = cls.get("index");
            System.out.println("\n--- Syncing class: " + indexName + " ---");
            
            String detailUrl = "https://www.dnd5eapi.co/api/classes/" + indexName;

            // Obtener datos detallados
            Map detailed = restTemplate.getForObject(detailUrl, Map.class);

            if (detailed == null) {
                System.err.println("Failed to fetch details for: " + indexName);
                continue;
            }

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
                    subclassLevel = 3; // Default para la mayoría
                }
            }

            // Guardar o actualizar clase
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
            System.out.println("✓ Class saved: " + savedClass.getName());

            // Sincronizar spell slot progression
            if (spellcastingAbility != null) {
                syncSpellSlotProgression(savedClass, indexName);
            }

            // Sincronizar class features del API
            syncClassFeatures(savedClass, indexName);

            // NUEVO: Generar ClassLevelProgression
            generateClassLevelProgression(savedClass, indexName);
        }
        
        System.out.println("\n=== Classes synchronized successfully! ===");
    }

    private void syncSpellSlotProgression(DndClass dndClass, String indexName) {
        System.out.println("  → Syncing spell slot progression...");
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
        System.out.println("  ✓ Spell slot progression synced");
    }

    private void syncClassFeatures(DndClass dndClass, String indexName) {
        System.out.println("  → Syncing class features...");
        String levelsUrl = "https://www.dnd5eapi.co/api/classes/" + indexName + "/levels";
        List<Map> levels = restTemplate.getForObject(levelsUrl, List.class);

        if (levels == null) return;

        int featuresCount = 0;
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
                
                // Obtener descripción detallada (opcional)
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
                    System.err.println("    ! Error fetching feature detail for: " + featureName);
                    existing.setDescription("Feature obtained at level " + characterLevel);
                }
                
                classFeatureRepository.save(existing);
                featuresCount++;
            }
        }
        System.out.println("  ✓ " + featuresCount + " class features synced");
    }

    private void generateClassLevelProgression(DndClass dndClass, String indexName) {
        System.out.println("  → Generating level progression...");
        String levelsUrl = "https://www.dnd5eapi.co/api/classes/" + indexName + "/levels";
        List<Map> levels = restTemplate.getForObject(levelsUrl, List.class);

        if (levels == null) {
            System.err.println("  ! No level data found");
            return;
        }

        for (Map levelData : levels) {
            int level = (int) levelData.get("level");
            
            // Buscar o crear progresión
            ClassLevelProgression progression = classLevelProgressionRepository
                    .findByDndClassAndLevel(dndClass, level)
                    .orElse(new ClassLevelProgression());
            
            progression.setDndClass(dndClass);
            progression.setLevel(level);
            
            ClassLevelProgression savedProgression = classLevelProgressionRepository.save(progression);
            
            // Generar features para este nivel
            generateFeaturesForLevel(savedProgression, dndClass, level, levelData);
        }
        
        System.out.println("  ✓ Level progression generated (1-20)");
    }

    private void generateFeaturesForLevel(ClassLevelProgression progression, 
                                          DndClass dndClass, 
                                          int level, 
                                          Map levelData) {
        
        // 1. HP INCREASE (todos los niveles)
        createFeature(progression, FeatureType.HP_INCREASE, false, null);
        
        // 2. SPELL SLOT UPDATE (si es spellcaster)
        if (levelData.containsKey("spellcasting")) {
            createFeature(progression, FeatureType.SPELL_SLOT_UPDATE, false, null);
        }
        
        // 3. ASI OR FEAT (niveles 4, 8, 12, 16, 19)
        if (isASILevel(level, dndClass.getIndexName())) {
            createFeature(progression, FeatureType.ASI_OR_FEAT, true, null);
        }
        
        // 4. SUBCLASS CHOICE
        if (dndClass.getSubclassLevel() != null && level == dndClass.getSubclassLevel()) {
            createFeature(progression, FeatureType.SUBCLASS_CHOICE, true, null);
        }
        
        // 5. DETECTAR FEATURES ESPECÍFICAS POR NOMBRE
        if (levelData.containsKey("features")) {
            List<Map<String, String>> features = (List<Map<String, String>>) levelData.get("features");
            
            for (Map<String, String> featureRef : features) {
                String featureName = featureRef.get("name");
                detectAndCreateSpecialFeature(progression, featureName, level, dndClass);
            }
        }
        
        // 6. SPELLS TO LEARN (según clase)
        if (dndClass.getSpellcastingAbility() != null) {
            createSpellLearningFeatures(progression, dndClass, level);
        }
    }

    private void createFeature(ClassLevelProgression progression, 
                               FeatureType type, 
                               boolean requiresChoice, 
                               String metadata) {
        ClassLevelFeature feature = new ClassLevelFeature();
        feature.setProgression(progression);
        feature.setType(type);
        feature.setRequiresChoice(requiresChoice);
        feature.setMetadata(metadata);
        classLevelFeatureRepository.save(feature);
    }

    private boolean isASILevel(int level, String className) {
        // Niveles estándar de ASI
        boolean standardASI = level == 4 || level == 8 || level == 12 || level == 16 || level == 19;
        
        // Fighter tiene ASI extra en 6 y 14
        boolean fighterExtra = className.equals("fighter") && (level == 6 || level == 14);
        
        // Rogue tiene ASI extra en 10
        boolean rogueExtra = className.equals("rogue") && level == 10;
        
        return standardASI || fighterExtra || rogueExtra;
    }

    private void detectAndCreateSpecialFeature(ClassLevelProgression progression, 
                                               String featureName, 
                                               int level, 
                                               DndClass dndClass) {
        
        String lowerName = featureName.toLowerCase();
        
        // Fighting Style
        if (lowerName.contains("fighting style")) {
            createFeature(progression, FeatureType.FIGHTING_STYLE, true, null);
        }
        
        // Metamagic (Sorcerer)
        else if (lowerName.contains("metamagic")) {
            int count = level == 3 ? 2 : (level == 10 ? 1 : (level == 17 ? 1 : 0));
            if (count > 0) {
                createFeature(progression, FeatureType.METAMAGIC, true, 
                            "{\"count\": " + count + "}");
            }
        }
        
        // Eldritch Invocations (Warlock)
        else if (lowerName.contains("eldritch invocations")) {
            int count = calculateInvocationCount(level);
            if (count > 0) {
                createFeature(progression, FeatureType.INVOCATION, true, 
                            "{\"count\": " + count + ", \"total\": " + getTotalInvocations(level) + "}");
            }
        }
    }

    private int calculateInvocationCount(int level) {
        // Warlock aprende invocaciones en ciertos niveles
        if (level == 2) return 2;
        if (level == 5) return 1;
        if (level == 7) return 1;
        if (level == 9) return 1;
        if (level == 12) return 1;
        if (level == 15) return 1;
        if (level == 18) return 1;
        return 0;
    }

    private int getTotalInvocations(int level) {
        if (level >= 18) return 8;
        if (level >= 15) return 7;
        if (level >= 12) return 6;
        if (level >= 9) return 5;
        if (level >= 7) return 4;
        if (level >= 5) return 3;
        if (level >= 2) return 2;
        return 0;
    }

    private void createSpellLearningFeatures(ClassLevelProgression progression, 
                                             DndClass dndClass, 
                                             int level) {
        String className = dndClass.getIndexName();
        int spellsToLearn = 0;
        
        switch (className) {
            case "wizard":
                // Wizards aprenden 2 hechizos por nivel (excepto nivel 1 que aprenden 6)
                spellsToLearn = level == 1 ? 6 : 2;
                break;
                
            case "sorcerer":
                // Sorcerers aprenden según tabla específica
                spellsToLearn = getSorcererSpellsKnown(level) - getSorcererSpellsKnown(level - 1);
                break;
                
            case "bard":
                // Bards aprenden según tabla específica
                spellsToLearn = getBardSpellsKnown(level) - getBardSpellsKnown(level - 1);
                break;
                
            case "warlock":
                // Warlocks aprenden según tabla
                spellsToLearn = getWarlockSpellsKnown(level) - getWarlockSpellsKnown(level - 1);
                break;
                
            case "ranger":
                // Rangers aprenden hechizos a partir de nivel 2
                if (level >= 2) {
                    spellsToLearn = getRangerSpellsKnown(level) - getRangerSpellsKnown(level - 1);
                }
                break;
                
            // Cleric, Druid, Paladin preparan hechizos, no los aprenden permanentemente
            case "cleric":
            case "druid":
            case "paladin":
                // Estos usan SPELL_PREPARE en lugar de SPELL_LEARN
                break;
        }
        
        if (spellsToLearn > 0) {
            createFeature(progression, FeatureType.SPELL_LEARN, true, 
                        "{\"count\": " + spellsToLearn + "}");
        }
    }

    // Tablas de hechizos conocidos (simplificadas)
    private int getSorcererSpellsKnown(int level) {
        int[] table = {0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 13, 14, 14, 15, 15, 15, 15};
        return level >= 0 && level < table.length ? table[level] : 0;
    }

    private int getBardSpellsKnown(int level) {
        int[] table = {0, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 15, 16, 18, 19, 19, 20, 22, 22, 22};
        return level >= 0 && level < table.length ? table[level] : 0;
    }

    private int getWarlockSpellsKnown(int level) {
        int[] table = {0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15};
        return level >= 0 && level < table.length ? table[level] : 0;
    }

    private int getRangerSpellsKnown(int level) {
        int[] table = {0, 0, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11};
        return level >= 0 && level < table.length ? table[level] : 0;
    }
}