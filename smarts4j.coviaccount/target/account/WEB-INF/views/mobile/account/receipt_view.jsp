<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<div data-role="page" id="account_receipt_view_page">
	<header class="header" id="account_receipt_view_header">
		<div class="sub_header">
			<div class="l_header">
	        	<a href="javascript: mobile_comm_back();" class="topH_close"><span></span></a>
	            <div class="menu_link gnb">
	            	<span class="topH_tit"><spring:message code='Cache.ACC_lbl_expenceApplicationDetail'/></span>
	            </div>
			</div>
			<div class="utill">
		  		<%-- <a href="#" class="topH_reload"><span class="Hicon"><spring:message code='Cache.btn_apv_refresh'/></span></a> --%>
			</div>
		</div>
	</header>
	
	<div data-role="content" class="cont_wrap">
		<!-- 법인카드 -->
		<div class="nea_card_detail_wrap" id="account_receipt_view_cardproof" style="display: none;">
			<div class="nea_card_detail">
				<div class="nea_card_detail_top">
					<p class="detail_top_tit" id="account_receipt_view_card_storeName"></p>
					<p class="detail_top_date" id="account_receipt_view_card_useDateTime"></p>
					<p class="detail_top"><span class="detail_top_p" id="account_receipt_view_card_amountWon"></span><spring:message code='Cache.ACC_lbl_won'/></p>
				</div>
				<div class="nea_card_detail_mid">
					<dl class="detail_mid_dl"><dt><spring:message code='Cache.ACC_lbl_confirmNum'/></dt><dd id="account_receipt_view_card_approveNo"></dd></dl>
					<dl class="detail_mid_dl"><dt><spring:message code='Cache.ACC_lbl_supplyValue'/></dt><dd id="account_receipt_view_card_repAmount"><spring:message code='Cache.ACC_lbl_won'/></dd></dl>
					<dl class="detail_mid_dl"><dt><spring:message code='Cache.ACC_lbl_taxType'/></dt><dd id="account_receipt_view_card_taxAmount"><spring:message code='Cache.ACC_lbl_won'/></dd></dl>
				</div>
				<div class="nea_card_detail_bottom">
					<select class="detail_bottom_sel" id="account_receipt_view_card_expType"></select>
					<textarea id="account_receipt_view_card_usageText" placeholder="<spring:message code='Cache.ACC_msg_inputComment'/>"></textarea>
				</div>
				<div class="nea_card_detail_btn"><a id="account_receipt_view_card_modify" onclick="javascript:mobile_account_clickbtn(this);" class="detail_btn_save"><span><spring:message code='Cache.ACC_btn_save'/></span></a></div>
			</div>
		</div>
		
		<!-- 모바일 영수증 -->
		<div class="mobile_popup_wrap" id="account_receipt_view_content" style="display: none;">
			<img id="account_receipt_view_receiptimage" style="width: 100%;"/>
		</div>
		
		<div class="mobile_popup_wrap" id="account_receipt_view_receiptproof" style="display: none;">
	    	<div class="nea_card_list_popup" style="top: 44%;">
				<div class="nea_post_ex_area">   
					<div class="post_ex">
						<p class="nea_bill_wrap">
							<input type="text" id="account_receipt_view_receipt_totalAmount" style="text-align: right; margin-bottom: 3px; width: 80%;" onkeypress="return mobile_account_inputNumChk(event, this);" onkeyup="mobile_account_setNumberComma(this);" />
							<spring:message code='Cache.ACC_lbl_won'/>
						</p>
					</div>
					<div class="post_ex">
						<select class="nea_bill_sel" id="account_receipt_view_receipt_expType"></select>
					</div>
					<!-- <div class="post_ex">
						<select class="nea_bill_sel" id="account_receipt_view_receipt_rcpType"></select>
					</div> -->
					<div class="post_ex">
						<textarea id="account_receipt_view_receipt_storeName" class="post_ex_textarea HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.ACC_msg_inputFranchiseCorpName'/>"></textarea>
					</div>
					<div class="post_ex">
						<textarea id="account_receipt_view_receipt_usageText" class="post_ex_textarea HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.ACC_msg_inputComment'/>"></textarea>
					</div>
					<div class="post_ex">
						<span class="th"><spring:message code='Cache.ACC_lbl_approveDate'/></span>
						<span class="tx">
							<input type="text" id="account_receipt_view_receipt_useDate" class="input_date HtmlCheckXSS ScriptCheckXSS" readonly="readonly">
						</span>
					</div>
					<div class="post_ex">
						<span class="th"><spring:message code='Cache.lbl_useTime'/></span>
						<span class="tx">
							<select id="account_receipt_view_receipt_useTimeHour"></select>
							&nbsp;:&nbsp;
							<select id="account_receipt_view_receipt_useTimeMinute"></select>
							<input type="hidden" id="account_receipt_view_useTime" />
						</span>
					</div>
					<div class="post_ex">
						<span class="th"><spring:message code='Cache.ACC_lbl_photoDate'/></span>
						<span class="tx" id="account_receipt_view_receipt_photoDate"></span>
					</div>
				</div>
				<div class="mobile_popup_btn">
					<a id="account_receipt_view_receipt_modify" onclick="javascript:mobile_account_clickbtn(this);" class="g_btn03"><spring:message code='Cache.ACC_btn_save'/></a>
					<a id="account_receipt_view_receipt_cancel" onclick="javascript:mobile_account_clickbtn(this);" class="g_btn04"><spring:message code='Cache.lbl_Cancel'/></a>
				</div>
			</div>
			<!-- HIDDEN FIELD -->
			<input type="hidden" id="account_receipt_view_storeAddress">	<!-- 주소 -->
	    </div>
    </div>
</div>