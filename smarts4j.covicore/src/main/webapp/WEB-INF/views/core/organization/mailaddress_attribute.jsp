<%@ page language="java" contentType="text/html; charset=UTF-8"	 pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
	
	<style>
		td {
			padding: 10px 15px 10px 3px;
		}
		
		th {
			font-size: 11pt;
		}
		
		table {
			width: 100%;
		}
		
		input[type=text] {
			border: 0px;
			border-bottom: 1px solid lightgray;
			min-height: 25px;
		}
	</style>
</head>

<body>
<div style="padding-top: 10px;">
	<table>
		<colgroup>
			<col style="width: 20%;">
			<col style="width: 80%;">
		</colgroup>
		<tbody>
			<tr>
				<th><spring:message code='Cache.lbl_Mail' /></th> <!-- 메일 -->
				<td>
					<input type="text"  id="txtEmail1"  class="AXInput W100"  style="width:40%;"> @ <input type="text"  id="txtEmail2"  class="AXInput W100"  style="width:50%;">
				</td>
			</tr>
		 </tbody>
	</table>
	
	<div align="center" style="padding-top: 15px">
		<input type="button" id="btnSave" value="<spring:message code='Cache.lbl_DuplicateCheck' />" onclick="CheckValidation(this);" class="AXButton" > <!-- 중복체크 -->
		<input type="button" id="btnModify" value="<spring:message code='Cache.lbl_Save' />" onclick="CheckValidation(this);" class="AXButton" > <!-- 확인-->
		<input type="button" id="btnClose" value="<spring:message code='Cache.btn_Close' />" onclick="closePopup();" class="AXButton"> <!-- 닫기 -->
	</div>
</div>
</body>
<script>

	var type = "${type}";
	//var mail = "${mail}";
	var mode = "${mode}";
	var CallBackMethod = "${CallBackMethod}";
	
	//팝업 닫기
	function closePopup() {
		Common.Close();
	}
	
	window.onload = initContent();

	function initContent(){
/*  		if(mail != null){
			$("#txtEmail1").val(mail.split('@')[0]);
			$("#txtEmail2").val(mail.split('@')[1]);
		} */
	}

/* 
  $(function() {
	  
		 if("${mode}" == "modify"){
			$("#btnSave").css("display", "none");
			$("#btnModify").css("display", "");
			
			$.ajaxSetup({
				cache : false
			});
			
			$.getJSON('/covicore/getGroup.do', {ShareType : '${ShareType}',GroupID : '${GroupID}'}, function(d) {
				d.list.forEach(function(d) {
					$("#txtGroupName").val(d.GroupName);
					$("#txtGroupPriorityOrder").val(d.OrderNO);
				});
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("/covicore/getGroupList.do", response, status, error);
			});
				
		} 
	}); 
	
	function CheckValidation(pObj) {
	    var bReturn = true;
	    if ($("#txtGroupName").val() == "") {
	        Common.Warning("<spring:message code='Cache.msg_EnterGroupName'/>", ""); //그룹명을 입력하세요.
	        bReturn = false;
	    } else if ($("#txtGroupPriorityOrder").val() == "") {
	        Common.Warning("<spring:message code='Cache.msg_EnterPriorityNumber'/>", ""); //우선순위를 입력하세요.
	        bReturn = false;
	    }
	
	    if(!bReturn) return false;
		
		$.ajaxSetup({
		     async: true
		});
		
		if(pObj.id == 'btnSave'){
			$.ajax({
				url : "/covicore/RegistGroup.do",
				type : "POST",
				data : {
					"GroupName" :  $("#txtGroupName").val(),
					"GroupPriorityOrder" :  $("#txtGroupPriorityOrder").val(),
					"ShareType" :  "${ShareType}"
				},
				success : function(d) {
					try {
						if(d.result == "OK") {
							Common.Inform("<spring:message code='Cache.msg_SuccessRegist'/>", 'Information Dialog', function (result) { //정상적으로 등록되었습니다.
								parent.window.location.href();
					        }); 
						} else if(d.result == "FAIL") {
							Common.Warning("<spring:message code='Cache.msg_ErrorRegistBizCardGroup'/>"); //그룹 등록 오류가 발생했습니다.
						} else {
							Common.Warning("<spring:message code='Cache.msg_CantRegistGroupDuplicateName'/>"); //이름이 중복된 그룹은 등록할 수 없습니다.
						}
					} catch(e) {
						
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("/covicore/RegistGroup.do", response, status, error);
				}
			});
		} else if(pObj.id == 'btnModify'){
			$.ajax({
				url : "/covicore/ModifyGroup.do",
				type : "POST",
				data : {
					"GroupName" :  $("#txtGroupName").val(),
					"GroupPriorityOrder" :  $("#txtGroupPriorityOrder").val(),
					"GroupID" : "${GroupID}"
				},
				success : function(d) {
					try {
						if(d.result == "OK") {
							Common.Inform("<spring:message code='Cache.msg_SuccessModify'/>", 'Information Dialog', function (result) { //정상적으로 수정되었습니다.
								parent.bizCardGrid.reloadList();
								closeLayer();
					        }); 
						} else if(d.result == "FAIL") {
							Common.Warning("<spring:message code='Cache.msg_ErrorModifyBizCardGroup'/>"); //그룹 수정 오류가 발생했습니다.
						} else {
							Common.Warning("<spring:message code='Cache.msg_CantRegistGroupDuplicateName'/>"); //이름이 중복된 그룹은 등록할 수 없습니다.
						}
					} catch(e) {
						
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("/covicore/ModifyGroup.do", response, status, error);
				}
			});
		}
	} */
</script>