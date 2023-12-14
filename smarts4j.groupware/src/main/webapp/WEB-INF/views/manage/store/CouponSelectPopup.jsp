<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="sadmin_pop sadminContent">
	<div class="sadminMTopCont">
		<div class="pagingType02 buttonStyleBoxLeft">
		</div>
		<div class="buttonStyleBoxRight">
			<select id="selectPageSize" class="selectType02 listCount" style="display:none;">
				<option>10</option>
				<option>20</option>
				<option>30</option>
			</select>
			<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
		</div>
	</div>
	<div id="couponSelectListGrid" class="tblList tblCont"></div>
	<div class="bottomBtnWrap">
		<a class="btnTypeDefault btnTypeBg" id="btnPurchaseForm" onClick="setSelectCoupon();"><spring:message code="Cache.btn_Apply"/></a> <!-- 적용 -->
		<a href="javascript:closeLayer()" class="btnTypeDefault"><spring:message code="Cache.btn_att_close"/></a><!-- 닫기 -->
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
					{key:'chk', label:'<spring:message code="Cache.btn_Select"/>', width:'50', align:'center', formatter:function(){
						return "<span class='radioStyle10' style='margin-top:5px;'><input type='radio' CouponName='" + this.item.IssueTypeName + "' value='" + this.item.CouponID + "' id='chk_" + this.item.CouponID + "' name='Coupon_chk' /><label for='chk_" + this.item.CouponID + "'><span class='s_radio'></span></label></span>";
					}},//일시
					{key:'IssueTypeName', label:'<spring:message code="Cache.lbl_Gubun"/>', width:'180', align:'center'},//구분
					{key:'ExpireDate', label:'<spring:message code="Cache.lbl_CouponExpireDate"/>', width:'100', align:'center', sort:"asc", formatter : function() {
						if(this.item.ExpireDate != '' && this.item.ExpireDate.length == 8) {
							return this.item.ExpireDate.substring(0,4) + "-" + this.item.ExpireDate.substring(4,6) + "-" + this.item.ExpireDate.substring(6,8);
						}
						return this.item.ExpireDate;
					}}
			];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "couponSelectListGrid", 
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
			"CouponType" : "${param.CouponType}" // 결재양식,컨텐츠앱,포탈 등.
		};
		myGrid.bindGrid({
 			ajaxUrl:"/groupware/store/getCouponSelectList.do",
 			ajaxPars: selectParams
		});
	}
	
	function setSelectCoupon() {
		var checkedItem = $("input[name=Coupon_chk]:checked");
		var pCouponID = "";
		var pCouponName = "";
		
		if($(checkedItem).length > 0){
			pCouponID = checkedItem.val();
			pCouponName = checkedItem.attr("CouponName");
		}else{
			alert("<spring:message code='Cache.msg_apv_003'/>");
			return;
		}
		
		var pWin = parent.CallBack_window;
		pWin.callbackCouponSelect({"CouponID" : pCouponID, "CouponName":pCouponName});
		closeLayer();
	}
	
	function closeLayer() {
		Common.Close();
	}
	
	// 새로고침
	function Refresh(){
		setGridData();
	}
</script>