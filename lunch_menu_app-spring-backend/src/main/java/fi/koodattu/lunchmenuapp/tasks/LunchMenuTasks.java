package fi.koodattu.lunchmenuapp.tasks;

import fi.koodattu.lunchmenuapp.model.LunchMenuAllergen;
import fi.koodattu.lunchmenuapp.model.LunchMenuCourse;
import fi.koodattu.lunchmenuapp.model.LunchMenuDay;
import fi.koodattu.lunchmenuapp.model.LunchMenuWeek;
import fi.koodattu.lunchmenuapp.service.LunchMenuService;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.hpsf.SummaryInformation;
import org.apache.poi.hwpf.HWPFDocument;
import org.apache.poi.ooxml.POIXMLProperties;
import org.apache.poi.poifs.filesystem.FileMagic;
import org.apache.poi.xwpf.extractor.XWPFWordExtractor;
import org.apache.poi.xwpf.usermodel.XWPFDocument;

import java.io.*;
import java.net.URL;
import java.net.URLConnection;
import java.nio.file.Files;
import java.nio.file.Path;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.Year;
import java.util.*;

@Slf4j
public class LunchMenuTasks {

    public static void FetchMenuFromDrive(LunchMenuService lunchMenuService) throws IOException {
        log.info("[INFO] Fetching menu from drive.");

        String driveFileUrl = "https://drive.google.com/uc?id=1ejQntnQPCHiajV_CLB6Un9AUElxzyOP4&export=download";
        URL url = new URL(driveFileUrl);
        URLConnection urlConnection = url.openConnection();
        BufferedInputStream inputStream = new BufferedInputStream(urlConnection.getInputStream());
        XWPFDocument xwpfDocument = new XWPFDocument(inputStream);
        LunchMenuWeek lunchMenuWeek = ParseLunchMenuWeekFromDocument(xwpfDocument);

        // check if missing or changed from database
        if (NeedsToSaveDocumentInDatabase(lunchMenuWeek, lunchMenuService)) {
            lunchMenuService.saveLunchMenuWeek(lunchMenuWeek);
            log.info("[INFO] Saved new lunch menu week to database.");
        }

        // save file if not saved
        if (NeedsToSaveDocumentInFolder(lunchMenuWeek)) {
            SaveDocumentFile(xwpfDocument, lunchMenuWeek);
            log.info("[INFO] Saved new lunch menu week document to folder.");
        }

        log.info("[INFO] Done fetching menu from drive.");
    }

    public static void ReadLocalFilesToDatabase(LunchMenuService lunchMenuService) throws IOException {
        log.info("[INFO] Reading local files to database.");
        String path = "./menu_doc_files/";

        if (Files.isDirectory(Path.of(path))){
            File folder = new File(path);
            List<String> files = new ArrayList<>();
            File[] filesInFolder = folder.listFiles();
            if (filesInFolder != null) {
                for (File file : filesInFolder){
                    String fileName = file.getName();
                    if (fileName.endsWith(".doc")){
                        files.add(fileName);
                    }
                }
            }

            log.info("[INFO] Found " + files.size() + " files.");
            List<LunchMenuWeek> weeks = new ArrayList<>();

            for (String filePath : files){
                File file = new File(path + filePath);
                FileInputStream fis = new FileInputStream(file);
                BufferedInputStream bis = new BufferedInputStream(fis);
                LunchMenuWeek week = ParseLunchMenuWeekFromInputStream(bis);
                weeks.add(week);
            }

            log.info("[INFO] Parsed " + weeks.size() + " files.");

            int counter = 0;

            for (LunchMenuWeek week : weeks){
                Optional<LunchMenuWeek> dbWeek = lunchMenuService.getWeekById(week.getId());
                if (dbWeek.isEmpty()){
                    lunchMenuService.saveLunchMenuWeek(week);
                    counter++;
                }
            }

            log.info("[INFO] Saved " + counter + " files to database.");
        }
    }

    private static LunchMenuWeek ParseLunchMenuWeekFromInputStream(BufferedInputStream inputStream) throws IOException {
        if (FileMagic.valueOf(inputStream) == FileMagic.OLE2){
            HWPFDocument document = new HWPFDocument(inputStream);
            return ParseLunchMenuWeekFromDocument(document);
        }
        if (FileMagic.valueOf(inputStream) == FileMagic.OOXML){
            XWPFDocument document = new XWPFDocument(inputStream);
            return ParseLunchMenuWeekFromDocument(document);
        }
        throw new IOException("Wrong file type.");
    }

    private static boolean NeedsToSaveDocumentInDatabase(LunchMenuWeek lunchMenuWeek, LunchMenuService lunchMenuService){
        Optional<LunchMenuWeek> savedWeek = lunchMenuService.getWeekById(lunchMenuWeek.getId());

        if (savedWeek.isEmpty()){
            return true;
        }

        Date docSavedDate = lunchMenuWeek.getDocumentSaveDate();
        Date dbSavedDate = savedWeek.get().getDocumentSaveDate();
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");

        return !dateFormat.format(docSavedDate).equals(dateFormat.format(dbSavedDate));
    }

    private static long GenerateWeekId(String weekName, String year){
        String week = weekName.split("(?=\\d*$)", 2)[1];
        return Long.parseLong(year + week);
    }

    private static boolean NeedsToSaveDocumentInFolder(LunchMenuWeek lunchMenuWeek) throws IOException {
        String documentsFolderPath = "./menu_doc_files/";
        String documentFilePath = documentsFolderPath + lunchMenuWeek.getWeekName() + "-" + Year.now() + ".doc";
        File file = new File(documentFilePath);

        if (!file.isFile()){
            return true;
        }

        XWPFDocument savedDocument = new XWPFDocument(new FileInputStream(file));
        POIXMLProperties.CoreProperties properties = savedDocument.getProperties().getCoreProperties();

        Date docSavedDate = lunchMenuWeek.getDocumentSaveDate();
        Date folderSavedDate = properties.getModified() != null ? properties.getModified() : properties.getCreated();
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");

        return !dateFormat.format(docSavedDate).equals(dateFormat.format(folderSavedDate));
    }

    private static void SaveDocumentFile(XWPFDocument document, LunchMenuWeek lunchMenuWeek) throws IOException {
        String documentsFolderPath = "./menu_doc_files/";
        String documentFilePath = documentsFolderPath + lunchMenuWeek.getWeekName() + "-" + Year.now();

        Path folderPath = Path.of(documentsFolderPath);

        if (!Files.isDirectory(folderPath)){
            Files.createDirectory(folderPath);
        }

        FileOutputStream fileOutputStream = new FileOutputStream(documentFilePath + ".doc");
        document.write(fileOutputStream);
        fileOutputStream.close();
    }

    private static LunchMenuWeek ParseLunchMenuWeekFromDocument(HWPFDocument document){
        SummaryInformation si = document.getSummaryInformation();
        Date created = si.getCreateDateTime();
        Date lastSaved = si.getLastSaveDateTime();
        String documentText = document.getDocumentText();

        if (lastSaved == null) {
            lastSaved = created;
            if (created == null){
                lastSaved = Calendar.getInstance().getTime();
            }
        }

        return ParseLunchMenuWeekFromText(documentText, lastSaved);
    }

    private static LunchMenuWeek ParseLunchMenuWeekFromDocument(XWPFDocument document){
        POIXMLProperties properties = document.getProperties();
        Date created = properties.getCoreProperties().getCreated();
        Date lastSaved = properties.getCoreProperties().getModified();
        String documentText = new XWPFWordExtractor(document).getText();

        if (lastSaved == null) {
            lastSaved = created;
            if (created == null){
                lastSaved = Calendar.getInstance().getTime();
            }
        }

        return ParseLunchMenuWeekFromText(documentText, lastSaved);
    }

    private static LunchMenuWeek ParseLunchMenuWeekFromText(String documentText, Date lastSaved) {
        LunchMenuWeek week = new LunchMenuWeek();
        List<LunchMenuDay> days = new ArrayList<>();

        week.setDocumentSaveDate(lastSaved);

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
        week.setId(GenerateWeekId(title, getYearFromDate(lastSaved)));

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
                name = name.replaceAll("L ,G", "L,G");
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

    private static String getYearFromDate(Date date){
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        return String.valueOf(calendar.get(Calendar.YEAR));
    }
}
