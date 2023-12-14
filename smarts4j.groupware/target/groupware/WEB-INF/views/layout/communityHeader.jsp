<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.baseframework.data.CoviMap"%>
<%@ page import="egovframework.coviframework.logging.LoggerHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	String appPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
%>

<script type="text/javascript" src="/groupware/resources/script/user/schedule.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/groupware/resources/script/user/schedule_google.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/groupware/resources/script/user/event_calendar.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/groupware/resources/script/user/event_date.js<%=resourceVersion%>"></script>

<link rel="stylesheet" id="cheader" type="text/css"  /> 
<!-- grid css -->
<%
String C = (String)request.getAttribute("C");
String activeKey = (String)request.getAttribute("activeKey");
String part = (String)request.getAttribute("part");

CoviMap params = new CoviMap();
params.put("CU_ID", C);

if ((request.getParameter("IsAdmin") == null || !request.getParameter("IsAdmin").equals("Y")) && egovframework.covision.groupware.auth.CommunityAuth.getDomainAuth(params) != true) {
	LoggerHelper.authErrorLogger((String) request.getAttribute("javax.servlet.forward.request_uri"), "NOAUTH", "", "", "Unauthorized : No Permission", "page");
	out.println("<script language='javascript'>CoviMenu_GetContent('/groupware/layout/board_BoardAuthError.do?CLSYS=Community&CLMD=user&CLBIZ=Community');</script>");
	return;
}
%>

<script type="text/javascript">
var cID = '<%=C %>';
var mActiveKey = '<%= activeKey%>';
var part = '<%=part%>';
var dnID = '';
var folderCheckList = ";";
var g_lastURL = "/groupware/layout/schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType=M&CSMU=C&communityId="+cID+"&activeKey="+mActiveKey;

var level = "0";

var QuickFolder = "";
var QuickFType = "";

var portalID = "";

var cType = "C"; //2019.11 커뮤니티(C), 프로젝트룸구분(T)

var communityCssPath = '<%=appPath %>';
var communityTheme = '';

$(function(){
	setHeader();
	inCommMenu();

/* 	// 플로워 팝업메뉴
	$('body').on('click', '.btnFlowerName', function(){
		var sibNode = $(this).siblings('.flowerMenuList');
		if(sibNode.hasClass('active')){			
			sibNode.removeClass('active');
		}else {
			$('.flowerMenuList').removeClass('active');
			sibNode.addClass('active');
		}
	}); */
	
/* 	// 플로워 팝업메뉴
	$('body').on('click', '.btnFlowerName', function(){
    	//이벤트 호출시 flowerPopup내부 Context Menu 태그 생성
		if($(this).closest('.flowerPopup').find('.flowerMenuList').size() == 0){
    		$(this).closest('.flowerPopup').coviCtrl('setUserInfoContext');
    	}
		var sibNode = $(this).closest('.flowerPopup').find('.flowerMenuList');
		if(sibNode.hasClass('active')){			
			sibNode.removeClass('active');
		}else {
			$('.flowerMenuList').removeClass('active');
			sibNode.addClass('active');
		}
	}); */
});

function setHeader(){
	
	$.ajax({
		url:"/groupware/layout/userCommunity/communityHeaderSetting.do",
		type:"POST",
		async:false,
		data:{
			communityID : cID
		},
		success:function (data) {
			if(data!=null && data.list!=null &&data.list.length > 0){
				$(data.list).each(function(i,v){
					dnID = v.DN_ID;
					portalID = v.PortalID;
					QuickFolder = v.FolderID;
					cType = v.Gubun;
					
					if (window.sessionStorage.getItem("communityAdmin") != null && window.sessionStorage.getItem("communityAdmin") != "" && window.sessionStorage.getItem("communityAdmin") == "Y") {
						v.MemberLevel = "9";
					}
					
					var cuTheme = (v.CommunityTheme != '' && v.CommunityTheme != null) ? v.CommunityTheme : 'blue';
					//$("#cheader").attr("href",communityCssPath+"/HtmlSite/smarts4j_n/covicore/resources/css/theme/community/"+cuTheme+".css?v="+v.nowDate);
					$("#cheader").attr("href",communityCssPath+"/covicore/resources/css/theme/community/"+cuTheme+".css?v="+v.nowDate);
					communityTheme = cuTheme;

					if(v.FilePath != null && v.FilePath != ''){
						if(v.FileCheck == "true"){
							var imgPath = coviCmn.loadImage(v.FilePath);
							$(".individualCommunity header").css("background", "url("+imgPath+") no-repeat center 0");
						}else{
							$(".individualCommunity header").css({'background':"url(/HtmlSite/smarts4j_n/covicore/resources/images/common/img_main_banner.jpg) no-repeat center 0"});
						}
					}else{
						$(".individualCommunity header").css({'background':"url(/HtmlSite/smarts4j_n/covicore/resources/images/common/img_main_banner.jpg) no-repeat center 0"});
					}

					if(v.BFilePath != '' && v.BFilePath != null){
						if(v.BFileCheck == "true"){
							var bImgPath = coviCmn.loadImage(v.BFilePath);
							$(".individualContent").css({'background':"url("+bImgPath+") repeat"});
						}else{
							$(".individualContent").css({'background':"#fff"});
						}
					}else{
						$(".individualContent").css({'background':"#fff"});
					}
					
					$("#Cname").text(v.CommunityName);
					//2019.11 - 동호회 다국어 처리 
					if(cType == "T"){
						$("#CcateGory").text(Common.getDic("CommunityDefaultBoardType_"+v.DefaultBoardType));
					}else{
						$("#CcateGory").text(v.categoryName+" "+Common.getDic("CommunityDefaultBoardType_"+v.DefaultBoardType));
					}
					level = v.MemberLevel;
					if(cType == "T"){
						//프로젝트룸은 즐겨찾기 지원하지 않음
					}else{
						if(v.MemberLevel == "9"){
							if(v.favoriteCnt != "0" && v.favoriteCnt != null && v.favoriteCnt != ''){
				    			$("#inTM").html("<a onclick='favoriteDel();' class='btnIndividualFavoriteAdd active'><spring:message code='Cache.btn_Favorite'/></a><a href='#' onclick='setTopMenu();' class='btnIndividualOption ml5'></a>");
				    		}else{
				    			$("#inTM").html("<a onclick='favoriteAdd();' class='btnIndividualFavoriteAdd'><spring:message code='Cache.btn_Favorite'/></a><a href='#' onclick='setTopMenu();' class='btnIndividualOption ml5'></a>");
				    		}
						}else{
							if(v.favoriteCnt != "0" && v.favoriteCnt != null && v.favoriteCnt != ''){
				    			$("#inTM").html("<a onclick='favoriteDel();' class='btnIndividualFavoriteAdd active'><spring:message code='Cache.btn_Favorite'/></a>");
				    		}else{
				    			$("#inTM").html("<a onclick='favoriteAdd();' class='btnIndividualFavoriteAdd'><spring:message code='Cache.btn_Favorite'/></a>");
				    		}
						}
					}
				});
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communityHeaderSetting.do", response, status, error); 
		}
	}); 
	
}

function favoriteAdd(){
	$.ajax({
		url:"/groupware/layout/userCommunity/communityFavoritesAdd.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				
			}else{ 
				alert("<spring:message code='Cache.msg_FailProcess' />");
			}
			setHeader();
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communityFavoritesAdd.do", response, status, error); 
		}
	}); 
}

function favoriteDel(){
	$.ajax({
		url:"/groupware/layout/communityFavoritesDelete.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				
			}else{ 
				alert("<spring:message code='Cache.msg_FailProcess' />");
			}
			setHeader();
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communityFavoritesDelete.do", response, status, error); 
		}
	}); 
}

function setTopMenu(){
	var url = "";
	url += "/groupware/layout/userCommunity/setTopMenuPopup.do?"+"C="+cID;
		
	Common.open("", "setTopMenuPopup", "<spring:message code='Cache.btn_TopMenuMgr'/>", url, "300px", "360px", "iframe", true, null, null, true);
}

function goCommunityMain(){
	location.href = "/groupware/layout/userCommunity/communityMain.do?C="+cID;
}

function inCommMenu(){
	var str = "";
	
	str = "<li></li>";
	str += "<li class='inCommMenu01 active'><a href='javascript:void(0);' onclick='goCommunityMain();'>HOME</a></li>";
	if(level != "0" && level != "" && level != null){
		
		str += String.format(
				'<li class="inCommMenu02">' +
					'<a href="#" onclick="goCommunityTMenu('+"''"+","+"'{0}'"+","+"'{1}'"+')" >{2}</a></li>' 
					,"S"
					,"2"
					,"<spring:message code='Cache.MN_108'/>" // 설문
				)
		
		/* str += "<li class='inCommMenu02'><a href='#' onclick='goMenu()' >설문</a></li>"; */
		
		str += selCommMenu();
	}
	
	str += "<li></li>";
	
	$("#inCommMenu").html(str);
	
	if(mActiveKey != null && mActiveKey != ''  && mActiveKey != 'null' && mActiveKey != '0'){
		$("li[class^='inCommMenu0']").removeClass("active");
		$("li[class='inCommMenu0"+mActiveKey+"']").addClass("active");
	}
	
	
}

function selCommMenu(){
	var str = "";
	var name = "";
	
	$.ajax({
		url:"/groupware/layout/userCommunity/selectCommunityHeaderSetting.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (data) {
			var num = 3;
			var lang = Common.getSession("lang");
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					str += "<li class='inCommMenu0"+num+"'>";
					
					if(v.FolderType != "Schedule"){
						name = CFN_GetDicInfo(v.MultiDisplayName, lang);
					}else{
						name = "<spring:message code='Cache.lbl_Schedule'/>"; // 일정
						folderCheckList = ";"+v.FolderID+";";
					}
					
					str += String.format('<a onclick="goCommunityTMenu('+"'{0}'"+","+"'{1}'"+","+"'{3}'"+')" >{2}</a></li>'
							,v.FolderID
							,v.FolderType
							,name
							,num
							);
					num ++;
				});
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/selectCommunityHeaderSetting.do", response, status, error); 
		}
	});
	
	return str;
}

function goCommunityTMenu(folderID, folderType, num){
	var url = "";
	
	$("li[class^='inCommMenu0']").removeClass("active");
	$("li[class='inCommMenu0"+num+"']").addClass("active");
	
	mActiveKey = num;
	if(folderType == "Schedule"){
		folderCheckList = ";"+folderID+";";
		/* folderCheckList = ";"+folderID+";"; */
		url = "/groupware/layout/schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType=M&CSMU=C&communityId="+cID+"&activeKey="+num+"&schFolderId="+folderID;
		
		if(part == 'Y'){
			location.href = url;
		}else{
			g_lastURL = url;
			 
			CoviMenu_GetContent(url);
			moveScroll();
		}
		
	}else if(folderType == "S"){
		url = "/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=proceed&CSMU=C&communityId="+cID+"&activeKey="+num;
		
		if(part == 'Y'){
			location.href = url;
		}else{
			CoviMenu_GetContent(url);
			moveScroll();
		}
		
		
	}else if(folderType == "Board" || folderType == "Notice" || folderType == "File" || folderType == "Calendar" || folderType == "Album" || folderType == "QuickComment"){
		board.goFolderContents("Board",cID,folderID,folderType,num,part);
		moveScroll();
	}
	
}

function moveScroll(){
	$( '.individualCommunityContainer' ).animate( { scrollTop : 0 }, 400 );
}

function goFolderContents(pBizSection, pMenuID, pFolderID, pFolderType, activeKey){
	$("li[class^='inCommMenu0']").removeClass("active");
	$("li[class='inCommMenu0"+activeKey+"']").addClass("active");
	mActiveKey = activeKey;
	board.goFolderContents(pBizSection, pMenuID, pFolderID, pFolderType, activeKey);
}



</script>
<div class="inCommTitle">
	<h1 id="Cname"></h1>
	<p class="mt15" id="CcateGory"></p>
</div>
<div class="inTopMenu" id="inTM">
	<!-- <a href="#" class="btnIndividualFavoriteAdd">즐겨찾기</a>"&gt;<a href="#" class="btnIndividualFavoriteAdd active">즐겨찾기</a>&lt;<a href="#" class="btnIndividualOption ml5"></a> -->
</div>

<ul class="inCommMenu" id="inCommMenu">
	<!-- <li></li>
	<li class="inCommMenu01 active"><a href="#" onclick="goCommunityMain();">HOME</a></li>
	<li class="inCommMenu02"><a href="#">설문</a></li> -->
	<!-- <li class="inCommMenu02 active"><a href="#">설문</a></li> -->
 	<!-- <li class="inCommMenu03"><a href="#">일정</a></li>
	<li></li> -->
</ul>


<!-- 간단등록에서 상세등록으로 이동시 temp -->
<input type="hidden" id="simpleFolderType" >
<input type="hidden" id="simpleSubject" >
<input type="hidden" id="simpleStartDate" >
<input type="hidden" id="simpleStartHour" >
<input type="hidden" id="simpleStartMinute" >
<input type="hidden" id="simpleEndDate" >
<input type="hidden" id="simpleEndHour" >
<input type="hidden" id="simpleEndMinute" >
<input type="hidden" id="simpleResources" >