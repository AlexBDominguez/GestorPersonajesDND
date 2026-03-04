package repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.DndClass;
import entities.SpellSlotProgression;

public interface SpellSlotProgressionRepository extends JpaRepository<SpellSlotProgression, Long> {
    
    void deleteByDndClassAndCharacterLevel(DndClass dndClass, int characterLevel);

    List<SpellSlotProgression> findByDndClassAndCharacterLevel(DndClass dndClass, int characterLevel);

}
