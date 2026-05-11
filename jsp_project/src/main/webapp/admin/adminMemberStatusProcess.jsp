<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.carrot.dao.MemberDAO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
private boolean isAllowedStatus(String status) {
    return "ACTIVE".equals(status) || "STOPPED".equals(status) || "WITHDRAWN".equals(status);
}

private boolean isAllowedSearchType(String searchType) {
    return "loginId".equals(searchType) || "nickname".equals(searchType)
        || "phone".equals(searchType) || "region".equals(searchType);
}

private String encodeParam(String value) {
    try {
        return URLEncoder.encode(value == null ? "" : value, "UTF-8");
    } catch (Exception e) {
        return "";
    }
}

private String buildListQuery(String searchType, String keyword, String status, String page) {
    return "searchType=" + encodeParam(isAllowedSearchType(searchType) ? searchType : "loginId")
        + "&keyword=" + encodeParam(keyword)
        + "&status=" + encodeParam(status == null || status.isEmpty() ? "ALL" : status)
        + "&page=" + encodeParam(page == null || page.isEmpty() ? "1" : page);
}
%>
<%
request.setCharacterEncoding("UTF-8");

String loginId = request.getParameter("loginId");
String status = request.getParameter("status");
String searchType = request.getParameter("searchType");
String keyword = request.getParameter("keyword");
String statusFilter = request.getParameter("statusFilter");
String pageNumber = request.getParameter("page");
String origin = request.getParameter("origin");
String contextPath = request.getContextPath();
String listQuery = buildListQuery(searchType, keyword, statusFilter, pageNumber);

String redirectUrl = contextPath + "/admin/adminMemberList.jsp?" + listQuery;
if ("detail".equals(origin) && loginId != null && !loginId.trim().isEmpty()) {
    redirectUrl = contextPath + "/admin/adminMemberDetail.jsp?loginId="
        + encodeParam(loginId.trim()) + "&" + listQuery;
}

if (loginId == null || loginId.trim().isEmpty() || !isAllowedStatus(status)) {
    response.sendRedirect(redirectUrl + "&result=fail");
    return;
}

try {
    boolean updated = new MemberDAO().updateMemberStatus(loginId.trim(), status);
    response.sendRedirect(redirectUrl + "&result=" + (updated ? "success" : "fail"));
} catch (Exception e) {
    response.sendRedirect(redirectUrl + "&result=fail");
}
%>
