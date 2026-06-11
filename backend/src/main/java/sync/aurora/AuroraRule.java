package sync.aurora;

public class AuroraRule {

    public enum RuleType { GRANT, SELECT, STAT, BONUS, OTHER }

    private RuleType ruleType;
    private String type;         // grant/select: "Proficiency", "Class Feature", "Size", etc.
    private String id;           // grant: Aurora element ID being granted
    private String name;         // select: display name; stat: stat key name
    private Integer level;       // grant/select: minimum character level (null = always)
    private String supports;     // select: filter tag, e.g. "Fighting Style, Fighter"
    private Integer number;      // select: how many choices the player can make
    private String requirements; // conditional logic string (IDs or expressions)
    private String value;        // stat/bonus: numeric value (as string to preserve +/-)
    private String bonus;        // stat: bonus type ("base", "ability", "proficiency", etc.)

    public RuleType getRuleType() { return ruleType; }
    public void setRuleType(RuleType ruleType) { this.ruleType = ruleType; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Integer getLevel() { return level; }
    public void setLevel(Integer level) { this.level = level; }

    public String getSupports() { return supports; }
    public void setSupports(String supports) { this.supports = supports; }

    public Integer getNumber() { return number; }
    public void setNumber(Integer number) { this.number = number; }

    public String getRequirements() { return requirements; }
    public void setRequirements(String requirements) { this.requirements = requirements; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }

    public String getBonus() { return bonus; }
    public void setBonus(String bonus) { this.bonus = bonus; }
}
