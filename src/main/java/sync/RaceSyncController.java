package sync;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/sync/races")
public class RaceSyncController {

    private final RaceSyncService raceSyncService;

    public RaceSyncController(RaceSyncService raceSyncService){
        this.raceSyncService = raceSyncService;
    }

    @PostMapping
    public String sync(){
        raceSyncService.syncRaces();
        return "Races synchronized";
    }

}
