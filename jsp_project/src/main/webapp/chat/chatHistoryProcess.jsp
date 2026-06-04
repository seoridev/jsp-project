<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.ChatMessageDAO" %>
<%@ page import="com.carrot.dto.ChatMessageDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.gson.Gson" %>
<%
    String userId = (String) session.getAttribute("loginId");
    String roomParam = request.getParameter("roomId");
    
    if (roomParam == null || userId == null) {
        out.print("[]");
        return;
    }
    
    int roomId = Integer.parseInt(roomParam);
    List<ChatMessageDTO> oldMessageList = new ChatMessageDAO().getMessageListByRoomId(roomId);
    
    Gson gson = new Gson();
    String jsonHistory = gson.toJson(oldMessageList);
    
    out.print(jsonHistory);
%>