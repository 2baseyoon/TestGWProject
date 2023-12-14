<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<body>
<form id="form1">
	<div class="sadmin_pop">
		<div id="orgGrid" class="fixLine"></div>
	</div>
</form>
</body>

<script>

	var orgMyGrid = new coviGrid();
	var lang = "${lang}";
	
	window.onload = initContent();

	function initContent(){
		setGrid();
	}
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		
		orgMyGrid.setGridHeader([
							  {key:'GroupCode', label:"<spring:message code='Cache.lbl_RegionCode'/>", width:'70', align:'center', formatter : function(){
								  return "<a href='#' onclick='bindRegion(\""+ this.item.GroupCode +"\", \"" + this.item.LANG_DISPLAYNAME + "\"); return false;'>"+ "<span name='code'>" + this.item.GroupCode + "</span>"+"</a>";
							  }}, //지역(사업장) 코드
			                  {key:'LANG_DISPLAYNAME',  label:"<spring:message code='Cache.lbl_DisplayName'/>", width:'70', align:'center', formatter : function(){
								  return "<a href='#' onclick='bindRegion(\""+ this.item.GroupCode +"\", \"" + this.item.LANG_DISPLAYNAME + "\"); return false;'>"+ "<span name='code'>" + this.item.LANG_DISPLAYNAME + "</span>"+"</a>";
							  }}
				      		]);
		setGridConfig();
		bindGridData();
	}
	
	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "orgGrid",		// grid target 지정
			height:"260px",
			paging : false
		};
		
		// Grid Config 적용
		orgMyGrid.setGridConfig(configObj);
	}	

	function bindGridData() {
		orgMyGrid.page.pageNo = 1;
		orgMyGrid.bindGrid({
			ajaxUrl:"/covicore/manage/conf/selectGroupListByGroupTypeByCode.do",
			ajaxPars: {
				domainCode :  "${domainCode}",
				groupType : 'Region',
				sortBy: orgMyGrid.getSortParam()
			}
		});
	}
		
	function onClickSearchButton(){
		bindGridData();
	}
	
	function bindRegion(regionCode, multiRegionName) {
		if("${functionName}" != null && "${functionName}" != ''){
    		if(parent["${functionName}"] != undefined){
				parent["${functionName}"](regionCode, multiRegionName);
    		}
    	}
		Common.Close();
	}
	
</script>