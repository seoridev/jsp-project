<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.ChatRoomDAO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%

    String buyerId = (String) session.getAttribute("loginId"); 

    // 파라미터 유효성 검증
    String productParam = request.getParameter("productId");
    if (productParam == null || productParam.trim().isEmpty()) {
        out.println("<script>");
        out.println("alert('잘못된 접근입니다. 상품 정보가 없습니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    int productId = 0;
    try {
        productId = Integer.parseInt(productParam);
    } catch (NumberFormatException e) {
        out.println("<script>");
        out.println("alert('올바르지 않은 상품 번호입니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    // 채팅방 가져오기 또는 생성하기
    ChatRoomDAO dao = new ChatRoomDAO();
    int roomId = dao.getOrCreateRoom(buyerId, productId);

    //  결과에 따른 페이지 이동
    if (roomId > 0) {
        response.sendRedirect("chatRoom.jsp?roomId=" + roomId);
    } else {
        // 실패 시
        out.println("<script>");
        out.println("alert('채팅방 개설에 실패했습니다. 잠시 후 다시 시도해주세요.');");
        out.println("history.back();");
        out.println("</script>");
    }
%>