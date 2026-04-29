package dto;

import enumeration.Role;

public class CreateUserRequest {

    private String username;
    private String password;
    private Role role = Role.USER;
    //Por defecto, el rol es USER. Solo un ADMIN puede cambiarlo al crear un nuevo usuario.

    public CreateUserRequest() {
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    

    
}
