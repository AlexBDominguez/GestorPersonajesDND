package entities;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "character_inventories")
public class CharacterInventory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    @ManyToOne
    @JoinColumn(name = "item_id", nullable = false)
    private Item item;

    private int quantity;

    private boolean equipped;

    private boolean attuned;

    // index_name de la Infusion aplicada a este objeto (Infuse Item, Artificiero), o null si no
    // está infusionado. Un objeto solo puede llevar una infusión a la vez -- este único campo
    // nullable ya lo garantiza sin necesitar una tabla de enlace aparte. Ver InfusionService.
    @Column(name = "infusion_index_name")
    private String infusionIndexName;

    // index_name del Item-arma real (ej. "longsword") que representa esta instancia concreta de
    // un objeto-plantilla (Item.needsBaseWeaponChoice = true, ej. Acheron Blade = "cualquier
    // espada"). Null si el item no es una plantilla o el jugador aún no ha elegido. Solo afecta a
    // qué dados de daño/tipo/alcance se muestran (CharacterInventoryService.toDto) -- el bono
    // numérico del item ya se aplica igual sin esto, ver #21 en Aurora_Fixes.md.
    @Column(name = "base_weapon_index_name")
    private String baseWeaponIndexName;

    @Column(columnDefinition = "TEXT")
    private String notes;


    public CharacterInventory(){}

    public CharacterInventory(PlayerCharacter character, Item item, int quantity, boolean equipped, boolean attuned, String notes) {
        this.character = character;
        this.item = item;
        this.quantity = quantity;
        this.equipped = equipped;
        this.attuned = attuned;
        this.notes = notes;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public PlayerCharacter getCharacter() {
        return character;
    }

    public void setCharacter(PlayerCharacter character) {
        this.character = character;
    }

    public Item getItem() {
        return item;
    }

    public void setItem(Item item) {
        this.item = item;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public boolean isEquipped() {
        return equipped;
    }

    public void setEquipped(boolean equipped) {
        this.equipped = equipped;
    }

    public boolean isAttuned() {
        return attuned;
    }

    public void setAttuned(boolean attuned) {
        this.attuned = attuned;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getInfusionIndexName() {
        return infusionIndexName;
    }

    public void setInfusionIndexName(String infusionIndexName) {
        this.infusionIndexName = infusionIndexName;
    }

    public String getBaseWeaponIndexName() {
        return baseWeaponIndexName;
    }

    public void setBaseWeaponIndexName(String baseWeaponIndexName) {
        this.baseWeaponIndexName = baseWeaponIndexName;
    }


    
    
}
