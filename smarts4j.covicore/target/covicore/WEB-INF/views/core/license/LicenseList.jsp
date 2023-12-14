<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/collaboration/resources/css/collaboration.css<%=resourceVersion%>">

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_licenseList"/></span> <!-- 라이선스 관리 -->
</h3>
<form id="form1">
	<div style="width:100%; min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<select id="isUse" class="AXSelect W80" onchange=searchGrid()>
				<option value=""><spring:message code="Cache.lbl_all"/></option> 	<!-- 전체 -->
				<option value="Y" selected><spring:message code="Cache.approval_inUse"/></option> 	<!-- 사용 중 -->
			</select>
			<input type="text" id="searchtext" class="AXInput"  onkeypress="if (event.keyCode==13){ searchData(); return false;}"/>&nbsp;
			<input type="button" id="btnSearch" class="AXButton" value="<spring:message code='Cache.btn_search'/>"/> <!-- 검색 -->
			<input type="button" class="AXButton BtnExcel" value="<spring:message code="Cache.btn_ExcelDownload"/>" onclick="excelDownload();"/>
		</div>
		<div id="grid"></div>
	</div>
</form>

<script>
	// #sourceURL=LicenseList.jsp
	
	var g_curDate = CFN_GetLocalCurrentDate("yyyyMMdd");
	var grid = new coviGrid();
	var headerData;
	
	var init = function(){
		setEvent();
		setGrid();
	}
	
	var setEvent = function(){
		// 조회
		$("#btnSearch").on("click", function(){
			searchGrid();
		});
	}
	
	//그리드 세팅
	var setGrid = function(){
		headerData = [
		//grid.setGridHeader([
   			{key:'DisplayName', label:'<spring:message code="Cache.ObjectType_DN"/>', width:'150', align:'left'},
			{key:'IsOpt', label:'<spring:message code="Cache.lbl_addtionStatus"/>', width:'50', align:'center', formatter:function(){
				return this.item.IsOpt=="Y"?"Y":"";
			} }, // 부가여부
			{key:'LicName', label:'<spring:message code="Cache.lbl_license"/>', width:'100', align:'center'},
			{key:'ServiceEnd', label:'<spring:message code="Cache.lbl_ServicePeriod"/>', width:'120', align:'center'   ,formatter:function () {return coviCmn.getDateFormat(this.item.ServiceEnd); }}, // 서비스기간
			{key:'ServiceUser', label:'<spring:message code="Cache.lbl_License_UserCnt"/>', width:'50', align:'center' }, // 서비스 사용자
			{key:'ExtraExpiredate', label:'<spring:message code="Cache.lbl_tempDeadline"/>', width:'80', align:'center',formatter:function () {return coviCmn.getDateFormat(this.item.ExtraExpiredate);}}, // ㅂ
			{key:'ExtraServiceUser', label:'<spring:message code="Cache.lbl_tempCnt"/>', width:'50', align:'center' }, // 초과여부
			{key:'LicUsingCnt', label:'<spring:message code="Cache.lbl_License_ActiveUserCnt"/>', width:'50', align:'center' }, // 사용수
			{key:'RemainCnt', label:'<spring:message code="Cache.lbl_n_att_remain"/>', width:'50', align:'center', formatter:function() {
				var leftCnt = (g_curDate>this.item.ExtraExpiredate?this.item.ServiceUser:this.item.ServiceUser+this.item.ExtraServiceUser)-this.item.LicUsingCnt;				
				return leftCnt;
			}}, // 잔여
			{key:'IsOpt', label:'<spring:message code="Cache.lbl_above"/>', width:'50', align:'center' , formatter:function(){
				return ((g_curDate>this.item.ExtraExpiredate?this.item.ServiceUser:this.item.ServiceUser+this.item.ExtraServiceUser)-this.item.LicUsingCnt)<0?"Y":"";
			}} // 초과여부
		//]);
		];
		grid.setGridHeader(headerData);
		setGridConfig();
		searchGrid();
	}
	
	//그리드 Config 설정
	var setGridConfig = function(){
		var configObj = {
			targetID: "grid",
			height: "auto",
			paging: true,
			sort : false,
			mergeCells: [0], // 인덱스 3, 4 셀을 머지하지만 앞의 셀이 머지 되었을 때만 다음셀을 병합합니다.
			body:{
		        addClass: function() {
					var leftCnt = (g_curDate>this.item.ExtraExpiredate?this.item.ServiceUser:this.item.ServiceUser+this.item.ExtraServiceUser)-this.item.LicUsingCnt;				
					if (leftCnt < 0) {
						return "red";
					}
		        }}
		};
		
		grid.setGridConfig(configObj);
		grid.page.pageNo = 1;
	}
	
	var searchGrid = function(){
		grid.bindGrid({
			ajaxUrl: "/covicore/license/getLicenseList.do"
			, ajaxPars: {"selectsearch":$("#searchtext").val(),
	 				"isUse":$("#isUse").val(),}
		});
	}
	
	// 엑셀 다운로드 header.
	var getHeaderNameForExcel = function() {
		var returnStr = "";
		for(var i=0; i<headerData.length; i++) {
			returnStr += headerData[i].label + ";";
		}
		return returnStr;
	}
	var getHeaderTypeForExcel = function() {
		var returnStr = "";
		for(var i=0; i<headerData.length; i++) {
			returnStr += (headerData[i].dataType != undefined ? headerData[i].dataType:"Text") + "|";
		}
		return returnStr;
	}
	var excelDownload = function() {
		if (confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>")) { 	// 엑셀을 저장하시겠습니까?
			
			var headername = getHeaderNameForExcel();
			headername = headername.replace(/ /gi, "");
			var headerType = getHeaderTypeForExcel();	
			var queryString = "?";
			queryString += "selectsearch="+$("#searchtext").val()+"&isUse="+$("#isUse").val();
			queryString += "&headername="+encodeURI(headername)+"&headerType="+encodeURI(headerType);
			
			location.href = "/covicore/license/downloadExcel.do"+queryString;
		}
	}
	
	init();
</script>