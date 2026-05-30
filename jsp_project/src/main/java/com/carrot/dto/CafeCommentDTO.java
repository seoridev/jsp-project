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
public class CafeCommentDTO {
    private int commentId;
    private int postId;
    private int cafeId;
    private String writerId;
    private String content;
    private String isDeleted;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private String writerNickname;
    private String writerRole;
    private String postTitle;
    private String cafeName;
    private String boardName;
}
