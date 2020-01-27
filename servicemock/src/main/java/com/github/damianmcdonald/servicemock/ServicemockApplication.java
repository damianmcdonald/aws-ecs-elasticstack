package com.github.damianmcdonald.servicemock;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ServicemockApplication {

	public static void main(String[] args) {
		SpringApplication.run(ServicemockApplication.class, args);
	}

}
