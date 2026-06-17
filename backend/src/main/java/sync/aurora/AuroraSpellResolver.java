package sync.aurora;

import entities.Spell;
import org.springframework.stereotype.Service;
import repositories.SpellRepository;

import java.util.regex.Pattern;

/**
 * Resolves an Aurora spell grant ID (e.g. "ID_PHB_SPELL_THAUMATURGY") to a persisted Spell.
 *
 * Aurora-defined spells are stored with indexApi = their Aurora ID; spells synced from
 * dnd5eapi.co use the public API slug instead, so we fall back to deriving that slug from
 * the ID (e.g. "ID_PHB_SPELL_THAUMATURGY" -> "thaumaturgy").
 *
 * Shared by every Aurora mapper that processes &lt;grant type="Spell"&gt; rules
 * (class features, subclass features, feats, racial traits, ...).
 */
@Service
public class AuroraSpellResolver {

    private static final Pattern SPELL_ID_PREFIX = Pattern.compile("^.*_SPELL_");

    private final SpellRepository spellRepo;

    public AuroraSpellResolver(SpellRepository spellRepo) {
        this.spellRepo = spellRepo;
    }

    public Spell resolve(String auroraSpellId) {
        if (auroraSpellId == null) return null;

        return spellRepo.findByIndexApi(auroraSpellId).orElseGet(() -> {
            String slug = SPELL_ID_PREFIX.matcher(auroraSpellId).replaceFirst("")
                .toLowerCase()
                .replace('_', '-')
                .replace("'", "");
            return spellRepo.findByIndexApi(slug).orElse(null);
        });
    }
}
