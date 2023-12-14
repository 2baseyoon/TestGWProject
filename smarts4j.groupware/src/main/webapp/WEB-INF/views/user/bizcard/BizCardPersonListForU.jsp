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
		<h2 class="title"><spring:message code='Cache.lbl_CompList' /></h2> <!-- 회사용 목록 -->
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
					<%-- <a href="#"  id="btnMail"  class="btnTypeDefault btnIco btnMail mr5" onclick="alert('<spring:message code='Cache.msg_037' />');"><!-- 아직 중비 중 입니다. --><spring:message code="Cache.btn_Mail"></spring:message></a><!-- 메일 -->
					<a href="#"  id="btnSMS"  class="btnTypeDefault btnIco btnSms mr5" onclick="alert('<spring:message code='Cache.msg_037' />');"><!-- 아직 중비 중 입니다. --><spring:message code="Cache.btn_SMS"></spring:message></a><!-- SMS --> --%>
					<%-- <a href="#"  id="btnCopy"  class="btnTypeDefault right" onclick="AdjustCheck(bizCardGrid, 'C');"><spring:message code="Cache.btn_Copy"></spring:message></a><!-- 복사 --> --%>
					<a href="#"  id="btnMove" class="btnTypeDefault middle" onclick="AdjustCheck(bizCardGrid, 'M');"><spring:message code="Cache.btn_Move"></spring:message></a><!-- 이동 -->
					<a href="#"  id="btnDelete" class="btnTypeDefault left"><spring:message code="Cache.btn_delete"></spring:message></a><!-- 삭제 -->
					<c:if test='${assignedMail}'>
					<a href="#"  id="btnMail"  class="btnTypeDefault btnIco btnMail mr5" onclick="goWriteMail(this);"><spring:message code="Cache.CPMail_mail"></spring:message></a><!-- 메일 -->
					</c:if>
					<!-- a href="#"  id="saveExlBtn" class="btnTypeDefault btnExcel" onclick="ExcelDownload();"><spring:message code='Cache.btn_SaveToExcel' /></a> 엑셀저장 -->
					<a href="#"  id="btnEachExport" class="btnTypeDefault left" onclick="eachExportImportExport(bizCardGrid);"><spring:message code="Cache.lbl_EachExportContact"></spring:message></a><!-- 개별 연락처 내보내기 -->
					<select class="selectType02 selectGroupLg" id="bizCardListGroup" onchange="clickBizcardType(this)" style="width:130px;display:;">
						<option value="ALL" selected><spring:message code='Cache.lbl_Whole'/></option> <!-- 전체 -->
						<option value="Bizcard"><spring:message code='Cache.lbl_Mail_Contact' /></option> <!-- 연락처 -->
						<option value="Group"><spring:message code='Cache.lbl_group' /></option> <!-- 그룹 -->
					</select>
				</div>
				<div class="buttonStyleBoxRight">	
					<select class="selectType02 listCount" id="selDataPerPageCnt" ><!-- 아직 중비 중 입니다. -->
						<option value="10">10</option> 
						<option value="15">15</option> 
						<option value="20">20</option> 
						<option value="30">30</option> 
						<option value="50">50</option> 
					</select>
					<%-- <a href="#" class="btnTypeDefault btnThemeLine"><spring:message code='Cache.btn_SelectFromOrg'/></a> --%><!-- 조직도 가져오기 -->
					<!-- <button type="button" class="btnIcoComm btnPrint" type="button" onclick="alert('<spring:message code='Cache.msg_037' />');">
					<spring:message code='Cache.lbl_Print'/>
				</button>  --><!-- 인쇄 -->
					<a href="#" id="listView" class="btnListView listViewType01 active">리스트보기1</a>
					<a href="#" id="albumView" class="btnListView listViewType02" style="margin-left:-5px;">리스트보기2</a>
					<button type="button"  class="btnRefresh" type="button" onclick="refresh()"></button> <!-- 새로고침 -->
				</div>
			</div>	
			<div class="selectListWrap autoCompleteCustom active">
				<div class="heading">
					<span><spring:message code='Cache.lbl_Choice' /></span><!-- 선택 -->
					<strong class="colorTheme">0</strong>
					<button class="btnRemoveAll" type="button" onclick="resetSelectedGroup();"><spring:message code='Cache.btn_DelAll' /></button><!-- 전체삭제 -->
				</div>
				<ul class="ui-autocomplete-multiselect ui-state-default ui-widget">
				</ul>
				<a class="btnMoreStyle01 active" href="#">fold list</a>
			</div>
			<div id="divTabTray" class="tblList tblCont tblBizcardList">
				<div class="tblFilterTop">
					<!-- p class="filterGroup">
						<a id="bizCardListGroup" href="#" onclick="clickTab(this);" value="Group"><spring:message code='Cache.lbl_group' /></a>
					</p-->
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

	var bizCardViewType = "U";
	var bizCardGrid = new coviGrid();
	var msgHeaderData = getGridHeader("P");
	var groupID = "";
	var page = 1;
	var storagePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("BizListCnt")){
		pageSize=CFN_GetCookie("BizListCnt");
	}
	
	$("#selDataPerPageCnt").val(pageSize);
	function clickBizcardType(pObj){
		$('#btnDelete').removeAttr('onclick');
		
		if($(pObj).val() == "Group"){
			$("#btnDelete").attr("onclick", "BizCardDeleteCheck(bizCardGrid, bizCardViewType, 'Group')");
		} else{
			$("#btnDelete").attr("onclick", "BizCardDeleteCheck(bizCardGrid, bizCardViewType, 'Person')");
		}
		
		if(viewType == "Album") {
			bindGridAlbumDataAll();
		} else {
			bizCardGrid = new coviGrid();

			// setGrid();  2019-01-03  iwyoon 그룹,연락처 통합조회를 위해 수정
			setGridAll();
		}		
	}	
	//***************************************************************************************************************************/
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGridAll(){		
		//개인, 부서, 회사
		var tabFilter = $("#bizCardListGroup").val();
		var UR_ID = Common.getSession("UR_ID");
		
		if(tabFilter == "ALL"){	
			$("ul.filterList").show();
			
			bizCardGrid.setGridHeader([
				{key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox',
					disabled:function(){
						if(UR_ID != this.item.RegisterID && sessionObj["isAdmin"] != "Y"){
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
				{key:'PhoneNum',  label:"<spring:message code='Cache.lbl_MobilePhone'/>", width:'100', align:'center', formatter : function() { 		//핸드폰
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
				{key:'ComName',  label:"<spring:message code='Cache.lbl_Company'/>", width:'70', align:'center'}, //회사
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
				{key:'JobTitle', label:"<spring:message code='Cache.lbl_JobTitle'/>", width:'70', align:'center'},
				{key:'RegisterName', label:"<spring:message code='Cache.lbl_Register'/>", width:'70', align:'center'},
				{key:'RegistDate', label:"<spring:message code='Cache.lbl_RegistDate'/>", width:'100', align:'center'}
      		]);
		} else if(tabFilter == "Bizcard"){	
			$("ul.filterList").show();
			
			bizCardGrid.setGridHeader([
 				  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
 				  {key:'IsFavorite',hideFilter : 'Y',colHeadTool:false,  label:'<a class=\"tblBtnFavorite\" href=\"#\">Favorite</a>', width:'20', align:'center', sort:false, formatter : function() {
                  	  var IsFavorite = "<span style='color:black;' onclick='ChangeFavoriteStatus(" + this.item.BizCardID + ",this)'>";
                 	  switch(this.item.IsFavorite) {
 	                	  case "Y" : IsFavorite += "<a class=\"tblBtnFavorite active\" href=\"#\">Favorite</a>"; break; 
 	                	  default : IsFavorite += "<a class=\"tblBtnFavorite\" href=\"#\">Favorite</a>"; break;
                 	  }
                 	  IsFavorite += "</span>"; 
                 	  return IsFavorite;
                   }},
                   {key:'Name',  label:"<spring:message code='Cache.lbl_name'/>", width:'100', align:'left', //이름
                 	  formatter:function () {
                 		  var sReturn = "<span onclick='ChangeFavoriteStatus(" + this.item.BizCardID + ",this)' class=\"thumb ";
                 		  if(this.item.ImagePath != "" && this.item.ImagePath != undefined) {
                 			  sReturn +=  "\">";
               			  	  sReturn +=  "<img name=\"bizCardThumbnail\" style=\"width: auto; height: 100%;\" onerror='this.src=\""+ "/covicore/resources/images/common/noImg.png\"' src=\"" + coviCmn.loadImage(storagePath + this.item.ImagePath);
       					  } else {
       						  sReturn +=  "noImg \">";
       						  sReturn += "<img name=\"bizCardThumbnail\" style=\"width: auto; height: 100%;\" src=\"" + "/covicore/resources/images/common/noImg.png";
       					  }
                 		sReturn += "\" /></span>&nbsp;";
               			sReturn += "<a href='#' onclick='viewBizCardPop(\""+ this.item.BizCardID +"\"); return false;'>"+this.item.Name+"</a>";
                 		
       					return sReturn;
       				}},
                   {key:'PhoneNum',  label:"<spring:message code='Cache.lbl_MobilePhone'/>", width:'70', align:'center', formatter : function() { //핸드폰
                 		var PhoneNum = this.item.PhoneNum;
                 		if(PhoneNum.indexOf(";") > 0)
                 			PhoneNum = PhoneNum.substr(0,PhoneNum.indexOf(";"));
                 		return PhoneNum;
                   }},
                   {key:'EMAIL', label:"<spring:message code='Cache.lbl_Email2'/>", width:'100', align:'center', formatter : function() { //이메일
                 		var EMAIL = this.item.EMAIL;
                 		if(EMAIL.indexOf(";") > 0)
                 			EMAIL = EMAIL.substr(0,EMAIL.indexOf(";"));
                 		return EMAIL;
                   }},
                   {key:'ComName',  label:"<spring:message code='Cache.lbl_Company'/>", width:'100', align:'center'}, //회사
                   {key:'ComPhoneNum',  label:"<spring:message code='Cache.lbl_HomePhone'/>", width:'70', align:'center', formatter : function() { //회사 전화
                 		var ComPhoneNum = this.item.ComPhoneNum;
                 		if(ComPhoneNum.indexOf(";") > 0)
                 			ComPhoneNum = ComPhoneNum.substr(0,ComPhoneNum.indexOf(";"));
                 		return ComPhoneNum;
                   }},
                   {key:'JobTitle', label:"<spring:message code='Cache.lbl_JobTitle'/>", width:'100', align:'center'}
 	      		]);
 		} else { 
 			//그룹
			$("ul.filterList").hide();
			
			bizCardGrid.setGridHeader([
				{key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
				{key:'Groupname', label:"<spring:message code='Cache.lbl_GroupName'/>", width:'70', align:'center', formatter: function(){ //그룹명
					var url = '';
					url += '<a onclick="searchBizCardGroupPersonListPop(\'' + bizCardViewType + '\', \'' + this.item.GroupID + '\', \'' + this.item.Groupname + '\');">';
					url += '<span>' + this.item.Groupname + '</span>';
					url += '</a>';
					
					return url;
				}},
				{key:'MemberCnt', label:"<spring:message code='Cache.lbl_MemberCount'/>", width:'50', align:'center'}, //멤버수
				{key:'Groupname', label:"<spring:message code='Cache.lbl_Modify'/>", width:'40', align:'center', sort:false, formatter : function() { //수정
					return "<button id='btnModify' type='button' class='AXButton' onclick='modifyGroupPop(\""+ bizCardViewType +"\",\""+ this.item.GroupID +"\"); return false;'><spring:message code='Cache.btn_Edit' /></button>";
				}}
      		]);
		}
		//setGridConfig();
		bindGridDataAll();
	}

	function bindGridDataAll() {	
				
		var tabFilter2 = $('#divTabTray').find(".active").first().children().attr('value');
		var tabFilter = $("#bizCardListGroup").val();
		
		var startDate = null;/* $("#startDate").val(); */
		var endDate = null;/* $("#endDate").val(); */
		var searchInput = $("#searchInput").val();
		var searchType = $("#searchType").val();
		
		setGridConfig();
		
		if(tabFilter == "ALL"){
			bizCardGrid.bindGrid({
				ajaxUrl:"/groupware/bizcard/getBizCardAllList.do",
				ajaxPars: {
					shareType : bizCardViewType,
					tabFilter : tabFilter2,
					searchWord : searchInput,
					searchType: searchType,
					startDate : startDate,
					endDate : endDate,
					sortBy: bizCardGrid.getSortParam(),
					groupIDs : groupID
				}
			});			
		}else if(tabFilter == "Group"){
			bizCardGrid.bindGrid({
				ajaxUrl:"/groupware/bizcard/getBizCardGroupList.do",
				ajaxPars: {
					shareType : bizCardViewType,
					sortBy: bizCardGrid.getSortParam()
				},
				onLoad:function () {
					$("#bizCardGrid").find('input[name=checkAll]').hide();
					$("#bizCardGrid").find('input[type=checkbox]').on("click", function(){ chkGroup(this); });
					//chkSelGroupChked();
				}
			});
		}
		else{
			bizCardGrid.bindGrid({
				ajaxUrl:"/groupware/bizcard/getBizCardPersonList.do",
				ajaxPars: {
					shareType : bizCardViewType,
					tabFilter : tabFilter2,
					searchWord : searchInput,
					searchType: searchType,
					startDate : startDate,
					endDate : endDate,
					sortBy: bizCardGrid.getSortParam(),
					groupIDs : groupID
				}
			});
		}
	}
	function setGrid(){		
		//개인, 부서, 회사
		if($("#divTabTray .active").find("a").attr('value') != "Group"){
			bizCardGrid.setGridHeader([
				  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
				  {key:'IsFavorite',hideFilter : 'Y',colHeadTool:false,  label:'<a class=\"tblBtnFavorite\" href=\"#\">Favorite</a>', width:'20', align:'center', sort:false, formatter : function() {
                 	  var IsFavorite = "<span style='color:black;' onclick='ChangeFavoriteStatus(" + this.item.BizCardID + ",this)'>";
                	  switch(this.item.IsFavorite) {
	                	  case "Y" : IsFavorite += "<a class=\"tblBtnFavorite active\" href=\"#\">Favorite</a>"; break; 
	                	  default : IsFavorite += "<a class=\"tblBtnFavorite\" href=\"#\">Favorite</a>"; break;
                	  }
                	  IsFavorite += "</span>"; 
                	  return IsFavorite;
                  }},
                  {key:'Name',  label:"<spring:message code='Cache.lbl_name'/>", width:'100', align:'left', //이름
                	  formatter:function () {
                		  var sReturn = "<span onclick='ChangeFavoriteStatus(" + this.item.BizCardID + ",this)' class=\"thumb ";
                		  if(this.item.ImagePath != "" && this.item.ImagePath != undefined) {
                			  sReturn +=  "\">";
                			  sReturn +=  "<img name=\"bizCardThumbnail\" style=\"width: auto; height: 100%;\" src=\"" + coviCmn.loadImage(storagePath + this.item.ImagePath);
      					  } else {
      						  sReturn +=  "noImg \">";
      						  sReturn += "<img name=\"bizCardThumbnail\" style=\"width: auto; height: 100%;\" src=\"" + "/covicore/resources/images/common/noImg.png";
      					  }
                		sReturn += "\" /></span>&nbsp;";
                		sReturn += "<a href='#' onclick='viewBizCardPop(\""+ this.item.BizCardID +"\"); return false;'>"+this.item.Name+"</a>";
                		
      					return sReturn;
      				}},
                  {key:'PhoneNum',  label:"<spring:message code='Cache.lbl_MobilePhone'/>", width:'70', align:'center', formatter : function() { //핸드폰
                		var PhoneNum = this.item.PhoneNum;
                		if(PhoneNum.indexOf(";") > 0)
                			PhoneNum = PhoneNum.substr(0,PhoneNum.indexOf(";"));
                		return PhoneNum;
                  }},
                  {key:'EMAIL', label:"<spring:message code='Cache.lbl_Email2'/>", width:'100', align:'left', formatter : function() { //이메일
                		var EMAIL = this.item.EMAIL;
                		if(EMAIL.indexOf(";") > 0)
                			EMAIL = EMAIL.substr(0,EMAIL.indexOf(";"));
                		return EMAIL;
                  }},
                  {key:'ComName',  label:"<spring:message code='Cache.lbl_Company'/>", width:'100', align:'left'}, //회사
                  {key:'ComPhoneNum',  label:"<spring:message code='Cache.lbl_HomePhone'/>", width:'70', align:'center', formatter : function() { //회사 전화
                		var ComPhoneNum = this.item.ComPhoneNum;
                		if(ComPhoneNum.indexOf(";") > 0)
                			ComPhoneNum = ComPhoneNum.substr(0,ComPhoneNum.indexOf(";"));
                		return ComPhoneNum;
                  }},
                  {key:'JobTitle', label:"<spring:message code='Cache.lbl_JobTitle'/>", width:'100', align:'left'} //직책
	      		]);
		} else { 
			//그룹
			bizCardGrid.setGridHeader([
					  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
					  {key:'Groupname',  label:"<spring:message code='Cache.lbl_GroupName'/>", width:'70', align:'center', formatter: function(){ //그룹명
               		return this.item.Groupname + "<span style='display:none;'>" + this.item.GroupID + "</span>"; 
                 }},
                 {key:'MemberCnt',  label:"<spring:message code='Cache.lbl_MemberCount'/>", width:'50', align:'center'}, //멤버수
                 {key:'Groupname',  label:"<spring:message code='Cache.lbl_Modify'/>", width:'40', align:'center', sort:false, formatter : function() { //수정
               	  return "<button id='btnModify' type='button' class='AXButton' onclick='modifyGroup(\""+ bizCardViewType +"\",\""+ this.item.GroupID +"\"); return false;'><spring:message code='Cache.btn_Edit' /></button>"; 
              	  }}
      		]);
		}
		//setGridConfig();
		bindGridData();
	}

	function bindGridData() {	
		
		
		var tabFilter = $('#divTabTray').find(".active").first().children().attr('value');
		var startDate = null;/* $("#startDate").val(); */
		var endDate = null;/* $("#endDate").val(); */
		var searchInput = $("#searchInput").val();
		var searchType = $("#searchType").val();
		
		setGridConfig();
		
		if(tabFilter == "Group"){
			bizCardGrid.bindGrid({
				ajaxUrl:"/groupware/bizcard/getBizCardGroupList.do",
				ajaxPars: {
					shareType : bizCardViewType,
					sortBy: bizCardGrid.getSortParam()
				},
				onLoad:function () {
					$("#bizCardGrid").find('input[name=checkAll]').hide();
					$("#bizCardGrid").find('input[type=checkbox]').on("click", function(){ chkGroup(this); });
					//chkSelGroupChked();
				}
			});
		}
		else{
			bizCardGrid.bindGrid({
				ajaxUrl:"/groupware/bizcard/getBizCardPersonList.do",
				ajaxPars: {
					shareType : bizCardViewType,
					tabFilter : tabFilter,
					searchWord : searchInput,
					searchType: searchType,
					startDate : startDate,
					endDate : endDate,
					sortBy: bizCardGrid.getSortParam(),
					groupIDs : groupID
				}
			});
		}
	}

	//***************************************************************************************************************************/
	
	// 새로고침
	function refresh(){
		if(viewType == "Album") {
			bindGridAlbumDataAll();
		} else {
			setGridAll();
		}
	}
	
	//***************************************************************************************************************************/
	
	//그룹 바인딩 : 체크박스에 체크시 처리
	var chkGroup = function(obj) {
		
		if(obj.checked == true){
			
			var sGroupID = "";
			var sGroupname = "";
			var sHTML = ""; 
			
			sGroupID = $(obj).closest('tr').children('td:nth-child(2)').find('span').text();
			sGroupname = $(obj).closest('tr').children('td:nth-child(2)').text().split(sGroupID)[0];	
			
			var cloneli = "<li id=\"" + sGroupID + "\"><div class=\"ui-autocomplete-multiselect-item\">";
			cloneli += sGroupname;
			cloneli += "<span class=\"ui-icon ui-icon-close\" onclick=\"deleteGroupBind(this);\"></span></div></li>"
			
			if($('ul.ui-autocomplete-multiselect').children('li').length == 0){
				$('ul.ui-autocomplete-multiselect').prepend(cloneli)
			} else{
				$('ul.ui-autocomplete-multiselect').children('li:last').after(cloneli);	
			}			
			
			groupID += sGroupID + ';';
			
		}
		else{
			
			var sGroupID = $(obj).closest('tr').children('td:nth-child(2)').find('span').text();
			$('ul.ui-autocomplete-multiselect').find('li[id=\"' + sGroupID +  '\"]').remove();
			groupID = groupID.replace(sGroupID+";", "");
	
		}
		setSelGroupDisplay();
	}
	
	//그룹 바인딩 해지 : 선택 그룹 표기 삭제, 체크박스 해지
	function deleteGroupBind(obj){
		groupID = groupID.replace($(obj).parent().parent().attr('id')+";", "");
		$(obj).closest('li').remove();
		
		if($("#divTabTray .active").find("a").attr('value') == "Group"){
			$('#bizCardGrid').find("span:contains('"+ $(obj).parent().parent().attr('id') +"')").parent().parent().parent().find('td:first-of-type input[type=checkbox]')[0].checked = false;
		} else{
			clickTab($("#divTabTray .active").find("a"));
		}
		
		setSelGroupDisplay();
	}
	
	//그룹 바인딩 : 선택 그룹에 포함된 chk 체크
	function chkSelGroupChked(){
		if($('ul.ui-autocomplete-multiselect').children('li').length > 0){
			$('ul.ui-autocomplete-multiselect').children('li').each (function() {
				$('#bizCardGrid').find("span:contains('"+ this.id +"')").parent().parent().parent().find('td:first-of-type input[type=checkbox]')[0].checked = true;
			});   		
		}
	}
	
	//그룹 바인딩 : 선택 그룹 표기 영역 display 여부
	function setSelGroupDisplay(){
		$('div.selectListWrap').hide();
		/*  선택그룹표시영역 display 안함
		if($('div.selectListWrap').children('ul').children('li').length > 0){
			$('div.selectListWrap').show();
		}
		else {
			$('div.selectListWrap').hide();
		}
		*/
		setSelectedGroupCnt();
	} 
	
	//그룹 바인딩 : 초기화
	function resetSelectedGroup(){
		$('div.selectListWrap').children('ul').children('li').remove();
		groupID = "";
		$('div.selectListWrap').hide();
		$('#bizCardGrid').find('td:first-of-type input[type=checkbox]').each(function() {
			this.checked = false;
		});
	}
	
	//그룹 바인딩 : 선택된 값 변경
	function setSelectedGroupCnt(){
		$('strong.colorTheme').text($('ul.ui-autocomplete-multiselect').children('li').length);
	}
	
	//***************************************************************************************************************************/
	
	//엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirm Dialog", function(result) {
			if(result){
				var headerName = getHeaderNameForExcel();
				var sortKey = "Date";//bizCardGrid.getSortParam("one").split("=")[1].split(" ")[0]; 
				var sortWay = "DESC"; //bizCardGrid.getSortParam("one").split("=")[1].split(" ")[1]; 				  	
				
				location.href = "/groupware/bizcard/bizCardListExcelDownload.do?sortColumn="+sortKey+"&sortDirection="+sortWay+"&tabFilter="+ $('#divTabTray').find(".active").first().children().attr('value') +"&searchWord="+ $("#searchInput").val() +"&searchType="+ $("#searchType").val() +"&shareType="+ bizCardViewType + "&groupID=" + groupID + "&headerName="+headerName;
			}
		});
	}

	//엑셀용 Grid 헤더정보 설정
	function getHeaderNameForExcel(){
		var returnStr = "";
		
	   	for(var i=0;i<msgHeaderData.length; i++){
	   	   	if(msgHeaderData[i].display != false && msgHeaderData[i].label != 'chk'){
	   	   		if(msgHeaderData[i].key == 'IsFavorite')
	   	   			returnStr += "<spring:message code='Cache.lbl_Favorite'/>" + ";";
   	   			else
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
	
	var searchWorkReport = function() {
		if(viewType == "Album") {
			bindGridAlbumDataAll();
		} else {
			// bindGridData();  2019-01-03  iwyoon 그룹,연락처 통합조회를 위해 수정
			bindGridDataAll();
		}
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
			bindGridAlbumDataAll();
		} else {
			bindGridDataAll();
		}
	}
		
	//탭 선택(그리드 헤더 변경)
	function clickTab(pObj){
		bizCardGrid = new coviGrid();		
		
		$("#divTabTray").find("a").parent().removeClass("active");
		$(pObj).parent().addClass("active");
		$("#searchInput").val("");
		
		if($("#divTabTray .active").find("a").attr('value') == 'Group'){
			if($('#bizcard_btn_group').css("display") != "none") {
				$('#bizcard_btn_group').css("display", "none");
				$('#group_btn_group').css("display", "block");
			}
			$('#btnDelete').removeAttr('onclick');
			$("#btnDelete").attr("onclick", "BizCardDeleteCheck(bizCardGrid, bizCardViewType, 'Group')");
		} else{
			if($('#group_btn_group').css("display") != "none") {
				$('#bizcard_btn_group').css("display", "block");
				$('#group_btn_group').css("display", "none");
			}
			$('#btnDelete').removeAttr('onclick');
			$("#btnDelete").attr("onclick", "BizCardDeleteCheck(bizCardGrid, bizCardViewType, 'Person')");
		}
		
		//setGrid();
		page = 1;
		if(viewType == "Album") {
			bindGridAlbumDataAll();
		} else {
			setGridAll();
		}
	}
		
	var viewBizCardPop = function(id) { //명함 보기
		var BizCardID = id;
		
		//return;
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
		
		$.urlParam = function(name){
			var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
			if(results != null)
				return results[1] || 0;
			else
				return null;
		}
		
		$('#btnDelete').removeAttr('onclick');
		$("#btnDelete").attr("onclick", "BizCardDeleteCheck(bizCardGrid, bizCardViewType, 'Person')");
		
		if($.urlParam('grpid') != null){
			
			var grpID = ($.urlParam('grpid'));
			
			$.getJSON('/groupware/bizcard/getGroup.do', {ShareType : bizCardViewType, GroupID : ($.urlParam('grpid'))}, function(d) {
				d.list.forEach(function(d) {
					var sGroupID = "";
					var sGroupname = "";
					var sHTML = ""; 

					sGroupID = grpID;
					sGroupname = d.GroupName;

					var cloneli = "<li id=\"" + sGroupID + "\"><div class=\"ui-autocomplete-multiselect-item\">";
					cloneli += sGroupname;
					cloneli += "<span class=\"ui-icon ui-icon-close\" onclick=\"deleteGroupBind(this);\"></span></div></li>"

					if($('ul.ui-autocomplete-multiselect').children('li').length == 0){
						$('ul.ui-autocomplete-multiselect').prepend(cloneli)
					} else{
						$('ul.ui-autocomplete-multiselect').children('li:last').after(cloneli);	
					}
					
					setSelGroupDisplay();
				});
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("/groupware/bizcard/getGroup.do", response, status, error);
			});
			
			groupID =  grpID + ";";
			
		}
		
		//리스트보기
		$("#listView").off('click').on('click', function(){
			changeBizCardBoardView();
			setGridAll();
		});

		//앨범보기
		$("#albumView").off('click').on('click', function(){
			changeBizCardAlbumView();
			bindGridAlbumDataAll();
		});
		
		//그리드 설정
		setGridAll();
		
		$(".selectSearchField").on("change", function() {
			page = 1;
			if(viewType == "Album") {
				//bindGridAlbumData(); 2019-01-09  iwyoon 그룹,연락처 통합조회를 위해 수정
				bindGridAlbumDataAll();
			} else {
				// bindGridData();  2019-01-03  iwyoon 그룹,연락처 통합조회를 위해 수정
				bindGridDataAll();
			}
		});
		
		$("#selDataPerPageCnt").on("change", function(){
			page = 1;
			if(viewType == "Album") {
				//bindGridAlbumData(); 2019-01-09  iwyoon 그룹,연락처 통합조회를 위해 수정
				bindGridAlbumDataAll();
			} else {
				//bindGridData();  2019-01-03  iwyoon 그룹,연락처 통합조회를 위해 수정
				bindGridDataAll();
			}
			CFN_SetCookieDay("BizListCnt", $(this).find("option:selected").val(), 31536000000);
		});
		
		//검색 조건 설정
		setSelGroupDisplay(); 		
		
		bindSelect(); 
	}
	
	//카드형 보기
	function bindGridAlbumDataAll(){

		var tabFilter2 = $('#divTabTray').find(".active").first().children().attr('value');
		var tabFilter = $("#bizCardListGroup").val();
		var startDate = null;/* $("#startDate").val(); */
		var endDate = null;/* $("#endDate").val(); */
		var searchInput = $("#searchInput").val();
		var searchType = $("#searchType").val();
		
		if(tabFilter == "Group"){
			changeBizCardBoardView();
			setGridAll();
		}
		else{	
			var searchParam = {
				"tabFilter" : tabFilter2,
				"startDate" : startDate,
				"endDate" : endDate,
				"searchInput" : searchInput,
				"searchType" : searchType,
				"shareType" : bizCardViewType,
				"sortBy" : bizCardGrid.getSortParam("one").split("=").pop(),
				"searchWord" : searchInput,
				"groupIDs" : groupID
			}
			
			if(page != undefined && page != ''){
				bizCardAlbum.page.pageNo = page;
			}
			bizCardAlbum.page.pageSize = $("#selDataPerPageCnt").val();
			bizCardAlbum.page.sortBy = bizCardGrid.getSortParam("one").split("=").pop();	

			bizCardAlbum.target = 'bizCardAlbum';
			if(tabFilter == "ALL"){
				bizCardAlbum.url = "/groupware/bizcard/getBizCardAllList.do";
			}else{
				bizCardAlbum.url = "/groupware/bizcard/getBizCardPersonList.do";				
			}			
			bizCardAlbum.setList(searchParam);
		}
	}
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
				"searchWord" : searchInput,
				"groupIDs" : groupID
			}
			
			if(page != undefined && page != ''){
				bizCardAlbum.page.pageNo = page;
			}
			bizCardAlbum.page.pageSize = $("#selDataPerPageCnt").val();
			bizCardAlbum.page.sortBy = bizCardGrid.getSortParam("one").split("=").pop();	

			bizCardAlbum.target = 'bizCardAlbum';
			bizCardAlbum.url = "/groupware/bizcard/getBizCardPersonList.do";
			bizCardAlbum.setList(searchParam);
		}
	}
</script>