<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
	<%=(RedisDataUtil.getBaseConfig("AssYn").equals("Y")?"":".divAss {display:none !important}")%>
	<%=(RedisDataUtil.getBaseConfig("OutsideYn").equals("Y")?"":".divOutside {display:none !important}")%>
	.selDate {background-color:#6d6e71;color:#fff!important}
	.setDate {background-color: #f5e3d9;}
</style>
</head>
<body>
<c:set var="week" value="${fn:split('Sun,Mon,Tue,Wed,Thu,Fri,Sat',',')}" />
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="ATMgt_popup_wrap">
			<h2 class="ATMgt_popup_title"><spring:message code='Cache.lbl_AddCustomTemplate'/></h2> <!-- 사용자 지정 템플릿 추가 -->
			<div class="ATMgt_popup_cont active" id="tab-1">
				<table class="ATMgt_popup_table type02" style="width:100%">
					<tbody>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_work'/> <spring:message code='Cache.lbl_type'/></td> <!-- 근무 유형 -->
						<td>
							<input type="radio" id="WorkingSystemType1" name="WorkingSystemType" value="0" checked/>
							<label for="WorkingSystemType1"><spring:message code='Cache.btn_Designated'/><spring:message code='Cache.lbl_Hours'/></label> <!-- 지정시간 -->
							<input type="radio" id="WorkingSystemType2" name="WorkingSystemType" value="1" />
							<label for="WorkingSystemType2"><spring:message code='Cache.lbl_Autonomous'/></label> <!-- 자율 -->
							<input type="radio" id="WorkingSystemType3" name="WorkingSystemType" value="2" />
							<label for="WorkingSystemType3"><spring:message code='Cache.lbl_Select'/>(<spring:message code='Cache.CPMail_Part'/>, <spring:message code='Cache.lbl_Totally'/>)</label> <!-- 선택(부분, 완전) -->
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_templateName'/></td>
						<td><input type="text" placeholder="<spring:message code='Cache.lbl_EnterTemplateName'/>" id="SchName" name="SchName" class="WorkingStatusAdd_title_input w100" value=""></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_coreTime'/></td> <!-- 코어타임 -->
						<td>
							<div class="ATMgt_T_Time">
                                <span class="alarm type01"><input id="CoreTimeYn" value="Y" type="checkbox" style="display:none">
                                <label class="onOffBtn" href="#" for="CoreTimeYn"><span></span></label></span>
								<select name="CoreStartTimeHour">
									<c:forEach begin="00" end="23" var="hour">
										<option value="${ hour < 10 ? '0' : '' }${hour}">${ hour < 10 ? '0' : '' }${hour}</option>
									</c:forEach>
								</select>
								<select name="CoreStartTimeMin">
									<c:forEach begin="00" end="59" var="min">
										<option value="${ min < 10 ? '0' : '' }${min}">${ min < 10 ? '0' : '' }${min}</option>
									</c:forEach>
								</select>
								~
								<select name="CoreEndTimeHour">
									<c:forEach begin="00" end="23" var="hour">
										<option value="${ hour < 10 ? '0' : '' }${hour}">${ hour < 10 ? '0' : '' }${hour}</option>
									</c:forEach>
								</select>
								<select name="CoreEndTimeMin">
									<c:forEach begin="00" end="59" var="min">
										<option value="${ min < 10 ? '0' : '' }${min}">${ min < 10 ? '0' : '' }${min}</option>
									</c:forEach>
								</select>
							</div>
						</td>
					</tr>
					<tr id="WorkTimeTr" style="display: none;">
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Time'/></td>
						<td>
							<div class="ATMgt_T ATMgt_T_wd">
								<div class="ATMgt_T_l">
									<div class="ATMgt_T_Time">
										<select id="WeekStartHour" name="WeekStartHour">
											<c:forEach begin="00" end="23" var="hour">
												<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"><c:out value="${ hour < 10 ? '0' : '' }${hour}"/></option>
											</c:forEach>
										</select>
										<span>:</span>
										<input type="text" name="WeekStartMin" id="WeekStartMin" maxlength="2" value="00"/>
										<span>-</span>
										<select id="WeekEndHour" name="WeekEndHour">
											<c:forEach begin="00" end="23" var="hour">
												<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"><c:out value="${ hour < 10 ? '0' : '' }${hour}"/></option>
											</c:forEach>
										</select>
										<span>:</span>
										<input type="text" name="WeekEndMin" id="WeekEndMin" maxlength="2" value="00"/>
										<input type="checkbox" id="WeekNextDayYn" name="WeekNextDayYn" value="Y"/>
										<label for="WeekNextDayYn"><spring:message code='Cache.lbl_NextDay'/></label>
									</div>
								</div>
								<div class="ATMgt_T_r">
									<input type="checkbox" id="WeekSet" name="WeekSet" value="Y"><a href="#" class="btnTypeDefault cal" id="btnCal"><spring:message code='Cache.lbl_SetTimeWeek'/></a> <!-- 요일별 시간 설정 -->
								</div>
							</div>
						</td>
					</tr>
					<tr id="GoWorkTimeTr" style="display: none;">
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_CanWorkTime'/></td> <!-- 출근가능시간 -->
						<td>
							<div class="ATMgt_T_Time">
                                <span class="alarm type01"><input id="GoWorkTimeYn" value="Y" type="checkbox" style="display:none">
                                <label class="onOffBtn" href="#" for="GoWorkTimeYn"><span></span></label></span>
								<select name="GoWorkStartTimeHour">
									<c:forEach begin="00" end="23" var="hour">
										<option value="${ hour < 10 ? '0' : '' }${hour}">${ hour < 10 ? '0' : '' }${hour}</option>
									</c:forEach>
								</select>
								<select name="GoWorkStartTimeMin">
									<c:forEach begin="00" end="59" var="min">
										<option value="${ min < 10 ? '0' : '' }${min}">${ min < 10 ? '0' : '' }${min}</option>
									</c:forEach>
								</select>
								~
								<select name="GoWorkEndTimeHour">
									<c:forEach begin="00" end="23" var="hour">
										<option value="${ hour < 10 ? '0' : '' }${hour}">${ hour < 10 ? '0' : '' }${hour}</option>
									</c:forEach>
								</select>
								<select name="GoWorkEndTimeMin">
									<c:forEach begin="00" end="59" var="min">
										<option value="${ min < 10 ? '0' : '' }${min}">${ min < 10 ? '0' : '' }${min}</option>
									</c:forEach>
								</select>
							</div>
						</td>
					</tr>
					<tr id="OffWorkTimeTr" style="display: none;">
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_GoHomeTime'/></td> <!-- 퇴근가능시간 -->
						<td>
							<div class="ATMgt_T_Time">
                                <span class="alarm type01"><input id="OffWorkTimeYn" value="Y" type="checkbox" style="display:none">
                                <label class="onOffBtn" href="#" for="OffWorkTimeYn"><span></span></label></span>
								<select name="OffWorkStartTimeHour">
									<c:forEach begin="00" end="23" var="hour">
										<option value="${ hour < 10 ? '0' : '' }${hour}">${ hour < 10 ? '0' : '' }${hour}</option>
									</c:forEach>
								</select>
								<select name="OffWorkStartTimeMin">
									<c:forEach begin="00" end="59" var="min">
										<option value="${ min < 10 ? '0' : '' }${min}">${ min < 10 ? '0' : '' }${min}</option>
									</c:forEach>
								</select>
								~
								<select name="OffWorkEndTimeHour">
									<c:forEach begin="00" end="23" var="hour">
										<option value="${ hour < 10 ? '0' : '' }${hour}">${ hour < 10 ? '0' : '' }${hour}</option>
									</c:forEach>
								</select>
								<select name="OffWorkEndTimeMin">
									<c:forEach begin="00" end="59" var="min">
										<option value="${ min < 10 ? '0' : '' }${min}">${ min < 10 ? '0' : '' }${min}</option>
									</c:forEach>
								</select>
							</div>
						</td>
					</tr>
					<tr id="AssTr" class="divAss" style="display: none;">
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Assum'/></td>
						<td>
							<div class="ATMgt_T_Time">
                                <span class="alarm type01"><input id="AssYn" value="Y" type="checkbox" style="display:none">
                                    <label class="onOffBtn" href="#" for="AssYn"><span></span></label>
                                </span>
								<select id="AssSeq" name="AssSeq">
									<c:forEach items="${assList}" var="list" varStatus="status">
										<option value="${list.AssSeq}">${list.AssName}</option>
									</c:forEach>
								</select>
							</div>
						</td>
					</tr>
					<tr id="SelfCommTr" style="display: none;">
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_AutoCmmutSystem'/></td> <!-- 자율출퇴근제 -->
						<td>
							<div class="ATMgt_T ATMgt_T_wd">
								<div class="ATMgt_T_l">
									<div class="ATMgt_T_Time">
										<input id="SelfCommYn" type="hidden" value="N" />
										<span><spring:message code='Cache.lbl_att_ac_time'/> : </span><input type="text" name="AttDayAC" id="AttDayAC" style="width:65px" value=""><span><spring:message code='Cache.lbl_Minutes'/></span> <!-- 인정시간 : 분 -->
										<span><spring:message code='Cache.lbl_n_att_resttime'/> : </span><input type="text" name="AttDayIdle" id="AttDayIdle" style="width:65px" value=""><span><spring:message code='Cache.lbl_Minutes'/></span> <!-- 휴게시간 : 분 -->
									</div>
								</div>
								<div class="ATMgt_T_r">
									<input type="checkbox" id="SelfCommWeekSet" name="SelfCommWeekSet" value="Y"><a href="#" class="btnTypeDefault cal" id="btnSelfCommCal"><spring:message code='Cache.lbl_SetTimeWeek'/></a> <!-- 요일별 시간 설정 -->
								</div>
							</div>
						</td>
					</tr>
					<tr id="AutoExtenTr" style="display: none;">
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_AutomaticOvertime'/></td> <!-- 자동연장근무 -->
						<td>
							<div class="ATMgt_T_Time">
							<span class="alarm type01"><input id="AutoExtenYn" value="Y" type="checkbox" style="display:none">
							<label class="onOffBtn" href="#" for="AutoExtenYn"><span></span></label></span>
								<span>최소 인정시간 : </span>
								<select name="AutoExtenMinTime">
									<option value="0"><spring:message code='Cache.lbl_Minutes'/></option> <!-- 분 -->
									<option value="10"><spring:message code='Cache.lbl_AlramTime_10'/></option> <!-- 10분전 -->
									<option value="15"><spring:message code='Cache.lbl_AlramTime_15'/></option> <!-- 15분전 -->
									<option value="30"><spring:message code='Cache.lbl_AlramTime_30'/></option> <!-- 30분전 -->
									<option value="60"><spring:message code='Cache.RepeatTerm_60'/></option> <!-- 60분 -->
									
									
								</select>
								<span><spring:message code='Cache.lbl_Mail_Maximum'/> <spring:message code='Cache.lbl_att_ac_time'/> : </span> <!-- 최대 인정시간 -->
								<select name="AutoExtenMaxTime"></select>
							</div>
						</td>
					</tr>
				</table>
				<div class="ATMgt_memo_wrap">
					<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
						<tbody>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Memo'/></td>
							<td><textarea maxlength="255" rows="5" id="Memo" name="Memo" class="ATMgt_Tarea av-required w100"></textarea></td>
						</tr>
						</tbody>
					</table>
				</div>
				<div class="ATMgt_map_wrap divOutside">
					<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
						<tbody>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_WorkingArea'/></td> <!-- 근무지 -->
							<td>
								<div class="searchBox03">
									<span>
										<input type="text" name="WorkZone" class="w100" id="WorkZone" value=""/>
										<button class="btnSearchType01" id="btnMap" type="button"></button>
									</span>
								</div>
								<input type="text" name="WorkAddr" class="w100 mt5" id="WorkAddr" value=""/>
								<input type="hidden" name="WorkPointX" id="WorkPointX" value=""/>
								<input type="hidden" name="WorkPointY" id="WorkPointY" value=""/>
							</td>
						</tr>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_CoordinateRadius'/>(m)</td> <!-- 좌표반경 -->
							<td><input type="text" class="w100" name="AllowRadius" id="AllowRadius" value=""></td>
						</tr>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_AttendanceArea'/> <spring:message code='Cache.btn_Add'/></td> <!-- 출근지 추가 -->
							<td>
								<select name="GoWorkPlace">
								</select>
								<a class="btn_Ok" onclick="addWorkPlace('GoWorkPlace');"><spring:message code='Cache.btn_Add'/></a> <!-- 추가 -->
								<div id="GoWorkPlaceSelected" style="width:100%">
									<c:forEach items="${goWorkPlaceList}" var="list" varStatus="status">
										<div class="ui-autocomplete-multiselect-item" style="margin:1px;background:skyblue;float:left;" data-value="${list.LocationSeq}" id="GoWorkPlace${list.LocationSeq}">${list.WorkZone}<span class="ui-icon ui-icon-close" onclick="removeWorkPlace('GoWorkPlace', '${list.LocationSeq}', '${list.WorkZone}')"></span></div>
									</c:forEach>
								</div>
							</td>
						</tr>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_LeaveWorkArea'/> <spring:message code='Cache.btn_Add'/></td> <!-- 퇴근지 추가 -->
							<td>
								<select name="OffWorkPlace">
								</select>
								<a class="btn_Ok" onclick="addWorkPlace('OffWorkPlace');"><spring:message code='Cache.btn_Add'/></a> <!-- 추가 -->
								<div id="OffWorkPlaceSelected" style="width:100%">
									<c:forEach items="${offWorkPlaceList}" var="list" varStatus="status">
										<div class="ui-autocomplete-multiselect-item" style="margin:1px;background:skyblue;float:left;" data-value="${list.LocationSeq}" id="OffWorkPlace${list.LocationSeq}">${list.WorkZone}<span class="ui-icon ui-icon-close" onclick="removeWorkPlace('OffWorkPlace', '${list.LocationSeq}', '${list.WorkZone}')"></span></div>
									</c:forEach>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
				</div>

				<div class="ATMgt_Work_Popup" id="divWeek" style="width:500px; right:40px; z-index:105;display:none; top:52px">
					<a id="icoDivClose" class="Btn_Popup_close"></a>
					<table class="ATMgt_DayTime_T" cellpadding="0" cellspacing="0">
						<thead>
						<tr>
							<th width="80"><spring:message code='Cache.lbl_ADay'/></th> <!-- 요일 -->
							<th><spring:message code='Cache.lbl_Start'/>/<spring:message code='Cache.lbl_Exit'/></th> <!-- 시작/종료 -->
							<th width="60"><label for="NextDayYn"><spring:message code='Cache.lbl_NextDay'/></label>
							</th>
						</tr>
						</thead>
						<tbody>
						<c:forEach items="${week}" var="list" varStatus="status">
							<c:set var="StartHour" value="Start${list}Hour"/>
							<c:set var="StartMin" value="Start${list}Min"/>
							<c:set var="EndHour" value="End${list}Hour"/>
							<c:set var="EndMin" value="End${list}Min"/>
							<c:set var="NextDayYn" value="NextDayYn${list}"/>
							<tr>
								<td>
									<c:choose>
										<c:when test="${list eq 'Sun' }"><span class="tx_sun"><spring:message code='Cache.lbl_sch_${fn:toLowerCase(list)}'/></span></c:when>
										<c:when test="${list eq 'Sat' }"><span class="tx_sat"><spring:message code='Cache.lbl_sch_${fn:toLowerCase(list)}'/></span></c:when>
										<c:otherwise><spring:message code='Cache.lbl_sch_${fn:toLowerCase(list)}'/></c:otherwise>
									</c:choose>
								</td>
								<td>
									<div class="ATMgt_T_Time">
										<select id="${StartHour}" name="${StartHour}">
											<c:forEach begin="00" end="23" var="hour">
												<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"><c:out value="${ hour < 10 ? '0' : '' }${hour}"/></option>
											</c:forEach>
										</select>
										<span>:</span>
										<input type="text" name="${StartMin}" id="${StartMin}" maxlength="2" value="00"/>
										<span>-</span>
										<select id="${EndHour}" name="${EndHour}">
											<c:forEach begin="00" end="23" var="hour">
												<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"><c:out value="${ hour < 10 ? '0' : '' }${hour}"/></option>
											</c:forEach>
										</select>
										<span>:</span>
										<input type="text" name="${EndMin}" id="${EndMin}" maxlength="2" value="00"/>
									</div>
								</td>
								<td>
									<input type="checkbox" id="${NextDayYn}" name="${NextDayYn}" value="Y" />
								</td>
							</tr>
						</c:forEach>
						</tbody>
					</table>
					<div class="bottom">
						<a href="#" class="btnTypeDefault btnTypeChk" id="btnAdd"><spring:message code='Cache.btn_Add'/></a> <!-- 추가 -->
						<a href="#" class="btnTypeDefault" id="btnDivClose"><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
					</div>
				</div>

				<div class="ATMgt_Work_Popup" id="divSelfCommWeek" style="width:500px; right:40px; z-index:105;display:none; top:52px">
					<a id="icoSelfCommDivClose" class="Btn_Popup_close"></a>
					<table class="ATMgt_DayTime_T" cellpadding="0" cellspacing="0">
						<thead>
						<tr>
							<th width="80"><spring:message code='Cache.lbl_ADay'/></th> <!-- 요일 -->
							<th><spring:message code='Cache.lbl_att_sch_rec'/>/<spring:message code='Cache.lbl_n_att_resttime'/></th> <!-- 인정/휴게 시간 -->
						</tr>
						</thead>
						<tbody>
						<c:forEach items="${week}" var="list" varStatus="status">
							<c:set var="Ac" value="Ac${list}"/>
							<c:set var="Idle" value="Idle${list}"/>
							<tr>
								<td>
									<c:choose>
										<c:when test="${list eq 'Sun' }"><span class="tx_sun"><spring:message code='Cache.lbl_sch_${fn:toLowerCase(list)}'/></span></c:when>
										<c:when test="${list eq 'Sat' }"><span class="tx_sat"><spring:message code='Cache.lbl_sch_${fn:toLowerCase(list)}'/></span></c:when>
										<c:otherwise><spring:message code='Cache.lbl_sch_${fn:toLowerCase(list)}'/></c:otherwise>
									</c:choose>
								</td>
								<td>
									<div class="ATMgt_T_Time">
										<span><spring:message code='Cache.lbl_att_ac_time'/> : </span><input type="text" name="Ac${list}" id="Ac${list}" style="width:65px" value=""><span><spring:message code='Cache.lbl_Minutes'/></span> <!-- 인정시간 : 분 -->
										<span><spring:message code='Cache.lbl_n_att_resttime'/> : </span><input type="text" name="Idle${list}" id="Idle${list}" style="width:65px" value=""><span><spring:message code='Cache.lbl_Minutes'/></span> <!-- 휴게시간 : 분 -->
									</div>
								</td>
							</tr>
						</c:forEach>
						</tbody>
					</table>
					<div class="bottom">
						<a href="#" class="btnTypeDefault btnTypeChk" id="btnSelfCommAdd"><spring:message code='Cache.btn_Add'/></a> <!-- 추가 -->
						<a href="#" class="btnTypeDefault" id="btnSelfCommDivClose"><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
					</div>
				</div>
			</div>
			<!-- 사용자 지정 템플릿 목록 팝업 시작 -->
			<p class="US_Temp_tit top_line"><spring:message code='Cache.lbl_MyTemplateList'/></p> <!-- 나의 템플릿 목록 -->
			<div class="US_Temp_list_wrap">
				<ul class="US_Temp_list">
					<c:forEach items="${list}" var="list" varStatus="status" >
						<li>${list.SchName} (${list.AttDayStartTime} ~ ${list.AttDayEndTime})</li>
					</c:forEach>
				</ul>
			</div>
			<!-- 사용자 지정 템플릿 목록 팝업 끝 -->
			<div class="bottom">
				<a id="btnCreate" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.lbl_Creation'/></a><!-- 신청하기 -->
				<a id="btnClose" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a><!-- 취소 -->
			</div>
		</div>
	</div>
</div>	
</body>
<script>
//var bWeekSet = false;
var callBackFunc = CFN_GetQueryString("callBackFunc");
var beforeWorkingSystemType = 0;

$(document).ready(function(){

	// 근무제에 따른 화면 표시
	var workingSystemType = 0;
	var selfCommYn = "N";

	beforeWorkingSystemType = workingSystemType;

	if(workingSystemType == 0) {
		$("#SelfCommYn").val('N'); //자율출근 N로 설정
		$("#WorkTimeTr").show();
		$("#AssTr").show();
		$("#AutoExtenTr").show();
		$("#GoWorkTimeTr").hide();
		$("#OffWorkTimeTr").hide();
		$("#SelfCommTr").hide();
	} else if(workingSystemType == 1) {
		$("#SelfCommYn").val('Y'); //자율출근 Y로 설정
		$("#WorkTimeTr").hide();
		$("#AssTr").hide();
		$("#AutoExtenTr").hide();
		$("#GoWorkTimeTr").hide();
		$("#OffWorkTimeTr").hide();
		$("#SelfCommTr").show();
	} else if(workingSystemType == 2) {
		$("#SelfCommYn").val('N'); //자율출근 N로 설정
		$("#WorkTimeTr").hide();
		$("#AssTr").hide();
		$("#AutoExtenTr").hide();
		$("#GoWorkTimeTr").show();
		$("#OffWorkTimeTr").show();
		$("#SelfCommTr").hide();
	}

	//자동연장근무 시작 초기화
	var extenUnit = Common.getBaseConfig("ExtenUnit");

	var autoExtenMinTime = "${data.AutoExtenMinTime}";
	if (autoExtenMinTime == null || autoExtenMinTime == "") {
		autoExtenMinTime = 0;
	}
	$("select[name=AutoExtenMinTime]").val(autoExtenMinTime);

	var autoExtenMaxTime = "${data.AutoExtenMaxTime}";
	if (autoExtenMaxTime == null || autoExtenMaxTime == "") {
		autoExtenMaxTime = 120;
	}

	var index = 1;
	var tmpValue = extenUnit == 0 ? 10 : extenUnit;
	while (tmpValue < 120) {
		tmpValue = index * (extenUnit == 0 ? 10 : extenUnit);
		var option = "<option value='" + tmpValue + "'>" + tmpValue + "분</option>";
		$("select[name=AutoExtenMaxTime]").append(option);
		index++;
	}
	$("select[name=AutoExtenMaxTime]").val(autoExtenMaxTime);

	//출근지 설정
	var placeParams = {
		"WorkPlaceType" : 0
		, "validYn" : "Y"
	};
	$.ajax({
		type: "POST",
		url: "/groupware/attendSchedule/getWorkPlaceList.do",
		data: placeParams,
		success: function (data) {
			if(data.status != "SUCCESS"){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
			} else {
				var workPlaceList = data.workPlaceList;
				for(var i=0; i<workPlaceList.length; i++) {
					var option = "<option value='" + workPlaceList[i].LocationSeq + "'>" + workPlaceList[i].WorkZone + "</option>";
					$("select[name=GoWorkPlace]").append(option);
				}
			}
		},
		error: function (error) {
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
		}
	});

	//퇴근지 설정
	placeParams = {
		"WorkPlaceType" : 1
		, "validYn" : "Y"
	};
	$.ajax({
		type: "POST",
		url: "/groupware/attendSchedule/getWorkPlaceList.do",
		data: placeParams,
		success: function (data) {
			if(data.status != "SUCCESS"){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
			} else {
				var workPlaceList = data.workPlaceList;
				for(var i=0; i<workPlaceList.length; i++) {
					var option = "<option value='" + workPlaceList[i].LocationSeq + "'>" + workPlaceList[i].WorkZone + "</option>";
					$("select[name=OffWorkPlace]").append(option);
				}
			}
		},
		error: function (error) {
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
		}
	});

	/* 근무제에 따라 화면 표시 변경 */
	$("input[name='WorkingSystemType']:radio").change(function() {
		var tmpValue = this.value;

		if(tmpValue == 0) {
			Common.Confirm("<spring:message code='Cache.mag_Attendance14' />", "Confirmation Dialog", function (confirmResult) { //근무시간이 초기화 됩니다. 지정시간 출근제로 변경하시겠습니까?
				if (confirmResult) {
					//자율 초기화
					$("#SelfCommYn").val('N');
					$("#AttDayAC").val('')
					$("#AttDayIdle").val('')

					$("#SelfCommWeekSet").prop("checked", false);

					//선택 초기화
					if($(".onOffBtn[for=GoWorkTimeYn]").hasClass("on")) {
						$(".onOffBtn[for=GoWorkTimeYn]").removeClass("on");

						$("#GoWorkStartTimeHour").val("00");
						$("#GoWorkStartTimeMin").val("00");
						$("#GoWorkEndTimeHour").val("00");
						$("#GoWorkEndTimeHour").val("00");

						$("#GoWorkTimeYn").prop("checked", false);
					}

					if($(".onOffBtn[for=OffWorkTimeYn]").hasClass("on")) {
						$(".onOffBtn[for=OffWorkTimeYn]").removeClass("on");

						$("#OffWorkStartTimeHour").val("00");
						$("#OffWorkStartTimeMin").val("00");
						$("#OffWorkEndTimeHour").val("00");
						$("#OffWorkEndTimeHour").val("00");

						$("#OffWorkTimeYn").prop("checked", false);
					}

					//화면
					$("#WorkTimeTr").show();
					$("#AssTr").show();
					$("#AutoExtenTr").show();
					$("#GoWorkTimeTr").hide();
					$("#OffWorkTimeTr").hide();
					$("#SelfCommTr").hide();

					workingSystemType = tmpValue;
					beforeWorkingSystemType = tmpValue;
				} else {
					$("input[name=WorkingSystemType]:radio[value='"+beforeWorkingSystemType+"']").prop('checked', true);
				}
			});
		} else if(tmpValue == 1) {
			Common.Confirm("<spring:message code='Cache.mag_Attendance15' />", "Confirmation Dialog", function (confirmResult) { //근무시간이 초기화 됩니다. 자율출근제로 변경하시겠습니까?
				if (confirmResult) {
					//지정 근무 초기화
					$("#WeekStartHour").val("00");
					$("#WeekStartMin").val("00");
					$("#WeekEndHour").val("00");
					$("#WeekEndMin").val("00");

					$("#WeekSet").prop("checked", false);

					if($(".onOffBtn[for=AssYn]").hasClass("on")) {
						$(".onOffBtn[for=AssYn]").removeClass("on");
						$("#AssYn").prop("checked", false);
						$("#AssSeq").attr('disabled', true);
					}

					if($(".onOffBtn[for=AutoExtenYn]").hasClass("on")) {
						$(".onOffBtn[for=AutoExtenYn]").removeClass("on");
						$("#AutoExtenYn").prop("checked", false);
						$("select[name=AutoExtenMinTime]").val("0");
						$("select[name=AutoExtenMaxTime]").val("120");
					}

					//선택 초기화
					if($(".onOffBtn[for=GoWorkTimeYn]").hasClass("on")) {
						$(".onOffBtn[for=GoWorkTimeYn]").removeClass("on");

						$("#GoWorkStartTimeHour").val("00");
						$("#GoWorkStartTimeMin").val("00");
						$("#GoWorkEndTimeHour").val("00");
						$("#GoWorkEndTimeHour").val("00");

						$("#GoWorkTimeYn").prop("checked", false);
					}

					if($(".onOffBtn[for=OffWorkTimeYn]").hasClass("on")) {
						$(".onOffBtn[for=OffWorkTimeYn]").removeClass("on");

						$("#OffWorkStartTimeHour").val("00");
						$("#OffWorkStartTimeMin").val("00");
						$("#OffWorkEndTimeHour").val("00");
						$("#OffWorkEndTimeHour").val("00");

						$("#OffWorkTimeYn").prop("checked", false);
					}

					$("#SelfCommYn").val('Y'); //자율출근 Y로 설정
					//화면
					$("#WorkTimeTr").hide();
					$("#AssTr").hide();
					$("#AutoExtenTr").hide();
					$("#GoWorkTimeTr").hide();
					$("#OffWorkTimeTr").hide();
					$("#SelfCommTr").show();

					workingSystemType = tmpValue;
					beforeWorkingSystemType = tmpValue;
				} else {
					$("input[name=WorkingSystemType]:radio[value='"+beforeWorkingSystemType+"']").prop('checked', true);
				}
			});
		} else if(tmpValue == 2) {
			Common.Confirm("<spring:message code='Cache.mag_Attendance16' />", "Confirmation Dialog", function (confirmResult) { //근무시간이 초기화 됩니다. 선택출근제로 변경하시겠습니까?
				if (confirmResult) {
					//지정근무 초기화
					$("#WeekStartHour").val("00");
					$("#WeekStartMin").val("00");
					$("#WeekEndHour").val("00");
					$("#WeekEndMin").val("00");

					$("#WeekSet").prop("checked", false);

					if($(".onOffBtn[for=AssYn]").hasClass("on")) {
						$(".onOffBtn[for=AssYn]").removeClass("on");
						$("#AssYn").prop("checked", false);
						$("#AssSeq").attr('disabled', true);
					}

					if($(".onOffBtn[for=AutoExtenYn]").hasClass("on")) {
						$(".onOffBtn[for=AutoExtenYn]").removeClass("on");
						$("#AutoExtenYn").prop("checked", false);
						$("select[name=AutoExtenMinTime]").val("0");
						$("select[name=AutoExtenMaxTime]").val("120");
					}

					if($(".onOffBtn[for=AssYn]").hasClass("on")) {
						$(".onOffBtn[for=AssYn]").removeClass("on");
					}

					//자율 초기화
					$("#SelfCommYn").val('N');
					$("#AttDayAC").val('')
					$("#AttDayIdle").val('')

					$("#SelfCommWeekSet").prop("checked", false);

					//화면
					$("#WorkTimeTr").hide();
					$("#AssTr").hide();
					$("#AutoExtenTr").hide();
					$("#GoWorkTimeTr").show();
					$("#OffWorkTimeTr").show();
					$("#SelfCommTr").hide();

					workingSystemType = tmpValue;
					beforeWorkingSystemType = tmpValue;
				} else {
					$("input[name=WorkingSystemType]:radio[value='"+beforeWorkingSystemType+"']").prop('checked', true);
				}
			});
		}
	});

	$("#btnSelfCommAdd").click(function () {
		$("#SelfCommWeekSet").prop("checked", true);
		$("#divSelfCommWeek").hide();
	});

	//요일별 시간 화면 오픈
	$("#btnCal").click(function () {
		$("#divWeek").show();
	});
	$("#icoDivClose, #btnDivClose").click(function () {
		$("#divWeek").hide();
	});

	//요일별 시간 화면 오픈
	$("#btnSelfCommCal").click(function () {
		$("#divSelfCommWeek").show();
	});
	$("#icoSelfCommDivClose, #btnSelfCommDivClose").click(function () {
		$("#divSelfCommWeek").hide();
	});

	$('#btnMap').click(function () {

		var param = {
			"Zone": encodeURI($("#WorkZone").val()),
			"Addr": encodeURI($("#WorkAddr").val()),
			"PointX": $("#WorkPointX").val(),
			"PointY": $("#WorkPointY").val()
		};
		AttendUtils.openMapPopup('AttendSchedulePopup', "${mode}", param);
	});

	//토글
	$(".onOffBtn").click(function (e) {
		if ($(this).attr("for") == "AssYn") {	//간주인경우
			$(this).toggleClass("on");
			$("#AssSeq").attr('disabled', !$(this).hasClass("on"));
		}
		/*
        if ($(this).attr("for") == "SelfCommYn") {	//자율출근제인 경우
            if (!$(this).hasClass("on")) {
                var obj = $(this);
                Common.Confirm("자율 출근제인경우 근무시간이 초기화 됩니다. 자율출근제로 지정하시겠습니까?", "Confirmation Dialog", function (confirmResult) {
                    if (confirmResult) {
                        $("#WeekStartHour").val("00");
                        $("#WeekStartMin").val("00");
                        $("#WeekEndHour").val("00");
                        $("#WeekEndMin").val("00");

                        obj.toggleClass("on");
                        $("#AttDayAC").attr('disabled', false);
                        $("#AttDayIdle").attr('disabled', false);

                        $("#WeekSet").prop("checked", false);
                    }
                });
            } else {
                $(this).toggleClass("on");
                $("#AttDayAC").attr('disabled', !$(this).hasClass("on"));
                $("#AttDayIdle").attr('disabled', !$(this).hasClass("on"));
            }
        }
        */

		if ($(this).attr("for") == "AutoExtenYn") {	//자동연장근무
			if (!$(this).hasClass("on")) {
				var obj = $(this);

				obj.toggleClass("on");
			} else {
				$(this).toggleClass("on");
			}
		}

		if ($(this).attr("for") == "CoreTimeYn") { //코어타임
			if (!$(this).hasClass("on")) {
				var obj = $(this);

				obj.toggleClass("on");
			} else {
				$(this).toggleClass("on");
			}
		}

		if ($(this).attr("for") == "GoWorkTimeYn") { //출근가능시간
			if (!$(this).hasClass("on")) {
				var obj = $(this);

				obj.toggleClass("on");
			} else {
				$(this).toggleClass(" on");
			}
		}

		if ($(this).attr("for") == "OffWorkTimeYn") { //퇴근가능시간
			if (!$(this).hasClass("on")) {
				var obj = $(this);

				obj.toggleClass("on");
			} else {
				$(this).toggleClass("on");
			}
		}
	});
	
	$('#btnCreate').click(function(){
		if (!validationChk()) return;

		if(workingSystemType == 0) {
			if ($("#WeekSet").prop("checked") == false) {
				Common.Confirm("<spring:message code='Cache.mag_Attendance17' />", "Confirmation Dialog", function (confirmResult) { //요일별 설정이 해제되어 있습니다. 입력하신 시간으로 모든 요일을 적용하시겠습니까?
					if (confirmResult) {
						addCustomeSchedule();
					}
				});
			} else {
				Common.Confirm("<spring:message code='Cache.msg_RUSave' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						addCustomeSchedule();
					}
				});
			}
		} else if(workingSystemType == 1) {
			if ($("#SelfCommWeekSet").prop("checked") == false) {
				Common.Confirm("<spring:message code='Cache.mag_Attendance17' />", "Confirmation Dialog", function (confirmResult) { //요일별 설정이 해제되어 있습니다. 입력하신 시간으로 모든 요일을 적용하시겠습니까?
					if (confirmResult) {
						addCustomeSchedule();
					}
				});
			} else {
				Common.Confirm("<spring:message code='Cache.msg_RUSave' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						addCustomeSchedule();
					}
				});
			}
		} else {
			Common.Confirm("<spring:message code='Cache.msg_RUSave' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					addCustomeSchedule();
				}
			});
		}
	});

	$("#btnAdd").click(function(){
		<c:forEach items="${week}" var="list" varStatus="status" >
			var StartTime = $("#Start${list}Hour").val()+''+$("#Start${list}Min").val();
			var EndTime = $("#End${list}Hour").val()+''+$("#End${list}Min").val();

			if(StartTime> EndTime && !$("#NextDayYn${list}").prop("checked")){
				Common.Warning(Common.getDic("msg_Mobile_InvalidStartTime"));			//시작일은 종료일 보다 이후일 수 없습니다.
				return false;
			}
		</c:forEach>
		
		bWeekSet = true;
		$("#divWeek").hide();		
	});
	$("#btnDivClose, #icoDivClose").click(function(){
		$("#divWeek").hide();		
	});
	$('#btnClose').click(function(){
		Common.Close();
	});	
});
//2022.02.07 nkpark 누락 함수 추가(근무지 커스텀 지정 콜백 함수용)
function setMapLocation(param) {
	$("#WorkZone").val(param["Zone"]);
	$("#WorkAddr").val(param["Addr"]);
	$("#WorkPointX").val(param["PointX"]);
	$("#WorkPointY").val(param["PointY"]);
}

function addCustomeSchedule(){
	var AttDayStartTime = $("#WeekStartHour").val() + '' + $("#WeekStartMin").val();
	var AttDayEndTime = $("#WeekEndHour").val() + '' + $("#WeekEndMin").val();

	var aJsonArray = new Array();

	if ($("#SelfCommYn").val() == 'Y' && ($("#AttDayAC").val() == "" || $("#AttDayAC").val() == 0)) {
		Common.Confirm("<spring:message code='Cache.mag_Attendance18' />", "Confirmation Dialog"); //자율 출근제인경우 인정근무시간을 입력하셔야 합니다.
		return;
	}

	var goWorkPlaceCodes = "";
	//출근지 설정
	$('#GoWorkPlaceSelected .ui-autocomplete-multiselect-item').each(function () {
		goWorkPlaceCodes += $(this).attr("data-value") + ",";
	});

	var offWorkPlaceCodes = "";
	//퇴근지 설정
	$('#OffWorkPlaceSelected .ui-autocomplete-multiselect-item').each(function () {
		offWorkPlaceCodes += $(this).attr("data-value") + ",";
	});

	var objParams = {
		"mode": "${mode}"
		, "SchName": $("#SchName").val()
		, "AttDayStartTime": AttDayStartTime
		, "AttDayEndTime": AttDayEndTime
		, "NextDayYn": ($("#WeekNextDayYn").prop("checked") ? 'Y' : 'N')
		, "AssYn": ($("#AssYn").prop("checked") ? 'Y' : 'N')
		, "AssSeq": ($("#AssYn").prop("checked") ? $("#AssSeq").val() : '')
		, "SelfCommYn": $("#SelfCommYn").val()
		, "AttDayAC": ($("#SelfCommYn").val() == 'Y' ? $("#AttDayAC").val() : '')
		, "AttDayIdle": ($("#SelfCommYn").val() == 'Y' ? $("#AttDayIdle").val() : '')
		, "AutoExtenYn": ($("#AutoExtenYn").prop("checked") ? 'Y' : 'N')
		, "AutoExtenMinTime": $("select[name=AutoExtenMinTime]").val()
		, "AutoExtenMaxTime": $("select[name=AutoExtenMaxTime]").val()
		, "Memo": $("#Memo").val()
		, "WorkZone": $("#WorkZone").val()
		, "WorkAddr": $("#WorkAddr").val()
		, "WorkPointX": $("#WorkPointX").val()
		, "WorkPointY": $("#WorkPointY").val()
		, "AllowRadius": $("#AllowRadius").val()
		, "WorkingSystemType": $('input[name=WorkingSystemType]:checked').val()
		, "CoreTimeYn": ($("#CoreTimeYn").prop("checked") ? 'Y' : 'N')
		, "CoreStartTimeHour": $("select[name=CoreStartTimeHour]").val()
		, "CoreStartTimeMin": $("select[name=CoreStartTimeMin]").val()
		, "CoreEndTimeHour": $("select[name=CoreEndTimeHour]").val()
		, "CoreEndTimeMin": $("select[name=CoreEndTimeMin]").val()
		, "GoWorkTimeYn": ($("#GoWorkTimeYn").prop("checked") ? 'Y' : 'N')
		, "GoWorkStartTimeHour": $("select[name=GoWorkStartTimeHour]").val()
		, "GoWorkStartTimeMin": $("select[name=GoWorkStartTimeMin]").val()
		, "GoWorkEndTimeHour": $("select[name=GoWorkEndTimeHour]").val()
		, "GoWorkEndTimeMin": $("select[name=GoWorkEndTimeMin]").val()
		, "OffWorkTimeYn": ($("#OffWorkTimeYn").prop("checked") ? 'Y' : 'N')
		, "OffWorkStartTimeHour": $("select[name=OffWorkStartTimeHour]").val()
		, "OffWorkStartTimeMin": $("select[name=OffWorkStartTimeMin]").val()
		, "OffWorkEndTimeHour": $("select[name=OffWorkEndTimeHour]").val()
		, "OffWorkEndTimeMin": $("select[name=OffWorkEndTimeMin]").val()
		, "GoWorkPlaceCodes" : goWorkPlaceCodes
		, "OffWorkPlaceCodes": offWorkPlaceCodes
	};


	<c:forEach items="${week}" var="list" varStatus="status" >
	objParams["Start${list}Hour"] = $("#Start${list}Hour").val()
	objParams["Start${list}Min"] = $("#Start${list}Min").val()
	objParams["End${list}Hour"] = $("#End${list}Hour").val()
	objParams["End${list}Min"] = $("#End${list}Min").val()
	objParams["NextDayYn${list}"] = ($("#NextDayYn${list}").prop("checked") ? 'Y' : 'N')
	objParams["Ac${list}"] = ($("#Ac${list}").val()==''?0:$("#Ac${list}").val())
	objParams["Idle${list}"] = ($("#Idle${list}").val()==''?0:$("#Idle${list}").val())
	</c:forEach>

	$.ajax({
		type: "POST",
		url:"/groupware/attendReq/addCustomSchedule.do",
		data: objParams,
		success:function (data) {
			if(data.result == "ok"){
				Common.Inform("<spring:message code='Cache.msg_Been_saved'/>");	//저장되었습니다.
				$("#<%=request.getParameter("parentId")%>_if", parent.document).get(0).contentWindow.getScheduleList(); // 템플릿 목록 갱신
				Common.Close();
			}
			else{
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
			}
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
		}
	});
}

function validationChk() {
	var returnVal = true;
	if ($.trim($("#SchName").val()) == "") {
		Common.Warning(Common.getDic("msg_ObjectUR_07"));			//근무제명 넣기
		return false;
	}

	if ($("#WeekSet").prop("checked") == false) {
		<c:forEach items="${week}" var="list" varStatus="status" >
		$("#Start${list}Hour").val($("#WeekStartHour").val());
		$("#Start${list}Min").val($("#WeekStartMin").val());
		$("#End${list}Hour").val($("#WeekEndHour").val());
		$("#End${list}Min").val($("#WeekEndMin").val());
		$("#NextDayYn${list}").prop("checked", $("#WeekNextDayYn").prop("checked"));
		</c:forEach>
	}

	if ($("#SelfCommWeekSet").prop("checked") == false) {
		<c:forEach items="${week}" var="list" varStatus="status" >
		$("#Ac${list}").val($("#AttDayAC").val());
		$("#Idle${list}").val($("#AttDayIdle").val());
		</c:forEach>
	}

	<c:forEach items="${week}" var="list" varStatus="status" >
	/* 시작시간 종료시간*/
	var AttDayStartTime = $("#Start${list}Hour").val() + '' + $("#Start${list}Min").val();
	var AttDayEndTime = $("#End${list}Hour").val() + '' + $("#End${list}Min").val();

	if (AttDayStartTime != "0000" && AttDayEndTime != "0000" && AttDayStartTime >= AttDayEndTime && !$("#NextDayYn${list}").prop("checked")) {
		Common.Warning(Common.getDic("msg_Mobile_InvalidStartTime"));			//시작일은 종료일 보다 이후일 수 없습니다.
		return false;
	}

	</c:forEach>

	return true;
}

function addWorkPlace(workPlaceType) {
	var code = $("select[name=" + workPlaceType +"]").val();
	var name = $("select[name=" + workPlaceType +"] option:selected").text();

	$("select[name=" + workPlaceType + "] option:selected").remove();

	var orgMapItem = $('<div class="ui-autocomplete-multiselect-item" style="margin:1px;background:skyblue;float:left;" id="' + workPlaceType + code + '"/>')
			.attr({'data-value': code } )
			.text(name)
			.append($("<span></span>")
					.addClass("ui-icon ui-icon-close")
					.attr("onclick", "removeWorkPlace('" + workPlaceType + "', '" + code + "', '" + name + "');"));
	$("#" + workPlaceType + "Selected").append(orgMapItem);
}

function removeWorkPlace(workPlaceType, code, name, obj) {
	$("#" + workPlaceType + code).remove();

	var option = "<option value='" + code + "'>" + name + "</option>";
	$("select[name=" + workPlaceType + "]").append(option);
}

</script>