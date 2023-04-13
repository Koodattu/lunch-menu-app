package fi.koodattu.lunchmenuapp.tasks;

import fi.koodattu.lunchmenuapp.model.LunchMenuAllergen;
import fi.koodattu.lunchmenuapp.model.LunchMenuCourse;
import fi.koodattu.lunchmenuapp.model.LunchMenuDay;
import fi.koodattu.lunchmenuapp.model.LunchMenuWeek;
import fi.koodattu.lunchmenuapp.repository.LunchMenuWeekRepository;
import fi.koodattu.lunchmenuapp.service.LunchMenuService;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.xwpf.extractor.XWPFWordExtractor;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.io.BufferedInputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Component
@Slf4j
public class ScheduledTasks {

    @Autowired
    LunchMenuService lunchMenuService;

    @Scheduled(fixedRate = 200000)
    public void scheduledFetchMenuFromDrive() {
        log.info("[INFO] Fetching menu from drive.");

        try {
            String driveFileUrl = "https://drive.google.com/uc?id=1ejQntnQPCHiajV_CLB6Un9AUElxzyOP4&export=download";
            URL url = new URL(driveFileUrl);
            URLConnection urlConnection = url.openConnection();
            BufferedInputStream inputStream = new BufferedInputStream(urlConnection.getInputStream());
            XWPFDocument xwpfDocument = new XWPFDocument(inputStream);
            //HWPFDocument hwpfDocument = new HWPFDocument(inputStream);
            String documentText = new XWPFWordExtractor(xwpfDocument).getText();
            LunchMenuWeek lunchMenuWeek = ParseLunchMenuWeekFromDocument(documentText);
            lunchMenuService.saveLunchMenuWeek(lunchMenuWeek);
            log.info("[INFO] Saved new lunch menu week to database.");
        }
        catch (Exception ex){
            log.error("[ERROR] Error fetching menu from drive.", ex);
        }

        log.info("[INFO] Done fetching menu from drive.");
    }

    private LunchMenuWeek ParseLunchMenuWeekFromDocument(String documentText) {
        LunchMenuWeek week = new LunchMenuWeek();
        List<LunchMenuDay> days = new ArrayList<>();

        documentText = documentText.trim().replaceAll("\r+", "\t").replaceAll(" +", " ").replaceAll("\t{2,}|\t+ +\t+", "\t").replaceAll("\n", "\t").replaceAll("\n\n", "\t").replaceAll("\n\n\n", "\t");
        String[] splits = documentText.split("\t");

        for (int i = 0; i < splits.length; i++) {
            splits[i] = splits[i].trim();
        }

        List<String> splitsList = new ArrayList<>(Arrays.asList(splits));
        splitsList.removeAll(Arrays.asList("", null));

        String companyName = splitsList.get(0);
        String saladPrice = splitsList.get(1);
        String restaurantName = splitsList.get(2);
        String foodPrice = splitsList.get(3);
        String phoneNumber = splitsList.get(4);
        String soupPrice = splitsList.get(5);
        String title = splitsList.get(6);

        week.setWeekName(title);

        week.setSaladCoursePrice(saladPrice.split(" ", 2)[1]);
        week.setSoupCoursePrice(soupPrice.split(" ", 2)[1]);
        week.setMainCoursePrice(foodPrice.split(" ", 2)[1]);

        boolean[] bDays = {false, false, false, false, false};
        List<List<String>> dayMenu = new ArrayList<>();

        for (int i = 7; i < splitsList.size(); i++) {

            String curr = splitsList.get(i);

            if (curr.toLowerCase().startsWith("ma ")){
                bDays[0] = true;
                List<String> monday = new ArrayList<>();
                while (true){
                    String next = splitsList.get(i);
                    if (next.toLowerCase().startsWith("ti ")){
                        break;
                    }
                    monday.add(next);
                    i++;
                }
                dayMenu.add(monday);
            }
            curr = splitsList.get(i);
            if (curr.toLowerCase().startsWith("ti ") && bDays[0]){
                bDays[1] = true;
                List<String> tuesday = new ArrayList<>();
                while (true){
                    String next = splitsList.get(i);
                    if (next.toLowerCase().startsWith("ke ")){
                        break;
                    }
                    tuesday.add(next);
                    i++;
                }
                dayMenu.add(tuesday);
            }
            curr = splitsList.get(i);
            if (curr.toLowerCase().startsWith("ke ") && bDays[1]){
                bDays[2] = true;
                List<String> wednesday = new ArrayList<>();
                while (true){
                    String next = splitsList.get(i);
                    if (next.toLowerCase().startsWith("to ")){
                        break;
                    }
                    wednesday.add(next);
                    i++;
                }
                dayMenu.add(wednesday);
            }
            curr = splitsList.get(i);
            if ((curr.toLowerCase().startsWith("to ") || curr.toLowerCase().startsWith("t0")) && bDays[2]){
                bDays[3] = true;
                List<String> thursday = new ArrayList<>();
                while (true){
                    String next = splitsList.get(i);
                    if (next.toLowerCase().startsWith("pe ")){
                        break;
                    }
                    thursday.add(next);
                    i++;
                }
                dayMenu.add(thursday);
            }
            curr = splitsList.get(i);
            if (curr.toLowerCase().startsWith("pe ") && bDays[3]){
                bDays[4] = true;
                List<String> friday = new ArrayList<>();
                while (true){
                    String next = splitsList.get(i);
                    if (next.toLowerCase().startsWith("lisä")){
                        break;
                    }
                    friday.add(next);
                    i++;
                }
                dayMenu.add(friday);
            }
        }

        for (List<String> menu : dayMenu) {
            String[] array = menu.toArray(new String[0]);
            List<LunchMenuCourse> courses = new ArrayList<>();
            String[] daySplits = array[0].split("\\.");
            String day = daySplits[0] + "." + daySplits[1] + ".";
            String type = "";

            for (int j = 1; j < array.length; j++) {
                String price = "?€";
                String name = array[j];
                if (name.contains("pöytä")) {
                    price = saladPrice;
                    type = "salad";
                } else if (name.contains("keitto")) {
                    price = soupPrice;
                    type = "soup";
                } else {
                    price = foodPrice;
                    type = "main";
                }

                name = name.replaceAll("L, G", "L,G");
                name = name.replaceAll("L,G", "L,G");
                name = name.replaceAll("L G", "L,G");
                name = name.replaceAll("LG", "L,G");
                name = name.replaceAll("G, L", "L,G");
                name = name.replaceAll("G,L", "L,G");
                name = name.replaceAll("G L", "L,G");
                name = name.replaceAll("GL", "L,G");
                String[] nameSplit = name.split(" ");
                String allergens = nameSplit[nameSplit.length - 1];
                String[] allergensSplit = {};

                boolean foundAllergens = true;
                for (int k = 0; k < allergens.length(); k++) {
                    if (Character.isLowerCase(allergens.charAt(k))) {
                        foundAllergens = false;
                    }
                }

                if (allergens.length() > 4){
                    foundAllergens = false;
                }

                if (foundAllergens) {
                    allergensSplit = allergens.split(",");
                    name = name.replaceAll(" " + allergens, "");
                }
                name = name.trim();
                name = name.substring(0, 1).toUpperCase() + name.substring(1);
                name = name.replaceAll("[,.!?;:]", "$0 ").replaceAll("\\s+", " ");

                name = name.replaceAll("\\.", "");

                if (name.equals("Juuresosekeittoa")){
                    name = "Juuressosekeittoa";
                }

                if (name.contains(",")){
                    name = name.split(",")[0];
                }

                List<String> tags = new ArrayList<>(Arrays.asList(allergensSplit));
                List<LunchMenuAllergen> allergenList = new ArrayList<>();
                for (String tag : tags) {
                    LunchMenuAllergen allergen = new  LunchMenuAllergen();
                    allergen.setAllergenSymbol(tag);
                    allergenList.add(allergen);
                }

                LunchMenuCourse course = new LunchMenuCourse();
                course.setCourseName(name);
                course.setCourseType(type);
                course.setAllergens(allergenList);

                courses.add(course);
            }
            LunchMenuDay rDay = new LunchMenuDay();
            rDay.setDayName(day);
            rDay.setMenuCourses(courses);

            days.add(rDay);
        }

        week.setMenuDays(days);

        return week;
    }
}
