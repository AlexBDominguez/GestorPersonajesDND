package sync.aurora;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class GitHubFileFetcher {

    private static final String REPO_OWNER = "AuroraLegacy";
    private static final String REPO_NAME = "elements";
    private static final String BRANCH = "master";
    private static final String TREE_URL =
        "https://api.github.com/repos/" + REPO_OWNER + "/" + REPO_NAME + "/git/trees/" + BRANCH + "?recursive=1";
    private static final String RAW_BASE =
        "https://raw.githubusercontent.com/" + REPO_OWNER + "/" + REPO_NAME + "/" + BRANCH + "/";

    @Value("${aurora.github.token:}")
    private String githubToken;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Calls the GitHub tree API (1 request) and returns the paths of all .xml files.
     * Uses raw.githubusercontent.com for file content to avoid API rate limits.
     */
    @SuppressWarnings("unchecked")
    public List<String> listXmlFilePaths() {
        HttpEntity<Void> entity = new HttpEntity<>(apiHeaders());
        ResponseEntity<Map> response = restTemplate.exchange(TREE_URL, HttpMethod.GET, entity, Map.class);

        Map<String, Object> body = response.getBody();
        if (body == null) return List.of();

        if (Boolean.TRUE.equals(body.get("truncated"))) {
            System.out.println("[Aurora] WARNING: GitHub tree response was truncated — some files may be missing.");
        }

        List<Map<String, Object>> tree = (List<Map<String, Object>>) body.get("tree");
        if (tree == null) return List.of();

        List<String> xmlPaths = new ArrayList<>();
        for (Map<String, Object> entry : tree) {
            String path = (String) entry.get("path");
            String type = (String) entry.get("type");
            if ("blob".equals(type) && path != null && path.endsWith(".xml")) {
                xmlPaths.add(path);
            }
        }
        return xmlPaths;
    }

    /**
     * Fetches the raw content of a single file from raw.githubusercontent.com.
     * This endpoint has much higher rate limits than api.github.com.
     */
    public String fetchFileContent(String path) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("User-Agent", "DungeonScroll/1.0");
        headers.setAccept(List.of(MediaType.TEXT_PLAIN, MediaType.ALL));
        if (githubToken != null && !githubToken.isBlank()) {
            headers.set("Authorization", "Bearer " + githubToken);
        }
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<String> response = restTemplate.exchange(RAW_BASE + path, HttpMethod.GET, entity, String.class);
        return response.getBody() != null ? response.getBody() : "";
    }

    private HttpHeaders apiHeaders() {
        HttpHeaders h = new HttpHeaders();
        h.set("User-Agent", "DungeonScroll/1.0");
        h.set("Accept", "application/vnd.github+json");
        if (githubToken != null && !githubToken.isBlank()) {
            h.set("Authorization", "Bearer " + githubToken);
        }
        return h;
    }
}
