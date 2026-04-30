package services;

import dto.PlayerCharacterDto;
import dto.SpellSlotDto;
import dto.CharacterSavingThrowDto;
import dto.CharacterSkillDto;
import dto.CharacterSpellSummaryDto;
import entities.*;
import enumeration.FeatureType;
import jakarta.transaction.Transactional;

import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import repositories.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
    private final SubclassRepository subclassRepository;
    private final SubraceRepository subraceRepository;
    private final CharacterClassResourceService characterClassResourceService;
    private final CharacterEquipmentRepository equipmentRepository;
    private final CharacterActiveEffectRepository characterActiveEffectRepository;
    private final UserRepository userRepository;
    private final CharacterFeatService characterFeatService;

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
            BackgroundRepository backgroundRepository,
            SubclassRepository subclassRepository,
            SubraceRepository subraceRepository,
            CharacterClassResourceService characterClassResourceService,
            CharacterEquipmentRepository equipmentRepository,
            CharacterActiveEffectRepository characterActiveEffectRepository,
            UserRepository userRepository,
            CharacterFeatService characterFeatService

        ) {
        this.characterRepository = characterRepository;
        this.raceRepository = raceRepository;
        this.dndClassRepository = dndClassRepository;
        this.characterSpellRepository = characterSpellRepository;
        this.userRepository = userRepository;
        this.characterFeatService = characterFeatService;
        this.spellRepository = spellRepository;
        this.spellSlotProgressionRepository = spellSlotProgressionRepository;
        this.slotRepository = slotRepository;
        this.classLevelProgressionRepository = classLevelProgressionRepository;
        this.classFeatureRepository = classFeatureRepository;
        this.characterFeatureRepository = characterFeatureRepository;
        this.pendingTaskRepository = pendingTaskRepository;
        this.characterSkillService = characterSkillService;
        this.backgroundRepository = backgroundRepository;
        this.subclassRepository = subclassRepository;
        this.subraceRepository = subraceRepository;
        this.characterClassResourceService = characterClassResourceService;
        this.equipmentRepository = equipmentRepository;
        this.characterActiveEffectRepository = characterActiveEffectRepository;
    }

    // ========== CRUD BÁSICO ==========

    public List<PlayerCharacterDto> getAll() {
        return characterRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public PlayerCharacterDto getById(Long id) {
        PlayerCharacter playerCharacter = characterRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("PlayerCharacter not found with ID: " + id));
        return toDto(playerCharacter);
    }

    @Transactional
    public PlayerCharacterDto create(PlayerCharacterDto dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + dto.getUserId()));

        long charCount = characterRepository.countByUser(user);
        if (charCount >= UserService.MAX_CHARACTERS_PER_USER){
            throw new ResponseStatusException(
                HttpStatus.FORBIDDEN,
                "Character limit reached (" + UserService.MAX_CHARACTERS_PER_USER + " per user).");
        }



        PlayerCharacter playerCharacter = new PlayerCharacter();

        playerCharacter.setName(dto.getName());
        playerCharacter.setLevel(dto.getLevel());
        // Normalizar claves de ability scores a minúsculas para coincidir con la lógica interna de la entidad
        if (dto.getAbilityScores() != null) {
            Map<String, Integer> normalized = new HashMap<>();
            dto.getAbilityScores().forEach((k, v) -> normalized.put(k.toLowerCase(), v));
            dto.setAbilityScores(normalized);
        }
        playerCharacter.setAbilityScores(dto.getAbilityScores());
        playerCharacter.setBackstory(dto.getBackstory());
        playerCharacter.setCurrentHP(dto.getCurrentHp());
        playerCharacter.setMaxHP(dto.getMaxHp());
        playerCharacter.setAlignment(dto.getAlignment());
        playerCharacter.setTemporaryHP(dto.getTemporaryHP());
        playerCharacter.setDeathSaveSuccesses(dto.getDeathSaveSuccesses());
        playerCharacter.setDeathSaveFailures(dto.getDeathSaveFailures());
        playerCharacter.setHasInspiration(dto.isHasInspiration());
        playerCharacter.setExperiencePoints(dto.getExperiencePoints());
        playerCharacter.setSpeedModifier(dto.getSpeedModifier());
        playerCharacter.setNaturalArmorBonus(dto.getNaturalArmorBonus());
        playerCharacter.setInitiativeBonus(dto.getInitiativeBonus());
        playerCharacter.setUseEncumbrance(dto.isUseEncumbrance());

        //Hit dice disponibles = nivel del personaje (se consume 1 por cada descanso corto)
        playerCharacter.setAvailableHitDice(dto.getLevel());

        //Campos descriptivos
        playerCharacter.setAge(dto.getAge());
        playerCharacter.setHeight(dto.getHeight());
        playerCharacter.setWeight(dto.getWeight());
        playerCharacter.setEyes(dto.getEyes());
        playerCharacter.setSkin(dto.getSkin());
        playerCharacter.setHair(dto.getHair());
        playerCharacter.setAppearance(dto.getAppearance());
        playerCharacter.setAlliesAndOrganizations(dto.getAlliesAndOrganizations());
        playerCharacter.setAdditionalTreasure(dto.getAdditionalTreasure());
        playerCharacter.setCharacterHistory(dto.getCharacterHistory());


        Race race = raceRepository.findById(dto.getRaceId())
                .orElseThrow(() -> new RuntimeException("Race not found"));
        playerCharacter.setRace(race);

        DndClass dndClass = dndClassRepository.findById(dto.getDndClassId())
                .orElseThrow(() -> new RuntimeException("DndClass not found"));
        playerCharacter.setDndClass(dndClass);

        //Solo calcular si el DTO no trae HP válido
        if (dto.getMaxHp() <= 0 ) {
            //Calcular HP inicial escalado al nivel: nivel 1 = dado máximo + conMod; niveles adicionales = media (hitDie/2+1) + conMod
            int conScore = dto.getAbilityScores() != null
                    ? dto.getAbilityScores().getOrDefault("con", 10)
                    : 10;
            int conMod = (conScore - 10) / 2;
            int level = playerCharacter.getLevel() > 0 ? playerCharacter.getLevel() : 1;
            int hitDie = dndClass.getHitDie();
            int calcHp = (hitDie + conMod) + ((hitDie / 2 + 1 + conMod) * (level - 1));
            int startingHp = Math.max(level, calcHp);
            playerCharacter.setMaxHP(startingHp);
            playerCharacter.setCurrentHP(startingHp);
        }else{
            playerCharacter.setMaxHP(dto.getMaxHp());
            playerCharacter.setCurrentHP(dto.getCurrentHp() >0 ? dto.getCurrentHp() : dto.getMaxHp());
        }

        if(dto.getBackgroundId()!= null) {
            Background background = backgroundRepository.findById(dto.getBackgroundId())
                    .orElseThrow(() -> new RuntimeException("Background not found"));
            playerCharacter.setBackground(background);
        }

        if(dto.getSubclassId() != null) {
            Subclass subclass = subclassRepository.findById(dto.getSubclassId())
                    .orElseThrow(() -> new RuntimeException("Subclass not found"));

            // Verificar que la subclase pertenezca a la clase del personaje
            if(!subclass.getDndClass().getId().equals(dndClass.getId())){
                throw new RuntimeException("Subclass does not belong to the character's class");
            }
            playerCharacter.setSubclass(subclass);
        }

        if (dto.getSubraceId() != null) {
            Subrace subrace = subraceRepository.findById(dto.getSubraceId())
                    .orElseThrow(() -> new RuntimeException("Subrace not found"));
            playerCharacter.setSubrace(subrace);
        }

        playerCharacter.setPersonalityTraits(dto.getPersonalityTrait() != null ? dto.getPersonalityTrait().trim() : null);
        playerCharacter.setIdeals(dto.getIdeal());
        playerCharacter.setBonds(dto.getBond());
        playerCharacter.setFlaws(dto.getFlaw());

        playerCharacter.setProficiencyBonus(2 + ((dto.getLevel() - 1) / 4));

        if(dto.getUserId() != null) {
            playerCharacter.setUser(user);
        }else{
            throw new RuntimeException("User ID is required to create a character");
        }

        //Aplicar bonos raciales a los ability scores
        if(race.getAbilityBonuses() != null && !race.getAbilityBonuses().isEmpty()){
            Map<String, Integer> scores = new HashMap<>(playerCharacter.getAbilityScores());
            race.getAbilityBonuses().forEach((ability, bonus) -> {
                //Los bonos de raza también están en minúsculas en la BD
                scores.merge(ability, bonus, Integer::sum);
            });
            playerCharacter.setAbilityScores(scores);
        }

        PlayerCharacter saved = characterRepository.save(playerCharacter);

        //PROCESAMIENTO DE FEATS
        if(dto.getFeatIds() != null && !dto.getFeatIds().isEmpty()){
            for (Long featId : dto.getFeatIds()){
                characterFeatService.assignFeatToCharacter(saved.getId(), featId, null);
            }
        }

        //Inicializar skills y saving throws
        characterSkillService.initializeCharacterSkills(saved);
        characterSkillService.initializeSavingThrows(saved);

        if(saved.getBackground() != null) {
            applyBackgroundProficiencies(saved);
        }

        // Apply class skill picks from wizard
        if (dto.getClassSkillIndices() != null) {
            for (String skillIndex : dto.getClassSkillIndices()) {
                characterSkillService.applySkillProficiencyByIndex(saved, skillIndex);
            }
        }

        applyRaceSpells(saved);

        if (dto.getSpellIds() != null){
            for (Long spellId : dto.getSpellIds()){
                addSpellToCharacter(saved.getId(), spellId, "CLASS");
            }
        }

        if (dto.getMagicalSecretSpellIds() != null){
            for (Long spellId : dto.getMagicalSecretSpellIds()){
                addSpellToCharacter(saved.getId(), spellId, "MAGICAL_SECRETS");
            }
        }

        generateSpellSlots(saved);

        // Generate pending tasks for all choice-requiring features from level 1 to selectedLevel
        generateChoiceTasksForCreation(saved);

        // Generate pending tasks for race-level choices (e.g., Dragonborn Draconic Ancestry)
        generateRaceChoiceTasksForCreation(saved);
        
        return toDto(saved);
    }

    @Transactional
    public void delete(Long id){
        PlayerCharacter character = characterRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Character not found with ID: " + id));                
        characterRepository.delete(character);
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
        // Normalizar claves a minúsculas para consistencia en el cliente
        if (playerCharacter.getAbilityScores() != null) {
            Map<String, Integer> normalized = new HashMap<>();
            playerCharacter.getAbilityScores().forEach((k, v) -> normalized.put(k.toLowerCase(), v));
            dto.setAbilityScores(normalized);
        }
        dto.setProficiencyBonus(playerCharacter.getProficiencyBonus());
        dto.setBackstory(playerCharacter.getBackstory());
        dto.setCurrentHp(playerCharacter.getCurrentHP());
        dto.setMaxHp(playerCharacter.getMaxHP());
        dto.setUserId(playerCharacter.getUser() != null ? playerCharacter.getUser().getId():null);

        
        // Campos calculados automáticamente
        CharacterEquipment equipment = equipmentRepository.findByCharacter(playerCharacter).orElse(null);
        List<CharacterActiveEffect> activeEffects = characterActiveEffectRepository.findByCharacterIdAndActive(
        playerCharacter.getId(), true);
        dto.setArmorClass(playerCharacter.getArmorClass(equipment, activeEffects));
        dto.setSpellSaveDC(playerCharacter.getSpellSaveDC());
        dto.setSpellAttackBonus(playerCharacter.getSpellAttackBonus());
        dto.setInitiativeModifier(playerCharacter.getInitiativeModifier());
        dto.setCurrentSpeed(playerCharacter.getCurrentSpeed());
        dto.setMaxPreparedSpells(playerCharacter.getMaxPreparedSpells());
        dto.setEncumberedThreshold(playerCharacter.getEncumberedThreshold());
        dto.setHeavilyEncumberedThreshold(playerCharacter.getHeavilyEncumberedThreshold());
        dto.setUseEncumbrance(playerCharacter.isUseEncumbrance());
        dto.setMeleeAttackBonus(playerCharacter.getMeleeAttackBonus());
        dto.setRangedAttackBonus(playerCharacter.getRangedAttackBonus());
        dto.setFinesseAttackBonus(playerCharacter.getFinesseAttackBonus());
        dto.setExperienceToNextLevel(playerCharacter.getExperienceToNextLevel());
        dto.setExperienceNeeded(playerCharacter.getExperienceNeeded());
        dto.setDying(playerCharacter.isDying());
        dto.setStable(playerCharacter.isStable());
        dto.setDead(playerCharacter.isDead());
        dto.setConscious(playerCharacter.isConscious());

        // Passive skills (requieren consultar CharacterSkill)
        List<CharacterSkill> characterSkills = characterSkillService.getCharacterSkills(playerCharacter);
        dto.setPassivePerception(playerCharacter.getPassivePerception(characterSkills));
        dto.setPassiveInvestigation(playerCharacter.getPassiveInvestigation(characterSkills));
        dto.setPassiveInsight(playerCharacter.getPassiveInsight(characterSkills));

        // Skills con proficiencia y bonus calculado
        List<CharacterSkillDto> skillDtos = new ArrayList<>();
        for (CharacterSkill cs : characterSkills) {
            CharacterSkillDto skillDto = new CharacterSkillDto();
            skillDto.setId(cs.getId());
            skillDto.setSkillName(cs.getSkill().getName());
            skillDto.setAbilityScore(cs.getSkill().getAbilityScore());
            skillDto.setProficient(cs.isProficient());
            skillDto.setExpertise(cs.isExpertise());
            skillDto.setBonus(cs.getBonus());
            skillDtos.add(skillDto);
        }
        dto.setSkills(skillDtos);

        //Saving throws con proficiencia y bonus calculado
        List<CharacterSavingThrow> savingThrows =
                characterSkillService.getCharacterSavingThrows(playerCharacter);
        List<CharacterSavingThrowDto> savingThrowDtos = new ArrayList<>();
        for (CharacterSavingThrow st: savingThrows){
            CharacterSavingThrowDto stDto = new CharacterSavingThrowDto();
            stDto.setId(st.getId());
            stDto.setAbilityScore(st.getAbilityScore());
            stDto.setProficient(st.isProficient());
            int abilityMod = playerCharacter.calculateAbilityModifier(st.getAbilityScore());
            int profBonus = st.isProficient() ? playerCharacter.getProficiencyBonus() : 0;
            stDto.setBonus(abilityMod + profBonus);
            savingThrowDtos.add(stDto);
        }
        dto.setSavingThrows(savingThrowDtos);

        //Hechizos del personaje con detalle completo
        List<CharacterSpell> characterSpells =
            characterSpellRepository.findByCharacter(playerCharacter);
        List<CharacterSpellSummaryDto> spellDtos = new ArrayList<>();
        for(CharacterSpell characterSpell: characterSpells){
            Spell s = characterSpell.getSpell();
            CharacterSpellSummaryDto spellDto = new CharacterSpellSummaryDto();
            spellDto.setId(s.getId());
            spellDto.setName(s.getName());
            spellDto.setLevel(s.getLevel());
            spellDto.setSchool(s.getSchool());
            spellDto.setCastingTime(s.getCastingTime());
            spellDto.setRange(s.getRange());
            spellDto.setDuration(s.getDuration());
            spellDto.setComponents(s.getComponents());
            spellDto.setDescription(s.getDescription());
            spellDto.setPrepared(characterSpell.isPrepared());
            spellDto.setLearned(characterSpell.isLearned());
            spellDto.setSpellSource(characterSpell.getSpellSource());
            spellDto.setAttackType(s.getAttackType());
            spellDto.setDcType(s.getDcType());
            spellDto.setDamageType(s.getDamageType());
            spellDto.setDamageBase(s.getDamageBase());
            spellDtos.add(spellDto);
        }
        dto.setCharacterSpells(spellDtos);

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

        if(playerCharacter.getSubclass() != null) {
            dto.setSubclassId(playerCharacter.getSubclass().getId());
            dto.setSubclassName(playerCharacter.getSubclass().getName());
        }

        if (playerCharacter.getSubrace() != null) {
            dto.setSubraceId(playerCharacter.getSubrace().getId());
            dto.setSubraceName(playerCharacter.getSubrace().getName());
        }

        dto.setPersonalityTrait(playerCharacter.getPersonalityTraits());
        dto.setIdeal(playerCharacter.getIdeals());
        dto.setBond(playerCharacter.getBonds());
        dto.setFlaw(playerCharacter.getFlaws());

        dto.setAlignment(playerCharacter.getAlignment());
        dto.setTemporaryHP(playerCharacter.getTemporaryHP());
        dto.setDeathSaveSuccesses(playerCharacter.getDeathSaveSuccesses());
        dto.setDeathSaveFailures(playerCharacter.getDeathSaveFailures());
        dto.setHasInspiration(playerCharacter.isHasInspiration());
        dto.setExperiencePoints(playerCharacter.getExperiencePoints());
        dto.setSpeedModifier(playerCharacter.getSpeedModifier());
        dto.setNaturalArmorBonus(playerCharacter.getNaturalArmorBonus());
        dto.setInitiativeBonus(playerCharacter.getInitiativeBonus());
        dto.setAvailableHitDice(playerCharacter.getAvailableHitDice());

        // Campos descriptivos
        dto.setAge(playerCharacter.getAge());
        dto.setHeight(playerCharacter.getHeight());
        dto.setWeight(playerCharacter.getWeight());
        dto.setEyes(playerCharacter.getEyes());
        dto.setSkin(playerCharacter.getSkin());
        dto.setHair(playerCharacter.getHair());
        dto.setAppearance(playerCharacter.getAppearance());
        dto.setAlliesAndOrganizations(playerCharacter.getAlliesAndOrganizations());
        dto.setAdditionalTreasure(playerCharacter.getAdditionalTreasure());
        dto.setCharacterHistory(playerCharacter.getCharacterHistory());

        // Spell slots
        List<CharacterSpellSlot> slots = slotRepository.findByCharacterId(playerCharacter.getId());
        List<SpellSlotDto> slotDtos = slots.stream()
                .filter(s -> s.getMaxSlots() > 0)
                .sorted((a, b) -> Integer.compare(a.getSpellLevel(), b.getSpellLevel()))
                .map(s -> new SpellSlotDto(s.getSpellLevel(), s.getMaxSlots(), s.getUsedSlots()))
                .collect(Collectors.toList());
        dto.setSpellSlots(slotDtos);

        return dto;
    }

    // ========== SPELL MANAGEMENT ==========

    @Transactional
    public void addSpellToCharacter(Long characterId, Long spellId) {
        addSpellToCharacter(characterId, spellId, "CLASS");
    }

    @Transactional
    public void addSpellToCharacter(Long characterId, Long spellId, String source) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));
        Spell spell = spellRepository.findById(spellId)
                .orElseThrow(() -> new RuntimeException("Spell not found"));

        // Evitar duplicados
        if (characterSpellRepository.findByCharacterIdAndSpellId(characterId, spellId).isPresent()) {
            return;
        }

        CharacterSpell characterSpell = new CharacterSpell(character, spell, source);
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

    //Toggle Prepare
    @Transactional
    public void togglePrepareSpell(Long characterId, Long spellId) {
        CharacterSpell characterSpell = characterSpellRepository
                .findByCharacterIdAndSpellId(characterId, spellId)
                .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Spell not found on this character"
                ));

            //Los cantrips(nivel 0) no se pueden preparar/despreparar
            if(characterSpell.getSpell().getLevel() == 0){
                throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Cantrips are always available and cannot be prepared/unprepared");                
            }

            // Si va a preparar (actualmente no preparado), verificar el límite
            if (!characterSpell.isPrepared()) {
                PlayerCharacter character = characterRepository.findById(characterId)
                    .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Character not found"));
                int maxPrepared = character.getMaxPreparedSpells();
                if (maxPrepared > 0) {
                    int currentPrepared = characterSpellRepository
                        .countPreparedNonCantripsByCharacterId(characterId);
                    if (currentPrepared >= maxPrepared) {
                        throw new ResponseStatusException(
                            HttpStatus.UNPROCESSABLE_ENTITY,
                            "Spell preparation limit reached (" + maxPrepared + "/" + maxPrepared + ")");
                    }
                }
            }

            characterSpell.setPrepared(!characterSpell.isPrepared());
            characterSpellRepository.save(characterSpell);
    }

    // Eliminar spell del personaje
    @Transactional
    public void removeSpellFromCharacter(Long characterId, Long spellId) {
      CharacterSpell characterSpell = characterSpellRepository
                .findByCharacterIdAndSpellId(characterId, spellId)
                .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Spell not found on this character"));  
        //No permitir borrar spells otorgados por raza (source = RACE)
        if ("RACE".equalsIgnoreCase(characterSpell.getSpellSource())){
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST, "Racial spells cannot be removed");                
        }
        characterSpellRepository.delete(characterSpell);
    }


    //Usar un slot por nivel (para el botón CAST de la tab sin spellId)
    @Transactional
    public void useSpellSlot(Long characterId, int level){
        if (level == 0) return; //cantrips: sin coste

        CharacterSpellSlot slot = slotRepository
                .findByCharacterIdAndSpellLevel(characterId, level)
                .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "No spell slots for level " + level
                ));

                if (slot.getUsedSlots() >= slot.getMaxSlots()) {
                    throw new ResponseStatusException(
                        HttpStatus.CONFLICT, "No spell slots available for level " + level);
                }
                slot.setUsedSlots(slot.getUsedSlots() + 1);
                slotRepository.save(slot);
    }

    public void restoreSpellSlot(Long characterId, int level) {
        if (level == 0) return;

        CharacterSpellSlot slot = slotRepository
                .findByCharacterIdAndSpellLevel(characterId, level)
                .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "No spell slots for level " + level
                ));

        if (slot.getUsedSlots() <= 0) return; // ya en 0, no hacer nada
        slot.setUsedSlots(slot.getUsedSlots() - 1);
        slotRepository.save(slot);
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

        DndClass dndClass = character.getDndClass();
        Subclass subclass = character.getSubclass();
        boolean classHasSpellcasting = dndClass != null && dndClass.getSpellcastingAbility() != null
                && !dndClass.getSpellcastingAbility().isEmpty();
        boolean subclassHasSpellcasting = subclass != null && subclass.getSpellcastingAbility() != null
                && !subclass.getSpellcastingAbility().isEmpty();

        if (classHasSpellcasting) {
            // Standard full/half-caster: look up progression table
            List<SpellSlotProgression> progression =
                    spellSlotProgressionRepository.findByDndClassAndCharacterLevel(
                            dndClass, character.getLevel());
            for (SpellSlotProgression p : progression) {
                CharacterSpellSlot slot = new CharacterSpellSlot();
                slot.setCharacter(character);
                slot.setSpellLevel(p.getSpellLevel());
                slot.setMaxSlots(p.getSlots());
                slot.setUsedSlots(0);
                slotRepository.save(slot);
            }
        } else if (subclassHasSpellcasting) {
            // Third-caster subclass (Eldritch Knight / Arcane Trickster)
            saveThirdCasterSlots(character, character.getLevel());
        }
    }

    /** Computes and persists spell slots for a 1/3-caster at the given character level. */
    private void saveThirdCasterSlots(PlayerCharacter character, int level) {
        int[] slots = computeThirdCasterSlots(level);
        for (int spellLvl = 1; spellLvl <= 3; spellLvl++) {
            int maxSlots = slots[spellLvl - 1];
            if (maxSlots > 0) {
                CharacterSpellSlot slot = slotRepository
                        .findByCharacterAndSpellLevel(character, spellLvl)
                        .orElse(new CharacterSpellSlot());
                slot.setCharacter(character);
                slot.setSpellLevel(spellLvl);
                slot.setMaxSlots(maxSlots);
                slot.setUsedSlots(0);
                slotRepository.save(slot);
            }
        }
    }

    /**
     * Third-caster (1/3) spell slot table per character level (PHB Eldritch Knight / Arcane Trickster).
     * Returns int[3] = [lv1Slots, lv2Slots, lv3Slots].
     */
    private int[] computeThirdCasterSlots(int level) {
        int lv1 = 0, lv2 = 0, lv3 = 0;
        if (level >= 3)  lv1 = 2;
        if (level >= 4)  lv1 = 3;
        if (level >= 7)  { lv1 = 4; lv2 = 2; }
        if (level >= 10) lv2 = 3;
        if (level >= 13) lv3 = 2;
        if (level >= 18) lv3 = 3;
        return new int[]{lv1, lv2, lv3};
    }

    private void updateSpellSlots(PlayerCharacter character, int newLevel) {
        DndClass dndClass = character.getDndClass();
        Subclass subclass = character.getSubclass();
        boolean classHasSpellcasting = dndClass != null && dndClass.getSpellcastingAbility() != null
                && !dndClass.getSpellcastingAbility().isEmpty();
        boolean subclassHasSpellcasting = subclass != null && subclass.getSpellcastingAbility() != null
                && !subclass.getSpellcastingAbility().isEmpty();

        if (classHasSpellcasting) {
            List<SpellSlotProgression> progressions =
                    spellSlotProgressionRepository.findByDndClassAndCharacterLevel(dndClass, newLevel);
            if (progressions.isEmpty()) {
                System.out.println("No spell slot progression for level " + newLevel);
                return;
            }
            for (SpellSlotProgression progression : progressions) {
                int spellLevel = progression.getSpellLevel();
                int maxSlots = progression.getSlots();
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
        } else if (subclassHasSpellcasting) {
            // Third-caster level-up
            saveThirdCasterSlots(character, newLevel);
        } else {
            System.out.println("Character is not a spellcaster");
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


    // ========== COMBAT METHODS ==========

    // DAÑO
    @Transactional
    public PlayerCharacterDto takeDamage(Long characterId, int damage) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        // Primero se consume el HP temporal
        if (character.getTemporaryHP() > 0) {
            if (damage <= character.getTemporaryHP()) {
                character.setTemporaryHP(character.getTemporaryHP() - damage);
                damage = 0;
            } else {
                damage -= character.getTemporaryHP();
                character.setTemporaryHP(0);
            }
        }

        // Luego el HP actual
        if (damage > 0) {
            int newHP = Math.max(0, character.getCurrentHP() - damage);
            character.setCurrentHP(newHP);

            // Si llega a 0, resetear death saves
            if (newHP == 0) {
                character.setDeathSaveSuccesses(0);
                character.setDeathSaveFailures(0);
            }
        }

        characterRepository.save(character);
        return toDto(character);
    }

    // CURACIÓN
    @Transactional
    public PlayerCharacterDto heal(Long characterId, int healing) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        int newHP = Math.min(character.getMaxHP(), character.getCurrentHP() + healing);
        character.setCurrentHP(newHP);

        //Si se cura, reseatear death saves
        if (newHP > 0) {
            character.setDeathSaveSuccesses(0);
            character.setDeathSaveFailures(0);
        }
        characterRepository.save(character);
        return toDto(character);
    }

    // TEMPORAL HP
    @Transactional
    public PlayerCharacterDto setTemporaryHP(Long characterId, int tempHP) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        // El HP temporal no se acumula, solo se reemplaza si es mayor
        if (tempHP > character.getTemporaryHP()) {
            character.setTemporaryHP(tempHP);
        }

        characterRepository.save(character);
        return toDto(character);
    }

    @Transactional
    public PlayerCharacterDto recordDeathSave(Long characterId, boolean success){
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        if(character.getCurrentHP()>0){
            throw new RuntimeException("Character is not unconscious and does not need death saves");
        }

        if(success){
            character.setDeathSaveSuccesses(character.getDeathSaveSuccesses() +1 );

            //3 éxitos = estabilizado, pero sigue inconsciente
            if(character.getDeathSaveSuccesses() >= 3){
                character.setDeathSaveSuccesses(0);
                character.setDeathSaveFailures(0);
                // No se recupera HP, solo se estabiliza
           }        
        }else{
            character.setDeathSaveFailures(character.getDeathSaveFailures()+1);

                //3 fallos = muerte
                if(character.getDeathSaveFailures() >= 3){
                    //Aquí se podría marcar al personaje como muerto
                    //Por ahora solo dejamos los fallos registrados
                }
        }
    
            characterRepository.save(character);
            return toDto(character);
    }

    // Reseteo de death saves (por ejemplo, tras un descanso largo)
    @Transactional
    public PlayerCharacterDto resetDeathSaves(Long characterId){
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        character.setDeathSaveSuccesses(0);
        character.setDeathSaveFailures(0);

        characterRepository.save(character);
        return toDto(character);
    }

    // Inspiración
    @Transactional
    public PlayerCharacterDto toggleInspiration(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        character.setHasInspiration(!character.isHasInspiration());
        characterRepository.save(character);
        return toDto(character);
    }

    // Añadir XP
    @Transactional
        public PlayerCharacterDto addExperience(Long characterId, int xp) {
        PlayerCharacter character = characterRepository.findById(characterId)
               .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        character.setExperiencePoints(character.getExperiencePoints() + xp);

        characterRepository.save(character);
        return toDto(character);
    }

    // Gastar hit dice para curarse durante un descanso corto
    @Transactional
    public PlayerCharacterDto spendHitDice(Long characterId, int numberOfDice) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));
        
        if(character.getAvailableHitDice() < numberOfDice){
            throw new RuntimeException("Not enough hit dice available");
        }
        character.setAvailableHitDice(character.getAvailableHitDice() - numberOfDice);
        characterRepository.save(character);
        return toDto(character);
    }

    @Transactional
    public PlayerCharacterDto longRest(Long characterId) {
    PlayerCharacter character = characterRepository.findById(characterId)
            .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

    // 1. Restaurar HP al máximo
    character.setCurrentHP(character.getMaxHP());
    
    // 2. Restaurar HP temporal a 0 (se pierde durante el descanso)
    character.setTemporaryHP(0);
    
    // 3. Restaurar hit dice (mínimo la mitad del nivel, redondeado hacia abajo)
    int hitDiceToRestore = Math.max(1, character.getLevel() / 2);
    int newHitDice = Math.min(character.getLevel(), 
                              character.getAvailableHitDice() + hitDiceToRestore);
    character.setAvailableHitDice(newHitDice);
    
    // 4. Resetear death saves
    character.setDeathSaveSuccesses(0);
    character.setDeathSaveFailures(0);
    
    // 5. Restaurar TODOS los spell slots
    List<CharacterSpellSlot> spellSlots = slotRepository.findByCharacter(character);
    for (CharacterSpellSlot slot : spellSlots) {
        slot.setUsedSlots(0);
        slotRepository.save(slot);
    }
    
    // 6. Restaurar recursos de clase que se recuperan en LONG_REST
    characterClassResourceService.recoverResources(characterId, "LONG_REST");
    
    // 7. Remover condiciones temporales que duren menos de 8 horas
    // Esto lo manejamos con el CharacterConditionService si es necesario
    // Por ahora, asumimos que las condiciones temporales se manejan manualmente
    
    characterRepository.save(character);
    
    System.out.println("Character " + character.getName() + " completed a long rest.");
    System.out.println("- HP restored to " + character.getMaxHP());
    System.out.println("- Hit dice restored: " + hitDiceToRestore + " (total: " + newHitDice + "/" + character.getLevel() + ")");
    System.out.println("- All spell slots restored");
    System.out.println("- All class resources restored");
    
    return toDto(character);
}


    @Transactional
    public PlayerCharacterDto shortRest(Long characterId, int hitDiceToSpend, int hitDiceRoll) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        if (hitDiceToSpend < 0) {
            throw new RuntimeException("Cannot spend negative hit dice");
        }
        
        if (hitDiceToSpend > character.getAvailableHitDice()) {
            throw new RuntimeException("Not enough hit dice available. Available: " + 
                                    character.getAvailableHitDice() + ", tried to spend: " + hitDiceToSpend);
        }

        // 1. Gastar hit dice y recuperar HP
        if (hitDiceToSpend > 0) {
            // hitDiceRoll = suma de las tiradas de dados + modificador CON por dado
            int conModifier = character.calculateAbilityModifier("con");
            int totalHealing = hitDiceRoll + (conModifier * hitDiceToSpend);
            
            // No se puede curar más allá del máximo
            int newHP = Math.min(character.getMaxHP(), character.getCurrentHP() + totalHealing);
            character.setCurrentHP(newHP);
            
            // Reducir hit dice disponibles
            character.setAvailableHitDice(character.getAvailableHitDice() - hitDiceToSpend);
            
            System.out.println("Character spent " + hitDiceToSpend + " hit dice and recovered " + 
                            (newHP - (newHP - totalHealing)) + " HP");
        }
        
            // 2. Restaurar spell slots de Warlock (Pact Magic)
        if (character.getDndClass() != null && 
            character.getDndClass().getIndexName() != null && 
            character.getDndClass().getIndexName().equalsIgnoreCase("warlock")) {
            
            List<CharacterSpellSlot> spellSlots = slotRepository.findByCharacter(character);
            for (CharacterSpellSlot slot : spellSlots) {
                slot.setUsedSlots(0);
                slotRepository.save(slot);
            }
            
            System.out.println("Warlock spell slots restored (Pact Magic)");
        }
        
        // 3. Restaurar recursos de clase que se recuperan en SHORT_REST
        characterClassResourceService.recoverResources(characterId, "SHORT_REST");
        
        characterRepository.save(character);
        
        System.out.println("Character " + character.getName() + " completed a short rest.");
        
        return toDto(character);
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

    /**
     * Creates PendingTasks for every choice-requiring ClassLevelFeature from level 1
     * to the character's starting level. Does NOT apply automatic features (those are
     * already handled during create()).
     */
    private void generateChoiceTasksForCreation(PlayerCharacter character) {
        DndClass dndClass = character.getDndClass();
        if (dndClass == null) return;
        for (int level = 1; level <= character.getLevel(); level++) {
            ClassLevelProgression progression =
                classLevelProgressionRepository.findByDndClassAndLevel(dndClass, level)
                    .orElse(null);
            if (progression == null) continue;
            List<ClassLevelFeature> features = progression.getFeatures();
            if (features == null) continue;
            for (ClassLevelFeature feature : features) {
                if (feature.isRequiresChoice()) {
                    createTask(character, level, feature);
                }
            }
        }
    }

    private void createTask(PlayerCharacter character, int level, ClassLevelFeature feature) {
        System.out.println("Creating task for feature type: " + feature.getType());

        // SPELL_LEARN / SPELL_PREPARE: initial spells are selected directly in the
        // creation wizard (spellIds in the DTO). These tasks are only relevant for
        // level-up, not for the initial creation.
        if (feature.getType() == FeatureType.SPELL_LEARN ||
            feature.getType() == FeatureType.SPELL_PREPARE) {
            System.out.println("Skipping " + feature.getType() + " at creation – handled by wizard spell selection.");
            return;
        }

        // SUBCLASS_CHOICE: if the wizard already chose a subclass, no pending task needed.
        if (feature.getType() == FeatureType.SUBCLASS_CHOICE &&
            character.getSubclass() != null) {
            System.out.println("Skipping SUBCLASS_CHOICE – subclass already chosen: " + character.getSubclass().getName());
            return;
        }

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

            case FAVORED_ENEMY:
                task.setTaskType("FAVORED_ENEMY");
                task.setDescription("Choose your Favored Enemy");
                break;
            
            case FAVORED_TERRAIN:
                task.setTaskType("FAVORED_TERRAIN");
                task.setDescription("Choose your Favored Terrain (Natural Explorer)");
                break;
            
            case DRACONIC_ANCESTRY:
                task.setTaskType("DRACONIC_ANCESTRY");
                task.setDescription("Choose your Draconic Ancestry (determines Breath Weapon damage type)");
                break;

            case EXPERTISE:
                task.setTaskType("EXPERTISE");
                task.setDescription("Choose skills to gain Expertise (double proficiency bonus)");
                task.setMetadata(feature.getMetadata()); // numero de skills a elegir
                break;

            default:
                System.out.println("Unknown task type for: " + feature.getType());
                return;
        }

        pendingTaskRepository.save(task);
        System.out.println("Task created: " + task.getTaskType());
    }

    /**
     * Creates PendingTasks for CHOICE_REQUIRED racial traits of the character's race (and subrace).
     * Only creates a task if no task of the same type+level already exists (avoids duplicates
     * e.g. for a Dragonborn Draconic Sorcerer whose class already generated a DRACONIC_ANCESTRY task).
     */
    private void generateRaceChoiceTasksForCreation(PlayerCharacter character) {
        List<RacialTrait> allTraits = new ArrayList<>();

        Race race = character.getRace();
        if (race != null && race.getTraits() != null) {
            allTraits.addAll(race.getTraits());
        }
        Subrace subrace = character.getSubrace();
        if (subrace != null && subrace.getTraits() != null) {
            allTraits.addAll(subrace.getTraits());
        }

        // These traits are derived from draconic-ancestry — they don't need their own task
        java.util.Set<String> derivedTraits = java.util.Set.of("breath-weapon", "damage-resistance");

        List<PendingTask> existing = pendingTaskRepository.findByCharacter(character);

        for (RacialTrait trait : allTraits) {
            // high-elf-cantrip may not be CHOICE_REQUIRED in the DB (needs re-sync to fix),
            // so we check it explicitly by indexName too.
            boolean isChoice = "CHOICE_REQUIRED".equals(trait.getTraitType()) ||
                               "high-elf-cantrip".equals(trait.getIndexName());
            if (!isChoice) continue;
            if (derivedTraits.contains(trait.getIndexName())) continue;

            String taskType;
            String description;
            switch (trait.getIndexName()) {
                case "draconic-ancestry":
                    taskType = "DRACONIC_ANCESTRY";
                    description = "Choose your Draconic Ancestry (determines Breath Weapon damage type)";
                    break;
                case "extra-language":
                    taskType = "EXTRA_LANGUAGE";
                    description = "Choose an extra language";
                    break;
                case "high-elf-cantrip":
                    taskType = "HIGH_ELF_CANTRIP";
                    description = "Choose one wizard cantrip (High Elf trait)";
                    break;
                case "skill-versatility": {
                    // Half-Elf gets TWO separate skill choices
                    String[] svTypes = {"SKILL_VERSATILITY_1", "SKILL_VERSATILITY_2"};
                    String[] svDescs = {
                        "Choose first skill proficiency (Skill Versatility)",
                        "Choose second skill proficiency (Skill Versatility)"
                    };
                    for (int i = 0; i < svTypes.length; i++) {
                        final String svType = svTypes[i];
                        boolean svExists = existing.stream()
                            .anyMatch(t -> svType.equals(t.getTaskType()) && t.getRelatedLevel() == 1);
                        if (!svExists) {
                            PendingTask svTask = new PendingTask();
                            svTask.setCharacter(character);
                            svTask.setRelatedLevel(1);
                            svTask.setCompleted(false);
                            svTask.setTaskType(svType);
                            svTask.setDescription(svDescs[i]);
                            pendingTaskRepository.save(svTask);
                            System.out.println("Race task created: " + svType + " for " + character.getName());
                        } else {
                            System.out.println("Race task " + svType + " level 1 already exists, skipping.");
                        }
                    }
                    continue;
                }
                case "tool-proficiency":
                    taskType = "TOOL_PROFICIENCY";
                    description = "Choose a tool proficiency (smith's tools, brewer's supplies, or mason's tools)";
                    break;
                default:
                    System.out.println("Skipping unhandled racial choice trait: " + trait.getIndexName());
                    continue;
            }

            // Avoid duplicate tasks (e.g. Draconic Sorcerer already has this from class features)
            final String finalTaskType = taskType;
            boolean alreadyExists = existing.stream()
                .anyMatch(t -> finalTaskType.equals(t.getTaskType()) && t.getRelatedLevel() == 1);
            if (alreadyExists) {
                System.out.println("Race task " + taskType + " level 1 already exists, skipping.");
                continue;
            }

            PendingTask task = new PendingTask();
            task.setCharacter(character);
            task.setRelatedLevel(1);
            task.setCompleted(false);
            task.setTaskType(taskType);
            task.setDescription(description);
            pendingTaskRepository.save(task);
            System.out.println("Race task created: " + taskType + " for " + character.getName());
        }
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

    // ========== SUBCLASS ==========
   @Transactional
    public PlayerCharacterDto assignSubclass(Long characterId, Long subclassId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));
        
        Subclass subclass = subclassRepository.findById(subclassId)
                .orElseThrow(() -> new RuntimeException("Subclass not found with ID: " + subclassId));
        
        // Verificar que la subclase pertenezca a la clase del personaje
        if (!subclass.getDndClass().getId().equals(character.getDndClass().getId())) {
            throw new RuntimeException("Subclass does not belong to character's class");
        }
        
        // Verificar que el personaje tenga el nivel adecuado
        Integer subclassLevel = character.getDndClass().getSubclassLevel();
        if (subclassLevel != null && character.getLevel() < subclassLevel) {
            throw new RuntimeException("Character must be at least level " + subclassLevel + " to choose a subclass");
        }
        
        character.setSubclass(subclass);
        characterRepository.save(character);
        
        return toDto(character);
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


    // En PlayerCharacterService.java
    @Transactional
    public List<PlayerCharacterDto> getCharactersByUserId(Long userId) {
        return characterRepository.findByUserId(userId)
                .stream()
                .map(this::convertToDto) 
                .collect(Collectors.toList());
    }

    // Método auxiliar para convertir entity a DTO
    private PlayerCharacterDto convertToDto(PlayerCharacter character) {
        PlayerCharacterDto dto = new PlayerCharacterDto();
        dto.setId(character.getId());
        dto.setName(character.getName());
        dto.setLevel(character.getLevel());
        dto.setCurrentHp(character.getCurrentHP());
        dto.setMaxHp(character.getMaxHP());
        // Normalizar claves a minúsculas para consistencia en el cliente
        if (character.getAbilityScores() != null) {
            Map<String, Integer> normalizedScores = new HashMap<>();
            character.getAbilityScores().forEach((k, v) -> normalizedScores.put(k.toLowerCase(), v));
            dto.setAbilityScores(normalizedScores);
        }
        dto.setExperiencePoints(character.getExperiencePoints());
        dto.setProficiencyBonus(character.getProficiencyBonus());
        dto.setAlignment(character.getAlignment());
        
        // Calcular armorClass con equipment y efectos activos
        CharacterEquipment equipment = equipmentRepository.findByCharacterId(character.getId()).orElse(null);
        List<CharacterActiveEffect> activeEffects = characterActiveEffectRepository.findByCharacterId(character.getId());
        dto.setArmorClass(character.getArmorClass(equipment, activeEffects));
        
        if (character.getBackground() != null) {
            dto.setBackgroundId(character.getBackground().getId());
            dto.setBackgroundName(character.getBackground().getName());
        }
        
        if (character.getRace() != null) {
            dto.setRaceId(character.getRace().getId());
            dto.setRaceName(character.getRace().getName());
        }
        
        if (character.getDndClass() != null) {
            dto.setDndClassId(character.getDndClass().getId());
            dto.setDndClassName(character.getDndClass().getName());
        }
        
        return dto;
    }

    private void applyRaceSpells(PlayerCharacter character){
        Race race = character.getRace();
        if(race == null || race.getGrantedSpells() == null || race.getGrantedSpells().isEmpty()){
            return;
        }
        for (Spell spell: race.getGrantedSpells()){
            //Evitar duplicados por si se llama más de una vez
            boolean alreadyHas = characterSpellRepository
                    .findByCharacterIdAndSpellId(character.getId(), spell.getId())
                    .isPresent();
            if(!alreadyHas){
                CharacterSpell characterSpell = new CharacterSpell(character, spell, "RACE");
                characterSpellRepository.save(characterSpell);
                System.out.println("Granted racial spell: " + spell.getName() + " to: " + character.getName());
            }
        }
    }

}
