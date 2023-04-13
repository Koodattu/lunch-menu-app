package fi.koodattu.lunchmenuapp.model;

import jakarta.persistence.*;
import lombok.Data;

import java.util.List;

@Entity
@Table(name = "weeks")
@Data
public class LunchMenuWeek {

    @Id
    @GeneratedValue
    private long id;

    @Column(name = "name")
    private String weekName;

    @Column(name = "salad_price")
    private String saladCoursePrice;

    @Column(name = "soup_price")
    private String soupCoursePrice;

    @Column(name = "main_price")
    private String mainCoursePrice;

    @OneToMany
    private List<LunchMenuDay> menuDays;

}
