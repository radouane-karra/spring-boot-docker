package com.rkarra.ms.resources;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.rkarra.ms.model.api.SingleResponse;

@RestController
public class DemoResource {

	@GetMapping(value = "/demo", produces = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<SingleResponse> response() {
		
		return ResponseEntity.ok().body(new SingleResponse("OK"));
	}
}
