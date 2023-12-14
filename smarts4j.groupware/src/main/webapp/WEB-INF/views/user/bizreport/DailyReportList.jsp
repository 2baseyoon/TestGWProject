<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class='cRConTop titType'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.lbl_dailyreportlist1' /></h2><!-- 일일보고 등록 -->
	<h2 id="dateTitle" class="title"></h2>
	<div class="pagingType02">
		<a class="pre" onclick="clickTopButton('PREV');"></a><a class="next" onclick="clickTopButton('NEXT');"></a><a onclick="setCurrentDate();" class="btnTypeDefault"><spring:message code='Cache.lbl_Todays' /></a><!-- 오늘 -->
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="ITMSubCont" id="divProjectTaskDaily">
		<table class="ITM_Businessreport_Team_table">
			<thead>
				<tr>
					<th width="100" class="ITMTableLine"><spring:message code='Cache.lbl_username' /></th>
					<th width="120" class="ITMTableLine"><spring:message code='Cache.lbl_Division2' /></th>
					<%-- <th width="120" class="ITMTableLine"><spring:message code='Cache.lbl_Project' /></th> --%>
					<th width="" class="ITMTableLine"><spring:message code='Cache.lbl_prj_workName' /></th>
					<th width="80" class="ITMTableLine"><spring:message code='Cache.lbl_Status' /></th>
					<th width="80" class="ITMTableLine"><spring:message code='Cache.lbl_ProgressRate' /></th>
					<th width="" class="ITMTableLine"><spring:message code='Cache.lbl_Contents' /></th>
					<!-- <th width="400" colspan="8">투입시간</th> -->
				</tr>
			</thead>
		</table>
		<div class="ITM_Businessreport_Team_table_scroll mScrollV scrollVType01">
		<table class="ITM_Businessreport_Team_table" id="tbReportDaily">
			<colgroup>
				<col width="100"/>
				<col width="120"/>
				<!-- <col width="120"/> -->
				<col width=""/>
				<col width="80"/>
				<col width="80"/>
				<col width=""/>
			</colgroup>
			<tbody>
			</tbody>
		</table>
		</div>
	</div>
</div>
<!-- 통합업무관리 업무보고 팀원주간조회 끝-->
<script>
	var userCode = Common.getSession("UR_Code");
	var userDeptCode = Common.getSession("GR_Code");
	var chkTaskTime = true;
	var currentDate = "";
	var taskCode = CFN_GetQueryString("taskID");
	var pmCode = CFN_GetQueryString("pmCode");
	var userCd = Common.getSession("UR_Code");
	var schType = "";
	var objMyTeamList; //관리부서 정보
	
	if(userCd == pmCode){
		schType = "PM";
	}else{
		schType = "Task";
	}
	
	initContent();
	
	function initContent() {
		init(); //초기화
	}
	
	//초기화
	function init() {
		coviInput.setDate();
		//해당 사용자(팀장/본부장)이 관리 팀 및 팀원 정보 조회
		$.getJSON("/groupware/bizreport/getMyTeamMembers.do",{deptCode : userDeptCode}, function(d) {
			objMyTeamList = d.MyTeamList;
		}).error(function(response, status, error){
			//TODO 추가 오류 처리
			CFN_ErrorAjax("/groupware/bizreport/getMyTeamMembers.do", response, status, error);
		});
		//오늘 날짜 바인딩
		setCurrentDate();
	}
	
	function setTable() {
		$(".reportData").remove();
		$.getJSON("/groupware/bizreport/getTaskReportDailyListAll.do",{startDate : currentDate, endDate : currentDate, userCode : userCode, deptCode : userDeptCode}, function(d) {
			//일반업무보고
			var projectTaskDaily = d.ProjectTaskList;
			var folderDaily = d.FolderList;
			var taskDaily = d.TaskList;
			var reportDaily = d.ReportList;
			var totalcount = projectTaskDaily.length + folderDaily.length + taskDaily.length + reportDaily.length;
			
			if( totalcount == 0 ){
				var outterTr = $("<tr></tr>").html("<td colspan='7'></td>").addClass("reportData").show();
				outterTr.find("td").eq(0).text("<spring:message code='Cache.msg_haveNotReportData' />");
				$("#tbReportDaily").append(outterTr);
			}else{
				var allCount = 0;
				objMyTeamList.forEach(function(oTeamMember, idx){
					var lusercode = oTeamMember.UserCode;
					var lprojectTaskDaily = projectTaskDaily.filter(function(object){ return object["TaskMemberCode"]===lusercode});
					var lfolderDaily = folderDaily.filter(function(object){ return object["TaskMemberCode"]===lusercode});
					var ltaskDaily = taskDaily.filter(function(object){ return object["TaskMemberCode"]===lusercode});
					var lreportDaily = reportDaily.filter(function(object){ return object["TaskMemberCode"]===lusercode});
					var memberreporttotalcount = lprojectTaskDaily.length + lfolderDaily.length + ltaskDaily.length + lreportDaily.length;
					
					if( memberreporttotalcount == 0 ){
						var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td></td><td></td><td></td><td></td><td></td>");
						outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(oTeamMember.DeptName,lang) + "<br>" + CFN_GetDicInfo(oTeamMember.UserName,lang)+"</strong>").addClass("bg_skyblue");
						$("#tbReportDaily").append(outterTr);
						allCount++;
					}else{
						//프로젝트 업무보고 출력
						lprojectTaskDaily.forEach(function(item) {
							var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td></td><td></td><td></td><td></td>");
							outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(item.DeptName,lang) + "<br>" + CFN_GetDicInfo(item.UserName,lang)+"</strong>").addClass("bg_skyblue");
							outterTr.find("td").eq(1).text(convertTaskGubun(item.TaskGubunCode));
							//outterTr.find("td").eq(2).text(item.CommunityName);
							outterTr.find("td").eq(2).text(item.TaskName);
							outterTr.find("td").eq(3).text(item.TaskState);
							outterTr.find("td").eq(4).text(item.TaskPercent + "%");
							//outterTr.find("td").eq(4).text(r_item.TaskHour);
							outterTr.find("td").eq(5).html(item.TaskEtc.replaceAll("\n", "<br>"));
							$("#tbReportDaily").append(outterTr);
						});
						//폴더 업무보고 출력
						lfolderDaily.forEach(function(item) {
							var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).html("<td></td><td></td><td></td><td></td><td></td><td></td>").addClass("reportData").show();
							outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(item.DeptName,lang) + "<br>" + CFN_GetDicInfo(item.UserName,lang)+"</strong>").addClass("bg_skyblue");
							outterTr.find("td").eq(1).text(convertTaskGubun(item.TaskGubunCode));
							//outterTr.find("td").eq(2).text(item.DisplayName);
							outterTr.find("td").eq(2).text(item.TaskName);
							outterTr.find("td").eq(3).text(item.TaskState);
							outterTr.find("td").eq(4).text(item.TaskPercent + "%");
							//outterTr.find("td").eq(4).text(r_item.TaskHour);
							outterTr.find("td").eq(5).html(item.TaskEtc.replaceAll("\n", "<br>"));
							$("#tbReportDaily").append(outterTr);
						});
						//Task 업무보고 출력
						ltaskDaily.forEach(function(item) {
							var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td></td><td></td><td></td><td></td><td></td>");
							outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(item.DeptName,lang) + "<br>" + CFN_GetDicInfo(item.UserName,lang)+"</strong>").addClass("bg_skyblue");
							outterTr.find("td").eq(1).text(convertTaskGubun(item.TaskGubunCode));
							//outterTr.find("td").eq(2).text(item.Subject);
							outterTr.find("td").eq(2).text(item.TaskName);
							outterTr.find("td").eq(3).text(item.TaskState);
							outterTr.find("td").eq(4).text(item.TaskPercent + "%");
							//outterTr.find("td").eq(4).text(r_item.TaskHour);
							outterTr.find("td").eq(5).html(item.TaskEtc.replaceAll("\n", "<br>"));
							$("#tbReportDaily").append(outterTr);
						});
						//일일 업무보고 출력
						lreportDaily.forEach(function(item) {
							var outterTr = $("<tr></tr>").css({"text-align":"center","font-size":"12px"}).addClass("reportData").html("<td></td><td></td><td></td><td></td><td></td><td></td>");
							outterTr.find("td").eq(0).html("<strong>"+CFN_GetDicInfo(item.DeptName,lang) + "<br>" + CFN_GetDicInfo(item.UserName,lang)+"</strong>").addClass("bg_skyblue");
							outterTr.find("td").eq(1).text(convertTaskGubun(item.TaskGubunCode));
							//outterTr.find("td").eq(2).text("");
							outterTr.find("td").eq(2).text(item.TaskName);
							outterTr.find("td").eq(3).text(item.TaskState);
							outterTr.find("td").eq(4).text(item.TaskPercent + "%");
							//outterTr.find("td").eq(4).text(r_item.TaskHour);
							outterTr.find("td").eq(5).html(item.TaskEtc.replaceAll("\n", "<br>"));
							$("#tbReportDaily").append(outterTr);
						});
						$(".reportData").eq(allCount).find("td").eq(0).attr("rowspan", memberreporttotalcount);
						for(var i=1; i<memberreporttotalcount; i++) {
							$(".reportData").eq(allCount+i).find("td").eq(0).remove();
						}
						allCount = allCount + memberreporttotalcount;
					}
				});
			}
		}).error(function(response, status, error){
			//TODO 추가 오류 처리
			CFN_ErrorAjax("/groupware/bizreport/getTaskReportDailyListAll.do", response, status, error);
		});
	}
	
	//오늘 날짜
	function setCurrentDate(){
		var rDate = new Date();
		currentDate = rDate.format("yyyy-MM-dd");
		
	 	// 상단 제목 날짜 표시
		$('#dateTitle').html("(" + currentDate + ")");
		
		setTable();
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
		var startDateObj = new Date(replaceDate(currentDate));
		
		if(liType == "PREV") { // 이전
			currentDate = setDateFormat(addDays(startDateObj, -1), '-');
		}else if(liType == "NEXT"){		// 다음
			currentDate = setDateFormat(addDays(startDateObj, 1), '-');
		}
		
		// 상단 제목 날짜 표시
		$('#dateTitle').html("(" + currentDate + ")");
		
		setTable();
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
