package fi.koodattu.lunchmenuapp.service;

import fi.koodattu.lunchmenuapp.model.*;
import fi.koodattu.lunchmenuapp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.CacheConfig;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@CacheConfig(cacheNames = {"latestWeek", "allWeeks", "allCourses", "frequentCourses"})
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
    @Autowired
    CacheManager cacheManager;

    @CacheEvict(allEntries = true)
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
                courseVote.setRanked(new Random().nextInt(90) + 10);
                courseVote.setLikes(new Random().nextInt(90) + 10);
                courseVote.setDislikes(new Random().nextInt(90) + 10);
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

    @Cacheable("allWeeks")
    public List<LunchMenuWeek> getAllWeeks(){
        return menuWeekRepository.findAll();
    }

    public Optional<LunchMenuWeek> getWeekById(long id){
        return menuWeekRepository.findById(id);
    }

    @Cacheable("latestWeek")
    public LunchMenuWeek getLatestWeek(){
        List<LunchMenuWeek> lunchMenuWeeks = menuWeekRepository.findAll();

        if (lunchMenuWeeks.isEmpty()) {
            return null;
        } else {
            lunchMenuWeeks.sort(Comparator.comparingInt(a -> (int) a.getId()));
            return lunchMenuWeeks.get(lunchMenuWeeks.size() - 1);
        }
    }

    @Cacheable("allCourses")
    public List<LunchMenuCourse> getAllCourses(){
        return menuCourseRepository.findAll();
    }

    public List<LunchMenuCourseVote> getAllVotes(){
        return courseVoteRepository.findAll();
    }

    @CacheEvict(value = "allCourses", allEntries = true)
    public LunchMenuCourseVote saveVote(LunchMenuCourseVote vote){
        Optional<LunchMenuCourseVote> courseVote = courseVoteRepository.findById(vote.getId());

        if (courseVote.isPresent()){
            courseVote.get().setLikes(courseVote.get().getLikes() + vote.getLikes());
            courseVote.get().setDislikes(courseVote.get().getDislikes() + vote.getDislikes());

            return courseVoteRepository.save(courseVote.get());
        }

        return null;
    }

    @CacheEvict(value = "allCourses", allEntries = true)
    public List<LunchMenuCourseVote> saveVoteRanked(List<LunchMenuCourseVote> votes){
        Optional<LunchMenuCourseVote> courseVoteWinner = courseVoteRepository.findById(votes.get(0).getId());
        Optional<LunchMenuCourseVote> courseVoteLoser = courseVoteRepository.findById(votes.get(1).getId());

        if (courseVoteWinner.isPresent() && courseVoteLoser.isPresent()){
            courseVoteWinner.get().setRanked(courseVoteWinner.get().getRanked() + votes.get(0).getRanked());
            int newLoserRanked = courseVoteLoser.get().getRanked() + votes.get(1).getRanked();
            if (newLoserRanked < 0) {
                newLoserRanked = 0;
            }
            courseVoteLoser.get().setRanked(newLoserRanked);

            return courseVoteRepository.saveAll(Arrays.asList(courseVoteWinner.get(), courseVoteLoser.get()));
        }

        return null;
    }


    @Cacheable("frequentCourses")
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

    public void clearAllCaches() {
        cacheManager.getCacheNames().forEach(cache -> Objects.requireNonNull(cacheManager.getCache(cache)).clear());
    }
}
