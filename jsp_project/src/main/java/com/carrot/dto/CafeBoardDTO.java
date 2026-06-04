package com.carrot.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CafeBoardDTO {
    private int boardId;
    private int cafeId;
    private String boardName;
    private String description;
    private String readPermission;
    private String writePermission;
    private String isNotice;
    private String isAdminOnly;
    private int displayOrder;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private int postCount;
}
