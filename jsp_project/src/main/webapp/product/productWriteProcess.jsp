<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="DAO.ProductDAO"%>
<%@ page import="DAO.ProductImageDAO"%>
<%@ page import="DTO.ProductDTO"%>
<%@ page import="DTO.ProductImageDTO"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.File" %>
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

        String sellerId = multi.getParameter("sellerId");
        int categoryId = Integer.parseInt(multi.getParameter("categoryId"));
        String title = multi.getParameter("title");
        int price = Integer.parseInt(multi.getParameter("price"));
        String region = multi.getParameter("region");
        String content = multi.getParameter("content");

        //ProductDTO 객체 생성 및 상품 등록
        ProductDTO product = ProductDTO.builder()
            .sellerId(sellerId)
            .categoryId(categoryId)
            .title(title)
            .price(price)
            .region(region)
            .content(content)
            .build();

    	ProductDAO productDao = new ProductDAO();
    	ProductImageDAO productImageDao = new ProductImageDAO();
        int result = productDao.insertProduct(product); 

        if (result > 0) {
        	int productId = productDao.selectLastProductId(); 

            String mainIdxParam = multi.getParameter("mainImageIndex");
            int mainIndex = (mainIdxParam != null) ? Integer.parseInt(mainIdxParam) : 0;
            
            Enumeration files = multi.getFileNames();
            
            while (files != null && files.hasMoreElements()) {
                String name = (String) files.nextElement();
                String originName = multi.getOriginalFileName(name);
                String saveName = multi.getFilesystemName(name);

                if (saveName != null) {
                    int fileIndex = 0;
                    try {
                        fileIndex = Integer.parseInt(name.substring(6)); 
                    } catch(Exception e) {
                        fileIndex = -1;
                    }

                    String isMain = (fileIndex == mainIndex) ? "Y" : "N";

                    ProductImageDTO imageDTO = ProductImageDTO.builder()
                        .productId(productId)
                        .originName(originName)
                        .saveName(saveName)
                        .imagePath("/upload/")
                        .isMain(isMain)
                        .build();

                    productImageDao.insertProductImage(imageDTO);
                }
            }
            
            //등록 성공 시 목록으로 이동
            response.sendRedirect("productList.jsp");
        } else {
            out.println("<script>alert('상품 등록에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('에러 발생: " + e.getMessage() + "'); history.back();</script>");
    }
%>