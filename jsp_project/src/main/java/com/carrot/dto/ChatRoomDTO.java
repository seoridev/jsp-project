package com.carrot.dto;

import java.sql.Timestamp;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class ChatRoomDTO {
    
    private int roomId;        
    private String buyerId;     
    private int productId;      
    private String status;      
    private Timestamp createdAt;
}