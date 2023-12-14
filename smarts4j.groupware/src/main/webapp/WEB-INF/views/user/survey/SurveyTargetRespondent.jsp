<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent pd0">
	<div class="selectSearchBox">
		<select class="selectType02" id="targetTypeSel">
			<option value="ur"><spring:message code='Cache.lbl_Participation_User' /></option>
			<option value="gr"><spring:message code='Cache.lbl_dept' /></option>
		</select>
		<span><input type="text" id="schTxt"   onkeypress=" if(event.keyCode==13){searchData(); return false;} " /><a class="btnSearchType01" onclick="searchData()" ></a></span>
		<button class="btnRefresh" type="button" onclick="refresh()"></button>					
	</div>				
	<div class="surTargetBtm" style="margin-top: 10px;">
		<div class="popSelectBox" style="height: 30px;">
			<select class="selectType02 pSel01" id="targetJoinSel" onchange="searchData();">
				<option value=""><spring:message code='Cache.btn_Select' /></option>
				<option value="attendance"><spring:message code='Cache.lbl_schedule_participation' /></option>
				<option value="nonAttendance"><spring:message code='Cache.lbl_Nonparticipation' /></option>
			</select>
			<select id="selectAlarmTarget" style="display:none;" class="selectType02" >
				<option value="part"><spring:message code='Cache.lbl_selectedUser' /></option>
				<option value="all"><spring:message code='Cache.lbl_allUser' /></option>
			</select>
			<% if (RedisDataUtil.getBaseConfig("isUseMail").equals("Y") && ComUtils.getAssignedBizSection("Mail")) { %> 
			<button id="btnAlarmSend" style="display:none;" class="btnBlueType01" type="button" onclick="sendNotAttendanceAlarm()"><spring:message code='Cache.btn_sendParticipationMsg' /></button>
			<%} %>
		</div>
		<div class="tblList">					
			<div id="gridDiv">
			</div>									
		</div>
	</div>
</div>

<script>
	//# sourceURL=SurveyTargetRespondent.jsp
	var surveyId = CFN_GetQueryString("surveyId");
	var ProfileImagePath = Common.getBaseConfig("ProfileImagePath").replace("/{0}", ""); //프로필 이미지 경로
	var grid = new coviGrid();
	var headerData = new Array();
	var listType = CFN_GetQueryString("listType");
	var isAnonymouse = (parent.surveyInfo && parent.surveyInfo.isAnonymouse) ? parent.surveyInfo.isAnonymouse : 'N';
	
	initContent();

	// 설문 대상
	function initContent(){
		setButton();
		
		setGrid();	// 그리드 세팅
		searchData();	// 검색
	}
	
	function setButton(){
		$.ajax({
			type:"POST",
			data:{
				"surveyId" : surveyId
			},
			async: false, 
			url:"/groupware/survey/getTargetRespondentList.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					if(listType == 'proceed'){
						if(data.list[0].RegisterCode == Common.getSession("UR_Code")){
							$("#selectAlarmTarget").show();
							$("#btnAlarmSend").show();
							
							headerData.push({key:'TargetCode', label:'', width:'8', align:'center', formatter:'checkbox',sort:false, disabled:function(){
						      			if(this.item.RegistDate == null || this.item.RegistDate == ""){
						      				return false;
						      			}else{
						      				return true;
						      			}
				      	  	 		}
							});
						}
					}
				}
				
			},
			error:function(response, status, error){
	    	     CFN_ErrorAjax("/covicore/survey/getTargetRespondentList.do", response, status, error);
	    	}
		});
	}
	
	// 그리드 세팅
	function setGrid() {
		headerData =  headerData.concat([
		      			/* {key:'TargetCode', label:'', width:'8', align:'center', formatter:'checkbox',sort:false, disabled:function(){
		      	      			if(this.item.RegistDate == null || this.item.RegistDate == ""){
		      	      				return false;
		      	      			}else{
		      	      				return true;
		      	      			}
		            	  	  }
		      			},		 */
		      			{key:'TargetCode', label:'', width:'8', align:'center', formatter:'checkbox',sort:false, display:false, hideFilter : 'Y'},		
		      			
		      			
		      			{key:'DisplayName', label:'<spring:message code="Cache.lbl_survey_participation" />', width:'28', align:'center', sort: 'ASC', addClass:'bodyTdFile', formatter:function () {
		      					var html = "<div class='tblParticipant'>"
		      					html += "<img src='" + coviCmn.loadImage(this.item.PhotoPath)+" ' alt='" + "<spring:message code='Cache.lbl_inputPhoto'/>" + "' style='width:30px;height:30px;border-radius:15px;' onerror='coviCmn.imgError(this, true)'>";
		      					html +=  "<a class='btnFlowerName' onclick='coviCtrl.setFlowerName(this)' style='margin-left : 10px'; data-user-code='"+ this.item.TargetCode +"' data-user-mail=''>" + this.item.DisplayName + "</a>";
		      					
		       					if (typeof(this.item.EtcOpinion) !='undefined' && this.item.EtcOpinion != '' && isAnonymouse != "Y") {
									html += "<div title='"+ this.item.EtcOpinion+"' class='tblToopTip'></div>";
								} 
		       				
		       					html += "</div>";
		       					
		      					return html;
		      				}					
		      			},
		      			{key:'DeptName', label:'<spring:message code="Cache.lbl_dept" />', width:'25', align:'center'},
		      			{key:'RegistDate', label:(isAnonymouse=="Y") ? '<spring:message code="Cache.lbl_Participation_Check" />' : '<spring:message code="Cache.lbl_Participation_Check" />'+Common.getSession("UR_TimeZoneDisplay"), width:'30', align:'left' ,align:'center',	formatter:function () {
		      					var html = "<span>";

		      					if (this.item.RegistDate == "") {
		      						html += "<spring:message code='Cache.lbl_Nonparticipation' />";
		      					} else {
		      						html += (isAnonymouse == "Y") ? "<spring:message code='Cache.lbl_survey_participation' />" : CFN_TransLocalTime(this.item.RegistDate);
		      					}
		      					
		      					html += "</span>";
		       						   			
		      					return html;
		      				}
		      			}		                  
		      		]);
		grid.setGridHeader(headerData);
		
		var configObj = {
			targetID : "gridDiv",
			height: "auto",
			colHeadTool : false
		};
		
		grid.setGridConfig(configObj);
	}

	// 검색
	function searchData() {
		var params = {surveyId : surveyId,
					  targetType : $("#targetTypeSel").val(),
					  schTxt : $("#schTxt").val(),
					  targetJoin : $("#targetJoinSel").val()};
		
		grid.page.pageNo = 1;
		grid.bindGrid({
			ajaxUrl : "/groupware/survey/getTargetRespondentList.do",
			ajaxPars : params
		});
	}
	
	function sendNotAttendanceAlarm(){
		var targetCode = ""
		
		if($("#selectAlarmTarget").val() == "all"){
			targetCode = "all";
		}else{
			var target = grid.getCheckedList(0);
			
			if(target.length == 0){
				Common.Warning("<spring:message code='Cache.msg_apv_157'/>"); /*대상자를 선택해 주세요.*/
				return;
			}
			
			var targetCodes = "";
			for(var i=0; i<target.length; i++){
				
				if(i==0){
					targetCodes = target[i].TargetCode;
				}else{
					targetCodes = targetCodes + ";" + target[i].TargetCode;
				}
			}
			
			targetCode = targetCodes;
		}
		
	
		$.ajax({
			type:"POST",
			data:{
				"targetCode" : targetCode,
				"surveyID" : surveyId
			},
			url:"/groupware/survey/sendNotAttendanceAlarm.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_NotificationSend'/>"); /*알림 발송 되었습니다. */
					grid.reloadList();
				}else{
					Common.Inform("<spring:message code='Cache.msg_failSendMsg'/>"); /*알림 발송이 실패하였습니다. */
				}
			},
			error:function(response, status, error){
	    	     CFN_ErrorAjax("/covicore/survey/sendNotAttendanceAlarm.do", response, status, error);
	    	}
		});
		
		
	}
	
	//새로고침
	function refresh(){
		$("#targetTypeSel").val('ur'),
		$("#schTxt").val(),
		$("#targetJoinSel").val(''),
		searchData();
	}
</script>
