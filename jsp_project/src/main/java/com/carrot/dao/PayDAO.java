package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.ChatRoomDTO;
import com.carrot.dto.PayTransactionDTO;

public class PayDAO extends BaseDAO {

    // 특정 사용자의 잔액 조회
    public int getBalance(String userId) {
        String sql = "SELECT BALANCE FROM USER_ACCOUNT WHERE USER_ID = ?";
        
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("BALANCE");
                } else {
                    // 계좌 데이터가 없으면 최초 1회 개설
                    insertNewAccount(userId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 신규 사용자 가상 계좌 생성
    private void insertNewAccount(String userId) {
        String sql = "INSERT INTO USER_ACCOUNT (USER_ID, BALANCE) VALUES (?, 0)";
        try (Connection conn = getConnection(); 
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 가상 머니 충전 (입금)
    public boolean chargePay(String userId, int amount) {
        String sql = "UPDATE USER_ACCOUNT SET BALANCE = BALANCE + ? WHERE USER_ID = ?";
        try (Connection conn = getConnection(); 
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, amount);
            pstmt.setString(2, userId);
            return pstmt.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 가상 머니 출금 (반환)
    public boolean withdrawPay(String userId, int amount) {
        // 잔액 검증 로직을 포함한 차감
        String checkSql = "SELECT BALANCE FROM USER_ACCOUNT WHERE USER_ID = ?";
        String updateSql = "UPDATE USER_ACCOUNT SET BALANCE = BALANCE - ? WHERE USER_ID = ?";
        
        try (Connection conn = getConnection()) {
            // 안전을 위해 트랜잭션 유지
            conn.setAutoCommit(false);
            
            int currentBalance = 0;
            try (PreparedStatement pstmt = conn.prepareStatement(checkSql)) {
                pstmt.setString(1, userId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) currentBalance = rs.getInt("BALANCE");
                }
            }
            
            if (currentBalance >= amount) {
                try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                    pstmt.setInt(1, amount);
                    pstmt.setString(2, userId);
                    pstmt.executeUpdate();
                    conn.commit();
                    return true;
                }
            } else {
                conn.rollback(); // 잔액 부족 시 롤백
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
 // 에스크로 송금
    public boolean sendEscrow(long productId, String buyerId, String sellerId, int amount) {
        String checkSql = "SELECT BALANCE FROM USER_ACCOUNT WHERE USER_ID = ?";
        String deductSql = "UPDATE USER_ACCOUNT SET BALANCE = BALANCE - ? WHERE USER_ID = ?";
        String insertTxSql = "INSERT INTO PAY_TRANSACTION (TX_ID, PRODUCT_ID, BUYER_ID, SELLER_ID, AMOUNT, STATUS) VALUES (PAY_TX_SEQ.NEXTVAL, ?, ?, ?, ?, 'STAY')";
        String productSql = "UPDATE PRODUCT SET STATUS = 'RESERVED' WHERE PRODUCT_ID = ?";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // 트랜잭션 시작

            // 구매자 잔액 검증
            int currentBalance = 0;
            try (PreparedStatement pstmt = conn.prepareStatement(checkSql)) {
                pstmt.setString(1, buyerId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) currentBalance = rs.getInt("BALANCE");
                }
            }
            if (currentBalance < amount) {
                conn.rollback();
                return false;
            }

            // 구매자 잔액 차감
            try (PreparedStatement pstmt = conn.prepareStatement(deductSql)) {
                pstmt.setInt(1, amount);
                pstmt.setString(2, buyerId);
                pstmt.executeUpdate();
            }

            // 에스크로 테이블 등록
            try (PreparedStatement pstmt = conn.prepareStatement(insertTxSql)) {
                pstmt.setLong(1, productId);
                pstmt.setString(2, buyerId);
                pstmt.setString(3, sellerId);
                pstmt.setInt(4, amount);
                pstmt.executeUpdate();
            }

            // 상품 상태 변경
            try (PreparedStatement pstmt = conn.prepareStatement(productSql)) {
                pstmt.setLong(1, productId);
                pstmt.executeUpdate();
            }

            conn.commit(); // 모든 작업 성공 시 DB 반영
            return true;

        } catch (Exception e) {
            if (conn != null) { try { conn.rollback(); } catch (Exception ex) {} }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) { try { conn.close(); } catch (Exception e) {} }
        }
    }

    // 구매 확정
    public boolean confirmEscrow(long txId, String sellerId, int amount, long productId) {
        String updateTxSql = "UPDATE PAY_TRANSACTION SET STATUS = 'CONFIRMED', UPDATED_AT = CURRENT_TIMESTAMP WHERE TX_ID = ? AND STATUS = 'STAY'";
        String creditSql = "UPDATE USER_ACCOUNT SET BALANCE = BALANCE + ? WHERE USER_ID = ?";
        String productSql = "UPDATE PRODUCT SET STATUS = 'SOLD' WHERE PRODUCT_ID = ?";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // 트랜잭션 시작
            
            // 에스크로 내역 정산 완료로 변경
            int updatedRows = 0;
            try (PreparedStatement pstmt = conn.prepareStatement(updateTxSql)) {
                pstmt.setLong(1, txId);
                updatedRows = pstmt.executeUpdate();
            }
            
            if (updatedRows == 0) {
                conn.rollback();
                return false;
            }

            // 판매자 계좌로 돈 정산 입금
            try (PreparedStatement pstmt = conn.prepareStatement(creditSql)) {
                pstmt.setInt(1, amount);
                pstmt.setString(2, sellerId);
                pstmt.executeUpdate();
            }

            // 상품 거래완료(SOLD) 처리
            try (PreparedStatement pstmt = conn.prepareStatement(productSql)) {
                pstmt.setLong(1, productId);
                pstmt.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            if (conn != null) { try { conn.rollback(); } catch (Exception ex) {} }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) { try { conn.close(); } catch (Exception e) {} }
        }
    }
    
	// 마지막 거래 ID 가져오기
	public int selectLastTxId() {
	    String sql = "SELECT PAY_TX_SEQ.CURRVAL FROM DUAL";
	    try (Connection conn = getConnection();
	         PreparedStatement pstmt = conn.prepareStatement(sql);
	         ResultSet rs = pstmt.executeQuery()) {
	        if (rs.next()) return rs.getInt(1);
	    } catch (Exception e) { e.printStackTrace(); }
	    return 0;
	}
    
	public PayTransactionDTO selectEscrowByTxId(int txId) {
        String sql = "SELECT * FROM PAY_TRANSACTION WHERE TX_ID = ?";
		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, txId);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return PayTransactionDTO.builder()
                            .txId(rs.getLong("TX_ID"))
                            .productId(rs.getLong("PRODUCT_ID"))
                            .buyerId(rs.getString("BUYER_ID"))
                            .sellerId(rs.getString("SELLER_ID"))
                            .amount(rs.getInt("AMOUNT"))
                            .status(rs.getString("STATUS"))
                            .createdAt(rs.getTimestamp("CREATED_AT").toLocalDateTime())
                            .build();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
    
    // 에스크로 내역 조회
    public List<PayTransactionDTO> selectEscrowList(String userId) {
        List<PayTransactionDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM PAY_TRANSACTION WHERE BUYER_ID = ? OR SELLER_ID = ? ORDER BY TX_ID DESC";
        
        try (Connection conn = getConnection(); 
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, userId);
            pstmt.setString(2, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    PayTransactionDTO tx = PayTransactionDTO.builder()
                            .txId(rs.getLong("TX_ID"))
                            .productId(rs.getLong("PRODUCT_ID"))
                            .buyerId(rs.getString("BUYER_ID"))
                            .sellerId(rs.getString("SELLER_ID"))
                            .amount(rs.getInt("AMOUNT"))
                            .status(rs.getString("STATUS"))
                            .createdAt(rs.getTimestamp("CREATED_AT").toLocalDateTime())
                            .build();
                    list.add(tx);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}