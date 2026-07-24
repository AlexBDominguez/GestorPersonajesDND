package services;

import dto.AuthResponse;
import dto.CreateUserRequest;
import dto.UserDto;
import entities.User;
import enumeration.Role;
import repositories.PlayerCharacterRepository;
import repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import security.JwtUtil;

import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private PlayerCharacterRepository characterRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private RefreshTokenService refreshTokenService;

    public static final int MAX_CHARACTERS_PER_USER = 10;

    // Mismas restricciones de formato para alta de usuario (admin) y cambio de username
    // (propio) — 3-20 caracteres, solo letras/números/guion bajo. Antes solo se validaba
    // en el diálogo "Create User" del panel de admin (Flutter), nunca en el backend.
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-zA-Z0-9_]{3,20}$");

    private void validateUsernameFormat(String username) {
        if (username == null || !USERNAME_PATTERN.matcher(username).matches()) {
            throw new RuntimeException(
                    "Username must be 3-20 characters and contain only letters, numbers and underscores.");
        }
    }

    // Listar todos los usuarios (excluye admins)
    public List<UserDto> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .filter(u -> u.getRole() != Role.ADMIN)
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    // Obtener un usuario por ID
    public UserDto getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con id: " + id));
        return toDto(user);
    }

    public UserDto getUserByUsername(String username) {
        return toDto(userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found: " + username)));
    }

    // Crear un usuario nuevo (solo el admin puede hacerlo)
    public UserDto createUser(CreateUserRequest request) {
        validateUsernameFormat(request.getUsername());
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("El nombre de usuario ya existe: " + request.getUsername());
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword())); // Hashear contraseña
        user.setRole(Role.USER); // el admin no puede crear otro admin desde este endpoint
        user.setActive(true);

        return toDto(userRepository.save(user));
    }

    // Activar o desactivar un usuario
    public UserDto setUserActive(Long id, boolean active) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con id: " + id));
        user.setActive(active);
        return toDto(userRepository.save(user));
    }

    // Cambiar el rol de un usuario
    public UserDto changeUserRole(Long id, Role role) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con id: " + id));
        user.setRole(role);
        return toDto(userRepository.save(user));
    }

    // Admin resetea la contraseña de un usuario 
    public void resetPassword(Long id, String newPassword) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found: " + id));
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    // El propio usuario cambia su contraseña verificando la actual
    public void changeOwnPassword(String username, String currentPassword, String newPassword) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found: " + username));
        if(!passwordEncoder.matches(currentPassword, user.getPassword()))
            throw new RuntimeException("Current password is incorrect");
        if(newPassword.length() < 6)
            throw new RuntimeException("New password must be at least 6 characters.");
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    // El propio usuario cambia su username. El JWT lleva el username como subject y los
    // refresh tokens también lo guardan como string plano (ver RefreshToken.username) — así
    // que un simple rename dejaría la sesión activa (access token + refresh tokens) apuntando
    // a un username que ya no existe, y la siguiente petición autenticada fallaría con "user
    // not found" (el usuario se desconectaría sin previo aviso). Por eso esto revoca los
    // refresh tokens viejos y devuelve un AuthResponse con tokens nuevos, igual que
    // login/refresh, para que el cliente los sustituya de inmediato.
    public AuthResponse changeOwnUsername(String currentUsername, String newUsername, String deviceInfo) {
        validateUsernameFormat(newUsername);
        if (userRepository.existsByUsername(newUsername))
            throw new RuntimeException("Username already taken: " + newUsername);
        User user = userRepository.findByUsername(currentUsername)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setUsername(newUsername);
        userRepository.save(user);

        refreshTokenService.revokeAllForUser(currentUsername);
        String accessToken = jwtUtil.generateToken(newUsername);
        String refreshToken = refreshTokenService.generate(newUsername, deviceInfo);
        return new AuthResponse(accessToken, refreshToken, newUsername, user.getRole().name());
    }


    // Eliminar un usuario (no se puede eliminar un admin)
    public void deleteUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con id: " + id));
        if (user.getRole() == Role.ADMIN) {
            throw new RuntimeException("Admin accounts cannot be deleted.");
        }
        userRepository.deleteById(id);
    }

    //Verifica si el usuario alcanzó el límite de personajes.
    public boolean hasReachedCharacterLimit(String username) {
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("User not found"));
        long count = characterRepository.countByUser(user);
        return count >= MAX_CHARACTERS_PER_USER;
    }

    // Convertir entidad a DTO (NUNCA incluir la contraseña)
    private UserDto toDto(User user) {
        UserDto dto = new UserDto(
                user.getId(),
                user.getUsername(),
                user.getActive(),
                user.getRole());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setLastLogin(user.getLastLogin());
        int count = (int) characterRepository.countByUser(user);
        dto.setCharacterCount(count);
        return dto;
    }
}