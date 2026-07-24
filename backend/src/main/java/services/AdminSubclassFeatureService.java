package services;

import dto.ClassFeatureDto;
import dto.SubclassFeatureAdminRequest;
import entities.ClassResource;
import entities.NumericBonus;
import entities.Proficiency;
import entities.Spell;
import entities.Subclass;
import entities.SubclassFeature;
import entities.SubclassProficiencyGrant;
import entities.SubclassSpell;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import repositories.ClassResourceRepository;
import repositories.NumericBonusRepository;
import repositories.ProficiencyRepository;
import repositories.SpellRepository;
import repositories.SubclassFeatureRepository;
import repositories.SubclassProficiencyGrantRepository;
import repositories.SubclassRepository;
import repositories.SubclassSpellRepository;

/**
 * #9 (panel de admin): crea una SubclassFeature junto con la fila de mecánica que le
 * corresponda según el "mechanicType" elegido, en una sola transacción -- el requisito de
 * diseño explícito de #9 es que el formulario (y por tanto este servicio) solo trabaje con
 * los campos que ese tipo concreto necesita, no un formulario de texto libre.
 *
 * RESOURCE_POOL y NUMERIC_BONUS enlazan desde la propia feature (consumesResourceIndexName /
 * grantsBonusKey, ver esas entidades). GRANT_SPELL y GRANT_PROFICIENCY, en cambio, no enlazan
 * desde la feature en absoluto en el esquema existente -- SubclassSpell/SubclassProficiencyGrant
 * van atadas directamente a la Subclass, así que aquí se crean como filas hermanas de la
 * feature (misma subclase, mismo nivel), no como algo que la feature referencie.
 */
@Service
public class AdminSubclassFeatureService {

    private final SubclassRepository subclassRepository;
    private final SubclassFeatureRepository subclassFeatureRepository;
    private final ClassResourceRepository classResourceRepository;
    private final NumericBonusRepository numericBonusRepository;
    private final SubclassSpellRepository subclassSpellRepository;
    private final SubclassProficiencyGrantRepository subclassProficiencyGrantRepository;
    private final SpellRepository spellRepository;
    private final ProficiencyRepository proficiencyRepository;

    public AdminSubclassFeatureService(SubclassRepository subclassRepository,
                                       SubclassFeatureRepository subclassFeatureRepository,
                                       ClassResourceRepository classResourceRepository,
                                       NumericBonusRepository numericBonusRepository,
                                       SubclassSpellRepository subclassSpellRepository,
                                       SubclassProficiencyGrantRepository subclassProficiencyGrantRepository,
                                       SpellRepository spellRepository,
                                       ProficiencyRepository proficiencyRepository) {
        this.subclassRepository = subclassRepository;
        this.subclassFeatureRepository = subclassFeatureRepository;
        this.classResourceRepository = classResourceRepository;
        this.numericBonusRepository = numericBonusRepository;
        this.subclassSpellRepository = subclassSpellRepository;
        this.subclassProficiencyGrantRepository = subclassProficiencyGrantRepository;
        this.spellRepository = spellRepository;
        this.proficiencyRepository = proficiencyRepository;
    }

    @Transactional
    public ClassFeatureDto create(Long subclassId, SubclassFeatureAdminRequest req) {
        Subclass subclass = subclassRepository.findById(subclassId)
                .orElseThrow(() -> new RuntimeException("Subclass not found: " + subclassId));

        if (req.getIndexName() == null || req.getIndexName().isBlank()) {
            throw new RuntimeException("indexName is required");
        }
        if (subclassFeatureRepository.findByIndexName(req.getIndexName()).isPresent()) {
            throw new RuntimeException("A feature with indexName '" + req.getIndexName() + "' already exists");
        }

        SubclassFeature feature = new SubclassFeature();
        feature.setSubclass(subclass);
        feature.setIndexName(req.getIndexName());
        feature.setName(req.getName());
        feature.setLevel(req.getLevel());
        feature.setDescription(req.getDescription());

        SubclassSpell pendingSpellGrant = null;
        SubclassProficiencyGrant pendingProficiencyGrant = null;

        String mechanic = req.getMechanicType() == null ? "NONE" : req.getMechanicType();
        switch (mechanic) {
            case "RESOURCE_POOL" -> {
                if (classResourceRepository.findByIndexName(req.getIndexName()).isPresent()) {
                    throw new RuntimeException(
                            "A resource with indexName '" + req.getIndexName() + "' already exists");
                }
                ClassResource resource = new ClassResource();
                resource.setDndClass(subclass.getDndClass());
                resource.setName(req.getName());
                resource.setIndexName(req.getIndexName());
                resource.setDescription(req.getDescription());
                resource.setMaxFormula(req.getResourceMaxFormula());
                resource.setRecoveryType(req.getResourceRecoveryType());
                resource.setLevelUnlocked(req.getLevel());
                resource.setSubclassRestriction(subclass.getName());
                classResourceRepository.save(resource);
                feature.setConsumesResourceIndexName(resource.getIndexName());
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
                feature.setGrantsBonusKey(bonus.getBonusKey());
            }
            case "GRANT_SPELL" -> {
                if (req.getSpellId() == null) {
                    throw new RuntimeException("spellId is required for GRANT_SPELL");
                }
                Spell spell = spellRepository.findById(req.getSpellId())
                        .orElseThrow(() -> new RuntimeException("Spell not found: " + req.getSpellId()));
                pendingSpellGrant = new SubclassSpell(subclass, spell, req.getLevel());
            }
            case "GRANT_PROFICIENCY" -> {
                if (req.getProficiencyId() == null) {
                    throw new RuntimeException("proficiencyId is required for GRANT_PROFICIENCY");
                }
                Proficiency proficiency = proficiencyRepository.findById(req.getProficiencyId())
                        .orElseThrow(() -> new RuntimeException("Proficiency not found: " + req.getProficiencyId()));
                pendingProficiencyGrant = new SubclassProficiencyGrant(subclass, proficiency);
            }
            case "NONE" -> { /* feature puramente descriptiva, nada más que crear */ }
            default -> throw new RuntimeException("Unknown mechanic type: " + mechanic);
        }

        subclassFeatureRepository.save(feature);
        if (pendingSpellGrant != null) subclassSpellRepository.save(pendingSpellGrant);
        if (pendingProficiencyGrant != null) subclassProficiencyGrantRepository.save(pendingProficiencyGrant);

        return toDto(feature);
    }

    private ClassFeatureDto toDto(SubclassFeature feature) {
        ClassFeatureDto dto = new ClassFeatureDto();
        dto.setId(feature.getId());
        dto.setIndexName(feature.getIndexName());
        dto.setName(feature.getName());
        dto.setLevel(feature.getLevel());
        dto.setDescription(feature.getDescription());
        dto.setApiUrl(feature.getApiUrl());
        dto.setConsumesResourceIndexName(feature.getConsumesResourceIndexName());
        dto.setGrantsBonusKey(feature.getGrantsBonusKey());
        return dto;
    }
}
