package fi.koodattu.lunchmenuapp.model;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LunchMenuFrequentCourse {
    private LunchMenuCourse course;
    private int count;
}
