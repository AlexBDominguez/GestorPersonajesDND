package sync.aurora;

import java.util.Map;

public class AuroraSourceMapper {

    private static final Map<String, String> FULL_TO_SHORT = Map.ofEntries(
        Map.entry("Player's Handbook", "PHB"),
        Map.entry("Dungeon Master's Guide", "DMG"),
        Map.entry("Monster Manual", "MM"),
        Map.entry("Xanathar's Guide to Everything", "XGtE"),
        Map.entry("Tasha's Cauldron of Everything", "TCE"),
        Map.entry("Mordenkainen's Tome of Foes", "MToF"),
        Map.entry("Volo's Guide to Monsters", "VGtM"),
        Map.entry("Sword Coast Adventurer's Guide", "SCAG"),
        Map.entry("Explorer's Guide to Wildemount", "EGtW"),
        Map.entry("Guildmasters' Guide to Ravnica", "GGtR"),
        Map.entry("Mythic Odysseys of Theros", "MOT"),
        Map.entry("Fizban's Treasury of Dragons", "FToD"),
        Map.entry("Strixhaven: A Curriculum of Chaos", "SCoC"),
        Map.entry("Elemental Evil Player's Companion", "EEPC"),
        Map.entry("The Tortle Package", "TTP"),
        Map.entry("Acquisitions Incorporated", "AI"),
        Map.entry("Eberron: Rising from the Last War", "ERLW"),
        Map.entry("Icewind Dale: Rime of the Frostmaiden", "IDRotF"),
        Map.entry("Van Richten's Guide to Ravenloft", "VRGtR"),
        Map.entry("The Wild Beyond the Witchlight", "WBtW"),
        Map.entry("Spelljammer: Adventures in Space", "SJA"),
        Map.entry("Dragonlance: Shadow of the Dragon Queen", "DSotDQ"),
        Map.entry("Bigby Presents: Glory of the Giants", "BGotG"),
        Map.entry("Phandelver and Below: The Shattered Obelisk", "PaBTSO"),
        Map.entry("Planescape: Adventures in the Multiverse", "PAtM"),
        Map.entry("Ghosts of Saltmarsh", "GoS"),
        Map.entry("Princes of the Apocalypse", "PotA"),
        Map.entry("Waterdeep: Dragon Heist", "WDH"),
        Map.entry("Baldur's Gate: Descent into Avernus", "BGDIA"),
        Map.entry("Curse of Strahd", "CoS"),
        Map.entry("Keys from the Golden Vault", "KftGV")
    );

    public static String toShortName(String fullName) {
        if (fullName == null || fullName.isBlank()) return "UNKNOWN";
        String mapped = FULL_TO_SHORT.get(fullName.trim());
        if (mapped != null) return mapped;
        // Fallback: extract uppercase letters as acronym
        String acronym = fullName.replaceAll("[^A-Z]", "");
        return acronym.isEmpty() ? fullName.trim() : acronym;
    }

    public static boolean isKnownSource(String fullName) {
        return fullName != null && FULL_TO_SHORT.containsKey(fullName.trim());
    }
}
