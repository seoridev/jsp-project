package com.carrot.dto;

import lombok.Builder;
import lombok.Getter;
import java.time.LocalDateTime;

@Getter
@Builder
public class UserAccountDTO {
    private String userId;
    private int balance;
    private LocalDateTime updatedAt;
}