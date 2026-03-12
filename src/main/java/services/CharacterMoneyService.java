package services;

import dto.CharacterMoneyDto;
import entities.CharacterMoney;
import entities.PlayerCharacter;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterMoneyRepository;
import repositories.PlayerCharacterRepository;

@Service
public class CharacterMoneyService {

    private final CharacterMoneyRepository moneyRepository;
    private final PlayerCharacterRepository characterRepository;

    public CharacterMoneyService(CharacterMoneyRepository moneyRepository,
                                 PlayerCharacterRepository characterRepository) {
        this.moneyRepository = moneyRepository;
        this.characterRepository = characterRepository;
    }

    public CharacterMoneyDto getCharacterMoney(Long characterId) {
        CharacterMoney money = moneyRepository.findByCharacterId(characterId)
                .orElse(null);

        if (money == null) {
            // Crear money si no existe
            PlayerCharacter character = characterRepository.findById(characterId)
                    .orElseThrow(() -> new RuntimeException("Character not found"));
            money = new CharacterMoney(character);
            moneyRepository.save(money);
        }

        return toDto(money);
    }

    @Transactional
    public CharacterMoneyDto addMoney(Long characterId, int platinum, int gold, int electrum, int silver, int copper) {
        CharacterMoney money = moneyRepository.findByCharacterId(characterId)
                .orElseGet(() -> {
                    PlayerCharacter character = characterRepository.findById(characterId)
                            .orElseThrow(() -> new RuntimeException("Character not found"));
                    return new CharacterMoney(character);
                });

        money.setPlatinum(money.getPlatinum() + platinum);
        money.setGold(money.getGold() + gold);
        money.setElectrum(money.getElectrum() + electrum);
        money.setSilver(money.getSilver() + silver);
        money.setCopper(money.getCopper() + copper);

        moneyRepository.save(money);
        return toDto(money);
    }

    @Transactional
    public CharacterMoneyDto subtractMoney(Long characterId, int platinum, int gold, int electrum, int silver, int copper) {
        CharacterMoney money = moneyRepository.findByCharacterId(characterId)
                .orElseThrow(() -> new RuntimeException("Character has no money record"));

        // Verificar que tenga suficiente
        if (money.getPlatinum() < platinum || money.getGold() < gold || 
            money.getElectrum() < electrum || money.getSilver() < silver || 
            money.getCopper() < copper) {
            throw new RuntimeException("Not enough money");
        }

        money.setPlatinum(money.getPlatinum() - platinum);
        money.setGold(money.getGold() - gold);
        money.setElectrum(money.getElectrum() - electrum);
        money.setSilver(money.getSilver() - silver);
        money.setCopper(money.getCopper() - copper);

        moneyRepository.save(money);
        return toDto(money);
    }

    @Transactional
    public CharacterMoneyDto setMoney(Long characterId, int platinum, int gold, int electrum, int silver, int copper) {
        CharacterMoney money = moneyRepository.findByCharacterId(characterId)
                .orElseGet(() -> {
                    PlayerCharacter character = characterRepository.findById(characterId)
                            .orElseThrow(() -> new RuntimeException("Character not found"));
                    return new CharacterMoney(character);
                });

        money.setPlatinum(platinum);
        money.setGold(gold);
        money.setElectrum(electrum);
        money.setSilver(silver);
        money.setCopper(copper);

        moneyRepository.save(money);
        return toDto(money);
    }

    private CharacterMoneyDto toDto(CharacterMoney money) {
        CharacterMoneyDto dto = new CharacterMoneyDto();
        dto.setId(money.getId());
        dto.setCharacterId(money.getCharacter().getId());
        dto.setCharacterName(money.getCharacter().getName());
        dto.setPlatinum(money.getPlatinum());
        dto.setGold(money.getGold());
        dto.setElectrum(money.getElectrum());
        dto.setSilver(money.getSilver());
        dto.setCopper(money.getCopper());
        dto.setTotalInGold(money.getTotalInGold());
        dto.setMoneyWeight(money.getMoneyWeight());
        return dto;
    }
}