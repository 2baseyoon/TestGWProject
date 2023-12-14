<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="sadmin_pop">
	<div>
		<input type="text" id="searchtext" onkeypress=""/>&nbsp;
		<a class="btnTypeDefault" id="btnSearch"><spring:message code='Cache.btn_search'/></a>
	</div>

	<div class="fixLine tblCont">
		<div id="grid"></div>
	</div>
	<div class="bottomBtnWrap">
		<a class="btnTypeDefault btnTypeBg" id="btnConfirm"><spring:message code='Cache.Cache.btn_Confirm'/></a><!-- 저장 -->
		<a class="btnTypeDefault" id="btnClose"><spring:message code='Cache.Cache.Cache.btn_Close'/></a><!-- 닫기 -->
	</div>
</div>

<script>
	(function(param){
		var grid = new coviGrid();
		
		var setEvent = function(){
			$("#searchtext").off("keypress").on("keypress", function(){
				if (event.keyCode==13){ bindGrid(); return false;}
			});

			$("#btnSearch").off("click").on("click", function(){
				bindGrid();
			});
			
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
				{key: 'chk', label: '', align:'center', width: '30', align: 'center', hideFilter: 'Y', formatter: 'checkbox'},
				{key: 'DomainCode', label:'<spring:message code="Cache.lbl_DN_Code"/>', width: '80', align: 'center'}, // 도메인 코드
				{key: 'DisplayName', label:'<spring:message code="Cache.lbl_CorpName"/>', width: '80', align: 'left', sort:'asc'}, // 회사명
                {key:'ServicePeriod',  label:'<spring:message code="Cache.lbl_ServicePeriod"/>', width:'120', align:'center'}
			];
			
			grid.setGridHeader(headerData);
			grid.setGridConfig({
				targetID		: "grid",
				height			: "auto",
				sort			: true,
				paging : false
			});
			
			bindGrid();
		};
		
	var bindGrid = function(){
			$.ajax({
				url: "/covicore/domain/getList.do",
				type: "POST",
				data:{
					"isUse" : "Y",
					"selectsearch":$("#searchtext").val(),
					"pageSize":"9999"
				},
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
				url: "/covicore/manage/menu/exportMenu.do",
				type: "POST",
				data: {
					  menuId: param.menuId
					, domainIds: domainIds.join(";")
					, sortPath: param.sortPath
					, exportMenuDomain: param.domainId
					, isAll: param.isAll
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
		, isAll : "${isAll}"
	});
</script>