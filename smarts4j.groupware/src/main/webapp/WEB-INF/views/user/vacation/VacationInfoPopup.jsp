<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent">
	<div class="surTargetBtm">
		<div class="tblList">
			<div id="gridDiv" style="height: auto;">
			</div>					
		</div>
	</div>
</div>

<script>
	var urCode = CFN_GetQueryString("urCode");
	var year = CFN_GetQueryString("year");
	var grid = new coviGrid();

	initContent();

	function initContent() {
		setGrid();	// 그리드 세팅
		
		search();	// 검색
	}
	
	// 그리드 세팅
	function setGrid() {
		// header
		var	headerData = [
			{key:'DisplayName', label:'<spring:message code="Cache.lbl_username" />', width:'100', align:'center', addClass:'bodyTdFile',
				formatter:function(){
					var html ="<div class='btnFlowerName' onclick='coviCtrl.setFlowerName(this)' style='position:relative;cursor:pointer' data-user-code='"+ this.item.UR_Code +"' data-user-mail=''>"
					html += this.item.DisplayName;
					html += "</div>";
						
					return html;
				}	
			},
			{key:'APPDATE', label:'<spring:message code="Cache.lbl_DraftDate" />', width:'100', align:'center'},
	        {key:'ENDDATE',  label:'<spring:message code="Cache.lbl_apv_EndDate" />', width:'100', align:'center'},	              
	        {key:'VacFlagName', label:'<spring:message code="Cache.lbl_Gubun" />', width:'100', align:'center'},
	        {key:'Year', label:'<spring:message code="Cache.lblNyunDo" />', width:'100', align:'center'},
	        {key:'Sdate', label:'<spring:message code="Cache.lbl_startdate" />', width:'100', align:'center'},
	        {key:'Edate', label:'<spring:message code="Cache.lbl_EndDate" />', width:'100', align:'center'},
	        {key:'VacDay', label:'<spring:message code="Cache.lbl_UseVacation" />', width:'100', align:'center',
				formatter: function(){
					return Number(this.item.VacDay);
				}
			},
	        {key:'Reason', label:'<spring:message code="Cache.lbl_Reason" />', width:'200', align:'left'}
		];
		
		grid.setGridHeader(headerData);
		
		// config
		var configObj = {
			targetID : "gridDiv",
			height:"auto"
		};
		grid.setGridConfig(configObj);
	}

	// 검색
	function search() {
		var params = {reqType : 'vacationInfo',
					  year : year,
					  urCode : urCode,
					  sortBy : ""};
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationInfoList.do",
			ajaxPars : params
		});
	}	
</script>
