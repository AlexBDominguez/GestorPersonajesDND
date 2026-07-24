package services;

import dto.RacialTraitAdminRequest;
import dto.RacialTraitDto;
import entities.NumericBonus;
import entities.Proficiency;
import entities.Race;
import entities.RaceResource;
import entities.RacialTrait;
import entities.RacialTraitProficiency;
import entities.RacialTraitSpell;
import entities.Spell;
import entities.Subrace;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import repositories.NumericBonusRepository;
import repositories.ProficiencyRepository;
import repositories.RaceRepository;
import repositories.RaceResourceRepository;
import repositories.RacialTraitProficiencyRepository;
import repositories.RacialTraitRepository;
import repositories.RacialTraitSpellRepository;
import repositories.SpellRepository;
import repositories.SubraceRepository;

/**
 * #9: crea un RacialTrait junto con la fila de mecánica que le corresponda (#8.2, generalizado
 * a razas) y lo adjunta a la Race o Subrace elegida, en una sola transacción. Mirrors
 * AdminSubclassFeatureService.
 *
 * GRANT_SPELL usa RacialTraitSpell (mirrors SubclassSpell/ClassSpell, con su propio
 * requiredLevel) en vez de Race.grantedSpells -- va atado al trait mismo, no a la raza, así
 * que funciona igual para traits de Race y de Subrace sin ninguna limitación.
 *
 * RESOURCE_POOL para razas no tiene gating por nivel (a diferencia de RESOURCE_POOL de clase/
 * subclase) porque race_traits/subrace_traits no tienen columna de nivel -- ver RacialTrait.java.
 */
@Service
public class AdminRacialTraitService {

    private final RaceRepository raceRepository;
    private final SubraceRepository subraceRepository;
    private final RacialTraitRepository racialTraitRepository;
    private final RaceResourceRepository raceResourceRepository;
    private final NumericBonusRepository numericBonusRepository;
    private final RacialTraitProficiencyRepository racialTraitProficiencyRepository;
    private final RacialTraitSpellRepository racialTraitSpellRepository;
    private final SpellRepository spellRepository;
    private final ProficiencyRepository proficiencyRepository;

    public AdminRacialTraitService(RaceRepository raceRepository,
                                   SubraceRepository subraceRepository,
                                   RacialTraitRepository racialTraitRepository,
                                   RaceResourceRepository raceResourceRepository,
                                   NumericBonusRepository numericBonusRepository,
                                   RacialTraitProficiencyRepository racialTraitProficiencyRepository,
                                   RacialTraitSpellRepository racialTraitSpellRepository,
                                   SpellRepository spellRepository,
                                   ProficiencyRepository proficiencyRepository) {
        this.raceRepository = raceRepository;
        this.subraceRepository = subraceRepository;
        this.racialTraitRepository = racialTraitRepository;
        this.raceResourceRepository = raceResourceRepository;
        this.numericBonusRepository = numericBonusRepository;
        this.racialTraitProficiencyRepository = racialTraitProficiencyRepository;
        this.racialTraitSpellRepository = racialTraitSpellRepository;
        this.spellRepository = spellRepository;
        this.proficiencyRepository = proficiencyRepository;
    }

    @Transactional
    public RacialTraitDto create(RacialTraitAdminRequest req) {
        if (req.getIndexName() == null || req.getIndexName().isBlank()) {
            throw new RuntimeException("indexName is required");
        }
        if (racialTraitRepository.findByIndexName(req.getIndexName()).isPresent()) {
            throw new RuntimeException("A trait with indexName '" + req.getIndexName() + "' already exists");
        }

        boolean isRace = "RACE".equalsIgnoreCase(req.getTargetType());
        Race race = null;
        Subrace subrace = null;
        if (isRace) {
            race = raceRepository.findById(req.getTargetId())
                    .orElseThrow(() -> new RuntimeException("Race not found: " + req.getTargetId()));
        } else {
            subrace = subraceRepository.findById(req.getTargetId())
                    .orElseThrow(() -> new RuntimeException("Subrace not found: " + req.getTargetId()));
        }

        RacialTrait trait = new RacialTrait();
        trait.setIndexName(req.getIndexName());
        trait.setName(req.getName());
        trait.setDescription(req.getDescription());
        trait.setTraitType(req.getTraitType() != null ? req.getTraitType() : "PASSIVE");

        Spell pendingSpellGrant = null;

        String mechanic = req.getMechanicType() == null ? "NONE" : req.getMechanicType();
        switch (mechanic) {
            case "RESOURCE_POOL" -> {
                if (raceResourceRepository.findByIndexName(req.getIndexName()).isPresent()) {
                    throw new RuntimeException(
                            "A race resource with indexName '" + req.getIndexName() + "' already exists");
                }
                RaceResource resource = new RaceResource();
                resource.setRace(isRace ? race : subrace.getRace());
                resource.setName(req.getName());
                resource.setIndexName(req.getIndexName());
                resource.setDescription(req.getDescription());
                resource.setMaxFormula(req.getResourceMaxFormula());
                resource.setRecoveryType(req.getResourceRecoveryType());
                if (!isRace) resource.setSubraceRestriction(subrace.getIndexName());
                raceResourceRepository.save(resource);
                trait.setConsumesResourceIndexName(resource.getIndexName());
            }
            case "NUMERIC_BONUS" -> {
                if (numericBonusRepository.findByBonusKey(req.getIndexName()).isPresent()) {
                    throw new RuntimeException(
                            "A numeric bonus with key '" + req.getIndexName() + "' already exists");
                }
                NumericBonus bonus = new NumericBonus();
                bonus.setName(req.getName());
                bonus.setBonusKey(req.getIndexName());
                bonus.setTargetField(req.getBonusTargetField());
                bonus.setFormula(req.getBonusFormula());
                bonus.setCondition(req.getBonusCondition());
                numericBonusRepository.save(bonus);
                trait.setGrantsBonusKey(bonus.getBonusKey());
            }
            case "GRANT_SPELL" -> {
                if (req.getSpellId() == null) {
                    throw new RuntimeException("spellId is required for GRANT_SPELL");
                }
                // RacialTraitSpell va atado al trait, no a Race/Subrace -- se guarda tras
                // persistir el trait (ver más abajo), no aquí.
                pendingSpellGrant = spellRepository.findById(req.getSpellId())
                        .orElseThrow(() -> new RuntimeException("Spell not found: " + req.getSpellId()));
            }
            case "GRANT_PROFICIENCY" -> {
                if (req.getProficiencyId() == null) {
                    throw new RuntimeException("proficiencyId is required for GRANT_PROFICIENCY");
                }
                Proficiency proficiency = proficiencyRepository.findById(req.getProficiencyId())
                        .orElseThrow(() -> new RuntimeException("Proficiency not found: " + req.getProficiencyId()));
                racialTraitProficiencyRepository.save(new RacialTraitProficiency(trait, proficiency));
            }
            case "NONE" -> { /* rasgo puramente descriptivo */ }
            default -> throw new RuntimeException("Unknown mechanic type: " + mechanic);
        }

        racialTraitRepository.save(trait);
        if (pendingSpellGrant != null) {
            racialTraitSpellRepository.save(
                    new RacialTraitSpell(trait, pendingSpellGrant, req.getSpellRequiredLevel()));
        }

        if (isRace) {
            race.getTraits().add(trait);
            raceRepository.save(race);
        } else {
            subrace.getTraits().add(trait);
            subraceRepository.save(subrace);
        }

        return toDto(trait);
    }

    private RacialTraitDto toDto(RacialTrait trait) {
        RacialTraitDto dto = new RacialTraitDto();
        dto.setId(trait.getId());
        dto.setIndexName(trait.getIndexName());
        dto.setName(trait.getName());
        dto.setDescription(trait.getDescription());
        dto.setTraitType(trait.getTraitType());
        dto.setConsumesResourceIndexName(trait.getConsumesResourceIndexName());
        dto.setGrantsBonusKey(trait.getGrantsBonusKey());
        return dto;
    }
}
