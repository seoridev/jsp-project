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
public class CafeDTO {
    private int cafeId;
    private String cafeName;
    private String description;
    private String imagePath;
    private String region;
    private String category;
    private String visibility;
    private String joinType;
    private String ownerId;
    private String status;
    private int memberCount;
    private int postCount;
    private int viewCount;
    private LocalDateTime lastActiveAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private String ownerNickname;
    private String myMemberStatus;
    private String myRole;
}
