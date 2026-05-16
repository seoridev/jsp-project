<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%!
    private boolean editBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    String loginIdForEdit = (String) session.getAttribute("loginId");

    try {
        int productId = Integer.parseInt(request.getParameter("productId"));
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        int price = Integer.parseInt(request.getParameter("price"));
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String region = request.getParameter("region");

        if (editBlank(title) || editBlank(content) || editBlank(region)) {
            response.sendRedirect(request.getContextPath() + "/product/productEdit.jsp?id=" + productId + "&error=empty");
            return;
        }

        ProductDTO product = ProductDTO.builder()
            .productId(productId)
            .sellerId(loginIdForEdit)
            .categoryId(categoryId)
            .title(title.trim())
            .content(content.trim())
            .price(price)
            .region(region.trim())
            .build();

        boolean updated = new ProductDAO().updateProduct(product, loginIdForEdit);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?id=" + productId);
        } else {
            response.sendRedirect(request.getContextPath() + "/product/productEdit.jsp?id=" + productId + "&error=fail");
        }
    } catch (Exception e) {
        response.sendRedirect(request.getContextPath() + "/product/productList.jsp?error=invalid");
    }
%>
