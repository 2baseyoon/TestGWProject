<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
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
	
	String mode = request.getParameter("mode") == null ? "Approval" : request.getParameter("mode");
	
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
	
	String listmode = request.getParameter("mode") == null ? "" : request.getParameter("mode");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/user/approvestat.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/security/AesUtil.js"></script>
<script type="text/javascript" src="/covicore/resources/script/security/aes.js"></script>
<script type="text/javascript" src="/covicore/resources/script/security/pbkdf2.js"></script>
<style>
#over { position: absolute; top: 0; left: 0;  width: 100%; height: 100%;  visibility: hidden; z-index: 2; }
.conin_list {overflow-y:auto};
</style>

<form name="IframeFrom" method="post">
	<input type="hidden" id="ProcessID" 			name="ProcessID" 			value="">
	<input type="hidden" id="WorkItemID" 			name="WorkItemID" 			value="">
	<input type="hidden" id="TaskID" 				name="TaskID" 				value="">
	<input type="hidden" id="PerformerID" 			name="PerformerID" 			value="">
	<input type="hidden" id="ProcessDescriptionID" 	name="ProcessDescriptionID" value="">
	<input type="hidden" id="Subkind" 				name="Subkind" 				value="">
	<input type="hidden" id="FormInstID" 			name="FormInstID" 			value="">
	<input type="hidden" id="FormID" 				name="FormID" 				value="">
	<input type="hidden" id="UserCode" 				name="UserCode" 			value="">
	<input type="hidden" id="BusinessData2" 		name="BusinessData2" 		value="">
	<input type="hidden" id="Mode" 					name="Mode" 				value="">
	<input type="hidden" id="Gloct" 				name="Gloct" 				value="">
	<input type="hidden" id="Archived" 				name="Archived" 			value="">
	<input type="hidden" id="Admintype" 			name="Admintype" 			value="">
	<input type="hidden" id="Usisdocmanager" 		name="Usisdocmanager" 		value="true">
	<input type="hidden" id="Listpreview" 			name="Listpreview" 			value="Y">
</form>
<div class="cRConTop titType">
	<h2 id="headerTitle" class="title"></h2>
	<div class="searchBox02">
		<span><input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ accountCtrl.getInfo('simpleSearchBtn').click(); return false;}"><button id="simpleSearchBtn"  type="button" onclick="onClickSearchButton(this);" class="btnSearchType01">검색</button></span><a id="detailSchBtn" onclick="DetailDisplay(this);" class="btnDetails"><spring:message code="Cache.lbl_apv_detail"/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type02 appSearch" id="DetailSearch">
		<%
			if(mode.equals("Complete")){
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
		</div>
		<%
			}
		%>
	</div>
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<div class="selBox" style="min-width: 95px;" id="selectGroupType"></div>
				<a id="copyBtn" class="btnTypeDefault" style="display:none" onclick="onClickFolderListPopup();"><spring:message code='Cache.btn_Copy' /></a><!-- 복사 -->
				<a id="chkAllBtn" class="btnTypeDefault" style="display:none" onclick="BatchCheck(ListGrid);"><spring:message code='Cache.btn_CheckAll' /></a><!-- 일괄확인 -->
				<a id="batchApvBtn" class="btnTypeDefault" style="display:none;" onclick="BatchApproval(ListGrid, 'APPROVAL', '<%=useFido%>');"><spring:message code='Cache.btn_apv_blocApprove' /></a><!-- 일괄결재 -->
				<a id="serialApvBtn" class="btnTypeDefault" style="display:none;" onclick="SerialApproval('ACCOUNT');"><spring:message code='Cache.btn_apv_SerialApprove' /></a><!-- 연속결재 -->
				<a id="saveExlBtn" class="btnTypeDefault btnExcel" style="display:none" onclick="ExcelDownLoad(selectParams, getHeaderDataForExcel_Eac(), gridCount);"><spring:message code='Cache.btn_SaveToExcel' /></a> <!-- 엑셀저장 -->
				<a id="delBtn481" class="btnTypeDefault" style="display:none" onclick="DeleteCheck(ListGrid,'Reject');"><spring:message code='Cache.btn_delete' /></a><!-- 삭제 -->
				<a id="delBtn482" class="btnTypeDefault" style="display:none" onclick="DeleteCheck(ListGrid,'TempSave');"><spring:message code='Cache.btn_delete' /></a><!-- 삭제 -->
				<div class="selBox" style="min-width: 90px;" id="selectPerson"></div>
				<a id="docRead" class="btnTypeDefault" onclick="doDocRead();" style="display:none"><spring:message code='Cache.lbl_apv_ReadCheck' /></a><!-- 읽음확인 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<!-- <a class="btnListView listViewType01 active" onclick="onClickListView(this);" value="listView" id="listView" ></a>
				<a class="btnListView listViewType03" onclick="onClickListView(this);" value="beforeView" id="beforeView"></a> -->
				<button class="btnRefresh" onclick="setApprovalListData();setAccountDocreadCount('USER');"></button><!-- 새로고침 -->
			</div>
		</div>
		<div class="apprvalBottomCont">
			<!-- 상단 고정영역 끝 -->
			<%-- <%
				if(cookie.equals("Y")){
			%>
			<div class="searchBox" style='display: none' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea'></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox" > <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<!-- 컨텐츠 좌측 시작 -->
					<div class="conin_list">
						<div id="approvalListGrid"></div>
					</div>
					<!-- 컨텐츠 좌측 끝 -->
					<!-- 컨텐츠 우측 시작 -->
					<div class="conin_view" id="conin_view"><!-- 좌우 폭 조정에 따라 값 변경(좌측 width값) -->
						<!-- 좌우폭 조정 Bar시작 -->
						<div class="xbar" id="changeScroll"></div>
						<div id="IframeDiv" style="display: none;">
							<iframe id="Iframe" name="Iframe" frameborder="0" width="100%" height="770px" class="wordLayout" scrolling="no"></iframe>
						</div>
						<div class="rightFixed" id="contDiv"><spring:message code='Cache.msg_approval_clickSubject' /></div>  <!--제목을 클릭해주세요.  -->
					</div>
					<!-- 컨텐츠 우측 끝 -->
				</div>
			</div>
			<%
				}else{
			%> --%>
			<div class="searchBox" style='display: none' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' ></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox"> <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<div class="conin_list" style="width:100%;">
						<div id="approvalListGrid"></div>
					</div>
				</div>
			</div>
			<%-- <%
				}
			%> --%>
		</div>
	</div>
	<!-- 본문 시작 -->
	<input type="hidden" id="hiddenGroupWord" value="" />
</div>
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
	var g_mode = CFN_GetQueryString("mode") == "undefined" ? "Approval" : CFN_GetQueryString("mode");
	var bstored = "false";
	var ListGrid = new coviGrid();		// ListGrid 라는 변수는 각 함에서 동일하게 사용
	var headerData;						// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var gridCount = 0;					// gridCount 라는 변수는 각 함에서 동일하게 사용
	var selectParams;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	
	var approvalListType = "user";		// 공통 사용 변수 - 결재함 종류 표현 - 개인결재함
	var gloct 	= "";
	var subkind = "";
	var userID  = "";
	var min = 550;
	var max = 1700;
	var right_min = 100;
	var title = "";
	var approvalCnt;
	var processCnt;
	var tcInfoCnt;
	var groupUrl;
	var ProfileImagePath = Common.getBaseConfig('ProfileImagePath').replace("{0}", Common.getSession("DN_Code"));
	var proaas = "<%=as%>";
	var proaaI = "<%=aI%>";
	var proaapp = "<%=app%>";
	var aesUtil = new AesUtil("<%=ak%>", "<%=ac%>");
	
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
	
	var contentHeight = 0;
	
	//일괄 호출 처리
	initApprovalListComm(initApprovalList, setGrid);
	
	function initApprovalList(){
		// 상단 제목 세팅
		var menuStr = "";
		setHeaderTitle('headerTitle')
		
		window.onresize = function(event) {
			accountCtrl.getInfoStr(".contbox").css('top', $(".content").height());
		};
	
	<%-- <%
		if(!cookie.equals("N")){
	%>
		var cWidth = "<%=listChangeVal%>";
        accountCtrl.getInfoStr('.conin_list').attr('style', 'width: ' + cWidth + 'px; overflow-x: scroll !important');
        accountCtrl.getInfoStr('.conin_view').css('left', cWidth+'px');
        accountCtrl.getInfoStr('.conin_view').css('overflow-y', 'hidden');
		accountCtrl.getInfo("beforeView").addClass("active");
		accountCtrl.getInfo("listView").removeClass("active");
	<%
		}else{
	%> --%>
		accountCtrl.getInfo("listView").addClass("active");
		accountCtrl.getInfo("beforeView").removeClass("active");
	<%-- <%
		}
	%> --%>
		
		// 각 함에 대한 별도 작업 진행
		setApprovalBox();
		
		setDivision();
		coviInput.setDate();
		setSearchParam();	// 이전 검색조건 세팅
	}
	
	// 이전 검색조건 세팅
	function setSearchParam() {
 		if (schFrmSeGroupID != "") {accountCtrl.getInfo("grp_"+schFrmSeGroupID).click();accountCtrl.getInfo("seGroupID").click();}
 		if (schFrmTitleNm != "") {accountCtrl.getInfo("titleNm").val(schFrmTitleNm)}
 		if (schFrmUserNm != "") {accountCtrl.getInfo("userNm").val(schFrmUserNm)}
 		if (schFrmFormSubject != "") {$("#txtFormSubject").val(schFrmFormSubject)}
 		if (schFrmInitiatorName != "") {$("#txtInitiatorName").val(schFrmInitiatorName)}
 		if (schFrmInitiatorUnitName != "") {$("#txtInitiatorUnitName").val(schFrmInitiatorUnitName)}
 		if (schFrmFormName != "") {$("#txtFormName").val(schFrmFormName)}
 		if (schFrmDocNo != "") {$("#txtDocNo").val(schFrmDocNo)}
 		if (schFrmDeputyFromDate != "") {accountCtrl.getInfo(g_mode+"DeputyFromDate").val(schFrmDeputyFromDate)}
 		if (schFrmDeputyToDate != "") {accountCtrl.getInfo(g_mode+"DeputyToDate").val(schFrmDeputyToDate)}
 		if (schFrmSeSearchID != "") {accountCtrl.getInfo('sch_'+schFrmSeSearchID).click();accountCtrl.getInfo("seSearchID").click();}
 		if (schFrmSearchInput != "") {accountCtrl.getInfo("searchInput").val(schFrmSearchInput)}
		// 상세 검색이 열려 있을때
		if (schFrmDtlSchBoxSts == "open") {DetailDisplay(accountCtrl.getInfo('detailSchBtn'));}
			
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
		accountCtrl.getInfoStr(".conin_list").append("<div id='over'></div>");
	    var pan1 = accountCtrl.getInfoStr('.conin_list');
	    var pan2 = accountCtrl.getInfoStr('.conin_view');
	    var bar =  accountCtrl.getInfo('changeScroll');
	    var over = accountCtrl.getInfo('over');
	    var curr_width = pan1.width();
	    var unlock = false;
		$(document).mousemove(function (e) {
			//e.preventDefault();
	        if (unlock) {
		        var change = event.pageX - pan1.offset().left;
	        	if (change > min && change < max && event.pageX < $(window).width() - right_min) {
	        		pan1.css('width', change);
	                pan2.css('left', change);
	                ListGrid.windowResizeApply(); //스크롤바를 리드로우한다.
	                
	        		CFN_SetCookieDay("ListChangeVal", change, null); // 쿠키저장
	        	}
	        }
	    });
	    bar.mousedown(function (e) {
	        curr_width = pan1.width();
	        unlock = true;
		over.css("visibility","visible");
	    });
	    $(document).mousedown(function (e) {
	        if (unlock) {
	            e.preventDefault();
	        }
	    });
	    $(document).mouseup(function (e) {
	        unlock = false;
		over.css("visibility","hidden");
	    });
	}
	
	//탭 선택(그리드 헤더 변경)
	function setApprovalBox(){
		ListGrid = new coviGrid();
		
		/* if (CFN_GetCookie("ListViewCookie") == "Y") {						
			var html = "<div id='IframeDiv' style='display: none;'>";
			html += "<iframe id='Iframe' name='Iframe' frameborder='0' width='100%' height='770px' class='wordLayout' scrolling='no'>";
			html += "</iframe></div>";
			accountCtrl.getInfo('IframeDiv').replaceWith(html);
		} */
		
		accountCtrl.getInfo('chkAllBtn').hide();
		accountCtrl.getInfo('saveExlBtn').hide();
		accountCtrl.getInfo('copyBtn').hide();
		accountCtrl.getInfo('delBtn481').hide();
		accountCtrl.getInfo('delBtn482').hide();
		accountCtrl.getInfo('batchApvBtn').hide();
		accountCtrl.getInfo('serialApvBtn').hide();
		accountCtrl.getInfo('docRead').hide();
		accountCtrl.getInfo("selectPerson").hide();
		
		// 기안자 input 처리
		if (g_mode=="TempSave") {
			accountCtrl.getInfo("userNm").attr("disabled",true);
		} else {
			accountCtrl.getInfo("userNm").attr("disabled",false);
		}
		
		switch (g_mode){
			case "PreApproval" : 
				if(Common.getBaseConfig("isUsechkAll") == "Y") {
					accountCtrl.getInfo('chkAllBtn').show();
				}
				break; // 예고함
			case "Approval" : 
				accountCtrl.getInfo('saveExlBtn').show();
				accountCtrl.getInfo('docRead').show();
				if(Common.getBaseConfig("isUsechkAll") == "Y") {
					accountCtrl.getInfo('chkAllBtn').show();
				}
				if(Common.getBaseConfig("isUsebatchApv") == "Y") {
					accountCtrl.getInfo('batchApvBtn').show();
				}
				if(Common.getBaseConfig("isUseSerial") == "Y") {
					accountCtrl.getInfo('serialApvBtn').show();
				}
				break;    // 미결함
			case "Process" : 
				accountCtrl.getInfo('saveExlBtn').show();
				if(Common.getBaseConfig("isUsechkAll") == "Y") {
					accountCtrl.getInfo('chkAllBtn').show();
				}
				break;		// 진행함
			case "Complete" : 
				accountCtrl.getInfo('copyBtn').show();
				accountCtrl.getInfo('saveExlBtn').show();
				accountCtrl.getInfo("selectPerson").show();
				if(Common.getBaseConfig("isUsechkAll") == "Y") {
					accountCtrl.getInfo('chkAllBtn').show();
				}
				break;	// 완료함
			case "Reject" : 
				accountCtrl.getInfo('delBtn481').show();
				accountCtrl.getInfo('saveExlBtn').show();
				if(Common.getBaseConfig("isUsechkAll") == "Y") {
					accountCtrl.getInfo('chkAllBtn').show();
				}
				break;		// 반려함
			case "TempSave" : 
				accountCtrl.getInfo('delBtn482').show();
				accountCtrl.getInfo("userNm").attr("disabled",true);
				break;	// 임시함
			case "TCInfo" : 
				accountCtrl.getInfo('copyBtn').show();
				accountCtrl.getInfo('saveExlBtn').show();
				accountCtrl.getInfo('docRead').show();
				accountCtrl.getInfo("selectPerson").show();
				if(Common.getBaseConfig("isUsechkAll") == "Y") {
					accountCtrl.getInfo('chkAllBtn').show();
				}
				break;		// 참조/회람함
		}
		
		groupUrl = "/approval/user/getApprovalGroupListData.do?&mode="+g_mode;
		setSelect(ListGrid, g_mode, groupUrl);				// 공통함수
		
		if(accountCtrl.getInfo("selectPerson").is(":visible") == true)
			setSelectPerson();				// 공통함수
		
		accountCtrl.getInfo("searchInput").val("");
			
		// 상세검색 초기화
		if(accountCtrl.getInfo("detailSchBtn").attr("class") == "opBtn on")
			DetailDisplay(accountCtrl.getInfo("detailSchBtn"));
		accountCtrl.getInfo("titleNm").val("");
		accountCtrl.getInfo("userNm").val("");
		accountCtrl.getInfo("txtFormSubject").val("");
		accountCtrl.getInfo("txtInitiatorName").val("");
		accountCtrl.getInfo("txtInitiatorUnitName").val("");
		accountCtrl.getInfo("txtFormName").val("");
		accountCtrl.getInfo("txtDocNo").val("");
		accountCtrl.getInfo(g_mode+"DeputyFromDate").val("");
		accountCtrl.getInfo(g_mode+"DeputyToDate").val("");
		
		accountCtrl.getInfo("hiddenGroupWord").val("");
		accountCtrl.getInfo("groupLiestDiv").css("display","none");
		accountCtrl.getInfoStr(".contbox").css('top', $(".content").height());
		
		setGrid();	//탭선택에 따른 그리드  변경을 위해 setGrid()호출
	}
	
	// 새로고침
	/* function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
		setDocreadCount("USER");
	} */
	
	function setGrid(){
		setGridConfig();
		setApprovalListData();
	}
	//
	function setGridConfig(){
		var notFixedWidth = 3;
		var overflowCell = [];
		//var height = "621px";
		
		if(g_mode == "Approval"){ //미결함 - 읽은 게시글은 style : font-weight를 사용하여 굵게 표시 하도록 분리
			 headerData =[	/// 결재 상세정보 표시 ////
        					  {
        						display: false,
        						key: 'showInfo', label: '' , width: '1', align: 'center'
        					  },
			              	  {key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox',sort:false,
        						  checked:function(){
			              			var checkedList = strWiid_List.split(";"); 
			              			if(this.item.WorkItemID!="" && checkedList.includes(this.item.WorkItemID)){
			              				return true;
			              			}else{
			              				return false;
			              			}
			              	  	  }
        					  },
			                  {key:'InitiatorName', label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'45', align:'center',sort:false,showExcel:true,
			                	  formatter: function () {
			                		  return "<div class=\"poRela\"><a class=\"cirPro\" onclick=\"showDetailInfo('"+this.index+"');return false;\"><img style=\"max-width: 100%; height: auto;\" src="+coviCmn.loadImage(this.item.PhotoPath)+" alt=\"\" onerror='coviCmn.imgError(this, true)'></a><a class=\"opnBt\" onclick=\'showDetailInfo(\""+this.index+"\");return false;'></a></div>";
								   }
			              	  },// 기안자
			                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'250', align:'left',showExcel:true,			    // 제목
							   	  formatter:function () {		
							   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
							   			
							   			if(this.item.Priority  == "5"){	html +="<span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/></span>";	} //긴급
							   			
										/* if(CFN_GetCookie("ListViewCookie") == "Y"){
											html += "<a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != '0000-00-00 00:00:00')?"": " style=\"font-weight : 900;\"") + " onclick='onClickIframeButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.TaskID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.FormInstID+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
							   			}else{ */
							   				html += "<a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != '0000-00-00 00:00:00')?"": " style=\"font-weight : 900;\"") + " onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.TaskID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.FormInstID+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
							   			//}
							   			
							   			if(this.item.IsSecureDoc == "Y"){	html += "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";	} //보안
						   				if(this.item.IsReserved == "Y"){	html +="<span class='btn_emer'><spring:message code='Cache.lbl_apv_hold'/></span>";	} //보류
						   				
						   				var InitiatorName = CFN_GetDicInfo(this.item.InitiatorName);
						   				var SubUserName = InitiatorName;
						   				var subUserCode = this.item.BusinessData5.split('^^^');
						   				
						   				if(this.item.BusinessData5.indexOf('^^^')>-1) {
											SubUserName = CFN_GetDicInfo(subUserCode[1]);
										}
										if(this.item.InitiatorID !== subUserCode[0] || !subUserCode[0] || !SubUserName || SubUserName == "null"){
										} else {
											InitiatorName += '('+SubUserName+')';
										}
										
										// 프리젠트 (FlowerName)
										InitiatorName = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+this.item.InitiatorID+"\" data-user-mail>" + InitiatorName + "</div>";
										
						   				html += "</div><ui class=\"listinfo\"><li>"+ this.item.SubKind  +" </li><li>"+ InitiatorName + "</li><li>"+ this.item.InitiatorUnitName +"</li><li>"+ CFN_TransLocalTime(this.item.Created)  +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\">유사양식</span></li></ul>";
							   			
							   			return html;
									}
			                  },
			                  {key:'SubUserName', label:'<spring:message code="Cache.lbl_Sub_Approver"/>', display: false, width:'100', align:'right',showExcel:true, formatter:function () {		
						   			
					   				var SubUserName = '';
					   				if(this.item.BusinessData5.indexOf('^^^')>-1)
					   					SubUserName = CFN_GetDicInfo(this.item.BusinessData5.split('^^^')[1]);
						   			 
						   			return SubUserName;
			                  	}
			                  },//대리기안자
			                  {key:'BusinessData4', label:'<spring:message code="Cache.ACC_useHistory"/>', width:'100', align:'left',showExcel:true, formatter:function () {
									var comment = this.item.BusinessData4;
									if((comment.match(/<br>/gi) || []).length > 1) comment = comment.replace(/<br>/gi, '\r\n');
									return comment;
								}
							  }, //적요
			                  {key:'BusinessData3', label:'<spring:message code="Cache.ACC_billReqAmt"/>', width:'45', align:'right',showExcel:true, formatter:"money"}, //금액
			                  {key:'IsComment', label:'<spring:message code="Cache.lbl_apv_comment"/>',  width:'30', align:'center',showExcel:true, sort:false,
			                	  formatter:function () {
			                		  if(this.item.IsComment == "Y"){
			                			  return "<a onclick='openCommentView(\""+this.item.ProcessID+"\",\""+this.item.FormInstID+"\")' style='cursor: default;'><img src=\"/approval/resources/images/Approval/ico_comment.gif\" alt=\"\"></a>";
			                		  }
			                	  }
			                  }]; // 의견
			                  
		}else if(g_mode == "PreApproval" || g_mode == "Process"){ //예고함, 진행함
			 headerData =[	/// 결재 상세정보 표시하기 위해 추가함 ////
      					  {
      						display: false,
      						key: 'showInfo', label: '' , width: '1', align: 'center'
      					  },
			              	  {key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox',sort:false},
			                  {key:'InitiatorName', label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'45', align:'center',sort:false,showExcel:true,
			                	  formatter: function () {
			                		  return "<div class=\"poRela\"><a class=\"cirPro\" onclick=\"showDetailInfo('"+this.index+"');return false;\"><img style=\"max-width: 100%; height: auto;\" src="+coviCmn.loadImage(this.item.PhotoPath)+" alt=\"\" onerror='coviCmn.imgError(this, true)'></a><a class=\"opnBt\" onclick=\'showDetailInfo(\""+this.index+"\");return false;'></a></div>";
								   }
			              	  },// 기안자
			                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'250', align:'left',showExcel:true,						    // 제목
							   	  formatter:function () {
							   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden;\">";
							   			
							   			if(this.item.Priority  == "5"){	html +="<span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/></span>";	} //긴급
							   			
										/* if(CFN_GetCookie("ListViewCookie") == "Y"){
											html += "<a class=\"taTit\" onclick='onClickIframeButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.TaskID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.FormInstID+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
							   			}else{ */
							   				html += "<a class=\"taTit\" onclick='onClickPopButton(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.TaskID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.FormInstID+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
							   			//}
							   										   			
							   			if(this.item.IsSecureDoc == "Y"){	html += "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";	} //보안
						   				if(this.item.IsReserved == "Y"){	html +="<span class='btn_emer'><spring:message code='Cache.lbl_apv_hold'/></span>";		} //보류

						   				var InitiatorName = CFN_GetDicInfo(this.item.InitiatorName);
						   				var SubUserName = InitiatorName;
						   				var subUserCode = this.item.BusinessData5.split('^^^');
						   				
						   				if(this.item.BusinessData5.indexOf('^^^')>-1) {
											SubUserName = CFN_GetDicInfo(subUserCode[1]);
										}
										if(this.item.InitiatorID !== subUserCode[0] || !subUserCode[0] || !SubUserName || SubUserName == "null"){
										} else {
											InitiatorName += '('+SubUserName+')';
										}

										// 프리젠트 (FlowerName)
										InitiatorName = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+this.item.InitiatorID+"\" data-user-mail>" + InitiatorName + "</div>";
										
							   			var oApvList = this.item.DomainDataContext
							   			var currentTarget='';
							   			if(oApvList!=undefined)
							   			{
							   				var oCurrentOUNode = $$(oApvList).find("steps > division:has(>taskinfo[status='pending'])");
								   			var oRecOUNode = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");
								   			if($$(oRecOUNode).find("ou").hasChild("person").length >0) {
								   				var ouPersonName = $$(oRecOUNode).find("ou>person").attr('name');
								   				var ouPersonCode = $$(oRecOUNode).find("ou>person").attr('code');
												// 프리젠트 (FlowerName)
								   				currentTarget	=	"<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+ouPersonCode+"\" data-user-mail>" + CFN_GetDicInfo(ouPersonName) + "</div>";
								   			} else {
								   				currentTarget	=	$$(oRecOUNode).find("ou").attr('name')+'함';
									   			currentTarget = CFN_GetDicInfo(currentTarget);
								   			}
							   			}
							   			
						   				html += "</div><ui class=\"listinfo\"><li>"+ this.item.SubKind  +" </li><li>"+ InitiatorName  +"</li><li>"+ CFN_GetDicInfo(this.item.InitiatorUnitName) +"</li><li>"+ CFN_TransLocalTime(g_mode=="PreApproval"?this.item.Created:this.item.Finished) +"</li><li>"+ CFN_GetDicInfo(this.item.FormName) +"</li><li>"+currentTarget+"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\">유사양식</span></li></ul>";		
						   				
							   			return html;
									}
			                  },
			                  {key:'SubUserName', label:'<spring:message code="Cache.lbl_Sub_Approver"/>', display: false, width:'100', align:'right',showExcel:true, formatter:function () {		
						   			
			                	 	var SubUserName = '';
					   				if(this.item.BusinessData5.indexOf('^^^')>-1){
					   					SubUserName = CFN_GetDicInfo(this.item.BusinessData5.split('^^^')[1]);
					   				}
						   			return SubUserName;
			                  	}
		                  	  }, //대리기안자
			                  {key:'BusinessData4', label:'<spring:message code="Cache.ACC_useHistory"/>', width:'100', align:'left',showExcel:true, formatter:function () {
									var comment = this.item.BusinessData4;
									if((comment.match(/<br>/gi) || []).length > 1) comment = comment.replace(/<br>/gi, '\r\n');
									return comment;
								}
							  }, //적요
			                  {key:'BusinessData3', label:'<spring:message code="Cache.ACC_billReqAmt"/>', width:'45', align:'right',showExcel:true, formatter:"money"}, //금액
			                  {key:'IsComment', label:'<spring:message code="Cache.lbl_apv_comment"/>',  width:'30', align:'center', showExcel:true, sort:false,
			                	  formatter:function () {
			                		  if(this.item.IsComment == "Y"){
			                			  return "<a onclick='openCommentView(\""+this.item.ProcessID+"\",\""+this.item.FormInstID+"\")' style='cursor: default;'><img src=\"/approval/resources/images/Approval/ico_comment.gif\" alt=\"\"></a>";
			                		  }
			                	  }
			                  }]; // 의견
			                  
		}else if(g_mode == "Complete" || g_mode == "Reject"){ //완료함 || 반려함
			 headerData =[
    					  {
      						display: false,
      						key: "showInfo", label: " " , width: "1", align: "center"
      					  },
			              {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', sort:false},
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center', sort:false,showExcel:true,
		                	  formatter: function () {
		                		   return "<a onclick=\'showDetailInfo(\""+this.index+"\");return false;'>"+this.item.SubKind+"</a>";
							   }
		                  },								   // 구분
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'100', align:'left',showExcel:true,						       // 제목
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden;\">";
						   			
									/* if(CFN_GetCookie("ListViewCookie") == "Y"){
										html += "<a class=\"taTit\" onclick='onClickIframeButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.TaskID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormInstID+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
						   			}else{ */
						   				html += "<a class=\"taTit\" onclick='onClickPopButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.TaskID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormInstID+"\",\""+this.item.FormSubKind+"\",\""+this.item.UserCode+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
						   			//}
						   			
						   			if(this.item.IsSecureDoc == "Y"){	html+= "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";	}  //보안
						   			
						   			html += "</div>";
						   			
							   		return html;
								}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',showExcel:true,
		                	  formatter:function(){return CFN_GetDicInfo(this.item.InitiatorUnitName);}
		                  },				           // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',showExcel:true,
		                	  formatter:function(){
									var InitiatorName = CFN_GetDicInfo(this.item.InitiatorName);
					   				var SubUserName = InitiatorName;
					   			 	var subUserCode = this.item.BusinessData5.split('^^^');
								 	if(this.item.BusinessData5.indexOf('^^^')>-1) {
										 SubUserName = CFN_GetDicInfo(subUserCode[1]);
								 	}
								 	if(this.item.InitiatorID == subUserCode[0] || !subUserCode[0]  || !SubUserName || SubUserName == "null"){
									 
									} else {
									 	InitiatorName += '('+SubUserName+')';
								 	}
								 	
									// 프리젠트 (FlowerName)
								 	InitiatorName = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+this.item.InitiatorID+"\" data-user-mail>" + InitiatorName + "</div>";
	                		  		
		                		  	return InitiatorName;
	                		  }
		                  },							// 기안자	
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',showExcel:true,
		                	  formatter:function () {
		                		  return CFN_GetDicInfo(this.item.FormName);
	                	  	  }
		                  }, // 양식명
		                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center',showExcel:true},									   // 문서번호
		                  
						  {key:'EndDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center', sort:'desc',showExcel:true, 
		                	  formatter:function () {
		                			  return CFN_TransLocalTime(this.item.EndDate);
		                	  }
		                  },					// 일시		
		                  {key:'SubUserName', label:'<spring:message code="Cache.lbl_Sub_Approver"/>', display: false, width:'100', align:'right',showExcel:true, formatter:function () {		
					   			
				   				var SubUserName = '';
				   				if(this.item.BusinessData5.indexOf('^^^')>-1)
				   					SubUserName = CFN_GetDicInfo(this.item.BusinessData5.split('^^^')[1]);
					   			 
					   			return SubUserName;
		                  	}
	                  	  }, //대리기안자
		                  {key:'BusinessData4', label:'<spring:message code="Cache.ACC_useHistory"/>', width:'100', align:'left',showExcel:true, formatter:function () {
								var comment = this.item.BusinessData4.replace(/<br>/gi, '\r\n');
								return comment;
							}
						  }, //적요 
		                  {key:'BusinessData3', label:'<spring:message code="Cache.ACC_billReqAmt"/>', width:'45', align:'right',showExcel:true, formatter:"money"}, //금액		                  			   
		                  {key:'IsComment', label:'<spring:message code="Cache.lbl_apv_comment"/>',  width:'30', align:'center', showExcel:true, sort:false,
		                	  formatter:function () {
		                		  if(this.item.IsComment == "Y"){
		                			  return "<a onclick='openCommentView(\""+this.item.ProcessArchiveID+"\",\""+this.item.FormInstID+"\")' style='cursor: default;'><img src=\"/approval/resources/images/Approval/ico_comment.gif\" alt=\"\"></a>";
		                		  }
		                	  }
		                  }]; // 의견	
		                  
		}else{ //참조/회람함
			 headerData =[
   					  	  {
     						display: false,
     						key: "showInfo", label: " " , width: "1", align: "center"
     					  },
			              {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center',sort:false,showExcel:true,
		                	  formatter: function () {
		                		  return "<a onclick=\'showDetailInfo(\""+this.index+"\");return false;'>"+this.item.SubKind+"</a>";
							   }
		                  },								    // 구분
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'150', align:'left',showExcel:true,						        // 제목
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 100%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden;\">"
						   			
						   			if(this.item.Priority  == "5"){	html += "<span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/></span>"; } //긴급
						   			
						   			/* if(CFN_GetCookie("ListViewCookie") == "Y"){
										html += "<a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != '0000-00-00 00:00:00')?"": " style=\"font-weight : 900;\"") + " onclick='onClickIframeButton(\""+this.item.ProcessID+"\",\"\",\"\",\"\",\"\",\"\",\""+this.item.Kind+"\",\""+this.item.UserCode+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
						   			}else{ */
						   				html += "<a class=\"taTit\"" + ((this.item.ReadDate != "" && this.item.ReadDate != '0000-00-00 00:00:00')?"": " style=\"font-weight : 900;\"") + " onclick='onClickPopButton(\""+this.item.ProcessID+"\",\"\",\"\",\"\",\"\",\""+this.item.FormInstID+"\",\""+this.item.Kind+"\",\""+this.item.UserCode+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
						   			//}
						   			
						   			if(this.item.IsSecureDoc == "Y"){  html += "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>"; } //보안
						   			if(this.item.IsReserved =="Y"){  html += "<span class=\"security\"><spring:message code='Cache.lbl_apv_hold'/></span>"; }  //보류
						   			
						   			html += "</div>";
						   			
						   			return html;
								}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',showExcel:true,
		                	  formatter:function(){return CFN_GetDicInfo(this.item.InitiatorUnitName);}
		                  },				            // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',showExcel:true,
		                	  formatter:function(){
									var InitiatorName = CFN_GetDicInfo(this.item.InitiatorName);
					   				var SubUserName = InitiatorName;
									var subUserCode = this.item.BusinessData5.split('^^^');
									
									if(this.item.BusinessData5.indexOf('^^^')>-1) {
										SubUserName = CFN_GetDicInfo(subUserCode[1]);
									}
									if(this.item.InitiatorID == subUserCode[0] || !subUserCode[0] || !SubUserName || SubUserName == "null"){
									} else {
										InitiatorName += '('+SubUserName+')';
									}
					   												 	
								 	InitiatorName = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+this.item.InitiatorID+"\" data-user-mail>" + InitiatorName + "</div>";
	                		  		
		                		  	return InitiatorName;
	                		  }
		                  },						    // 기안자
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',showExcel:true,
		                	  formatter:function () {
		                		  return CFN_GetDicInfo(this.item.FormName);
	                	  	  }
		                  }, // 양식명
		                  {key:'RegDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center',sort:'desc',showExcel:true,
		                	  formatter:function () {
	                			  return CFN_TransLocalTime(this.item.RegDate)
	                	  	   }
		                  },							// 일시(참조 지정일시)
		                  {key:'BusinessData4', label:'<spring:message code="Cache.ACC_useHistory"/>', width:'100', align:'left',showExcel:true, formatter:function () {
								var comment = this.item.BusinessData4.replace(/<br>/gi, '\r\n');
								return comment;
							}
						  }, //적요 
		                  {key:'BusinessData3', label:'<spring:message code="Cache.ACC_billReqAmt"/>', width:'45', align:'right',showExcel:true, formatter:"money"}, //금액
		                  {key:'SubUserName', label:'<spring:message code="Cache.lbl_Sub_Approver"/>', display: false, width:'100', align:'right',showExcel:true, formatter:function () {		
					   			
				   				var SubUserName = '';
				   				if(this.item.BusinessData5.indexOf('^^^')>-1)
				   					SubUserName = this.item.BusinessData5.split('^^^')[1];
					   			 
					   			return SubUserName;
							
	                  	  	}
		                  }//대리기안자
						];	        
		                   
			 notFixedWidth = 4;
		}
		
		ListGrid.setGridHeader(headerData);
		
		accountCtrl.getInfo("approvalListGrid").attr("id", "approvalListGrid"+g_mode);

		var configObj = {
			targetID : "approvalListGrid"+g_mode,
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
									if(g_mode == "PreApproval" || g_mode == "Approval" || g_mode == "Process" || g_mode == "TCInfo"){ //예고함 || 미결함||진행함 || 참조/회람함
										return "<iframe src='/account/user/ApprovalDetailList.do?FormInstID=" + this.item.FormInstID + "&ProcessID=" + this.item.ProcessID + "' width=100% height=240px frameborder=0>" + this.item.no + "</iframe>" ;
									}else if(g_mode == "Complete" || g_mode == "Reject"){ //완료함 || 반려함
										return "<iframe src='/account/user/ApprovalDetailList.do?FormInstID=" + this.item.FormInstID + "&ProcessID=" + this.item.ProcessArchiveID + "' width=100% height=240px frameborder=0>" + this.item.no + "</iframe>" ;
									}
								}, align: "center"

							}]
						]
					}
             },
			page : {
				pageNo:1,
				pageSize:accountCtrl.getInfo("selectPageSize").val()
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
    }

	function setApprovalListData(){
		if(searchValueValidationCheck()){		// 공통 함수
			setSelectParams(ListGrid);// 공통 함수
			
			ListGrid.bindGrid({
				ajaxUrl:"/approval/user/getApprovalListData.do?&mode="+g_mode,
				ajaxPars: selectParams,
				onLoad: function(){
 					accountCtrl.getInfoStr('.gridBodyTable > tbody > tr > td').css('background', 'white');
 					accountCtrl.getInfoStr('.AXGrid').css('overflow','visible');
 					if(g_mode == 'Approval' || g_mode == 'Process') {
 						$('.listinfo').closest('td').children('div').css('overflow','visible');
 						$('.listinfo').css('overflow','visible');
 					}
 					if(g_mode == 'Complete' || g_mode == 'Reject' || g_mode == 'TCInfo') {
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
	
	function openModifyPop(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,FormPrefix){
		var archived = "false";
		switch (g_mode){
			case "Complete" : mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;	// 완료함
			case "Reject" : mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode; break;		// 반려함
		}
		CFN_OpenWindow("/approval/goHistoryListPage.do?ProcessID="+ProcessID+"&FormInstID="+FormInstID+"&FormPrefix="+FormPrefix+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"&mode="+mode+"&type=List", "", 830, (window.screen.height - 100), "both");
	}
	
	function openCommentView(ProcessID,FormInstID) {
		var archived = "false";
		switch(g_mode) {
			case "Complete": case "Reject": archived = "true"; break;
		}
		CFN_OpenWindow("/approval/goCommentViewPage.do?ProcessID="+ProcessID+"&FormInstID="+FormInstID+"&archived="+archived+"&bstored="+bstored, "", 540, 500, "resize");
	}
	
	function setGridCount(){
		gridCount = ListGrid.page.listCount;
		if (g_mode == "Approval") {
			accountCtrl.getInfo("approvalAllCnt").text(gridCount);
		} else if (g_mode == "Process") {
			accountCtrl.getInfo("processAllCnt").text(gridCount);
		}
	}

	function setSearchGroupWord(id){														// 공통함수에서 호출
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		
		accountCtrl.getInfo("hiddenGroupWord").val(id);
		schFrmSeGroupWord = id;
		
		// 클릭 시, hover 와 동일한 css 적용되도록 추가
		accountCtrl.getInfoStr("a[id^='fieldName_']").attr("style", "");
		accountCtrl.getInfoStr("a[id='fieldName_" + id + "']").css("background", "#4497dc");
		accountCtrl.getInfoStr("a[id='fieldName_" + id + "']").css("color", "#fff");
		
		if(accountCtrl.getViewPageDivID().indexOf("JobFunction") > -1 && typeof(setApprovalListData_JF) == "function") {
			setApprovalListData_JF();			
		} else {
			setApprovalListData();
		}
		
	}

	function onClickSearchButton(pObj){
		if($(pObj).attr("class") == "searchImgGry"){
			if(accountCtrl.getInfo("seSearchID").attr("value") !="" && accountCtrl.getInfo("searchInput").val() ==""){
				Common.Warning("<spring:message code='Cache.msg_EnterSearchword' />");							//검색어를 입력하세요
				accountCtrl.getInfo("searchInput").focus();
				return false;
			}
		}
		if(pObj.id == "simpleSearchBtn") $("#titleNm").val($("#searchInput").val());
		
		// 본문검색인 경우 기간 설정 필요
		// 최대 6개월
		if(accountCtrl.getInfo("seSearchID").attr("value") == "BodyContextOrg") {
			var QSDATE = accountCtrl.getInfo(g_mode+"DeputyFromDate").val();
			
			if(QSDATE == "") {
				Common.Warning("<spring:message code='Cache.msg_apv_chk_date' />");	// 날짜를 입력해주세요.
				return false;
			}
			
	        var chkQEDATE = getCurrentSixMonth(accountCtrl.getInfo(g_mode+"DeputyToDate").val());
	        if (QSDATE < chkQEDATE) {
	        	Common.Warning("<spring:message code='Cache.gMessageSixMonth' />");	// 본문검색은 검색기간이 6개월로 제한됩니다
				return false;
			}
		}
        
		var url = "/approval/user/getApprovalGroupListData.do?&mode="+g_mode;
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		setGroupType(ListGrid, url);			// 공통함수. 그룹별 보기 목록 다시 조회함.
		
		// 그룹별 보기 이후에 검색하는 경우 다시 선택할 수 있도록 조회결과 표시하지 않도록 수정
		if(accountCtrl.getInfo("seGroupID").attr("value") != "all") {
			ListGrid.bindGrid({page:{pageNo:1,pageSize:$("#selectPageSize").val(),pageCount:1},list:[]});
		}
		
		// 검색어 저장
		coviCtrl.insertSearchData([accountCtrl.getInfo("searchInput").val(), accountCtrl.getInfo("titleNm").val()], 'Approval');
	}
	function onClickPopButton(ProcessID,WorkItemID,TaskID,PerformerID,ProcessDescriptionID,FormInstID,SubKind,UserCode,FormID,BusinessData2){
		strPiid_List = "";
		strWiid_List = "";
		strFiid_List = "";
		strPtid_List = "";
		
		var archived = "false";
		switch (g_mode){
			//case "PreApproval" : mode="PREAPPROVAL"; gloct = "PREAPPROVAL"; subkind="T010"; userID=UserCode; break; // 예고함
			case "Approval" : mode="APPROVAL"; gloct = "APPROVAL"; subkind=SubKind; userID=UserCode; break;    // 미결함
			case "Process" : mode="PROCESS"; gloct = "PROCESS"; subkind=SubKind; userID=UserCode; break;		// 진행함
			case "Complete" : mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;	// 완료함
			case "Reject" : mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode; break;		// 반려함
			//case "TempSave" : mode="TEMPSAVE"; gloct = "TEMPSAVE"; subkind="";  userID=""; break;	// 임시함
			case "TCInfo" : mode="COMPLETE"; gloct = "TCINFO"; subkind=SubKind; userID=""; break;		// 참조/회람함
		}
				
		CFN_OpenWindow("/account/expenceApplication/ExpenceApplicationViewPopup.do?mode="+mode
				+"&processID="+ProcessID
				+"&workitemID="+WorkItemID
				+"&taskID="+TaskID
				+"&performerID="+PerformerID
				+"&processdescriptionID="+ProcessDescriptionID
				+"&userCode="+userID
				+"&gloct="+gloct
				+"&formID="+FormID
				+"&forminstanceID="+FormInstID
				+"&ExpAppID="+BusinessData2
				+"&admintype=&archived="+archived
				+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"", "", 1070, (window.screen.height - 100), "both");
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
		// TODO 다른 방식으로 처리 필요
		accountCtrl.getInfo('schFrmSeGroupID').val(accountCtrl.getInfo('seGroupID').attr('value'));
		accountCtrl.getInfo('schFrmSeGroupWord').val(accountCtrl.getInfo("hiddenGroupWord").val());
		accountCtrl.getInfo('schFrmTitleNm').val(accountCtrl.getInfo("titleNm").val());
		accountCtrl.getInfo('schFrmUserNm').val(accountCtrl.getInfo("userNm").val());
		accountCtrl.getInfo('schFrmFormSubject').val(accountCtrl.getInfo("txtFormSubject").val());
		accountCtrl.getInfo('schFrmInitiatorName').val(accountCtrl.getInfo("txtInitiatorName").val());
		accountCtrl.getInfo('schFrmInitiatorUnitName').val(accountCtrl.getInfo("txtInitiatorUnitName").val());
		accountCtrl.getInfo('schFrmFormName').val(accountCtrl.getInfo("txtFormName").val());
		accountCtrl.getInfo('schFrmDocNo').val(accountCtrl.getInfo("txtDocNo").val());
		accountCtrl.getInfo('schFrmDeputyFromDate').val(accountCtrl.getInfo(g_mode+"DeputyFromDate").val());
		accountCtrl.getInfo('schFrmDeputyToDate').val(accountCtrl.getInfo(g_mode+"DeputyToDate").val());
		accountCtrl.getInfo('schFrmSeSearchID').val(accountCtrl.getInfo('seSearchID').attr('value'));
		accountCtrl.getInfo('schFrmSearchInput').val(accountCtrl.getInfo("searchInput").val());
		// 상세검색 열림 여부
		if (accountCtrl.getInfo('DetailSearch').css('display') == "none") {
			accountCtrl.getInfo('schFrmDtlSchBoxSts').val("close");
		} else if (accountCtrl.getInfo('DetailSearch').css('display') == "block"){
			accountCtrl.getInfo('schFrmDtlSchBoxSts').val("open");
		}
		accountCtrl.getInfo('schFrmTabId').val(accountCtrl.getInfoStr('.AXTab.on').attr('id'));
		accountCtrl.getInfo("schFrm").attr("action", "/account/layout/account_ApprovalList.do?CLSYS=account&CLMD=user&CLBIZ=Account&mode="+g_mode+"");
		accountCtrl.getInfo('schFrm').submit();
	}

	// 상세검색 열고닫기
	function DetailDisplay(pObj){
		if(accountCtrl.getInfo("DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			//accountCtrl.getInfo('groupLiestDiv').hide();
			accountCtrl.getInfo('DetailSearch').removeClass("active");
		}else{
			$(pObj).addClass("active");
			accountCtrl.getInfo('DetailSearch').addClass("active");
		}
		
		accountCtrl.getInfoStr(".contbox").css('top', $(".content").height());
		coviInput.setDate();
	}
	
	function onClickIframeButton(ProcessID,WorkItemID,TaskID,PerformerID,ProcessDescriptionID,SubKind,FormInstID,UserCode,FormID,BusinessData2){
		strPiid_List = "";
		strWiid_List = "";
		strFiid_List = "";
		strPtid_List = "";
		
		var archived = "false";
		
		switch (g_mode){
			case "PreApproval" : mode="PREAPPROVAL"; gloct = "PREAPPROVAL"; subkind="T010"; userID=UserCode; break; // 예고함
			case "Approval" : mode="APPROVAL"; gloct = "APPROVAL"; subkind=SubKind; userID=UserCode; break;    // 미결함
			case "Process" : mode="PROCESS"; gloct = "PROCESS"; subkind=SubKind; userID=UserCode; break;		// 진행함
			case "Complete" : mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;	// 완료함
			case "Reject" : mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode; break;		// 반려함
			case "TempSave" : mode="TEMPSAVE"; gloct = "TEMPSAVE"; subkind="";  userID=""; break;	// 임시함
			case "TCInfo" : mode="COMPLETE"; gloct = "TCINFO"; subkind=SubKind; userID=""; break;		// 참조/회람함
		}
		document.IframeFrom.target = "Iframe";
	  	document.IframeFrom.action = "/account/user/ApprovalIframeList.do";
	  	//
	  	document.IframeFrom.ProcessID.value = ProcessID;
	  	document.IframeFrom.WorkItemID.value = WorkItemID;
	  	document.IframeFrom.TaskID.value = TaskID;
	  	document.IframeFrom.PerformerID.value = PerformerID;
	  	document.IframeFrom.ProcessDescriptionID.value = ProcessDescriptionID;
	  	document.IframeFrom.Subkind.value = SubKind;
	  	document.IframeFrom.FormInstID.value = FormInstID;
	  	document.IframeFrom.UserCode.value = userID;
	  	document.IframeFrom.FormID.value = FormID;
	  	document.IframeFrom.BusinessData2.value = BusinessData2;
	  	document.IframeFrom.Mode.value = mode;
	  	document.IframeFrom.Gloct.value = gloct;
	  	document.IframeFrom.Archived.value = archived;
	  	//
	  	document.IframeFrom.submit();
	  	accountCtrl.getInfo("IframeDiv").show();
	  	accountCtrl.getInfo("contDiv").hide();
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
							var str = v.ProcessID + "|" + v.FormInstID + "|" + v.Kind;
							paramArr.push(str);
						}
					})
					
					if (paramArr.length > 0) {
	 					$.ajax({
							url:"/approval/user/docRead.do",
							type:"post",
							data:{"mode" : g_mode, 
								  "paramArr" : paramArr
							},
							async:false,
							success:function (data) {
								setAccountDocreadCount();
								ListGrid.reloadList(); //Grid만 reload되도록 변경
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/approval/user/docRead.do", response, status, error);
							}
						});
					} else {
						Common.Warning("<spring:message code='Cache.msg_ReadProcessingError' />");
						//TODO reload
					}
				} else {
					return false;
				}
			});
		} else {
			Common.Error("<spring:message code='Cache.msg_ScriptApprovalError' />", "Error");
		}
	}
	
	if (!window.ApprovalList) {
		window.ApprovalList = {};
	}

	(function(window) {
		var ApprovalList = {
			
			pageView : function() {
				g_mode = CFN_GetQueryString("mode") == "undefined" ? "Approval" : CFN_GetQueryString("mode");
				approvalListType = "user";
				
				accountCtrl.getInfo("approvalListGrid").attr("id", "approvalListGrid"+g_mode);
				
				setApprovalBox();
				
				setDivision();
				coviInput.setDate();
				setSearchParam();	// 이전 검색조건 세팅
			}
		}
		
		//initApprovalList();

		window.ApprovalList = ApprovalList;
	})(window);
</script>
