package repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.Skill;

public interface SkillRepository extends JpaRepository<Skill, Long> {
    Optional<Skill> findByIndexName(String indexName);
}

    
