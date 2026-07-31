package services;

import entities.CharacterProficiency;
import entities.DndClass;
import entities.PlayerCharacter;
import entities.Proficiency;
import org.springframework.stereotype.Service;
import repositories.CharacterProficiencyRepository;
import repositories.ProficiencyRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Reglas de multiclase del PHB (Aurora_Fixes.md #17, fase 1): mínimos de característica
 * para tomar una clase nueva (aviso no bloqueante) y el subconjunto reducido de
 * proficiencies que otorga tomar esa clase como clase adicional (nunca salvaciones).
 * Mismo patrón que otras tablas fijas del PHB ya hardcodeadas en este código
 * (p.ej. computeThirdCasterSlots() en PlayerCharacterService).
 */
@Service
public class MulticlassRulesService {

    private final ProficiencyRepository proficiencyRepository;
    private final CharacterProficiencyRepository characterProficiencyRepository;

    public MulticlassRulesService(ProficiencyRepository proficiencyRepository,
                                   CharacterProficiencyRepository characterProficiencyRepository) {
        this.proficiencyRepository = proficiencyRepository;
        this.characterProficiencyRepository = characterProficiencyRepository;
    }

    // Grupos OR: basta con satisfacer TODOS los requisitos de UN grupo interior (así se
    // expresa también un AND de un fijo + un OR, p.ej. Blood Hunter = Int 13 Y (Str 13 O Dex
    // 13): dos grupos {int:13,str:13} / {int:13,dex:13}, cualquiera de los dos vale).
    // Clases ausentes de este mapa (homebrew/Aurora sin tabla de multiclase conocida, p.ej.
    // Gunslinger) no generan ningún aviso -- opción conservadora, nunca avisa de más sobre
    // una regla que no se ha podido confirmar para esa clase.
    private static final Map<String, List<Map<String, Integer>>> ABILITY_PREREQS = Map.ofEntries(
            Map.entry("barbarian", List.of(Map.of("str", 13))),
            Map.entry("bard",      List.of(Map.of("cha", 13))),
            Map.entry("cleric",    List.of(Map.of("wis", 13))),
            Map.entry("druid",     List.of(Map.of("wis", 13))),
            Map.entry("fighter",   List.of(Map.of("str", 13), Map.of("dex", 13))),
            Map.entry("monk",      List.of(Map.of("dex", 13, "wis", 13))),
            Map.entry("paladin",   List.of(Map.of("str", 13, "cha", 13))),
            Map.entry("ranger",    List.of(Map.of("dex", 13, "wis", 13))),
            Map.entry("rogue",     List.of(Map.of("dex", 13))),
            Map.entry("sorcerer",  List.of(Map.of("cha", 13))),
            Map.entry("warlock",   List.of(Map.of("cha", 13))),
            Map.entry("wizard",    List.of(Map.of("int", 13))),
            // Artificer (TCE p.10, oficial pero post-PHB, dos variantes de sourcebook en esta
            // app -- ver DndClass.indexName "artificer-erlw"/"artificer-tce").
            Map.entry("artificer-erlw", List.of(Map.of("int", 13))),
            Map.entry("artificer-tce",  List.of(Map.of("int", 13))),
            // Blood Hunter (Matt Mercer/Critical Role, homebrew con reglas de multiclase
            // publicadas -- confirmado en dndbeyond.com/classes/357975-blood-hunter y
            // dnd5e.wikidot.com/blood-hunter, mismo prerrequisito en ambas fuentes).
            Map.entry("blood-hunter", List.of(Map.of("int", 13, "str", 13), Map.of("int", 13, "dex", 13)))
    );

    // Tabla oficial "Multiclass Proficiencies" del PHB (armadura/armas/herramientas -- nunca
    // salvaciones). Deliberadamente NO incluye las elecciones de skill de Bardo/Pícaro/
    // Explorador (una skill a elegir de la lista de la clase) ni la de herramienta de
    // Artificiero -- se avisan por texto en vez de automatizarse, ver EXTRA_CHOICE_NOTES /
    // grantReducedProficiencies().
    private static final Map<String, List<String>> REDUCED_PROFICIENCIES = Map.ofEntries(
            Map.entry("barbarian", List.of("shields", "simple-weapons", "martial-weapons")),
            Map.entry("bard",      List.of("light-armor")),
            Map.entry("cleric",    List.of("light-armor", "medium-armor", "shields")),
            Map.entry("druid",     List.of("light-armor", "medium-armor", "shields")),
            Map.entry("fighter",   List.of("light-armor", "medium-armor", "shields", "simple-weapons", "martial-weapons")),
            Map.entry("paladin",   List.of("light-armor", "medium-armor", "shields", "simple-weapons", "martial-weapons")),
            Map.entry("ranger",    List.of("light-armor", "simple-weapons", "martial-weapons")),
            Map.entry("rogue",     List.of("light-armor", "thieves-tools")),
            Map.entry("warlock",   List.of("light-armor", "simple-weapons")),
            Map.entry("monk",      List.of("simple-weapons", "shortswords")),
            // Sorcerer y Wizard no otorgan ninguna proficiency al multiclasear (regla real).
            // Artificer (TCE p.10): armadura ligera + una herramienta de artesano a elegir (la
            // elección de herramienta no se automatiza, ver EXTRA_CHOICE_NOTES).
            Map.entry("artificer-erlw", List.of("light-armor")),
            Map.entry("artificer-tce",  List.of("light-armor")),
            // Blood Hunter: confirmado SOLO en dndbeyond.com/classes/357975-blood-hunter (no
            // corroborado en dnd5e.wikidot.com, que no publica una tabla de multiclase
            // separada) -- es prácticamente idéntico al set completo de nivel 1 de la clase
            // (le falta la elección de 2 skills). Fiabilidad menor que el resto de esta tabla
            // (PHB, verificada contra la API real); revisar si aparece una fuente mejor.
            Map.entry("blood-hunter", List.of("light-armor", "medium-armor", "shields",
                    "simple-weapons", "martial-weapons", "alchemists-supplies"))
    );

    // Elecciones de la tabla de multiclase que este mapa no automatiza (skill de la lista de
    // la clase, herramienta de artesano...) -- se comunican como aviso informativo.
    private static final Map<String, String> EXTRA_CHOICE_NOTES = Map.ofEntries(
            Map.entry("bard",   "one skill of your choice from its class skill list, and one musical instrument of your choice"),
            Map.entry("ranger", "one skill of your choice from its class skill list"),
            Map.entry("rogue",  "one skill of your choice from its class skill list"),
            Map.entry("artificer-erlw", "one type of artisan's tools of your choice"),
            Map.entry("artificer-tce",  "one type of artisan's tools of your choice")
    );

    /** Nunca lanza excepción: devuelve avisos informativos, no bloquea el level-up. */
    public List<String> checkAbilityScorePrerequisites(PlayerCharacter character, DndClass targetClass) {
        List<Map<String, Integer>> groups = ABILITY_PREREQS.get(indexNameOf(targetClass));
        if (groups == null) return List.of();

        boolean anyGroupSatisfied = groups.stream().anyMatch(group ->
                group.entrySet().stream().allMatch(e ->
                        character.getAbilityScores() != null
                                && character.getAbilityScores().getOrDefault(e.getKey(), 0) >= e.getValue()));

        if (anyGroupSatisfied) return List.of();
        return List.of("Warning: this character does not meet the standard multiclassing ability score "
                + "prerequisite for " + targetClass.getName() + " (non-blocking).");
    }

    /** Otorga el subconjunto reducido de proficiencies de multiclase; nunca duplica ni toca salvaciones. */
    public List<String> grantReducedProficiencies(PlayerCharacter character, DndClass targetClass) {
        List<String> messages = new ArrayList<>();
        String idx = indexNameOf(targetClass);

        List<String> profIndexNames = REDUCED_PROFICIENCIES.get(idx);
        if (profIndexNames != null) {
            for (String profIndexName : profIndexNames) {
                Proficiency prof = proficiencyRepository.findByIndexName(profIndexName).orElse(null);
                if (prof == null) {
                    messages.add("Note: proficiency catalog entry '" + profIndexName + "' not found, skipped.");
                    continue;
                }
                if (!characterProficiencyRepository.existsByCharacterAndProficiency(character, prof)) {
                    characterProficiencyRepository.save(new CharacterProficiency(character, prof, "MULTICLASS"));
                }
            }
        }

        String extraChoiceNote = EXTRA_CHOICE_NOTES.get(idx);
        if (extraChoiceNote != null) {
            messages.add("Note: " + targetClass.getName() + "'s multiclass proficiencies also include "
                    + extraChoiceNote + " — not applied automatically, choose it manually.");
        }

        return messages;
    }

    private String indexNameOf(DndClass dndClass) {
        return dndClass.getIndexName() != null ? dndClass.getIndexName().toLowerCase() : "";
    }
}
