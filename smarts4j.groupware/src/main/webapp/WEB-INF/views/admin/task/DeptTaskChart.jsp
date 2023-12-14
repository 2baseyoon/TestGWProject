<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div id="workDiv">
	<h3 class="con_tit_box">
		<span id="folderTitle" class="con_tit">부서별 통계</span> 
	</h3>
	<div style="width:100%;min-height: 500px">
	       <div id="topitembar01" class="topbar_grid">
				<input id="workRefreshBtn"  type="button" class="AXButton BtnRefresh"  style="margin-right: 5px;" onclick="refresh();" value="<spring:message code='Cache.lbl_Refresh'/>" /><!--새로고침-->
	       		조회할 부서 : <input id="groupName" type="text" class="AXInput" readonly="readonly" placeholder="부서 선택" onclick="popupOrgChart();"/>
				<input id="hidGroupID" type="hidden" value=""/> 
				<input type="button" value="<spring:message code="Cache.lbl_DeptOrgMap"/>" onclick="popupOrgChart();" class="AXButton"/><!--조직도 -->
		   </div>
			<div id="chartGrid"></div>
	</div>
</div>



<script type="text/javascript">
	//# sourceURL=DeptTaskChart.jsp

	var chartGrid = new coviGrid();

	//ready
	init();
	
	function init(){
		setGrid();
	}
	
	// 헤더 설정
	//그리드 세팅
	function setGrid(){
		chartGrid.setGridHeader([	
				                  {key:'Kind', label:'<spring:message code="Cache.lbl_kind"/>', width:'10', align:'center'},     //명칭
				                  {key:'Waiting',  label:'<spring:message code="Cache.lbl_inactive"/>', width:'30', align:'center'},    //대기
				                  {key:'Process',  label:'<spring:message code="Cache.lbl_goProcess"/>', width:'30', align:'center' },	     //진행
				                  {key:'Complete',  label:'<spring:message code="Cache.lbl_Completed"/>', width:'30', align:'center' },	     //완료
					      		]);
		
		setGridConfig();
	}
	
	function refresh(){
		$("#groupName").val('');
		$("#hidGroupID").val('');
		
		searchChart();
		
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		chartGrid.setGridConfig({
				targetID : "chartGrid",
				height:"auto",
				listCountMSG: " ",
				emptyListMSG: "<spring:message code='Cache.msg_ObjectUR_10'/>", // 부서를 선택하여 주십시오.  
				paging: false
		});
	}
	

	//업무 그리드 바인딩
	function searchChart(){	
		if($("#hidGroupID").val() !=''){
			chartGrid.bindGrid({
					ajaxUrl:"/groupware/task/getGroupChartData.do",
					ajaxPars: {
						"groupCode": $("#hidGroupID").val(),
					}
			});
		}else{
			chartGrid.bindGrid({page:{pageNo:1,pageSize:10,pageCount:1},list:[]});
		}
	}	
	
	
	//업무(Task) 삭제
	function popupOrgChart(){
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?type=C1&callBackFunc=callBackOrgChart","1060px","580px","iframe",true,null,null,true);
	}
	
	function callBackOrgChart(data){
		var jsonOrg = $.parseJSON(data);
		
		if(jsonOrg.item[0] != null){
			$("#groupName").val(CFN_GetDicInfo(jsonOrg.item[0].DN));
			$("#hidGroupID").val(jsonOrg.item[0].AN);
			
			searchChart();
		}	
	}
	
</script>

