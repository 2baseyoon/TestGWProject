<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="account_prcard_page">	
	<header data-role="header" id="account_prcard_header">
		<div class="sub_header">
			<div class="l_header">
				<a onclick="javascript: mobile_account_popupClose('PRCard');" class="btn_close"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link">
					<a id="account_write_title" class="pg_tit"><spring:message code='Cache.ACC_lbl_privateCardSelect'/></a> <!-- 개인카드 선택 -->
				</div>
			</div>
			<div class="utill">
				<a onclick="javascript: mobile_account_selectPrivateCard();" class="btn_txt"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="account_prcard_content">
 		<div class="receipt_list"> <!-- TODO: prcard_list class 추가 필요 -->
			<!-- 법인카드 사용내역 목록 영역 -->
			<ul id="account_prcard_list"></ul>
			
			<div id="account_prcard_more" class="btn_list_more" style="display: none;">
				<a onclick="javascript: mobile_account_nextlist('prcard');"><span><spring:message code='Cache.lbl_MoreView'/></span></a><!-- 더보기 -->
			</div>
		</div>
	</div>

</div>

