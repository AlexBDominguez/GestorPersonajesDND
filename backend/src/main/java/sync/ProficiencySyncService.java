package sync;

import entities.Proficiency;
import enumeration.ProficiencyType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.ProficiencyRepository;

import java.util.List;
import java.util.Map;

@Service
public class ProficiencySyncService {

    private final ProficiencyRepository proficiencyRepository;
    private final RestTemplate restTemplate;

    private final String BASE_URL = "https://www.dnd5eapi.co/api/proficiencies";

    public ProficiencySyncService(ProficiencyRepository proficiencyRepository, RestTemplate restTemplate) {
        this.proficiencyRepository = proficiencyRepository;
        this.restTemplate = restTemplate;
    }

    public void syncProficiencies() {
        System.out.println("Starting proficiency synchronization...");

        // Obtener lista de todas las proficiencies
        Map<String, Object> response = restTemplate.getForObject(BASE_URL, Map.class);
        List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");

        for (Map<String, Object> proficiencySummary : results) {
            String index = (String) proficiencySummary.get("index");

            // Verificar si ya existe
            if (proficiencyRepository.findByIndexName(index).isPresent()) {
                System.out.println("Proficiency " + index + " already exists, skipping...");
                continue;
            }

            ApiRateLimiter.waitBetweenRequests();

            // Obtener detalles de la proficiency
            Map<String, Object> detail = restTemplate.getForObject(BASE_URL + "/" + index, Map.class);

            Proficiency proficiency = new Proficiency();
            proficiency.setIndexName(index);
            proficiency.setName((String) detail.get("name"));
            proficiency.setApiUrl((String) detail.get("url"));

            // Tipo de proficiency
            String typeStr = (String) detail.get("type");
            ProficiencyType type = mapApiTypeToProficiencyType(typeStr);
            proficiency.setType(type);

            // Descripción (puede no estar presente en la API)
            List<String> descList = (List<String>) detail.get("desc");
            if (descList != null && !descList.isEmpty()) {
                proficiency.setDescription(String.join("\n", descList));
            }

            // Categoría/Referencias (para armaduras, armas, etc.)
            Object reference = detail.get("reference");
            if (reference instanceof Map) {
                Map<String, Object> refMap = (Map<String, Object>) reference;
                String refName = (String) refMap.get("name");
                if (refName != null) {
                    proficiency.setCategory(refName);
                }
            }

            // Para algunos tipos, la categoría viene en "classes" o "races"
            List<Map<String, Object>> classes = (List<Map<String, Object>>) detail.get("classes");
            if (classes != null && !classes.isEmpty()) {
                proficiency.setCategory("Class Proficiency");
            }

            proficiencyRepository.save(proficiency);
            System.out.println("Saved proficiency: " + proficiency.getName() + " (Type: " + type + ")");
        }

        System.out.println("Proficiency synchronization completed.");
    }

    private ProficiencyType mapApiTypeToProficiencyType(String apiType){
        if (apiType == null){
            return ProficiencyType.TOOL;
        }

        switch (apiType.toUpperCase()) {
            case "ARMOR":
                return ProficiencyType.ARMOR;
            case "WEAPONS":
            case "WEAPON":
                return ProficiencyType.WEAPON;
            case "ARTISAN'S TOOLS":
            case "GAMING SETS":
            case "MUSICAL INSTRUMENTS":
            case "OTHER":
                return ProficiencyType.TOOL;
            case "VEHICLES":
                return ProficiencyType.VEHICLE;
            case "SAVING THROWS":
                return ProficiencyType.SAVING_THROW;
            case "SKILLS":
                return ProficiencyType.SKILL;
            default:
                System.out.println("Unknown proficiency type: " + apiType + ", defaulting to TOOL");
                return ProficiencyType.TOOL;
        }
    }
}
