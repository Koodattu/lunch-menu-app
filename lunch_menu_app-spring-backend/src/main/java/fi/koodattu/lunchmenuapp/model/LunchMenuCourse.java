package fi.koodattu.lunchmenuapp.model;

import jakarta.persistence.*;
import lombok.Data;

import java.util.List;

@Data
@Entity
@Table(name = "courses", schema = "public")
public class LunchMenuCourse {

    @Id
    @GeneratedValue
    private long id;

    @Column(name = "name")
    private String courseName;

    @Column(name = "type")
    private String courseType;

    @ManyToMany
    private List<LunchMenuAllergen> allergens;
}
