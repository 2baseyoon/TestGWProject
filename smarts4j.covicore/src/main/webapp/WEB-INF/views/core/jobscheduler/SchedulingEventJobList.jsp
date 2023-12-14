<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<style>	
	label {
		font-size: 13px;
	}
	
	.colHeadTable, .gridBodyTable {
		font-size: 13px;
	}
</style>
		<form>
			<div style="width:100%;min-height: 500px">
				<div id="topitembar_1" class="topbar_grid">
					<input type="button" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"class="AXButton BtnRefresh"/>
					<input type="button" id="btnJobCreate" value="<spring:message code="Cache.lbl_Activity"/> <spring:message code="Cache.btn_apv_register"/>" class="AXButton BtnAdd" />
					<input type="button" id="btnJobDelete" value="<spring:message code="Cache.lbl_Activity"/> <spring:message code="Cache.btn_delete"/>" class="AXButton BtnDelete"/>
				</div>
				<!-- Grid -->
				<div class="divpop_contents" style="width:100%;" >
					<div id="jobGrid"></div>
				</div>
			</div>
		</form>
<script>
	var paramEventID = "${EventID}";	
	var paramIsCopy = "${IsCopy}";	

	//새로고침
	function Refresh(){
		window.location.reload();
	}

	var jobGrid = new coviGrid();
	
	window.onload = initContent();
	
	function initContent(){
		var lang = Common.getSession("lang");
		var myDn = Common.getSession("lang");
		setGrid(); 
		$("#btnJobCreate").click(function(){
			var aJsonArray = new Array();
			var selectObject = jobGrid.getCheckedList(0);
			if(selectObject.length == 0 || selectObject == null){
				Common.Warning("<spring:message code='Cache.CPMail_mail_itemSel'/>"); //msg_CheckDeleteObject
			}else{
				Common.Confirm("<spring:message code='Cache.msg_AreYouCreateQ'/>", "Confirmation Dialog", function (result) {
					if(result) {
						var deleteSeq = "";
						
						//문자에 agent정보 추가
						for(var i=0; i < selectObject.length; i++){
							var saveData = { "DomainID":selectObject[i].DomainID, "DomainCode":selectObject[i].DomainCode};
				            aJsonArray.push(saveData);
						}
						
						$.ajax({
							type:"POST",
							contentType:'application/json; charset=utf-8',
							dataType   : 'json',
							data:JSON.stringify({"dataList" : aJsonArray ,"EventID":paramEventID }),
							url:"/covicore/admin/jobscheduler/insertJobSchedulerEventJob.do",
							success:function (data) {
								if(data.status == "FAIL") {
									Common.Warning(data.message);
								} else {
									Common.Inform("<spring:message code='Cache.msg_apv_136'/>", "Information Dialog", function(result) {
										if(result) {
											jobGrid.reloadList();
										}
									});
								}
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/covicore/admin/jobscheduler/deleteschedulingjob.do", response, status, error);
							}
						});
					}
				});
			}
		});
		
		$("#btnJobDelete").click(function(){
			var deleteObject = jobGrid.getCheckedList(0);
			if(deleteObject.length == 0 || deleteObject == null){
				Common.Warning("<spring:message code='Cache.msg_CheckDeleteObject'/>"); //msg_CheckDeleteObject
			}else{
				Common.Confirm("<spring:message code='Cache.msg_152'/>", "Confirmation Dialog", function (result) {
					if(result) {
						var deleteSeq = "";
						
						//문자에 agent정보 추가
						for(var i=0; i < deleteObject.length; i++){
							if(i==0){
								deleteSeq = deleteObject[i].JobID + ":" + deleteObject[i].AgentServer;
							}else{
								deleteSeq = deleteSeq + "," + deleteObject[i].JobID + ":" + deleteObject[i].AgentServer;
							}
						}
						
						$.ajax({
							type:"POST",
							dataType : 'json',
							data:{
								"DeleteObj" : deleteSeq
							},
							url:"/covicore/admin/jobscheduler/deleteschedulingjob.do",
							success:function (data) {
								if(data.status == "FAIL") {
									Common.Warning(data.message);
								} else {
									Common.Inform("<spring:message code='Cache.msg_138'/>", "Information Dialog", function(result) {
										if(result) {
											jobGrid.reloadList();
										}
									});
								}
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/covicore/admin/jobscheduler/deleteschedulingjob.do", response, status, error);
							}
						});
					}
				});
			}
		});
		
	}
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		jobGrid.setGridHeader([
							  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
			                  { key:'DisplayName', label:'<spring:message code="Cache.lbl_CompanyName"/>', width:'50', align:'left'},
			                  { key:'ServicePeriod',  label:'<spring:message code="Cache.lbl_ServicePeriod"/>', width:'70', align:'center'},
			                  {key:'JobState', label:"<spring:message code='Cache.lbl_JobState'/>", width:'30', align:'center', formatter : function(){
								  return "<a href='#' onclick='ShowJobLogList(\"" + this.item.JobID + "\",\"" + this.item.DomainID + "\"); return false;'>"+ "<span name='code'>" + StateChangeDic("JobState", this.item.JobState) + "</span>"+"</a>";
							  }}, //작업상태
			                  {key:'Reserved1', label:"<spring:message code='Cache.lbl_Schedule'/>", width:'50', align:'center'}, //일정
			                  {key:'LastRunTime', label:"<spring:message code='Cache.lbl_LastRunTime'/>" + Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center',
										formatter: function(){
					      		  			  return this.item.LastRunTime!=null ? CFN_TransLocalTime(this.item.LastRunTime):"";
										} //등록일								  
			                  }, //최종실행시간
			                  {key:'IsUse', label:"<spring:message code='Cache.lbl_Run'/>", width:'30', align:'center', formatter:function () {
			      				  return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsUse"+this.item.DomainID+"' style='width:50px;height:20px;border:0px none;' value='"+(this.item.JobState=="WAITING"||this.item.JobState=="ACQUIRED"? "Y":"N")+"'  onchange='updateIsUseJob("+JSON.stringify(this.item)+")' />";
			      		  	  }} //실행(여부)
				      		]);
		var configObj = {
				targetID : "jobGrid",		// grid target 지정
				height:"auto",
				page : {
					pageNo:1,
					pageSize:10
				},
				paging : true
			};
			
		// Grid Config 적용
		jobGrid.setGridConfig(configObj);
		bindGridData();
	}
	
	function StateChangeDic(pType, pState) 
    {
        var strReturn = "";

        if (pType == "JobState")
        {
            if (pState == "WAITING") { strReturn = "<spring:message code='Cache.lbl_Ready'/>"; }
            else if (pState == "PAUSED") { strReturn = "<spring:message code='Cache.lbl_Stop'/>"; }
            else if (pState == "ACQUIRED") { strReturn = "<spring:message code='Cache.lbl_Running'/>"; }
            else if (pState == "BLOCKED") { strReturn = "<font color='red'>" + "<spring:message code='Cache.lbl_Fail'/>" +"</font>"; }
            else if (pState == "COMPLETE") { strReturn = "<spring:message code='Cache.lbl_Completed'/>"; }
        }

        return strReturn;
    }
	
	function bindGridData() {	
		jobGrid.bindGrid({
			ajaxUrl:"/covicore/admin/jobscheduler/getJobSchedulerEventJob.do",
			ajaxPars: {
 				"EventID": paramEventID,
 				"IsCopy": paramIsCopy,
				sortBy: jobGrid.getSortParam(),
				isPaging: "Y"
			}
		});
	}
	
	// 실행 여부 - 스위치 버튼에 대한 값 변경
	function updateIsUseJob(dataMap){
		var pJobID  = dataMap.JobID;
		var pDomainID  = dataMap.DomainID;
		var isUseValue = $("#IsUse"+pDomainID).val();

		if (pJobID ==  null || pJobID == ""){
			Common.Warning("<spring:message code='Cache.msg_not_register'/>");
			jobGrid.reloadList();
			return;
		}
		
		var l_msgConfirm;
		if (isUseValue == "N") {
            l_msgConfirm = confirm("<spring:message code='Cache.msg_ItemDisabledQ'/>");
        } else {
            l_msgConfirm = confirm("<spring:message code='Cache.msg_itemEnabledQ'/>");
        }
		if(!l_msgConfirm){		
			return false;		
		}
		
		var now = new Date();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		$.ajax({
			type:"POST",
			data:{
				"JobID" : pJobID,
				"AgentServer" : dataMap["AgentServer"],
				"JobType" : dataMap["JobType"],
				"Path" : dataMap["Path"],
				"Method" : dataMap["Method"],
				"Params" : dataMap["Params"],
				"ScheduleID" : dataMap["ScheduleID"],
				"Reserved1" : dataMap["Reserved1"],
				"TimeOut" : dataMap["TimeOut"],
				"RetryCnt" : dataMap["RetryCnt"],
				"RepeatCnt" : dataMap["RepeatCnt"],
				"IsUse" : isUseValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:"/covicore/admin/jobscheduler/updateisuse_job.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog", function(result) {
						if(result) {
							jobGrid.reloadList();
						}
					});
				}else{
					Common.Warning("<spring:message code='Cache.CPMail_error_msg'/>");
					jobGrid.reloadList();
				}		
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/jobscheduler/updateisuse_job.do", response, status, error);
			}
		});
	}
	// 작업 로그정보 조회	
    function ShowJobLogList(pJobID, pDomainID) {    	
    	parent.Common.open("","JobLog_","<spring:message code='Cache.lbl_ScheduleJobLogView'/>|||<spring:message code='Cache.lbl_view'/>","/covicore/jobloglistpop.do?JobID=" + pJobID+"&DomainID=" + pDomainID,"900px","600px","iframe",true,null,null,true);
    }
	
</script>