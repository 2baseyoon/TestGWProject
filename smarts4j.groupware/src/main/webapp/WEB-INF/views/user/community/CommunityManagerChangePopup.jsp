<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="popContent pd0">
	<div class="selectSearchBox">
		<span><input type="text" id="searchText" onkeypress=" if(event.keyCode==13){searchData(); return false;} " /><a class="btnSearchType01" onclick="searchData()" ></a></span>
		<button class="btnRefresh" type="button" onclick="refresh()"></button>					
	</div>				
	<div class="surTargetBtm" style="margin-top: 10px;">
		<div class="tblList">					
			<div id="gridDiv"></div>									
		</div>
	</div>
	<div class="popBtn">
		<input type="button" class="ooBtn ooBtnChk" onclick="returnData();" value="확인"/>
		<input type="button" class="owBtn mr30" onclick="closeLayer();" value="닫기" />
	</div>
	<input type="hidden" id="hidOperator" value= "" />
	<input type="hidden" id="hidOperatorCode" value= "" />
	<input type="hidden" id="hidOperatorDeptName" value= "" />
	<input type="hidden" id="hidOperatorPositionName" value= "" />
</div>
<script>
	var callBackFunc = CFN_GetQueryString("callBackFunc");
	var CU_ID = CFN_GetQueryString("CU_ID");	
	var grid = new coviGrid();
	var headerData = new Array();
	
	initContent();

	function initContent(){
		setGrid();	// 그리드 세팅
		searchData();
	}
	
	// 그리드 세팅
	function setGrid() {
		var headerData = [
		            {key:'chk', label:'선택',  width:'2', align:'center', hideFilter : 'Y', sort:false, formatter:function(){
		            	var html ;		            	
		            	if(this.item.memberLevel == "9"){
		            		html = "";
		            	}else{
		            		html = seletRadioBox(this.item.UR_Code, this.item.opName, this.item.opDeptName, this.item.opJobPositionName);
		            	}
		            	return html;
		            }},                   
					{key:'UR_Code', label:'UR_Code', hideFilter : 'Y',display:false},
					{key:'opName',  label:"<spring:message code='Cache.lbl_name'/>", width:'3', align:'center'},
					{key:'opDeptName',  label:"<spring:message code='Cache.lbl_apv_dept'/>", width:'3', align:'center'},
					{key:'opJobPositionName',  label:"<spring:message code='Cache.lbl_JobPosition'/>", width:'3', align:'center'},
					{key:'CuMemberLevel',  label:"<spring:message code='Cache.lbl_User_Grade'/>", width:'3', align:'center'}
		];
		
		grid.setGridHeader(headerData);
		
		var configObj = {
			targetID : "gridDiv",
			height: "auto",
			colHeadTool : false
		};
		
		grid.setGridConfig(configObj);
	}
	
	// 데이터 초기화
	function initData() {
		$("#hidOperatorCode").val("");
		$("#hidOperator").val("");
		$("#hidOperatorDeptName").val("");
		$("#hidOperatorPositionName").val("");
	};
	
	// 검색
	function searchData() {
		initData();
		grid.page.pageNo = 1;
		grid.page.pageSize = 5;
		grid.bindGrid({
			ajaxUrl:"/groupware/layout/userCommunity/selectCommunityMemberGridList.do",
			ajaxPars: {
				CU_ID : CU_ID,
				searchText : $("#searchText").val()
			}
		});
	}
	
	//새로고침
	function refresh(){
		$("#searchText").val("");
		initData();
		searchData();
	}
	
	// 운영자 선택 Radio
	function seletRadioBox(UR_Code, opName, opDeptName, opJobPositionName){
		var str = String.format('<input type="radio" name="managerChange" style="margin-top: 4px;" onclick=checkBox(\''+UR_Code+'\',\''+opName+'\',\''+opDeptName+'\',\''+opJobPositionName+'\')>');	
		return str;
	}
	
	// 운영자 선택	
	function checkBox(UR_Code, opName, opDeptName, opJobPositionName) {
		$("#hidOperatorCode").val(UR_Code);
		$("#hidOperator").val(opName);
		$("#hidOperatorDeptName").val(opDeptName);
		$("#hidOperatorPositionName").val(opJobPositionName);
	}
	
	// 운영자 선택 확인
	function returnData() {
		if($("#hidOperatorCode").val() == "") {
			Common.Warning(Common.getDic("msg_selectOperator"));
			return false;
		}
		
		if(window[callBackFunc] != undefined){
			window[callBackFunc]($("#hidOperatorCode").val(), $("#hidOperator").val(), $("#hidOperatorDeptName").val(), $("#hidOperatorPositionName").val());
		} else if(parent[callBackFunc] != undefined){
			parent[callBackFunc]($("#hidOperatorCode").val(), $("#hidOperator").val(), $("#hidOperatorDeptName").val(), $("#hidOperatorPositionName").val());
		} else if(opener[callBackFunc] != undefined){
			opener[callBackFunc]($("#hidOperatorCode").val(), $("#hidOperator").val(), $("#hidOperatorDeptName").val(), $("#hidOperatorPositionName").val());
		}
		
		Common.Close();
	}
	
	// 닫기
	function closeLayer() {
		Common.Close();
	}
</script>