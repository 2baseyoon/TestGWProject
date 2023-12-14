<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style>
	#frmComment { padding: 10px; }
	
	#spnCommentInfo{
		font-weight: 700;
		padding-bottom: 10px;
	}
	
	#txtComment {
		width: 100%;
		height: 100px;
		resize: none;
	}
</style>

<script>
	//var mode = ${mode};
	
	$(document).ready(function () {
		$("#spnCommentInfo").text("<spring:message code='Cache.msg_gw_ValidationComment' />");
	});

	function setCommentData(){
		parent.$("#hiddenComment").val($("#txtComment").val());
	}
	
	//하단의 닫기 버튼 함수
	function closeLayer(){
		Common.Close();
	}

	function saveComment(){
		if($("#txtComment").val()==""){
			parent.Common.Warning("<spring:message code='Cache.msg_gw_ValidationComment' />", "Warning Dialog", function () {     //필드명 입력
		 	$("#txtComment").focus();
		    });
			return;
		}
		parent._CallBackMethod(setCommentData());
		Common.Close();
	}
</script>
<div>
	<form id="frmComment">
		<!-- 팝업 Contents 시작 -->
		<div id="spnCommentInfo"></div>
		<textarea id="txtComment" placeholder="<spring:message code='Cache.msg_Board_reasonProcess' /> <spring:message code='Cache.msg_BoardReasonMaxChar' />" maxlength="300"></textarea>
		<div align="center" style="padding-top: 10px">
			<input type="button" value="<spring:message code='Cache.lbl_Confirm' />" onclick="saveComment();" class="AXButton red">
			<input type="button" value="<spring:message code='Cache.lbl_Cancel' />" onclick="closeLayer();" class="AXButton">
		</div>
	</form>
</div>