<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.dto.MemberDTO" %>
<%!
private boolean isBlank(String value) {
    return value == null || value.trim().isEmpty();
}

private boolean isValidLoginId(String value) {
    return value != null && value.matches("^[A-Za-z0-9]{4,20}$");
}

private boolean isValidPassword(String value) {
    return value != null && value.matches("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d!@#$%^&*]{8,20}$");
}

private boolean isValidNickname(String value) {
    return value != null && value.trim().length() >= 2 && value.trim().length() <= 20;
}

private boolean isValidPhone(String value) {
    return value == null || value.trim().isEmpty() || value.trim().matches("^01[016789]-[0-9]{4}-[0-9]{4}$");
}

private boolean isValidRegion(String value) {
    return value != null && value.trim().length() >= 2;
}
%>
<%
request.setCharacterEncoding("UTF-8");

String loginId = request.getParameter("loginId");
String password = request.getParameter("password");
String passwordConfirm = request.getParameter("passwordConfirm");
String nickname = request.getParameter("nickname");
String phone = request.getParameter("phone");
String region = request.getParameter("region");
String contextPath = request.getContextPath();

if (isBlank(loginId) || isBlank(password) || isBlank(passwordConfirm) || isBlank(nickname) || isBlank(region)) {
    response.sendRedirect(contextPath + "/member/signupFail.jsp?error=empty");
    return;
}

loginId = loginId.trim();
nickname = nickname.trim();
phone = phone == null ? "" : phone.trim();
region = region.trim();

if (!isValidLoginId(loginId)) {
    response.sendRedirect(contextPath + "/member/signupFail.jsp?error=idRule");
    return;
}

if (!isValidPassword(password)) {
    response.sendRedirect(contextPath + "/member/signupFail.jsp?error=passwordRule");
    return;
}

if (!password.equals(passwordConfirm)) {
    response.sendRedirect(contextPath + "/member/signupFail.jsp?error=password");
    return;
}

if (!isValidNickname(nickname)) {
    response.sendRedirect(contextPath + "/member/signupFail.jsp?error=nicknameRule");
    return;
}

if (!isValidPhone(phone)) {
    response.sendRedirect(contextPath + "/member/signupFail.jsp?error=phoneRule");
    return;
}

if (!isValidRegion(region)) {
    response.sendRedirect(contextPath + "/member/signupFail.jsp?error=regionRule");
    return;
}

MemberDTO member = new MemberDTO();
member.setLoginId(loginId);
member.setPassword(password);
member.setNickname(nickname);
member.setPhone(phone);
member.setRegion(region);
member.setStatus("ACTIVE");

MemberDAO memberDAO = new MemberDAO();

try {
    if (memberDAO.isDuplicateLoginId(member.getLoginId())) {
        response.sendRedirect(contextPath + "/member/signupFail.jsp?error=duplicate");
        return;
    }

    boolean inserted = memberDAO.insertMember(member);
    if (inserted) {
        response.sendRedirect(contextPath + "/member/signupSuccess.jsp");
    } else {
        response.sendRedirect(contextPath + "/member/signupFail.jsp?error=fail");
    }
} catch (SQLException e) {
    if (e.getErrorCode() == 1) {
        response.sendRedirect(contextPath + "/member/signupFail.jsp?error=duplicate");
    } else {
        response.sendRedirect(contextPath + "/member/signupFail.jsp?error=db");
    }
} catch (Exception e) {
    response.sendRedirect(contextPath + "/member/signupFail.jsp?error=db");
}
%>
