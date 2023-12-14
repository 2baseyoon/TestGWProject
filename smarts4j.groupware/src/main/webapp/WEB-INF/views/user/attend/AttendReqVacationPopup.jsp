<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil,egovframework.covision.groupware.attend.user.util.AttendUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'>
	<meta http-equiv='expires' content='0'>
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<style>
		#resultViewDetailDiv, #resultViewDetailDiv .ui-autocomplete-multiselect { width: 100% !important; }
		.org_list_box_attend{display:flex; flex-wrap:wrap; flex:1 1 auto; min-height:30px; height:auto !important; max-height: 186px; overflow:hidden auto; padding:1px 2px;}
		.org_list_box_attend input{width:100px !important; border:0px !important; vertical-align:middle !important;}
	</style>
</head>
<body>
	<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="ATMgt_popup_wrap">
			<div >
				<table class="ATMgt_popup_table type02" cellspacing="0" cellpadding="0">
					<colgroup>
						<col width="115">
						<col width="*">
						<col width="115">
						<col width="*">
					</colgroup>
				<tbody>
					<c:choose>
						<c:when test="${authType eq 'ADMIN'}">
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_hrMng_targetUser' /></td> <!-- 대상자 -->
								<td colspan=3>
								<div class="ATMgt_T">
									<div class="ATMgt_T_l">
									<div class="org_list_box_attend" id="resultViewDetailDiv">
										<input id="resultViewDetailInput" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS" autocomplete="off">
									</div>
									</div>
									<div class="ATMgt_T_r" style="width: 70px;vertical-align:middle;">
										<a class="btnTypeDefault nonHover type01" onclick="openOrgMapLayerPopup('resultViewDetailDiv');"><spring:message code='Cache.btn_OrgManage' /></a> <!-- 조직도 -->
									</div>
								</div>
								</td>
							</tr>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.VACATION_TYPE_VACATION_ANNUAL'/></td>
								<td id="VacDay" colspan="3"></td>
							</tr>
							<tr id="tr_vaclist" style="display: none;">
								<td class="ATMgt_T_th"><spring:message code='Cache.MN_657'/></td>
								<td colspan=3 style="padding: 0;">
									<div id="extraDiv" style="width:549px;height:auto;">
										<table class="tbl tblType02" style="width: 547px;font-size: 12px;">
											<colgroup>
												<col width="107">
												<col width="80">
												<col width="80">
												<col width="140">
												<col width="140">
											</colgroup>
											<tbody>
											<tr>
												<th class="bg"><spring:message code='Cache.lbl_type'/></th>
												<th class="bg"><spring:message code='Cache.lbl_apv_Vacation_days'/></th>
												<th class="bg"><spring:message code='Cache.lbl_appjanyu'/></th>
												<th class="bg"><spring:message code='Cache.lbl_expiryDate'/></th>
												<th class="bg"><spring:message code='Cache.lbl_Reason'/></th>
											</tr>
											</tbody>
										</table>
										<div id="extraTable" class="mScrollV scrollVType01 scrollbar" style="width:549px;height:97px;" >
											<table class="tbl tblType02" style="width: 547px;">
												<colgroup>
													<col width="107">
													<col width="80">
													<col width="80">
													<col width="140">
													<col width="140">
												</colgroup>
												<tbody>
												</tbody>
											</table>
										</div>
									</div>
								</td>
							</tr>
							<tr id="tr_vaclist" style="display: none;">
								<td class="ATMgt_T_th"><spring:message code='Cache.MN_657'/></td>
								<td colspan="3">
									<div class="ATMgt_T_Time" ><spring:message code='Cache.msg_notViewPeopleVacInfo' /></div>
								</td>
							</tr>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.VACATION_TYPE_VACATION_TYPE'/></td>
								<td colspan="3">
									<div class="ATMgt_T_Time" style="float: left;">
										<span id="VacFlag" style="width:100px">	</span>
										<select data-type="rField" name="VacOffFlag" id="VacOffFlag" style="width:50px;" required title="<spring:message code='VACATION_OFF'/><spring:message code='Cache.lbl_type'/>"  onchange="javascript:changeVacOffFlag(this);"> <!-- 반차유형 -->
											<option name="" value="0" selected><spring:message code='Cache.lbl_Select'/></option> <!-- 선택 -->
											<option name="AM" value="AM"><spring:message code='Cache.lbl_AM'/></option> <!-- 오전 -->
											<option name="PM" value="PM"><spring:message code='Cache.lbl_PM'/></option> <!-- 오후 -->
										</select>
										<span id="spanTimeRange" style="display: none;">
											<select id="StartHour" name="StartHour" onchange="javascript:changeStartHour(this);">
												<c:forEach begin="00" end="23" var="hour">
													<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>" ><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
												</c:forEach>
											</select>
											<span>:</span>
											<input type="text" name="StartMin"  id="StartMin" maxlength="2" value="00" disabled/>
											<span>-</span>
											<input type="text" name="EndHour"  id="EndHour" maxlength="2" value="00" disabled/>
											<span>:</span>
											<input type="text" name="EndMin"  id="EndMin" maxlength="2" value="00" disabled/>
										</span>
									</div>
								</td>
							</tr>
						</c:when>
						<c:otherwise>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.VACATION_TYPE_VACATION_ANNUAL'/></td>
								<td>${vacInfo.VacDay}<spring:message code='Cache.lbl_day'/>(<spring:message code='Cache.lbl_Use'/> : ${vacInfo.UseDays}) <spring:message code='Cache.lbl_n_att_remain'/> : ${vacInfo.ATot}</td> <!-- 일 (사용 : ) 잔여 :-->
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Approver' /></td>
								<td>${UR_ManagerName}</td>
							</tr>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.MN_657'/></td>
								<td colspan=3 style="padding: 0;">
									<div id="extraDiv" style="width:549px;height:auto;">
										<table class="tbl tblType02" style="width: 547px;font-size: 12px;">
											<colgroup>
												<col width="107">
												<col width="80">
												<col width="80">
												<col width="140">
												<col width="140">
											</colgroup>
											<tbody>
											<tr>
												<th class="bg"><spring:message code='Cache.lbl_type'/></th>
												<th class="bg"><spring:message code='Cache.lbl_apv_Vacation_days'/></th>
												<th class="bg"><spring:message code='Cache.lbl_appjanyu'/></th>
												<th class="bg"><spring:message code='Cache.lbl_expiryDate'/></th>
												<th class="bg"><spring:message code='Cache.lbl_Reason'/></th>
											</tr>
											</tbody>
										</table>
										<div id="extraTable" class="mScrollV scrollVType01 scrollbar" style="width:549px;height:97px;" >
											<table class="tbl tblType02" style="width: 547px;">
												<colgroup>
													<col width="107">
													<col width="80">
													<col width="80">
													<col width="140">
													<col width="140">
												</colgroup>
												<tbody>
												</tbody>
											</table>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.VACATION_TYPE_VACATION_TYPE'/></td>
								<td colspan="3">
									<div class="ATMgt_T_Time" style="float: left;">
										<span id="VacFlag" style="width:100px">	</span>
										<select data-type="rField" name="VacOffFlag" id="VacOffFlag" style="width:50px;" required title="<spring:message code='VACATION_OFF'/><spring:message code='Cache.lbl_type'/>"  onchange="javascript:changeVacOffFlag(this);"> <!-- 반차유형 -->
											<option name="" value="0" selected><spring:message code='Cache.lbl_Select'/></option> <!-- 선택 -->
											<option name="AM" value="AM"><spring:message code='Cache.lbl_AM'/></option> <!-- 오전 -->
											<option name="PM" value="PM"><spring:message code='Cache.lbl_PM'/></option> <!-- 오후 -->
										</select>
										<span id="spanTimeRange" style="display: none;">
											<select id="StartHour" name="StartHour" onchange="javascript:changeStartHour(this);">
												<c:forEach begin="00" end="23" var="hour">
													<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>" ><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
												</c:forEach>
											</select>
											<span>:</span>
											<input type="text" name="StartMin"  id="StartMin" maxlength="2" value="00" disabled/>
											<span>-</span>
											<input type="text" name="EndHour"  id="EndHour" maxlength="2" value="00" disabled/>
											<span>:</span>
											<input type="text" name="EndMin"  id="EndMin" maxlength="2" value="00" disabled/>
										</span>
									</div>
								</td>
							</tr>
						</c:otherwise>
					</c:choose>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Remark'/></td>
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
						<c:forEach begin="1" end="5">
						<tr>
							<td class="tx_sun"><p class="tx_day"></p><div><p></p></div></td>
							<td><p class="tx_day"></p><div><p></p></div></td>
							<td><p class="tx_day"></p><div><p></p></div></td>
							<td><p class="tx_day"></p><div><p></p></div></td>
							<td><p class="tx_day"></p><div><p></p></div></td>
							<td><p class="tx_day"></p><div><p></p></div></td>
							<td class="tx_sat"><p class="tx_day"></p><div><p></p></div></td>
						</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>
		</div>
		<div class="bottom">
			<a id="btnReq"	class="btnTypeDefault btnTypeChk"><%=AttendUtils.getRequestName(RedisDataUtil.getBaseConfig("VacReqMethod"))%></a> 	<!-- 신청하기 -->
			<a id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
		</div>
	</div>
</div>
</body>
<script>
var orgMapDivEl = $("<p/>", {'class' : 'date_del', attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'ui-icon ui-icon-close'}));
var orgCalTtlE1 = $(".WTab").html();
var orgCalContE1 = $(".WTemp_cal_wrap").html();
var nowYear = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss")).getFullYear();
var vacInfoData = null;
var vacationKindData = null;
//자동완성 옵션
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

		// 연차 표시
		if ($("#resultViewDetailDiv .date_del").length === 1 && $("#resultViewDetailDiv .date_del").attr("type") === "UR") {
			getVacInfo();
		} else if ($("#resultViewDetailDiv .date_del").length == 0) {
			$("#VacDay").text("");
		} else {
			$("#VacDay").text(Common.getDic("<spring:message code='Cache.msg_notViewPeopleVacInfo' />")); // 다수 인원 지정 시 잔여연차 정보는 표기되지 않습니다.
		}
	}
};


var gAttDayAC = 0;
var gAttDayAC2 = 0;
var WORK_HOUR = 8;
var gPublicRemainVacDay = parseFloat("0.0");

$(document).ready(function(){
	coviCtrl.setCustomAjaxAutoTags('resultViewDetailInput', '/groupware/attendCommon/getAttendUserGroupAutoTagList.do', MultiAutoInfos);	// 근태대상
	$(".ui-autocomplete-multiselect.ui-state-default.ui-widget").removeAttr('style');

	coviCtrl.bindmScrollV($('.mScrollV'));

	//휴가현황 표 출력
	loadVacationInfo();

	var initInfos = [
		     	        {
		     		        target : 'VacFlag',
		     		        codeGroup : 'VACATION_TYPE',
		     		        defaultVal : '',
		     		        width : '100',
		     		       onchange : 'changeTargetType'
		     	        }
		             ];
	//coviCtrl.renderAjaxSelect(initInfos, '', 'ko');	//event 세팅
	var useBefore = isBeforeAnnualMember();
	var lang = Common.getSession("lang");
	var html = "";
	$.ajax({
		url : "/groupware/vacation/getUserVacTypeInfo.do",
		type: "POST",
		dataType : 'json',
		async: false,
		success:function (data) {
			lang = coviCmn.isNull(lang, "");
			html += '<select class="selectType04" style="width:100px">';
			var listData = data.list;
			if(listData.length>0){
				for(var i=0;i<listData.length;i++){
					var isUse = listData[i].IsUse;
					if(isUse==="N"){
						continue;
					}
					var reserved1 = listData[i].Reserved1;
					var reserved2 = listData[i].Reserved2;
					var reserved3 = listData[i].Reserved3;
					var listCode  = listData[i].Code;
					var groupCode = listData[i].GroupCode;
					if (!(!useBefore && reserved2 === "1") && (existUserVacationInfo(listCode, groupCode) || reserved1==="N")) { // 선연차 제외
						var codeObj = listData[i];
						var codeName = (lang != "" ? CFN_GetDicInfo(codeObj.MultiCodeName, lang) : codeObj.CodeName);

						html += '	<option ';
						html += ' value= "' + codeObj.Code  +'" ' +
								'data-code=\'' + JSON.stringify(codeObj) + '\' ' +
								'data-codename="' + codeName + '"' +
								'data-reserved1="' + reserved1 + '"' +
								'data-reserved2="' + reserved2 + '"' +
								'data-reserved3="' + reserved3 + '"' +
								'>' + codeName + '</option>';
					}
				}
			}
			html += '</select>';

			$('#VacFlag').html(html);

			$("#VacFlag select").change(function(){
				changeTargetType();
			});
			changeTargetType();
		},
		error:function (error){
			alert(error.message);
		}
	});

	try {
		var today = new Date();
		var userId = "${UserCode}";
		var sEnterDate = Common.GetObjectInfo("UR", userId, "ENTERDATE").ENTERDATE;
		var bBefore = false;
		// 당해 입사자 이거나, 전년도 입사자 6/30일까지 + 추가한 설정의 사용자
		if(sEnterDate.substring(0, 4) == today.getFullYear()
				|| (sEnterDate.substring(0, 4) == (today.getFullYear()-1) && CFN_PadLeft((today.getMonth()+1), 2, "0") + "-" + CFN_PadLeft(today.getDate(), 2, "0") < "06-30")
				|| Common.getBaseConfig("BeforeAnnualMember").indexOf(userId + ";") > -1 ) {
			if (gPublicRemainVacDay > 0.0 ){//잔여시 선연자제거
				bBefore = true;
			}
		}
		else{
			bBefore = true;
		}
	} catch(e) {
		coviCmn.traceLog(e);
	}

	/*if (bBefore == true){	//선연자 제거
		$("#VacFlag select option").each(function(){
			var dataStr = $(this).attr("data-code");
			if (dataStr != ""){
				var dataMap = JSON.parse(dataStr);
				if (dataMap["Reserved2"] == "1") $(this).remove();
			}
		});
	}*/


	var mode = "${authType}" === "ADMIN" ? "ONLY" : "";
	AttendUtils.getScheduleMonth(CFN_GetLocalCurrentDate("yyyy-MM-dd"), "calendar", "dateTitle", mode, "calTbody");

	//event 세팅
	$(".WTemp_cal_wrap .pre").click(function(){
		<c:choose>
		<c:when test="${authType eq 'ADMIN'}">
		if ($("#resultViewDetailDiv .date_del").length === 1 && $("#resultViewDetailDiv .date_del").eq(0).attr("type") === "UR") {
			mode = "";
		}else{
			mode = "${authType}" === "ADMIN" ? "ONLY" : "";
		}
		</c:when>
		</c:choose>
		AttendUtils.goScheduleNextPrev(-1, "calendar", "dateTitle", mode, "calTbody");
		if(Number($("#dateTitle").text().substring(0,4))!==nowYear){
			nowYear = Number($("#dateTitle").text().substring(0,4));
			loadVacationInfo();
		}
		if($("#VacFlag > select").find(':selected').data('code').Reserved1==="Y") {
			vacInfoData = vacationDetailInfo($("#VacFlag > select").find(':selected').data('code').CodeID);
		}
	});
	$(".WTemp_cal_wrap .next").click(function(){
		<c:choose>
		<c:when test="${authType eq 'ADMIN'}">
		if ($("#resultViewDetailDiv .date_del").length === 1 && $("#resultViewDetailDiv .date_del").eq(0).attr("type") === "UR") {
			mode = "";
		}else{
			mode = "${authType}" === "ADMIN" ? "ONLY" : "";
		}
		</c:when>
		</c:choose>
		AttendUtils.goScheduleNextPrev(1, "calendar", "dateTitle", mode, "calTbody");
		if(Number($("#dateTitle").text().substring(0,4))!==nowYear){
			nowYear = Number($("#dateTitle").text().substring(0,4));
			loadVacationInfo();
		}
		if($("#VacFlag > select").find(':selected').data('code').Reserved1==="Y") {
			vacInfoData = vacationDetailInfo($("#VacFlag > select").find(':selected').data('code').CodeID);
		}
	});

	//event 세팅
	$('#btnReq').click(function(){
		if(!validationChk()) return;

		Common.Confirm("<spring:message code='Cache.ACC_isAppCk' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				reqVacation();
			}
		});
	});

	$('#btnClose').click(function(){
		Common.Close();
	});

});

function existUserVacationInfo(Code, GroupCode){
	var rtn = false;
	var jsonVacKindData = JSON.parse(vacationKindData);
	for (var i = 0; i < jsonVacKindData.length; i++) {
		if (jsonVacKindData[i].VacKind === "PUBLIC" && GroupCode === "PUBLIC") {
			rtn = true;
			break;
		}else if(jsonVacKindData[i].VacKind === Code){
			rtn = true;
			break;
		}
	}
	return rtn;
}

function isBeforeAnnualMember() {
	var useBefore = false;
	try {
		if (Common.getBaseConfig("BeforeAnnualMember").indexOf(Common.getSession("USERID")+ ";") > -1) {
			useBefore = true;
		}
		if (Common.getBaseConfig("BeforeAnnualMember").indexOf("ALL@" + ";") > -1) {
			useBefore = true;
		}

		if (getInfo("Request.templatemode") == "Read") {
			useBefore = true;
		}
	} catch (e) { coviCmn.traceLog(e); }
	return useBefore;
}

function loadVacationInfo(){
	var params = null;
	<c:choose>
	<c:when test="${authType eq 'ADMIN'}">
	params = {
		"year" : ""+nowYear,
		"schTypeSel" : "userCode",
		"schTxt" : $("#resultViewDetailDiv .date_del").eq(0).attr("code")
	};
	</c:when>
	<c:otherwise>
	params = {
		"year" : ""+nowYear,
		"schTypeSel" : "userCode",
		"schTxt" : Common.getSession('USERID')
	};
	</c:otherwise>
	</c:choose>

	$.ajax({
		type : "POST",
		data : params,
		async: false,
		url : "/groupware/vacation/getVacationListByKind.do",
		success: function (list) {
			vacationKindData = JSON.stringify(list.list);
			$("#extraTable tbody").html("");
			var data = list.list;
			$.each(data, function(i, v) {
            	if ((v.VacKind=="PUBLIC" && v.CurYear == "Y") ||	v.RemainVacDay>0){
					var row = $("<tr "+(v.CurYear == "Y"?"class='ERBoxbg'":"")+">")
	                        .append($("<td>",{"style":"font-size: 12px;width:107px;text-align: center;"}).text((v.VacKind=="PUBLIC"?v.Year+" ":"")+v.VacName))
						.append($("<td>",{"style":"font-size: 12px;width:80px;"}).text(v.VacDay))
						.append($("<td>",{"style":"font-size: 12px;width:80px;"}).text(v.RemainVacDay))
						.append($("<td>",{"style":"font-size: 12px;width:140px;"}).text(v.ExpDate))
						.append($("<td>",{"style":"font-size: 12px;width:140px;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;","title":v.Reason}).text(v.Reason!=null?v.Reason:""));

					$("#extraTable tbody").append(row);
					if(v.VacKind === "PUBLIC"){
						gPublicRemainVacDay = parseFloat(v.RemainVacDay);
					}
				}
			});

		},
		error:function(response, status, error) {
			CFN_ErrorAjax( "/groupware/vacation/getVacationListByKind.do", response, status, error);
		}
	});

}

$(document).on("click",".calDate",function(){
	var userCnt = 1;
	<c:choose>
	<c:when test="${authType eq 'ADMIN'}">
	var targetUserArr = new Array();
	$('#resultViewDetailDiv').find('.date_del').each(function (i, v) {
		var item = $(v);
		var saveData = {"Type": item.attr('type'), "Code": item.attr('code')};
		targetUserArr.push(saveData);
	});
	userCnt = targetUserArr.length;
	</c:when>
	</c:choose>
	var dataStr = $(this).find("div p").attr("data-map");
	const clickDate = Number($(this).attr("title").replaceAll("-", ""));
	if (dataStr !== undefined && dataStr !== "" || userCnt > 1) {
		var dataMap = null;
		if(userCnt === 1) {
			dataMap = JSON.parse(dataStr);
			if (dataMap["VacFlag"] != "N" || (dataMap["WorkSts"] == "OFF" || dataMap["WorkSts"] == "HOL")) {
				Common.Warning("<spring:message code='Cache.mag_Attendance34' />");			//이미 휴가 처리 되었거나 휴무(휴일) 입니다.
				return false;
			}
			if (dataMap["ConfmYn"] == "Y") {
				Common.Warning("<spring:message code='Cache.msg_apv_personnel_items_modify_refresh' />");
				return;
			}
		}
		//AttDayAC 기준 시간차 인경우 시간 계산

		var Reserved1 = $("#VacFlag > select").find(':selected').data('code').Reserved1;
		var Reserved2 = $("#VacFlag > select").find(':selected').data('code').Reserved2;
		if(Reserved1==="Y" && Reserved2!=="1") {
			var vacDay = $("#VacFlag > select").find(':selected').data('reserved3');
			if (vacDay === "" || vacDay == null) {
				vacDay = 1;
			}
			if (vacDay < 0.5 && userCnt === 1) {
				gAttDayAC2 = gAttDayAC;
				gAttDayAC = dataMap["AttDayAC"];
				WORK_HOUR = gAttDayAC / 60;
				if (gAttDayAC2 != 0 && gAttDayAC != 0 && gAttDayAC2 != gAttDayAC) {
					Common.Warning("<spring:message code='Cache.msg_vacation_diffscheduler' />");
					return;
				}
			}

			if ($(this).hasClass("selDate")) {
				$(this).toggleClass("selDate");
			} else {
				if (vacInfoData.list.length > 0) {
					var able = false;
					for (var i = 0; i < vacInfoData.list.length; i++) {
						var vacInfo = vacInfoData.list[i];
						var selCnt = 0;
						var vacDayRemain = 0;
						var sDate = Number(vacInfo.Sdate);
						var eDate = Number(vacInfo.Edate);
						vacDayRemain = parseFloat(vacInfo.VacDayRemain);
						$(".calDate").each(function () {
							const thisDate = Number($(this).attr("title").replaceAll("-", ""));
							if ($(this).hasClass("selDate") && thisDate >= sDate && thisDate <= eDate) {
								selCnt = selCnt + vacDay;
							}
						});
						if (selCnt + vacDay > vacDayRemain && clickDate >= sDate && clickDate <= eDate) {
							Common.Warning("[" + vacInfo.CodeName + "]" + "<spring:message code='Cache.msg_apv_chk_remain_vacation'/>");//휴가 사용 기한을 확인 하여 주세요.
							return;
						}

						if (clickDate >= sDate && clickDate <= eDate) {
							able = true;
						}
					}//end for i

					if (able) {
						$(this).toggleClass("selDate");
					} else {
						Common.Warning("[" + vacInfoData.list[0].CodeName + "]" + "<spring:message code='Cache.msg_vacationdate_rangecheck'/>");//휴가 사용 기한을 확인 하여 주세요.
					}
				} else {
					Common.Warning("<spring:message code='Cache.msg_vacation_notexist'/>");//선택하신 휴가유형의 연차가능 정보가 존재 하지 않습니다.
					return;
				}
			}
		}else{//미차감 연차 타입
			$(this).toggleClass("selDate");
		}
  	}else{
		$(this).toggleClass("selDate");
		/*if ("${authType}" !== "ADMIN") {
			Common.Warning("<spring:message code='Cache.lbl_NoRegistSchedule'/>");
		}*/
	}

});

function vacationDetailInfo(CodeID){
	var rtn = null;
	var params = null;
	var calMonth = $("#dateTitle").text();
	<c:choose>
		<c:when test="${authType eq 'ADMIN'}">
		var targetUserArr = new Array();
		$('#resultViewDetailDiv').find('.date_del').each(function (i, v) {
			var item = $(v);
			var saveData = {"Type": item.attr('type'), "Code": item.attr('code')};
			targetUserArr.push(saveData);
		});
		params = {
			"year" : nowYear,
			"urCodeList" : targetUserArr,
			"codeID" : CodeID,
			"calMonth" : calMonth
		};
		</c:when>
		<c:otherwise>
		params = {
			"year" : nowYear,
			"urCode" : Common.getSession('USERID'),
			"codeID" : CodeID,
			"calMonth" : calMonth
		};
		</c:otherwise>
	</c:choose>

	$.ajax({
		type : "POST",
		async: false,
		contentType: 'application/json; charset=utf-8',
		data: JSON.stringify(params),
		url : "/groupware/vacation/getVacationByCode.do",
		success: function (list) {
			if(list.list.length>0){
				rtn = list;
			}else{
				Common.Warning("<spring:message code='Cache.msg_vacation_notexist'/>");//선택하신 휴가유형의 연차가능 정보가 존재 하지 않습니다.
			}
		},
		error:function(response, status, error) {
			CFN_ErrorAjax( "/groupware/vacation/getVacationByCode.do", response, status, error);
		}
	});
	return rtn;
}


$(document).ready(function(){
	changeTargetType();
});

function changeStartHour(obj){
	var vacDay = $("#VacFlag > select").find(':selected').data('reserved3');
	var sHour = $(obj).find(':selected').val();
	var startHour = parseInt(sHour);
	var startMinutes = parseInt($("#EndMin").val());
	var endTime = new Date();
	endTime.setHours(startHour + WORK_HOUR * vacDay, startMinutes);
	var endHour = String(endTime.getHours()).padStart(2, "0");
	var endMinutes = String(endTime.getMinutes()).padStart(2, "0");

	$("#EndHour").val(endHour);
	$("#EndMin").val(endMinutes);

	if(startHour<13){
		$("#VacOffFlag").val("AM").prop("selected", true);
	}else{
		$("#VacOffFlag").val("PM").prop("selected", true);
	}
}

function changeVacOffFlag(obj){
	var sHour = $("#StartHour").find(':selected').val();
	var startHour = parseInt(sHour);
	var reserved1 = $("#VacFlag > select").find(':selected').data('reserved1');
	var vacDay = $("#VacFlag > select").find(':selected').data('reserved3');
	var ampmVal = $(obj).find(':selected').val();
	if ( vacDay < 0.5 && reserved1==="Y") {
		if(startHour<13 && ampmVal==="PM"){
			$("#StartHour").val("13").prop("selected", true);
			changeStartHour($("#StartHour"));
		}
		if(startHour>12 && ampmVal==="AM"){
			$("#StartHour").val("09").prop("selected", true);
			changeStartHour($("#StartHour"));
		}
	}
}

function changeTargetType() {
	var reserved1 = $("#VacFlag > select").find(':selected').data('reserved1');
	if(reserved1==="Y") {
		vacInfoData = vacationDetailInfo($("#VacFlag > select").find(':selected').data('code').CodeID);
	}
	var vacDay = $("#VacFlag > select").find(':selected').data('reserved3');

	if ( vacDay <= 0.5 ) {
		$("#VacOffFlag").show();
		if(vacDay < 0.5){
			$("#spanTimeRange").show();
			changeStartHour($("#StartHour"));
		}else{
			$("#spanTimeRange").hide();
			$("#StartHour").val("00");
			$("#StartMin").val("00");
			$("#EndHour").val("00");
			$("#EndMin").val("00");
		}
	} else {
		$("#VacOffFlag").hide();
/*		if(vacDay < 0.5 ){
			$("#spanTimeRange").show();
			$("#StartHour").val("00");
			$("#StartMin").val("00");
			$("#EndHour").val("00");
			$("#EndMin").val("00");
		}else{
			$("#spanTimeRange").hide();
			$("#StartHour").val("00");
			$("#StartMin").val("00");
			$("#EndHour").val("00");
			$("#EndMin").val("00");
		}*/
		}
	checkCancel();
}

function checkCancel(){
	$(".selDate").each(function(idx, obj){
		$(this).toggleClass("selDate");
	});
}

function validationChk(){
	var returnVal= true;
	if ($(".selDate").length == 0){
		 Common.Warning("<spring:message code='Cache.ACC_msg_selectDate'/>", "Warning Dialog", function () {
        });
        return false;
	}
	var iDay = 0;
	$(".selDate").each(function(idx, obj){
		var dataStr = $(obj).find("div p").attr("data-map");
/*   		if (dataStr == undefined || dataStr == "") {
   			Common.Warning(Common.getDic("근무가 설정되어 있지 않습니다."));
			returnVal = false;
			return;
   		}
   		else*/ iDay++;
	});

	if (returnVal == false) return returnVal;

	if("${authType}" === "ADMIN" && $("#resultViewDetailDiv .date_del").length === 0){
		Common.Warning("<spring:message code='Cache.msg_apv_162'/>"); // 하나 이상의 대상자를 선택하세요.
		return false;
	}

	if ($('#VacOffFlag').is(':visible')) {
		if ($("#VacOffFlag").val() == "0")
		{
			Common.Warning("<spring:message code='Cache.mag_Attendance41'/>");	 //반차사용시 오전오후를 선택해주세요.
			returnVal = false;
			return returnVal;

		}
	}

	
	return returnVal;
}

function reqVacation(){
//	var StartTime = $("#StartHour").val()+''+$("#StartMin").val();
//	var EndTime = $("#EndHour").val()+''+$("#EndMin").val();
	var authType  = "${authType}";

	var aJsonArray = new Array();
	$(".selDate").each(function(idx, obj){
		var sTime = null;
		var eTime = null;
		var reserved1 = $("#VacFlag > select").find(':selected').data('reserved1');
		var vacDay = $("#VacFlag > select").find(':selected').data('reserved3');
		if ( vacDay <= 0.5 && reserved1==="Y") {
			sTime = $("#StartHour").find(':selected').val()+":"+$("#StartMin").val();
			eTime = $("#EndHour").val()+":"+$("#EndMin").val();
			if(sTime==="00:00" && eTime==="00:00"){
				sTime = null;
				eTime = null;
			}
		}
		var saveData = {
			"VacFlag":coviCtrl.getSelected('VacFlag').val
			, "VacOffFlag":$("#VacOffFlag").val()
			, "WorkDate":$(obj).attr("title")
			, "startTime":sTime
			, "endTime":eTime
		};
        aJsonArray.push(saveData);
	});

	var saveJson = {
		"ReqType": "V",
		"ReqGubun": "C",
		"Comment": $("#Comment").val(),
		"ReqData": aJsonArray
	}

	// 관리자 - 휴가 생성
	if (authType && authType === "ADMIN") {
		var targetArr = new Array();

		$('#resultViewDetailDiv').find('.date_del').each(function (i, v){
			var item = $(v);
			var saveData = {"Type": item.attr('type'), "Code": item.attr('code'), "Name": item.text()};
			targetArr.push(saveData);
		});

		saveJson["VacYear"] = "${VacYear}";
		saveJson["TargetData"] = targetArr;
		saveJson["AuthType"] = authType;
	}

	//insert 호출
	$.ajax({
		type: "POST",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		url: "/groupware/attendReq/requestVacation.do",
		data: JSON.stringify(saveJson),
		success: function(data){
			if (data.status === 'SUCCESS') {
				if (authType && authType === "ADMIN" && data.usedCnt > 0) {
					parent.AttendUtils.openUsedVacationPopup(saveJson["VacYear"], data.userCodeList);
					Common.Close();
				} else {
					Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information", function(result){ //저장되었습니다.
						if (result) Common.Close();
					});
				}
			} else {
				if (data.errorCode) {
					if (data.errorCode == "msg_apv_chk_vacation") {
						var subMsg="";
						if (data.errorData) {
							subMsg = "[" + data.errorData + "]";
						}

						Common.Warning(Common.getDic(data.errorCode) + subMsg);
					} else if (data.errorCode === 9001) {
						Common.Warning("<spring:message code='Cache.mag_Attendance34' />"); // 이미 휴가 처리 되었거나 휴무(휴일) 입니다.
					}
				} else {
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
				}
			}
		},
		error: function(response, status, error){
			//TODO 추가 오류 처리
			CFN_ErrorAjax("/groupware/attendReq/requestVacation.do", response, status, error);
		}
	});
}

function getVacInfo(){
	var params = {
		  "code"	: $("#resultViewDetailDiv .date_del").eq(0).attr("code")
		, "domain"	: $("#resultViewDetailDiv .date_del").eq(0).attr("domain") ? $("#resultViewDetailDiv .date_del").eq(0).attr("domain") : Common.getSession("DN_Code")
		, "vacYear"	: "${VacYear}"
		, "vacFlag"	: $("#VacFlag select").val()
	};

	$.ajax({
		url: "/groupware/attendReq/getVacationInfo.do",
		type: "POST",
		async: false,
		data: params,
		success: function(res){
			if (res.status === 'SUCCESS') {
				if (res.data) {
					var vacInfo = res.data;
					var vacText = String.format("{0}<spring:message code='Cache.lbl_day'/>(<spring:message code='Cache.lbl_Use'/> : {1}) <spring:message code='Cache.lbl_n_att_remain'/> : {2}", vacInfo.VacDay, vacInfo.UseDays, vacInfo.ATot);

					$("#VacDay").text(vacText);
				}
			} else {
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/attendReq/getVacationInfo.do", response, status, error);
		}
	});
}

//조직도 팝업
function openOrgMapLayerPopup(reqTar) {
	AttendUtils.openOrgChart("${authType}", "orgMapLayerPopupCallBack");
}

// 조직도 팝업 콜백
function orgMapLayerPopupCallBack(orgData) {
	var data = $.parseJSON(orgData);
	var item = data.item

	if (item != '') {
		var reqOrgMapTarDiv = 'resultViewDetailDiv';
		var duplication = false; // 중복 여부
		$.each(item, function (i, v) {
			var cloned = orgMapDivEl.clone();
			var type = (v.itemType == 'user') ? 'UR' : 'GR';
			var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;

			if ($('#' + reqOrgMapTarDiv).find(".date_del[type='"+ type+"'][code='"+ code+"']").length > 0) {
				duplication = true;
				return true;
			}

			cloned.attr('type', type).attr('code', code);
			cloned.find('.ui-icon-close').before(CFN_GetDicInfo(v.DN));

			$('#' + reqOrgMapTarDiv + ' .ui-autocomplete-input').before(cloned);
		});

		if(duplication){
			Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
		}

		// 연차 표시
		if ($("#resultViewDetailDiv .date_del").length === 1 && $("#resultViewDetailDiv .date_del").attr("type") === "UR") {
			getVacInfo();
			$("#tr_vaclist").show();
			loadVacationInfo();
			onePersonScheView();
		} else if ($("#resultViewDetailDiv .date_del").length == 0) {
			$("#VacDay").text("");
			$("#tr_vaclist").hide();
		} else {
			$("#VacDay").text(Common.getDic("<spring:message code='Cache.msg_notViewPeopleVacInfo' />")); // 다수 인원 지정 시 잔여연차 정보는 표기되지 않습니다.
			$("#tr_vaclist").hide();
			onePersonScheView();
		}
	}
	vacInfoData = vacationDetailInfo($("#VacFlag > select").find(':selected').data('code').CodeID);
}

//사용자나 부서/ 일자 삭제
$(document).on('click', '.ui-icon-close', function(e) {
	e.preventDefault();
	$(this).parent().remove();

	// 연차 표시
	if ($("#resultViewDetailDiv .date_del").length === 1 && $("#resultViewDetailDiv .date_del").attr("type") === "UR") {
		getVacInfo();
		onePersonScheView();
		$("#tr_vaclist").show();
		loadVacationInfo();
	} else if ($("#resultViewDetailDiv .date_del").length == 0) {
		$("#VacDay").text("");
		$("#tr_vaclist").hide();
	} else {
		$("#VacDay").text(Common.getDic("<spring:message code='Cache.msg_notViewPeopleVacInfo' />")); // 다수 인원 지정 시 잔여연차 정보는 표기되지 않습니다.
		$("#tr_vaclist").hide();
		onePersonScheView();
	}
});

function onePersonScheView(){
	var mode = "";
	var standDay = replaceDate($("#dateTitle").text());
	if (standDay.length==7) standDay+="/01";
	<c:choose>
	<c:when test="${authType eq 'ADMIN'}">
	if ($("#resultViewDetailDiv .date_del").length === 1 && $("#resultViewDetailDiv .date_del").eq(0).attr("type") === "UR") {
		mode = "";
	}else{
		mode = "${authType}" === "ADMIN" ? "ONLY" : "";
	}
	</c:when>
	</c:choose>
	AttendUtils.getScheduleMonth(schedule_SetDateFormat(standDay,'-'), "calendar", "dateTitle", mode, "calTbody");
}
</script>