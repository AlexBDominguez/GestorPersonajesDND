package repositories;

import entities.PlayerCharacter;
import entities.User;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlayerCharacterRepository extends JpaRepository<PlayerCharacter, Long> {

    List<PlayerCharacter> findByUserId(Long userId);
    long countByUser(User user);

}
