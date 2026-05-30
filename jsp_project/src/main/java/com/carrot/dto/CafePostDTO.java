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
public class CafePostDTO {
    private int postId;
    private int cafeId;
    private int boardId;
    private String writerId;
    private String title;
    private String content;
    private int viewCount;
    private int likeCount;
    private int commentCount;
    private String isNotice;
    private String isHidden;
    private String isDeleted;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private String writerNickname;
    private String writerRole;
    private String boardName;
    private String cafeName;
}
