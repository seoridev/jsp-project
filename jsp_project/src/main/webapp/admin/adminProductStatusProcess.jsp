<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="DAO.ProductDAO" %>
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
%>
<%
    request.setCharacterEncoding("UTF-8");
    long productId = parseLongParam(request.getParameter("productId"));
    String status = request.getParameter("status") == null ? "" : request.getParameter("status").trim().toUpperCase();

    if (productId <= 0 || !isAllowedStatus(status)) {
        response.sendRedirect(request.getContextPath() + "/admin/adminProductList.jsp?result=fail");
        return;
    }

    boolean success = new ProductDAO().updateProductStatusForAdmin(productId, status);
    response.sendRedirect(request.getContextPath() + "/admin/adminProductList.jsp?result=" + (success ? "success" : "fail"));
%>
