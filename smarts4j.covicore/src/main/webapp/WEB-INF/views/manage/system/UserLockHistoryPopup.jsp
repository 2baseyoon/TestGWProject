<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="sadmin_pop">
	<div class="fixLine tblCont">
		<div id="grid"></div>
	</div>
	<div class="bottomBtnWrap">
		<a class="btnTypeDefault" id="btnClose"><spring:message code='Cache.Cache.Cache.btn_Close'/></a><!-- 닫기 -->
	</div>
</div>

<script>
	(function(param){
		var grid = new coviGrid();
		
		var setEvent = function(){
			$("#btnClose").off("click").on("click", function(){
				Common.Close();
			});
		};
		
		var setGrid = function(){
			var headerData = [
		             {key:'RegistDate', label:'<spring:message code="Cache.lbl_ProcessingDays"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center',formatter: function(){
	      					return CFN_TransLocalTime(this.item.RegistDate);
	  					}, dataType:'DateTime'},
	 	             {key:'ApprovalRemark', label:'<spring:message code="Cache.lbl_ApprovalDetail"/>', width:'200', align:'left'},
	        		 {key:'Result',  label:'<spring:message code="Cache.lbl_apv_result2"/>', width:'60', align:'center'},
	        		 {key:'DisplayName',  label:'<spring:message code="Cache.lbl_Processor"/>',width:'60', align:'center'}
			];
			
			grid.setGridHeader(headerData);
			grid.setGridConfig({
				targetID		: "grid",
				height			: "480px"
			});
			
			grid.bindGrid({
	 			ajaxUrl:"/covicore/manage/user/getUserLockHistory.do",
	 			ajaxPars: {
	 				"UserCode":"${UserCode}"
	 			}
			});
		};
		
		var init = function(){
			setEvent();
			setGrid();
		};
		
		init();
		
	})({
		  userCode: "${UserCode}"
	});
</script>