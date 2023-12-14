<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<script type="text/javascript" src="/covicore/resources/script/menu/adminorganization.js<%=resourceVersion%>"></script>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_188"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form>
	<div style="width:100%;min-height: 500px">
		<div id="topitembar_1" class="topbar_grid">
			<input type="button" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"class="AXButton BtnRefresh"/>
			<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="viewArbitraryGroupPop('T', '', 'add',''); return false;" class="AXButton BtnAdd" />
			<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="DeleteCheck(orgGrid);"class="AXButton BtnDelete"/>
			<input type="button" value="<spring:message code="Cache.btn_UP"/>" onclick="moveUp(orgGrid);"class="AXButton BtnUp"/>
			<input type="button" value="<spring:message code="Cache.btn_Down"/>" onclick="moveDown(orgGrid);"class="AXButton BtnDown"/>
			<input type="button" value="<spring:message code="Cache.btn_ExcelDownload"/>" onclick="excelDownload('title');"class="AXButton BtnExcel"/> <!-- 엑셀 다운로드 -->
		</div>
		<div class="topbar_grid">
			<span style="display: none;"> <spring:message code="Cache.lbl_Company"/><!-- 회사 -->
				<select id='domainSelectBox' class='AXSelect W100' onchange='onClickSearchButton();'></select>
			</span>
			<span> <spring:message code="Cache.lbl_IsUse"/><!-- 사용여부 -->
				<select name="" class="AXSelect" id="IsUseType" onchange='onClickSearchButton();'>
					<option value="All"><spring:message code='Cache.lbl_all'/></option> <!-- 전체 -->
					<option value="Y">Y</option> <!-- Y -->
					<option value="N">N</option> <!-- N -->
				</select>
			</span>
			<span>  <spring:message code="Cache.lbl_IsHR"/><!-- 인사연동여부 -->
				<select name="" class="AXSelect" id="IsHRType" onchange='onClickSearchButton();'>
					<option value="All"><spring:message code='Cache.lbl_all'/></option> <!-- 전체 -->
					<option value="Y">Y</option> <!-- Y -->
					<option value="N">N</option> <!-- N -->
				</select>
			</span>
			<span><spring:message code="Cache.lbl_IsMail"/><!-- 메일사용여부 -->
				<select name="" class="AXSelect" id="IsMailType" onchange='onClickSearchButton();'>
					<option value="All"><spring:message code='Cache.lbl_all'/></option> <!-- 전체 -->
					<option value="Y">Y</option> <!-- Y -->
					<option value="N">N</option> <!-- N -->
				</select>
			</span>
			<span> <spring:message code="Cache.lbl_SearchCondition"/><!-- 검색 조건 -->
				<select name="" class="AXSelect" id="searchType">
					<option value="DisplayName"><spring:message code='Cache.lbl_DisplayName'/></option> <!-- 표시이름 -->
					<option value="JobTitleCode"><spring:message code='Cache.lbl_JobTitle_Code'/></option> <!-- 직책코드 -->
				</select>
				<input type="text" class="AXInput"	placeholder="<spring:message code='Cache.msg_apv_001' />"	id="searchText" onKeypress="if(event.keyCode==13) {onClickSearchButton(); return false;}"> 
				<input type="button" class="AXButton" onclick="onClickSearchButton();" value="<spring:message code='Cache.lbl_search'/>"> <!-- 검색 -->
			</span>
		</div>
		<!-- Grid -->
		<div id="resultBoxWrap">
			<div id="orgGrid"></div>
		</div>
	</div>
</form>

<script>

	var orgGrid = new coviGrid();
	var isMailDisplay = true;

	//개별호출 일괄처리
	Common.getBaseConfigList(["IsSyncMail"]);
	
	window.onload = initContent();

	function initContent(){
		
		//기초설정에 따른 메일 표기 여부
		if(coviCmn.configMap["IsSyncMail"] == null |  coviCmn.configMap["IsSyncMail"] == 'N'){
			$("#IsMailType").closest('span').css("display","none");
			isMailDisplay = false;
		}
		
		$.ajaxSetup({
			cache : false
		});
		
		bindSelect();
		setGrid(); 
	}
	
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		orgGrid.setGridHeader([
							  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
							  {key:'GroupCode', label:"<spring:message code='Cache.lbl_JobTitleCode'/>", width:'70', align:'center', formatter : function(){
								  return "<a href='#' onclick='viewArbitraryGroupPop(\"T\", \""+ this.item.GroupCode +"\", \"modify\", \""+ this.item.PrimaryMail +"\"); return false;'>"+ "<span name='code'>" + this.item.GroupCode + "</span>"+"</a>";
							  }}, //직책코드
			                  {key:'GroupName',  label:"<spring:message code='Cache.lbl_DisplayName'/>", width:'70', align:'center'}, //표시이름
			                  {key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>", width:'40', align:'center'}, //우선순의
			                  {key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>", width:'70', align:'center', formatter : function() { //사용여부
			                	    var str =  '<input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" style="width:50px;height:20px;border:0px none;" id="AXInputSwitch_IsUse_';
			                  	    str += this.item.GroupCode;
			                  	    str += '"  onchange="changeSetting(\'IsUse\', \'' + this.item.GroupCode +  '\', \''+this.item.GroupType + '\', orgGrid);" value="' +  this.item.IsUse + '"/>';
			                		return  str;
			                  }},
			                  {key:'IsHR', label:"<spring:message code='Cache.lbl_IsHR'/>", width:'70', align:'center', formatter : function() { //인사연동여부
			                	    var str =  '<input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" style="width:50px;height:20px;border:0px none;"  id="AXInputSwitch_IsHR_';
			                  	    str += this.item.GroupCode;
			                  	    str += '"  onchange="changeSetting(\'IsHR\', \'' + this.item.GroupCode +  '\', \''+this.item.GroupType + '\', orgGrid);" value="' +  this.item.IsHR + '"/>';
			                		return  str;
			                  }},
			                  {key:'IsMail', label:"<spring:message code='Cache.lbl_IsMail'/>", width:'70', align:'center', display: isMailDisplay, formatter : function() { //메일사용여부
			                	    var str =  '<input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" style="width:50px;height:20px;border:0px none;" id="AXInputSwitch_IsMail_';
			                  	    str += this.item.GroupCode;
			                  	    str += '"  onchange="changeSetting(\'IsMail\', \'' + this.item.GroupCode +  '\', \''+this.item.GroupType + '\', orgGrid);" value="' +  this.item.IsMail + '"/>';
			                		return  str;
			                  }},
			                  {key:'PrimaryMail',  label:"<spring:message code='Cache.lbl_Mail'/>", width:'70', align:'center'}, //메일
			                  {key:'Description',  label:"<spring:message code='Cache.lbl_Description'/>", width:'70', align:'center'} //설명
				      		]);
		setGridConfig();
		bindGridData();
	}
	
	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "orgGrid",
			height:"auto",
			xscroll:true,
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		// Grid Config 적용
		orgGrid.setGridConfig(configObj);
	}	

	function bindGridData() {
		var IsUseType = $("#IsUseType").val();
		var IsHRType = $("#IsHRType").val();
		var IsMailType = $("#IsMailType").val();
		var searchText = $("#searchText").val();
		var searchType = $("#searchType").val();
		var ty = "one";
		
		orgGrid.page.pageNo = 1;

		orgGrid.bindGrid({
			ajaxUrl:"/covicore/admin/orgmanage/getarbitrarygrouplist.do",
			ajaxPars: {
				domain : $("#domainCodeSelectBox :selected").val(),
				grouptype : "title",
				IsUse : IsUseType,
				IsHR : IsHRType,
				IsMail : IsMailType,
				searchText : searchText,
				searchType : searchType,
				sortBy: orgGrid.getSortParam(ty)
			}
		});
	}
		
	function onClickSearchButton(){
		bindGridData();
	}
	
	
	function viewArbitraryGroupPop(pType, pCode, pMode, mail){
		if(pMode == 'add'){
			var title = "<spring:message code='Cache.lbl_JobTitleAdd'/>";
		} else{
			var title = "<spring:message code='Cache.lbl_JobTitleEdit'/>";
		}
		Common.open("", "ViewArbitraryGroup", title, "/covicore/arbitarygroupinfopop.do?type=" + encodeURIComponent(pType) + "&code=" + encodeURIComponent(pCode) + "&mode=" + encodeURIComponent(pMode) + "&dncode=" + encodeURIComponent($("#domainCodeSelectBox :selected").val()) + "&mail=" + mail, "530px", "480px", "iframe", true, null, null, true);
		return;
	}
	
	//엑셀 - Grid Header 항목 시작
	function getGridHeader( pHeaderType ){
		var headerData = [
			                  {key:'GroupCode',  label:'<spring:message code="Cache.lbl_JobTitleCode"/>', width:'100', align:'center'},
			                  {key:'GroupName',  label:'<spring:message code="Cache.lbl_DisplayName"/>', width:'100', align:'center'},
			                  {key:'SortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'70', align:'center'},
			                  {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'80', align:'center'},
			                  {key:'IsHR', label:'<spring:message code="Cache.lbl_IsHR"/>',   width:'70', align:'center'},
				      		  {key:'PrimaryMail', label:'<spring:message code="Cache.lbl_Mail"/>', width:'80', align:'center'},
				      		  {key:'Description',  label:'<spring:message code="Cache.lbl_Description"/>', width:'70', align:'center'}
		               ];
		return headerData;
	}
	
</script>