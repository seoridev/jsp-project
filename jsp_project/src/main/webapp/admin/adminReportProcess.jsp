<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
%>
<%
    request.setCharacterEncoding("UTF-8");
    int reportId = parseIntParam(request.getParameter("reportId"));
    int targetId = parseIntParam(request.getParameter("targetId"));
    String action = request.getParameter("action") == null ? "" : request.getParameter("action").trim();

    ReportDAO reportDAO = new ReportDAO();
    boolean success = false;
    if (reportId > 0 && "hide".equals(action) && targetId > 0) {
        success = reportDAO.processReportAndHideProduct(reportId, targetId);
    } else if (reportId > 0 && "done".equals(action)) {
        success = reportDAO.processReport(reportId, "DONE");
    } else if (reportId > 0 && "reject".equals(action)) {
        success = reportDAO.processReport(reportId, "REJECTED");
    }

    response.sendRedirect(request.getContextPath() + "/admin/adminReportList.jsp?result=" + (success ? "success" : "fail"));
%>
