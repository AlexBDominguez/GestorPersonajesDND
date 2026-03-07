package entities;

import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.*;

@Entity
@Table(name = "spells")
public class Spell {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique=true)
    private String indexApi;

    private String name;
    private int level;
    private String school;
    private String castingTime;
    
    @Column(name = "`range`")
    private String range;
    
    private String duration;
    private String components;

    @Column(columnDefinition = "TEXT")
    private String description;


    @OneToMany(mappedBy = "spell")
    private Set<CharacterSpell> characterSpells = new HashSet<>();
    

    // Constructors
    public Spell() {}

    public Spell(String indexApi, String name, int level, String school,
                 String castingTime, String range, String duration,
                 String components, String description) {
        this.indexApi = indexApi;
        this.name = name;
        this.level = level;
        this.school = school;
        this.castingTime = castingTime;
        this.range = range;
        this.duration = duration;
        this.components = components;
        this.description = description;
    }

        // Getters and Setters


        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public String getIndexApi() {
            return indexApi;
        }

        public void setIndexApi(String indexApi) {
            this.indexApi = indexApi;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getLevel() {
            return level;
        }

        public void setLevel(int level) {
            this.level = level;
        }

        public String getSchool() {
            return school;
        }

        public void setSchool(String school) {
            this.school = school;
        }

        public String getCastingTime() {
            return castingTime;
        }

        public void setCastingTime(String castingTime) {
            this.castingTime = castingTime;
        }

        public String getRange() {
            return range;
        }

        public void setRange(String range) {
            this.range = range;
        }

        public String getDuration() {
            return duration;
        }

        public void setDuration(String duration) {
            this.duration = duration;
        }

        public String getComponents() {
            return components;
        }

        public void setComponents(String components) {
            this.components = components;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }
}
