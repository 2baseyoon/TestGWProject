<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class='cRConTop titType'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.MN_112' /></h2><!-- 진행중인 설문 -->
	<div class="searchBox02">
		<span><input id="simpleSchTxt" type="text"  onkeypress="if (event.keyCode==13){ search(); return false;}"  /><button type="button" class="btnSearchType01" onclick="search()">검색</button></span>
		<a class="btnDetails"><spring:message code='Cache.lbl_apv_detail' /></a><!-- 상세 -->
	</div>
</div>
<div class='surveyProgress'>
	<div class="inPerView type02">
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Contents' /></span><!-- 내용 -->
				<select class="selectType02" id="schContentType">
					<option value="subject"><spring:message code='Cache.lbl_Title' /></option><!-- 제목 -->
					<option id="opt_register" value="register"><spring:message code='Cache.lbl_Register' /></option><!-- 등록자 -->
					<option value="description"><spring:message code='Cache.lbl_Description' /></option><!-- 설문지 설명 -->
				</select>
				<div class="dateSel type02">
					<input type="text" id="schTxt"  onkeypress="if (event.keyCode==13){ search(); return false;}" >
				</div>											
			</div>
			<div onclick="search()">
				<a class="btnTypeDefault btnSearchBlue nonHover" ><spring:message code='Cache.lbl_search' /></a><!-- 검색 -->
			</div>
			<div class="chkGrade">									
				<div class="chkStyle01" id="notReadFg" style="display: none">
					<input type="checkbox" id="chkGrade"><label for="chkGrade"><span></span><spring:message code='Cache.lbl_Mail_Unread' /></label><!-- 읽지않음 -->
				</div>
			</div>
		</div>
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Period' /></span><!-- 기간 -->
				<select id="searchDate" class="selectType02"></select>
				<div id="divCalendar" class="dateSel type02">
					<input class="adDate" type="text" id="startDate" date_separator="." readonly=""> - <input id="endDate" date_separator="." kind="twindate" date_startTargetID="startDate" class="adDate" type="text" readonly="">
				</div>	
			</div>
		</div>
	</div>
	<div class="selectBox" id="selectBoxDiv">
		<a class="btnTypeDefault" id="delBtn" style="display: none" onclick="deleteSurvey();"><spring:message code='Cache.lbl_delete' /></a><!-- 삭제 -->
		<select class="selectType02" id="schState" style="display: none" onchange="search()">
		    <option value="" selected="selected"><spring:message code='Cache.lbl_Whole' /></option>
		    <option value="B"><spring:message code='Cache.lbl_review1' /></option>
		    <option value="C"><spring:message code='Cache.lbl_adstandby' /></option>
		    <option value="D"><spring:message code='Cache.lbl_ReviewRejected' /></option>
		    <option value="F"><spring:message code='Cache.lbl_Progressing' /></option>
		    <option value="G"><spring:message code='Cache.lbl_SurveyEnd' /></option>
		    <option value="X"><spring:message code='Cache.lbl_ApprovalDeny' /></option>
		</select>
		<select class="selectType02" id="schMySel" style="display: none" onchange="setGrid()">
		    <option value="written" selected="selected"><spring:message code='Cache.lbl_CompletedQuestionnaire' /></option><!-- 내가 작성한 설문 -->
		    <option value="participated"><spring:message code='Cache.lbl_SurveyedParty' /></option><!-- 내가 참여한 설문 -->
		</select>
		<select class="selectType02" id="listCntSel" style="width:63px;">
			<option>10</option>
			<option>15</option>
			<option>20</option>
			<option>30</option>
			<option>50</option>
		</select>
		<button class="btnRefresh" type="button" onclick="search()"></button>							
	</div>
	<div class="tblList tblCont">
		<div id="gridDiv">
		</div>
		<!-- <div class="goPage">
			<input type="text"> <span> / 총 </span><span>1</span><span>페이지</span><a class="btnGo">go</a>
		</div>		 -->
	</div>
</div>

<script>
	//# sourceURL=SurveyList.jsp
	var reqType = CFN_GetQueryString("reqType");	// reqType : proceed(진행중), complete(완료), tempSave(임시저장), reqApproval(검토, 승인 대기)
	var communityId = typeof(cID) == 'undefined' ? 0 : cID;	// 커뮤니티ID
	var activeKey = typeof(mActiveKey) == 'undefined' ? 1 : mActiveKey;	// 커뮤니티 메뉴 Key
	var listSelect = CFN_GetQueryString("listSelect")	// written(내가 작성한 설문) , participated(내가 참여한 설문) - 목록으로 돌아갈 때 사용
	var page = CFN_GetQueryString("page")== 'undefined'?1:CFN_GetQueryString("page");
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	

	if(CFN_GetCookie("surListCnt")){
		pageSize=CFN_GetCookie("surListCnt");
	}
	
	$("#listCntSel").val(pageSize);
	//개별호출-일괄호출
	var sessionObj = Common.getSession(); //전체호출
	
	var lang = sessionObj["lang"];
	var userID = sessionObj["USERID"];
	
	var grid = new coviGrid();
	
	initContent();

	// 진행 중인 설문, 완료된 설문, 임시저장한 설문, 승인 및 검토 요청
	function initContent(){
		init();		// 초기화

		setGrid();	// 그리드 세팅
		
		search();	// 검색
	}
	
	// 초기화
	function init() {
		switch (reqType) {
			case 'mySurvey' : $("#reqTypeTxt").html("<spring:message code='Cache.MN_114' />");/* 나의 설문 */
							  $("#schMySel").css("display",""); 
							  break ;
			case 'proceed' : $("#reqTypeTxt").html("<spring:message code='Cache.MN_112' />");/* 진행중인 설문 */
							 $("#notReadFg").css("display",""); 
							 break;
			case 'complete' : $("#reqTypeTxt").html("<spring:message code='Cache.MN_113' />");/* 완료된 설문 */
							  $("#notReadFg").css("display",""); 
							  $("#opt_participate").css("display", "none"); 
							  break;
			case 'tempSave' : $("#reqTypeTxt").html("<spring:message code='Cache.MN_111' />");/* 임시저장 */
							  $('#selectBoxDiv').addClass('type01'); 
							  $("#delBtn").css("display",""); 
							  $("#opt_register").css("display", "none"); 
							  $(".suveryMenu01 a").removeClass("selected");
							  $(".suveryMenu03 a").addClass("selected");
							  break;
			case 'reqApproval' : $("#reqTypeTxt").html("<spring:message code='Cache.MN_115' />");/* 승인 및 검토요청 */
								 break;
		}
		
		if(listSelect != 'undefined' &&  listSelect != null){
			$("#schMySel").val(listSelect); //뒤로가기 (목록) 버튼으로 뒤로 돌아온 경우 선택했던 select box 선택
		}
		
		// 상세 보기
 		$('.btnDetails').on('click', function(){
			var mParent = $('.inPerView');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
		});

		// 그리드 카운트
		$('#listCntSel').on('change', function(e) {
			grid.page.pageSize = $(this).val();
			CFN_SetCookieDay("surListCnt", $(this).find("option:selected").val(), 31536000000);
			grid.reloadList();
		});

		// 내가 작성한 설문...
		$('#schMySel').on('change', function(e) {
			search();
		});		

		$('#searchDate').coviCtrl("setDateInterval", $('#startDate'), $('#endDate'), "", {"changeTarget": "startDate"});	//검색 기간
	}
	
	
	
	// 그리드 세팅
	function setGrid() {
		// header
		var headerData;
		var overflowCell =[];
		
		if(reqType == 'mySurvey' && $("#schMySel").val() == "written"){ //나의 설문 내가 작성한 설문
			$("#opt_register").hide();
			$("#schState").show();
			headerData = [
				          	{key:'State', label:'<spring:message code="Cache.lbl_State" />', width:'10', align:'center', 
								formatter:function () {
									return getStateName(this.item.State);
								}
							},
							{key:'Subject', label:'<spring:message code="Cache.lbl_subject" />', width:'60', align:'left',
								formatter:function () {
									var html = "<div class='tblLink'>";
									html += "<a onclick='openPop(\"" + reqType + "\", \"" + this.item.SurveyID + "\", \"" + this.item.joinFg + "\", \"Y\", \"" + this.item.IsTargetRespondent + "\", \"" + this.item.State + "\"); return false;'>";
									if (this.item.IsImportance == 'Y') {	html += "<span class='btnType02 active'><spring:message code='Cache.lbl_surveyUrgency' /></span> ";	}				
									html += this.item.SubjectHtml;
									//if (this.item.readFg != 'Y' && this.item.RegisterCode != userID){ 	html += "<span class='cycleNew new'>N</span>";	}
									html += "</a></div>";
										
									return html;
								}
							},
							{key:'SurveyStartDate', label:'<spring:message code="Cache.lbl_Survey_period" />'+ Common.getSession("UR_TimeZoneDisplay"), width:'20', align:'center', formatter: function(){
								return (this.item.SurveyStartDate + "~" + this.item.SurveyEndDate);
							}},
							{label:'<spring:message code="Cache.lbl_StatisticsView" />', width:'10', align:'center', sort:false, formatter:function () {
								var ret = '';
								if(this.item.State == 'G') {
									ret= "<a class='btnTypeDefault' onclick='openSurveyReportPop(\"" + this.item.SurveyID + "\")'><spring:message code='Cache.lbl_StatisticsView'/></a>" //통계보기
								}
								return ret;
							}},
							{label:"<spring:message code='Cache.lbl_Setting' /> <spring:message code='Cache.lbl_change' />", width:'10', align:'center', sort:false, formatter:function () { // 설정 변경
								var ret = '';
								if(this.item.State == 'F') {
									ret= "<a class='btnTypeDefault' onclick='goEditPage(\"" + this.item.SurveyID + "\")'><spring:message code='Cache.lbl_Setting' /> <spring:message code='Cache.lbl_change' /></a>" // 설정 변경
								}
								return ret;
							}}
						];
		}else if (reqType == 'mySurvey' && $("#schMySel").val() == "participated") { //나의 설문 - 내가 참여한 설문
			$("#opt_register").show();
			$("#schState").hide();
			headerData = [
				          	{key:'State', label:'<spring:message code="Cache.lbl_State" />', width:'10', align:'center', 
								formatter:function () {
									return getStateName(this.item.State);
								}
							},
							{key:'Subject', label:'<spring:message code="Cache.lbl_subject" />', width:'50', align:'left',
								formatter:function () {
									var html = "<div class='tblLink'>";
									html += "<a onclick='openPop(\"" + reqType + "\", \"" + this.item.SurveyID + "\", \"" + this.item.joinFg + "\", \"" + this.item.IsTargetResultView + "\", \"\", \"\"); return false;'>";
									if (this.item.IsImportance == 'Y') {	html += "<span class='btnType02 active'><spring:message code='Cache.lbl_surveyUrgency' /></span> ";		}					   			
									html += this.item.SubjectHtml;
									//if (this.item.readFg != 'Y' && this.item.RegisterCode != userID) {	html += "<span class='cycleNew new'>N</span>";	}
									html += "</a></div>";
										
									return html;
								}
							},
							{key:'SurveyStartDate', label:'<spring:message code="Cache.lbl_Survey_period" />'+ Common.getSession("UR_TimeZoneDisplay"), width:'20', align:'center', formatter: function(){
								return (this.item.SurveyStartDate + "~" + this.item.SurveyEndDate);
							}},
							{key:'RegisterName',  label:'<spring:message code="Cache.lbl_Register" />', width:'10', align:'center', formatter: function(){
					            return coviCtrl.formatUserContext("List", CFN_GetDicInfo(this.item.RegisterName, lang), this.item.RegisterCode, this.item.MailAddress);
					        }},
							{label:"<spring:message code='Cache.CuPoint_Reply' /> <spring:message code='Cache.btn_Edit' />", width:'10', align:'center', sort:false, formatter:function () { // 답변 수정
								var ret = '';
								if(this.item.State == 'F') {
									ret= "<a class='btnTypeDefault' onclick='goSurveyEditPage(\"" + this.item.SurveyID + "\")'><spring:message code='Cache.CuPoint_Reply' /> <spring:message code='Cache.btn_Edit' /></a>" // 답변 수정
								}
								return ret;
							}}
						];
		
			overflowCell = [3];
		}else if (reqType == 'proceed') {
			headerData = [
				{key:'State', label:'<spring:message code="Cache.lbl_State" />', width:'30', align:'center', 
					formatter:function () {
						if(this.item.joinFg == 'N'){
							return '<spring:message code="Cache.lbl_Ready" />';	
						}else{
							return '<spring:message code="Cache.lbl_Completed" />';
						}
					}
				},
				{key:'Subject', label:'<spring:message code="Cache.lbl_subject" />', width:'170', align:'left',
					formatter:function () {
						var html = "<div class='tblLink'>";
						html += "<a onclick='openPop(\"" + reqType + "\", \"" + this.item.SurveyID + "\", \"" + this.item.joinFg + "\",\""+ this.item.IsTargetResultView+"\", \"" + this.item.IsTargetRespondent + "\", \"" + this.item.State + "\"); return false;'>";
						if (this.item.IsImportance == 'Y') {	html += "<span class='btnType02 active'><spring:message code='Cache.lbl_surveyUrgency' /></span> ";}	   			
						//html += this.item.SubjectHtml;
						if(this.item.joinFg == 'N'){
							html += "<strong>" + this.item.Subject + "</strong>";	
						}else{
							html += this.item.Subject;
						}
						if (this.item.readFg != 'Y' && this.item.RegisterCode != userID){ 	html += "<span class='cycleNew new'>N</span>";	}
						html += "</a>";
						html += "</div>";
							
						return html;
					}
				},
				{key:'SurveyStartDate', label:'<spring:message code="Cache.lbl_Survey_period" />'+ Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', formatter: function(){
					return (CFN_TransLocalTime(this.item.SurveyStartDate,'yyyy.MM.dd') + "~" + CFN_TransLocalTime(this.item.SurveyEndDate,'yyyy.MM.dd'));
				}},
		        {key:'RegisterName',  label:'<spring:message code="Cache.lbl_Register" />', width:'100', align:'center', addClass:"bodyTdFile", formatter: function(){
		            return coviCtrl.formatUserContext("List", CFN_GetDicInfo(this.item.RegisterName, lang), this.item.RegisterCode, this.item.MailAddress);
		        }}, 
		        {key:'joinRate', label:'<spring:message code="Cache.lbl_rate" />', width:'100', align:'center',
					formatter:function () {
						var rate = Math.ceil(this.item.joinRate);
						var html = "<div class='participationRateBar'>";
						html += "<div style='width:" + rate + "%;'></div>";
						html += "</div>";
						html += "<span>" + rate + "%</span>";
						  			
						return html;
					}
				}
			];
			overflowCell = [2];
		}else if ( reqType == 'complete') {
			headerData = [
				{key:'Subject', label:'<spring:message code="Cache.lbl_subject" />', width:'144', align:'left',
					formatter:function () {
						var html = "<div class='tblLink'>";
						html += "<a onclick='openPop(\"" + reqType + "\", \"" + this.item.SurveyID + "\", \"" + this.item.joinFg + "\",\""+ this.item.IsTargetResultView+"\", \"" + this.item.IsTargetRespondent + "\", \"" + this.item.State + "\"); return false;'>";
						if (this.item.IsImportance == 'Y') {	html += "<span class='btnType02 active'><spring:message code='Cache.lbl_surveyUrgency' /></span> ";}	   			
						html += this.item.SubjectHtml;
						if (this.item.readFg != 'Y' && this.item.RegisterCode != userID){ 	html += "<span class='cycleNew new'>N</span>";	}
						html += "</a>";
						html += "</div>";
							
						return html;
					}
				},
				{key:'SurveyStartDate', label:'<spring:message code="Cache.lbl_Survey_period" />'+ Common.getSession("UR_TimeZoneDisplay"), width:'110', align:'center', formatter: function(){
					return (CFN_TransLocalTime(this.item.SurveyStartDate,'yyyy.MM.dd') + "~" + CFN_TransLocalTime(this.item.SurveyEndDate,'yyyy.MM.dd'));
				}},
		        {key:'RegisterName',  label:'<spring:message code="Cache.lbl_Register" />', width:'89', align:'center', formatter: function(){
		            return coviCtrl.formatUserContext("List", CFN_GetDicInfo(this.item.RegisterName, lang), this.item.RegisterCode, this.item.MailAddress);
		        }}, 
		        {key:'joinRate', label:'<spring:message code="Cache.lbl_rate" />', width:'96', align:'center',
					formatter:function () {
						var rate = Math.ceil(this.item.joinRate);
						var html = "<div class='participationRateBar'>";
						html += "<div style='width:" + rate + "%;'></div>";
						html += "</div>";
						html += "<span>" + rate + "%</span>";
						  			
						return html;
					}
				},
		        {label:'<spring:message code="Cache.lbl_StatisticsView" />', width:'71', align:'center', sort:false, formatter:function () {
						return "<a class='btnTypeDefault' onclick='openSurveyReportPop(\"" + this.item.SurveyID + "\")'><spring:message code="Cache.lbl_StatisticsView" /></a>";
				}}
			];
			overflowCell = [2];
		} else if (reqType == 'tempSave') {
			headerData = [
				{key:'SurveyID', label:'SurveyID', width:'25', align:'center', formatter:'checkbox', sort:false},			              
				{key:'Subject', label:'<spring:message code="Cache.lbl_subject" />', width:'350', align:'left',
					formatter:function () {
						var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						html += "<a href=\"#none\" class=\"taTit\" onclick='openPop(\"" + reqType + "\", \"" + this.item.SurveyID + "\", \"\", \"\", \"\", \"\"); return false;'>" + this.item.Subject + "</a>";
						html += "</div>";
						
						return html;
					}
				},
				{key:'RegistDate', label:'<spring:message code="Cache.lbl_RegDate" />'  + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', formatter: function(){
					return getStringDateToString("yyyy-MM-dd", this.item.RegistDate);
				}}
			];			
		} else if (reqType == 'reqApproval') {
			headerData = [
				{key:'State', label:'<spring:message code="Cache.lbl_reqClass" />', width:'30', align:'center',
					formatter:function () {
						if(this.item.State == "B")
							return "<a class='btnGray'><spring:message code='Cache.lbl_Mail_Review' /></a>";
						else
							return  "<a class='btnGray'><spring:message code='Cache.lbl_Approval' /></a>";
					}
				},
				{key:'Subject', label:'<spring:message code="Cache.lbl_subject" />', width:'250', align:'left',
					formatter:function () {
						var html = "<div class='tblLink'>";
						html += "<a onclick='openPop(\"" + reqType + "\", \"" + this.item.SurveyID + "\", \"\", \"\", \"\", \"\"); return false;'>";
						if (this.item.IsImportance == 'Y'){ html += "<span class='btnType02 active'><spring:message code='Cache.lbl_surveyUrgency' /></span> ";	}
						html += this.item.SubjectHtml;
						//if (this.item.readFg != 'Y' && this.item.RegisterCode != userID) {	html += "<span class='cycleNew new'>N</span>";	}
						html += "</a></div>";
						  			
						return html;
					}
				},
				{key:'SurveyStartDate', label:'<spring:message code="Cache.lbl_Survey_period" />'+ Common.getSession("UR_TimeZoneDisplay"), width:'50', align:'center', formatter: function(){
					return (CFN_TransLocalTime(this.item.SurveyStartDate,'yyyy.MM.dd') + "~" + CFN_TransLocalTime(this.item.SurveyEndDate,'yyyy.MM.dd'));
				}},
				{key:'RegisterName',  label:'<spring:message code="Cache.lbl_Register" />', width:'50', align:'center', formatter: function(){
		           return coviCtrl.formatUserContext("List", CFN_GetDicInfo(this.item.RegisterName, lang), this.item.RegisterCode, this.item.MailAddress);
		        }}, 
		        {label:' ', width:'60', align:'center', sort:false, formatter:function () {
						var html = '';
	
						html += "<div class='btnTblBox'>";
						html += "<a class='btnTypeChk btnTypeDefault' onclick='updateSurveyState(\"" + this.item.State + "\", \"accept\", \"" + this.item.SurveyID + "\")'><spring:message code='Cache.lbl_Approval' /></a>";
						html += "<a class='btnTypeX btnTypeDefault' onclick='updateSurveyState(\"" + this.item.State + "\", \"refuse\", \"" + this.item.SurveyID + "\")'><spring:message code='Cache.lbl_Deny' /></a>";
						html += "</div>";
						  				
						return html;
				}}
			];
			
			overflowCell = [3];
		}
		
		grid.setGridHeader(headerData);
		
		// config
		var configObj = {
			targetID : "gridDiv",
			height:"auto",
			colHeadTool: false,
			page : {
				pageNo: (page != undefined && page != '')?page:1,
				pageSize: (pageSize != undefined && pageSize != '')?pageSize:10,
			},
			overflowCell: overflowCell
		};
		grid.setGridConfig(configObj);
		
		var listCntSel =  $("select[id='listCntSel']");
		
		if(listCntSel.length > 0) {
	    	if(CFN_GetCookie("surListCnt")) {
	    		listCntSel.val(CFN_GetCookie("surListCnt"));
	        }	    	
	    	
		}
	
	}

	// 검색
	function search() {
		var params = {
			reqType : reqType,
			schContentType : $('#schContentType').val(),
			schMySel : $('#schMySel').val(),
			schState : $('#schState').val(),
			notReadFg : $('#chkGrade').prop('checked') ? 'Y' : 'N',
			schTxt : $('#schTxt').val(),
			simpleSchTxt : $('#simpleSchTxt').val(), /* 상단 간편검색 제목 기준 */
			communityId : communityId
		};
		
		if($('.btnDetails').hasClass('active')){
			if($("#startDate").val() > $("#endDate").val()){
				Common.Warning(Common.getDic("msg_StartDateCannotAfterEndDate"))	//시작일은 종료일보다 이후일 수 없습니다.
				return;
			}
			params['startDate'] = $("#startDate").val();
			params['endDate'] = $("#endDate").val();
		} else {
			params['startDate'] = "";
			params['endDate'] = "";
		}
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/survey/getSurveyList.do",
			ajaxPars : params
		});
	}
	
	// 통계보기
	function openSurveyReportPop(surveyId) {
		// isPopup : 문항이 많아질경우 layer popup 의 iframe 내의 Table 깨짐을 방지하기 위한 flag
		Common.open("","viewReport","<spring:message code='Cache.lbl_Survey_Statistics' />","/groupware/surveyAdmin/goSurveyReport.do?isPopup=y&type=user&surveyId="+surveyId, "800px","500px","iframe",true,null,null,true,"UA");	
	}

	// 설문 정보 수정 페이지 이동
	function goEditPage(surveyId){
		var communityId = CFN_GetQueryString("communityId");
		
		CoviMenu_GetContent('/groupware/layout/survey_SurveyWrite.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&listType=modify&reqType=edit&surveyId='+surveyId+'&communityId='+communityId);
	}
	
	// 설문 답변 수정 페이지 이동
	function goSurveyEditPage(surveyId){
		var communityId = CFN_GetQueryString("communityId");
		
		CoviMenu_GetContent('/groupware/layout/survey_Survey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=edit&listType=proceed&surveyId='+surveyId+'&communityId='+communityId);
	}
	
	// 제목 클릭 (joinFg: 참여 여부, isViewer: 결과공개대상 여부)
	function openPop(type, surveyId, joinFg, isViewer, isTarget, state) {
		var url = '';
		// 설문상태(A:작성중, B:검토대기, D:검토거부, C:승인대기, X:승인거부, F:진행중, G:설문종료)
		if(type == 'mySurvey' && $("#schMySel").val() == "written"){  //나의 설문 내가 작성한 설문
			if( ['B','C','D','X'].includes(state) ){
				url = '/groupware/survey/goSurveyReqApproval.do?CLSYS=survey&CLMD=user&reqType=reqApproval&CLBIZ=Survey&surveyId=' + surveyId;
				
				if (communityId != 0) 
					url += '&CSMU=C';
				
				Common.open("","reqApproval_pop","<spring:message code='Cache.lbl_title15' />",url,"1050px","608px","iframe",true,null,null,true);	// 설문 승인, 거부 팝업
			}else if(state == "G"){
				 openPop('complete', surveyId, joinFg, isViewer, isTarget, state);
			}else if(state == "F"){
				 openPop('proceed', surveyId, joinFg, 'Y', isTarget, state);
			}
		}else if (type == 'mySurvey' && $("#schMySel").val() == "participated") { //나의 설문 - 내가 참여한 설문
			//updateSurveyRead(surveyId);	// 읽음 업데이트

			if(isViewer == "Y"){	// 결과 공개 대상인 경우: 결과 보기 화면으로 이동
				url = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&listType='+reqType+'&listSelect='+$("#schMySel").val()+'&surveyId=' + surveyId + '&viewType=resultView&communityId=' + communityId;	// 전체 결과 보기
			}else {// 결과 공개 대상이 아닌 경우: 자신이 응답한 내용 조회
				url = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&listType='+reqType+'&listSelect='+$("#schMySel").val()+'&surveyId=' + surveyId + '&viewType=myAnswer&communityId=' + communityId;	// 설문보기
			}
			
			if (communityId != 0) 
				url += '&CSMU=C';
			
			CoviMenu_GetContent(url);
			
		}else if (type == 'proceed') {
			updateSurveyRead(surveyId);	// 읽음 업데이트
			
			if(isTarget == "Y"){
				if(joinFg == "Y"){
					if(isViewer == "Y"){
						//전체 결과 공개
						url = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + surveyId + '&listType='+reqType+'&viewType=resultView&communityId=' + communityId;	// 전체 결과 보기
					}else{
						//자기가 한 결과만 공개
						url = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + surveyId + '&listType='+reqType+'&viewType=myAnswer&communityId=' + communityId;	// 설문보기
					}
				}else{
					//참여
					url = '/groupware/layout/survey_Survey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=join&listType='+reqType+'&surveyId=' + surveyId + '&communityId=' + communityId;	// 설문참여
				}
			}else{ // isTarget == "N"
				//전체 결과 공개
				url = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&listType='+reqType+'&surveyId=' + surveyId + '&viewType=resultView&communityId=' + communityId;	// 설문보기
			}
			
			if (communityId != 0) 
				url += '&CSMU=C';

			//location.href=url;
			CoviMenu_GetContent(url);
		} else if (type == 'complete') {
			updateSurveyRead(surveyId);
			
			url = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&viewType=resultView&listType='+reqType+'&surveyId=' + surveyId + '&communityId=' + communityId;	// 설문보기
			
			if (communityId != 0)
				url += '&CSMU=C';
			
			CoviMenu_GetContent(url);
		} else if (type == 'tempSave') {	
			url = '/groupware/layout/survey_SurveyWrite.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&listType='+reqType+'&reqType=tempSave&surveyId=' + surveyId + "&communityId=" + communityId;	// 설문수정
			
			if (communityId != 0) url += '&CSMU=C';
			
			CoviMenu_GetContent(url);
		} else if (type == 'reqApproval') {
			url = '/groupware/survey/goSurveyReqApproval.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&listType='+reqType+'&reqType=reqApproval&surveyId=' + surveyId + '&viewType=req';
			
			if (communityId != 0) 
				url += '&CSMU=C';
			
			Common.open("","reqApproval_pop","<spring:message code='Cache.btn_preview' />",url,"1050px","608px","iframe",true,null,null,true);	// 설문 승인, 거부 팝업
		}
	}

	// 읽음 업데이트
	function updateSurveyRead(surveyId) {
		$.ajax({
			type : "POST",
			data : {surveyId : surveyId},
			url : "/groupware/survey/updateSurveyTargetRead.do",
			success:function (data) {
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	// 삭제
	function deleteSurvey() {
		var params = new Object();
		var surveyIdArr = new Array();
		
		if(grid.getCheckedList(0).length > 0){
			if(reqType != "tempSave"){
				Common.Warning("<spring:message code='Cache.msg_noDeleteACL'/>"); // 삭제 권한이 없습니다.
				return false;
			}
		}else{
			Common.Warning("<spring:message code='Cache.msg_apv_003' />"); // 선택된 항목이 없습니다.
			return false;
		}
		
	    $('#gridDiv_AX_gridBodyTable tr').find('input[type="checkbox"]:checked').each(function () {
	    	surveyIdArr.push(this.value);
	    });
		params.surveyIdArr = surveyIdArr;
		
      	Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/survey/deleteSurvey.do",
					success:function (data) {
						if (data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform("<spring:message code='Cache.msg_50' />", "Inform", function() {
									search();	// 검색
								});
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
	
	
	// 설문 상태 변경(승인, 거부)
	function updateSurveyState(state, type, surveyId) {
		var params = new Object();
		// 설문상태(A:작성중, B:검토대기, D:검토거부, C:승인대기, X:승인거부, F:진행중, G:설문종료)
		if (state == 'B') {	// 검토대기
			params.state = (type == 'accept') ? 'C' : 'D';
		} else {
			params.state = (type == 'accept') ? 'F' : 'X';
		}
		var surveyIdArr = new Array();
		surveyIdArr.push(surveyId);
		params.surveyIdArr = surveyIdArr;
		
		var qTxt = (type == 'accept') ? "<spring:message code='Cache.lbl_Approval' />" : "<spring:message code='Cache.lbl_Deny' />";
       	Common.Confirm(qTxt + " 하시겠습니까?", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/survey/updateSurveyState.do",
					success:function (data) {
						if(data.result == "ok") {
							if(data.status == 'SUCCESS') {
								if ($('#reqApproval_pop_p').length > 0) $('.divpop_close').click();
								
								search();	// 검색
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
	
	// 승인, 검토 화면에서의 버튼 처리
	function updateSurveyStateByPopup(reqType) {
		tarTr = $("#gridDiv_AX_tbody > tr.selected").length;
		
		if (tarTr > 0) {
			if (reqType == 'accept') {
				$("#gridDiv_AX_tbody > tr.selected").find('.btnTypeChk').click();
			} else {
				$("#gridDiv_AX_tbody > tr.selected").find('.btnTypeX').click();
			}
		}
	}
	
	
	function getStateName(state){
		// 설문상태(A:작성중, B:검토대기, D:검토거부, C:승인대기, X:승인거부, F:진행중, G:설문종료)
		var name = '';  
		
		switch(state){
		case 'A':
			name = "<spring:message code='Cache.lbl_SurveyWriting' />";
			break;
		case 'B':
			name = "<spring:message code='Cache.lbl_review1' />";
			break;
		case 'C':
			name = "<spring:message code='Cache.lbl_adstandby' />";
			break;
		case 'D':
			name = "<spring:message code='Cache.lbl_ReviewRejected' />";
			break;
		case 'F':
			name = "<spring:message code='Cache.lbl_Progressing' />";
			break;
		case 'G':
			name = "<spring:message code='Cache.lbl_SurveyEnd' />";
			break;
		case 'X':
			name = "<spring:message code='Cache.lbl_ApprovalDeny' />";
			break;
		}
		
		return name; 
	}
</script>			