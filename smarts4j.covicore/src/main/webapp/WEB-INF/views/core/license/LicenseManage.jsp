<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/collaboration/resources/css/collaboration.css<%=resourceVersion%>">
<style>
	.aLink { cursor: pointer; }
	.help_ico {
		cursor: pointer;
		color: transparent !important;
	}
</style>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_licenseManage"/></span> <!-- 라이선스 관리 -->
</h3>
<form id="form1">
	<div style="width:100%; min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" id="btnRefresh" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>"/> <!-- 새로고침 -->
			<input type="button" id="btnAdd" class="AXButton BtnAdd" value="<spring:message code="Cache.lbl_Add"/>"/> <!-- 추가 -->
			<input type="button" id="btnDelete" class="AXButton BtnDelete" value="<spring:message code="Cache.lbl_delete"/>"/> <!-- 삭제 -->
		</div>
		<div id="grid"></div>
	</div>
</form>

<script>
	// #sourceURL=LicenseManage.jsp
	var grid = new coviGrid();
	
	var init = function(){
		setEvent();
		setGrid();
	}
	
	var setEvent = function(){
		// 조회(새로고침)
		$("#btnRefresh").on("click", function(){
			searchGrid();
		});
		
		// 추가
		$("#btnAdd").on("click", function(){
			openLicenseManagePopup("add");
		});
		
		// 삭제
		$("#btnDelete").on("click", function(){
			deleteLicense();
		});
	}
	
	//그리드 세팅
	var setGrid = function(){
		grid.setGridHeader([
			{key:'chk', label:'chk', width:'2', align:'center', formatter: 'checkbox'},
			{key:'LicName', label:'<spring:message code="Cache.lbl_license"/>', width:'10', align:'center', tooltip:function(){ return  this.item.Description}, formatter: function(){ // 포함모듈
				var onClick = "openLicenseManagePopup('edit', '" + this.item.LicSeq + "')";
				var returnObj = $("<a/>", {"text": this.item.LicName, "class": "aLink", "onclick": onClick});
				
				return returnObj[0].outerHTML;
			}},
			{key:'LicModule', label:'<spring:message code="Cache.lbl_includedModule"/>', width:'30', align:'left'},
			{key:'IsOpt', label:'<spring:message code="Cache.lbl_addtionStatus"/>', width:'5', align:'center' }, // 부가여부
			{key:'PortalName', label:'<spring:message code="Cache.lbl_portal"/>', width:'15', align:'center'}, // 포탈
			{key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>', width:'10', align:'center'}, // 등록자
			{key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'10', align:'center', sort:"desc", formatter: function(){ // 수정일
				return CFN_TransLocalTime(this.item.ModifyDate);
			
			}}
		]);
		
		setGridConfig();
		searchGrid();
	}
	
	//그리드 Config 설정
	var setGridConfig = function(){
		var configObj = {
			targetID: "grid",
			height: "auto"
		};
		
		grid.setGridConfig(configObj);
	}
	
	var searchGrid = function(){
		grid.bindGrid({
			ajaxUrl: "/covicore/license/getLicenseManageList.do",
			ajaxPars: {},
			onLoad: function(){
				$("#grid .help_ico").each(function(idx, item){
					openToolTip(this, $(this).text());
				});
			}
		});
	}
	
	var openToolTip = function(thisObj, description){
		var toolTip = $("<div>", {"class": "helppopup", "style": "width: 400px;"})
						.append($("<div>", {"class": "help_p"})
						.append($("<p>", {"class": "helppopup_tit", "text": description})));
		
		$(thisObj).parent().append(toolTip);
		
		// event
		$(thisObj).on("mouseover", function(){
			$(this).toggleClass("active");
		});
		
		$(thisObj).on("mouseout", function(){
			$(this).toggleClass("active");
		});
	}
	
	var openLicenseManagePopup = function(mode, seq){
		var title = mode === "add" ? "<spring:message code='Cache.lbl_licenseRegist'/>" : "<spring:message code='Cache.lbl_licenseModify'/>"; // 라이선스 등록 / 라이선스 수정
		var url =  "/covicore/license/goLicenseManagePopup.do";
			url += "?licSeq=" + seq;
			url += "&mode=" + mode;
		
		Common.open("", "LicManagePopup", title, url, "650px", "380px", "iframe", false, null, null, true);
	}
	
	var deleteLicense = function(){
		var checkedList = grid.getCheckedList(0);
		
		if (checkedList.length <= 0) {
			Common.Warning('<spring:message code="Cache.msg_Common_03"/>'); // 삭제할 항목을 선택하여 주십시오.
			return false;
		} else {
			Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function(result){ // 선택한 항목을 삭제하시겠습니까?
				if(result){
					var licSeq = grid.getCheckedList(0).map(function(item){
						return item.LicSeq;
					}).join(";");
					
					$.ajax({
						type: "POST",
						url: "/covicore/license/deleteLicense.do",
						data: {
							"licSeq": licSeq
						},
						success: function(data){
							if(data.status === 'SUCCESS'){
								Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
								searchGrid();
							}else{
								Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
							}
						},
						error: function(response, status, error){
							CFN_ErrorAjax("/covicore/license/deleteLicense.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	init();
</script>