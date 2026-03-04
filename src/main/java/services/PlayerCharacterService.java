package services;

import dto.PlayerCharacterDto;
import entities.PlayerCharacter;
import entities.Race;
import entities.Spell;
import entities.SpellSlotProgression;
import jakarta.transaction.Transactional;
import entities.CharacterSpell;
import entities.CharacterSpellSlot;
import entities.ClassLevelFeature;
import entities.ClassLevelProgression;
import entities.DndClass;

import org.springframework.stereotype.Service;
import repositories.PlayerCharacterRepository;
import repositories.RaceRepository;
import repositories.SpellRepository;
import repositories.SpellSlotProgressionRepository;
import repositories.CharacterSpellSlotRepository;
import repositories.CharacterSpellRepository;
import repositories.DndClassRepository;
import repositories.ClassLevelProgressionRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PlayerCharacterService {

    private final PlayerCharacterRepository characterRepository;
    private final RaceRepository raceRepository;
    private final DndClassRepository dndClassRepository;
    private final CharacterSpellRepository characterSpellRepository;
    private final SpellRepository spellRepository;
    private final SpellSlotProgressionRepository spellSlotProgressionRepository;
    private final CharacterSpellSlotRepository slotRepository;
    private final ClassLevelProgressionRepository classLevelProgressionRepository;

    public PlayerCharacterService(PlayerCharacterRepository characterRepository,
                                  RaceRepository raceRepository,
                                  DndClassRepository dndClassRepository,
                                  CharacterSpellRepository characterSpellRepository,
                                  SpellRepository spellRepository,
                                  SpellSlotProgressionRepository spellSlotProgressionRepository,
                                  CharacterSpellSlotRepository slotRepository,
                                  ClassLevelProgressionRepository classLevelProgressionRepository) {
        this.characterRepository = characterRepository;
        this.raceRepository = raceRepository;
        this.dndClassRepository = dndClassRepository;
        this.characterSpellRepository = characterSpellRepository;
        this.spellRepository = spellRepository;
        this.spellSlotProgressionRepository = spellSlotProgressionRepository;
        this.slotRepository = slotRepository;
        this.classLevelProgressionRepository = classLevelProgressionRepository;
    }

    public List<PlayerCharacterDto> getAll() {
        return characterRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public PlayerCharacterDto getById(Long id) {
        PlayerCharacter playerCharacter = characterRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("PlayerCharacter not found with ID: " + id));

        return toDto(playerCharacter);
    }

    public PlayerCharacterDto create(PlayerCharacterDto dto) {
        PlayerCharacter playerCharacter = new PlayerCharacter();

        playerCharacter.setName(dto.getName());
        playerCharacter.setLevel(dto.getLevel());
        playerCharacter.setAbilityScores(dto.getAbilityScores());
        playerCharacter.setBackstory(dto.getBackstory());
        playerCharacter.setCurrentHP(dto.getCurrentHp());
        playerCharacter.setMaxHP(dto.getMaxHp());

        Race race = raceRepository.findById(dto.getRaceId())
                .orElseThrow(() -> new RuntimeException("Race not found"));
        playerCharacter.setRace(race);

        DndClass dndClass = dndClassRepository.findById(dto.getDndClassId())
                .orElseThrow(() -> new RuntimeException("DndClass not found"));
        playerCharacter.setDndClass(dndClass);

        playerCharacter.setProficiencyBonus((int) Math.ceil((2 + (dto.getLevel() - 1) / 4.0)));

        characterRepository.save(playerCharacter);
        generateSpellSlots(playerCharacter);
        return toDto(playerCharacter);
    }

    private PlayerCharacterDto toDto(PlayerCharacter playerCharacter) {

        PlayerCharacterDto dto = new PlayerCharacterDto();

        dto.setId(playerCharacter.getId());
        dto.setName(playerCharacter.getName());
        dto.setLevel(playerCharacter.getLevel());
        dto.setAbilityScores(playerCharacter.getAbilityScores());
        dto.setProficiencyBonus(playerCharacter.getProficiencyBonus());
        dto.setBackstory(playerCharacter.getBackstory());
        dto.setCurrentHp(playerCharacter.getCurrentHP());
        dto.setMaxHp(playerCharacter.getMaxHP());

        if (playerCharacter.getRace() != null) {
            dto.setRaceId(playerCharacter.getRace().getId());
            dto.setRaceName(playerCharacter.getRace().getName());
        }

        if (playerCharacter.getDndClass() != null) {
            dto.setDndClassId(playerCharacter.getDndClass().getId());
            dto.setDndClassName(playerCharacter.getDndClass().getName());
        }

        return dto;
    }

    // Añadir hechizos al personaje
    public void addSpellToCharacter(Long characterId, Long spellId){
        
        PlayerCharacter character = characterRepository.findById(characterId)
            .orElseThrow(() -> new RuntimeException("Character not found"));

        Spell spell = spellRepository.findById(spellId)
            .orElseThrow(() -> new RuntimeException("Spell not found"));

        // Crear la relación CharacterSpell en lugar de usar getSpells()
        CharacterSpell characterSpell = new CharacterSpell(character, spell);
        characterSpellRepository.save(characterSpell);
    }


    // Aprender hechizos
    public void learnSpell(Long characterId, Long spellId) {

        PlayerCharacter character = characterRepository.findById(characterId)
            .orElseThrow(() -> new RuntimeException("Character not found"));

        Spell spell = spellRepository.findById(spellId)
            .orElseThrow(() -> new RuntimeException("Spell not found"));

        CharacterSpell characterSpell = new CharacterSpell(character, spell);
        
        characterSpellRepository.save(characterSpell);
    }

    //Preparar hechizos
    public void prepareSpell(Long characterId, Long spellId) {
        
        CharacterSpell characterSpell = characterSpellRepository
            .findByCharacterIdAndSpellId(characterId, spellId)
            .orElseThrow(() -> new RuntimeException("Spell not learned"));

        characterSpell.setPrepared(true);

        characterSpellRepository.save(characterSpell);
    }

    // Lanzar hechizos
    public void castSpell(Long characterId, Long spellId){

        CharacterSpell characterSpell = characterSpellRepository
            .findByCharacterIdAndSpellId(characterId, spellId)
            .orElseThrow(() -> new RuntimeException("Spell not learned"));

        if (!characterSpell.isPrepared()){
            throw new RuntimeException("Spell is not prepared");            
        }

        Spell spell = characterSpell.getSpell();
        int spellLevel = spell.getLevel();

        CharacterSpellSlot slot = slotRepository.findByCharacterIdAndSpellLevel(characterId, spellLevel);

        if(slot == null){
            throw new RuntimeException("No spell slots available for this spell level");
        }

        if(slot.getUsedSlots() >= slot.getMaxSlots()){
            throw new RuntimeException("No spell slots available");
        }

        slot.setUsedSlots(slot.getUsedSlots() + 1);
        characterSpell.setTimesCast(characterSpell.getTimesCast() + 1);

        slotRepository.save(slot);
        characterSpellRepository.save(characterSpell);
    }   

    // Generar ranuras de hechizos
    public void generateSpellSlots(PlayerCharacter character) {
        //Borrar slots anteriores

        List<CharacterSpellSlot> existingSlots = slotRepository.findByCharacterId(character.getId());
        slotRepository.deleteAll(existingSlots);

        //Buscar progresión según clase y nivel
        List<SpellSlotProgression> progression = 
            spellSlotProgressionRepository.findByDndClassAndCharacterLevel(
                character.getDndClass(),
                character.getLevel()  
        );

        for(SpellSlotProgression p: progression){
            CharacterSpellSlot slot = new CharacterSpellSlot();
            slot.setCharacter(character);
            slot.setSpellLevel(p.getSpellLevel());
            slot.setMaxSlots(p.getSlots());
            slot.setUsedSlots(0);

            slotRepository.save(slot);
        }
    }

    //Subir de nivel
    @Transactional
    public void startLevelUp(Long characterId){

        PlayerCharacter character = characterRepository.findById(characterId)
            .orElseThrow(() -> new RuntimeException("Character not found"));

        int newLevel = character.getLevel() + 1;
        character.setLevel(newLevel);

        updateProficiency(character);

        characterRepository.save(character);

        ClassLevelProgression progression = 
            classLevelProgressionRepository
            .findByDndClassAndLevel(character.getDndClass(), newLevel)
            .orElseThrow(() -> new RuntimeException("No progression data"));

        for(ClassLevelFeature feature : progression.getFeatures()){
            if(feature.isRequiresChoice()){
                createTask(character, newLevel, feature);
            }else{
                applyAutomaticFeature(character, feature);
            }
        }
    }
    

    //Descanso largo
    @Transactional
    public void longRest(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
            .orElseThrow(() -> new RuntimeException("Character not found"));

        // Recuperar todos los spell slots
        List<CharacterSpellSlot> slots = 
            slotRepository.findByCharacterId(characterId);

        for (CharacterSpellSlot slot: slots){
            slot.setUsedSlots(0);
        }

        slotRepository.saveAll(slots);

        //Recuperar HP al máximo
        character.setCurrentHP(character.getMaxHP());
        characterRepository.save(character);
    }

    private void updateProficiency(PlayerCharacter character){
        int level = character.getLevel();

        int proficiency = 2 + ((level -1) / 4);
        character.setProficiencyBonus(proficiency);
    }

    private void createTask(PlayerCharacter character, int targetLevel, ClassLevelFeature feature) {
        // TODO: Implementar lógica de creación de tareas
        // Este método será implementado en el futuro
    }

    private void applyAutomaticFeature(PlayerCharacter character, ClassLevelFeature feature) {
        // TODO: Implementar lógica de aplicación automática de features
        // Este método será implementado en el futuro
    }

}
