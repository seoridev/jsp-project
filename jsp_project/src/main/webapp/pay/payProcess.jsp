<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.PayDAO" %>
<%
    request.setCharacterEncoding("UTF-8");

    String loginId = (String) session.getAttribute("loginId");
    String action = request.getParameter("action"); 
    int amount = Integer.parseInt(request.getParameter("amount"));
    
    PayDAO payDao = new PayDAO();
    String alertMsg = "";

    if ("charge".equals(action)) {
        if (payDao.chargePay(loginId, amount)) {
            alertMsg = "동네페이 " + amount + "원이 안전하게 충전되었습니다.";
        } else {
            alertMsg = "충전에 실패했습니다. 시스템 오류를 확인하세요.";
        }
    } else if ("withdraw".equals(action)) {
        if (payDao.withdrawPay(loginId, amount)) {
            alertMsg = "입력하신 " + amount + "원이 연동 계좌로 환급되었습니다.";
        } else {
            alertMsg = "환급에 실패했습니다. 잔액이 부족하거나 계좌 상태를 확인하세요.";
        }
    }
%>
<script>
    alert("<%= alertMsg %>");
    location.href = "payInOut.jsp";
</script>