<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%
	String userNowDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd"); 
%>
<style>
/*#realTimeTr{diplay:none}*/
.WorkBoxM.Absent {background-color:#E6E1E0;}
</style>
<div class="cRConTop titType AtnTop">
	<h2 class="title"></h2> 
	<div class="pagingType02">
		<a href="#" class="pre dayChg" data-paging="-"></a>
		<a href="#" class="next dayChg" data-paging="+"></a>
		<a href="#" class="btnTypeDefault calendartoday"><spring:message code='Cache.lbl_Todays'/></a>
		<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
		<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
	</div> 
	<div class="searchBox02"> 
		<span><input type="text" id="sUserTxt"><button type="button" id="searchBtn" class="btnSearchType01"><spring:message code='Cache.lbl_search'/></button></span>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<!-- 컨텐츠 시작 -->
	<div class="ATMCont">
		<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft"> 	 
				<a href="#" id="setAttBtn" class="s_active btnTypeDefault  btnTypeBg btnAttAdd"><spring:message code='Cache.lbl_n_att_history'/> <spring:message code='Cache.btn_Add'/>/<spring:message code='Cache.btn_Edit'/></a>
				<a class="btnTypeDefault btnExcel" id="excelBtn" href="#"><spring:message code='Cache.lbl_SaveToExcel'/></a> 
			</div>
			<div class="ATMbuttonStyleBoxRight">
				<ul class="ATMschSelect">
					<li class="pageToggle selected"><a href="#"><spring:message code='Cache.lbl_Weekly' /></a></li>
					<li class="pageToggle"><a href="#"><spring:message code='Cache.lbl_Monthly' /></a></li>
				</ul>
			</div>
		</div>
		<div class="ATMFilter_Info_wrap">
			<div class="ATMFilter">
				<p class="ATMFilter_title"><spring:message code='Cache.lbl_att_select_department'/></p>
				<select class="size112" id="groupPath"></select>
				<select class="size72" id="jobGubun">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option> 
					<option value="JobTitle"><spring:message code='Cache.lbl_JobTitle'/></option>
					<option value="JobLevel"><spring:message code='Cache.lbl_JobLevel'/></option>
				</select>
				<select class="size72" id="jobCode">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option>
				</select>
				<label for="retireUser"><spring:message code='Cache.lbl_att_retireuser'/></label>	<!--  퇴사자 포함 -->
				<input type="checkbox" id="retireUser" />
			</div>
			<div class="ATMInfo">
				<p class="Calling"><spring:message code='Cache.lbl_n_att_callingTarget'/></p>  	
				<p class="Normal"><spring:message code='Cache.lbl_attendance_normal'/></p>  	
				<p class="Outside"><spring:message code='Cache.lbl_OutsideWorking'/></p> 
				<p class="Ex"><spring:message code='Cache.lbl_over'/>/<spring:message code='Cache.lbl_Holiday'/></p> 	 
				<p class="Holyday"><spring:message code='Cache.lbl_att_sch_holiday'/></p> 
				<p class="Vacation"><spring:message code='Cache.lbl_Vacation'/></p> 
			</div> 
		</div>
		<div class="tblList"></div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>

<!-- 근태현황 temp 테이블 시작 -->
<table id="attWeekTemp" class="ATMTable" cellpadding="0" cellspacing="0" style="display:none;">
	<thead>
		<tr> 	
			<th width="150"><spring:message code='Cache.lbl_name' /></th>
			<th width="130"><div class="tfoot_box"><p class="tfoot_title"><spring:message code='Cache.lbl_att_Cumulative_duty_hours' /></p><a id="btnFilter" class="btn_close" href="#"></a></div></th> 	
			<th width="110"><spring:message code='Cache.lbl_Gubun' /></th>
			<th class="dayScope"></th>
			<th class="dayScope"></th>
			<th class="dayScope"></th>
			<th class="dayScope"></th>
			<th class="dayScope"></th>
			<th class="dayScope"></th>
			<th class="dayScope"></th>
		</tr> 
	</thead>
</table>


<table id="attWeekTempTable" class="ATMTable top_line"cellpadding="0" cellspacing="0" style="display:none;">
	<tbody>
		<tr>
			<td rowspan="6" width="150">
				<div class="ATMT_user_wrap type">
					<div class="ATMT_user_img"></div>
					<p class="ATMT_name"></p> 
					<p class="ATMT_team"></p>
					<!-- <p class="ATMT_type">근무제</p> -->
				</div>
			</td>
			<td rowspan="6" width="130" >
				<p class="workTime tx_time_total"></p>
				<p class="workTime tx_etc"></p>
				<p class="workTime tx_etc"></p>
				<p class="workTime tx_etc"></p>
				<p class="workTime tx_etc"></p>
				<p class="workTime tx_etc"></p>
				<p class="workTime tx_etc"></p>
			</td>
			<td width="110"><p class="td_type"><spring:message code='Cache.lbl_att_goWork' /></p></td>
			<td>
				<a href="#" class="WorkBoxW startSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW startSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW startSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW startSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW startSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW startSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW startSts"></a>
			</td>
		</tr>
		<tr>
			<td><p class="td_type"><spring:message code='Cache.lbl_att_offWork' /></p></td> 	
			<td>
				<a href="#" class="WorkBoxW endSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW endSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW endSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW endSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW endSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW endSts"></a>
			</td>
			<td>
				<a href="#" class="WorkBoxW endSts"></a>
			</td>
		</tr>
		<tr>
			<td><p class="td_type"><spring:message code='Cache.lbl_att_work' /></p></td>
			<td class="workSts" ></td>
			<td class="workSts" ></td>
			<td class="workSts" ></td>
			<td class="workSts" ></td>
			<td class="workSts" ></td>
			<td class="workSts" ></td>
			<td class="workSts" ></td>
		</tr>
		<tr>
			<td><p class="td_type"><spring:message code='Cache.lbl_Status' /></p></td>
			<td class="jobSts"></td>
			<td class="jobSts"></td>
			<td class="jobSts"></td>
			<td class="jobSts"></td>
			<td class="jobSts"></td>
			<td class="jobSts"></td>
			<td class="jobSts"></td>
		</tr>
		<tr id="realTimeTr" style="display:none">
			<td><p class="td_type"><spring:message code='Cache.lbl_n_att_AttRealTime' /></p></td> 	
			<td class="attReal" ></td>
			<td class="attReal" ></td>
			<td class="attReal" ></td>
			<td class="attReal" ></td>
			<td class="attReal" ></td>
			<td class="attReal" ></td>
			<td class="attReal" ></td>
		</tr>
		<tr>
			<td><p class="td_type"><spring:message code='Cache.lbl_n_att_attendSch' /></p></td>
			<td class="schName"></td>
			<td class="schName"></td>
			<td class="schName"></td>
			<td class="schName"></td>
			<td class="schName"></td>
			<td class="schName"></td>
			<td class="schName"></td>
		</tr>
		<tr>
			<td><p class="td_type"><spring:message code='Cache.lbl_AccWorkMonth' /></p></td> <!-- 월 누적 근무시간 -->
			<td class="monthlyAttAcSum"></td>
			<td class="monthlyAttAcSum"></td>
			<td class="monthlyAttAcSum"></td>
			<td class="monthlyAttAcSum"></td>
			<td class="monthlyAttAcSum"></td>
			<td class="monthlyAttAcSum"></td>
			<td class="monthlyAttAcSum"></td>
		</tr>
	</tbody>
</table>	
<!-- 근태현황  temp 테이블 끝 -->

<!-- 근태현황 월간 테이블 시작 -->
<table id="attMonthTemp" class="ATMTable" cellpadding="0" cellspacing="0" style="display:none">
	<thead>
		<tr>
			<th width="150"><spring:message code='Cache.lbl_name' /></th>
			<th width="130"><spring:message code='Cache.lbl_att_Cumulative_duty_hours' /></th>
			<th><span class="tx_date_month"></span></th>
		</tr>
	</thead>
</table>

<table  id="attMonthTempTable" class="ATMTable" cellpadding="0" cellspacing="0"  style="display:none">
	<tbody>
		<tr>
			<td width="150">
				<div class="ATMT_user_wrap type">
					<div class="ATMT_user_img"></div>
					<p class="ATMT_name"></p>
					<p class="ATMT_team"></p>
					<!-- <p class="ATMT_type">근무제</p> -->
				</div>
			</td>
			<td width="130">
				<p class="workTime tx_time_total"></p>
				<p class="workTime tx_etc"></p>
				<p class="workTime tx_etc"></p>
				<p class="workTime tx_etc"></p>
				<p class="workTime tx_etc"></p>
				<p class="workTime tx_etc"></p>
				<p class="workTime tx_etc"></p>
			</td>
			<td valign="top">
				<div class="ATMTable_month_wrap">
					<table class="ATMTable_month" cellpadding="0" cellspacing="0">
						<thead>
							<tr></tr>
						</thead>
						<tbody>
							<tr></tr>
							<tr></tr>
						</tbody>
					</table>
				</div>
			</td>
		</tr>											
	</tbody>
</table>
<!-- 근태현황 월간 테이블 끝 -->

<!-- 기타근무 레이어 팝업 -->
<div id="divJobPopup" style="position:initial;display:none">
	<div class="ATMgt_Work_Popup" style="width:282px;  position:absolute; z-index:105">
		<a class="Btn_Popup_close" onclick='AttendUtils.hideAttJobListPopup();'></a>
		<div class="ATMgt_Cont" id="jobListInfo"></div>
		<div class="bottom">
			<a href="#" class="btnTypeDefault" onclick='AttendUtils.hideAttJobListPopup();'><spring:message code='Cache.lbl_close' /></a>
		</div> 
	</div>
</div>

<script type="text/javascript">

var _pageType = 0; 

var _targetDate = "<%=userNowDate%>";
var _curStDate;
var _curEdDate;
var _stDate;
var _edDate;

var _wpMon = "<spring:message code='Cache.lbl_WPMon' />";
var _wpTue = "<spring:message code='Cache.lbl_WPTue' />";
var _wpWed = "<spring:message code='Cache.lbl_WPWed' />";
var _wpThu = "<spring:message code='Cache.lbl_WPThu' />";
var _wpFri = "<spring:message code='Cache.lbl_WPFri' />";
var _wpSat = "<spring:message code='Cache.lbl_WPSat' />";
var _wpSun = "<spring:message code='Cache.lbl_WPSun' />";

var _days = "<spring:message code='Cache.lbl_days' />";

var _absent = "<spring:message code='Cache.lbl_n_att_absent' />";
var _calling = "<spring:message code='Cache.lbl_n_att_callingTarget' />";

var _page = 1 ;
var _pageSize = 10 ;

$(document).ready(function(){
	init();
	setPageType(_pageType);
});

function init(){
	//부서선택
	AttendUtils.getDeptList($("#groupPath"),'', false, false, true);
	$("#groupPath").on('change',function(){
		reLoadList();
	});
	
	//날짜paging
	$(".dayChg").on('click',function(){
		dayChg($(this).data("paging"));
		reLoadList();
	});
	
	$(".pageToggle").on('click',function(){
		$(".pageToggle").attr("class","pageToggle");
		$(this).attr("class","selected pageToggle");
		_page = 1;
		setPageType($(this).index());
	});
	
	$("#setAttBtn").on('click',function(){
		goAttStatusSetPopup();
	});
	
	//사용자명 검색
	$("#sUserTxt").on('keypress', function(e){ 
		if (e.which == 13) {
			reLoadList();
	    }
	});
	
	$("#searchBtn").on('click',function(){
		reLoadList();
	});
	
	//달력 검색
	setTodaySearch();
	
	//직급 직책 리스트 조회
	$("#jobGubun").on('change',function(){
		var memberOf = "1_"+$(this).val();
		AttendUtils.getJobList(memberOf,'jobCode');
		if($(this).val()==''){
			reLoadList();			
		}
	});
	
	$("#jobCode").on('change',function(){
		reLoadList();
	});
	
	$("#retireUser").on('click',function(){
		reLoadList();
	});

	$("#excelBtn").on('click',function(){
		var popupID		= "AttendUserStatusPopup";
		var openerID	= "AttendUserStatus";
		var popupTit	= "<spring:message code='Cache.lbl_SaveToExcel' />";
		var popupYN		= "N";
		var popupUrl	= "/groupware/attendUserSts/goAttUserExcelDownPopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "StartDate="		+ _curStDate + "&"
						+ "EndDate="		+ _curEdDate ;

		Common.open("", popupID, popupTit, popupUrl, "500px", "450px", "iframe", true, null, null, true);
	});

}
$(document).on("click","#btnFilter",function(){
	$(this).toggleClass("btn_open").toggleClass("btn_close");
	$("#attTable table").each( function() {
        $( this ).find("#realTimeTr").toggle();
      } );
    
});

function searchList(d){
	_targetDate = d;
	clearGetAttList();
}

function dayChg(t){
	if("+"==t){
		_targetDate = _edDate;
	}else if("-"==t){
		_targetDate = _stDate;
	}
}

function clearGetAttList(){
	$(".tblList").html("");
	setTempHtml();
}

function reLoadList(){
	_page = 1; 
	clearGetAttList();
}


function refreshList(){
	_targetDate = "<%=userNowDate%>"; 
	reLoadList();
}


function setPageType(t){
	_pageType = t;
	setTempHtml();
}

function setTempHtml(){
	var tempHtml;
	if(_pageType==0){
		tempHtml = $("#attWeekTemp").clone();
		tempHtml = tempHtml.removeAttr("style","display:none;");
		$(".tblList").html(tempHtml);
		$(".tblList").append("<div class='ATMTable_02_scroll' id='attTable'></div>");
	}else if(_pageType==1){
		tempHtml = $("#attMonthTemp").clone();
		tempHtml = tempHtml.removeAttr("style","display:none;");
		$(".tblList").html(tempHtml);
		$(".tblList").append("<div class='ATMTable_03_scroll' id='attMonthTable'></div>");
	}
	getAttList();
}

function setWeekHtml(att, monthlyMaxWorkTime){
	
	//상단 날짜 표시
	$(".title").html(att.dayTitle);
	_curStDate = att.sDate;
	_curEdDate = att.eDate;
	_stDate = att.p_sDate;
	_edDate = att.p_eDate;
	
	var dayList = att.dayList;
	for(var i=0;i<dayList.length;i++){
		var dayObj = dayList[i];
		var dayHtml = "";
		var vDayOfWeek = "";
		var vDayClass = "";
		switch (dayObj.weekd){
			case 0 : dayHtml = dayObj.dDate+_days+"("+_wpMon+")" ; break;
			case 1 : dayHtml = dayObj.dDate+_days+"("+_wpTue+")" ; break;
			case 2 : dayHtml = dayObj.dDate+_days+"("+_wpWed+")" ; break;
			case 3 : dayHtml = dayObj.dDate+_days+"("+_wpThu+")" ; break;
			case 4 : dayHtml = dayObj.dDate+_days+"("+_wpFri+")" ; break;
			case 5 : dayHtml = dayObj.dDate+_days+"("+_wpSat+")" ; $(".dayScope").eq(i).attr("class","dayScope tx_sat"); break;
			case 6 : dayHtml = dayObj.dDate+_days+"("+_wpSun+")" ; $(".dayScope").eq(i).attr("class","dayScope tx_sun"); break;
		}
		$(".dayScope").eq(i).html(dayHtml);
	}
	
	//<th class="dayScope"><span class="tx_holy">20일 (월)</span></th>
	
	//$("#attTable").html("");
	var userAtt = att.userAtt;
	for(var i=0;i<userAtt.length;i++){
		
		var tempTable = $("#attWeekTempTable").clone();
		tempTable = tempTable.removeAttr("style","display:none;");
		tempTable = tempTable.removeAttr("id");
		
		//프로필이미지
		if (userAtt[i].photoPath != ""){
			tempTable.find("div.ATMT_user_img").html('<img src="'+coviCmn.loadImage(userAtt[i].photoPath)+'" onerror="coviCmn.imgError(this, true)" alt=""></div>'); // img").attr("src",userAtt[i].photoPath);
		}	
		else{
			tempTable.find("div.ATMT_user_img").html('<p class="bgColor'+Math.floor(i%5+1)+'"><strong>'+userAtt[i].displayName.substring(0,1)+'</strong></p>');
		}
		//사용자명
		var UserNameInfo = userAtt[i].displayName;
		if(userAtt[i].jobPositionName!=null) {
			UserNameInfo += " " + userAtt[i].jobPositionName;
		}
		tempTable.find("p.ATMT_name").html(UserNameInfo);
		//부서
		tempTable.find("p.ATMT_team").html(userAtt[i].deptName);
		
		var userAttList = userAtt[i].userAttList;
		for(var j=0;j<userAttList.length;j++){
			//var startHtml = "";
			var startHtml = $('<span />', {});
			var endHtml = $('<span />', {});
			var startCss = "";
			var endCss = "";
			
			/*css 문제로 빈값추가*/
			/* var workHtml = "<p class='td_time_w'>&nbsp;</p>"; */
			/*var workHtml = $('<p />', {
				class : "td_time_w"
				,html : '&nbsp;'
				//td_time_wbox
			});*/
			var workHtml =  $('<div />', {
				class : "td_time_wbox"
				});
			var jobHtml = "<p class='td_time_w'>&nbsp;</p>";
			var schNameHtml = "<p class='td_time_w'>&nbsp;</p>";
			var attRealHtml = "<p class='td_time_w'>&nbsp;</p>";
			var monthlyAttAcSumHtml = "<p class='td_time_w'>&nbsp;</p>";
			
			//정상
			if(userAttList[j].StartSts!=null){
				if(userAttList[j].StartSts=="lbl_n_att_callingTarget"){
					startCss = "Calling";	//소명 css
					startHtml.html(Common.getDic(userAttList[j].StartSts));
				}
				else{
					if(userAttList[j].v_AttStartTime != null){
						startHtml.addClass("tx_time");
						startHtml.html(userAttList[j].v_AttStartTime);
						startCss = "Normal";
					}else{
						if(userAttList[j].StartSts=="lbl_n_att_absent"){
							startCss = "Absent";	//결근 css
						}
						startHtml.html(Common.getDic(userAttList[j].StartSts));
					}					
				}
			}
			if(userAttList[j].EndSts!=null){
				if(userAttList[j].EndSts=="lbl_n_att_callingTarget"){
					endCss = "Calling";	//소명 css
					endHtml.html(Common.getDic(userAttList[j].EndSts));
				}
				else{
					if(userAttList[j].v_AttEndTime != null){
						endHtml.addClass("tx_time");
						endHtml.html(userAttList[j].v_AttEndTime);
						endCss = "Normal";
					}else{
						if(userAttList[j].EndSts=="lbl_n_att_absent"){
							endCss = "Absent";	//결근 css
						}
						endHtml.html(Common.getDic(userAttList[j].EndSts));
					}	
				}	
			}
			
			//근무상태 ( 외근 등.. )
			if(userAttList[j].jh_JobStsName!=null && userAttList[j].jh_JobStsName != ""){
				//endHtml = "<span class='tx_time'>"+userAttList[j].jobStsStartTime+"</span>";
				startCss = "Outside";
				endCss = "Outside";
				
				//상태text
				jobHtml = "<p class='td_time_w' ><a href='#' data-usercode='"+userAtt[i].userCode+"' data-targetdate='"+userAttList[j].dayList+"' onclick='showJobList(this);'>"+userAttList[j].jh_JobStsName+"</a></p>";
			}
			
			//연장 휴일
			if(
					(userAttList[j].ExtenAc!=null && userAttList[j].ExtenAc!="")
					||(userAttList[j].HoliAc!=null && userAttList[j].HoliAc!="")		
			){
				startCss = "Ex";
				endCss = "Ex";
			}
			
			//휴무
			if(userAttList[j].WorkSts == "OFF" || userAttList[j].WorkSts == "HOL"){
				startHtml.addClass("tx_title");
				startHtml.html(userAttList[j].WorkSts== "OFF"? "<spring:message code='Cache.lbl_att_sch_holiday' />":"<spring:message code='Cache.lbl_Holiday' />");
				startCss = "Holyday";
				endHtml.removeClass();
				endHtml.html("");
				endCss = "";
			}
			
			//휴가
			if(userAttList[j].VacFlag != null && userAttList[j].VacFlag != ""){
				//연차종류
				//반차
				if(userAttList[j].VacFlag == "VACATION_OFF" && userAttList[j].VacCnt == 1){
					startHtml.addClass("tx_title");
					startHtml.html(userAttList[j].VacName);
					startCss = "Vacation";
					endHtml.removeClass();
					endHtml.html("");
					endCss = "";
				}else{
					if(userAttList[j].VacOffFlag == "AM"){
						startHtml.addClass("tx_title");
						startHtml.html(userAttList[j].VacName);
						startCss = "Half Vacation" +(userAttList[j].StartSts=="lbl_n_att_callingTarget"?" Calling" :"");
					}else if(userAttList[j].VacOffFlag == "PM"){
						endHtml.addClass("tx_title");
						endHtml.html(userAttList[j].VacName);
						endCss = "Half Vacation" +(userAttList[j].EndSts=="lbl_n_att_callingTarget"?" Calling" :"");
					}else{	//오전오후 반차 구분 없을 시 오전반차 표시!
						startHtml.addClass("tx_title");
						startHtml.html(userAttList[j].VacName);
						startCss = "Half Vacation" +(userAttList[j].StartSts=="lbl_n_att_callingTarget"?" Calling" :"");;
					}
				}
			}
			
			/*출퇴근 좌표*/
			if(
					userAttList[j].StartPointX!=null && userAttList[j].StartPointX!=''
					&& userAttList[j].StartPointY!=null && userAttList[j].StartPointY!=''
			){
				var startPoi = $('<a />', {
					class			: "btn_gps_chk"
					,"data-point-x" : userAttList[j].StartPointX
					,"data-point-y" : userAttList[j].StartPointY
					,"data-addr" : userAttList[j].StartAddr
				});
				startHtml.append(startPoi);
			}
			if(
					userAttList[j].EndPointX!=null && userAttList[j].EndPointX!=''
					&& userAttList[j].EndPointY!=null && userAttList[j].EndPointY!=''
			){
				var endPoi = $('<a />', {
					class			: "btn_gps_chk"
					,"data-point-x" : userAttList[j].EndPointX
					,"data-point-y" : userAttList[j].EndPointY
					,"data-addr" : userAttList[j].EndAddr
				});
				endHtml.append(endPoi);
			} 
			
			var workArry = new Array();
			//정상근무시간
			if(userAttList[j].AttRealTime != null && userAttList[j].AttRealTime != "" ){
				var workval = {
					name : "<spring:message code='Cache.lbl_attendance_normal' />"
					,time : AttendUtils.convertSecToStr(userAttList[j].AttRealTime,"H")
				}
				workArry.push(workval);
			}
			//연장근무시간
			if(userAttList[j].ExtenAc != null && userAttList[j].ExtenAc != "" ){
				
				var workval = {
						name : "<spring:message code='Cache.lbl_att_overtime' />"
						,time : AttendUtils.convertSecToStr(userAttList[j].ExtenAc,"H")
						,type : "Ex"
					}
				workArry.push(workval);
				
				
			}
			//휴일근무시간
			if(userAttList[j].HoliAc != null && userAttList[j].HoliAc != "" ){
				var workval = {
						name : "<spring:message code='Cache.lbl_Holiday' />"
						,time : AttendUtils.convertSecToStr(userAttList[j].HoliAc,"H")
						,type : "Ho"
					}
				workArry.push(workval);
			}
			
			for(var w=0;w<workArry.length;w++){
				var workHtmlTmep = $('<p />', {
					class : "td_time_w"
						,html : '&nbsp;'
					});

				if(w==0){ 
//					workHtml.html(workHtmlTmep);	//css꺠짐으로 인한 공백 제거 
				}
				
				if(workArry[w].type=='Ex'){	
					var exHtml;
					if(userAttList[j].ExtenCnt > 1){
						exHtml = $('<a />', {
							html : workArry[w].name+" : "+workArry[w].time+ (userAttList[j].ExtenNotEnough == 'N'?" (<a class='exHoSts'><spring:message code='Cache.lbl_NotRun'/></a>)":"")
							,onclick : "showExhoList(this,'O')"
							,"data-usercode" : userAtt[i].userCode
							,"data-targetdate" : userAttList[j].dayList
						}); 
					}else{
						exHtml = $('<a />', {
							html : workArry[w].name+" : "+workArry[w].time+ (userAttList[j].ExtenNotEnough == 'N'?" (<a class='exHoSts'><spring:message code='Cache.lbl_NotRun'/></a>)":"")
							,onclick : "goAttStatusExPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\",\"O\")"
						});
					}
					workHtmlTmep.html(exHtml);
				}else if(workArry[w].type=='Ho'){	
					var hoHtml;
					if(userAttList[j].HoliCnt > 1){
						hoHtml = $('<a />', {
							html : workArry[w].name+" : "+workArry[w].time+ (userAttList[j].HoliNotEnough == 'N'?" (<a class='exHoSts'><spring:message code='Cache.lbl_NotRun'/></a>)":"")
							,onclick : "showExhoList(this,'H')"
							,"data-usercode" : userAtt[i].userCode
							,"data-targetdate" : userAttList[j].dayList
						}); 
					}else{
						hoHtml = $('<a />', {
							html : workArry[w].name+" : "+workArry[w].time+ (userAttList[j].HoliNotEnough == 'N'?" (<a class='exHoSts'><spring:message code='Cache.lbl_NotRun'/></a>)":"")
							,onclick : "goAttStatusExPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\",\"H\")"
						});
					}
					workHtmlTmep.html(hoHtml);
				}else{
//					workHtmlTmep.html(workArry[w].name+" :=> "+workArry[w].time);
					workHtmlTmep.html($('<p />', {
						html : workArry[w].name+" : "+workArry[w].time
						,class:"td_time_w"
					}));
				}
				workHtml.append(workHtmlTmep);
			}
			
			if(userAttList[j].SchName != null && userAttList[j].SchName != ''){
				//근무제 일정 명 길이 제한
				var spNum = 13;
				var schName = userAttList[j].SchName;

				if(schName == null)
					schName = "";
				else
					schName = userAttList[j].SchName.length > spNum ? userAttList[j].SchName.substring(0,spNum)+".." : userAttList[j].SchName;

				schNameHtml = "<p class='td_time_w ATMT_type' title='"+schName+"'>"+schName+(userAttList[j].AssYn=="Y"?"(간)":"")+"</p>";
			}
			
			if(userAttList[j].v_startToEndSec != null  && userAttList[j].v_startToEndSec != ''){
				attRealHtml = "<p class='td_time_w'>"+AttendUtils.convertSecToStr(userAttList[j].v_startToEndSec,"H")+"</p>";
			}

			if(userAttList[j].MonthlyAttAcSum != null  && userAttList[j].MonthlyAttAcSum != '') {
				monthlyAttAcSumHtml = "<p class='td_time_w'>"+AttendUtils.convertSecToStr(userAttList[j].MonthlyAttAcSum,"H")+"</p>";
			}
		
			tempTable.find("a.startSts").eq(j).attr("class","WorkBoxW startSts "+startCss);
			tempTable.find("a.endSts").eq(j).attr("class","WorkBoxW endSts "+endCss);
			tempTable.find("a.startSts").eq(j).html(startHtml);
			tempTable.find("a.endSts").eq(j).html(endHtml);
			
			//근태기록 상세 데이터 추가
			tempTable.find("a.startSts").eq(j).attr("class","WorkBoxW startSts "+startCss);
			tempTable.find("a.endSts").eq(j).attr("class","WorkBoxW endSts "+endCss);
			tempTable.find("a.startSts").eq(j).attr('href',"javascript:goAttStatusSetPopup('"+userAtt[i].userCode+"','"+userAttList[j].dayList+"');");
			tempTable.find("a.endSts").eq(j).attr('href',"javascript:goAttStatusSetPopup('"+userAtt[i].userCode+"','"+userAttList[j].dayList+"');");
			tempTable.find("td.attReal").eq(j).html(attRealHtml); 
			tempTable.find("td.workSts").eq(j).html(workHtml); 
			tempTable.find("td.jobSts").eq(j).html(jobHtml);
			
			tempTable.find("td.schName").eq(j).html(schNameHtml);
			tempTable.find("a.startSts").eq(j).closest("td").addClass("s_active");
			tempTable.find("a.endSts").eq(j).closest("td").addClass("s_active");
//			tempTable.find("td.schName").eq(j).addClass("s_active");

			tempTable.find("td.monthlyAttAcSum").eq(j).html(monthlyAttAcSumHtml);
			if(userAttList[j].WorkingSystemType == 2) {
				if (userAttList[j].MonthlyAttAcSum >= monthlyMaxWorkTime) {
					tempTable.find("td.monthlyAttAcSum").eq(j).attr("style", "background: lightgray !important;");
				}
			}
		}
		//누적 근무시간
		var userWorkTime = userAtt[i].userAttWorkTime;
		var totWorkTime = userWorkTime.TotWorkTime != ''?userWorkTime.TotWorkTime:"00h"; 
		var attRealTime = userWorkTime.AttRealTime != ''?userWorkTime.AttRealTime:"0h"; 
		var extenAc = userWorkTime.ExtenAc != ''?userWorkTime.ExtenAc:"0h"; 
		var holiAc = userWorkTime.HoliAc != ''?userWorkTime.HoliAc:"0h"; 	
		var totConfWorkTime = userWorkTime.TotConfWorkTime != ''?userWorkTime.TotConfWorkTime:"0h"; 	
		var remainTime = userWorkTime.RemainTime != ''?userWorkTime.RemainTime:"0h"; 	
		var jobStsTime = userWorkTime.JobStsSumTime != ''?userWorkTime.JobStsSumTime:"0h"; 	
		tempTable.find("p.workTime").eq(0).html(AttendUtils.convertSecToStr(totWorkTime,'H'));
		tempTable.find("p.workTime").eq(1).html("<spring:message code='Cache.lbl_n_att_acknowledgedWork'/> "+AttendUtils.convertSecToStr(attRealTime,'H'));
		tempTable.find("p.workTime").eq(2).html("<spring:message code='Cache.lbl_att_overtime'/> "+AttendUtils.convertSecToStr(extenAc,'H'));
		tempTable.find("p.workTime").eq(3).html("<spring:message code='Cache.lbl_Holiday'/> "+AttendUtils.convertSecToStr(holiAc,'H'));
		tempTable.find("p.workTime").eq(4).html("<spring:message code='Cache.lbl_n_att_AttRealTime'/> "+AttendUtils.convertSecToStr(totConfWorkTime,'H'));
		tempTable.find("p.workTime").eq(5).html("<spring:message code='Cache.lbl_n_att_remain'/> "+AttendUtils.convertSecToStr(remainTime,'H'));
		//tempTable.find("p.workTime").eq(5).html("<spring:message code='Cache.lbl_n_att_otherjob_sts'/> "+jobStsTime);
		
		/*실근무 시간 표기 확인*/
		if(Common.getBaseConfig('RealTimeYn')!="Y"){
			$("#btnFilter").hide();
//			$("#excelRealBtn").hide();
		}
	
		AttendUtils.Colspan(tempTable.find("tr").eq(5));
		
		$("#attTable").append(tempTable);

		$(".btn_gps_chk").on('click',function(){
			var pointx = $(this).data('point-x');
			var pointy = $(this).data('point-y');
			var addr = $(this).data('addr');
			parent.AttendUtils.openMapInfoPopup(pointx,pointy,addr);
			return false;
		});
	}
	
	
}

function setMonthHtml(att, monthlyMaxWorkTime){
	//상단 날짜 표시
	$(".title").html(att.dayTitleMonth);
	_stDate = att.p_sDate;
	_edDate = att.p_eDate;
	
	$(".tx_date_month").html(att.dayTitleMonth);

	var userAtt = att.userAtt;
	for(var i=0;i<userAtt.length;i++){
		
		var tempTable = $("#attMonthTempTable").clone();
		tempTable = tempTable.removeAttr("style","display:none;");
		tempTable = tempTable.removeAttr("id");
		
		//프로필이미지
		if (userAtt[i].photoPath != ""){
			tempTable.find("div.ATMT_user_img").html('<img src="'+coviCmn.loadImage(userAtt[i].photoPath)+'" onerror="coviCmn.imgError(this, true)" alt=""></div>'); // img").attr("src",userAtt[i].photoPath);
		}	
		else{
			tempTable.find("div.ATMT_user_img").html('<p class="bgColor'+Math.floor(i%5+1)+'"><strong>'+userAtt[i].displayName.substring(0,1)+'</strong></p>');
		}
		//사용자명
		tempTable.find("p.ATMT_name").html(userAtt[i].displayName+" "+userAtt[i].jobPositionName);
		//부서
		tempTable.find("p.ATMT_team").html(userAtt[i].deptName);

		var userAttList = userAtt[i].userAttList;
		for(var j=0;j<userAttList.length;j++){
			var thHtml = "<th>";
			switch (userAttList[j].weekd){
				case 0 : case 1 : case 2 : case 3 : case 4 : 
					thHtml += userAttList[j].v_day; break;
				case 5 : thHtml += "<span class='tx_sat'>"+userAttList[j].v_day+"</span>"; break;
				case 6 : thHtml += "<span class='tx_sun'>"+userAttList[j].v_day+"</span>"; break;
			}
			thHtml += "</th>";
			
			//출퇴근
			var startHtml = "";
			var endHtml = "";
			
			//근무상태
			
			//정상
			if(userAttList[j].StartSts!=null){
				if(userAttList[j].StartSts=="lbl_n_att_callingTarget"){
					startHtml = "<a href='#' class='WorkBoxM Calling'></a>";//소명 css
				}
				else{
					if(userAttList[j].v_AttStartTime != null){
						startHtml = "<a href='#' class='WorkBoxM Normal'></a>";
					}else{
						if(userAttList[j].StartSts=="lbl_n_att_absent"){
							startHtml = "<a href='#' class='WorkBoxM Absent'></a>";	//결근 css
						}
					}	
				}	
			}
			if(userAttList[j].EndSts!=null){
				if(userAttList[j].EndSts=="lbl_n_att_callingTarget"){
					endHtml = "<a href='#' class='WorkBoxM Calling'></a>";//소명 css
				}
				else{
					if(userAttList[j].v_AttEndTime != null){
						endHtml = "<a href='#' class='WorkBoxM Normal'></a>";
					}else{
						if(userAttList[j].EndSts=="lbl_n_att_absent"){
							endHtml = "<a href='#' class='WorkBoxM Absent'></a>";	//결근 css
						}
					}					
				}	
			}
			
			//근무상태 ( 외근 등.. )
			if(userAttList[j].jh_JobStsName!=null && userAttList[j].jh_JobStsName != ""){
				//endHtml = "<span class='tx_time'>"+userAttList[j].jobStsStartTime+"</span>";
				endHtml = "<a href='#' class='WorkBoxM Outside'></a>"
			}
			
			//연장 휴일
			if(
					(userAttList[j].ExtenAc!=null && userAttList[j].ExtenAc!="")
					||(userAttList[j].HoliAc!=null && userAttList[j].HoliAc!="")		
			){
				startHtml = "<a href='#' class='WorkBoxM Ex'></a>";
				endHtml = "<a href='#' class='WorkBoxM Ex'></a>";
			}
			
			//휴무
			if(userAttList[j].WorkSts == "OFF" || userAttList[j].WorkSts == "HOL"){
				startHtml = "<a href='#' class='WorkBoxM Holyday'></a>";
				endHtml = "";
			}
			
			//휴가
			if(userAttList[j].VacFlag != null && userAttList[j].VacFlag != ""){
				//연차종류
				//반차
				if(userAttList[j].VacOffFlag == "AM" || userAttList[j].VacOffFlag == "PM"){
					if(userAttList[j].VacOffFlag == "AM"){
						startHtml = "<a href='#' class='WorkBoxM Half Vacation'></a>";
					}else if(userAttList[j].VacOffFlag == "PM"){
						endHtml = "<a href='#' class='WorkBoxM Half Vacation'></a>";
					}else{	//오전오후 반차 구분 없을 시 오전반차 표시!
						startHtml = "<a href='#' class='WorkBoxM Half Vacation'></a>";
					}
				}else{
					startHtml = "<a href='#' class='WorkBoxM Vacation'></a>";
					endHtml = "";
				}
			}
			
			tempTable.find(".ATMTable_month thead tr").append(thHtml);
			if(userAttList[j].WorkingSystemType == 2) {
				if (userAttList[j].MonthlyAttAcSum >= monthlyMaxWorkTime) {
					tempTable.find(".ATMTable_month tbody tr").eq(0).append("<td style='background: lightgray;' onclick='goAttStatusSetPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\");'>"+startHtml+"</td>");
					tempTable.find(".ATMTable_month tbody tr").eq(1).append("<td style='background: lightgray;' onclick='goAttStatusSetPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\");'>"+endHtml+"</td>");
				} else {
					tempTable.find(".ATMTable_month tbody tr").eq(0).append("<td onclick='goAttStatusSetPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\");'>"+startHtml+"</td>");
					tempTable.find(".ATMTable_month tbody tr").eq(1).append("<td onclick='goAttStatusSetPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\");'>"+endHtml+"</td>");
				}
			} else {
				tempTable.find(".ATMTable_month tbody tr").eq(0).append("<td onclick='goAttStatusSetPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\");'>"+startHtml+"</td>");
				tempTable.find(".ATMTable_month tbody tr").eq(1).append("<td onclick='goAttStatusSetPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\");'>"+endHtml+"</td>");
			}
			
		}
		
		//누적 근무시간
		var userWorkTime = userAtt[i].userAttWorkTime;
		var totWorkTime = userWorkTime.TotWorkTime != ''?userWorkTime.TotWorkTime:"00h"; 
		var attRealTime = userWorkTime.AttRealTime != ''?userWorkTime.AttRealTime:"0h"; 
		var extenAc = userWorkTime.ExtenAc != ''?userWorkTime.ExtenAc:"0h"; 
		var holiAc = userWorkTime.HoliAc != ''?userWorkTime.HoliAc:"0h"; 	
		var totConfWorkTime = userWorkTime.TotConfWorkTime != ''?userWorkTime.TotConfWorkTime:"0h";
		var remainTime = userWorkTime.RemainTime != ''?userWorkTime.RemainTime:"0h"; 	
		var jobStsTime = userWorkTime.JobStsSumTime != ''?userWorkTime.JobStsSumTime:"0h"; 	
		tempTable.find("p.workTime").eq(0).html(AttendUtils.convertSecToStr(totWorkTime,'H'));
		tempTable.find("p.workTime").eq(1).html("<spring:message code='Cache.lbl_n_att_acknowledgedWork'/> "+AttendUtils.convertSecToStr(attRealTime,'H'));
		tempTable.find("p.workTime").eq(2).html("<spring:message code='Cache.lbl_att_overtime'/> "+AttendUtils.convertSecToStr(extenAc,'H'));
		tempTable.find("p.workTime").eq(3).html("<spring:message code='Cache.lbl_Holiday'/> "+AttendUtils.convertSecToStr(holiAc,'H'));
		tempTable.find("p.workTime").eq(4).html("<spring:message code='Cache.lbl_n_att_AttRealTime'/> "+AttendUtils.convertSecToStr(totConfWorkTime,'H'));
		tempTable.find("p.workTime").eq(5).html("<spring:message code='Cache.lbl_n_att_remain'/> "+AttendUtils.convertSecToStr(remainTime,'H'));
//		tempTable.find("p.workTime").eq(5).html("<spring:message code='Cache.lbl_n_att_otherjob_sts'/> "+jobStsTime);
		
		$("#attMonthTable").append(tempTable);
	}
	
}


function getAttList(){
	var params = {
		groupPath : 	$("#groupPath").val()
		,dateTerm : _pageType==0?"W":_pageType==1?"M":null
		,targetDate : _targetDate
		,pageSize : _pageSize
		,pageNo : _page
		,sUserTxt : $("#sUserTxt").val()
		,sJobTitleCode : $("#jobGubun").val()=="JobTitle"?$("#jobCode").val():null
		,sJobLevelCode : $("#jobGubun").val()=="JobLevel"?$("#jobCode").val():null
		,retireUser:$("#retireUser").is(":checked")?"":"INOFFICE"
	}

	$.ajax({
		type:"POST",
		dataType : "json",
		data: params,
		url:"/groupware/attendUserSts/getUserAttendance.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				$(".mScrollVH").off();
				if(data.loadCnt > 0){
					if(_pageType==0){
						setWeekHtml(data.data, data.monthlyMaxWorkTime);
					}else if(_pageType==1){
						setMonthHtml(data.data, data.monthlyMaxWorkTime);
					}
					$(".mScrollVH").scroll(function(){
				        var scrollTop = $(this).scrollTop();
				        var innerHeight = $(this).innerHeight();
				        var scrollHeight = $(this).prop('scrollHeight');

				        if (scrollTop + innerHeight >= scrollHeight) {
			        		_page++; 
			        		getAttList();
				        } 
					});
				}
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
			}
		}
	});   
}

//근태현황수정 팝업
function goAttStatusSetPopup(u,t){

	AttendUtils.openAttMyStatusPopup(u,t,'Y');
	
	//AttendUtils.openAttStatusSetPopup(u,t);
}


//조직도 팝업 콜백
function orgMapLayerPopupCallBack(orgData) {
	wiUrArry = new Array();
	var data = $.parseJSON(orgData);
	var item = data.item
	var len = item.length;
	//기존 입력정보 초기화
	attPopValueClear();
	
	var childPop = $('#AttendAttStstusPopup_if').contents();
	//사용자 정보 표시
	childPop.find('#userCode').val(item[0].UserCode);
	childPop.find('#at_dept').html(CFN_GetDicInfo(item[0].RGNM));
	childPop.find('#at_name').html(CFN_GetDicInfo(item[0].DN));
}	

function attPopValueClear(){
	var childPop = $('#AttendAttStstusPopup_if').contents();
	
	//기존 입력정보 초기화
	childPop.find('#at_dept').html("");
	childPop.find('#at_name').html("");
	childPop.find('#at_schName').html("");
	childPop.find('#AXInput-1').val("");
	childPop.find('#AXInput-2').val("");
	childPop.find('#AXInput-3').val("");
    
	childPop.find('#at_startHour').val("");
	childPop.find('#at_startMin').val("");
	childPop.find('#at_startAP').val("");
	childPop.find('#at_endHour').val("");
	childPop.find('#at_endMin').val("");
	childPop.find('#at_endAP').val("");
    
	childPop.find('#at_etc').val("");
}

//기타근무 리스트 팝업 
function showJobList(o){
	AttendUtils.openAttJobListPopup(o,$(o).parent(),'Y');
}

//연장(휴일)근무  리스트 팝업
function showExhoList(o,gubun){
	AttendUtils.openAttExhoListPopup(o,$(o).parent(),gubun,'Y');
}


//연장근무 수정 팝업
function goAttStatusExPopup(u,t,reqType){
	AttendUtils.openAttExHoInfoPopup(u,t,reqType,'','Y');
}


</script>