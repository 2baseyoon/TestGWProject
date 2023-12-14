<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String ProcessID 			= StringUtil.replaceNull(request.getParameter("processID"),"");
	String WorkItemID 			= StringUtil.replaceNull(request.getParameter("workitemID"),"");
	String PerformerID 			= StringUtil.replaceNull(request.getParameter("performerID"),"");
	String ProcessDescriptionID = StringUtil.replaceNull(request.getParameter("processdescriptionID"),"");
	String FormTempInstBoxID 	= StringUtil.replaceNull(request.getParameter("formtempinstboxID"),"");
	String FormInstID 			= StringUtil.replaceNull(request.getParameter("forminstanceID"),"");
	String FormID 				= StringUtil.replaceNull(request.getParameter("formID"),"");
	String FormInstTableName 	= StringUtil.replaceNull(request.getParameter("forminstancetablename"),"");
	String Mode 				= StringUtil.replaceNull(StringUtil.replaceNull(request.getParameter("mode")).toString(),"");
	String Gloct 				= StringUtil.replaceNull(request.getParameter("gloct"),"");
	String Subkind 				= StringUtil.replaceNull(request.getParameter("subkind"),"");
	String Archived 			= StringUtil.replaceNull(request.getParameter("archived"),"");
	String UserCode 			= StringUtil.replaceNull(request.getParameter("userCode"),"");
	String Usisdocmanager 		= StringUtil.replaceNull(request.getParameter("usisdocmanager"),"");
	String Admintype 			= StringUtil.replaceNull(request.getParameter("admintype"),"");
	String Listpreview 			= StringUtil.replaceNull(request.getParameter("listpreview"),"");
	String Readtype				= StringUtil.replaceNull(request.getParameter("Readtype"), "");
%>
<div data-role="page" id="approval_preview_page">

	<!-- 각 양식 JS 파일 -->
	<!-- 에디터 스크립트 -->
	<script type="text/javascript" >

		${formJsonForDev}
		
		var gFormFavoriteYN = "${strFormFavoriteYN}";
		var strApvLineYN = "${strApvLineYN}";
		var strErrorMsg = "${strErrorMsg}";
		var strSuccessYN = "${strSuccessYN}";
	
		var formJson = "${formJson}";
		
		var processdesJson = ${processdesJson};
		var forminstanceJson = ${forminstanceJson};
		
		if(strSuccessYN == false){
			alert(strErrorMsg);
			window.close();
		}

		var admintype = mobile_comm_getQueryString("admintype");

		var g_szEditable = false;//작성창 open 여부
		var gLngIdx = ${strLangIndex}; 
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
		
	<%-- ${strEditorSrc} --%>	

	<div data-role="content" class="cont_wrap" id="approval_preview_content" style="padding-top: 0px">
	
		<div id="board_view_watermarkbody" class="watermarked" data-watermark="${WaterMark}">
		    <div class="post_cont" id="approval_preview_showContent">
		      	<div id="FormBody" style="display:none;">
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
					<!-- <div style="background: rgb(0, 0, 0); left: 0px; top: 0px; width: 100%; height: 1296px; position: fixed; z-index: 149; opacity: 0; filter: progid:DXImageTransform.Microsoft.Alpha(opacity=0); -ms-filter:'progid:DXImageTransform.Microsoft.Alpha(opacity=0)'; " id="loading_overlay"></div>
					<div id="divLoading" style="text-align:center;z-index:10;background-color:red;margin:0 auto;position:absolute; top:16%; left:50%; height:20px; margin-left:-10px; margin-top:-10px; ">
						<img src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/loding12.gif" style="text-align:center;" />
					</div> -->
				</div>
			</div>
			
		</div>
	</div>
		
	<div class="bg_dim" style="display: none;"></div>
</div>