package controllers;

import dto.CreateUserRequest;
import dto.UserDto;
import enumeration.Role;
import services.UserService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
public class UserController {

    @Autowired
    private UserService userService;


    // -- Admin endpoints (/api/admin/users) --

    // GET /api/admin/users -> listar todos los usuarios
    @GetMapping("/api/admin/users")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UserDto>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    // GET /api/admin/users/{id} -> obtener un usuario por ID
    @GetMapping("/api/admin/users/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserDto> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }

    // POST /api/admin/users -> crear un usuario nuevo
    @PostMapping("/api/admin/users")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserDto> createUser(@RequestBody CreateUserRequest request) {
        UserDto created = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // PATCH /api/admin/users/{id}/activate -> activar usuario
    @PatchMapping("/api/admin/users/{id}/activate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserDto> activateUser(@PathVariable Long id) {
        return ResponseEntity.ok(userService.setUserActive(id, true));
    }

    // PATCH /api/admin/users/{id}/deactivate -> desactivar usuario
    @PatchMapping("/api/admin/users/{id}/deactivate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserDto> deactivateUser(@PathVariable Long id) {
        return ResponseEntity.ok(userService.setUserActive(id, false));
    }

    // PATCH /api/admin/users/{id}/role -> cambiar rol
    @PatchMapping("/api/admin/users/{id}/role")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserDto> changeRole(@PathVariable Long id, @RequestParam Role role) {
        return ResponseEntity.ok(userService.changeUserRole(id, role));
    }

    // PATCH /api/admin/users/{id}/reset-password -> resetear contraseña
    @PatchMapping("/api/admin/users/{id}/reset-password")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> resetPassword(
        @PathVariable Long id,
        @RequestBody Map<String, String> body) {
            String newPassword = body.get("newPassword");
            if(newPassword == null || newPassword.length() < 6)
                return ResponseEntity.badRequest().build();
            userService.resetPassword(id, newPassword);
            return ResponseEntity.noContent().build();
        }
    

    // DELETE /api/admin/users/{id} -> eliminar usuario
    @DeleteMapping("/api/admin/users/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    // -- Self-service endpoints (/api/users/me) --

    // GET /api/users/me -> datos del usuario actual
    @GetMapping("/api/users/me")
    public ResponseEntity<UserDto> getMe(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(userService.getUserByUsername(userDetails.getUsername()));
    }

    // PATCH /api/users/me/pasword -> cambiar propia contraseña
    @PatchMapping("/api/users/me/password")
    public ResponseEntity<?> changePassword(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody Map<String, String> body) {
        String current = body.get("currentPassword");
        String newPw = body.get("newPassword");
        if(current == null || newPw == null)
            return ResponseEntity.badRequest().body("currentPassword and newPassword are required");
        try {
            userService.changeOwnPassword(userDetails.getUsername(), current, newPw);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }    
    }

    // Patch /api/users/me/username -> cambiar propio username
    @PatchMapping("/api/users/me/username")
    public ResponseEntity<?> changeUsername(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody Map<String, String> body) {
        String newUsername = body.get("newUsername");
        if(newUsername == null || newUsername.isBlank())
            return ResponseEntity.badRequest().body("newUsername is required");
        try {
            UserDto updated = userService.changeOwnUsername(userDetails.getUsername(),
                newUsername);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
}