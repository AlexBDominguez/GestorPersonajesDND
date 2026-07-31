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
    private final CharacterRaceResourceService characterRaceResourceService;
    private final CharacterEquipmentRepository equipmentRepository;
    private final CharacterActiveEffectRepository characterActiveEffectRepository;
    private final CharacterInventoryRepository characterInventoryRepository;
    private final UserRepository userRepository;
    private final CharacterFeatService characterFeatService;
    private final SubclassSpellService subclassSpellService;
    private final SubclassProficiencyService subclassProficiencyService;
    private final RacialTraitService racialTraitService;
    private final ClassSpellService classSpellService;
    private final NumericBonusService numericBonusService;
    private final InfusionRepository infusionRepository;
    private final CharacterFormulaService formulaService;
    private final PlayerCharacterClassRepository playerCharacterClassRepository;
    private final MulticlassRulesService multiclassRulesService;

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
            CharacterRaceResourceService characterRaceResourceService,
            CharacterEquipmentRepository equipmentRepository,
            CharacterActiveEffectRepository characterActiveEffectRepository,
            CharacterInventoryRepository characterInventoryRepository,
            UserRepository userRepository,
            CharacterFeatService characterFeatService,
            SubclassSpellService subclassSpellService,
            SubclassProficiencyService subclassProficiencyService,
            RacialTraitService racialTraitService,
            ClassSpellService classSpellService,
            NumericBonusService numericBonusService,
            InfusionRepository infusionRepository,
            CharacterFormulaService formulaService,
            PlayerCharacterClassRepository playerCharacterClassRepository,
            MulticlassRulesService multiclassRulesService

        ) {
        this.characterRepository = characterRepository;
        this.raceRepository = raceRepository;
        this.dndClassRepository = dndClassRepository;
        this.characterSpellRepository = characterSpellRepository;
        this.userRepository = userRepository;
        this.characterFeatService = characterFeatService;
        this.subclassSpellService = subclassSpellService;
        this.subclassProficiencyService = subclassProficiencyService;
        this.racialTraitService = racialTraitService;
        this.classSpellService = classSpellService;
        this.numericBonusService = numericBonusService;
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
        this.characterRaceResourceService = characterRaceResourceService;
        this.equipmentRepository = equipmentRepository;
        this.characterActiveEffectRepository = characterActiveEffectRepository;
        this.characterInventoryRepository = characterInventoryRepository;
        this.infusionRepository = infusionRepository;
        this.formulaService = formulaService;
        this.playerCharacterClassRepository = playerCharacterClassRepository;
        this.multiclassRulesService = multiclassRulesService;
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
        if (dto.getAbilityDisplayMode() != null) {
            playerCharacter.setAbilityDisplayMode(dto.getAbilityDisplayMode());
        }
        if (dto.getSelectedSources() != null && !dto.getSelectedSources().isEmpty()) {
            playerCharacter.setSelectedSources(dto.getSelectedSources());
        }

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

        // Tiradas de HP por nivel hechas en el wizard (nivel → valor tirado). Si un nivel
        // no tiene tirada aquí, su contribución se calcula con la media del dado.
        Map<Integer, Integer> hpRolls = dto.getHpRolls() != null
                ? new HashMap<>(dto.getHpRolls())
                : new HashMap<>();
        playerCharacter.setHpRolls(hpRolls);

        //Solo calcular si el DTO no trae HP válido
        if (dto.getMaxHp() <= 0 ) {
            //Calcular HP inicial escalado al nivel: nivel 1 = dado máximo + conMod;
            //niveles adicionales = tirada del jugador (si existe) o media (hitDie/2+1), + conMod
            int conScore = dto.getAbilityScores() != null
                    ? dto.getAbilityScores().getOrDefault("con", 10)
                    : 10;
            int conMod = (conScore - 10) / 2;
            int level = playerCharacter.getLevel() > 0 ? playerCharacter.getLevel() : 1;
            int hitDie = dndClass.getHitDie();
            int calcHp = hitDie + conMod;
            for (int lvl = 2; lvl <= level; lvl++) {
                Integer roll = hpRolls.get(lvl);
                int gain = (roll != null ? roll : (hitDie / 2 + 1)) + conMod;
                calcHp += Math.max(1, gain);
            }
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

        //Aplicar bonos raciales y de subraza a los ability scores.
        //Las subrazas normales (p.ej. High Elf) SUMAN su bono al de la raza base, pero algunos
        //linajes variantes (Tiefling MToF/SCAG) sustituyen por completo el bono de la raza base
        //en vez de sumarse a él (replacesRaceAbilityBonus) — si no, se contaría dos veces el CHA.
        Subrace subrace = playerCharacter.getSubrace();
        boolean subraceReplacesRaceBonus = subrace != null && subrace.isReplacesRaceAbilityBonus();
        Map<String, Integer> scores = new HashMap<>(playerCharacter.getAbilityScores());
        if (!subraceReplacesRaceBonus && race.getAbilityBonuses() != null) {
            //Los bonos de raza también están en minúsculas en la BD
            race.getAbilityBonuses().forEach((ability, bonus) -> scores.merge(ability, bonus, Integer::sum));
        }
        if (subrace != null && subrace.getAbilityBonuses() != null) {
            subrace.getAbilityBonuses().forEach((ability, bonus) -> scores.merge(ability, bonus, Integer::sum));
        }
        playerCharacter.setAbilityScores(scores);

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

        // Aplicar elecciones de skill de clase del wizard
        if (dto.getClassSkillIndices() != null) {
            for (String skillIndex : dto.getClassSkillIndices()) {
                characterSkillService.applySkillProficiencyByIndex(saved, skillIndex);
            }
        }

        // Aplicar expertise elegida en el wizard directamente en la creación
        if (dto.getExpertiseSkillNames() != null) {
            for (String skillName : dto.getExpertiseSkillNames()) {
                characterSkillService.applyExpertiseByName(saved, skillName);
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

        // Inicializar recursos de clase (cargas de Rabia, Ki Points, Bardic Inspiration, etc.)
        characterClassResourceService.initializeClassResourcesForCharacter(saved.getId());
        // Inicializar recursos de raza homebrew (#9, ej. aliento de un dracónido custom)
        characterRaceResourceService.initializeRaceResourcesForCharacter(saved.getId());

        // Generar tareas pendientes para todas las features que requieren elección del nivel 1 al nivel seleccionado
        generateChoiceTasksForCreation(saved);

        // Generar tareas pendientes para las elecciones de raza (p.ej., Dragonborn Draconic Ancestry)
        generateRaceChoiceTasksForCreation(saved);

        // Generar tareas pendientes específicas de la subclase (Battle Master, Totem Warrior, etc.)
        generateSubclassChoiceTasksForCreation(saved);

        // Aplicar hechizos automáticos de subclase (Dominios de Clérigo, Juramentos de Paladín, etc.)
        subclassSpellService.applySubclassSpells(saved, saved.getSubclass(), saved.getLevel());

        // Aplicar hechizos automáticos otorgados por features de la clase base (p.ej. Artificer)
        classSpellService.applyClassSpells(saved, saved.getDndClass(), saved.getLevel());

        // Aplicar proficiencias automáticas de subclase y crear tareas de elección
        subclassProficiencyService.applySubclassProficiencies(saved, saved.getSubclass());

        // Aplicar efectos de stat de subclase (Natural Armor, etc.)
        applySubclassStatEffects(saved, saved.getSubclass());

        // Bonificador de PG máximo declarativo (p.ej. Draconic Resilience: +1 por nivel) -- ver
        // #8.2 NUMERIC_BONUS. Retroactivo a todos los niveles ya alcanzados en la creación; las
        // subidas de nivel posteriores ya suman su parte en addHitPoints().
        int maxHpPerLevelBonus = numericBonusService.bonusFor(saved, "MAX_HP_PER_LEVEL");
        if (maxHpPerLevelBonus > 0) {
            saved.setMaxHP(saved.getMaxHP() + maxHpPerLevelBonus * saved.getLevel());
            saved.setCurrentHP(saved.getMaxHP());
        }

        // Aplicar efectos automáticos de traits raciales (proficiencias y hechizos sin elección)
        racialTraitService.applyAutomaticRacialTraits(saved);

        // Fundamento de multiclase (dual-write): la clase de creación siempre es classOrder=0
        // (proficiencies/saves completas). No sustituye a dndClass/subclass/level de arriba,
        // que se mantienen intactos como fuente de verdad para personajes mono-clase.
        PlayerCharacterClass primaryClass = new PlayerCharacterClass();
        primaryClass.setCharacter(saved);
        primaryClass.setDndClass(saved.getDndClass());
        primaryClass.setSubclass(saved.getSubclass());
        primaryClass.setLevel(saved.getLevel());
        primaryClass.setClassOrder(0);
        playerCharacterClassRepository.save(primaryClass);

        return toDto(saved);
    }

    @Transactional
    public void delete(Long id){
        PlayerCharacter character = characterRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Character not found with ID: " + id));                
        characterRepository.delete(character);
    }

    // ========== EDIT CHARACTER PROFILE ==========

    @Transactional
    public PlayerCharacterDto updateProfile(Long characterId, dto.CharacterProfileUpdateDto dto) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Character not found with ID: " + characterId));

        if (dto.getName() != null && !dto.getName().isBlank()) {
            character.setName(dto.getName().trim());
        }
        if (dto.getAlignment() != null)         character.setAlignment(dto.getAlignment());
        if (dto.getPersonalityTrait() != null)  character.setPersonalityTraits(dto.getPersonalityTrait());
        if (dto.getIdeal() != null)             character.setIdeals(dto.getIdeal());
        if (dto.getBond() != null)              character.setBonds(dto.getBond());
        if (dto.getFlaw() != null)              character.setFlaws(dto.getFlaw());
        if (dto.getAge() != null)               character.setAge(dto.getAge());
        if (dto.getHeight() != null)            character.setHeight(dto.getHeight());
        if (dto.getWeight() != null)            character.setWeight(dto.getWeight());
        if (dto.getEyes() != null)              character.setEyes(dto.getEyes());
        if (dto.getSkin() != null)              character.setSkin(dto.getSkin());
        if (dto.getHair() != null)              character.setHair(dto.getHair());
        if (dto.getAbilityDisplayMode() != null) character.setAbilityDisplayMode(dto.getAbilityDisplayMode());
        if (dto.getUseEncumbrance() != null)    character.setUseEncumbrance(dto.getUseEncumbrance());

        if (dto.getSubclassId() != null) {
            Subclass subclass = subclassRepository.findById(dto.getSubclassId())
                    .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Subclass not found"));
            if (!subclass.getDndClass().getId().equals(character.getDndClass().getId())) {
                throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Subclass does not belong to character's class");
            }
            character.setSubclass(subclass);
        }

        if (dto.getBackgroundId() != null) {
            Background background = backgroundRepository.findById(dto.getBackgroundId())
                    .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Background not found"));
            character.setBackground(background);
        }

        if (dto.getRaceId() != null) {
            Race race = raceRepository.findById(dto.getRaceId())
                    .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Race not found"));
            if (character.getRace() == null || !dto.getRaceId().equals(character.getRace().getId())) {
                character.setRace(race);
                character.setSubrace(null); // limpiar subraza al cambiar de raza
            }
        }

        if (dto.getSubraceId() != null) {
            Subrace subrace = subraceRepository.findById(dto.getSubraceId())
                    .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Subrace not found"));
            character.setSubrace(subrace);
        }

        if (dto.getAbilityScores() != null && !dto.getAbilityScores().isEmpty()) {
            Map<String, Integer> existingScores = character.getAbilityScores();
            if (existingScores == null) existingScores = new HashMap<>();
            existingScores.putAll(dto.getAbilityScores());
            character.setAbilityScores(existingScores);
        }

        characterRepository.save(character);
        return toDto(character);
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
        // ability scores se setean más abajo, tras computar los effective scores con overrides de items
        dto.setProficiencyBonus(playerCharacter.getProficiencyBonus());
        dto.setBackstory(playerCharacter.getBackstory());
        dto.setCurrentHp(playerCharacter.getCurrentHP());
        dto.setMaxHp(playerCharacter.getMaxHP());
        dto.setHpRolls(playerCharacter.getHpRolls());
        dto.setUserId(playerCharacter.getUser() != null ? playerCharacter.getUser().getId():null);

        
        // Campos calculados automáticamente
        CharacterEquipment equipment = equipmentRepository.findByCharacter(playerCharacter).orElse(null);
        List<CharacterActiveEffect> activeEffects = characterActiveEffectRepository.findByCharacterIdAndActive(
        playerCharacter.getId(), true);

        // Bonuses de objetos equipados / sintonizados
        List<CharacterInventory> inventory = characterInventoryRepository.findByCharacterId(playerCharacter.getId());
        int itemBonusAc = 0, itemBonusToHit = 0, itemBonusDamage = 0, itemBonusSavingThrows = 0;
        // Infusiones (Infuse Item, Artificiero, #8): a diferencia de los bonos de Item (que son
        // fijos por catálogo), el bono de una infusión depende del nivel del personaje (p.ej.
        // Enhanced Weapon pasa de +1 a +2 en nivel 10) y solo aplica al objeto concreto que la
        // lleva, no a todo lo demás -- ver Infusion.bonusTarget/bonusFormula. WEAPON_ATTACK_DAMAGE
        // se suma a itemBonusToHit (mismo mecanismo que ya usa cualquier arma +1 real) y por
        // separado a itemBonusDamage/meleeDamageBonus.
        int infusionWeaponDamageBonus = 0;
        int infusionSpellAttackBonus = 0;

        // Effective ability scores: copia de los scores base con overrides de items activos
        Map<String, Integer> effectiveScores = new HashMap<>();
        if (playerCharacter.getAbilityScores() != null) {
            playerCharacter.getAbilityScores().forEach((k, v) -> effectiveScores.put(k.toLowerCase(), v));
        }

        for (CharacterInventory ci : inventory) {
            Item item = ci.getItem();
            Infusion infusion = ci.getInfusionIndexName() != null
                    ? infusionRepository.findByIndexName(ci.getInfusionIndexName()).orElse(null)
                    : null;
            // Objetos que requieren sintonización (por el propio item o por la infusión que
            // llevan): el bonus aplica solo si están sintonizados. El resto, si están equipados.
            boolean requiresAttunementEffective = item.isRequiresAttunement()
                    || (infusion != null && infusion.isRequiresAttunement());
            boolean active = requiresAttunementEffective ? ci.isAttuned() : ci.isEquipped();
            if (active) {
                itemBonusAc            += item.getBonusAc();
                itemBonusToHit         += item.getBonusToHit();
                itemBonusDamage        += item.getBonusDamage();
                itemBonusSavingThrows  += item.getBonusSavingThrows();

                // Ability score overrides: solo aplica si la puntuación del item supera la actual
                applyAbilityOverride(effectiveScores, "str", item.getSetStrTo());
                applyAbilityOverride(effectiveScores, "dex", item.getSetDexTo());
                applyAbilityOverride(effectiveScores, "con", item.getSetConTo());
                applyAbilityOverride(effectiveScores, "int", item.getSetIntTo());
                applyAbilityOverride(effectiveScores, "wis", item.getSetWisTo());
                applyAbilityOverride(effectiveScores, "cha", item.getSetChaTo());

                if (infusion != null && infusion.getBonusTarget() != null) {
                    int bonus = formulaService.evaluate(playerCharacter, infusion.getBonusFormula());
                    switch (infusion.getBonusTarget()) {
                        case "AC" -> itemBonusAc += bonus;
                        case "WEAPON_ATTACK_DAMAGE" -> {
                            itemBonusToHit += bonus;
                            infusionWeaponDamageBonus += bonus;
                        }
                        case "SPELL_ATTACK" -> infusionSpellAttackBonus += bonus;
                        default -> { }
                    }
                }
            }
        }

        // Aplicar effective scores al personaje antes de calcular stats derivados
        playerCharacter.applyEffectiveAbilityScores(effectiveScores);

        // Fighting Style bonuses (Archery → +2 ranged; Defense → +1 AC while armored) --
        // declarativos vía #8.2 NUMERIC_BONUS, ver NumericBonusService.fightingStyleBonusFor().
        String fightingStyle = pendingTaskRepository
                .findByCharacterAndCompleted(playerCharacter, true)
                .stream()
                .filter(t -> "FIGHTING_STYLE".equals(t.getTaskType()) && t.getMetadata() != null)
                .map(t -> extractChoiceFromMetadata(t.getMetadata()))
                .filter(c -> c != null)
                .findFirst()
                .orElse(null);
        boolean wearingArmor = equipment != null && equipment.getArmor() != null;
        // Dueling exige un arma cma a una mano equipada y ninguna otra arma -- mismo criterio que
        // antes vivía hardcodeado en tab_combat.dart (vm.equippedWeapons.length == 1 && !ranged
        // && !two-handed), ahora migrado a NUMERIC_BONUS (condition
        // ";REQUIRES_SINGLE_ONE_HANDED_MELEE_WEAPON") para que un futuro fighting-style-like
        // grantable desde el panel admin (#9) con esta misma forma funcione sin tocar Dart.
        List<CharacterInventory> equippedWeapons = inventory.stream()
                .filter(ci -> ci.isEquipped() && ci.getItem().getDamageDice() != null
                        && !ci.getItem().getDamageDice().isEmpty())
                .collect(Collectors.toList());
        boolean singleOneHandedMeleeWeaponEquipped = equippedWeapons.size() == 1
                && !"ranged".equalsIgnoreCase(equippedWeapons.get(0).getItem().getWeaponRange())
                && (equippedWeapons.get(0).getItem().getWeaponProperties() == null
                        || equippedWeapons.get(0).getItem().getWeaponProperties().stream()
                                .noneMatch(p -> p.toLowerCase().contains("two-handed")));
        int fightingStyleAcBonus = numericBonusService.fightingStyleBonusFor(playerCharacter, "AC", wearingArmor, false);
        int fightingStyleRangedBonus = numericBonusService.fightingStyleBonusFor(playerCharacter, "RANGED_ATTACK", wearingArmor, false);
        int fightingStyleMeleeDamageBonus = numericBonusService.fightingStyleBonusFor(
                playerCharacter, "MELEE_DAMAGE", false, singleOneHandedMeleeWeaponEquipped);
        dto.setMeleeDamageBonus(fightingStyleMeleeDamageBonus + infusionWeaponDamageBonus + itemBonusDamage);
        // Expuesto al frontend también en crudo para Two-Weapon Fighting (sumar el mod. de
        // característica al daño del offhand no es un bono aditivo, es una regla que se activa/
        // desactiva -- no encaja en la forma de NUMERIC_BONUS, así que sigue leyéndose el campo
        // directamente en character_sheet_viewmodel.dart, antes corrigiendo un bug real: comprobaba
        // una ClassFeature que nunca existe, ya que el Fighting Style es una elección, no una
        // feature de clase).
        dto.setFightingStyle(fightingStyle);

        // Ability scores efectivos (con overrides de items ya aplicados al personaje)
        dto.setAbilityScores(effectiveScores);

        dto.setArmorClass(playerCharacter.getArmorClass(equipment, activeEffects) + itemBonusAc + fightingStyleAcBonus);
        dto.setMaxAttunementSlots(playerCharacter.getMaxAttunementSlots());
        dto.setSpellSaveDC(playerCharacter.getSpellSaveDC());
        dto.setSpellAttackBonus(playerCharacter.getSpellAttackBonus() + infusionSpellAttackBonus);
        dto.setInitiativeModifier(playerCharacter.getInitiativeModifier());
        dto.setCurrentSpeed(playerCharacter.getCurrentSpeed(activeEffects));
        dto.setMaxPreparedSpells(playerCharacter.getMaxPreparedSpells());
        dto.setEncumberedThreshold(playerCharacter.getEncumberedThreshold());
        dto.setHeavilyEncumberedThreshold(playerCharacter.getHeavilyEncumberedThreshold());
        dto.setUseEncumbrance(playerCharacter.isUseEncumbrance());
        dto.setAbilityDisplayMode(playerCharacter.getAbilityDisplayMode());
        dto.setSelectedSources(playerCharacter.getSelectedSources());
        dto.setMeleeAttackBonus(playerCharacter.getMeleeAttackBonus() + itemBonusToHit);
        dto.setRangedAttackBonus(playerCharacter.getRangedAttackBonus() + itemBonusToHit + fightingStyleRangedBonus);
        dto.setFinesseAttackBonus(playerCharacter.getFinesseAttackBonus() + itemBonusToHit);
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
            // + bonificadores declarativos condicionados a la skill (p.ej. Remarkable Athlete:
            // mitad de competencia en STR/DEX/CON sin ser competente) -- ver #8.2 NUMERIC_BONUS.
            skillDto.setBonus(cs.getBonus() + numericBonusService.conditionalSkillBonus(playerCharacter, cs));
            skillDtos.add(skillDto);
        }
        dto.setSkills(skillDtos);

        //Saving throws con proficiencia y bonus calculado
        List<CharacterSavingThrow> savingThrows =
                characterSkillService.getCharacterSavingThrows(playerCharacter);

        // Bonificadores declarativos a salvaciones (p.ej. Aura of Protection del Paladín) —
        // ver #8.2 NUMERIC_BONUS. Ya no hay ningún if/else por clase aquí: cualquier
        // ClassFeature/SubclassFeature con grantsBonusKey apuntando a un NumericBonus de
        // targetField "SAVING_THROW_ALL" se suma sola.
        int featureBonusSavingThrows = numericBonusService.bonusFor(playerCharacter, "SAVING_THROW_ALL");

        List<CharacterSavingThrowDto> savingThrowDtos = new ArrayList<>();
        for (CharacterSavingThrow st: savingThrows){
            CharacterSavingThrowDto stDto = new CharacterSavingThrowDto();
            stDto.setId(st.getId());
            stDto.setAbilityScore(st.getAbilityScore());
            stDto.setProficient(st.isProficient());
            int abilityMod = playerCharacter.calculateAbilityModifier(st.getAbilityScore());
            int profBonus = st.isProficient() ? playerCharacter.getProficiencyBonus() : 0;
            stDto.setBonus(abilityMod + profBonus + itemBonusSavingThrows + featureBonusSavingThrows);
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
            spellDto.setDamageAtSlotLevel(s.getDamageAtSlotLevel());
            // Bonificadores de daño declarativos (Elemental Affinity por tipo de daño, Empowered
            // Evocation por escuela, Agonizing Blast por hechizo concreto) -- ver #8.2 NUMERIC_BONUS.
            int bonusDamage = numericBonusService.spellDamageBonusFor(playerCharacter, s.getDamageType())
                    + numericBonusService.spellDamageBonusForSchool(playerCharacter, s.getSchool())
                    + numericBonusService.spellDamageBonusForNamedSpell(playerCharacter, s.getName());
            spellDto.setBonusDamage(bonusDamage);
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
                .filter(s -> s.getMaxSlots() + s.getBonusMax() > 0)
                .sorted((a, b) -> Integer.compare(a.getSpellLevel(), b.getSpellLevel()))
                // bonusMax (Hechicero: Flexible Casting, slots creados con puntos de hechicería
                // que no cuentan como progresión normal de clase) se pliega en maxSlots aquí para
                // que el resto de la app (frontend, useSpellSlot/restoreSpellSlot) no necesite
                // saber que existe -- ver createSpellSlotFromSorceryPoints más abajo.
                .map(s -> new SpellSlotDto(s.getSpellLevel(), s.getMaxSlots() + s.getBonusMax(), s.getUsedSlots()))
                .collect(Collectors.toList());
        dto.setSpellSlots(slotDtos);

        dto.setClasses(toClassDtos(playerCharacter));

        playerCharacter.clearEffectiveAbilityScores();

        return dto;
    }

    // Fundamento de multiclase (Aurora_Fixes.md #17, fase 1): lista de clases del personaje,
    // ordenadas por classOrder (0 = clase original). Reutilizada por toDto()/convertToDto().
    private List<dto.PlayerCharacterClassDto> toClassDtos(PlayerCharacter playerCharacter) {
        return playerCharacterClassRepository.findByCharacterOrderByClassOrderAsc(playerCharacter)
                .stream()
                .map(pcc -> {
                    dto.PlayerCharacterClassDto classDto = new dto.PlayerCharacterClassDto();
                    classDto.setId(pcc.getId());
                    classDto.setDndClassId(pcc.getDndClass().getId());
                    classDto.setDndClassName(pcc.getDndClass().getName());
                    if (pcc.getSubclass() != null) {
                        classDto.setSubclassId(pcc.getSubclass().getId());
                        classDto.setSubclassName(pcc.getSubclass().getName());
                    }
                    classDto.setLevel(pcc.getLevel());
                    classDto.setClassOrder(pcc.getClassOrder());
                    return classDto;
                })
                .collect(Collectors.toList());
    }

    // ========== SPELL MANAGEMENT ==========

    @Transactional
    public void addSpellToCharacter(Long characterId, Long spellId) {
        addSpellToCharacter(characterId, spellId, "CLASS", null);
    }

    @Transactional
    public void addSpellToCharacter(Long characterId, Long spellId, String source) {
        addSpellToCharacter(characterId, spellId, source, null);
    }

    /**
     * Multiclase (Aurora_Fixes.md #17, fase 4b): con classId informado, el hechizo queda
     * atribuido a esa clase y el chequeo de duplicados es POR CLASE -- dos clases distintas
     * SÍ pueden conocer el mismo hechizo (p.ej. Fireball en Wizard y en Sorcerer), a
     * diferencia del chequeo character-wide de siempre (sin classId, retrocompatible).
     */
    @Transactional
    public void addSpellToCharacter(Long characterId, Long spellId, String source, Long classId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));
        Spell spell = spellRepository.findById(spellId)
                .orElseThrow(() -> new RuntimeException("Spell not found"));

        DndClass targetClass = null;
        if (classId != null) {
            targetClass = dndClassRepository.findById(classId)
                    .orElseThrow(() -> new RuntimeException("DndClass not found"));
        }

        boolean alreadyExists = targetClass != null
                ? characterSpellRepository.existsByCharacterIdAndSpellIdAndDndClassId(characterId, spellId, classId)
                : characterSpellRepository.findByCharacterIdAndSpellId(characterId, spellId).isPresent();
        if (alreadyExists) {
            return;
        }

        CharacterSpell characterSpell = new CharacterSpell(character, spell, source);
        characterSpell.setDndClass(targetClass);
        characterSpellRepository.save(characterSpell);
    }

    // Multiclase (Aurora_Fixes.md #17, fase 4a): clases "de conocidos" (lista fija de
    // hechizos conocidos, no preparan de toda la lista de clase) -- mismo set que ya usa
    // `alwaysPreparedClass` en el frontend. Wizard también siembra ClassLevelFeature
    // SPELL_LEARN (crecimiento de su libro de conjuros), pero deliberadamente NO se trata
    // aquí como límite de "conocidos" -- ver limitación documentada en el plan de la fase 4.
    private static final java.util.Set<String> KNOWN_CASTER_CLASSES =
            java.util.Set.of("sorcerer", "bard", "warlock", "ranger");

    /**
     * Total de hechizos "conocidos" que esta clase permite tener a este nivel EN ESA CLASE,
     * sumando los deltas ya sembrados como ClassLevelFeature(SPELL_LEARN, metadata=
     * {"count":N}) por DndClassSyncService en cada nivel de 1 a levelInClass. Devuelve -1 si
     * la clase no es "de conocidos" (no aplica este límite).
     */
    private int maxKnownSpellsForClass(DndClass dndClass, int levelInClass) {
        String idx = dndClass.getIndexName() != null ? dndClass.getIndexName().toLowerCase() : "";
        if (!KNOWN_CASTER_CLASSES.contains(idx)) {
            return -1;
        }
        int total = 0;
        for (int lvl = 1; lvl <= levelInClass; lvl++) {
            ClassLevelProgression progression = classLevelProgressionRepository
                    .findByDndClassAndLevel(dndClass, lvl).orElse(null);
            if (progression == null || progression.getFeatures() == null) continue;
            for (ClassLevelFeature feature : progression.getFeatures()) {
                if (feature.getType() == FeatureType.SPELL_LEARN) {
                    total += parseCountFromMetadata(feature.getMetadata());
                }
            }
        }
        return total;
    }

    private int parseCountFromMetadata(String metadata) {
        if (metadata == null) return 0;
        int idx = metadata.indexOf("\"count\":");
        if (idx == -1) return 0;
        int start = idx + 8;
        while (start < metadata.length() && !Character.isDigit(metadata.charAt(start))) start++;
        int end = start;
        while (end < metadata.length() && Character.isDigit(metadata.charAt(end))) end++;
        if (end <= start) return 0;
        try {
            return Integer.parseInt(metadata.substring(start, end));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    @Transactional
    public void learnSpell(Long characterId, Long spellId, boolean prepared) {
        learnSpell(characterId, spellId, prepared, null);
    }

    /**
     * Multiclase (Aurora_Fixes.md #17, fase 4a): con classId informado, el límite se
     * comprueba SOLO contra esa clase (conocidos o preparados, según lo que otorgue) y el
     * hechizo queda atribuido a ella. Sin classId (retrocompatible, comportamiento de
     * siempre), se mantiene el límite de preparados character-wide y el hechizo se guarda
     * sin clase atribuida.
     */
    @Transactional
    public void learnSpell(Long characterId, Long spellId, boolean prepared, Long classId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        Spell spell = spellRepository.findById(spellId)
                .orElseThrow(() -> new RuntimeException("Spell not found"));

        DndClass targetClass = null;
        if (classId != null) {
            targetClass = dndClassRepository.findById(classId)
                    .orElseThrow(() -> new RuntimeException("DndClass not found"));
        }

        if (targetClass != null && spell.getLevel() > 0) {
            String idx = targetClass.getIndexName() != null ? targetClass.getIndexName().toLowerCase() : "";
            if (KNOWN_CASTER_CLASSES.contains(idx)) {
                PlayerCharacterClass row = playerCharacterClassRepository
                        .findByCharacterAndDndClass(character, targetClass).orElse(null);
                int levelInClass = row != null ? row.getLevel() : character.getLevel();
                int maxKnown = maxKnownSpellsForClass(targetClass, levelInClass);
                if (maxKnown >= 0) {
                    int currentKnown = characterSpellRepository
                            .countKnownNonCantripsByCharacterIdAndClass(characterId, classId);
                    if (currentKnown >= maxKnown) {
                        throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY,
                                "Known spell limit reached for " + targetClass.getName()
                                        + " (" + currentKnown + "/" + maxKnown + ")");
                    }
                }
            } else if (prepared && targetClass.getSpellcastingAbility() != null
                    && !targetClass.getSpellcastingAbility().isEmpty()) {
                Integer maxPrepared = character.getMaxPreparedSpellsByClass().get(classId);
                if (maxPrepared != null && maxPrepared > 0) {
                    int currentPrepared = characterSpellRepository
                            .countPreparedNonCantripsByCharacterIdAndClass(characterId, classId);
                    if (currentPrepared >= maxPrepared) {
                        throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY,
                                "Spell preparation limit reached for " + targetClass.getName()
                                        + " (" + currentPrepared + "/" + maxPrepared + ")");
                    }
                }
            }
        } else if (targetClass == null && prepared && spell.getLevel() > 0) {
            // Comportamiento legacy character-wide, sin cambios.
            int maxPrepared = character.getMaxPreparedSpells();
            if (maxPrepared > 0) {
                int currentPrepared = characterSpellRepository.countPreparedNonCantripsByCharacterId(characterId);
                if (currentPrepared >= maxPrepared) {
                    throw new ResponseStatusException(
                        HttpStatus.UNPROCESSABLE_ENTITY,
                        "Spell preparation limit reached (" + maxPrepared + "/" + maxPrepared + ")");
                }
            }
        }

        CharacterSpell characterSpell = new CharacterSpell(character, spell);
        characterSpell.setDndClass(targetClass);
        // Los cantrips siempre están preparados; los no-cantrips respetan el flag 'prepared'
        characterSpell.setPrepared(spell.getLevel() == 0 || prepared);
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

            // Si va a preparar (actualmente no preparado), verificar el límite. Multiclase
            // (Aurora_Fixes.md #17, fase 4a): si el hechizo tiene clase atribuida (dndClass,
            // guardado al aprenderlo), el límite se comprueba SOLO contra esa clase; si no
            // (fila legacy sin classId), se mantiene el comportamiento character-wide de siempre.
            if (!characterSpell.isPrepared()) {
                PlayerCharacter character = characterRepository.findById(characterId)
                    .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Character not found"));
                DndClass spellClass = characterSpell.getDndClass();
                int maxPrepared;
                int currentPrepared;
                if (spellClass != null) {
                    Integer max = character.getMaxPreparedSpellsByClass().get(spellClass.getId());
                    maxPrepared = max != null ? max : 0;
                    currentPrepared = characterSpellRepository
                            .countPreparedNonCantripsByCharacterIdAndClass(characterId, spellClass.getId());
                } else {
                    maxPrepared = character.getMaxPreparedSpells();
                    currentPrepared = characterSpellRepository
                        .countPreparedNonCantripsByCharacterId(characterId);
                }
                if (maxPrepared > 0 && currentPrepared >= maxPrepared) {
                    throw new ResponseStatusException(
                        HttpStatus.UNPROCESSABLE_ENTITY,
                        "Spell preparation limit reached (" + currentPrepared + "/" + maxPrepared + ")"
                            + (spellClass != null ? " for " + spellClass.getName() : ""));
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

                if (slot.getUsedSlots() >= slot.getMaxSlots() + slot.getBonusMax()) {
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

    // Hechicero: Flexible Casting (Font of Magic). Coste en puntos de hechicería por nivel de
    // slot creado, tabla real de 5e (PHB pág. 101). "Character does not have this resource",
    // lanzado por CharacterClassResourceService.spendResource si el personaje no tiene
    // font-of-magic, ya sirve como guarda natural -- no hace falta comprobar aparte que sea
    // Hechicero (#8.2 NUMERIC_BONUS/RESOURCE_POOL usan el mismo criterio: la condición es "tiene
    // el recurso", no "es de tal clase").
    private static final Map<Integer, Integer> FLEXIBLE_CASTING_SLOT_COST =
            Map.of(1, 2, 2, 3, 3, 5, 4, 6, 5, 7);

    @Transactional
    public void createSpellSlotFromSorceryPoints(Long characterId, int spellLevel) {
        Integer cost = FLEXIBLE_CASTING_SLOT_COST.get(spellLevel);
        if (cost == null) {
            throw new RuntimeException("Flexible Casting can only create a spell slot of level 1-5");
        }

        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        characterClassResourceService.spendResource(characterId, "font-of-magic", cost);

        CharacterSpellSlot slot = slotRepository.findByCharacterAndSpellLevel(character, spellLevel)
                .orElseGet(() -> {
                    CharacterSpellSlot s = new CharacterSpellSlot();
                    s.setCharacter(character);
                    s.setSpellLevel(spellLevel);
                    s.setMaxSlots(0);
                    s.setUsedSlots(0);
                    return s;
                });
        slot.setBonusMax(slot.getBonusMax() + 1);
        slotRepository.save(slot);
    }

    @Transactional
    public void convertSpellSlotToSorceryPoints(Long characterId, int spellLevel) {
        if (spellLevel < 1 || spellLevel > 5) {
            throw new RuntimeException("Flexible Casting can only convert a spell slot of level 1-5");
        }

        CharacterSpellSlot slot = slotRepository.findByCharacterIdAndSpellLevel(characterId, spellLevel)
                .orElseThrow(() -> new RuntimeException("Character has no spell slots of level " + spellLevel));

        if (slot.getUsedSlots() >= slot.getMaxSlots() + slot.getBonusMax()) {
            throw new RuntimeException("No unused level " + spellLevel + " spell slot to convert");
        }

        slot.setUsedSlots(slot.getUsedSlots() + 1);
        slotRepository.save(slot);

        characterClassResourceService.recoverResourceDto(characterId, "font-of-magic", spellLevel);
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

        if (slot.getUsedSlots() >= slot.getMaxSlots() + slot.getBonusMax()) {
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
            // Lanzador full/half estándar: consultar tabla de progresión
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
            // Subclase lanzador 1/3 (Eldritch Knight / Arcane Trickster)
            saveThirdCasterSlots(character, character.getLevel());
        }
    }

    /** Calcula y persiste los spell slots para un lanzador 1/3 en el nivel de personaje dado. */
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
     * Tabla de spell slots para lanzadores 1/3 por nivel de personaje (PHB Eldritch Knight / Arcane Trickster).
     * Devuelve int[3] = [slotsNv1, slotsNv2, slotsNv3].
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
            // Subida de nivel como lanzador 1/3
            saveThirdCasterSlots(character, newLevel);
        } else {
            System.out.println("Character is not a spellcaster");
        }
    }

    // Clasificación de lanzador para combinar niveles de multiclase (PHB "Multiclass
    // Spellcaster" table). Clases ausentes de ambos conjuntos (incl. Artificer, cuyo
    // indexName varía por sourcebook, y cualquier homebrew) simplemente no aportan al
    // cómputo combinado -- opción conservadora documentada, no un intento de cubrir
    // every caso.
    private static final java.util.Set<String> MULTICLASS_FULL_CASTERS =
            java.util.Set.of("bard", "cleric", "druid", "sorcerer", "wizard");
    private static final java.util.Set<String> MULTICLASS_HALF_CASTERS =
            java.util.Set.of("paladin", "ranger");

    /**
     * Multiclase (Aurora_Fixes.md #17, fase 1): recalcula los spell slots combinando el
     * "nivel de lanzador" ponderado de todas las clases del personaje (full=1x, half=0.5x,
     * third=0.33x, redondeado hacia abajo al final), reutilizando la tabla
     * SpellSlotProgression ya existente contra un lanzador full-caster de referencia (Wizard)
     * al nivel combinado -- la tabla "Multiclass Spellcaster" del PHB es numéricamente
     * idéntica a la de cualquier full caster al mismo nivel.
     *
     * LIMITACIÓN CONOCIDA Y DOCUMENTADA: Warlock se excluye a propósito de este cómputo (su
     * Pact Magic es una reserva paralela, no combinable). Si el personaje tiene Warlock JUNTO
     * con otra(s) clase(s), este método sobrescribe las mismas filas CharacterSpellSlot que
     * hoy usa el Pact Magic de Warlock (CharacterSpellSlot no tiene un discriminador de
     * "pool" -- su clave natural es solo (character, spellLevel)), perdiendo esas slots. Se
     * deja así deliberadamente: arreglarlo de raíz requiere un cambio de esquema y tocar
     * shortRest(), que hoy es código crítico para cualquier Warlock mono-clase en producción
     * -- ver Aurora_Fixes.md #17 para el follow-up.
     */
    private void recalculateMulticlassSpellSlots(PlayerCharacter character) {
        double combinedCasterLevel = 0;
        for (PlayerCharacterClass pcc : playerCharacterClassRepository.findByCharacterOrderByClassOrderAsc(character)) {
            String idx = pcc.getDndClass().getIndexName() != null
                    ? pcc.getDndClass().getIndexName().toLowerCase() : "";
            if ("warlock".equals(idx)) {
                continue;
            } else if (MULTICLASS_FULL_CASTERS.contains(idx)) {
                combinedCasterLevel += pcc.getLevel();
            } else if (MULTICLASS_HALF_CASTERS.contains(idx)) {
                combinedCasterLevel += pcc.getLevel() / 2.0;
            } else if (pcc.getSubclass() != null && pcc.getSubclass().getSpellcastingAbility() != null
                    && !pcc.getSubclass().getSpellcastingAbility().isEmpty()) {
                // Lanzador 1/3 vía subclase (Eldritch Knight / Arcane Trickster)
                combinedCasterLevel += pcc.getLevel() / 3.0;
            }
        }

        int lookupLevel = (int) Math.floor(combinedCasterLevel);
        if (lookupLevel <= 0) {
            return;
        }

        DndClass referenceFullCaster = dndClassRepository.findByIndexName("wizard").orElse(null);
        if (referenceFullCaster == null) {
            System.out.println("Multiclass spell slots: reference full-caster class 'wizard' not found in catalog, skipping.");
            return;
        }

        List<SpellSlotProgression> progression =
                spellSlotProgressionRepository.findByDndClassAndCharacterLevel(referenceFullCaster, lookupLevel);
        for (SpellSlotProgression p : progression) {
            CharacterSpellSlot slot = slotRepository
                    .findByCharacterAndSpellLevel(character, p.getSpellLevel())
                    .orElse(new CharacterSpellSlot());
            slot.setCharacter(character);
            slot.setSpellLevel(p.getSpellLevel());
            slot.setMaxSlots(p.getSlots());
            slot.setUsedSlots(0);
            slotRepository.save(slot);
        }
        System.out.println("Multiclass spell slots recalculated: combined caster level " + lookupLevel);
    }

    // ========== LEVEL UP ==========

    @Transactional
    public PlayerCharacter levelUp(Long characterId) {
        return levelUp(characterId, null);
    }

    @Transactional
    public PlayerCharacter levelUp(Long characterId, Integer hpRoll) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        if (character.getLevel() >= 20) {
            throw new RuntimeException("Character is already at max level (20)");
        }

        int newLevel = character.getLevel() + 1;
        character.setLevel(newLevel);

        if (hpRoll != null) {
            Map<Integer, Integer> hpRolls = character.getHpRolls();
            if (hpRolls == null) {
                hpRolls = new HashMap<>();
            }
            hpRolls.put(newLevel, hpRoll);
            character.setHpRolls(hpRolls);
        }

        System.out.println("=== Leveling up " + character.getName() + " to level " + newLevel + " ===");

        // 1. Actualizar proficiency bonus
        updateProficiency(character);

        // 2. Procesar ClassLevelFeatures (sistema de mecánicas)
        processClassLevelFeatures(character, newLevel, hpRoll);

        // 3. Añadir ClassFeatures descriptivas del API
        addClassFeaturesFromAPI(character, newLevel);

        // 4. Inicializar recursos de clase nuevos desbloqueados en este nivel
        //    y actualizar los máximos de los recursos existentes (escalan con el nivel)
        characterClassResourceService.initializeClassResourcesForCharacter(character.getId());
        characterClassResourceService.updateResourceMaximums(character.getId());
        // Recursos de raza homebrew (#9): el máximo puede escalar con el nivel de personaje
        // aunque la propia raza no tenga "niveles" -- ver CharacterRaceResourceService.
        characterRaceResourceService.updateResourceMaximums(character.getId());

        // 5. Aplicar traits raciales con hechizos desbloqueados por nivel (p.ej. Drow Magic)
        racialTraitService.applyAutomaticRacialTraits(character);

        // 6. Guardar cambios
        characterRepository.save(character);

        System.out.println("=== Level up complete! ===");

        return character;
    }

    // ========== LEVEL UP MULTICLASE (Aurora_Fixes.md #17, fase 1) ==========

    /**
     * Punto de entrada retrocompatible del endpoint de level-up. Cuando classId es null y el
     * personaje sigue mono-clase, delega tal cual en levelUp(Long, Integer) sin tocar su
     * cuerpo -- el frontend actual, que nunca envía classId, sigue funcionando exactamente
     * igual. classId != null (o un personaje ya multiclaseado sin classId, que debe fallar
     * alto y claro en vez de adivinar) son los únicos caminos nuevos.
     */
    @Transactional
    public dto.LevelUpResultDto levelUpMulticlass(Long characterId, Integer hpRoll, Long classId, Long subclassId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        if (classId == null) {
            long classCount = playerCharacterClassRepository.countByCharacter(character);
            if (classCount > 1) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "This character is multiclassed — specify classId to level up.");
            }
            PlayerCharacter leveled = levelUp(characterId, hpRoll);
            return new dto.LevelUpResultDto("Character leveled up!", List.of(), toDto(leveled));
        }

        DndClass targetClass = dndClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("DndClass not found"));

        if (character.getLevel() >= 20) {
            throw new RuntimeException("Character is already at max level (20)");
        }

        List<String> warnings = new ArrayList<>();
        PlayerCharacterClass row = playerCharacterClassRepository
                .findByCharacterAndDndClass(character, targetClass).orElse(null);
        boolean isBrandNewClass = row == null;
        int levelInClass;

        if (isBrandNewClass) {
            warnings.addAll(multiclassRulesService.checkAbilityScorePrerequisites(character, targetClass));

            int maxOrder = playerCharacterClassRepository.findByCharacterOrderByClassOrderAsc(character)
                    .stream().mapToInt(PlayerCharacterClass::getClassOrder).max().orElse(-1);
            row = new PlayerCharacterClass();
            row.setCharacter(character);
            row.setDndClass(targetClass);
            row.setClassOrder(maxOrder + 1);
            levelInClass = 1;

            warnings.addAll(multiclassRulesService.grantReducedProficiencies(character, targetClass));
        } else {
            levelInClass = row.getLevel() + 1;
        }

        int newCharacterLevel = character.getLevel() + 1;
        character.setLevel(newCharacterLevel);

        if (hpRoll != null) {
            Map<Integer, Integer> hpRolls = character.getHpRolls();
            if (hpRolls == null) {
                hpRolls = new HashMap<>();
            }
            hpRolls.put(newCharacterLevel, hpRoll);
            character.setHpRolls(hpRolls);
        }

        System.out.println("=== Leveling up " + character.getName() + " in " + targetClass.getName()
                + " to class level " + levelInClass + " (character level " + newCharacterLevel + ") ===");

        // El bono de competencia ya es correcto por nivel TOTAL de personaje -- no cambia con multiclase.
        updateProficiency(character);

        if (subclassId != null) {
            Subclass subclass = subclassRepository.findById(subclassId)
                    .orElseThrow(() -> new RuntimeException("Subclass not found"));
            assignSubclassForClass(targetClass, row, subclass);
        }

        processClassLevelFeaturesForClass(character, targetClass, row.getSubclass(), levelInClass, hpRoll);
        addClassFeaturesFromAPIForClass(character, targetClass, levelInClass);

        row.setLevel(levelInClass);
        playerCharacterClassRepository.save(row);

        // classOrder=0 es la clase que dndClass/subclass/level de PlayerCharacter reflejan
        // (dual-write, ver create()) -- se mantiene el espejo también al subir de nivel.
        if (row.getClassOrder() == 0) {
            character.setDndClass(targetClass);
            character.setSubclass(row.getSubclass());
        }

        // Spell slots combinados: se recalculan una sola vez, tras procesar la clase que sube,
        // porque dependen de TODAS las clases lanzadoras del personaje a la vez, no solo de esta.
        if (playerCharacterClassRepository.countByCharacter(character) > 1) {
            recalculateMulticlassSpellSlots(character);
        } else {
            updateSpellSlots(character, levelInClass);
        }

        characterClassResourceService.initializeClassResourcesForCharacterAndClass(
                character.getId(), targetClass, row.getSubclass(), levelInClass);
        characterClassResourceService.updateResourceMaximums(character.getId());
        characterRaceResourceService.updateResourceMaximums(character.getId());
        racialTraitService.applyAutomaticRacialTraits(character);

        characterRepository.save(character);

        System.out.println("=== Level up complete! ===");

        return new dto.LevelUpResultDto(
                "Character leveled up in " + targetClass.getName() + "!", warnings, toDto(character));
    }

    /** Multiclase: asigna subclase a una PlayerCharacterClass concreta (no a la legacy character.subclass directamente). */
    private void assignSubclassForClass(DndClass targetClass, PlayerCharacterClass row, Subclass subclass) {
        if (!subclass.getDndClass().getId().equals(targetClass.getId())) {
            throw new RuntimeException("Subclass does not belong to the class being leveled");
        }
        Integer subclassLevel = targetClass.getSubclassLevel();
        int levelAfterThisLevelUp = row.getLevel() + 1;
        if (subclassLevel != null && levelAfterThisLevelUp < subclassLevel) {
            throw new RuntimeException("Character must be at least level " + subclassLevel
                    + " in " + targetClass.getName() + " to choose a subclass");
        }
        row.setSubclass(subclass);
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
    
    // 5. Restaurar TODOS los spell slots. bonusMax (Flexible Casting) también se resetea a 0
    // aquí: cualquier slot creado con puntos de hechicería desaparece al final del descanso
    // largo, a diferencia de usedSlots que también se restaura en descanso corto para Warlock.
    List<CharacterSpellSlot> spellSlots = slotRepository.findByCharacter(character);
    for (CharacterSpellSlot slot : spellSlots) {
        slot.setUsedSlots(0);
        slot.setBonusMax(0);
        slotRepository.save(slot);
    }
    
    // 6. Restaurar recursos de clase y de raza que se recuperan en LONG_REST
    characterClassResourceService.recoverResources(characterId, "LONG_REST");
    characterRaceResourceService.recoverResources(characterId, "LONG_REST");
    
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
        
        // 3. Restaurar recursos de clase y de raza que se recuperan en SHORT_REST
        characterClassResourceService.recoverResources(characterId, "SHORT_REST");
        characterRaceResourceService.recoverResources(characterId, "SHORT_REST");
        
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

    private void processClassLevelFeatures(PlayerCharacter character, int newLevel, Integer hpRoll) {
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
                applyAutomaticFeature(character, newLevel, feature, hpRoll);
            }
        }

        // Tareas adicionales específicas de la subclase (Battle Master, Totem Warrior, etc.)
        createSubclassLevelTasks(character, newLevel);

        // Aplicar hechizos automáticos de subclase desbloqueados al nuevo nivel
        subclassSpellService.applySubclassSpells(character, character.getSubclass(), newLevel);

        // Aplicar hechizos automáticos de la clase base desbloqueados al nuevo nivel
        classSpellService.applyClassSpells(character, character.getDndClass(), newLevel);
    }

    /**
     * Crea PendingTasks para cada ClassLevelFeature que requiere elección del nivel 1
     * al nivel inicial del personaje. NO aplica features automáticas (ya se gestionan
     * durante create()).
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

        // SPELL_LEARN / SPELL_PREPARE: los spells iniciales se seleccionan directamente en el
        // wizard de creación (spellIds en el DTO). Estas tareas solo son relevantes para
        // subidas de nivel, no para la creación inicial.
        if (feature.getType() == FeatureType.SPELL_LEARN ||
            feature.getType() == FeatureType.SPELL_PREPARE) {
            System.out.println("Skipping " + feature.getType() + " at creation – handled by wizard spell selection.");
            return;
        }

        // SUBCLASS_CHOICE: si el wizard ya eligió una subclase, no se necesita tarea pendiente.
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

            case INFUSION_CHOICE:
                task.setTaskType("INFUSION_CHOICE");
                task.setDescription("Choose artificer infusion(s) known (Infuse Item)");
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

            case BLOOD_CURSE_CHOICE:
                task.setTaskType("BLOOD_CURSE_CHOICE");
                task.setDescription("Choose a Blood Curse (Blood Hunter)");
                task.setMetadata(feature.getMetadata());
                break;

            case TRICK_SHOT_CHOICE:
                task.setTaskType("TRICK_SHOT_CHOICE");
                task.setDescription("Choose a Trick Shot (Gunslinger)");
                task.setMetadata(feature.getMetadata());
                break;

            default:
                System.out.println("Unknown task type for: " + feature.getType());
                return;
        }

        pendingTaskRepository.save(task);
        System.out.println("Task created: " + task.getTaskType());
    }

    /**
     * Crea PendingTasks para los traits raciales CHOICE_REQUIRED de la raza del personaje (y subraza).
     * Solo crea una tarea si no existe ya una del mismo tipo+nivel (evita duplicados,
     * p.ej. para un Dragonborn Draconic Sorcerer cuya clase ya generó una tarea DRACONIC_ANCESTRY).
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

        // Traits que se gestionan por otros mecanismos y no necesitan PendingTask
        java.util.Set<String> derivedTraits = java.util.Set.of(
            "breath-weapon", "damage-resistance",
            "natural-illusionist" // aplicado automáticamente en RacialTraitService
        );

        List<PendingTask> existing = pendingTaskRepository.findByCharacter(character);

        for (RacialTrait trait : allTraits) {
            // high-elf-cantrip puede no estar como CHOICE_REQUIRED en la BD (requiere re-sync para corregirlo),
            // por lo que también se comprueba explícitamente por indexName.
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
                    // Half-Elf obtiene DOS elecciones de skill separadas
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

            // Evitar tareas duplicadas (p.ej. Draconic Sorcerer ya tiene ésta de las features de clase)
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

        // Flexible ASI (MoTM-style): the race has no fixed bonuses — player chooses +2 to one ability and +1 to another.
        if (race != null && race.isFlexibleAsi()) {
            boolean exists = pendingTaskRepository.findByCharacter(character).stream()
                .anyMatch(t -> "RACIAL_ASI_CHOICE".equals(t.getTaskType()));
            if (!exists) {
                PendingTask asiTask = new PendingTask();
                asiTask.setCharacter(character);
                asiTask.setRelatedLevel(1);
                asiTask.setCompleted(false);
                asiTask.setTaskType("RACIAL_ASI_CHOICE");
                asiTask.setDescription("Choose your racial Ability Score Increases: apply +2 to one ability and +1 to a different ability");
                pendingTaskRepository.save(asiTask);
            }
        }
    }

    /**
     * Crea PendingTasks específicas de la subclase del personaje para todos los niveles
     * del 1 al nivel actual (usado durante create()).
     */
    private void generateSubclassChoiceTasksForCreation(PlayerCharacter character) {
        if (character.getSubclass() == null) return;
        for (int level = 1; level <= character.getLevel(); level++) {
            createSubclassLevelTasks(character, level);
        }
    }

    /**
     * Crea las PendingTasks de subclase que corresponden a un nivel concreto.
     * Llamado tanto durante la creación como al subir de nivel.
     */
    private void createSubclassLevelTasks(PlayerCharacter character, int level) {
        if (character.getSubclass() == null) return;
        String sub = character.getSubclass().getIndexName();
        if (sub == null) return;

        switch (sub) {
            case "battle-master":
                if (level == 3)
                    createSubclassTask(character, level, "MANEUVER_CHOICE",
                            "Choose 3 Battle Master Maneuvers", "{\"count\":3}");
                else if (level == 7 || level == 15)
                    createSubclassTask(character, level, "MANEUVER_CHOICE",
                            "Choose 2 additional Battle Master Maneuvers", "{\"count\":2}");
                break;

            case "path-of-the-totem-warrior":
                if (level == 3)
                    createSubclassTask(character, level, "TOTEM_SPIRIT",
                            "Choose your Totem Spirit (Bear, Eagle, or Wolf)", null);
                else if (level == 6)
                    createSubclassTask(character, level, "TOTEM_ASPECT",
                            "Choose your Aspect of the Beast (Bear, Eagle, or Wolf)", null);
                else if (level == 14)
                    createSubclassTask(character, level, "TOTEM_ATTUNEMENT",
                            "Choose your Totemic Attunement (Bear, Eagle, or Wolf)", null);
                break;

            case "hunter":
                if (level == 3)
                    createSubclassTask(character, level, "HUNTERS_PREY",
                            "Choose your Hunter's Prey ability", null);
                else if (level == 7)
                    createSubclassTask(character, level, "DEFENSIVE_TACTICS",
                            "Choose your Defensive Tactics", null);
                else if (level == 11)
                    createSubclassTask(character, level, "HUNTER_MULTIATTACK",
                            "Choose your Multiattack style", null);
                else if (level == 15)
                    createSubclassTask(character, level, "SUPERIOR_HUNTERS_DEFENSE",
                            "Choose your Superior Hunter's Defense", null);
                break;

            case "way-of-the-four-elements":
                if (level == 3)
                    createSubclassTask(character, level, "ELEMENTAL_DISCIPLINE",
                            "Choose 2 Elemental Disciplines", "{\"count\":2}");
                else if (level == 6 || level == 11 || level == 17)
                    createSubclassTask(character, level, "ELEMENTAL_DISCIPLINE",
                            "Choose an additional Elemental Discipline", "{\"count\":1}");
                break;

            case "land":
                if (level == 3)
                    createSubclassTask(character, level, "LAND_TYPE_CHOICE",
                            "Choose your Land type (Arctic, Coast, Desert, Forest, Grassland, Mountain, Swamp, or Underdark)", null);
                break;

            case "lore":
                if (level == 6)
                    createSubclassTask(character, level, "ADDITIONAL_MAGICAL_SECRETS",
                            "Learn 2 spells of your choice from any class (they count as bard spells)", null);
                break;

            case "gunslinger":
                if (level == 3)
                    createSubclassTask(character, level, "TRICK_SHOT_CHOICE",
                            "Choose 2 Trick Shots (Gunslinger)", "{\"count\":2}");
                else if (level == 7 || level == 10 || level == 15 || level == 18)
                    createSubclassTask(character, level, "TRICK_SHOT_CHOICE",
                            "Choose an additional Trick Shot (Gunslinger)", "{\"count\":1}");
                break;

            case "order-of-the-mutant":
                if (level == 3) {
                    // Number of formulas known scales with INT modifier (minimum 1), same rule the wizard uses.
                    int formulaCount = Math.max(1, character.calculateAbilityModifier("int"));
                    createSubclassTask(character, level, "MUTAGEN_CHOICE",
                            "Choose " + formulaCount + " Mutagenic Formula" + (formulaCount == 1 ? "" : "s"),
                            "{\"count\":" + formulaCount + "}");
                }
                break;

            // Rune Knight (Aurora/TCE): index_name real es el ID crudo de Aurora, no un slug
            // limpio como el resto de casos de este switch (ver #8.2 fase 5 -- las subclases
            // que llegan por Aurora no siempre tienen slug bonito). 2 runas a nivel 3, +1 a
            // nivel 7/10/15 (5 en total, igual que Rune Carver). Cada runa elegida es su propio
            // ClassResource (ver CharacterClassResourceService/patch_resource_pool_rune_knight.sql).
            case "ID_WOTC_TCOE_ARCHETYPE_FIGHTER_RUNE_KNIGHT":
                if (level == 3)
                    createSubclassTask(character, level, "RUNE_CHOICE",
                            "Choose 2 Runes Known", "{\"count\":2}");
                else if (level == 7 || level == 10 || level == 15)
                    createSubclassTask(character, level, "RUNE_CHOICE",
                            "Choose an additional Rune Known", "{\"count\":1}");
                break;
        }
    }

    /** Crea una PendingTask de subclase evitando duplicados por tipo+nivel. */
    private void createSubclassTask(PlayerCharacter character, int level,
                                    String taskType, String description, String initialMetadata) {
        boolean alreadyExists = pendingTaskRepository.findByCharacter(character).stream()
                .anyMatch(t -> taskType.equals(t.getTaskType()) && t.getRelatedLevel() == level);
        if (alreadyExists) return;

        PendingTask task = new PendingTask();
        task.setCharacter(character);
        task.setRelatedLevel(level);
        task.setTaskType(taskType);
        task.setDescription(description);
        task.setMetadata(initialMetadata);
        task.setCompleted(false);
        pendingTaskRepository.save(task);
        System.out.println("Subclass task created: " + taskType + " at level " + level
                + " for " + character.getName());
    }

    private void applyAutomaticFeature(PlayerCharacter character, int level, ClassLevelFeature feature, Integer hpRoll) {
        System.out.println("Applying automatic feature: " + feature.getType());

        switch (feature.getType()) {
            case HP_INCREASE:
                addHitPoints(character, hpRoll);
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

    private void addHitPoints(PlayerCharacter character, Integer hpRoll) {
        DndClass dndClass = character.getDndClass();

        if (dndClass == null) {
            throw new RuntimeException("Character has no class assigned");
        }

        int hitDie = dndClass.getHitDie();

        int constitutionModifier = calculateAbilityModifier(
                character.getAbilityScores().getOrDefault("con", 10)
        );

        // Si el jugador tiró el dado de HP manualmente en el wizard, usar esa tirada;
        // si no, usar la media del dado (comportamiento previo).
        int hpGain = (hpRoll != null ? hpRoll : (hitDie / 2) + 1) + constitutionModifier;

        // Mínimo 1 HP por nivel
        if (hpGain < 1) {
            hpGain = 1;
        }

        // Bonificador de PG por nivel declarativo (p.ej. Draconic Resilience: +1) -- ver #8.2
        // NUMERIC_BONUS. La parte retroactiva a niveles ya alcanzados se aplica en create()/
        // PendingTaskService.applyRetroactiveMaxHpBonus(), esto solo cubre la subida actual.
        hpGain += numericBonusService.bonusFor(character, "MAX_HP_PER_LEVEL");

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

    // ========== MULTICLASE (Aurora_Fixes.md #17, fase 1) ==========
    //
    // Copias deliberadas de los métodos de nivel-por-clase de arriba, parametrizadas con
    // `targetClass`/`levelInClass` en vez de leer implícitamente character.getDndClass()/
    // character.getLevel(). Se duplica en vez de añadir un parámetro a los métodos
    // originales para que el camino mono-clase existente (levelUp(Long, Integer), que
    // sigue llamando siempre a los métodos de arriba sin tocar) no pueda verse afectado
    // por ningún bug de este código nuevo, todavía sin ejercitar en producción.

    private void processClassLevelFeaturesForClass(PlayerCharacter character, DndClass targetClass,
            Subclass subclassForRow, int levelInClass, Integer hpRoll) {
        ClassLevelProgression progression =
                classLevelProgressionRepository.findByDndClassAndLevel(targetClass, levelInClass)
                        .orElse(null);

        if (progression == null) {
            System.out.println("No progression data found for " + targetClass.getName() + " level " + levelInClass);
            return;
        }

        List<ClassLevelFeature> features = progression.getFeatures();
        if (features == null || features.isEmpty()) {
            System.out.println("No features configured for this level");
            return;
        }

        for (ClassLevelFeature feature : features) {
            if (feature.isRequiresChoice()) {
                createTaskForClass(character, targetClass, levelInClass, feature, subclassForRow);
            } else {
                applyAutomaticFeatureForClass(character, targetClass, levelInClass, feature, hpRoll);
            }
        }

        // Tareas adicionales específicas de la subclase (Battle Master, Totem Warrior, etc.)
        createSubclassLevelTasksForClass(character, targetClass, subclassForRow, levelInClass);

        // Aplicar hechizos automáticos de subclase/clase base desbloqueados al nuevo nivel
        // (estos servicios ya reciben clase/subclase como parámetro explícito, no hace falta duplicarlos)
        subclassSpellService.applySubclassSpells(character, subclassForRow, levelInClass);
        classSpellService.applyClassSpells(character, targetClass, levelInClass);
    }

    private void createTaskForClass(PlayerCharacter character, DndClass targetClass, int levelInClass,
            ClassLevelFeature feature, Subclass subclassForRow) {
        System.out.println("Creating task for feature type: " + feature.getType() + " (class: " + targetClass.getName() + ")");

        if (feature.getType() == FeatureType.SPELL_LEARN ||
            feature.getType() == FeatureType.SPELL_PREPARE) {
            System.out.println("Skipping " + feature.getType() + " – handled by wizard spell selection.");
            return;
        }

        if (feature.getType() == FeatureType.SUBCLASS_CHOICE && subclassForRow != null) {
            System.out.println("Skipping SUBCLASS_CHOICE – subclass already chosen: " + subclassForRow.getName());
            return;
        }

        PendingTask task = new PendingTask();
        task.setCharacter(character);
        task.setDndClass(targetClass);
        task.setRelatedLevel(levelInClass);
        task.setCompleted(false);

        switch (feature.getType()) {
            case ASI_OR_FEAT:
                task.setTaskType("ASI_OR_FEAT");
                task.setDescription("Choose between increasing ability scores (+2 to one or +1 to two) or taking a feat");
                break;

            case SUBCLASS_CHOICE:
                task.setTaskType("CHOOSE_SUBCLASS");
                task.setDescription("Choose your " + targetClass.getName() + " subclass/archetype");
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

            case INFUSION_CHOICE:
                task.setTaskType("INFUSION_CHOICE");
                task.setDescription("Choose artificer infusion(s) known (Infuse Item)");
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
                task.setMetadata(feature.getMetadata());
                break;

            case BLOOD_CURSE_CHOICE:
                task.setTaskType("BLOOD_CURSE_CHOICE");
                task.setDescription("Choose a Blood Curse (Blood Hunter)");
                task.setMetadata(feature.getMetadata());
                break;

            case TRICK_SHOT_CHOICE:
                task.setTaskType("TRICK_SHOT_CHOICE");
                task.setDescription("Choose a Trick Shot (Gunslinger)");
                task.setMetadata(feature.getMetadata());
                break;

            default:
                System.out.println("Unknown task type for: " + feature.getType());
                return;
        }

        pendingTaskRepository.save(task);
        System.out.println("Task created: " + task.getTaskType() + " (class: " + targetClass.getName() + ")");
    }

    private void createSubclassLevelTasksForClass(PlayerCharacter character, DndClass targetClass,
            Subclass subclassForRow, int levelInClass) {
        if (subclassForRow == null) return;
        String sub = subclassForRow.getIndexName();
        if (sub == null) return;

        switch (sub) {
            case "battle-master":
                if (levelInClass == 3)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "MANEUVER_CHOICE",
                            "Choose 3 Battle Master Maneuvers", "{\"count\":3}");
                else if (levelInClass == 7 || levelInClass == 15)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "MANEUVER_CHOICE",
                            "Choose 2 additional Battle Master Maneuvers", "{\"count\":2}");
                break;

            case "path-of-the-totem-warrior":
                if (levelInClass == 3)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "TOTEM_SPIRIT",
                            "Choose your Totem Spirit (Bear, Eagle, or Wolf)", null);
                else if (levelInClass == 6)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "TOTEM_ASPECT",
                            "Choose your Aspect of the Beast (Bear, Eagle, or Wolf)", null);
                else if (levelInClass == 14)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "TOTEM_ATTUNEMENT",
                            "Choose your Totemic Attunement (Bear, Eagle, or Wolf)", null);
                break;

            case "hunter":
                if (levelInClass == 3)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "HUNTERS_PREY",
                            "Choose your Hunter's Prey ability", null);
                else if (levelInClass == 7)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "DEFENSIVE_TACTICS",
                            "Choose your Defensive Tactics", null);
                else if (levelInClass == 11)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "HUNTER_MULTIATTACK",
                            "Choose your Multiattack style", null);
                else if (levelInClass == 15)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "SUPERIOR_HUNTERS_DEFENSE",
                            "Choose your Superior Hunter's Defense", null);
                break;

            case "way-of-the-four-elements":
                if (levelInClass == 3)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "ELEMENTAL_DISCIPLINE",
                            "Choose 2 Elemental Disciplines", "{\"count\":2}");
                else if (levelInClass == 6 || levelInClass == 11 || levelInClass == 17)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "ELEMENTAL_DISCIPLINE",
                            "Choose an additional Elemental Discipline", "{\"count\":1}");
                break;

            case "land":
                if (levelInClass == 3)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "LAND_TYPE_CHOICE",
                            "Choose your Land type (Arctic, Coast, Desert, Forest, Grassland, Mountain, Swamp, or Underdark)", null);
                break;

            case "lore":
                if (levelInClass == 6)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "ADDITIONAL_MAGICAL_SECRETS",
                            "Learn 2 spells of your choice from any class (they count as bard spells)", null);
                break;

            case "gunslinger":
                if (levelInClass == 3)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "TRICK_SHOT_CHOICE",
                            "Choose 2 Trick Shots (Gunslinger)", "{\"count\":2}");
                else if (levelInClass == 7 || levelInClass == 10 || levelInClass == 15 || levelInClass == 18)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "TRICK_SHOT_CHOICE",
                            "Choose an additional Trick Shot (Gunslinger)", "{\"count\":1}");
                break;

            case "order-of-the-mutant":
                if (levelInClass == 3) {
                    int formulaCount = Math.max(1, character.calculateAbilityModifier("int"));
                    createSubclassTaskForClass(character, targetClass, levelInClass, "MUTAGEN_CHOICE",
                            "Choose " + formulaCount + " Mutagenic Formula" + (formulaCount == 1 ? "" : "s"),
                            "{\"count\":" + formulaCount + "}");
                }
                break;

            case "ID_WOTC_TCOE_ARCHETYPE_FIGHTER_RUNE_KNIGHT":
                if (levelInClass == 3)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "RUNE_CHOICE",
                            "Choose 2 Runes Known", "{\"count\":2}");
                else if (levelInClass == 7 || levelInClass == 10 || levelInClass == 15)
                    createSubclassTaskForClass(character, targetClass, levelInClass, "RUNE_CHOICE",
                            "Choose an additional Rune Known", "{\"count\":1}");
                break;
        }
    }

    /** Crea una PendingTask de subclase evitando duplicados por tipo+nivel+clase. */
    private void createSubclassTaskForClass(PlayerCharacter character, DndClass targetClass, int levelInClass,
            String taskType, String description, String initialMetadata) {
        boolean alreadyExists = pendingTaskRepository.findByCharacter(character).stream()
                .anyMatch(t -> taskType.equals(t.getTaskType()) && t.getRelatedLevel() == levelInClass
                        && t.getDndClass() != null && targetClass.getId().equals(t.getDndClass().getId()));
        if (alreadyExists) return;

        PendingTask task = new PendingTask();
        task.setCharacter(character);
        task.setDndClass(targetClass);
        task.setRelatedLevel(levelInClass);
        task.setTaskType(taskType);
        task.setDescription(description);
        task.setMetadata(initialMetadata);
        task.setCompleted(false);
        pendingTaskRepository.save(task);
        System.out.println("Subclass task created: " + taskType + " at level " + levelInClass
                + " for " + character.getName() + " (class: " + targetClass.getName() + ")");
    }

    private void applyAutomaticFeatureForClass(PlayerCharacter character, DndClass targetClass, int levelInClass,
            ClassLevelFeature feature, Integer hpRoll) {
        System.out.println("Applying automatic feature: " + feature.getType() + " (class: " + targetClass.getName() + ")");

        switch (feature.getType()) {
            case HP_INCREASE:
                addHitPointsForClass(character, targetClass, hpRoll);
                break;

            case SPELL_SLOT_UPDATE:
                // No se recalculan aquí: bajo multiclase los slots dependen de TODAS las clases
                // combinadas (nivel de lanzador ponderado), no solo de la que se está subiendo.
                // levelUpMulticlass() llama a recalculateMulticlassSpellSlots() una sola vez,
                // después de procesar todas las clases implicadas en esta subida de nivel.
                System.out.println("Spell slots recalculados aparte por recalculateMulticlassSpellSlots()");
                break;

            case CLASS_FEATURE:
                System.out.println("Class feature (descriptive) - handled separately");
                break;

            default:
                System.out.println("No automatic action for: " + feature.getType());
        }
    }

    private void addHitPointsForClass(PlayerCharacter character, DndClass targetClass, Integer hpRoll) {
        int hitDie = targetClass.getHitDie();

        int constitutionModifier = calculateAbilityModifier(
                character.getAbilityScores().getOrDefault("con", 10)
        );

        int hpGain = (hpRoll != null ? hpRoll : (hitDie / 2) + 1) + constitutionModifier;
        if (hpGain < 1) {
            hpGain = 1;
        }

        hpGain += numericBonusService.bonusFor(character, "MAX_HP_PER_LEVEL");

        int oldMaxHP = character.getMaxHP();
        character.setMaxHP(oldMaxHP + hpGain);
        character.setCurrentHP(character.getMaxHP());

        System.out.println("HP increased by " + hpGain + " (from " + oldMaxHP + " to " + character.getMaxHP() + ", class: " + targetClass.getName() + ")");
    }

    private void addClassFeaturesFromAPIForClass(PlayerCharacter character, DndClass targetClass, int levelInClass) {
        List<ClassFeature> newFeatures = classFeatureRepository
                .findByDndClassAndLevel(targetClass, levelInClass);

        if (newFeatures.isEmpty()) {
            System.out.println("No API features found for level " + levelInClass + " (class: " + targetClass.getName() + ")");
            return;
        }

        for (ClassFeature feature : newFeatures) {
            boolean alreadyHas = characterFeatureRepository.findByCharacter(character)
                    .stream()
                    .anyMatch(cf -> cf.getClassFeature().getId().equals(feature.getId()));

            if (!alreadyHas) {
                CharacterFeature characterFeature = new CharacterFeature(
                        character,
                        feature,
                        levelInClass
                );
                characterFeatureRepository.save(characterFeature);

                System.out.println("Added feature: " + feature.getName() + " (class: " + targetClass.getName() + ")");
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
        dto.setMaxAttunementSlots(character.getMaxAttunementSlots());
        
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

        if (character.getSubclass() != null) {
            dto.setSubclassId(character.getSubclass().getId());
            dto.setSubclassName(character.getSubclass().getName());
        }

        dto.setSpellSaveDC(character.getSpellSaveDC());
        dto.setSpellAttackBonus(character.getSpellAttackBonus());
        dto.setTemporaryHP(character.getTemporaryHP());

        dto.setClasses(toClassDtos(character));

        return dto;
    }

    private void applySubclassStatEffects(PlayerCharacter character, Subclass subclass) {
        if (subclass == null) return;
        switch (subclass.getIndexName()) {
            case "draconic-bloodline":
                // Natural Armor: AC = 13 + DEX when unarmored (Draconic Resilience)
                if (character.getNaturalArmorBonus() == null) {
                    character.setNaturalArmorBonus(13);
                }
                break;
            default:
                break;
        }
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

    /**
     * Aplica un override de ability score: establece la puntuación al valor del item
     * solo si supera la puntuación actual del personaje (p.ej. Gauntlets of Ogre Power STR=19).
     */
    private void applyAbilityOverride(Map<String, Integer> scores, String ability, Integer overrideTo) {
        if (overrideTo == null) return;
        int current = scores.getOrDefault(ability, 10);
        if (overrideTo > current) {
            scores.put(ability, overrideTo);
        }
    }

    /** Extrae el valor "choice" del metadata JSON de una tarea. Formato: {"choice":"Defense",...} */
    private String extractChoiceFromMetadata(String metadata) {
        int idx = metadata.indexOf("\"choice\":\"");
        if (idx == -1) return null;
        int start = idx + 10;
        int end = metadata.indexOf("\"", start);
        return (end > start) ? metadata.substring(start, end) : null;
    }

}
