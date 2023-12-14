<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script type="text/javascript">	
	var clickedTab; 
	var myGrid = new coviGrid();
	
	$(document).ready(function (){
		clickTab($(".on"));		
	});
	
	
	// 탭 클릭 이벤트
	function clickTab(pObj){
		clickedTab = $(pObj).attr("value");
		
		var strObjName = $(pObj).attr("value");
		$(".AXTab").attr("class","AXTab");
		$(pObj).addClass("AXTab on");
			
		$("#divSchemaInfo div").hide();
		
		$("#div" + strObjName).height();
		$("#div" + strObjName).show();
		
		//탭선택에 따른 그리드  변경을 위해 setGrid()호출
		setGrid();		
	}
	
	
	function setGridHeader(){
		// 헤더 설정
		var headerDataWorkitem =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},	            
		                  {key:'WorkItemID', label:'WORKITEM_ID', width:'150', align:'left'},
		                  {key:'Created',  label:'CREATED', width:'150', align:'left', sort:"desc"
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.Created, "yyyy-MM-dd HH:mm:ss")} },	                  
		                  {key:'FinishRequested',  label:'FINISH_REQUESTED', width:'150', align:'left'},
		                  {key:'Name', label:'NAME', width:'150', align:'left'},
		                  {key:'PerformerID',  label:'PERFORMER_ID', width:'150', align:'left'},
		                  {key:'UserName', label:'PERFORMER_NAME', width:'350', align:'left'}	                  
			      		];
		
		// 헤더 설정
		var headerDataProcess =[
		                  {key:'chk', label:'chk', width:'20', align:'left', formatter:'checkbox'},	            
		                  {key:'ProcessID', label:'PROCESS_ID', width:'150', align:'left'},
		                  {key:'StartDate',  label:'STARTED', width:'150', align:'left', sort:"desc"
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.startDate, "yyyy-MM-dd HH:mm:ss")} },	                  
		                  {key:'ProcessName',  label:'NAME', width:'350', align:'left'},
		                  {key:'DocSubject', label:'PROCESS_SUBJECT', width:'350', align:'left'},
		                  {key:'InitiatorID',  label:'INITIATOR_ID', width:'150', align:'left'},
		                  {key:'InitiatorName', label:'INITIATOR_NAME', width:'150', align:'left'}	                  
			      		];
		
		if(clickedTab=="Workitem"){
			myGrid.setGridHeader(headerDataWorkitem); 
		}else if (clickedTab=="Process"){
			myGrid.setGridHeader(headerDataProcess); 
		}
	}
	
	//그리드 세팅
	function setGrid(){
		setGridHeader();		
		setGridConfig();
		searchConfig(clickedTab);
	}
	
	// 그리드 Config 설정
	function setGridConfig(){		
		var configObj = {
			targetID : "GridView",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};		
		
		myGrid.setGridConfig(configObj);
		
	}
	
	// baseconfig 검색
	function searchConfig(flag){

		myGrid.bindGrid({
				ajaxUrl:"admin/getMonitorErrorList.do",
				ajaxPars: {
					"TYPE" : clickedTab
				},
				onLoad:function(){
					//아래 처리 공통화 할 것
					coviInput.setSwitch();
					//custom 페이징 추가
					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			   		myGrid.fnMakeNavi("GridView");
				}
		});
	}	

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}
	
	//재처리
	function Instance_ReProcess(){
		SelectedRow_Process("ReProcess");
	}
	
	//상태변경-완료
	function Instance_Complete(){
		SelectedRow_Process("Complete");
	}
	
	//상태변경-강제종료
	function Instance_Delete(){
		SelectedRow_Process("Delete");
	}
	
	
	function SelectedRow_Process(sAction){
		
		switch(clickedTab){
			case 'Workitem':
				if (sAction == "ReProcess")
                {
                    InstacnceProcess_Workitem();
                }
                else
                {
                    InstacnceChange(clickedTab,sAction);
                }
				break;
			case 'Process':
				if (sAction == "ReProcess")
                {
                    InstacnceProcess_Process();
                }
                else
                {
                    InstacnceChange(clickedTab,sAction);
                }
				break;
		}
	}
	
	function InstacnceChange(sType, sAction){
		var chkObj = myGrid.getCheckedList(0);
		var ArrayINSTANCE_ID = new Array;	
		var INSTANCE_ID = "";
		if(chkObj.length ==0){
			Common.Warning("<spring:message code='Cache.lbl_apv_alert_selectRow' />"); //선택한 행이 없습니다.
			return false;
		}
		
		Common.Confirm("<spring:message code='Cache.lbl_apv_alert_state' />", "Confirmation Dialog", function(result){//상태를 변경하시겠습니까?
			if(!result){
				return false;
			}else{
				for(var i = 0; i <chkObj.length; i++){
					if(sType=="Workitem")
						ArrayINSTANCE_ID.push(chkObj[i].WorkItemID);	
					else if(sType=="Process")
						ArrayINSTANCE_ID.push(chkObj[i].ProcessID);
				}
				
				INSTANCE_ID = ArrayINSTANCE_ID.join(",");
				
				var CHANGE_STATE ="";
				
				if(sAction=="ReProcess"){
					if(clickedTab=="Workitem"){
						CHANGE_STATE = "289";
					}else{
						CHANGE_STATE = "276";
					}				
				}else if(sAction=="Progress"){
					CHANGE_STATE = "288";
				}else if(sAction=="Delete"){
					CHANGE_STATE = "545";
				}else if(sAction=="Complete"){
					CHANGE_STATE = "528";
				}
						
				$.ajax({
					type:"POST",
					data:{
						"INSTANCE_ID" : INSTANCE_ID,
						"sType" : sType,
						"sAction" : sAction,
						"CHANGE_STATE" : CHANGE_STATE
					},
					url:"admin/setMonitorChangeState.do",
					success:function (data) {
						if(data.result == "ok")
							Refresh();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("admin/setMonitorChangeState.do", response, status, error);
					}
				});
			}
		});
	}
</script>
<h3 class="con_tit_box">
	<span class="con_tit">오류 목록</span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
		<div id="topitembar02" class="topbar_grid">
			<label>
				<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>	
				<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_Reprocessing"/>" onclick="Instance_ReProcess();"/>
				<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_apv_chage_status_exit"/>" onclick="Instance_Delete();"/>
				<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_apv_chage_status_complete"/>" onclick="Instance_Complete();"/>									
			</label>
	</div>
	<div class="AXTabs" style="width:100%;margin-bottom: 10px">
			<div class="AXTabsTray" style="height:30px">					
					<a onclick="clickTab(this);" class="AXTab on" value="Workitem">Workitem</a><!--Workitem-->
					<a onclick="clickTab(this);" class="AXTab" value="Process">Process</a><!--Process-->						
			</div>		
	</div>	
	<div id="GridView"></div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>