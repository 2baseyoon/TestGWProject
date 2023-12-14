<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent">
	<div class="surTargetBtm">
		<div class="top">						
			<div class="tblList">
				<div id="gridDiv" style="height: auto;">
				</div>					
			</div>	
		</div>
		<div class="bottom">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="insertVacationCancelDoc()"><spring:message code='Cache.btn_register' /></a>
			<a href="#" class="btnTypeDefault" onclick="Common.Close()"><spring:message code='Cache.btn_Close' /></a>
		</div>
	</div>
</div>
			
<script>
	var param = location.search.substring(1).split('&');
	var urCode = param[0].split('=')[1];
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
			{key:'formKey', label:'formKey', width:'25', align:'center', formatter:'checkbox', sort:false},
			{key:'DocSubject', label:'<spring:message code="Cache.lbl_subject" />', width:'100', align:'left'},
	        {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept" />', width:'70', align:'center'},	              
	        {key:'InitiatorName', label:'<spring:message code="Cache.lbl_apv_writer" />', width:'50', align:'center',
				formatter:function () {
					var workItemId = this.item.formKey.split(';')[0];
					var processId = this.item.formKey.split(';')[1];
					
					var html = "<div>";
					html += "<a href='#' onclick='openVacationViewPopup(\"" + this.item.UR_Code + "\", \"" + processId + "\", \"" + workItemId + "\"); return false;'>";
					html += this.item.InitiatorName;
					html += "</a>";
					html += "</div>";
						
					return html;
				}
	        },
	        {key:'FormName', label:'<spring:message code="Cache.lbl_FormNm" />', width:'100', align:'left'},
	        {key:'EndDate', label:'<spring:message code="Cache.lbl_apv_donedate" />', width:'100', align:'center'}
		];
		
		grid.setGridHeader(headerData);
		
		// config
		var configObj = {
			targetID : "gridDiv",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",			
			paging : true,
			page : {
				pageNo:1,
				pageSize:10
			}
		};
		grid.setGridConfig(configObj);
	}

	// 검색
	function search() {
		var params = {urCode : urCode,
					  sortBy : "EndDate DESC"};
		
		// bind
		grid.bindGrid({
			ajaxUrl : "/groupware/vacation/getVacationCancelDocList.do",
			ajaxPars : params,
			onLoad : function() {
				//아래 처리 공통화 할 것
				coviInput.setSwitch();
				//custom 페이징 추가
				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
				grid.fnMakeNavi("grid");
			}
		});
	}
	
	// 등록
	function insertVacationCancelDoc() {
		var formKeyArr = new Array();
	    $('#gridDiv_AX_gridBodyTable tr').find('input[type="checkbox"]:checked').each(function () {
	    	formKeyArr.push(this.value);
	    });
		
		if (formKeyArr.length > 1) {
			alert('<spring:message code="Cache.msg_SelectOne" />');
			return;
		} else {
			opener.window.formKey = formKeyArr.slice();
			Common.Close();
		}
	}
	
	// 휴가 신청/취소 내역
	function openVacationViewPopup(urCode, processId, workItemId) {
		CFN_OpenWindow("/approval/approval_Form.do?mode=COMPLETE&processID="+processId+"&workitemID="+workItemId+"&userCode="+urCode+"&archived=true", "", 790, (window.screen.height - 100), "resize");
	}	
</script>
