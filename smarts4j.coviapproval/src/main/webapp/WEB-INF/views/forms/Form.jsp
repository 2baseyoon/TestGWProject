<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@page import="egovframework.coviframework.util.RedisDataUtil"%>
<% String as = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt")); %>
<% String aI = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv")); %>
<% String ak = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize")); %>
<% int ac = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount"))); %>
<% int app = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase"))); %>

<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<%
	pageContext.setAttribute("isUseMultiEdit", request.getAttribute("strUseMultiEditYN"));
	pageContext.setAttribute("isUseAccount", RedisDataUtil.getBaseConfig("isUseAccount"));
	pageContext.setAttribute("isUseBizMnt", RedisDataUtil.getBaseConfig("isUseBizMnt"));
	pageContext.setAttribute("IsUseCRM", RedisDataUtil.getBaseConfig("IsUseCRM"));
	pageContext.setAttribute("isCSTFPreview", request.getAttribute("isCSTFPreview"));
	pageContext.setAttribute("isUseCollabApproval", RedisDataUtil.getBaseConfig("isUseCollabApproval"));
%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<head>
	<title></title>
	
	<!--CSS Include Start -->
	<!-- 공통 CSS  -->
	<jsp:include page="/WEB-INF/views/cmmn/PopupInclude.jsp"></jsp:include>
	
	<!-- 양식개선 새 컴포넌트용 CSS (Xeasy) -->
	<link type="text/css" rel="stylesheet" href="<%=cssPath%>/approval/resources/css/xeasy/xeasy.0.9.css<%=resourceVersion%>" />
	<!--CSS Include End -->
	
	<!--JavaScript Include Start -->
	<!-- 공통 JavaScript  -->	

	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.editor.js<%=resourceVersion%>"></script>
<%-- 	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.dic.js<%=resourceVersion%>"></script> --%>
	<script type="text/javascript" src="/approval/resources/script/user/common/ApprovalUserCommon.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>
	
	<c:if test="${isUseAccount eq 'Y'}">
		<script type="text/javascript" src="/account/resources/script/user/accountCommon.js<%=resourceVersion%>"></script>
		<script type="text/javascript" src="/account/resources/script/user/accountFileCommon.js<%=resourceVersion%>"></script>
		<script type="text/javascript" src="/account/resources/script/common/account.control.js<%=resourceVersion%>"></script>
	</c:if>
	
	<c:if test="${isUseBizMnt eq 'Y'}">
		<script type="text/javascript" src="/bizmnt/resources/script/user/bizmntApproval.js<%=resourceVersion%>"></script>
	</c:if>	
	<c:if test="${IsUseCRM eq 'Y'}">
		<script type="text/javascript" src="/crm/resources/script/user/crmMntApproval.js<%=resourceVersion%>"></script>
	</c:if>
	
	<!-- 양식 Javascript -->
	<script type="text/javascript" src="resources/script/forms/Form.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/FormBody.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/FormAttach.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/FormApvLine.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/FormMenu.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/MultiApvUtil.js<%=resourceVersion%>"></script>
	
	<c:if test="${isUseMultiEdit eq 'Y'}">
		<!-- 다안기안 관련 Javascript -->
		<script type="text/javascript" src="resources/script/forms/MultiApvUtil.js<%=resourceVersion%>"></script>
		<script type="text/javascript" src="resources/script/forms/MultiCtrl.js<%=resourceVersion%>"></script>
	</c:if>

	<!-- 양식스토어 미리보기 기본 js -->
	<c:if test="${isCSTFPreview eq 'Y'}">
		<script type="text/javascript" src="resources/script/forms/CSTFPreview.js<%=resourceVersion%>"></script>
	</c:if>
	
	<!-- 양식개선 새 컴포넌트 모음 -->
	<script type="text/javascript" src="resources/script/xeasy/xeasy-number.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/xeasy/xeasy-numeral.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/xeasy/xeasy-timepicker.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/xeasy/xeasy.multirow.0.9.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/xeasy/xeasy4j.0.9.2.js<%=resourceVersion%>"></script>

	<!-- 추가 외부 Library 모음 -->
	<script type="text/javascript" src="resources/script/forms/json2.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/underscore.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/jquery.xml2json.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/approval/resources/script/user/common/govDocHWPFilter.js<%=resourceVersion%>"></script>
	<!-- JqGid 관련 Library 모음 -->
	<!-- <script type="text/javascript" src="resources/script/forms/jquery.jqGrid.4.6.0.src.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/jquery.jqGrid.locale-kr.js<%=resourceVersion%>"></script> -->
	<!--JavaScript Include End -->
	<script type="text/javascript" src="/covicore/resources/script/security/AesUtil.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/aes.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/pbkdf2.js<%=resourceVersion%>"></script>
	
	<c:if test="${isUseCollabApproval eq 'Y'}">
		<script type="text/javascript" src="/groupware/resources/script/user/collab_util.js<%=resourceVersion%>"></script>
	</c:if>
	
	<script type="text/javascript">
		// 서버에서 문서변환시 해당스크립트를 호출하여 HTML을 가져간다.
		// 1) EDMS 이관
		// 2) 협업업무 등록
	 	function getPcSaveHtml(){
			$("#AppLine").attr('align', 'right');
			$("#RApvLine").attr('align', 'right');
			
		    isServer = true;
		    bDisplayOnly = true;
		    bPresenceView = false;
		    initApvList();
		    
		    var printDiv = getBodyHTML("PcSave", isServer);
		    printDiv = printDiv.replace("<thead>","")/*.replace("min-height","height")*/;
		    return printDiv;
	 	}
	</script>
</head>
<body scroll="auto">
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
	          				<td class="wordLeft" style="padding-top: 0px;"><!--문서양식 왼쪽 시작-->
	           					 <h2><span id="headname" class="apptit_h2 fsbTop"></span></h2>
	           					 
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

										<!-- 문서 안 결재선 부분 들어 올 곳 -->
										${strAddInApvLineTempl}
										
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
									<input type="hidden" ID="hidFileSeq"/>

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
				<div class="conin_view" style="left:790px;position: fixed; top:70px;"><!-- 좌우 폭 조정에 따라 값 변경(좌측 width값) -->
					<!-- 좌우폭 조정 Bar시작 -->
					<div class="xbar"></div>
					<!-- 좌우폭 조정 Bar 끝 -->
					<!--문서양식 오른쪽 시작-->
					<div class="wordView" style="height: calc(100% - 91px);">
						<iframe id="IframePreview" name="IframePreview" frameborder="0" width="100%" height="100%" scrolling="no"></iframe>
						<input type="hidden" id="previewVal" value="">						
					</div>
					<!--문서양식 오른쪽 끝-->
			  	</div>
			</div>
			<div style="display: none; position: fixed; top: 100px; left: 800px; width: 46%;" id="evidPreview">			
				<div class="conin_view">
					<div class="e_formRTitle">
						<span class="e_TitleText"></span>
						<span class="e_TitleBtn">
							<span class="pagecount"><span class="countB" id="previewCurrentPage"></span>/<span id="previewTotalPage"></span></span>
							<span class="pagingType01"><a onclick="clickPaging(this);" class="pre"></a><a onclick="clickPaging(this);" class="next"></a></span>
						</span>
					</div>
					<div class="e_formRCont" id="evidContent">
						<div class="billW" style="display: none;"></div>
						<div class="invoice_wrap" style="width:910px; display: none;"></div>
						<input type="hidden" id="hidReceiptID" value="">			
					</div>
					<div class="wordView" id="fileContent">
						<iframe id="e_IframePreview" name="IframePreview" frameborder="0" width="100%" height="800px" scrolling="no"></iframe>
						<input type="hidden" id="e_previewVal" value="">						
					</div>
				</div>
			</div>
		</div>
		<div id="divFileDownload" style="display:none;">
			<iframe id="frmFileDownload" width="1" height="1"></iframe>
		</div>
	</div>

	<!-- 로딩 이미지  -->
<!-- 	<div style="background: rgb(0, 0, 0); left: 0px; top: 0px; width: 100%; height: 1296px; position: fixed; z-index: 149; opacity: 0; filter: progid:DXImageTransform.Microsoft.Alpha(opacity=0); -ms-filter:'progid:DXImageTransform.Microsoft.Alpha(opacity=0)'; " id="loading_overlay"></div> -->
<!-- 	<div id="divLoading" style="text-align:center;z-index:10;background-color:red;margin:0 auto;position:absolute; top:16%; left:50%; height:20px; margin-left:-10px; margin-top:-10px; "> -->
<!-- 		<img src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/loding12.gif" style="text-align:center;" /> -->
<!-- 	</div> -->
</div>
</body>

<!-- 에디터 스크립트 -->
${strEditorSrc}

<!-- 각 양식 JS 파일 -->
<script type="text/javascript" >
${strBodyTemplJS}
</script>

<script type="text/javascript" language="javascript">
	var strSuccessYN = ${strSuccessYN};
	//ready -> load
	$(document).ready(function () {
		 // 양식을 열지 않음 처리 (서명 여부, workitem 값 등 확인 처리)
		var strErrorMsg = "${strErrorMsg}";
		if(strSuccessYN == false){
			Common.Warning(strErrorMsg, "Warning", function(){
				Common.Close();
			}); 
		}
	});

	var admintype = CFN_GetQueryString("admintype");
	var gLngIdx = ${strLangIndex};
	
	var g_szEditable = false;//작성창 open 여부
	var openMode = "B"; //L:Layer PopUp, W : window open --%>

	var openID = CFN_GetQueryString("CFN_OpenLayerName");

	<%-- 비사용
	 var gUseEditYN = "";"<%= gUseEditYN %>"; --%>
	//히스토리 기능 처리를 위한 변수 선언
	var gIsHistoryView = CFN_GetQueryString("ishistory");
	var gHistoryRev = CFN_GetQueryString("historyrev");

	//첨부파일UX통일 시작
	var g_LimitFileSize = ""; <%-- parseInt("<%=sMaxUnitSize %>"); //업로드할 수 있는 개별 파일의 최대 용량임.(Byte) --%>
	var g_LimitFileCnt = ""; <%-- parseInt("<%=sMaxUpload %>"); //최대 업로드 개수 --%>

	var strStorage = ""; <%-- '<%=strStorage%>'; --%>
	//첨부파일UX통일 끝
	var varInkCNT = ""; <%-- '<%=inkCNT%>'; --%>
	var inkvisit = 0;

	var gMailDomain = ""; <%-- "<%=System.Configuration.ConfigurationManager.AppSettings["WF_MailDomain"]  %>"; --%>
	var g_szBaseURL = ""; <%-- "<%=Covi.Framework.ConfigurationManager.GetBaseConfig("MailCountUrl") %>"; --%>
	var bMailUse = Common.getBaseConfig("MailUse"); // 메일보내기 사용 유무
	var gFileAttachType = "";<%-- "<%=Covi.Framework.ConfigurationManager.GetBaseConfig("FileAttachType") %>"; //첨부파일 컴퍼넌트 타입 체크 --%>
	var gPrintType = "1";
	var gDocboxMenu = Common.getBaseConfig("DocboxMenu"); <%--  "<%=Covi.Framework.ConfigurationManager.GetBaseConfig("DocboxMenu") %>"; --%>

	var PopUpWidth = 120;
	//팀장 여부 체크하기  Y/N(Y이면 팀장)
	var gManagerYN = ""; <%-- "<%= GetManagerYN() %>"; --%>
	var gDeputyType = ""; <%-- "<%=strDeputyType %>";//대결타입 T:대결자대결기간설정 --%>

	var gFormFavoriteYN = "${strFormFavoriteYN}";  //즐겨찾기 여부 추가(2014-05-29 leesh) --%>
	var strApvLineYN = "${strApvLineYN}";

	// [2015-07-20 han add] 양식팝업창 title 변경
	var _strAppName = "${AppName}";

	var tableLineMax = Common.getBaseConfig("ApprovalLineMax_Table"); //테이블형 결재선 표시 최대 수

	var useFido = "${useFido}";
	var proaas = "<%=as%>";
	var proaaI = "<%=aI%>";
	var proaapp = "<%=app%>";
	var aesUtil = new AesUtil("<%=ak%>", "<%=ac%>");
	var formDraftkey = "${formDraftkey}";
     //아래 함수에서 전역 변수 선언(지움. 기존 .net 소스 참조)
	
     //통합 Data json Object
     var formJson = "${formJson}";
     ${formJsonForDev}
     
     var orgBodyContext = {};

     $(window).load(function () {
    	 if(strSuccessYN == false){ return false; }
    	 if (!_ie) {
             if (navigator.userAgent.toLowerCase().indexOf("edge/") > -1) 
                 window.resizeTo(window.outerWidth, screen.availHeight - 50); //2020.04.27 dgkim 사이즈폭 수정 
             else
                 window.resizeTo(window.outerWidth, screen.availHeight); // chrome, safari 의 팝업 높이가 더 커서 팝업후 재조정
         }

         //underscore binding 시작 부분
         //escape 문자 설정
         _.templateSettings = {
             variable: "doc",
             interpolate: /\{\{(.+?)\}\}/g,      // print value: {{ value_name }}
             evaluate: /\{%([\s\S]+?)%\}/g,   // excute code: {% code_to_execute %}
             escape: /\{%-([\s\S]+?)%\}/g
         }; // excape HTML: {%- <script> %} prints &lt;script&gt;

        formJson = Base64.b64_to_utf8(formJson);
        formJson = JSON.parse(formJson);
        formJson = $.extend({}, formJson, returnLangUsingLangIdx(gLngIdx)); // 양식 내 json 다국
        
         //미리보기 데이터 처리

         //레이어 팝업 , 윈도우 팝업 구분
         var m_oInfoSrc;
         if (openID != "") {//Layer popup 실행
             //var openID = getInfo("FormInfo.FormID");
             if ($("#" + openID + "_if", parent.document).length > 0) {
                 m_oInfoSrc = $("#" + openID + "_if", parent.document)[0].contentWindow;
             } else { //바닥 popup
                 m_oInfoSrc = parent;
             }
         } else {
             m_oInfoSrc = top.opener;
         }


         try {
             var openerLoc = m_oInfoSrc.location.href.toString();
             /* if (openerLoc.indexOf('Form.aspx') > -1) { */
            if (openerLoc.indexOf('approval_Form.do') > -1 || openerLoc.indexOf('approval_CstfForm.do') > -1) {
                 if (getInfo("Request.readtype") == 'preview' || getInfo("Request.readtype") == 'Pubpreview' || getInfo("Request.readtype") == 'Print' || getInfo("Request.readtype") == 'govpreviewWrite') {
                     setPreViewData();
                 }
                 else if (getInfo("Request.readtype") == 'openwindow') {
                     setOpenWindowData();
                 }
             }
         } catch (e) { }

         //data에 대한 수정이 필요한 부분을 처리
         commonDataChanger();
		
         // Grab the HTML out of our template tag and pre-compile it.
         //var templateHtml = $("script.template").html();
         var templateHtml = $("#FormBody").html();

         //template 내의 underscore 구문의 정합성을 체크하는 부분
         //underscore binding 부분은 {{ doc.~~ }} 형태를 준수 할 것
         // 23.09.20 수신함, 발송완료 delay 걸리는 오류 수정
         // templateHtml = validateUnderscore(templateHtml);
         if(getInfo("Request.mode") != "GOVACCEPT") {
        	 templateHtml = validateUnderscore(templateHtml);
         }
         

         var templateObject = $(templateHtml);
         var template = _.template(
             templateHtml
         );

         $("#FormBody").html(
                 template(formJson)
             );
         
         $('#FormBody').show();
         $('#loading_overlay').hide();
         $('#divLoading').hide();
		
         if (m_oInfoSrc != null && gIsHistoryView != 'true') {
             try {

                 //미리보기 후 처리
                 //신세계 Layer 수정 적용
                 //2016-06-08
                 //YJYOO
                 var openerLoc = m_oInfoSrc.location.href.toString();
                 // [2015-10-15 leesm] readtype=print 조건 추가(결재선 및 불필요한 버튼들 제거하기 위함)
                if ((openerLoc.indexOf('approval_Form.do') > -1 || openerLoc.indexOf('approval_CstfForm.do') > -1) && (getInfo("Request.readtype") == 'preview' || getInfo("Request.readtype") == 'Print')) {
                     setPreViewPostRendering();
                     //양식 별 후처리에 대한 부분을 고려한 호출
                     postRenderingForTemplate();
                 }
                 else if ((openerLoc.indexOf('approval_Form.do') > -1 || openerLoc.indexOf('approval_CstfForm.do') > -1) && getInfo("Request.readtype") == 'openwindow') {
                     setOpenWindowPostRendering();
                     //양식 별 후처리에 대한 부분을 고려한 호출
                     postRenderingForTemplate();
                 }else if(openerLoc.indexOf('approval_Form.do') > -1 && ( (getInfo("Request.readtype") == 'govpreview' || getInfo("Request.readtype") == 'govpreviewWrite') || getInfo("Request.menukind") == "notelist" && getInfo("SchemaContext.scDistribution.isUse")=="Y" && getInfo("ExtInfo.UseEditYN") == "Y")){
                	//양식 별 후처리에 대한 부분을 고려한 호출
                	setGovView();
                 }else {
                     postLoad();
                 }
             } catch (e) { postLoad(); }
         }
         else {
             //히스토리 리스트에서 양식을 여는 경우
             // 레이어 변경 작업
             if (gIsHistoryView == 'true') {
                 setHistoryMenu();
                 //양식 별 후처리에 대한 부분을 고려한 호출
                 postRenderingForTemplate();
             }
             else {
                 postLoad();
             }
         }

         //Legacy Data 처리
         /* initLegacyData(); */
			
       	 //Form load 완료후 정상작동시 unread count 갱신 및 제목 굵기 속성 변경처리
       	 //문서이관시 서버에서 해당 page 호출 (PDF변환)
       	 <c:if test="${param.callMode != 'PDF'}">
       	 setSubjectHighlight();
         </c:if>
         //삭제 하지 말 것
         EASY.init(); // - required!!!
         
         if("${ArchiveStored}" == "true"){
        	 // Stored 문서는 버튼최소화
        	 $(".topWrap > input[type=button]").hide();
        	 $(".topWrap > #btLine,#btPrint").show();
        	 
        	 $("#divMenu02 > li").hide();
        	 $("#divMenu02 > #btPcSave,#btComment,#btHistory").show();
         }

         // 2022-10-20 한글 웹 기안기에선 setOrgBodyContext 미사용
         // 2022-11-22 기안/임시저장일때는 본문 값 비교 필요없음.
         // 에디터가 있는양식은 에디터 로드 후 셋팅(setEditor)
         if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE" || getInfo("ExtInfo.UseHWPEditYN") == "Y"
        		 || (formJson && formJson.BodyContext && formJson.BodyContext.tbContentElement)) {
         } else {
        	 setOrgBodyContext();
         }
         
         // 2022-11-15 작성자 영역에 FlowerName 추가
         if ($('#InitiatorDisplay').length == 1) {
     		$('#InitiatorDisplay').html(setUserFlowerName(getInfo("FormInstanceInfo.InitiatorID"), m_oFormMenu.getLngLabel(getInfo("FormInstanceInfo.InitiatorName"), false), 'upTdOverflow'));
     	}
     });
     
     function setOrgBodyContext() {
    	 try {
    		 var timer = setInterval(function(){
				 orgBodyContext = getBodyContext();
				 if(getInfo("Request.editmode") != "Y" || JSON.stringify(orgBodyContext) == "{}" || typeof orgBodyContext.BodyContext.tbContentElement == "undefined" || orgBodyContext.BodyContext.tbContentElement != "") {
					 clearInterval(timer);
				 }
					
			 }, 1000);
    	 } catch (e) {
    		 clearInterval(timer);
    	 }
     }

     function postLoad() {
        //편집모드에서 제목 특수기호 < > " 처리
        // [16-02-24] kimhs, 관리자에서 읽기미리보기 시 지정된 SUBJECT가 없어 조건 추가
        if (getInfo("FormInstanceInfo.Subject") != undefined && (getInfo("Request.editmode") == 'Y' || getInfo("Request.templatemode") == "Read")) {
             setInfo("FormInstanceInfo.Subject", getInfo("FormInstanceInfo.Subject").replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"'));
             $("#Subject").val(getInfo("FormInstanceInfo.Subject"));
        }
        
        if(getInfo('ExtInfo.UseMultiEditYN') == "Y" && getInfo('ExtInfo.UseHWPEditYN') == "Y"){
     		//한글에디터 결재선 업데이트
			$("#APVLIST").on({
				"change": function() {
					drawApvLineHWP();
				}
			});
			$('.fsbTop').hide();
     	}

        if (formJson.AppInfo.usid != null || formJson.AppInfo.usid != '') {
        	var sMenuKind = getInfo("Request.menukind");
        	
             //sMenuURL 값은 스키마에 따라 분기처리
             if (sMenuKind == "") {
                 initOnloadformmenu();
                 initOnloadformedit();

                 //양식 별 후처리에 대한 부분을 고려한 호출
                 postRenderingForTemplate();

                 // XForm 조회연동 시작
                 if (getInfo("$.Request.templatemode") == "Write" && formJson.Request.mode == "DRAFT"){

                	 var viewlink_count = 0; // XForm 조회연동 여부

                	$('*[ext-data-type1="viewlink_d_text"]').each(function () {
                		 viewlink_count = viewlink_count + 1;
					});

                	 if (viewlink_count > 0) {
                		 $('*[ext-data-type1="viewlink_d_text"]').each(function () {

                			 // 연결정보

                			 var strConnectString = $(this).attr('ext-data-type2');
                			 // 연동 필드 수만큼 쿼리 호출
                			 var strTable = $(this).attr('ext-data-type3');
                			 var strField = $(this).attr('ext-data-type4');
                			 var strParameter1 = $(this).attr('ext-data-param1');
                			 var strParameter2 = $(this).attr('ext-data-param2');
                			 var strParameter3 = $(this).attr('ext-data-param3');
                			 var strParameter4 = $(this).attr('ext-data-param4');
                			 var strParameter1_value = "";
                			 var strParameter2_value = "";
                			 var strParameter3_value = "";
                			 var strParameter4_value = "";

                			 // 파라미터값 세팅
                			 if (strParameter1 != "") {
                				 strParameter1_value = CFN_GetQueryString(strParameter1);
                			 }
                			 if (strParameter2 != "") {
                				 strParameter2_value = CFN_GetQueryString(strParameter2);
                			 }
                			 if (strParameter3 != "") {
                				 strParameter3_value = CFN_GetQueryString(strParameter3);
                			 }
                			 if (strParameter4 != "") {
                				 strParameter4_value = CFN_GetQueryString(strParameter4);
                			 }

                			 var strResult = "";
                			 if (strConnectString != "" && strTable != "" && strField != "" && strParameter1 != "" && strParameter1_value != "undefined") {
                				 $.ajax({
                					 type:"POST",
                					 url:"xform/getDataSelect.do",
                					 data:{
                						 "connect":strConnectString,
                						 "tableName":strTable,
                						 "columnName":strField,
                						 "param1":strParameter1,
                						 "paramValue1":strParameter1_value,
                						 "param2":strParameter2,
                						 "paramValue2":strParameter2_value,
                						 "param3":strParameter3,
                						 "paramValue3":strParameter3_value,
                						 "param4":strParameter4,
                						 "paramValue4":strParameter4_value
                					},
                					async: false,
                					success:function (data) {
                						if(data!= null && data.result=="ok"){
                							if(data.Table.indexOf('ERROR')==0){
                								alert(data.Table);
                								return;
                							}
                							var oJson = data.Table;
                							for (var i = 0; oJson.Table.length > i; i++) {
                								if (strResult == "") {
                									strResult = oJson.Table[i][strField];
                								} else {
                									strResult = strResult + ", " + oJson.Table[i][strField];
                								}
                							}
                						}
                					},
                					error:function(response, status, error){
                						CFN_ErrorAjax("xform/getDataSelect.do", response, status, error);
                					}
                				});
                			}
                			$(this).attr('value', strResult);
                		});
                	}
                }
                // XForm 조회연동 끝

                 //첨부파일UX통일-첨부파일 컨트롤 및 기본 값 채우기
                 //첨부파일 정리 후 하단 정리 할 것
                 if (getInfo("Request.templatemode") == "Write") {
                     controlDisplaySetFIleInfo();   // 기존 첨부파일 정보 바인드(CoviFileTrans 와 Basic Upload)
                     controlDisplaySetMultiFIleInfo(); // 다안기안 첨부파일 정보 바인드
                     
                     try { docLinks.init(1); } catch(e) {}
                 }

                 //참조회람 읽음 처리, 서버단에서 읽음 확인과 함께 진행.
            }
            else if (sMenuKind == "notelist") {
                 //문서대장 처리양식
                 initOnloadformmenu_notelist();
                 
                 // 다안기안 + 문서유통일때 처리
                 if (typeof (isGovMulti) == 'function' && isGovMulti()) {
                	 initOnloadformedit();
                 } else {
                	 initForm();
                 }
                 
                 //양식 별 후처리에 대한 부분을 고려한 호출
                 postRenderingForTemplate();
                 
                 //첨부파일UX통일-첨부파일 컨트롤 및 기본 값 채우기
                 //첨부파일 정리 후 하단 정리 할 것
                 if (getInfo("Request.templatemode") == "Write") {
                     controlDisplaySetFIleInfo();   // 기존 첨부파일 정보 바인드(CoviFileTrans 와 Basic Upload)
                     controlDisplaySetMultiFIleInfo(); // 다안기안 첨부파일 정보 바인드
                     
                     try { docLinks.init(1); } catch(e) {}
                 }
             }
             /* else {
                 //모바일 메뉴에 대한 처리
                 initOnloadformmenu_ext();
                 //양식 별 후처리에 대한 부분을 고려한 호출
                 postRenderingForTemplate();
             } */
             
             // $(document.body).append("<input type='hidden' id='load_complete_s' />");
         }
        $(document.body).append("<input type='hidden' id='load_complete_s' />");
    }
     
 	function displayTop(){ // 한글 기안양식 상단 결재선/기본정보 숨기기(기본)
 		if($('.fsbTop').css("display") == "none"){
 			$('.fsbTop').show();
 		} else {
 			$('.fsbTop').hide();
 		}
 	}

  </script>
