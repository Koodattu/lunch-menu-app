package fi.koodattu.lunchmenuapp.model;

import jakarta.persistence.*;
import lombok.Data;

import java.util.List;

@Entity
@Table(name = "days")
@Data
public class LunchMenuDay {

    @Id
    @GeneratedValue
    private long id;

    @Column(name = "name")
    private String dayName;

    @ManyToMany
    private List<LunchMenuCourse> menuCourses;
}
