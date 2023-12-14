<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class='cRConTop titType'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.lbl_dailyreport' /></h2><!-- 일일보고 등록 -->
	<h2 id="dateTitle" class="title"></h2>
	<div class="pagingType02">
		<a class="pre" onclick="clickTopButton('PREV');"></a><a class="next" onclick="clickTopButton('NEXT');"></a><a onclick="setCurrentDate();" class="btnTypeDefault"><spring:message code='Cache.lbl_Todays' /></a><!-- 오늘 -->
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<div class="ITMSubCont">
		<div class="pjtroom_title_wrap"><p class="pjtroom_title"><spring:message code='Cache.lbl_dailyreportlist' /></p></div><!-- 프로젝트/업무관리 일일보고현황-->
		<div class="tblList tblCont" id="divProjectTaskDaily">
			<table style="width:100%; border-color:#c3d7df;" border="1">
				<colgroup>
					<col width="20%"/>
					<col width="30%"/>
					<col width="15%"/>
					<col width="15%"/>
					<col width="20%"/>
				</colgroup>
				<tbody>
					<tr style="height:30px; text-align:center; font-weight:bold; font-size:12px; background-color:#f1f6f9;">
						<td><spring:message code='Cache.lbl_Division2' /></td> <!-- 선택 -->
						<td><spring:message code='Cache.lbl_prj_workName' /></td> <!-- 업무명 -->
						<td><spring:message code='Cache.lbl_State' /></td> <!-- 업무상태 -->
						<td><spring:message code='Cache.lbl_ProgressRate' /></td> <!-- 진행율(%) -->
						<td><spring:message code='Cache.lbl_Remark' /></td> <!-- 비고 -->
					</tr>
					<tr style="height:30px; text-align:center; font-size:12px;">
						<td>프로젝트</td>
						<td>제목</td>
						<td>진행중</td>
						<td>80</td>
						<td>기타</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="pjtroom_title_wrap">
			<p class="pjtroom_title"><spring:message code='Cache.lbl_generalwork' /></p>
			<div class="btnFloatRight"><a href="#" id="btnAdd" class="btnTypeDefault" onclick="javascript:addTaskReport(1);"><spring:message code='Cache.lbl_Add'/></a><a href="#" id="btnDelete" class="btnTypeDefault"  onclick="javascript:deleteTaskReport();"><spring:message code='Cache.lbl_delete'/></a></div>
		</div>
		<div class="tblList tblCont">
			<table style="width:100%; border-color:#c3d7df;" border="1" id="tbReportDaily">
				<colgroup>
					<col width="10%"/>
					<col width="30%"/>
					<col width="15%"/>
					<col width="15%"/>
					<col width="30%"/>
				</colgroup>
				<thead>
					<tr style="height:30px; text-align:center; font-weight:bold; font-size:12px; background-color:#f1f6f9;">
						<td><input type="checkbox" id="chkAll" name="chkAll" class="chkAllReport" /></td> <!-- 선택 -->
						<td><spring:message code='Cache.lbl_prj_workName' /></td> <!-- 업무명 -->
						<td><spring:message code='Cache.lbl_State' /></td> <!-- 업무상태 -->
						<td><spring:message code='Cache.lbl_ProgressRate' /></td> <!-- 진행율(%) -->
						<td><spring:message code='Cache.lbl_Remark' /></td> <!-- 비고 -->
					</tr>
				</thead>
				<tbody id="trReportNoneData" style="display:none;">
					<tr style="height:30px; text-align:center; font-size:12px;">
						<td colspan="5"><spring:message code='Cache.msg_haveNotReportData' /></td> <!-- 보고할 내용이 없습니다. -->
					</tr>
				</tbody>
				<tbody id="trReportClone" style="display:none;">
					<tr style="height:30px; text-align:center; font-size:12px;">
						<td>
							<input type="hidden" id="txtReportCode"/>
							<input type="hidden" id="txtPrjCode"/>
							<input type="hidden" id="txtTaskFolderCode"/>
							<input type="checkbox" id="chkReportCode" name="chkReportCode" class="chkAllReportDetail" />
							<input type="hidden" id="txtInputTime"/>
							<!-- <span id="txtPrjName"></span> -->
						</td>
						<td>
							<input type="hidden" id="txtTaskIDX"/>
							<input type="text" id="txtTaskName" style="width:99%;" />
						</td>
						<td>
							<select id="selTaskStatusCode" style="width:99%;"></select>
						</td>
						<td>
							<input type="text" id="txtTaskPercent" style="width:25%; text-align:right;" onblur="chkPercent(this)"/> %
						</td>
						<td>
							<textarea id="txtContent" rows="2" style="font-family:Malgun Gothic; width:100%; resize:none;"></textarea>
						</td>
					</tr>
				</tbody>
			</table>
			<div style="text-align:center; margin:10px;">
				<a onclick="insertTaskReportDaily()" id="btnAdd" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_register' /></a><!-- 등록 -->
				<a onclick="movePage()" id="btnCancel" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel' /></a><!-- 취소 -->
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
	var userCode = Common.getSession("UR_Code");
	var userDeptCode = Common.getSession("GR_Code");
	var chkTaskTime = true;
	var currentDate = "";
	
	initContent();
	
	function initContent() {
		init(); //초기화
	}
	
	//초기화
	function init() {
		coviInput.setDate();
		
		//업무상태 selectBox 옵션 추가
		var ProjectStatus = Common.getBaseCode("TaskState");
		$(ProjectStatus.CacheData).each(function(idx, obj) {
			if (obj.Code == 'TaskState'){
				return true;
			}else{
				$('#selTaskStatusCode').append($('<option>', {
					value : obj.Code,
				 	text : CFN_GetDicInfo(obj.MultiCodeName, lang)
				}));
				//if (setState != "") $("#selTaskStatusCode").val(setPrjKind);
			}
		});
		
		// 체크박스 전체선택
		$('.chkAllReport').each(function(){
			$(this).on('click',function(){	
				if($(this).is(':checked')){
					$('.chkAllReportDetail').prop('checked',true);
				}else{
					$('.chkAllReportDetail').prop('checked',false);
				}
			});
		});
		
		//오늘 날짜 바인딩
		setCurrentDate();
	}
	
	//오늘 날짜 바인딩
	function setCurrentDate(){
		var rDate = new Date();
		currentDate = rDate.format("yyyy-MM-dd");
		
		$('#dateTitle').html("(" + currentDate + ")");
		
		setTable();
	}
	
	function setTable() {
		$(".reportData").remove();
		$("#btnAdd").show();
		
		//기존등록내역 불러오기
		//1. 프로젝트+업무관리내역
		//2. 업무보고 일반내역 내역이 없을 경우 기본 5개 활성화(추가/삭제 구현 필요)
		
		$.getJSON("/groupware/bizreport/getTaskReportDailyList.do",{reportDate : currentDate, userCode : userCode}, function(d) {
			//일반업무보고
			var reportDaily = d.ReportList;
			
			if(reportDaily.length == 0) {
				var outterTr = $("#trReportClone").clone().addClass("reportData").show();
				//$("#tbReportDaily").append(outterTr);
				//addTaskReport(1);
			} else {
				$("#trReportNoneData").hide(); //보고할 내용이 없습니다.
				
				reportDaily.forEach(function(item) {
					var outterTr = $("#trReportClone").clone().addClass("reportData").show();
					var statusSel = outterTr.find("#selTaskStatusCode");
					if(statusSel.find("option[value='" + item.TaskStatus + "']").length > 0){
						$.ajaxSetup({
							async: false
						});
						
						statusSel.val(item.TaskStatus);
					}
					outterTr.find("#txtPrjCode").val(item.ProjectCode);
					outterTr.find("#txtPrjName").text(item.ProjectName);
					outterTr.find("#txtTaskIDX").val(item.TaskID);
					outterTr.find("#txtTaskName").val(item.TaskName);
					outterTr.find("#txtTaskPercent").val(item.TaskPercent);
					
					if(item.ReportID != null || item.ReportID != "") {
						outterTr.attr("value", item.ReportID);
						outterTr.find("#txtReportCode").val(item.ReportID);
						outterTr.find("#txtInputTime").val(item.TaskHour);
						outterTr.find("#txtContent").val(item.TaskEtc);
					}
					
					$("#tbReportDaily").append(outterTr);
				});
			}
			addTaskReport(1);
			
			//일반업무보고
			var projectTaskDaily = d.ProjectTaskList;
			var folderDaily = d.FolderList;
			var taskDaily = d.TaskList;
			var htmlDaily = "";
			if((projectTaskDaily.length + folderDaily.length + taskDaily.length) == 0){
				htmlDaily  ='<table style="width:100%; border-color:#c3d7df;" border="1">';
				htmlDaily +='<colgroup><col width="10%"/><col width="30%"/><col width="15%"/><col width="15%"/><col width="30%"/></colgroup>';
				htmlDaily +='<tbody>';
				htmlDaily +='	<tr style="height:30px; text-align:center; font-size:12px;">';
				htmlDaily +='	<td colspan="5">'+ "<spring:message code='Cache.msg_haveNotReportData' />"+'</td> ';
				htmlDaily +='</tr>';
				htmlDaily +='</tbody></table>';
			}else{
				htmlDaily  ='<table style="width:100%; border-color:#c3d7df;" border="1">';
				//htmlDaily  +='<colgroup><col width="15%"/><col width="15%"/><col width="25%"/><col width="15%"/><col width="15%"/><col width="15%"/><col width="15%"/></colgroup>';
				htmlDaily  +='<colgroup><col width="15%"/><col width="15%"/><col width="25%"/><col width="15%"/><col width="15%"/><col width="15%"/></colgroup>';
				htmlDaily  +='<tbody>';
				htmlDaily  +='<tr style="height:30px; text-align:center; font-weight:bold; font-size:12px; background-color:#f1f6f9;">';
				htmlDaily  +='<td>'+"<spring:message code='Cache.lbl_Division2' />"+'</td> ';
				htmlDaily  +='<td>'+"<spring:message code='Cache.lbl_name' />"+'</td> ';
				htmlDaily  +='<td>'+"<spring:message code='Cache.lbl_prj_workName' />"+'</td> ';
				htmlDaily  +='<td>'+"<spring:message code='Cache.lbl_scope' />"+'</td> ';
				htmlDaily  +='<td>'+"<spring:message code='Cache.lbl_State' />"+'</td> ';
				htmlDaily  +='<td>'+"<spring:message code='Cache.lbl_ProgressRate' />"+'</td> ';
				/* htmlDaily  +='<td>'+"<spring:message code='Cache.lbl_Remark' />"+'</td>'; */
				htmlDaily  +='</tr>';
					
				//프로젝트 업무보고 출력
				projectTaskDaily.forEach(function(item) {
					htmlDaily  +='<tr style="height:30px; text-align:center; font-size:12px;">';
					htmlDaily  +='<td>'+"<spring:message code='Cache.lbl_Project' />"+'</td>';
					htmlDaily  +='<td>'+item.CommunityName+'</td>';
					htmlDaily  +='<td>'+item.ATName+'</td>';
					htmlDaily  +='<td>'+item.StartDate + '~'+item.EndDate+'</td>';
					htmlDaily  +='<td>'+item.TaskState+'</td>';
					htmlDaily  +='<td>'+item.Progress+'%</td>';
					//htmlDaily  +='<td>'+(item.ReportID==""?"<spring:message code='Cache.lbl_reportn' />":"<spring:message code='Cache.lbl_reporty' />")+'</td>';
					htmlDaily  +='</tr>';
				});
				//폴더 업무보고 출력
				folderDaily.forEach(function(item) {
					htmlDaily  +='<tr style="height:30px; text-align:center; font-size:12px;">';
					htmlDaily  +='<td>'+"<spring:message code='Cache.lbl_TaskManage' />"+'</td>';
					htmlDaily  +='<td>'+'-'+'</td>';
					htmlDaily  +='<td>'+item.DisplayName+'</td>';
					htmlDaily  +='<td>'+item.StartDate + '~'+item.EndDate+'</td>';
					htmlDaily  +='<td>'+item.FolderState+'</td>';
					htmlDaily  +='<td>'+item.Progress+'%</td>';
					//htmlDaily  +='<td>'+(item.ReportID==""?"<spring:message code='Cache.lbl_reportn' />":"<spring:message code='Cache.lbl_reporty' />")+'<br />'+item.Description+'</td>';
					htmlDaily  +='</tr>';
				});
				//Task 업무보고 출력
				taskDaily.forEach(function(item) {
					htmlDaily  +='<tr style="height:30px; text-align:center; font-size:12px;">';
					htmlDaily  +='<td>'+"<spring:message code='Cache.lbl_TaskManage' />"+'</td>';
					htmlDaily  +='<td>'+item.FolderName+'</td>';
					htmlDaily  +='<td>'+item.Subject+'</td>';
					htmlDaily  +='<td>'+item.StartDate + '~'+item.EndDate+'</td>';
					htmlDaily  +='<td>'+item.TaskState+'</td>';
					htmlDaily  +='<td>'+item.Progress+'%</td>';
					//htmlDaily  +='<td>'+(item.ReportID==""?"<spring:message code='Cache.lbl_reportn' />":"<spring:message code='Cache.lbl_reporty' />")+'<br />'+item.Description+'</td>';
					htmlDaily  +='</tr>';
				});
				htmlDaily  +='</tbody>';
				htmlDaily  +='</table>';
			}
			$("#divProjectTaskDaily").html(htmlDaily);
		}).error(function(response, status, error){
			//TODO 추가 오류 처리
			CFN_ErrorAjax("/groupware/bizreport/getTaskReportDailyList.do", response, status, error);
		});
	}
	
	//취소
	function movePage(){
		window.history.go(-1);
		return false;
	}
	
	//등록 및 수정
	function insertTaskReportDaily(){
		var formData = new FormData();
		var reportData = getReportDailyJSON();
		formData.append("insertData", JSON.stringify(reportData.insertArr));
		formData.append("updateData", JSON.stringify(reportData.updateArr));
		formData.append("deleteData", JSON.stringify(deleteArr));
		
		var qTxt = (chkTaskTime) ? "" : Common.getDic("msg_checkTaskHourFirst") + "<br/>";
		
		Common.Confirm(qTxt + Common.getDic("msg_RURegist"), "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				$.ajax({
					url: "/groupware/bizreport/insertTaskReportDaily.do",
					type: "POST",
					data: formData,
					dataType: 'json',
					processData: false,
					contentType: false,
					success: function(data){
						if(data.result == "ok"){
							Common.Inform("<spring:message code='Cache.msg_insert'/>");
							setTable();
							deleteArr = new Array(); //삭제 array초기화	
						}
					},
					error:function (error){
						CFN_ErrorAjax("/groupware/bizreport/insertTaskReportDaily.do", response, status, error);
					}
				});
			} else {
				return false;
			}
		});
	}
	
	//일일보고 내용 JSON객체로 반환
	function getReportDailyJSON() {
		var jsonArr = new Object();
		var insertArr = new Array();
		var updateArr = new Array();
		chkTaskTime = true;
		
		$(".reportData").each(function(idx, item) {
			var reportList = {};
			
			if($(item).find("#txtTaskName").val() != null && $(item).find("#txtTaskName").val().trim() != "") {		
				reportList.strTaskIDX = ($(item).find("#txtTaskIDX").val()==""? "0":$(item).find("#txtTaskIDX").val());
				reportList.strPrjCode = ($(item).find("#txtPrjCode").val()==""? "0":$(item).find("#txtPrjCode").val());
				reportList.strTaskName = $(item).find("#txtTaskName").val();
				reportList.strTaskDate = currentDate;
				reportList.strTaskHour = ($(item).find("#txtInputTime").val()==""? "0":$(item).find("#txtInputTime").val());
				reportList.strTaskStatusCode = $(item).find("#selTaskStatusCode").val();
				reportList.strTaskPercent = $(item).find("#txtTaskPercent").val();
				reportList.strTaskEtc = $(item).find("#txtContent").val();
				reportList.TaskMemCode = userCode;
				reportList.TaskMemDeptCode = userDeptCode;
				reportList.TaskGubunCode = "G"; //일반업무보고
				
				if($(item).find("#txtReportCode").val() != "") {
					reportList.strReportCode = $(item).find("#txtReportCode").val();
					updateArr.push(reportList);
				} else {
					insertArr.push(reportList);
				}
			} else {
				//chkTaskTime = false;
			}
		});
		
		jsonArr.insertArr = insertArr;
		jsonArr.updateArr = updateArr;
		
		return jsonArr;
	};
	
	//진행율 체크
	function chkPercent(obj) {
		if(obj.value.trim() != "") {
			if(!(0 <= parseInt(obj.value) && parseInt(obj.value) <= 100)) {
				parent.Common.Warning(Common.getDic("msg_checkTaskPercent"), "Warning Dialog", function(){
					obj.value = "0.0";
				});
			}
		}
	}
	
	//투입시간 체크
	function chkTime(obj) {
		if(obj.value.trim() != "") {
			if(!(0 <= parseInt(obj.value) && parseInt(obj.value) <= 24)) {
				parent.Common.Warning(Common.getDic("msg_checkTaskHour"), "Warning Dialog", function(){
					obj.value = "";
				});
			}
		}
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
	
	function addTaskReport(pIndex){
		/*복제개념
		var reportTable = $("#tbReportDaily").find("tbody:last");
		for(var i = 0; i < pIndex; i++){
			var tmpObjRow = $(reportTable).find("tr:last").clone(true).appendTo(reportTable);
			tmpObjRow.addClass("reportData").show();
		}*/
		for(var i = 0; i < pIndex; i++){
			var outterTr = $("#trReportClone").clone().addClass("reportData").show();
			var statusSel = outterTr.find("#selTaskStatusCode");
			$("#tbReportDaily").append(outterTr);
		}
	}
	
	var deleteArr = new Array();
	function deleteTaskReport(){
		//삭제대상 모아 넣기
		var reportList = null;
		$("[name='chkReportCode']:checked").each(function (index,obj){
			reportList = {};
			var item = $(obj).closest("tr");
			if($(item).find("#txtReportCode").val() != "") {
				reportList.strTaskIDX = $(item).find("#txtTaskIDX").val();
				reportList.strPrjCode = $(item).find("#txtPrjCode").val();
				reportList.strTaskName = $(item).find("#txtTaskName").val();
				reportList.strTaskDate = currentDate;
				reportList.strTaskHour = $(item).find("#txtInputTime").val();
				reportList.strTaskStatusCode = $(item).find("#selTaskStatusCode").val();
				reportList.strTaskPercent = $(item).find("#txtTaskPercent").val();
				reportList.strTaskEtc = $(item).find("#txtContent").val();
				reportList.TaskMemCode = userCode;
				reportList.TaskMemDeptCode = userDeptCode;
				reportList.TaskGubunCode = "G"; //일반업무보고
				reportList.strReportCode = $(item).find("#txtReportCode").val();
				deleteArr.push(reportList);
			}
		});
		
		var reportTable = $("#tbReportDaily").find("tbody:last");
		for(var i= $("[name='chkReportCode']").length-1;i>-1;i--){
			$("[name='chkReportCode']:checked").eq(0).closest("tr").remove();
		}
	}
</script>