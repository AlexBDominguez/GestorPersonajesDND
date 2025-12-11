package sync;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/sync/classes")
public class DndClassSyncController {
    private final DndClassSyncService syncService;

    public DndClassSyncController(DndClassSyncService syncService) {
        this.syncService = syncService;
    }

    @PostMapping
    public String sync(){
        syncService.syncClasses();
        return "Classes synchronized";
    }
}
