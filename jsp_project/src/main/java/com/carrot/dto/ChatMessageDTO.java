package com.carrot.dto;

import java.sql.Timestamp;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class ChatMessageDTO {
	// 웹소켓 제어용 필드 
    private String type;      

    private int messageId;    
    private int roomId;       
    private String senderId;   
    private String message;    
    private String isRead;     
    private Timestamp createdAt;
}
