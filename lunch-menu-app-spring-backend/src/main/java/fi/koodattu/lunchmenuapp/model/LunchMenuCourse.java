package fi.koodattu.lunchmenuapp.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.Data;

import java.util.List;

@Data
@Entity
@Table(name = "courses", schema = "public")
public class LunchMenuCourse {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(name = "name")
    private String courseName;

    @Column(name = "type")
    private String courseType;

    @ManyToMany
    private List<LunchMenuAllergen> allergens;

    @OneToOne(mappedBy = "course", cascade = CascadeType.ALL)
    @PrimaryKeyJoinColumn
    @JsonManagedReference
    private LunchMenuCourseVote courseVote;
}
