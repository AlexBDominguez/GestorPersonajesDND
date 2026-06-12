package services;

import dto.ContentSourceDto;
import entities.ContentSource;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;
import repositories.ContentSourceRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ContentSourceService {

    private final ContentSourceRepository repository;

    public ContentSourceService(ContentSourceRepository repository) {
        this.repository = repository;
    }

    @PostConstruct
    public void seedContentSources() {
        seedIfAbsent("PHB",  "Player's Handbook",                   "Core D&D 5e rulebook (2014). Always active.", true);
        seedIfAbsent("XGtE", "Xanathar's Guide to Everything",      "First major supplement with new subclasses, spells and more.", false);
        seedIfAbsent("TCE",  "Tasha's Cauldron of Everything",      "Expanded subclasses, optional class features and more.", false);
        seedIfAbsent("MToF", "Mordenkainen's Tome of Foes",         "New races and monsters from across the planes.", false);
        seedIfAbsent("VGtM", "Volo's Guide to Monsters",            "Monster races and lore for players and DMs.", false);
        seedIfAbsent("SCAG", "Sword Coast Adventurer's Guide",      "Faerûn-specific subclasses, backgrounds and setting lore.", false);
        seedIfAbsent("EGtW", "Explorer's Guide to Wildemount",      "Critical Role setting with Chronurgy and Graviturgy.", false);
        seedIfAbsent("GGtR", "Guildmasters' Guide to Ravnica",      "Magic: The Gathering crossover — Ravnica setting content.", false);
        seedIfAbsent("MOT",  "Mythic Odysseys of Theros",           "Ancient Greek-inspired setting races and subclasses.", false);
        seedIfAbsent("FToD", "Fizban's Treasury of Dragons",        "Draconic subclasses, spells and dragon lore.", false);
        seedIfAbsent("SCoC", "Strixhaven: A Curriculum of Chaos",   "Magic academy setting with new backgrounds and spells.", false);
        seedIfAbsent("ERLW",  "Eberron: Rising from the Last War",   "Eberron setting — Warforged, Shifter, Changeling, Kalashtar and more.", false);
        seedIfAbsent("AI",    "Acquisitions Incorporated",            "Humorous campaign setting — includes the Verdan race.", false);
        seedIfAbsent("IDRotF","Icewind Dale: Rime of the Frostmaiden","2020 adventure setting with additional player options.", false);
        seedIfAbsent("VRGtR", "Van Richten's Guide to Ravenloft",    "Gothic horror setting — Dhampir, Hexblood and Reborn lineages.", false);
        seedIfAbsent("WBtW",  "The Wild Beyond the Witchlight",      "2021 Feywild adventure — Fairy and Harengon races.", false);
        seedIfAbsent("CR",    "Critical Role (Homebrew)",             "Contenido de Matt Mercer: Blood Hunter, Gunslinger y más.", false);
    }

    private void seedIfAbsent(String shortName, String fullName, String description, boolean isBase) {
        if (!repository.existsByShortName(shortName)) {
            repository.save(new ContentSource(shortName, fullName, description, isBase));
        }
    }

    public List<ContentSourceDto> getAll() {
        return repository.findAllByOrderByIsBaseDescShortNameAsc()
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    private ContentSourceDto toDto(ContentSource cs) {
        ContentSourceDto dto = new ContentSourceDto();
        dto.setId(cs.getId());
        dto.setShortName(cs.getShortName());
        dto.setFullName(cs.getFullName());
        dto.setDescription(cs.getDescription());
        dto.setBase(cs.isBase());
        return dto;
    }
}
