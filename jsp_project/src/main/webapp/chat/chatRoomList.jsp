<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.ChatRoomDAO" %>
<%@ page import="com.carrot.dto.ChatRoomDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%
	String currentLoginId = (String) session.getAttribute("loginId");

    List<ChatRoomDTO> roomList = new ChatRoomDAO().getRoomListByUserId(currentLoginId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>동네마켓 - 채팅 목록</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell">
    <div class="admin-heading">
        <div>
            <h1>채팅 목록</h1>
            <p style="margin: 6px 0 0; color: #756b61; font-weight: 700;">대화 중인 채팅방을 확인할 수 있습니다.</p>
        </div>
        <div class="admin-actions">
            <button onclick="location.reload();">새로고침</button>
        </div>
    </div>

    <!-- 채팅 리스트 컨테이너 (admin-table-wrap 재활용) -->
    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th style="width: 15%;">방 번호</th>
                    <th style="width: 20%;">구매 희망자</th>
                    <th style="width: 25%;">관련 상품 번호</th>
                    <th style="width: 20%;">생성일</th>
                    <th style="width: 20%; text-align: center;">대화하기</th>
                </tr>
            </thead>
            <tbody>
                <%
                    if (roomList == null || roomList.isEmpty()) {
                %>
                    <tr>
                        <td colspan="5" class="empty-cell">
                            진행 중인 채팅방이 없습니다. <br>
                            <span style="font-size: 13px; color: #a0958a;">상품 상세 페이지에서 대화를 시작해 보세요!</span>
                        </td>
                    </tr>
                <%
                    } else {
                        for (ChatRoomDTO room : roomList) {
                %>
                    <tr>
                        <td><strong>#<%= room.getRoomId() %></strong></td>
                        <td>
                            <span class="status-badge is-active"><%= room.getBuyerId() %></span>
                        </td>
                        <td>
                            <a href="${pageContext.request.contextPath}/product/productDetail.jsp?id=<%= room.getProductId() %>" class="table-link">
                                <%= room.getProductId() %>번 상품 보기
                            </a>
                        </td>
                        <td>
                            <span style="color: #756b61; font-size: 13px;">
                                <%= room.getCreatedAt().toString().substring(0, 16) %>
                            </span>
                        </td>
                        <td style="text-align: center;">
                            <!-- 클릭 시 해당 채팅방 상세 페이지(대화창)로 이동 -->
                            <a href="${pageContext.request.contextPath}/chat/chatRoom.jsp?roomId=<%= room.getRoomId() %>" class="button primary" style="min-height: 34px; padding: 0 12px; font-size: 13px;">
                                입장하기
                            </a>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
            </tbody>
        </table>
    </div>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>