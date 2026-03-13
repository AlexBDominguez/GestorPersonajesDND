package sync;

import entities.DamageType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.DamageTypeRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class DamageTypeSyncService {

    private final DamageTypeRepository damageTypeRepository;
    private final RestTemplate restTemplate;

    private final String BASE_URL = "https://www.dnd5eapi.co/api/damage-types";

    public DamageTypeSyncService(DamageTypeRepository damageTypeRepository, RestTemplate restTemplate) {
        this.damageTypeRepository = damageTypeRepository;
        this.restTemplate = restTemplate;
    }

    public void syncDamageTypes() {
        System.out.println("Starting damage type synchronization...");

        // Obtener lista de todos los tipos de daño
        Map<String, Object> response = restTemplate.getForObject(BASE_URL, Map.class);
        List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");

        for (Map<String, Object> damageTypeSummary : results) {
            String index = (String) damageTypeSummary.get("index");

            // Verificar si ya existe
            if (damageTypeRepository.findByIndexName(index).isPresent()) {
                System.out.println("DamageType " + index + " already exists, skipping...");
                continue;
            }

            ApiRateLimiter.waitBetweenRequests();

            // Obtener detalles del tipo de daño
            Map<String, Object> detail = restTemplate.getForObject(BASE_URL + "/" + index, Map.class);

            DamageType damageType = new DamageType();
            damageType.setIndexName(index);
            damageType.setName((String) detail.get("name"));

            // Descripción (array de strings)
            List<String> descList = (List<String>) detail.get("desc");
            if (descList != null && !descList.isEmpty()) {
                damageType.setDescription(new ArrayList<>(descList));
            }

            damageTypeRepository.save(damageType);
            System.out.println("Saved damage type: " + damageType.getName());
        }

        System.out.println("Damage type synchronization completed.");
    }
}