package DTO;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Builder
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Setter
public class MemberDTO {
    private String loginId;
    private String password;
    private String nickname;
    private String phone;
    private String region;
    private String profileText;
    private double mannerScore;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
}
