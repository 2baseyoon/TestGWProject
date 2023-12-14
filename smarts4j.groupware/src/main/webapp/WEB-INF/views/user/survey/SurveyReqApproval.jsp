<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent pd0">
	<div id="approvalBtn" class="surAPTop" style="display:none;">
		<a class="btnTypeChk btnTypeDefault"><spring:message code='Cache.lbl_Approval' /></a>
		<a class="btnTypeX btnTypeDefault"><spring:message code='Cache.lbl_Deny' /></a>
	</div>				
	<div class="surAPBtm">
		<div id="tarDiv"  style="height:93%">
		  <iframe id="tarIfm" name="timessquare" src='' frameborder='0' style='overflow:hidden;overflow-x:hidden;overflow-y:hidden;height:100%;width:100%;position:absolute;top:0px;left:0px;right:0px;bottom:0px' height='100%' width='100%'>
			<html>
				<head></head>
				<body>
					<div style='font:15px arial, serif;'>
	 					iFrame을 지원하지 않는 브라우저입니다.<br>
 					</div>
 				</body>
 			</html>
		  </iframe>
		</div>						
	</div>
</div>

<script>
	//#sourceURL=SurveyReqApproval.jsp
	var surveyId = CFN_GetQueryString("surveyId");
	var viewType = CFN_GetQueryString("viewType");
	var openLayerName = CFN_GetQueryString("CFN_OpenLayerName") == "undefined" ? "" : CFN_GetQueryString("CFN_OpenLayerName");
	
	initContent();

	// 승인 및 검토 요청 팝업
	function initContent(){
		if(viewType == "req"){
			$("#approvalBtn").show();
			$("#tarDiv").css("height","82%");
		}

//		$('#tarDiv').load("/groupware/survey/goSurvey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=reqApproval&surveyId=" + surveyId);
		$('#tarIfm').attr("src","/groupware/survey/goSurvey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=reqApproval&isPopup=Y&CFN_OpenLayerName=" + openLayerName + "&surveyId=" + surveyId);
	}
	
	$(function() {
		/* 설문 설정 on Off*/
		$('.surveryContSetting').on('click', function(){
			var mParent = $('.surveySettingView');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
		});
		
		// 승인 거부 버튼
		$('.btnTypeDefault').on('click', function(e) {
			if ($(this).hasClass('btnTypeChk')) {
				parent.updateSurveyStateByPopup('accept');
			} else {
				parent.updateSurveyStateByPopup('refuse');
			}
		});
	});	
</script>