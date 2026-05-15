package services;

import entities.RefreshToken;
import repositories.RefreshTokenRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;

@Service
public class RefreshTokenService {

    private final RefreshTokenRepository repo;

    @Value("${jwt.refresh.expiration:2592000000}")
    private long refreshExpirationMs; // default: 30 days

    private static final SecureRandom RANDOM = new SecureRandom();

    public RefreshTokenService(RefreshTokenRepository repo) {
        this.repo = repo;
    }

    /**
     * Creates a new refresh token for {@code username}, persists its SHA-256 hash,
     * and returns the raw (plain-text) token that must be sent to the client.
     */
    @Transactional
    public String generate(String username, String deviceInfo) {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String rawToken = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);

        RefreshToken rt = new RefreshToken();
        rt.setTokenHash(sha256(rawToken));
        rt.setUsername(username);
        rt.setExpiresAt(LocalDateTime.now().plusSeconds(refreshExpirationMs / 1000));
        rt.setRevoked(false);
        rt.setDeviceInfo(deviceInfo);
        repo.save(rt);

        return rawToken;
    }

    /**
     * Validates {@code rawToken}, revokes it, and returns a fresh replacement
     * token together with the owning username (token rotation).
     *
     * <p>If a <em>previously revoked</em> token is presented we assume possible
     * theft and revoke <strong>all</strong> tokens for that user.</p>
     */
    @Transactional
    public RotateResult rotate(String rawToken, String deviceInfo) {
        String hash = sha256(rawToken);

        RefreshToken rt = repo.findByTokenHash(hash)
                .orElseThrow(() -> new RuntimeException("INVALID_REFRESH_TOKEN"));

        if (Boolean.TRUE.equals(rt.getRevoked())) {
            // Possible token-reuse attack — revoke every token for this user
            repo.revokeAllByUsername(rt.getUsername());
            throw new RuntimeException("REFRESH_TOKEN_REVOKED");
        }

        if (rt.getExpiresAt().isBefore(LocalDateTime.now())) {
            rt.setRevoked(true);
            repo.save(rt);
            throw new RuntimeException("REFRESH_TOKEN_EXPIRED");
        }

        // Rotate: mark old as revoked, issue a brand-new one
        rt.setRevoked(true);
        repo.save(rt);

        String newRawToken = generate(rt.getUsername(), deviceInfo);
        return new RotateResult(rt.getUsername(), newRawToken);
    }

    /** Revokes a single refresh token (called on explicit logout). */
    @Transactional
    public void revoke(String rawToken) {
        String hash = sha256(rawToken);
        repo.findByTokenHash(hash).ifPresent(rt -> {
            rt.setRevoked(true);
            repo.save(rt);
        });
    }

    /** Nightly cleanup at 03:00 — removes expired and revoked rows. */
    @Scheduled(cron = "0 0 3 * * *")
    @Transactional
    public void cleanup() {
        repo.deleteExpiredAndRevoked(LocalDateTime.now());
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(64);
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }

    public record RotateResult(String username, String newRefreshToken) {}
}
