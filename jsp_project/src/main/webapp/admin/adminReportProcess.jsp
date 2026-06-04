<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.carrot.dao.ReportDAO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private boolean isAllowedSearchType(String searchType) {
        return "product".equals(searchType) || "reporter".equals(searchType);
    }

    private String encodeParam(String value) {
        try {
            return URLEncoder.encode(value == null ? "" : value, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }

    private String buildListQuery(String searchType, String keyword, String status) {
        String safeSearchType = isAllowedSearchType(searchType) ? searchType : "product";
        String safeStatus = status == null || status.trim().isEmpty() ? "ALL" : status.trim().toUpperCase();
        return "searchType=" + encodeParam(safeSearchType)
            + "&keyword=" + encodeParam(keyword)
            + "&status=" + encodeParam(safeStatus);
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    int reportId = parseIntParam(request.getParameter("reportId"));
    int targetId = parseIntParam(request.getParameter("targetId"));
    String action = request.getParameter("action") == null ? "" : request.getParameter("action").trim();
    String searchType = request.getParameter("searchType");
    String keyword = request.getParameter("keyword");
    String statusFilter = request.getParameter("statusFilter");
    String listQuery = buildListQuery(searchType, keyword, statusFilter);

    ReportDAO reportDAO = new ReportDAO();
    boolean success = false;
    if (reportId > 0 && "hide".equals(action) && targetId > 0) {
        success = reportDAO.processReportAndHideProduct(reportId, targetId);
    } else if (reportId > 0 && "done".equals(action)) {
        success = reportDAO.processReport(reportId, "DONE");
    } else if (reportId > 0 && "reject".equals(action)) {
        success = reportDAO.processReport(reportId, "REJECTED");
    }

    response.sendRedirect(request.getContextPath() + "/admin/adminReportList.jsp?" + listQuery + "&result=" + (success ? "success" : "fail"));
%>
