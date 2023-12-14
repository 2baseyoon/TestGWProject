<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent" style="padding: 0px 0px 0px;">
	<div class="surTargetBtm">
		<div class="tblList">
			<div id="gridDiv" style="height: auto;">
			</div>					
		</div>
	</div>
</div>

<script>
	var urCode = CFN_GetQueryString("urCode");
	var startDate = CFN_GetQueryString("startDate");
	var endDate = CFN_GetQueryString("endDate");
	var vacType = CFN_GetQueryString("vacType") != 'undefined' ? CFN_GetQueryString("vacType") : "";
	var vacKind = CFN_GetQueryString("vacKind");
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
			}, //이름
			{key:'UseDate', label:'<spring:message code="Cache.lbl_expiryDate" />', width:'100', align:'center'}, //유효기간
	        {key:'VacDay', label:'<spring:message code="Cache.lbl_vacationMsg53" />', width:'100', align:'center', //부여
				formatter: function(){
					return Number(this.item.VacDay);
				}
			},
			{key:'VmMethod', label:'<spring:message code="Cache.lbl_vacationMsg58" />', width:'50', align:'center', addClass:'bodyTdFile',
				formatter:function(){
					 if (this.item.VmMethod == "AUTO"){
						return "<spring:message code='Cache.lbl_auto'/>"; // 자동
					}else if (this.item.VmMethod == "MNL"){
						return "<spring:message code='Cache.lbl_handwriting'/>"; // 수기
					}else{
						return this.item.VmMethod
					}
				}	
			}, //생성방법
			{key:'ChangeDate',  label:'<spring:message code="Cache.lbl_chgdate" />', width:'120', align:'center'}, //변경일시
	        {key:'Comment', label:'<spring:message code="Cache.lbl_ProcessContents" />', width:'200', align:'left'} //처리내용
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
					  startDate : startDate,
					  endDate : endDate,
					  urCode : urCode,
					  vacType: vacType,
					  vacKind : vacKind,
					  sortBy : ""};
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationPlanHist.do",
			ajaxPars : params
		});
	}	
</script>
