package com.carrot.dto;

import lombok.Builder;
import lombok.Getter;
import java.time.LocalDateTime;

@Getter
@Builder
public class PayTransactionDTO {
    private long txId;               
    private long productId;          
    private String buyerId;         
    private String sellerId;        
    private int amount;              
    private String status;        
    private LocalDateTime createdAt; 
    private LocalDateTime updatedAt; 
}