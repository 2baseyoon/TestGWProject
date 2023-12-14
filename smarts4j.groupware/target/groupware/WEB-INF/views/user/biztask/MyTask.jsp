<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- 통합업무관리 포탈 시작-->
<!-- 리스트 시작 -->
<div class="cRContBottom mScrollVH ITMPortalCont">
<div class="ITMPortalWrap">
	<div class="ITMTopTitle">
		<p style="float:left;margin-top:9px;"><spring:message code='Cache.lbl_myworkreport' /></p>
		<div class="pagingType02" style="float:right;padding-top:0px;">
			<div class="searchBox02 ">
				<span>
					<input id="SchTxt" type="text" onkeypress="if (event.keyCode==13){ setListData(); return false;}" placeholder="<spring:message code='Cache.lbl_workname'/> <spring:message code='Cache.lbl_search'/>"><!--업무명 검색-->
					<button type="button" class="btnSearchType01" onclick="setListData();"><spring:message code='Cache.lbl_search'/><!-- 검색 --></button>
				</span>
			</div>
		</div>
	</div> <!-- 나의 업무 현황 -->
	<div class="ITMListWrap">
		<div class="ITMListBox_p">
			<div class="ITMListBox">
				<div class="ITMList_Top">
					<h3 class="ITMList_Toptitle"><spring:message code='Cache.lbl_delaywork' /></h3><a href="/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=TF" class="ITMList_morebtn" ><span id="spandelaycnt"></span></a>
				</div>
				<div class="ITMContentTalbeWrap">
					<div id="divDelayTask"></div>
					<div id="divDelayTaskNone" class="ITMList_none" style="display:none"><spring:message code='Cache.msg_NoDataList' /></div>
				</div>
			</div>
		</div>
	</div>
	<!-- 리스트 끝-->
	<div class="ITMListWrap">
		<div class="ITMListBox_p">
			<div class="ITMListBox">
				<div class="ITMList_Top">
					<h3 class="ITMList_Toptitle"><spring:message code='Cache.lbl_progresswork' /></h3><a href="/groupware/layout/task_ItemList.do?CLSYS=task&CLMD=user&CLBIZ=Task&folderID=0&isMine=Y" class="ITMList_morebtn"><span id="spanpendingcnt"></span></a>
				</div>
				<div class="ITMContentTalbeWrap">
					<div id="divPendingTask"></div>
					<div id="divPendingTaskNone" class="ITMList_none" style="display:none"><spring:message code='Cache.msg_NoDataList' /></div>
				</div>
			</div>
		</div>
	</div>
</div>
</div>
<!-- 프로젝트관리 포탈 끝 -->

<script>
	var userCode = Common.getSession("UR_Code");
	var currentDate = "";
	init();
	
	function init(){
		var rDate = new Date();
		currentDate = rDate.format("yyyy-MM-dd");
		setListData(); //나의 업무 조회
	}
	
	//나의 업무 조회
	function setListData(){
		$.getJSON("/groupware/biztask/getMyTaskList.do",{userCode : userCode, searchText: $("#SchTxt").val()}, function(d) {
			var projectTaskDaily = d.ProjectTaskList;
			var taskDaily = d.TaskList;
			var htmlDaily = "";
			if((projectTaskDaily.length + taskDaily.length) == 0){
				$("#divPendingTask").hide();
				$("#divDelayTask").hide();
				$("#divPendingTaskNone").show();
				$("#divDelayTaskNone").show();
			}else{
				//지연업무, 진행업무 분리
				var delayHTML="";
				var pendingHTML="";
				var delaycnt=0;
				var pendingcnt=0;
				//프로젝트 업무보고 출력
				projectTaskDaily.forEach(function(item) {
					var inlineHTML="";
					inlineHTML ='<tr onclick="openPop(\''+item.CU_ID +'\',\''+item.AT_ID +'\',\'Y\')" style="cursor: pointer;">';
					inlineHTML +='<td align="center">'+"<spring:message code='Cache.lbl_Project' />"+'</td><td>'+item.CommunityName+'</td>';
					if(item.EndDate < currentDate ){
						delaycnt++;
						inlineHTML +='<td align="center"><span class="ITMList_title delay" style="float:none;">'+(item.DelayDay < 7 ? '<span class="cycleNew blue new">N</span>':'')+item.ATName+'</span></td>';
					}else{
						pendingcnt++;
						inlineHTML +='<td align="center">'+item.ATName+'</td>';
					}
					inlineHTML +='<td align="center">'+item.StartDate+'~'+item.EndDate+'</td>';
					inlineHTML +='<td align="center">'+item.Progress+'%</td>';
					inlineHTML +='</tr>';
					
					if(item.EndDate < currentDate ){
						delayHTML +=inlineHTML;
					}else{
						pendingHTML += inlineHTML;
					}
				});
				
				//Task 업무보고 출력
				taskDaily.forEach(function(item) {
					var inlineHTML="";
					var isOwner = (item.RegisterCode==userCode || item.OwnerCode == userCode)? "Y":"N";
					inlineHTML +='<tr onclick="goTaskSetPopup(\''+item.TaskID +'\',\''+item.FolderID +'\',\''+ isOwner +'\')" style="cursor: pointer;">'
					//inlineHTML +='<span>업무관리</span>';
					inlineHTML +='<td align="center">'+"<spring:message code='Cache.lbl_TaskManage' />"+'</td><td >'+item.DisplayName+'</td>';
					if(item.EndDate < currentDate ){
						delaycnt++;
						inlineHTML +='<td align="center"><span class="ITMList_title delay" style="float:none;">'+(item.DelayDay < 7 ? '<span class="cycleNew blue new">N</span>':'')+item.Subject+'</td>';
					}else{
						pendingcnt++;
						inlineHTML +='<td align="center">'+item.Subject+'</td>';
					}
					inlineHTML +='<td align="center">'+item.StartDate+'~'+item.EndDate+'</td>';
					inlineHTML +='<td align="center">'+item.Progress+'%</td>';
					inlineHTML +='</tr>';
					
					if(item.EndDate < currentDate ){
						delayHTML +=inlineHTML;
					}else{
						pendingHTML += inlineHTML;
					}
				});
				
				$("#spandelaycnt").html("<spring:message code='Cache.lbl_Total_Sum' /> : " + String(delaycnt));
				$("#spanpendingcnt").html("<spring:message code='Cache.lbl_Total_Sum' /> : " + String(pendingcnt));
				
				var headerHTML ='<table class="ITMContentTable" cellspacing="0" cellpadding="0">';
				headerHTML +='<colgroup><col width="100"><col width="200"><col width="*"><col width="150"><col width="110"></colgroup>';
				headerHTML +='<thead><tr><th>'+"<spring:message code='Cache.lbl_businessDivision' />"+'</th><th>'+"<spring:message code='Cache.lbl_workname' />"+'</th><th>'+"<spring:message code='Cache.lbl_detailworkname' />"+'</th><th>'+"<spring:message code='Cache.lbl_scope' />"+'</th><th>'+"<spring:message code='Cache.lbl_ProgressRate' />"+'</th></tr></thead>';
				headerHTML +='<tbody>';
				var bottomHTML = '</tbody></table>';
				if(delaycnt == 0){
					$("#divDelayTask").hide();
					$("#divDelayTaskNone").show();
				}else{
					$("#divDelayTask").show();
					$("#divDelayTaskNone").hide();
					$("#divDelayTask").html(headerHTML+delayHTML+bottomHTML);
				}
				if(pendingcnt == 0){
					$("#divPendingTask").hide();
					$("#divPendingTaskNone").show();
				}else{
					$("#divPendingTask").show();
					$("#divPendingTaskNone").hide();
					$("#divPendingTask").html(headerHTML+pendingHTML+bottomHTML);
				}
			}
		});
	}
	
	// Activity
	function openPop(pcommunityId, ActivityId, isOwner) {
		Common.open("","ActivitySet","<spring:message code='Cache.btn_Modify' />","/groupware/tf/goActivitySetPopup.do?mode=MODIFY&CLSYS=biztask&CLMD=user&CLBIZ=BizTask&CSMU=T&C="+pcommunityId+"&ActivityId="+ActivityId+"&isOwner="+isOwner ,"950px", "650px","iframe", true,null,null,true);
	}
	function search(){
		setListData();
	}
	//Task
	//업무 수정/조회 팝업
	function goTaskSetPopup(taskID,folderID,isOwner,isSearch){
		var height = isOwner=="Y"? "650px": "570px";
		Common.open("","taskSet",Common.getDic("lbl_task_taskManage"),"/groupware/task/goTaskSetPopup.do?mode=Modify&isOwner="+isOwner+"&taskID="+taskID+"&folderID="+folderID+"&isSearch="+isSearch,"950px", height ,"iframe", true,null,null,true);
	}
</script>
