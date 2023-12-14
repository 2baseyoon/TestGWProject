<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
String storageBaseDir = PropertiesUtil.getExtensionProperties().getProperty("approval.pdfconvert.destination.path");
%>
<style type="text/css">
.loggerArea li {
	font-family : Courier New, Consolas, Candara !important;
}
</style>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_apv_pdfexport"/></span><!-- 결재문서 일괄 다운로드 -->	
</h3>
<div style="width:100%;" id="approvalDocumentsDownloadPage">
	<div id="topitembar02" class="topbar_grid">
		<input type="button" value="<spring:message code='Cache.btn_apv_refresh' />" onclick="CoviMenu_GetContent(location.href.replace(location.origin, ''), false);" class="AXButton BtnRefresh"/> <!-- 새로고침 -->
		<a class="AXButton btnTypeBg" onclick="pdfConvertProcess.startExport();"><spring:message code="Cache.lbl_apv_pdfexport_start"/></a><!-- 내보내기 -->
		<a class="AXButton" onclick="pdfConvertProcess.interruptTask();"><spring:message code="Cache.lbl_apv_pdfexport_stop"/></a><!-- 현재작업 강제종료 -->
	</div>
	<div class="result_grid">
		<div class="star">
			<spring:message code="Cache.lbl_apv_pdfexport_desc1"/>
		</div>
		<table class="AXFormTable">
			<thead>
				<colcolgroup>
					<col width="300" />
					<col width="*" />
				</colcolgroup>
			</thead>
			<tbody>
				<tr>
					<th><spring:message code="Cache.lbl_apv_pdfexport_url"/></th><!-- 결재문서 조회 URL -->
					<td><input type="text" class="AXInput" style="width:100%" value="http://localhost:9080/approval/pdfTransferView.do" id="RenderURL"/></td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_apv_pdfexport_skipsuccess"/></th><!-- 동일문서로 성공내역 존재시 재처리여부 -->
					<td><input type="checkbox" value="Y" class="" id="overwrite"/></td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_apv_pdfexport_skiperror"/></th><!-- 동일문서로 오류내역 존재시 재처리여부 -->
					<td><input type="checkbox" value="Y" class="" id="retryerror"/></td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_apv_pdfexport_pdfpath"/></th><!-- 결과 PDF Directory(상대경로) -->
					<td><%=storageBaseDir %><input type="text" class="AXInput" style="width:400px" value="approval_convert/\${TaskID}/\${CompletedDate}/\${FormInstID}" id="DestPdfFilePath"/></td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_apv_pdfexport_attachpath"/></th><!-- 결과 Attach Directory(상대경로) -->
					<td><%=storageBaseDir %><input type="text" class="AXInput" style="width:400px" value="approval_convert/\${TaskID}/\${CompletedDate}/\${FormInstID}/attach" id="DestAttachFilePath"/></td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_apv_pdfexport_usercode"/></th><!-- 로그인세션사용자ID -->
					<td><input type="text" class="AXInput" style="width:100px" value="superadmin" id="DraftID"/></td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_apv_pdfexport_completedate"/></th><!-- 결재완료일자 -->
					<td>
						<div id="divCalendar" class="dateSel type02">
							<input class="AXInput" type="text" id="StartDate" date_separator="-">
							~ <input class="AXInput" type="text" id="EndDate" date_separator="-" kind="twindate" date_starttargetid="StartDate" data-axbind="twinDate">						
						</div>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
</div>
	<table class="log_table">
		<thead>
			<colcolgroup>
				<col width="250" />
				<col width="*" />
			</colcolgroup>
		</thead>
		<tbody>
			<td valign="top">
				<h3>Active Task List</h3>
				<div id="activeTaskList" style="margin-top:10px;padding:10px;">
					<jsp:include page="/WEB-INF/views/admin/approval/ConvertPdfProcessList.jsp"></jsp:include>
				</div>
			</td>
			<td valign="top">
				<h3>Current Log Messages [<span id="tit_taskID"></span>]</h3>
				<div class="loggerArea">
					<ul id="loggingWrapper"></ul>
				</div>
			</td>
		</tbody>
	</table>
<script type="text/javascript">
function PDFConvertProcess () {
	this.init = function() {
		setConfig();
	};	
	var setConfig = function () {
	};
	
	var messageQueueOnOpen = {};
	
	var refreshActiveTask = function() {
		var url = "/approval/common/convert/goThreadInfo.do";
		$.get(url, function(data){
			$("#activeTaskList").html(data);
		});
	};
	// On click active task.
	this.showTask = function(taskID) {
		if(pdfConvertProcess.getCurrentTask() != taskID) {
			showLogger(taskID);
		}
	};
	
	this.interruptTask = function(){
		var taskID = pdfConvertProcess.getCurrentTask();
		if(socketMap[taskID] != null) {
			var msg = '<spring:message code="Cache.msg_apv_pdfexport_stop" />';
			msg = msg.replace("{0}", taskID);
			Common.Confirm(msg, "Confirm", function(result){
				if(result) {
					socketMap[taskID].send("[STOP]" + taskID);
				}
			});
		}else{
			Common.Warning('<spring:message code="Cache.msg_apv_pdfexport_notask"/>');
			return;
		}
	};
	
	var checkValid = function() {
		if($("#StartDate").val() == "" || $("#EndDate").val() == "") {
			Common.Warning('<spring:message code="Cache.msg_apv_pdfexport_nodate"/>');
			return false;
		}
		if($("#DraftID").val() == "") {
			Common.Warning('<spring:message code="Cache.msg_apv_pdfexport_nousercode"/>');// 로그인세션 아이디가 입력되지 않았습니다.
			return false;
		}
		
		return true;
	};
	this.startExport = function(){
		if(!checkValid()){
			return;
		}
		Common.Confirm('<spring:message code="Cache.msg_apv_pdfexport_start"/>', "Confirm", function(result){ // 내보내기를 시작하시겠습니까?
			if(result) {
				var __taskID = Date.now().toString();
				showLogger(__taskID);
				$.ajax({
					url : "/approval/common/convert/startExport.do",
					type: "POST",
					data : {
						"TaskID" : __taskID,
						"overwrite" : $("#overwrite").is(":checked") ? "Y" : "",
						"retryerror" : $("#retryerror").is(":checked") ? "Y" : "",
						"StartDate" : $("#StartDate").val(),
						"EndDate" : $("#EndDate").val(),
						"DraftID" : $("#DraftID").val(), // 세션만들 사용자 아이디 (관리자)
						"RenderURL" : $("#RenderURL").val(),
						"DestPdfFilePath" : $("#DestPdfFilePath").val(),
						"DestAttachFilePath" : $("#DestAttachFilePath").val()
					},
					async:true,
					success:function (data) {
						writeLog(">>>>>>>>>>> Background task has been started.");
						refreshActiveTask();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/common/convert/startExport.do", response, status, error);
					}
				});
			}
		});
	};
	
	var currentTaskId = "";
	var setCurrentTask = function(taskId) {
		currentTaskId = taskId;
	};
	this.getCurrentTask = function() {
		return currentTaskId;
	};
	
	var showLogger = function(taskID){
		setCurrentTask(taskID);
		var firstSocket = false;
		if( !socketMap[taskID] || socketMap[taskID] == null ) {
			initWebSocket(taskID);
			firstSocket = true;
		}
		$("#loggingWrapper").attr("taskid", taskID).html("");
		$("span#tit_taskID").html(taskID);
		
		if(firstSocket === true) {
			if(messageQueueOnOpen[taskID] == null){
				messageQueueOnOpen[taskID] = [];
			}
			messageQueueOnOpen[taskID].push(function (){
				loadPreviousLogs(taskID);
			});
		}else {
			loadPreviousLogs(taskID);
		}
	};
	
	// 이전 로그내역 가져오기
	var loadPreviousLogs = function (taskID) {
		socketMap[taskID].send("[GETLOG]" + taskID);
	};
	
	var counter = 0;
	var maxLines = 3000;
	var writeLog = function(message, taskId, type) {
		//coviCmn.traceLog(message);
		var listNode = document.getElementById('loggingWrapper');
		if(listNode.getAttribute("taskid") != taskId)  {
			return;
		}
		if(type == "INIT") {
			var logTxt = message.replace("[PREVLOG]", ""); // [PREVLOG]31!@|@!<li>[2022-11-01 11:22:21.221] Blah..... </li><li>..............
			var info = logTxt.split("!@|@!");
			var cnt = parseInt(info[0]);
			logTxt = info[1];
			$(listNode).html(logTxt);
			counter = cnt;
		}else{
			if(counter > maxLines) {
				listNode.removeChild(0);
			}
			if(message.indexOf("<li>") != 0) {
				message = "<li>" + message + "</li>";
			}
	        $(listNode).append(message); // message = "<li>blah...</li>"
		}
        
        var scrollWrap = $(".loggerArea")[0];
        scrollWrap.scrollTop = scrollWrap.scrollHeight;
	    
        counter++; 
	};
	
	var socketMap = new Object();
	var initWebSocket = function (taskId) {
		var _protocol = "ws://";
		if ("https:" == location.protocol) {
			_protocol = "wss://";
		}
		var url = _protocol + location.host + "/approval/asyncpdfconvertws/" + taskId;
		var socket = new WebSocket(url);
		socketMap[taskId] = socket;

		// (Tiles) Close socket when DOM remove event 
		$("#approvalDocumentsDownloadPage")[0].addEventListener ("DOMNodeRemoved", function () {
			for(var key in socketMap) {
				socketMap[key].close();
				coviCmn.traceLog("DOM detattched. closing socket.");
			}
		}, false);
		
		socket.onopen = function(e) {
			var taskID = event.target.url.substring(event.target.url.lastIndexOf("/") + 1)
			writeLog("Socket connectd for Logging. URL [" + event.target.url + "]");
			writeLog("Socket connectd for Logging. [" + taskID + "]");
			
			// send queued message.
			if(messageQueueOnOpen[taskID] != null) {
				var arr = messageQueueOnOpen[taskID];
				for(var i = 0; i < arr.length; i++) {
					if ($.isFunction(arr[i])) {
						arr[i].call(this);
					}
				}
			}
		};

		socket.onmessage = function(event) {
			var taskID = event.target.url.substring(event.target.url.lastIndexOf("/") + 1);
			if(event.data.indexOf("[PREVLOG]") == 0) {
				writeLog(event.data, taskID, "INIT");
			}else{
				writeLog(event.data, taskID);
			}
		};

		socket.onclose = function(event) {
			var taskId = event.target.url.substring(event.target.url.lastIndexOf("/") + 1) ;
			if (event.wasClean) {
				delete socketMap[taskId];
		  	} else {
		    	// 예시: 프로세스가 죽거나 네트워크에 장애가 있는 경우
		    	// event.code가 1006이 됩니다.
		    	// alert('[close] 커넥션이 죽었습니다.');
		  		delete socketMap[taskId];
			}
			writeLog("Socket is closed. maybe Task has been completed. [" + taskId + "]", taskId);
			refreshActiveTask();
		};

		socket.onerror = function(error) {
			writeLog(error);
		};
	};
}
var pdfConvertProcess = new PDFConvertProcess();
jQuery(document).ready(function() {
	pdfConvertProcess.init();
});
</script>
