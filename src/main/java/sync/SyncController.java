package sync;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;



@RestController
@RequestMapping("/api/sync")
public class SyncController {

    private final RaceSyncService raceSyncService;
    private final SpellSlotSyncService spellSlotSyncService;
    private final SkillSyncService skillSyncService;
    private final BackgroundSyncService backgroundSyncService;
    private final DndClassSyncService dndClassSyncService;
    private final SpellSyncService spellSyncService;
    private final SubclassSyncService subclassSyncService;
    private final ProficiencySyncService proficiencySyncService;
    private final LanguageSyncService languageSyncService;
    private final ConditionSyncService conditionSyncService;
    private final DamageTypeSyncService damageTypeSyncService;

    public SyncController(  RaceSyncService raceSyncService,
                            SpellSlotSyncService spellSlotSyncService,
                            SkillSyncService skillSyncService,
                            BackgroundSyncService backgroundSyncService,
                            DndClassSyncService dndClassSyncService,
                            SpellSyncService spellSyncService,
                            SubclassSyncService subclassSyncService,
                            ProficiencySyncService proficiencySyncService,
                            LanguageSyncService languageSyncService,
                            ConditionSyncService conditionSyncService,
                            DamageTypeSyncService damageTypeSyncService                        
                        ) {
                            
        this.raceSyncService = raceSyncService;
        this.spellSlotSyncService = spellSlotSyncService;
        this.skillSyncService = skillSyncService;
        this.backgroundSyncService = backgroundSyncService;
        this.dndClassSyncService = dndClassSyncService;
        this.spellSyncService = spellSyncService;
        this.subclassSyncService = subclassSyncService;
        this.proficiencySyncService = proficiencySyncService;
        this.languageSyncService = languageSyncService;
        this.conditionSyncService = conditionSyncService;
        this.damageTypeSyncService = damageTypeSyncService;
    }

    @PostMapping("/races")
    public String syncRaces(){
        raceSyncService.syncRaces();
        return "Races synced";
    }

    @PostMapping("/spell-slots/{classIndex}")
    public String syncSpellSlots(@PathVariable String classIndex){
        spellSlotSyncService.syncSpellSlotForClass(classIndex);
        return "Spell slots synced for class " + classIndex;
    }

    @PostMapping("/skills")
    public String syncSkills(){
        skillSyncService.syncSkills();
        return "Skills synced";
    }

    @PostMapping("/backgrounds")
    public String syncBackgrounds(){
        backgroundSyncService.syncBackgrounds();
        return "Backgrounds synced";
    }

    @PostMapping("/classes")
    public String syncClasses(){
        dndClassSyncService.syncClasses();
        return "Classes synced";
    }

    @PostMapping("/spells")
    public String syncSpells(){
        spellSyncService.syncSpells();
        return "Spells synced";
    }

    @PostMapping("/subclasses")
    public ResponseEntity<String> syncSubclasses() {
        subclassSyncService.syncSubclasses();
        return ResponseEntity.ok("Subclasses synchronized successfully!");
    }

    @PostMapping("/proficiencies")
    public ResponseEntity<String> syncProficiencies() {
        proficiencySyncService.syncProficiencies();
        return ResponseEntity.ok("Proficiencies synchronized successfully!");
    }

    @PostMapping("/languages")
    public ResponseEntity<String> syncLanguages() {
        languageSyncService.syncLanguages();
        return ResponseEntity.ok("Languages synchronized successfully!");
    }

    @PostMapping("/conditions")
    public ResponseEntity<String> syncConditions() {
        conditionSyncService.syncConditions();
        return ResponseEntity.ok("Conditions synchronized successfully!");        
    }

    @PostMapping("/damage-types")
    public ResponseEntity<String> syncDamageTypes() {
        damageTypeSyncService.syncDamageTypes();
        return ResponseEntity.ok("Damage types synchronized successfully!");
    }

    @PostMapping("/all")
    public String syncAll() {
        System.out.println("=== STARTING FULL SYNCHRONIZATION ===");
        
        try {
            System.out.println("\n1/8 - Syncing Skills...");
            skillSyncService.syncSkills();
            ApiRateLimiter.waitLonger();
            
            System.out.println("\n2/8 - Syncing Backgrounds...");
            backgroundSyncService.syncBackgrounds();
            ApiRateLimiter.waitLonger();
            
            System.out.println("\n3/8 - Syncing Races...");
            raceSyncService.syncRaces();
            ApiRateLimiter.waitLonger();
            
            System.out.println("\n4/8 - Syncing Classes...");
            dndClassSyncService.syncClasses();
            ApiRateLimiter.waitLonger();
            
            System.out.println("\n5/8 - Syncing Spells...");
            spellSyncService.syncSpells();
            ApiRateLimiter.waitLonger();

            System.out.println("\n6/8 - Syncing Subclasses...");
            subclassSyncService.syncSubclasses();
            ApiRateLimiter.waitLonger();

            System.out.println("\n7/8 - Syncing Proficiencies...");
            proficiencySyncService.syncProficiencies();
            ApiRateLimiter.waitLonger();

            System.out.println("\n8/8 - Syncing Languages...");
            languageSyncService.syncLanguages();
            ApiRateLimiter.waitLonger();

            System.out.println("\n9/8 - Syncing Conditions...");
            conditionSyncService.syncConditions();
            ApiRateLimiter.waitLonger();

            System.out.println("\n10/8 - Syncing Damage Types...");
            damageTypeSyncService.syncDamageTypes();
            ApiRateLimiter.waitLonger();

            System.out.println("\n=== FULL SYNCHRONIZATION COMPLETE ===");
            return "Full synchronization completed successfully!";
            
        } catch (Exception e) {
            System.err.println("Error during synchronization: " + e.getMessage());
            return "Synchronization failed: " + e.getMessage();
        }
    }
}
