<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.ComUtils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	pageContext.setAttribute("assignedMail", ComUtils.getAssignedBizSection("Mail"));
%>

<style>
.bizcard_org_view_list03 li a .tx_info01 {
	position: absolute;
	top: 11px;
	left: 135px;
	padding: 0;
	display: inline-block;
	width: 225px;
	vertical-align: top;
}
</style>

<script type="text/javascript">
(function(){	
	var addScript = function(src){
		var jsname = src.split('/').reverse()[0].split('.')[0];
		if ($("html head script[src*="+jsname+"]").length == 0){
			var $script = document.createElement("script");	
			$script.type = "text/javascript";
			$script.src = src+'<%=resourceVersion%>';
			document.head.appendChild($script);	
		}
	}
	
	addScript("/groupware/resources/script/user/bizcard.js");
	addScript("/groupware/resources/script/user/bizcard_list.js");
})();
</script>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_FavoriteList' /></h2> <!-- 즐겨찾는 연락처 --> 
	<div class="searchBox02" >
		<select id="searchType" class="selectType02 lg widSm">
			<option value="Name"><spring:message code='Cache.lbl_name'/></option> <!-- 이름 -->
			<option value="EMAIL"><spring:message code='Cache.lbl_Email2'/></option> <!-- 이메일 -->
			<option value="PhoneNumber"><spring:message code='Cache.lbl_MobilePhone'/></option> <!-- 핸드폰 -->
		</select>
		<span>
			<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ onClickSearchButton(this); return false; }"> <%-- placeholder="<spring:message code='Cache.msg_apv_001' />"	 --%>
			<button type="button" class="btnSearchType01" onclick="onClickSearchButton(this);"><spring:message code='Cache.lbl_search'/></button><!-- 검색 -->
		</span>
	</div>
</div>

<!-- 상단 필터 및 메뉴 -->
<div class="cRContBottom mScrollVH ">
	<div class="bizcardAllCont">
		<div class="bizcardTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a href="#"  id="btnDelete" class="btnTypeDefault" onclick="BizCardDeleteCheck(bizCardGrid, 'P', 'Person');"><spring:message code="Cache.btn_delete"></spring:message></a><!-- 삭제 -->
				<c:if test='${assignedMail}'>
				<a href="#"  id="btnMail"  class="btnTypeDefault btnIco btnMail mr5" onclick="goWriteMail(this);"><spring:message code="Cache.CPMail_mail"></spring:message></a><!-- 메일 -->
				</c:if>
				<%--<a href="#"  id="saveExlBtn" class="btnTypeDefault btnExcel" onclick="ExcelDownload();"><spring:message code='Cache.btn_SaveToExcel' /></a><!-- 엑셀저장 -->--%>
				<a href="#"  id="btnEachExport" class="btnTypeDefault left" onclick="eachExportImportExport(bizCardGrid);"><spring:message code="Cache.lbl_EachExportContact"></spring:message></a><!-- 개별 연락처 내보내기 -->
			</div>
			<div class="buttonStyleBoxRight">	
				<select class="selectType02 listCount" id="selDataPerPageCnt" > 
					<option value="10">10</option> 
					<option value="15">15</option> 
					<option value="20">20</option> 
					<option value="30">30</option>  
					<option value="50">50</option>
				</select>
				<!-- <button type="button" class="btnIcoComm btnPrint" type="button" onclick="alert('<spring:message code='Cache.msg_037' />');">
					<spring:message code='Cache.lbl_Print'/>
				</button>  --><!-- 인쇄 -->
				<a href="#" id="listView" class="btnListView listViewType01 active">리스트보기1</a>
				<a href="#" id="albumView" class="btnListView listViewType02" style="margin-left:-5px;">리스트보기2</a>
				<button type="button"  class="btnRefresh" type="button" onclick="refresh()"></button> <!-- 새로고침 -->
			</div>
		</div>	
		<div id="divTabTray" class="tblList tblCont tblBizcardList">
			<div class="tblFilterTop">
				<ul class="filterList">
					<li class="active"><a id="bizCardListAll" href="#" onclick="clickTab(this);" value="ALL"><spring:message code='Cache.lbl_all' /></a><!-- 전체 --></li>
					<li><a id="bizCardListKor1" href="#" onclick="clickTab(this);" 	value="ㄱ">ㄱ</a> </li>
					<li><a id="bizCardListKor2" href="#" onclick="clickTab(this);" 	value="ㄴ">ㄴ</a> </li>
					<li><a id="bizCardListKor3"	href="#" onclick="clickTab(this);" value="ㄷ">ㄷ</a></li>
					<li><a id="bizCardListKor4" href="#" onclick="clickTab(this);" value="ㄹ">ㄹ</a> </li>
					<li><a id="bizCardListKor5"	href="#" onclick="clickTab(this);" value="ㅁ">ㅁ</a></li>
					<li><a id="bizCardListKor6" href="#" onclick="clickTab(this);" 	value="ㅂ">ㅂ</a> </li>
					<li><a id="bizCardListKor7"	href="#" onclick="clickTab(this);" value="ㅅ">ㅅ</a></li>
					<li><a id="bizCardListKor8" href="#" onclick="clickTab(this);"	value="ㅇ">ㅇ</a> </li>
					<li><a id="bizCardListKor9"	href="#" onclick="clickTab(this);" value="ㅈ">ㅈ</a></li>
					<li><a id="bizCardListKor10" href="#" onclick="clickTab(this);"	value="ㅊ">ㅊ</a> </li>
					<li><a id="bizCardListKor11"	href="#" onclick="clickTab(this);" value="ㅋ">ㅋ</a></li>
					<li><a id="bizCardListKor12" href="#" onclick="clickTab(this);"	value="ㅌ">ㅌ</a> </li>
					<li><a id="bizCardListKor13"	href="#" onclick="clickTab(this);" value="ㅍ">ㅍ</a></li>
					<li><a id="bizCardListKor14" href="#" onclick="clickTab(this);"	value="ㅎ">ㅎ</a> </li>
					<li><a id="bizCardListEng" href="#"	onclick="clickTab(this);" value="ENG">A-Z</a> </li>
					<li><a id="bizCardListNum" href="#" onclick="clickTab(this);"	value="NUM">0-9</a></li>
					<li><a id="bizCardListEtc" href="#" onclick="clickTab(this);"	value="ETC"><spring:message code='Cache.lbl_Etc' /></a></li><!-- 기타 -->
				</ul>
			</div>
		
			<!-- Grid -->
			<div id="resultBoxWrap">
				<div id="bizCardGrid"></div>
			</div>
			
			<div id="resultBoxWrapAlbum" style="display:none;">
				<div id="bizCardAlbum" style="margin-top:0px; border-top:1px solid #969696; overflow:auto !important;"></div>
			</div>
		</div>
	</div>
</div>		
<script>
	var bizCardViewType = "A"; //즐겨찾기도 "A"로
	var bizCardGrid = new coviGrid();
	var msgHeaderData = getGridHeader("F");
	var page = 1;
	var storagePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
	var page = CFN_GetQueryString("page")== 'undefined'?1:CFN_GetQueryString("page");
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	

	if(CFN_GetCookie("BizListCnt")){
		pageSize=CFN_GetCookie("BizListCnt");
	}
	
	$("#selDataPerPageCnt").val(pageSize);
	//***************************************************************************************************************************/
	
	// 새로고침
	function refresh(){
		if(viewType == "Album") {
			bindGridAlbumData();
		} else {
			setGrid();
		}
	}
	
	//***************************************************************************************************************************/
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		var UR_ID = Common.getSession("UR_ID");
		
		bizCardGrid.setGridHeader([
			{key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox',
				disabled:function(){
					if(this.item.ShareType == "U" && UR_ID != this.item.RegisterID && sessionObj["isAdmin"] != "Y"){
						return true;
					}else{
						return false;
					}
				}
			},
		  	{key:'IsFavorite',hideFilter : 'Y',colHeadTool:false,  label:'<a class=\"tblBtnFavorite\" href=\"#\">Favorite</a>', width:'20', align:'center', sort:false, formatter : function() {
				if(this.item.BizCardType == 'BizCard'){
					var IsFavorite = "<span style='color:black;' onclick='ChangeFavoriteStatus(" + this.item.BizCardID + ",this)'>";
					switch(this.item.IsFavorite) {
						case "Y" : IsFavorite += "<a class=\"tblBtnFavorite active\" href=\"#\">Favorite</a>"; break; 
						default : IsFavorite += "<a class=\"tblBtnFavorite\" href=\"#\">Favorite</a>"; break;
					}
					IsFavorite += "</span>"; 
					return IsFavorite;
				}else{
					return '';				  		
			  	}
			}},
			{key:'Name',  label:"<spring:message code='Cache.lbl_name'/>", width:'100', align:'left', formatter:function () { //이름
				var sReturn = "<span class=\"thumb ";				
				if(this.item.ImagePath != "" && this.item.ImagePath != undefined) {
					sReturn +=  "\">";
					if(this.item.BizCardType == 'BizCard'  ){
						sReturn +=  "<img name=\"bizCardThumbnail\" style=\"width: auto; height: 100%;\" onerror='this.src=\""+ "/covicore/resources/images/common/noImg.png\"' src=\"" + coviCmn.loadImage(storagePath + this.item.ImagePath);
					}else{
						sReturn +=  "<img name=\"bizCardThumbnail\" style=\"width: auto; height: 100%;\" onerror='this.src=\""+ "/covicore/resources/images/common/noGroupImg.png\"' src=\"" + coviCmn.loadImage(storagePath + this.item.ImagePath);						                			
					}
				} else {
					sReturn +=  "noImg \">";
					if(this.item.BizCardType == 'BizCard'  ){
						sReturn += "<img name=\"bizCardThumbnail\" style=\"width: auto; height: 100%;\" src=\"" + "/covicore/resources/images/common/noImg.png";
					}else{
						  	sReturn += "<img name=\"bizCardThumbnail\" style=\"width: auto; height: 100%;\" src=\"" + "/covicore/resources/images/common/noGroupImg.png";  
					}
				}					
				sReturn += "\" /></span>&nbsp;";
           		if(this.item.BizCardType == 'BizCard'  ){
           			sReturn += "<a href='#' onclick='viewBizCardPop(\""+ this.item.BizCardID +"\"); return false;'>"+this.item.Name+"</a>";
           		}else{
           			sReturn += "<a href='#' onclick='modifyGroupPop(\""+ bizCardViewType +"\",\""+ this.item.BizCardID +"\"); return false;'>"+this.item.Name+"</a>";
           		}               		
 				return sReturn;
			}},
			{key:'PhoneNum',  label:"<spring:message code='Cache.lbl_MobilePhone'/>", width:'70', align:'center', formatter : function() { 		//핸드폰
				var PhoneNum = this.item.PhoneNum;
           		if(PhoneNum.indexOf(";") > 0)
           			PhoneNum = PhoneNum.substr(0,PhoneNum.indexOf(";"));
           		return PhoneNum;
			}},
			{key:'EMAIL', label:"<spring:message code='Cache.lbl_Email2'/>", width:'100', align:'center', formatter : function() { 				//이메일
           		var EMAIL = this.item.EMAIL;
           		if(EMAIL.indexOf(";") > 0)
           			EMAIL = EMAIL.substr(0,EMAIL.indexOf(";"));
           		return EMAIL;
			}},
			{key:'ComName',  label:"<spring:message code='Cache.lbl_Company'/>", width:'100', align:'center'}, //회사
			{key:'ComPhoneNum',  label:"<spring:message code='Cache.lbl_Office_Line'/>", width:'70', align:'center', formatter : function() { 	//회사 전화
           		var ComPhoneNum = this.item.ComPhoneNum;
           		if(ComPhoneNum.indexOf(";") > 0)
           			ComPhoneNum = ComPhoneNum.substr(0,ComPhoneNum.indexOf(";"));
           		return ComPhoneNum;
			}},
			{key:'FaxNum',  label:"<spring:message code='Cache.lbl_Office_Fax'/>", width:'70', align:'center', formatter : function() { 		//팩스
				var FaxNum = this.item.FaxNum;
				if(FaxNum.indexOf(";") > 0)
					FaxNum = FaxNum.substr(0,FaxNum.indexOf(";"));
				return FaxNum;
			}},			
			{key:'EtcNum',  label:"<spring:message code='Cache.lbl_EtcPhone'/>", width:'70', align:'center', formatter : function() { 			//기타전화
				var EtcNum = this.item.EtcNum;
				if(EtcNum.indexOf(";") > 0)
					EtcNum = EtcNum.substr(0,EtcNum.indexOf(";"));
				return EtcNum;
			}},
			{key:'HomePhoneNum',  label:"<spring:message code='Cache.lbl_HomePhone'/>", width:'70', align:'center', formatter : function() { 	// 자택전화
				var HomePhoneNum = this.item.HomePhoneNum;
				if(HomePhoneNum.indexOf(";") > 0)
					HomePhoneNum = HomePhoneNum.substr(0,HomePhoneNum.indexOf(";"));
				return HomePhoneNum;
			}},
			{key:'JobTitle', label:"<spring:message code='Cache.lbl_JobTitle'/>", width:'100', align:'center'}, 
			{key:'ShareType',  label:"<spring:message code='Cache.lbl_Division'/>", width:'70', align:'center', formatter : function() { 		//구분
         	  var shareType = "";
         	  switch(this.item.ShareType) {
         	  case 'P' : shareType = "<spring:message code='Cache.lbl_ShareType_Personal'/>"; break; //개인
         	  case 'D' : shareType = "<spring:message code='Cache.lbl_ShareType_Dept'/>"; break; //부서
         	  case 'U' : shareType = "<spring:message code='Cache.lbl_ShareType_Comp'/>"; break; //회사
         	  }
         	  return shareType;
			}}
   		]);
		/* setGridConfig(); */
		bindGridData();
	}
	
	function bindGridData() {	
				
		var tabFilter = $('#divTabTray').find(".active").first().children().attr('value');
		var startDate = null;/* $("#startDate").val(); */
		var endDate = null;/* $("#endDate").val(); */
		var searchInput = $("#searchInput").val();
		var searchType = $("#searchType").val();
		
		setGridConfig();
		
		bizCardGrid.bindGrid({
			ajaxUrl:"/groupware/bizcard/getBizCardFavoriteList.do",
			ajaxPars: {
				tabFilter : tabFilter,
				searchWord : searchInput,
				searchType: searchType,
				startDate : startDate,
				endDate : endDate,
				sortBy: bizCardGrid.getSortParam()
			}
		});
	}
	
	//***************************************************************************************************************************/
	
	//엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", 'Confirm Dialog', function(result) {
			if(result){
				var headerName = getHeaderNameForExcel();
				var groupID = "";
				var	sortKey = "Date";//bizCardGrid.getSortParam("one").split("=")[1].split(" ")[0]; 
				var	sortWay = "DESC"; //bizCardGrid.getSortParam("one").split("=")[1].split(" ")[1]; 				  	
				var bizCardViewType = "F";
				
				location.href = "/groupware/bizcard/bizCardListExcelDownload.do?sortColumn="+sortKey+"&sortDirection="+sortWay+"&tabFilter="+ $('#divTabTray').find(".active").first().children().attr('value') +"&searchWord="+ $("#searchInput").val() +"&searchType="+ $("#searchType").val() +"&shareType="+ bizCardViewType + "&groupID=" + groupID + "&headerName="+headerName;
			}
		});
		
	}
	
	//엑셀용 Grid 헤더정보 설정
	function getHeaderNameForExcel(){
		var returnStr = "";
		returnStr += "<spring:message code='Cache.lbl_Favorite'/>" + "|";
		
	   	for(var i=0;i<msgHeaderData.length; i++){
	   	   	if(msgHeaderData[i].display != false && msgHeaderData[i].label != 'chk'){
					returnStr += msgHeaderData[i].label + "|";
	   	   	}
		}
		
		return returnStr;
	}
	
	//***************************************************************************************************************************/
	
	//Grid 설정 관련
	function setGridConfig(){
		var pageNum = 1;
		if(page != undefined && page != ''){
			pageNum = page;
		}
		
		var configObj = {
			targetID : "bizCardGrid",		// grid target 지정
			height:"auto",
			page : {
				pageNo:pageNum,
				pageSize:$("#selDataPerPageCnt").val()
			},
			paging : true
		};
		
		// Grid Config 적용
		bizCardGrid.setGridConfig(configObj);
	}	
	
	var bindSelect = function() {
	};
	
	function onClickSearchButton(pObj){
		/* if($(pObj).attr("class") == "btnSearchType01"){
			if($("#seSearchID").attr("value") !="" && $("#searchInput").val() ==""){
				Common.Warning("<spring:message code='Cache.msg_EnterSearchword'/>");							//검색어를 입력하세요
				$("#searchInput").focus();
				return false;
			}
		} */
		
		//bindGridData();
		if(viewType == "Album") {
			bindGridAlbumData();
		} else {
			bindGridData();
		}
	}
		
	//탭 선택(그리드 헤더 변경)
	function clickTab(pObj){
		bizCardGrid = new coviGrid();	
		
		$("#divTabTray").find("a").parent().removeClass("active");
		$(pObj).parent().addClass("active");
		$("#searchInput").val("");
	
		//setGrid();	//탭선택에 따른 그리드  변경을 위해 setGrid()호출
		page = 1;
		if(viewType == "Album") {
			bindGridAlbumData();
		} else {
			setGrid();
		}
	}
	
	var viewBizCardPop = function(id) { //명함 보기
		var BizCardID = id;
	
		location.href = "/groupware/bizcard/ModifyBizCard.do" + "?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard&mnp=" + encodeURIComponent(0) + "&BizCardID=" + encodeURIComponent(BizCardID) + "&TypeCode=P";
		
		console.dir(event);
		// 이벤트 기본동작 방지
		event.preventDefault ? event.preventDefault() : (event.returnValue = false);	
		// 버블링 방지
		event.stopPropagation ? event.stopPropagation() : (event.cancelBubble = true);	
		
		return false;
		
	}
	
	window.onload = initContent();
		
	function initContent(){

		//리스트보기
		$("#listView").off('click').on('click', function(){
			changeBizCardBoardView();
			setGrid();
		});

		//앨범보기
		$("#albumView").off('click').on('click', function(){
			changeBizCardAlbumView();
			bindGridAlbumData();
		});
		
		//그리드 설정
		setGrid();
	
		$(".selectSearchField").on("change", function() {
			bindGridData();
		});
		
		$("#selDataPerPageCnt").on("change", function(){
			//bindGridData();
			page = 1;
			if(viewType == "Album") {
				bindGridAlbumData();
			} else {
				bindGridData();
			}		

			CFN_SetCookieDay("BizListCnt", $(this).find("option:selected").val(), 31536000000);
		});
		
		bindSelect();
	}
	
	//카드형 보기
	function bindGridAlbumData(){
		var tabFilter = $('#divTabTray').find(".active").first().children().attr('value');
		var startDate = null;/* $("#startDate").val(); */
		var endDate = null;/* $("#endDate").val(); */
		var searchInput = $("#searchInput").val();
		var searchType = $("#searchType").val();
		
		if(tabFilter == "Group"){
			changeBizCardBoardView();
			setGrid();
		}
		else{	
			var searchParam = {
				"tabFilter" : tabFilter,
				"startDate" : startDate,
				"endDate" : endDate,
				"searchInput" : searchInput,
				"searchType" : searchType,
				"shareType" : bizCardViewType,
				"sortBy" : bizCardGrid.getSortParam("one").split("=").pop(),
				"searchWord" : searchInput
			}
			
			if(page != undefined && page != ''){
				bizCardAlbum.page.pageNo = page;
			}
			bizCardAlbum.page.pageSize = $("#selDataPerPageCnt").val();
			bizCardAlbum.page.sortBy = bizCardGrid.getSortParam("one").split("=").pop();	

			bizCardAlbum.target = 'bizCardAlbum';
			bizCardAlbum.url = "/groupware/bizcard/getBizCardFavoriteList.do";
			bizCardAlbum.setList(searchParam);
		}
	}
	
	/*메일 쓰기 이동*/
	function goWriteBizMail(obj){
		// param setting
		var userMail = "&userMail="+JSON.parse(sessionStorage.getItem($("#inputUserId").val())).userMail;
		var inputUserId = "&inputUserId="+$("#inputUserId").val();
		var popupId = "write_"+sessionStorage.getItem("writePopupCount");
		
		var isSendMail = JSON.parse(sessionStorage.getItem($("#inputUserId").val())).isSendMail;
		if(isSendMail == 'N'){
			Common.Warning("<spring:message code='Cache.CPMail_mail_msgNotPermission'/>", "<spring:message code='Cache.CPMail_warning_msg'/>");  //권한이 없습니다.
			return;
		}
		
		// 그리드 선택된 사용자 메일 정보.
		var list = bizCardGrid.getCheckedList(0);
		if(list == 0){
			Common.Inform("<spring:message code='Cache.msg_mail_selectRecipient'/>", "<spring:message code='Cache.CPMail_info_msg'/>"); // 수신인을 선택해주세요.
			return;
		}
		
		// 팝업
		Common.open("", popupId, "Mail Write", 
				"/mail/bizcard/goMailWritePopup.do?"
				+"callBackFunc=mailWritePopupCallback"
				+"&callMenu="+"BizCard"
				+ userMail
				+ inputUserId
				+ "&popup=Y"
				+ "&popupId="+popupId
				+ "&bizCardSendType="+"S",
				"1000px", "800px", "iframe", true, null, null, true);
		
		
		// 페이지 이동(메일쓰기) -> 화면 이동 후 수신자 세팅해주는 function 호출
		//CoviMenu_GetContent('/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail');
	}
</script>