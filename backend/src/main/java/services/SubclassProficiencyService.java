package services;

import entities.CharacterProficiency;
import entities.PendingTask;
import entities.PlayerCharacter;
import entities.Subclass;
import entities.SubclassProficiencyGrant;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterProficiencyRepository;
import repositories.PendingTaskRepository;
import repositories.SubclassProficiencyGrantRepository;

@Service
public class SubclassProficiencyService {

    private final CharacterProficiencyRepository characterProficiencyRepository;
    private final SubclassProficiencyGrantRepository subclassProficiencyGrantRepository;
    private final PendingTaskRepository pendingTaskRepository;

    public SubclassProficiencyService(CharacterProficiencyRepository characterProficiencyRepository,
                                      SubclassProficiencyGrantRepository subclassProficiencyGrantRepository,
                                      PendingTaskRepository pendingTaskRepository) {
        this.characterProficiencyRepository = characterProficiencyRepository;
        this.subclassProficiencyGrantRepository = subclassProficiencyGrantRepository;
        this.pendingTaskRepository = pendingTaskRepository;
    }

    @Transactional
    public void applySubclassProficiencies(PlayerCharacter character, Subclass subclass) {
        if (subclass == null || subclass.getIndexName() == null) return;

        // Automatic (non-choice) grants: fully data-driven now (subclass_proficiency_grants —
        // see GRANT_PROFICIENCY in Aurora_Fixes.md #8.2). Used to be a per-subclass if/grant()
        // chain here; migrated to seeded rows so a new subclass with a flat proficiency grant
        // (heavy armor, a tool, martial weapons...) needs a seed row, not a Java change.
        for (SubclassProficiencyGrant entry : subclassProficiencyGrantRepository.findBySubclass(subclass)) {
            if (!characterProficiencyRepository.existsByCharacterAndProficiency(character, entry.getProficiency())) {
                characterProficiencyRepository.save(
                        new CharacterProficiency(character, entry.getProficiency(), "SUBCLASS"));
            }
        }

        // Choices (the player picks skills/tools/a cantrip/etc.): stays as PendingTask, a
        // different mechanic from an automatic grant — not something #8.2's GRANT_PROFICIENCY
        // piece covers, the choice-resolution system already handles this generically.
        //
        // PHB subclasses have clean slugs as indexName (synced from dnd5eapi.co), but
        // Aurora-sourced subclasses (Artificer, Blood Hunter, ...) store the raw Aurora
        // element ID instead (e.g. "ID_WOTC_TCOE_ARCHETYPE_ARTIFICER_ALCHEMIST"), so an
        // exact-match switch never matches those. Use substring matching on the lowercased
        // indexName instead — same convention already used in the frontend wizard
        // (character_creator_viewmodel.dart's subclass feature-choice detection).
        String idx = subclass.getIndexName().toLowerCase();

        if (idx.contains("knowledge")) {
            createTask(character, "KNOWLEDGE_DOMAIN_SKILLS",
                    "Choose 2 skills to gain Expertise (Knowledge Domain)", "{\"count\":2}");
            createTask(character, "EXTRA_LANGUAGE",
                    "Choose an extra language (Knowledge Domain — 1st)");
            createTask(character, "EXTRA_LANGUAGE",
                    "Choose a second extra language (Knowledge Domain — 2nd)");
        }

        if (idx.contains("nature")) {
            createTask(character, "NATURE_DOMAIN_CANTRIP",
                    "Choose a cantrip from the Nature Domain list (Animal Friendship, Poison Spray, Shillelagh, or Thorn Whip)");
        }

        // "lore" alone would also match unrelated subclasses like "...ranger_explorer"
        // (the substring "lore" appears inside "explorer"), so require a word boundary.
        if (idx.equals("lore") || idx.contains("_lore") || idx.contains("-lore")
                || idx.contains("college of lore") || idx.contains("college-of-lore")) {
            createTask(character, "LORE_BARD_SKILLS",
                    "Choose 3 additional skill proficiencies (College of Lore)", "{\"count\":3}");
        }

        if (idx.contains("battle-master") || idx.contains("battle master") || idx.contains("battlemaster")) {
            createTask(character, "BATTLE_MASTER_TOOL",
                    "Choose one artisan's tool or language proficiency (Battle Master)");
        }

        if (idx.contains("lycan")) {
            createTask(character, "LYCAN_TYPE",
                    "Choose your Lycanthrope type");
        }

        if (idx.contains("profane")) {
            createTask(character, "PROFANE_SOUL_PATRON",
                    "Choose your Otherworldly Patron");
        }
    }

    /** Creates a task, deduplicating by type+description. */
    private void createTask(PlayerCharacter character, String taskType, String description) {
        createTask(character, taskType, description, null);
    }

    private void createTask(PlayerCharacter character, String taskType,
                            String description, String metadata) {
        boolean exists = pendingTaskRepository.findByCharacter(character).stream()
                .anyMatch(t -> taskType.equals(t.getTaskType())
                        && description.equals(t.getDescription()));
        if (exists) return;

        PendingTask task = new PendingTask();
        task.setCharacter(character);
        task.setRelatedLevel(character.getLevel());
        task.setTaskType(taskType);
        task.setDescription(description);
        task.setMetadata(metadata);
        task.setCompleted(false);
        pendingTaskRepository.save(task);
    }
}
