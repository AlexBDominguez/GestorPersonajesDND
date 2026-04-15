package controllers;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import dto.ItemDto;
import entities.Item;
import repositories.ItemRepository;

@RestController
@RequestMapping("/api/items")
public class ItemController {

    private final ItemRepository itemRepository;

    public ItemController(ItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    // GET /api/items                        -> todos
    // GET /api/items?type=weapon            ->filtro por tipo
    // GET /api/items?name=sword             ->   búsqueda por nombre
    // GET /api/items?type=weapon&name=sword -> combinado


    @GetMapping
    public ResponseEntity<List<ItemDto>> getItems(
        @RequestParam(required = false) String type,
        @RequestParam(required = false) String name) {

        List<Item> items;
        if (type != null && name != null) {
            items = 
                itemRepository.findByItemTypeAndNameContainingIgnoreCase(type, name);
        }else if (type != null) {
            items = itemRepository.findByItemType(type);
        }else if (name != null) {
            items = itemRepository.findByNameContainingIgnoreCase(name);
        }else {
            items = itemRepository.findAll();
        }

        return ResponseEntity.ok(
            items.stream().map(this::toDto).collect(Collectors.toList()));
        }

        @GetMapping("/{id}")
        public ResponseEntity<ItemDto> getById(@PathVariable Long id) {
            return itemRepository.findById(id)
                .map(item -> ResponseEntity.ok(toDto(item)))
                .orElse(ResponseEntity.notFound().build());
        }

        private ItemDto toDto(Item item) {
        ItemDto dto = new ItemDto();
        dto.setId(item.getId());
        dto.setIndexName(item.getIndexName());
        dto.setName(item.getName());
        dto.setItemType(item.getItemType());
        dto.setCategory(item.getCategory());
        dto.setWeight(item.getWeight());
        dto.setCostInCopper(item.getCostInCopper());
        dto.setDescription(item.getDescription());
        dto.setDamageDice(item.getDamageDice());
        dto.setDamageType(item.getDamageType());
        dto.setWeaponRange(item.getWeaponRange());
        dto.setWeaponProperties(item.getWeaponProperties());
        dto.setArmorClass(item.getArmorClass());
        dto.setArmorType(item.getArmorType());
        dto.setRarity(item.getRarity());
        dto.setRequiresAttunement(item.isRequiresAttunement());
        return dto;
    }

    
}
