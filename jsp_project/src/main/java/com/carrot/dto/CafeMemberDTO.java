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
public class CafeMemberDTO {
    private int cafeMemberId;
    private int cafeId;
    private String memberId;
    private String role;
    private String status;
    private LocalDateTime joinedAt;
    private LocalDateTime updatedAt;

    private String nickname;
    private String region;
}
