<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>

<div data-role="page" id="approval_write_page">

	<!-- 각 양식 JS 파일 -->
	<!-- 에디터 스크립트 -->
	<script type="text/javascript" >

		var gFormFavoriteYN = ""; //${strFormFavoriteYN}
		var strApvLineYN = ""; //${strApvLineYN}
		var strErrorMsg = ""; //${strErrorMsg}
		var strSuccessYN = ""; //${strSuccessYN}
	
		if(typeof(formJson) == 'undefined')
			var formJson = ""; //${formJson}
			
		var useFIDO = "${useFIDO}";

		var formDraftkey = "${formDraftkey}";
		var proaas = "${aesSalt}";
		var proaaI = "${aesIv}";
		var proaapp = "${aesPassPhrase}";
		var aesUtil = new AesUtil("${aesKeysize}", "${aesIterationCount}");

		var admintype = mobile_comm_getQueryString("admintype", "approval_write_page");

		var g_szEditable = false;//작성창 open 여부
		var gLngIdx = ${strLangIndex}; 
		var openMode = "B";
		
		//히스토리 기능 처리를 위한 변수 선언
		var gIsHistoryView = mobile_comm_getQueryString("ishistory", "approval_write_page");
		var gHistoryRev = "";

		//첨부파일UX통일 시작
		var g_LimitFileSize = "";
		var g_LimitFileCnt = "";

		var strStorage = ""; 
		//첨부파일UX통일 끝
		var varInkCNT = "";
		var inkvisit = 0;

		var gMailDomain = "";
		var g_szBaseURL = "";
		var bMailUse = "";
		var gFileAttachType = "";
		var gPrintType = "1";
		var gDocboxMenu = "";

		var PopUpWidth = 120;
		var gManagerYN = "";
		var gDeputyType = ""
		
		var _strAppName = "CoviFlow4J";

		var tableLineMax = mobile_comm_getBaseConfig("ApprovalLineMax_Table"); //테이블형 결재선 표시 최대 수
		
		${strBodyTemplJS}
		
		$("#Iframe").load(function(){
			if(($("#Iframe").get(0).contentWindow.location.href).indexOf("/mobile/approval/preview.do") > -1)
				setTimeout(function(){
					$("#Iframe").attr("height", $("#Iframe").get(0).contentWindow.document.getElementById("FormBody").clientHeight * 2);
				}, 500);
		});
		
	</script>
		
	<!-- ${strEditorSrc} -->	
	
	<header id="approval_write_header">
		<div class="sub_header">
			<div class="l_header">
				<a id="approval_write_btn_back" href="javascript: isLoad='N'; mobile_comm_back();" class="topH_close"><span><!-- 이전페이지로 이동 --></span></a>
				<a id="approval_write_btn_closeDialog" href="javascript: mobile_comm_back();" class="topH_close" style="display: none;"><span><!-- 다이얼로그 닫기 --></span></a>
				<div class="menu_link"><a href="#" class="pg_tit"><spring:message code='Cache.lbl_Write' /></a></div><!-- 작성 -->
			</div>
			<div class="utill">
				<a id="approval_write_btn_tempsave" href="javascript:  mobile_approval_tempsave();" class="topH_draft"><span class="Hicon"><!-- 임시저장 --></span></a>
				<a id="approval_write_btn_draft" href="javascript:  mobile_approval_draft();" class="topH_mailsend"><span class="Hicon"><!-- 기안 --></span></a>
				<a id="approval_write_btn_completeApv" href="javascript:  mobile_approval_completeApv();" class="topH_save" style="display: none;"><span class="Hicon">완료</span></a><!-- 완료 -->
				<a id="approval_write_btn_completeMod" href="javascript:  mobile_approval_completeMod();" class="topH_save" style="display: none;"><span class="Hicon">완료</span></a><!-- 완료 -->
			</div>
		</div>
	</header>
	
	<form name="IframeFrom" method="post">
		<input type="hidden" id="processID" 				name="processID" 			value="">
		<input type="hidden" id="workitemID" 				name="workitemID" 			value="">
		<input type="hidden" id="performerID" 				name="performerID" 			value="">
		<input type="hidden" id="processdescriptionID" 		name="processdescriptionID" value="">
		<input type="hidden" id="formtempinstboxID" 		name="formtempinstboxID" 	value="">
		<input type="hidden" id="forminstanceID" 			name="forminstanceID" 			value="">
		<input type="hidden" id="formID" 					name="formID" 				value="">
		<input type="hidden" id="forminstancetablename" 	name="forminstancetablename" 	value="">
		<input type="hidden" id="mode" 						name="mode" 				value="">
		<input type="hidden" id="gloct" 					name="gloct" 				value="">
		<input type="hidden" id="subkind" 					name="subkind" 				value="">
		<input type="hidden" id="archived" 					name="archived" 			value="">
		<input type="hidden" id="userCode" 					name="userCode" 			value="">
		<input type="hidden" id="admintype" 				name="admintype" 			value="">
		<input type="hidden" id="usisdocmanager" 			name="usisdocmanager" 		value="true">
		<input type="hidden" id="listpreview" 				name="listpreview" 			value="Y">
		<input type="hidden" id="Readtype" 					name="Readtype" 			value="">
	</form>

	<div data-role="" class="cont_wrap" id="approval_write_content">
		<div class="approval_write write_wrap">
			<div class="tab_wrap">
				<ul class="g_tab" id="approval_write_tabmenu">
					<%-- <li class="step01 on" value="approval_write_div_formSelect"><a onclick="javascript: mobile_approval_write_clickTab(this, 'menu');"><i></i><span><spring:message code='Cache.lbl_apv_formchoice' /></span></a></li> <!-- 양식선택 --> --%>
					<li class="step02 on" value="approval_write_div_detailItem"><a onclick="javascript: mobile_approval_write_clickTab(this, 'menu');"><i></i><span><spring:message code='Cache.lbl_apv_detailItem' /></span></a></li> <!-- 세부항목 -->
					<li class="step03" value="approval_write_div_approvalLine"><a onclick="javascript: mobile_approval_write_clickTab(this, 'menu');"><i></i><span><spring:message code='Cache.lbl_ApprovalLine' /></span></a></li> <!-- 결재선 -->
					<li class="step04" value="approval_write_div_preview"><a onclick="javascript: mobile_approval_write_clickTab(this, 'menu');"><i></i><span><spring:message code='Cache.btn_apv_preview' /></span></a></li> <!-- 미리보기 -->
				</ul>
				<div class="tab_cont_wrap" id="approval_write_wrapmenu">
					<div class="tab_cont" id="approval_write_div_detailItem">
						<div>
							<select id="approval_write_formList" class="full sel_type" onchange="javascript:mobile_approval_selectForm(this);"></select>
						</div>
						<div class="title_wrap">
							<input type="text" class="full mobileViceInputCtrl" voiceInputType="change" voiceCallBack="" id="approval_write_Subject" placeholder="<spring:message code='Cache.lbl_subject' />" onblur="mobile_approval_changeSelectBox(this);">
							<!-- <a onclick="mobile_comm_VoiceInput(this)" mobile_VoiceInputId="approval_write_Subject" mobile_VoiceInputType="change" class="btn_vw used ui-link" style="display:;"><span>사용</span></a> -->
						</div>
						<div>
							<div id="FormBody" style="display: none;">
							<div class="form_wrap">
								<!-- 메뉴가 들어 올 영역 -->
								<%-- 히스토리 보기 시 메뉴영역 그리지 않는다.--%>
								<div id="approval_write_strMenuTempl" style="display: none;"></div>
						
								<!-- 양식 상단 끝 -->
								<!-- 양식 본문 시작 -->
								<div id="bodytable" class="wordCont" style="top:100px;"><!-- 상단 영역 확장시 높이 변경(추후 알려드리겠습니다.) -->
									<div class="form_box" id="formBox">
			           					 <div id="editor">
				           					 <div id="bodytable_content">
				           					 	<!-- 결재선이 들어 올 곳 -->
												<div id="approval_write_strApvLineTempl" style="display: none;"></div>
		
												<!-- common fields template 들어 올 곳 -->
												<div id="approval_write_strCommonFieldsTempl" style="display: none;"></div>
		
												<!-- 양식 상단 부분 들어 올 곳 -->
												<div id="approval_write_strHeaderTempl"></div>
		
												<!-- 양식 template 들어 올 곳 -->
												<div id="approval_write_strBodyTempl"></div>
											</div>
										</div>
										<div>
											<!-- 양식 하단 부분이 들어 올 곳 -->
											<div id="approval_write_strFooterTempl" style="display: none;"></div>
		
		
											<!-- 첨부 부분이 들어 올 곳 -->
											<div id="approval_write_strAttachTempl" style="display: none;"></div>
		
											<!-- 첨부 쪽 처리 -->
											<input type="hidden" ID="hidFrontPath"/>
											<input type="hidden" ID="hidFileSize"/>
											<input type="hidden" ID="hidOldFile"/>
											<input type="hidden" ID="hidDeleteFront"/>
											<input type="hidden" ID="hidImageFile"/>
											<input type="hidden" ID="hidDeleteFile"/>
											<input type="hidden" ID="hidUseVideo" Value="N" />
		
											<input type="hidden" ID="llegacy_form"/>
											<input type="hidden" ID="lkey"/>
											<input type="hidden" ID="lsubject"/>
											<input type="hidden" ID="lbodycontext"/>
											<input type="hidden" ID="lempno"/>
											<input type="hidden" ID="lattachfile"/>
										</div>
									</div>
									<div style="display: none;" id="filePreview">
										<div class="conin_view" style="left:790px;"><!-- 좌우 폭 조정에 따라 값 변경(좌측 width값) -->
										<!-- 좌우폭 조정 Bar시작 -->
										<div class="xbar"></div>
										<!-- 좌우폭 조정 Bar 끝 -->
										<!--문서양식 오른쪽 시작-->
										<div class="wordView">
											<iframe id="IframePreview" name="IframePreview" frameborder="0" width="100%" height="800px" scrolling="no"></iframe>
											<input type="hidden" id="previewVal" value="">
										</div>
										<!--문서양식 오른쪽 끝-->
									  	</div>
									</div>
								</div>
								<div id="divFileDownload" style="display:none;">
									<iframe id="frmFileDownload" width="1" height="1"></iframe>
								</div>
							</div>
						
							<!-- 로딩 이미지  -->
							<!-- <div style="background: rgb(0, 0, 0); left: 0px; top: 0px; width: 100%; height: 1296px; position: fixed; z-index: 149; opacity: 0; filter: progid:DXImageTransform.Microsoft.Alpha(opacity=0); -ms-filter:'progid:DXImageTransform.Microsoft.Alpha(opacity=0)'; " id="loading_overlay"></div>
							<div id="divLoading" style="text-align:center;z-index:10;background-color:red;margin:0 auto;position:absolute; top:16%; left:50%; height:20px; margin-left:-10px; margin-top:-10px; ">
								<img src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/loding12.gif" style="text-align:center;" />
							</div> -->
							</div>
						</div>
						
						<!-- 기본정보 -->
						<div class="infos_wrap">
							<a onclick="javascript: mobile_approval_write_showORhide(this);" class="infos_close"><span class="tx"><spring:message code='Cache.lbl_apv_baseInfo' /></span></a> <!-- 기본정보 -->
							<div class="detail_info">
								<div class="inner">
									<ul>
										<li id="approval_write_InitiatorDisplay"></li>
										<li id="approval_write_InitiatorOUDisplay"></li>
									</ul>
									<ul>
										<li id="approval_write_DocNo" style="min-height: 16px;"><span class="label"><spring:message code='Cache.lbl_apv_DocNo' /></span></li> <!-- 문서번호 -->
										<li>
											<span class="label"><spring:message code='Cache.lbl_apv_docfoldername' /></span> <!-- 문서분류 -->
											<a onclick="javascript: mobile_approval_openDocClassPopup();" class="ico_add_file"></a>
											<input type="hidden" id="approval_write_DocClassID"></span>
											<span id="approval_write_DocClassName"></span>
										</li>
									</ul>
									<ul>
										<li>
											<span class="label"><spring:message code='Cache.lbl_apv_SecurityLevel' /></span> <!-- 보안등급 -->
											<select id="approval_write_DocLevel" onchange="mobile_approval_changeSelectBox(this);">
												<option value="100"><spring:message code='Cache.DOC_LEVEL_10' /></option> <!-- 일반문서 -->
												<option value="200"><spring:message code='Cache.DOC_LEVEL_20' /></option> <!-- 보안문서 -->
												<option value="300"><spring:message code='Cache.DOC_LEVEL_30' /></option> <!-- 3등급 -->
											</select>
										</li>
										<li>
											<span class="label"><spring:message code='Cache.lbl_apv_retention' /></span> <!-- 보존년한 -->
												<select id="approval_write_SaveTerm" onchange="mobile_approval_changeSelectBox(this);">
													<option value="1"><spring:message code='Cache.SAVE_TERM_1' /></option> <!-- 1년 -->
													<option value="3"><spring:message code='Cache.SAVE_TERM_3' /></option> <!-- 3년 -->
													<option value="5"><spring:message code='Cache.SAVE_TERM_5' /></option> <!-- 5년 -->
													<option value="7"><spring:message code='Cache.SAVE_TERM_7' /></option> <!-- 7년 -->
													<option value="10"><spring:message code='Cache.SAVE_TERM_10' /></option> <!-- 10년 -->
													<option value="99"><spring:message code='Cache.SAVE_TERM_99' /></option> <!-- 영구 -->
												</select>
										</li>
									</ul>
								</div>
							</div>
						</div>
						
						<!-- 연관문서 -->
						<div class="docs_wrap active">
							<span class="tx" id="label_DocLinkInfo"><spring:message code='Cache.Cache.lbl_apv_ConDoc' /></span>
							<a onclick="javascript: mobile_approval_addDocLink();" class="btn_add_n"><span class="tx"><spring:message code='Cache.lbl_apv_ConDoc' /></span></a> <!-- 연관문서 -->
							<div class="docs_a" id="approval_write_DocLinkInfo" style="display: none;"></div>
						</div>
						
						<!-- 첨부파일 -->
						<div class="files_wrap">
							<div covi-mo-attachupload system="Approval"></div>
							<!-- <div class="files_area">
								<div class="files_area_btn">
									<p class="tx">파일첨부</p>
									<a onclick="javascript: mobile_approval_addFile" class="file_add"></a>
								</div>
								<ul id="approval_write_attachFileList"></ul>
							</div> -->
						</div>
					</div>
					<div class="tab_cont" id="approval_write_div_approvalLine">
						<div class="tab_wrap">
							<ul class="g_tab sm_tab" id="approval_write_tabtype">
								<li class="on" value="approval_write_div_approval"><a onclick="javascript: mobile_approval_write_clickTab(this, 'type');"><spring:message code='Cache.lbl_apv_app' /></a></li> <!-- 결재 -->
								<li value="approval_write_div_tcinfo"><a onclick="javascript: mobile_approval_write_clickTab(this, 'type');"><spring:message code='Cache.lbl_apv_cc' /></a></li> <!-- 참조 -->
								<li value="approval_write_div_distribution"><a onclick="javascript: mobile_approval_write_clickTab(this, 'type');"><spring:message code='Cache.lbl_chkDistribution' /></a></li> <!-- 배포 -->
							</ul>
							<div class="tab_cont_wrap" id="approval_write_wraptype">
								<div class="tab_cont on" id="approval_write_div_approval">
									<div class="approval_h">
										<div class="inner">
											<ol id="approval_write_approvalList"></ol>
										</div>
									</div>
									<div class="btn_wrap">
										<a onclick="javascript: mobile_approval_addApprovalLine('approval');" class="g_btn03"><i class="ico_add_wh"></i><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
										<a onclick="javascript: mobile_approval_addApprovalLine('approval', 'receive');" class="g_btn03" name="addReceiveApv" style="display:none;"><i class="ico_add_wh"></i><spring:message code='Cache.btn_apv_addCharge' /></a> <!-- 담당자 추가 -->
										<a onclick="javascript: mobile_approval_resetApprovalLine('approval');"  class="g_btn04"><i class="ico_reload"></i><spring:message code='Cache.btn_apv_init' /></a> <!-- 초기화 -->
									</div>
								</div>
								<div class="tab_cont" id="approval_write_div_tcinfo">
									<div class="approval_h">
										<div class="inner">
											<ol id="approval_write_tcinfoList"></ol>
										</div>
									</div>
									<div class="btn_wrap">
										<a onclick="javascript: mobile_approval_addApprovalLine('tcinfo');" class="g_btn03"><i class="ico_add_wh"></i><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
										<a onclick="javascript: mobile_approval_resetApprovalLine('tcinfo');" class="g_btn04"><i class="ico_reload"></i><spring:message code='Cache.btn_apv_init' /></a> <!-- 초기화 -->
									</div>
								</div>
								<div class="tab_cont" id="approval_write_div_distribution">
									<div class="approval_h">
										<div class="inner">
											<ol id="approval_write_distributionList"></ol>
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
					<div class="tab_cont" id="approval_write_div_preview">
						<div id="IframeDiv">
							<iframe id="Iframe" name="Iframe" frameborder="0" width="100%" class="wordLayout" scrolling="no" style="background: white;"></iframe>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="fixed_btm_wrap">
			<div class="approval_comment" id="approval_write_commentarea"> <!--  비밀번호 입력 칸 추가 시 secret 클래스 추가-->
				<a class="btn_toggle" onclick="mobile_approval_clickbtn(this, 'toggle');"></a>
				<div class="comment_inner">
					<div class="secret">
						<input type="password" id="approval_write_inputpassword" class="inputP" name="" value="" style="display:none;" placeholder="<spring:message code='Cache.msg_enter_PW'/>"> <!-- 비밀번호를 입력하여 주십시오. -->
						<a onclick="mobile_fido_requestCheckFido(); return false;" id="fido_btn" style="display:none;" class="g_btn01 inputPB ui-link"><spring:message code='Cache.lbl_Biometrics'/></a> <!-- 생체인증 -->
					</div>
					<div class="txt_area">
						<textarea name="name" id="approval_write_inputcomment" placeholder="<spring:message code='Cache.msg_apv_161'/>"></textarea> <!-- 의견을 입력하세요 -->
						<a id="approval_write_btn_OK" onclick="mobile_approval_doOK();" class="g_btn_sm"><spring:message code='Cache.btn_Confirm'/></a> <!-- 확인 -->
					</div>
				</div>
			</div>
			<div class="btn_wrap" id="approval_write_buttonarea" style="display: none;">
				<a id="approval_write_btApproval" onclick="mobile_approval_clickbtn(this, 'approved');" class="btn_approval" style="display:none;"><i class="ico"></i><spring:message code='Cache.lbl_apv_Approved'/></a><!-- 승인 -->
				<a id="approval_write_btDeptDraft" onclick="mobile_approval_clickbtn(this, 'deptdraft');" class="btn_approval" style="display:none; margin-right:10px;"><i class="ico"></i><spring:message code='Cache.btn_apv_redraft'/></a><!-- 재기안 -->
				<a id="approval_write_btRec" onclick="mobile_approval_clickbtn(this, 'rec');" class="btn_approval" style="display:none; margin-right:10px;"><i class="ico"></i><spring:message code='Cache.Cache.btn_apv_receipt'/></a><!-- 접수 -->
				<a id="approval_write_btReject" onclick="mobile_approval_clickbtn(this, 'reject');" class="btn_return" style="display:none;"><i class="ico"></i><spring:message code='Cache.lbl_apv_reject'/></a><!-- 반려 -->
			</div>
		</div>
	</div>	
	
	<div class="bg_dim" style="display: none;"></div>
</div>