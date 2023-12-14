<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>

<style>
	.popBottom { text-align: center; }
</style>

<div>
	<div>
		<div class="tblList tblCont">
			<div id="grid"></div>
		</div>
	</div>
	<div class="popBottom">
		<input id="btnConfirm" type="button" value="<spring:message code='Cache.btn_Confirm'/>" class="AXButton red"> <!-- 확인 -->
		<input id="btnClose" type="button" value="<spring:message code='Cache.btn_Close'/>" class="AXButton"> <!-- 닫기 -->
	</div>
</div>

<script>
	(function(param){
		var grid = new coviGrid();
		
		var setEvent = function(){
			$("#btnConfirm").off("click").on("click", function(){
				var cnt = grid.getCheckedList(0).length;
				
				if (cnt > 0) {
					exportMenu();
				} else {
					Common.Warning("<spring:message code='Cache.msg_apv_003'/>"); // 선택된 항목이 없습니다.
					return false;
				}
			});
			
			$("#btnClose").off("click").on("click", function(){
				Common.Close();
			});
		};
		
		var setGrid = function(){
			var headerData = [
				{key: 'chk', label: '', align:'center', width: '5', align: 'center', hideFilter: 'Y', formatter: 'checkbox'},
				{key: 'DomainCode', label:'<spring:message code="Cache.lbl_DN_Code"/>', width: '40', align: 'center'}, // 도메인 코드
				{key: 'DisplayName', label:'<spring:message code="Cache.lbl_CorpName"/>', width: '40', align: 'center'} // 회사명
			];
			
			grid.setGridHeader(headerData);
			
			grid.setGridConfig({
				targetID		: "grid",
				height			: "auto",
				paging			: true,
				sort			: true,
				overflowCell	: [],
				body: {}
			});
			
			bindGrid();
		};
		
		var bindGrid = function(){
			$.ajax({
				url: "/covicore/domain/getCode.do",
				type: "POST",
				success: function(data){
					if(data.status === "SUCCESS"){
						var list = data.list.filter(function(d){
							return d.DomainID !== param.domainId;
						});
						
						grid.setData({
							  list: list
							, page: {
								listCount: list.length
							}
						});
					}else{
						Common.Warning(data.message);
					}
				},
				error: function(response, status, error){
				     CFN_ErrorAjax("/covicore/domain/getCode.do", response, status, error);
				}
			});
		};
		
		var exportMenu = function(){
			var domainIds = grid.getCheckedList(0).map(function(data){
				return data.DomainID;
			});
			
			$.ajax({
				url: "/covicore/menu/exportMenu.do",
				type: "POST",
				data: {
					  menuId: param.menuId
					, domainIds: domainIds.join(";")
					, sortPath: param.sortPath
				},
				success: function(data){
					if(data.status === "SUCCESS"){
						parent.Common.Inform(data.message, "Information", function(result){
							if (result) Common.Close();
						});
					}else{
						Common.Warning(data.message);
					}
				},
				error: function(response, status, error){
				     CFN_ErrorAjax("/covicore/menu/exportMenu.do", response, status, error);
				}
			});
		};
		
		var init = function(){
			setEvent();
			setGrid();
		};
		
		init();
		
	})({
		  menuId: "${menuId}"
		, sortPath: unescape("${sortPath}")
		, domainId: "${domainId}"
	});
</script>