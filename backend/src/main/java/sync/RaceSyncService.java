package sync;

import entities.Race;
import entities.RacialTrait;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.RaceRepository;
import repositories.RacialTraitRepository;

import java.util.*;

@Service
public class RaceSyncService {

    private final RaceRepository raceRepository;
    private final RacialTraitRepository traitRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    public RaceSyncService(RaceRepository raceRepository,
                           RacialTraitRepository traitRepository) {
        this.raceRepository = raceRepository;
        this.traitRepository = traitRepository;
    }

    @SuppressWarnings("unchecked")
    public void syncRaces() {
        String url = "https://www.dnd5eapi.co/api/races";
        Map<String, Object> response = restTemplate.getForObject(url, Map.class);
        List<Map<String, String>> results = (List<Map<String, String>>) response.get("results");

        for (Map<String, String> raceInfo : results) {
            String indexName = raceInfo.get("index");
            ApiRateLimiter.waitBetweenRequests();

            Map<String, Object> detailed = restTemplate.getForObject(
                    "https://www.dnd5eapi.co/api/races/" + indexName, Map.class);
            if (detailed == null) continue;

            Race race = raceRepository.findByIndexName(indexName).orElse(new Race());
            race.setIndexName(indexName);
            race.setName((String) detailed.get("name"));
            race.setSize((String) detailed.get("size"));

            Object speedObj = detailed.get("speed");
            if (speedObj instanceof Integer) race.setSpeed((Integer) speedObj);
            else if (speedObj instanceof Double) race.setSpeed(((Double) speedObj).intValue());
            else race.setSpeed(30);

            // Ability bonuses
            List<Map<String, Object>> bonuses = (List<Map<String, Object>>) detailed.get("ability_bonuses");
            Map<String, Integer> bonusMap = new HashMap<>();
            if (bonuses != null) {
                for (Map<String, Object> b : bonuses) {
                    Map<String, Object> ability = (Map<String, Object>) b.get("ability_score");
                    if (ability != null)
                        bonusMap.put((String) ability.get("index"), ((Number) b.get("bonus")).intValue());
                }
            }
            race.setAbilityBonuses(bonusMap);

            // Description
            Object descRaw = detailed.get("desc");
            if (descRaw instanceof List) race.setDescription(String.join("\n", (List<String>) descRaw));
            else if (descRaw instanceof String) race.setDescription((String) descRaw);
            else race.setDescription("");

            // Traits — llamada individual por trait para obtener descripción
            List<Map<String, Object>> traitRefs = (List<Map<String, Object>>) detailed.get("traits");
            List<RacialTrait> traitEntities = new ArrayList<>();
            if (traitRefs != null) {
                for (Map<String, Object> ref : traitRefs) {
                    String traitIndex = (String) ref.get("index");
                    RacialTrait trait = syncTrait(traitIndex);
                    if (trait != null) traitEntities.add(trait);
                }
            }
            race.setTraits(traitEntities);

            raceRepository.save(race);
            System.out.println("  Synced race: " + indexName + " with " + traitEntities.size() + " traits");
        }
    }

    @SuppressWarnings("unchecked")
    RacialTrait syncTrait(String traitIndex) {
        // Reutilizar si ya existe
        Optional<RacialTrait> existing = traitRepository.findByIndexName(traitIndex);
        if (existing.isPresent()) return existing.get();

        ApiRateLimiter.waitBetweenRequests();
        try {
            Map<String, Object> data = restTemplate.getForObject(
                    "https://www.dnd5eapi.co/api/traits/" + traitIndex, Map.class);
            if (data == null) return null;

            RacialTrait trait = new RacialTrait();
            trait.setIndexName(traitIndex);
            trait.setName((String) data.get("name"));

            Object descRaw = data.get("desc");
            if (descRaw instanceof List) trait.setDescription(String.join("\n", (List<String>) descRaw));
            else if (descRaw instanceof String) trait.setDescription((String) descRaw);
            else trait.setDescription("");

            // Clasificación básica por nombre
            trait.setTraitType(classifyTrait(traitIndex));

            return traitRepository.save(trait);
        } catch (Exception e) {
            System.out.println("  Could not sync trait: " + traitIndex + " — " + e.getMessage());
            return null;
        }
    }

    private String classifyTrait(String indexName) {
        // Traits que tienen relevancia en combate
        final Set<String> combatTraits = Set.of(
            "aggressive", "relentless-endurance", "savage-attacks",
            "halfling-luck", "brave", "martial-training",
            "stone-s-endurance", "powerful-build",
            "gnome-cunning", "artificers-lore", "tinker",
            "dwarven-combat-training", "dwarven-resilience",
            "elven-accuracy", "fey-step", "trance",
            "lucky", "halfling-nimbleness",
            "breath-weapon", "draconic-ancestry"
        );
        // Traits que requieren elección del jugador
        final Set<String> choiceTraits = Set.of(
            "draconic-ancestry", "breath-weapon",
            "extra-language", "tool-proficiency", "skill-versatility",
            "natural-illusionist", "high-elf-cantrip"
        );
        if (choiceTraits.contains(indexName)) return "CHOICE_REQUIRED";
        if (combatTraits.contains(indexName)) return "COMBAT";
        return "PASSIVE";
    }
}