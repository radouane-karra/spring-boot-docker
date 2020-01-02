package com.rkarra.ms.model.api;

public class SingleResponse {

	private Object value;

	public SingleResponse(Object value) {
		this.value = value;
	}

	public Object getValue() {
		return value;
	}

	public void setValue(Object value) {
		this.value = value;
	}
}
