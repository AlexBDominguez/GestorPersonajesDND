package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.Subclass;
import entities.SubclassFeature;

public interface SubclassFeatureRepository extends JpaRepository<SubclassFeature, Long> {
    
    Optional<SubclassFeature> findByIndexName(String indexName);

    List<SubclassFeature> findBySubclass(Subclass subclass);

    List<SubclassFeature> findBySubclassAndLevel(Subclass subclass, int level);

    List<SubclassFeature> findBySubclassAndLevelLessThanEqual(Subclass subclass, int level);
}
