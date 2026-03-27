package sync;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import entities.DndClass;
import entities.Subclass;
import entities.SubclassFeature;
import repositories.DndClassRepository;
import repositories.SubclassFeatureRepository;
import repositories.SubclassRepository;

@Service
public class SubclassSyncService {
    
    private final SubclassRepository subclassRepository;
    private final SubclassFeatureRepository subclassFeatureRepository;
    private final DndClassRepository dndClassRepository;
    private final RestTemplate restTemplate;

    private final String BASE_URL = "https://www.dnd5eapi.co/api/subclasses";

    public SubclassSyncService( SubclassRepository subclassRepository,
                                SubclassFeatureRepository subclassFeatureRepository,
                                DndClassRepository dndClassRepository,
                                RestTemplate restTemplate) {
        this.subclassRepository = subclassRepository;
        this.subclassFeatureRepository = subclassFeatureRepository;
        this.dndClassRepository = dndClassRepository;
        this.restTemplate = restTemplate;

    }

    public void syncSubclasses() {
        System.out.println("=== Starting subclass synchronization ===");

        //Obtener lista de todas las subclases
        Map<String, Object> response = restTemplate.getForObject(BASE_URL, Map.class);
        List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");

        for(Map<String, Object> subclassSummary : results) {
            String index = (String) subclassSummary.get("index");

            //Verificar si existe
            if(subclassRepository.findByIndexName(index).isPresent()) {
                System.out.println("Subclass " + index + " already exists. Skipping...");
                continue;
            }

            ApiRateLimiter.waitBetweenRequests();

            //Obtener detalles de la subclase
            Map<String, Object> detail = restTemplate.getForObject(BASE_URL + "/" + index, Map.class);

            Subclass subclass = new Subclass();
            subclass.setIndexName(index);
            subclass.setName((String) detail.get("name"));
            subclass.setSubclassFlavor((String) detail.get("subclass_flavor"));

            //Descripción (array de strings)
            List<String> descList = (List<String>) detail.get("desc");
            if(descList != null && !descList.isEmpty()) {
                subclass.setDescription(String.join("\n", descList));
            }

            //Spellcasting ability (puede ser null)
            Map<String, Object> spellcasting = (Map<String, Object>)detail.get("spellcasting");
            if(spellcasting != null){
                Map<String, Object> spellcastingAbility = (Map<String, Object>) spellcasting.get("spellcasting_ability");
                if(spellcastingAbility != null) {
                    subclass.setSpellcastingAbility((String) spellcastingAbility.get("index"));
                }
            }

            //Buscar la clase padre
            Map<String, Object> classRef = (Map<String, Object>) detail.get("class");
            if(classRef != null) {
                String classIndex = (String) classRef.get("index");
                DndClass dndClass = dndClassRepository.findByIndexName(classIndex)
                        .orElseThrow(() -> new RuntimeException("DndClass not found for index: " + classIndex));
                subclass.setDndClass(dndClass);
        }

        subclassRepository.save(subclass);
        System.out.println("Saved subclass: " + subclass.getName());

        //Sincronizar features en la subclase
        syncSubclassFeatures(subclass, index);
        }

        System.out.println("Subclass synchronization completed.");
    }

    private void syncSubclassFeatures(Subclass subclass, String subclassIndex) {
        String levelsUrl = BASE_URL + "/" + subclassIndex + "/levels";

        try {
            //Obtener info de niveles de la subclase
            Map<String, Object> levelsResponse = restTemplate.getForObject(levelsUrl, Map.class);

            if(levelsResponse == null) {
                return;
            }

            //La API devuelve un array de niveles
            for(int level = 1; level <= 20; level++){
                ApiRateLimiter.waitBetweenRequests();

                String levelUrl = levelsUrl + "/" + level;
                Map<String, Object> levelDetail = restTemplate.getForObject(levelUrl, Map.class);

                if(levelDetail == null) {
                    continue;
                }

                //Obtener features de este nivel
                List<Map<String, Object>> features = (List<Map<String,Object>>) levelDetail.get("features");

                if(features == null || features.isEmpty()) {
                    continue;
                }

                for (Map<String, Object> featureRef : features) {
                    String featureIndex = (String) featureRef.get("index");

                    //Verificar si ya existe
                    if(subclassFeatureRepository.findByIndexName(featureIndex).isPresent()){
                        continue;
                    }
                    ApiRateLimiter.waitBetweenRequests();

                    //Obtener detalles de la feature
                    String featureUrl = (String) featureRef.get("url");
                    Map<String, Object> featureDetail = restTemplate.getForObject("https://www.dnd5eapi.co" + featureUrl, Map.class);

                    SubclassFeature subclassFeature = new SubclassFeature();
                    subclassFeature.setSubclass(subclass);
                    subclassFeature.setIndexName(featureIndex);
                    subclassFeature.setName((String) featureDetail.get("name"));
                    subclassFeature.setLevel((Integer)featureDetail.get("level"));
                    subclassFeature.setApiUrl(featureUrl);

                    //Descripcion
                    List<String> desc = (List<String>) featureDetail.get("desc");
                    if (desc!= null && !desc.isEmpty()) {
                        subclassFeature.setDescription(String.join("\n", desc));
                    }

                    subclassFeatureRepository.save(subclassFeature);
                    System.out.println("Saved feature: " + subclassFeature.getName() + " (Level " + subclassFeature.getLevel() + ")");
                }
            }
        }catch (Exception e) {
            System.err.println("Error syncing features for subclass " + subclass.getName() + ": " + e.getMessage());
        }
    }
}
