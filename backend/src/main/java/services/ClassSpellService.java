package services;

import entities.CharacterSpell;
import entities.ClassSpell;
import entities.DndClass;
import entities.PlayerCharacter;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterSpellRepository;
import repositories.ClassSpellRepository;

import java.util.List;

/** Grants all base-class spells from the DB table for spells unlocked at or below characterLevel. */
@Service
public class ClassSpellService {

    private final ClassSpellRepository classSpellRepository;
    private final CharacterSpellRepository characterSpellRepository;

    public ClassSpellService(ClassSpellRepository classSpellRepository,
                             CharacterSpellRepository characterSpellRepository) {
        this.classSpellRepository = classSpellRepository;
        this.characterSpellRepository = characterSpellRepository;
    }

    @Transactional
    public void applyClassSpells(PlayerCharacter character, DndClass dndClass, int characterLevel) {
        if (dndClass == null) return;
        List<ClassSpell> entries = classSpellRepository
                .findByDndClassAndRequiredLevelLessThanEqual(dndClass, characterLevel);
        for (ClassSpell entry : entries) {
            boolean alreadyHas = characterSpellRepository
                    .findByCharacterIdAndSpellId(character.getId(), entry.getSpell().getId())
                    .isPresent();
            if (!alreadyHas) {
                characterSpellRepository.save(new CharacterSpell(character, entry.getSpell(), "CLASS"));
            }
        }
    }
}
