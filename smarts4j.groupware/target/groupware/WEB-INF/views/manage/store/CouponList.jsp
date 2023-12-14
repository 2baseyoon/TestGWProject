<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_CouponMng' /></h2> <!-- 쿠폰관리 -->
	<div class="searchBox02">
		<span><input id="searchInputSimple" type="text" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}"><button type="button" id="simpleSearchBtn" class="btnSearchType01" onclick="onClickSearchButton(this);"><spring:message code="Cache.btn_search"/></button></span><a href="#" class="btnDetails" onclick="DetailDisplay(this);"><spring:message code="Cache.lbl_apv_detail"/></a>
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 appSearch" id="DetailSearch" >
		<div>
			<div class="selectCalView">
				<spring:message code="Cache.lbl_CompanyName"/> : 
				<input type="text" id="detailSearchKeyword" style="width: 215px;" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}" >
				<a id="detailSearchBtn"  onclick="onClickSearchButton(this)" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent appstoreContent">
		<!-- 상단 버튼 시작 -->
		<div class="sadminMTopCont">
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
				
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
					{key:'CompanyName', label:'<spring:message code="Cache.lbl_CompanyName"/>', width:'150', align:'center', mergeCells : true },//회사명
					{key:'CouponTypeName', label:'<spring:message code="Cache.lbl_CouponTypeName"/>', width:'250', align:'center', sort:false},//쿠폰종류
					{key:'TotCount', label:'<spring:message code="Cache.lbl_CouponCnt"/>', width:'80', align:'center'}, //총 쿠폰
					{key:'UseCount', label:'<spring:message code="Cache.lbl_CouponUseCnt"/>', width:'80', align:'center'}, //사용쿠폰
					{key:'RemainCount', label:'<spring:message code="Cache.lbl_CouponRemainCnt"/>', width:'80', align:'center'}, //잔여쿠폰
	                {key:'AddCoupon', label:'<spring:message code="Cache.lbl_CouponAdd"/>', width:'70', align:'center', sort:false , 
	                	  formatter:function () {
	                		  return "<a class='btnTypeDefault' onclick='addCoupon(\"" + this.item.DomainID + "\", \"" + this.item.CouponType + "\", \"" + this.item.CouponTypeName + "\", \"" + this.item.CompanyName + "\")'><spring:message code='Cache.lbl_CouponAdd'/></a>";
		      		}},//쿠폰추가
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
			mergeCells : [1],
			selectedClearOnPaging : true,
			colHeadTool : false
		};
		
		myGrid.setGridConfig(configObj);
		
		setGridData();
	}
	
	// data bind
	function setGridData(){
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		var selectParams = {
			"search" : isDetail ? $("#detailSearchKeyword").val() : $("#searchInputSimple").val()
		};
		myGrid.bindGrid({
 			ajaxUrl:"/groupware/store/getAdminCouponList.do",
 			ajaxPars: selectParams
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addCoupon(pDomainID, pCouponType, pCouponTypeName, pCompanyName){
		var pModal = true;
		Common.open("","CouponAddPopup","<spring:message code='Cache.lbl_CouponAdd'/> [" + pCouponTypeName + "]","/groupware/store/goCouponAddPopup.do?DomainID=" + pDomainID + "&CouponType=" + pCouponType + "&CouponTypeName=" + encodeURIComponent(pCouponTypeName) + "&CompanyName=" + encodeURIComponent(pCompanyName),"400px","300px","iframe",pModal,null,null,true);
		$(".gridBodyTr").removeClass("selected");
	}
	
	function viewCouponEventList(pDomainID, pCouponType, pCouponTypeName, pCompanyName) {
		var pModal = true;
		Common.open("","CouponEventViewPopup","<spring:message code='Cache.lbl_CouponEventView'/> [" + pCouponTypeName + "]","/groupware/store/goCouponEventListPopup.do?DomainID=" + pDomainID + "&CouponType=" + pCouponType + "&CompanyName=" + encodeURIComponent(pCompanyName), "850px","600px","iframe",pModal,null,null,true);
	}
	
	// 상세검색 열고닫기
	function DetailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			$('#DetailSearch').removeClass("active");
		}else{
			$(pObj).addClass("active");
			$('#DetailSearch').addClass("active");
		}
		$(".contbox").css('top', $(".content").height());
	}
	
	// 검색
	function onClickSearchButton() {
		setGridConfig();
	} 
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
</script>