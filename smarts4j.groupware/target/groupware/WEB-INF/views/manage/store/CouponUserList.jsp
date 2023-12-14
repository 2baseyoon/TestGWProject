<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_CouponMng' /></h2> <!-- 쿠폰관리 -->
</div>
<div class="cRContBottom mScrollVH">
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent appstoreContent">
		<!-- 상단 버튼 시작 -->
		<div class="sadminMTopCont">
			<div class="buttonStyleBoxRight">
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div id="couponListGrid" class="tblList"></div>
	</div>
</div>	
<script type="text/javascript">
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	
	initList();

	function initList(){
		setGrid();			// 그리드 세팅
		$("#selectPageSize").change(function(){
			setGridConfig();
		});
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[
					{key:'showInfo', label: '' , width: '0', align: 'center'},//병합셀이 처음오는것을 방지.
					{key:'CompanyName', label:'<spring:message code="Cache.lbl_CompanyName"/>', width:'150', align:'center'},//회사명
					{key:'CouponTypeName', label:'<spring:message code="Cache.lbl_CouponTypeName"/>', width:'250', align:'center', sort:false},//쿠폰종류
					{key:'TotCount', label:'<spring:message code="Cache.lbl_CouponCnt"/>', width:'80', align:'center'}, //총 쿠폰
					{key:'UseCount', label:'<spring:message code="Cache.lbl_CouponUseCnt"/>', width:'80', align:'center'}, //사용쿠폰
					{key:'RemainCount', label:'<spring:message code="Cache.lbl_CouponRemainCnt"/>', width:'80', align:'center'}, //잔여쿠폰
	                {key:'EventView', label:'<spring:message code="Cache.lbl_CouponEventView"/>', width:'70', align:'center', sort:false , 
	                	  formatter:function () {
	                		  return "<a class='btnTypeDefault' onclick='viewCouponEventList(\"" + this.item.DomainID + "\", \"" + this.item.CouponType + "\", \"" + this.item.CouponTypeName + "\", \"" + this.item.CompanyName + "\")'><spring:message code='Cache.lbl_CouponEventView'/></a>";
		      		}}//사용내역
			];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "couponListGrid", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			mergeCells : [1], // 회사명 Merge cell
			selectedClearOnPaging : true,
			colHeadTool : false
		};
		
		myGrid.setGridConfig(configObj);
		
		setGridData();
	}
	
	// data bind
	function setGridData(){
		var selectParams = {};
		myGrid.bindGrid({
 			ajaxUrl:"/groupware/store/getDomainCouponList.do",
 			ajaxPars: selectParams
		});
	}
	
	function viewCouponEventList(pDomainID, pCouponType, pCouponTypeName, pCompanyName) {
		var pModal = false;
		parent.Common.open("","CouponEventViewPopup","<spring:message code='Cache.lbl_CouponEventView'/> [" + pCouponTypeName + "]","/groupware/store/goCouponEventListPopup.do?DomainID=" + pDomainID + "&CouponType=" + pCouponType + "&CompanyName=" + encodeURIComponent(pCompanyName), "850px","600px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
</script>