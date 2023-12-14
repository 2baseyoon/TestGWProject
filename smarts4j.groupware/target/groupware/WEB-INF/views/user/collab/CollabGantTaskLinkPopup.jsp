<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<body>
	<div class="collabo_popup_wrap">
		<div class="collabo_table_wrap">
			<table class="collabo_table type02" cellpadding="0" cellspacing="0">
				<colgroup>
					<col width="90">
					<col width="*">
					<col width="50">
				</colgroup>
				<tbody>
					<tr>
						<th><spring:message code='Cache.lbl_LinkAF'/></th>	<!-- 선행업무 -->
						<td><input type="text" class="taskName" id="preLinkedTask" value="" readonly/></td>
						<td><a href="#" id="removeLinkedTask" class="btnPhotoRemove gray"></a></td>
					</tr>
					<tr>
						<th></th>
						<td><select id="taskListSelect"class="selectType02 w100"></select></td>
						<td><a href="#" id="searchTaskList" class="btnTypeDefault search"></a></td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</body>
<script type="text/javascript">
(function(){
	var linkedTaskSeq = "${linkedTaskSeq}";
	var linkedTaskName = "${linkedTaskName}";
	var taskSeq = "${taskSeq}";
	
	/* select box의 option을 설정해주는 함수 */
	function setSelect() {
		$("#preLinkedTask").val(linkedTaskName);
		
		$("#taskListSelect").html($('<option>'));
		var taskSeqStr = "${taskSeqStr}";
		var taskNameStr = "${taskNameStr}";
		
		var taskSeqList = taskSeqStr.split(";");
		var taskNameList = taskNameStr.split(";");
		
		var taskList = [];
		
		for(var i=0; i<taskSeqList.length-1; i++) { /* 정렬을 위한 데이터 가공 */
			var param = {};
			param.name = taskNameList[i];
			param.seq = taskSeqList[i];
			
			taskList.push(param);
		}
		
		taskList = taskList.sort((a, b) => a.name < b.name ? -1 : 1); /* select box 이름 순으로 정렬 */
		
		for(var i = 0; i<taskList.length; i++) {
			$("#taskListSelect").append($('<option>',{"value":taskList[i].seq}).text(taskList[i].name));
		}
	};
	/* 업무를 연결 또는 제거를 했을 때, 부모 창에 간트 차트를 새로고침 해주는 함수 */
	function refresh() {
		$("#preLinkedTask").val(linkedTaskName);
		parent.$(".btnRefresh").trigger("click");
	}
	/* 업무 연결 처리 함수 */
	function addLinkedTask() {
		$.ajax({
			type:"POST",
			data: {
				"taskSeq":taskSeq,
				"linkTaskSeq": linkedTaskSeq,
				"linkTaskName": linkedTaskName
			},
			url:"/groupware/collabTask/addTaskLink.do",
			success: function(data) {
				refresh();
			},
			error:function (jqXHR, textStatus, errorThrown) {
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />")
			}
		});
	}
	/* 관련업무 팝업 창을 실행 */
	$("#searchTaskList").click(function(){
		var popupUrl = "/groupware/collabTask/CollabTaskLinkPopup.do?";
		popupUrl += "pType="+"${prjType}"+"&pSeq="+"${prjSeq}"+"&callBackFunc=callbackTaskLink";
		
		CFN_OpenWindow(popupUrl, Common.getDic("lbl_linkTask"), 600, 500, "");
	});
	/* select box에서 연결할 업무를 선택했을 때 해당 업무 연결 */
	$("#taskListSelect").change(function() {
		$("#removeLinkedTask").trigger("click");
		linkedTaskName = $("#taskListSelect option:selected").text();
		linkedTaskSeq = $("#taskListSelect option:selected").val();
		
		addLinkedTask();
	});
	/* 연결되어 있는 업무를 제거 이벤트*/
	$("#removeLinkedTask").click(function(){
		linkedTaskName = "";
		
		$.ajax({
			type:"POST",
			data: {
				"taskSeq": taskSeq
			},
			async: false,
			url:"/groupware/collabTask/deleteTaskLink.do",
			success: function(data) {
				refresh();
			},
			error:function (jqXHR, textStatus, errorThrown) {
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred'/>") // 오류가 발생했습니다.
			}
		});
	});
	/* 관련업무 팝업 창을 띄워서 해당 팝업에서 관련업무를 선택했을 때, 정보 받아오기 */
	window.addEventListener('message', function(e) {
		switch(e.data.functionName) {
		case "callbackTaskLink" :
			$("#removeLinkedTask").trigger("click");
			
			linkedTaskName = e.data.params.TaskName;
			linkedTaskSeq = e.data.params.TaskSeq;
			
			addLinkedTask();
			break;
		}
	});
	
	setSelect();
})();
</script>