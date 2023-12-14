<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<head>
	<meta http-equiv="content-type" content="text/html">
	<title></title>

	<!-- 양식 Javascript -->
	<script type="text/javascript" src="resources/script/forms_M/Form.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms_M/FormBody.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms_M/FormAttach.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms_M/FormApvLine.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms_M/FormMenu.js<%=resourceVersion%>"></script>

	<!-- 양식개선 새 컴포넌트 모음 -->
	<link type="text/css" rel="stylesheet" href="<%=cssPath%>/approval/resources/css/xeasy/xeasy.0.9.css<%=resourceVersion%>" />
	<script type="text/javascript" src="resources/script/xeasy/xeasy-number.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/xeasy/xeasy-numeral.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/xeasy/xeasy-timepicker.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/xeasy/xeasy.multirow.0.9.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/xeasy/xeasy4j.0.9.2.js<%=resourceVersion%>"></script>

	<!-- 추가 외부 Library 모음 -->
	<script type="text/javascript" src="resources/script/forms/json2.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/underscore.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/jquery.xml2json.js<%=resourceVersion%>"></script>

	<!-- JqGid 관련 Library 모음 -->
	<script type="text/javascript" src="resources/script/forms/jquery.jqGrid.4.6.0.src.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="resources/script/forms/jquery.jqGrid.locale-kr.js<%=resourceVersion%>"></script>
	
</head>
<body scroll="auto">
<div id="FormBody" style="display:none;">
	<div class="form_wrap">
		<!-- 메뉴가 들어 올 영역 -->
		<%-- 히스토리 보기 시 메뉴영역 그리지 않는다.--%>
		${strMenuTempl}
		<!-- 양식 상단 끝 -->
		<!-- 양식 본문 시작 -->
		<div id="bodytable" class="wordCont" ><!-- 상단 영역 확장시 높이 변경(추후 알려드리겠습니다.) -->
			<div class="form_box" id="formBox">
	    		<table class="wordLayout">
	      			<colgroup>
	      				<col style="*" />
	      			</colgroup>
	      			<thead>
	        			<tr>
	          				<td class="wordLeft"><!--문서양식 왼쪽 시작-->
	          					<h2 id="h2_headname"><span id="headname" class="apptit_h2"></span></h2>
	          				
 					           	<div id="editor" name="editor">
		           					 <div id="bodytable_content">
		           					 <!-- 결재문서 Top 영역이 들어 올 곳 -->
                                     <iframe id="frmHTML" width="100%" height="810px" style="display: none; width: 100%"></iframe>		           					 	
                                     <div id="divHTML" width="100%" height="810px" style="display: none;"></div>
										<!-- common fields template 들어 올 곳 -->
										${strCommonFieldsTempl}

										<!-- 양식 상단 부분 들어 올 곳 -->

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
				<div class="conin_view" style="left:790px;position: absolute;"><!-- 좌우 폭 조정에 따라 값 변경(좌측 width값) -->
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
</body>

<!-- 에디터 스크립트 -->

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

	var admintype = CFN_GetQueryString("admintype");<%-- '<%=Request.QueryString["admintype"]%>'; --%>
	<%-- 비사용
	 var rel_activityid =""; '<%=Request["TaskID"] %>';
	var rel_activityname = "";'<%=Request["TaskName"]%>'; --%>
	<%-- 비사용
	var gLngIdx = "";parseInt("<%=strLangIndex %>"); --%>

	var g_szEditable = false;//작성창 open 여부
	var openMode = "B";<%-- '<%=openMode %>';//L:Layer PopUp, W : window open --%>

	var openID = CFN_GetQueryString("CFN_OpenLayerName");

	<%-- 비사용
	 var gUseEditYN = "";"<%= gUseEditYN %>"; --%>
	//히스토리 기능 처리를 위한 변수 선언
	var gIsHistoryView = CFN_GetQueryString("ishistory"); <%-- "<%= sHistory %>"; --%>
	var gHistoryRev = ""; <%-- "<%= sHistoryRev %>"; --%>

	//첨부파일UX통일 시작
	var g_LimitFileSize = ""; <%-- parseInt("<%=sMaxUnitSize %>"); //업로드할 수 있는 개별 파일의 최대 용량임.(Byte) --%>
	var g_LimitFileCnt = ""; <%-- parseInt("<%=sMaxUpload %>"); //최대 업로드 개수 --%>

	var strStorage = ""; <%-- '<%=strStorage%>'; --%>
	//첨부파일UX통일 끝
	var varInkCNT = ""; <%-- '<%=inkCNT%>'; --%>
	var inkvisit = 0;

	var gMailDomain = ""; <%-- "<%=System.Configuration.ConfigurationManager.AppSettings["WF_MailDomain"]  %>"; --%>
	var g_szBaseURL = ""; <%-- "<%=Covi.Framework.ConfigurationManager.GetBaseConfig("MailCountUrl") %>"; --%>
	var bMailUse = "";<%-- "<%=Covi.Framework.ConfigurationManager.GetBaseConfig("MailUse") %>"; --%>
	var gFileAttachType = "";<%-- "<%=Covi.Framework.ConfigurationManager.GetBaseConfig("FileAttachType") %>"; //첨부파일 컴퍼넌트 타입 체크 --%>
	var gPrintType = "1";
	var gDocboxMenu = ""; <%--  "<%=Covi.Framework.ConfigurationManager.GetBaseConfig("DocboxMenu") %>"; --%>

	var PopUpWidth = 120;
	//팀장 여부 체크하기  Y/N(Y이면 팀장)
	var gManagerYN = ""; <%-- "<%= GetManagerYN() %>"; --%>
	var gDeputyType = ""; <%-- "<%=strDeputyType %>";//대결타입 T:대결자대결기간설정 --%>

	/* var tableLineMax = ""; */ <%-- "<%=Covi.Framework.ConfigurationManager.GetBaseConfig("ApprovalLineMax_Table") %>"; //테이블형 결재선 표시 최대 수 --%>

	var gFormFavoriteYN = "${strFormFavoriteYN}";  //즐겨찾기 여부 추가(2014-05-29 leesh) --%>
	var strApvLineYN = "${strApvLineYN}";

	// [2015-11-17 modi] 로드되기 전에 구문이 실행되서 "$(window).load(function () {" 함수 내부로 이동
	//if(!_ie) window.resizeTo(window.outerWidth, screen.availHeight); // chrome, safari 의 팝업 높이가 더 커서 팝업후 재조정 (2013-12-16 leesh)

	// [2015-07-20 han add] 양식팝업창 title 변경
	var _strAppName = "${AppName}";

	var tableLineMax = Common.getBaseConfig("ApprovalLineMax_Table"); //테이블형 결재선 표시 최대 수
     //아래 함수에서 전역 변수 선언(지움. 기존 .net 소스 참조)
	
	//20210126 이관함 참조/회람 기능용
	var g_CirculationFiid = "";
	var g_CirculationPiid = "";
	var g_Circulationwiid = "";
	
     //통합 Data json Object
     var formJson = "${formJson}";
     ${formJsonForDev}

     $(window).load(function () {
    	 if(strSuccessYN == false){ return false; }
    	 if (!_ie) {
             if (navigator.userAgent.toLowerCase().indexOf("edge/") > -1) // [16-03-08] kimhs, Edge 팝업 사이즈 조정
                 window.resizeTo(800, screen.availHeight - 50);
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
            if (openerLoc.indexOf('approval_Form.do') > -1) {
                 if (getInfo("Request.readtype") == 'preview' || getInfo("Request.readtype") == 'Pubpreview' || getInfo("Request.readtype") == 'Print') {
                     setPreViewData();
                 }
                 else if (getInfo("Request.readtype") == 'openwindow') {
                     setOpenWindowData();
                 }
             }
         } catch (e) { }

         //data에 대한 수정이 필요한 부분을 처리
         commonDataChanger();
		
         //미리보기 : 제목일때 태그 삭제
         /* if (getInfo("Request.readtype") == 'preview') {
             setInfo("SUBJECT", getInfo("FormInstanceInfo.Subject").replace(/</g, '&lt;').replace(/>/g, '&gt;'));
         } */

         // Grab the HTML out of our template tag and pre-compile it.
         //var templateHtml = $("script.template").html();
         var templateHtml = $("#FormBody").html();

         //template 내의 underscore 구문의 정합성을 체크하는 부분
         //underscore binding 부분은 {{ doc.~~ }} 형태를 준수 할 것
         templateHtml = validateUnderscore(templateHtml);

         var templateObject = $(templateHtml);
         var template = _.template(
             templateHtml
         );

         /* 비사용
         //2015.09.11 B.K. 기간계 연동 추가
         //body context의 CDATA정리
         setCDataSection(formJson.BodyContext); */

         // template와 data binding
         /* 비사용
         $("#templateContainer").html(
             template(formJson)
         ); */
         $("#FormBody").html(
                 template(formJson)
             );
         
         $('#FormBody').show();
         $('#loading_overlay').hide();
         $('#divLoading').hide();
		
         /*비사용
         //전역변수 선언
         setGlobalVar(); */

         //아래 부분 정리
         //sMenuURL이 formmenuExt.aspx 인 경우 메뉴에 대한 처리 부분
         //template 처리로 변경

         if (m_oInfoSrc != null && gIsHistoryView != 'true') {
             try {

                 //미리보기 후 처리
                 //신세계 Layer 수정 적용
                 //2016-06-08
                 //YJYOO
                 var openerLoc = m_oInfoSrc.location.href.toString();
                 // [2015-10-15 leesm] readtype=print 조건 추가(결재선 및 불필요한 버튼들 제거하기 위함)
                 /* if (openerLoc.indexOf('Form.aspx') > -1 && (getInfo("Request.readtype") == 'preview' || getInfo("Request.readtype") == 'Print')) { */
                if (openerLoc.indexOf('approval_Form.do') > -1 && (getInfo("Request.readtype") == 'preview' || getInfo("Request.readtype") == 'Print')) {
                     setPreViewPostRendering();
                     //양식 별 후처리에 대한 부분을 고려한 호출
                     postRenderingForTemplate();
                 }/* else if (openerLoc.indexOf('Form.aspx') > -1 && getInfo("Request.readtype") == 'openwindow') { */
                 else if (openerLoc.indexOf('approval_Form.do') > -1 && getInfo("Request.readtype") == 'openwindow') {
                     setOpenWindowPostRendering();
                     //양식 별 후처리에 대한 부분을 고려한 호출
                     postRenderingForTemplate();
                 }
                 else {
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

                 /* try { document.getElementById("CommentList").style.display = "none"; } catch (e) { }
                 var strHistoryHtmlDiv = "<html><body>" + getBodyHTML() + "</body></html>";

                 if (m_oInfoSrc.parent.targetHisTory == "txtHistory1") {
                     m_oInfoSrc.parent.document.getElementById('txtHistory1').value = strHistoryHtmlDiv;
                 } else {
                     m_oInfoSrc.parent.document.getElementById('txtHistory2').value = strHistoryHtmlDiv;
                 }
                 if (m_oInfoSrc.parent.document.getElementById('txtHistory1').value != "" && m_oInfoSrc.parent.document.getElementById('txtHistory2').value != "") {
                     m_oInfoSrc.parent.launch();
                 }
                 m_oInfoSrc.parent.ToggleLoadingImage(); */
             }
             else {
                 postLoad();
             }


         }

         // 의견 숨김 
         //$("#commentListDisp").hide();

         // 20210126 이관문서 인쇄 이벤트 변경
         if (getInfo('FormInstanceInfo.BodyContext').indexOf(".mht") > -1) {
        	 $("#btPrint").removeAttr("onclick");
        	 $("#btPrint").attr("onclick", "window.frames['frmHTML'].print();");
         }
         
         // 20210126 이관문서 메일보내기 사용유무
//          if (Common.getBaseConfig("UseApprovalStore_MailSend") == "Y") {
//         	 $("#btMailSend").show();
//          }
         
         // 20210126 이관문서 연동 시스템에서 오픈 시 기능 숨김 처리
/*          if (getInfo("Request.gloct") == "") {
        	 $("#btMailSend").hide();
        	 $("#divMenu02").hide();
         } */
         
		// 이관문서 편집 금지
		//$("#btModify").hide();
         
		//20210126 이관함 참조/회람 기능용
		g_CirculationFiid = getInfo("FormInstanceInfo.FormInstID") + ";";
		g_CirculationPiid = getInfo("ProcessInfo.ProcessID") + ";";
		g_Circulationwiid = getInfo("Request.workitemID") + ";";
		
         //Legacy Data 처리
         /* initLegacyData(); */

         // [2015-08-04 han modi] 공통 로고삽입으로 인해 삭제
         // 계열사별 양식 로고 셋팅
         //setFormLogoOfEnt();
			
       	 //Form load 완료후 정상작동시 unread count 갱신 및 제목 굵기 속성 변경처리
       	 setSubjectHighlight();
         
         //삭제 하지 말 것
         EASY.init(); // - required!!!
     });
     //MhtLoad 파일을 실행하여 마이그레이션 데이터를 가져온다.시행문과 함께 있기때문에 | 로구분 하여 일반과 시행문 둘로 구분함.
      /* 1. HTML, PDF파일은 브라우저에서 지원 -> iframe에 경로 던져주면 Open
	   2. MHT파일은 브라우저에서 미지원, synap(문서뷰어)에 경로 던져주면 Open
	   3. vBodyContext에 HTML소스로 있는 경우 frmHTML src속성 사용     */	   
	function MhtLoad(){
		var bodytype = getInfo('FormInstanceInfo.BodyType');		  	// HTML(HTM) or PDF or MHT or SOURCE
        var vBodyContext  = getInfo('FormInstanceInfo.BodyContext');	// 본문 파일의 물리 경로        
        
        // div 태그에 src 속성 사용 가능?
        if(bodytype == "LINK") { // src, 물리 파일 경로
        	$("#frmHTML").attr("src", vBodyContext);
        	$("#frmHTML").css("display", "");
        }
        else if(bodytype == "HTML" || bodytype == "PDF") { 
            	var url = "/approval/MigBody.do?companycode=GENERAL&type=ApprovalMig&file=" +vBodyContext;
      
            	$("#frmHTML").attr("src", url);
            	$("#frmHTML").css("display", "");
            } 
        else if (bodytype == "MHT") {
        	var url = Common.getBaseConfig("SYNAP_SERVER_URL") +"/job"+ "?fid=filePreview&fileType=URL&convertType=1&filePath=" 
        			+ encodeURIComponent("" + location.protocol + "//" + location.host + "/approval/MigBody.do" + "?companycode=GENERAL&type=ApprovalMig&file=" + vBodyContext ) 
        			+ "&sync=true&force=false";
        	
        	$("#frmHTML").attr("src", url);
        	$("#frmHTML").css("display", "");
           }
        else if (bodytype == "SOURCE"){        
        	$("#frmHTML").attr("srcdoc", vBodyContext);        
        	$("#frmHTML").css("display", "");
         }
        else {
        	$("#divHTML").html(vBodyContext);           
    	   $("#divHTML").css("display", "");
         }
	}
     function postLoad() {
    	 var bodytype = getInfo('FormInstanceInfo.BodyType');
    	 
         //편집모드에서 제목 특수기호 < > " 처리
         // [16-02-24] kimhs, 관리자에서 읽기미리보기 시 지정된 SUBJECT가 없어 조건 추가
         if (getInfo("FormInstanceInfo.Subject") != undefined && (getInfo("Request.editmode") == 'Y' || getInfo("Request.templatemode") == "Read")) {
             setInfo("FormInstanceInfo.Subject", getInfo("FormInstanceInfo.Subject").replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"'));
             $("#Subject").val(getInfo("FormInstanceInfo.Subject"));
         }
         //$("#bodytable").attr("style","top:50px !important");
         $("#bodytable").attr("style","top:100px");
		 $(".wordLeft").attr("style","border:5px !important ");
		 //$(".form_wrap").attr("style","display:none");
         setTimeout(MhtLoad,100);
         //$('#divMenu02').css('display','none'); // 20210126 이관문서함에서 참조/회람 기능 사용
         
         //if (formJson.oFormData.usid != null || formJson.oFormData.usid != '') {
        if (formJson.AppInfo.usid != null || formJson.AppInfo.usid != '') {
             //sMenuURL 값은 스키마에 따라 formmenu.aspx와 formmenuExt.aspx 두가지 경우로 나뉨
             <%-- if ("<%=sMenuURL %>" == "formmenu.aspx") { --%>
             /* if ("FormMenu.js" == "FormMenu.js") { */
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
                							var oJson = data;//eval('('+JSON.stringify(data.Table)+')');
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

                 //if(formJson.oFormData.mode == "DRAFT")

                 //첨부파일UX통일-첨부파일 컨트롤 및 기본 값 채우기
                 //첨부파일 정리 후 하단 정리 할 것
                 if (getInfo("Request.templatemode") == "Write") {

                     //[2015-07-21 add kh] HTML5 첨부 파일 컨트롤 관련
                     //$('#divFileControlContainer').html(LoadFileUpload());
                     //setSizeDesc();
                     //attFile2();     // ATTACH_FILE_INFO 에서 hidOldFile 정보 가져오기.
                     //FileOnLoad();   // 기존 첨부파일 정보 바인드(CoviFileTrans 와 Basic Upload)
                     controlDisplaySetFIleInfo();   // 기존 첨부파일 정보 바인드(CoviFileTrans 와 Basic Upload)
                 }

                 //참조회람 읽음 처리, 서버단에서 읽음 확인과 함께 진행.


                 <%-- 비사용
                 //[2014-12-24 add] 이관문서 Image
                 if ("<%= bstored %>" == "True") {
                 //    $('#dvFormImage').show();
                 //
                 //    var imageTag = '<img src="' + getInfo("FormInstanceInfo.DocLinks") + '" alt="Form" />';
                 //
                 //    $('#dvFormImage').append(imageTag);
                 //
                 //    //모바일 메뉴에 대한 처리
                 //    initOnloadformmenu_ext();
                 //
                 //    //양식 별 후처리에 대한 부분을 고려한 호출
                 //    postRenderingForTemplate();
                 //} --%>
             /* } */
            <%--  else if ("<%=sMenuKind %>" == "notelist") { --%>
            /* else if ("" == "notelist") {
                 //문서대장 처리양식
                 initOnloadformmenu_notelist();
                 initForm();
                 //양식 별 후처리에 대한 부분을 고려한 호출
                 postRenderingForTemplate();
                 //첨부파일UX통일-첨부파일 컨트롤 및 기본 값 채우기
                 //첨부파일 정리 후 하단 정리 할 것
                 if (getInfo("Request.templatemode") == "Write") {
                     //[2015-07-21 add kh] HTML5 첨부 파일 컨트롤 관련
                     $('#divFileControlContainer').html(LoadFileUpload());
                     setSizeDesc();
                     attFile2();     // ATTACH_FILE_INFO 에서 hidOldFile 정보 가져오기.
                     FileOnLoad();   // 기존 첨부파일 정보 바인드(CoviFileTrans 와 Basic Upload)
                 }
             } */
             /* else {
                 //모바일 메뉴에 대한 처리
                 initOnloadformmenu_ext();
                 //양식 별 후처리에 대한 부분을 고려한 호출
                 postRenderingForTemplate();
             } */
         }
             
         // 20210126 이관문서에서 사용하지 않을 메뉴 숨김처리
   		 $("#btHistory").hide();
   		 $("#btReceiptView").hide();
   		 $("#btComment").hide();
   		 //$("#btCommentView").hide();
   		 $('#btExitPreView').show();
         $("#commentListDisp").hide();
 		 $("#btModify").hide();
         // 이관문서 메일보내기 사용유무
         if (Common.getBaseConfig("UseApprovalStore_MailSend") != "Y") {$("#btMailSend").hide();}        
         // 이관문서 의견보기 사용유무
         if (Common.getBaseConfig("UseApprovalStore_CommentView") != "Y") {$("#btCommentView").hide();} 		 
   		 
   		 
   		 if(bodytype == "LINK"){
   			 $('#btPrint').hide();
   			 $("#btPcSave").hide();
   			 $("#h2_headname").hide();
   			 $("#divMenu02").css("margin-bottom","0px").css("padding-bottom","0px");
   			 $("#bodytable").css("top","65px");
   		 }
   		 else if(bodytype == "PDF" || bodytype == "MHT"){
 	   		 $('#btPrint').hide();
 	   		 $("#btPcSave").hide();
 	   		 $("#h2_headname").hide();
 	   		 $("#bodytable").css("top","65px");
	      }else{
	   		 $('#btPrint').show();
	   	     $("#btPcSave").hide();
	  	     $("#h2_headname").hide(); 			 
	      }
     }

	function levelSel(){
		
		var sVal = document.getElementById("DocLevel").value;
		
		if(sVal == "100"){
			document.getElementById("chk_secrecy").checked = true;
			document.getElementById("chk_secrecy").value = "1";
		}else{
			document.getElementById("chk_secrecy").checked = false;
			document.getElementById("chk_secrecy").value = "0";
		}
	}
             
  </script>
