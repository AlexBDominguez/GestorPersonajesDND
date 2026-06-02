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
                              SubclassRepository subclassRepository) {
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
                                    .ifPresent(character::setSubclass);
                        }
                        break;
                }

                default:
                        System.out.println("No apply logic for task type: " + task.getTaskType());
                }    
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

        private String escapeJson(String s) {
                if(s == null) return "";
                return s.replace("\\", "\\\\").replace("\"", "\\\"");
        }
}
