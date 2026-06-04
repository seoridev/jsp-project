package com.carrot.util;

import java.util.LinkedHashMap;
import java.util.Map;

import com.google.gson.Gson;

public final class JsonResponse {
    private static final Gson GSON = new Gson();

    private JsonResponse() {
    }

    public static String validation(boolean valid, boolean duplicate, String message) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("valid", valid);
        body.put("duplicate", duplicate);
        body.put("message", message == null ? "" : message);
        return GSON.toJson(body);
    }
}
