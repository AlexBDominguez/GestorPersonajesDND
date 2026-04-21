package services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import dto.PendingTaskDto;
import dto.ResolveTaskRequest;
import entities.PendingTask;
import entities.PlayerCharacter;
import jakarta.transaction.Transactional;
import repositories.PendingTaskRepository;
import repositories.PlayerCharacterRepository;

@Service
public class PendingTaskService {

    private final PendingTaskRepository taskRepository;
    private final PlayerCharacterRepository characterRepository;

    public PendingTaskService(PendingTaskRepository taskRepository,
                              PlayerCharacterRepository characterRepository) {
        this.taskRepository = taskRepository;
        this.characterRepository = characterRepository;
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
                        //La feature Fighting Style se guarda en metadata - se muestra en Features
                        //No modifica stats directos (el UI lo mostrará como feature activa)
                        System.out.println("Fighting Style chose: " + choice + " for  " + character.getName());
                        break;

                case "FAVORED_ENEMY":
                        System.out.println("Favored Enemy chosen: " + choice + " for " + character.getName());
                        break;

                case "FAVORED_TERRAIN":
                        System.out.println("Favored Terrain chosen: " + choice + " for " + character.getName());
                        break;
                
                case "DRACONIC_ANCESTRY":
                        //Dragonborn: tel tipo de daño del Breath Weapon depende de esto
                        System.out.println("Draconic Ancestry chosen: " + choice + " for " + character.getName());
                        break;
                
                case "EXPERTISE":
                        //Bard/Rogue nivel 1/3: doblar proficiency en 2 skills elegidas
                        // La implementación real requeriría actualizar CharacterSkill.expertise
                        System.out.println("Expertise chosen: " + choice + " for " + character.getName());
                        break;
                
                case "ASI_OR_FEAT":
                        //Si choice = "ASI", el extraData contiene qué abilities subir
                        //Si choice = "FEAT", el extraData contiene el featId
                        //Por ahora lo registramos - la aplicación real va en el sprint de level-up
                        System.out.println("ASI or Feat chosen: " + choice + " for " + character.getName());
                        break;

                case "CHOOSE_SUBCLASS":
                        // El subclass debería haberse asignado en el wizard ya
                        //Aquí se llega si el personaje llegó al nivel sin haberlo elegido
                        System.out.println("Subclass chosen: " + choice + " for " + character.getName());
                        break;

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
