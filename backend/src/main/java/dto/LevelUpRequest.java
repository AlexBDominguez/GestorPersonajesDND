package dto;

public class LevelUpRequest {
    
    private boolean useAverage;
    private Integer rolledHp; // Solo si useAverage es false

    public boolean isUseAverage() {
        return useAverage;
    }

    public void setUseAverage(boolean useAverage) {
        this.useAverage = useAverage;    
    }

    public Integer getRolledHp() {
        return rolledHp;
    }

    public void setRolledHp(Integer rolledHp) {
        this.rolledHp = rolledHp;
    }

}
