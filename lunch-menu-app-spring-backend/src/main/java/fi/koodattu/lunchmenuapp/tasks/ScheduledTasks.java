package fi.koodattu.lunchmenuapp.tasks;

import fi.koodattu.lunchmenuapp.service.LunchMenuService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class ScheduledTasks {

    @Autowired
    private LunchMenuService lunchMenuService;

    @Scheduled(cron = "0 0 8,20 * * *", zone = "Europe/Helsinki")
    public void scheduledFetchMenuFromDrive() {
        try {
            LunchMenuTasks.FetchMenuFromDrive(lunchMenuService);
        } catch (Exception e){
            log.error("[ERROR] Error fetching week menu from drive.", e);
        }
    }

}
