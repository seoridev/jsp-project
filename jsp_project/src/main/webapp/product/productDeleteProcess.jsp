<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%
    String loginIdForDelete = (String) session.getAttribute("loginId");

    try {
        long productId = Long.parseLong(request.getParameter("id"));
        boolean deleted = new ProductDAO().softDeleteProduct(productId, loginIdForDelete);

        if (deleted) {
            response.sendRedirect(request.getContextPath() + "/product/productList.jsp?delete=success");
        } else {
            response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?id=" + productId + "&error=deleteFail");
        }
    } catch (Exception e) {
        response.sendRedirect(request.getContextPath() + "/product/productList.jsp?error=invalid");
    }
%>
