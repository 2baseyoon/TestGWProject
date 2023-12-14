<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/task.js"></script>

<style>
	.siteLinkName { text-decoration: underline; cursor: pointer; }
	.bottom { text-align: center; }
</style>

<div class="divpop_contents" style="height:100%;">
	<div class="divpop_body" style="overflow:hidden; padding:0;">
		<div class="popContent">
			<div class="middle">
				<div class="tblList tblCont">
					<div id="grid"></div>
				</div>
			</div>
			<div class="bottom">
				<a href="#" id="btnAdd" class="btnTypeDefault"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
				<a href="#" id="btnDelete" class="btnTypeDefault"><spring:message code="Cache.btn_Delete"/></a> <!-- 삭제 -->
				<a href="#" id="btnClose" class="btnTypeDefault"><spring:message code="Cache.btn_Close"/></a> <!-- 닫기 -->
			</div>
		</div>
	</div>
</div>

<script>
	var grid  = new coviGrid();
	var returnMode = CFN_GetQueryString("returnMode") == "undefined" ? "" : CFN_GetQueryString("returnMode");
	var popupID = CFN_GetQueryString("popupID") == "undefined" ? "" : CFN_GetQueryString("popupID");
	
	function init(){
		setEvent();
		setGrid();
	}
	
	function setEvent(){
		$("#btnClose").click(function(){
			if(returnMode == "Webpart") parent.window.pnSiteLink.getSiteLinkList();
			
			Common.Close();
		});
		
		$("#btnAdd").on("click", openSiteLinkAddPopup);
		
		$("#btnDelete").on("click", deleteSiteLinkList);
	}
	
	function setGrid(){
		var headerData = [
			{key: 'chk', label:'chk', width:'5', align:'center', formatter: 'checkbox'},
			{key: 'SiteLinkID', label:'SiteLinkID', width:'5', align:'center', display: false},
			{key: 'UserCode', label:'UserCode', width:'5', align:'center', display: false},
			{key: 'SiteLinkName', label: '<spring:message code="Cache.lbl_SiteLinkName"/>', width:'50', align:'center' // 사이트링크 이름
				, formatter: function(){
					return "<span class='siteLinkName' onclick='openSiteLinkModifyPopup(\"" + this.item.SiteLinkID + "\")'>" + this.item.SiteLinkName + "</span>";
				}
			}, 
			{key: 'SiteLinkURL', label: '<spring:message code="Cache.lbl_SiteLinkAddress"/>', width:'50', align:'center'} // 사이트링크 주소
		];
		
		grid.setGridHeader(headerData);
		setGridConfig();
		selectGridList();
	}
	
	function setGridConfig(){
		var configObj = {
			targetID: "grid",
			listCountMSG: "<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height: "auto",
			page: {
				pageNo: 1,
				pageSize: 10,
			},
			paging: true,
			colHead: {},
			body: {}
		};
		
		grid.setGridConfig(configObj);
	}
	
	function selectGridList(){
		var params = {};
		
		grid.page.pageNo = 1;
		
		grid.bindGrid({
			ajaxPars: params,
			ajaxUrl: "/groupware/pnPortal/selectSiteLinkList.do"
		});
		
		if(returnMode == "Personal") {
			window.parent.postMessage({ functionName :"systemShortcut", params:{}}, '*');
		}
	}
	
	function openSiteLinkAddPopup(){
		parent.Common.open("", "SiteLinkAdd", "<spring:message code='Cache.lbl_AddSiteLink' />", "/groupware/pnPortal/goSiteLinkAddPopup.do?mode=Add&callBackFunc=selectGridList&openerID="+popupID, "500px", "240px", "iframe", true, null, null, true); // 사이트링크 추가
	}
	
	function openSiteLinkModifyPopup(pSiteLinkID){
		parent.Common.open("", "SiteLinkModify", "<spring:message code='Cache.lbl_ModifySiteLink' />", "/groupware/pnPortal/goSiteLinkAddPopup.do?mode=Modify&siteLinkID="+pSiteLinkID+"&callBackFunc=selectGridList&openerID="+popupID, "500px", "240px", "iframe", true, null, null, true); // 사이트링크 수정
	}
	
	function deleteSiteLinkList(){
		var checkedList = grid.getCheckedList(0);
		
		if(checkedList.length == 0){
			Common.Inform("<spring:message code='Cache.lbl_apv_alert_selectRow' />"); // 선택한 행이 없습니다.
			return false;
		}
		
		var selLinks = checkedList.map(function(item){
			return item.SiteLinkID;
		}, []).join(";");
		
		$.ajax({
			url: "/groupware/pnPortal/deleteSiteLinkList.do",
			type: "POST",
			data: {
				"siteLinkIDs": selLinks
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_DeleteResult'/>", "Information", function(result){ // 성공적으로 삭제되었습니다
						selectGridList();
					});
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/pnPortal/deleteSiteLinkList.do", response, status, error);
			}
		});
	}
	
	init();
</script>