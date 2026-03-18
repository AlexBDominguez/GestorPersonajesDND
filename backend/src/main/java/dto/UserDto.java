package dto;

import enumeration.Role;

public class UserDto {
    
    private Long id;
    private String username;
    private String email;
    private Boolean active;
    private Role role;

    public UserDto() {
    }

    public UserDto(Long id, String username, String email, Boolean active, Role role) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.active = active;
        this.role = role;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    
}
