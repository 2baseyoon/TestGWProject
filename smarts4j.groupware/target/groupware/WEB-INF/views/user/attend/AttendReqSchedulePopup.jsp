<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil
,egovframework.covision.groupware.attend.user.util.AttendUtils,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<style>
		<%=(RedisDataUtil.getBaseConfig("CustomSchYn").equals("Y")?"":".btn_WTemp_wrap {display:none !important}")%>
	</style>
</head>
<body>
	<div class="layer_divpop" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="ATMgt_popup_wrap">
			<div class="ATMgt_work_wrap">
				<table class="ATMgt_popup_table type03" cellspacing="0" cellpadding="0">
					<colgroup>
				        <col width="122">
				        <col width="*">
				        <col width="122">
				        <col width="*">        
				    </colgroup>
					<tbody>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.mag_Attendance37' /></td> <!-- 신청 방식 -->
							<td colspan=3>
								<input type="radio" id="selectType1" name="selectType" value="0" checked/>
								<label for="selectType1"><spring:message code='Cache.mag_Attendance38' /></label> <!-- 근무제 선택 -->
								<input type="radio" id="selectType2" name="selectType" value="1">
								<label for="selectType2"><spring:message code='Cache.lbl_Mail_DirectInput' /></label> <!-- 직접입력 -->
							</td>
						</tr>
						<tr>
							<td class="ATMgt_T_th" id="selectTypeTitle"><spring:message code='Cache.lbl_n_att_attendSch' /></td>
							<td colspan=3>
								<div class="ATMgt_T">
									<div class="ATMgt_T_l" id="selectSchDiv">
										<a onclick='$("#divWork").show()' class="btnTypeDefault selectType02" id="selectSchedule"><spring:message code='Cache.msg_Select' /></a>
									</div>
									<div class="ATMgt_T_l" id="directInputDiv" style="display: none">
										<div class="ATMgt_T_Time">
											<select id="WorkStartHour" name="WorkStartHour" style="width:50px;">
												<c:forEach begin="00" end="23" var="hour">
													<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"> <c:out value="${ hour < 10 ? '0' : '' }${hour}"/></option>
												</c:forEach>
											</select>
											<span>:</span>
											<input type="text" name="WorkStartMin" id="WorkStartMin" maxlength="2" value="00"/>
											<span>-</span>
											<select id="WorkEndHour" name="WorkEndHour" style="width:50px;">
												<c:forEach begin="00" end="23" var="hour">
													<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"> <c:out value="${ hour < 10 ? '0' : '' }${hour}"/></option>
												</c:forEach>
											</select>
											<span>:</span>
											<input type="text" name="WorkEndMin" id="WorkEndMin" maxlength="2" value="00"/>
											<input type="checkbox" id="WorkNextDayYn" name="WorkNextDayYn" value="Y"/>
											<label for="WorkNextDayYn"><spring:message code='Cache.lbl_NextDay'/></label>
										</div>
									</div>
									<div class="ATMgt_T_r"><a class="btnTypeDefault btnRepeat" id="btnRepeat" ><spring:message code='Cache.lbl_scope' /></a></div>
								</div>
								<!-- 템플릿 선택 레이어 팝업 시작 -->
								<div class="ATMgt_Work_Popup" id="divWork" style="width:385px; left:170px; z-index:105;display:none">
									<a onclick='$("#divWork").hide()' class="Btn_Popup_close"></a>
									<div class="ATMgt_Cont">
										<div class="WTemp_search_wrap">
											<div class="searchBox02">
												<span>
													<input type="text" class="w100" id="SchName" name="SchName">
													<button class="btnSearchType01" type="button"  id="allFind"><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
												</span>
											</div>
										</div>
										<div class="WTemp_Type_wrap">
											<ul class="WTemp_Type_list">
											</ul>
										</div>
										<div class="btn_WTemp_wrap"><a href="#" class="btnTypeDefault btn_WTemp" id="btnTemp"><spring:message code='Cache.mag_Attendance39' /></a></div> <!-- 사용자 지정 템플릿 관리 -->
										<div class="bottom">
											<a href="#" class="btnTypeDefault" onclick='$("#divWork").hide()'><spring:message code='Cache.lbl_close' /></a>
										</div>
									</div>
								</div>
								<!-- 템플릿 선택 레이어 팝업 끝 -->
								<!-- 반복 선택 레이어 팝업 시작 -->
								<div class="ATMgt_Work_Popup" id="divRepeat" style="width:282px; left:170px; z-index:105;display:none">
									<a onclick='$("#divRepeat").hide()' class="Btn_Popup_close"></a>
									<div class="ATMgt_Cont">
									    <span id="divCalendar" class="dateSel type02">
											<input class="adDate" type="text" id="StartDate" date_separator="-" readonly=""> -
											<input id="EndDate" date_separator="-" kind="twindate" date_startTargetID="StartDate" class="adDate" type="text" readonly="">
										</span>
										<div class="bottom">
											<a href="#" class="btnTypeDefault btnTypeChk" id="btnReqRepeat"><spring:message code='Cache.lbl_att_approval' /></a>
											<a href="#" class="btnTypeDefault" onclick='$("#divRepeat").hide()'><spring:message code='Cache.lbl_close' /></a>
										</div>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_excludeHolidays' /></td>
							<td><div class="alarm type01"><input id="HolidayFlag" value="Y" type="checkbox" checked style="display:none">
								<label class="onOffBtn on" href="#" for="HolidayFlag"><span></span></label></div>
							</td>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Approver' /></td>
							<td>${UR_ManagerName}</td>
							
						</tr>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_work_content' /></td> <!-- 비고 -->
							<td colspan=3><textarea id="Comment" name="Comment" class="ATMgt_Tarea"></textarea></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="WTemp_cal_wrap">
				<div class="WTemp_cal_Top">
					<strong class="WTemp_cal_date"  id="dateTitle"></strong>
					<div class="pagingType01"><a class="pre" href="#"></a><a class="next" href="#"></a></div>
				</div>
    			<table class="WTemp_cal" id="calendar" cellpadding="0" cellspacing="0">
					<thead>
						<tr>
							<th><span class="tx_sun"><spring:message code='Cache.lbl_sch_sun' /></span></th> <!-- 일 -->
							<th><spring:message code='Cache.lbl_sch_mon' /></th> <!-- 월 -->
							<th><spring:message code='Cache.lbl_sch_tue' /></th> <!-- 화 -->
							<th><spring:message code='Cache.lbl_sch_wed' /></th> <!-- 수 -->
							<th><spring:message code='Cache.lbl_sch_thu' /></th> <!-- 목 -->
							<th><spring:message code='Cache.lbl_sch_fri' /></th> <!-- 금 -->
							<th><span class="tx_sat"><spring:message code='Cache.lbl_sch_sat' /></span></th> <!-- 토-->
						</tr>
					</thead>
					<tbody id="calTbody">
					</tbody>
			  </table>
           </div>   	
			<div class="bottom">
				<a id="btnReq"	class="btnTypeDefault btnTypeChk"><%=AttendUtils.getRequestName(RedisDataUtil.getBaseConfig("WorkCreateMethod"))%></a> 	<!-- 신청하기 -->
				<a id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
			</div>
		</div>	
	</div>
</body>
<script>
$(document).ready(function(){
	AttendUtils.getScheduleMonth(CFN_GetLocalCurrentDate("yyyy-MM-dd"), "calendar", "dateTitle", "", "calTbody");
	getScheduleList();
	$("#divRepeat").hide();
	//event 세팅
	
	$(".WTemp_cal_wrap .pre").click(function(){
		AttendUtils.goScheduleNextPrev(-1, "calendar", "dateTitle", "", "calTbody");
	});
	$(".WTemp_cal_wrap .next").click(function(){
		AttendUtils.goScheduleNextPrev(1, "calendar", "dateTitle", "", "calTbody");
	});
	
	//반복
	$('#btnRepeat').click(function(){
		if(!validationChk(''))     	return ;
		$("#divRepeat").show();
	});
	
	//반복신청
	$('#btnReqRepeat').click(function(){
		if(!validationChk('R'))     	return ;
		Common.Confirm("<spring:message code='Cache.msg_RUSave' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				reqScheduleRepeat();
			}	
		});				
	});
	
	//신청
	$('#btnReq').click(function(){
		if(!validationChk('S'))     	return ;
		Common.Confirm("<spring:message code='Cache.msg_RUSave' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				reqSchedule();
			}	
		});
	});
	
	//닫기
	$('#btnClose').click(function(){
		Common.Close();
	});	
	
	//근무일 입력
	$("#SchName").keyup(function(e){
		if(e.keyCode == 13)  getScheduleList(); 
	});
	
	//모두
	$("#allFind").click(function(e){
		$("#SchName").val("");
		getScheduleList(); 
	});
	
	//사용자 지정 템플릿
	$("#btnTemp").click(function(e){
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_CustomWork'/>","/groupware/attendReq/AttendCustomSchedulePopup.do?parentId=AttendReqSchedulePopup","630px","750px","iframe",true,null,null,true);
		//getScheduleList();
	});
	
	//휴무일제외 토글
	$(".onOffBtn").click(function(e){
		$(this).toggleClass( "on" );
	});

	//신청 방식에 따른 화면 전환
	$("input[name='selectType']:radio").change(function() {
		var tmpValue = this.value;

		if(tmpValue == 0) {
			//화면
			$("#selectSchDiv").show();
			$("#directInputDiv").hide();

			$("#selectTypeTitle").text("<spring:message code='Cache.lbl_n_att_attendSch' />");
		} else {
			//화면
			$("#selectSchDiv").hide();
			$("#directInputDiv").show();

			$("#selectTypeTitle").text("<spring:message code='Cache.lbl_att_work' /> <spring:message code='Cache.lbl_Hours' />"); //근무 시간
		}
	});
});

$(document).on("click",".calDate",function(){
	var selectType = $("input[name='selectType']:checked").val();
	if(selectType == 0) {
		if ($("#selectSchedule").attr("data") == undefined || $("#selectSchedule").attr("data") == "") {
			Common.Warning("<spring:message code='Cache.lbl_n_att_worksch'/> <spring:message code='Cache.msg_Select'/>", "Warning Dialog", function () {
			});
			return false;
		}
	} else {
		/* 시작시간 종료시간*/
		var StartTime = $("#WorkStartHour").val() + '' + $("#WorkStartMin").val();
		var EndTime = $("#WorkEndHour").val() + '' + $("#WorkEndMin").val();

		if (StartTime != "0000" && EndTime != "0000" && StartTime >= EndTime && !$("#WorkNextDayYn").prop("checked")) {
			Common.Warning("<spring:message code='Cache.msg_Mobile_InvalidStartTime'/>");			//시작일은 종료일 보다 이후일 수 없습니다.
			return false;
		}
	}

	var dataStr = $(this).find("div p").attr("data-map");
	if (dataStr != undefined && dataStr != "") {
		if (!$(this).hasClass("selDate")) {
			var dataMap = JSON.parse(dataStr);
			if (dataMap["ConfmYn"] == "Y") {
				Common.Warning("<spring:message code='Cache.msg_apv_personnel_items_modify_refresh' />");
				return;
			}
		}
	}

	$(this).toggleClass("selDate");
	if ($(this).hasClass("selDate")){
		$(this).find("div p").attr("ori-text", $(this).find("div p").text());
		$(this).find("div p").attr("ori-data-map", dataStr);

		var saveData;
		var clickDate = $(this).attr("title");
		var week = ['WorkTimeSun', 'WorkTimeMon', 'WorkTimeTue', 'WorkTimeWed', 'WorkTimeThu', 'WorkTimeFri', 'WorkTimeSat'];
		var dayOfWeek = week[new Date(clickDate).getDay()];
		if(selectType == 0) {
			var selectDataMap = JSON.parse($("#selectSchedule").attr("data-map"));
			saveData = { "SchSeq":$("#selectSchedule").attr("data"), "WorkDate":$(this).attr("title"),"HolidayFlag":$("#HolidayFlag").is(":checked")?"Y":"N", "Mode":"T"};
			var choiceScheTime = selectDataMap[dayOfWeek];
			if(choiceScheTime.indexOf("~")>-1){
				choiceScheTime = choiceScheTime.replace("~", " ~ ");
			}
			//$(this).find("div p").text(selectDataMap["SchName"] + " " + AttendUtils.maskTime(selectDataMap["AttDayStartTime"]) + " ~ " + AttendUtils.maskTime(selectDataMap["AttDayEndTime"]));
			$(this).find("div p").html(selectDataMap["SchName"] + "<br/>" + choiceScheTime);
		} else  {
			saveData = { "SchSeq":"-1", "WorkDate":$(this).attr("title"),"HolidayFlag":$("#HolidayFlag").is(":checked")?"Y":"N", "Mode":"T", "StartTime":StartTime, "EndTime":EndTime, "NextDayYn": ($("#WorkNextDayYn").prop("checked") ? 'Y' : 'N')};
			$(this).find("div p").text(AttendUtils.maskTime(saveData["StartTime"]) + " ~ " + AttendUtils.maskTime(saveData["EndTime"]));
		}
		$(this).find("div p").attr("data-map", JSON.stringify(saveData));
	} else {
		var oriDataStr = $(this).find("div p").attr("ori-data-map");
		var oriText = $(this).find("div p").attr("ori-text");
		$(this).find("div p").text(oriText);
		$(this).find("div p").attr("data-map", oriDataStr);
		$(this).find("div p").removeAttr("ori-data-map");
		$(this).find("div p").removeAttr("ori-text");
	}
	
});

$(document).on("click","#scheduleInfo",function(){
	var dataMap = JSON.parse($(this).attr("data-map"));
	if (dataMap["SchSeq"] == null)
	{
		return;
	}
	$("#selectSchedule").text(dataMap["SchName"]);
	$("#selectSchedule").attr("data", dataMap["SchSeq"]);
	$("#selectSchedule").attr("data-map", JSON.stringify(dataMap));
	$("#divWork").hide();
});

function getScheduleList(){
	 $.ajax({
			type:"POST",
            url : "/groupware/attendReq/getScheduleList.do",
            data : {"SchName" : $("#SchName").val()},
            success : function(data){	
            	if(data.status=='SUCCESS'){
            		var strHtml="";
            		$.each(data.list, function(idx, obj){
        				//var dataMap = {"SchSeq": obj["SchSeq"], "SchName": obj["SchName"]};
						strHtml += "<li><a data-map='"+JSON.stringify(obj)+"' id='scheduleInfo'> "+obj.SchName;
						if(obj.AttDayStartTime!=null && obj.AttDayStartTime.length>0 && obj.AttDayEndTime!=null && obj.AttDayEndTime.length>0){
							strHtml += " ("+AttendUtils.maskTime(obj.AttDayStartTime) +" ~ "+AttendUtils.maskTime(obj.AttDayEndTime)+")";
						}
            			strHtml+="</a></li>";
            		});
            		$(".WTemp_Type_list").html(strHtml);
            	}
            },
            error:function(response, status, error){
                CFN_ErrorAjax("attendReq/requestJobStatus.do", response, status, error);
            }
        });
}

function reqScheduleRepeat(){
	var aJsonArray = new Array();
	var saveData;

	var selectType = $("input[name='selectType']:checked").val();

	if(selectType == 0) {
		saveData = { "SchSeq":$("#selectSchedule").attr("data"), "StartDate":$("#StartDate").val(), "EndDate":$("#EndDate").val(),"HolidayFlag":$("#HolidayFlag").is(":checked")?"Y":"N", "Mode":"R"};
	} else {
		var StartTime = $("#WorkStartHour").val() + '' + $("#WorkStartMin").val();
		var EndTime = $("#WorkEndHour").val() + '' + $("#WorkEndMin").val();

		saveData = { "SchSeq":"-1", "StartDate":$("#StartDate").val(), "EndDate":$("#EndDate").val(),"HolidayFlag":$("#HolidayFlag").is(":checked")?"Y":"N", "Mode":"R", "StartTime":StartTime, "EndTime":EndTime, "NextDayYn": ($("#WorkNextDayYn").prop("checked") ? 'Y' : 'N')};
	}

	aJsonArray.push(saveData);

	var saveJson ={
			"ReqType":"S",
			"ReqGubun":"C",
			"SelectType":selectType,
			"Comment":$("#Comment").val(),
			"ReqData":aJsonArray
	}
	//insert 호출		
	 $.ajax({
		type:"POST",
		contentType:"application/json; charset=utf-8",
		dataType   : "json",
        url : "/groupware/attendReq/requestScheduleRepeat.do",
        data : JSON.stringify(saveJson),
        success : function(data){	
        	if(data.status=='SUCCESS'){
            	Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>");
				Common.Close();
        	}else{
        		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
        	}
        },
        error:function(response, status, error){
            //TODO 추가 오류 처리
            CFN_ErrorAjax("attendReq/requestJobStatus.do", response, status, error);
        }
    });
}
function reqSchedule(){
	var aJsonArray = new Array();
	var saveData;

	var selectType = $("input[name='selectType']:checked").val();
	/*
	if(selectType == 0) {
		$(".selDate").each(function(idx, obj){
			saveData = { "SchSeq":$("#selectSchedule").attr("data"), "WorkDate":$(obj).attr("title"),"HolidayFlag":$("#HolidayFlag").is(":checked")?"Y":"N", "Mode":"T"};
			aJsonArray.push(saveData);
		});
	} else {
		var StartTime = $("#WorkStartHour").val() + '' + $("#WorkStartMin").val();
		var EndTime = $("#WorkEndHour").val() + '' + $("#WorkEndMin").val();

		$(".selDate").each(function(idx, obj){
			saveData = { "SchSeq":"-1", "WorkDate":$(obj).attr("title"),"HolidayFlag":$("#HolidayFlag").is(":checked")?"Y":"N", "Mode":"T", "StartTime":StartTime, "EndTime":EndTime, "NextDayYn": ($("#WorkNextDayYn").prop("checked") ? 'Y' : 'N')};
			aJsonArray.push(saveData);
		});
	}*/
	$(".selDate").each(function(idx, obj){
		saveData = JSON.parse($(obj).find("div p").attr("data-map"));
		aJsonArray.push(saveData);
	});

	var saveJson ={
			"ReqType":"S",
			"ReqGubun":"C",
			"SelectType":selectType,
			"Comment":$("#Comment").val(),
			"ReqData":aJsonArray
	}
	//insert 호출
	 $.ajax({
		type:"POST",
		contentType:"application/json; charset=utf-8",
		dataType   : "json",
		url : "/groupware/attendReq/requestSchedule.do",
		data : JSON.stringify(saveJson),
		success : function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>","Information",function(){ //저장되었습니다.
					Common.Close();
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
			}
		},
		error:function(response, status, error){
			//TODO 추가 오류 처리
			CFN_ErrorAjax("attendReq/requestJobStatus.do", response, status, error);
		}
	});

}
function validationChk(mode){
	var selectType = $("input[name='selectType']:checked").val();
	if(selectType == 0) {
		if ($("#selectSchedule").attr("data") == undefined || $("#selectSchedule").attr("data") == "") {
			Common.Warning("<spring:message code='Cache.lbl_n_att_worksch'/> <spring:message code='Cache.msg_Select'/>", "Warning Dialog", function () {
			});
			return false;
		}
	} else {
		/* 시작시간 종료시간*/
		var StartTime = $("#WorkStartHour").val() + '' + $("#WorkStartMin").val();
		var EndTime = $("#WorkEndHour").val() + '' + $("#WorkEndMin").val();

		if (StartTime != "0000" && EndTime != "0000" && StartTime >= EndTime && !$("#WorkNextDayYn").prop("checked")) {
			Common.Warning("<spring:message code='Cache.msg_Mobile_InvalidStartTime'/>");			//시작일은 종료일 보다 이후일 수 없습니다.
			return false;
		}
	}
	if (mode == "S"){	//스케쥴 생성
		if ($(".selDate").length == 0){
			 Common.Warning("<spring:message code='Cache.ACC_msg_selectDate'/>", "Warning Dialog", function () {     
	         });
	         return false;
		}	
	}
	
	if (mode == "R"){	//스케쥴 생성(반복)
		if ($("#StartDate").val() == ""|| $("#EndDate").val() == ""){
			 Common.Warning("<spring:message code='Cache.CPMail_TargetPeriodIsRequired'/>", "Warning Dialog", function () {     
	         });
	         return false;
		}
		if ($("#EndDate").val() < $("#StartDate").val() ){
			 Common.Warning("<spring:message code='Cache.CPMail_EndDateIsEarlierThanStartDate'/>", "Warning Dialog", function () {     
	         });
	         return false;
		}
	}

	return true;

}

</script>