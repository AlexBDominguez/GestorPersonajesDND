package dto;

/**
 * Body para POST /api/characters/{id}/pending-tasks/{taskId}/resolve
 * choice: la elección del jugador (texto libre o indexName según el tipo)
 * extraData: JSON adicional si la resolución necesita más info (ej: ASI scores)
 */
public class ResolveTaskRequest {
    private String choice;
    private String extraData;
    public String getChoice() {
        return choice;
    }
    public void setChoice(String choice) {
        this.choice = choice;
    }
    public String getExtraData() {
        return extraData;
    }
    public void setExtraData(String extraData) {
        this.extraData = extraData;
    }

    

}
