package fi.koodattu.lunchmenuapp.service;

import fi.koodattu.lunchmenuapp.model.LunchMenuAllergen;
import fi.koodattu.lunchmenuapp.model.LunchMenuCourse;
import fi.koodattu.lunchmenuapp.model.LunchMenuDay;
import fi.koodattu.lunchmenuapp.model.LunchMenuWeek;
import fi.koodattu.lunchmenuapp.repository.LunchMenuAllergenRepository;
import fi.koodattu.lunchmenuapp.repository.LunchMenuCourseRepository;
import fi.koodattu.lunchmenuapp.repository.LunchMenuDayRepository;
import fi.koodattu.lunchmenuapp.repository.LunchMenuWeekRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class LunchMenuService {

    @Autowired
    LunchMenuWeekRepository lunchMenuWeekRepository;
    @Autowired
    LunchMenuDayRepository lunchMenuDayRepository;
    @Autowired
    LunchMenuCourseRepository lunchMenuCourseRepository;
    @Autowired
    LunchMenuAllergenRepository lunchMenuAllergenRepository;

    public LunchMenuWeek saveLunchMenuWeek(LunchMenuWeek lunchMenuWeek){

        for (LunchMenuDay day : lunchMenuWeek.getMenuDays()){
            for (LunchMenuCourse course : day.getMenuCourses()){
                for (LunchMenuAllergen allergen : course.getAllergens()){
                    allergen.setId(0);
                    LunchMenuAllergen dbAllergen = lunchMenuAllergenRepository.findAllergenBySymbol(allergen.getAllergenSymbol());
                    if (dbAllergen == null){
                        allergen.setId(lunchMenuAllergenRepository.save(allergen).getId());
                    } else {
                        allergen.setId(dbAllergen.getId());
                    }
                }
                course.setId(0);
                LunchMenuCourse dbCourse = lunchMenuCourseRepository.findCourseByName(course.getCourseName());
                if (dbCourse == null){
                    course.setId(lunchMenuCourseRepository.save(course).getId());
                } else {
                    course.setId(dbCourse.getId());
                }
            }
            lunchMenuDayRepository.save(day);
        }

        return lunchMenuWeekRepository.saveAndFlush(lunchMenuWeek);
    }

}
