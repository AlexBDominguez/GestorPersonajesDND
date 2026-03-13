package sync;

import org.springframework.web.client.RestTemplate;

import entities.Condition;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import repositories.ConditionRepository;

@Service
public class ConditionSyncService {
    
    private final ConditionRepository conditionRepository;
    private final RestTemplate restTemplate;

    private final String BASE_URL = "https://www.dnd5eapi.co/api/conditions";

    public ConditionSyncService(ConditionRepository conditionRepository, RestTemplate restTemplate) {
        this.conditionRepository = conditionRepository;
        this.restTemplate = restTemplate;
    }


    public void syncConditions(){
        System.out.println("Starting condition synchronization...");

        //Obtener lista de todas las condiciones
        Map<String, Object> response = restTemplate.getForObject(BASE_URL, Map.class);
        List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");

        for(Map<String, Object> conditionSummary : results){
            String index = (String) conditionSummary.get("index");

            //Verificar si ya existe
            if(conditionRepository.findByIndexName(index).isPresent()){
                System.out.println("Condition with index " + index + " already exists. Skipping.");
                continue;
            }
            ApiRateLimiter.waitBetweenRequests();

            // Obtener detalles de la condición
            Map<String, Object> detail = restTemplate.getForObject(BASE_URL + "/" + index, Map.class);

            Condition condition = new Condition();
            condition.setIndexName(index);
            condition.setName((String) detail.get("name"));

            // Descripción (array de strings)
            List<String> descList = (List<String>) detail.get("desc");
            if (descList != null && !descList.isEmpty()) {
                condition.setDescription(new ArrayList<>(descList));
            }

            conditionRepository.save(condition);
            System.out.println("Saved condition: " + condition.getName());
        }

        System.out.println("Condition synchronization completed.");
    }
}