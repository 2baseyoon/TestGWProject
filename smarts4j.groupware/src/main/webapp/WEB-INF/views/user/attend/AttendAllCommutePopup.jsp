<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
		
		.chkStyle04 { margin-right: 8px; }
	</style>
</head>
<body>
	<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="ATMgt_popup_wrap">
			<div class="ATMgt_work_wrap">
				<table class="ATMgt_popup_table type02" cellspacing="0" cellpadding="0">
					<colgroup>
						<col width="115">
						<col width="*">
						<col width="115">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_hrMng_targetUser'/></td> <!-- 대상자 -->
							<td colspan=3>
								<div class="date_del_scroll ATMgt_T" id="resultViewDetailDiv">
									<input id="resultViewDetailInput" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS" autocomplete="off">
									<div class="ATMgt_T_r" style="width: 70px;">
										<a id="orgBtn" class="btnTypeDefault nonHover type01"><spring:message code='Cache.btn_OrgManage'/></a> <!-- 조직도 -->
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_allCommuteOption'/></td> <!-- 일괄출퇴근 옵션 -->
							<td colspan=3>
								<span class="chkStyle04 chkType01">
									<input type="checkbox" id="allGoWork" name="attCommute">
									<label for="allGoWork"><span><span></span></span><spring:message code='Cache.lbl_allGoWork'/></label> <!-- 일괄출근 -->
								</span>
								<span class="chkStyle04 chkType01">
									<input type="checkbox" id="allOffWork" name="attCommute">
									<label for="allOffWork"><span><span></span></span><spring:message code='Cache.lbl_allOffWork'/></label> <!-- 일괄퇴근 -->
								</span>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="WTemp_cal_Top" id="myTabTtl">
				<div class="WTemp_cal_Tab">
					<div class="WTab on" data="0">
						<a class="WTemp_cal_date" id="dateTitle_0"></a>
						<div class="pagingType01">
							<a class="pre" href="#"></a>
							<a class="next" href="#"></a>
							<a class="close" href="#">X</a>
						</div>
					</div>
				</div>	
				<a class="addBtn" id="addTab" herf="#">+</a>
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
		</div>
		<div class="bottom">
			<a id="btnApply" class="btnTypeDefault btnTypeChk" href="#"><spring:message code='Cache.btn_Apply'/></a> <!-- 적용 -->
			<a id="btnExcelUpload" class="btnTypeDefault btnExcel" href="#"><spring:message code='Cache.btn_ExcelUpload'/></a> <!-- 엑셀 업로드 -->
			<a id="btnCancel" class="btnTypeDefault" href="#"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
		</div>
	</div>
</body>
<script>
var orgMapDivEl = $("<p/>", {'class' : 'date_del', attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'ui-icon ui-icon-close'}));
var orgCalTtlE1 = $(".WTab").html();
var orgCalContE1 = $(".WTemp_cal_wrap").html();

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
		var type = "UR";
		
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
	coviCtrl.setCustomAjaxAutoTags('resultViewDetailInput', '/groupware/attendCommon/getAttendUserGroupAutoTagList.do', MultiAutoInfos); // 대상자 자동완성 설정
	
	AttendUtils.getScheduleMonth(CFN_GetLocalCurrentDate("yyyy-MM-dd"), "calendar_0", "dateTitle_0", "ONLY", "calTbody");
	
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
	
	// 조직도
	$("#orgBtn").off("click").on("click", function(){
		openOrgMapLayerPopup('resultViewDetailDiv');
	});
	
	// 적용
	$("#btnApply").off("click").on("click", function(){
		if (!validationChk()) return;
		setAllCommute();
	});
	
	// 엑셀 업로드
	$("#btnExcelUpload").off("click").on("click", function(){
		openExcelUploadPopup();
	});
	
	// 취소
	$("#btnCancel").off("click").on("click", function(){
		Common.Close();
	});
});

$(document).on("click", ".WTemp_cal_date", function(){
	$("#myTabCont .WTemp_cal_wrap").hide();
	$("#myTabTtl .WTab").removeClass("on");
	$(this).parent().addClass("on");
	var j = $("#myTabTtl .WTab").index($(this).parent()); 
	
	$("#myTabCont .WTemp_cal_wrap:eq("+j+")").show();
	
	$("#workTotMonthTime strong").text($("#myTabCont .WTemp_cal_wrap:eq("+j+") #workMonthTime").text());
});

$(document).on("click", ".pre", function(){
	var data = $(this).parent().parent().attr("data")
	AttendUtils.goScheduleNextPrev(-1, "calendar_"+data, "dateTitle_"+data, "ONLY", "calTbody");
});

$(document).on("click", ".next", function(){
	var data = $(this).parent().parent().attr("data")
	AttendUtils.goScheduleNextPrev(1, "calendar_"+data, "dateTitle_"+data, "ONLY", "calTbody");
});

$(document).on("click", ".close", function(){
	event.stopPropagation();
	
	if ($("#myTabTtl .WTab").size() > 1 ){
		var j = $("#myTabTtl .WTab").index($(this).parent().parent());
		var bOn = $("#myTabTtl .WTab:eq("+j+")").hasClass("on");
			
		$("#myTabTtl .WTab:eq("+j+")").remove();
		$("#myTabCont .WTemp_cal_wrap:eq("+j+")").remove();
		
		if (bOn) {
			$("#myTabTtl .WTab:eq(0)").addClass("on");
			$("#myTabCont .WTemp_cal_wrap:eq(0)").show();
		}
	}	
});

$(document).on("click", ".calDate", function(){
	$(this).toggleClass("selDate");
});

function validationChk(){
	if ($('#resultViewDetailDiv .date_del').length == 0) {
		Common.Warning("<spring:message code='Cache.msg_apv_162'/>"); // 하나 이상의 대상자를 선택하세요.
		return false;
	}
	
	if ($("input[name=attCommute]:checked").length == 0) {
		Common.Warning("<spring:message code='Cache.msg_apv_243'/>"); // 옵션을 선택하셔야 합니다.
		return false;
	}
	
	if ($(".selDate").length == 0) {
		Common.Warning("<spring:message code='Cache.ACC_msg_selectDate'/>"); // 날짜를 선택해 주세요.
		return false;
	} else {
		var today = new Date(CFN_GetLocalCurrentDate("yyyy-MM-dd").replaceAll("-", "/")).getTime();
		var retValue = true;
		
		$(".selDate").each(function(idx, obj){
			var selDate = new Date($(obj).attr("title").replaceAll("-", "/")).getTime();
			
			if (today < selDate) {
				Common.Warning("<spring:message code='Cache.msg_onlyWorkPreDay'/>"); // 현재보다 이전 일에만 작업이 가능합니다.
				retValue = false;
				return;
			}
		});
		
		return retValue;
	}
	
	for (var i = 0; i < $(".WTab").length; i++){
		for (var j = 0; j < $(".WTab").length; j++){
			if (i != j){
				if ($(".WTab:eq("+i+") .WTemp_cal_date").text() == $(".WTab:eq("+j+") .WTemp_cal_date").text()) {
					Common.Warning("<spring:message code='Cache.lbl_monthDup'/>");
			        return false;
				}
			}
		}
	}
	
	return true;
}

function setAllCommute(){
	var aJsonArray = new Array();
	$(".selDate").each(function(idx, obj){
		var saveData = {"WorkDate": $(obj).attr("title")};
		aJsonArray.push(saveData);
	});
	
	var targetArr = new Array();
	$('#resultViewDetailDiv').find('.date_del').each(function (i, v){
		var item = $(v);
		var saveData = {"Type": item.attr('type'), "Code": item.attr('code'), "Name": item.text()};
		targetArr.push(saveData);
	});
	
	var params = {
		  "ReqData"		: aJsonArray
		, "TargetData"	: targetArr
		, "IsGoWork"	: $("#allGoWork:checked").length ? "Y" : "N"
		, "IsOffWork"	: $("#allOffWork:checked").length ? "Y" : "N"
	};
	
	$.ajax({
		url: "/groupware/attendUserSts/setAllCommute.do",
		type: "POST",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		data: JSON.stringify(params),
		success: function(res){	
			if (res.status === 'SUCCESS') {
				Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information", function(result){ // 요청하신 작업이 정상적으로 처리되었습니다.
					if (result) {
						Common.Close();
					}
				});
			} else {
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/attendUserSts/setAllCommute.do", response, status, error);
		}
	});
}

// 엑셀 업로드 팝업
function openExcelUploadPopup(){
	parent.AttendUtils.openAllCommuteExcelPopup();
	Common.Close();
}

//조직도 팝업
function openOrgMapLayerPopup(reqTar){
	AttendUtils.openOrgChart("ADMIN", "orgMapLayerPopupCallBack");
}

// 조직도 팝업 콜백
function orgMapLayerPopupCallBack(orgData){
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
				return true;
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
$(document).on('click', '.ui-icon-close', function(e){
	e.preventDefault();
	$(this).parent().remove();
});
</script>