<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="account_vendor_page">	
	<header data-role="header" id="account_vendor_header">
		<div class="sub_header">
			<div class="l_header">
				<a onclick="javascript: mobile_account_popupClose('Vendor');" class="btn_close"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link">
					<a id="account_vendor_title" class="pg_tit"><spring:message code='Cache.lbl_selectVendor'/></a>
				</div>
			</div>
			<div class="utill">
				<a onclick="javascript: mobile_comm_opensearch();" id="account_vendor_search" class="btn_search"><span></span></a>
				<a onclick="javascript: mobile_account_selectVendor();" class="btn_txt"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
		<div class="ly_search" id="account_vendor_div_search">
			<a onclick="javascript: mobile_comm_closesearch();" class="btn_back"><span><!-- 닫기 --></span></a>
			<input type="text" id="account_vendor_search_input" name="" value="" placeholder="거래처명, 사업자번호로 검색" onkeypress="if (event.keyCode==13){ mobile_account_clickSearchVendor(); return false;}"> <!-- 거래처명, 사업자번호로 검색 -->
			<a onclick="javascript: mobile_account_cleansearch('account_vendor_search_input')" class="del"></a>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="account_vendor_content">
 		<div class="receipt_list"> <!-- TODO: vendor_list class 추가 필요 -->
			<!-- 거래처 목록 영역 -->
			<ul id="account_vendor_list"></ul>
			
			<div id="account_vendor_more" class="btn_list_more" style="display: none;">
				<a onclick="javascript: mobile_account_nextlist('vendor');"><span><spring:message code='Cache.lbl_MoreView'/></span></a><!-- 더보기 -->
			</div>
		</div>
	</div>

</div>

