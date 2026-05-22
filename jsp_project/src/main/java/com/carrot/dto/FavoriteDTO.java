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
public class FavoriteDTO {
    private int favoriteId;
    private String memberId;
    private int productId;
    private LocalDateTime createdAt;

    private String productTitle;
    private String productStatus;
    private String productRegion;
}
