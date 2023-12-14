<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- 통합업무관리 업무보고 팀원주간조회 시작-->
<div class="cRConTop titType">
	<span></span>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.lbl_weeklyreportteam' /></h2>
	<h2 id="dateTitle" class="title"></h2>
	<div class="pagingType02">
		<a class="pre" onclick="clickTopButton('PREV');"></a><a class="next" onclick="clickTopButton('NEXT');"></a><a onclick="setCurrentDate();" class="btnTypeDefault"><spring:message code='Cache.lbl_Todays' /></a><!-- 오늘 -->
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="ITMSubCont" id="divProjectTaskWeekly">
		<table class="ITM_Businessreport_Team_table">
			<thead>
				<tr>
					<th width="100" class="ITMTableLine"><spring:message code='Cache.lbl_username' /></th>
					<th width="" class="ITMTableLine"><spring:message code='Cache.lbl_prj_ConAndIssue' /></th>
					<%-- <th width="120" class="ITMTableLine"><spring:message code='Cache.lbl_Project' /></th> --%>
					<th width="" class="ITMTableLine"><spring:message code='Cache.lbl_prj_nextWeekPlan' /></th>
					<%-- <th width="80" class="ITMTableLine"><spring:message code='Cache.lbl_Status' /></th>
					<th width="80" class="ITMTableLine"><spring:message code='Cache.lbl_ProgressRate' /></th>
					<th width="" class="ITMTableLine"><spring:message code='Cache.lbl_Contents' /></th> --%>
					<!-- <th width="400" colspan="8">투입시간</th> -->
				</tr>
			</thead>
		</table>
		<div class="ITM_Businessreport_Team_table_scroll mScrollV scrollVType01">
		<table class="ITM_Businessreport_Team_table" id="tbReportWeekly">
			<colgroup>
				<col width="100"/>
				<col width=""/>
				<!-- <col width="120"/> -->
				<col width=""/>
				<!-- <col width="80"/>
				<col width="80"/>
				<col width=""/> -->
			</colgroup>
			<tbody>
			</tbody>
		</table>
		</div>
	</div>
</div>
<!-- 통합업무관리 업무보고 팀원주간조회 끝-->

<script type="text/javascript">
	var userCode = Common.getSession("UR_Code");
	var userDeptCode = Common.getSession("GR_Code");
	var setPrjCode = "";
	var objMyTeamList; //관리부서 정보
	var startDate = "";
	var endDate = "";
	
	var grid = new coviGrid();
	
	initContent();
	
	function initContent() {
		init(); 	// 초기화
	}
	
	// 초기화
	function init() {
		//프로젝트명
		$.getJSON("/groupware/bizreport/getMyTeamMembers.do",{deptCode : userDeptCode}, function(d) {
			objMyTeamList = d.MyTeamList;
		}).error(function(response, status, error){
			 //TODO 추가 오류 처리
			 CFN_ErrorAjax("/groupware/bizreport/getMyTeamMembers.do", response, status, error);
		});
		setCurrentDate();
	}
	
	function setTable() {
		$(".reportData").remove();
		$.getJSON("/groupware/bizreport/getTaskReportWeeklyListAll.do",{startDate : startDate, endDate : endDate, userCode : userCode, deptCode : userDeptCode}, function(d) {
			//일반업무보고
			var projectTaskDaily = d.ProjectTaskList;
			var folderDaily = d.FolderList;
			var taskDaily = d.TaskList;
			var reportDaily = d.GeralList;
			var reportWeekly = d.ReportList;
			var totalcount = reportWeekly.length;
			
			if( totalcount == 0 ){
				var outterTr = $("<tr></tr>").html("<td colspan='7'></td>").addClass("reportData").show();
				outterTr.find("td").eq(0).text("<spring:message code='Cache.msg_haveNotReportData' />");
				$("#tbReportWeekly").append(outterTr);
			}else{
				objMyTeamList.forEach(function(oTeamMember, idx){
					var lusercode = oTeamMember.UserCode;
					var lprojectTaskDaily = projectTaskDaily.filter(function(object){ return object["TaskMemberCode"]===lusercode});
					var lfolderDaily = folderDaily.filter(function(object){ return object["TaskMemberCode"]===lusercode});
					var ltaskDaily = taskDaily.filter(function(object){ return object["TaskMemberCode"]===lusercode});
					var lreportDaily = reportDaily.filter(function(object){ return object["TaskMemberCode"]===lusercode});
					var lreportWeekly = reportWeekly.filter(function(object){ return object["RegisterCode"]===lusercode});
					var memberreporttotalcount = lreportWeekly.length;
					
					if( memberreporttotalcount == 0 ){
						var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td></td><td></td>");
						outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(oTeamMember.DeptName,lang) + "<br>" + CFN_GetDicInfo(oTeamMember.UserName,lang)+"</strong>").addClass("bg_skyblue");
						$("#tbReportWeekly").append(outterTr);
					}else{
						//주간보고 등록 사항 기준으로 출력
						lreportWeekly.forEach(function(reportitem, ridx) {
							if(reportitem.TaskGubunCode == "TF" && reportitem.ProjectCode != "" ){
								var llprojectTaskDaily = lprojectTaskDaily.filter(function(object){ return object["ProjectCode"]===reportitem.ProjectCode});
								//프로젝트 업무보고 출력
								if(llprojectTaskDaily.length == 0 ){
									var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td></td><td></td>");
									outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(oTeamMember.DeptName,lang) + "<br>" + CFN_GetDicInfo(oTeamMember.UserName,lang)+"</strong>").addClass("bg_skyblue");
									outterTr.find("td").eq(1).text(convertTaskGubun("TF"));
									outterTr.find("td").eq(2).text(reportitem.ProjectCode);
									//outterTr.find("td").eq(3).text(item.TaskName);
									//outterTr.find("td").eq(4).text(item.TaskState);
									//outterTr.find("td").eq(5).text(item.TaskPercent);
									//outterTr.find("td").eq(4).text(r_item.TaskHour);
									//outterTr.find("td").eq(6).html(item.TaskEtc.replaceAll("\n", "<br>"));
									$("#tbReportWeekly").append(outterTr);
								}else{
									llprojectTaskDaily.forEach(function(item) {
										var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td></td><td></td>");
										outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(item.DeptName,lang) + "<br>" + CFN_GetDicInfo(item.UserName,lang)+"</strong>").addClass("bg_skyblue");
										outterTr.find("td").eq(1).text(convertTaskGubun(item.TaskGubunCode));
										//outterTr.find("td").eq(2).text(item.CommunityName);
										outterTr.find("td").eq(2).text(item.TaskName);
										outterTr.find("td").eq(3).text(item.TaskState);
										outterTr.find("td").eq(4).text(item.TaskPercent);
										//outterTr.find("td").eq(4).text(r_item.TaskHour);
										outterTr.find("td").eq(5).html(item.TaskEtc.replaceAll("\n", "<br>"));
										$("#tbReportWeekly").append(outterTr);
									});
								}
								var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td colspan='2'></td><td></td><td colspan='2'></td>");
								outterTr.find("td").eq(0).html("<strong><spring:message code='Cache.lbl_prj_nextWeekPlan' /></strong>").addClass("bg_skyblue");
								outterTr.find("td").eq(1).html(reportitem.NextPlan.replaceAll("\n", "<br>"));
								//outterTr.find("td").eq(2).html("<strong><spring:message code='Cache.lbl_prj_ConAndIssue' /></strong>").addClass("bg_skyblue");
								outterTr.find("td").eq(2).html(reportitem.WeekEtc.replaceAll("\n", "<br>"));
								$("#tbReportWeekly").append(outterTr);
							}
							
							if(reportitem.TaskGubunCode == "Task"){
								//폴더 업무보고 출력
								lfolderDaily.forEach(function(item) {
									var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).html("<td></td><td></td><td></td>").addClass("reportData").show();
									outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(item.DeptName,lang) + "<br>" + CFN_GetDicInfo(item.UserName,lang)+"</strong>").addClass("bg_skyblue");
									outterTr.find("td").eq(1).text(convertTaskGubun(item.TaskGubunCode));
									//outterTr.find("td").eq(2).text(item.DisplayName);
									outterTr.find("td").eq(2).text(item.TaskName);
									outterTr.find("td").eq(3).text(item.TaskState);
									outterTr.find("td").eq(4).text(item.TaskPercent);
									//outterTr.find("td").eq(4).text(r_item.TaskHour);
									outterTr.find("td").eq(5).html(item.TaskEtc.replaceAll("\n", "<br>"));
									$("#tbReportWeekly").append(outterTr);
								});
								
								//Task 업무보고 출력
								ltaskDaily.forEach(function(item) {
									var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td></td><td></td>");
									outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(item.DeptName,lang) + "<br>" + CFN_GetDicInfo(item.UserName,lang)+"</strong>").addClass("bg_skyblue");
									outterTr.find("td").eq(1).text(convertTaskGubun(item.TaskGubunCode));
									//outterTr.find("td").eq(2).text(item.Subject);
									outterTr.find("td").eq(2).text(item.TaskName);
									outterTr.find("td").eq(3).text(item.TaskState);
									outterTr.find("td").eq(4).text(item.TaskPercent);
									//outterTr.find("td").eq(4).text(r_item.TaskHour);
									outterTr.find("td").eq(5).html(item.TaskEtc.replaceAll("\n", "<br>"));
									$("#tbReportWeekly").append(outterTr);
								});
								
								//주간보고 사항 등록
								var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td colspan='2'></td><td></td><td colspan='2'></td>");
								outterTr.find("td").eq(0).html("<strong><spring:message code='Cache.lbl_prj_nextWeekPlan' /></strong>").addClass("bg_skyblue");
								outterTr.find("td").eq(1).html(reportitem.NextPlan.replaceAll("\n", "<br>"));
								outterTr.find("td").eq(2).html("<strong><spring:message code='Cache.lbl_prj_ConAndIssue' /></strong>").addClass("bg_skyblue");
								outterTr.find("td").eq(3).html(reportitem.WeekEtc.replaceAll("\n", "<br>"));
								$("#tbReportWeekly").append(outterTr);
							}
							
							if(reportitem.TaskGubunCode == "G"){
								var rowspan = 1;
								//일일 업무보고 출력
								var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td></td><td></td>");
								outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(reportitem.DeptName,lang) + "<br>" + CFN_GetDicInfo(reportitem.UserName,lang)+"</strong>").addClass("bg_skyblue");
								//outterTr.find("td").eq(1).html("<strong><spring:message code='Cache.lbl_prj_ConAndIssue' /></strong>").addClass("bg_skyblue");
								outterTr.find("td").eq(1).html(reportitem.WeekEtc.replaceAll("\n", "<br>"));
								//outterTr.find("td").eq(3).html("<strong><spring:message code='Cache.lbl_prj_nextWeekPlan' /></strong>").addClass("bg_skyblue");
								outterTr.find("td").eq(2).html(reportitem.NextPlan.replaceAll("\n", "<br>"));
								
								$("#tbReportWeekly").append(outterTr);
							}
						});
					}
				});
			}
		}).error(function(response, status, error){
			//TODO 추가 오류 처리
			CFN_ErrorAjax("/groupware/bizreport/getTaskReportWeeklyListAll.do", response, status, error);
		});
	}
	
	function setDateFormat(pDate, pType) {
		var formattedDate = '';
		var date = new Date(replaceDate(pDate));
		var year = date.getFullYear();
		var month = date.getMonth() + 1;
		var day = date.getDate();
		
		if (month < 10) {
			month = '0' + month;
		}
		if (day < 10) {
			day = '0' + day;
		}
		
		switch (pType) {
			case '.': formattedDate = year + '.' + month + '.' + day;
				break;
			case '/': formattedDate = year + '/' + month + '/' + day;
				break;
			case '-': formattedDate = year + '-' + month + '-' + day;
				break;
			case '': formattedDate = year.toString() + month.toString() + day.toString();
				break;
		}
		
		return formattedDate;
	}
	
	//특정일이 속한 일요일
	function getSunday(d) {
		var date = new Date(d);
		var day = date.getDay();
		var diff = date.getDate() - day;
		return new Date(replaceDate(date.setDate(diff)));
	}
	
	//지정한 만큼 이후 일
	function addDays(strDate, days) {
		var date = new Date(replaceDate(strDate));
		var d = date.getDate() + days;
		date.setDate(d);
		return date;
	}
	
	//날짜 이동 버튼
	function clickTopButton(liType){
		var startDateObj = new Date(replaceDate(startDate));
		
		if(liType == "PREV") { // 이전
			sDate = setDateFormat(addDays(startDateObj, -7), '.');
			eDate = setDateFormat(addDays(startDateObj, -1), '.');
		}else if(liType == "NEXT"){		// 다음
			sDate = setDateFormat(addDays(startDateObj, 7), '.');
			eDate = setDateFormat(addDays(startDateObj, 13), '.');
		}
		
		dateArr = new Array();
		
		dateArr.push(getSunday(replaceDate(sDate)));
		var strSun = setDateFormat(dateArr[0], '/');
		dateArr.push(addDays(strSun, 1));
		dateArr.push(addDays(strSun, 2));
		dateArr.push(addDays(strSun, 3));
		dateArr.push(addDays(strSun, 4));
		dateArr.push(addDays(strSun, 5));
		dateArr.push(addDays(strSun, 6));
		
		startDate = sDate;
		endDate = eDate;
		
		// 상단 제목 날짜 표시
		$('#dateTitle').html("(" + startDate + ' ~ ' + endDate + ")");
		
		setTable();
	}
	
	//오늘 날짜
	function setCurrentDate(){
		var rDate = new Date();
		startDateObj = rDate.format("yyyy-MM-dd");
		
		dateArr = new Array();
		
		dateArr.push(getSunday(startDateObj));
		var strSun = setDateFormat(dateArr[0], '/');
		dateArr.push(addDays(strSun, 1));
		dateArr.push(addDays(strSun, 2));
		dateArr.push(addDays(strSun, 3));
		dateArr.push(addDays(strSun, 4));
		dateArr.push(addDays(strSun, 5));
		dateArr.push(addDays(strSun, 6));
		
		startDate = dateArr[0].format("yyyy-MM-dd");
		endDate =  dateArr[6].format("yyyy-MM-dd")
		
		// 상단 제목 날짜 표시
		$('#dateTitle').html("(" + startDate + ' ~ ' + endDate + ")");
		
		setTable();
	}
	
	function convertTaskGubun(pTaskGubunCode){
		var rtnTaskType ="<spring:message code='Cache.lbl_generalwork' />";
		
		switch(pTaskGubunCode){
			case "TF": rtnTaskType="<spring:message code='Cache.lbl_Project' />";break;
			case "Task": rtnTaskType="<spring:message code='Cache.lbl_TaskManage' />";break;
			case "G": rtnTaskType="<spring:message code='Cache.lbl_generalwork' />";break;
		}
		
		return rtnTaskType;
	}
</script>