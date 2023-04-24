package fi.koodattu.lunchmenuapp.service;

import fi.koodattu.lunchmenuapp.model.*;
import fi.koodattu.lunchmenuapp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class LunchMenuService {

    @Autowired
    LunchMenuWeekRepository menuWeekRepository;
    @Autowired
    LunchMenuDayRepository menuDayRepository;
    @Autowired
    LunchMenuCourseRepository menuCourseRepository;
    @Autowired
    LunchMenuAllergenRepository menuAllergenRepository;
    @Autowired
    LunchMenuCourseVoteRepository courseVoteRepository;

    public LunchMenuWeek saveLunchMenuWeek(LunchMenuWeek lunchMenuWeek){

        for (LunchMenuDay day : lunchMenuWeek.getMenuDays()){
            for (LunchMenuCourse course : day.getMenuCourses()){
                for (LunchMenuAllergen allergen : course.getAllergens()){
                    allergen.setId(0);
                    LunchMenuAllergen dbAllergen = menuAllergenRepository.findAllergenBySymbol(allergen.getAllergenSymbol());
                    if (dbAllergen == null){
                        allergen.setId(menuAllergenRepository.save(allergen).getId());
                    } else {
                        allergen.setId(dbAllergen.getId());
                    }
                }
                course.setId(0);

                LunchMenuCourseVote courseVote = new LunchMenuCourseVote();
                courseVote.setCourse(course);
                course.setCourseVote(courseVote);

                LunchMenuCourse dbCourse = menuCourseRepository.findCourseByName(course.getCourseName());
                if (dbCourse == null){
                    course.setId(menuCourseRepository.save(course).getId());
                } else {
                    course.setId(dbCourse.getId());
                }
            }
            menuDayRepository.save(day);
        }

        return menuWeekRepository.save(lunchMenuWeek);
    }

    public List<LunchMenuWeek> getAllWeeks(){
        return menuWeekRepository.findAll();
    }

    public Optional<LunchMenuWeek> getWeekById(long id){
        return menuWeekRepository.findById(id);
    }

    public LunchMenuWeek getLatestWeek(){
        List<LunchMenuWeek> lunchMenuWeeks = menuWeekRepository.findAll();

        if (lunchMenuWeeks.isEmpty()) {
            return null;
        } else {
            return lunchMenuWeeks.get(lunchMenuWeeks.size() - 1);
        }
    }

    public List<LunchMenuCourse> getAllCourses(){
        return menuCourseRepository.findAll();
    }

    public List<LunchMenuCourseVote> getAllVotes(){
        return courseVoteRepository.findAll();
    }

    public LunchMenuCourseVote saveVote(LunchMenuCourseVote vote){
        Optional<LunchMenuCourseVote> courseVote = courseVoteRepository.findById(vote.getId());

        if (courseVote.isPresent()){
            courseVote.get().setLikes(courseVote.get().getLikes() + vote.getLikes());
            courseVote.get().setDislikes(courseVote.get().getDislikes() + vote.getDislikes());

            return courseVoteRepository.save(vote);
        }

        return null;
    }
}
