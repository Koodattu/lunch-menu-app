package fi.koodattu.lunchmenuapp;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Slf4j
@EnableScheduling
@SpringBootApplication
@EnableTransactionManagement
public class LunchMenuApplication {

	public static void main(String[] args) {
		log.info("Application starting...");
		SpringApplication.run(LunchMenuApplication.class, args);
	}

}
