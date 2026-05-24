<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%
	//파일 저장 경로 설정
    String savePath = request.getServletContext().getRealPath("/upload/chat");

    int maxSize = 10 * 1024 * 1024; // 최대 10MB 
    String encoding = "UTF-8";
    
    try {
        //MultipartRequest 객체 생성
        MultipartRequest multi = new MultipartRequest(
            request, savePath, maxSize, encoding, new DefaultFileRenamePolicy()
        );
        
        // 서버 시스템에 실제로 저장된 파일명 꺼내기
        String filesystemName = multi.getFilesystemName("imageFile");
        
        // 파일명만 결과로 출력
        if (filesystemName != null) {
            out.print(filesystemName);
        } else {
            out.print("FAIL");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.print("ERROR");
    }
%>