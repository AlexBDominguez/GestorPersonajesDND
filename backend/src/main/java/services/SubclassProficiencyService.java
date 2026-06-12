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
        if (subclass == null) return;
        String index = subclass.getIndexName();
        if (index == null) return;

        switch (index) {
            case "tempest":
            case "war":
                grant(character, "armor-heavy");
                grant(character, "weapons-martial");
                break;

            case "knowledge":
                createTask(character, "KNOWLEDGE_DOMAIN_SKILLS",
                        "Choose 2 skills to gain Expertise (Knowledge Domain)", "{\"count\":2}");
                createTask(character, "EXTRA_LANGUAGE",
                        "Choose an extra language (Knowledge Domain — 1st)");
                createTask(character, "EXTRA_LANGUAGE",
                        "Choose a second extra language (Knowledge Domain — 2nd)");
                break;

            case "nature":
                grant(character, "armor-heavy");
                createTask(character, "NATURE_DOMAIN_CANTRIP",
                        "Choose a cantrip from the Nature Domain list (Animal Friendship, Poison Spray, Shillelagh, or Thorn Whip)");
                break;

            case "valor":
                grant(character, "armor-medium");
                grant(character, "armor-shields");
                grant(character, "weapons-martial");
                break;

            case "lore":
                createTask(character, "LORE_BARD_SKILLS",
                        "Choose 3 additional skill proficiencies (College of Lore)", "{\"count\":3}");
                break;

            case "battle-master":
                createTask(character, "BATTLE_MASTER_TOOL",
                        "Choose one artisan's tool or language proficiency (Battle Master)");
                break;

            case "armorer":
                grant(character, "armor-heavy");
                break;

            case "battle-smith":
                grant(character, "weapons-martial");
                grant(character, "smiths-tools");
                break;

            case "alchemist":
                grant(character, "alchemists-supplies");
                break;

            case "artillerist":
                grant(character, "woodcarvers-tools");
                break;

            case "lycan":
                createTask(character, "LYCAN_TYPE",
                        "Choose your Lycanthrope type");
                break;

            case "profane-soul":
                createTask(character, "PROFANE_SOUL_PATRON",
                        "Choose your Otherworldly Patron");
                break;
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
