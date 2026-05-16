<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%!
    private boolean isValidLoginId(String value) {
        return value != null && value.matches("^[A-Za-z0-9]{4,20}$");
    }

    private boolean isValidNickname(String value) {
        return value != null && value.trim().length() >= 2 && value.trim().length() <= 20;
    }

    private boolean isValidPhone(String value) {
        return value == null || value.trim().isEmpty() || value.trim().matches("^01[016789]-[0-9]{4}-[0-9]{4}$");
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

    String type = request.getParameter("type");
    String value = request.getParameter("value");
    value = value == null ? "" : value.trim();

    MemberDAO memberDAO = new MemberDAO();

    try {
        if ("loginId".equals(type)) {
            if (!isValidLoginId(value)) {
                out.print(json(false, false, "아이디는 4~20자의 영문, 숫자만 사용할 수 있습니다."));
                return;
            }

            boolean duplicate = memberDAO.isDuplicateLoginId(value);
            out.print(json(true, duplicate, duplicate ? "이미 사용 중인 아이디입니다." : "사용 가능한 아이디입니다."));
            return;
        }

        if ("nickname".equals(type)) {
            if (!isValidNickname(value)) {
                out.print(json(false, false, "닉네임은 2~20자로 입력해 주세요."));
                return;
            }

            boolean duplicate = memberDAO.isDuplicateNickname(value);
            out.print(json(true, duplicate, duplicate ? "이미 사용 중인 닉네임입니다." : "사용 가능한 닉네임입니다."));
            return;
        }

        if ("phone".equals(type)) {
            if (!isValidPhone(value)) {
                out.print(json(false, false, "연락처 뒷자리는 숫자 8자리로 입력해 주세요."));
                return;
            }

            if (value.isEmpty()) {
                out.print(json(true, false, ""));
                return;
            }

            boolean duplicate = memberDAO.isDuplicatePhone(value);
            out.print(json(true, duplicate, duplicate ? "이미 사용 중인 연락처입니다." : "사용 가능한 연락처입니다."));
            return;
        }

        out.print(json(false, false, "확인할 항목이 올바르지 않습니다."));
    } catch (Exception e) {
        out.print(json(false, false, "중복 확인 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요."));
    }
%>
