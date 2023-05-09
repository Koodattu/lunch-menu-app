package fi.koodattu.lunchmenuapp.controller;

import fi.koodattu.lunchmenuapp.model.LunchMenuCourse;
import fi.koodattu.lunchmenuapp.model.LunchMenuCourseVote;
import fi.koodattu.lunchmenuapp.model.LunchMenuFrequentCourse;
import fi.koodattu.lunchmenuapp.model.LunchMenuWeek;
import fi.koodattu.lunchmenuapp.service.LunchMenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1")
public class LunchMenuController {

    @Autowired
    LunchMenuService lunchMenuService;

    @GetMapping("/lunch-menu-weeks")
    public ResponseEntity<List<LunchMenuWeek>> getAllLunchMenuWeeks() {
        try {
            List<LunchMenuWeek> lunchMenuWeeks = lunchMenuService.getAllWeeks();

            if (lunchMenuWeeks.isEmpty()) {
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }

            return new ResponseEntity<>(lunchMenuWeeks, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ArrayList<>(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/lunch-menu-weeks/{id}")
    public ResponseEntity<LunchMenuWeek> getLunchMenuWeekById(@PathVariable("id") long id) {
        Optional<LunchMenuWeek> lunchMenuWeek = lunchMenuService.getWeekById(id);

        if (lunchMenuWeek.isPresent()) {
            return new ResponseEntity<>(lunchMenuWeek.get(), HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/lunch-menu-weeks/latest")
    public ResponseEntity<LunchMenuWeek> getLatestLunchMenuWeek() {
        LunchMenuWeek lunchMenuWeek = lunchMenuService.getLatestWeek();

        if (lunchMenuWeek == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        } else {
            return new ResponseEntity<>(lunchMenuWeek, HttpStatus.OK);
        }
    }

    @GetMapping("/lunch-menu-courses")
    public ResponseEntity<List<LunchMenuCourse>> getAllLunchMenuCourses() {
        try {
            List<LunchMenuCourse> courses = lunchMenuService.getAllCourses();

            if (courses.isEmpty()) {
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }

            return new ResponseEntity<>(courses, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ArrayList<>(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/lunch-menu-course-votes")
    public ResponseEntity<List<LunchMenuCourseVote>> getAllLunchMenuCourseVotes() {
        try {
            List<LunchMenuCourseVote> courseVotes = lunchMenuService.getAllVotes();

            if (courseVotes.isEmpty()) {
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }

            return new ResponseEntity<>(courseVotes, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ArrayList<>(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/lunch-menu-course-votes/vote")
    public ResponseEntity<LunchMenuCourseVote> postLunchMenuCourseVote(@RequestBody LunchMenuCourseVote courseVote) {

        LunchMenuCourseVote vote = lunchMenuService.saveVote(courseVote);

        if (vote == null) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        } else {
            return new ResponseEntity<>(vote, HttpStatus.OK);
        }
    }

    @GetMapping("/lunch-menu-courses/frequent")
    public ResponseEntity<List<LunchMenuFrequentCourse>> getMostFrequentLunchMenuCourses() {
        try {
            List<LunchMenuFrequentCourse> frequentCourses = lunchMenuService.getMostFrequentLunchMenuCourses();

            if (frequentCourses.isEmpty()) {
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }

            return new ResponseEntity<>(frequentCourses, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ArrayList<>(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
