<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType">
	<h2 class="title"></h2>						
	<div class="searchBox02">
		<span><input type="text" id="seValue" onkeypress="if(event.keyCode==13) {onClickSearchButton(); return false;}"/><button type="button" class="btnSearchType01" onclick="onClickSearchButton()"><spring:message code='Cache.lbl_search'/></button></span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
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
					<input id="searchText" type="text" onkeypress="if(event.keyCode==13) {onClickSearchDetail(); return false;}">
				</div>											
			</div>
			<div>
				<a href="#" id="btnSearch" onclick="onClickSearchDetail()" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search'/></a>
			</div>
		</div>	
	</div>
	<div class="communityContent ">
 		<div class="communityHotStroy"> 
 			<div class="hotStoryNews"> 
 				<p class="tit">HOT STORY</p> 
 				<p class="txt mt20"> 
					<spring:message code='Cache.lbl_HotSotry1'/><br/> 
					<spring:message code='Cache.lbl_HotSotry2'/> 
 				</p> 
 			</div> 
			<div class="hotStoryInfo">
 				<div  class="hotStoryslide" id="hotStory"> 
						
 				</div> 
 			</div>		 
 			<div class="pagingType01"> 
				<a href="#" class="pre hotStoryslidePrev"></a><a href="#" class="next hotStoryslideNext"></a> 
			</div> 
		</div> 
		<div class="communityNoticeCont">
			<div class="communityFavoriteCont">
				<h2 class="cycleTitle"><spring:message code='Cache.lbl_FavoriteCommunity'/></h2>
				<div class="albumContent mt35 comm" >
					<ul class="clearFloat" id="communityFavorite">
					</ul> 
				</div>
				<div class="communitySearchForm mt30">
					<select class="selectType02">
						<option><spring:message code='Cache.lbl_selCommunityName'/></option>
					</select>
					<div class="searchBox03 ml5">
						<span><input type="text" id="communitySearchWord" onkeypress="if(event.keyCode==13) {goSearchCommunity(); return false;}"><button type="button" class="btnSearchType01" onclick="goSearchCommunity()"><spring:message code='Cache.btn_search'/></button></span>
					</div>
					<p class="ml10" id="searchWord">
					</p>
				</div>									
			</div>		
			<div class="joinCommunityNoTice mt40">
				<h2 class="cycleTitle"><spring:message code='Cache.WP_212'/></h2>
				<ul class="joinCommunityNoTiceList mt30" id="communityNotice">
										
				</ul>
			</div>								
		</div>	
		<div class="introduceCommunity mt30">
			<div class="bestCommunity">
				<div>
					<h2 class="cycleTitle"><spring:message code='Cache.lbl_ExcellentCommunity'/></h2>
					<a href="#" onclick="goBestCommunity()" class="btnTypeDefault btnMoreStyle03"><spring:message code='Cache.lbl_MoreView'/></a>
					<ul class="bestCommRanking mt20" id="communityFrequent">

					</ul>
				</div>
			</div>
			<div class="newCommunity">
				<div>
					<div>
						<h2 class="cycleTitle"><spring:message code='Cache.lbl_NewCommunity'/></h2>
						<a href="#" onclick="goCommunity('', 'new')" class="btnTypeDefault btnMoreStyle03"><spring:message code='Cache.lbl_MoreView'/></a>
						<ul class="newCommunityList" id="newCommunity">
						</ul>											
					</div>
				</div>
			</div>								
		</div>
	</div>
</div>		
<script type="text/javascript">
$(function(){					
 	setHotStory();
	setFavorite();
	searchWord();
	setNotice();
	setFrequent();
	setNewCommunity();
	setEvent();
});

function setHotStory(){
	var recResourceHTML = "";
	
	$.ajax({
		url:"/groupware/layout/communityHotStorySetting.do",
		type:"POST",
		async:false,
		data:{
			
		},
		success:function (data) {
			$("#hotStory").html("");
			
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					recResourceHTML += "<div class='hotStoryslideCont' onclick='goUserCommunity("+v.CU_ID+")' style='cursor:pointer;'>";
					recResourceHTML += "<div class='commThumb'>";
					if(v.FilePath != null && v.FilePath != ''){
						if(v.FileCheck == "true"){
							var imgPath = coviCmn.loadImage(v.FilePath);
							recResourceHTML += "<img src='"+imgPath+"' onerror='coviCmn.imgError(this);' style='width: 100%;'/>";
						}else{
							recResourceHTML += "<img src='/groupware/resources/images/img_default01.png'>";
						}
					}else{
						recResourceHTML += "<img src='/groupware/resources/images/img_default01.png'>";
					}
					recResourceHTML += "</div>";
					recResourceHTML += "<div class='txtBox'>";
					recResourceHTML += "<p class='tbTit mt5'>"+v.categoryName+" "+Common.getDic("CommunityDefaultBoardType_B")+"</p>";
					recResourceHTML += "<p class='tbTxt mt10'>"+v.CommunityName+"</p>";
					recResourceHTML += "<p class='tbDate mt15'>"+Common.getDic("lbl_Establishment_Day")+" : <span>"+CFN_TransLocalTime(v.RegProcessDate,_ServerDateSimpleFormat)+"</span> | "+Common.getDic("CuMemberLevel_9")+" : <span>"+v.CreatorName+"</span></p>";
					recResourceHTML += "<p class='mt10'><span class='tbViewCount'>"+v.MemberCNT+"</span> <span class='tbNoticeCount ml20'>"+v.MsgCount+"</span></p>";
					recResourceHTML += "<p class='mt30'><a href='#' class='btnTypeDefault' onclick='goUserCommunity("+v.CU_ID+")'>"+Common.getDic("lbl_DetailView1")+"</a></p>";
					recResourceHTML += "</div></div>";
		    	});
			}
			
			$("#hotStory").html(recResourceHTML);
			
			initEvent();
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communityHotStorySetting.do", response, status, error); 
		}
	}); 
	
}

function initEvent(){
	$('.hotStoryslide').slick({arrows: false,autoplay: true});
	
	$('.hotStoryslidePrev').on('click', function(){
		$('.hotStoryslide').slick('slickPrev');
	});
	$('.hotStoryslideNext').on('click', function(){
		$('.hotStoryslide').slick('slickNext');		
	});
}

function setFavorite(){
	var recResourceHTML = "";
	
	$.ajax({
		url:"/groupware/layout/communityFavoriteSetting.do",
		type:"POST",
		async:false,
		data:{
			
		},
		success:function (e) {
			$("#communityFavorite").html("");
			
			if(e.list.length > 0){
				$(e.list).each(function(i,v){
					
					recResourceHTML += "<li>";
					recResourceHTML += "<a href='#'>";
					recResourceHTML += "<div class='albumBox ' onclick='goUserCommunity("+v.CU_ID+")'>";
					recResourceHTML += "<div class='titImg' >";
					if(v.FilePath != null && v.FilePath != ''){
						if(v.FileCheck == "true"){
							var imgPath = coviCmn.loadImage(v.FilePath);
							recResourceHTML += "<img src='"+imgPath+"' onerror='coviCmn.imgError(this);' />";
						}else{
							recResourceHTML += "<img src='/groupware/resources/images/img_default01.png'>";
						}
					}else{
						recResourceHTML += "<img src='/groupware/resources/images/img_default01.png'>";
					}
					recResourceHTML += "</div>";
					recResourceHTML += "<div class='txtBox'>";
					recResourceHTML += "<p class='tbTit mt5'>"+v.categoryName+" "+Common.getDic("CommunityDefaultBoardType_B")+"</p>";
					recResourceHTML += "<p class='tbTxt mt10'>"+v.CommunityName+"</p>";
					recResourceHTML += "<p class='tbDate mt15'>"+Common.getDic("lbl_Establishment_Day")+" : <span>"+CFN_TransLocalTime(v.RegProcessDate,_ServerDateSimpleFormat)+"</span> | "+Common.getDic("CuMemberLevel_9")+" : <span>"+v.CreatorName+"</span></p>";
					recResourceHTML += "<p class='mt10'><span class='tbViewCount'>"+v.MemberCNT+"</span> <span class='tbNoticeCount ml20'>"+v.MsgCount+"</span></p>";
					recResourceHTML += "</div>";
					recResourceHTML += "</div>";
					recResourceHTML += "</a>";
					recResourceHTML += "</li>";
		    	});
			}
			$("#communityFavorite").html(recResourceHTML);
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communityFavoriteSetting.do", response, status, error); 
		}
	}); 
}

function searchWord(){
	var recResourceHTML = "";
	$.ajax({
		url:"/groupware/layout/communitySearchWord.do",
		type:"POST",
		async:false,
		data:{
			
		},
		success:function (we) {
			$("#searchWord").html("");
			
			recResourceHTML += "<strong>"+Common.getDic("lbl_portal_popularSearch")+" </strong>";	
			if(we.list.length > 0){
				$(we.list).each(function(i,v){
					recResourceHTML += '<span style="cursor:pointer;" onclick="goSearchCommunityWord('+i+')" id="SearchWord_'+i+'">'+v.SearchWord+"</span>,";	
		    	});
			}
			
			recResourceHTML = recResourceHTML.substring(0, recResourceHTML.length-1); 
			
			
			$("#searchWord").html(recResourceHTML);
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communitySearchWord.do", response, status, error); 
		}
	}); 
	
}

function setNotice(){
	var recResourceHTML = "";
	$.ajax({
		url:"/groupware/layout/communityNotice.do",
		type:"POST",
		async:false,
		data:{
			bizSection : 'Board'
		},
		success:function (c) {
			$("#communityNotice").html("");
			
			if(c.cnt > 0 ){
				if(c.list.length > 0){
					$(c.list).each(function(i,v){
						recResourceHTML += "<li>";	
						recResourceHTML += "<div class='tit'><a href='#' onclick='goUserCommunity("+v.CU_ID+")'><span>"+v.CommunityName+"</span></a></div>";	
						recResourceHTML += "<div class='txt'>";	
						recResourceHTML += "<p class='txtTIt'>";
						
						recResourceHTML += String.format(
								'<a onclick="goCommunityBoardDetail('+"'{0}'"+","+"'{1}'"+","+"'{2}'"+","+"'{3}'"+","+"'{5}'"+');">{4}</a>'
									,v.Version
									,v.FolderID
									,v.MessageID
									,v.CU_ID
									,v.Subject
									,v.CommunityName
						 )
						
					/* 	recResourceHTML += "<a href='#'>"+v.Subject+"</a>"; */
						recResourceHTML += "</p>";
						recResourceHTML += "<p class='date mt10'>";
						recResourceHTML += Common.getDic("lbl_CreateDates") + " : <span>" + CFN_TransLocalTime(v.RegistDate) + " " + Common.getSession("UR_TimeZoneDisplay") + "</span>";
						recResourceHTML += "</p></div>";
						recResourceHTML += "</li>";	
			    	});
				}
			}
			
			
			$("#communityNotice").html(recResourceHTML); 
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communityNotice.do", response, status, error); 
		}
	}); 	
}

function setFrequent(){
	var recResourceHTML = "";
	var num = 0;
	$.ajax({
		url:"/groupware/layout/communityFrequent.do",
		type:"POST",
		async:false,
		data:{
			
		},
		success:function (f) {
			$("#communityFrequent").html("");
			
			if(f.list.length > 0){
				$(f.list).each(function(i,v){
					num ++;
					
					recResourceHTML += "<li>";
					recResourceHTML += "<div>"+num+"</div>";
					recResourceHTML += "<div>";
					recResourceHTML += "<a href='#' onclick='goUserCommunity("+v.CU_ID+")'>";
					recResourceHTML += "<div class='commThumb thumbType02'>";
					if(v.FilePath != null && v.FilePath != ''){
						if(v.FileCheck == "true"){
							var imgPath = coviCmn.loadImage(v.FilePath);
							recResourceHTML += "<img src='"+imgPath+"' onerror='coviCmn.imgError(this);'/>";
						}else{
							recResourceHTML += "<img src='/groupware/resources/images/img_default02.png'>";
						}
					}else{
						recResourceHTML += "<img src='/groupware/resources/images/img_default01.png'>";
					}
					recResourceHTML += "</div>";
					recResourceHTML += "<div class='txtBox'>";
					recResourceHTML += "<p class='tbTit mt5'>"+v.categoryName+" "+Common.getDic("CommunityDefaultBoardType_B")+"</p>";
					recResourceHTML += "<p class='tbTxt mt10'>"+v.CommunityName+"</p>";
					recResourceHTML += "<p class='tbDate mt15'>"+Common.getDic("lbl_Establishment_Day")+" : <span>"+CFN_TransLocalTime(v.RegProcessDate,_ServerDateSimpleFormat)+"</span> | "+Common.getDic("CuMemberLevel_9")+" : <span>"+v.CreatorName+"</span></p>";
					recResourceHTML += "<p class='mt10'><span class='tbViewCount'>"+v.MemberCNT+"</span> <span class='tbNoticeCount ml20'>"+v.MsgCount+"</span></p>";
					recResourceHTML += "</div></a></div>";
					recResourceHTML += "<div><p>"+v.Point+"</p></div>";
					recResourceHTML += "</li>";	
					
		    	});
			}
			
			$("#communityFrequent").html(recResourceHTML);
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communityFrequent.do", response, status, error); 
		}
	}); 	
	
}

function setNewCommunity(){
	var recResourceHTML = "";
	$.ajax({
		url:"/groupware/layout/newCommunity.do",
		type:"POST",
		async:false,
		data:{
			
		},
		success:function (d) {
			$("#newCommunity").html("");
			
			if(d.list.length > 0){
				$(d.list).each(function(i,v){
					recResourceHTML += "<li class='albumBox '>";
					recResourceHTML += "<a href='#'  onclick='goUserCommunity("+v.CU_ID+")'>";
					recResourceHTML += "<div class='titImg'>";
					if(v.FilePath != null && v.FilePath != ''){
						if(v.FileCheck == "true"){
							var imgPath = coviCmn.loadImage(v.FilePath);
							recResourceHTML += "<img src='"+imgPath+"' onerror='coviCmn.imgError(this);'/>";
						}else{
							recResourceHTML += "<img src='/groupware/resources/images/img_default01.png'>";
						}
					}else{
						recResourceHTML += "<img src='/groupware/resources/images/img_default01.png'>";
					}
					recResourceHTML += "</div>";
					recResourceHTML += "<div class='txtBox'>";
					recResourceHTML += "<p class='tbTit mt15'>"+v.categoryName+" "+Common.getDic("CommunityDefaultBoardType_B")+"</p>";
					recResourceHTML += "<p class='tbTxt mt10'><span>"+v.CommunityName+"<span class='tbViewCount'>"+v.MemberCNT+"</span></span></p>";
					recResourceHTML += "<p class='tbDate mt10'>"+CFN_TransLocalTime(v.RegProcessDate,_ServerDateSimpleFormat)+"</span></p>";
					recResourceHTML += "</div>";
					recResourceHTML += "</a>";
					recResourceHTML += "</li>";
		    	});
			}
			
			$("#newCommunity").html(recResourceHTML);
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/newCommunity.do", response, status, error); 
		}
	}); 	
	
}

function setEvent(){
	$('.btnDetails').on('click', function(){
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

function goBestCommunity(){
	CoviMenu_GetContent('/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&searchWord=&searchType=C&CategoryID=&sortColumn=Grade&sortDirection=Asc&type=best');
}

function goCommunity(word, mode){
	
	$.ajax({
		url:"/groupware/layout/communitySearchWordPoint.do",
		type:"POST",
		async:false,
		data:{
			SearchWord : word
		},
		success:function (m) {
			var cUrl = "/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&searchWord="+urlEncodeValue(word)+"&searchType=C&CategoryID=";
			
			if(mode == "new"){
				cUrl += "&type=new&sortColumn=RegProcessDate&sortDirection=desc";
			}
			
			CoviMenu_GetContent(cUrl);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communitySearchWordPoint.do", response, status, error); 
		}
	}); 
	
	
}

function goSearchCommunity(){
	
	$.ajax({
		url:"/groupware/layout/communitySearchWordPoint.do",
		type:"POST",
		async:false,
		data:{
			SearchWord : $("#communitySearchWord").val()
		},
		success:function (m) {
			CoviMenu_GetContent('/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&searchWord='+urlEncodeValue($("#communitySearchWord").val())+"&searchType=C&CategoryID=");
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communitySearchWordPoint.do", response, status, error); 
		}
	}); 
	
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
			CoviMenu_GetContent('/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&searchWord='+urlEncodeValue($("#seValue").val())+"&searchType="+$("#searchType").val()+"&CategoryID=");
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communitySearchWordPoint.do", response, status, error); 
		}
	}); 
}

function onClickSearchDetail(){
	
	$.ajax({
		url:"/groupware/layout/communitySearchWordPoint.do",
		type:"POST",
		async:false,
		data:{
			SearchWord : $("#searchText").val()
		},
		success:function (m) {
			CoviMenu_GetContent('/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&searchWord='+urlEncodeValue($("#searchText").val())+"&CategoryID=&searchType="+$("#searchType").val());
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communitySearchWordPoint.do", response, status, error); 
		}
	}); 
	
}

function goSearchCommunityWord(i){
	
	$.ajax({
		url:"/groupware/layout/communitySearchWordPoint.do",
		type:"POST",
		async:false,
		data:{
			SearchWord : $("#SearchWord_"+i).text()
		},
		success:function (m) {
			CoviMenu_GetContent('/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&searchWord='+urlEncodeValue($("#SearchWord_"+i).text())+"&searchType=C&CategoryID=");
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communitySearchWordPoint.do", response, status, error); 
		}
	}); 
	
}

function goCommunityBoardDetail(pVersion, pFolderID, pMessageID, pCommunityID, pCommunityName){
	var url = String.format("/groupware/board/goBoardViewPopup.do?CLSYS=board&CLMD=user&CLBIZ=Community&menuID={0}&version={1}&folderID={2}&messageID={3}&viewType=Popup"
		, pCommunityID, pVersion, pFolderID, pMessageID);
	Common.open("", "boardViewPop", Common.getDic('lbl_notice') + ' - ' + pCommunityName, url, "1080px", "600px", "iframe", true, null, null, true); // 상세보기
}
</script>