package fi.koodattu.lunchmenuapp.service;

import fi.koodattu.lunchmenuapp.model.*;
import fi.koodattu.lunchmenuapp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

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
            lunchMenuWeeks.sort(Comparator.comparingInt(a -> (int) a.getId()));
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

            return courseVoteRepository.save(courseVote.get());
        }

        return null;
    }

    public List<LunchMenuFrequentCourse> getMostFrequentLunchMenuCourses(){
        List<LunchMenuDay> days = menuDayRepository.findAll();
        HashMap<Long, Integer> frequentCoursesMap = new HashMap<>();

        for (LunchMenuDay day : days){
            for (LunchMenuCourse course : day.getMenuCourses()){
                if (frequentCoursesMap.containsKey(course.getId())){
                    frequentCoursesMap.put(course.getId(), frequentCoursesMap.get(course.getId()) + 1);
                } else {
                    frequentCoursesMap.put(course.getId(), 1);
                }
            }
        }

        List<LunchMenuCourse> courses = menuCourseRepository.findAll();
        List<LunchMenuFrequentCourse> frequentCourses = new ArrayList<>();

        for(Map.Entry<Long, Integer> entry : frequentCoursesMap.entrySet()){
            Optional<LunchMenuCourse> course = courses.stream().filter(c -> c.getId() == entry.getKey()).findAny();
            course.ifPresent(lunchMenuCourse -> frequentCourses.add(new LunchMenuFrequentCourse(lunchMenuCourse, entry.getValue())));
        }

        frequentCourses.sort(Comparator.comparingInt(LunchMenuFrequentCourse::getCount));
        Collections.reverse(frequentCourses);

        return frequentCourses;
    }
}
