package fi.koodattu.lunchmenuapp.tasks;

import fi.koodattu.lunchmenuapp.service.LunchMenuService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class DatabaseLocalFilesCheckTask {

    @Autowired
    private LunchMenuService lunchMenuService;

    @EventListener(ApplicationReadyEvent.class)
    private void ApplicationStarted(){
        try {
            LunchMenuTasks.ReadLocalFilesToDatabase(lunchMenuService);
        } catch (Exception e){
            log.error("[ERROR] Error reading local files to database.", e);
        }

        try {
            LunchMenuTasks.FetchMenuFromDrive(lunchMenuService);
        } catch (Exception e){
            log.error("[ERROR] Error fetching week menu from drive.", e);
        }
    }

}
