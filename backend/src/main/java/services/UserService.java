package services;

import dto.CreateUserRequest;
import dto.UserDto;
import entities.User;
import enumeration.Role;
import repositories.PlayerCharacterRepository;
import repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private PlayerCharacterRepository characterRepository;

    public static final int MAX_CHARACTERS_PER_USER = 10;

    // Listar todos los usuarios
    public List<UserDto> getAllUsers() {
        return userRepository.findAll()
                .stream()
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
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("El nombre de usuario ya existe: " + request.getUsername());
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword())); // Hashear contraseña
        user.setRole(Role.USER); //admin never creates another admin from this endpoint
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

    //El propio usuario cambia su username.
    public UserDto changeOwnUsername(String currentUsername, String newUsername) {
        if (userRepository.existsByUsername(newUsername))
            throw new RuntimeException("Username already taken: " + newUsername);
        User user = userRepository.findByUsername(currentUsername)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setUsername(newUsername);
        return toDto(userRepository.save(user));
    }
    

    // Eliminar un usuario
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("Usuario no encontrado con id: " + id);
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