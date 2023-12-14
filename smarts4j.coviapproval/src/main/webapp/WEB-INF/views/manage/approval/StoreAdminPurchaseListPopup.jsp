<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="divpop_contents">
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<!-- 그리드 컨트롤 사용 영역입니다. -->
		<div id="divGridView" class="tblList tblCont">
			<div id="storeFormsListGrid" class="tblList"></div>									
		</div>
	</div>
</div>
<script type="text/javascript">
	var paramStoredFormID = "${param.id}"; 
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	var headerData; // global , for Excel download.
	setSchemaGridData(paramStoredFormID);
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		headerData =[
		                  {key:'ROWNUM', label:'No', width:'50', align:'center'}, //No
		                  {key:'CompanyName', label:'<spring:message code="Cache.lbl_CustomerName"/>',   width:'120'}, //고객사명
			      		  {key:'PurchaseUserName', label:'<spring:message code="Cache.lbl_PurchaseUserName"/>',   width:'100', align:'center'},//구매담당자
		                  {key:'RevisionNo', label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE06"/>',   width:'50', align:'center'},//버전
			      		  {key:'IsFree', label:'<spring:message code="Cache.lbl_apv_gubun"/>',   width:'50', align:'center',
			      			formatter:function () {
		                		  return this.item.IsFree == 'Y' ? '<spring:message code="Cache.lbl_price_free"/>' : '<spring:message code="Cache.lbl_price_charged"/>';
			      			  }},//구분
			              {key:'PurchaseDate', label:'<spring:message code="Cache.lbl_PurchaseDate"/>',   width:'120', align:'center',
			      			formatter:function () {
								return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.PurchaseDate);
		                	}}//구매일자
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "storeFormsListGrid", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// data bind
	function setSchemaGridData(params){
		var param = {
				StoredFormID : params
		};
		
		setGrid();
		myGrid.bindGrid({
 			ajaxUrl:"/approval/manage/StoreAdminPurchaseListData.do",
 			ajaxPars:param
		});
	}
</script>