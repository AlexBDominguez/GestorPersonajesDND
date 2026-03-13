package repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.PendingTask;
import entities.PlayerCharacter;

public interface PendingTaskRepository extends JpaRepository<PendingTask, Long> {

    List<PendingTask> findByCharacter(PlayerCharacter character);

    List<PendingTask> findByCharacterAndCompleted(PlayerCharacter character, boolean completed);

    List<PendingTask> findByCharacterAndCompletedFalse(PlayerCharacter character);
    
}
