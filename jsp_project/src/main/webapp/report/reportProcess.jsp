<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="DAO.ReportDAO" %>
<%@ page import="DTO.ReportDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
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

    String reporterId = (String) session.getAttribute("loginId");
    String targetType = request.getParameter("targetType") == null ? "PRODUCT" : request.getParameter("targetType").trim().toUpperCase();
    int targetId = parseIntParam(request.getParameter("targetId"));
    String reason = request.getParameter("reason") == null ? "" : request.getParameter("reason").trim();
    String detail = request.getParameter("detail") == null ? "" : request.getParameter("detail").trim();

    if (!"PRODUCT".equals(targetType) || targetId <= 0 || reason.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/report/report.jsp?targetType=PRODUCT&targetId=" + targetId + "&error=empty");
        return;
    }

    ReportDTO report = ReportDTO.builder()
        .reporterId(reporterId)
        .targetType(targetType)
        .targetId(targetId)
        .reason(reason)
        .detail(detail)
        .build();

    if (new ReportDAO().insertReport(report)) {
        response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?id=" + targetId + "&report=success");
    } else {
        response.sendRedirect(request.getContextPath() + "/report/report.jsp?targetType=PRODUCT&targetId=" + targetId + "&error=fail");
    }
%>
