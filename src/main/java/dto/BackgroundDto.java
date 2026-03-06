package dto;

import java.util.List;

public class BackgroundDto {
    private Long id;
    private String indexName;
    private String name;
    private List<String> skillProficiencies;
    private List<String> toolProficiencies;
    private List<String> languages;
    private int languageOptions;
    private String feature;
    private String featureDescription;
    private String description;
    private List<String> personalityTraits;
    private List<String> ideals;
    private List<String> bonds;
    private List<String> flaws;
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getIndexName() {
        return indexName;
    }
    public void setIndexName(String indexName) {
        this.indexName = indexName;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public List<String> getSkillProficiencies() {
        return skillProficiencies;
    }
    public void setSkillProficiencies(List<String> skillProficiencies) {
        this.skillProficiencies = skillProficiencies;
    }
    public List<String> getToolProficiencies() {
        return toolProficiencies;
    }
    public void setToolProficiencies(List<String> toolProficiencies) {
        this.toolProficiencies = toolProficiencies;
    }
    public List<String> getLanguages() {
        return languages;
    }
    public void setLanguages(List<String> languages) {
        this.languages = languages;
    }
    public int getLanguageOptions() {
        return languageOptions;
    }
    public void setLanguageOptions(int languageOptions) {
        this.languageOptions = languageOptions;
    }
    public String getFeature() {
        return feature;
    }
    public void setFeature(String feature) {
        this.feature = feature;
    }
    public String getFeatureDescription() {
        return featureDescription;
    }
    public void setFeatureDescription(String featureDescription) {
        this.featureDescription = featureDescription;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public List<String> getPersonalityTraits() {
        return personalityTraits;
    }
    public void setPersonalityTraits(List<String> personalityTraits) {
        this.personalityTraits = personalityTraits;
    }
    public List<String> getIdeals() {
        return ideals;
    }
    public void setIdeals(List<String> ideals) {
        this.ideals = ideals;
    }
    public List<String> getBonds() {
        return bonds;
    }
    public void setBonds(List<String> bonds) {
        this.bonds = bonds;
    }
    public List<String> getFlaws() {
        return flaws;
    }
    public void setFlaws(List<String> flaws) {
        this.flaws = flaws;
    }

    // Getters and setters
    
}
