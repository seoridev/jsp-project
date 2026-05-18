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
public class ProductImageDTO {
    private int imageId;
    private int productId;
    private String originName;
    private String saveName;
    private String imagePath;
    private String isMain;
    private LocalDateTime createdAt;
}
