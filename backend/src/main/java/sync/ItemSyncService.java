package sync;

import entities.Item;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import repositories.ItemRepository;

import java.util.List;
import java.util.Map;

@Service
public class ItemSyncService {

    private final ItemRepository itemRepository;
    private final RestTemplate restTemplate;

    private static final String BASE_URL = "https://www.dnd5eapi.co/api/equipment";

    public ItemSyncService(ItemRepository itemRepository, RestTemplate restTemplate) {
        this.itemRepository = itemRepository;
        this.restTemplate = restTemplate;
    }

    public void syncItems() {
        System.out.println("Starting item synchronization...");

        Map<String, Object> response = restTemplate.getForObject(BASE_URL, Map.class);
        List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");

        int saved = 0;
        int skipped = 0;

        for (Map<String, Object> summary : results) {
            String index = (String) summary.get("index");

            if (itemRepository.findByIndexName(index).isPresent()) {
                skipped++;
                continue;
            }

            ApiRateLimiter.waitBetweenRequests();

            try {
                Map<String, Object> detail = restTemplate.getForObject(BASE_URL + "/" + index, Map.class);
                Item item = mapToEntity(detail);
                itemRepository.save(item);
                saved++;
                System.out.println("Saved item: " + item.getName());
            } catch (Exception e) {
                System.err.println("Error syncing item " + index + ": " + e.getMessage());
            }
        }

        System.out.println("Item synchronization completed. Saved: " + saved + ", Skipped: " + skipped);
    }

    private Item mapToEntity(Map<String, Object> detail) {
        Item item = new Item();

        item.setIndexName((String) detail.get("index"));
        item.setName((String) detail.get("name"));

        // Category
        Map<String, Object> equipmentCategory = (Map<String, Object>) detail.get("equipment_category");
        if (equipmentCategory != null) {
            String categoryIndex = (String) equipmentCategory.get("index");
            item.setItemType(categoryIndex != null ? categoryIndex.toUpperCase().replace("-", "_") : "GEAR");
            item.setCategory((String) equipmentCategory.get("name"));
        }

        // Cost → copper
        Map<String, Object> cost = (Map<String, Object>) detail.get("cost");
        if (cost != null) {
            Object quantityObj = cost.get("quantity");
            String unit = (String) cost.get("unit");
            int quantity = quantityObj instanceof Number ? ((Number) quantityObj).intValue() : 0;
            item.setCostInCopper(convertToCopper(quantity, unit));
        }

        // Weight
        Object weightObj = detail.get("weight");
        if (weightObj instanceof Number) {
            item.setWeight(((Number) weightObj).doubleValue());
        }

        // Description
        List<String> descList = (List<String>) detail.get("desc");
        if (descList != null && !descList.isEmpty()) {
            item.setDescription(String.join("\n", descList));
        }

        // Weapon fields
        Map<String, Object> damage = (Map<String, Object>) detail.get("damage");
        if (damage != null) {
            item.setDamageDice((String) damage.get("damage_dice"));
            Map<String, Object> damageType = (Map<String, Object>) damage.get("damage_type");
            if (damageType != null) {
                item.setDamageType((String) damageType.get("name"));
            }
        }

        String weaponRange = (String) detail.get("weapon_range");
        if (weaponRange != null) {
            item.setWeaponRange(weaponRange);
        }

        List<Map<String, Object>> properties = (List<Map<String, Object>>) detail.get("properties");
        if (properties != null) {
            List<String> propNames = new java.util.ArrayList<>();
            for (Map<String, Object> prop : properties) {
                String propName = (String) prop.get("name");
                if (propName != null) propNames.add(propName);
            }
            item.setWeaponProperties(propNames);
        }

        // Armor fields
        Map<String, Object> armorClass = (Map<String, Object>) detail.get("armor_class");
        if (armorClass != null) {
            Object base = armorClass.get("base");
            if (base instanceof Number) {
                item.setArmorClass(((Number) base).intValue());
            }
        }

        String armorCategory = (String) detail.get("armor_category");
        if (armorCategory != null) {
            item.setArmorType(armorCategory);
        }

        Object maxDex = detail.get("max_dex_bonus");
        if (maxDex instanceof Number) {
            item.setMaxDexBonus(((Number) maxDex).intValue());
        }

        Object strMin = detail.get("str_minimum");
        if (strMin instanceof Number) {
            item.setMinimumStrength(((Number) strMin).intValue());
        }

        Object stealthDisadv = detail.get("stealth_disadvantage");
        if (stealthDisadv instanceof Boolean) {
            item.setStealthDisadvantage((Boolean) stealthDisadv);
        }

        return item;
    }

    private int convertToCopper(int quantity, String unit) {
        if (unit == null) return quantity;
        return switch (unit.toLowerCase()) {
            case "cp" -> quantity;
            case "sp" -> quantity * 10;
            case "ep" -> quantity * 50;
            case "gp" -> quantity * 100;
            case "pp" -> quantity * 1000;
            default -> quantity;
        };
    }
}
