<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%!
    private boolean isValidCafeName(String value) {
        return value != null && !value.trim().isEmpty() && value.trim().length() <= 100;
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        return value
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\r", "\\r")
            .replace("\n", "\\n");
    }

    private String json(boolean valid, boolean duplicate, String message) {
        return "{\"valid\":" + valid
            + ",\"duplicate\":" + duplicate
            + ",\"message\":\"" + escapeJson(message) + "\"}";
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String cafeName = request.getParameter("cafeName");
    cafeName = cafeName == null ? "" : cafeName.trim();

    try {
        if (!isValidCafeName(cafeName)) {
            out.print(json(false, false, "카페명을 1~100자로 입력해 주세요."));
            return;
        }

        CafeDAO cafeDao = new CafeDAO();
        boolean duplicate = cafeDao.isDuplicateCafeName(cafeName);
        out.print(json(true, duplicate, duplicate ? "이미 사용 중인 카페명입니다." : "사용 가능한 카페명입니다."));
    } catch (Exception e) {
        out.print(json(false, false, "중복 확인 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요."));
    }
%>
