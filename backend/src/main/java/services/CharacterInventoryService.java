package services;

import dto.CharacterInventoryDto;
import entities.CharacterEquipment;
import entities.CharacterInventory;
import entities.Infusion;
import entities.PlayerCharacter;
import entities.Item;
import jakarta.transaction.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import repositories.CharacterEquipmentRepository;
import repositories.CharacterInventoryRepository;
import repositories.InfusionRepository;
import repositories.PlayerCharacterRepository;
import repositories.ItemRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CharacterInventoryService {

    private final CharacterInventoryRepository inventoryRepository;
    private final PlayerCharacterRepository characterRepository;
    private final ItemRepository itemRepository;
    private final CharacterEquipmentRepository equipmentRepository;
    private final InfusionRepository infusionRepository;
    private final InfusionService infusionService;
    private final CharacterFormulaService formulaService;

    public CharacterInventoryService(CharacterInventoryRepository inventoryRepository,
                                     PlayerCharacterRepository characterRepository,
                                     ItemRepository itemRepository,
                                     CharacterEquipmentRepository equipmentRepository,
                                     InfusionRepository infusionRepository,
                                     InfusionService infusionService,
                                     CharacterFormulaService formulaService) {
        this.inventoryRepository = inventoryRepository;
        this.characterRepository = characterRepository;
        this.itemRepository = itemRepository;
        this.equipmentRepository = equipmentRepository;
        this.infusionRepository = infusionRepository;
        this.infusionService = infusionService;
        this.formulaService = formulaService;
    }

    // El objeto requiere sintonización para equiparse si el objeto base ya la requería
    // (magic item normal) O si la infusión aplicada la requiere (p.ej. Enhanced Arcane Focus) --
    // un objeto mundano infusionado con algo que exige sintonización pasa a exigirla también.
    private boolean effectiveRequiresAttunement(CharacterInventory inventory) {
        if (inventory.getItem().isRequiresAttunement()) return true;
        if (inventory.getInfusionIndexName() == null) return false;
        return infusionRepository.findByIndexName(inventory.getInfusionIndexName())
                .map(Infusion::isRequiresAttunement)
                .orElse(false);
    }

    public List<CharacterInventoryDto> getCharacterInventory(Long characterId) {
        return inventoryRepository.findByCharacterId(characterId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public Double getTotalWeight(Long characterId) {
        Double weight = inventoryRepository.calculateTotalWeight(characterId);
        return weight != null ? weight : 0.0;
    }

    @Transactional
    public CharacterInventoryDto addItemToInventory(Long characterId, Long itemId, int quantity) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        Item item = itemRepository.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Item not found with ID: " + itemId));

        // Verificar si ya tiene el item (para items apilables)
        CharacterInventory existing = inventoryRepository.findByCharacterAndItem(character, item).orElse(null);

        if (existing != null) {
            // Aumentar cantidad
            existing.setQuantity(existing.getQuantity() + quantity);
            inventoryRepository.save(existing);
            return toDto(existing);
        } else {
            // Crear nuevo
            CharacterInventory newItem = new CharacterInventory(character, item, quantity, false, false, null);
            inventoryRepository.save(newItem);
            return toDto(newItem);
        }
    }

    @Transactional
    public CharacterInventoryDto updateQuantity(Long inventoryId, int newQuantity) {
        CharacterInventory inventory = inventoryRepository.findById(inventoryId)
                .orElseThrow(() -> new RuntimeException("Inventory item not found with ID: " + inventoryId));

        if (newQuantity <= 0) {
            inventoryRepository.delete(inventory);
            return null;
        }

        inventory.setQuantity(newQuantity);
        inventoryRepository.save(inventory);
        return toDto(inventory);
    }

    @Transactional
    public void removeItemFromInventory(Long characterId, Long itemId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        Item item = itemRepository.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Item not found"));

        CharacterInventory inventory = inventoryRepository.findByCharacterAndItem(character, item)
                .orElseThrow(() -> new RuntimeException("Item not in character's inventory"));

        inventoryRepository.delete(inventory);
    }

    @Transactional
    public CharacterInventoryDto toggleAttuned(Long inventoryId) {
        CharacterInventory inventory = inventoryRepository.findById(inventoryId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Inventory item not found"));

        // Verificar límite de attunement (3 por defecto, 4 con Magic Item Adept)
        if (!inventory.isAttuned()) {
            int maxAttunement = inventory.getCharacter().getMaxAttunementSlots();
            long attunedCount = inventoryRepository.findByCharacterIdAndAttuned(
                    inventory.getCharacter().getId(), true).size();

            if (attunedCount >= maxAttunement) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Character already has " + maxAttunement + " attuned items (maximum)");
            }
        }

        inventory.setAttuned(!inventory.isAttuned());
        inventoryRepository.save(inventory);
        return toDto(inventory);
    }

    /**
     * Para armors: sincroniza CharacterEquipment armor slot para que el AC se calcule correctamente. 
     * Equipar una segunda armadura automáticamente desequipa la primera
     * 
     */

    @Transactional
    public CharacterInventoryDto toggleEquipped(Long inventoryId) {
        CharacterInventory inventory = inventoryRepository.findById(inventoryId)
                .orElseThrow(() -> new RuntimeException("Inventory item not found"));

        boolean willBeEquipped = !inventory.isEquipped();

        // Los items que requieren attunement solo pueden equiparse si ya están
        // attuned — el frontend ya lo impide vía drag-and-drop, esto es defensa en
        // profundidad para que la regla se cumpla sin depender solo de la UI (#16).
        if (willBeEquipped && effectiveRequiresAttunement(inventory) && !inventory.isAttuned()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "This item requires attunement before it can be equipped");
        }

        inventory.setEquipped(willBeEquipped);

        // Sincronizar CharacterEquipment para ARMOR y SHIELD -> impulsa el cálculo de AC
        String itemType = inventory.getItem().getItemType();
        String armorType = inventory.getItem().getArmorType();
        boolean isShield = "Shield".equalsIgnoreCase(armorType);
        if (itemType != null && itemType.equalsIgnoreCase("armor")) {
            CharacterEquipment eq = equipmentRepository
                    .findByCharacter(inventory.getCharacter())
                    .orElseGet(() -> {
                        CharacterEquipment newEq = new CharacterEquipment(inventory.getCharacter());
                        return equipmentRepository.save(newEq);
                    });

            if (isShield) {
                // Shield va al slot offHand
                if (willBeEquipped) {
                    Item previousOffHand = eq.getOffHand();
                    if (previousOffHand != null && !previousOffHand.getId().equals(inventory.getItem().getId())) {
                        inventoryRepository
                                .findByCharacterAndItem(inventory.getCharacter(), previousOffHand)
                                .ifPresent(old -> {
                                    old.setEquipped(false);
                                    inventoryRepository.save(old);
                                });
                    }
                    eq.setOffHand(inventory.getItem());
                } else {
                    if (eq.getOffHand() != null && eq.getOffHand().getId().equals(inventory.getItem().getId())) {
                        eq.setOffHand(null);
                    }
                }
            } else {
                // Armadura real va al slot armor
                if (willBeEquipped) {
                    Item previousArmor = eq.getArmor();
                    if (previousArmor != null && !previousArmor.getId().equals(inventory.getItem().getId())) {
                        inventoryRepository
                                .findByCharacterAndItem(inventory.getCharacter(), previousArmor)
                                .ifPresent(old -> {
                                    old.setEquipped(false);
                                    inventoryRepository.save(old);
                                });
                    }
                    eq.setArmor(inventory.getItem());
                } else {
                    if (eq.getArmor() != null && eq.getArmor().getId().equals(inventory.getItem().getId())) {
                        eq.setArmor(null);
                    }
                }
            }
            equipmentRepository.save(eq);
        }

        inventoryRepository.save(inventory);
        return toDto(inventory);
    }

    // Infuse Item (Artificiero, #8) — aplica una infusión conocida a un objeto mundano. A
    // diferencia de attune/equip (booleanos), esto es "cuál" de las infusiones conocidas del
    // personaje lleva este objeto -- un solo campo nullable en CharacterInventory, ver su
    // comentario. No cuenta contra el límite de objetos infusionados si el objeto YA estaba
    // infusionado (cambiar de infusión no es "infusionar uno nuevo").
    @Transactional
    public CharacterInventoryDto applyInfusion(Long inventoryId, String infusionName) {
        CharacterInventory inventory = inventoryRepository.findById(inventoryId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Inventory item not found"));
        PlayerCharacter character = inventory.getCharacter();

        Infusion infusion = infusionService.requireKnownInfusion(character, infusionName);

        Item item = inventory.getItem();
        boolean alreadyMagical = item.isRequiresAttunement() || item.getBonusAc() != 0
                || item.getBonusToHit() != 0 || item.getBonusSavingThrows() != 0;
        if (alreadyMagical) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Infusions can only be applied to nonmagical objects");
        }

        if (inventory.getInfusionIndexName() == null) {
            int maxInfused = infusionService.maxInfusedItems(character);
            long currentlyInfused = inventoryRepository.findByCharacterId(character.getId()).stream()
                    .filter(ci -> ci.getInfusionIndexName() != null)
                    .count();
            if (currentlyInfused >= maxInfused) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Character already has " + maxInfused + " infused items (maximum)");
            }
        }

        inventory.setInfusionIndexName(infusion.getIndexName());
        inventoryRepository.save(inventory);
        return toDto(inventory);
    }

    @Transactional
    public CharacterInventoryDto removeInfusion(Long inventoryId) {
        CharacterInventory inventory = inventoryRepository.findById(inventoryId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Inventory item not found"));
        inventory.setInfusionIndexName(null);
        inventoryRepository.save(inventory);
        return toDto(inventory);
    }

    // Base weapon para plantillas de arma mágica genérica de Aurora (#21 Fase 2, ej. Acheron
    // Blade = "cualquier espada"): el catálogo (Item) se queda sin damageDice/damageType/
    // weaponRange propios -- el jugador elige a qué arma real corresponde SU instancia
    // concreta, y toDto() usa esos datos del arma elegida en vez de los (vacíos) del catálogo.
    @Transactional
    public CharacterInventoryDto selectBaseWeapon(Long inventoryId, String weaponIndexName) {
        CharacterInventory inventory = inventoryRepository.findById(inventoryId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Inventory item not found"));
        if (!inventory.getItem().isNeedsBaseWeaponChoice()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "This item does not need a base weapon choice");
        }
        Item baseWeapon = itemRepository.findByIndexName(weaponIndexName)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Base weapon not found"));
        if (baseWeapon.getDamageDice() == null || baseWeapon.getDamageDice().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Chosen item is not a real weapon");
        }
        inventory.setBaseWeaponIndexName(baseWeapon.getIndexName());
        inventoryRepository.save(inventory);
        return toDto(inventory);
    }

    @Transactional
    public CharacterInventoryDto clearBaseWeapon(Long inventoryId) {
        CharacterInventory inventory = inventoryRepository.findById(inventoryId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Inventory item not found"));
        inventory.setBaseWeaponIndexName(null);
        inventoryRepository.save(inventory);
        return toDto(inventory);
    }

    private CharacterInventoryDto toDto(CharacterInventory inventory) {
        CharacterInventoryDto dto = new CharacterInventoryDto();
        dto.setId(inventory.getId());
        dto.setCharacterId(inventory.getCharacter().getId());
        dto.setCharacterName(inventory.getCharacter().getName());
        dto.setItemId(inventory.getItem().getId());
        dto.setItemName(inventory.getItem().getName());
        dto.setItemType(inventory.getItem().getItemType());
        dto.setQuantity(inventory.getQuantity());
        dto.setWeight(inventory.getItem().getWeight());
        dto.setTotalWeight(inventory.getItem().getWeight() * inventory.getQuantity());
        dto.setAttuned(inventory.isAttuned());
        dto.setEquipped(inventory.isEquipped());
        dto.setNotes(inventory.getNotes());
        dto.setRequiresAttunement(effectiveRequiresAttunement(inventory));
        dto.setDescription(inventory.getItem().getDescription());

        // Plantilla de arma genérica (#21 Fase 2): usar los datos del arma real elegida por el
        // jugador para ESTA instancia en vez de los del catálogo, que se quedan vacíos a propósito.
        Item displayWeapon = inventory.getItem();
        dto.setNeedsBaseWeaponChoice(inventory.getItem().isNeedsBaseWeaponChoice());
        if (inventory.getBaseWeaponIndexName() != null) {
            Item resolved = itemRepository.findByIndexName(inventory.getBaseWeaponIndexName()).orElse(null);
            if (resolved != null) {
                displayWeapon = resolved;
                dto.setBaseWeaponIndexName(resolved.getIndexName());
                dto.setBaseWeaponName(resolved.getName());
            }
        }
        dto.setDamageDice(displayWeapon.getDamageDice());
        dto.setDamageType(displayWeapon.getDamageType());
        dto.setWeaponRange(displayWeapon.getWeaponRange());
        dto.setWeaponProperties(displayWeapon.getWeaponProperties());
        dto.setBonusAc(inventory.getItem().getBonusAc());
        dto.setBonusToHit(inventory.getItem().getBonusToHit());
        dto.setBonusSavingThrows(inventory.getItem().getBonusSavingThrows());

        if (inventory.getInfusionIndexName() != null) {
            infusionRepository.findByIndexName(inventory.getInfusionIndexName()).ifPresent(infusion -> {
                dto.setInfusionName(infusion.getName());
                dto.setInfusionDescription(infusion.getDescription());
                dto.setInfusionBonusTarget(infusion.getBonusTarget());
                if (infusion.getBonusTarget() != null) {
                    dto.setInfusionBonusValue(formulaService.evaluate(inventory.getCharacter(), infusion.getBonusFormula()));
                }
            });
        }
        return dto;
    }
}