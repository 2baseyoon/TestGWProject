<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

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
	
(function() {
	
	var initFunc = function() {
		$("#spnCommentInfo").text("<spring:message code='Cache.msg_gw_ValidationComment' />");
	}
	
	var setCommentData = function() {
		parent.$("#hiddenComment").val($("#txtComment").val());
	}
	
	//하단의 닫기 버튼 함수
	this.closeLayer = function() {
		Common.Close();
	}
	
	this.saveComment = function() {
		
		if ($("#txtComment").val()=="") {
			parent.Common.Warning("<spring:message code='Cache.msg_gw_ValidationComment' />", "Warning Dialog", function () {     //필드명 입력
		 		$("#txtComment").focus();
		    });
			return;
		}
		parent._CallBackMethod(setCommentData());
		Common.Close();
	}
	
	initFunc();
})();
</script>
<div>
	<form id="frmComment">
		<!-- 팝업 Contents 시작 -->
		<div id="spnCommentInfo" class="sadmin_pop"></div>
		<textarea id="txtComment"></textarea>
		<div class="popBottom">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveComment();"><spring:message code="Cache.btn_Confirm"/></a>	<!-- 확인 -->
			<a href="#" class="btnTypeDefault" onclick="closeLayer();"><spring:message code="Cache.btn_Cancel"/></a>	<!-- 취소 -->
		</div>
	</form>
</div>