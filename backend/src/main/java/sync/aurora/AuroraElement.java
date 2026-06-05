package sync.aurora;

import java.util.*;

public class AuroraElement {

    private String id;              // e.g. "ID_PHB_RACE_ELF"
    private String name;            // e.g. "Elf"
    private String type;            // e.g. "Race", "Class", "Archetype", "Feat", "Spell", etc.
    private String source;          // Full book name, e.g. "Player's Handbook"
    private String description;     // Full text description
    private String sheetDescription; // Short character-sheet description from <sheet>
    private String supports;        // What this element qualifies as (comma-separated tags)
    private String requirements;    // Prerequisite expression
    private List<AuroraRule> rules = new ArrayList<>();
    private Map<String, String> setters = new LinkedHashMap<>(); // <set name="key">value</set>

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getSheetDescription() { return sheetDescription; }
    public void setSheetDescription(String sheetDescription) { this.sheetDescription = sheetDescription; }

    public String getSupports() { return supports; }
    public void setSupports(String supports) { this.supports = supports; }

    public String getRequirements() { return requirements; }
    public void setRequirements(String requirements) { this.requirements = requirements; }

    public List<AuroraRule> getRules() { return rules; }
    public void setRules(List<AuroraRule> rules) { this.rules = rules; }

    public Map<String, String> getSetters() { return setters; }
    public void setSetters(Map<String, String> setters) { this.setters = setters; }

    @Override
    public String toString() {
        return "AuroraElement{id='" + id + "', name='" + name + "', type='" + type + "', source='" + source + "'}";
    }
}
