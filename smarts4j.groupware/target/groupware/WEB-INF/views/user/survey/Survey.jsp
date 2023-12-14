<%@page import="egovframework.baseframework.util.SessionHelper,
				egovframework.baseframework.data.CoviMap,
				egovframework.covision.groupware.auth.SurveyAuth"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String reqType = request.getParameter("reqType");
	String surveyID = request.getParameter("surveyId");
	String listType = request.getParameter("listType");
	String communityID = request.getParameter("communityId");
	
	boolean isJoinSurvey = false;
	if ("join".equals(reqType)){
		CoviMap params = new CoviMap();
		params.put("surveyID", surveyID);
		params.put("userID", SessionHelper.getSession("USERID"));
		params.put("viewType", "myAnswer");
		isJoinSurvey = SurveyAuth.isJoinSurvey(params);
	}
	
	if(isJoinSurvey) {
		String redirectURL = "/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&viewType=myAnswer";
		redirectURL += "&listType="+listType;
		redirectURL += "&surveyId="+surveyID;
		if(communityID != null) redirectURL += "&CSMU=C&communityId="+communityID;
		out.println("<script>window.self.location='"+redirectURL+"';</script>");
	}

	if(request.getParameter("isPopup") != null && request.getParameter("isPopup").equals("Y")){
%>
		<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<%
	}
%>


<link rel="stylesheet" id="surveyCheader" type="text/css"  /> 
<link rel="stylesheet" id="cCss" type="text/css" /> 
<link rel="stylesheet" id="cthemeCss" type="text/css" /> 

<div class='cRConTop'>
	<div class='surveryTopButtons'>
		<a class='btnTypeDefault btnTypeLArrr' id='listBtn' style='display:none;' onclick='goPrevPage()'><spring:message code='Cache.lbl_Index' /></a><!-- 목록 -->
		<a class='btnTypeDefault'  id="reuseSurveyBtn" style="display:none;" onclick="reuseSurvey()"><spring:message code='Cache.btn_reuse' /></a><!-- 재사용 -->
		<a class="btnTypeDefault left" id="deleteBtn" style='display:none;' onclick="deleteSurvey(); return false;"><spring:message code='Cache.lbl_delete' /></a><!-- 삭제 -->
	</div>
	<div class='surveySetting'>
		<a class="surveryContSetting"><spring:message code='Cache.lbl_Set' /></a><!-- 설정 -->
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<div class='surveyMakeView'>							
	</div>
</div>

<script>
	//# sourceURL=Survey.jsp
	// 미리보기, 설문참여, 승인 및 검토에서 팝업 창
	var reqType = CFN_GetQueryString("reqType")	// reqType : preview(미리보기), join(설문참여), reqApproval(승인 or 검토)
	var listType = CFN_GetQueryString("listType") // proceed(진행중), complete(완료), tempSave(임시저장), reqApproval(검토, 승인 대기) - 목록으로 돌아갈 때 사용
	var listSelect = CFN_GetQueryString("listSelect")	// written(내가 작성한 설문) , participated(내가 참여한 설문) - 목록으로 돌아갈 때 사용
	var surveyId = (reqType == 'preview') ? '' : CFN_GetQueryString("surveyId");
	var communityId = CFN_GetQueryString("communityId") == "undefined" ? "" : CFN_GetQueryString("communityId");
	var isPopup = CFN_GetQueryString("isPopup") == "undefined" ? "" : CFN_GetQueryString("isPopup");
	var openLayerName = CFN_GetQueryString("CFN_OpenLayerName") == "undefined" ? "" : CFN_GetQueryString("CFN_OpenLayerName");
	
	var surveyInfo = null;
	var questions = null;
	var isGrouping = null;
	var nowQuestions = new Array();	// 현재 문항 arr
	var questionSortArr = new Array();	// 사용자의 이전 다음 문항 arr
	var tempGroups = null;
	var answerArr = new Array();	// 사용자의 답변 arr
	var realAnswerArr = new Array();	//사용자가 실제로 답변을 한 문항 목록 
	
	var g_fileList = null;
	var resultViewAuth = false;

	checkSurveyResultViewAuth();
	initContent();
	
	// 결과보기 대상자 여부 체크
	function checkSurveyResultViewAuth() {
		$.ajax({
			type : "POST",
			data : {surveyId : surveyId},
			async: false,
			url : "/groupware/survey/getTargetResultViewAuth.do",
			success:function (data) {
				if(data.status == 'SUCCESS') {
					if(data.data == 'Y') {
						resultViewAuth = true;
					}else {
						resultViewAuth = false;
					}
				} else {
					resultViewAuth = false;
				}				
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}

	// 미리보기, 설문참여, 승인검토 팝업
	function initContent(){
		init();	// 초기화
		
		if (parent && parent.communityID != '' && parent.communityCssPath != '' && parent.communityTheme != ''){
			$("#cCss").attr("href",parent.communityCssPath + "/community/resources/css/community.css");
			$("#cthemeCss").attr("href",parent.communityCssPath + "/covicore/resources/css/theme/community/"+parent.communityTheme+".css");
		}
		else {
			$("#cCss, #cthemeCss").remove();
		}
		
		if (CFN_GetQueryString("communityId") != 'undefined'){
			var level = (typeof memberLevel == 'string') ? memberLevel : '0';
			if (level == '0') $("#listBtn").remove();
		}
	}
	
	// 초기화
    function init() {
		// 커뮤니티 테마 적용
		if(communityId != "" && communityId != "0"){
			$.ajax({
				url: "/groupware/layout/userCommunity/communityHeaderSetting.do",
				type: "POST",
				async: false,
				data: {
					"communityID": communityId
				},
				success: function(data){
					if(data.list.length > 0){
						$(data.list).each(function(i, v){
							if(v.CommunityTheme != '' && v.CommunityTheme != null){
								$("#surveyCheader").attr("href", "/HtmlSite/smarts4j_n/covicore/resources/css/theme/community/" + v.CommunityTheme + ".css?v=" + v.nowDate);
							}
						});
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityHeaderSetting.do", response, status, error); 
				}
			}); 
		}
		
    	if (reqType == "preview") {
    		//$('.commContent').addClass('popLeft');	// 팝업시 class 변경
    	} else if (reqType == "join" || reqType == "edit") {
    		$('#listBtn, #editBtn').css('display', '');
    		
    		if(isPopup === "Y") $("#listBtn").hide();
    	} else {
    		$('.surveryWinPop').css('display', 'none');
    	}
		
    	if (reqType == "preview") {
    		surveyInfo = parent.surveyInfo;
    	} else if(reqType == "edit") {
    		$.ajax({
    			type : "POST",
    			data : {
    				surveyId : surveyId,
    				viewType : "myAnswer"
    			},
    			async: false,
    			url : "/groupware/survey/getSurveyAnswerData.do",
    			success:function (list) {
    				if (list.data != null) {
    					surveyInfo = $.extend(true, {}, list.data);
    					g_fileList = list.fileList;
    					
    					if(surveyInfo.state == "F") { // 진행중인 설문은 삭제할 수 없도록 삭제 버튼 제거
    						$("#deleteBtn").remove();
    					}
    					
    					if(['D','X','G'].includes(surveyInfo.state)){ //거부 또는 종료일 때
    						$("#reuseSurveyBtn").show();
    					}
    					if(surveyInfo.registerCode == Common.getSession("USERID")){
    						if (listType != "proceed") {
    							$("#deleteBtn").show();
    						}
    					}
    				}
    			},
    			error:function(response, status, error) {
    				CFN_ErrorAjax(url, response, status, error);
    			}
    		});
    	} else {
    		$.ajax({
    			type : "POST",
    			data : {surveyId : surveyId},
    			async: false,
    			url : "/groupware/survey/getSurveyData.do",
    			success:function (list) {
    				surveyInfo = $.extend(true, {}, list.data);
    				g_fileList = list.fileList; 
    				
					if(['D','X','G'].includes(surveyInfo.state)){ //거부 또는 종료일 때
						$("#reuseSurveyBtn").show();
					}
    				if(surveyInfo.registerCode == Common.getSession("USERID")){
    					//$("#deleteBtn").show();
    				}
    			},
    			error:function(response, status, error) {
    				CFN_ErrorAjax(url, response, status, error);
    			}
    		});
    	}
    	
   		questions = surveyInfo.questions;
   		isGrouping = surveyInfo.isGrouping;
   		
   		setSurveyInfo();	// 설문 정보 세팅
   		
    	setQuestionData("init")	// 문항 데이터 세팅
    	
    	setSurveyHtml();	// 설문 html
    	
    	setSurveyQuestionHtml();	// 설문 문항 html
    }
	
	// 설문 정보 세팅
    function setSurveyInfo() {
   		var answerObj = null;
		$.each(questions, function(i, v) {
			answerObj = new Object();
			answerObj.surveyID = surveyId;
			answerObj.questionID = v.questionID;
			answerObj.questionNO = v.questionNO;
			answerObj.questionNO = v.questionNO;
			answerObj.groupingNo = v.groupingNo;
			answerObj.itemID = "";
			answerObj.answerItem = "";
			answerObj.etcOpinion = "";
			answerObj.weighting = "";
			answerArr.push(answerObj);
		}); 
    }
	
 	// 설문 html
    function setSurveyHtml() {
		$(".surveyMakeView").empty();
		
		var html = "<div class='surveySettingView active'>";	
		html += "<div class='surveyParticipationContTItle bvcTitle'>";
		html += "<h2>";
		html += "<span class='btnType02 ";
		if (surveyInfo.isImportance == 'Y') {
			html += "active'";	
		} else {
			html += "'";
		}
		html += "><spring:message code='Cache.lbl_surveyUrgency' /></span> ";
		html += surveyInfo.subjectHtml;
		html += "<p class='date'>";
		html += "<span>" + CFN_TransLocalTime(surveyInfo.surveyStartDate,'yyyy.MM.dd') + "</span>";
		html += "~";
		html += "<span>" + CFN_TransLocalTime(surveyInfo.surveyEndDate,'yyyy.MM.dd') + "</span>";
		html += "</p>";
		html += "</h2>";
		html += "<div class='attFileListBox' style='top:42px; right:15px;'></div>";
		html += "<p class='txt'>";
		
		var surveyInfoInlineImages = surveyInfo.inlineImage;
		if(surveyInfoInlineImages){
			var surveyInfoInlineImageList = surveyInfoInlineImages.split('|');			
		 	for (var si = 0; si < surveyInfoInlineImageList.length; si++) {
		 		surveyInfo.description = surveyInfo.description.replace("‡%" + si + "‡%", "src=\""+  surveyInfoInlineImageList[si] + "\"" );
		 	}
		}
		
		html += "<div>";
		html += surveyInfo.description;
		html += "</div>";
		html += "</p>";
		html += "<div class='spBtnBox'>";
		html += "<div class='pagingType01'>";
		html += "</div>";
		// TODO 차트 보기 기능을 설문 진행중일때도 작성자 결과 공개 기간에 상관없이 다 보여주는거고, 나머지는 결과 공개 기간일 때만 보는건지...어느걸로 할지 정해야함.
		if (reqType != "preview" && resultViewAuth) {
			html += "<a class='btnTypeDefault' onclick='goTarget()'><spring:message code='Cache.lbl_polltargetview' /></a>";
			html += "<a class='btnTypeDefault ml5' onclick='goResultTarget()'><spring:message code='Cache.lbl_title_surveyResult_01' /></a>";
		}
		
		//개별호출-일괄호출
		var sessionObj = Common.getSession(); //전체호출
		
		// 관리자이거나, 설문 작성자일경우 설문조기마감 버튼 보임
		if((sessionObj["isAdmin"] == 'Y' || sessionObj["USERID"] == surveyInfo.registerCode) && surveyInfo.state != 'G' && surveyInfo.state != 'del' && reqType != 'preview' && reqType != 'reqApproval') {
			html += "<a class='btnTypeDefault ml5' onclick='closeSurvey()'><spring:message code='Cache.btn_EarlyCloseSurvey' /></a>";
		}
		
		html += "</div>";
		html += "</div>";
		html += "</div>";
    	
    	$(".surveyMakeView").append(html);
    	
    	if(g_fileList !== undefined && g_fileList !== null && g_fileList.length > 0){
			var attFileAnchor = $('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');"/>').addClass('btnAttFile btnAttFileListBox').text('(' + g_fileList.length + ')');
			var attFileListCont = $('<ul>').addClass('attFileListCont');
			var attFileDownAll = $('<li>').append("<a href='#' onclick='javascript:downloadAll(g_fileList)'>"+Common.getDic("lbl_download_all")+"</a>").append($('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');" >').addClass("btnXClose btnAttFileListBoxClose"));
			var attFileList = $('<li>');
			var videoHtml = '';
			
			$.each(g_fileList, function(i, item){
				var iconClass = "";
				if(item.Extention == "ppt" || item.Extention == "pptx"){
					iconClass = "ppt";
				} else if (item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
					iconClass = "fNameexcel";
				} else if (item.Extention == "pdf"){
					iconClass = "pdf";
				} else if (item.Extention == "doc" || item.Extention == "docx"){
					iconClass = "word";
				} else if (item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
					iconClass = "zip";
				} else if (item.Extention == "jpg" || item.Extention == "gif" || item.Extention == "png"|| item.Extention == "bmp"){
					iconClass = "attImg";
				} else {
					iconClass = "default";
				}				
				$(attFileList).append($('<p style="cursor:pointer;"/>').attr({"fileID": item.FileID, "fileToken": item.FileToken}).addClass('fName').append($('<span title="'+item.FileName+'">').addClass(iconClass).text(item.FileName)).append($('<span class="fileSize">').text("("+convertFileSize(item.Size)+")")));
			});
			$('#BodyText').html($('#BodyText').html() + videoHtml);
			
			$(attFileListCont).append(attFileDownAll, attFileList);
			$('.attFileListBox').append(attFileAnchor ,attFileListCont);
			$('.attFileListBox .fName').click(function(){
				Common.fileDownLoad($(this).attr("fileID"), $(this).text(), $(this).attr("fileToken"));
			});
			$('.attFileListBox').show();
		} else {
			$('.attFileListBox').hide();
		}
    	
 	}
 	
 	function downloadAll( pFileList ){
		var fileList = pFileList.slice(0);	//array 객체 복사용
		Common.downloadAll(fileList);
	}
 	
 	// 설문 문항 html
    function setSurveyQuestionHtml() {
    	$('p.groupTitle, div.surveyParticipationListView').remove();

 		var html = "";
 		var questionNum = 0;
 		if (isGrouping == 'Y' && nowQuestions.length > 0) {
 			html += "<p class='groupTitle'>";
 			html += "<span>";
 			html += nowQuestions[0].groupName;
 			html += "</span>";
 			html += "</p>";
 		}
 		html += "<div class='surveyParticipationListView'>";
 		html += "<div class='surPartListCont'>";

    	var itemRadioCnt = 1;
    	var labelCnt = 1;
    	var defaultNext = 99;
    	$.each(nowQuestions, function(i, v) {
    		questionNum = v.questionNO;
    		defaultNext = (isGrouping == 'Y' )? nowQuestions[0].nextGroupingNo :  v.nextDefaultQuestionNO  //기본 
    		var answerItem ='';	// 기존 선택한 답변 세팅
 			var groupingNo = v.groupingNo;
			var questionNo = v.questionNO;
			$.each(answerArr, function(i, v) {
				if (groupingNo == v.groupingNo && questionNo == v.questionNO) {
					if (v.questionType == 'N') {
						answerItem = v.weighting;
					} else if(v.questionType == 'S' || v.questionType=='M'){
						answerItem = v.itemID;
					} else if(v.questionType == 'D'){
						answerItem = v.answerItem;
					}
						
					return false;
				}
			});
			
    		var isEtc = v.isEtc;
       		if ((typeof(v.paragraph) != "undefined" && v.paragraph != "") || (typeof(v.description) != "undefined" && v.description != "")) {
    			html += "<div class='surParticipationBox inputFocusConten exTitle'>";
   				html += "<p class='spListTitle'>";
   				if((typeof(v.paragraph) != "undefined" && v.paragraph != "")) {
   					html += "<span>" + v.paragraph + "</span>";
   				}
   				if((typeof(v.description) != "undefined" && v.description != "")){
   					html += v.description;
   				}
   				html += "</p>";
       		} else {
       			html += "<div class='surParticipationBox'>";
       		}
        	html += "<input type='hidden' value=" + v.questionID + ">";
        	html += "<input type='hidden' value='" + v.questionType + "'>";
        	html += "<input type='hidden' value='" + isEtc + "'>";
        	html += "<input type='hidden' value='" + v.isRequired + "'>";
        	html += "<input type='hidden' value='" + v.requiredInfo + "'>";
   			html += "<div class='sruTitleCont'>";
   			html += "<div class='ribbon shadow'>" + v.questionNO + "</div>";
   			
   			html += "<div class='title'>";
   			if(v.isRequired == "Y")
   				html += "<span class='star'>";

   			html +=  v.question;
   			
 			if(v.isRequired == "Y")
   				html += "</span >";
   			
   			if(v.questionType == "D" && v.isRequired == "Y" && v.requiredInfo != ""){	//주관식, 필수
   			
   				//툴팁
   	   			html += "<div class='collabo_help02'>";
				html += "	<a href='#' class='help_ico'></a>";
				html += "	<div class='helppopup'>";
				html += "		<div class='help_p'>";
				html += "		<p class='helppopup_tit'>안내</p>";
				html += 		v.requiredInfo;
				html += "		</div>";
				html += "	</div>";
				html += "</div>";		//</h3>
			
   			}
   			
   			html += "</div>";
   			html += "</div>";
       		
   			html += "<div class='sruParticipationListDivi'>";
    		var questionType = v.questionType;
    		if (questionType == 'S') {
    			var len = v.items.length;
        		$.each(v.items, function(i, v) {
        			if (i == (len -1) && isEtc == 'Y') {
            			html += "<div class='exList inputFocusConten theRest'>";
            			html += "<div class='titleStyle01'>";
            			html += "<div class='radioStyle03'>";
            			html += "<input type='hidden' value='" + v.itemID + "'>";
            			html += "<input type='hidden' value='" + v.nextQuestionNO + "'>";
            			
            			if (answerItem != '' && answerItem != undefined && answerItem == v.itemID) {	// 답변 세팅
            				//그룹핑일 경우 onchang 걸 필요 없음
            				defaultNext = v.nextQuestionNO;  // 이미 선택된 값이 있을 경우 defaultNext 값도 변경
            				html += "<input type='radio' id='sel" + labelCnt  + "' name='itemRadio" + itemRadioCnt + "' checked " +( (isGrouping != 'Y' ) ? "onchange='changeObjectiveValue(this)'" : "") + "/><label for='sel" + labelCnt + "'><span></span>";
            			} else {
	            			html += "<input type='radio' id='sel" + labelCnt  + "' name='itemRadio" + itemRadioCnt + "' " +( (isGrouping != 'Y' ) ? "onchange='changeObjectiveValue(this)'" : "") + "/><label for='sel" + labelCnt + "'><span></span>";
            			}
            			html += "<input type='text' class='inpStyle01 type03 subject inpFocus HtmlCheckXSS ScriptCheckXSS' placeholder='" + "<spring:message code='Cache.lbl_Etc'/>" + "'/></label>";
        			} else {
	        			html += "<div class='exList'>";
	        			html += "<div class='titleStyle01'>";
	        			html += "<div class='radioStyle03'>";
	        			html += "<input type='hidden' value='" + v.itemID + "'>";
	        			html += "<input type='hidden' value='" + v.nextQuestionNO + "'>";
	        			
	        			if (answerItem != '' && answerItem != undefined && answerItem == v.itemID) {
	        				html += "<input type='radio' id='sel" + labelCnt  + "' name='itemRadio" + itemRadioCnt + "' checked " + "onchange='changeObjectiveValue(this)'" + "/><label for='sel" + labelCnt + "'><span></span>" + v.item + "</label>";
	        			} else {
		        			html += "<input type='radio' id='sel" + labelCnt  + "' name='itemRadio" + itemRadioCnt + "' " + "onchange='changeObjectiveValue(this)'" + "/><label for='sel" + labelCnt + "'><span></span>" + v.item + "</label>";
	        			}
        			}
        			html += "</div>";
        			html += "</div>";

       				var fileIds;
					if (typeof(v.updateFileIds) != "undefined" && v.updateFileIds != "") {	// back 이미지
						fileIds = v.updateFileIds.split(';');
    					$.each(fileIds, function(i, v) {
    						if(v){
    							var src = "/covicore/common/view/Survey/" + v + ".do";

    				    		html += "<div class='chkPhotoView'>";
    	        				html += "<img src=\"/covicore/common/preview/Survey/" + v + ".do\" alt='' style='width:106px;height:104px;' onClick=\"coviComment.callImageViewer('" + src + "')\">";
    	        				html += "</div>";
    						}
	        			});
					}
         			if (typeof(v.fileIds) != "undefined" && v.fileIds != "") {	// front 이미지
         				if (reqType == 'preview') {
         					fileIds = JSON.parse(v.fileIds);
        					$.each(fileIds, function(i, v) {
        						var frontAddPath = "";
								if(v.FrontAddPath){
									frontAddPath = v.FrontAddPath;
								}
								
        						var src = coviCmn.commonVariables.frontPath + Common.getSession("DN_Code") + frontAddPath + "/" + v.SavedName;
        						var thumbSrc = src.split('.')[0] + '_thumb.jpg';
        						
        						html += "<div class='chkPhotoView'>";
    	        				html += "<img src=\"" + thumbSrc + "\" alt='' orgSrc=\"" + src + "\" style='width:106px;height:104px;' onClick=\"coviComment.callImageViewer('" + src + "')\">";
    	        				html += "</div>";
    	        			});
         				} else {
	        				fileIds = v.fileIds.split(',');
	    					$.each(fileIds, function(i, v) {
	    						html += "<div class='chkPhotoView'>";
		        				html += "<img src=\"/covicore/common/preview/Survey/" + v + ".do\" alt='' style='width:106px;height:104px;'>";
		        				html += "</div>";
		        			});
         				}
        			}
         			
        			html += "</div>";
        			
        			labelCnt++;
        		});
        		
        		itemRadioCnt++;				
    		} else if (questionType == 'D') { //주관식
        		$.each(v.items, function(i, v) {
        			html += "<div class='exList inputFocusConten'>";
        			html += "<div class='titleStyle01 type01'>";
        			html += "<span>";
        			html += "<input type='hidden' value='" + v.itemID + "'>";
        			
        			if (answerItem != '') {
        				html += "<input type='text' class='inpStyle01 type03 subject inpFocus HtmlCheckXSS ScriptCheckXSS' value=\"" + answerItem + "\">";
        			} else {
	        			html += "<input type='text' class='inpStyle01 type03 subject inpFocus HtmlCheckXSS ScriptCheckXSS'>";
        			}
        			html += "</span>";
        			html += "</div>";
        			html += "</div>";
        		});
    		} else if (questionType == 'M') { //복수선택
    			var answerItemArr;
    			if(answerItem != undefined){
    				answerItemArr = answerItem.split(';');
    			}
    			
        		$.each(v.items, function(i, v) {
        			html += "<div class='exList'>";
        			html += "<div class='titleStyle01'>";
        			html += "<div class='chkStyle02'>";
        			html += "<input type='hidden' value='" + v.itemID + "'>";
        			
        			if (answerItemArr != undefined && answerItem != undefined &&  answerItemArr.includes(v.itemID)) {
        				html += "<input type='checkbox' id='sel" + labelCnt  + "' name='itemCheckbox' checked/><label for='sel" + labelCnt + "'><span></span>" + v.item + "</label>";        				
        			} else {
	        			html += "<input type='checkbox' id='sel" + labelCnt  + "' name='itemCheckbox'/><label for='sel" + labelCnt + "'><span></span>" + v.item + "</label>";
        			}
        			html += "</div>";
        			html += "</div>";
        			
       				var fileIds;
					if (typeof(v.updateFileIds) != "undefined" && v.updateFileIds != "") {	// back 이미지
						fileIds = v.updateFileIds.split(';');
    					$.each(fileIds, function(i, v) {
    						if(v) {
    							var src = "/covicore/common/view/Survey/" + v + ".do";

    				    		html += "<div class='chkPhotoView'>";
    	        				html += "<img src=\"/covicore/common/preview/Survey/" + v + ".do\" alt='' style='width:106px;height:104px;' onClick=\"coviComment.callImageViewer('" + src + "')\">";
    	        				html += "</div>";	
    						}
	        			});
					}
         			if (typeof(v.fileIds) != "undefined" && v.fileIds != "") {	// front 이미지
         				if (reqType == 'preview') {
         					fileIds = JSON.parse(v.fileIds);
        					$.each(fileIds, function(i, v) {
        						var src = coviCmn.commonVariables.frontPath + Common.getSession("DN_Code") + "/" + v.SavedName;
        						var thumbSrc = src.split('.')[0] + '_thumb.jpg';
        						
        						html += "<div class='chkPhotoView'>";
    	        				html += "<img src=\"" + thumbSrc + "\" alt='' orgSrc=\"" + src + "\" style='width:106px;height:104px;' onClick=\"coviComment.callImageViewer('" + src + "')\">";
    	        				html += "</div>";
    	        			});
         				} else {
	        				fileIds = v.fileIds.split(',');
	    					$.each(fileIds, function(i, v) {
	    						html += "<div class='chkPhotoView'>";
		        				html += "<img src=\"/covicore/common/preview/Survey/" + v + ".do\" alt='' style='width:106px;height:104px;'>";
		        				html += "</div>";
		        			});
         				}
        			}
         			
        			html += "</div>";
        			
        			labelCnt++;
        		});
    		} else if (questionType == 'N') { //순위
    			var answerItemArr;
    			if(answerItem != undefined){
    				answerItemArr = answerItem.split(';');
    			}
    			
        		$.each(v.items, function(i, v) {
        			html += "<div class='exList'>";
        			html += "<div class='titleStyle01'>";
        			html += "<div class='ranking'>";
        			html += "<input type='hidden' value='" + v.itemID + "'>";
        			
        			if (answerItem != undefined && answerItemArr[i] != undefined) {
        				html += "<input type='text' class='inpStyle03 qTypeNInput HtmlCheckXSS ScriptCheckXSS' maxlength='2' value=\"" + answerItemArr[i] + "\"/><span>" + v.item + "</span>";
        			} else {
	        			html += "<input type='text' class='inpStyle03 qTypeNInput HtmlCheckXSS ScriptCheckXSS' maxlength='2'/><span>" + v.item + "</span>";
        			}
        			html += "</div>";
        			html += "</div>";
        			
       				var fileIds;
					if (typeof(v.updateFileIds) != "undefined" && v.updateFileIds != "") {	// back 이미지
						fileIds = v.updateFileIds.split(';');
    					$.each(fileIds, function(i, v) {
    						if(v) {
    							var src = "/covicore/common/view/Survey/" + v + ".do";

    				    		html += "<div class='chkPhotoView'>";
    	        				html += "<img src=\"/covicore/common/preview/Survey/" + v + ".do\" alt='' style='width:106px;height:104px;' onClick=\"coviComment.callImageViewer('" + src + "')\">";
    	        				html += "</div>";	
    						}
	        			});
					}
         			if (typeof(v.fileIds) != "undefined" && v.fileIds != "") {	// front 이미지
         				if (reqType == 'preview') {
         					fileIds = JSON.parse(v.fileIds);
        					$.each(fileIds, function(i, v) {
        						var src = coviCmn.commonVariables.frontPath + Common.getSession("DN_Code") + "/" + v.SavedName;
        						var thumbSrc = src.split('.')[0] + '_thumb.jpg';
        						
        						html += "<div class='chkPhotoView'>";
    	        				html += "<img src=\"" + thumbSrc + "\" alt='' orgSrc=\"" + src + "\" style='width:106px;height:104px;' onClick=\"coviComment.callImageViewer('" + src + "')\">";
    	        				html += "</div>";
    	        			});
         				} else {
	        				fileIds = v.fileIds.split(',');
	    					$.each(fileIds, function(i, v) {
	    						html += "<div class='chkPhotoView'>";
		        				html += "<img src=\"/covicore/common/preview/Survey/" + v + ".do\" alt='' style='width:106px;height:104px;'>";
		        				html += "</div>";
		        			});
         				}
        			}
         			
        			html += "</div>";
        		});   
    		}
       		html += "</div>";
       		html += "</div>";
   		});
 		html += "</div>";
 		html += "<div class='surPartListEnd'>";
 		html += "<div class='surveryTopButtons'>";
 		if(chkPrevExist(nowQuestions[0]) != -1){
	 		html += "<a id='prevBtn' class='btnTypeDefault pre' onclick='setQuestionData(\"prev\")'><spring:message code='Cache.lbl_previous' /></a>";
 		}
		html += "<a id='nextBtn' class='btnTypeDefault next' onclick='setQuestionData(\"next\")'><spring:message code='Cache.lbl_next' /></a>";
		html += "<a id='joinBtn' class='btnTypeDefault btnTypeChk' onclick='submitSurvey()'><spring:message code='Cache.lbl_completeSurvey' /></a>"; 
 		
 		html += "</div>";
    	html += "</div>";
 		html += "</div>";
				
 		$(".surveyMakeView").after(html);
 		
 		var checkedNext = $('.surParticipationBox input[type=radio]:checked').siblings('input[type=hidden]:eq(1)').val();
 		
 		$('.help_ico').mouseover(function() {
			$(this).toggleClass("active");
		});
 		
 		$('.help_ico').mouseout(function() {
			$(this).toggleClass("active");
		});
 		
 		if (reqType == "edit") {
	    	// 값 세팅
	    	$(".surParticipationBox").each(function (i, v) {
	    		var question = $(this);
				var questionId = question.find('input[type=hidden]:eq(0)').val();
				var questionType = question.find('input[type=hidden]:eq(1)').val();
				var isEtc = question.find('input[type=hidden]:eq(2)').val();
				var surveyInfoList;

				if(answerArr[questionNum-1].itemID != null && answerArr[questionNum-1].itemID != ""){
					surveyInfoList = answerArr[questionNum-1];
				}else{
					surveyInfoList = surveyInfo.userAnswers[0].answers
				}
				
		    	$.each(surveyInfoList, function(i, v) {
		    		var answerItem = v.AnswerItem;
		    		var answerItemId = v.AnswerItemId;
		    		var etcOpinion = v.EtcOpinion;
		    		
		    		if (questionId == v.QuestionID) {
						if (questionType == 'S') {	// 객관식
							$.each(question.find('div.exList'), function(i, v) {
								var item = $(this).find('input[type=hidden]:eq(0)');
								if (answerItemId == item.val()) {
									item.siblings('#'+item.siblings('label').attr("for")).prop("checked", true);
								}
								if (answerItemId == item.val() &&  etcOpinion != "") item.siblings('label').append(etcOpinion);
							});
						} else if (questionType == 'D') {	// 주관식
							question.find('div.exList input:text').val(answerItem);
						} else if (questionType == 'M') {	// 복수응답
							var answerItemIdArr = answerItemId.split(';');
							$.each(question.find('div.exList'), function(i, v) {
								var item = $(this).find('input[type=hidden]:eq(0)');
								if ($.inArray(item.val(), answerItemIdArr) != -1) item.siblings('#'+item.siblings('label').attr("for")).prop("checked", true);
							});
						} else if (questionType == 'N') {	// 순위선택
							var answerItemArr = new Array();
							var answerItemIDArr = answerItemId.split(";");
						
							$.each(answerItem.split(';'), function(idx, item){
								answerItemArr.push({
									"id": answerItemIDArr[idx],
									"item": item,
									"rank": idx+1
								});
							});
							
							answerItemArr.sort(function(a, b) {
							    return a.id < b.id ? -1 : a.id > b.id ? 1 : 0;
							});
						
							$.each(question.find('div.exList'), function(i, v) {
								$(this).find('.ranking span:nth-child(3)').text(answerItemArr[i].item);
								$(this).find('.ranking .inpStyle03.qTypeNInput').val(answerItemArr[i].rank);
							});
						}
		    		}
		    	});
	    	});
    	} 	
 		
 		if(reqType == "preview" || reqType=="reqApproval" || (defaultNext != "99" && checkedNext != "99")){
 			$("#nextBtn").show();
 			$("#joinBtn").hide();
 		}else if (reqType == "join" && (defaultNext == "99" || checkedNext == "99")) {
 	 		$("#joinBtn").show();
 			$("#nextBtn").hide();
 	 	}
 	}
 	
	// 문항 데이터 세팅
    function setQuestionData(type) {
		// 그룹 분기
		if (isGrouping == "Y") {
	    	if (type == "init") {
	    		tempGroups = new Array();
	    		$.each(questions, function(i, v) {
		    		if (1 == v.groupingNo) {
		    			tempGroups.push(v);
		    		}
	   			});
		    	
		    	questionSortArr.push(tempGroups);
		    	nowQuestions = tempGroups.slice();
			} else if (type == "prev") {
				setAnswer();	// 답변 세팅
				setRealAnswer("prev");  //실제 대답항목에서 삭제
				
				var idx = chkPrevExist(nowQuestions[0]);
				
				if (idx != -1) {
		    		tempGroups = new Array();
		    		$.each(questionSortArr[idx - 1], function(i, v) {
		    			tempGroups.push(v);
		   			});
		    		nowQuestions = tempGroups.slice();
		    		
					questionSortArr.splice(idx, 1);
					
	    			setSurveyQuestionHtml();	// 설문 문항 html
				} else {
					Common.Warning("이전 그룹 문항이 없습니다.");
				}
			} else if (type == "next") {
				if(reqType =="join"){
					if(!checkRequired()){ // 필수 체크
						return ;
					}
				}
				setAnswer();
				setRealAnswer("next");  //실제 대답항목에 추가
       			
        		var nextGroupingNo = nowQuestions[0].nextGroupingNo;
        		var questionType = nowQuestions[0].questionType;
        		
        		if (questionType == 'S') {	// 객관식
					var checked = $('.surParticipationBox input[type=radio]:checked').eq(0).val();
	        		if (checked == null || typeof(checked) == "undefined") {
	        			nextQuestionNo = nowQuestions[0].nextDefaultQuestionNO;	// 객관식 선택 안했을 시에는 다음 문항
	        		} else {
	        			nextQuestionNo = $('.surParticipationBox input[type=radio]:checked').siblings('input[type=hidden]:eq(1)').val();
	        		}
        		} else {	// 주관식, 복수응답, 순위선택
        			nextQuestionNo = nowQuestions[0].items[0].nextQuestionNO;
	        	}
        		if (nextGroupingNo == "99") {
        			Common.Warning("다음 그룹 문항이 없습니다.");
        		} else {
        			var nowGroupingNo = nowQuestions[0].groupingNo;
        			var len = questionSortArr.length;
        			while (len--) {
			    		if (nowGroupingNo == questionSortArr[len][0].groupingNo) {
	    		    		tempGroups = new Array();
			    	    	$.each(questions, function(i, v) {
			    	    		if (nextQuestionNo == v.questionNO) {
	    			    			tempGroups.push(v);
			    	    		}
			    	   		});
			    	    	nowQuestions = tempGroups.slice();
			    	    	
			    			questionSortArr.splice(len + 1, 0, nowQuestions);
			    			
			    			setSurveyQuestionHtml();	// 설문 문항 html
			    		}
        			}
        		}
			}
		} else {
			if (type == "init") {
				questionSortArr.push(surveyInfo.questions[0]);
				nowQuestions[0] = surveyInfo.questions[0];
			} else if (type == "prev") {
				setAnswer();
				setRealAnswer("prev");  //실제 대답항목에서 삭제
				
				var idx = chkPrevExist(nowQuestions[0]);
				if (idx != -1) {
					nowQuestions[0] = questionSortArr[idx - 1];
					
					questionSortArr.splice(idx, 1);
					
	    			setSurveyQuestionHtml();	// 설문 문항 html
				} else {
					Common.Warning("이전 문항이 없습니다.");
				}
				
			} else if (type == "next") {
				if(reqType =="join"){
					if(!checkRequired()){ // 필수 체크
						return ;
					}
				}
       			setAnswer();
				setRealAnswer("next");  //실제 대답항목에 추가
				
       			var nextQuestionNo = "";
		 		var questionType = nowQuestions[0].questionType;
		 		
        		if (questionType == 'S') {	// 객관식
					var checked = $('.surParticipationBox input[type=radio]:checked').eq(0).val();
	        		if (checked == null || typeof(checked) == "undefined") {
	        			nextQuestionNo = nowQuestions[0].nextDefaultQuestionNO;	// 객관식 선택 안했을 시에는 다음 문항
	        			//nextQuestionNo = nowQuestions[0].items[0].nextQuestionNO;	// 객관식 선택 안했을 시에는 첫번째 보기의 분기
	        		} else {
	        			nextQuestionNo = $('.surParticipationBox input[type=radio]:checked').siblings('input[type=hidden]:eq(1)').val();
	        		}
        		} else {	// 주관식, 복수응답, 순위선택
        			nextQuestionNo = nowQuestions[0].items[0].nextQuestionNO;
	        	}
       			
        		if (nextQuestionNo == "99") {
        			Common.Warning("다음 문항이 없습니다.");
        		} else {
        			var nowQuestionNo = nowQuestions[0].questionNO;
        			var len = questionSortArr.length;
        			while (len--) {
			    		if (nowQuestionNo == questionSortArr[len].questionNO) {
			    	    	$.each(questions, function(i, v) {
			    	    		if (nextQuestionNo == v.questionNO) {
			    	    			nowQuestions[0] = v;
			    	    			
					    			questionSortArr.splice(len + 1, 0, nowQuestions[0]);
					    			
					    			setSurveyQuestionHtml();	// 설문 문항 html
					    			
			    	    			return false;
			    	    		}
			    	   		});
			    		}
        			}
        		}
			}
		}
    }
	
 	// 순서 데이터 포함 여부 확인(없음 : -1, 있음  : 이전 index)
     function chkPrevExist(obj) {
 		var rtnIdx = -1;
			
    	$.each(questionSortArr, function(i, v) {
    		// 그룹 분기
    		if (isGrouping == "Y") {
	    		if (obj.groupingNo == v[0].groupingNo) {
					if (questionSortArr[i - 1] != null && typeof(questionSortArr[i - 1]) != "undefined") {
						rtnIdx = i;
					}
					
	    			return false;
	    		}
    		} else {
	    		if (obj.questionNO == v.questionNO) {
					if (questionSortArr[i - 1] != null && typeof(questionSortArr[i - 1]) != "undefined") {
						rtnIdx = i;
					}
					
	    			return false;
	    		}
    		}
   		});
	    	
    	return rtnIdx;
    }
 	
 	
     function checkRequired() {
    	 var chkRequired = true; // true : 필수 항목에 모두 응답 , false: 필수 항목에 모두 응답 X
    	 
 		$("div.surPartListCont").find(".surParticipationBox").each(function (i, v) {
 			var questionDiv = $(this);
 			var questionType = questionDiv.find('input[type=hidden]:eq(1)').val();
 			var isRequired = questionDiv.find('input[type=hidden]:eq(3)').val();

 			if(isRequired == "N"){
 				return true;
 			}
 			
 			
 			if (questionType == 'S') {	// 객관식
 				if( questionDiv.find('input[type=radio]:checked').length <= 0){
 					chkRequired = false;
 					return false;
 				}
 			
 			} else if (questionType == 'D') {	// 주관식
 				if( questionDiv.find("input:text").val().trim() == "" || questionDiv.find("input:text").val() == undefined ){
 					chkRequired = false;
 					return false;
 				}
 			} else if (questionType == 'M') {	// 복수응답
 				if( questionDiv.find("input:checkbox[name=itemCheckbox]:checked").length <= 0 ){
 					chkRequired = false;
 					return false;
 				}
 			} else if (questionType == 'N') {	// 순위선택
 				var stopflag = false;
 				$.each(questionDiv.find(".ranking"), function() {
 					if ($(this).find('input:text').val() == '') {
 						flag = true;
 						chkRequired = false;
 						return false
 					}
 				});
 				
 				if(stopflag){
 					return false;
 				}
 			
 			}
 			
 		});
    	 
    	 
    	if(!chkRequired) {
    		Common.Warning("필수항목에 응답해주세요");
    	}
    	
    	return chkRequired;
 	}
 	
 	
	// 답변 세팅
	function setAnswer() {
		$("div.surPartListCont").find(".surParticipationBox").each(function (i, v) {
			var questionDiv = $(this);
			var questionId = questionDiv.find('input[type=hidden]:eq(0)').val();
			var questionType = questionDiv.find('input[type=hidden]:eq(1)').val();
			var isEtc = questionDiv.find('input[type=hidden]:eq(2)').val();
			var selVal = "";
			var itemVal = "";
			var etcVal = "";
			var weightVal = "";
			var allInputNType = "Y"; //순위선택 시 모두 입력했는지 여부
			var selTempArr = new Array();
			var itemTempArr = new Array();
			var weightTempArr = new Array();
			
			if (questionType == 'S') {	// 객관식
				var checked = questionDiv.find('input[type=radio]:checked');
				selVal = checked.siblings('input[type=hidden]:eq(0)').val();

				if (checked.closest('.exList').hasClass('theRest')) {
					etcVal = questionDiv.find("input:text").val();
				} else {
					itemVal = checked.next().text();
				}
			} else if (questionType == 'D') {	// 주관식
				var inputText = questionDiv.find("input:text");
				if (inputText.val() != '') {
					selVal = inputText.siblings('input[type=hidden]:eq(0)').val();
					itemVal = inputText.val();
				}
			} else if (questionType == 'M') {	// 복수응답
				$.each(questionDiv.find("input:checkbox[name=itemCheckbox]:checked"), function() {
					selTempArr.push($(this).siblings('input[type=hidden]:eq(0)').val());
					itemTempArr.push($(this).next().text());
				})
				selVal = selTempArr.join(';');
				itemVal = itemTempArr.join(';');
			} else if (questionType == 'N') {	// 순위선택
				$.each(questionDiv.find(".ranking"), function() {
					if ($(this).find('input:text').val() == '') {
						allInputNType = 'N'
					}
					selTempArr.push($(this).find('input[type=hidden]:eq(0)').val());
					itemTempArr.push($(this).find('span').text());
					weightTempArr.push($(this).find('input:text').val());
				})
				
				if(weightTempArr.join("") == "" ){ //모두 안입력했을 경우에는 필수가 아닌 항목에 그냥 답변하지 않을 것이므로 체크 x
					allInputNType = 'Y';
				}
				
				selVal = selTempArr.join(';');
				itemVal = itemTempArr.join(';');
				weightVal = weightTempArr.join(';');
			}
			if (typeof(selVal) == "undefined") selVal = "";
			
			$(answerArr).each(function (i, v) {
 				if (questionId == v.questionID) {
 					v.itemID = selVal;
 					v.answerItem = itemVal;
  	        		if (questionType == 'S' && isEtc == 'Y') v.etcOpinion = etcVal;
  	        		if (questionType == 'N') {
  	        			v.weighting = weightVal;
  	        			v.allInput = allInputNType; //모든 순위 입력 여부
  	        		}
  	        		v.questionType = questionType;
 					
					return false;
				}
			});
		});
	}
	
	function setRealAnswer(type){
		// realAnswerArr
		if (type == "next") {
			$("div.surPartListCont").find(".surParticipationBox").each(function(idx,obj){
				realAnswerArr.push($(obj).find('input[type=hidden]:eq(0)').val());
			});
		}else if(type == "prev"){
			$("div.surPartListCont").find(".surParticipationBox").each(function(idx,obj){
				var removeIdx = realAnswerArr.indexOf($(obj).find('input[type=hidden]:eq(0)').val());
				if(removeIdx < 0) {
					return true;
				}
				realAnswerArr.splice(removeIdx,1);
			});
		}
	}
	
	// 답변 제출
	function submitSurvey() {
		if(!checkRequired()){ // 필수 체크
			return ;
		}
		
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		setAnswer();	// 답변 세팅
		setRealAnswer("next");  //실제 대답항목에 추가
		surveyInfo = new Object();
		surveyInfo.surveyID = surveyId;
		surveyInfo.answers = answerArr;

		var chkAllRank = 'Y';
		
		//분기에 따라 답변을 하지 않은 항목은 defualt 값으로 변경
		$.each(surveyInfo.answers , function(idx,obj){
			if(!realAnswerArr.includes(obj.questionID)){
    				delete obj.questionType;
    			  	obj.itemID = "";
    			  	obj.answerItem = "";
    			  	obj.etcOpinion = "";
			}
			
			if(obj.questionType == 'N'){
				if(obj.allInput == 'N'){//순위 지정에서 일부분만 값을 입력한 경우 = N		
					chkAllRank = "N";
				}
			 	delete obj.allInput; //allInput 값은 스크립트 상에서 validation chk를 위해 만든 값이므로 삭제.
			}
			
		});

     	
		if(chkAllRank == "N"){
			Common.Confirm("<spring:message code='Cache.lbl_surveyMsg1' />\n<spring:message code='Cache.lbl_surveyMsg2' />","Confirmation Dialog",function(result){
				if(result){
					saveAnswer(surveyInfo);
				}
			});
		}else{
			saveAnswer(surveyInfo);
		}
		
      
	}
	
	function saveAnswer(surveyInfo){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		Common.Prompt("<spring:message code='Cache.lbl_surveyMsg3' />","","<spring:message code='Cache.lbl_RegOpinion' />",function (res) {
      		if(res != null){
	    		surveyInfo.etcOpinion =res;
	    		
	    		Common.Confirm("<spring:message code='Cache.lbl_surveyMsg4' />", "Confirmation Dialog", function (confirmResult) {
	    			if (confirmResult) {
	    				var url = "/groupware/survey/insertQuestionItemAnswer.do";
	    				
	    				if(reqType == "edit"){
	    					url = "/groupware/survey/updateQuestionItemAnswer.do";
	    				}
	    				
	    				$.each(surveyInfo.answers , function(idx,obj){		//순위선택을 모두 입력하지 않았을 경우 제거
	    					if(obj.questionType == 'N' && obj.weighting.replaceAll(";","") == ''){ 
	    					  	obj.itemID = "";
	    					  	obj.answerItem = "";
	    					  	obj.etcOpinion = "";
	    					}
	    				});
	    				
	    		 		$.ajax({
	    					type : "POST",
	    					data : {surveyID : surveyInfo.surveyID, surveyInfo : JSON.stringify(surveyInfo)},
	    					url : url,
	    					async: false,
	    					success:function (data) {
	    						if(data.result == "ok") {
	    							if(data.status == 'SUCCESS') {
	    								if(isPopup === "Y"){
	    									parent.Common.Close(openLayerName);
	    									
	    									if(openLayerName.indexOf("Collab") > -1){
	    										parent.$(".Project_tabList li[data-type=SURVEY]").click();
	    									}
	    								}else{
	    									var html = "<div class='surParticipationBox end'>";
		    								html += "<p><spring:message code='Cache.lbl_surveyMsg5' /></p>";
		    								html += "<p><spring:message code='Cache.lbl_surveyMsg6' /></p>";
		    								html += "<div>";
		    								html += "<a href='#' class='btnTypeDefault btnTypeBg f17' onclick='goPrevPage()'><spring:message code='Cache.btn_ok' /></a>";
		    								html += "</div>";
		    								html += "</div>";
		    								
		    								$('div.surParticipationBox, div.surveryTopButtons, p.groupTitle').remove();
		    								$('div.surPartListCont').append(html);
	    								}
	    			          		} else {
	    			          			Common.Warning("<spring:message code='Cache.msg_apv_030' />");
	    			          		}
	    						}
	    					},
	    					error:function(response, status, error) {
	    						CFN_ErrorAjax(url, response, status, error);
	    					}
	    				});
	    			} else {
	    				return false;
	    			}
	    		});
      		}
    	});
	}
	
	
	function changeObjectiveValue(obj){
		var nextQuestionNO = $(obj).siblings('input[type=hidden]:eq(1)').val();
		if(reqType == "preview" || reqType=="reqApproval" || nextQuestionNO != "99"){
 			$("#nextBtn").show();
			$("#joinBtn").hide();
		}else if (reqType == "join" && nextQuestionNO == "99"){
 			$("#joinBtn").show();
 			$("#nextBtn").hide();
		} 
	}
	
	// 설문 대상 보기
    function goTarget() {
		var url = "/groupware/survey/goTargetRespondentList.do?surveyId="+surveyId+"";
		if (listType == 'proceed') url+= '&listType='+listType;
    	if(reqType == "reqApproval"){
    		parent.parent.Common.open("","target_pop","<spring:message code='Cache.lbl_polltargetview' />",url,"500px","665px","iframe",true,null,null,true);
			
    		/* var reqApprovalZIndex = Number($("#reqApproval_pop_p", parent.parent.document).css("z-index"));
	    	$("#target_pop_p", parent.parent.document).attr("style", 
	    		"width: 506px; height: 710px; left: 652px; top: 133.5px; z-index: " + (reqApprovalZIndex + 2) + " !important;"
    		);
	    	$("#target_pop_overlay", parent.parent.document).attr("style", 
	    		"position: fixed; top: 0px; left: 0px; width: 100%; height: 977px; background: rgb(0, 0, 0); opacity: 0; z-index: " + (reqApprovalZIndex + 1)
    		); */
	    	
    	}else{
	    	Common.open("","target_pop","<spring:message code='Cache.lbl_polltargetview' />",url,"500px","665px","iframe",true,null,null,true);
    	}
    }
	
	// 결과공개 대상 보기
    function goResultTarget() {
    	if(reqType == "reqApproval"){
    		parent.parent.Common.open("","result_pop","<spring:message code='Cache.lbl_title_surveyResult_01' />","/groupware/survey/goTargetResultviewList.do?surveyId="+surveyId,"500px","665px","iframe",true,null,null,true);
	    	
	    	/* var reqApprovalZIndex = Number($("#reqApproval_pop_p", parent.parent.document).css("z-index"));
	    	$("#result_pop_p", parent.parent.document).attr("style", 
	    		"width: 506px; height: 710px; left: 652px; top: 133.5px; z-index: " + (reqApprovalZIndex + 2) + " !important;"
    		);
	    	$("#result_pop_overlay", parent.parent.document).attr("style", 
	    		"position: fixed; top: 0px; left: 0px; width: 100%; height: 977px; background: rgb(0, 0, 0); opacity: 0; z-index: " + (reqApprovalZIndex + 1)
    		); */
	    	
    	}else{
	    	Common.open("","result_pop","<spring:message code='Cache.lbl_title_surveyResult_01' />","/groupware/survey/goTargetResultviewList.do?surveyId="+surveyId,"500px","665px","iframe",true,null,null,true);
    	}
    }
	
	// 이전 페이지 이동
    function goPrevPage() {
		if (CFN_GetQueryString("CFN_OpenLayerName") == "CollabSurveyPopup") {
			parent.$(".Project_tabList li[data-type=SURVEY]").click();
			Common.Close();
		}
		else{
			var communityId = CFN_GetQueryString("communityId");
			var activeKey = CFN_GetQueryString("activeKey");
			var CSMU = CFN_GetQueryString("CSMU");
			
	    	CoviMenu_GetContent('/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType='+listType+(listSelect == "undefined" ? "" : "&listSelect="+listSelect)+(CSMU == "undefined" ? "" : "&CSMU="+CSMU)+(communityId == "undefined" ? "" : "&communityId="+communityId)+(activeKey == "undefined" ? "" : "&activeKey="+activeKey));
		}	
    }
	
    var tempOrderArr = new Array();
	$(function() {
		/* 설문 설정 on Off*/
		$('.surveryContSetting').on('click', function(){
			var mParent = $('.surveySettingView');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).addClass('active');
			}else {
				mParent.addClass('active');
				$(this).removeClass('active');
			}
		});
		
		$('.cRContBottom').on('focus', '.inpFocus', function(eve) {
			  //eve.stopPropagation();
			  
			  var mParent = $(this).closest('.inputFocusConten');
			  
			  if (!mParent.hasClass('focus')) {
					$('.inputFocusConten').removeClass('focus');
					mParent.addClass('focus');
			  }
		});
	
		// 순위선택 인풋 체크 onKeypress
		$('.cRContBottom').on('keypress', '.qTypeNInput', function(e) {
	        tempOrderArr = new Array();
	        $(this).closest('.surParticipationBox').find('.qTypeNInput').each(function (i, v) {
		        tempOrderArr.push($(this).val());
	    	});
		});
		
		// 순위선택 인풋 체크 onKeyup
		$('.cRContBottom').on('keyup', '.qTypeNInput', function(e) {
	        // backspace, delete, tab, escape, enter and, Ctrl+A, Command+A, home, end, left, right, down, up 가능
	        if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
	            (e.keyCode === 65 && (e.ctrlKey === true || e.metaKey === true)) || 
	            (e.keyCode >= 35 && e.keyCode <= 40)) {
	                 return;
	        }
	        
	        var val = $(this).val().replace(/[^0-9\.]/g,'').replace('.','');
	        var tar = $(this).closest('.surParticipationBox').find('.qTypeNInput');
	        
	        if (val > tar.length ||
	        	($.inArray(val, tempOrderArr) != -1) || 
	        	((val.length == 1 || val.length == 2) && val.substring(0, 1) == 0)) {
	        		$(this).val('');
	        } else {
	        	$(this).val(val);
	        }
		});
		
		// 2017 09 01 기타 포커스시 앞에 라디오(또는 체크박스) 선택 (선택만 되어있음)
		$('.cRContBottom').on('focus', '.theRest .subject', function(eve) {
			$(this).closest('label').siblings('input').prop('checked', true);
		});		
	});	
	
	function deleteSurvey() {
		var surveyIdArr = new Array();
		
		if(surveyInfo.registerCode != Common.getSession("USERID")
			|| listType == "proceed"){
			Common.Warning("<spring:message code='Cache.msg_noDeleteACL'/>"); // 삭제 권한이 없습니다.
			return false;
		}
		
		surveyIdArr.push(surveyId);
		
		var params = new Object();
		params.surveyIdArr = surveyIdArr;
		params.state = 'del';
		
       	Common.Confirm("<spring:message code='Cache.msg_AreYouDelete'/>", "Confirmation Dialog", function (confirmResult) { /*  삭제하시겠습니까?  */
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/survey/updateSurveyState.do",
					success:function (data) {
						if(data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform("<spring:message code='Cache.msg_Deleted'/>", "Inform", function() {	/* 삭제 되었습니다 */
									if(reqType == "reqApproval"){
								    	parent.search();
								    	Common.Close();
							    	}else{
							    		goPrevPage();
							    	}
								});
			          		} else {
			          			Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");/* 오류가 발생하였습니다. */
			          		}
						} else {
							Common.Warning(data.message); /* 실패 메시지 */
						}
					},
					error:function(response, status, error) {
						CFN_ErrorAjax("/groupware/survey/updateSurveyState.do", response, status, error);
					}
				});
			} else {
				return false;
			}
		});
	}
	
	function closeSurvey() {
		var surveyIdArr = new Array();
		
		surveyIdArr.push(surveyId);
		
		var params = new Object();
		params.surveyIdArr = surveyIdArr;
		params.state = 'G';
		
		Common.Confirm("<spring:message code='Cache.msg_EarlyCloseSurveyCheck'/>", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/survey/updateSurveyState.do",
					success:function (data) {
						if(data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform("<spring:message code='Cache.msg_EarlyCloseSurveySucess'/>", "Inform", function() {
									if(reqType == "reqApproval"){
								    	parent.search();
								    	Common.Close();
							    	}else{
							    		goPrevPage();
							    	}
								});
			          		} else {
			          			Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");/* 오류가 발생하였습니다. */
			          		}
						}
					},
					error:function(response, status, error) {
						CFN_ErrorAjax("/groupware/survey/updateSurveyState.do", response, status, error);
					}
				});
				
			} else {
				return false;
			}
		});
		
	}
	
	function reuseSurvey(){
    	var communityId = CFN_GetQueryString("communityId");
		var activeKey = CFN_GetQueryString("activeKey");
		var CSMU = CFN_GetQueryString("CSMU");
		parent.parent.Common.close(openLayerName);
		parent.parent.CoviMenu_GetContent('/groupware/layout/survey_SurveyWrite.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=reuse&surveyId='+surveyId+(CSMU == "undefined" ? "" : "&CSMU="+CSMU)+(communityId == "undefined" ? "" : "&communityId="+communityId)+(activeKey == "undefined" ? "" : "&activeKey="+activeKey));
	}
	
	function convertFileSize(pSize) {
		var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
	    if (pSize == 0) return 'n/a';
	    var i = parseInt(Math.floor(Math.log(pSize) / Math.log(1024)));
	    return (pSize / Math.pow(1024, i)).toFixed(1) + sizes[i];
	}
	
</script>