<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@page import="egovframework.coviframework.util.XSSUtils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String as = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt")); %>
<% String aI = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv")); %>
<% String ak = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize")); %>
<% int ac = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount"))); %>
<% int app = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase"))); %>
<%
	String userID 				= SessionHelper.getSession("USERID");
	String useFido			    = PropertiesUtil.getSecurityProperties().getProperty("fido.login.used");	
	String cookie 				= "N";
	String listChangeVal 		= "737";
	Cookie[] cookies  			= request.getCookies();
	for(int i = 0; i < cookies.length; i++){
		if(cookies[i].getValue().equals(userID)){
			for(int j= 0; j < cookies.length; j++){
				if(cookies[j].getName().equals("ListViewCookie")){
					cookie = cookies[j].getValue();
				}
				if(cookies[j].getName().equals("ListChangeVal")){
					listChangeVal = cookies[j].getValue();
				}
			}
		}
	}
	
	String mode = request.getParameter("mode") == null ? "DeptComplete" : request.getParameter("mode");
	
	// 이전 검색 조건 세팅
	String schFrmSeGroupID = request.getParameter("schFrmSeGroupID") == null ? "" : request.getParameter("schFrmSeGroupID");
	String schFrmSeGroupWord = request.getParameter("schFrmSeGroupWord") == null ? "" : request.getParameter("schFrmSeGroupWord");
	String schFrmTitleNm = request.getParameter("schFrmTitleNm") == null ? "" : request.getParameter("schFrmTitleNm");
	String schFrmUserNm = request.getParameter("schFrmUserNm") == null ? "" : request.getParameter("schFrmUserNm");
	String schFrmFormSubject = request.getParameter("schFrmFormSubject") == null ? "" : request.getParameter("schFrmFormSubject");
	String schFrmInitiatorName = request.getParameter("schFrmInitiatorName") == null ? "" : request.getParameter("schFrmInitiatorName");
	String schFrmInitiatorUnitName = request.getParameter("schFrmInitiatorUnitName") == null ? "" : request.getParameter("schFrmInitiatorUnitName");
	String schFrmFormName = request.getParameter("schFrmFormName") == null ? "" : request.getParameter("schFrmFormName");
	String schFrmDocNo = request.getParameter("schFrmDocNo") == null ? "" : request.getParameter("schFrmDocNo");
	String schFrmDeputyFromDate = request.getParameter("schFrmDeputyFromDate") == null ? "" : request.getParameter("schFrmDeputyFromDate");
	String schFrmDeputyToDate = request.getParameter("schFrmDeputyToDate") == null ? "" : request.getParameter("schFrmDeputyToDate");
	String schFrmSeSearchID = request.getParameter("schFrmSeSearchID") == null ? "" : request.getParameter("schFrmSeSearchID");
	String schFrmSearchInput = request.getParameter("schFrmSearchInput") == null ? "" : request.getParameter("schFrmSearchInput");
	String schFrmDtlSchBoxSts = request.getParameter("schFrmDtlSchBoxSts") == null ? "" : request.getParameter("schFrmDtlSchBoxSts");
	String schFrmTabId = request.getParameter("schFrmTabId") == null ? "" : request.getParameter("schFrmTabId");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/user/approvestat.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/security/AesUtil.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/security/aes.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/security/pbkdf2.js<%=resourceVersion%>"></script>
<form name="IframeFrom" method="post">
	<input type="hidden" id="ProcessID" 			name="ProcessID" 			value="">
	<input type="hidden" id="WorkItemID" 			name="WorkItemID" 			value="">
	<input type="hidden" id="PerformerID" 			name="PerformerID" 			value="">
	<input type="hidden" id="ProcessDescriptionID" 	name="ProcessDescriptionID" value="">
	<input type="hidden" id="Mode" 					name="Mode" 				value="">
	<input type="hidden" id="Gloct" 				name="Gloct" 				value="">
	<input type="hidden" id="Subkind" 				name="Subkind" 				value="">
	<input type="hidden" id="Archived" 				name="Archived" 			value="">
	<input type="hidden" id="UserCode" 				name="UserCode" 			value="">
	<input type="hidden" id="Admintype" 			name="Admintype" 			value="">
	<input type="hidden" id="FormInstID" 			name="FormInstID" 			value="">
	<input type="hidden" id="Usisdocmanager" 		name="Usisdocmanager" 		value="true">
	<input type="hidden" id="Listpreview" 			name="Listpreview" 			value="Y">
	<input type="hidden" id="BusinessData1" 		name="BusinessData1" 		value="">
	<input type="hidden" id="BusinessData2" 		name="BusinessData2" 		value="">
	<input type="hidden" id="RowSeq" 				name="RowSeq" 				value="">
</form>
<div class="cRConTop titType">
	<h2 class="title"></h2>
	<div class="searchBox02">
		<span><input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}"><button id="simpleSearchBtn"  type="button" onclick="onClickSearchButton(this);" class="btnSearchType01">검색</button></span><a id="detailSchBtn" onclick="DetailDisplay(this);" class="btnDetails"><spring:message code="Cache.lbl_apv_detail"/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type02 appSearch" id="DetailSearch" >
		<%
			if(mode.equals("DeptComplete")){
		%>
		<div id="DetailSearchType2">
			<div>
				<div class="selectCalView">
					<span><spring:message code='Cache.lbl_apv_subject'/></span>
					<!-- 제목 -->
					<input type="text" id="txtFormSubject" style="width: 236px;" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}">
				</div>
				<div class="selectCalView">
					<span><spring:message code='Cache.lbl_apv_writer'/></span>
					<!-- 기안자 -->
					<input type="text" id="txtInitiatorName" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}">
				</div>
				<div class="selectCalView">
					<span><spring:message code='Cache.lbl_DraftDept'/></span>
					<!-- 기안부서 -->
					<input type="text" id="txtInitiatorUnitName" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}">
				</div>
			</div>
			<div>
				<div class="selectCalView">
					<span><spring:message code='Cache.lbl_Period'/></span>	<!-- 기간 -->
					<div id="divCalendar" class="dateSel type02">
						<input class="adDate" type="text" id="DeputyFromDate" date_separator="-"> - <input id="DeputyToDate" date_separator="-" kind="twindate" date_startTargetID="DeputyFromDate" class="adDate" type="text">
					</div>
				</div>
				<div class="selectCalView">
					<span><spring:message code='Cache.lbl_apv_formname'/></span>
					<!-- 양식명 -->
					<input type="text" id="txtFormName" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}">
				</div>
				<div class="selectCalView">
					<span><spring:message code='Cache.lbl_apv_DocNo'/></span>
					<!-- 문서번호 -->
					<input type="text" id="txtDocNo" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}">
				</div>
				<a id="detailSearchBtn"  onclick="onClickSearchButton(this)" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>
		<%
			} else {
		%>
		<div id="DetailSearchType1">
			<div>
				<div class="selectCalView">
					<!--<span>* 제목+: 제목+기안자명+기안부서명 검색</span><br/>  todo: 다국어처리 필요 -->
					<span><spring:message code='Cache.lbl_Contents'/></span>	<!-- 내용 -->
					<div class="selBox" style="width: 110px;" id="selectSearchType"></div>
					<input type="text" id="titleNm" style="width: 215px;" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}" >
				</div>
			</div>
			<div>
				<div class="selectCalView">
					<span><spring:message code='Cache.lbl_Period'/></span>	<!-- 기간 -->
					<div id="divCalendar" class="dateSel type02">
						<input class="adDate" type="text" id="DeputyFromDate" date_separator="-"> - <input id="DeputyToDate" date_separator="-" kind="twindate" date_startTargetID="DeputyFromDate" class="adDate" type="text">
					</div>
				</div>
				<a id="detailSearchBtn"  onclick="onClickSearchButton(this)" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a>
			</div>		
		</div>	
		<%
			}
		%>
	</div>
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<div class="selBox" style="min-width: 95px;" id="selectGroupType"></div>
				<a id="copyBtn" style="display:none" class="btnTypeDefault" onclick="onClickFolderListPopup();"><spring:message code='Cache.btn_Copy' /></a><!-- 복사 -->
				<a id="chkAllBtn" class="btnTypeDefault" style="display:none" onclick="BatchCheck(ListGrid);"><spring:message code='Cache.btn_CheckAll' /></a><!-- 일괄확인 -->
				<a id="circulationBtn" class="btnTypeDefault" style="display:none" onclick="ListCirculation(ListGrid);"><spring:message code='Cache.btn_apv_blocCirculate' /></a><!-- 일괄회람 -->
				<a id="saveExlBtn" class="btnTypeDefault btnExcel" onclick="ExcelDownLoad(selectParams, getHeaderDataForExcel(), gridCount);"><spring:message code='Cache.btn_SaveToExcel' /></a><!-- 엑셀저장 -->
				<a id="batchApvBtn" class="btnTypeDefault" onclick="BatchApproval(ListGrid, 'DEPT', '<%=XSSUtils.removeXSSScript(useFido)%>');"><spring:message code='Cache.btn_apv_blocReceipt' /></a><!-- 일괄접수 -->
				<a id="batchApvLineBtn" class="btnTypeDefault"  onclick="BatchApvLine(ListGrid);"><spring:message code='Cache.btn_apv_blocApvline' /></a><!-- 일괄결재선 -->
				<%-- 일괄담당자 차후수행 <input type="button" class="AXButton"  onclick="aaaaa(ListGrid);" value="<spring:message code='Cache.btn_apv_blocCharge' />"> --%>	<!-- 일괄담당자 -->
				<div class="selBox" style="min-width: 90px; max-width: 100%;" id="selectDept"></div>
				<a id="docRead" class="btnTypeDefault" onclick="doDocRead();" style="display:none"><spring:message code='Cache.lbl_apv_ReadCheck' /></a><!-- 읽음확인 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<a class="btnListView listViewType01 active" onclick="onClickListView(this);" value="listView" id="listView" ></a>
				<a class="btnListView listViewType03" onclick="onClickListView(this);" value="beforeView" id="beforeView"></a>
				<button class="btnRefresh" onclick="Refresh();"></button><!-- 새로고침 -->
			</div>
		</div>							
		<div class="apprvalBottomCont">
			<!-- 본문 시작 -->
			<%
				if(cookie.equals("Y")){
			%>
			<div class="searchBox" style='display: none' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' ></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox" > <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<!-- 컨텐츠 좌측 시작 -->
					<div class="conin_list ovscroll_x">
						<div id="deptapprovalListGrid" ></div>
					</div>
					<!-- 컨텐츠 좌측 끝 -->
					<!-- 컨텐츠 우측 시작 -->
					<div class="conin_view" id="conin_view"><!-- 좌우 폭 조정에 따라 값 변경(좌측 width값) -->
						<!-- 좌우폭 조정 Bar시작 -->
						<div class="xbar" id="changeScroll"></div>
						<div id="IframeDiv" style="display: none; margin-left: ">
							<iframe id="Iframe" name="Iframe" frameborder="0" width="100%" height="770px" class="wordLayout" scrolling="no"></iframe>
						</div>
						<div class="rightFixed" id="contDiv"><spring:message code='Cache.msg_approval_clickSubject' />  <!--제목을 클릭해주세요.  --></div>
					</div>
					<!-- 컨텐츠 우측 끝 -->
				</div>
			</div>
			<%
				}else{
			%>
			<div class="searchBox" style='display: none' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' ></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox" > <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<div class="conin_list w100">
						<div id="deptapprovalListGrid"></div>
					</div>
				</div>
			</div>
			<%
			}
			%>
		</div>
	</div>						
</div>

<input type="hidden" id="hiddenGroupWord" value="" />
<input type="hidden" id="APVLIST" value="">

<form id="schFrm" style="visibility:hidden" action="" method="post">
	<input type="hidden" id="schFrmSeGroupID" name="schFrmSeGroupID" value=""/>
	<input type="hidden" id="schFrmSeGroupWord" name="schFrmSeGroupWord" value=""/>
	<input type="hidden" id="schFrmTitleNm" name="schFrmTitleNm" value=""/>
	<input type="hidden" id="schFrmUserNm" name="schFrmUserNm" value=""/>
	<input type="hidden" id="schFrmFormSubject" name="schFrmFormSubject" value=""/>
	<input type="hidden" id="schFrmInitiatorName" name="schFrmInitiatorName" value=""/>
	<input type="hidden" id="schFrmInitiatorUnitName" name="schFrmInitiatorUnitName" value=""/>
	<input type="hidden" id="schFrmFormName" name="schFrmFormName" value=""/>
	<input type="hidden" id="schFrmDocNo" name="schFrmDocNo" value=""/>
	<input type="hidden" id="schFrmDeputyFromDate" name="schFrmDeputyFromDate" value=""/>
	<input type="hidden" id="schFrmDeputyToDate" name="schFrmDeputyToDate" value=""/>
	<input type="hidden" id="schFrmSeSearchID" name="schFrmSeSearchID" value=""/>
	<input type="hidden" id="schFrmSearchInput" name="schFrmSearchInput" value=""/>
	<input type="hidden" id="schFrmDtlSchBoxSts" name="schFrmDtlSchBoxSts" value=""/>
	<input type="hidden" id="schFrmTabId" name="schFrmTabId" value=""/>
</form>
	
<script>
	var g_mode = CFN_GetQueryString("mode") == "undefined" ? "APPROVAL" : CFN_GetQueryString("mode");
	var bstored = "false";
	var ListGrid = new coviGrid();		// ListGrid 라는 변수는 각 함에서 동일하게 사용
	var headerData;						// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var gridCount = 0;					// gridCount 라는 변수는 각 함에서 동일하게 사용
	var selectParams;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	
	var approvalListType = "dept";					// 공통 사용 변수 - 결재함 종류 표현 - 부서결재함
	var gloct 	= "";
	var subkind = "";
	var userID  = "";
	var clickedTab;
	var min = 550;
	var max = 1500;
	var right_min = 200;
	var title = "";
	var receiveCnt;
	var tcInfoCnt;
	var processCnt;
	var groupUrl;
	var ProfileImagePath = Common.getBaseConfig('ProfileImagePath').replace("{0}", Common.getSession("DN_Code"));
	
	var prevClickIdx  = -1; ///// 결재 상세정보 표시하기 위해 필요한 플래그. 다른 행을 클릭했는지 동일한 행을 토글하기 위해 클릭했는지 판단할때 사용됨
	
	var schFrmSeGroupID = "<%=schFrmSeGroupID%>";
	var schFrmSeGroupWord = "<%=schFrmSeGroupWord%>";
	var schFrmTitleNm = "<%=schFrmTitleNm%>";
	var schFrmUserNm = "<%=schFrmUserNm%>";
	var schFrmFormSubject = "<%=schFrmFormSubject%>";
	var schFrmInitiatorName = "<%=schFrmInitiatorName%>";
	var schFrmInitiatorUnitName = "<%=schFrmInitiatorUnitName%>";
	var schFrmFormName = "<%=schFrmFormName%>";
	var schFrmDocNo = "<%=schFrmDocNo%>";
	var schFrmDeputyFromDate = "<%=schFrmDeputyFromDate%>";
	var schFrmDeputyToDate = "<%=schFrmDeputyToDate%>";
	var schFrmSeSearchID = "<%=schFrmSeSearchID%>";
	var schFrmSearchInput = "<%=schFrmSearchInput%>";
	var schFrmDtlSchBoxSts = "<%=schFrmDtlSchBoxSts%>";
	var schFrmTabId = "<%=schFrmTabId%>";
	var proaas = "<%=as%>";
	var proaaI = "<%=aI%>";
	var proaapp = "<%=app%>";
	var aesUtil = new AesUtil("<%=ak%>", "<%=ac%>");
	
	//일괄 호출 처리
	initApprovalListComm(initDeptDraftList, setGrid);
	
	function initDeptDraftList(){
		// 상단 제목 세팅
		var menuStr = "";
		switch (g_mode) {
		case "DeptComplete":
			menuStr = "<spring:message code='Cache.lbl_apv_doc_complete3' />";		// 완료함
			break;
		case "SenderComplete":
			menuStr = "<spring:message code='Cache.lbl_apv_doc_sent' />";		// 발신함
			break;
		case "Receive":
			menuStr = "<spring:message code='Cache.lbl_apv_doc_receive' />";		// 수신함
			break;
		case "ReceiveComplete":
			menuStr = "<spring:message code='Cache.lbl_apv_doc_receiveprocess' />";		// 수신처리함
			break;
		case "DeptTCInfo":
			menuStr = "<spring:message code='Cache.lbl_apv_doc_circulation' />";		// 참조/회람함
			break;
		case "DeptProcess":
			menuStr = "<spring:message code='Cache.lbl_apv_doc_process2' />";		// 진행함
			break;
		case "DeptRecExhibit":
			menuStr = "<spring:message code='Cache.lbl_apv_doc_recExhibit' />";		// 수신공람함
			break;
		default:
			break;
		}
		$(".title").html(menuStr);
		
		window.onresize = function(event) {
			$(".contbox").css('top', $(".content").height());
		};
		
	<%
		if(!cookie.equals("N")){
	%>
		var cWidth = "<%=XSSUtils.removeXSSScript(listChangeVal)%>";
        $('.conin_list').css('width', cWidth);
        $('.conin_view').css('left', cWidth+'px');
        $("#beforeView").addClass("active");
		$("#listView").removeClass("active");
	<%
		}else{
	%>
		$("#listView").addClass("active");
		$("#beforeView").removeClass("active");
	<%
		}
	%>
		
		// 각 함에 대한 별도 작업 진행
		setDeptApprovalBox();
		
		setDivision();
		coviInput.setDate();
		setSearchParam();	// 이전 검색조건 세팅
		
		setDocreadCount("DEPT"); // 좌측메뉴 카운트 조회
	}
	
	// 이전 검색조건 세팅
	function setSearchParam() {
 		if (schFrmSeGroupID != "") {$('#grp_'+schFrmSeGroupID).click();$("#seGroupID").click();}
 		if (schFrmTitleNm != "") {$("#titleNm").val(schFrmTitleNm)}
 		if (schFrmUserNm != "") {$("#userNm").val(schFrmUserNm)}
 		if (schFrmFormSubject != "") {$("#txtFormSubject").val(schFrmFormSubject)}
 		if (schFrmInitiatorName != "") {$("#txtInitiatorName").val(schFrmInitiatorName)}
 		if (schFrmInitiatorUnitName != "") {$("#txtInitiatorUnitName").val(schFrmInitiatorUnitName)}
 		if (schFrmFormName != "") {$("#txtFormName").val(schFrmFormName)}
 		if (schFrmDocNo != "") {$("#txtDocNo").val(schFrmDocNo)}
 		if (schFrmDeputyFromDate != "") {$("#DeputyFromDate").val(schFrmDeputyFromDate)}
 		if (schFrmDeputyToDate != "") {$("#DeputyToDate").val(schFrmDeputyToDate)}
 		if (schFrmSeSearchID != "") {$('#sch_'+schFrmSeSearchID).click();$("#seSearchID").click();}
 		if (schFrmSearchInput != "") {$("#searchInput").val(schFrmSearchInput)}
		// 상세 검색이 열려 있을때
		if (schFrmDtlSchBoxSts == "open") {DetailDisplay($('#detailSchBtn'));}
			
		schFrmSeGroupID = "";
		schFrmSeGroupWord = "";
		schFrmTitleNm = "";
		schFrmUserNm = "";
		schFrmFormSubject = "";
		schFrmInitiatorName = "";
		schFrmInitiatorUnitName = "";
		schFrmFormName = "";
		schFrmDocNo = "";
		schFrmDeputyFromDate = "";
		schFrmDeputyToDate = "";
		schFrmSeSearchID = "";
		schFrmSearchInput = "";
		schFrmDtlSchBoxSts = "";
	}
	function setDivision(){
		$(".conin_list").append("<div id='over'></div>");
	    var pan1 = $('.conin_list');
	    var pan2 = $('.conin_view');
	    var bar =  $('#changeScroll');
	    var frame = $("#Iframe"); //뷰 아이프레임 선언
	    var over = $('#over');
	    var curr_width = pan1.width();
	    var unlock = false;
		$(document).mousemove(function (e) {
			//e.preventDefault();
			var change = event.pageX - pan1.offset().left;
	        if (unlock) {
	        	if (change > min && change < max && event.pageX < $(window).width() - right_min) {
	                pan1.css('width', change);
	                pan2.css('left', change);
	                //ListGrid.windowResizeApply(); //스크롤바를 리드로우한다.
	        		
	                CFN_SetCookieDay("ListChangeVal", change, null); // 쿠키저장
	        	}
	        }
	    });
		bar.mouseup(function (e) {
		    ListGrid.windowResizeApply();
		});
	    bar.mousedown(function (e) {
	        curr_width = pan1.width();
	        unlock = true;
		over.css("visibility","visible");
		frame.css("pointer-events","none");
	    });
	    $(document).mousedown(function (e) {
	        if (unlock) {
	            e.preventDefault();
	        }
	    });
	    $(document).mouseup(function (e) {
	    	if(unlock) {
	    	    ListGrid.windowResizeApply(); 
	    	 }
	        unlock = false;
			over.css("visibility","hidden");
			frame.css("pointer-events", "");
	    });
	}

	//탭 선택(그리드 헤더 변경)
	function setDeptApprovalBox(){
		ListGrid = new coviGrid();
		
		if (CFN_GetCookie("ListViewCookie") == "Y") {
			var html = "<div id='IframeDiv' style='display: none;'>";
			html += "<iframe id='Iframe' name='Iframe' frameborder='0' width='100%' height='100%' class='wordLayout' scrolling='no'>";
			html += "</iframe></div>";
			$('#IframeDiv').replaceWith(html);
		}
		
		$('#copyBtn,#batchApvBtn,#batchApvLineBtn,#docRead,#chkAllBtn').hide();
		$("#selectDept").hide();
		
		switch (g_mode){
			case "DeptComplete" :
				$('#copyBtn').show();
				$("#selectDept").show();
				if (Common.getBaseConfig("isUseDeptCircular") == "Y") {
					$('#circulationBtn').show();
				} else {
					$('#circulationBtn').hide();
				}
				break; // 완료함
			case "SenderComplete" : 
				$('#copyBtn').show();
				$("#selectDept").show();
				break;    // 발신함
			case "Receive" : 
				$('#batchApvLineBtn,#docRead').show();
				if(Common.getBaseConfig("isUsebatchApv") == "Y") {
					if(Common.getBaseConfig("IsUseDeptReceiptManager") == "Y"){
						if(Common.getBaseConfig("WorkReportTMJobTitle").indexOf(Common.getSession("UR_JobTitleCode")) != -1 || chkDocManager()){
							$("#batchApvBtn").show();
						}else{
							$("#batchApvLineBtn").hide();
						}
					}else{
						$("#batchApvBtn").show();
					}
				}
				break;		// 수신함
			case "ReceiveComplete" : 
				$('#copyBtn').show();
				$("#selectDept").show();
				if (Common.getBaseConfig("isUseDeptCircular") == "Y") {
					$('#circulationBtn').show();
				} else {
					$('#circulationBtn').hide();
				}
				break;	// 수신처리함
			case "DeptTCInfo" : 
				$('#copyBtn,#docRead').show();
				$("#selectDept").show();
				if(Common.getBaseConfig("isUsechkAll") == "Y") {
					$('#chkAllBtn').show();
				}
				break;		// 참조/회람함
		}
	
		groupUrl = "/approval/user/getDeptApprovalGroupListData.do?&mode="+g_mode;
		setSelect(ListGrid, g_mode, groupUrl);				// 공통함수
		
		if($("#selectDept").is(":visible") == true)
			setSelectDept();				// 공통함수

		$("#searchInput").val("");
		
		// 상세검색 초기화
		if($("#detailSchBtn").attr("class") == "opBtn on")
			DetailDisplay($("#detailSchBtn"));
		$("#titleNm").val("");
		$("#userNm").val("");
		$("#txtFormSubject").val("");
		$("#txtInitiatorName").val("");
		$("#txtInitiatorUnitName").val("");
		$("#txtFormName").val("");
		$("#txtDocNo").val("");
		$("#DeputyFromDate").val("");
		$("#DeputyToDate").val("");
			
		$("#hiddenGroupWord").val("");
		$("#groupLiestDiv").css("display","none");
		$(".contbox").css('top', $(".content").height());
		
		setGrid();	//탭선택에 따른 그리드  변경을 위해 setGrid()호출
	}

	function setGrid(){
		setGridConfig();
		setApprovalListData();
	}

	function setGridConfig(){
		var notFixedWidth = 3;
		var overflowCell = [];
		//var height = "511px";
		
		if(g_mode == "Receive" || g_mode == "DeptProcess"){ //수신함 || 진행함
		 headerData =[	/// 결재 상세정보 표시하기 위해 추가함 ////
  					    {
  							display: false,
  							key: "showInfo", label: " " , width: "1", align: "center"
  					    },
						{key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox',
							disabled : function(){
	  							  /* if(g_mode == "Receive"){
									var returnStr = true;
									var extInfo = this.item.ExtInfo;
									if (extInfo != null) {
										if(extInfo != "" && extInfo.UseBlocApprove == "Y") {
											returnStr = false;
										}
									}
									
									return returnStr;
								}else{
									return true;
	  							  } */
	  							  
	  							  return false;
							}
						},
		                {key:'InitiatorName', label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'45', align:'center',sort:false,
		                	formatter: function () {
		                		return "<div class=\"poRela\"><a class=\"cirPro\"><img style=\"max-width: 100%; height: auto;\" src="+this.item.PhotoPath+" alt=\"\" onerror='coviCmn.imgError(this, true)'></a><a class=\"opnBt\" href=\"#\" onclick=\'showDetailInfo(\""+this.index+"\");return false;'></a></div>";
							}
						},							// 기안자
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'350', align:'left',
						   	formatter:function () {
					   			var extInfo = this.item.ExtInfo;
					   			var useDeptReceiptManager = "N";
							  	if (extInfo != null) {
								  	if(extInfo != "" && extInfo.UseDeptReceiptManager != undefined && extInfo.UseDeptReceiptManager != "") {
								  		useDeptReceiptManager = extInfo.UseDeptReceiptManager;
								  	}
							  	}
								if((CFN_GetCookie("ListViewCookie") == "Y")){
						   			if(g_mode == "Receive"){ //수신함
						   				if(this.item.Priority  != "5" && this.item.IsSecureDoc == "Y"){
							   				return "<div class=\"tableTxt\"><a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != null && this.item.ReadDate != '0000-00-00 00:00:00')?"":" style=\"font-weight : 900;\"") + " onclick='onClickIframeButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.MODE+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\"\",\""+useDeptReceiptManager+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a><span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span></div><ui class=\"listinfo\" style = 'overflow : visible;'><li>"+ this.item.SubKind  +" </li><li>"
								   			+ setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName) +"</li><li>"
							   				+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created)  +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\"><spring:message code='Cache.lbl_approval_similarApproval'/></span></li></ul>";
							   			}else if(this.item.Priority  == "5" && this.item.IsSecureDoc == "N"){
							   				return "<div class=\"tableTxt\"><span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/></span><a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != null && this.item.ReadDate != '0000-00-00 00:00:00')?"":" style=\"font-weight : 900;\"") + " onclick='onClickIframeButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.MODE+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\"\",\""+useDeptReceiptManager+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a></div><ui class=\"listinfo\"  style = 'overflow : visible;'><li>"+ this.item.SubKind  +" </li><li>"
								   			+ setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName) +"</li><li>"
							   				+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created)  +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\"><spring:message code='Cache.lbl_approval_similarApproval'/></span></li></ul>";
							   			}else if(this.item.Priority  == "5" && this.item.IsSecureDoc == "Y"){
							   				return "<div class=\"tableTxt\"><span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/> </span><a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != null && this.item.ReadDate != '0000-00-00 00:00:00')?"":" style=\"font-weight : 900;\"") + " onclick='onClickIframeButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.MODE+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\"\",\""+useDeptReceiptManager+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a><span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span></div><ui class=\"listinfo\" style = 'overflow : visible;'><li>"+ this.item.SubKind  +" </li><li>"
								   			+ setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName) +"</li><li>"
							   				+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created) +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\"><spring:message code='Cache.lbl_approval_similarApproval'/></span></li></ul>";
							   			}else{
							   				return "<div class=\"tableTxt\"><a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != null && this.item.ReadDate != '0000-00-00 00:00:00')?"":" style=\"font-weight : 900;\"") + " onclick='onClickIframeButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.MODE+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\"\",\""+useDeptReceiptManager+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a></div><ui class=\"listinfo\" style = 'overflow : visible;'><li>"+ this.item.SubKind  +" </li><li>"
								   			+ setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName) +"</li><li>"
							   				+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created) +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\"><spring:message code='Cache.lbl_approval_similarApproval'/></span></li></ul>";
							   			}
					   				}else{ //진행함
							   			var html = "<div class=\"tableTxt\">";
							   			if(this.item.Priority  == "5"){
						   					html +="<span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/> </span>";
						   				}
							   			html += "<a class=\"taTit\" onclick='onClickIframeButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.Mode+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\"\",\""+useDeptReceiptManager+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
						   				
						   				if(this.item.IsSecureDoc == "Y"){
						   					html += "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>"; //보안
						   				}
						   				
						   				if(this.item.IsReserved=="Y"){
						   					html +="<span class='btn_emer'><spring:message code='Cache.lbl_apv_hold'/></span>"; //보류
						   				}
						   				
						   				html += "</div><ui class=\"listinfo\" style = 'overflow : visible;'><li>"+ this.item.SubKind  +" </li><li>"
							   			+ setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName) +"</li><li>"
						   				+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created)  +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li>담당자 : "+ CFN_GetDicInfo(this.item.Charge)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\"><spring:message code='Cache.lbl_approval_similarApproval'/></span></li></ul>";
						   				return html;
					   				}
					   			}else{
					   				if(g_mode == "Receive"){ //수신함
					   					if(this.item.Priority  != "5" && this.item.IsSecureDoc == "Y"){
								   				return "<div class=\"tableTxt\"><a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != null && this.item.ReadDate != '0000-00-00 00:00:00')?"":" style=\"font-weight : 900;\"") + " onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.MODE+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.TaskID+"\",\""+useDeptReceiptManager+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a><span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span></div><ui class=\"listinfo\" style = 'overflow : visible;'><li>"+ this.item.SubKind  +" </li><li>"
									   			+ setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName) +"</li><li>"
								   				+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created) +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\"><spring:message code='Cache.lbl_approval_similarApproval'/></span></li></ul>";
							   			}else if(this.item.Priority  == "5" && this.item.IsSecureDoc == "N"){
								   				return "<div class=\"tableTxt\"><span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/></span><a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != null && this.item.ReadDate != '0000-00-00 00:00:00')?"":" style=\"font-weight : 900;\"") + " onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.MODE+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.TaskID+"\",\""+useDeptReceiptManager+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a></div><ui class=\"listinfo\" style = 'overflow : visible;'><li>"+ this.item.SubKind  +" </li><li>"
									   			+ setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName) +"</li><li>"
								   				+"</li><li>"+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created)  +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\"><spring:message code='Cache.lbl_approval_similarApproval'/></span></li></ul>";
							   			}else if(this.item.Priority  == "5" && this.item.IsSecureDoc == "Y"){
								   				return "<div class=\"tableTxt\"><span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/></span><a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != null && this.item.ReadDate != '0000-00-00 00:00:00')?"":" style=\"font-weight : 900;\"") + " onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.MODE+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.TaskID+"\",\""+useDeptReceiptManager+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a><span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span></div><ui class=\"listinfo\" style = 'overflow : visible;'><li>"+ this.item.SubKind  +" </li><li>"
									   			+ setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName) +"</li><li>"
								   				+"</li><li>"+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created)  +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\"><spring:message code='Cache.lbl_approval_similarApproval'/></span></li></ul>";
							   			}else{
								   				return "<div class=\"tableTxt\"><a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != null && this.item.ReadDate != '0000-00-00 00:00:00')?"":" style=\"font-weight : 900;\"") + " onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.MODE+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.TaskID+"\",\""+useDeptReceiptManager+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a></div><ui class=\"listinfo\" style = 'overflow : visible;'><li>"+ this.item.SubKind  +" </li><li>"
									   			+ setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName) +"</li><li>"
								   				+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created)  +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\"><spring:message code='Cache.lbl_approval_similarApproval'/></span></li></ul>";
							   			}
					   				}else{ //진행함
					   					var html = "<div class=\"tableTxt\">";
					   					
					   					if(this.item.Priority  == "5"){
						   					html +="<span class='btn_emer'><spring:message code='Cache.lbl_apv_surveyUrgency'/></span>"; //긴급
						   				}
							   				html += "<a class=\"taTit\" onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.Mode+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\"\",\"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
						   				
						   				if(this.item.IsSecureDoc == "Y"){
						   					html += "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>"; //보안
						   				}
						   				
						   				if(this.item.IsReserved=="Y"){
						   					html +="<span class='btn_emer'><spring:message code='Cache.lbl_apv_hold'/></span>"; //보류
						   				}
						   				html += "</div><ui class=\"listinfo\" style = 'overflow : visible;'><li>"+ this.item.SubKind  +" </li><li>"
							   			+ setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName) +"</li><li>"
						   				+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created)  +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li><spring:message code='Cache.lbl_apv_charge_person'/> : "+ CFN_GetDicInfo(this.item.Charge)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\"><spring:message code='Cache.lbl_apv_charge_person'/></span></li></ul>";						   								   				
							   			
						   				return html;
					   				}
					   			}
							}
		                  }, // 제목
		                {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'45', align:'center',sort:false,
		                	formatter:function () {
		                		if(this.item.IsFile == "Y"){
		                			return "<div class=\"fClip\" style=\"float: none;\"><a class=\"mClip\" onclick='openFileList(this,\""+this.item.FormInstID+"\")'>첨부</a></div>";
		                		}
		                	}
		                  }]; // 파일
		
		 overflowCell = [4];
		 //height = "621px";
		}else if(g_mode == "DeptComplete" || g_mode == "SenderComplete" || g_mode == "ReceiveComplete" || g_mode == "DeptRecExhibit"){ //완료함 || 발신함 || 수신처리함 || 수신공람함
			 headerData =[
    					  {
      						display: false,
      						key: "showInfo", label: " " , width: "1", align: "center"
      					  },
		              	  {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center',sort:false,
		                	  formatter: function () {
		                		  return "<a onclick=\'showDetailInfo(\""+this.index+"\");return false;'>"+this.item.SubKind+"</a>";
							  }
		                  }, // 구분
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'130', align:'left',
		                	  formatter:function () {
		                		var html = "<div class=\"tableTxt\" style=\"width : 80%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden;\">";
		                		
		                		// if(this.item.Priority  == "5"){	html += "<span class=\"btn_emer\">긴급</span>";	}
		                		
		                		if(CFN_GetCookie("ListViewCookie") == "Y"){
		                		 	html += "<a class=\"taTit\" onclick='onClickIframeButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\"\",\"\",\""+this.item.UserCode+"\",\"\",\"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
		                		}else{
		                			html += "<a class=\"taTit\" onclick='onClickPopButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\",\"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\"\",\"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>"
		                		}
		                		
		                		if(this.item.IsSecureDoc == "Y"){	html+= "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";	} //보안
		                		
		                		html += "</div>";
		                		
		                		return html;
		                		
		                	  }
		                  }, // 제목
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
		                	  formatter:function(){return this.item.InitiatorUnitName;}
		                  }, // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
		                	  formatter:function(){
		                		  return setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName);
		                		  }
		                  }, // 기안자
		                  {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'20', align:'center',sort:false,
		                	  formatter:function () {
		                		  if(this.item.IsFile == "Y"){
		                			  return "<div class=\"fClip\" style=\"float: none;\"><a class=\"mClip\" onclick='openFileList(this,\""+this.item.FormInstID+"\")'><spring:message code='Cache.lbl_attach'/></a></div>"; //첨부
		                		  }
		                	  }
		                  }, // 파일
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',
		                	  formatter:function () {
	                			  return CFN_GetDicInfo(this.item.FormName);
		                	  }
	                	  }, // 양식명
		                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center'},							        // 문서번호
		                  {key:'EndDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center', sort:'desc',
		                	  formatter:function () {
	                			  return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.EndDate);
	                	  		}
		                  }]; // 일시
			 
			overflowCell = [6];
		}else{// 참조회람함
			 headerData =[
    					  {
      						display: false,
      						key: "showInfo", label: " " , width: "1", align: "center"
      					  },
			              {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center',sort:false,
		                	  formatter: function () {
		                		  return "<a onclick=\'showDetailInfo(\""+this.index+"\");return false;'>"+this.item.SubKind+"</a>";
							   }
		                  },								    // 구분
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',
		                	  formatter:function () {
		                		  return CFN_GetDicInfo(this.item.FormName);
	                	  	}},							            // 양식명
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'150', align:'left',						        // 제목
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 100%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden;\">";
						   			
						   			// if(this.item.Priority  == "5"){	html += "<span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/></span>"; } //긴급
						   			
						   			if(CFN_GetCookie("ListViewCookie") == "Y"){
						   				html += "<a class=\"taTit\" " +(this.item.ReadCheck == "Y" ?"":" style=\"font-weight : 900;\"") + "onclick='onClickIframeButton(\""+this.item.ProcessID+"\",\"\",\"\",\"\",\"\",\""+this.item.FormSubKind+"\",\""+this.item.ReceiptID+"\",\""+this.item.FormInstID+"\",\"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
						   			}else{
						   				html += "<a class=\"taTit\" " +(this.item.ReadCheck == "Y" ?"":" style=\"font-weight : 900;\"") + "onclick='onClickPopButton(\""+this.item.ProcessID+"\",\"\",\"\",\"\",\"\",\""+this.item.FormSubKind+"\",\""+this.item.ReceiptID+"\",\""+this.item.FormPrefix+"\",\""+this.item.FormInstID+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\",\""+this.item.TaskID+"\",\"\",\""+this.item.BusinessData6+"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>"
						   			}
						   			if(this.item.IsSecureDoc == "Y"){	html+= "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";	} //보안
						   			
						   			html += "</div>";
						   			
						   			return html;
							  }
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
		                	  formatter:function(){return this.item.InitiatorUnitName;}
		                  },				            // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
		                	  formatter:function(){
		                		  return setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName);
		                		  }
		                  },						    // 기안자
		                  {key:'RegDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center',sort:'desc',
		                	  formatter:function () {
	                			  return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.RegDate);
	                	  		}
		                  }, // 일시
		                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center'}]; // 문서번호
		                  
			 notFixedWidth = 4; 
		}
		
		ListGrid.setGridHeader(headerData);

		var configObj = {
			targetID : "deptapprovalListGrid",
			height:"auto",
			//height:height,
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			body: {
				/// 결재 상세정보 표시하기 위해 추가함 ////
					marker       :
					{
						display: function () { return this.item.showInfo; },
						rows: [
							[{
								colSeq  : null, colspan: 12, formatter: function () {
									$.Event(event).stopPropagation();
									if(g_mode == "DeptComplete" || g_mode == "SenderComplete" || g_mode == "ReceiveComplete"){ //완료함 || 발신함 || 수신처리함
										return "<iframe src='/approval/user/ApprovalDetailList.do?FormInstID=" + this.item.FormInstID + "&ProcessID=" + this.item.ProcessArchiveID + "' width=100% height=240px frameborder=0>" + this.item.no + "</iframe>" ;
									}else{
										return "<iframe src='/approval/user/ApprovalDetailList.do?FormInstID=" + this.item.FormInstID + "&ProcessID=" + this.item.ProcessID + "' width=100% height=240px frameborder=0>" + this.item.no + "</iframe>" ;
									}
								}, align: "center"

							}]
						]
					}
					///////////////////////////////////////////
          	},
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			notFixedWidth : notFixedWidth,
			overflowCell : overflowCell
		};

		ListGrid.setGridConfig(configObj);
	}

 	/// 결재 상세정보 표시하기 위해 추가함 ////
    function showDetailInfo(index) {
        $.Event(event).stopPropagation();

		var item = ListGrid.list[index];
		if(prevClickIdx != index){ //현재 그리드에서 펼쳐진 행은 모두 닫는다.
			$.each(
					ListGrid.list, function(idx) {
				if(ListGrid.list[idx].showInfo)
					ListGrid.updateItem(0,0,idx,false);
			});
		}
		if(!item.showInfo){
			ListGrid.updateItem(0,0,index,true);
			prevClickIdx = index;
		}
		else{
			ListGrid.updateItem(0,0,index,false);
		}
		ListGrid.setFocus(index);
		ListGrid.windowResizeApply(); //스크롤바를 리드로우한다.
		/* $('#deptapprovalListGrid_AX_col_AX_2_AX_CB').css('width', '100px');
        $('#deptapprovalListGrid_AX_col_AX_2_AX_CH').css('width', '100px'); */
    }

	function setApprovalListData(){
		if(searchValueValidationCheck()){		// 공통 함수
			setSelectParams(ListGrid);// 공통 함수
			ListGrid.bindGrid({
				ajaxUrl:"/approval/user/getDeptApprovalListData.do?&mode="+g_mode,
				ajaxPars: selectParams,
				onLoad: function(){
					$('.gridBodyTable > tbody > tr > td').css('background', 'white');
					$('.AXGrid').css('overflow','visible');
					if(g_mode ==  "Receive" || g_mode == "DeptProcess"){
						$('.listinfo').parent().css('overflow','visible');
					}else if(g_mode == "DeptComplete" || g_mode == "SenderComplete" || g_mode == "ReceiveComplete" || g_mode == "DeptTCInfo"){
						$('.btnFlowerName').parent().css('overflow','visible');
					}
					coviInput.init();
					setGridCount();
					if(ListGrid.getCheckedList(1).length<=0){ //일괄 승인시 최상위 체크 박스가 유지되는 문제 해결
						ListGrid.checkedColSeq(1, false);
					}
				}
			});
		}
	}

	function openFileList(pObj,FormInstID){
		if(!axf.isEmpty($(pObj).parent().find('.file_box').html())){
			$(pObj).parent().find('.file_box').remove();
			return false;
		}
		$('.file_box').remove();
		var Params = {
				FormInstID : FormInstID
		};
		$.ajax({
			url:"/approval/getCommFileListData.do",
			type:"post",
			data:Params,
			async:false,
			success:function (data) {
				if(data.list.length > 0){
					var vHtml = "<ul class='file_box'>";
						vHtml += "<li class='boxPoint'></li>";
					for(var i=0; i<data.list.length;i++){
						vHtml += "<li><a onclick='Common.fileDownLoad(\""+data.list[i].FileID+"\",\""+data.list[i].FileName+"\",\""+data.list[i].FileToken+"\"); '>"+data.list[i].FileName+"</a></li>";
					}
					vHtml += "</ul>";
					$(pObj).parent().append(vHtml);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/getCommFileListData.do", response, status, error);
			}
		});
	}

	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
		setDocreadCount("DEPT");
	}
	
	function setGridCount(){
		gridCount = ListGrid.page.listCount;
		//$("#approvalCnt").html(gridCount);
		if (g_mode == "Receive") {
			$("#receiveUnreadCnt").text(gridCount);
		} else if (g_mode == "DeptProcess") {
			$("#processAllCnt").text(gridCount);
		}
	}

	function setSearchGroupWord(id){														// 공통함수에서 호출
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		
		$("#hiddenGroupWord").val(id);
		schFrmSeGroupWord = id;
		
		// 클릭 시, hover 와 동일한 css 적용되도록 추가
		$("a[id^='fieldName_']").attr("style", "");
		$("a[id='fieldName_" + id + "']").css("background", "#4497dc");
		$("a[id='fieldName_" + id + "']").css("color", "#fff");
		
		setApprovalListData();
	}

	function onClickSearchButton(pObj){
		if($(pObj).attr("class") == "searchImgGry"){
			if($("#seSearchID").attr("value") !="" && $("#searchInput").val() ==""){
				Common.Warning("<spring:message code='Cache.msg_EnterSearchword' />");							//검색어를 입력하세요
				$("#searchInput").focus();
				return false;
			}
		}
		if(pObj.id == "simpleSearchBtn") $("#titleNm").val($("#searchInput").val());
		
		var QSDATE = $("#DeputyFromDate").val();
		var QEDATE = $("#DeputyToDate").val();

		if((QSDATE != "" && QEDATE == "") || (QSDATE == "" && QEDATE != "")){
			Common.Warning("<spring:message code='Cache.msg_apv_periodSearchAllInputDT' />");	// 기간 검색 시 시작일과 종료일을 모두 입력해주십시오.
			return false;
		}
		
		// 본문검색인 경우 기간 설정 필요
		// 최대 6개월
		if($("#seSearchID").attr("value") == "BodyContextOrg") {
			if(QSDATE == "" || QEDATE == "") {
				Common.Warning("<spring:message code='Cache.msg_apv_chk_date' />");	// 날짜를 입력해주세요.
				return false;
			}
			
	        var chkQEDATE = getCurrentSixMonth($("#DeputyToDate").val());
	        if (QSDATE < chkQEDATE) {
	        	Common.Warning("<spring:message code='Cache.gMessageSixMonth' />");	// 본문검색은 검색기간이 6개월로 제한됩니다
				return false;
			}
		}
		
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		setGroupType(ListGrid,"/approval/user/getDeptApprovalGroupListData.do?mode="+g_mode);			// 공통함수. 그룹별 보기 목록 다시 조회함.
		
		// 그룹별 보기 이후에 검색하는 경우 다시 선택할 수 있도록 조회결과 표시하지 않도록 수정
		if($("#seGroupID").attr("value") != "all") {
			ListGrid.bindGrid({page:{pageNo:1,pageSize:$("#selectPageSize").val(),pageCount:1},list:[]});
		}
		
		// 검색어 저장
		coviCtrl.insertSearchData([$("#searchInput").val(), $("#titleNm").val()], 'Approval');
	}
	function onClickPopButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,Mode,SubKind,UserCode,FormPrefix,FormInstID,FormID,BusinessData1,BusinessData2,TaskID,useDeptReceiptManager,BusinessData6){
		var width;
		var archived = "true";
		var usisdocmanager = "false";
		var rowSeq = ""; // 문서유통 다안기안 내부수신용
		
		switch (g_mode){
			case "DeptComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="A"; userID = UserCode; break;
			case "SenderComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="S"; userID = UserCode; break;
			case "Receive" : mode =  Mode; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = UserCode; break;
			case "ReceiveComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="REQCMP"; userID = UserCode; break;
			case "DeptTCInfo" : mode = "COMPLETE"; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = UserCode; break;
			case "DeptProcess" : mode =  Mode; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = UserCode; break;
		}
		if(IsWideOpenFormCheck(FormPrefix, FormID) == true){
			width = 1070;
		}else{
			width = 790;
		}
		
		// 문서유통 다안기안용
		rowSeq = ((typeof BusinessData6!="undefined"&&BusinessData6!="undefined")?BusinessData6:"");
		
		if(Common.getBaseConfig("IsUseDeptReceiptManager") == "Y" && (useDeptReceiptManager != undefined && useDeptReceiptManager == "Y")){
			if(Common.getBaseConfig("WorkReportTMJobTitle").indexOf(Common.getSession("UR_JobTitleCode")) != -1 || chkDocManager()){
				usisdocmanager = "true";
			}
		}else{
			usisdocmanager = "true";
		}
		
		CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&forminstanceID="+FormInstID+"&userCode="+userID+"&gloct="+gloct+"&admintype=&archived="+archived+"&usisdocmanager="+usisdocmanager+"&listpreview=N&subkind="+subkind+""
				+"&ExpAppID="+((typeof BusinessData2!="undefined"&&BusinessData2!="undefined")?BusinessData2:"")+"&taskID="+(typeof TaskID!="undefined"?TaskID:"")+(rowSeq != "" ? "&rowSeq="+rowSeq : ""), "", width, (window.screen.height - 100), "resize");
	}

	// 목록변경
	function onClickListView(pObj){
		CFN_SetCookieDay("CookieUserID", Common.getSession("USERID"), null); // 쿠키저장
		if($(pObj).attr("value") == "listView"){
			CFN_SetCookieDay("ListViewCookie", "N", null); // 쿠키저장
		}else{
			CFN_SetCookieDay("ListViewCookie", "Y", null); //쿠키저장
		}

		// 이전 검색 조건 세팅
		$('#schFrmSeGroupID').val($('#seGroupID').attr('value'));
		$('#schFrmSeGroupWord').val($("#hiddenGroupWord").val());
		$('#schFrmTitleNm').val($("#titleNm").val());
		$('#schFrmUserNm').val($("#userNm").val());
		$('#schFrmFormSubject').val($("#txtFormSubject").val());
		$('#schFrmInitiatorName').val($("#txtInitiatorName").val());
		$('#schFrmInitiatorUnitName').val($("#txtInitiatorUnitName").val());
		$('#schFrmFormName').val($("#txtFormName").val());
		$('#schFrmDocNo').val($("#txtDocNo").val());
		$('#schFrmDeputyFromDate').val($("#DeputyFromDate").val());
		$('#schFrmDeputyToDate').val($("#DeputyToDate").val());
		$('#schFrmSeSearchID').val($('#seSearchID').attr('value'));
		$('#schFrmSearchInput').val($("#searchInput").val());
		// 상세검색 열림 여부
		if ($('#DetailSearch').css('display') == "none") {
			$('#schFrmDtlSchBoxSts').val("close");
		} else if ($('#DetailSearch').css('display') == "block"){
			$('#schFrmDtlSchBoxSts').val("open");
		}
		$('#schFrmTabId').val($('.AXTab.on').attr('id'));
		$("#schFrm").attr("action", "/approval/layout/approval_DeptDraftCompleteList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode="+g_mode+"");
		$('#schFrm').submit();
		
		//Refresh();
	}

	// 상세검색 열고닫기
	function DetailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			//$('#groupLiestDiv').hide();
			$('#DetailSearch').removeClass("active");
			// 검색조건 초기화
			$('#DetailSearch').find("input[type='text']").val("");
			$('#DetailSearch').find(".selList").each(function(idx,item){
			    $(item).find("a").eq(0).trigger("click");
			    $(item).hide();
			});
		}else{
			$(pObj).addClass("active");
			$('#DetailSearch').addClass("active");
		}
		
		$(".contbox").css('top', $(".content").height());
		coviInput.setDate();
	}
	
	function onClickIframeButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,Mode,SubKind,UserCode,FormInstID,useDeptReceiptManager,BusinessData1,BusinessData2,BusinessData6){
		var archived = "true";
		switch (g_mode){
			case "DeptComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="A"; userID = UserCode; break;
			case "SenderComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="S"; userID = UserCode; break;
			case "Receive" : mode =  Mode; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = UserCode; break;
			case "ReceiveComplete" : mode = "COMPLETE"; gloct = "DEPART"; subkind="REQCMP"; userID = UserCode; break;
			case "DeptTCInfo" : mode = "COMPLETE"; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = UserCode; break;
			case "DeptProcess" : mode =  Mode; gloct = "DEPART"; subkind=SubKind; archived="false"; userID = UserCode; break;
		}
		
		// 문서유통 다안기안용
		var rowSeq = ((typeof BusinessData6!="undefined"&&BusinessData6!="undefined")?BusinessData6:"");
		
		document.IframeFrom.target = "Iframe";
	  	document.IframeFrom.action = "/approval/user/ApprovalIframeList.do";
	  	//
	  	document.IframeFrom.ProcessID.value = ProcessID;
	  	document.IframeFrom.WorkItemID.value = WorkItemID;
	  	document.IframeFrom.PerformerID.value = PerformerID;
	  	document.IframeFrom.ProcessDescriptionID.value = ProcessDescriptionID;
	  	document.IframeFrom.Subkind.value = SubKind;
	  	document.IframeFrom.FormInstID.value = FormInstID;
	  	document.IframeFrom.Mode.value = mode;
	  	document.IframeFrom.Gloct.value = gloct;
	  	document.IframeFrom.UserCode.value = userID;
	  	document.IframeFrom.Archived.value = archived;
	  	document.IframeFrom.BusinessData1.value = BusinessData1;
	  	document.IframeFrom.BusinessData2.value = BusinessData2;
	  	document.IframeFrom.Usisdocmanager.value = useDeptReceiptManager;
	  	document.IframeFrom.RowSeq.value = rowSeq;
	  	//
	  	document.IframeFrom.submit();
	  	$("#IframeDiv").show();
	  	$("#contDiv").hide();
	}

	// 읽음 확인
	function doDocRead() {
		var checkApprovalList = ListGrid.getCheckedList(1);
		
		if (checkApprovalList.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
		} else if (checkApprovalList.length > 0) {
			Common.Confirm("<spring:message code='Cache.msg_Mail_SelectedItemRead' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
			    	var paramArr = new Array();
					$(checkApprovalList).each(function(i, v) {
						if (typeof(v.ReadDate) == "undefined" || v.ReadDate == "") {
							var str = v.ProcessID + "|" + v.FormInstID + "|" + v.FormSubKind;
							paramArr.push(str);
						}
					})
					
					if (paramArr.length > 0) {
	 					$.ajax({
							url:"/approval/user/deptDocRead.do",
							type:"post",
							data:{"mode" : g_mode, 
								  "paramArr" : paramArr
							},
							async:false,
							success:function (data) {
								setDocreadCount("DEPT");
								ListGrid.reloadList(); //Grid만 reload되도록 변경
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/approval/user/docRead.do", response, status, error);
							}
						});
					} else {
						Common.Warning("<spring:message code='Cache.msg_ReadProcessingError' />");
						Refresh();
					}
				} else {
					return false;
				}
			});
		} else {
			Common.Error("<spring:message code='Cache.msg_ScriptApprovalError' />", "Error");
		}
	}
	
	function chkDocManager(){
		var res = false;
		var userCode = Common.getSession("USERID");
		
		$.ajax({
			url: "/approval/user/getGovDocInOutManager.do",
			type: "post",
			data: {
				"deptCode": Common.getSession("DEPTID")
			},
			async: false,
			success: function(data) {
				var list = data.list;
				
				if(list != null && list != ""){
					$.each(list, function(idx, item){
						if(item.ListAuthorityID.indexOf(userCode) != -1){
							res = true;
							return false;
						}
					});
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/approval/user/getGovDocInOutManager.do", response, status, error);
			}
		});
		
		return res;
	}
</script>