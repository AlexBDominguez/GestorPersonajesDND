package controllers;

import dto.AuthResponse;
import dto.LoginRequest;
import entities.User;
import repositories.UserRepository;
import security.JwtUtil;
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
@CrossOrigin(origins = "*") // Permitir CORS para todas las fuentes (ajustar según necesidades)
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            // Autenticar usuario con Spring Security
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()
                    )
            );

            // Si llega aquí, la autenticación fue exitosa
            String username = authentication.getName();
            String token = jwtUtil.generateToken(username);

            // Actualizar lastLogin
            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("User not found"));

                //Bloquear acceso a usuarios inactivos
                if (!user.getActive()){
                    return ResponseEntity.status(HttpStatus.FORBIDDEN)
                            .body("User account is inactive. Please contact the administrator.");
                }

            user.setLastLogin(LocalDateTime.now());
            userRepository.save(user);

            // Retornar token y datos del usuario
            AuthResponse response = new AuthResponse(
                token, 
                user.getUsername(), 
                user.getRole().name()
            );
            return ResponseEntity.ok(response);

        } catch (BadCredentialsException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Incorrect username or password");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Server error: " + e.getMessage());
        }
    }
}