package controllers;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import services.RaceSyncService;

@RestController
@RequestMapping("/api/sync")
public class SyncController {

    private final RaceSyncService raceSyncService;

    public SyncController(RaceSyncService raceSyncService) {
        this.raceSyncService = raceSyncService;
    }

    @PostMapping("/races")
    public String syncRaces(){
        raceSyncService.syncRaces();
        return "Races synced";
    }
}
