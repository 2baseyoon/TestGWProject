<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="account_costcenter_page">	
	<header class="header" id="account_costcenter_header">
		<div class="sub_header">
			<div class="l_header">
				<a onclick="javascript: mobile_comm_back();" class="topH_close"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link">
					<a id="account_costcenter_title" class="topH_tit"><spring:message code='Cache.lbl_selectCostCenter'/></a>
				</div>
			</div>
			<div class="utill">
				<a id="account_costcenter_search" href="javascript: javascript: mobile_comm_opensearch();" class="topH_search"><span class="Hicon"></span></a>
				<a onclick="javascript: mobile_account_selectCostCenter();" class="topH_save"><span class="Hicon"><spring:message code='Cache.btn_Confirm'/></span></a>
			</div>
		</div>
		<div class="ly_search" id="account_costcenter_div_search">
			<a onclick="javascript: mobile_comm_closesearch();" class="topH_back"><span><!-- 닫기 --></span></a>
			<input type="text" id="account_costcenter_search_input" name="" value="" placeholder="<spring:message code='Cache.ACC_Search_CostCenterCode'/>" onkeypress="if (event.keyCode==13){ mobile_account_clickSearchCostCenter(); return false;}"> <!-- 거래처명, 사업자번호로 검색 -->
			<a onclick="javascript: mobile_account_cleansearch('account_costcenter_search_input')" class="topH_del"></a>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="account_costcenter_content">
 		<div class="receipt_list">
			<!-- 코스트센터 목록 영역 -->
			<ul id="account_costcenter_list"></ul>
			
			<div id="account_costcenter_more" class="btn_list_more" style="display: none;">
				<a onclick="javascript: mobile_account_nextlist('costcenter');"><span><spring:message code='Cache.lbl_MoreView'/></span></a><!-- 더보기 -->
			</div>
		</div>
	</div>

</div>

