package fi.koodattu.lunchmenuapp.repository;

import fi.koodattu.lunchmenuapp.model.LunchMenuCourseVote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LunchMenuCourseVoteRepository extends JpaRepository<LunchMenuCourseVote, Long> {
}
