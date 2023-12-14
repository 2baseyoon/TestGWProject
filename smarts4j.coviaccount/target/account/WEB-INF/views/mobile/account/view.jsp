<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>

<div data-role="page" id="account_view_page">
	<script type="text/javascript" >
		var useFIDO = '<c:out value="${useFIDO}"/>';
		var proaas = "${aesSalt}";
		var proaaI = "${aesIv}";
		var proaapp = "${aesPassPhrase}";
		var aesUtil = new AesUtil("${aesKeysize}", "${aesIterationCount}");
	</script>
	<header class="header" id="account_view_header">
		<div class="sub_header">
			<div class="l_header">
				<a onclick="javascript: window.sessionStorage.removeItem('account_viewinit'); mobile_comm_back();" class="topH_close"><span></span></a>
				<div class="menu_link gnb">
					<span class="topH_tit"><spring:message code='Cache.lbl_DetailView' /></span>
				</div>
			</div>
			<div class="utill">
				<div class="dropMenu" id="account_view_dropMenuBtn" style="display: none;">
					<a class="topH_exmenu" onclick="mobile_account_showExtMenu();"><span class="Hicon">확장메뉴</span></a>
				</div>
			</div>
		</div>
	</header>
	<div data-role="content" class="cont_wrap" id="account_view_content">
		<div class="approval_write write_wrap">
		    <div class="title eafull">
		    	<input id="account_view_subject" type="text" class="full" readonly="readonly"/>
		    </div>
			<div class="neaapp_line"><!-- write_info_appline -->
				<div class="scr_h" id="account_view_approvalList"></div>
			</div>
			<div class="sea_top">
				<dl class="sea_top_dl">
					<dt><spring:message code='Cache.lbl_eviTotalAmt'/></dt>
					<dd><span class="tx_cost_pc" id="account_view_TotalAmount"></span><spring:message code='Cache.ACC_lbl_won'/></dd>
				</dl>
				<dl class="sea_top_dl">
					<dt><spring:message code='Cache.ACC_billReqAmt'/></dt>
					<dd><span class="tx_cost_pc" id="account_view_ReqAmount"></span><spring:message code='Cache.ACC_lbl_won'/></dd>
				</dl>
			</div>
			<div class="sea_top">
				<dl class="sea_top_dl">
					<dt><spring:message code='Cache.ACC_lbl_payDay2'/></dt>
					<dd><span class="tx_cost_pc" id="account_view_payDate"></span></dd>
				</dl>
			</div>
			<div class="nea_applist">
				<ul id="account_view_list"></ul>
			</div>
			<input type="hidden" id="account_view_chargeJob">
		</div>
		<textarea id="APVLIST" style="display:none"></textarea>
		<input type="hidden" id="ACTIONCOMMENT" value="" />
	</div>
	<div class="fixed_btm_wrap" id="account_view_apvProcessArea" style="display: none;">
		<div class="approval_comment" id="account_view_commentarea"> <!--  비밀번호 입력 칸 추가 시 secret 클래스 추가-->
			<a class="btn_toggle" onclick="mobile_approval_clickbtn(this, 'toggle');"></a>
			<div class="comment_inner">
				<div class="secret">
						<input type="password" id="account_view_inputpassword" class="inputP" name="" value="" style="display:none;" placeholder="<spring:message code='Cache.msg_enter_PW'/>"> <!-- 비밀번호를 입력하여 주십시오. -->
						<a onclick="mobile_fido_requestCheckFido(); return false;" id="fido_btn" style="display:none;" class="g_btn01 inputPB ui-link">생체인증</a> <!-- 생체인증 -->
				</div>
				<div class="txt_area">
					<textarea name="name" id="account_view_inputcomment" placeholder="<spring:message code='Cache.msg_apv_161'/>"></textarea> <!-- 의견을 입력하세요 -->
					<a id="account_view_btn_OK" onclick="mobile_account_doOK();" class="g_btn_sm"><spring:message code='Cache.btn_Confirm'/></a> <!-- 확인 -->
				</div>
			</div>
		</div>
		<div class="btn_wrap" id="account_view_buttonarea"  style="display:none;">
			<a id="account_view_btApproval" onclick="mobile_approval_clickbtn(this, 'approved');" class="btn_approval" style="display:none;"><i class="ico"></i><spring:message code='Cache.lbl_apv_Approved'/></a><!-- 승인 -->
			<a id="account_view_btDeptDraft" onclick="mobile_approval_clickbtn(this, 'deptdraft');" class="btn_approval" style="display:none; margin-right:10px;"><i class="ico"></i><spring:message code='Cache.btn_apv_redraft'/></a><!-- 재기안 -->
			<a id="account_view_btRec" onclick="mobile_approval_clickbtn(this, 'rec');" class="btn_approval" style="display:none; margin-right:10px;"><i class="ico"></i><spring:message code='Cache.Cache.btn_apv_receipt'/></a><!-- 접수 -->
			<a id="account_view_btReject" onclick="mobile_approval_clickbtn(this, 'reject');" class="btn_return" style="display:none;"><i class="ico"></i><spring:message code='Cache.lbl_apv_reject'/></a><!-- 반려 -->
		</div>
	</div>
	
    <div class="mobile_popup_wrap" id="account_view_card_proof" style="display: none;">
    	<div class="card_list_bill_popup">
			<div class="eaccounting_bill">
				<p class="card_number">
					<span id="account_view_card_proof_CardNo"></span>
				</p>
				<div class="card_info01_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_confirmNum'/></dt>
						<dd id="account_view_card_proof_ApproveNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_TransactionDate'/></dt>
						<dd id="account_view_card_proof_UseDate"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_payMethod'/></dt>
						<dd id="account_view_card_proof_PayMethod"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_franchiseCorpName'/></dt>
						<dd id="account_view_card_proof_StoreName"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_franchiseCorpNo'/></dt>
						<dd id="account_view_card_proof_StoreNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_RepresentativeName'/></dt>
						<dd id="account_view_card_proof_StoreRepresentative"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_bizRegNo'/></dt>
						<dd id="account_view_card_proof_StoreRegNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_PhoneNum'/></dt>
						<dd id="account_view_card_proof_StoreTel"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_Address'/></dt>
						<dd id="account_view_card_proof_StoreAddress"></dd>
					</dl>
				</div>
				<div class="card_info02_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_amt'/></dt>
						<dd id="account_view_card_proof_RepAmount"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_taxType'/></dt>
						<dd id="account_view_card_proof_TaxAmount"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_serviceAmt'/></dt>
						<dd id="account_view_card_proof_ServiceAmount"></dd>
					</dl>
				</div>
				<div class="card_info03_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.lblSum'/></dt>
						<dd id="account_view_card_proof_AmountWon_InfoIndex"></dd>
					</dl>
				</div>
			</div>
			<div class="mobile_popup_btn">
				<a id="account_view_card_proof_ok" onclick="javascript: mobile_account_clickbtn(this)" class="g_btn03"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
    </div>
    
	<div class="mobile_popup_wrap" id="account_view_receipt_popup" style="display:none;">
    	<div class="receipt_upload_popup">
			<div class="receipt_upload_img" id="account_view_receipt_image"></div>
			<div class="mobile_popup_btn">
				<a onclick="javascript:mobile_account_clickbtn(this);" class="g_btn03" id="account_view_receipt_popup_ok"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
    </div>    
    
	<div class="mobile_popup_wrap" id="account_view_cc_popup" style="display:none;">
    	<div class="card_list_popup">
			<div class="eaccounting_bill">
				<p class="card_number">
					<span id="account_view_cc_p" style="border: 0px;"></span>
				</p>
				<div class="card_info01_wrap" id="account_view_cc_div" style="margin-bottom: 13px;"></div>
			</div>
			<div class="mobile_popup_btn">
				<a onclick="javascript:mobile_account_clickbtn(this);" class="g_btn03" id="account_view_cc_popup_ok"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
    </div>
    
	<div class="mobile_popup_wrap" id="account_view_cmt_popup" style="display:none;">
    	<div class="card_list_popup">
			<div class="eaccounting_bill" style="overflow-y:scroll;max-height:300px;margin:10px 0 20px 0;">
				<p class="card_number" style="border:none;">
					<span id="account_view_cmt_Comment" style="height:auto;border:none;font-size:1.0rem;font-weight:normal;line-height:1.5;"></span>
				</p>
			</div>
			<div class="mobile_popup_btn">
				<a onclick="javascript:mobile_account_clickbtn(this);" class="g_btn03" id="account_view_cmt_popup_ok"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
    </div>
	
	<!-- <div name="mobileApp_hiddenViewForm" style="display: none"></div> -->
</div>

