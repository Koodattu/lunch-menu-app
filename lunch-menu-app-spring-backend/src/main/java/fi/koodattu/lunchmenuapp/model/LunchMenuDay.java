package fi.koodattu.lunchmenuapp.model;

import jakarta.persistence.*;
import lombok.Data;

import java.util.List;

@Data
@Entity
@Table(name = "days", schema = "public")
public class LunchMenuDay {

    @Id
    @GeneratedValue
    private long id;

    @Column(name = "name")
    private String dayName;

    @ManyToMany
    private List<LunchMenuCourse> menuCourses;
}
