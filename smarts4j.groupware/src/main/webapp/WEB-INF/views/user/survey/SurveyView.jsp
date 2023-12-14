<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
	String isPopup = request.getParameter("isPopup");
	pageContext.setAttribute("isPopup", isPopup);
%>

<c:if test="${isPopup eq 'Y'}">
	<head>
		<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	</head>
</c:if>

<div class='cRConTop'>
	<div class='surveryTopButtons'>
		<a class='btnTypeDefault btnTypeLArrr' id='listBtn' onclick='goPrevPage()'><spring:message code='Cache.lbl_Index' /></a>
		<a class='btnTypeDefault'  id="reuseSurveyBtn" style="display:none;" onclick="reuseSurvey()"><spring:message code='Cache.btn_reuse' /></a>
		<a class="btnTypeDefault left" id="deleteBtn" style='display:none;' onclick="deleteSurvey(); return false;"><spring:message code='Cache.lbl_delete' /></a><!-- 삭제 -->
	</div>
	<div class='surveySetting'>
		<a class="surveryContSetting"><spring:message code='Cache.lbl_Set' /></a>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<div class='surveyMakeView'>							
	</div>
</div>

<script>
	//# sourceURL=SurveyView.jsp
	var surveyId = CFN_GetQueryString("surveyId");
	var viewType = CFN_GetQueryString("viewType") == 'undefined' ? 'myAnswer' : CFN_GetQueryString("viewType"); 
	var listType = CFN_GetQueryString("listType") // proceed(진행중), complete(완료), tempSave(임시저장), reqApproval(검토, 승인 대기) - 목록으로 돌아갈 때 사용
	var listSelect = CFN_GetQueryString("listSelect")	// written(내가 작성한 설문) , participated(내가 참여한 설문) - 목록으로 돌아갈 때 사용
	var isPopup = CFN_GetQueryString("isPopup") == "undefined" ? "" : CFN_GetQueryString("isPopup");
	var openLayerName = CFN_GetQueryString("CFN_OpenLayerName") == "undefined" ? "" : CFN_GetQueryString("CFN_OpenLayerName");
	
	var surveyInfo = new Object();	// 설문 정보
	var isGrouping;
	var nowAnswersOrder = 1;
	var questionLen;
	var answerLen;
	
	var g_fileList = null;
	
	initContent();

	// 설문보기
	function initContent(){
		init();	// 초기화
		
		if (CFN_GetQueryString("communityId") != 'undefined'){
			var level = (typeof memberLevel == 'string') ? memberLevel : '0';
			if (level == '0') $("#listBtn").remove();
		}
	}
	
	// 초기화
    function init() {
		$.ajax({
			type : "POST",
			data : {
				surveyId : surveyId,
				viewType : viewType
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
					
					if(['D','X','G'].includes(surveyInfo.state)) { //거부 또는 종료일 때
						$("#reuseSurveyBtn").show();
					}
					
					if(surveyInfo.registerCode == Common.getSession("USERID")){
						if (listType != "proceed") {
							$("#deleteBtn").show();
						}
					}
					
					isGrouping = surveyInfo.isGrouping;
					questionLen = surveyInfo.questions.length;
					answerLen = surveyInfo.userAnswers.length;
				}
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
		
		if(isPopup === "Y") {
			$("#listBtn").hide();
			$("#reuseSurveyBtn").hide();
		}
		
    	setSurveyHtml();	// 설문 html
    	
    	setSurveyQuestionHtml(nowAnswersOrder);	// 설문 문항 html
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
		html += surveyInfo.description;
		html += "</p>";
		html += "<div class='spBtnBox'>";
		html += "<div class='pagingType01'>";
		if(viewType == "myAnswer"){
			html += " <h3 class='cycleTitle'><spring:message code='Cache.lbl_myResponse' /></span>";
		}else if (viewType == "resultView" && answerLen > 0) {
			html += "<a class='pre' onclick='moveAnswer(\"prev\")'></a>";
			html += "<a class='next' onclick='moveAnswer(\"next\")'></a>";
			html += " <span class='select' id='nowAnswerOrder'>" + nowAnswersOrder + "</span>";
			html += "<span>/</span>";
			html += "<span>" + answerLen + "</span>";
    	}
		html += "</div>";
		if(viewType == "resultView"){
			html += "<a class='btnTypeDefault' onclick='goSurveyChartView()'><spring:message code='Cache.lbl_viewChart' /></a>";
			html += "<a class='btnTypeDefault ml5' onclick='goTarget()'><spring:message code='Cache.lbl_polltargetview' /></a>";
			html += "<a class='btnTypeDefault ml5' onclick='goResultTarget()'><spring:message code='Cache.lbl_title_surveyResult_01' /></a>";
		}
		
		// 관리자이거나, 설문 작성자일경우 설문조기마감 버튼 보임
		//개별호출-일괄호출
		var sessionObj = Common.getSession(); //전체호출
		
		if((sessionObj["isAdmin"] == 'Y' || sessionObj["USERID"] == surveyInfo.registerCode) && surveyInfo.state != 'G' && surveyInfo.state != 'del') {
			html += "<a class='btnTypeDefault ml5' onclick='closeSurvey()'>"+Common.getDic("btn_EarlyCloseSurvey")+"</a>";
		}
		
		// 완료된설문 > 설문자료 저장, 설문통계 저장(엑셀)
		if(viewType == "resultView" && surveyInfo.state == "G"){
			html += "<a class='btnTypeDefault btnExcel ml5' style='height:30px; line-height:28px' id='btnExcel' onclick='excelDownloadRawData();'>"+Common.getDic("btn_SaveSurveyData")+"</a>";
			html += "<a class='btnTypeDefault btnExcel ml5' style='height:30px; line-height:28px' id='btnExcel' onclick='excelDownloadStatistics();'>"+Common.getDic("btn_SaveSurveyStatistics")+"</a>";
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
    function setSurveyQuestionHtml(order) {
    	$('p.groupTitle, div.surveyLookView').remove();
    	
    	var itemRadioCnt = 1;
    	var labelCnt = 1;
    	var groupNoArr = new Array();
    	var html = "";
    	
    	if (isGrouping == 'N') {
       		html += "<div class='surveyLookView'>";
       		html += "<div class='surPartListCont'>"; 
    	}
    	
    	$.each(surveyInfo.questions, function(i, v) {
   			if (isGrouping == 'Y') {
   				var index = $.inArray(v.groupingNo, groupNoArr);
   				var groupArrLen = groupNoArr.length;
   				if (groupArrLen != 0 && index == -1) {
			 		html += "</div>";
			 		html += "</div>";
   				}
		 		if (groupArrLen == 0 || index == -1) {
	     			html += "<p class='groupTitle'>";
	     			html += "<span>";
	     			html += v.groupName;
	     			html += "</span>";
	     			html += "</p>";
	     			
	   				groupNoArr.push(v.groupingNo);
	   				
		       		html += "<div class='surveyLookView'>";
		       		html += "<div class='surPartListCont'>"; 
		 		}
   			}
   			
    		var isEtc = v.isEtc;
       		if (typeof(v.paragraph) != "undefined") {
    			html += "<div class='surParticipationBox inputFocusConten exTitle'>";
   				html += "<p class='spListTitle'>";
   				html += "<span>" + v.paragraph + "</span>";
   				html += v.description;
   				html += "</p>";
       		} else {
       			html += "<div class='surParticipationBox'>";
       		}
        	html += "<input type='hidden' value=" + v.questionID + ">";
        	html += "<input type='hidden' value='" + v.questionType + "'>";
        	html += "<input type='hidden' value='" + v.isEtc + "'>";
   			html += "<div class='sruTitleCont'>";
   			html += "<div class='ribbon shadow'>" + v.questionNO + "</div>";
   			html += "<p class='title'>" + v.question + "</p>";
   			html += "</div>";
   			
   			html += "<div class='sruParticipationListDivi'>";
     		var questionType = v.questionType;
    		if (questionType == 'S') {
    			var len = v.items.length;
        		$.each(v.items, function(i, obj) {
           			html += "<div class='exList'>";
           			html += "<div class='titleStyle01'>";
           			html += "<div class='radioStyle03'>";
           			html += "<input type='hidden' value='" + obj.itemID + "'>";
           			html += "<input type='hidden' value='" + obj.nextQuestionNO + "'>";
           			if(v.isEtc == "Y" && i ==( v.items.length - 1)){
	           			html += "<label for='sel" + labelCnt + "'><span></span><spring:message code='Cache.lbl_otherOpinions' /> : </label>";           			
           			}else{
	           			html += "<label for='sel" + labelCnt + "'><span></span>" + obj.item + "</label>";           			
           			}
        			html += "</div>";
        			html += "</div>";
        			
					if (typeof(obj.updateFileIds) != "undefined" && obj.updateFileIds != "") {	// back 이미지
						var fileIds = obj.updateFileIds.split(';');
    					$.each(fileIds, function(i, fileID) {
    						if(fileID){
    							var src = "/covicore/common/view/Survey/" + fileID + ".do";

    				    		html += "<div class='chkPhotoView'>";
    	        				html += "<img src=\"/covicore/common/preview/Survey/" + fileID + ".do\" alt='' style='width:106px;height:104px;' onClick=\"coviComment.callImageViewer('" + src + "')\">";
    	        				html += "</div>";
    						}
	        			});
					}
         			
        			html += "</div>";
        			
        			labelCnt++;
        		});
        		
        		itemRadioCnt++;				
    		} else if (questionType == 'D') {
        		$.each(v.items, function(i, v) {
        			html += "<div class='exList'>";
        			html += "<div class='titleStyle01 type01'>";
        			html += "<input type='hidden' value='" + v.itemID + "'>";
        			html += "<input type='text' class='inpStyle01 type03 subject' readonly>";
        			html += "</div>";
        			html += "</div>";
        		});
    		} else if (questionType == 'M') {
        		$.each(v.items, function(i, v) {
        			html += "<div class='exList'>";
        			html += "<div class='titleStyle01'>";
        			html += "<div class='chkStyle02'>";
        			html += "<input type='hidden' value='" + v.itemID + "'>";
        			html += "<label for='sel" + labelCnt + "'><span></span>" + v.item + "</label>"; 
        			html += "</div>";
        			html += "</div>";
        			
					if (typeof(v.updateFileIds) != "undefined" && v.updateFileIds != "") {	// back 이미지
						var fileIds = v.updateFileIds.split(',');
    					$.each(fileIds, function(i, v) {
				    		var src = "/covicore/common/view/Survey/" + v + ".do";

				    		html += "<div class='chkPhotoView'>";
	        				html += "<img src=\"/covicore/common/preview/Survey/" + v + ".do\" alt='' style='width:106px;height:104px;' onClick=\"coviComment.callImageViewer('" + src + "')\">";
	        				html += "</div>";
	        			});
					}
					
        			html += "</div>";
        			
        			labelCnt++;
        		});
    		} else if (questionType == 'N') {
        		$.each(v.items, function(i, v) {
        			html += "<div class='exList'>";
        			html += "<div class='titleStyle01'>";
        			html += "<div class='ranking'>";
        			html += "<input type='hidden' value='" + v.itemID + "'>";
        			html += "<span></span><span></span><span>" + v.item + "</span>";
        			html += "</div>";
        			html += "</div>";
        			
					if (typeof(v.updateFileIds) != "undefined" && v.updateFileIds != "") {	// back 이미지
						var fileIds = v.updateFileIds.split(',');
    					$.each(fileIds, function(i, v) {
				    		var src = "/covicore/common/view/Survey/" + v + ".do";

				    		html += "<div class='chkPhotoView'>";
	        				html += "<img src=\"/covicore/common/preview/Survey/" + v + ".do\" alt='' style='width:106px;height:104px;' onClick=\"coviComment.callImageViewer('" + src + "')\">";
	        				html += "</div>";
	        			});
					}
					
        			html += "</div>";
        		});   
    		}
       		html += "</div>";
       		html += "</div>";
       		
       		if ((i + 1) == questionLen) {
       	 		html += "</div>";
       	 		html += "</div>";
       		}
   		});
   		
    	if (isGrouping == 'N') {
    		html += "</div>";
    		html += "</div>"; 
    	}   		
				
 		$(".surveyMakeView").after(html);
 		
    	if (answerLen > 0 && (viewType == "resultView" || viewType == "myAnswer")) {
	    	// 값 세팅
	    	$(".surParticipationBox").each(function (i, v) {
	    		var question = $(this);
				var questionId = question.find('input[type=hidden]:eq(0)').val();
				var questionType = question.find('input[type=hidden]:eq(1)').val();
				var isEtc = question.find('input[type=hidden]:eq(2)').val();
	    		
		    	$.each(surveyInfo.userAnswers[order - 1].answers, function(i, v) {
		    		var answerItem = v.AnswerItem;
		    		var answerItemId = v.AnswerItemId;
		    		var etcOpinion = v.EtcOpinion;
		    		
		    		if (questionId == v.QuestionID) {
						if (questionType == 'S') {	// 객관식
							$.each(question.find('div.exList'), function(i, v) {
								var item = $(this).find('input[type=hidden]:eq(0)');
								if (answerItemId == item.val()) item.siblings('label').addClass('selected');
								if (answerItemId == item.val() &&  etcOpinion != "") item.siblings('label').append(etcOpinion);
							});
						} else if (questionType == 'D') {	// 주관식
							question.find('div.exList input').val(answerItem);
						} else if (questionType == 'M') {	// 복수응답
							var answerItemIdArr = answerItemId.split(';');
							$.each(question.find('div.exList'), function(i, v) {
								var item = $(this).find('input[type=hidden]:eq(0)');
								if ($.inArray(item.val(), answerItemIdArr) != -1) item.siblings('label').addClass('selected');
							});
						} else if (questionType == 'N') {	// 순위선택
							var answerItemArr = answerItem.split(';');
						
							$.each(question.find('div.exList'), function(i, v) {
								$(this).find('.ranking span:nth-child(2)').text(i + 1);
								/* $(this).find('.ranking span:nth-child(3)').text(' 위)'); */
								$(this).find('.ranking span:nth-child(3)').text(')');
								$(this).find('.ranking span:nth-child(4)').text(answerItemArr[i]);
							});
						}
		    		}
		    	});
	    	});
    	} 		
 	}

	// 답변 이동 
    function moveAnswer(type) {
		if (type == "prev") {
	    	if (nowAnswersOrder == 1) {
	    		Common.Warning("<spring:message code='Cache.lbl_surveyMsg7' />");
	    		return;
	    	} else {
	    		nowAnswersOrder--;
	    		setSurveyQuestionHtml(nowAnswersOrder);	// 설문 문항 html
	    	}
		} else {
	    	if (nowAnswersOrder == answerLen) {
	    		Common.Warning("<spring:message code='Cache.lbl_surveyMsg8' />");
	    		return;
	    	} else {
	    		nowAnswersOrder++;
	    		setSurveyQuestionHtml(nowAnswersOrder);
	    	}
		}
   		$("#nowAnswerOrder").html(nowAnswersOrder);
    }
	
	// 설문 대상 보기
    function goTarget() {
    	Common.open("","target_pop","<spring:message code='Cache.lbl_polltargetview' />","/groupware/survey/goTargetRespondentList.do?surveyId="+surveyId+"&listType="+listType,"500px","665px","iframe",true,null,null,true);
    }
	
	// 결과공개 대상 보기
    function goResultTarget() {
    	Common.open("","result_pop","<spring:message code='Cache.lbl_title_surveyResult_01' />","/groupware/survey/goTargetResultviewList.do?surveyId="+surveyId,"500px","665px","iframe",true,null,null,true);
    }
	
	function goSurveyChartView(){
		Common.open("","chart_popup","<spring:message code='Cache.lbl_viewChart' />", "/groupware/survey/goSurveyChartView.do?surveyId=" + surveyId,"700px","500px","iframe",true,null,null,true);	// 설문 결과 보기
	}
	
	function reuseSurvey(){
    	var communityId = CFN_GetQueryString("communityId");
		var activeKey = CFN_GetQueryString("activeKey");
		var CSMU = CFN_GetQueryString("CSMU");
		
		CoviMenu_GetContent('/groupware/layout/survey_SurveyWrite.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=reuse&surveyId='+surveyId+(CSMU == "undefined" ? "" : "&CSMU="+CSMU)+(communityId == "undefined" ? "" : "&communityId="+communityId)+(activeKey == "undefined" ? "" : "&activeKey="+activeKey));
	}
	
	// 이전 페이지 이동
    function goPrevPage() {
		
    	var communityId = CFN_GetQueryString("communityId");
		var activeKey = CFN_GetQueryString("activeKey");
		var CSMU = CFN_GetQueryString("CSMU");
		
    	CoviMenu_GetContent('/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=&reqType='+listType+(listSelect == "undefined" ? "" : "&listSelect="+listSelect)+(CSMU == "undefined" ? "" : "&CSMU="+CSMU)+(communityId == "undefined" ? "" : "&communityId="+communityId)+(activeKey == "undefined" ? "" : "&activeKey="+activeKey));
    }
	
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
									if(isPopup === "Y"){
										if(openLayerName.indexOf("Collab") > -1){
    										parent.$(".tabList li[data-type=SURVEY]").click();
    									}
										
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
		
		Common.Confirm(Common.getDic("msg_EarlyCloseSurveyCheck"), "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/survey/updateSurveyState.do",
					success:function (data) {
						if(data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform(Common.getDic("msg_EarlyCloseSurveySucess"), "Inform", function() {
									if(isPopup === "Y" || reqType == "reqApproval"){
										if(openLayerName.indexOf("Collab") > -1){
    										parent.$(".tabList li[data-type=SURVEY]").click();
    									}else{
    										parent.search();
    									}
										
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
	
	// 완료된설문 > 설문자료 저장(엑셀)
	function excelDownloadRawData(){
		var params = { surveyId : surveyId };
		ajax_download('/groupware/survey/excelDownloadRawData.do', params);		// 엑셀 다운로드 post 요청
	}
	
	// 완료된설문 > 설문통계 저장(엑셀)
	function excelDownloadStatistics(){
		var params = { surveyId : surveyId };
		ajax_download('/groupware/survey/excelDownloadStatistics.do', params);	// 엑셀 다운로드 post 요청
	}
	
	// 엑셀 다운로드 post 요청
	function ajax_download(url, data) {
	    var $iframe, iframe_doc, iframe_html;

	    if (($iframe = $('#download_iframe')).length > 0) {
	    	$iframe.remove();
	    }
	    
        $iframe = $("<iframe id='download_iframe' style='display: none' src='about:blank'></iframe>").appendTo("body");
	   
	    iframe_doc = $iframe[0].contentWindow || $iframe[0].contentDocument;
	    if (iframe_doc.document) {
	        iframe_doc = iframe_doc.document;
	    }

	    iframe_html = "<html><head></head><body><form method='POST' action='" + url +"'>" 
	    Object.keys(data).forEach(function(key) {
	        iframe_html += "<input type='hidden' name='"+key+"' value='"+data[key]+"'>";
	    });
	    iframe_html +="</form></body></html>";

	    iframe_doc.open();
	    iframe_doc.write(iframe_html);
	    $(iframe_doc).find('form').submit();
	}
	
	function convertFileSize(pSize) {
		var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
	    if (pSize == 0) return 'n/a';
	    var i = parseInt(Math.floor(Math.log(pSize) / Math.log(1024)));
	    return (pSize / Math.pow(1024, i)).toFixed(1) + sizes[i];
	}
	
</script>