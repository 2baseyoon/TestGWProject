<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<% pageContext.setAttribute("isViewPanel", request.getParameter("isViewPanel")); %>

<div data-role="page" id="approval_view_page">	
	${strEditorSrc}
	<!-- 각 양식 JS 파일 -->
	<!-- 에디터 스크립트 -->
	<script type="text/javascript" >
		
		var strApvLineYN = "${strApvLineYN}";
		var strErrorMsg = "${strErrorMsg}";
		var strSuccessYN = "${strSuccessYN}";
	
		var formJson = "${formJson}";
		mobile_approval_formjsonload();//view page(taget)에서 결재선 호출시 formJson이 초기화되는 현상 방지.
		
		var useFIDO = "${useFIDO}";
		var proaas = "${aesSalt}";
		var proaaI = "${aesIv}";
		var proaapp = "${aesPassPhrase}";
		var aesUtil = new AesUtil("${aesKeysize}", "${aesIterationCount}");
		var formDraftkey = "${formDraftkey}";
		
		var processdesJson = ${processdesJson};
		var forminstanceJson = ${forminstanceJson};
		
		if(strSuccessYN == false){
			alert(strErrorMsg);
			window.close();
		}

		var admintype = mobile_comm_getQueryString("admintype", 'approval_view_page');

		var gLngIdx = ${strLangIndex}; 
		var g_szEditable = false;//작성창 open 여부
		var openMode = "B";
		
		//히스토리 기능 처리를 위한 변수 선언
		var gIsHistoryView = mobile_comm_getQueryString("ishistory", 'approval_view_page');
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

		var approvalViewQueryString = "${QueryString}";
		
		${strBodyTemplJS}
		
	</script>

	<header id="approval_view_header">
		<div class="sub_header">
			<div class="l_header">
				<c:if test="${isViewPanel != 'Y'}">
					<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
				</c:if>
				<div class="menu_link"><a class="pg_tit"><spring:message code='Cache.lbl_DetailView' /></a></div> <!-- 상세보기 -->
			</div>
			<div class="utill">
				<div class="dropMenu" id="approval_view_dropMenuBtn" style="display: none;">
					<a class="topH_exmenu" onclick="mobile_approval_showExtMenu();"><span class="Hicon">확장메뉴</span></a>
				</div>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="approval_view_content" style="-webkit-text-size-adjust: auto;">
		<div class="post_title">
	        <p class="post_location" id="approval_view_formname"></p> <!-- 양식명 -->
	      	<h2 class="tit" id="approval_view_formsubject"></h2> <!-- 양식제목 -->
	      	<a class="thumb" id="approval_view_initiatorphoto"></a>
	      	<p class="info"><a class="name" id="approval_view_initiatorname"></a></p>
	      	<p class="info"><span class="date" id="approval_view_initiatedate"></span></p>
	      </div>
	      
	      <div id="approval_view_fileArea"></div> <!-- 첨부파일 -->
	      
	      <div id="board_view_watermarkbody" class="watermarked" data-watermark="${WaterMark}">
		      <div class="post_cont" id="approval_view_showContent" style="padding: 0;">
		      	<div id="FormBody" style="display: none;">
					<div class="form_wrap">			
						<!-- 양식 상단 끝 -->
						<!-- 양식 본문 시작 -->
						<div id="bodytable" class="wordCont" style="top:100px;"><!-- 상단 영역 확장시 높이 변경(추후 알려드리겠습니다.) -->
							<div class="form_box" id="formBox">
					    		<table class="wordLayout">
					      			<colgroup>
					      				<col style="*" />
					      			</colgroup>
					      			<thead>
					        			<tr>
					          				<td class="wordLeft"><!--문서양식 왼쪽 시작-->
					           					 <h2><span id="headname" class="apptit_h2"></span></h2>
				
					           					 <div id="editor">
						           					 <div id="bodytable_content">
						           					 	<!-- 결재문서 Top 영역이 들어 올 곳 -->
						           					 	${strTopTempl}
		           					 	
						           					 	<!-- 결재선이 들어 올 곳 -->
														${strApvLineTempl}
				
														<!-- common fields template 들어 올 곳 -->
														${strCommonFieldsTempl}
				
														<!-- 양식 상단 부분 들어 올 곳 -->
														${strHeaderTempl}
				
														<!-- 양식 template 들어 올 곳 -->
														${strBodyTempl}
													</div>
												</div>
												<div>
													<!-- 양식 하단 부분이 들어 올 곳 -->
													${strFooterTempl}
												</div>
											</td>
										</tr>
									</thead>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="fixed_btm_wrap">
			<div class="approval_comment" id="approval_view_commentarea"> <!--  비밀번호 입력 칸 추가 시 secret 클래스 추가-->
				<a class="btn_toggle" onclick="mobile_approval_clickbtn(this, 'toggle');"></a>
				<div class="comment_inner">
					<div class="secret">
							<input type="password" id="approval_view_inputpassword" class="inputP" name="" value="" style="display:none;" placeholder="<spring:message code='Cache.msg_enter_PW'/>"> <!-- 비밀번호를 입력하여 주십시오. -->
							<a onclick="mobile_fido_requestCheckFido(); return false;" id="fido_btn" style="display:none;" class="g_btn01 inputPB ui-link"><spring:message code='Cache.lbl_Biometrics'/></a> <!-- 생체인증 -->
					</div>
					<div class="txt_area">
						<textarea name="name" id="approval_view_inputcomment" placeholder="<spring:message code='Cache.msg_apv_161'/>"></textarea> <!-- 의견을 입력하세요 -->
						<a id="approval_view_btn_OK" onclick="mobile_approval_doOK();" class="g_btn_sm"><spring:message code='Cache.btn_Confirm'/></a> <!-- 확인 -->
					</div>
				</div>
			</div>
			<div class="btn_wrap" id="approval_view_buttonarea" style="display: none;">
				<a id="approval_view_btApproval" onclick="mobile_approval_clickbtn(this, 'approved');" class="btn_approval" style="display:none;"><i class="ico"></i><spring:message code='Cache.lbl_apv_Approved'/></a><!-- 승인 -->
				<a id="approval_view_btDeptDraft" onclick="mobile_approval_clickbtn(this, 'deptdraft');" class="btn_approval" style="display:none; margin-right:10px;"><i class="ico"></i><spring:message code='Cache.btn_apv_redraft'/></a><!-- 재기안 -->
				<a id="approval_view_btRec" onclick="mobile_approval_clickbtn(this, 'rec');" class="btn_approval" style="display:none; margin-right:10px;"><i class="ico"></i><spring:message code='Cache.Cache.btn_apv_receipt'/></a><!-- 접수 -->
				<a id="approval_view_btReject" onclick="mobile_approval_clickbtn(this, 'reject');" class="btn_return" style="display:none;"><i class="ico"></i><spring:message code='Cache.lbl_apv_reject'/></a><!-- 반려 -->
				<a id="approval_view_btCAgree" onclick="mobile_approval_clickbtn(this, 'cAgree');" class="btn_approval" style="display:none;"><i class="ico"></i><spring:message code='Cache.lbl_apv_agree'/></a><!-- (검토)동의 -->
				<a id="approval_view_btCDisagree" onclick="mobile_approval_clickbtn(this, 'cDisagree');" class="btn_return" style="display:none;"><i class="ico"></i><spring:message code='Cache.lbl_apv_disagree'/></a><!-- (검토)거부 -->
			</div>
		</div>
	</div>

	<!-- 검토의견조회 팝업 -->
	<div id="approval_view_consultation_comment_view" class="mobile_popup_wrap" style="display: none;">
	    <div class="card_list_popup approval_pop" style="width: 320px; height: 460px;">
	        <div class="card_list_popup_cont">
	            <div class="card_list_title">
	                <strong class="tit"><spring:message	code='Cache.lbl_apv_consult_comment_view' /></strong><!-- 검토의견보기 -->
	            </div>
	            <div class="vpop_box02">
	                <!-- 테이블 영역 -->
	                <table class="approval_table">
	                    <caption>확장필드</caption>
	                    <colgroup>
	                    	<col width="13%" />
	                        <col width="25%" />
	                        <col width="13%" />
	                        <col width="25%" />
	                        <col width="*" />
	                    </colgroup>
	                    <thead>
	                        <tr>
	                        	<th scope="col"><spring:message code='Cache.lbl_Number'/></th><!-- 순번 -->
	                            <th scope="col"><spring:message code='Cache.lbl_apv_reviewer'/></th><!-- 검토자 -->
	                            <th scope="col"><spring:message code='Cache.lbl_apv_state'/></th><!-- 상태 -->
	                            <th scope="col"><spring:message code='Cache.lbl_apv_approvdate'/></th><!-- 결재일자 -->
	                            <th scope="col"><spring:message code='Cache.lbl_apv_comment'/></th><!-- 의견 -->
	                        </tr>
	                    </thead>
	                    <tbody>
	                    </tbody>
	                </table>
	            </div>
	
	            <!-- 버튼영역 -->
	            <div class="mobile_popup_btn">
	                <a href="#" class="g_btn04 ui-link">닫기</a>
	            </div>
	        </div>
	    </div>
	</div>
	
	<div class="bg_dim" style="display: none;"></div>
</div>