package services;

import dto.ClassFeatureAdminRequest;
import dto.ClassFeatureDto;
import entities.ClassFeature;
import entities.ClassResource;
import entities.ClassSpell;
import entities.DndClass;
import entities.NumericBonus;
import entities.Spell;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import repositories.ClassFeatureRepository;
import repositories.ClassResourceRepository;
import repositories.ClassSpellRepository;
import repositories.DndClassRepository;
import repositories.NumericBonusRepository;
import repositories.SpellRepository;

/**
 * #9: crea una ClassFeature (clase base) junto con su mecánica (#8.2) en una sola transacción.
 * Mirrors AdminSubclassFeatureService -- ver ClassFeatureAdminRequest para por qué
 * GRANT_PROFICIENCY no está soportado aquí (no hay tabla de "class proficiency grant").
 */
@Service
public class AdminClassFeatureService {

    private final DndClassRepository dndClassRepository;
    private final ClassFeatureRepository classFeatureRepository;
    private final ClassResourceRepository classResourceRepository;
    private final NumericBonusRepository numericBonusRepository;
    private final ClassSpellRepository classSpellRepository;
    private final SpellRepository spellRepository;

    public AdminClassFeatureService(DndClassRepository dndClassRepository,
                                    ClassFeatureRepository classFeatureRepository,
                                    ClassResourceRepository classResourceRepository,
                                    NumericBonusRepository numericBonusRepository,
                                    ClassSpellRepository classSpellRepository,
                                    SpellRepository spellRepository) {
        this.dndClassRepository = dndClassRepository;
        this.classFeatureRepository = classFeatureRepository;
        this.classResourceRepository = classResourceRepository;
        this.numericBonusRepository = numericBonusRepository;
        this.classSpellRepository = classSpellRepository;
        this.spellRepository = spellRepository;
    }

    @Transactional
    public ClassFeatureDto create(Long classId, ClassFeatureAdminRequest req) {
        DndClass dndClass = dndClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found: " + classId));

        if (req.getIndexName() == null || req.getIndexName().isBlank()) {
            throw new RuntimeException("indexName is required");
        }
        if (classFeatureRepository.findByIndexName(req.getIndexName()).isPresent()) {
            throw new RuntimeException("A feature with indexName '" + req.getIndexName() + "' already exists");
        }

        ClassFeature feature = new ClassFeature();
        feature.setDndClass(dndClass);
        feature.setIndexName(req.getIndexName());
        feature.setName(req.getName());
        feature.setLevel(req.getLevel());
        feature.setDescription(req.getDescription());

        Spell pendingSpellGrant = null;

        String mechanic = req.getMechanicType() == null ? "NONE" : req.getMechanicType();
        switch (mechanic) {
            case "RESOURCE_POOL" -> {
                if (classResourceRepository.findByIndexName(req.getIndexName()).isPresent()) {
                    throw new RuntimeException(
                            "A resource with indexName '" + req.getIndexName() + "' already exists");
                }
                ClassResource resource = new ClassResource();
                resource.setDndClass(dndClass);
                resource.setName(req.getName());
                resource.setIndexName(req.getIndexName());
                resource.setDescription(req.getDescription());
                resource.setMaxFormula(req.getResourceMaxFormula());
                resource.setRecoveryType(req.getResourceRecoveryType());
                resource.setLevelUnlocked(req.getLevel());
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
                pendingSpellGrant = spellRepository.findById(req.getSpellId())
                        .orElseThrow(() -> new RuntimeException("Spell not found: " + req.getSpellId()));
            }
            case "NONE" -> { /* feature puramente descriptiva */ }
            default -> throw new RuntimeException("Unknown mechanic type: " + mechanic
                    + " (GRANT_PROFICIENCY is not supported for base class features)");
        }

        classFeatureRepository.save(feature);
        if (pendingSpellGrant != null) {
            classSpellRepository.save(new ClassSpell(dndClass, pendingSpellGrant, req.getLevel()));
        }

        return toDto(feature);
    }

    private ClassFeatureDto toDto(ClassFeature feature) {
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
