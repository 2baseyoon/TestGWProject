<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.covision.groupware.attend.user.util.AttendUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<style>
		.bottom { text-align: center; }
		
		.bottom > a {
			height: 30px;
			line-height: 30px;
		}
		
		#inform {
			margin-bottom: 10px;
			padding: 15px;
			background-color: #f9f9f9;
			border-radius: 5px;
			font-size: 15px;
			line-height: 18px;
		}
	</style>
</head>
<body>
	<div class="ATMgt_popup_wrap">
		<div id="inform">
			<b><spring:message code='Cache.msg_usedVacInform'/></b> <!-- 해당 연도의 연차가 이미 소진된 인원을 하기와 같이 안내 드립니다. -->
		</div>
		<div>
			<div id="grid"></div>
		</div>
	</div>
	<div class="bottom">
		<a id="btnExcel" class="btnTypeDefault btnExcel"><spring:message code='Cache.btn_ExcelDownload'/></a> <!-- 엑셀 다운로드 -->
		<a id="btnClose" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
	</div>
</body>
<script>
	var grid = new coviGrid();
	var headerData = [
		{key: 'DeptName',		label: '<spring:message code="Cache.lbl_dept"/>',			width: '20', align: 'center', hideFilter: 'Y'}, // 부서
		{key: 'DisplayName',	label: '<spring:message code="Cache.lbl_username"/>',		width: '20', align: 'center', hideFilter: 'Y'}, // 이름
		{key: 'ATot',			label: '<spring:message code="Cache.lbl_RemainVacation"/>',	width: '20', align: 'center', hideFilter: 'Y'}  // 잔여연차
	];
	
	function setGridConfig(){
		grid.setGridHeader(headerData);
		
		grid.setGridConfig({
			  targetID: "grid"
			, width: "100%"
			, height: "auto"
			, page: {
				  pageNo: 1
				, pageSize: 5
			}
			, paging: true
			, sort: true
			, overflowCell: []
			, body: {}
		});
	}
	
	function setGrid(){
		grid.bindGrid({
			ajaxUrl: "/groupware/attendReq/getUsedVacationList.do",
			ajaxPars: {
				  vacYear: "${vacYear}"
				, userCodeList: "${userCodes}"
			}
		});
	}
	
	function excelDownload(){
		var sortInfo = grid.getSortParam("one").split("=");
		var	sortColumn = sortInfo.length > 1 ? sortInfo[1].split(" ")[0] : "";
		var	sortDirection = sortInfo.length > 1 ? sortInfo[1].split(" ")[1] : "";
		var params = String.format("vacYear={0}&userCodeList={1}&sortColumn={2}&sortDirection={3}", "${vacYear}", "${userCodes}", sortColumn, sortDirection);
		
		AttendUtils.gridToExcel("<spring:message code='Cache.lbl_usedVacPeopleList' />", headerData, params, "/groupware/attendReq/downloadUsedVacExcel.do"); // 연차 소진 인원 목록
	}
	
	function setEvent(){
		// 엑셀 다운로드
		$("#btnExcel").off("click").on("click", function(){
			excelDownload();
		});
		
		// 닫기
		$("#btnClose").off("click").on("click", function(){
			Common.Close();
		});
	}
	
	function init(){
		setEvent();
		setGridConfig();
		setGrid();
	}
	
	init();
</script>