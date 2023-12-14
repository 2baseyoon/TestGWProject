<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.StringUtil" %>
<%StringUtil func = new StringUtil();
String isAttendAdmin = StringUtil.replaceNull(request.getParameter("AuthMode"),"").equals("U")?"": SessionHelper.getSession("isAttendAdmin");%>
<style>
.cRContBottom {
    top: 120px;
}
.tabMenuCont {	
	padding: 0 25px;
}
</style>

<input type="hidden" id="JobStsName" value="J" />
<input type="hidden" id="pageNo" value="1" />
	<div class="cRConTop titType AtnTop">
		<h2 class="title"><spring:message code='Cache.MN_882'/></h2>	
		<span id="divDate" >
			<h2 class="title" id="dateTitle"></h2>
		    <div class="pagingType02">
		        <a class="pre"></a>
		        <a class="next"></a>
				<a href="#" class="calendartoday btnTypeDefault"><spring:message code='Cache.lbl_Todays'/></a>	<!-- 오늘 -->
			    <a href="#" class="calendarcontrol btnTypeDefault cal"></a>
				<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
		    </div>
		</span>
		<div class="searchBox02">
			<span>
				<input type="text" id="searchText"><button type="button" class="btnSearchType01" id="btnSearch" ><spring:message code='Cache.btn_search'/></button> <!-- 검색 -->
			</span>
			<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a>	<!-- 상세 -->
		</div>
	</div>
<div class="mt20 tabMenuCont">
	<ul class="tabMenu clearFloat tabMenuType02">
		<li class="topToggle"><a href="#" onclick="toggleTab('O');"><spring:message code='Cache.lbl_over'/>/<spring:message code='Cache.lbl_Holiday'/></a></li>		<!-- 연장 -->
		<li class="topToggle"><a href="#"  onclick="toggleTab('C');"><spring:message code='Cache.lbl_app_calling'/></a></li>	<!-- 소명 -->
	</ul>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type05 amSearchDetail" style="margin-top: 2px;">
		<div>
			<div class="selectCalView">
				<div class="msd_top">
					<span><spring:message code='Cache.lbl_SmartDept'/></span> <!--  부서 -->
					<select class="selectType02" id="deptList">
						<option value=""><spring:message code='Cache.lbl_Whole'/></option><!-- 전체  -->
					</select>
				</div>
			</div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_apv_DurPeriod'/></span><!-- 기간  -->	
				<div class="dateSel type02" id="">
					<input type="text" class="txtDate" id="searchDate_StartDate"/>-
					<input type="text" class="txtDate" id="searchDate_EndDate"/>
				</div>											
			</div>
			<div>
				<a href="javascript:search(1)" class="btnTypeDefault btnSearchBlue nonHover" ><spring:message code='Cache.lbl_search'/></a><!--  검색-->
			</div>
		</div>
		<div>
			<div class="msd_bottom exhoSearch">
				<span><spring:message code='Cache.lbl_att_approvalSts'/></span><!-- 신청상태 -->
				<select id="ApprovalSts" class="selectType02">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option><!-- 전체  -->
					<option value="Y"><spring:message code='Cache.lbl_att_approval'/></option><!-- 신청  -->
					<option value="S"><spring:message code='Cache.lbl_att_approval_cancel'/></option><!-- 취소신청  -->
				</select>
			</div>
			<div class="msd_bottom exhoSearch">
				<span><spring:message code='Cache.lbl_RunState'/></span><!-- 실행상태 -->
				<select id="ApprovalStsU" class="selectType02">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option><!-- 전체  -->
					<option value="Y"><spring:message code='Cache.lbl_att_approval'/></option><!-- 신청  -->
					<option value="NOT"><spring:message code='Cache.lbl_att_approval_notRunning'/></option><!-- 미실행 -->
					<option value="SUCCESS"><spring:message code='Cache.lbl_att_approval_runningSuccess'/></option><!-- 실행완료 -->
				</select>
			</div>
			
			<div class="msd_bottom isAdminChk">
				<span><spring:message code='Cache.lbl_att_retireuser'/></span><!-- 퇴사자 포함 -->
				<input type="checkbox" id="retireUser" />
			</div>
		</div>
	</div>
	<div class="boardAllCont">
		<div class="boradTopCont">
			<div class="ATMTop_info_Time">
				<dl class="ATMTime_dl">
					<dt><spring:message code='Cache.mag_Attendance21'/></dt>  <!-- 주 52시간 초과 근무자 -->
					<dd><span class="tx_normal" id="OverCnt"></span></dd> 
				</dl>
				<dl class="ATMTime_dl">
					<dt><spring:message code='Cache.lbl_att_overtime_work'/></dt> <!--연장근무  -->
					<dd><span class="tx_normal" id="TotTime"></span></dd>
				</dl>
				<dl class="ATMTime_dl">
					<dt><spring:message code='Cache.lbl_all'/></dt>  <!-- 전체 -->
					<dd><span class="tx_normal" id="TotCnt"></span></dd>
				</dl>
				<dl class="ATMTime_dl">
					<dt><spring:message code='Cache.lbl_NotRun'/></dt> <!-- 미실행 -->
					<dd><span class="tx_holy" id="NotCnt"></span></dd>
				</dl>
				<dl class="ATMTime_dl">
					<dt><spring:message code='Cache.lbl_Run'/><spring:message code='Cache.lbl_Cancel'/></dt> <!-- 실행취소 -->
					<dd><span class="tx_normal" id="CanCnt"></span></dd>
				</dl>
			</div>
			<div class="pagingType02 buttonStyleBoxLeft">
				<a href="#" class="btnTypeDefault exhoSearch" onclick="cancle('S');"><spring:message code='Cache.lbl_att_approval_cancel'/></a> <!-- 취소신청 -->
				<a href="#" class="btnTypeDefault exhoSearch isAdminChk"  onclick="cancle('N');"><spring:message code='Cache.lbl_att_approval_cancel_ac'/></a>
				<a href="#" class="btnTypeDefault exFormOpen"  ><spring:message code='Cache.lbl_app_approval_extention'/></a><!-- 연장근무신청 -->
				<a href="#" class="btnTypeDefault hoFormOpen"  ><spring:message code='Cache.lbl_app_approval_holiday'/></a><!-- 휴일근무신청 -->	
				<a href="#" class="btnTypeDefault callFormOpen"><spring:message code='Cache.lbl_app_approval_call'/></a><!-- 소명신청 -->
				<% if (isAttendAdmin.equals("ADMIN")){
					out.println("<a class=\"btnTypeDefault btnExcel\" href=\"#\" onclick=\"excelDownload();\">엑셀저장</a>		<!-- 엑셀저장 -->"+						
					"<a class=\"btnTypeDefault btnExcel\" href=\"#\" onclick=\"openExcelPopup();\">엑셀양식</a>		<!-- 엑셀저장 -->						");
				}%>
			</div>
			<div class="buttonStyleBoxRight">
				<spring:message code='Cache.lbl_NoAction'/>	<!-- 미조치 -->
				<select class="selectType02 listCount" id="listCount" onchange="search(1); return false;">
					<option value="10">10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="50">50</option>
					<option value="100">100</option>
				</select>
				<button href="#" class="btnRefresh" type="button" onclick="search(1); return false;"></button> 
			</div>

		</div>
		<!-- 목록보기-->
		<div class="tblList tblCont boradBottomCont" id="gridExHoDiv"></div>			
	</div>												
</div>		
</div>					
					
<script type="text/javascript">
var g_curDate = CFN_GetLocalCurrentDate("yyyy-MM-dd");
var strtWeek = parseInt(Common.getBaseConfig("AttBaseWeek"));
var grid = new coviGrid();
var isAdmin = "<%=isAttendAdmin%>";
var page = 1;
var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");

if(CFN_GetCookie("AttListCnt")){
	pageSize = CFN_GetCookie("AttListCnt");
}
if(pageSize===null||pageSize===""||pageSize==="undefined"){
	pageSize=10;
}

$("#listCount").val(pageSize);

$(document).ready(function(){
	AttendUtils.getDeptList($("#deptList"),'', false, false, true);
	
	sDate = AttendUtils.getWeekStart(new Date(replaceDate(g_curDate)), strtWeek-1);
	sDate = schedule_SetDateFormat(sDate, '-');
	eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '-');
	
    $("#searchDate_StartDate").val(sDate);
    $("#searchDate_EndDate").val(eDate);
    
	setTodaySearch();
	
	//이전
	$(".pre").click(function(){
		var startDateObj = new Date(replaceDate($("#searchDate_StartDate").val()));
		sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -7), '-');
		eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '-');
		
        $("#searchDate_StartDate").val(sDate);
        $("#searchDate_EndDate").val(eDate);
		setPage(1);
	});
	
	//이후
	$(".next").click(function(){
		var startDateObj = new Date(replaceDate($("#searchDate_StartDate").val()));
		sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 7), '-');
		eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 13), '-');
        $("#searchDate_StartDate").val(sDate);
        $("#searchDate_EndDate").val(eDate);
		setPage(1);
	});
	$("#TotCnt").click(function(){
		$("#ApprovalSts").val("");
		$("#ApprovalStsU").val("");
		setPage(1);
	});
	$("#NotCnt").click(function(){
		$("#ApprovalStsU").val("NOT");
		setPage(1);
	});
	
	$("#CanCnt").click(function(){
		$("#ApprovalSts").val("S");
		setPage(1);
	});
	
	//사용자명 검색
	$("#searchText").on('keypress', function(e){ 
		if (e.which == 13) {
			search(1);
	    }
	});

	$("#btnSearch").click(function(){
		search(1);
	});
	init();
	setDatePickerExHo();
});

function init(){
	toggleTab('O');

	// 상세 보기
	$('.btnDetails').on('click', function() {
		var mParent = $('.inPerView');
		if(mParent.hasClass('active')){
			mParent.removeClass('active');
			$(this).removeClass('active');
		}else {
			mParent.addClass('active');
			$(this).addClass('active');
		}
	});
	
	//연장
	$(".exFormOpen").click(function(){
		AttendUtils.openOverTimePopup();
	});
	//휴일
	$(".hoFormOpen").click(function(){
		AttendUtils.openHolidayPopup();
	});
	//소명
	$(".callFormOpen").click(function(){
		AttendUtils.openCallPopup();
	});

	
	var searchType ="<%=(request.getParameter("searchType") == null) ? "" : request.getParameter("searchType")%>";
	if(searchType=="Ex"){
		setSeachParamList();
	}
}


function setGridHeader(gridType) {
	grid = new coviGrid();
	// header
	var	headerData = null;
	if (gridType == "C"){ //소명
		headerData = [
		          	{key:'CallingSeq', label:'callingChk', width:'25', align:'center', formatter:'checkbox', sort:false},
					{key:'TransMultiDisplayName', label:'<spring:message code="Cache.lbl_name" />', width:'50', align:'center' }, /* 이름  */
					{key:'TransMultiDeptName', label:'<spring:message code="Cache.lbl_SmartDept" />', width:'50', align:'center' },	/* 부서 */
		  			{key:'TargetDate', label:'<spring:message code="Cache.lbl_att_workDate" />', width:'50', align:'center'}, /* 근무일 */ 
		  			{key:'CommuteYnStr', label:'<spring:message code="Cache.lbl_Gubun" />', width:'50', align:'center'}, /* 구분 */
	  				{key:'PreChangeTime', label:'<spring:message code="Cache.lbl_att_change_preTime" />', width:'80', align:'center'}, /* 변경전시간 */
	  				{key:'ChangeTime', label:'<spring:message code="Cache.lbl_att_change_time" />', width:'80', align:'center'}, /* 변경시간 */
	  				{key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDate" />', width:'90', align:'center'}, /* 등록일 */
	  				{key:'Etc', label:'<spring:message code="Cache.lbl_att_calling_contents" />', width:'50', align:'center'}, /* 소명내용  */
		  			{key:'BillName',  label:'<spring:message code="Cache.lbl_att_approvalForm" />', width:'200', align:'center',
						formatter:function(){ 
							return String.format("<a onclick='javascript:openForm(\"\",\"{1}\");' >{0}</a>", this.item.BillName, this.item.ProcessId);
						}	
					}
	 		];  
	}
	else {//연장근무신처서
			headerData = [
	 	          	{key:'ExHoSeq', label:'exHoChk', width:'25', align:'center', formatter:'checkbox', sort:false},
					{key:'TransMultiDisplayName', label:'<spring:message code="Cache.lbl_name" />', width:'50', align:'center' },
		  			{key:'JobStsNameKr', label:'<spring:message code="Cache.lbl_Gubun" />', width:'50', align:'center'},
		  			{key:'JobDate', label:'<spring:message code="Cache.lbl_att_workDate" />', width:'50', align:'center'},
		  			{key:'f_StartTime',  label:'<spring:message code="Cache.lbl_StartTime" />', width:'50', align:'center',
						formatter:function(){ 
							return String.format("<span class='exHo' data='{1}' >{0}</span>", this.item.f_StartTime, this.item.ExHoSeq);
						}	
					}, 
		  			{key:'f_EndTime',  label:'<spring:message code="Cache.lbl_EndTime" />', width:'50', align:'center',
						formatter:function(){ 
							return String.format("<span class='exHo' data='{1}' >{0}</span>", this.item.f_EndTime, this.item.ExHoSeq);
						}	
					}, 
		  			{key:'f_WorkTime',  label:'<spring:message code="Cache.lbl_att_ac_time" />', width:'50', align:'center',
						formatter:function(){  
							return String.format("<span class='exHo' data='{1}' >{0}</span>", this.item.f_WorkTime, this.item.ExHoSeq);
						}	
					}, 
		  			{key:'Etc', label:'<spring:message code="Cache.lbl_att_reason" />', width:'50', align:'center'},
		  			{key:'ApprovalSts', label:'<spring:message code="Cache.lbl_att_approvalSts" />', width:'50', align:'center',
						formatter:function(){
							switch (this.item.ApprovalSts)
							{
								case "S":
									return "<spring:message code='Cache.lbl_att_approval_cancel' />";
									break;
								case "N":
									return "<spring:message code='Cache.lbl_Cancel' />";
								default :	
									return "<spring:message code='Cache.lbl_att_approval' />";
									
							}
						}	
		  			},
		  			{key:'ApprovalStsU', label:'<spring:message code="Cache.lbl_RunState" />', width:'50', align:'center',
						formatter:function(){
							switch (this.item.ApprovalStsU)
							{
								case "NOT":
									return "<spring:message code='Cache.lbl_att_approval_notRunning' />";
									break;
								case "SUCCESS":	
									return "<spring:message code='Cache.lbl_att_approval_runningSuccess' />";
									break;
								default :
									switch (this.item.ApprovalSts)
									{
										case "S":
											return "<spring:message code='Cache.lbl_att_approval_cancel' />";
											break;
										case "N":
											return "<spring:message code='Cache.lbl_Cancel' />";
										default :	
											return "<spring:message code='Cache.lbl_att_approval' />";
											
									}
									
							}
						}	
					},
		  			{key:'BillName',  label:'<spring:message code="Cache.lbl_att_approvalForm" />', width:'200', align:'center',
						formatter:function(){ 
							return String.format("<a onclick='javascript:openForm(\"\",\"{1}\");' >{0}</a>", this.item.BillName, this.item.ProcessId);
						}	
					}
		  		]; 
	}
	var configObj = {
		targetID : "gridExHoDiv",
		height:"auto",			
		paging : true,
		page : {
			pageNo:1,
			pageSize:$("#listCntSel").val()
		}
	};
	
	grid.setGridHeader(headerData);
	grid.setGridConfig(configObj);
	//grid.setConfig(});

}

$(document).on("click",".exHo",function(){
	if(isAdmin == "ADMIN"){
		openExHoSchPop($(this).attr("data"));
	}	
});

function setPage (n) {
	$("#pageNo").val(n);
	search();
}


//검색
function searchList(gDate) {
	sDate = AttendUtils.getWeekStart(new Date(replaceDate(gDate)), strtWeek-1);
	sDate = schedule_SetDateFormat(sDate, '-');
	eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '-');
    $("#searchDate_StartDate").val(sDate);
    $("#searchDate_EndDate").val(eDate);
    search();
}

function search(){
	
	var params = {
				  StartDate : $('#searchDate_StartDate').val(),
				  EndDate : $('#searchDate_EndDate').val(),
				  ApprovalSts : $('#ApprovalSts').val(),
				  ApprovalStsU : $('#ApprovalStsU').val(),
			  	  sortBy : "JobDate DESC",
			  	  GroupPath : $("#deptList").val(),
		  		  JobStsName : $('#JobStsName').val(),
			  	  RetireUser : $("#retireUser").is(":checked")?"Y":"N",
			  	  searchText : $('#searchText').val(),
			  	  isAttendAdmin : "<%=isAttendAdmin%>"
				};
	
	grid.page.pageNo = $("#pageNo").val();
	grid.page.pageSize = $("#listCount").val();
	$("#dateTitle").text (AttendUtils.maskDate($("#searchDate_StartDate").val()) +"~"+ AttendUtils.maskDate($("#searchDate_EndDate").val()));
	
	// bind
	grid.bindGrid({
		ajaxUrl : "/groupware/attendExHo/getExHoInfoList.do",
		ajaxPars : params,
		response: function(){ 
			grid.ajaxGetList(this);
			
			$("#OverCnt").text(this.foot.OverCnt==null?"":this.foot.OverCnt);
			$("#TotTime").text(AttendUtils.convertSecToStr(this.foot.TotTime*60,"H"));
			$("#TotCnt").text(this.foot.ExHoCnt==null?"":this.foot.ExHoCnt);
			$("#NotCnt").text(this.foot.NotCnt==null?"":this.foot.NotCnt);
			$("#CanCnt").text(this.foot.CanCnt==null?"":this.foot.CanCnt);
			
			if(isAdmin == "ADMIN"){
				$(".exHo").css("cursor","pointer");
			}

			
	    }
	});

}

function setDatePickerExHo(){
	$("#searchDate_StartDate").datepicker({
		dateFormat: 'yy.mm.dd',
	    showOn: 'button',
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true
	});
	$("#searchDate_EndDate").datepicker({
		dateFormat: 'yy.mm.dd',
	    showOn: 'button',
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true,
        onSelect : function(selected){
        	var $start = $("#searchDate_StartDate");
        	var startDate = new Date($start.val().replaceAll(".", "/"));
        	var endDate = new Date(selected.replaceAll(".", "/"));

        	if (startDate.getTime() > endDate.getTime()){
        		Common.Warning("<spring:message code='Cache.mag_Attendance19' />"); //시작일 보다 이전 일 수 없습니다.
        		$("#searchDate_EndDate").val(startDate.format('yyyy.MM.dd'));
        	}
        }
	});
	
	$(".txtDate").focusout(function(obj){
		obj = obj.currentTarget; 
		var dataStr = $(obj).val();
		if(dataStr != ""){
			if(dataStr.split('.').length != 3){
				if(dataStr.replaceAll(".", "").length == 8){
					var returnStr = dataStr.substring(0, 4) + "." + dataStr.substring(4, 6) + "." + dataStr.substring(6, 8);
					
					if(!isNaN(Date.parse(returnStr))){
						$(obj).val(returnStr);
						//coviCtrl.getHWMY(target, "end");
					}
					else{
						$(obj).val("");
						$(".txtDate").val("");
						Common.Warning("<spring:message code='Cache.mag_Attendance20' />");		//날짜 포맷에 맞는 데이터를 입력해주시기 바랍니다.
					}
				}else{
					$(obj).val("");
					$(".txtDate").val("");
					Common.Warning("<spring:message code='Cache.mag_Attendance20' />");		//날짜 포맷에 맞는 데이터를 입력해주시기 바랍니다.
				}
			}
		}
	});
}

function cancle(s){
	
	var msg = "";
	
	var canArray = new Array();
	
	for(var i=0;i<$("input[name=exHoChk]").length;i++){
		if($("input[name=exHoChk]").eq(i).is(":checked")){
			canArray.push($("input[name=exHoChk]").eq(i).val());
		}
	}
	
	if(canArray.length>0){
		
		if(s=="S"){
			msg = "<spring:message code='Cache.msg_att_cancel'/>";
		}else if(s=="N"){
			msg = "<spring:message code='Cache.msg_att_cancel_approval'/>";
			// 취소신청 대상만 선택했을 때 취소 승인함.
			if (grid.getCheckedList(0).length > 0 ) {
				for (let i=0;i<grid.getCheckedList(0).length;i++) {
					if (!(grid.getCheckedList(0)[i].ApprovalSts === "S")) {
						Common.Confirm("<spring:message code='Cache.lbl_att_approval_cancel'/> <spring:message code='Cache.msg_SelectTarget'/>", "Infomation", ); 	// 취소신청 대상을 선택해주세요.
						return;
					}
				}
			}
		}
		
		Common.Confirm(msg, "Infomation", function(result) {
			if(result) {
				
				var params = {
					canArray : JSON.stringify(canArray)
					, ApprovalSts : s
				};
				
				$.ajax({
					url : "/groupware/attendExHo/cancelExHoStatus.do",
					type: "POST",
					dataType : 'json',
					data : params,
					success:function (data) {
						if(data.status=='SUCCESS'){
							Common.Inform("<spring:message code='Cache.msg_att_cancel_alram'/>","Infomation","");
							search(1);
						}else{
							Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
						}
					},
					error:function (error){
						//CFN_ErrorAjax("/groupware/layout/attendance_AttendanceBaseInfo.do", response, status, error);
					}
				}); 
				
			}
		});
	}else{
		Common.Inform("대상을 선택 해 주세요","Infomation","");
	}

	
}

//엑셀 다운로드
function excelDownload(){
	$('#download_iframe').remove();
	var params = {urName : $('#schUrName').val(),
			  StartDate : $('#searchDate_StartDate').val()!=undefined?$('#searchDate_StartDate').val():"",
			  EndDate : $('#searchDate_EndDate').val()!=undefined?$('#searchDate_EndDate').val():"",
		  	  DEPTID : $("#deptList").val(),
		  	  JobStsName : $('#JobStsName').val(),
		  	  GroupPath : $("#deptList").val(),
		  	  searchText : $('#searchText').val()
			};
	ajax_download('/groupware/attendExHo/excelDownAttendanceExHo.do', params);	// 엑셀 다운로드 post 요청
	
}

//엑셀폼 다운
function openExcelPopup(){
	var popupID		= "AttendExHoPopup";
	var openerID	= "AttendExtennHolyday";
	var popupTit	= "<spring:message code='Cache.lbl_SaveToExcel' />";
	var popupYN		= "N";
	var popupUrl	= "/groupware/attendExHo/AttendExHoExcelPopup.do?"
					+ "popupID="		+ popupID	+ "&"
					+ "openerID="		+ openerID	+ "&"
					+ "popupYN="		+ popupYN	+ "&"
					+ "StartDate="		+ $('#searchDate_StartDate').val() + "&"
					+ "EndDate="		+ $('#searchDate_EndDate').val() ;
	
	Common.open("", popupID, popupTit, popupUrl, "500px", "450px", "iframe", true, null, null, true);
}

function refreshList(){
	sDate = AttendUtils.getWeekStart(new Date(replaceDate(g_curDate)), strtWeek-1);
	sDate = schedule_SetDateFormat(sDate, '-');
	eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '-');
	
    $("#searchDate_StartDate").val(sDate);
    $("#searchDate_EndDate").val(eDate);
	
	search(1);
}

function toggleTab(t){
	$(".topToggle").attr("class","topToggle");
	$(".exhoSearch").removeAttr("style","display");
	if(isAdmin != "ADMIN"){
		$(".isAdminChk").hide();
	}
	else{
		$(".isAdminChk").show();
	}
	
/*	if(isAdmin == "ADMIN"){
	}
*/
	if(t=="C"){
		$("#JobStsName").val("C");
		$(".ATMTop_info_Time").hide();
		$(".exhoSearch").attr("style","display:none;");
		$(".topToggle").eq(1).attr("class","topToggle active");
		$(".ATMTop_info_Time").removeClass("my_overtime");
	}else{
		$("#JobStsName").val("");
		$(".ATMTop_info_Time").show();
		$(".topToggle").eq(0).attr("class","topToggle active");
		$(".ATMTop_info_Time").addClass("my_overtime");
		checkValueEmpty();
	}	
	setGridHeader(t);
	search(1);
}

function setSeachParamList(){
	
	var ApprovalSts ="<%=(request.getParameter("ApprovalSts") == null) ? "" : request.getParameter("ApprovalSts")%>";
	var TargetDate ="<%=(request.getParameter("TargetDate") == null) ? "" : request.getParameter("TargetDate")%>";
	$("#ApprovalStsU").val(ApprovalSts);
	$("#searchDate_StartDate").val(TargetDate);
	$("#searchDate_EndDate").val(TargetDate);
	$(".btnDetails").trigger("click");
	
	search(1);
}

// 내 연장,휴일 근무 값 미표기 방지용
function checkValueEmpty(){
	var OverCnt = $("#OverCnt");
	var TotTime = $("#TotTime");
	var TotCnt = $("#TotCnt");
	var NotCnt = $("#NotCnt");
	var CanCnt = $("#CanCnt");
	if(OverCnt.text() === "" || OverCnt.text() === null || OverCnt.text() === 'undefined'){
		OverCnt.text("0");
	}
	if(TotTime.text() === "" || TotTime.text() === null || TotTime.text() === 'undefined'){
		TotTime.text("0");
	}
	if(TotCnt.text() === "" || TotCnt.text() === null || TotCnt.text() === 'undefined'){
		TotCnt.text("0");
	}
	if(NotCnt.text() === "" || NotCnt.text() === null || NotCnt.text() === 'undefined'){
		NotCnt.text("0");
	}
	if(CanCnt.text()=== "" || CanCnt.text() === null || CanCnt.text() === 'undefined'){
		CanCnt.text("0");
	}
}

</script>
				