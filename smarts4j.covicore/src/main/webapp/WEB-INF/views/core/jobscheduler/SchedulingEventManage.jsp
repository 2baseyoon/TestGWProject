<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

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
			<input type="button" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"class="AXButton BtnRefresh"/>
			<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="popupSchedulingJob('','add');" class="AXButton BtnAdd" />
			<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="deleteSchedulingJob();"class="AXButton BtnDelete"/>
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
		setGrid(); 
		
		$(document).on("click","#jobInfo",function(){
			var dataMap = JSON.parse($(this).attr("data-map"));
			if (dataMap["EventID"] == null)
			{
				Common.Inform("지정일에 근무가 없습니다.");	
				return;
			}
			var popupID		= "SchedulingEventPopup";
			var openerID	= "SchedulingEventManage";
			var popupTit	= "<spring:message code='Cache.BizSection_JobScheduler' /> [" + dataMap["JobTitle"]+ "]";
			var popupYN		= "N";
			var callBack	= "SchedulingEventPopup_CallBack";
			var popupUrl	= "/covicore/SchedulingEventJobList.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "EventID="		+ dataMap["EventID"]	+ "&"
							+ "IsCopy="		+ dataMap["IsCopy"]	+ "&"
							+ "callBackFunc="	+ callBack	;
			
			Common.open("", popupID, popupTit, popupUrl, "850px", "650px", "iframe", true, null, null, true);
			
		});
	}
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		jobGrid.setGridHeader([
							  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
							  {key:'JobType', label:"<spring:message code='Cache.lbl_JobKind'/>", width:'40', align:'center'}, //작업유형
			                  {key:'JobTitle', label:"<spring:message code='Cache.lbl_JobName'/>", width:'150', align:'left', formatter : function(){
								  return "<a href='#' onclick='popupSchedulingJob(\"" + this.item.EventID + "\",\"modify\"); return false;'>"+ "<span name='code'>" + this.item.JobTitle + "</span>"+"</a>";
							  }}, //일정유형 */
			                  {key:'ScheduleTitle', label:"<spring:message code='Cache.lbl_ScheduleNm'/>", width:'150', align:'left'}, 
			                  {key:'CronExpr', label:"<spring:message code='Cache.lbl_Schedule'/>", width:'100', align:'center'},
			                  {key:'IsCopy', label:"<spring:message code='Cache.lbl_Enterprise_By'/>(<spring:message code='Cache.lbl_apv_formcreate_LCODE13'/>)", width:'100', align:'center'},
			                  {key:'JobCnt', label:"<spring:message code='Cache.btn_apv_register'/>(<spring:message code='Cache.lbl_Enterprise_By'/>)", width:'100', align:'center', formatter : function(){
									return "<a href='#' id='jobInfo' data-map='"+ JSON.stringify(this.item)+"'>" + this.item.JobCnt + "</a>";
			                  }},		  
			                  {key:'QrtzCnt', label:"<spring:message code='Cache.ACC_btn_execute'/>(<spring:message code='Cache.lbl_Enterprise_By'/>)", width:'100', align:'center', formatter : function(){
								  return "<a href='#' id='jobInfo' data-map='"+ JSON.stringify(this.item)+"'>" + this.item.QrtzCnt + "</a>";
			                  }},
			                  {key:'RegistDate', label:"<spring:message code='Cache.lbl_RegistDate'/>" + Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center', 
									formatter: function(){
				      		  			  return CFN_TransLocalTime(this.item.RegDate);
									} //등록일
			                  }
				      		]);
		setGridConfig();
		bindGridData();
	}
	
    // 작업 로그정보 조회	
    function ShowJobLogList(pJobID) {    	
    	parent.Common.open("","JobLog_","<spring:message code='Cache.lbl_ScheduleJobLogView'/>|||<spring:message code='Cache.lbl_view'/>","/covicore/jobloglistpop.do?JobID=" + pJobID,"900px","600px","iframe",false,null,null,true);
    }
    
    function ShowScheduleTitle(pObj, event) {
        Common.openballoon("Div1", "BolloonDivPopupLayer", "", pObj.title, "300px", null, null, null, "right", event);
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
		jobGrid.bindGrid({
			ajaxUrl:"/covicore/admin/jobscheduler/getJobSchedulerEventList.do",
			ajaxPars: {
				sortBy: jobGrid.getSortParam(),
				isPaging: "Y"
			},
			objectName: 'jobGrid',
			callbackName: 'bindGridData'
		});
	}
	
	function popupSchedulingJob(pEventID, mode){
		var sOpenName = "divJobInfo";

		var sURL = "/covicore/SchedulingEventInfoPop.do";
		sURL += "?mode="+mode;
		sURL += "&EventID=" + pEventID;
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_ScheduleJobInfoManage'/>" + " ||| " + (mode=="add"?"<spring:message code='Cache.lbl_Add'/>":"<spring:message code='Cache.lbl_Edit'/>");

		var sWidth = "750px";
		var sHeight = "650px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
	function deleteSchedulingJob(){
		var aJsonArray = new Array();
		var selectObject = jobGrid.getCheckedList(0);
		if(selectObject.length == 0 || selectObject == null){
			Common.Warning("<spring:message code='Cache.CPMail_mail_itemSel'/>"); //msg_CheckDeleteObject
		}else{
			Common.Confirm("<spring:message code='Cache.msg_AreYouCreateQ'/> <spring:message code='Cache.msg_ScheduleDelete'/> ", "Confirmation Dialog", function (result) {
				if(result) {
					var deleteSeq = "";
					
					//문자에 agent정보 추가
					for(var i=0; i < selectObject.length; i++){
						var saveData = { "EventID":selectObject[i].EventID};
			            aJsonArray.push(saveData);
					}
					
					$.ajax({
						type:"POST",
						contentType:'application/json; charset=utf-8',
						dataType   : 'json',
						data:JSON.stringify({"dataList" : aJsonArray }),
						url:"/covicore/admin/jobscheduler/deleteJobSchedulerEvent.do",
						success:function (data) {
							if(data.status == "FAIL") {
								Common.Warning(data.message);
							} else {
								Common.Inform("<spring:message code='Cache.msg_sns_05'/>", "Information Dialog", function(result) {
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
	
	
	
</script>