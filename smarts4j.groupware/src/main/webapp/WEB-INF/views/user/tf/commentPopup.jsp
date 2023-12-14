<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable surveryAllPop" id="testpopup_p" style="width:285px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent layerType02 ">
			<div class="popTop">
				<p id="spnCommentInfo"><spring:message code='Cache.msg_gw_ValidationComment'/></p> <!-- 처리사유를 입력해주세요 -->
			</div>
			<div class="popMiddle" style="height:97px;">
				<textarea id="txtComment" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
			</div>	
			<div class="popBottom">
				<a href="#" class="btnTypeDefault btnTypeBg" onclick="javascript:saveComment();"><spring:message code='Cache.btn_Confirm'/></a> <!-- 확인 -->
				<a href="#" class="btnTypeDefault" onclick="javascript:closeLayer();"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>
	</div>	
</div>
<script>
	var comment = null;
	var upperObj = null;
	var mode = CFN_GetQueryString("mode");
	
	$(document).ready(function(){
		if(parent != null){
			comment = parent.$("#closeComment");
			upperObj = parent;
		} else {
			comment = opener.$("#closeComment");
			upperObj = opener;
		}
	
		$("#spnCommentInfo").text("<spring:message code='Cache.msg_Board_reasonProcess'/>");
	});
	
	function setCommentData(){
		comment.val($("#txtComment").val());
	}
	
	//하단의 닫기 버튼 함수
	function closeLayer(){
		Common.Close();
	}
	
	function saveComment(){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		if($("#txtComment").val()==""){
			upperObj.Common.Warning("<spring:message code='Cache.msg_Board_reasonProcess'/>", "Warning Dialog", function () {	 //필드명 입력
				$("#txtComment").focus();
			});
			return;
		}
		upperObj._CallBackMethod(setCommentData());
		Common.Close();
	}
</script>