package services;

import entities.CharacterProficiency;
import entities.PendingTask;
import entities.PlayerCharacter;
import entities.Proficiency;
import entities.Subclass;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterProficiencyRepository;
import repositories.PendingTaskRepository;
import repositories.ProficiencyRepository;

@Service
public class SubclassProficiencyService {

    private final CharacterProficiencyRepository characterProficiencyRepository;
    private final ProficiencyRepository proficiencyRepository;
    private final PendingTaskRepository pendingTaskRepository;

    public SubclassProficiencyService(CharacterProficiencyRepository characterProficiencyRepository,
                                      ProficiencyRepository proficiencyRepository,
                                      PendingTaskRepository pendingTaskRepository) {
        this.characterProficiencyRepository = characterProficiencyRepository;
        this.proficiencyRepository = proficiencyRepository;
        this.pendingTaskRepository = pendingTaskRepository;
    }

    @Transactional
    public void applySubclassProficiencies(PlayerCharacter character, Subclass subclass) {
        if (subclass == null || subclass.getIndexName() == null) return;

        // PHB subclasses have clean slugs as indexName (synced from dnd5eapi.co), but
        // Aurora-sourced subclasses (Artificer, Blood Hunter, ...) store the raw Aurora
        // element ID instead (e.g. "ID_WOTC_TCOE_ARCHETYPE_ARTIFICER_ALCHEMIST"), so an
        // exact-match switch never matches those. Use substring matching on the lowercased
        // indexName instead — same convention already used in the frontend wizard
        // (character_creator_viewmodel.dart's subclass feature-choice detection).
        String idx = subclass.getIndexName().toLowerCase();

        if (idx.contains("tempest") || idx.equals("war") || idx.contains("oath-of-the-war")) {
            grant(character, "armor-heavy");
            grant(character, "weapons-martial");
        }

        if (idx.contains("knowledge")) {
            createTask(character, "KNOWLEDGE_DOMAIN_SKILLS",
                    "Choose 2 skills to gain Expertise (Knowledge Domain)", "{\"count\":2}");
            createTask(character, "EXTRA_LANGUAGE",
                    "Choose an extra language (Knowledge Domain — 1st)");
            createTask(character, "EXTRA_LANGUAGE",
                    "Choose a second extra language (Knowledge Domain — 2nd)");
        }

        if (idx.contains("nature")) {
            grant(character, "armor-heavy");
            createTask(character, "NATURE_DOMAIN_CANTRIP",
                    "Choose a cantrip from the Nature Domain list (Animal Friendship, Poison Spray, Shillelagh, or Thorn Whip)");
        }

        if (idx.contains("valor")) {
            grant(character, "armor-medium");
            grant(character, "armor-shields");
            grant(character, "weapons-martial");
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

        if (idx.contains("armorer")) {
            grant(character, "armor-heavy");
        }

        if (idx.contains("battle_smith") || idx.contains("battle-smith") || idx.contains("battlesmith")) {
            grant(character, "weapons-martial");
            grant(character, "smiths-tools");
        }

        if (idx.contains("alchemist")) {
            grant(character, "alchemists-supplies");
        }

        if (idx.contains("artillerist")) {
            grant(character, "woodcarvers-tools");
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

    private void grant(PlayerCharacter character, String indexName) {
        proficiencyRepository.findByIndexName(indexName).ifPresent(prof -> {
            if (!characterProficiencyRepository.existsByCharacterAndProficiency(character, prof)) {
                characterProficiencyRepository.save(new CharacterProficiency(character, prof, "SUBCLASS"));
            }
        });
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
