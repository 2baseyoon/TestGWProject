<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class='cRConTop titType'>
	<span></span>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.lbl_weeklyreport' /></h2><!-- 주간보고 등록 -->
	<h2 id="dateTitle" class="title"></h2>
	<div class="pagingType02">
		<a class="pre" onclick="clickTopButton('PREV');"></a><a class="next" onclick="clickTopButton('NEXT');"></a><a onclick="setCurrentDate();" class="btnTypeDefault"><spring:message code='Cache.lbl_Todays' /></a><!-- 오늘 -->
	</div>
</div>

<div class='cRContBottom mScrollVH'>
	<div class="boardAllCont">
		<div class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv" style="display: none;">
				<select class="selectType02" id="schProjectSel" onchange="setTable()" style="width:300px;">
				</select>
				<input type="hidden" id="txtTaskGubunCode" name="txtTaskGubunCode" />
			</div>
		</div>
		<div class="tblList tblCont">
			<table style="width:100%; border-color:#c3d7df;" border="1" id="tbReportWeekly">
				<colgroup>
					<col width="10%"/>
					<col width="30%"/>
					<col width="15%"/>
					<col width="15%"/>
					<col width="30%"/>
				</colgroup>
				<tr style="height:30px; text-align:center; font-weight:bold; font-size:12px; background-color : #f1f6f9;">
					<td></td>
					<td><spring:message code='Cache.lbl_prj_workName' /></td> <!-- 업무명 -->
					<td><spring:message code='Cache.lbl_prj_taskStatus' /></td> <!-- 업무상태 -->
					<td><spring:message code='Cache.lbl_projectProgressRate' /></td> <!-- 진행율(%) -->
					<!-- <td><spring:message code='Cache.lbl_input_time' /></td> <!-- 투입시간 -->
					<td><spring:message code='Cache.lbl_Contents' /></td> <!-- 내용 -->
				</tr>
				<tr style="display:none; height:30px; text-align:center; font-size:12px;" id="trReportClone">
					<td style="font-weight:bold; background-color : #f1f6f9;"></td>
					<td></td>
					<td></td>
					<td></td>
					<td style="text-align:left;"></td>
				</tr>
			</table>
			<br/>
			<table style="width:100%; border-color:#c3d7df;" border="1" id="tbReportWeeklyEtc">
				<colgroup>
					<col width="20%"/>
					<col width="80%"/>
				</colgroup>
				<tr style="text-align:center; font-size:12px;">
					<td style="font-weight:bold; background-color : #f1f6f9;"><spring:message code='Cache.lbl_prj_ConAndIssue' /></td> <!-- 내용/이슈 -->
					<td id="tdIssue" style="text-align:left;">
						<textarea id="txtIssue" rows="5" style="font-family:Malgun Gothic; width:100%; resize:none;"></textarea>
					</td>
				</tr>
				<tr style="text-align:center; font-size:12px;">
					<td style="font-weight:bold; background-color : #f1f6f9;"><spring:message code='Cache.lbl_prj_nextWeekPlan' /></td> <!-- 차주계획 -->
					<td id="tdPlan" style="text-align:left;">
						<textarea id="txtPlan" rows="5" style="font-family:Malgun Gothic; width:100%; resize:none;"></textarea>
					</td>
				</tr>
			</table>
			<div style="text-align:center; margin:10px;">
				<a onclick="insertTaskReportWeekly()" id="btnAdd" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_register' /></a><!-- 등록 -->
				<a onclick="updateTaskReportWeekly()" id="btnModify" class="btnTypeDefault btnTypeChk" style="display:none;"><spring:message code='Cache.btn_Modify' /></a><!-- 수정 -->
				<a onclick="movePage()" id="btnCancel" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel' /></a><!-- 취소 -->
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
	var userCode = Common.getSession("UR_Code");
	var userDeptCode = Common.getSession("GR_Code");
	var setPrjCode = "";
	var dateArr = new Array();
	var weekday = new Array(Common.getDic("lbl_sch_sun"), Common.getDic("lbl_sch_mon"), Common.getDic("lbl_sch_tue"), Common.getDic("lbl_sch_wed"), Common.getDic("lbl_sch_thr"), Common.getDic("lbl_sch_fri"), Common.getDic("lbl_sch_sat"));
	var startDate = "";
	var endDate = "";
	
	initContent();
	
	function initContent() {
		init(); // 초기화
	}
	
	// 초기화
	function init() {
		//일반업무보고
		/* $('#schProjectSel').append($('<option>', {
			value : "Task",
		 	text : "업무관리"
		})); */
		
		//일반업무보고
		$('#schProjectSel').append($('<option>', {
			value : "G",
			text : "일반업무"
		}));
		
		//프로젝트 목록 가져오기 실시
		$.ajax({
			type:"POST",
			data:{
				"userCd" : userCode
			},
			async:false,
			url:"/groupware/bizreport/getMyProject.do",
			success:function (data) {
				data.list.forEach(function(data) {
					$('#schProjectSel').append($('<option>', {
						value : data.ProjectCode,
						text : '[프로젝트]'+data.ProjectName
					}));
				});
				if (setPrjCode != "")$("#schProjectSel").val(setPrjCode);
			},
			error:function (response, status, error){
				CFN_ErrorAjax("/groupware/bizreport/getMyProject.do", response, status, error);
			}
		});
		
		setCurrentDate();
	}
	
	function setTable() {
		//업무구분 설정
		$("#txtTaskGubunCode").val(($("#schProjectSel").val()=="Task" || $("#schProjectSel").val()=="G")? $("#schProjectSel").val():"P");
		checkRegistered();
		
		$(".reportData").remove();
		var projectCode = (($("#schProjectSel").val()=="Task" || $("#schProjectSel").val()=="G")? "":$("#schProjectSel").val());
		var taskGubunCode = $("#txtTaskGubunCode").val() == "Task" ? "T" : $("#txtTaskGubunCode").val();
		var cloneObj = $("#trReportClone").clone();
		
		$.getJSON("/groupware/bizreport/getTaskReportWeeklyList.do", 
		 {startDate : startDate, endDate : endDate, userCode : userCode, projectCode : projectCode, taskGubunCode : taskGubunCode  },function(d) {
			var reportWeekly = d.TaskReportWeeklyList;
			
			dateArr.forEach(function(item, idx) {
				var rowspan = 0;
				
				reportWeekly.forEach(function(r_item, r_idx) {
					if(r_item.TaskDate.substring(0,10) == item.format("yyyy-MM-dd")) {
						var outterTr = $("<tr></tr>").css({"height":"30px","text-align":"center","font-size":"12px"}).addClass("reportData").html(cloneObj.html());
						outterTr.find("td").eq(0).text(item.getDate() + "(" + weekday[idx] + ")");
						outterTr.find("td").eq(1).text(r_item.TaskName);
						outterTr.find("td").eq(2).text(r_item.TaskState);
						outterTr.find("td").eq(3).text(r_item.TaskPercent);
						//outterTr.find("td").eq(4).text(r_item.TaskHour);
						outterTr.find("td").eq(4).html(r_item.TaskEtc.replaceAll("\n", "<br>"));
						$("#tbReportWeekly").append(outterTr);
						rowspan++;
					}
				});
				
				if(rowspan == 0) {
					var outterTr = $("<tr></tr>").css({"height":"30px","text-align":"center","font-size":"12px"}).addClass("reportData").html(cloneObj.html());
					outterTr.find("td").eq(0).text(item.getDate() + "(" + weekday[idx] + ")");
					$("#tbReportWeekly").append(outterTr);
				} else {
					$(".reportData").eq(idx).find("td").eq(0).attr("rowspan", rowspan);
					for(var i=1; i<rowspan; i++) {
						$(".reportData").eq(idx+i).find("td").eq(0).remove();
					}
				}
			});
		}).error(function(response, status, error){
			 //TODO 추가 오류 처리
			 CFN_ErrorAjax("/groupware/bizreport/getTaskReportWeeklyList.do", response, status, error);
		});
	}
	
	//취소
	function movePage(){
		window.history.go(-1);
		return false;
	}
	
	//등록
	function insertTaskReportWeekly(){
		Common.Confirm(Common.getDic("msg_RURegist"), "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var projectCode = (($("#schProjectSel").val()=="Task" || $("#schProjectSel").val()=="G")? "":$("#schProjectSel").val());
				
				$.ajax({
					url: "/groupware/bizreport/insertProjectTaskReportWeekly.do",
					type: "POST",
					data: {
						"ProjectCode" : projectCode,
						"TaskFolderID" : $("#txtTaskFolderID").val(),
						"StartDate" : startDate,
						"EndDate" : endDate,
						"WeekEtc" : $("#txtIssue").val(),
						"NextPlan" : $("#txtPlan").val(),
						"TaskGubunCode" : $("#txtTaskGubunCode").val(),
						"RegisterCode" : userCode,
						"RegisterDeptCode" : userDeptCode
					},
					success: function(data){
						if(data.status === "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_insert'/>");
							setTable();
						}
					},
					error: function (error){
						CFN_ErrorAjax("/groupware/bizreport/insertProjectTaskReportWeekly.do", response, status, error);
					}
				});
			} else {
				return false;
			}
		});
	}
	
	//수정
	function updateTaskReportWeekly(){
		Common.Confirm(Common.getDic("msg_RUEdit"), "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				$.ajax({
					url : "/groupware/bizreport/updateProjectTaskReportWeekly.do",
					type : "POST",
					data:{
						"ReportID" : $("#reportID").val(),
						"WeekEtc" : $("#txtIssue").val(),
						"NextPlan" : $("#txtPlan").val()
					},
					success:function (data) {
						if(data.result == "ok")
							Common.Inform("<spring:message code='Cache.msg_ChangeAlert'/>"); // 수정되었습니다
							setTable();
					},
					error:function (error){
						CFN_ErrorAjax("/groupware/bizreport/updateProjectTaskReportWeekly.do", response, status, error);
					}
				});
			} else {
				return false;
			}
		});
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
	
	//이미 등록되어 있는지 확인
	function checkRegistered() {
		var projectCode = (($("#schProjectSel").val()=="Task" || $("#schProjectSel").val()=="G")? "":$("#schProjectSel").val());
		
		$.ajax({
			type:"POST",
			url:"/groupware/bizreport/checkReportWeeklyRegistered.do",
			data:{
				"ProjectCode" : projectCode,
				"StartDate" : startDate,
				"EndDate" : endDate,
				"RegisterCode" : userCode,
				"TaskGubunCode" : $("#txtTaskGubunCode").val()
			},
			async: false,
			success:function (data) {
				$("#tdIssue").html("<input type='hidden' id='reportID'/><textarea id='txtIssue' rows='5' style='font-family:Malgun Gothic; width:100%; resize:none;'></textarea>");
				$("#tdPlan").html("<textarea id='txtPlan' rows='5' style='font-family:Malgun Gothic; width:100%; resize:none;'></textarea>");
				
				if(data.list != null && data.list[0] != null){
					$("#btnAdd").hide();
					$("#btnModify").show();
					
					$("#reportID").val(data.list[0].ReportWeekID);
					$("#txtIssue").val(data.list[0].WeekEtc);
					$("#txtPlan").val(data.list[0].NextPlan);
				} else {
					$("#reportID").val();
					$("#txtIssue").val();
					$("#txtPlan").val();
					$("#btnAdd").show();
					$("#btnModify").hide();
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/bizreport/checkReportWeeklyRegistered.do", response, status, error);
			}
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
</script>