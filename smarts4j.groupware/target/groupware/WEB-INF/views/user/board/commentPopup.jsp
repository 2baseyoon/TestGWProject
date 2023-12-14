<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<link rel="stylesheet" id="cCss" type="text/css" /> 
<link rel="stylesheet" id="cthemeCss" type="text/css" /> 

<div class="layer_divpop ui-draggable surveryAllPop" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent layerType02 ">
			<div class="popTop">
				<p id="spnCommentInfo">처리사유를 입력해주세요</p>
			</div>
			<div class="popMiddle" style="height:97px;">
				<textarea id="txtComment" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
			</div>	
			<div class="popBottom">
				<a href="#" class="btnTypeDefault btnTypeBg" onclick="javascript:saveComment();"><spring:message code='Cache.lbl_Confirm'/></a>
				<a href="#" class="btnTypeDefault" onclick="javascript:closeLayer();"><spring:message code='Cache.btn_Cancel'/></a>
			</div>
		</div>
	</div>	
</div>
<script>
	var comment = null;
	var upperObj = null;
	var mode = CFN_GetQueryString("mode");
	
	$(document).ready(function () {
		//팝업 모드 별 parent, opener Element참조용...개선이 필요함 구림
		if(parent != null && parent.$("#hiddenComment").val() != undefined  ){
			comment = parent.$("#hiddenComment");
			upperObj = parent;
		} else {
			comment = opener.$("#hiddenComment");
			upperObj = opener;
		}
	
		if(mode == "updateCheckOut"){
			$('#spnCommentInfo').text("<spring:message code='Cache.msg_Board_reasonCheckOut'/>");
		} else {
		/* 	$("#spnCommentInfo").text("<spring:message code='Cache.msg_gw_ValidationComment' />"); */
		 	$("#spnCommentInfo").text("<spring:message code='Cache.msg_Board_reasonProcess'/>"); 
		}
		
		if (parent && parent.communityID != '' && parent.communityCssPath != '' && parent.communityTheme != ''){
			$("#cCss").attr("href",parent.communityCssPath + "/community/resources/css/community.css");
			$("#cthemeCss").attr("href",parent.communityCssPath + "/covicore/resources/css/theme/community/"+parent.communityTheme+".css");
		}
		else {
			$("#cCss, #cthemeCss").remove();
		}
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
			upperObj.Common.Warning("<spring:message code='Cache.msg_Board_reasonProcess'/>", "Warning Dialog", function () {     //필드명 입력
/* 			upperObj.Common.Warning("<spring:message code='Cache.msg_gw_ValidationComment' />", "Warning Dialog", function () {     //필드명 입력 */
		    	$("#txtComment").focus();
		    });
			return;
		}
		upperObj._CallBackMethod(setCommentData());
		Common.Close();
	}

	
</script>
