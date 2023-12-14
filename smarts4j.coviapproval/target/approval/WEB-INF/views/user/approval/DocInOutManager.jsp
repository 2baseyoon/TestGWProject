<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>

<div class="cRConTop titType">
	<h2 id="govDocsTit" class="title"><spring:message code='Cache.lbl_apv_govdoc_inout_manager' /></h2> <!-- 문서수발신 담당자 관리 -->
</div>
<div class="cRContBottom mScrollVH">
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="addUser" class="btnTypeDefault"><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
				<select id="searchType" class="selectType02">
					<option value="All"><spring:message code='Cache.lbl_all' /></option> <!-- 전체 -->
					<option value="Assign"><spring:message code='Cache.lbl_allocation' /></option> <!-- 할당 -->
					<option value="Misassign"><spring:message code='Cache.lbl_unallocated' /></option> <!-- 미할당 -->
				</select>
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>										
				<button id="refresh" class="btnRefresh"></button><!-- 새로고침 -->
			</div>
		</div>
		<div class="apprvalBottomCont">
			<div id="groupLiestDiv" class="searchBox" style="display: none">
				<div class="searchInner">
					<ul id="groupLiestArea" class="usaBox"></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox">
					<div class="conin_list" style="width:100%;">
						<div id="approvalListGrid"></div>
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>

<script>	
	var ListGrid = new coviGrid();
	var initData = {};
	var Constants = {			
		HEADER: [
			 	{key: 'DeptName', label: '<spring:message code="Cache.lbl_apv_ChargeDept" />', width: '20', align: 'center'}, // 담당부서
			 	{key: 'ListAuthorityName', label: '<spring:message code="Cache.lbl_apv_charge_person" />', width: '70', align: 'left'}, // 담당자
			 	{label: ' ', width: '15', align: 'center', sort: false,
			 		formatter: function(){
			 			var item = this.item;
			 			var returnObj;
			 			
			 			if(item.ListAuthorityName != "" && item.ListAuthorityID != ""){
			 				returnObj = $("<a>", {"class": "btnTypeDefault modifyBtn", "text": "<spring:message code='Cache.btn_Edit' />", "onclick": "openManagerPopup('M', '" + item.DeptCode + "')"}).get(0).outerHTML; // 수정
			 			}else{
			 				returnObj = $("<a>", {"class": "btnTypeDefault", "text": "<spring:message code='Cache.btn_Add' />", "onclick": "openManagerPopup('I', '" + item.DeptCode + "', '" + item.DeptName + "')"}).get(0).outerHTML; // 추가
			 			}
			 			
			 			return returnObj;
			 		}
			 	}
			]
	}

	var govDocFunction = {		 	
		init: function(){
			$("#refresh").on("click", function(){
				ListGrid.page.pageNo = 1;
				ListGrid.bindGrid({ajaxUrl: "/approval/user/getGovDocInOutManager.do", ajaxPars: {"searchType": $("#searchType").val()}});	
			});
			
			$("#addUser").on("click", function(){
				openManagerPopup("I");
			});
			
			$("#searchType").on("change", function(){
				ListGrid.page.pageNo = 1;
				ListGrid.bindGrid({ajaxUrl: "/approval/user/getGovDocInOutManager.do", ajaxPars: {"searchType": $("#searchType").val()}});	
			});
		},
		setGrid: function(){
			ListGrid.setGridHeader(Constants.HEADER);
			ListGrid.setGridConfig({
				targetID: "approvalListGrid",
				height: "auto",
				page: {
					pageNo: 1,
					pageSize: $("#selectPageSize").val()
				},
				paging: true,
				sort: true,
				overflowCell: [],
				body: {}
			});
			ListGrid.bindGrid({ajaxUrl: "/approval/user/getGovDocInOutManager.do", ajaxPars: {"searchType": $("#searchType").val()}});	
		}
	}	

	//일괄 호출 처리
	initApprovalListComm(initDocInOutManager, govDocFunction.setGrid);
	
	function initDocInOutManager() {
		govDocFunction.init();
		govDocFunction.setGrid();
	}
	
	function openManagerPopup(mode, deptCode, deptName){
		var popupName = "";
		var url = "/approval/user/govDocInOutUserAdd.do?mode=" + mode;
		
		switch(mode){
			case "I":
				popupName = "<spring:message code='Cache.lbl_addDocumentRecipient' />"; // 문서수발신 담당자 추가
				break;
			case "M":
				popupName = "<spring:message code='Cache.lbl_modifyDocumentRecipient' />"; // 문서수발신 담당자 수정
				break;
		}
		
		if(deptCode != null && deptCode != undefined){
			url += "&deptCode=" + deptCode;
		}
		
		if(deptName != null && deptName != undefined){
			url += "&deptName=" + encodeURIComponent(deptName);
		}
		
		Common.open("", "addUser", popupName, url, "650px", "400px", "iframe", true, null, null, true);
	}
</script>