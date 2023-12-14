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
			<div>
				<table class="ATMgt_popup_table type02" cellspacing="0" cellpadding="0">
				<tbody>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Time'/></td>
						<td>
							<div class="ATMgt_T">
								<div class="ATMgt_T_Time">
									<select id="StartHour" name="StartHour">
										<c:forEach begin="00" end="23" var="hour">
											<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>" ><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
										</c:forEach>
									</select>
									<span>:</span>
									<input type="text" name="StartMin"  id="StartMin" maxlength="2" value="00" />
									<span>-</span>
									<select id="EndHour" name="EndHour">
										<c:forEach begin="00" end="23" var="hour">
											<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>" ><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
										</c:forEach>
									</select>
									<span>:</span> 
									<input type="text" name="EndMin"  id="EndMin" maxlength="2" value="00"/>
								</div>
							</div>
						</td>
					</tr>
					<c:choose>
						<c:when test="${authType eq 'ADMIN'}">
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_hrMng_targetUser' /></td> <!-- 대상자 -->
								<td>
								<div class="ATMgt_T">
									<div class="ATMgt_T_l">
									<div class="org_list_box_attend" id="resultViewDetailDiv">
										<input id="resultViewDetailInput" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS" autocomplete="off">
									</div>	
									</div>
									<div class="ATMgt_T_r" style="width: 70px;vertical-align:middle;">
										<a class="btnTypeDefault nonHover type01" onclick="openOrgMapLayerPopup('resultViewDetailDiv')"><spring:message code='Cache.btn_OrgManage' /></a> <!-- 조직도 -->
									</div>
								</div>	
								</td>
							</tr>
						</c:when>
						<c:otherwise>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Approver' /></td>
								<td>${UR_ManagerName}</td>
							</tr>
						</c:otherwise>
					</c:choose>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Remark'/></td>
						<td><textarea id="Comment" name="Comment" class="ATMgt_Tarea"></textarea></td>
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
			<a id="btnReq" class="btnTypeDefault btnTypeChk"><%=AttendUtils.getRequestName(request.getParameter("ReqMethod"))%></a> 	<!-- 신청하기 -->
			<a id="btnClose" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
		</div>
	</div>
<script type="text/javascript">
var orgMapDivEl = $("<p/>", {'class' : 'date_del', attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'ui-icon ui-icon-close'}));
var orgCalTtlE1 = $(".WTab").html();
var orgCalContE1 = $(".WTemp_cal_wrap").html();

var g_JobStsName = "";
var g_JobStsSeq  = "${JobStsSeq}";

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
	}
};

$(document).ready(function(){
	coviCtrl.setCustomAjaxAutoTags('resultViewDetailInput', '/groupware/attendCommon/getAttendUserGroupAutoTagList.do', MultiAutoInfos);	// 근태대상
	$(".ui-autocomplete-multiselect.ui-state-default.ui-widget").removeAttr('style');

	var mode = "${authType}" === "ADMIN" ? "ONLY" : "";
	var g_curDate = CFN_GetLocalCurrentDate("yyyyMMdd");
	AttendUtils.getScheduleMonth(CFN_GetLocalCurrentDate("yyyy-MM-dd"), "calendar", "dateTitle", mode, "calTbody");

	//event 세팅
	$(".WTemp_cal_wrap .pre").click(function(){
		AttendUtils.goScheduleNextPrev(-1, "calendar", "dateTitle", mode, "calTbody");
	});
	$(".WTemp_cal_wrap .next").click(function(){
		AttendUtils.goScheduleNextPrev(1, "calendar", "dateTitle", mode, "calTbody");
	});


	$('#btnReq').click(function(){
		if(!validationChk())     	return ;
		Common.Confirm("<spring:message code='Cache.ACC_isAppCk' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				reqJobStatus();
			}
		});
	});
	
	$('#btnClose').click(function(){
		Common.Close();
	});

	if(g_JobStsSeq!=null && g_JobStsSeq!=""){
		$.ajax({
			type:"POST",
			url : "/groupware/attendCommon/getOtherJobList.do",
			data : {
				'JobStsSeq': g_JobStsSeq
			},
			success : function(data){
				if(data.status=='SUCCESS'){
					g_JobStsName = data.jobList[0].JobStsName;
				}else{
					g_JobStsName = "${JobStsName}";
				}
			}
		});
	}
	
});

$(document).on("click",".calDate",function(){
	if ("${authType}" !== "ADMIN") {
		var dataStr = $(this).find("div p").attr("data-map");
		
		if (dataStr == undefined || dataStr == "") {
			Common.Warning(Common.getDic("<spring:message code='Cache.mag_Attendance26'/>"));			//근무가 설정되어 있지 않습니다.
			return false;
		}
		else{
			var dataMap = JSON.parse(dataStr);
			if (dataMap["ConfmYn"] == "Y"){
				Common.Warning("<spring:message code='Cache.msg_apv_personnel_items_modify_refresh' />");
				return;
			}
			if ((dataMap["VacFlag"]!="N" &&  dataMap["VacDay"]=="1" ) 	|| (dataMap["WorkSts"]=="OFF" || (dataMap["WorkSts"]=="HOL"))){
				Common.Warning("<spring:message code='Cache.mag_Attendance34'/>");			//이미 휴가 처리 되었거나 휴무(휴일) 입니다.
				return false;
			}
		}
	}
	
	$(this).toggleClass("selDate");
	
});

function validationChk(){
	var returnVal= true;
	
	// 날짜 선택
	if ($(".selDate").length == 0){
		Common.Warning("<spring:message code='Cache.ACC_msg_selectDate'/>");
		return false;
	}
	// 시작시간 종료시간
	var attDayStartTime = $("#StartHour").val()+''+$("#StartMin").val();
	var attDayEndTime = $("#EndHour").val()+''+$("#EndMin").val();
	
	if(attDayStartTime>= attDayEndTime && !$("#NextDayYn").prop("checked")){
		Common.Warning("<spring:message code='Cache.msg_Mobile_InvalidStartTime'/>");			//시작일은 종료일 보다 이후일 수 없습니다.
		return false;
	}
	
	if ("${authType}" === "ADMIN") {
		if ($("#resultViewDetailDiv .date_del").length === 0) {
			Common.Warning("<spring:message code='Cache.msg_apv_162'/>"); // 하나 이상의 대상자를 선택하세요.
			return false;
		}
	} else {
		$(".selDate").each(function(idx, obj){
			var dataStr = $(obj).find("div p").attr("data-map");
			if (dataStr == undefined || dataStr == "") {
				Common.Warning(Common.getDic("<spring:message code='Cache.mag_Attendance26'/>"));			//근무가 설정되어 있지 않습니다.
				returnVal = false;
				return;	
			}
			var dataMap = JSON.parse(dataStr);
			if ((dataMap["VacFlag"]!="N" &&  dataMap["VacDay"]=="1" ) || (dataMap["WorkSts"]=="OFF" || dataMap["WorkSts"]=="HOL" )){
				Common.Warning("<spring:message code='Cache.mag_Attendance34'/>");			//이미 휴가 처리 되었거나 휴무(휴일) 입니다.
				returnVal = false;
				return;	
			}
			if (attDayEndTime > dataMap["AttDayEndTime"].replace(":",""))
			{
				Common.Warning(Common.getDic("<spring:message code='Cache.mag_Attendance35'/>"), "Confirmation Dialog", function (confirmResult) {});			//근무 종료 이후에는 근무를 신청할 수 없습니다.	
				returnVal = false;
				return;	
			}
		});
	}
	
	return returnVal;
}

function reqJobStatus(){
	var StartTime = $("#StartHour").val()+''+$("#StartMin").val();
	var EndTime = $("#EndHour").val()+''+$("#EndMin").val();
	var authType  = "${authType}";
	
	var aJsonArray = new Array();
	$(".selDate").each(function(idx, obj){
		var saveData = {"JobStsSeq": "${JobStsSeq}", "JobStsName": g_JobStsName, "WorkDate": $(obj).attr("title"), "StartTime": StartTime, "EndTime": EndTime};
		aJsonArray.push(saveData);
	});
	
	var saveJson = {
		"ReqType": "J",
		"ReqGubun": "C",
		"Comment": $("#Comment").val(),
		"ReqData": aJsonArray
	}
	
	// 관리자 - 기타근무 생성
	if (authType && authType === "ADMIN") {
		var targetArr = new Array();
		$('#resultViewDetailDiv').find('.date_del').each(function (i, v){
			var item = $(v);
			var saveData = {"Type": item.attr('type'), "Code": item.attr('code'), "Name": item.text()};
			targetArr.push(saveData);
		});
		
		saveJson["TargetData"] = targetArr;
		saveJson["AuthType"] = authType;
	}
	
	//insert 호출		
	 $.ajax({
			type:"POST",
			contentType:"application/json; charset=utf-8",
			dataType   : "json",
            url : "/groupware/attendReq/requestJobStatus.do",
            data : JSON.stringify(saveJson),
            success : function(data){	
            	if(data.status=='SUCCESS'){
	            	Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>","Information",function(){ //저장되었습니다.
						Common.Close();
	            	});
            	}else{
            		Common.Warning("<spring:message code='Cache.msg_att_overlapping'/>");
            	}
            },
            error:function(response, status, error){
                //TODO 추가 오류 처리
                CFN_ErrorAjax("attendReq/requestJobStatus.do", response, status, error);
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
	var len = item.length;
	
	if (item != '') {
		var reqOrgMapTarDiv = 'resultViewDetailDiv';
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
</body>
