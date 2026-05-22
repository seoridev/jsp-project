<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.ProductDAO"%>
<%@ page import="com.carrot.dao.ProductImageDAO"%>
<%@ page import="com.carrot.dto.ProductDTO"%>
<%@ page import="com.carrot.dto.ProductImageDTO"%>
<%@ page import="java.util.List" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>

<%
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='productList.jsp';</script>");
        return;
    }

    int productId = Integer.parseInt(idParam);
	ProductDAO productDao = new ProductDAO();
	ProductImageDAO productImageDao = new ProductImageDAO();

    // 서버에 저장된 실제 이미지 파일들 삭제
    List<ProductImageDTO> images = productImageDao.selectImagesByProductId(productId);
    String savePath = request.getServletContext().getRealPath("/upload");

    if (images != null) {
        for (ProductImageDTO img : images) {
            File file = new File(savePath + File.separator + img.getSaveName());
            if (file.exists()) {
                file.delete();
            }
        }
    }

    // DB 데이터 삭제
    int result = productDao.deleteProduct(productId);

    if (result > 0) {
        out.println("<script>alert('삭제되었습니다.'); location.href='productList.jsp';</script>");
    } else {
        out.println("<script>alert('삭제에 실패했습니다.'); history.back();</script>");
    }
%>