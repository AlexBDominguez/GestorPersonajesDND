package sync;

import org.springframework.stereotype.Service;
import sync.aurora.*;

import java.time.Instant;
import java.util.*;

/**
 * Orchestrates fetching and indexing all Aurora Legacy Elements XML files from GitHub.
 * The registry stays in memory for the lifetime of the process; mappers read from it
 * when persisting individual content types to the database.
 */
@Service
public class AuroraSyncService {

    private final GitHubFileFetcher fetcher;
    private final AuroraXmlParser parser;
    private final AuroraRegistry registry;

    // Last-run stats (volatile for safe publication to status endpoint)
    private volatile String lastStatus = "Never run";
    private volatile Instant lastRun = null;
    private volatile int lastTotalElements = 0;
    private volatile int lastFilesFound = 0;
    private volatile int lastFilesProcessed = 0;
    private volatile int lastFilesErrored = 0;
    private volatile long lastDurationMs = 0;
    private volatile Map<String, Long> lastByType = Map.of();
    private volatile Map<String, Long> lastBySource = Map.of();

    public AuroraSyncService(GitHubFileFetcher fetcher, AuroraXmlParser parser, AuroraRegistry registry) {
        this.fetcher = fetcher;
        this.parser = parser;
        this.registry = registry;
    }

    /**
     * Fetches all .xml files from the AuroraLegacy/elements repository, parses them,
     * and indexes every element in the registry. Runs synchronously.
     */
    public synchronized Map<String, Object> fetchAndIndex() {
        long start = System.currentTimeMillis();
        lastStatus = "Running";
        registry.clear();

        int filesProcessed = 0;
        int filesErrored = 0;

        try {
            System.out.println("[Aurora] Listing XML files from GitHub...");
            List<String> xmlPaths = fetcher.listXmlFilePaths();
            lastFilesFound = xmlPaths.size();
            System.out.println("[Aurora] Found " + xmlPaths.size() + " XML files to process.");

            for (int i = 0; i < xmlPaths.size(); i++) {
                String path = xmlPaths.get(i);
                if (i > 0 && i % 50 == 0) {
                    System.out.printf("[Aurora] Progress: %d/%d files processed, %d elements indexed%n",
                        i, xmlPaths.size(), registry.size());
                }
                try {
                    String content = fetcher.fetchFileContent(path);
                    List<AuroraElement> elements = parser.parse(content);
                    elements.forEach(registry::register);
                    filesProcessed++;
                    Thread.sleep(100); // polite delay for raw.githubusercontent.com
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    lastStatus = "Interrupted";
                    break;
                } catch (Exception e) {
                    filesErrored++;
                    System.err.printf("[Aurora] Error fetching %s: %s%n", path, e.getMessage());
                }
            }

            lastDurationMs = System.currentTimeMillis() - start;
            lastFilesProcessed = filesProcessed;
            lastFilesErrored = filesErrored;
            lastTotalElements = registry.size();
            lastByType = registry.countByType();
            lastBySource = registry.countBySource();
            lastRun = Instant.now();
            if (!"Interrupted".equals(lastStatus)) lastStatus = "Completed";

            System.out.printf("[Aurora] Done: %d elements indexed from %d files in %.1fs%n",
                registry.size(), filesProcessed, lastDurationMs / 1000.0);

        } catch (Exception e) {
            lastStatus = "Failed: " + e.getMessage();
            lastDurationMs = System.currentTimeMillis() - start;
            lastRun = Instant.now();
            System.err.println("[Aurora] Sync failed: " + e.getMessage());
        }

        return buildResult();
    }

    public Map<String, Object> getStatus() {
        return buildResult();
    }

    public AuroraRegistry getRegistry() {
        return registry;
    }

    private Map<String, Object> buildResult() {
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("status", lastStatus);
        r.put("lastRun", lastRun != null ? lastRun.toString() : null);
        r.put("durationMs", lastDurationMs);
        r.put("filesFound", lastFilesFound);
        r.put("filesProcessed", lastFilesProcessed);
        r.put("filesErrored", lastFilesErrored);
        r.put("totalElements", lastTotalElements);
        r.put("byType", lastByType);
        r.put("bySource", lastBySource);
        return r;
    }
}
