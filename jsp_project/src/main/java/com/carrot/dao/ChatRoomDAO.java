package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.ChatRoomDTO;

public class ChatRoomDAO extends BaseDAO {

	// 기존 채팅방이 있는지 확인하고, 없으면 생성 후 방 번호 반환
    public int getOrCreateRoom(String buyerId, int productId) {
        String selectSql = "SELECT ROOM_ID FROM CHAT_ROOM WHERE BUYER_ID = ? AND PRODUCT_ID = ? AND STATUS = 'OPEN'";
        String insertSql = "INSERT INTO CHAT_ROOM (ROOM_ID, BUYER_ID, PRODUCT_ID, STATUS, CREATED_AT) "
                         + "VALUES (?, ?, ?, 'OPEN', SYSTIMESTAMP)";
        String seqSql = "SELECT SEQ_ROOM.NEXTVAL FROM DUAL";

        try (Connection conn = getConnection()) {
            
            // 기존 방이 있는지 조회
            try (PreparedStatement selectPstmt = conn.prepareStatement(selectSql)) {
                selectPstmt.setString(1, buyerId);
                selectPstmt.setInt(2, productId);
                
                try (ResultSet rs = selectPstmt.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("ROOM_ID"); // 기존 방이 있으면 바로 반환
                    }
                }
            }

            // 기존 방이 없으므로 시퀀스로부터 신규 ROOM_ID 번호 먼저 확보하기
            int nextRoomId = 0;
            try (PreparedStatement seqPstmt = conn.prepareStatement(seqSql);
                 ResultSet rs = seqPstmt.executeQuery()) {
                if (rs.next()) {
                    nextRoomId = rs.getInt(1);
                }
            }

            // 시퀀스를 정상적으로 가져오지 못한 예외 상황 처리
            if (nextRoomId == 0) {
                return 0;
            }

            // 신규 생성
            try (PreparedStatement insertPstmt = conn.prepareStatement(insertSql)) {
                insertPstmt.setInt(1, nextRoomId); // 위에서 뽑은 시퀀스 번호를 1번에 바인딩
                insertPstmt.setString(2, buyerId);
                insertPstmt.setInt(3, productId);
                
                int result = insertPstmt.executeUpdate();

                // 성공적으로 행이 추가되었다면 미리 확보해 둔 번호를 그대로 반환
                if (result > 0) {
                    return nextRoomId;
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0; 
    }


    // 웹소켓 검증용 방 체크
    public boolean checkChatRoomExist(int roomId) {
        String sql = "SELECT 1 FROM CHAT_ROOM WHERE ROOM_ID = ? AND STATUS = 'OPEN'";

        try (Connection conn = getConnection(); 
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return false;
    }

    
    // 구매자와 판매자 모두를 고려한 채팅방 리스트 가져오기
    public List<ChatRoomDTO> getRoomListByUserId(String userId) {
        // 내가 구매자인 방 이거나, 해당 상품의 판매자인 방을 모두 조회
        String sql = "SELECT CR.ROOM_ID, CR.BUYER_ID, CR.PRODUCT_ID, CR.STATUS, CR.CREATED_AT "
                   + "FROM CHAT_ROOM CR "
                   + "JOIN PRODUCT P ON CR.PRODUCT_ID = P.PRODUCT_ID "
                   + "WHERE (CR.BUYER_ID = ? OR P.SELLER_ID = ?) AND CR.STATUS = 'OPEN' "
                   + "ORDER BY CR.CREATED_AT DESC";

        List<ChatRoomDTO> list = new ArrayList<>();

        try (Connection conn = getConnection(); 
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, userId);
            pstmt.setString(2, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ChatRoomDTO dto = ChatRoomDTO.builder()
                            .roomId(rs.getInt("ROOM_ID"))
                            .buyerId(rs.getString("BUYER_ID"))
                            .productId(rs.getInt("PRODUCT_ID"))
                            .status(rs.getString("STATUS"))
                            .createdAt(rs.getTimestamp("CREATED_AT"))
                            .build();
                    
                    list.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return list;
    }
}