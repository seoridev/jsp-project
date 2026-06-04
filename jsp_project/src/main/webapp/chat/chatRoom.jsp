<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.ChatRoomDAO" %>
<%@ page import="com.carrot.dto.ChatRoomDTO" %>
<%@ page import="com.carrot.dto.ChatMessageDTO"%>
<%@ page import="java.util.List" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%
	String userId = (String) session.getAttribute("loginId");

    String roomParam = request.getParameter("roomId");
    if (roomParam == null || roomParam.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }

    int roomId = 0;
    try {
        roomId = Integer.parseInt(roomParam);
    } catch (NumberFormatException e) {
        out.println("<script>alert('올바르지 않은 방 번호입니다.'); history.back();</script>");
        return;
    }

    // 웹소켓 검증
    ChatRoomDTO room = new ChatRoomDAO().selectChatRoomByRoomId(roomId); 
    if (room == null) {
        out.println("<script>alert('존재하지 않거나 종료된 채팅방입니다.'); history.back();</script>");
        return;
    }
    String buyerId = room.getBuyerId();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>동네마켓 | 채팅방</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
    <style>
        .chat-shell {
            max-width: 640px;
            margin: 0 auto;
            padding: 22px 16px 56px;
        }
        
        .chat-main-panel {
            border: 1px solid #e5ded3;
            border-radius: 8px;
            background: #fff;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        /* 채팅 메시지 스크롤 영역 */
        .chat-body {
            height: 480px;
            overflow-y: auto;
            padding: 20px;
            background-color: #fffdf9;
            border-bottom: 1px solid #eee7dc;
        }

        /* 말풍선 공통 흐름 구조 */
        .msg-wrapper {
            margin-bottom: 16px;
            display: flex;
            flex-direction: column;
        }
        
        .msg-bubble {
            max-width: 75%;
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 14px;
            line-height: 1.5;
            word-break: break-all;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }

        /* 내가 보낸 메시지 스타일 (오른쪽 정렬 + 당근 주황색) */
        .msg-wrapper.me {
            align-items: flex-end;
        }
        .msg-wrapper.me .msg-bubble {
            background-color: #ff6f0f;
            color: #fff;
            border-top-right-radius: 2px;
        }
        .msg-wrapper.me .msg-sender {
            display: none;
        }

        /* 상대방이 보낸 메시지 스타일 (왼쪽 정렬 + 베이지/그레이 회색) */
        .msg-wrapper.other {
            align-items: flex-start;
        }
        .msg-wrapper.other .msg-bubble {
            background-color: #f4eee5;
            color: #202124;
            border-top-left-radius: 2px;
        }
        .msg-wrapper.other .msg-sender {
            font-size: 12px;
            font-weight: 700;
            color: #756b61;
            margin-bottom: 4px;
            margin-left: 4px;
        }
        
        /* 시스템 알림 스타일 */
        .msg-system {
            text-align: center;
            margin: 12px 0;
            font-size: 13px;
            font-weight: 700;
        }
        
		.inline-check {
		    display: flex !important;
		    align-items: center !important;
		    gap: 8px; /* 요소 사이의 간격을 일정하게 유지 */
		    width: 100%;
		}
		
		.inline-check button[onclick*="imageInput"] {
		    flex-shrink: 0; /* 버튼이 찌그러지지 않도록 방어 */
		    background: none !important;
		    border: none !important;
		    font-size: 22px !important;
		    padding: 0 4px !important;
		    margin: 0 !important;
		    cursor: pointer;
		    line-height: 1;
		}
		
		#messageInput {
		    flex-grow: 1;
		    height: 40px; 
		    padding: 0 12px;
		    border: 1px solid #cbd5e1;
		    border-radius: 6px;
		    box-sizing: border-box;
		}
		
		#sendBtn {
		    flex-shrink: 0;
		    height: 40px;
		    white-space: nowrap;
		}
    </style>
</head>
<body>

<%@ include file="../common/header.jsp" %>

<!-- 메인 채팅방 레이아웃 -->
<main class="chat-shell">
    <div class="chat-main-panel">
        
        <!-- 메시지 출력 구역 -->
		<div class="chat-body" id="chatMessages">
		    <div class="msg-system field-message" style="color: #7a7066;" id="loadingNotice">대화 기록을 불러오는 중입니다...</div>
		</div>
		        
        <!-- 입력 구역 -->
        <div class="status-panel" style="border: none; border-radius: 0; padding: 18px;">
            <div class="field">
                <div class="inline-check">
                    <form id="imageForm" enctype="multipart/form-data" style="display: none;">
                    	<input type="file" id="imageInput" name="imageFile" accept="image/*" onchange="uploadImageFile()">
                    </form>
                    <% if (userId.equals(buyerId)) { %>
    					<button type="button" onclick="requestSafetyPay();" style="background: none; border: none; font-size: 20px; cursor: pointer; padding-right: 10px;" title="안전결제 요청">💵</button>
					<% } %>
                    <button type="button" onclick="document.getElementById('imageInput').click();" style="background: none; border: none; font-size: 20px; cursor: pointer; padding-right: 10px;" title="이미지 업로드">🖼️</button>
                    
                    <input type="text" id="messageInput" placeholder="메시지를 입력하세요..." onkeyup="if(event.keyCode==13) sendMessage();" disabled>
                    <button type="button" id="sendBtn" class="primary" onclick="sendMessage();" disabled>전송</button>
                </div>
            </div>
        </div>
    </div>
    
</main>
<%@ include file="../common/footer.jsp" %>

<script>
    const roomId = "<%= roomId %>";
    const userId = "<%= userId %>";
    const buyerId = "<%= buyerId %>";
    
    let webSocket;
    const chatMessages = document.getElementById("chatMessages");
    const messageInput = document.getElementById("messageInput");
    const sendBtn = document.getElementById("sendBtn");

    window.onload = function() {
        connectWebSocket();
        loadChatHistory();
        setTimeout(scrollToBottom, 100);
    };

    function connectWebSocket() {
        // 현재 접속한 페이지 프로토콜에 맞춰 WebSocket 프로토콜 선택
        const protocol = window.location.protocol === "https:" ? "wss://" : "ws://";
        // 배포 컨텍스트 경로를 JSP에서 가져와 하드코딩 경로 문제 방지
        const contextPath = "<%= request.getContextPath() %>";
        // userId에 특수문자가 있어도 WebSocket 경로가 깨지지 않도록 인코딩
        const wsUrl = protocol + window.location.host + contextPath + "/chatServer/" + roomId + "/" + encodeURIComponent(userId);
        webSocket = new WebSocket(wsUrl);

        webSocket.onopen = function(event) {
            chatMessages.innerHTML += '<div class="msg-system field-message is-success">채팅방에 성공적으로 연결되었습니다.</div>';
            messageInput.disabled = false;
            sendBtn.disabled = false;
            messageInput.focus();
            scrollToBottom();
        };

        webSocket.onmessage = function(event) {
            try {
                const data = JSON.parse(event.data);
            	if (data.msgType === "ERROR") {
                    alert(data.message);
                    return;
            	}
                displayMessage(data.senderId, data.message, data.msgType);
            } catch (e) {
                displayMessage("시스템", event.data);
            }
        };

        webSocket.onclose = function(event) {
            chatMessages.innerHTML += '<div class="msg-system field-message is-error">연결이 종료되었습니다. 창을 새로고침 해주세요.</div>';
            messageInput.disabled = true;
            sendBtn.disabled = true;
        };

        webSocket.onerror = function(event) {
            console.error("WebSocket Error: ", event);
        };
    }
    
    function loadChatHistory() {        
        fetch("<%= request.getContextPath() %>/chat/chatHistoryProcess.jsp?roomId=" + roomId)
            .then(response => response.json())
            .then(historyList => {
                // 로딩 메시지 제거
                const loadingNotice = document.getElementById("loadingNotice");
                if(loadingNotice) loadingNotice.remove();
                
                if (historyList && historyList.length > 0) {
                    historyList.forEach(msg => {
                        displayMessage(msg.senderId, msg.message, msg.msgType);
                    });
                } else {
                    chatMessages.innerHTML += '<div class="msg-system field-message" style="color: #7a7066;" id="emptyNotice">이전 대화 기록이 없습니다. 새로운 대화를 시작해보세요!</div>';
                }
                
                scrollToBottom();
            })
            .catch(err => {
                console.error("채팅 기록 로드 실패:", err);
                document.getElementById("loadingNotice").innerText = "대화 기록을 불러오지 못했습니다.";
            });
    }

    // 메시지 전송
    function sendMessage() {
        const msg = messageInput.value.trim();
        if (msg === "") return;

        const packet = {
            roomId: roomId,
            senderId: userId,
            message: msg,
            msgType: "TEXT"
        };

        webSocket.send(JSON.stringify(packet));
        
        messageInput.value = "";
        messageInput.focus();
    }
    
    // 이미지 업로드
    function uploadImageFile() {
        const fileInput = document.getElementById("imageInput");
        if (!fileInput.files || !fileInput.files[0]) return;

        const formData = new FormData();
        formData.append("imageFile", fileInput.files[0]);

        fetch("<%= request.getContextPath() %>/chat/chatSendProcess.jsp", {
            method: "POST",
            body: formData
        })
        .then(response => response.text())
        .then(fileName => {
            const result = fileName.trim();
            if (result === "FAIL" || result === "ERROR") {
                alert("이미지 업로드에 실패했습니다.");
                return;
            }

            const packet = {
                roomId: roomId,
                senderId: userId,
                message: result,  // 파일명
                msgType: "IMAGE"  // 이미지 타입 명시
            };

            webSocket.send(JSON.stringify(packet));
     
            fileInput.value = "";
        })
        .catch(err => {
            console.error("Upload Error:", err);
            alert("서버 연결에 실패했습니다.");
        });
    }
    
 	// 안전결제 요청
    function requestSafetyPay() {
    	const inputAmount = prompt("안전결제를 진행할 금액을 입력해 주세요.");
    	
    	if (inputAmount === null) return;
    	
    	const amount = parseInt(inputAmount.trim(), 10);
    	
    	if (isNaN(amount) || amount <= 0) {
            alert("올바른 금액을 입력해 주세요.");
            return;
        }
    	
    	if (!confirm(amount.toLocaleString() + "원으로 안전결제를 진행하시겠습니까?")) {
            return;
        }
    	
        const packet = {
            roomId: roomId,
            senderId: userId,
            message: amount, // 금액
            msgType: "PAY_REQUEST"
        };
        
        webSocket.send(JSON.stringify(packet));
    }

    // 구매 확정 요청
    function confirmSafetyPay(event, txId) {
    	const payButton = event.target;
    	
    	// 중복실행 방지
    	if (payButton.disabled) return;
    	
        if(!confirm("물품을 무사히 수령하셨나요? 판매자에게 대금이 정산되며 취소할 수 없습니다.")) return;

        payButton.disabled = true;
        payButton.innerText = "구매 확정 처리 중...";
        
        const packet = {
            roomId: roomId,
            senderId: userId,
            message: txId, // 거래 번호를 실어서 전송
            msgType: "PAY_CONFIRM"
        };
        
        webSocket.send(JSON.stringify(packet));
    }

    // 메시지 출력
	function displayMessage(sender, message, msgType = "TEXT") {
	    const isMe = (sender === userId);
	    const msgClass = isMe ? "me" : "other";
	    let html = "";
	    
	    if (msgType === "PAY_REQUEST") {
	        const payInfo = JSON.parse(message);

	        const amount = parseInt(payInfo.amount, 10);
	        const txId = payInfo.txId;
	    	
	        const displayAmount = isNaN(amount) ? message : amount.toLocaleString();
	        
	        html = '<div class="msg-system">'
	             + '  <div class="status-panel" style="border-left: 4px solid #ff6f0f; text-align: left; background:#fff; box-shadow: 0 2px 4px rgba(0,0,0,0.05); padding: 14px; margin: 8px 0;">'
	             + '    <h3 style="margin:0 0 8px; color:#ff6f0f; font-size:15px;">🔒 당근페이 안전결제 보관중</h3>'
	             + '    <p style="font-size:14px; margin:0 0 4px; font-weight: bold;">결제 금액: <span style="color:#ff6f0f;">' + displayAmount + '원</span></p>'
	             + '    <p style="font-size:12px; margin:0 0 12px; color:#756b61;">안전하게 대금이 중개 보관되었습니다. 물건을 유효하게 수령하신 후 구매 확정을 눌러주세요.</p>';
	        
	        if (userId == buyerId) {
	            html += '    <button class="primary" style="width:100%; min-height:36px; font-size:13px;" onclick="confirmSafetyPay(event, ' + txId + ')">구매 확정하기</button>';
	        } else {
	            html += '    <p style="font-size:12px; color:#ff6f0f; font-weight:700; margin:0;">💡 구매자가 물품 확인 후 구매확정을 누르면 내 지갑으로 정산됩니다.</p>';
	        }
	        
	        html += '  </div>'
	             + '</div>';
	             
	    } else if (msgType === "PAY_CONFIRM") {
	        html = '<div class="msg-system">'
	             + '  <div class="status-panel" style="border-left: 4px solid #23723a; text-align: left; background:#f4fbf6; padding: 14px; margin: 8px 0;">'
	             + '    <h3 style="margin:0 0 4px; color:#23723a; font-size:15px;">✅ 거래 완료 (정산 완료)</h3>'
	             + '    <p style="font-size:13px; margin:0; color:#555;">구매자가 구매를 확정하여 판매자에게 대금 송금이 완료되었습니다.</p>'
	             + '  </div>'
	             + '</div>';
	             
	    } else {
	        let contentHtml = "";
	        if (msgType === "IMAGE") {
	            const imgPath = "<%= request.getContextPath() %>/upload/chat/" + message;
	            contentHtml = '<img src="' + imgPath + '" style="max-width: 200px; border-radius: 8px; cursor: pointer;" onclick="window.open(this.src)">';
	        } else {
	            contentHtml = message;
	        }
	        
	        html = '<div class="msg-wrapper ' + msgClass + '">'
	             + '  <div class="msg-sender">' + sender + '</div>'
	             + '  <div class="msg-bubble">' + contentHtml + '</div>'
	             + '</div>';
	    }
	    
	    chatMessages.innerHTML += html;
	    scrollToBottom();
	}

    function scrollToBottom() {
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }
</script>

</body>
</html>
