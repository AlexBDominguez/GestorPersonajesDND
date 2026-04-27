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
    private final SubraceSyncService subraceSyncService;
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
    private final ItemSyncService itemSyncService;

    public SyncController(  RaceSyncService raceSyncService,
                            SubraceSyncService subraceSyncService,
                            SpellSlotSyncService spellSlotSyncService,
                            SkillSyncService skillSyncService,
                            BackgroundSyncService backgroundSyncService,
                            DndClassSyncService dndClassSyncService,
                            SpellSyncService spellSyncService,
                            SubclassSyncService subclassSyncService,
                            ProficiencySyncService proficiencySyncService,
                            LanguageSyncService languageSyncService,
                            ConditionSyncService conditionSyncService,
                            DamageTypeSyncService damageTypeSyncService,
                            ItemSyncService itemSyncService
                        ) {
                            
        this.raceSyncService = raceSyncService;
        this.subraceSyncService = subraceSyncService;
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
        this.itemSyncService = itemSyncService;
    }

    @PostMapping("/races")
    public String syncRaces(){
        raceSyncService.syncRaces();
        return "Races synced";
    }

    @PostMapping("/subraces")
    public ResponseEntity<String> syncSubraces() {
        subraceSyncService.syncSubraces();
        return ResponseEntity.ok("Subraces synchronized successfully!");
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

    @PostMapping("/class-spells")
    public ResponseEntity<String> syncClassSpells() {
        dndClassSyncService.syncClassSpells();
        return ResponseEntity.ok("Class spells synchronized!");
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

    @PostMapping("/subclass-features")
    public ResponseEntity<String> syncSubclassFeatures() {
        subclassSyncService.syncMissingSubclassFeatures();
        return ResponseEntity.ok("Subclass features synchronized successfully!");
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

    @PostMapping("/items")
    public ResponseEntity<String> syncItems() {
        itemSyncService.syncItems();
        return ResponseEntity.ok("Items synchronized successfully!");
    }

    @PostMapping("/all")
    public String syncAll() {
        System.out.println("=== STARTING FULL SYNCHRONIZATION ===");
        
        try {
            System.out.println("\n1/11 - Syncing Skills...");
            skillSyncService.syncSkills();
            ApiRateLimiter.waitLonger();
            
            System.out.println("\n2/11 - Syncing Backgrounds...");
            backgroundSyncService.syncBackgrounds();
            ApiRateLimiter.waitLonger();
            
            System.out.println("\n3/11 - Syncing Races...");
            raceSyncService.syncRaces();
            ApiRateLimiter.waitLonger();

            System.out.println("\n3b - Syncing Subraces...");
            subraceSyncService.syncSubraces();
            ApiRateLimiter.waitLonger();
            
            System.out.println("\n4/11 - Syncing Classes...");
            dndClassSyncService.syncClasses();
            ApiRateLimiter.waitLonger();
            
            System.out.println("\n5/11 - Syncing Spells...");
            spellSyncService.syncSpells();
            ApiRateLimiter.waitLonger();

            System.out.println("\n6/11 - Syncing Subclasses...");
            subclassSyncService.syncSubclasses();
            ApiRateLimiter.waitLonger();

            System.out.println("\n7/11 - Syncing Proficiencies...");
            proficiencySyncService.syncProficiencies();
            ApiRateLimiter.waitLonger();

            System.out.println("\n8/11 - Syncing Languages...");
            languageSyncService.syncLanguages();
            ApiRateLimiter.waitLonger();

            System.out.println("\n9/11 - Syncing Conditions...");
            conditionSyncService.syncConditions();
            ApiRateLimiter.waitLonger();

            System.out.println("\n10/11 - Syncing Damage Types...");
            damageTypeSyncService.syncDamageTypes();
            ApiRateLimiter.waitLonger();

            System.out.println("\n11/11 - Syncing Items...");
            itemSyncService.syncItems();
            ApiRateLimiter.waitLonger();

            System.out.println("\n=== FULL SYNCHRONIZATION COMPLETE ===");
            return "Full synchronization completed successfully!";
            
        } catch (Exception e) {
            System.err.println("Error during synchronization: " + e.getMessage());
            return "Synchronization failed: " + e.getMessage();
        }
    }
}
