package fi.koodattu.lunchmenuapp.controller;

import fi.koodattu.lunchmenuapp.model.LunchMenuWeek;
import fi.koodattu.lunchmenuapp.repository.LunchMenuWeekRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1")
public class LunchMenuController {

    @Autowired
    LunchMenuWeekRepository lunchMenuWeekRepository;

    @GetMapping("/lunch-menu-weeks")
    public ResponseEntity<List<LunchMenuWeek>> getAllLunchMenuWeeks() {
        try {
            List<LunchMenuWeek> lunchMenuWeeks = lunchMenuWeekRepository.findAll();

            if (lunchMenuWeeks.isEmpty()) {
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }

            return new ResponseEntity<>(lunchMenuWeeks, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/lunch-menu-weeks/{id}")
    public ResponseEntity<LunchMenuWeek> getLunchMenuWeekById(@PathVariable("id") long id) {
        Optional<LunchMenuWeek> lunchMenuWeek = lunchMenuWeekRepository.findById(id);

        if (lunchMenuWeek.isPresent()) {
            return new ResponseEntity<>(lunchMenuWeek.get(), HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/lunch-menu-weeks/latest")
    public ResponseEntity<LunchMenuWeek> getLatestLunchMenuWeek() {
        List<LunchMenuWeek> lunchMenuWeeks = lunchMenuWeekRepository.findAll();

        if (lunchMenuWeeks.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        } else {
            LunchMenuWeek lunchMenuWeek = lunchMenuWeeks.get(lunchMenuWeeks.size() - 1);
            return new ResponseEntity<>(lunchMenuWeek, HttpStatus.OK);
        }
    }

}
