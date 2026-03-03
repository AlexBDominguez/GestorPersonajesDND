package sync;

import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/sync")
public class SyncController {

    private final RaceSyncService raceSyncService;
    private final SpellSlotSyncService spellSlotSyncService;

    public SyncController(RaceSyncService raceSyncService) {
        this.raceSyncService = raceSyncService;
    }

    @PostMapping("/races")
    public String syncRaces(){
        raceSyncService.syncRaces();
        return "Races synced";
    }

    @PostMapping("/sync/spell-slots/{classIndex}")
    public String syncSpellSlots(@PathVariable String classIndex){
        spellSlotSyncService.syncSpellSlotForClass(classIndex);
        return "Spell slots synced for class " + classIndex;
    }



}
