package sync.aurora;

import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * In-memory index of all parsed Aurora elements, keyed by their Aurora ID.
 * Used by mappers to resolve cross-references (e.g. a Race grants a Racial Trait by ID).
 */
@Service
public class AuroraRegistry {

    private final Map<String, AuroraElement> byId = new ConcurrentHashMap<>();

    public void clear() {
        byId.clear();
    }

    public void register(AuroraElement element) {
        byId.put(element.getId(), element);
    }

    public Optional<AuroraElement> resolve(String id) {
        return Optional.ofNullable(byId.get(id));
    }

    /** Returns all elements of a given Aurora type (case-insensitive). */
    public List<AuroraElement> getByType(String type) {
        return byId.values().stream()
            .filter(e -> type.equalsIgnoreCase(e.getType()))
            .collect(Collectors.toList());
    }

    /** Returns all elements whose source maps to a given short name (e.g. "XGtE"). */
    public List<AuroraElement> getBySourceShortName(String shortName) {
        return byId.values().stream()
            .filter(e -> shortName.equals(AuroraSourceMapper.toShortName(e.getSource())))
            .collect(Collectors.toList());
    }

    public Map<String, Long> countByType() {
        return byId.values().stream()
            .collect(Collectors.groupingBy(AuroraElement::getType, Collectors.counting()))
            .entrySet().stream()
            .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
            .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue,
                (a, b) -> a, LinkedHashMap::new));
    }

    public Map<String, Long> countBySource() {
        return byId.values().stream()
            .collect(Collectors.groupingBy(
                e -> AuroraSourceMapper.toShortName(e.getSource()),
                Collectors.counting()))
            .entrySet().stream()
            .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
            .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue,
                (a, b) -> a, LinkedHashMap::new));
    }

    public int size() {
        return byId.size();
    }

    public boolean isEmpty() {
        return byId.isEmpty();
    }
}
