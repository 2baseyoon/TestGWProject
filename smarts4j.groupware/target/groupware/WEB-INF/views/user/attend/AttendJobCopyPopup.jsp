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
.selDate {background-color:#6d6e71;color:#fff!important}
.setDate {background-color: #f5e3d9;}
.org_list_box_attend{display:flex; flex-wrap:wrap; flex:1 1 auto; min-height:30px; height:auto !important; max-height: 186px; overflow:hidden auto; padding:1px 2px;}
.org_list_box_attend input{width:100px !important; border:0px !important; vertical-align:middle !important;}
</style>
</head>
<body>
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="ATMgt_popup_wrap">
			<div class="ATMgt_work_wrap">
				<table class="ATMgt_popup_table type03" cellpadding="0" cellspacing="0">
					<tbody>
					 <tr>
					 	<td class="ATMgt_T_th"><spring:message code='Cache.ObjectType_UR' /></span></td>
						<td colspan=3>
								<div class="ATMgt_T">
									<div class="ATMgt_T_l">
									<div class="org_list_box_attend" id="resultViewDetailDiv">
										<input id="resultViewDetailInput" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS"  autocomplete="off">
									</div>
									</div>
									<div class="ATMgt_T_r" style="width: 70px;vertical-align:middle;">
										<a class="btnTypeDefault nonHover type01" onclick="openOrgMapLayerPopup('resultViewDetailDiv')"><spring:message code='Cache.btn_OrgManage' /></a> <!-- 조직도 -->
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
					  <tr hidden>
		             	<td colspan=4>
							<div class="date_del_scroll" id="resultViewDateDiv">
								<input id="resultViewDateInput" type="text" class="ui-autocomplete-input HtmlCheckXSS ScriptCheckXSS" style="display:none" autocomplete="off">
							</div>
		             	</td>
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
							<td class="tx_sun"><p class="tx_day"></p></td>
							<td><p class="tx_day"></p></td>
							<td><p class="tx_day"></p></td>
							<td><p class="tx_day"></p></td>
							<td><p class="tx_day"></p></td>
							<td><p class="tx_day"></p></td>
							<td class="tx_sat"><p class="tx_day"></p></td>
						</tr>
						</c:forEach>
					</tbody>
			  </table>
			</div>
			<div class="bottom">
				<a id="btnCopy"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.lbl_Copy'/></a> 	<!-- 저장 -->
				<a id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
			</div>
		</div>	
	</div>	
</div>
</body>
<script>
var orgMapDivEl = $("<p/>", {'class' : 'date_del', attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'ui-icon ui-icon-close'}));
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


$(document).ready(function(){
	coviCtrl.setCustomAjaxAutoTags('resultViewDetailInput', '/groupware/attendCommon/getAttendUserGroupAutoTagList.do', MultiAutoInfos);	// 근태대상
	$(".ui-autocomplete-multiselect.ui-state-default.ui-widget").removeAttr('style');
	AttendUtils.getScheduleMonth( CFN_GetLocalCurrentDate("yyyy-MM-dd"), "calendar", "dateTitle", "ONLY", "calTbody");
	$('#resultViewDetailInput').parent().css('width', '100%');
	
	//event 세팅
	$(".pre").click(function(){
		AttendUtils.goScheduleNextPrev(-1, "calendar", "dateTitle", "ONLY", "calTbody");
	});
	$(".next").click(function(){
		AttendUtils.goScheduleNextPrev(1, "calendar", "dateTitle", "ONLY", "calTbody");
	});

	//$('#resultViewDetailInput').parent().css('width', 'calc(100% - 100px)');
	//event 세팅
	$('#btnCopy').click(function(){
		copyScheduleJob();
	});
	
	$('#btnClose').click(function(){
		Common.Close();
	});	
	
	//휴무일제외 토글
	$(".onOffBtn").click(function(e){
		$(this).toggleClass( "on" );
	});

	
});


$(document).on("click",".calDate",function(){
	$(this).toggleClass("selDate");
	var reqDateMapTarDiv = 'resultViewDateDiv' ;
	var type = 'UR';
	var code = $(this).attr("title");

	if ($(this).hasClass("selDate")){
		var cloned = orgMapDivEl.clone();
		cloned.attr('type', type).attr('code', code);
		cloned.find('.ui-icon-close').before(code);
		$('#' + reqDateMapTarDiv + ' .ui-autocomplete-input').before(cloned);
	} else {
		$('#' + reqDateMapTarDiv).find(".date_del[type='"+ type+"'][code='"+ code+"']").remove();
	}
	
});

function copyScheduleJob(){
	var targetArr = new Array();
	var targetDateArr = new Array();
	var orgJobDate = "${JobDate}";
	var orgUserCode = "${UserCode}";
	$('#resultViewDetailDiv').find('.date_del').each(function (i, v) {
		var item = $(v);
		var saveData = { "Type":item.attr('type'), "Code":item.attr('code')};
		targetArr.push(saveData);
	});
	if(targetArr.length == 0){
		Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");
		return;
	}
	
	$('#resultViewDateDiv').find('.date_del').each(function (i, v) {
		var item = $(v);
		targetDateArr.push(item.attr('code'));
	});
	if(targetDateArr.length == 0){
		Common.Warning("<spring:message code='Cache.msg_AttendanceDate'/>");
		return;
	}

	Common.Confirm("<spring:message code='Cache.msg_RUCopy' />", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) { 
			$.ajax({
				type:"POST",
				contentType:'application/json; charset=utf-8',
				dataType   : 'json',
				data:JSON.stringify({ "trgUsers" : targetArr  
					, "trgDates": targetDateArr
					, "orgJobDate": orgJobDate
				    , "orgUserCode": orgUserCode
					, "HolidayFlag":$("#HolidayFlag").is(":checked")?"Y":"N"
					, "WeekFlag":$("#WeekFlag").is(":checked")?"Y":"N"
					}),
				url:"/groupware/attendJob/copyAttendScheduleJob.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_task_completeCopy'/>");	//복사되었습니다.
						parent.searchData();
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
	});	
			
}
// 조직도 팝업
function openOrgMapLayerPopup(reqTar) {
	
	AttendUtils.openOrgChart("${authType}", "orgMapLayerPopupCallBack");
/*	url = "/covicore/control/goOrgChart.do?callBackFunc=orgMapLayerPopupCallBack&type=B9&treeKind=Group&groupDivision=Basic";			
	title = "<spring:message code='Cache.lbl_att_specifier_add'/>"; // 근무상태
	var w = "1000";
	var h = "580";
	CFN_OpenWindow(url,"openGroupLayerPop",1060,580,"");*/
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

// 사용자나 부서/ 일자 삭제
$(document).on('click', '.ui-icon-close', function(e) {
	e.preventDefault();
	
	$(this).parent().remove();
});

</script>