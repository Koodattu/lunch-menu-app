package fi.koodattu.lunchmenuapp.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;

@Data
@Entity
@Table(name = "course_votes", schema = "public")
public class LunchMenuCourseVote {

    @Id
    @Column(name = "course_id")
    private long id;

    @OneToOne
    @MapsId
    @JsonBackReference
    @JoinColumn(name = "course_id")
    private LunchMenuCourse course;

    @Column(name = "likes")
    private int likes;

    @Column(name = "dislikes")
    private int dislikes;

    @Column(name = "ranked")
    private int ranked;
}
