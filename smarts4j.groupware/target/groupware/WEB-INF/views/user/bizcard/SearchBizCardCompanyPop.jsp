<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<style>
	#divTabTray  a {
		min-width: 1px;
	}
	
	#selSearchType {
		min-width: 120px;
	}
	
	.toRight {
		float: right;
	}
	
	.btn_group{
		margin-bottom: 10px;
	}
	
	.bodyTdText, .colHeadTdText {
		font-size: 13px;
	}
	</style>
</head>
<div>

	<!-- 상단 필터 및 메뉴 -->
	<div class="btn_group">
		<span style="padding-left: 10px;"> 
			<select name="" class="AXSelect" id="searchType">
				<option value="ComName"><spring:message code='Cache.lbl_BusinessName' /></option> <!-- 업체명 -->
				<option value="PhoneNum"><spring:message code='Cache.lbl_Phone' /></option> <!-- 전화 -->
				<option value="EMAIL"><spring:message code='Cache.lbl_Email2' /></option> <!-- 이메일 -->
			</select>
			<input type="text" class="W200"	placeholder="<spring:message code='Cache.msg_apv_001' />" id="searchInput"> <!-- 검색어를 입력하십시오. -->
			<input type="button" class="searchImgGry" onclick="onClickSearchButton(this);" value="<spring:message code='Cache.lbl_search' />"> <!-- 검색 -->
			<input type="button" class="AXButton" id="btnRegistCompany" onclick="RegistCompany(this);" value="<spring:message code='Cache.btn_CompanyCreation' />"> <!-- 업체등록 -->
		</span>
	</div>

	<!-- Grid -->
	<div id="resultBoxWrap">
		<div id="bizCardGrid"></div>
	</div>
	
	<div>
		<div style="margin-top : 10px;" align="center">
			<button type="button" class="AXButton" onclick="closeBizCard();"><spring:message code='Cache.btn_Close' /></button> <!-- 닫기 -->
		</div>
	</div>
</div>

<script>
	$(function() {		
		setGrid();
	});

	var bizCardGrid = new coviGrid();
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		//myGrid.setGridHeader(headerData);
		bizCardGrid.setGridHeader([
			                  {key:'ComName',  label:"<spring:message code='Cache.lbl_CompanyName'/>", width:'70', align:'center', 
			                	  formatter:function () {
				      					return "<a href='#' onclick='bindCompanyInfo(\""+ this.item.BizCardID +"\", \"" + this.item.ComName + "\"); return false;'>"+this.item.ComName+"</a>";
				      				}},
			                  {key:'ComRepName',  label:"<spring:message code='Cache.lbl_RepName'/>", width:'50', align:'center'},
			                  {key:'EMAIL', label:"<spring:message code='Cache.lbl_Email2'/>", width:'70', align:'center', formatter : function() {
			                		var EMAIL = this.item.EMAIL;
			                		if(EMAIL.indexOf(";") > 0)
			                			EMAIL = EMAIL.substr(0,EMAIL.indexOf(";"));
			                		return EMAIL;
			                  }},
			                  {key:'PhoneNum',  label:"<spring:message code='Cache.lbl_Phone'/>", width:'70', align:'center', formatter : function() {
			                		var PhoneNum = this.item.PhoneNum;
			                		
			                		if(PhoneNum.indexOf(";") > -1)
			                			PhoneNum = PhoneNum.substr(0,PhoneNum.indexOf(";"));
			                		return PhoneNum;
			                  }},
			                  {key:'ComAddress', label:"<spring:message code='Cache.lbl_HomeAddress'/>", width:'100', align:'center', formatter : function() {
			                		var ComAddress = this.item.ComAddress;

			                		if(ComAddress.length > 25)
			                			ComAddress = ComAddress.substr(0,25) + "...";;
			                		return ComAddress;
			                  }}
				      		]);
		setGridConfig();
		bindGridData();
	}

	function bindGridData() {	
		var type = $("#selType").val();
		var tabFilter = $('#divTabTray').find(".on").attr('value');
		var searchInput = $("#searchInput").val();
		var searchType = $("#searchType").val();
		
		bizCardGrid.bindGrid({
			ajaxUrl:"getBizCardCompanyList.do",
			ajaxPars: {
				type : type,
				tabFilter : tabFilter,
				searchWord : searchInput,
				searchType: searchType,
				startDate : '',
				endDate : ''
			},
			onLoad:function () {
				bizCardGrid.fnMakeNavi("bizCardGrid");
			}
		});
	}
	
	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "bizCardGrid",		// grid target 지정
			sort : true,		// 정렬
			colHeadTool : false,	// 컬럼 툴박스 사용여부
			fitToWidth : true,		// 자동 너비 조정 사용여부
			colHeadAlign : 'center',
			height:"auto",
			
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		// Grid Config 적용
		bizCardGrid.setGridConfig(configObj);
	}	
	
	function onClickSearchButton(pObj){
		if($(pObj).attr("class") == "searchImgGry"){
			if($("#seSearchID").attr("value") !="" && $("#searchInput").val() ==""){
				Common.Warning("<spring:message code='Cache.msg_EnterSearchword'/>");							//검색어를 입력하세요
				$("#searchInput").focus();
				return false;
			}
		}
		bindGridData();
	}
	
	function RegistCompany(obj) {
		parent.Common.open("", "GoToRegistBizCardCompany", "<spring:message code='Cache.lbl_bizcard_registCompany'/>", "/groupware/bizcard/GoToRegistBizCardCompany.do", "1000px", "500px", "iframe", true, null, null, true);	

		return;
	}
	
	function bindCompanyInfo(id, name) {
		$("#txtCompanyID", parent.document).val(id);
		$("#txtCompanyName_p", parent.document).val(name);
		Common.Close();
	}
	function closeBizCard() {
		Common.Close();
	}
	
</script>