<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<script>

	var historyGrid = new coviGrid();
	var messageID_pop = CFN_GetQueryString("messageID");
	
	$(document).ready(function () {	
		setGrid();		
	});
		
	function setGrid(){
		setGridHeader();
		setGridConfig();
		setListData();
	}
	
	function setGridHeader(){
		var headerData =[{key:'rowNum', label:'<spring:message code="Cache.lbl_Num"/>', width:'2',align:'center',
							formatter:function(){ 
								return formatRowNum(this); 
							}
						},			//번호
						{key:'HistoryType', label:"<spring:message code='Cache.lbl_Processing_History'/>",  width:'3', align:'center',
							formatter:function(){ 
			        			return formatHistoryType(this); 
			        		}
						},			//처리 이력
						{key:'Comment', label:"<spring:message code='Cache.lbl_ReasonForProcessing'/>",  width:'7', align:'center',
							formatter: function() {
								var comment = this.item.Comment;
								if(comment) comment = comment.replace(/<br>/gi, '\r\n');
								return "<div class='bodyNode bodyTdText' align='center' title='"+comment+"'>"+comment+"</div>";
							}
						},			//처리 사유
						{key:'DisplayName', label:"<spring:message code='Cache.lbl_Register'/>",  width:'6', align:'center'},			//등록자 이름
						{key:'DeptName', label:"<spring:message code='Cache.lbl_SmartDept'/>",  width:'6', align:'center'},				//등록자 부서
						{key:'RegistDate', label:"<spring:message code='Cache.lbl_Registration_Date'/>" + Common.getSession("UR_TimeZoneDisplay"), width:'6',align:'center'}			//조회일시
		];
		historyGrid.setGridHeader(headerData);	
	}
	
	function setGridConfig(){
		var configObj = {
				targetID : "historyGrid",
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
		
		historyGrid.setGridConfig(configObj);
	}
	
	function setListData(){
		historyGrid.bindGrid({
			ajaxUrl: "/groupware/admin/selectMessageHistoryGridList.do",
			ajaxPars: {messageID : messageID_pop},
		});
		
		$("#historyGrid").find("table").css("font-size", "13px");
	} 

	//Grid Index 표시용
	function formatRowNum(pObj){
		return pObj.index+1;
	}
	
	//하단의 닫기 버튼 함수
	function btnClose_Click(){
		Common.Close();
	}
	
	function formatHistoryType(pObj){
		var msgState;
		switch(pObj.item.HistoryType){
		
		case "Delete":
			msgState = "<spring:message code='Cache.lbl_delete'/>";		// 삭제
			break;
		case "Move":
			msgState = "<spring:message code='Cache.lbl_Move'/>";		// 이동
			break;
		case "Copy":
			msgState = "<spring:message code='Cache.lbl_Copy'/>";		// 복사
			break;
		case "Report":
			msgState = "<spring:message code='Cache.lbl_Report'/>";		// 보고
			break;
		case "Restore":
			msgState = "<spring:message code='Cache.lbl_Restore'/>";	// 복원
			break;
		case "Approval":
			msgState = "<spring:message code='Cache.lbl_Approval'/>";	// 승인
			break;
		case "Lock":
			msgState = "<spring:message code='Cache.lbl_Lock'/>";		// 잠금
			break;
		case "Return":
			msgState = "<spring:message code='Cache.lbl_Return'/>";		// 반납
			break;
		case "Unlock":
			msgState = "<spring:message code='Cache.lbl_UnLock'/>";		// 잠금해제
			break;
		case "Export":
			msgState = "<spring:message code='Cache.lbl_Export'/>";		// 내보내기
			break;
		case "ChangeOption":
			msgState = "<spring:message code='Cache.lbl_ChangeOption'/>"// 옵션변경
			break;
		default:
		}		
		
		return msgState;
	}

</script>
<div>
    <!-- 팝업 Contents 시작 -->
   	<div class="coviGrid">
		<div id="historyGrid"></div>
	</div>
<!-- 	<div> -->
<!-- 	    <div class="popBtn"> -->
<!-- 	    	<a class="ooBtn" href="#ax" onclick="btnClose_Click();" return false;> -->
<%-- 	    		<spring:message code='Cache.btn_apv_close'/> --%>
<!-- 	    	</a> -->
<!-- 		</div> -->
<!-- 	</div> -->
</div>
