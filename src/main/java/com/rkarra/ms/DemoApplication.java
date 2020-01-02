package com.rkarra.ms;


import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.boot.web.servlet.ServletComponentScan;


@ServletComponentScan
@SpringBootApplication
@EnableAutoConfiguration(exclude = {SecurityAutoConfiguration.class}) 
public class DemoApplication implements CommandLineRunner {

	public static void main(String[] args) {
		
		SpringApplication.run(DemoApplication.class, args);
	}
	
    @Override
    public void run(String... arg0) throws Exception {
    	
    	System.out.println("Start exemple Application");
    	
    }
   

 
}