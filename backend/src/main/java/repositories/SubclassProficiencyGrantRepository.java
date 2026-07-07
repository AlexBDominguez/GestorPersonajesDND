package repositories;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import entities.Subclass;
import entities.SubclassProficiencyGrant;

public interface SubclassProficiencyGrantRepository extends JpaRepository<SubclassProficiencyGrant, Long> {
    List<SubclassProficiencyGrant> findBySubclass(Subclass subclass);
}
