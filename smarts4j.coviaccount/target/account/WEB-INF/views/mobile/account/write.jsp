<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>

<div data-role="page" id="account_write_page">
	<script type="text/javascript" >
		var propertyAprv = '<c:out value="${propertyAprv}"/>'; 
		var propertyOtherApv = '<c:out value="${propertyOtherApv}"/>';
		var useFIDO = '<c:out value="${useFIDO}"/>';
		
		var formDraftkey = "${formDraftkey}";
		var proaas = "${aesSalt}";
		var proaaI = "${aesIv}";
		var proaapp = "${aesPassPhrase}";
		var aesUtil = new AesUtil("${aesKeysize}", "${aesIterationCount}");
	</script>
	<header class="header" id="account_write_header">
		<div class="sub_header">
			<div class="l_header">
				<a onclick="javascript: window.sessionStorage.removeItem('account_writeinit'); mobile_comm_back();" class="topH_close"><span></span></a>
				<div class="menu_link gnb">
					<span class="topH_tit"><spring:message code='Cache.btn_CostApplication' /></span>
				</div>
			</div>
			<div class="utill">
				<a onclick="javascript: mobile_account_clickbtn(this);" class="topH_delete" id="account_write_del"><span class="Hicon"><spring:message code='Cache.ACC_lbl_delete' /></span></a> 
				<a onclick="javascript: mobile_account_draft('T');" class="topH_draft"><span class="Hicon"><spring:message code='Cache.btn_tempsave' /></span></a> 
				<a onclick="javascript: mobile_account_draft('S');" class="topH_save"><span class="Hicon"><spring:message code='Cache.btn_Application' /></span></a>
				<a onclick="javascript: mobile_account_completeApv();" id="account_write_btn_completeApv" class="topH_save" style="display: none;"><span class="Hicon">완료</span></a><!-- 완료 -->
				<!-- <a onclick="javascript: mobile_approval_completeMod();" id="account_write_btn_completeMod" class="topH_save" style="display: none;"><span class="Hicon">완료</span></a>완료 -->
			</div>
		</div>
	</header>
	<div data-role="content" class="cont_wrap" id="account_write_content">
		<div class="approval_write write_wrap">
			<div class="tab_wrap">
				<ul class="g_tab" id="account_write_tabmenu">
					<li class="step02 on" value="account_write_div_detailItem"><a onclick="javascript: mobile_account_write_clickTab(this, 'menu');"><i></i><span><spring:message code='Cache.lbl_apv_detailItem' /></span></a></li> <!-- 세부항목 -->
					<li class="step03" value="account_write_div_approvalLine"><a onclick="javascript: mobile_account_write_clickTab(this, 'menu');"><i></i><span><spring:message code='Cache.lbl_ApprovalLine' /></span></a></li> <!-- 결재선 -->
				</ul>
				<div class="tab_cont_wrap" id="account_write_wrapmenu">
					<div class="tab_cont" id="account_write_div_detailItem">
					    <div class="title eafull">
					    	<input id="account_write_subject" type="text" class="full HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_028'/>">
					    </div>
						<div class="sea_top">
							<dl class="sea_top_dl">
								<dt><spring:message code='Cache.lbl_eviTotalAmt'/></dt>
								<dd><span class="tx_cost_pc" id="account_write_TotalAmount"></span><spring:message code='Cache.ACC_lbl_won'/></dd>
							</dl>
							<dl class="sea_top_dl">
								<dt><spring:message code='Cache.ACC_billReqAmt'/></dt>
								<dd><span class="tx_cost_pc" id="account_write_ReqAmount"></span><spring:message code='Cache.ACC_lbl_won'/></dd>
							</dl>
						</div>
						<div class="write_info_etc">
							<div class="write_info_etc_search">
								<input type="text" id="account_write_costCenter" placeholder="<spring:message code='Cache.lbl_memDept'/>" class="etc_search_input" readonly="readonly">
								<a onclick="mobile_account_goSearchCostCenter();" class="etc_search_btn"></a>
								<input type="hidden" id="account_write_costCenter_code">
							</div>
							<div class="write_info_etc_search" style="display: none;">
								<input type="text" id="account_write_IO" placeholder="<spring:message code='Cache.lbl_project_name'/>" class="etc_search_input" readonly="readonly">
								<a onclick="mobile_account_goSearchIO();" class="etc_search_btn"></a>
								<input type="hidden" id="account_write_IO_code">
							</div>
							<select id='account_write_payDateType' onchange="mobile_account_changePayDateType(this);" class="nea_bottom_sel">
								<option value=""><spring:message code='Cache.ACC_lbl_payDay'/></option>
							</select>
							<p class="write_info_etc_date">
								<input type="text" id="account_write_payDate" class="input_date" style="display: none;" />
							</p>
						</div>
						<div class="nea_applist">
							<div class="nea_applist_write">
								<ul id="account_write_list"></ul>
							</div>
						</div>
						<input type="hidden" id="account_write_chargeJob">
				  	</div>
					<div class="tab_cont" id="account_write_div_approvalLine">
						<div class="tab_wrap">
							<ul class="g_tab sm_tab" id="account_write_tabtype">
								<li class="on" value="account_write_div_approval"><a onclick="javascript: mobile_account_write_clickTab(this, 'type');"><spring:message code='Cache.lbl_apv_app' /></a></li> <!-- 결재 -->
								<li value="account_write_div_tcinfo"><a onclick="javascript: mobile_account_write_clickTab(this, 'type');"><spring:message code='Cache.lbl_apv_cc' /></a></li> <!-- 참조 -->
								<li value="account_write_div_distribution"><a onclick="javascript: mobile_account_write_clickTab(this, 'type');"><spring:message code='Cache.lbl_chkDistribution' /></a></li> <!-- 배포 -->
							</ul>
							<div class="tab_cont_wrap" id="account_write_wraptype">
								<div class="tab_cont on" id="account_write_div_approval">
									<div class="approval_h">
										<div class="inner">
											<ol id="account_write_approvalList"></ol>
										</div>
									</div>
									<div class="btn_wrap">
										<a onclick="javascript: mobile_approval_addApprovalLine('approval');" class="g_btn03"><i class="ico_add_wh"></i><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
										<a onclick="javascript: mobile_approval_resetApprovalLine('approval');"  class="g_btn04"><i class="ico_reload"></i><spring:message code='Cache.btn_apv_init' /></a> <!-- 초기화 -->
									</div>
								</div>
								<div class="tab_cont" id="account_write_div_tcinfo">
									<div class="approval_h">
										<div class="inner">
											<ol id="account_write_tcinfoList"></ol>
										</div>
									</div>
									<div class="btn_wrap">
										<a onclick="javascript: mobile_approval_addApprovalLine('tcinfo');" class="g_btn03"><i class="ico_add_wh"></i><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
										<a onclick="javascript: mobile_approval_resetApprovalLine('tcinfo');" class="g_btn04"><i class="ico_reload"></i><spring:message code='Cache.btn_apv_init' /></a> <!-- 초기화 -->
									</div>
								</div>
								<div class="tab_cont" id="account_write_div_distribution">
									<div class="approval_h">
										<div class="inner">
											<ol id="account_write_distributionList"></ol>
										</div>
									</div>
									<div class="btn_wrap">
										<a onclick="javascript: mobile_approval_addApprovalLine('distribution');" class="g_btn03"><i class="ico_add_wh"></i><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
										<a onclick="javascript: mobile_approval_resetApprovalLine('distribution');" class="g_btn04"><i class="ico_reload"></i><spring:message code='Cache.btn_apv_init' /></a> <!-- 초기화 -->
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="fixed_btm_wrap">
			<div class="approval_comment" id="account_write_commentarea"> <!--  비밀번호 입력 칸 추가 시 secret 클래스 추가-->
				<a class="btn_toggle" onclick="mobile_approval_clickbtn(this, 'toggle');"></a>
				<div class="comment_inner">
					<div class="secret">
						<input type="password" id="account_write_inputpassword" class="inputP" name="" value="" style="display:none;" placeholder="<spring:message code='Cache.msg_enter_PW'/>"> <!-- 비밀번호를 입력하여 주십시오. -->
						<a onclick="mobile_fido_requestCheckFido(); return false;" id="fido_btn" style="display:none;" class="g_btn01 inputPB ui-link">생체인증</a> <!-- 생체인증 -->
					</div>
					<div class="txt_area">
						<textarea name="name" id="account_write_inputcomment" placeholder="<spring:message code='Cache.msg_apv_161'/>"></textarea> <!-- 의견을 입력하세요 -->
						<a id="account_write_btn_OK" onclick="mobile_account_doOK();" class="g_btn_sm"><spring:message code='Cache.btn_Confirm'/></a> <!-- 확인 -->
					</div>
				</div>
			</div>
			<div class="btn_wrap" id="account_write_buttonarea" style="display: none;">
				<a id="account_write_btApproval" onclick="mobile_approval_clickbtn(this, 'approved');" class="btn_approval" style="display:none;"><i class="ico"></i><spring:message code='Cache.lbl_apv_Approved'/></a><!-- 승인 -->
				<a id="account_write_btDeptDraft" onclick="mobile_approval_clickbtn(this, 'deptdraft');" class="btn_approval" style="display:none; margin-right:10px;"><i class="ico"></i><spring:message code='Cache.btn_apv_redraft'/></a><!-- 재기안 -->
				<a id="account_write_btRec" onclick="mobile_approval_clickbtn(this, 'rec');" class="btn_approval" style="display:none; margin-right:10px;"><i class="ico"></i><spring:message code='Cache.Cache.btn_apv_receipt'/></a><!-- 접수 -->
				<a id="account_write_btReject" onclick="mobile_approval_clickbtn(this, 'reject');" class="btn_return" style="display:none;"><i class="ico"></i><spring:message code='Cache.lbl_apv_reject'/></a><!-- 반려 -->
			</div>
		</div>
		<textarea id="APVLIST" style="display:none"></textarea>
		<input type="hidden" id="ACTIONCOMMENT" value="" />
	</div>
	
    <div class="mobile_popup_wrap" id="account_write_card_proof" style="display: none;">
    	<div class="card_list_bill_popup">
			<div class="eaccounting_bill">
				<p class="card_number">
					<span id="account_write_card_proof_CardNo"></span>
				</p>
				<div class="card_info01_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_confirmNum'/></dt>
						<dd id="account_write_card_proof_ApproveNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_TransactionDate'/></dt>
						<dd id="account_write_card_proof_UseDate"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_payMethod'/></dt>
						<dd id="account_write_card_proof_PayMethod"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_franchiseCorpName'/></dt>
						<dd id="account_write_card_proof_StoreName"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_franchiseCorpNo'/></dt>
						<dd id="account_write_card_proof_StoreNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_RepresentativeName'/></dt>
						<dd id="account_write_card_proof_StoreRepresentative"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_bizRegNo'/></dt>
						<dd id="account_write_card_proof_StoreRegNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_PhoneNum'/></dt>
						<dd id="account_write_card_proof_StoreTel"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_Address'/></dt>
						<dd id="account_write_card_proof_StoreAddress"></dd>
					</dl>
				</div>
				<div class="card_info02_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_amt'/></dt>
						<dd id="account_write_card_proof_RepAmount"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_taxType'/></dt>
						<dd id="account_write_card_proof_TaxAmount"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_serviceAmt'/></dt>
						<dd id="account_write_card_proof_ServiceAmount"></dd>
					</dl>
				</div>
				<div class="card_info03_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.lblSum'/></dt>
						<dd id="account_write_card_proof_AmountWon_InfoIndex"></dd>
					</dl>
				</div>
			</div>
			<div class="mobile_popup_btn">
				<a id="account_write_card_proof_ok" onclick="javascript: mobile_account_clickbtn(this)" class="g_btn03"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
    </div>
    
	<div class="mobile_popup_wrap" id="account_write_receipt_popup" style="display:none;">
    	<div class="receipt_upload_popup">
			<div class="receipt_upload_img" id="account_write_receipt_image"></div>
			<div class="mobile_popup_btn">
				<a onclick="javascript:mobile_account_clickbtn(this);" class="g_btn03" id="account_write_receipt_popup_ok"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
    </div>    
    
	<div class="mobile_popup_wrap" id="account_write_cc_popup" style="display:none;">
    	<div class="card_list_popup">
			<div class="eaccounting_bill">
				<p class="card_number">
					<span id="account_write_cc_p" style="border: 0px;"></span>
				</p>
				<div class="card_info01_wrap" id="account_write_cc_div" style="margin-bottom: 13px;"></div>
			</div>
			<div class="mobile_popup_btn">
				<a onclick="javascript:mobile_account_clickbtn(this);" class="g_btn03" id="account_write_cc_popup_ok"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
    </div>
	
	<!-- <div name="mobileApp_hiddenViewForm" style="display: none"></div> -->
</div>

