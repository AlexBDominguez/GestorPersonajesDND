package controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import dto.PendingTaskDto;
import dto.ResolveTaskRequest;
import services.PendingTaskService;

@RestController
@RequestMapping("/api/characters/{characterId}/pending-tasks")
public class PendingTaskController {
    private final PendingTaskService taskService;

    public PendingTaskController(PendingTaskService taskService) {
        this.taskService = taskService;
    }

    /** GET /api/characters/{id}/pending-tasks -> tareas sin completar */
    @GetMapping("/all")
    public ResponseEntity<List<PendingTaskDto>> getAllTasks(
            @PathVariable Long characterId) {
                return ResponseEntity.ok(taskService.getAllTasks(characterId));
    }
    
    /** POST /api/characters/{id}/pending-tasks/{taskId}/resolve */
    @PostMapping("/{taskId}/resolve")
    public ResponseEntity<PendingTaskDto> resolveTask(
            @PathVariable Long characterId,
            @PathVariable Long taskId,
            @RequestBody ResolveTaskRequest request) {
        return ResponseEntity.ok(taskService.resolveTask(characterId, taskId, request));
    }
}
