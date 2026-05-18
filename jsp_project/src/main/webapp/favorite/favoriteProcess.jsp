<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="DAO.FavoriteDAO" %>
<%@ page import="DAO.ProductDAO" %>
<%@ page import="DTO.ProductDTO" %>
<%
    request.setCharacterEncoding("UTF-8");

    String loginId = (String) session.getAttribute("loginId");
    if (loginId == null) {
        response.sendRedirect(request.getContextPath() + "/member/login.jsp?error=loginRequired");
        return;
    }

    long productId = 0;
    try {
        String idValue = request.getParameter("productId");
        if (idValue == null || idValue.trim().isEmpty()) {
            idValue = request.getParameter("id");
        }
        productId = idValue == null ? 0 : Long.parseLong(idValue);
    } catch (NumberFormatException e) {
        productId = 0;
    }

    String source = request.getParameter("source");
    if (productId <= 0) {
        if ("list".equals(source)) {
            response.sendRedirect(request.getContextPath() + "/favorite/favoriteList.jsp?error=invalid");
        } else {
            response.sendRedirect(request.getContextPath() + "/product/productList.jsp?error=noProduct");
        }
        return;
    }

    ProductDTO product = new ProductDAO().selectProductById(productId);
    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/product/productList.jsp?error=noProduct");
        return;
    }

    if (loginId.equals(product.getSellerId())) {
        response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?id=" + productId + "&favorite=own");
        return;
    }

    String result = new FavoriteDAO().toggleFavorite(loginId, productId);
    if ("list".equals(source)) {
        response.sendRedirect(request.getContextPath() + "/favorite/favoriteList.jsp?favorite=" + result);
        return;
    }

    response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?id=" + productId + "&favorite=" + result);
%>
