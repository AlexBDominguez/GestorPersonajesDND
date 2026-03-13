package services;

import dto.CharacterEquipmentDto;
import entities.CharacterEquipment;
import entities.PlayerCharacter;
import entities.Item;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterEquipmentRepository;
import repositories.PlayerCharacterRepository;
import repositories.ItemRepository;

@Service
public class CharacterEquipmentService {

    private final CharacterEquipmentRepository equipmentRepository;
    private final PlayerCharacterRepository characterRepository;
    private final ItemRepository itemRepository;

    public CharacterEquipmentService(CharacterEquipmentRepository equipmentRepository,
                                    PlayerCharacterRepository characterRepository,
                                    ItemRepository itemRepository) {
        this.equipmentRepository = equipmentRepository;
        this.characterRepository = characterRepository;
        this.itemRepository = itemRepository;
    }

    public CharacterEquipmentDto getCharacterEquipment(Long characterId) {
        CharacterEquipment equipment = equipmentRepository.findByCharacterId(characterId)
                .orElse(null);

        if (equipment == null) {
            // Crear equipment vacío si no existe
            PlayerCharacter character = characterRepository.findById(characterId)
                    .orElseThrow(() -> new RuntimeException("Character not found"));
            equipment = new CharacterEquipment(character);
            equipmentRepository.save(equipment);
        }

        return toDto(equipment);
    }

    @Transactional
    public CharacterEquipmentDto equipItem(Long characterId, Long itemId, String slot) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        Item item = itemRepository.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Item not found"));

        CharacterEquipment equipment = equipmentRepository.findByCharacter(character)
                .orElse(new CharacterEquipment(character));

        // Equipar en el slot correspondiente
        switch (slot.toLowerCase()) {
            case "mainhand":
                equipment.setMainHand(item);
                break;
            case "offhand":
                equipment.setOffHand(item);
                break;
            case "armor":
                equipment.setArmor(item);
                break;
            case "helmet":
                equipment.setHelmet(item);
                break;
            case "gloves":
                equipment.setGloves(item);
                break;
            case "boots":
                equipment.setBoots(item);
                break;
            case "cloak":
                equipment.setCloak(item);
                break;
            case "amulet":
                equipment.setAmulet(item);
                break;
            case "ring1":
                equipment.setRing1(item);
                break;
            case "ring2":
                equipment.setRing2(item);
                break;
            case "belt":
                equipment.setBelt(item);
                break;
            default:
                throw new RuntimeException("Invalid equipment slot: " + slot);
        }

        equipmentRepository.save(equipment);
        return toDto(equipment);
    }

    @Transactional
    public CharacterEquipmentDto unequipItem(Long characterId, String slot) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        CharacterEquipment equipment = equipmentRepository.findByCharacter(character)
                .orElseThrow(() -> new RuntimeException("No equipment found for character"));

        // Desequipar del slot
        switch (slot.toLowerCase()) {
            case "mainhand":
                equipment.setMainHand(null);
                break;
            case "offhand":
                equipment.setOffHand(null);
                break;
            case "armor":
                equipment.setArmor(null);
                break;
            case "helmet":
                equipment.setHelmet(null);
                break;
            case "gloves":
                equipment.setGloves(null);
                break;
            case "boots":
                equipment.setBoots(null);
                break;
            case "cloak":
                equipment.setCloak(null);
                break;
            case "amulet":
                equipment.setAmulet(null);
                break;
            case "ring1":
                equipment.setRing1(null);
                break;
            case "ring2":
                equipment.setRing2(null);
                break;
            case "belt":
                equipment.setBelt(null);
                break;
            default:
                throw new RuntimeException("Invalid equipment slot: " + slot);
        }

        equipmentRepository.save(equipment);
        return toDto(equipment);
    }

    private CharacterEquipmentDto toDto(CharacterEquipment equipment) {
        CharacterEquipmentDto dto = new CharacterEquipmentDto();
        dto.setId(equipment.getId());
        dto.setCharacterId(equipment.getCharacter().getId());
        dto.setCharacterName(equipment.getCharacter().getName());

        if (equipment.getMainHand() != null) {
            dto.setMainHandId(equipment.getMainHand().getId());
            dto.setMainHandName(equipment.getMainHand().getName());
        }

        if (equipment.getOffHand() != null) {
            dto.setOffHandId(equipment.getOffHand().getId());
            dto.setOffHandName(equipment.getOffHand().getName());
        }

        if (equipment.getArmor() != null) {
            dto.setArmorId(equipment.getArmor().getId());
            dto.setArmorName(equipment.getArmor().getName());
        }

        if (equipment.getHelmet() != null) {
            dto.setHelmetId(equipment.getHelmet().getId());
            dto.setHelmetName(equipment.getHelmet().getName());
        }

        if (equipment.getGloves() != null) {
            dto.setGlovesId(equipment.getGloves().getId());
            dto.setGlovesName(equipment.getGloves().getName());
        }

        if (equipment.getBoots() != null) {
            dto.setBootsId(equipment.getBoots().getId());
            dto.setBootsName(equipment.getBoots().getName());
        }

        if (equipment.getCloak() != null) {
            dto.setCloakId(equipment.getCloak().getId());
            dto.setCloakName(equipment.getCloak().getName());
        }

        if (equipment.getAmulet() != null) {
            dto.setAmuletId(equipment.getAmulet().getId());
            dto.setAmuletName(equipment.getAmulet().getName());
        }

        if (equipment.getRing1() != null) {
            dto.setRing1Id(equipment.getRing1().getId());
            dto.setRing1Name(equipment.getRing1().getName());
        }

        if (equipment.getRing2() != null) {
            dto.setRing2Id(equipment.getRing2().getId());
            dto.setRing2Name(equipment.getRing2().getName());
        }

        if (equipment.getBelt() != null) {
            dto.setBeltId(equipment.getBelt().getId());
            dto.setBeltName(equipment.getBelt().getName());
        }

        return dto;
    }
}