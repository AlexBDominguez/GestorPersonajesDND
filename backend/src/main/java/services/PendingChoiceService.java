package services;

import entities.PlayerCharacter;
import org.springframework.stereotype.Service;
import repositories.PendingTaskRepository;

/**
 * Shared helper for reading a character's resolved wizard/level-up choices from PendingTask —
 * used to gate NUMERIC_BONUS and RESOURCE_POOL rows on "does this character have option X from
 * choice Y" (e.g. Fighting Style: Defense, Agonizing Blast among Eldritch Invocations, Cloud
 * Rune among Runes Known). Extracted from NumericBonusService once CharacterClassResourceService
 * needed the exact same multi-choice check for Rune Knight (#8.2) instead of duplicating it a
 * third time.
 */
@Service
public class PendingChoiceService {

    private final PendingTaskRepository pendingTaskRepository;

    public PendingChoiceService(PendingTaskRepository pendingTaskRepository) {
        this.pendingTaskRepository = pendingTaskRepository;
    }

    /** Extrae el valor "choice" del metadata JSON de una tarea. Formato: {"choice":"Black",...} */
    public String extractChoiceFromMetadata(String metadata) {
        if (metadata == null) return null;
        int idx = metadata.indexOf("\"choice\":\"");
        if (idx == -1) return null;
        int start = idx + 10;
        int end = metadata.indexOf("\"", start);
        return (end > start) ? metadata.substring(start, end) : null;
    }

    /** Primer valor resuelto de una tarea de elección única de este tipo (p.ej. FIGHTING_STYLE,
     *  DRACONIC_ANCESTRY), o null si no hay ninguna completada. */
    public String resolvedSingleChoice(PlayerCharacter character, String taskType) {
        return pendingTaskRepository.findByCharacterAndCompleted(character, true).stream()
                .filter(t -> taskType.equals(t.getTaskType()) && t.getMetadata() != null)
                .map(t -> extractChoiceFromMetadata(t.getMetadata()))
                .filter(choice -> choice != null)
                .findFirst()
                .orElse(null);
    }

    /** Valor resuelto de la tarea de este tipo en un nivel concreto, o null. A diferencia de
     *  resolvedSingleChoice (primer resultado de cualquier nivel), esto es para elecciones que
     *  se repiten en varios hitos de nivel (p.ej. INFUSION_CHOICE en 2/6/10/14/18) donde hay que
     *  combinar el resultado de cada hito por separado -- mismo patrón que
     *  CharacterSheetViewModel.knownRuneFeatures usa en el frontend vía resolvedChoiceFor. */
    public String resolvedChoiceAtLevel(PlayerCharacter character, String taskType, int level) {
        return pendingTaskRepository.findByCharacterAndCompleted(character, true).stream()
                .filter(t -> taskType.equals(t.getTaskType()) && t.getRelatedLevel() == level
                        && t.getMetadata() != null)
                .map(t -> extractChoiceFromMetadata(t.getMetadata()))
                .filter(choice -> choice != null)
                .findFirst()
                .orElse(null);
    }

    /** true si alguna tarea completada de ese tipo tiene requiredValue exacto entre sus
     *  elecciones separadas por comas (p.ej. Eldritch Invocations, Runes Known -- mismo formato
     *  comma-separated que usan Battle Master Maneuvers). */
    public boolean hasMultiChoiceValue(PlayerCharacter character, String taskType, String requiredValue) {
        return pendingTaskRepository.findByCharacterAndCompleted(character, true).stream()
                .filter(t -> taskType.equals(t.getTaskType()) && t.getMetadata() != null)
                .map(t -> extractChoiceFromMetadata(t.getMetadata()))
                .filter(choice -> choice != null)
                .anyMatch(choice -> java.util.Arrays.stream(choice.split(","))
                        .anyMatch(v -> v.trim().equalsIgnoreCase(requiredValue)));
    }

    /** condition con formato "HAS_MULTI_CHOICE:<taskType>:<valor requerido>". */
    public boolean matchesMultiChoiceCondition(PlayerCharacter character, String condition) {
        if (condition == null || !condition.startsWith("HAS_MULTI_CHOICE:")) return false;
        String[] parts = condition.substring("HAS_MULTI_CHOICE:".length()).split(":", 2);
        if (parts.length != 2) return false;
        return hasMultiChoiceValue(character, parts[0], parts[1]);
    }

    /** condition con formato "HAS_SINGLE_CHOICE:<taskType>:<valor requerido>" (p.ej. Fighting
     *  Style). Ignora cualquier sufijo ";ALGO" -- el llamador se encarga de esas condiciones
     *  extra (p.ej. ";REQUIRES_ARMOR" en Fighting Style: Defense). */
    public boolean matchesSingleChoiceCondition(PlayerCharacter character, String condition) {
        if (condition == null) return false;
        String base = condition.split(";")[0];
        if (!base.startsWith("HAS_SINGLE_CHOICE:")) return false;
        String[] parts = base.substring("HAS_SINGLE_CHOICE:".length()).split(":", 2);
        if (parts.length != 2) return false;
        String resolved = resolvedSingleChoice(character, parts[0]);
        return parts[1].equalsIgnoreCase(resolved);
    }
}
