<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String folder = request.getParameter("folder");
	String searchWord = request.getParameter("searchWord");
	String searchType = request.getParameter("searchType");
	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
	String type = request.getParameter("type");
%>

<div class='cRConTop titType'>
	<h2 class="title" id="reqTypeTxt"><spring:message code='Cache.lbl_CommunityList'/></h2>
	<div class="searchBox02" id="aaa">
		<span><input type="text" id="seValue"  onkeypress="if(event.keyCode==13) {onClickSearchButton(); return false;}" /><button type="button" class="btnSearchType01" onclick="onClickSearchButton()"><spring:message code='Cache.lbl_search'/></button></span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a>
	</div>
</div>
<div class='cRContBottom mScrollVH surveyProgress'>
	<div class="inPerView type02">
		
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Contents'/></span>
				<select id="searchType" class="selectType02">
					<option value="A"><spring:message code='Cache.lbl_all'/></option>
					<option value="C"><spring:message code='Cache.lbl_selCommunityName'/></option>
					<option value="O"><spring:message code='Cache.lbl_Operator'/></option>
				</select>
				<div class="dateSel type02">
					<input id="searchText" type="text" onkeypress="if(event.keyCode==13) {goSearchDetail(); return false;}">
				</div>											
			</div>
			<div>
				<a href="#" id="btnSearch" onclick="goSearchDetail()" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search'/></a>
			</div>
		</div>	
	</div>
	<div class="selectBox" id="selectBoxDiv">
		<select class="selectType02" id="selectSize">
			<option>10</option>
			<option>15</option>
			<option>20</option>
			<option>30</option>
			<option>50</option>
		</select>
		<button href="#" class="btnRefresh" type="button" onclick="onClickSearchButton()"></button>							
	</div>
	<div class="tblList tblCont">
		<form id="form1">
			<div id="gridDiv">
			</div>
		</form>
	</div>
</div>
<script type="text/javascript">
var folder = '<%=folder%>';
var searchWord = '<%=searchWord%>';
var searchType = '<%=searchType%>';
var type = '<%=type%>';

var g_sortColumn = '<%=sortColumn%>';
var g_sortDirectoin =  '<%=sortDirection%>';

var communityGrid = new coviGrid();
var msgHeaderData = "";
var page = 1;
var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");

if(CFN_GetCookie("CommuListCnt")){
	pageSize = CFN_GetCookie("CommuListCnt");
}

$("#selectSize").val(pageSize);
initContent();

//부서휴가유형별조회, 휴가유형별현황
function initContent() {
	
	$('#selectSize').on('change', function(e) {
		pageSize = $(this).val();
		
		CFN_SetCookieDay("CommuListCnt", $(this).find("option:selected").val(), 31536000000);
		
		grid.page.pageSize = $(this).val();
		grid.reloadList();
	});
	
	GridHeader();	// 그리드 세팅
}

communityGrid.config.fitToWidthRightMargin=0;
$(function(){
	
	// 21.08.09, 기존에는 커뮤니티 항목 변경 후 조회하면, searchType이 request parameter에서 null값으로 들어와 'null'(String)로 들어옴. 이때 초기값으로 전체('A')로 설정.
	if (searchType == 'null') {
		searchType = "A";
	}
	
	$("#searchType").val(searchType);	
	searchWord = urlDecodeValue(searchWord);
	if(searchWord != "null" && searchWord != "" && searchWord != null){
		$("#seValue").val(searchWord);
	}else{
		$("#seValue").val("");
		searchWord = "";
	}
	
	var titleTxt = "<spring:message code='Cache.lbl_CommunityList'/>"; // 커뮤니티 목록
	
	switch(type){
		case "best": 
			titleTxt = "<spring:message code='Cache.lbl_ExcellentCommunity'/>"; // 우수 커뮤니티
			break;
		case "new": 
			titleTxt = "<spring:message code='Cache.lbl_NewCommunity'/>"; // 신규 커뮤니티
			break;
	}
	
	$("#reqTypeTxt").text(titleTxt);
	
	setCommunityGrid();
	setEvent();
});

//폴더 그리드 세팅
function setCommunityGrid(){
	communityGrid.setGridHeader(GridHeader());
	selectCommunityList();				
}

function selectCommunityList(){
	var sortColumn = "";
	var sortDicrection  = "";
	
	if(g_sortColumn != "null" && g_sortColumn != "" && g_sortColumn != null){
		sortColumn = g_sortColumn;
	}
	if(g_sortDirectoin != "null" && g_sortDirectoin != "" && g_sortDirectoin != null){
		sortDicrection = g_sortDirectoin;
	}

	//폴더 변경시 검색항목 초기화
	setCommunityGridConfig();
	communityGrid.bindGrid({
		ajaxUrl:"/groupware/layout/selectUserCommunityGridList.do",
		ajaxPars: {
			"CategoryID" : folder,
			"searchWord" : searchWord,
			"searchType" : $("#searchType").val(),
			"sortColumn" : sortColumn,
			"sortDirection" : sortDicrection
		},
	}); 
}
function setCommunityGridConfig(){
	var configObj = {
		targetID : "gridDiv",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height:"auto",
		overflowCell: [11],
		page : {
			pageNo: 1,
			pageSize: (pageSize != undefined && pageSize != '')?pageSize:10,
		},
		paging : true,
		colHead:{},
		body:{
		}
	};
	
	communityGrid.setGridConfig(configObj);
}

function GridHeader(){
	var communityGridHeader = [
								{key:'num', label:"<spring:message code='Cache.lbl_Number'/>", width:'1', align:'center', display:true},
								{key:'AppStatus', label:'AppStatus',display:false, hideFilter : 'Y'},
								{key:'CU_Code', label:'', align:'center', display:false, hideFilter : 'Y'},
								{key:'CU_ID', label:'', align:'center', display:false, hideFilter : 'Y'},
								{key:'CommunityName',  label:"<spring:message code='Cache.lbl_selCommunityName'/>",width:'2',display:true,formatter:function () {
			      		  			var html = "";
			      		  			
			      		  			if(this.item.AppStatus == "RA" || this.item.AppStatus == "UV"){
			      		  				html = String.format("<div title='[<spring:message code='Cache.lbl_adstandby'/>] {0}'> <span class='btnType02'><spring:message code='Cache.lbl_adstandby'/></span> {0}</div>",this.item.CommunityName);
			      		  			} else if(this.item.AppStatus == "RD"){
			      		  			html = String.format("<div title='[<spring:message code='Cache.CuAppDetail_RD'/>] {0}'> <span class='btnType02'><spring:message code='Cache.CuAppDetail_RD'/></span> {0}</div>",this.item.CommunityName);
			      		  			} else{
				      		        	html = String.format("<div title='{0}' class='tblLink'><a href='#' onclick='javascript:goCommunitySite({1});'>{0}</a></div>", this.item.CommunityName, this.item.CU_ID);
			      		  			}
			      		  			
		      		        		return html;
		      		        	}}, 
		      		        	{key:'SearchTitle',  label:"<spring:message code='Cache.lbl_CommunityIntro'/>",width:'3',align:'center',display:true, formatter:function(){
		      		        		return String.format("<div title='{0}'>{0}</div>", this.item.SearchTitle);
		      		        	}},  
								{key:'CommunityType',  label:"<spring:message code='Cache.lbl_type'/>",width:'1',align:'center',display:true},  
								{key:'CommunityJoin',  label:"<spring:message code='Cache.lbl_JoinMethod'/>",width:'2',align:'center',display:true},  
								{key:'MembersCount',  label:"<spring:message code='Cache.lbl_User_Count'/>",width:'1',align:'center',display:true},  
								{key:'Point',  label:'Point',width:'1',align:'center',display:true},  
								{key:'Grade',  label:"<spring:message code='Cache.lbl_RankTitle'/>",width:'1',align:'center',display:true,formatter:function () {
			      		  			var html = "";
			      		  			if(this.item.Grade == "1"){
				      		        	html = "<div class='tblRankingImgBox gold'><strong class='colorBk'>1</strong></div>";
			      		  			}else if(this.item.Grade == "2"){
			      		  				html = "<div class='tblRankingImgBox silver'><strong class='colorBk'>2</strong></div>";
			      		  			}else  if(this.item.Grade == "3"){
			      		  				html = "<div class='tblRankingImgBox copper'><strong class='colorBk'>3</strong></div>";
			      		  			}else{
			      		  			    html = this.item.Grade;
			      		  			}
		      		        		return html;
		      		        	}},  
								{key:'DisplayName',  label:"<spring:message code='Cache.lbl_Operator'/>",width:'2',align:'center',display:true, formatter: function(){
								     return coviCtrl.formatUserContext("List", this.item.DisplayName, this.item.UserCode, this.item.MailAddress);
								}},  
								{key:'RegProcessDate',  label:"<spring:message code='Cache.lbl_Establishment_Day'/>" +Common.getSession("UR_TimeZoneDisplay"),width:'2',align:'center',display:true,
									formatter:function(){
										return CFN_TransLocalTime(this.item.RegProcessDate,_ServerDateSimpleFormat);
									}	
								},
								{key:'CategoryID',  label:'',display:false, hideFilter : 'Y'},
		      		        	{key:'UserCode',  label:'UserCode', align:'center' , display:false, hideFilter : 'Y'} 
	      		        ];
	msgHeaderData = communityGridHeader;
	return communityGridHeader;
}

function onClickSearchButton(){
	$.ajax({
		url:"/groupware/layout/communitySearchWordPoint.do",
		type:"POST",
		async:false,
		data:{
			SearchWord : $("#seValue").val()
		},
		success:function (m) {
			//CoviMenu_GetContent('/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&searchWord='+$("#seValue").val()+"&searchType=C&CategoryID="+folder);
		
			searchWord = $("#seValue").val();
			searchType =   $("#searchType").val();
			
			//커뮤니티 전체 검색
			if(Common.getBaseConfig("communitySearchOption") == 'Y'){
				folder = "";
				// 검색 시 페이지 타이틀 변경
				$("#reqTypeTxt").text(Common.getDic("lbl_CommunityList"));
			}

			
			selectCommunityList();
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communitySearchWordPoint.do", response, status, error); 
		}
	}); 
	
}

function goSearchDetail(){
	$.ajax({
		url:"/groupware/layout/communitySearchWordPoint.do",
		type:"POST",
		async:false,
		data:{
			SearchWord : $("#searchText").val()
		},
		success:function (m) {
			//CoviMenu_GetContent('/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&searchWord='+$("#searchText").val()+"&searchType="+$("#searchType").val()+"&CategoryID="+folder);
			
			searchWord = $("#searchText").val();
			searchType = $("#searchType").val();
			folder = "";
			selectCommunityList();
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communitySearchWordPoint.do", response, status, error); 
		}
	}); 
}

function refresh(){
	selectCommunityList(); 	
}

function goCommunitySite(community){
	 var specs = "left=10,top=10,width=1050,height=900";
	 specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
	 window.open("/groupware/layout/userCommunity/communityMain.do?C="+community, "community", specs);
}

function setEvent(){
	$("#selectSize").change(function(){
		selectCommunityList(); 	
	});

	$('.btnSearchBlue').on('click', function() {
		goSearchDetail();
	});
	
	$('.btnDetails').unbind("click");
	$('.btnDetails').bind("click",function(){
		var mParent = $('.inPerView');
		if(mParent.hasClass('active')){
			mParent.removeClass('active');
			$(this).removeClass('active');
		}else {
			mParent.addClass('active');
			$(this).addClass('active');
		}
	});
	
}
</script>