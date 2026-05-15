package controllers;

import dto.AuthResponse;
import dto.LoginRequest;
import dto.RefreshRequest;
import entities.User;
import repositories.UserRepository;
import security.JwtUtil;
import services.RefreshTokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired private AuthenticationManager authenticationManager;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private UserRepository userRepository;
    @Autowired private RefreshTokenService refreshTokenService;

    // ── Login ────────────────────────────────────────────────────────────────

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestBody LoginRequest loginRequest,
            @RequestHeader(value = "User-Agent", defaultValue = "Unknown") String userAgent) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()));

            String username = authentication.getName();

            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            if (!user.getActive()) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("User account is inactive. Please contact the administrator.");
            }

            user.setLastLogin(LocalDateTime.now());
            userRepository.save(user);

            String accessToken  = jwtUtil.generateToken(username);
            String refreshToken = refreshTokenService.generate(username, userAgent);

            return ResponseEntity.ok(new AuthResponse(
                    accessToken, refreshToken, user.getUsername(), user.getRole().name()));

        } catch (BadCredentialsException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Incorrect username or password");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Server error: " + e.getMessage());
        }
    }

    // ── Refresh ──────────────────────────────────────────────────────────────

    /**
     * Accepts a valid refresh token, rotates it (old one is revoked) and returns
     * a new access token + new refresh token.
     */
    @PostMapping("/refresh")
    public ResponseEntity<?> refresh(
            @RequestBody RefreshRequest request,
            @RequestHeader(value = "User-Agent", defaultValue = "Unknown") String userAgent) {
        try {
            String deviceInfo = request.getDeviceInfo() != null ? request.getDeviceInfo() : userAgent;
            RefreshTokenService.RotateResult result =
                    refreshTokenService.rotate(request.getRefreshToken(), deviceInfo);

            String accessToken = jwtUtil.generateToken(result.username());

            // Fetch user for role
            User user = userRepository.findByUsername(result.username())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            return ResponseEntity.ok(new AuthResponse(
                    accessToken, result.newRefreshToken(), user.getUsername(), user.getRole().name()));

        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Invalid or expired refresh token.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Server error: " + e.getMessage());
        }
    }

    // ── Logout ───────────────────────────────────────────────────────────────

    /**
     * Revokes the provided refresh token so it can never be used again.
     * Always returns 200 — even if the token is unknown/already revoked.
     */
    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestBody RefreshRequest request) {
        if (request.getRefreshToken() != null) {
            try {
                refreshTokenService.revoke(request.getRefreshToken());
            } catch (Exception ignored) {
                // Best-effort — client should clear local state regardless
            }
        }
        return ResponseEntity.ok().build();
    }
}
