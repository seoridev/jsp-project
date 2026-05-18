package DTO;

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
public class ProductDTO {
    private int productId;
    private String sellerId;
    private int categoryId;
    private String title;
    private String content;
    private int price;
    private String region;
    private String status;
    private int viewCount;
    private String isDeleted;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private String categoryName;
    private String sellerNickname;
    private String mainImagePath;
}
