<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ include file="../common/adminSessionCheck.jsp" %>
<%!
    private long parseLongParam(String value) {
        try {
            return value == null ? 0 : Long.parseLong(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private boolean isAllowedStatus(String status) {
        return "SALE".equals(status) || "RESERVED".equals(status) || "SOLD".equals(status) || "HIDDEN".equals(status);
    }

    private boolean isAllowedSearchType(String searchType) {
        return "title".equals(searchType) || "seller".equals(searchType);
    }

    private String encodeParam(String value) {
        try {
            return URLEncoder.encode(value == null ? "" : value, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }

    private String buildListQuery(String searchType, String keyword, String status) {
        String safeSearchType = isAllowedSearchType(searchType) ? searchType : "title";
        String safeStatus = status == null || status.trim().isEmpty() ? "ALL" : status.trim().toUpperCase();
        return "searchType=" + encodeParam(safeSearchType)
            + "&keyword=" + encodeParam(keyword)
            + "&status=" + encodeParam(safeStatus);
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    long productId = parseLongParam(request.getParameter("productId"));
    String status = request.getParameter("status") == null ? "" : request.getParameter("status").trim().toUpperCase();
    String searchType = request.getParameter("searchType");
    String keyword = request.getParameter("keyword");
    String statusFilter = request.getParameter("statusFilter");
    String listQuery = buildListQuery(searchType, keyword, statusFilter);

    if (productId <= 0 || !isAllowedStatus(status)) {
        response.sendRedirect(request.getContextPath() + "/admin/adminProductList.jsp?" + listQuery + "&result=fail");
        return;
    }

    boolean success = new ProductDAO().updateProductStatusForAdmin(productId, status);
    response.sendRedirect(request.getContextPath() + "/admin/adminProductList.jsp?" + listQuery + "&result=" + (success ? "success" : "fail"));
%>
