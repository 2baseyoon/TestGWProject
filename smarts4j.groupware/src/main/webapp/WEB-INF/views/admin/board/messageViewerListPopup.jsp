<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<script>

	var viewerGrid = new coviGrid();
	var messageID_pop = CFN_GetQueryString("messageID");
	var messageVer_pop = CFN_GetQueryString("messageVer");
	var folderID_pop = CFN_GetQueryString("folderID");
	var bizSection_pop = CFN_GetQueryString("CLBIZ");
	
	$(document).ready(function () {	
		setGrid();		
	});
		
	function setGrid(){
		setGridHeader();
		setGridConfig();
		setListData();
	}
	
	function setGridHeader(){
		var headerData =[{key:'rowNum', label:'<spring:message code="Cache.lbl_Num"/>', width:'2', align:'center', sort:false,
							formatter:function(){ 
								return formatRowNum(this); 
							}
						},			//번호
						{key:'DisplayName', label:"<spring:message code='Cache.lbl_Searcher'/>",  width:'4', align:'center'},		//조회자
						{key:'JobPositionName', label:"<spring:message code='Cache.lbl_JobLevel'/>",  width:'4', align:'center'},	//직급
						{key:'DeptName', label:"<spring:message code='Cache.lbl_SmartDept'/>",  width:'7', align:'center'},			//부서
						{key:'ReadDate', label:"<spring:message code='Cache.lbl_ViewDate'/>" + Common.getSession("UR_TimeZoneDisplay"), width:'9',align:'center', sort:'desc'},			//조회일시
						{key:'Version', label:"<spring:message code='Cache.lbl_Version'/>",  width:'3', align:'center'}
		];
		viewerGrid.setGridHeader(headerData);	
	}
	
	function setGridConfig(){
		var configObj = {
				targetID : "viewerGrid",
				height:"auto",
				listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
				page : {
					pageNo:1,
					pageSize:10
				},
				paging : true,
				colHead:{},
				body:{}
		}
		
		viewerGrid.setGridConfig(configObj);
	}
	
	function setListData(){
		viewerGrid.bindGrid({
			ajaxUrl: "/groupware/admin/selectMessageViewerGridList.do",//조회 컨트롤러
			ajaxPars: {messageID : messageID_pop, version:messageVer_pop, folderID : folderID_pop, bizSection: bizSection_pop},
		});
		
		$("#viewerGrid").find("table").css("font-size", "13px");
	} 

	function formatRowNum(pObj){
		return pObj.index+1;
	}
	
	//하단의 닫기 버튼 함수
	function btnClose_Click(){
		Common.Close();
	}

</script>
<div>
    <!-- 팝업 Contents 시작 -->
   	<div class="coviGrid">
		<div id="viewerGrid"></div>
	</div>
<!-- 	<div> -->
<!-- 	    <div class="popBtn"> -->
<!-- 	    	<a class="ooBtn" href="#ax" onclick="btnClose_Click();" return false;> -->
<%-- 	    		<spring:message code='Cache.btn_apv_close'/> --%>
<!-- 	    	</a> -->
<!-- 		</div> -->
<!-- 	</div> -->
</div>
