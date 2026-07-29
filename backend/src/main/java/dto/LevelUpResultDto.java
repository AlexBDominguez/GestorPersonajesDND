package dto;

import java.util.List;

public class LevelUpResultDto {
    private String message;
    private List<String> warnings;
    private PlayerCharacterDto character;

    public LevelUpResultDto() {
    }

    public LevelUpResultDto(String message, List<String> warnings, PlayerCharacterDto character) {
        this.message = message;
        this.warnings = warnings;
        this.character = character;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public List<String> getWarnings() {
        return warnings;
    }

    public void setWarnings(List<String> warnings) {
        this.warnings = warnings;
    }

    public PlayerCharacterDto getCharacter() {
        return character;
    }

    public void setCharacter(PlayerCharacterDto character) {
        this.character = character;
    }
}
