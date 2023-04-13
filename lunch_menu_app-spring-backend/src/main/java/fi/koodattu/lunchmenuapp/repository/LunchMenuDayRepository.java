package fi.koodattu.lunchmenuapp.repository;

import fi.koodattu.lunchmenuapp.model.LunchMenuDay;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LunchMenuDayRepository extends JpaRepository<LunchMenuDay, Long> {
}
