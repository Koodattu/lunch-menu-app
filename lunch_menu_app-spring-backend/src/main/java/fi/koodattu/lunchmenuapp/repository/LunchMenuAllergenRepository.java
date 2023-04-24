package fi.koodattu.lunchmenuapp.repository;

import fi.koodattu.lunchmenuapp.model.LunchMenuAllergen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface LunchMenuAllergenRepository extends JpaRepository<LunchMenuAllergen, Long> {
    @Query(value = "SELECT * FROM Allergens a WHERE a.symbol = :symbol", nativeQuery = true)
    LunchMenuAllergen findAllergenBySymbol(@Param("symbol") String symbol);
}
