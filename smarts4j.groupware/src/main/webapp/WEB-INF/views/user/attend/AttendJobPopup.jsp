<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<style>
		.org_list_box_attend{display:flex; flex-wrap:wrap; flex:1 1 auto; min-height:30px; height:auto !important; max-height: 186px; overflow:hidden auto; padding:1px 2px;}
		.org_list_box_attend input{width:100px !important; border:0px !important;}
	</style>
</head>

<body>
<div class="layer_divpop ui-draggable" id="AttendJobPopup_p" style="width: 100%">
<div class="divpop_contents" id="AttendJobPopup_container">
	<div class="pop_header" id="AttendJobPopup_ph">
		<h4 class="divpop_header ui-draggable-handle" id="AttendJobPopup_Title"><span class="divpop_header_ico"><spring:message code='Cache.MN_887' /></span></h4> <!-- 근무제 설정 -->
	</div>

<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="ATMgt_popup_wrap">
			<div class="ATMgt_work_wrap">
				<table class="ATMgt_popup_table type03" cellpadding="0" cellspacing="0">
					<colgroup>
						<col style="width: 125px;"/>
						<col style="width: calc(50% - 125px);"/>
						<col style="width: 125px;"/>
						<col style="width: calc(50% - 125px);;"/>
					</colgroup>
					<tbody>
					 <tr>
					 	<td class="ATMgt_T_th"><spring:message code='Cache.ObjectType_UR' /></span></td>
						<Td colspan=3>
						<div class="ATMgt_T">
							<div class="ATMgt_T_l">
							<div class="org_list_box_attend" id="resultViewDetailDiv">
								<input id="resultViewDetailInput" type="text" class="ui-autocomplete-input  HtmlCheckXSS ScriptCheckXSS"  autocomplete="off">
							</div>	
							</div>
							<div class="ATMgt_T_r">
								<a class="btnTypeDefault nonHover type01" onclick="openOrgMapLayerPopup('resultViewDetailDiv')"><spring:message code='Cache.btn_OrgManage' /></a>
							</div>	
						</div>	
						</Td>
					 </tr>
					 <tr>
						 <td class="ATMgt_T_th"><spring:message code='Cache.lbl_SettingMethod' /></td> <!-- 설정 방식 -->
						 <td colspan=3>
							 <input type="radio" id="selectType1" name="selectType" value="0" checked/>
							 <label for="selectType1"><spring:message code='Cache.lbl_n_att_attendSch' /> <spring:message code='Cache.lbl_Select' /></label> <!-- 근무제 선택 -->
							 <input type="radio" id="selectType2" name="selectType" value="1">
							 <label for="selectType2"><spring:message code='Cache.lbl_Mail_DirectInput' /></label> <!-- 직접입력 -->
						 </td>
					 </tr>
                     <tr>
                          <td  class="ATMgt_T_th" id="selectTypeTitle"><spring:message code='Cache.lbl_n_att_attendSch' /></td>
			              <td colspan=3>
			              	<div class="ATMgt_T">
								<div class="ATMgt_T_l"  id="selectSchDiv">
									<select class="selectType02" id="SchSeq" name="SchSeq">
										<option value="OFF"><spring:message code='Cache.lbl_att_sch_holiday' /></option>
										<c:forEach items="${list}" var="list" varStatus="status" >
											<option value="${list.SchSeq}" <c:if test="${status.index==0}">selected</c:if>>${list.SchName}</option>
										</c:forEach>
									</select>
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
								<div class="ATMgt_T_r"><a id="btnRepeat"  class="btnTypeDefault btnRepeat" href="#"><spring:message code='Cache.lbl_scope' /></a></div>
							</div>
							<!-- 반복 선택 레이어 팝업 시작 -->
							<div class="ATMgt_Work_Popup" id="divRepeat" style="width:282px; right:20px; z-index:105;display:none">
								<a class="Btn_Popup_close"  id="iconRepeatClose"></a>
								<div class="ATMgt_Cont">
								    <span id="divCalendar" class="dateSel type02">
										<input class="adDate" type="text" id="StartDate" date_separator="." readonly=""> - 
										<input id="EndDate" date_separator="." kind="twindate" date_startTargetID="StartDate" class="adDate" type="text" readonly="">
									</span>											
									<div class="bottom">
										<a href="#" class="btnTypeDefault btnTypeChk" id="btnReqRepeat"><spring:message code='Cache.lbl_att_approval' /></a>
										<a href="#" class="btnTypeDefault" id="btnRepeatClose" ><spring:message code='Cache.lbl_close' /></a>
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
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_workingWeek' /> <spring:message code='Cache.lbl_Use' /></td>
						<td><div class="alarm type01"><input id="WeekFlag" value="Y" type="checkbox" checked style="display:none">
							<label class="onOffBtn on" href="#" for="WeekFlag"><span></span></label></div>
						</td>
					 </tr>		
                  </tbody>
                </table>
                
             </div>   
			<div class="WTemp_cal_Top" id="myTabTtl">
				<div class="WTemp_cal_Tab" >
					<div class="WTab on" data="0">
						<a class="WTemp_cal_date"  id="dateTitle_0"></a>
						<div class="pagingType01">
							<a class="pre" href="#"></a>
							<a class="next" href="#"></a>
							<a class="close" href="#">X</a>
						</div>
					</div>
				</div>	
				<a class="addBtn" id="addTab" herf="#">+</a>
				<span class="allTime" id="workTotMonthTime"><spring:message code='Cache.lbl_total' /> <spring:message code='Cache.lbl_n_att_workingHours' /> <spring:message code='Cache.lbl_sum' /> : <strong>0h</strong></span> <!-- 총 근로시간 합계 -->
			</div>
			 <div id=myTabCont>
				<div class="WTemp_cal_wrap" data="0">
					<span id=workMonthTime style="display:none" data="0">0</span>
	    			<table class="WTemp_cal" id="calendar_0" cellpadding="0" cellspacing="0">
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
							<c:forEach begin="1" end="6">
							<tr>
								<td weekId="Sun" class="tx_sun"><p class="tx_day"></p><div><p></p></div></td>
								<td weekId="Mon"><p class="tx_day"></p><div><p></p></div></td>
								<td weekId="Tue"><p class="tx_day"></p><div><p></p></div></td>
								<td weekId="Wed"><p class="tx_day"></p><div><p></p></div></td>
								<td weekId="Thu"><p class="tx_day"></p><div><p></p></div></td>
								<td weekId="Fri"><p class="tx_day"></p><div><p></p></div></td>
								<td weekId="Sat" class="tx_sat"><p class="tx_day"></p><div><p></p></div></td>
							</tr>
							</c:forEach>
						</tbody>
				  </table>
				</div>
			</div>	
			<div class="bottom">
				<a id="btnCreate"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.lbl_Creation'/></a> 	<!-- 저장 -->
				<a id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
			</div>
		</div>	
	</div>
</div>	
</div>
</div>

</body>
<script>
var orgMapDivEl = $("<p/>", {'class' : 'date_del', attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'ui-icon ui-icon-close'}));
var orgCalTtlE1 = $(".WTab").html();
var orgCalContE1 = $(".WTemp_cal_wrap").html();
var schList = {};
<c:forEach items="${list}" var="list" varStatus="status" >
schList["${list.SchSeq}"]={
	<c:forEach items="${list}" var="entry" varStatus="status">
		<c:if test="${status.index>0}">,</c:if>"${entry.key}": "${entry.value}"
	</c:forEach>};
</c:forEach>

// 직접 입력시 휴게시간 계산
var overTime;
var rewardTime;

// 자동완성 옵션
var MultiAutoInfos = {
	labelKey : 'DisplayName',
	valueKey : 'UserCode',
	minLength : 1,
	useEnter : false,
	multiselect : true,
	select : function(event, ui) {
		var id = $(document.activeElement).attr('id');
		var item = ui.item;
		var type = "UR" ;
		
		if ($('#' + id.replace("Input","Div")).find(".date_del[type='"+ type+"'][code='"+ item.UserCode+"']").length > 0) {
			Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
			ui.item.value = '';
			return;
		}
		
		var cloned = orgMapDivEl.clone();
		cloned.attr('type', type).attr('code', item.UserCode);
		cloned.find('.ui-icon-close').before(item.label);

		$('#' + id).before(cloned);
		
    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
	}		
};

$(document).on("click",".WTemp_cal_date",function(){
	
	$("#myTabCont .WTemp_cal_wrap").hide();
	$("#myTabTtl .WTab").removeClass("on");
	$(this).parent().addClass("on");
	var j = $("#myTabTtl .WTab").index($(this).parent()); 
	
	$("#myTabCont .WTemp_cal_wrap:eq("+j+")").show();
	
	$("#workTotMonthTime strong").text($("#myTabCont .WTemp_cal_wrap:eq("+j+") #workMonthTime").text());
});

$(document).on("click",".pre",function(){
	var data = $(this).parent().parent().attr("data")
	AttendUtils.goScheduleNextPrev(-1, "calendar_"+data, "dateTitle_"+data, "ONLY", "calTbody");
});
$(document).on("click",".next",function(){
	var data = $(this).parent().parent().attr("data")
	AttendUtils.goScheduleNextPrev(1, "calendar_"+data, "dateTitle_"+data, "ONLY", "calTbody");
});

$(document).on("click",".close",function(){
	event.stopPropagation();
	
	if ($("#myTabTtl .WTab").size() > 1 ){
		
		var j = $("#myTabTtl .WTab").index($(this).parent().parent());
		var bOn = $("#myTabTtl .WTab:eq("+j+")").hasClass("on");
			
		$("#myTabTtl .WTab:eq("+j+")").remove();
		$("#myTabCont .WTemp_cal_wrap:eq("+j+")").remove();
		
		if (bOn){
			$("#myTabTtl .WTab:eq(0)").addClass("on");
			$("#myTabCont .WTemp_cal_wrap:eq(0)").show();
		}
	}	
});

//var mycalendar = new AXCalendar();
$(document).ready(function(){
	coviCtrl.setCustomAjaxAutoTags('resultViewDetailInput', '/groupware/attendCommon/getAttendUserGroupAutoTagList.do', MultiAutoInfos);	// 근태대상
	AttendUtils.getScheduleMonth( CFN_GetLocalCurrentDate("yyyy-MM-dd"), "calendar_0", "dateTitle_0", "ONLY", "calTbody");
	$(".ui-autocomplete-multiselect.ui-state-default.ui-widget").removeAttr('style');

	var tabIdx=0;
	$("#addTab").click(function(){
		if ($("#myTabCont .WTemp_cal_wrap").length > 2){
			Common.Warning("<spring:message code='Cache.lbl_canNotAdd'/>");
			return;
		}
		var data = $("#myTabTtl .on").attr("data");

		$("#myTabCont .WTemp_cal_wrap").hide();
		$("#myTabTtl .WTab").removeClass("on");
		
		tabIdx++;
		$("#myTabTtl .WTemp_cal_Tab").append("<div class='WTab on' data='"+tabIdx+"'>"+orgCalTtlE1.replace("_0","_"+tabIdx)+"</div>");
		$("#myTabCont").append("<div class='WTemp_cal_wrap' data='"+tabIdx+"'>"+orgCalContE1.replace("_0","_"+tabIdx)+"</div>");
		$("#myTabTtl .WTab[data="+tabIdx+"]").find("#dateTitle_"+tabIdx).text($("#dateTitle_"+data).text());
		AttendUtils.goScheduleNextPrev(1, "calendar_"+tabIdx, "dateTitle_"+tabIdx, "ONLY", "calTbody");
	});

	
	$("#divRepeat").hide();
	$('#resultViewDetailInput').parent().css('width', '100%');
	//event 세팅
	$('#btnCreate').click(function(){
		if(!validationChk('S'))     	return ;
		Common.Confirm("<spring:message code='Cache.msg_AreYouCreateQ' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				createScheduleJobDiv();
			}	
		});				
	});
	
	$('#btnClose').click(function(){
		Common.Close();
	});	
	
	//event 세팅
	$('#btnReqRepeat').click(function(){
		if(!validationChk('R'))     	return ;
		Common.Confirm("<spring:message code='Cache.msg_AreYouCreateQ' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				createScheduleJob();
			}	
		});				
	});

	$("#btnRepeat").click(function(){
		if($('#WeekFlag').is(":checked") == false){
			Common.Warning("<spring:message code='Cache.msg_not_create' />");	//소정근로 미사용시 기간별 근무일정은 생성할 수 없습니다.
			return;
		}
		
		$("#divRepeat").show();
	});	
	
	$("#btnRepeatClose,#iconRepeatClose").click(function(){
		$("#divRepeat").hide();
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

			$("#selectTypeTitle").text("<spring:message code='Cache.lbl_att_workTime' />"); //근무 시간
		}
	});

	$.ajax({
		type:"GET",
		async: false,
		url:"/groupware/attendCommon/getRewardTimeInfo.do",
		success : function (data) {
			if(data.status == "SUCCESS"){
				overTime = data.timeInfo.OverTime;
				rewardTime = data.timeInfo.RewardTime;
			}
			else{
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
			}
		},
		error:function (request,status,error){
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		}
	});
});


$(document).on("click",".calDate",function(){
	$(this).toggleClass("selDate");
	if ($(this).hasClass("selDate")){
		if ($("#SchSeq").val() == "OFF"){//휴무설정
			var dataMap = {"WorkSts": "OFF"};
			$(this).find("div p").text("휴무");
			$(this).find("div p").attr("data-map",JSON.stringify(dataMap) );//Holiday
			$(this).addClass("Holiday");
		}
		else{
			var selectType = $("input[name='selectType']:checked").val();
			var weekId = $(this).attr("weekId");
			var dataMap;
			if(selectType == 0) {
				var schSeq = $("#SchSeq").val();
				dataMap = schList[schSeq];
			} else {
				var StartTime = $("#WorkStartHour").val() + $("#WorkStartMin").val();
				var EndTime = $("#WorkEndHour").val() + $("#WorkEndMin").val();

				var StartTimeStr = $("#WorkStartHour").val() + ":" + $("#WorkStartMin").val();
				var EndTimeStr = $("#WorkEndHour").val() + ":" +$ ("#WorkEndMin").val();

				var WorkTimeStr = StartTimeStr + "~" + EndTimeStr;

				var NextDayYn = ($("#WorkNextDayYn").prop("checked") ? 'Y' : 'N');

				dataMap = {
					"SchSeq": "-1"
					, "SchName": "<spring:message code='Cache.CPMail_DirectInput' />" //직접입력
					, "StartTime": StartTime
					, "EndTime": EndTime
					, ["WorkTime" + weekId]: WorkTimeStr
					, ["AcTime" + weekId]: AttendUtils.getAcTimeToMin(StartTimeStr, EndTimeStr, NextDayYn, overTime, rewardTime)
					, "NextDayYn": NextDayYn
				};
			}
			dataMap["WorkSts"] = "ON";

			$(this).find("div p").text(dataMap["SchName"] + "(" + dataMap["WorkTime" + weekId] + ")");
			$(this).find("div p").attr("data-map", JSON.stringify(dataMap));

			var obj = $(this).parents(".WTemp_cal_wrap").find("#workMonthTime");
			var workTime = obj.attr("data");
			if (workTime == "") workTime = 0;
			else workTime =  parseInt(workTime, 10);
			workTime += parseInt(dataMap["AcTime"+weekId],10);
			obj.attr("data", workTime);
			obj.text(AttendUtils.convertSecToStr(workTime,"H"));
			$("#workTotMonthTime strong").text(AttendUtils.convertSecToStr(workTime,"H"));
		}	
	}
	else{
		$(this).removeClass("Holiday");
		var dataStr = $(this).find("div p").attr("data-map");
		if (dataStr != undefined && dataStr != "") {
			var weekId = $(this).attr("weekId");
			dataMap = JSON.parse(dataStr);
			if (dataMap["WorkSts"] == "ON"){
				var obj = $(this).parents(".WTemp_cal_wrap").find("#workMonthTime");
				var workTime = obj.attr("data");
				if (workTime == "") workTime =0;
				else workTime =  parseInt(workTime, 10);
				workTime -= parseInt(dataMap["AcTime"+weekId],10);
				obj.attr("data", workTime);
				obj.text(AttendUtils.convertSecToStr(workTime,"H"));
				$("#workTotMonthTime strong").text(AttendUtils.convertSecToStr(workTime,"H"));
			}	
		}
		$(this).find("div p").text("");
    	$(this).find("div p").attr("data-map", "");
	}

});

function validationChk(mode){
	if($('#resultViewDetailDiv').find('.date_del').length == 0){
		Common.Warning("<spring:message code='Cache.msg_apv_271'/>");
		return;
	}

	if (mode == "S"){	//개별생성
		if ($(".selDate").length == 0){
			Common.Warning("<spring:message code='Cache.msg_apv_dateInput'/>");
	        return false;
		}
	
		for (var i=0; i < $(".WTab").length; i++){
			for (var j=0; j < $(".WTab").length; j++){
				if (i!=j){
					if ($(".WTab:eq("+i+") .WTemp_cal_date").text() == $(".WTab:eq("+j+") .WTemp_cal_date").text())
					{
						Common.Warning("<spring:message code='Cache.lbl_monthDup'/>");
				        return false;
					}
				}
			}
		}
	
	}
	else	{	//스케쥴 생성(반복)
		if ($("#StartDate").val() == ""|| $("#EndDate").val() == ""){
			 Common.Warning("<spring:message code='Cache.CPMail_TargetPeriodIsRequired'/>", "Warning Dialog", function () {     
	         });
	         return false;
		}
		if ($("#EndDate").val() <= $("#StartDate").val() ){
			 Common.Warning("<spring:message code='Cache.CPMail_EndDateIsEarlierThanStartDate'/>", "Warning Dialog", function () {     
	         });
	         return false;
		}
	}

	return true;

}


function createScheduleJob(){
	var targetArr = new Array();
	$('#resultViewDetailDiv').find('.date_del').each(function (i, v) {
		var item = $(v);
		var saveData = { "Type":item.attr('type'), "Code":item.attr('code')};
		targetArr.push(saveData);
	});

	var selectType = $("input[name='selectType']:checked").val();
	var paramMap;
	if(selectType == 0) {
		paramMap = {
			"dataList" : targetArr
			, "SchSeq": $("#SchSeq").val()
			, "StartDate": $("#StartDate").val()
			, "EndDate": $("#EndDate").val()
			, "HolidayFlag":$("#HolidayFlag").is(":checked")?"Y":"N"
		}
	} else {
		var StartTime = $("#WorkStartHour").val() + $("#WorkStartMin").val();
		var EndTime = $("#WorkEndHour").val() + $("#WorkEndMin").val();
		var NextDayYn = ($("#WorkNextDayYn").prop("checked") ? 'Y' : 'N');

		paramMap = {
			"dataList" : targetArr
			, "SchSeq": "-1"
			, "StartDate": $("#StartDate").val()
			, "EndDate": $("#EndDate").val()
			, "HolidayFlag":$("#HolidayFlag").is(":checked")?"Y":"N"
			, "StartTime": StartTime
			, "EndTime": EndTime
			, "NextDayYn": NextDayYn
		}
	}
	
	$.ajax({
		type:"POST",
		contentType:'application/json; charset=utf-8',
		dataType   : 'json',
		data:JSON.stringify(paramMap),
		url:"/groupware/attendJob/createAttendScheduleJob.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_apv_136'/>");	//복사되었습니다.
				opener.searchData();
				Common.Close();
			}
			else{
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
			}
		},
		error:function (request,status,error){
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		}
	});
}

function createScheduleJobDiv(){
	var targetArr = new Array();
	var targetData = new Array();
	//var targetData = new Array();
	$('#resultViewDetailDiv').find('.date_del').each(function (i, v) {
		var item = $(v);
		var saveData = { "Type":item.attr('type'), "Code":item.attr('code')};
		targetArr.push(saveData);
	});

	
	if ($(".selDate").length == 0){
		Common.Warning("<spring:message code='Cache.msg_apv_dateInput'/>");
        return false;
	}

	$(".selDate").each(function(idx, obj){
		var dataStr= $(obj).find("div p").attr("data-map");
		var dataMap = JSON.parse(dataStr);
		if (dataStr == undefined || dataStr == "") {
			Common.Warning("<spring:message code='Cache.mag_Attendance26' />");			//근무가 설정되어 있지 않습니다.
			return false;
		}
		else{
			var saveData;
			if(dataMap["SchSeq"] != null && dataMap["SchSeq"] == "-1") {
				saveData = {
					"TargetDate": $(obj).attr("title")
					, "WorkSts": dataMap["WorkSts"]
					, "SchSeq": dataMap["SchSeq"]
					, "StartTime": dataMap["StartTime"]
					, "EndTime": dataMap["EndTime"]
					, "NextDayYn": dataMap["NextDayYn"]
				};
			} else {
				saveData = {
					"TargetDate": $(obj).attr("title")
					, "WorkSts": dataMap["WorkSts"]
					, "SchSeq": (dataMap["WorkSts"] == "ON" ? dataMap["SchSeq"] : "")
				};
			}
			targetData.push(saveData);
		}     
	});

	$.ajax({
		type:"POST",
		contentType:'application/json; charset=utf-8',
		dataType   : 'json',
		data:JSON.stringify({"trgUsers" : targetArr  
			, "trgLists": targetData
//			, "SchSeq": $("#SchSeq").val() 
			, "StartDate": $("#StartDate").val()
			, "EndDate": $("#EndDate").val()
			, "HolidayFlag":$("#HolidayFlag").is(":checked")?"Y":"N"
			, "WeekFlag":$("#WeekFlag").is(":checked")?"Y":"N"
			}),
		url:"/groupware/attendJob/createAttendScheduleJobDiv.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_apv_136'/>");	//복사되었습니다.
				opener.searchData();
				Common.Close();
			}
			else{
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
			}
		},
		error:function (request,status,error){
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		}
	});
}
// 조직도 팝업
function openOrgMapLayerPopup(reqTar) {

	AttendUtils.openOrgChart("${authType}", "orgMapLayerPopupCallBack");
/*	url = "/groupware/attendCommon/AttendOrgChart.do?callBackFunc=orgMapLayerPopupCallBack&type=B9&treeKind=Group&groupDivision=Basic&drawOpt=_MARB";			
	title = "<spring:message code='Cache.lbl_att_specifier_add'/>"; // 근무상태
	var w = "1000";
	var h = "580";
	CFN_OpenWindow(url,"openGroupLayerPop",760,580,"");*/
}

// 조직도 팝업 콜백
function orgMapLayerPopupCallBack(orgData) {
	var data = $.parseJSON(orgData);
	var item = data.item
	var len = item.length;
	
	if (item != '') {
		var reqOrgMapTarDiv = 'resultViewDetailDiv' ;
		var duplication = false; // 중복 여부
		$.each(item, function (i, v) {
			var cloned = orgMapDivEl.clone();
			var type = (v.itemType == 'user') ? 'UR' : 'GR';
			var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;
			
			if ($('#' + reqOrgMapTarDiv).find(".date_del[type='"+ type+"'][code='"+ code+"']").length > 0) {
				duplication = true;
				return true;;
			}
			
			cloned.attr('type', type).attr('code', code);
			cloned.find('.ui-icon-close').before(CFN_GetDicInfo(v.DN));

			$('#' + reqOrgMapTarDiv + ' .ui-autocomplete-input').before(cloned);
		});
		
		if(duplication){
			Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
		}
			
	}
}
//사용자나 부서/ 일자 삭제
$(document).on('click', '.ui-icon-close', function(e) {
	e.preventDefault();
	$(this).parent().remove();
});

</script>