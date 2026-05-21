package com.carrot.server;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import com.carrot.dao.ChatMessageDAO;
import com.carrot.dto.ChatMessageDTO;
import com.google.gson.Gson;

import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;


@ServerEndpoint("/chatServer/{roomId}/{userId}")
public class ChatServer {

    // 각 채팅방(roomId)별로 접속해 있는 세션(Session)들을 관리하는 Map
    private static Map<Integer, Set<Session>> roomSessionMap = Collections.synchronizedMap(new HashMap<>());
    
    // 유저 ID와 세션을 매핑
    private static Map<Session, String> sessionUserMap = Collections.synchronizedMap(new HashMap<>());

    private Gson gson = new Gson();
    private ChatMessageDAO chatDAO = new ChatMessageDAO();

    //클라이언트가 웹소켓에 연결되었을 때 호출
    @OnOpen
    public void onOpen(Session session, @PathParam("roomId") int roomId, @PathParam("userId") String userId) {
        System.out.println("[웹소켓 연결] 방번호: " + roomId + ", 유저: " + userId + ", 세션ID: " + session.getId());

        // 해당 방의 세션 리스트가 없으면 새로 생성, 있으면 가져옴
        if (!roomSessionMap.containsKey(roomId)) {
            roomSessionMap.put(roomId, Collections.synchronizedSet(new HashSet<>()));
        }
        
        // 방 세션 리스트에 현재 접속한 유저의 세션 추가
        roomSessionMap.get(roomId).add(session);
        
        // 세션-유저ID 매핑 정보 저장
        sessionUserMap.put(session, userId);

        System.out.println("현재 " + roomId + "번 방 동시 접속자 수: " + roomSessionMap.get(roomId).size());
    }
    
    // 클라이언트로부터 메시지가 도착했을 때 호출
    @OnMessage
    public void onMessage(String messageJson, Session session, @PathParam("roomId") int roomId) {
        System.out.println("[메시지 수신] 방번호 " + roomId + "로부터 메시지: " + messageJson);

        try {
            // 수신한 JSON 문자열을 DTO 객체로 변환
            ChatMessageDTO messageDto = gson.fromJson(messageJson, ChatMessageDTO.class);
            
            // DB에 대화 내역 저장
            chatDAO.insertMessage(messageDto);
            
            // 현재 같은 채팅방(roomId)에 접속해 있는 모든 세션에게 메시지 브로드캐스팅
            Set<Session> roomSessions = roomSessionMap.get(roomId);
            if (roomSessions != null) {
                // DTO를 다시 JSON 문자열로 변환하여 전송
                String broadcastMessage = gson.toJson(messageDto);
                
                synchronized (roomSessions) {
                    for (Session clientSession : roomSessions) {
                        // 상대방뿐만 아니라 본인 세션에도 보내서 화면을 갱신하게 하거나, 
                        // 상대방에게만 보낼지 여부는 프론트엔드 구현에 따라 분기 가능합니다.
                        if (clientSession.isOpen()) {
                            clientSession.getBasicRemote().sendText(broadcastMessage);
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            System.err.println("메시지 처리 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // 클라이언트와 연결이 끊겼을 때 호출
    @OnClose
    public void onClose(Session session, @PathParam("roomId") int roomId) {
        System.out.println("[웹소켓 종료] 세션ID: " + session.getId() + " 가 방 " + roomId + "에서 퇴장합니다.");

        // 해당 방의 세션 리스트에서 제거
        Set<Session> roomSessions = roomSessionMap.get(roomId);
        if (roomSessions != null) {
            roomSessions.remove(session);
            
            // 만약 방에 아무도 없다면 Map에서 방 자체를 제거
            if (roomSessions.isEmpty()) {
                roomSessionMap.remove(roomId);
                System.out.println(roomId + "번 방에 남은 인원이 없어 방 관리 리스트에서 삭제됨");
            }
        }
        
        // 세션-유저ID 매핑 테이블에서도 제거
        sessionUserMap.remove(session);
    }

    // 에러 발생시 호출
    @OnError
    public void onError(Session session, Throwable throwable) {
        System.err.println("[웹소켓 에러 발생] 세션ID: " + session.getId());
        throwable.printStackTrace();
    }
}