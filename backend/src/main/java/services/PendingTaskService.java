package services;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import dto.PendingTaskDto;
import dto.ResolveTaskRequest;
import entities.CharacterFeat;
import entities.CharacterLanguage;
import entities.CharacterProficiency;
import entities.CharacterSpell;
import entities.Feat;
import entities.Language;
import entities.PendingTask;
import entities.PlayerCharacter;
import entities.Proficiency;
import entities.Spell;
import entities.Subclass;
import jakarta.transaction.Transactional;
import repositories.CharacterFeatRepository;
import repositories.CharacterLanguageRepository;
import repositories.CharacterProficiencyRepository;
import repositories.CharacterSpellRepository;
import repositories.FeatRepository;
import repositories.LanguageRepository;
import repositories.PendingTaskRepository;
import repositories.PlayerCharacterRepository;
import repositories.ProficiencyRepository;
import repositories.SpellRepository;
import repositories.SubclassRepository;

@Service
public class PendingTaskService {

    private final PendingTaskRepository taskRepository;
    private final PlayerCharacterRepository characterRepository;
    private final CharacterSkillService characterSkillService;
    private final CharacterLanguageRepository characterLanguageRepository;
    private final LanguageRepository languageRepository;
    private final CharacterProficiencyRepository characterProficiencyRepository;
    private final ProficiencyRepository proficiencyRepository;
    private final CharacterSpellRepository characterSpellRepository;
    private final SpellRepository spellRepository;
    private final CharacterFeatRepository characterFeatRepository;
    private final FeatRepository featRepository;
    private final SubclassRepository subclassRepository;
    private final SubclassSpellService subclassSpellService;
    private final SubclassProficiencyService subclassProficiencyService;
    private final FeatMechanicalEffectService featMechanicalEffectService;

    public PendingTaskService(PendingTaskRepository taskRepository,
                              PlayerCharacterRepository characterRepository,
                              CharacterSkillService characterSkillService,
                              CharacterLanguageRepository characterLanguageRepository,
                              LanguageRepository languageRepository,
                              CharacterProficiencyRepository characterProficiencyRepository,
                              ProficiencyRepository proficiencyRepository,
                              CharacterSpellRepository characterSpellRepository,
                              SpellRepository spellRepository,
                              CharacterFeatRepository characterFeatRepository,
                              FeatRepository featRepository,
                              SubclassRepository subclassRepository,
                              SubclassSpellService subclassSpellService,
                              SubclassProficiencyService subclassProficiencyService,
                              FeatMechanicalEffectService featMechanicalEffectService) {
        this.taskRepository = taskRepository;
        this.characterRepository = characterRepository;
        this.characterSkillService = characterSkillService;
        this.characterLanguageRepository = characterLanguageRepository;
        this.languageRepository = languageRepository;
        this.characterProficiencyRepository = characterProficiencyRepository;
        this.proficiencyRepository = proficiencyRepository;
        this.characterSpellRepository = characterSpellRepository;
        this.spellRepository = spellRepository;
        this.characterFeatRepository = characterFeatRepository;
        this.featRepository = featRepository;
        this.subclassRepository = subclassRepository;
        this.subclassSpellService = subclassSpellService;
        this.subclassProficiencyService = subclassProficiencyService;
        this.featMechanicalEffectService = featMechanicalEffectService;
    }

    /** Todas las tareas pendientes (sin completar) de un personaje */
    public List<PendingTaskDto> getPendingTasks(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));
        return taskRepository.findByCharacterAndCompletedFalse(character)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    /** Todas las tareas (completadas y pendientes) - útil para historial */
    public List<PendingTaskDto> getAllTasks(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));
        return taskRepository.findByCharacter(character)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());                        
    }

    /**
     * Resuelve una tarea: guarda la elección en metadata y la marca como completada.
     * La lógica de aplicar el efecto real (ej: añadir fighting style al personaje)
     * se hace aquí por tipo de tarea.
     */
    @Transactional
    public PendingTaskDto resolveTask(Long characterId, Long taskId, ResolveTaskRequest request) {
        PlayerCharacter character =
                characterRepository.findById(characterId)
                        .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));
        
        PendingTask task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found with ID: " + taskId));
        
        if (!task.getCharacter().getId().equals(characterId)) {
                throw new RuntimeException("Task does not belong to the character with ID: " + characterId);        
        }
        if (task.isCompleted()){
                throw new RuntimeException("Task already completed");
        }

        //Guardar la elección en metadata
        String choiceJson = "{\"choice\":\"" + escapeJson(request.getChoice()) + "\""
                + (request.getExtraData() != null
                    ? ",\"extra\":" + request.getExtraData()
                    : "")
                + "}";
        task.setMetadata(choiceJson);
        task.setCompleted(true);

        //Aplicar efecto según el tipo
        applyChoice(character, task, request.getChoice());

        taskRepository.save(task);
        characterRepository.save(character);

        return toDto(task);
    }

    private void applyChoice(PlayerCharacter character, PendingTask task,
                String choice) {
        if (choice == null || choice.isBlank()) return;

        switch(task.getTaskType()) {
                case "FIGHTING_STYLE":
                        // Se guarda en metadata; el UI lo muestra como feature activa
                        break;

                case "FAVORED_ENEMY":
                case "FAVORED_TERRAIN":
                case "DRACONIC_ANCESTRY":
                        // Guardado en metadata para uso descriptivo en el UI
                        break;

                case "EXPERTISE":
                        // choice = comma-separated skill names, e.g. "Acrobatics,Stealth"
                        for (String skillName : choice.split(",")) {
                            characterSkillService.applyExpertiseByName(character, skillName);
                        }
                        break;

                case "SKILL_VERSATILITY_1":
                case "SKILL_VERSATILITY_2":
                        // choice = skill display name, e.g. "Stealth"
                        characterSkillService.applySkillProficiencyByName(character, choice.trim());
                        break;

                case "EXTRA_LANGUAGE": {
                        // choice = language display name, e.g. "Elvish"
                        List<Language> langs = languageRepository.findByNameContainingIgnoreCase(choice.trim());
                        if (!langs.isEmpty()) {
                            Language lang = langs.get(0);
                            if (!characterLanguageRepository.existsByCharacterAndLanguage(character, lang)) {
                                characterLanguageRepository.save(new CharacterLanguage(character, lang, "CHOICE"));
                            }
                        } else {
                            System.out.println("Language not found: " + choice);
                        }
                        break;
                }

                case "TOOL_PROFICIENCY": {
                        // choice = tool name, e.g. "Smith's Tools"
                        List<Proficiency> profs = proficiencyRepository.findByNameContainingIgnoreCase(choice.trim());
                        if (!profs.isEmpty()) {
                            Proficiency prof = profs.get(0);
                            if (!characterProficiencyRepository.existsByCharacterAndProficiency(character, prof)) {
                                characterProficiencyRepository.save(new CharacterProficiency(character, prof, "CHOICE"));
                            }
                        } else {
                            System.out.println("Proficiency not found: " + choice);
                        }
                        break;
                }

                case "HIGH_ELF_CANTRIP": {
                        // choice = cantrip name, e.g. "Prestidigitation"
                        List<Spell> cantrips = spellRepository.findByNameContainingIgnoreCase(choice.trim());
                        if (!cantrips.isEmpty()) {
                            Spell cantrip = cantrips.get(0);
                            boolean alreadyKnows = characterSpellRepository
                                    .findByCharacterIdAndSpellId(character.getId(), cantrip.getId())
                                    .isPresent();
                            if (!alreadyKnows) {
                                characterSpellRepository.save(new CharacterSpell(character, cantrip, "RACE"));
                            }
                        } else {
                            System.out.println("Cantrip not found: " + choice);
                        }
                        break;
                }

                case "ASI_OR_FEAT": {
                        if (choice.startsWith("ASI:")) {
                            // Format: ASI:ABILITY:+N  or  ASI:ABILITY1:+1+ABILITY2:+1
                            String rest = choice.substring(4);
                            String[] parts = rest.split(":");
                            Map<String, Integer> scores = new HashMap<>(character.getAbilityScores());
                            if (parts.length == 2) {
                                // e.g. STR:+2
                                String ability = parts[0].toLowerCase();
                                int bonus = Integer.parseInt(parts[1].replace("+", ""));
                                scores.merge(ability, bonus, Integer::sum);
                            } else if (parts.length == 3) {
                                // e.g. STR:+1+DEX:+1  -> parts=["STR","+1+DEX","+1"]
                                String ability1 = parts[0].toLowerCase();
                                // parts[1] = "+1+DEX" -> split by + gives ["","1","DEX"]
                                String[] mid = parts[1].split("\\+");
                                String ability2 = mid[mid.length - 1].toLowerCase();
                                scores.merge(ability1, 1, Integer::sum);
                                scores.merge(ability2, 1, Integer::sum);
                            }
                            character.setAbilityScores(scores);
                        } else if (choice.startsWith("FEAT:")) {
                            String featName = choice.substring(5).trim();
                            List<Feat> feats = featRepository.findByNameContainingIgnoreCase(featName);
                            if (!feats.isEmpty()) {
                                Feat feat = feats.get(0);
                                if (!characterFeatRepository.existsByCharacterAndFeat(character, feat)) {
                                    characterFeatRepository.save(
                                        new CharacterFeat(character, feat, character.getLevel()));
                                }
                                applyFeatEffects(character, feat);
                            } else {
                                System.out.println("Feat not found: " + featName);
                            }
                        }
                        break;
                }

                case "CHOOSE_SUBCLASS": {
                        // choice = subclass display name; assign if not already set
                        if (character.getSubclass() == null && character.getDndClass() != null) {
                            List<Subclass> subclasses = subclassRepository.findByDndClass(character.getDndClass());
                            subclasses.stream()
                                    .filter(sc -> sc.getName().equalsIgnoreCase(choice.trim()))
                                    .findFirst()
                                    .ifPresent(sc -> {
                                        character.setSubclass(sc);
                                        subclassSpellService.applySubclassSpells(character, sc, character.getLevel());
                                        subclassProficiencyService.applySubclassProficiencies(character, sc);
                                        applySubclassStatEffects(character, sc);
                                    });
                        }
                        break;
                }

                case "LAND_TYPE_CHOICE": {
                        // choice = land type name, e.g. "Forest"
                        subclassSpellService.applyLandCircleSpells(character, choice.trim(), character.getLevel());
                        break;
                }

                // Battle Master — maneuvers stored as comma-separated names in metadata
                case "MANEUVER_CHOICE":
                        break;

                // Totem Warrior — choice stored in metadata
                case "TOTEM_SPIRIT":
                case "TOTEM_ASPECT":
                case "TOTEM_ATTUNEMENT":
                        break;

                // Hunter Ranger — choices stored in metadata
                case "HUNTERS_PREY":
                case "DEFENSIVE_TACTICS":
                case "HUNTER_MULTIATTACK":
                case "SUPERIOR_HUNTERS_DEFENSE":
                        break;

                // Four Elements Monk — disciplines stored as comma-separated names in metadata
                case "ELEMENTAL_DISCIPLINE":
                        break;

                // Knowledge Domain — choice = comma-separated skill names; apply expertise to each
                case "KNOWLEDGE_DOMAIN_SKILLS": {
                        for (String skillName : choice.split(",")) {
                            characterSkillService.applyExpertiseByName(character, skillName.trim());
                        }
                        break;
                }

                // Nature Domain — choice = cantrip name; add as SUBCLASS spell
                case "NATURE_DOMAIN_CANTRIP": {
                        List<Spell> cantrips = spellRepository.findByNameContainingIgnoreCase(choice.trim());
                        if (!cantrips.isEmpty()) {
                            Spell cantrip = cantrips.get(0);
                            boolean alreadyHas = characterSpellRepository
                                    .findByCharacterIdAndSpellId(character.getId(), cantrip.getId())
                                    .isPresent();
                            if (!alreadyHas) {
                                characterSpellRepository.save(new CharacterSpell(character, cantrip, "SUBCLASS"));
                            }
                        } else {
                            System.out.println("Nature domain cantrip not found: " + choice);
                        }
                        break;
                }

                // College of Lore — choice = comma-separated skill names; apply proficiency to each
                case "LORE_BARD_SKILLS": {
                        for (String skillName : choice.split(",")) {
                            characterSkillService.applySkillProficiencyByName(character, skillName.trim());
                        }
                        break;
                }

                // Battle Master — choice = tool name or language name
                case "BATTLE_MASTER_TOOL": {
                        List<Proficiency> profs = proficiencyRepository.findByNameContainingIgnoreCase(choice.trim());
                        if (!profs.isEmpty()) {
                            Proficiency prof = profs.get(0);
                            if (!characterProficiencyRepository.existsByCharacterAndProficiency(character, prof)) {
                                characterProficiencyRepository.save(new CharacterProficiency(character, prof, "SUBCLASS"));
                            }
                        } else {
                            // Try as a language
                            List<Language> langs = languageRepository.findByNameContainingIgnoreCase(choice.trim());
                            if (!langs.isEmpty()) {
                                Language lang = langs.get(0);
                                if (!characterLanguageRepository.existsByCharacterAndLanguage(character, lang)) {
                                    characterLanguageRepository.save(new CharacterLanguage(character, lang, "SUBCLASS"));
                                }
                            } else {
                                System.out.println("Battle Master tool/language not found: " + choice);
                            }
                        }
                        break;
                }

                // MoTM-style flexible ASI: choice format "str:2,con:1"
                case "RACIAL_ASI_CHOICE": {
                        java.util.Map<String, Integer> scores = new java.util.HashMap<>(character.getAbilityScores());
                        for (String part : choice.split(",")) {
                                String[] kv = part.trim().split(":");
                                if (kv.length != 2) continue;
                                String ability = kv[0].trim().toLowerCase();
                                try {
                                        int bonus = Integer.parseInt(kv[1].trim());
                                        scores.merge(ability, bonus, Integer::sum);
                                } catch (NumberFormatException ignored) {}
                        }
                        character.setAbilityScores(scores);
                        break;
                }

                // Blood Hunter Order of the Lycan / Order of the Profane Soul — stored in metadata
                case "LYCAN_TYPE":
                case "PROFANE_SOUL_PATRON":
                        break;

                // Resilient — choice = ability name (str/dex/con/int/wis/cha): +1 + saving throw proficiency
                case "RESILIENT_ABILITY": {
                        String ability = choice.trim().toLowerCase();
                        Map<String, Integer> scores = new HashMap<>(character.getAbilityScores());
                        scores.merge(ability, 1, Integer::sum);
                        character.setAbilityScores(scores);
                        characterSkillService.applySavingThrowProficiency(character, ability);
                        break;
                }

                // Feat ability choice — choice = ability name: +1 to that ability
                case "FEAT_ABILITY_CHOICE": {
                        String ability = choice.trim().toLowerCase();
                        Map<String, Integer> scores = new HashMap<>(character.getAbilityScores());
                        scores.merge(ability, 1, Integer::sum);
                        character.setAbilityScores(scores);
                        break;
                }

                // Skilled / Weapon Master — choice = comma-separated proficiency display names
                case "SKILLED_CHOICES":
                case "WEAPON_MASTER_CHOICES": {
                        for (String profName : choice.split(",")) {
                                List<Proficiency> profs = proficiencyRepository.findByNameContainingIgnoreCase(profName.trim());
                                if (!profs.isEmpty()) {
                                        Proficiency prof = profs.get(0);
                                        if (!characterProficiencyRepository.existsByCharacterAndProficiency(character, prof)) {
                                                characterProficiencyRepository.save(new CharacterProficiency(character, prof, "FEAT"));
                                        }
                                } else {
                                        characterSkillService.applySkillProficiencyByName(character, profName.trim());
                                }
                        }
                        break;
                }

                // Purely descriptive feat choices — stored in metadata for display
                case "MAGIC_INITIATE":
                case "RITUAL_CASTER_CLASS":
                case "SPELL_SNIPER_CANTRIP":
                case "MARTIAL_ADEPT_MANEUVER":
                case "ELEMENTAL_ADEPT_TYPE":
                        break;

                // Blood Hunter — curses/shots stored in metadata for display
                case "BLOOD_CURSE_CHOICE":
                case "TRICK_SHOT_CHOICE":
                        break;

                default:
                        System.out.println("No apply logic for task type: " + task.getTaskType());
                }
        }

        private void applyFeatEffects(PlayerCharacter character, Feat feat) {
                featMechanicalEffectService.applyFeatSpells(character, feat);

                String index = feat.getIndexName();
                if (index == null) return;

                Map<String, Integer> scores = new HashMap<>(character.getAbilityScores());

                switch (index) {
                        case "alert":
                                character.setInitiativeBonus(character.getInitiativeBonus() + 5);
                                break;

                        case "tough": {
                                int hpBonus = 2 * character.getLevel();
                                character.setMaxHP(character.getMaxHP() + hpBonus);
                                character.setCurrentHP(character.getCurrentHP() + hpBonus);
                                break;
                        }

                        case "actor":
                                scores.merge("cha", 1, Integer::sum);
                                character.setAbilityScores(scores);
                                break;

                        case "durable":
                                scores.merge("con", 1, Integer::sum);
                                character.setAbilityScores(scores);
                                break;

                        case "keen-mind":
                                scores.merge("int", 1, Integer::sum);
                                character.setAbilityScores(scores);
                                break;

                        case "heavily-armored":
                                scores.merge("str", 1, Integer::sum);
                                character.setAbilityScores(scores);
                                grantProficiency(character, "armor-heavy");
                                break;

                        case "heavy-armor-master":
                                scores.merge("str", 1, Integer::sum);
                                character.setAbilityScores(scores);
                                break;

                        case "linguist":
                                scores.merge("int", 1, Integer::sum);
                                character.setAbilityScores(scores);
                                for (int i = 1; i <= 3; i++) {
                                        createFeatTask(character, "EXTRA_LANGUAGE",
                                                "Choose a language (Linguist — " + i + " of 3)");
                                }
                                break;

                        case "observant":
                                character.setPassiveSensesBonus(character.getPassiveSensesBonus() + 5);
                                createFeatTask(character, "FEAT_ABILITY_CHOICE",
                                        "Choose +1 to Intelligence or Wisdom (Observant)",
                                        "{\"options\":[\"int\",\"wis\"],\"count\":1}");
                                break;

                        case "resilient":
                                createFeatTask(character, "RESILIENT_ABILITY",
                                        "Choose an ability score: gain +1 and saving throw proficiency (Resilient)");
                                break;

                        case "skilled":
                                createFeatTask(character, "SKILLED_CHOICES",
                                        "Choose 3 skill or tool proficiencies (Skilled)",
                                        "{\"count\":3}");
                                break;

                        case "athlete":
                                createFeatTask(character, "FEAT_ABILITY_CHOICE",
                                        "Choose +1 to Strength or Dexterity (Athlete)",
                                        "{\"options\":[\"str\",\"dex\"],\"count\":1}");
                                break;

                        case "tavern-brawler":
                                createFeatTask(character, "FEAT_ABILITY_CHOICE",
                                        "Choose +1 to Strength or Constitution (Tavern Brawler)",
                                        "{\"options\":[\"str\",\"con\"],\"count\":1}");
                                break;

                        case "lightly-armored":
                                grantProficiency(character, "armor-light");
                                grantProficiency(character, "armor-shields");
                                createFeatTask(character, "FEAT_ABILITY_CHOICE",
                                        "Choose +1 to Strength or Dexterity (Lightly Armored)",
                                        "{\"options\":[\"str\",\"dex\"],\"count\":1}");
                                break;

                        case "moderately-armored":
                                grantProficiency(character, "armor-medium");
                                grantProficiency(character, "armor-shields");
                                createFeatTask(character, "FEAT_ABILITY_CHOICE",
                                        "Choose +1 to Strength or Dexterity (Moderately Armored)",
                                        "{\"options\":[\"str\",\"dex\"],\"count\":1}");
                                break;

                        case "weapon-master":
                                createFeatTask(character, "FEAT_ABILITY_CHOICE",
                                        "Choose +1 to Strength or Dexterity (Weapon Master)",
                                        "{\"options\":[\"str\",\"dex\"],\"count\":1}");
                                createFeatTask(character, "WEAPON_MASTER_CHOICES",
                                        "Choose 4 weapon proficiencies (Weapon Master)",
                                        "{\"count\":4}");
                                break;

                        case "magic-initiate":
                                createFeatTask(character, "MAGIC_INITIATE",
                                        "Choose a class and learn 2 cantrips + 1 1st-level spell (Magic Initiate)");
                                break;

                        case "ritual-caster":
                                createFeatTask(character, "RITUAL_CASTER_CLASS",
                                        "Choose a class and learn 2 ritual spells (Ritual Caster)");
                                break;

                        case "spell-sniper":
                                createFeatTask(character, "SPELL_SNIPER_CANTRIP",
                                        "Choose a class and learn an attack cantrip (Spell Sniper)");
                                break;

                        case "martial-adept":
                                createFeatTask(character, "MARTIAL_ADEPT_MANEUVER",
                                        "Choose a Battle Master maneuver (Martial Adept)");
                                break;

                        case "elemental-adept":
                                createFeatTask(character, "ELEMENTAL_ADEPT_TYPE",
                                        "Choose an element: acid, cold, fire, lightning, or thunder (Elemental Adept)");
                                break;

                        // Feats sin lógica dedicada (típicamente de Aurora): si declaran un bono
                        // numérico estructurado (effectModifierType/effectModifierValue), se aplica
                        // genéricamente como CharacterActiveEffect.
                        default:
                                featMechanicalEffectService.applyFeatModifier(character, feat);
                                break;
                }
        }

        private void grantProficiency(PlayerCharacter character, String indexName) {
                proficiencyRepository.findByIndexName(indexName).ifPresent(prof -> {
                        if (!characterProficiencyRepository.existsByCharacterAndProficiency(character, prof)) {
                                characterProficiencyRepository.save(new CharacterProficiency(character, prof, "FEAT"));
                        }
                });
        }

        private void createFeatTask(PlayerCharacter character, String taskType, String description) {
                createFeatTask(character, taskType, description, null);
        }

        private void createFeatTask(PlayerCharacter character, String taskType,
                                    String description, String metadata) {
                boolean exists = taskRepository.findByCharacter(character).stream()
                        .anyMatch(t -> taskType.equals(t.getTaskType()) && description.equals(t.getDescription()));
                if (exists) return;
                PendingTask task = new PendingTask();
                task.setCharacter(character);
                task.setRelatedLevel(character.getLevel());
                task.setTaskType(taskType);
                task.setDescription(description);
                task.setMetadata(metadata);
                task.setCompleted(false);
                taskRepository.save(task);
        }

        private PendingTaskDto toDto(PendingTask t) {
                PendingTaskDto dto = new PendingTaskDto();
                dto.setId(t.getId());
                dto.setTaskType(t.getTaskType());
                dto.setRelatedLevel(t.getRelatedLevel());
                dto.setDescription(t.getDescription());
                dto.setCompleted(t.isCompleted());
                dto.setMetadata(t.getMetadata());
                return dto;
        }

        private void applySubclassStatEffects(PlayerCharacter character, Subclass subclass) {
                if (subclass == null) return;
                switch (subclass.getIndexName()) {
                        case "draconic-bloodline":
                                if (character.getNaturalArmorBonus() == null) {
                                        character.setNaturalArmorBonus(13);
                                }
                                break;
                        default:
                                break;
                }
        }

        private String escapeJson(String s) {
                if(s == null) return "";
                return s.replace("\\", "\\\\").replace("\"", "\\\"");
        }
}
