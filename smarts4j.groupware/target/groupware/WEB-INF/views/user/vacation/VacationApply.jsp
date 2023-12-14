<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<style>
.AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr.selected td { background:#d2d9df; }
</style>
<div class='cRConTop titType'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.MN_661' /></h2>
</div>
<div class='cRContBottom mScrollVH'>
	<div class="boardAllCont">
		<div class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">
			<input id="schYearSel" type="hidden">
				<a href="#" class="btnTypeDefault btnPromotion" period="Code1" onclick="vacationVacationApply.openPromotionPopup('plan', 'normal');" style="display:none"><spring:message code='Cache.lbl_vacation_plan_normal' /><!-- 연차사용계획서 --></a>
				<a href="#" class="btnTypeDefault btnPromotion" period="Code2" onclick="vacationVacationApply.openPromotionPopup('request', 'normal');" style="display:none"><spring:message code='Cache.lbl_vacation_request_normal' /><!-- 1차 지정 요청서 --></a>
				<a href="#" class="btnTypeDefault btnPromotion" period="Code2" onclick="vacationVacationApply.openPromotionPopup('notification1', 'normal');" style="display:none"><spring:message code='Cache.lbl_vacation_notification1_normal' /><!-- 1차 지정 통보서 --></a>
				<a href="#" class="btnTypeDefault btnPromotion" period="Code3" onclick="vacationVacationApply.openPromotionPopup('notification2', 'normal');" style="display:none"><spring:message code='Cache.lbl_vacation_notification2_normal' /><!-- 2차 지정 통보서 --></a>

				<a href="#" class="btnTypeDefault btnPromotion" period="Code4" onclick="vacationVacationApply.openPromotionPopup('plan', 'newEmp');" style="display:none"><spring:message code='Cache.lbl_vacation_plan_newEmp' /><!-- 1년 미만자 연차사용계획서 --></a>
				<a href="#" class="btnTypeDefault btnPromotion" period="Code5" onclick="vacationVacationApply.openPromotionPopup('request', 'newEmpForNine');" style="display:none"><spring:message code='Cache.lbl_vacation_request_newEmpForNine' /><!-- 1년 미만자 1차 지정 요청서 (9일) --></a>
				<a href="#" class="btnTypeDefault btnPromotion" period="Code5" onclick="vacationVacationApply.openPromotionPopup('notification1', 'newEmpForNine');" style="display:none"><spring:message code='Cache.lbl_vacation_notification1_newEmpForNine' /><!-- 1년 미만자 1차 지정 통보서 (9일) --></a>
				<a href="#" class="btnTypeDefault btnPromotion" period="Code6" onclick="vacationVacationApply.openPromotionPopup('notification2', 'newEmpForNine');" style="display:none"><spring:message code='Cache.lbl_vacation_notification2_newEmpForNine' /><!-- 1년 미만자 2차 지정 통보서 (9일) --></a>

				<a href="#" class="btnTypeDefault btnPromotion" period="Code7" onclick="vacationVacationApply.openPromotionPopup('request', 'newEmpForTwo');" style="display:none"><spring:message code='Cache.lbl_vacation_request_newEmpForTwo' /><!-- 1년 미만자 1차 지정 요청서 (2일) --></a>
				<a href="#" class="btnTypeDefault btnPromotion" period="Code7" onclick="vacationVacationApply.openPromotionPopup('notification1', 'newEmpForTwo');" style="display:none"><spring:message code='Cache.lbl_vacation_notification1_newEmpForTwo' /><!-- 1년 미만자 1차 지정 통보서 (2일) --></a>
				<a href="#" class="btnTypeDefault btnPromotion" period="Code8" onclick="vacationVacationApply.openPromotionPopup('notification2', 'newEmpForTwo');" style="display:none"><spring:message code='Cache.lbl_vacation_notification2_newEmpForTwo' /><!-- 1년 미만자 2차 지정 통보서 (2일) --></a>
				
				<a href="#" class="btnTypeDefault" style="visibility: hidden"></a>
			</div>
			<div class="buttonStyleBoxRight">	
				<button href="#" class="btnRefresh" type="button"></button>							
			</div>
		</div>
		<div>
			<div id="gridVacDiv" class="tblList tblCont" style="display:block;float:left;width:490px;">
           		<covi:grid id="gridVacDiv" gridVar="vacationApplyVacGrid" pageCookie="VacListCnt" pageSize="10">
					<tr>
					  <td key="VacName"	label="lbl_type"	 width="100"  align="center" sort="false" formatter="CUSTOM" formatAddtion="vacationVacationApply.formatVacName" />
					  <td key="ExpDate"	label="lbl_expiryDate"	 width="125"  align="center" sort="false" />
					  <td key="VacDay"	label="lbl_apv_Vacation_days"	 width="50"  align="center" sort="false" />
					  <td key="RemainVacDay"	label="lbl_appjanyu"	 width="50"  align="center" sort="false" />
					  <td key="LastVacDay"		label="lbl_lastvacday"   width="50"  align="center" sort="false" hideFilter="<%=(RedisDataUtil.getBaseConfig("DisplayLastVacDay").equals("N")?"Y":"N")%>" 
					  		display="<%=(RedisDataUtil.getBaseConfig("DisplayLastVacDay").equals("N")?false:true)%>" /> <!-- 이월년차-->
					</tr>  
				</covi:grid>			
			</div>
			<div style="display:block;float:right;width:calc(100% - 500px);">
				<div class="mt10 tabMenuCont">
					<ul class="tabMenu clearFloat tabMenuType02">
						<li class="topToggle active"><a href="#" onclick="vacationVacationApply.toggleTab('1');"><spring:message code='Cache.lbl_Vacation' /> <spring:message code='Cache.lbl_Use' /> <spring:message code='Cache.lbl_expense_detail' /></a></li>
						<li class="topToggle"><a href="#" onclick="vacationVacationApply.toggleTab('2');"><spring:message code='Cache.lbl_Vacation' /> <spring:message code='Cache.lbl_Occurrence' /> <spring:message code='Cache.lbl_expense_detail' /></a></li>						
					</ul>
				</div>
				<div id="gridDiv" id="boradTopCont_1" class="tblList tblCont">
	           		<covi:grid id="gridDiv" gridVar="vacationApplyGrid" pageCookie="VacListCnt" pageSize="1000">
						<tr>
							<td key="APPDATE"	label="lbl_DraftDate"	 	width="50"  align="center" 	sort="false" />
							<td key="ENDDATE"	label="lbl_apv_EndDate"	 	width="50"  align="center" 	sort="false" />
							<td key="GubunName"	label="lbl_Gubun"	 		width="30"  align="center" 	sort="false" />
							<td key="VACTEXT"	label="VACATION_TYPE_VACATION_TYPE"	 	width="50"  	align="center" sort="false" formatter="CUSTOM" formatAddtion="vacationVacationApply.formatText"/>
							<td key="Sdate"		label="lbl_startdate"	 	width="50"  align="center" 	sort="false" />
							<td key="Edate"		label="lbl_EndDate"	 		width="50"  align="center" 	sort="false" />
							<td key="VacDay"	label="lbl_used_days"	 	width="35" align="center" 	sort="false" formatter="NUMBER"/>
							<td key="Reason"	label="lbl_Reason"		 	width="250" align="left" 	sort="false" />
						</tr>	
					</covi:grid>	
				</div>
				<div id="gridDiv2" id="boradTopCont_2" class="tblList tblCont" style="display: none;">
	           		<covi:grid id="gridDiv2" gridVar="vacationApplyGrid2" pageCookie="VacListCnt" pageSize="1000">
						<tr>
							<td key="RegistDate"	label="lbl_ChangeDate"		width="50"  align="center" sort="false" />
							<td key="RegisterName"	label="lbl_ChangerName"	 	width="50"  align="center" sort="false" formatter="CUSTOM" formatAddtion="vacationVacationApply.formatRegister"/>
							<td key="VacDay"		label="lbl_vacationMsg55"	width="50"  align="center" sort="false" formatter="NUMBER"/>
							<td key="Reason"		label="lbl_Reason"			width="350"  align="left" 	sort="false" />
						</tr>	
					</covi:grid>	
				</div>	
			</div>	
		</div>
	</div>
</div>
<script>
var vacationVacationApply = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	var tabNo = 1;
	var gridVac = new coviGrid();
	var grid  	= new coviGrid();
	var grid2 	= new coviGrid();
	
	var page = 1;
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	this.formatVacName=function(item){
		return (item.VacKind=="PUBLIC"?item.Year+" ":"")+item.VacName;
	}
	
	this.formatText=function(item){
		var html = "<div>";
		var isLink = false;
		if (item.GUBUN == 'VACATION_PUBLIC' || item.GUBUN == 'VACATION_PUBLIC_CANCEL') {
			isLink = true;
			html += "<a href='#' onclick='Common.Inform(\"<spring:message code='Cache.lbl_vacationMsg25' />\"); return false;'>";
		} else {
			if(Number(item.EXIST_APPROVAL_FORM) > 0) {
				isLink = true;
				html += "<a href='#' onclick='vacationVacationApply.openVacationViewPopup(\"" + item.UR_Code + "\", \"" + item.ProcessID + "\", \"" + item.WorkItemID + "\"); return false;'>";
			}else if(Number(item.EXIST_REQUEST_FORM) > 0) {
				isLink = true;
				var popupUrl	= "/groupware/attendRequestMng/AttendRequestDetailPopup.do?"
						+ "popupID=AttendRequestDetailPopup&"
						+ "openerID=AttendRequestDetail&"
						+ "popupYN=N&"
						+ "UserName="		+ item.DisplayName	+ "&"
						+ "ReqType=V&"
						+ "UserCode="		+ item.UR_Code	+ "&"
						+ "ReqSeq="		+ item.EXIST_REQUEST_FORM+ "&"
						+ "callBackFunc=AttendJobDetailPopup_CallBack";

				html += "<a href='#' onclick='Common.open(\"\", \"AttendRequestDetailPopup\", \""+item.DisplayName+" ("+item.ReqTitle+")"+"\", \""+popupUrl+"\", \"650px\", \"700px\", \"iframe\", true, null, null, true);'>";
			}
		}
		html += item.VACTEXT;
		if(isLink) {
			html += "</a>";
		}
		html += "</div>";			
		return html;
	}
	
	this.formatRegister=function(item){
		if(item.RegisterCode == "system") {
			return Common.getDic("lbl_auto");
		} else {
			return item.RegisterName;	
		}
	}
	
	this.initContent = function(bLoad, linkUrl) {
		init();	// 초기화
		if (bLoad != true){
			coviUtil.getAjaxPost("/groupware/vacation/getVacationFacilitatingDateList.do",{"year" : (new Date()).format('yyyy'),"urCode":Common.getSession("USERID")}, function (data) {
				var row = data.list;
				
				if(row !== undefined && row.length > 0) {
					var IsOneYear = Number(row[0].IsOneYear);
					var nowDate = Number(new Date(CFN_GetLocalCurrentDate('yyyy/MM/dd')).format('yyyyMMdd'));
					var VacDate = Number(new Date(row[0].VacDate.replaceAll('-','/')).format('yyyyMMdd'));
					var VacDateUntil = Number(new Date(row[0].VacDateUntil.replaceAll('-','/')).format('yyyyMMdd'));
					var OneDate = new Date(row[0].OneDate.replaceAll('-','/')).format('yyyyMMdd');
					var OneDateUntil = new Date(row[0].OneDateUntil.replaceAll('-','/')).format('yyyyMMdd');
					var TwoDate = new Date(row[0].TwoDate.replaceAll('-','/')).format('yyyyMMdd');
					var TwoDateUntil = new Date(row[0].TwoDateUntil.replaceAll('-','/')).format('yyyyMMdd');
					var LessVacDate = new Date(row[0].LessVacDate.replaceAll('-','/')).format('yyyyMMdd');
					var LessVacDateUntil = new Date(row[0].LessVacDateUntil.replaceAll('-','/')).format('yyyyMMdd');
					var LessOneDate9 = new Date(row[0].LessOneDate9.replaceAll('-','/')).format('yyyyMMdd');
					var LessOneDate9Until = new Date(row[0].LessOneDate9Until.replaceAll('-','/')).format('yyyyMMdd');
					var LessTwoDate9 = new Date(row[0].LessTwoDate9.replaceAll('-','/')).format('yyyyMMdd');
					var LessTwoDate9Until = new Date(row[0].LessTwoDate9Until.replaceAll('-','/')).format('yyyyMMdd');
					var LessOneDate2 = new Date(row[0].LessOneDate2.replaceAll('-','/')).format('yyyyMMdd');
					var LessOneDate2Until = new Date(row[0].LessOneDate2Until.replaceAll('-','/')).format('yyyyMMdd');
					var LessTwoDate2 = new Date(row[0].LessTwoDate2.replaceAll('-','/')).format('yyyyMMdd');
					var LessTwoDate2Until = new Date(row[0].LessTwoDate2Until.replaceAll('-','/')).format('yyyyMMdd');
					var Code1 = (IsOneYear==1&&nowDate>=VacDate && nowDate <= VacDateUntil)?true:false;
					var Code2 = (IsOneYear==1&&nowDate>=OneDate && nowDate <= OneDateUntil)?true:false;
					var Code3 = (IsOneYear==1&&nowDate>=TwoDate && nowDate <= TwoDateUntil)?true:false;
					
					var Code4 = (IsOneYear==0&&nowDate>=LessVacDate && nowDate <= LessVacDateUntil)?true:false;
					var Code5 = (IsOneYear==0&&nowDate>=LessOneDate9 && nowDate <= LessOneDate9Until)?true:false;
					var Code6 = (IsOneYear==0&&nowDate>=LessTwoDate9 && nowDate <= LessTwoDate9Until)?true:false;
					var Code7 = (IsOneYear==0&&nowDate>=LessOneDate2 && nowDate <= LessOneDate2Until)?true:false;
					var Code8 = (IsOneYear==0&&nowDate>=LessTwoDate2 && nowDate <= LessTwoDate2Until)?true:false;
					
					var codeJson = new Object();
					codeJson["Code1"] = Code1;
					codeJson["Code2"] = Code2;
					codeJson["Code3"] = Code3;
					codeJson["Code4"] = Code4;
					codeJson["Code5"] = Code5;
					codeJson["Code6"] = Code6;
					codeJson["Code7"] = Code7;
					codeJson["Code8"] = Code8;
					
					$(".btnPromotion").each(function (idx, obj){
						if(new Function ("return " + codeJson[$(this).attr("period")]).apply()){
							$(this).show();
						}
					});
				}
			});
			
			vacationApplyGrid["paging"] = false;
			grid.setGridConfig(vacationApplyGrid);
			getUserVacationInfo();	// 연차 사용정보
			
			search("");
		} else{
			gridVac.bindEvent(true);
			grid.bindEvent(true);
			grid2.bindEvent(true);
		}
	}	
	
	// 초기화
	function init() {
		$("#schYearSel").val((new Date()).format('yyyy'));
		
		// 검색 버튼
		$('.btnRefresh').on('click', function(e) {			
			if(tabNo === 1){
				grid.reloadList();	
			} else if(tabNo === 2){
				grid2.reloadList();	
			}
		});
	}
	
	function search(row) {
		if(tabNo === 1){
			var params = {"VacKind" : typeof(row.item) === "object" ? row.item.VacKind : "ALL", "Sdate" : typeof(row.item) === "object" ? row.item.Sdate : "" };		
			grid.page.pageNo = 1;
			grid.bindGrid({
				ajaxUrl : "/groupware/vacation/getMyVacationInfoList.do",
				ajaxPars : params,
			});	
		} else if(tabNo === 2){
			var params = {"VacKind" : typeof(row.item) === "object" ? row.item.VacKind : "ALL", "Sdate" : typeof(row.item) === "object" ? row.item.Sdate : "" };		
			grid2.page.pageNo = 1;
			grid2.bindGrid({
				ajaxUrl : "/groupware/vacation/getMyVacationCreateInfoList.do",
				ajaxPars : params,
			});	
		}
	}
	
	// 연차 사용정보
	function getUserVacationInfo() {
		vacationApplyVacGrid["paging"] = false;
		vacationApplyVacGrid["body"] = {
			addClass: function() {
				if (this.item.CurYear == "Y") return "ERBoxbg";
	        },
			onclick: function() {
				search(gridVac.getSelectedItem());
			}			
		};

		gridVac.setGridConfig(vacationApplyVacGrid);	
		gridVac.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationListByKind.do",
			ajaxPars : {year : $('#schYearSel').val(), reqType:"myVacation"},
			onLoad:function(){
				search(0);
			}
		});
	}
	
	this.openPromotionPopup=function(formType, empType){
		var year = $('#schYearSel').val();
		var params = "?year="+year+"&viewType=user&formType=" + formType + "&empType=" + empType;
		
		CFN_OpenWindow("/groupware/vacation/goVacationPromotionPopup.do" + params, "", 960, (window.screen.height - 100), "scroll");
	}
	
	this.openVacationViewPopup=function(urCode, processId, workItemId) {
		CFN_OpenWindow("/approval/approval_Form.do?mode=COMPLETE&processID="+processId+"&userCode="+urCode+"&archived=true", "", 790, (window.screen.height - 100), "resize");
	}
	
	this.toggleTab=function (t) {
		$(".topToggle").attr("class","topToggle");

		if(t === "1") {
			tabNo = 1;
			$(".topToggle").eq(0).attr("class","topToggle active");
			$("#boradTopCont_1").show();
			$("#boradTopCont_2").hide();
			$("#gridDiv").show();
			$("#gridDiv2").hide();
			
			vacationApplyGrid["paging"] = true;			
			grid.setGridConfig(vacationApplyGrid);
			grid.redrawGrid();
		} else if (t === "2"){
			tabNo = 2;
			$(".topToggle").eq(1).attr("class","topToggle active");
			$("#boradTopCont_1").hide();
			$("#boradTopCont_2").show();
			$("#gridDiv").hide();
			$("#gridDiv2").show();
			
			vacationApplyGrid2["paging"] = true;
	 		grid2.setGridConfig(vacationApplyGrid2);
	 		grid2.redrawGrid();
		}
		
		search(gridVac.getSelectedItem());
	}
}();

$(document).ready(function(){
	vacationVacationApply.initContent();
});
</script>