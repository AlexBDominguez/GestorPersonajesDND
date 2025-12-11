package sync;

import entities.DndClass;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.DndClassRepository;

import java.util.List;
import java.util.Map;

@Service
public class DndClassSyncService {

    private final RestTemplate restTemplate;
    private final DndClassRepository repository;

    private static final String API_URL = "https://www.dnd5eapi.co/api/classes";

    public DndClassSyncService(RestTemplate restTemplate, DndClassRepository repository) {
        this.restTemplate = restTemplate;
        this.repository = repository;
    }

    public void syncClasses(){
        //1 Obtener lista de clases
        Map response = restTemplate.getForObject(API_URL, Map.class);

        List<Map<String, String>> results = (List<Map<String, String>>) response.get("results");

        for (Map<String, String> cls: results){
            String indexName = cls.get("index");
            String detailUrl = "https://www.dnd5eapi.co/api.classes/" + indexName;


            //2. Obtener datos detallados
            Map detailed = restTemplate.getForObject(detailUrl, Map.class);

            assert detailed != null;
            String name = (String) detailed.get("name");
            int hitDie = (int) detailed.get("hit_die");

            List<Map<String, String>> proficienciesRaw = (List<Map<String, String>>) detailed.get("proficiencies");
            List<String> proficiencies = proficienciesRaw.stream()
                    .map(p -> p.get("name"))
                    .toList();

            // 3. Guardar o actualizar en la base de datos
            DndClass existing = repository.findByIndexName(indexName).orElse(null);
            if (existing == null){
                existing = new DndClass();

            }

            existing.setIndexName(indexName);
            existing.setName(name);
            existing.setHitDie(hitDie);
            existing.setProficiencies(proficiencies);
            existing.setDescription("Imported from DND 5e API");

            repository.save(existing);
        }
        System.out.println("Classes synchronized succesfully!!");
    }

}
