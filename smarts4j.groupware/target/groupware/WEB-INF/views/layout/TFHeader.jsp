<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
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
%>

<script type="text/javascript">
var cID = '<%=C %>';
var mActiveKey = '<%= activeKey%>';
var part = '<%=part%>';
var dnID = '';
var folderCheckList = ";";
var g_lastURL = "/groupware/layout/schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType=M&CSMU=T&communityId="+cID+"&activeKey="+mActiveKey;

var level = "0";

var QuickFolder = "";
var QuickFType = "";

var portalID = "";

$(function(){
	setHeader();
	inCommMenu();
	
	// 플로워 팝업메뉴
	/*$('body').on('click', '.btnFlowerName', function(){
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
	});*/
});

function setHeader(){
	
	$.ajax({
		url:"/groupware/layout/userTF/TFHeaderSetting.do",
		type:"POST",
		async:false,
		data:{
			communityID : cID
		},
		success:function (data) {
			
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					dnID = v.DN_ID;
					portalID = v.PortalID;
					QuickFolder = v.FolderID;
					
					if(v.CommunityTheme != '' && v.CommunityTheme != null){
						$("#cheader").attr("href","/HtmlSite/smarts4j_n/covicore/resources/css/theme/community/"+v.CommunityTheme+".css?v="+v.nowDate);
					}
					
					if(v.FilePath != '' && v.FilePath != null){
						if(v.FileCheck == "true"){
							$(".individualCommunity header").css({'background':"url("+v.FilePath+") no-repeat center 0"});
						}else{
							$(".individualCommunity header").css({'background':"url(url(/HtmlSite/smarts4j_n/covicore/resources/images/common/img_main_banner.jpg) no-repeat center 0"});
						}
					}else{
						$(".individualCommunity header").css({'background':"url(url(/HtmlSite/smarts4j_n/covicore/resources/images/common/img_main_banner.jpg) no-repeat center 0"});
					}
					
					if(v.BFilePath != '' && v.BFilePath != null){
						if(v.BFileCheck == "true"){
							$(".individualContent").css({'background':"url("+v.BFilePath+") repeat"});
						}else{
							$(".individualContent").css({'background':"#fff"});
						}
					}else{
						$(".individualContent").css({'background':"#fff"});
					}
					
					$("#Cname").text(v.CommunityName);
					$("#CcateGory").text(v.categoryName+" "+"TF");
					level = v.MemberLevel;
					
					if(v.MemberLevel == "9"){
		    			$("#inTM").html("<a href='#' onclick='setTopMenu();' class='btnIndividualOption ml5'></a>");
					}
				});
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userTF/TFHeaderSetting.do", response, status, error); 
		}
	}); 
	
}
/*TF 사용안함*/
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
/*TF 사용안함*/
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
	url += "/groupware/layout/userTF/setTopMenuPopup.do?"+"C="+cID;
		
	Common.open("", "setTopMenuPopup", "<spring:message code='Cache.btn_TopMenuMgr'/>", url, "300px", "360px", "iframe", true, null, null, true);
}

function goCommunityMain(){
	location.href = "/groupware/layout/usertf/TFMain.do?C="+cID;
}

function inCommMenu(){
	var str = "";
	
	str = "<li></li>";
	str += "<li class='inCommMenu01 active'><a href='javascript:void(0);' onclick='goCommunityMain();'>HOME</a></li>";
	if(level != "0" && level != "" && level != null){

		//설문조사, 일정 숨김처리 2019.10
		/*str += String.format(
				'<li class="inCommMenu02">' +
					'<a href="#" onclick="goCommunityTMenu('+"''"+","+"'{0}'"+","+"'{1}'"+')" >{2}</a></li>' 
					,"S"
					,"2"
					,"설문"
				)*/
		
		
		//str += selCommMenu();
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
		url:"/groupware/layout/userTF/selectTFHeaderSetting.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (data) {
			var num = 3;
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					str += "<li class='inCommMenu0"+num+"'>";
					
					if(v.FolderType != "Schedule"){
						name = v.DisplayName;
					}else{
						name = "일정";
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
			CFN_ErrorAjax("/groupware/layout/userTF/selectTFHeaderSetting.do", response, status, error); 
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
		url = "/groupware/layout/schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType=M&CSMU=T&communityId="+cID+"&activeKey="+num+"&schFolderId="+folderID;
		
		if(part == 'Y'){
			location.href = url;
		}else{
			g_lastURL = url;
			 
			CoviMenu_GetContent(url);
			moveScroll();
		}
		
	}else if(folderType == "S"){
		url = "/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=proceed&CSMU=T&communityId="+cID+"&activeKey="+num;
		
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