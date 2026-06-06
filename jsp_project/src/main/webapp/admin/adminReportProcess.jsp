<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.ReportDAO" %>
<%@ page import="com.carrot.util.AdminPageUtil" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    int reportId = AdminPageUtil.parseInt(request.getParameter("reportId"));
    String action = request.getParameter("action") == null ? "" : request.getParameter("action").trim();
    String searchType = request.getParameter("searchType");
    String keyword = request.getParameter("keyword");
    String statusFilter = request.getParameter("statusFilter");
    String listQuery = AdminPageUtil.productReportListQuery(searchType, keyword, statusFilter);

    ReportDAO reportDAO = new ReportDAO();
    boolean success = false;
    if (reportId > 0 && "hide".equals(action)) {
        success = reportDAO.processProductReport(reportId, "HIDE_PRODUCT");
    } else if (reportId > 0 && "reject".equals(action)) {
        success = reportDAO.processProductReport(reportId, "REJECT");
    }

    response.sendRedirect(request.getContextPath() + "/admin/adminReportList.jsp?" + listQuery + "&result=" + (success ? "success" : "fail"));
%>
