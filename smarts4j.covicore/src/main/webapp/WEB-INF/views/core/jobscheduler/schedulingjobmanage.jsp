<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String quartzMode = PropertiesUtil.getGlobalProperties().getProperty("quartz.mode"); %>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_210"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form>
	<div style="width:100%;min-height: 500px">
		<div id="topitembar_1" class="topbar_grid">
			<span class=domain>
				<spring:message code="Cache.lbl_Domain"/>&nbsp;
				<select name="" class="AXSelect" id="selectDomain"></select>
			</span>
			<%if (quartzMode.equals("Y")){%>
			
			<input type="button" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"class="AXButton BtnRefresh"/>
			<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="addSchedulingJob();" class="AXButton BtnAdd" />
			<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="deleteSchedulingJob();"class="AXButton BtnDelete"/>

			<input type="button" value="스케쥴서버 초기화" onclick="initQuartServer();"class="AXButton BtnDelete"/>
			<%}else{out.println("쿼츠모드 상태를 확인하세요");} %>
			<input type="button" value="call scheduler" onclick="callService();"class="AXButton"/>
			
			<!-- <input type="button" value="call procedure" onclick="callProc();"class="AXButton"/>
				<input type="button" value="start TestJob" onclick="startTestJob();"class="AXButton"/> -->
			<!-- <input type="button" value="stop TestJob" onclick="stopTestJob();"class="AXButton"/> -->
			<!-- <input type="button" value="<spring:message code="Cache.btn_ExcelDownload"/>" onclick="excelDownload('job');"class="AXButton"/> -->
		</div>
		<!-- Grid -->
		<div id="resultBoxWrap">
			<div id="jobGrid"></div>
		</div>
	</div>
</form>

<script>

	//새로고침
	function Refresh(){
		window.location.reload();
	}

	var jobGrid = new coviGrid();
	
	window.onload = initContent();
	
	function initContent(){
		var lang = Common.getSession("lang");
		var myDn = Common.getSession("lang");
		coviCtrl.renderDomainAXSelect('selectDomain', lang, 'bindGridData', '', Common.getSession("DN_ID"), true);
		setGrid(); 
	}
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		jobGrid.setGridHeader([
							  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
							  {key:'JobID', label:"<spring:message code='Cache.No'/>", width:'20', align:'center'}, //순서 
							  {key:'JobType', label:"<spring:message code='Cache.lbl_JobKind'/>", width:'40', align:'center'}, //작업유형
			                  {key:'JobTitle', label:"<spring:message code='Cache.lbl_JobName'/>", width:'100', align:'left', formatter : function(){
								  return "<a href='#' onclick='editSchedulingJob(\"" + this.item.JobID + "\"); return false;'>"+ "<span name='code'>" + this.item.JobTitle + "</span>"+"</a>";
							  }}, //작업명
			                  {key:'JobState', label:"<spring:message code='Cache.lbl_JobState'/>", width:'30', align:'center', formatter : function(){
								  return "<a href='#' onclick='ShowJobLogList(\"" + this.item.JobID + "\"); return false;'>"+ "<span name='code'>" + StateChangeDic("JobState", this.item.JobState) + "</span>"+"</a>";
							  }}, //작업상태
			               /*    {key:'ScheduleType', label:"<spring:message code='Cache.lbl_ScheduleType'/>", width:'30', align:'center', formatter : function(){
			                	  return "<p class='grv_nowrap' style='cursor:pointer' onclick='ShowScheduleTitle(this, event);' title='"+this.item.ScheduleTitle+"'>"+this.item.ScheduleType+"</p>";
							  }}, //일정유형 */
			                  {key:'LastRunTime', label:"<spring:message code='Cache.lbl_LastRunTime'/>" + Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center',
										formatter: function(){
					      		  			  return CFN_TransLocalTime(this.item.LastRunTime);
										} //등록일								  
			                  }, //최종실행시간
			                  {key:'NextRunTime', label:"<spring:message code='Cache.lbl_NextRunTime'/>" + Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center',
			          			formatter: function(){
			          			      		  			  return CFN_TransLocalTime(this.item.NextRunTime);
			          				} //등록일								  
        	                  }, //다음실행시간
    		                  {key:'IsUse', label:"<spring:message code='Cache.lbl_Run'/>", width:'30', align:'center', formatter:function () {
    		      				  return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsUse"+this.item.JobID+"' style='width:50px;height:20px;border:0px none;' value='"+(this.item.JobState == '' || this.item.JobState == 'PAUSED'?'N':'Y')+"' onchange='updateIsUseJob("+JSON.stringify(this.item)+");' />";
    		      		  	  }}, //실행(여부)
			                  {key:'RegistDate', label:"<spring:message code='Cache.lbl_RegistDate'/>" + Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center', 
										formatter: function(){
					      		  			  return CFN_TransLocalTime(this.item.RegistDate);
										} //등록일
			                  },
			                  {key:'Path', display: false, width:'0'}
			                  
				      		]);
		setGridConfig();
		bindGridData();
	}
	
    // 작업 로그정보 조회	
    function ShowJobLogList(pJobID) {    	
    	parent.Common.open("","JobLog_","<spring:message code='Cache.lbl_ScheduleJobLogView'/>|||<spring:message code='Cache.lbl_view'/>","/covicore/jobloglistpop.do?JobID=" + pJobID+"&DomainID=" + $("#selectDomain").val(),"900px","600px","iframe",false,null,null,true);
    }
    
    function ShowScheduleTitle(pObj, event) {
        Common.openballoon("Div1", "BolloonDivPopupLayer", "", pObj.title, "300px", null, null, null, "right", event);
    }
	
	function StateChangeDic(pType, pState) 
    {
        var strReturn = "";

        if (pType == "LastState")
        {
            if (pState == "WAITING") { strReturn = "<spring:message code='Cache.lbl_Ready'/>"; }
            else if (pState == "PAUSED") { strReturn = "<spring:message code='Cache.lbl_Stop'/>"; }
            else if (pState == "ACQUIRED") { strReturn = "<spring:message code='Cache.lbl_Running'/>"; }
            else if (pState == "BLOCKED") { strReturn = "<font color='red'>" + "<spring:message code='Cache.lbl_Fail'/>" +"</font>"; }
            else if (pState == "COMPLETE") { strReturn = "<spring:message code='Cache.lbl_Completed'/>"; }

            /*if (pState == "R") { strReturn = "<spring:message code='Cache.lbl_NotRun'/>"; }
            else if (pState == "I") { strReturn = "<spring:message code='Cache.lbl_Running'/>"; }
            else if (pState == "F") { strReturn = "<font color='red'>" + "<spring:message code='Cache.lbl_Fail'/>" + "</font>"; }
            else if (pState == "C") { strReturn = "<spring:message code='Cache.lbl_Success'/>"; }*/
        }
        else if (pType == "JobState")
        {
        	 if (pState == "WAITING") { strReturn = "<spring:message code='Cache.lbl_Ready'/>"; }
             else if (pState == "PAUSED") { strReturn = "<spring:message code='Cache.lbl_Stop'/>"; }
             else if (pState == "ACQUIRED") { strReturn = "<spring:message code='Cache.lbl_Running'/>"; }
             else if (pState == "BLOCKED") { strReturn = "<font color='red'>" + "<spring:message code='Cache.lbl_Fail'/>" +"</font>"; }
             else if (pState == "COMPLETE") { strReturn = "<spring:message code='Cache.lbl_Completed'/>"; }
             else if (pState == "") { strReturn = "<spring:message code='Cache.lbl_Unregistered'/>"; }
             else strReturn = pState;

        }

        return strReturn;
    }
	
	//Grid 설정 관련
	function setGridConfig(){
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
	}	

	function bindGridData() {	
		var domain = document.getElementById("selectDomain").value;
		
		var sortStr = '';
		var sortParam = jobGrid.getSortParam('one');
		if (sortParam != '') {
			sortStr = sortParam.split('=')[1];
		}
		
		jobGrid.bindGrid({
			ajaxUrl:"/covicore/admin/jobscheduler/getjobschedulerlist.do",
			ajaxPars: {
 				"domain": domain,
 				"sortBy": sortStr,
 				"isPaging": "Y"
			},
			objectName: 'jobGrid',
			callbackName: 'bindGridData'
		});
	}
	
	function addSchedulingJob(){
		var sOpenName = "divJobInfo";

		var sURL = "/covicore/schedulingjobinfopop.do";
		sURL += "?mode=add";
		sURL += "&JobID=" + "";
		sURL += "&DomainID=" + $("#selectDomain").val();
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_ScheduleJobInfoManage'/>" + " ||| " + "<spring:message code='Cache.lbl_Add'/>";

		var sWidth = "650px";
		var sHeight = "400px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
	function editSchedulingJob(pJobID){
		var sOpenName = "divJobInfo";

		var sURL = "/covicore/schedulingjobinfopop.do";
		sURL += "?mode=modify";
		sURL += "&JobID=" + pJobID;
		sURL += "&DomainID=" + $("#selectDomain").val();
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_ScheduleJobInfoManage'/>" + " ||| " + "<spring:message code='Cache.lbl_Edit'/>";

		var sWidth = "650px";
		var sHeight = "400px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
	function deleteSchedulingJob(){
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
	}
	
	// 실행 여부 - 스위치 버튼에 대한 값 변경
	function updateIsUseJob(dataMap){
		<%if (!quartzMode.equals("Y")){%>
		Common.Inform("쿼츠 상태를 확인하세요");
		return;
	<%}%>

		var pJobID  = dataMap.JobID;
		var isUseValue = $("#IsUse"+pJobID).val();
		
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
	
	// 실행 여부 - 스위치 버튼에 대한 값 변경
	function startTestJob(){
		var pJobID = 'testJob';
		
		$.ajax({
			type:"POST",
			data:{
				"JobID" : pJobID
			},
			url:"/covicore/batch/startJob.do",
			success:function (data) {
				coviCmn.traceLog(data);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/batch/startJob.do", response, status, error);
			}
		});
	}
	
	// 실행 여부 - 스위치 버튼에 대한 값 변경
	function stopTestJob(){
		var pJobID = 'testJob';
		
		$.ajax({
			type:"POST",
			data:{
				"JobID" : pJobID
			},
			url:"/covicore/batch/stopJob.do",
			success:function (data) {
				coviCmn.traceLog(data);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/batch/stopJob.do", response, status, error);
			}
		});
	}
	
	//선택 프로시져 실행해 보기로 수정.
	function callProc(){
		var initObject = jobGrid.getCheckedList(0);
		if(initObject.length == 0 || initObject == null){
			Common.Warning("Not Selected");
			return;
		}else{
			var cnt = 0;
			var etcCnt = 0;
			for(var i=0; i < initObject.length; i++){
				var JobType = initObject[i].JobType;
				if(JobType == "Procedure"){
					cnt ++;
				}else{
					etcCnt ++;
				}
			}
			if(etcCnt > 0 || cnt == 0){
				Common.Inform("작업유형이 Procedure 인 작업만 선택하세요.");
				return;
			}
			for(var i=0; i < initObject.length; i++){
				var AgentServer = initObject[i].AgentServer;
				var jobId = initObject[i].JobID;
				var url = initObject[i].Path;
				var JobType = initObject[i].JobType;
				if(JobType == "Procedure"){
					$.ajax({
						type:"POST",
						data:{
							"ProcName" : url
							,"jobID" : "JOB_" + jobId
						},
						url:"/covicore/batch/callProc.do",
						success:function (data) {
							Common.Inform(Common.getDic("Success to call procedure."));
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/batch/callProc.do", response, status, error);
						}
					});
				}
			}
		}
	}
	
	//선택 프로시져 실행해 보기로 수정.
	function callService(){
		var initObject = jobGrid.getCheckedList(0);
		if(initObject.length == 0 || initObject == null){
			Common.Warning("Not Selected");
			return;
		}else if (initObject.length > 1){
			Common.Warning("1건만 선택");
			return;
		}

		Common.Confirm("즉시 스케쥴러를 실행합니다. 운영시 중복 실행에 유의 하십시요.", "Confirmation Dialog", function (result) {
			if(result) {
				var cnt = 0;
				var AgentServer = initObject[0].AgentServer;
				var jobId = initObject[0].JobID;
				var url = initObject[0].Path;
				var JobType = initObject[0].JobType;
				if(JobType == "Procedure"){
					$.ajax({
						type:"POST",
						data:{
							"ProcName" : url
							,"jobID" : "JOB_" + jobId
						},
						url:"/covicore/batch/callProc.do",
						success:function (data) {
							Common.Inform("Success to call procedure.");
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/batch/callProc.do", response, status, error);
						}
					});
				}else{
					$.ajax({
						type:"POST",
						data:{"JobID" : jobId},
						url:"/covicore/batch/callWebservice.do",
						success:function (data) {
							if(data.status == 'SUCCESS'){
								Common.Inform("Success to call procedure.");
							}else	{
								Common.Error("Fail"+data.message);
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/batch/callProc.do", response, status, error);
						}
					});
				}
			}});
	}
	
	//쿼츠 서버 초기화
	function initQuartServer(){
		Common.Confirm("스케쥴서버(쿼츠 서버)를 초기화합니다. 초기화  후 스케쥴 데이타를 재등록하셔야합니다. <br> 이미 일정이 있는 스케쥴은  실행만 체크 해주시면 됩니다. 진행하시겠습니까?.", "Confirmation Dialog", function (result) {
			if(result) {
				$.ajax({
					type:"POST",
					url:"/covicore/admin/jobscheduler/initQuartServer.do",
					success:function (data) {
						Common.Inform("Success", "Information Dialog", function(result) {
							Refresh();	
						});
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/batch/callProc.do", response, status, error);
					}
				});
			}});
	}
</script>