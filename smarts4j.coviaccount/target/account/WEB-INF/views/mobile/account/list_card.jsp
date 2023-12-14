<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="account_list_card_page">	
	<header class="header" id="account_list_card_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('account_list_card_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="account_list_card_title" class="topH_tit"><spring:message code='Cache.ACC_lbl_corpCardUseList'/></span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle approval"><spring:message code='Cache.ACC_lbl_corpCardUseList'/></span>
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('account_list_card_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i>닫기</i></button>
							</span>
						</div>
						<div class="tree_default" id="account_list_card_topmenu"></div>
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('account_list_card_topmenu',true);return false;" style="display: none;"></div>
				</div>
			</div>                	
			<div class="utill">			  
			  <a href="javascript: mobile_account_clickrefresh('C');" class="topH_reload"><span class="Hicon">새로고침</span></a>			  
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="account_list_card_content">
		<div class="btn_eaccounting_wrap">
			<a id="account_list_card_application" class="btn_eaccounting" onclick="javascript:mobile_account_clickbtn(this);"><span><spring:message code='Cache.btn_CostApplication'/></span></a> <!-- 비용신청 -->
			<a id="account_list_card_application_del" class="btn_eaccounting_del" onclick="javascript:mobile_account_clickbtn(this);"><span><spring:message code='Cache.ACC_lbl_exceptApplication'/></span></a> <!-- 신청제외 -->
		</div>
 		<div class="card_list">
			<!-- 법인카드 사용내역 목록 영역 -->
			<ul id="account_list_card_list"></ul>
			
			<div id="account_list_card_more" class="btn_list_more" style="display: none;">
				<a onclick="javascript: mobile_account_nextlist('card');"><span><spring:message code='Cache.lbl_MoreView'/></span></a><!-- 더보기 -->
			</div>
		</div>
	</div>
	
	<div class="mobile_popup_wrap" id="account_list_card_popup" style="display:none;">
    	<div class="card_list_popup">
			<div class="card_list_popup_cont">
				<p class="card_list_title"><spring:message code='Cache.ACC_msg_selectExpenceType'/></p>
				<div class="card_list_radio_wrap" id="account_list_card_radio_div" style="height: 160px; overflow-y: scroll; margin-bottom: 13px;">
				</div>
			</div>
			<div class="mobile_popup_btn">
				<a onclick="javascript:mobile_account_clickbtn(this);" class="g_btn03" id="account_list_card_popup_ok"><spring:message code='Cache.btn_Confirm'/></a>
				<a onclick="javascript:mobile_account_clickbtn(this);" class="g_btn04" id="account_list_card_popup_cancel"><spring:message code='Cache.lbl_Cancel'/></a>
			</div>
		</div>
    </div>
    
    <div class="mobile_popup_wrap" id="account_list_card_proof" style="display: none;">
    	<div class="card_list_bill_popup">
			<div class="eaccounting_bill">
				<p class="card_number">
					<span id="account_list_card_proof_CardNo"></span>
				</p>
				<div class="card_info01_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_confirmNum'/></dt>
						<dd id="account_list_card_proof_ApproveNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_TransactionDate'/></dt>
						<dd id="account_list_card_proof_UseDate"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_payMethod'/></dt>
						<dd id="account_list_card_proof_PayMethod"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_franchiseCorpName'/></dt>
						<dd id="account_list_card_proof_StoreName"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_franchiseCorpNo'/></dt>
						<dd id="account_list_card_proof_StoreNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_RepresentativeName'/></dt>
						<dd id="account_list_card_proof_StoreRepresentative"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_bizRegNo'/></dt>
						<dd id="account_list_card_proof_StoreRegNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_PhoneNum'/></dt>
						<dd id="account_list_card_proof_StoreTel"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_Address'/></dt>
						<dd id="account_list_card_proof_StoreAddress"></dd>
					</dl>
				</div>
				<div class="card_info02_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_amt'/></dt>
						<dd id="account_list_card_proof_RepAmount"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_taxType'/></dt>
						<dd id="account_list_card_proof_TaxAmount"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_serviceAmt'/></dt>
						<dd id="account_list_card_proof_ServiceAmount"></dd>
					</dl>
				</div>
				<div class="card_info03_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.lblSum'/></dt>
						<dd id="account_list_card_proof_AmountWon_InfoIndex"></dd>
					</dl>
				</div>
			</div>
			<div class="mobile_popup_btn">
				<a id="account_list_card_proof_ok" onclick="javascript: mobile_account_clickbtn(this)" class="g_btn03"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
    </div>

	<div class="bg_dim" style="display: none;"></div>

</div>

