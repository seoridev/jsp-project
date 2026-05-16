<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dao.ProductImageDAO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ page import="com.carrot.dto.ProductImageDTO" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%!
    private boolean productBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
%>
<%
    String loginIdForProduct = (String) session.getAttribute("loginId");
    if (loginIdForProduct == null) {
        response.sendRedirect(request.getContextPath() + "/member/login.jsp?error=loginRequired");
        return;
    }

    String uploadPath = "/upload/product/";
    String savePath = request.getServletContext().getRealPath(uploadPath);
    File uploadDir = new File(savePath);
    if (!uploadDir.exists()) {
        uploadDir.mkdirs();
    }

    int maxSize = 1024 * 1024 * 10;
    String encoding = "UTF-8";

    try {
        MultipartRequest multi = new MultipartRequest(
            request, savePath, maxSize, encoding, new DefaultFileRenamePolicy()
        );

        String title = multi.getParameter("title");
        String content = multi.getParameter("content");
        String region = multi.getParameter("region");

        if (productBlank(title) || productBlank(content) || productBlank(region)) {
            response.sendRedirect(request.getContextPath() + "/product/productWrite.jsp?error=empty");
            return;
        }

        int categoryId = Integer.parseInt(multi.getParameter("categoryId"));
        int price = Integer.parseInt(multi.getParameter("price"));
        int mainImageIndex = Integer.parseInt(multi.getParameter("mainImageIndex"));

        ProductDTO product = ProductDTO.builder()
            .sellerId(loginIdForProduct)
            .categoryId(categoryId)
            .title(title.trim())
            .content(content.trim())
            .price(price)
            .region(region.trim())
            .build();

        ProductDAO productDAO = new ProductDAO();
        ProductImageDAO imageDAO = new ProductImageDAO();
        int productId = productDAO.insertProduct(product);

        if (productId <= 0) {
            response.sendRedirect(request.getContextPath() + "/product/productWrite.jsp?error=fail");
            return;
        }

        List<Integer> uploadedIndexes = new ArrayList<>();
        for (int i = 0; i < 5; i++) {
            if (multi.getFilesystemName("image_" + i) != null) {
                uploadedIndexes.add(i);
            }
        }

        boolean selectedMainExists = uploadedIndexes.contains(mainImageIndex);
        int fallbackMainIndex = uploadedIndexes.isEmpty() ? -1 : uploadedIndexes.get(0);

        for (Integer index : uploadedIndexes) {
            String fieldName = "image_" + index;
            String saveName = multi.getFilesystemName(fieldName);
            String originName = multi.getOriginalFileName(fieldName);
            boolean isMain = selectedMainExists ? index == mainImageIndex : index == fallbackMainIndex;

            ProductImageDTO image = ProductImageDTO.builder()
                .productId(productId)
                .originName(originName)
                .saveName(saveName)
                .imagePath(uploadPath)
                .isMain(isMain ? "Y" : "N")
                .build();
            imageDAO.insertProductImage(image);
        }

        response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?id=" + productId);
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(request.getContextPath() + "/product/productWrite.jsp?error=fail");
    }
%>
