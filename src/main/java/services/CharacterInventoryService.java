package services;

import dto.CharacterInventoryDto;
import entities.CharacterInventory;
import entities.PlayerCharacter;
import entities.Item;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterInventoryRepository;
import repositories.PlayerCharacterRepository;
import repositories.ItemRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CharacterInventoryService {

    private final CharacterInventoryRepository inventoryRepository;
    private final PlayerCharacterRepository characterRepository;
    private final ItemRepository itemRepository;

    public CharacterInventoryService(CharacterInventoryRepository inventoryRepository,
                                     PlayerCharacterRepository characterRepository,
                                     ItemRepository itemRepository) {
        this.inventoryRepository = inventoryRepository;
        this.characterRepository = characterRepository;
        this.itemRepository = itemRepository;
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
                .orElseThrow(() -> new RuntimeException("Inventory item not found"));

        // Verificar límite de attunement (máximo 3 items attuned)
        if (!inventory.isAttuned()) {
            long attunedCount = inventoryRepository.findByCharacterIdAndAttuned(
                    inventory.getCharacter().getId(), true).size();

            if (attunedCount >= 3) {
                throw new RuntimeException("Character already has 3 attuned items (maximum)");
            }
        }

        inventory.setAttuned(!inventory.isAttuned());
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
        return dto;
    }
}