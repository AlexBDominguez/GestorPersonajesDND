package sync;


import entities.Spell;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.SpellRepository;
import java.util.List; 
import java.util.Map;
import java.util.Optional;

@Service
public class SpellSyncService {

    private final SpellRepository spellRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    private final String BASE_URL = "https://www.dnd5eapi.co/api/spells";

    public SpellSyncService(SpellRepository spellRepository) {
        this.spellRepository = spellRepository;
    }

    public void syncSpells() {

        Map<String, Object> response = restTemplate.getForObject(BASE_URL, Map.class);
        List<Map<String, Object>> results =
                (List<Map<String, Object>>) response.get("results");

        for (Map<String, Object> spellSummary : results) {

            String index = (String) spellSummary.get("index");

            Optional<Spell> existingOpt = spellRepository.findByIndexApi(index);
            if (existingOpt.isPresent() && existingOpt.get().isExtendedDataSynced()) {
                continue; // Already fully synced
            }

            ApiRateLimiter.waitBetweenRequests();

            // Llamada detalle
            Map<String, Object> detail =
                    restTemplate.getForObject(BASE_URL + "/" + index, Map.class);

            Spell spell = existingOpt.orElse(new Spell());

            // Basic fields (only set on new spells)
            if (existingOpt.isEmpty()) {
                spell.setIndexApi(index);
                spell.setName((String) detail.get("name"));
                spell.setLevel((Integer) detail.get("level"));

                // School
                Map<String, Object> school =
                        (Map<String, Object>) detail.get("school");
                if (school != null) {
                    spell.setSchool((String) school.get("name"));
                }

                spell.setCastingTime((String) detail.get("casting_time"));
                spell.setRange((String) detail.get("range"));
                spell.setDuration((String) detail.get("duration"));

                // Components (array → string)
                List<String> components =
                        (List<String>) detail.get("components");
                if (components != null) {
                    spell.setComponents(String.join(", ", components));
                }

                // Description (array → texto largo)
                List<String> descList =
                        (List<String>) detail.get("desc");
                if (descList != null) {
                    spell.setDescription(String.join("\n", descList));
                }
            }

            // Extended combat data (new fields)
            spell.setAttackType((String) detail.get("attack_type"));

            Map<String, Object> dc = (Map<String, Object>) detail.get("dc");
            if (dc != null) {
                Map<String, Object> dcTypeMap = (Map<String, Object>) dc.get("dc_type");
                if (dcTypeMap != null) {
                    spell.setDcType((String) dcTypeMap.get("name"));
                }
            }

            Map<String, Object> damage = (Map<String, Object>) detail.get("damage");
            if (damage != null) {
                Map<String, Object> damageTypeMap = (Map<String, Object>) damage.get("damage_type");
                if (damageTypeMap != null) {
                    spell.setDamageType((String) damageTypeMap.get("name"));
                }
                // Base damage: slot-level for leveled spells, character-level for cantrips
                Map<String, String> slotDmg = (Map<String, String>) damage.get("damage_at_slot_level");
                Map<String, String> charDmg = (Map<String, String>) damage.get("damage_at_character_level");
                if (slotDmg != null && !slotDmg.isEmpty()) {
                    int spellLevel = spell.getLevel() > 0 ? spell.getLevel() : 1;
                    String base = slotDmg.get(String.valueOf(spellLevel));
                    if (base == null) base = slotDmg.values().iterator().next();
                    spell.setDamageBase(base);
                } else if (charDmg != null && !charDmg.isEmpty()) {
                    String base = charDmg.get("1");
                    if (base == null) base = charDmg.values().iterator().next();
                    spell.setDamageBase(base);
                }
            }

            spell.setExtendedDataSynced(true);
            spellRepository.save(spell);
        }

        System.out.println("Spells synchronized correctly.");
    }
}

