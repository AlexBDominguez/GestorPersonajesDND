package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.Item;

public interface ItemRepository extends JpaRepository<entities.Item, Long> {
    Optional<Item> findByIndexName(String indexName);
    List<Item> findByItemType(String itemType);
    List<Item> findByNameContainingIgnoreCase(String name);

}
