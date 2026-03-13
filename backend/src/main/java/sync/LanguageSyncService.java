package sync;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import entities.Language;
import repositories.LanguageRepository;

@Service
public class LanguageSyncService {

    private final LanguageRepository languageRepository;
    private final RestTemplate restTemplate;

    private final String BASE_URL = "https://www.dnd5eapi.co/api/languages";

    public LanguageSyncService(LanguageRepository languageRepository, RestTemplate restTemplate) {
        this.languageRepository = languageRepository;
        this.restTemplate = restTemplate;
    }

    public void syncLanguages(){
        System.out.println("Starting language synchronization...");

        //Obtener la lista de todos los idiomas
        Map<String, Object> response = restTemplate.getForObject(BASE_URL, Map.class);
        List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");

        for(Map<String, Object> languageSummary : results){
            String index = (String) languageSummary.get("index");

            //Verificar si ya existe
            if(languageRepository.findByIndexName(index).isPresent()){
                System.out.println("Language with index " + index + " already exists. Skipping.");
                continue;
            }
            ApiRateLimiter.waitBetweenRequests();

            //Obtener detalles del idioma
            Map<String, Object> detail = restTemplate.getForObject(BASE_URL + "/" + index, Map.class);

            Language language = new Language();
            language.setIndexName(index);
            language.setName((String) detail.get("name"));
            language.setType((String) detail.get("type"));
            language.setScript((String) detail.get("script"));

            //Descripcion
            String desc = (String) detail.get("desc");
            if(desc != null){
                language.setDescription(desc);
            }

            //Typical speakers
            Object typicalSpeakersObj = detail.get("typical_speakers");
            if(typicalSpeakersObj instanceof List){
                List<String> speakers = (List<String>) typicalSpeakersObj;
                language.setTypicalSpeakers(String.join(", ", speakers));
            } else if (typicalSpeakersObj instanceof String){
                language.setTypicalSpeakers((String) typicalSpeakersObj);
            }

            languageRepository.save(language);
            System.out.println("Saved language: " + language.getName() + " (Type: " + language.getType() + ")");
        }

        System.out.println("Language synchronization completed.");
    }
    
}
