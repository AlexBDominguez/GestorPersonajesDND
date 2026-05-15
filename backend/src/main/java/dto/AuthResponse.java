package dto;

public class AuthResponse {

    private String token;
    private String refreshToken;
    private String username;
    private String role; // "ADMIN" | "USER"

    public AuthResponse() {}

    public AuthResponse(String token, String refreshToken, String username, String role) {
        this.token        = token;
        this.refreshToken = refreshToken;
        this.username     = username;
        this.role         = role;
    }

    public String getToken()                       { return token; }
    public void   setToken(String token)           { this.token = token; }
    public String getRefreshToken()                { return refreshToken; }
    public void   setRefreshToken(String rt)       { this.refreshToken = rt; }
    public String getUsername()                    { return username; }
    public void   setUsername(String username)     { this.username = username; }
    public String getRole()                        { return role; }
    public void   setRole(String role)             { this.role = role; }
}
