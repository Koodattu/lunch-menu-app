package fi.koodattu.lunchmenuapp.repository;

import fi.koodattu.lunchmenuapp.model.LunchMenuWeek;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LunchMenuWeekRepository extends JpaRepository<LunchMenuWeek, Long> {
}
