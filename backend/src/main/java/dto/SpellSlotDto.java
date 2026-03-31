package dto;

public class SpellSlotDto {
    private int spellLevel;
    private int maxSlots;
    private int usedSlots;

    public SpellSlotDto() {}

    public SpellSlotDto(int spellLevel, int maxSlots, int usedSlots) {
        this.spellLevel = spellLevel;
        this.maxSlots = maxSlots;
        this.usedSlots = usedSlots;
    }

    public int getSpellLevel() { return spellLevel; }
    public void setSpellLevel(int spellLevel) { this.spellLevel = spellLevel; }

    public int getMaxSlots() { return maxSlots; }
    public void setMaxSlots(int maxSlots) { this.maxSlots = maxSlots; }

    public int getUsedSlots() { return usedSlots; }
    public void setUsedSlots(int usedSlots) { this.usedSlots = usedSlots; }
}
