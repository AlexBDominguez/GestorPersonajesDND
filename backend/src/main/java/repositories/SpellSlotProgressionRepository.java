package repositories;

import java.util.List;
import java.util.Optional;

import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;

import entities.DndClass;
import entities.SpellSlotProgression;

public interface SpellSlotProgressionRepository extends JpaRepository<SpellSlotProgression, Long> {
    
    @Transactional
    void deleteByDndClassAndCharacterLevel(DndClass dndClass, int characterLevel);

    List<SpellSlotProgression> findByDndClassAndCharacterLevel(DndClass dndClass, int characterLevel);

    Optional<SpellSlotProgression> findByDndClassAndCharacterLevelAndSpellLevel(
        DndClass dndClass, int characterLevel, int spellLevel);

}
