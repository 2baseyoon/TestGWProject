<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>


<div data-role="page" id="approval_view_page">
		
	<!-- 각 양식 JS 파일 -->
	<!-- 에디터 스크립트 -->
	<script type="text/javascript" >
		
		var gFormFavoriteYN = "${strFormFavoriteYN}";
		var strApvLineYN = "${strApvLineYN}";
		var strErrorMsg = "${strErrorMsg}";
		var strSuccessYN = "${strSuccessYN}";
	
		var formJson = "${formJson}";
		
		if(strSuccessYN == false){
			alert(strErrorMsg);
			window.close();
		}

		var admintype = mobile_comm_getQueryString("admintype");

		var g_szEditable = false;//작성창 open 여부
		var openMode = "B";
		
		//히스토리 기능 처리를 위한 변수 선언
		var gIsHistoryView = mobile_comm_getQueryString("ishistory");
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
		
	</script>
		
	${strEditorSrc}	

	<header data-role="header" id="approval_view_header">
		
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="btn_back"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link"><a class="pg_tit"><spring:message code='Cache.lbl_DetailView' /></a></div> <!-- 상세보기 -->
			</div>
			<div class="utill">
				<div class="dropMenu" id="approval_view_dropMenuBtn">
					<a class="btn_exmenu" onclick="mobile_approval_showExtMenu();"><span><!-- 확장메뉴 --></span></a>
				</div>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="approval_view_content">
		<div class="post_title">
	        <p class="post_location" id="approval_view_formname"></p> <!-- 양식명 -->
	      	<h2 class="tit" id="approval_view_formsubject"></h2> <!-- 양식제목 -->
	      	<a class="thumb" id="approval_view_initiatorphoto"></a>
	      	<p class="info"><a class="name" id="approval_view_initiatorname"></a></p>
	      	<p class="info"><span class="date" id="approval_view_initiatedate"></span></p>
	      </div>
	      
	      <div id="approval_view_fileArea"></div> <!-- 첨부파일 -->
	      
	      <div id="board_view_watermarkbody" class="watermarked" data-watermark="${WaterMark}">
		      <div class="post_cont" id="approval_view_showContent">
		      	<div id="FormBody" style="display: none;">
					<div class="form_wrap">
						<!-- 메뉴가 들어 올 영역 -->
						<%-- 히스토리 보기 시 메뉴영역 그리지 않는다.--%>
						${strMenuTempl}
				
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
				
				
													<!-- 첨부 부분이 들어 올 곳 -->
													${strAttachTempl}
				
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
				
											</td>
										</tr>
									</thead>
								</table>
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
					<div style="background: rgb(0, 0, 0); left: 0px; top: 0px; width: 100%; height: 1296px; position: fixed; z-index: 149; opacity: 0; filter: progid:DXImageTransform.Microsoft.Alpha(opacity=0); -ms-filter:'progid:DXImageTransform.Microsoft.Alpha(opacity=0)'; " id="loading_overlay"></div>
					<div id="divLoading" style="text-align:center;z-index:10;background-color:red;margin:0 auto;position:absolute; top:16%; left:50%; height:20px; margin-left:-10px; margin-top:-10px; ">
						<img src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/loding12.gif" style="text-align:center;" />
					</div>
				</div>
			</div>
		</div>
		<div class="fixed_btm_wrap">
			<div class="approval_comment" id="approval_view_commentarea"> <!--  비밀번호 입력 칸 추가 시 secret 클래스 추가-->
				<a class="btn_toggle" onclick="mobile_approval_clickbtn(this, 'toggle');"></a>
				<div class="comment_inner">
					<input type="password" id="approval_view_inputpassword" name="" value="" placeholder="<spring:message code='Cache.msg_enter_PW'/>" style="display: none;"> <!-- 비밀번호를 입력하여 주십시오. -->
					<div class="txt_area">
						<textarea name="name" id="approval_view_inputcomment" placeholder="<spring:message code='Cache.msg_apv_161'/>"></textarea> <!-- 의견을 입력하세요 -->
						<a onclick="mobile_approval_doOK();" class="g_btn_sm"><spring:message code='Cache.btn_Confirm'/></a> <!-- 확인 -->
					</div>
				</div>
			</div>
			<div class="btn_wrap" id="approval_view_buttonarea">
			</div>
		</div>
	</div>
</div>