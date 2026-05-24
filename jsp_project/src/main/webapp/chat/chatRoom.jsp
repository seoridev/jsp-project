<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.ChatRoomDAO" %>
<%@ page import="com.carrot.dao.ChatMessageDAO" %>
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

    // 웹소켓 검증 (존재하고 활성화된 방인지 확인)
    ChatRoomDAO dao = new ChatRoomDAO();
    if (!dao.checkChatRoomExist(roomId)) {
        out.println("<script>alert('존재하지 않거나 종료된 채팅방입니다.'); history.back();</script>");
        return;
    }
    

    // 채팅 내역 불러오기
    ChatMessageDAO messageDao = new ChatMessageDAO();
    List<ChatMessageDTO> oldMessageList = messageDao.getMessageListByRoomId(roomId);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅방 - 동네마켓</title>
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
        	<%-- 대화 로그 기록 렌더링 --%>
		    <% if (oldMessageList != null && !oldMessageList.isEmpty()) { 
		        for (ChatMessageDTO msgDto : oldMessageList) { 
		            // 로그인한 나인지, 상대방인지 판별
		            boolean isMe = msgDto.getSenderId().equals(userId);
		            String msgClass = isMe ? "me" : "other";
		    %>
		            <div class="msg-wrapper <%= msgClass %>">
		                <div class="msg-sender"><%= msgDto.getSenderId() %></div>
		                <div class="msg-bubble">
		                    <% if ("IMAGE".equals(msgDto.getMsgType())) { %>
		                        <img src="<%= request.getContextPath() %>/upload/chat/<%= msgDto.getMessage() %>" style="max-width: 200px; border-radius: 8px; cursor: pointer;" onclick="window.open(this.src)">
		                    <% } else { %>
		                        <%= msgDto.getMessage() %>
		                    <% } %>
		                </div>
		            </div>
		    <% 
		        } 
		    } else { 
		    %>
		        <div class="msg-system field-message" style="color: #7a7066;" id="emptyNotice">이전 대화 기록이 없습니다. 새로운 대화를 시작해보세요!</div>
		    <% } %>
            <div class="msg-system field-message" style="color: #7a7066;">채팅방 서버 연결을 시도하고 있습니다...</div>
        </div>
        
        <!-- 입력 구역 -->
        <div class="status-panel" style="border: none; border-radius: 0; padding: 18px;">
            <div class="field">
                <div class="inline-check">
                    <form id="imageForm" enctype="multipart/form-data" style="display: none;">
                    	<input type="file" id="imageInput" name="imageFile" accept="image/*" onchange="uploadImageFile()">
                    </form>
                    <button type="button" onclick="document.getElementById('imageInput').click();" style="background: none; border: none; font-size: 20px; cursor: pointer; padding-right: 10px;">🖼️</button>
                    
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
    
    let webSocket;
    const chatMessages = document.getElementById("chatMessages");
    const messageInput = document.getElementById("messageInput");
    const sendBtn = document.getElementById("sendBtn");

    window.onload = function() {
        connectWebSocket();
        setTimeout(scrollToBottom, 100);
    };

    function connectWebSocket() {
        // 추가됨: 현재 접속한 페이지 프로토콜에 맞춰 WebSocket 프로토콜 선택
        const protocol = window.location.protocol === "https:" ? "wss://" : "ws://";
        // 추가됨: 배포 컨텍스트 경로를 JSP에서 가져와 하드코딩 경로 문제 방지
        const contextPath = "<%= request.getContextPath() %>";
        // 추가됨: userId에 특수문자가 있어도 WebSocket 경로가 깨지지 않도록 인코딩
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
                if (data.senderId !== userId) {
                	displayMessage(data.senderId, data.message, data.msgType);
                }
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
        displayMessage(userId, msg, "TEXT");
        
        messageInput.value = "";
        messageInput.focus();
    }
    
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

            displayMessage(userId, result, "IMAGE");
            
            fileInput.value = "";
        })
        .catch(err => {
            console.error("Upload Error:", err);
            alert("서버 연결에 실패했습니다.");
        });
    }

    function displayMessage(sender, message, msgType = "TEXT") {
        const isMe = (sender === userId);
        const msgClass = isMe ? "me" : "other";
        
        let contentHtml = "";
        if (msgType === "IMAGE") {
            const imgPath = "<%= request.getContextPath() %>/upload/chat/" + message;
            contentHtml = '<img src="' + imgPath + '" style="max-width: 200px; border-radius: 8px; cursor: pointer;" onclick="window.open(this.src)">';
        } else {
            contentHtml = message;
        }
        
        const html = '<div class="msg-wrapper ' + msgClass + '">'
                   + '<div class="msg-sender">' + sender + '</div>'
                   + '<div class="msg-bubble">' + contentHtml + '</div>'
                   + '</div>';
        
        chatMessages.innerHTML += html;
        scrollToBottom();
    }

    function scrollToBottom() {
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }
</script>

</body>
</html>
