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

<form id="JobLogListForm">
    <div style="width:100%; min-height: 500px">
		<div id="topitembar02" class="topbar_grid">			
			<label>				
				<select class="AXSelect" name="ddlJobID" id="ddlJobID" >
				</select>
				<%-- <input type="button" class="AXButton" value="<spring:message code="Cache.btn_delete"/>" onclick="deleteJobLog();"/> --%>
				<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>				
			</label>				
			<label style="float: right;">
				<p class="pagesize">Page size :
				<select  name="ddlPageSize" class="AXSelect" id="ddlPageSize" onchange="setGridConfig();searchConfig(); return false;">
					<option value="10" selected="selected">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="50">50</option>
					<option value="100">100</option>					
				</select>	
				</p>									
			</label>
		</div>	
		<div id="jobLogGrid"></div>
	</div>
</form>

<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var paramJobID =param[0].split('=')[1];	
	var paramDomainID =param[1].split('=')[1];	
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가

	$(document).ready(function(){	
		setGrid();	
		setSelect();		
	});
	
	// 헤더 설정
	var headerData =[   
	                  {key:'EventDate', label:'<spring:message code="Cache.lbl_EventDate"/>' +Common.getSession("UR_TimeZoneDisplay"), width:'30', align:'center', sort:"desc",
	                	  formatter:function () {  
		                	  	return getStringDateToString("yyyy-MM-dd HH:mm:ss",CFN_TransLocalTime(this.item.EventDate));	                	  
		                	  }},
	                  {key:'AgentServer',  label:'Run', width:'30', align:'center',
	                	  formatter:function () {
	                		  	var returnval;
	                		  	/* if(ddlJobID.SelectedValue == "0"){ */
	                		  	if(true){
	                		  		returnval = "<p class='grv_ellipsis_none' title='"+this.item.JobTitle+"'>"+this.item.JobTitle+"</p>";
	                		  	}else{
	                		  		returnval = "<p class='grv_ellipsis_none' title='"+this.item.AgentServer+"'>"+this.item.AgentServer+"</p>";
	                		  	}
		                	  	return returnval;	                	  
		                	  }},
	                  {key:'IsSuccess',  label:'<spring:message code="Cache.lbl_State"/>', width:'20', align:'center',
	                	  formatter:function () {  
	                	  		var sMessage = this.item.Message;
								
	                		  	if(sMessage == "" || sMessage == null || Object.keys(sMessage).length == 0) sMessage =this.item.IsSuccess;
	                		  	else if(typeof sMessage == "object"){
	                		  		if (this.item.Message.message != "" && this.item.Message.message != null) sMessage = this.item.Message.message;
	                		  		if (this.item.Message.status != "" && this.item.Message.status != null) sMessage = this.item.Message.status;
	                		  	}
	                		  	
		                	  	return "<a onclick='ShowResult(\"["+this.item.AgentServer+"] "+XFN_ReplaceAllSpecialChars(sMessage).replace(/(?:\r\n|\r|\n)/g, '')+"\", event)' style='cursor:pointer'>"+StateChangeDic("LastState", this.item.IsSuccess)+"</a>";	                	  
		                	  }
	                	  },	                  
	                  {key:'Message',  label:'Result', width:'30', align:'center',	                	  
	                	  formatter:function () {		
	                			var htmlString = removeHtml(this.item.ResultText.replace("\n", "").replace("\r", "").replace("<![CDATA[", "").replace("]]>", ""));
		                	  	return "<p class='grv_ellipsis_none' title='"+htmlString+"'>"+htmlString+"</p>";	                	  
		                	  }
	                  },
	                  {key:'SortKey', display:false}
		      		];
	
	var myGrid = new coviGrid();

	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
		//searchConfig();
		
	}
	function searchConfig(){	
		myGrid.bindGrid({
				ajaxUrl:"/covicore/admin/jobscheduler/getjobloglist.do",
				ajaxPars: {
					JobID : $("#ddlJobID").val(),
					"pageSize": $("#ddlPageSize").val() 
				}
		});
	}
	
	// Select box 바인드
	function setSelect(){
		$.ajax({
			url:"/covicore/admin/jobscheduler/getjobschedulerlist.do",
			type:"post",
			data:{sortBy: "seq asc", pageNo: "1", pageSize: "10000", domain:paramDomainID},
			async:false,
			success:function (data) {			
				$('#ddlJobID').bindSelect({
					reserveKeys: {
						optionValue: "JobID",
						optionText: "JobTitle"
					},
					options: data.list,
					setValue : paramJobID,
					onchange: function(){
						searchConfig();
					}
					
				});	
			}				
		});
		
		searchConfig();
//		$("#ddlJobID").setValue(paramJobID);
//		$("#ddlJobID").setValueSelect(paramJobID);
		//setGrid();
	}

	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "jobLogGrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#ddlPageSize").val()
			},
		};
		
		myGrid.setGridConfig(configObj);
	}

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){
		parent.Common.open("","updatebaseconfig","<spring:message code='Cache.lbl_apv_Regisign'/>|||<spring:message code='Cache.lbl_apv_sign_msg'/>","admin/goSignManagerSetPopup.do?mode=modify&key="+configkey,"450px","250px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		location.reload();
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}
	
	function deleteJobLog(){
		$.ajax({
			url:"../system/deleteJobLog.do",
			type:"post",
			data:{JobID : $('#ddlJobID').val(),
				AgentServer :$("#ddlAgentServer").val()
			},			
			async:false,
			success:function (data) {				
				searchConfig();		
			}				
		});
	}
	
	// 작업상태 다국어변환
    function StateChangeDic(pType,  pState) 
    {
        var strReturn = "";

        if (pType == "LastState")
        {
            if (pState == "R") { strReturn = "<spring:message code='Cache.lbl_NotRun'/>"; }
//             else if (pState == "I") { strReturn = "<spring:message code='Cache.lbl_Running'/>"; }
            else if (pState == "FAIL") { strReturn = "<font color='red'>" + "<spring:message code='Cache.lbl_Fail'/>"; + "</font>"; }
            else if (pState == "SUCCESS") { strReturn = "<spring:message code='Cache.lbl_Success'/>"; }
        }
        else if (pType == "JobState")
        {
            if (pState == "R") { strReturn = "<spring:message code='Cache.lbl_Ready'/>"; }
//             else if (pState == "I") { strReturn = "<spring:message code='Cache.lbl_Running'/>"; }
            else if (pState == "FAIL") { strReturn = "<font color='red'>" + "<spring:message code='Cache.lbl_Fail'/>"; +"</font>"; }
            else if (pState == "SUCCESS") { strReturn = "<spring:message code='Cache.lbl_Completed'/>"; }
        }

        return strReturn;
    }
	
	function ShowResult(pMessage, pEvent){
		Common.Inform(pMessage);
	}
</script>