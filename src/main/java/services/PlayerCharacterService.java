package services;

import dto.PlayerCharacterDto;
import entities.*;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.*;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PlayerCharacterService {

    private final PlayerCharacterRepository characterRepository;
    private final CharacterSpellRepository characterSpellRepository;
    private final RaceRepository raceRepository;
    private final DndClassRepository dndClassRepository;
    private final SpellRepository spellRepository;
    private final SpellSlotProgressionRepository spellSlotProgressionRepository;
    private final CharacterSpellSlotRepository slotRepository;
    private final ClassLevelProgressionRepository classLevelProgressionRepository;
    private final ClassFeatureRepository classFeatureRepository;
    private final CharacterFeatureRepository characterFeatureRepository;
    private final PendingTaskRepository pendingTaskRepository;
    private final CharacterSkillService characterSkillService;
    private final BackgroundRepository backgroundRepository;

    public PlayerCharacterService(
            PlayerCharacterRepository characterRepository,
            RaceRepository raceRepository,
            DndClassRepository dndClassRepository,
            CharacterSpellRepository characterSpellRepository,
            SpellRepository spellRepository,
            SpellSlotProgressionRepository spellSlotProgressionRepository,
            CharacterSpellSlotRepository slotRepository,
            ClassLevelProgressionRepository classLevelProgressionRepository,
            ClassFeatureRepository classFeatureRepository,
            CharacterFeatureRepository characterFeatureRepository,
            PendingTaskRepository pendingTaskRepository,
            CharacterSkillService characterSkillService,
            BackgroundRepository backgroundRepository
        ) {
        this.characterRepository = characterRepository;
        this.raceRepository = raceRepository;
        this.dndClassRepository = dndClassRepository;
        this.characterSpellRepository = characterSpellRepository;
        this.spellRepository = spellRepository;
        this.spellSlotProgressionRepository = spellSlotProgressionRepository;
        this.slotRepository = slotRepository;
        this.classLevelProgressionRepository = classLevelProgressionRepository;
        this.classFeatureRepository = classFeatureRepository;
        this.characterFeatureRepository = characterFeatureRepository;
        this.pendingTaskRepository = pendingTaskRepository;
        this.characterSkillService = characterSkillService;
        this.backgroundRepository = backgroundRepository;
    }

    // ========== CRUD BÁSICO ==========

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

    @Transactional
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

        if(dto.getBackgroundId()!= null) {
            Background background = backgroundRepository.findById(dto.getBackgroundId())
                    .orElseThrow(() -> new RuntimeException("Background not found"));
            playerCharacter.setBackground(background);
        }

        // Map individual DTO fields to entity text fields
        String personalityTraits = (dto.getPersonalityTrait1() != null ? dto.getPersonalityTrait1() : "") +
                                  (dto.getPersonalityTrait2() != null ? "\n" + dto.getPersonalityTrait2() : "");
        playerCharacter.setPersonalityTraits(personalityTraits.trim());
        playerCharacter.setIdeals(dto.getIdeal());
        playerCharacter.setBonds(dto.getBond());
        playerCharacter.setFlaws(dto.getFlaw());

        playerCharacter.setProficiencyBonus(2 + ((dto.getLevel() - 1) / 4));

        PlayerCharacter saved = characterRepository.save(playerCharacter);

        //Inicializar skills y saving throws
        characterSkillService.initializeCharacterSkills(saved);
        characterSkillService.initializeSavingThrows(saved);

        if(saved.getBackground() != null) {
            applyBackgroundProficiencies(saved);
        }

        generateSpellSlots(saved);
        
        return toDto(saved);
    }

    private void applyBackgroundProficiencies(PlayerCharacter character) {
        Background background = character.getBackground();

        if(background.getSkillProficiencies()!= null) {
            for (String skillIndex : background.getSkillProficiencies()){
                characterSkillService.applySkillProficiencyByIndex(character, skillIndex);
            }
        }
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

        if(playerCharacter.getBackground() != null){
            dto.setBackgroundId(playerCharacter.getBackground().getId());
            dto.setBackgroundName(playerCharacter.getBackground().getName());
        }

        // Map entity text fields to individual DTO fields
        String[] traits = playerCharacter.getPersonalityTraits() != null ? 
                         playerCharacter.getPersonalityTraits().split("\n", 2) : new String[]{null, null};
        dto.setPersonalityTrait1(traits.length > 0 ? traits[0] : null);
        dto.setPersonalityTrait2(traits.length > 1 ? traits[1] : null);
        dto.setIdeal(playerCharacter.getIdeals());
        dto.setBond(playerCharacter.getBonds());
        dto.setFlaw(playerCharacter.getFlaws());

        return dto;
    }

    // ========== SPELL MANAGEMENT ==========

    @Transactional
    public void addSpellToCharacter(Long characterId, Long spellId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        Spell spell = spellRepository.findById(spellId)
                .orElseThrow(() -> new RuntimeException("Spell not found"));

        CharacterSpell characterSpell = new CharacterSpell(character, spell);
        characterSpellRepository.save(characterSpell);
    }

    @Transactional
    public void learnSpell(Long characterId, Long spellId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        Spell spell = spellRepository.findById(spellId)
                .orElseThrow(() -> new RuntimeException("Spell not found"));

        CharacterSpell characterSpell = new CharacterSpell(character, spell);
        characterSpellRepository.save(characterSpell);
    }

    @Transactional
    public void prepareSpell(Long characterId, Long spellId) {
        CharacterSpell characterSpell = characterSpellRepository
                .findByCharacterIdAndSpellId(characterId, spellId)
                .orElseThrow(() -> new RuntimeException("Spell not learned"));

        characterSpell.setPrepared(true);
        characterSpellRepository.save(characterSpell);
    }

    @Transactional
    public void castSpell(Long characterId, Long spellId) {
        CharacterSpell characterSpell = characterSpellRepository
                .findByCharacterIdAndSpellId(characterId, spellId)
                .orElseThrow(() -> new RuntimeException("Spell not learned"));

        if (!characterSpell.isPrepared()) {
            throw new RuntimeException("Spell is not prepared");
        }

        Spell spell = characterSpell.getSpell();
        int spellLevel = spell.getLevel();

        CharacterSpellSlot slot = slotRepository
                .findByCharacterIdAndSpellLevel(characterId, spellLevel)
                .orElseThrow(() -> new RuntimeException("No spell slots available for this spell level"));

        if (slot.getUsedSlots() >= slot.getMaxSlots()) {
            throw new RuntimeException("No spell slots available");
        }

        slot.setUsedSlots(slot.getUsedSlots() + 1);
        characterSpell.setTimesCast(characterSpell.getTimesCast() + 1);

        slotRepository.save(slot);
        characterSpellRepository.save(characterSpell);
    }

    // ========== SPELL SLOTS ==========

    @Transactional
    public void generateSpellSlots(PlayerCharacter character) {
        // Borrar slots anteriores
        List<CharacterSpellSlot> existingSlots = slotRepository.findByCharacterId(character.getId());
        slotRepository.deleteAll(existingSlots);

        // Buscar progresión según clase y nivel
        List<SpellSlotProgression> progression =
                spellSlotProgressionRepository.findByDndClassAndCharacterLevel(
                        character.getDndClass(),
                        character.getLevel()
                );

        for (SpellSlotProgression p : progression) {
            CharacterSpellSlot slot = new CharacterSpellSlot();
            slot.setCharacter(character);
            slot.setSpellLevel(p.getSpellLevel());
            slot.setMaxSlots(p.getSlots());
            slot.setUsedSlots(0);

            slotRepository.save(slot);
        }
    }

    private void updateSpellSlots(PlayerCharacter character, int newLevel) {
        DndClass dndClass = character.getDndClass();

        if (dndClass == null || dndClass.getSpellcastingAbility() == null) {
            System.out.println("Character is not a spellcaster");
            return;
        }

        // Obtener la progresión de spell slots para este nivel
        List<SpellSlotProgression> progressions =
                spellSlotProgressionRepository.findByDndClassAndCharacterLevel(dndClass, newLevel);

        if (progressions.isEmpty()) {
            System.out.println("No spell slot progression for level " + newLevel);
            return;
        }

        for (SpellSlotProgression progression : progressions) {
            int spellLevel = progression.getSpellLevel();
            int maxSlots = progression.getSlots();

            // Buscar o crear el slot del personaje
            CharacterSpellSlot characterSlot = slotRepository
                    .findByCharacterAndSpellLevel(character, spellLevel)
                    .orElse(new CharacterSpellSlot());

            characterSlot.setCharacter(character);
            characterSlot.setSpellLevel(spellLevel);
            characterSlot.setMaxSlots(maxSlots);
            characterSlot.setUsedSlots(0);

            slotRepository.save(characterSlot);

            System.out.println("Updated spell slots level " + spellLevel + ": " + maxSlots + " slots");
        }
    }

    // ========== LEVEL UP ==========

    @Transactional
    public PlayerCharacter levelUp(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        if (character.getLevel() >= 20) {
            throw new RuntimeException("Character is already at max level (20)");
        }

        int newLevel = character.getLevel() + 1;
        character.setLevel(newLevel);

        System.out.println("=== Leveling up " + character.getName() + " to level " + newLevel + " ===");

        // 1. Actualizar proficiency bonus
        updateProficiency(character);

        // 2. Procesar ClassLevelFeatures (sistema de mecánicas)
        processClassLevelFeatures(character, newLevel);

        // 3. Añadir ClassFeatures descriptivas del API
        addClassFeaturesFromAPI(character, newLevel);

        // 4. Guardar cambios
        characterRepository.save(character);

        System.out.println("=== Level up complete! ===");

        return character;
    }

    public PlayerCharacterDto levelUpAndReturnDto(Long characterId) {
        PlayerCharacter character = levelUp(characterId);
        return toDto(character);
    }

    private void updateProficiency(PlayerCharacter character) {
        int level = character.getLevel();
        int proficiency = 2 + ((level - 1) / 4);
        character.setProficiencyBonus(proficiency);
        System.out.println("Proficiency bonus updated to: " + proficiency);
    }

    private void processClassLevelFeatures(PlayerCharacter character, int newLevel) {
        DndClass dndClass = character.getDndClass();

        if (dndClass == null) {
            System.out.println("Warning: Character has no class assigned");
            return;
        }

        // Obtener la progresión de este nivel
        ClassLevelProgression progression =
                classLevelProgressionRepository.findByDndClassAndLevel(dndClass, newLevel)
                        .orElse(null);

        if (progression == null) {
            System.out.println("No progression data found for " + dndClass.getName() + " level " + newLevel);
            return;
        }

        // Obtener features mecánicas de este nivel
        List<ClassLevelFeature> features = progression.getFeatures();

        if (features == null || features.isEmpty()) {
            System.out.println("No features configured for this level");
            return;
        }

        for (ClassLevelFeature feature : features) {
            if (feature.isRequiresChoice()) {
                createTask(character, newLevel, feature);
            } else {
                applyAutomaticFeature(character, newLevel, feature);
            }
        }
    }

    private void createTask(PlayerCharacter character, int level, ClassLevelFeature feature) {
        System.out.println("Creating task for feature type: " + feature.getType());

        PendingTask task = new PendingTask();
        task.setCharacter(character);
        task.setRelatedLevel(level);
        task.setCompleted(false);

        switch (feature.getType()) {
            case ASI_OR_FEAT:
                task.setTaskType("ASI_OR_FEAT");
                task.setDescription("Choose between increasing ability scores (+2 to one or +1 to two) or taking a feat");
                break;

            case SPELL_LEARN:
                task.setTaskType("LEARN_SPELLS");
                task.setDescription("Learn new spell(s)");
                task.setMetadata(feature.getMetadata());
                break;

            case SPELL_PREPARE:
                task.setTaskType("PREPARE_SPELLS");
                task.setDescription("Prepare your spells");
                task.setMetadata(feature.getMetadata());
                break;

            case SUBCLASS_CHOICE:
                task.setTaskType("CHOOSE_SUBCLASS");
                task.setDescription("Choose your " + character.getDndClass().getName() + " subclass/archetype");
                break;

            case FIGHTING_STYLE:
                task.setTaskType("FIGHTING_STYLE");
                task.setDescription("Choose a fighting style");
                break;

            case INVOCATION:
                task.setTaskType("INVOCATION");
                task.setDescription("Choose Eldritch Invocation(s)");
                task.setMetadata(feature.getMetadata());
                break;

            case METAMAGIC:
                task.setTaskType("METAMAGIC");
                task.setDescription("Choose Metamagic option(s)");
                task.setMetadata(feature.getMetadata());
                break;

            default:
                System.out.println("Unknown task type for: " + feature.getType());
                return;
        }

        pendingTaskRepository.save(task);
        System.out.println("Task created: " + task.getTaskType());
    }

    private void applyAutomaticFeature(PlayerCharacter character, int level, ClassLevelFeature feature) {
        System.out.println("Applying automatic feature: " + feature.getType());

        switch (feature.getType()) {
            case HP_INCREASE:
                addHitPoints(character);
                break;

            case SPELL_SLOT_UPDATE:
                updateSpellSlots(character, level);
                break;

            case CLASS_FEATURE:
                System.out.println("Class feature (descriptive) - handled separately");
                break;

            default:
                System.out.println("No automatic action for: " + feature.getType());
        }
    }

    private void addHitPoints(PlayerCharacter character) {
        DndClass dndClass = character.getDndClass();

        if (dndClass == null) {
            throw new RuntimeException("Character has no class assigned");
        }

        int hitDie = dndClass.getHitDie();

        // Fórmula: promedio del dado + modificador CON
        int constitutionModifier = calculateAbilityModifier(
                character.getAbilityScores().getOrDefault("con", 10)
        );

        int hpGain = (hitDie / 2) + 1 + constitutionModifier;

        // Mínimo 1 HP por nivel
        if (hpGain < 1) {
            hpGain = 1;
        }

        int oldMaxHP = character.getMaxHP();
        character.setMaxHP(oldMaxHP + hpGain);
        character.setCurrentHP(character.getMaxHP());

        System.out.println("HP increased by " + hpGain + " (from " + oldMaxHP + " to " + character.getMaxHP() + ")");
    }

    private int calculateAbilityModifier(int abilityScore) {
        return (abilityScore - 10) / 2;
    }

    private void addClassFeaturesFromAPI(PlayerCharacter character, int newLevel) {
        DndClass dndClass = character.getDndClass();

        if (dndClass == null) {
            return;
        }

        // Obtener las features del API que se desbloquean en este nivel
        List<ClassFeature> newFeatures = classFeatureRepository
                .findByDndClassAndLevel(dndClass, newLevel);

        if (newFeatures.isEmpty()) {
            System.out.println("No API features found for level " + newLevel);
            return;
        }

        for (ClassFeature feature : newFeatures) {
            // Verificar si ya tiene esta feature
            boolean alreadyHas = characterFeatureRepository.findByCharacter(character)
                    .stream()
                    .anyMatch(cf -> cf.getClassFeature().getId().equals(feature.getId()));

            if (!alreadyHas) {
                CharacterFeature characterFeature = new CharacterFeature(
                        character,
                        feature,
                        newLevel
                );
                characterFeatureRepository.save(characterFeature);

                System.out.println("Added feature: " + feature.getName());
            }
        }
    }

    // ========== LONG REST ==========

    @Transactional
    public void longRest(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        // Recuperar todos los spell slots
        List<CharacterSpellSlot> slots = slotRepository.findByCharacterId(characterId);

        for (CharacterSpellSlot slot : slots) {
            slot.setUsedSlots(0);
        }

        slotRepository.saveAll(slots);

        // Recuperar HP al máximo
        character.setCurrentHP(character.getMaxHP());
        characterRepository.save(character);

        System.out.println(character.getName() + " completed a long rest (HP and spell slots restored)");
    }

    // ========== QUERY METHODS ==========

    public List<CharacterFeature> getCharacterFeatures(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));
        return characterFeatureRepository.findByCharacter(character);
    }

    public List<PendingTask> getPendingTasks(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));
        return pendingTaskRepository.findByCharacterAndCompletedFalse(character);
    }
}
