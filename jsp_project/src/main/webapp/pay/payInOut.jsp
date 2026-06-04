<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.PayDAO" %>
<%@ page import="com.carrot.dto.PayTransactionDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%@ include file="../common/header.jsp" %>
<%
	int balance = new PayDAO().getBalance(loginId);
    DecimalFormat df = new DecimalFormat("#,###");
    
    // 내 거래 목록
    List<PayTransactionDTO> txList = new PayDAO().selectEscrowList(loginId);
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>안전결제 센터 | 동네마켓</title>
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=mypage-1">
<style>
    * { box-sizing: border-box; }
    html { color-scheme: light; }
    body {
        margin: 0; min-height: 100vh;
        font-family: "Malgun Gothic", "Apple SD Gothic Neo", Arial, sans-serif;
        color: #202124; background: #f7f4ee; padding: 20px;
    }
    a { color: inherit; text-decoration: none; }

    .page-shell { width: min(1120px, calc(100% - 32px)); margin: 0 auto; padding: 22px 0 56px; }
    
    .pay-layout {
        display: grid;
        grid-template-columns: minmax(0, 1.25fr) minmax(340px, 0.75fr);
        gap: 28px;
        align-items: stretch;
    }

    .pay-hero-panel {
        padding: 40px; border-radius: 8px; color: #fff;
        background: linear-gradient(135deg, rgba(255, 111, 15, 0.96), rgba(255, 169, 77, 0.9));
        box-shadow: 0 4px 15px rgba(255, 111, 15, 0.15);
    }
    .eyebrow { margin: 0 0 10px; font-size: 15px; font-weight: 800; opacity: 0.9; }
    .pay-hero-panel h1 { margin: 0; font-size: 38px; font-weight: 900; }
    .pay-hero-panel .balance-display { font-size: 46px; font-weight: 900; margin: 15px 0; }
    
    .status-panel { border: 1px solid #e5ded3; border-radius: 8px; background: #fff; padding: 28px; }
    .status-panel h2 { margin: 0 0 12px; font-size: 22px; font-weight: 800; }
    
    .form-grid { display: grid; gap: 18px; margin-top: 15px; }
    .field { display: grid; gap: 8px; }
    .field label { font-size: 14px; font-weight: 800; color: #5f574f; }
    .field input {
        width: 100%; min-height: 46px; border: 1px solid #d7d0c5; border-radius: 8px;
        padding: 0 14px; font-size: 15px; background: #fffdf9; font-weight: 700;
    }
    .field input:focus { outline: 3px solid rgba(255, 111, 15, 0.18); border-color: #ff6f0f; }

    .button-group { display: flex; gap: 8px; margin-top: 5px; }
    button {
        flex: 1; display: inline-flex; align-items: center; justify-content: center;
        min-height: 44px; padding: 0 16px; border: 1px solid #ded6ca; border-radius: 8px;
        background: #fffaf3; color: #222; font-size: 14px; font-weight: 700; cursor: pointer;
        transition: all 0.2s;
    }
    button.primary { border-color: #ff6f0f; background: #ff6f0f; color: #fff; }
    button.primary:hover { background: #e05e0c; }
    button:not(.primary):hover { background: #eee7dc; }

    .escrow-section { margin-top: 32px; background: #fff; border: 1px solid #e5ded3; border-radius: 8px; padding: 28px; }
    .escrow-section h3 { margin: 0 0 18px; font-size: 20px; font-weight: 800; }
    
    .admin-table-wrap { overflow-x: auto; border: 1px solid #e5ded3; border-radius: 8px; background: #fff; }
    .admin-table { width: 100%; border-collapse: collapse; min-width: 600px; }
    .admin-table th, .admin-table td { padding: 13px 14px; border-bottom: 1px solid #eee7dc; text-align: left; font-size: 14px; }
    .admin-table th { background: #fff7ed; color: #5c5148; font-weight: 800; }
    
    .status-badge {
        display: inline-flex; align-items: center; min-height: 26px; padding: 0 10px; border-radius: 999px;
        background: #f4eee5; color: #4d453d; font-size: 12px; font-weight: 800;
    }
    .status-badge.is-active { background: #eaf7ed; color: #23723a; } /* 결제완료(보관중) */
    .status-badge.is-withdrawn { background: #f2f0ee; color: #6c6259; } /* 정산완료 */

    @media (max-width: 760px) {
        .pay-layout { grid-template-columns: 1fr; }
        .pay-hero-panel { padding: 24px; }
        .pay-hero-panel h1 { font-size: 28px; }
        .pay-hero-panel .balance-display { font-size: 34px; }
    }
</style>
</head>
<body>
<div class="page-shell">
    <div class="pay-layout">
        
        <div>
            <div class="pay-hero-panel">
                <div class="eyebrow">동네 안전결제 지갑</div>
                <h1>안녕하세요, <%= loginId %>님</h1>
                <div class="balance-display"><%= df.format(balance) %> 원</div>
                <div style="font-size: 14px; opacity: 0.85; font-weight: 700;">
                    💡 현재 결제 대기방이나 에스크로에 묶여있지 않은 전액 출금 가능한 금액입니다.
                </div>
            </div>
        </div>

        <div class="status-panel">
            <h2>머니 입출금</h2>
            <p style="font-size: 13px; color:#756b61; margin: 0 0 15px;">계좌 연동 없이 즉시 처리되는 가상 충전소입니다.</p>
            
            <form action="payProcess.jsp" method="post" class="form-grid">
                <div class="field">
                    <label for="amount">금액 입력</label>
                    <input type="number" id="amount" name="amount" min="1000" step="1000" placeholder="금액을 입력하세요 (단위: 1,000원)" required>
                </div>
                
                <div class="button-group">
                    <button type="submit" name="action" value="charge" class="primary">가상 입금 (충전)</button>
                    <button type="submit" name="action" value="withdraw">가상 출금 (반환)</button>
                </div>
            </form>
        </div>
    </div>

    <div class="escrow-section">
        <h3>🔒 안전결제 에스크로 거래 내역 (중개 보관 상태 현황)</h3>
        <div class="admin-table-wrap">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>거래 번호</th>
                        <th>상품 번호</th>
                        <th>구매자</th>
                        <th>판매자</th>
                        <th>보관 금액</th>
                        <th>에스크로 상태</th>
                    </tr>
                </thead>
				<tbody>
				    <% if (txList == null || txList.isEmpty()) { %>
				        <tr>
				            <td colspan="6" style="text-align: center; height: 96px; color: #756b61;">참여 중인 안전결제 내역이 없습니다.</td>
				        </tr>
				    <% } else { 
				        for (PayTransactionDTO tx : txList) { 
				    %>
				        <tr>
				            <td>TX-<%= tx.getTxId() %></td>
				            <td><a href="<%= request.getContextPath() %>/product/productDetail.jsp?id=<%= tx.getProductId() %>" class="table-link">#<%= tx.getProductId() %></a></td>
				            <td><%= tx.getBuyerId().equals(loginId) ? tx.getBuyerId() + " (나)" : tx.getBuyerId() %></td>
				            <td><%= tx.getSellerId().equals(loginId) ? tx.getSellerId() + " (나)" : tx.getSellerId() %></td>
				            <td style="font-weight: 800; color:#ff5a5f;"><%= df.format(tx.getAmount()) %>원</td>
				            <td>
				                <% if ("STAY".equals(tx.getStatus())) { %>
				                    <span class="status-badge is-active">구매 보관중</span>
				                <% } else if ("CONFIRMED".equals(tx.getStatus())) { %>
				                    <span class="status-badge is-withdrawn">정산 완료</span>
				                <% } else { %>
				                    <span class="status-badge"><%= tx.getStatus() %></span>
				                <% } %>
				            </td>
				        </tr>
				    <% 
				        } 
				    } 
				    %>
				</tbody>
            </table>
        </div>
    </div>
</div>
<%@ include file="../common/footer.jsp" %>
</body>
</html>