package fi.koodattu.lunchmenuapp.repository;

import fi.koodattu.lunchmenuapp.model.LunchMenuCourse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface LunchMenuCourseRepository extends JpaRepository<LunchMenuCourse, Long> {

    @Query(value = "SELECT * FROM Courses c WHERE c.name = :name", nativeQuery = true)
    LunchMenuCourse findCourseByName(@Param("name") String name);
}
