<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%
	String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.tte_DomainManage"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input id="refreshBtn"  type="button"  class="AXButton BtnRefresh" value="<spring:message code="Cache.btn_Refresh"/>" onclick="refreshGrid();" name="refresh"/>
			<input id="addBtn" type="button"  class="AXButton BtnAdd" value="<spring:message code="Cache.btn_Add"/>"  onclick="addDomain(false);" name="add"/>
			<select id="isUse" class="AXSelect W80" onchange=searchGrid()>
				<option value=""><spring:message code="Cache.lbl_all"/></option> 	<!-- 전체 -->
				<option value="Y" selected><spring:message code="Cache.approval_inUse"/></option> 	<!-- 사용 중 -->
			</select>
			<input type="text" id="searchtext" class="AXInput"  onkeypress="if (event.keyCode==13){ searchGrid(); return false;}"/>&nbsp;
			<input type="button" id="btnSearch" class="AXButton" value="<spring:message code='Cache.btn_search'/>"/> <!-- 검색 -->
			<input type="button" class="AXButton BtnExcel" value="<spring:message code="Cache.btn_ExcelDownload"/>" onclick="excelDownload();"/>
		</div>
		<div id="grid"></div>
	</div>
</form>
<script type="text/javascript">
	//# sourceURL=DomainManage.jsp
	
	var g_curDate = CFN_GetLocalCurrentDate("yyyyMMdd");
	var grid = new coviGrid();
	var headerData;
	
	var init = function() {
		setEvent();
		setGrid();
	}
	
	var setEvent = function() {
		$("#btnSearch").on("click", function(){
			searchGrid();
		});
	}
	
	var setGrid = function() {
		let isSaaS = "<%=isSaaS%>";
		
		if (isSaaS === "Y") {
			headerData = [
				{key:'DisplayName', label:'<spring:message code="Cache.ObjectType_DN"/> / <spring:message code="Cache.lbl_DN_Code"/> ', width:'150', align:'left', formatter: function() {
					return "<a href='#' onclick='updateDomain(false, \""+ this.item.DomainId +"\"); return false;'>"+ this.item.DisplayName + " / " + this.item.DomainCode +"</a>";
	 			}},
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
			];
		} else {
			headerData = [
				{key:'DisplayName', label:'<spring:message code="Cache.ObjectType_DN"/> / <spring:message code="Cache.lbl_DN_Code"/> ', width:'150', align:'left'
					, formatter: function() {
						return "<a href='#' onclick='updateDomain(false, \""+ this.item.DomainID +"\"); return false;'>"+ this.item.DisplayName + " / " + this.item.DomainCode +"</a>";
	 				}
				},
	 			{key:'DomainID', label:'<spring:message code="Cache.lbl_Domain"/> ID', width:'50', align:'center' },
	 			{key:'SortKey', label:'<spring:message code="Cache.lbl_SortOrder"/>', width:'50', align:'center' }, 	// 정렬순서
	 			{key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'30', align:'center' }, // 사용여부
	 			{key:'ServicePeriod', label:'<spring:message code="Cache.lbl_ServicePeriod"/>', width:'120', align:'center' }, // 서비스기간
	 			{key:'RegistDate', label:'<spring:message code="Cache.lbl_RegDate"/>', width:'70', align:'center' } // 등록일
			];
		}
		
		grid.setGridHeader(headerData);
		setGridConfig();
		searchGrid();
	}
	
	var setGridConfig = function() {
		var configObj = {
			targetID: "grid",
			height: "auto",
			paging: true,
			sort : false,
			mergeCells: [0], // 인덱스 3, 4 셀을 머지하지만 앞의 셀이 머지 되었을 때만 다음셀을 병합합니다.
			body: {
				addClass: function() {
					var leftCnt = (g_curDate>this.item.ExtraExpiredate?this.item.ServiceUser:this.item.ServiceUser+this.item.ExtraServiceUser)-this.item.LicUsingCnt;				
					if (leftCnt < 0) {
						return "red";
					}
		        }
			}
		};
		grid.setGridConfig(configObj);
		grid.page.pageNo = 1;
	}

	var searchGrid = function() {
		let isSaaS = "<%=isSaaS%>";
		let strUrl = "/covicore/domain/getList.do";
		
		if ("Y" === isSaaS) {
			strUrl = "/covicore/license/getLicenseList.do";
		}
		
		grid.bindGrid({
			ajaxUrl: strUrl
			, ajaxPars: {"selectsearch":$("#searchtext").val(),"isUse":$("#isUse").val()}
			, onload : setGridSelectClear()
		});
	}
	
	// rowspan을 사용하는 셀을 선택 후 페이지 이동을 반복하면 테이블 디자인에 오류 발생. 선택 해제를 페이징 이벤트와 연결.
	var setGridSelectClear = function() {
		$("#grid .AXgridPageBody").click(function() { grid.selectClear() });
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
	
	var addDomain = function(pModal) {
		parent.Common.open("","setDomain","<spring:message code='Cache.lbl_DomainLayerPopupTitle_Add'/>","/covicore/domain/goDomainPopup.do?mode=add","1250px","430px","iframe",pModal,null,null,true);
	}

	var updateDomain = function(pModal, configkey) {
		parent.Common.open("","setDomain","<spring:message code='Cache.lbl_DomainLayerPopupTitle_Modify'/>","/covicore/domain/goDomainPopup.do?mode=modify&domainID="+configkey,"1250px","430px","iframe",pModal,null,null,true);
	}
	
	var refreshGrid = function() {
		grid.reloadList();
	}
	
	init();

</script>
