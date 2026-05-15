package entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "refresh_tokens",
    indexes = {
        @Index(name = "idx_rt_token_hash", columnList = "token_hash"),
        @Index(name = "idx_rt_username",   columnList = "username")
    })
public class RefreshToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** SHA-256 hex of the raw token — never store the raw value in DB. */
    @Column(name = "token_hash", nullable = false, unique = true, length = 64)
    private String tokenHash;

    @Column(nullable = false, length = 50)
    private String username;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(nullable = false)
    private Boolean revoked = false;

    /** Browser / device hint — informational only. */
    @Column(name = "device_info", length = 255)
    private String deviceInfo;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    // ── Getters & Setters ────────────────────────────────────────────────────

    public Long getId()                            { return id; }
    public String getTokenHash()                   { return tokenHash; }
    public void   setTokenHash(String tokenHash)   { this.tokenHash = tokenHash; }
    public String getUsername()                    { return username; }
    public void   setUsername(String username)     { this.username = username; }
    public LocalDateTime getExpiresAt()            { return expiresAt; }
    public void   setExpiresAt(LocalDateTime t)    { this.expiresAt = t; }
    public Boolean getRevoked()                    { return revoked; }
    public void   setRevoked(Boolean revoked)      { this.revoked = revoked; }
    public String getDeviceInfo()                  { return deviceInfo; }
    public void   setDeviceInfo(String deviceInfo) { this.deviceInfo = deviceInfo; }
    public LocalDateTime getCreatedAt()            { return createdAt; }
}
