package entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/** Mirrors CharacterClassResource, for RaceResource instead of ClassResource. See #9. */
@Entity
@Table(name = "character_race_resources")
public class CharacterRaceResource {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    @ManyToOne
    @JoinColumn(name = "race_resource_id", nullable = false)
    private RaceResource raceResource;

    private int maxAmount;
    private int currentAmount;

    public CharacterRaceResource() {}

    public CharacterRaceResource(PlayerCharacter character, RaceResource raceResource, int maxAmount) {
        this.character = character;
        this.raceResource = raceResource;
        this.maxAmount = maxAmount;
        this.currentAmount = maxAmount;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public PlayerCharacter getCharacter() { return character; }
    public void setCharacter(PlayerCharacter character) { this.character = character; }

    public RaceResource getRaceResource() { return raceResource; }
    public void setRaceResource(RaceResource raceResource) { this.raceResource = raceResource; }

    public int getMaxAmount() { return maxAmount; }
    public void setMaxAmount(int maxAmount) { this.maxAmount = maxAmount; }

    public int getCurrentAmount() { return currentAmount; }
    public void setCurrentAmount(int currentAmount) { this.currentAmount = currentAmount; }
}
