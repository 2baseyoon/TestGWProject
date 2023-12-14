<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>    

<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code="Cache.BizSection_Survey"/> <spring:message code="Cache.BizSection_Admin"/></h2>
</div>		
<div class="cRContBottom mScrollVH">
<form id="form1">
	<div id="topitembar03" class="inPerView type02 sa04 active">
		<div>
			<div class="selectCalView">
				<spring:message code='Cache.lbl_State2'/>&nbsp;
				<select id="state" class="selectType04">
					<option value=""><spring:message code="Cache.lbl_all"/></option> <!-- 전체 -->
					<option value="B"><spring:message code="Cache.lbl_review1"/></option> <!-- 검토대기 -->
					<option value="D"><spring:message code="Cache.lbl_ReviewRejected"/></option> <!-- 검토거절 -->
					<option value="C"><spring:message code="Cache.lbl_adstandby"/></option> <!-- 승인대기  -->
					<option value="X"><spring:message code="Cache.lbl_ApprovalDeny"/></option> <!-- 승인거부 -->
					<option value="F"><spring:message code="Cache.lbl_Progressing"/></option> <!-- 진행중 -->
					<option value="G"><spring:message code="Cache.lbl_SurveyEnd"/></option> <!-- 설문종료 -->
				</select>
			</div>
			<div class="selectCalView" id="scheduleType"> 
				<select id="selType" class="selectType02"></select>			
				<input name="search" type="text" id="schTxt" onkeypress="if (event.keyCode==13){ searchSurvey(); return false;}" class="HtmlCheckXSS ScriptCheckXSS" />
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchSurvey();" ><spring:message code="Cache.btn_search"/></a>
			</div>	
		</div>	
	</div>	
    <div class="sadminContent">
    	<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
	    		<a class="btnTypeDefault BtnDelete" style="display:none;" onclick="updateSurveyState('', 'C', '<spring:message code="Cache.lbl_ReviewApproval"/>')"><spring:message code='Cache.lbl_ReviewApproval'/></a> <!-- 검토승인 -->
	    		<a class="btnTypeDefault BtnDelete" style="display:none;" onclick="updateSurveyState('', 'D', '<spring:message code="Cache.lbl_ReviewRejected"/>');"><spring:message code='Cahce.lbl_ReviewRejected'/></a> <!-- 검토거부 -->
	    		<a class="btnTypeDefault BtnDelete" onclick="updateSurveyState('', 'F', '<spring:message code="Cache.lbl_Approval"/>');"><spring:message code="Cache.lbl_Approval"/></a> 	<!-- 승인 -->
	    		<a class="btnTypeDefault BtnDelete" onclick="updateSurveyState('', 'X', '<spring:message code="Cache.lbl_ApprovalDeny"/>');"><spring:message code="Cache.lbl_ApprovalDeny"/></a> 	<!-- 승인거부 -->
	    		<a class="btnTypeDefault BtnDelete" onclick="updateSurveyState('', 'G', '<spring:message code="Cache.lbl_ForcedExit"/>');"><spring:message code="Cache.lbl_ForcedExit"/></a><!-- 강제종료 -->
	    		<a class="btnTypeDefault BtnDelete" onclick="updateSurveyState('', 'del', '<spring:message code="Cache.btn_delete"/>');"><spring:message code="Cache.btn_delete"/></a> 	<!-- 삭제 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" onclick="searchSurvey()"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv"></div>
		</div>	
	</div>
</form>
</div>
<script>
	//#sourceURL=SurveyManage.jsp
	
	var grid = new coviGrid();
	var lang = Common.getSession("lang");
	
	var page = CFN_GetQueryString("page")== 'undefined'?1:CFN_GetQueryString("page");
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	$('#selectPageSize').val(pageSize);
	
	init();

	// 설문관리(관리자)
	function init() {
		$("#selType").bindSelect({ //검색 조건
			options: [{'optionValue':'subject','optionText':"<spring:message code='Cache.lbl_subject'/>"},{'optionValue':'registerName','optionText':"<spring:message code='Cache.lbl_Register'/>"}]  // lbl_subject : 제목 , lbl_Register : 등록자
		});
		setGrid();	// 그리드 세팅
		searchSurvey();	// 검색
	}

	// 그리드 세팅
	function setGrid() {
		var headerData = [
		              	  {key:'SurveyID', label:'SurveyID', width:'20', align:'center', formatter:'checkbox',sort:false},
		                  {key:'Subject', label:"<spring:message code='Cache.lbl_subject'/>", width:'200', //제목
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						   				//if (this.item.State == 'F' || this.item.State == 'G') {
							   				html += "<a href=\"#none\" class=\"taTit\" onclick='openSurveyView(\"" + this.item.SurveyID + "\", \"" + this.item.State + "\")'>" + this.item.Subject + "</a>";
						   				//}
						   				html += "</div>";
						   			return html;
								}
		              	  },
		                  {key:'SurveyStartDate', label:"<spring:message code='Cache.lbl_startdate'/>"+ Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center', formatter: function(){ //시작일
		                	  return CFN_TransLocalTime(this.item.SurveyStartDate, 'yyyy.MM.dd');
		                  }}, 
		                  {key:'SurveyEndDate', label:"<spring:message code='Cache.lbl_EndDate'/>"+ Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center', formatter: function(){ //종료일
		                	  return CFN_TransLocalTime(this.item.SurveyEndDate, 'yyyy.MM.dd');
		                  }}, 
		                  {key:'State', label:"<spring:message code='Cache.lbl_ProgressState'/>", width:'60', align:'center', formatter: function(){ //진행상태
		                	  return Common.getDic('lbl_SurveyStatus_' + this.item.State);
		                  }}, 
		                  {key:'RespondentCnt', label:"<spring:message code='Cache.lbl_ParticipantsNum'/>", width:'40', align:'center'}, //참여자 수
			        	  {key:'RegistDate',  label:'<spring:message code="Cache.lbl_RegistDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', sort:'desc', formatter: function(){
								return CFN_TransLocalTime(this.item.RegistDate);
							   }},
		                  {key:'RegisterName', label:"<spring:message code='Cache.lbl_Register'/>", width:'50', align:'center'}, //등록자
		                  {key:'통계보기', label:'<spring:message code="Cache.lbl_StatisticsView"/>', width:'60', align:'center', sort:false,
						   	  formatter:function () {
						   			var html = "";
						   				if (this.item.State == 'F' || this.item.State == 'G') {
						   					html += "<a href='javascript:;' class='btnTypeDefault' onclick='openSurveyReportPop(\"" + this.item.SurveyID + "\")'><spring:message code='Cache.lbl_StatisticsView'/></a>";
						   				}
						   			return html;
								}
		              	  },
		                  {key:'차트보기', label:'<spring:message code="Cache.lbl_viewChart"/>', width:'60', align:'center', sort:false,
						   	  formatter:function () {
						   			var html = "";
						   				if (this.item.State == 'F' || this.item.State == 'G') {
						   					html += "<a href='javascript:;' class='btnTypeDefault' onclick='goSurveyChartView(\"" + this.item.SurveyID + "\")'><spring:message code='Cache.lbl_viewChart'/></a>"; 	// 차트보기
						   				}
						   			return html;
								}
		              	  },
		                  {key:'', label:'<spring:message code="Cache.lbl_State"/>', width:'120', align:'left', sort:false,	// 상태
						   	  formatter:function () {
						   			var html = "<div class='btnActionWrap'>";
						   			if (this.item.State == 'B' || this.item.State == 'D') {
						   				html += "<a href='javascript:;' class='btnTypeDefault' style='margin-right: 5px;' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "C" + "\",\"" + "<spring:message code='Cache.lbl_ReviewApproval'/>" + "\")'><spring:message code='Cache.lbl_ReviewApproval'/></a>"; // 감토승인
						   				html += "<a href='javascript:;' class='btnTypeDefault' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "D" + "\",\"" + "<spring:message code='Cache.lbl_ReviewRejected'/>" + "\")'><spring:message code='Cache.lbl_ReviewRejected'/></a>"; //검토거부
						   			} else if (this.item.State == 'X'){
						   				html += "<a href='javascript:;' class='btnTypeDefault' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "del" + "\",\"" + "<spring:message code='Cache.lbl_delete'/>" + "\")'><spring:message code='Cache.lbl_delete'/></a>"; //삭제
						   			} else if (this.item.State == 'C') {
						   				html += "<a href='javascript:;' class='btnTypeDefault' style='margin-right: 5px;' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "F" + "\",\"" + "<spring:message code='Cache.lbl_Approval'/>" + "\")'><spring:message code='Cache.lbl_Approval'/></a>"; //승인
						   				html += "<a href='javascript:;' class='btnTypeDefault' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "X" + "\",\"" + "<spring:message code='Cache.lbl_Reject'/>" + "\")'><spring:message code='Cache.lbl_Reject'/></a>"; //거절
						   			} else if (this.item.State == 'F') {
						   				html += "<a href='javascript:;' class='btnTypeDefault' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "G" + "\",\"" + "<spring:message code='Cache.lbl_ForcedExit'/>" + "\")'><spring:message code='Cache.lbl_ForcedExit'/></a>"; //강제종료
						   			} else if (this.item.State == 'G') {
						   				html += "<a href='javascript:;' class='btnTypeDefault' onclick='updateSurveyState(\"" + this.item.SurveyID + "\",\"" + "del" + "\",\"" + "<spring:message code='Cache.lbl_delete'/>" + "\")'><spring:message code='Cache.lbl_delete'/></a>"; //삭제
						   			} 
					   				html+="</div>";
						   			return html;
								}
		                  }
			      		 ];
		grid.setGridHeader(headerData);
		
		var configObj = {
			targetID : "gridDiv",
			colHeadTool : false,
			height:"auto",
			page : {
				pageNo : (page != undefined && page != '') ? page : 1,
				pageSize : (pageSize != undefined && pageSize != '') ? pageSize : 10
			},
			paging : true
		};
		grid.setGridConfig(configObj);
	}

	// 검색
	function searchSurvey() {
		<%-- paging 처리 --%>
		if(page != undefined && page != ''){
			grid.page.pageNo = page;
		}
		if(pageSize != undefined && pageSize != ''){
			grid.page.pageSize = pageSize;
		}
		
		var params = {sortBy : "RegistDate DESC", companyCode : confMenu.domainCode,
				 		selType : $('#selType').val(), schTxt : $('#schTxt').val(), state : $('#state').val()};
		
		grid.bindGrid({
			ajaxUrl : "/groupware/manage/survey/getSurveyManageList.do",
			ajaxPars : params,
		});
	}

	// 통계보기
	function openSurveyReportPop(surveyId) {
		Common.open("","survey_report","<spring:message code='Cache.lbl_StatisticsView'/>"/*설문결과 통계보기*/, "/groupware/manage/survey/goSurveyReportView.do?surveyId="+surveyId+"&isPopup=y","1000px","700px","iframe",true,null,null,true);	// 설문 결과 보기
	}
	
	function goSurveyChartView(surveyId){
		Common.open("","chart_popup","<spring:message code='Cache.lbl_viewChart'/>"/*설문결과 차트보기*/, "/groupware/survey/goSurveyChartView.do?surveyId=" + surveyId,"700px","500px","iframe",true,null,null,true);	// 설문 결과 보기
	}
	
	// 설문보기
	function openSurveyView(surveyId,state) {
/*		if(['F','G'].includes(state) ){
			window.open('/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + surveyId + '&viewType=resultView&listType='+(state=='F' ? 'proceed' : 'complete')+'&communityId=0','_blank','fullscreen=yes' );
		}else{
			Common.open("","reqApproval_pop","설문 내용보기",'/groupware/survey/goSurveyReqApproval.do?CLSYS=survey&CLMD=user&reqType=reqApproval&CLBIZ=Survey&surveyId=' + surveyId,"1050px","600px","iframe",true,null,null,true);	// 설문 승인, 거부 팝업
		}*/
		Common.open("","reqApproval_pop","<spring:message code='Cache.lbl_schedule_showContent'/>"/*설문 내용보기*/,'/groupware/survey/goSurveyCollabViewPopup.do?viewType=preview&isPopup=Y&surveyId=' + surveyId,"1050px","600px","iframe",true,null,null,true);	// 설문 승인, 거부 팝업
	}
	
	
	
	// 설문 상태 변경(B:검토대기, D:검토거부, C:승인대기, X:승인거부, F:진행중, G:설문종료)
	function updateSurveyState(surveyId, afterState, qTxt) {
		var surveyIdArr = new Array();
		if (surveyId == '') {
		    $(grid.getCheckedListWithIndex(0)).each(function () {
		    	if ((afterState == 'C' || afterState == 'D') && (this.item.State == 'B' || this.item.State == 'D')) {
		    		surveyIdArr.push(this.item.SurveyID);
		    	} else if ((afterState == 'F' || afterState == 'X') && this.item.State == 'X') {
		    		return;
		    	} else if ((afterState == 'F' || afterState == 'X') && (this.item.State == 'C' || this.item.State == 'X')) {
		    		surveyIdArr.push(this.item.SurveyID);
		    	} else if (afterState == 'G' && this.item.State == 'F') {
		    		surveyIdArr.push(this.item.SurveyID);
		    	} else if (afterState == 'del' && (this.item.State == 'G' || this.item.State == 'X')) {
		    		surveyIdArr.push(this.item.SurveyID);
		    	} else{
		    		grid.checkedColSeq(0,false,this.index);
		    	}
		    });
		} else {
			surveyIdArr.push(surveyId);
		}
		
		if(surveyIdArr.length < 1){
			Common.Warning(String.format("<spring:message code='Cache.msg_NotPossibleContent'/>", qTxt)); // {0} 가능한 항목이 없습니다.
			return false;
		}
		
		var params = new Object();
		params.surveyIdArr = surveyIdArr;
		params.state = afterState;
		
       	Common.Confirm(String.format("<spring:message code='Cache.msg_SureWantTo'/>", qTxt), "Confirmation Dialog", function (confirmResult) { // {0} 하시겠습니까?
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/survey/updateSurveyState.do",
					success:function (data) {
						if(data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform(String.format("<spring:message code='Cache.msg_SuccessSurvey'/>", qTxt), "Inform", function() { // 설문이 {0} 되었습니다.
									searchSurvey();	// 검색
								});
			          		} else {
			          			Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); //오류가 발생하였습니다.
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
	
	//페이지 개수 변경
	$("#selectPageSize").off('change').on("change", function(){
		pageSize = $(this).val();
		grid.page.pageSize = $(this).val();
		
		setGrid();	// 그리드 세팅
		searchSurvey();	// 검색
	});
	
</script>	
</body>
</html>