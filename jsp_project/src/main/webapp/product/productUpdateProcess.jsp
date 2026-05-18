<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="DAO.ProductDAO"%>
<%@ page import="DAO.ProductImageDAO"%>
<%@ page import="DTO.ProductDTO"%>
<%@ page import="DTO.ProductImageDTO"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>

<%
    //파일 저장 경로 설정
    String savePath = request.getServletContext().getRealPath("/upload");
    int maxSize = 1024 * 1024 * 10; //최대 10MB
    String encoding = "UTF-8";

    try {
        //MultipartRequest 객체 생성
        MultipartRequest multi = new MultipartRequest(
            request, savePath, maxSize, encoding, new DefaultFileRenamePolicy()
        );

        int productId = Integer.parseInt(multi.getParameter("productId"));
        int categoryId = Integer.parseInt(multi.getParameter("categoryId"));
        String title = multi.getParameter("title");
        int price = Integer.parseInt(multi.getParameter("price"));
        String region = multi.getParameter("region");
        String content = multi.getParameter("content");
        int mainIndex = Integer.parseInt(multi.getParameter("mainImageIndex"));

        //ProductDTO 객체 생성 및 상품 등록
        ProductDTO product = ProductDTO.builder()
            .productId(productId)
            .categoryId(categoryId)
            .title(title)
            .price(price)
            .region(region)
            .content(content)
            .build();

    	ProductDAO productDao = new ProductDAO();
    	ProductImageDAO productImageDao = new ProductImageDAO();
    	
        int result = productDao.updateProduct(product); 

        if (result > 0) {
            List<ProductImageDTO> oldImages = productImageDao.selectImagesByProductId(productId);

            java.util.Set<String> maintainedFiles = new java.util.HashSet<>();
            for (int i = 0; i < 5; i++) {
                String existingName = multi.getParameter("existing_image_" + i);
                if (existingName != null) {
                    maintainedFiles.add(existingName);
                }
            }
            
            for (ProductImageDTO old : oldImages) {
                String oldSaveName = old.getSaveName();
                
                if (!maintainedFiles.contains(oldSaveName)) {
                    File f = new File(savePath + File.separator + oldSaveName);
                    if (f.exists()) {
                        f.delete();
                        System.out.println("삭제된 파일: " + oldSaveName);
                    }
                }
            }
            
            productImageDao.deleteImagesByProductId(productId);
            
            // 신규 리스트 등록 (새 파일 + 유지된 기존 파일 이름)
            for (int i = 0; i < 5; i++) {
                String isMain = (i == mainIndex) ? "Y" : "N";
                
                // 새로 업로드된 파일이 있는 경우
                if (multi.getFilesystemName("image_" + i) != null) {
                    String saveName = multi.getFilesystemName("image_" + i);
                    String originName = multi.getOriginalFileName("image_" + i);
                    
                    productImageDao.insertProductImage(ProductImageDTO.builder()
                        .productId(productId).originName(originName).saveName(saveName)
                        .imagePath("/upload/").isMain(isMain).build());
                } 
                // 기존에 있던 파일을 그대로 유지한 경우
                else if (multi.getParameter("existing_image_" + i) != null) {
                    String saveName = multi.getParameter("existing_image_" + i);
                    
                    // 기존 파일은 원본 이름을 알기 어려우므로 저장된 이름을 그대로 넣어줌
                    productImageDao.insertProductImage(ProductImageDTO.builder()
                        .productId(productId).originName(saveName).saveName(saveName)
                        .imagePath("/upload/").isMain(isMain).build());
                }
            }
            
            // 성공 시 상세페이지로 이동
            out.println("<script>alert('상품 정보가 수정되었습니다.'); location.href='productDetail.jsp?id=" + productId + "';</script>");
        } else {
            out.println("<script>alert('상품 정보 수정에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('에러 발생: " + e.getMessage() + "'); history.back();</script>");
    }
%>