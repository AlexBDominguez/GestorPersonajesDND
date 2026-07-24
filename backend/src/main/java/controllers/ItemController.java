package controllers;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
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

        // #9: creación manual de items homebrew desde el panel de admin. Incluye los bonos
        // mecánicos de #21 (bonusAc/bonusToHit/bonusDamage/set*To) para que un item creado a
        // mano pueda tener efecto real en la ficha, no solo texto descriptivo.
        @PostMapping
        @PreAuthorize("hasRole('ADMIN')")
        public ResponseEntity<?> create(@RequestBody ItemDto dto) {
            if (dto.getIndexName() == null || dto.getIndexName().isBlank()) {
                return ResponseEntity.badRequest().body("indexName is required");
            }
            if (itemRepository.findByIndexName(dto.getIndexName()).isPresent()) {
                return ResponseEntity.status(HttpStatus.CONFLICT)
                        .body("An item with indexName '" + dto.getIndexName() + "' already exists");
            }
            Item item = toEntity(dto);
            return ResponseEntity.ok(toDto(itemRepository.save(item)));
        }

        private Item toEntity(ItemDto dto) {
            Item item = new Item();
            item.setIndexName(dto.getIndexName());
            item.setName(dto.getName());
            item.setItemType(dto.getItemType());
            item.setCategory(dto.getCategory());
            item.setWeight(dto.getWeight());
            item.setCostInCopper(dto.getCostInCopper());
            item.setDescription(dto.getDescription());
            item.setDamageDice(dto.getDamageDice());
            item.setDamageType(dto.getDamageType());
            item.setWeaponRange(dto.getWeaponRange());
            item.setWeaponProperties(dto.getWeaponProperties());
            item.setArmorClass(dto.getArmorClass());
            item.setArmorType(dto.getArmorType());
            item.setRarity(dto.getRarity());
            item.setRequiresAttunement(dto.isRequiresAttunement());
            item.setBonusAc(dto.getBonusAc());
            item.setBonusToHit(dto.getBonusToHit());
            item.setBonusDamage(dto.getBonusDamage());
            item.setBonusSavingThrows(dto.getBonusSavingThrows());
            item.setSetStrTo(dto.getSetStrTo());
            item.setSetDexTo(dto.getSetDexTo());
            item.setSetConTo(dto.getSetConTo());
            item.setSetIntTo(dto.getSetIntTo());
            item.setSetWisTo(dto.getSetWisTo());
            item.setSetChaTo(dto.getSetChaTo());
            item.setSource("Homebrew");
            return item;
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
        dto.setBonusAc(item.getBonusAc());
        dto.setBonusToHit(item.getBonusToHit());
        dto.setBonusDamage(item.getBonusDamage());
        dto.setBonusSavingThrows(item.getBonusSavingThrows());
        dto.setSetStrTo(item.getSetStrTo());
        dto.setSetDexTo(item.getSetDexTo());
        dto.setSetConTo(item.getSetConTo());
        dto.setSetIntTo(item.getSetIntTo());
        dto.setSetWisTo(item.getSetWisTo());
        dto.setSetChaTo(item.getSetChaTo());
        return dto;
    }

    
}
