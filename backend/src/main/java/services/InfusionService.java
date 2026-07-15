package services;

import entities.Infusion;
import entities.PlayerCharacter;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import repositories.InfusionRepository;

import java.util.LinkedHashSet;
import java.util.Set;

/**
 * Infuse Item (Artificiero, #8 — mayor gap del inventario, "sistema entero inexistente" per
 * Aurora_Fixes.md). Dos mitades: cuáles infusiones conoce el personaje (esta clase) y cuál
 * infusión lleva aplicada cada objeto (CharacterInventory.infusionIndexName, gestionado por
 * CharacterInventoryService al ser una operación de inventario, no de personaje).
 */
@Service
public class InfusionService {

    private static final int[] KNOWN_MILESTONE_LEVELS = {2, 6, 10, 14, 18};

    private final InfusionRepository infusionRepository;
    private final PendingChoiceService pendingChoiceService;
    private final CharacterFormulaService formulaService;

    public InfusionService(InfusionRepository infusionRepository,
                            PendingChoiceService pendingChoiceService,
                            CharacterFormulaService formulaService) {
        this.infusionRepository = infusionRepository;
        this.pendingChoiceService = pendingChoiceService;
        this.formulaService = formulaService;
    }

    // Nombres (no index_name) de las infusiones conocidas, combinando las hasta 5 tareas
    // INFUSION_CHOICE (una por hito de nivel: 2/6/10/14/18) -- mismo patrón que
    // CharacterSheetViewModel.knownRuneFeatures en el frontend.
    public Set<String> knownInfusionNames(PlayerCharacter character) {
        Set<String> names = new LinkedHashSet<>();
        for (int level : KNOWN_MILESTONE_LEVELS) {
            String resolved = pendingChoiceService.resolvedChoiceAtLevel(character, "INFUSION_CHOICE", level);
            if (resolved == null) continue;
            for (String n : resolved.split(",")) {
                String trimmed = n.trim();
                if (!trimmed.isEmpty()) names.add(trimmed);
            }
        }
        return names;
    }

    public int maxInfusedItems(PlayerCharacter character) {
        return formulaService.evaluate(character, "artificer_infusions_active_table");
    }

    // Valida que el personaje conoce esta infusión (por nombre, tal y como se guardó en la
    // elección resuelta) y que su nivel actual la permite, y devuelve la fila del catálogo.
    // Lanza 404/409 si no -- usado por CharacterInventoryService.applyInfusion().
    public Infusion requireKnownInfusion(PlayerCharacter character, String infusionName) {
        boolean known = knownInfusionNames(character).stream()
                .anyMatch(n -> n.equalsIgnoreCase(infusionName));
        if (!known) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "\"" + infusionName + "\" is not one of this character's known infusions");
        }
        Infusion infusion = infusionRepository.findByIndexName(toIndexName(infusionName))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Unknown infusion: " + infusionName));
        if (character.getLevel() < infusion.getMinLevel()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    infusion.getName() + " requires artificer level " + infusion.getMinLevel());
        }
        return infusion;
    }

    // Mismo slug usado al sembrar Infusion.indexName -- ver
    // backend/scripts/patch_infusions_seed.sql y frontend kArtificerInfusions.
    public static String toIndexName(String infusionName) {
        return infusionName.toLowerCase().trim()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-+|-+$)", "");
    }
}
