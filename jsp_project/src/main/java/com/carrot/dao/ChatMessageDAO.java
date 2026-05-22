package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.carrot.dto.ChatMessageDTO;


public class ChatMessageDAO extends BaseDAO {

	// 채팅 메세지 삽입
    public int insertMessage(ChatMessageDTO dto) {
        String sql = "INSERT INTO CHAT_MESSAGE (MESSAGE_ID, ROOM_ID, SENDER_ID, MESSAGE, IS_READ, CREATED_AT) "
                   + "VALUES (SEQ_MESSAGE.NEXTVAL, ?, ?, ?, '1', SYSTIMESTAMP)";

        int result = 0;
        
		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, dto.getRoomId());
            pstmt.setString(2, dto.getSenderId());
            pstmt.setString(3, dto.getMessage()); 

            result = pstmt.executeUpdate();            
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }

	// 대화 내역 가져오기
    public List<ChatMessageDTO> getMessageListByRoomId(int roomId) {
        List<ChatMessageDTO> list = new ArrayList<>();

        String sql = "SELECT MESSAGE_ID, ROOM_ID, SENDER_ID, MESSAGE, IS_READ, CREATED_AT "
                   + "FROM CHAT_MESSAGE "
                   + "WHERE ROOM_ID = ? "
                   + "ORDER BY CREATED_AT ASC";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, roomId);
			try (ResultSet rs = pstmt.executeQuery()) {
	
	            while (rs.next()) {
	            	ChatMessageDTO dto = ChatMessageDTO.builder()
	            	        .messageId(rs.getInt("MESSAGE_ID"))
	            	        .roomId(rs.getInt("ROOM_ID"))
	            	        .senderId(rs.getString("SENDER_ID"))
	            	        .message(rs.getString("MESSAGE"))
	            	        .isRead(rs.getString("IS_READ"))
	            	        .createdAt(rs.getTimestamp("CREATED_AT"))
	            	        .type("TALK")
	            	        .build();	                
	                list.add(dto);
	            }
			}

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 메세지 읽음 처리
    public int updateMessageReadStatus(int roomId, String readerId) {
        // 내가 보낸 메시지가 아니면서 안 읽은 상태인 메시지들을 읽음으로 수정
        String sql = "UPDATE CHAT_MESSAGE SET IS_READ = '0' "
                   + "WHERE ROOM_ID = ? AND SENDER_ID != ? AND IS_READ = '1'";

		int result = 0;
        
		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, roomId);
            pstmt.setString(2, readerId);
            
            result = pstmt.executeUpdate();
            System.out.println("[DB 성공] 안 읽은 메시지 " + result + "건 읽음 처리 완료");

        } catch (Exception e) {
            e.printStackTrace();
        }
		
	    return result;
    }
}