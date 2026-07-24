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
    private long refreshExpirationMs; // por defecto: 30 días

    private static final SecureRandom RANDOM = new SecureRandom();

    public RefreshTokenService(RefreshTokenRepository repo) {
        this.repo = repo;
    }

    /**
     * Crea un nuevo refresh token para {@code username}, persiste su hash SHA-256
     * y devuelve el token en texto plano que debe enviarse al cliente.
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
     * Valida {@code rawToken}, lo revoca y devuelve un token de reemplazo
     * junto con el nombre de usuario propietario (rotación de tokens).
     *
     * <p>Si se presenta un token <em>previamente revocado</em>, se asume un posible
     * robo y se revocan <strong>todos</strong> los tokens de ese usuario.</p>
     */
    @Transactional
    public RotateResult rotate(String rawToken, String deviceInfo) {
        String hash = sha256(rawToken);

        RefreshToken rt = repo.findByTokenHash(hash)
                .orElseThrow(() -> new RuntimeException("INVALID_REFRESH_TOKEN"));

        if (Boolean.TRUE.equals(rt.getRevoked())) {
            // Posible ataque de reutilización de token — revocar todos los tokens del usuario
            repo.revokeAllByUsername(rt.getUsername());
            throw new RuntimeException("REFRESH_TOKEN_REVOKED");
        }

        if (rt.getExpiresAt().isBefore(LocalDateTime.now())) {
            rt.setRevoked(true);
            repo.save(rt);
            throw new RuntimeException("REFRESH_TOKEN_EXPIRED");
        }

        // Rotación: marcar el token anterior como revocado y emitir uno nuevo
        rt.setRevoked(true);
        repo.save(rt);

        String newRawToken = generate(rt.getUsername(), deviceInfo);
        return new RotateResult(rt.getUsername(), newRawToken);
    }

    /** Revoca un único refresh token (se llama al cerrar sesión explícitamente). */
    @Transactional
    public void revoke(String rawToken) {
        String hash = sha256(rawToken);
        repo.findByTokenHash(hash).ifPresent(rt -> {
            rt.setRevoked(true);
            repo.save(rt);
        });
    }

    /**
     * Revoca todos los refresh tokens de {@code username} — usado al cambiar el propio
     * username (#15): los tokens ya emitidos llevan el username VIEJO, así que quedarían
     * huérfanos (ya no resuelven a ningún usuario real) si no se revocan explícitamente.
     */
    @Transactional
    public void revokeAllForUser(String username) {
        repo.revokeAllByUsername(username);
    }

    /** Limpieza nocturna a las 03:00 — elimina filas caducadas y revocadas. */
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
