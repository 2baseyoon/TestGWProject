<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<% String approvalAppPath = PropertiesUtil.getGlobalProperties().getProperty("approval.app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style>

	.layer_divpop table,p {font-size:12px}
	.bottom {
		padding:10px 0 0 0;	
	}
	#at_userEtc {
		width:80% ; height:45px
	}
	userEtcBtn {
		width:20% ;
	}	
	.at_time .btnNoticeOder{
	    margin: 0 0 0 5px;
	}
</style>
<body>	

<!-- 근태기록 추가 및 수정 팝업 시작 -->
<!-- <div class="layer_divpop" style="width:500px; left:0; top:0; z-index:104;"> -->
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="" style="overflow:hidden; padding:0;">
		<div class="ATMgt_popup_wrap">
			<!-- <p class="ATMgt_popup_title" id="titleName"></p> -->
			<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
				<colgroup>
					<col width='115px'/>
					<col />
					<col width='115px'/>
					<col />
				</colgroup>
				<tbody>
					<!-- <tr>
						<td class="ATMgt_T_th">지점</td>
						<td><p class="tx_company">본사</p></td>
					</tr> -->
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_date' /></td>
						<td colspan=3>
							<div class="dateSel type02">
								<input class="adDate" data-axbind="date" date_separator="."  type="text" id="AXInput-1" kind="date" >
							</div>
						</td> 
					</tr>
					
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_worktype' />/<spring:message code='Cache.lbl_dept' /></td>
						<td><p class="tx_dept w100 noResult" id="at_dept"></p></td>
						
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_Staff' /></td>	
						<td>
							<div class="ATMgt_T2">
								<div class="ATMgt_T_l">
									<p class="tx_company noResult" id="at_name">&nbsp;</p>
								</div>	
								<div class="ATMgt_T_r"  id="btnOrg" style="display:none">
									<a class="btnTypeDefault nonHover type01" onclick="openGroupLayer()"><spring:message code='Cache.btn_OrgManage' /></a>
								</div>	
							</div>
						</td>
					</tr>
					<tr> 
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_worksch' /></td>	
						<td><p class="tx_template w100 noResult" id="at_schName"></p></td>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_certainTime' /></td>
						<td><p class="" id="at_attDayTime"></p></td>
					</tr>
					
					<tr>
						<td class="ATMgt_T_th at_time"><spring:message code='Cache.lbl_startdate2' /></td>
						<td><p class="" id="at_startDate"></p></td>
						<td class="ATMgt_T_th at_time"><spring:message code='Cache.lbl_EndDate3' /></td>
						<td><p class="" id="at_endDate"></p></td>
					</tr>
					
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_overtime_work' /></td>	
						<td>
							<p class="" id="at_extenTime"></p>
						</td>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_holiday_work' /></td>	
						<td>
							<p class="" id="at_holiTime"></p>
						</td>
					</tr>
					
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_otherjob_sts' /></td>	
						<td>
							<p class="" id="at_jobStsName"></p>
						</td>
						<td class="ATMgt_T_th td_etc"><spring:message code='Cache.lbl_n_att_coreTime' /></td>
						<td>
							<p class="td_etc" id="at_coreTime"></p>
						</td>
					</tr>
					<tr id="monthlyWorkingTimeTr" style="display:none">
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_AccWorkMonth' /></td> <!-- 월 누적 근무시간 -->
						<td colspan=3>
							<p class="td_etc" id="monthlyWorkingTime"></p>
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_User' /> <spring:message code='Cache.lbl_Remark' /></td>	
						<td colspan=3 id="at_userEtcTd">
							
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_worknote' /></td>	
						<td id="at_etcTd">
							<p class="" id="at_etc"></p>
						</td>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_apv_vacation_statistics' /></td>
						<td id="at_vacationInfoTd">
							<p class="" id="at_vacinfo"></p>
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th" colspan=2><spring:message code='Cache.lbl_over' />/<spring:message code='Cache.lbl_Holiday' />/<spring:message code='Cache.lbl_app_calling' />/
							<spring:message code='Cache.lbl_Vacation' />(<spring:message code='Cache.lbl_show_form' />)</td>	
						<td colspan=2 >
							<p class="" id="at_app"></p>
						</td>
					</tr>
				</tbody>
			</table>
			
			<div class="bottom">
				<a href="#" class="btnTypeDefault" onclick="parent.Common.close('AttendMyStstusPopup');"><spring:message code='Cache.lbl_close' /></a>
			</div>
		</div>				
	</div>
</div>
<!-- 근태기록 추가 및 수정 팝업 끝 -->
<input type="hidden" id="userCode" value="${userCode}" >

<!-- 기타근무 레이어 팝업 (연장/휴일근무 다건일 경우 공유 )-->
<div id="divJobPopup" style="display:none">
	<div class="ATMgt_Work_Popup">
		<a class="Btn_Popup_close" onclick='AttendUtils.hideAttJobListPopup();'></a>
		<div class="ATMgt_Cont" id="jobListInfo"></div>
		<div class="bottom">
			<a href="#" class="btnTypeDefault" onclick='AttendUtils.hideAttJobListPopup();'><spring:message code='Cache.lbl_close' /></a>
		</div> 
	</div>
</div>
</body>
<script>
var _userCode = "${userCode}";
var _targetDate = "${targetDate}";
var _mngType = "${mngType}";

var _attendAuth = "${authType}";

$(document).ready(function(){
	init();
	if (_userCode != "")		getMyAttInfo();
	coviInput.setDate();
	
	if("ADMIN"==_attendAuth	&& "Y"==_mngType) {
		$("#btnOrg").show();
		$(".at_time").append("<a href='#' class='btnNoticeOder'>&nbsp;</a>");
		$(".btnNoticeOder").hide();
		$(".btnNoticeOder").on('click',function(){
			parent.AttendUtils.openAttStatusSetPopup(_userCode,_targetDate);
			parent.Common.close('AttendMyStstusPopup');
		});
	}
	
	// 연장/기타근무 수정내역이 있을 수 있기에 reload.
	$("div.bottom a").click(function() {
		parent.getMyAttInfo()
	});

});

function init(){	
	$("#AXInput-1").val(_targetDate.replaceAll("-","."));

	$("#AXInput-1").on('change',function(){
		_targetDate = this.value;
		if (_userCode != "")		getMyAttInfo();
	});
}

function getMyAttInfo(){

	var params = {
		targetDate : _targetDate
		,sUserCode : _userCode
	}
	
	$.ajax({
		type : "POST",
		data : params,
		url : "/groupware/attendUserSts/getMyAttStatusInfo.do",
		success:function (data) {
			if(data.status=="SUCCESS"){
				
				
				var attMap = data.attMap;
				var userAtt = attMap.userAtt[0];
				
				var userAttList = userAtt.userAttList[0];
				
				if(userAttList.AttConfirmYn == "Y" && Common.getBaseConfig("AttConfirmYn") == "Y") {
					if("ADMIN"==_attendAuth	&& "Y"==_mngType) {
						$(".btnNoticeOder").show();	
					} else {
						$(".btnNoticeOder").remove();	
					}	
				} else {
					$(".btnNoticeOder").show();
				}
				
				var userAttWorkTime = userAtt.userAttWorkTime;
				var monthlyMaxWorkTime = data.monthlyMaxWorkTime;
				
				$("#at_dept").html(userAtt.deptName);
				$("#at_name").html(userAtt.displayName);
				
				var spNum = 15;
				var schName = "";
				if(userAttList.SchName != null)
					schName = userAttList.SchName.length > spNum ? userAttList.SchName.substring(0,spNum)+".." : userAttList.SchName;
				
				$("#at_schName").html(schName);

				//일정시간
				var attDayTime = userAttList.v_AttDayStartTime!=null && userAttList.v_AttDayStartTime!="" ? userAttList.v_AttDayStartTime+"~"+userAttList.v_AttDayEndTime :"";
				$("#at_attDayTime").html('<span class="a_time">'+attDayTime+'</span>');
				if(
						userAttList.WorkPointX!=null && userAttList.WorkPointX!=''
						&& userAttList.WorkPointY!=null && userAttList.WorkPointY!=''
				){
					var jobPoi = $('<a />', {
						class			: "btn_gps_chk"
						,"data-point-x" : userAttList.WorkPointX
						,"data-point-y" : userAttList.WorkPointY
						,"data-addr" : userAttList.WorkAddr
					});
					$("#at_attDayTime").append(jobPoi);
				}
				
				//출퇴근
				var startTime = userAttList.v_AttStartTime != null && userAttList.v_AttStartTime != ""?userAttList.v_AttStartTime : "";
				var endTime = userAttList.v_AttEndTime != null && userAttList.v_AttEndTime != ""?userAttList.v_AttEndTime : "";
				
				var startSts =  userAttList.StartSts != null && userAttList.StartSts != "" ? "["+Common.getDic(userAttList.StartSts)+"]":"";
				var endSts =  userAttList.EndSts != null && userAttList.EndSts != "" ?"["+Common.getDic(userAttList.EndSts)+"]":"";
				
				//출퇴근 시간 표기 여부
				if(_mngType!= "Y" && Common.getBaseConfig('CommuteTimeYn')!='Y'){
					startTime = "";
					endTime = "";
				}
				
				$("#at_startDate").html(startTime+startSts );
				$("#at_endDate").html(endTime+endSts);
				
				if(userAttList.StartSts == "lbl_n_att_callingTarget" ||  userAttList.StartSts == "lbl_att_beingLate"){
					$("#at_startDate").css("cursor", "pointer");
					$("#at_startDate").on('click',function(){
						parent.AttendUtils.openCallPopup();
					});
				} else {
					$("#at_startDate").removeAttr("style");
				}
				
				if(userAttList.EndSts == "lbl_n_att_callingTarget" ||  userAttList.EndSts == "lbl_att_leaveErly"){
					$("#at_endDate").css("cursor", "pointer");
					$("#at_endDate").on('click',function(){
						parent.AttendUtils.openCallPopup();
					});
				} else {
					$("#at_endDate").removeAttr("style");
				}
				
				if(
						userAttList.StartPointX!=null && userAttList.StartPointX!=''
						&& userAttList.StartPointY!=null && userAttList.StartPointY!=''
				){
					var startPoi = $('<a />', {
						class			: "btn_gps_chk"
						,"data-point-x" : userAttList.StartPointX
						,"data-point-y" : userAttList.StartPointY
						,"data-addr" : userAttList.StartAddr
					});
					$("#at_startDate").append(startPoi);
				}
				if(
						userAttList.EndPointX!=null && userAttList.EndPointX!=''
						&& userAttList.EndPointY!=null && userAttList.EndPointY!=''
				){
					var endPoi = $('<a />', {
						class			: "btn_gps_chk"
						,"data-point-x" : userAttList.EndPointX
						,"data-point-y" : userAttList.EndPointY
						,"data-addr" : userAttList.EndAddr
					});
					$("#at_endDate").append(endPoi);
				}

				if(userAttList.ExtenCnt > 1){
					var exHtml = $('<a />', {
						"data-usercode" : _userCode
						,"data-targetdate" : _targetDate
						,html : userAttList.ExtenAc
						,onclick : "showExhoList(this,'O')"
					}); 
					$("#at_extenTime").html(exHtml);
				}else{
					var extenTime = userAttList.v_ExtenStartTime!=null && userAttList.v_ExtenStartTime != "" ?AttendUtils.maskTime(userAttList.v_ExtenStartTime)+"~"+AttendUtils.maskTime(userAttList.v_ExtenEndTime) : "";
					if(
						("ADMIN"==_attendAuth
						&&"Y"==_mngType) 
						||"Y"!=_mngType
					){
						if(extenTime!= "" &&  Common.getBaseConfig("ExtenUpdMethod") != "Approval"){
							extenTime += "<a href='#' onclick='showExHoListPopup(\""+_userCode+"\",\""+_targetDate+"\",\"O\")'> [<spring:message code='Cache.btn_Edit' />]</a>";
						}
					}
					$("#at_extenTime").html(extenTime);
				}

				if(userAttList.HoliCnt > 1){
					var hoHtml = $('<a />', {
						"data-usercode" : _userCode
						,"data-targetdate" : userAttList.dayList
						,html : userAttList.HoliAc
						,onclick : "showExhoList(this,'H')"
					}); 
					$("#at_holiTime").html(hoHtml);
				}else{
					var holiTime = userAttList.v_HoliStartTime!=null && userAttList.v_HoliStartTime != "" ?AttendUtils.maskTime(userAttList.v_HoliStartTime)+"~"+AttendUtils.maskTime(userAttList.v_HoliEndTime) : "";
					if(
						("ADMIN"==_attendAuth
						&&"Y"==_mngType)
						||"Y"!=_mngType
					){
						if(holiTime!= "" &&  Common.getBaseConfig("HoliUpdMethod") != "Approval"){
							holiTime += "<a href='#' onclick='showExHoListPopup(\""+_userCode+"\",\""+_targetDate+"\",\"H\")'> [<spring:message code='Cache.btn_Edit' />]</a>";
						}
					}
					$("#at_holiTime").html(holiTime);
				}

				var jobHisHtml = $('<a />', {
					"data-usercode" : _userCode
					,"data-targetdate" : userAttList.dayList
					,html : userAttList.jh_JobStsName
					,onclick : "showJobList(this)"
				}); 
				$("#at_jobStsName").html(jobHisHtml);
				
				
				var coreTime = $('<p />', {
					class : "td_time_day"
					,text : (userAttList.CoreTime==null?'':userAttList.CoreTime) + " "+(userAttList.CoreTimeObey=="Y"?Common.getDic("lbl_n_att_compliance"): userAttList.CoreTimeObey==null?'':Common.getDic("lbl_n_att_non_compliance"))
				});

				$("#at_coreTime").html(coreTime);

				if(userAttList.WorkingSystemType == 2) {
					$("#monthlyWorkingTimeTr").show();
					if(userAttList.MonthlyAttAcSum >= monthlyMaxWorkTime) {
						$("#monthlyWorkingTime").attr("style", "color: red !important; font-weight: bold !important;");
					}
					$("#monthlyWorkingTime").html(AttendUtils.convertSecToStr(userAttList.MonthlyAttAcSum, "H"));
				}
				
				//권한별 사용자 비고 표시
				$("#at_userEtcTd").html("");
				if("Y"!=_mngType){
					var ueText = $('<textarea/>',{
						id : "at_userEtc"
						,text : userAttList.UserEtc!=null?userAttList.UserEtc:""
					});
					var ueBtn = $('<a/>',{
						class : "btnTypeDefault btnTypeBg"
						,id : "userEtcBtn"
						,text : "<spring:message code='Cache.TodoMsgType_TaskOpinion' />"
						,"onclick" : "setUserEtc()"
					});
					$("#at_userEtcTd").html(ueText);
					$("#at_userEtcTd").append(ueBtn);
				}else{
					if(userAttList.UserEtc!=""&&userAttList.UserEtc!=null){
						$("#at_userEtcTd").html(userAttList.UserEtc.replaceAll("\n", "<br>"));
					}
				}
				
				$("#at_etc").html("");
				if(userAttList.Etc!=""&&userAttList.Etc!=null){
					$("#at_etc").html(userAttList.Etc.replaceAll("\n", "<br>"));
				}

				$("#at_vacinfo").html("");
				if(userAttList.VacName!=null&&userAttList.VacName!=""){
					$("#at_vacinfo").text(userAttList.VacName);
				}
				
				var appMap = data.appMap;
				$("#at_app").html("");
				for (var i=0; i< appMap.length; i++){
					$("#at_app").append("<li><a href='#' onclick=\"openForm('','"+appMap[i]["ProcessId"]+"');\">"+appMap[i]["BillName"]+"</a></li>");
				}
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
			}
			
			
			$(".btn_gps_chk").on('click',function(e){				
				e.stopPropagation();	// 부모 이벤트 전파 방지
				var pointx = $(this).data('point-x');
				var pointy = $(this).data('point-y');
				var addr = $(this).data('addr');
				parent.AttendUtils.openMapInfoPopup(pointx,pointy,addr);
			});
			
			//코어타임 미사용 시 표기 컬럼 제거
			if(Common.getBaseConfig('CoreTimeYn')!="Y"){
				$(".td_etc").html("");
			}
		},
		error:function (request,status,error){
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		}
	});
}

//기타근무 리스트 팝업 
function showJobList(o){
	parent.AttendUtils.openAttJobListPopup(o,$(o).parent(),_mngType);
}

//연장(휴일)근무  리스트 팝업
function showExhoList(o,gubun){
	parent.AttendUtils.openAttExhoListPopup(o,$(o).parent(),gubun,_mngType);
}

//연장 (휴일)근무 단건 수정 팝업
function showExHoListPopup(u,t,gubun){
	parent.AttendUtils.openAttExHoInfoPopup(u,t,gubun,'',_mngType);
}

function refreshList(){
	getMyAttInfo();
}


//사용자 비고 등록
function setUserEtc(){
	var params = {
			targetDate : _targetDate
			,userCode : _userCode
			,userEtc : $("#at_userEtc").val()
		}
	$.ajax({
		type : "POST",
		data : params,
		url : "/groupware/attendUserSts/setUserEtc.do",
		success:function (data) {
			if(data.status=="SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_DeonRegist'/>","Information");	
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
			}
		},
		error:function (request,status,error){
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		}
	});
}

function openGroupLayer(){
	AttendUtils.openOrgChart("${authType}", "callbackMember","B1");
// 	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=callbackSchMember&type=D1&targetID=orgChart","openGroupLayerPop",1060,580,"");
}
function callbackMember(result){
	var cbData =  $.parseJSON(result);
	_userCode = cbData.item[0].UserCode;
	$("#at_name").text(CFN_GetDicInfo(cbData.item[0].DN))

	if (_targetDate !="") getMyAttInfo();
}	
	
</script>
