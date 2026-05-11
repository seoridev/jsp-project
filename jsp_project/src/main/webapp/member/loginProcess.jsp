<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ page import="com.carrot.dto.MemberDTO" %>
<%!
private boolean isBlank(String value) {
    return value == null || value.trim().isEmpty();
}
%>
<%
request.setCharacterEncoding("UTF-8");

String loginId = request.getParameter("loginId");
String password = request.getParameter("password");
String contextPath = request.getContextPath();

if (isBlank(loginId) || isBlank(password)) {
    response.sendRedirect(contextPath + "/member/login.jsp?error=empty");
    return;
}

MemberDAO memberDAO = new MemberDAO();

try {
    MemberDTO savedMember = memberDAO.getMemberByLoginId(loginId.trim());

    if (savedMember == null) {
        response.sendRedirect(contextPath + "/member/login.jsp?error=noMember");
        return;
    }

    if (savedMember.getStatus() != null && !"ACTIVE".equalsIgnoreCase(savedMember.getStatus())) {
        response.sendRedirect(contextPath + "/member/login.jsp?error=stopped");
        return;
    }

    MemberDTO loginMember = memberDAO.login(loginId.trim(), password);
    if (loginMember == null) {
        response.sendRedirect(contextPath + "/member/login.jsp?error=password");
        return;
    }

    session.setAttribute("loginId", loginMember.getLoginId());
    session.setAttribute("loginNickname", loginMember.getNickname());
    session.setAttribute("loginRegion", loginMember.getRegion());
    session.setMaxInactiveInterval(60 * 30);

    response.sendRedirect(contextPath + "/index.jsp");
} catch (Exception e) {
    response.sendRedirect(contextPath + "/member/login.jsp?error=db");
}
%>
