<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="sadmin_pop sadminContent">
	<div class="sadminMTopCont">
		<div class="pagingType02 buttonStyleBoxLeft">
			<p class="sadmin_txt" style="margin:15px 0 0 0;"><spring:message code='Cache.lbl_CorpName' /> : ${param.CompanyName}</p>
		</div>
		<div class="buttonStyleBoxRight">
			<select id="selectPageSize" class="selectType02 listCount">
				<option>10</option>
				<option>20</option>
				<option>30</option>
			</select>
			<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
		</div>
	</div>
	<div id="couponEvnetListGrid" class="tblList tblCont"></div>
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
					{key:'EventDate', label:'<spring:message code="Cache.lbl_CouponEventDate"/>'+Common.getSession("UR_TimeZoneDisplay"), width:'140', align:'center', sort:"desc", formatter:function(){
						return CFN_TransLocalTime(this.item.EventDate);
					}},//일시
					{key:'EventUser', label:'<spring:message code="Cache.lbl_User"/>', width:'100', align:'center'},//작업자
					{key:'EventTypeName', label:'<spring:message code="Cache.lbl_Gubun"/>', width:'80', align:'center'},//구분
					{key:'Memo', label:'<spring:message code="Cache.lbl_Contents"/>', width:'250', align:'left'}, //Memo
					{key:'ExpireDate', label:'<spring:message code="Cache.lbl_CouponExpireDate"/>', width:'80', align:'center', formatter : function() {
						if(this.item.ExpireDate != null && this.item.ExpireDate != '' && this.item.ExpireDate.length == 8) {
							return this.item.ExpireDate.substring(0,4) + "-" + this.item.ExpireDate.substring(4,6) + "-" + this.item.ExpireDate.substring(6,8);
						}
						return this.item.ExpireDate;
					}}
					,{key:'CouponQty', label:'<spring:message code="Cache.lbl_CouponIssueCnt"/>', width:'80', align:'center' } //개수
			];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "couponEvnetListGrid", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
		
		setGridData();
	}
	
	// data bind
	function setGridData(){
		var selectParams = {
			"DomainID" : "${param.DomainID}",
			"CouponType" : "${param.CouponType}"
		};
		myGrid.bindGrid({
 			ajaxUrl:"/groupware/store/getAdminCouponEventList.do",
 			ajaxPars: selectParams
		});
	}
	
	// 새로고침
	function Refresh(){
		setGridData();
	}
</script>