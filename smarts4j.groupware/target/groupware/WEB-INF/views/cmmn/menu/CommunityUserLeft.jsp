<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cLnbTop">
	<h2 onclick="goMain();" style="cursor: pointer;"><spring:message code='Cache.lbl_Community'/></h2>
	<div><a id="btnWrite" href="#" onclick="goAddCommunity();" class="btnType01"><spring:message code='Cache.lbl_MakeCommunity'/></a></div>
	<div class="selectBox lnb">
		<select class="selectType02" id="selectJoinCommunity"></select>
	</div>
</div>
<div class="cLnbMiddle mScrollV scrollVType01 communityLnbContent">
	<ul class="contLnbMenu communityMenu">
		<li class="communityMenu01">
			<button class="btnLnbOption"><spring:message code='Cache.lbl_Option'/></button>
			<div class="selOnOffBox ">
				<a href="#" class="btnOnOff active" style="max-width: 80%;"><spring:message code='Cache.lbl_FavoriteCommunity'/><span></span></a>
			</div>
			<div class="selOnOffBoxChk type02 boxList active" id="boxList">
			</div>
		</li>
	</ul>
	<ul id="leftMenu" class="contLnbMenu communityMenu"></ul>
</div>
<script type="text/javascript">
	var myFolderTree = new coviTree();
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var domainId = '${domainId}';
	var isAdmin = '${isAdmin}';
	var g_bizSection = '<%=request.getParameter("CLBIZ")%>';
	var g_lastURL;
	
	var boardLeft;
	
	var body = {
		onclick:function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
			if(item.FolderType == "Root" && item.FolderPath == ""){
				selectCommunityTreeListByTree(item.FolderID, item.FolderType, "0", item.FolderName);
			}else{
				selectCommunityTreeListByTree(item.FolderID, item.FolderType, item.FolderPath, item.FolderName);
			}
		}
	};
	
	var treeMinHeight = (Common.getBaseConfig("treeMinHeight",Common.getSession("DN_ID")) == ""? 250 : Common.getBaseConfig("treeMinHeight",Common.getSession("DN_ID")));
	var treeMaxHeight = (Common.getBaseConfig("treeMaxHeight",Common.getSession("DN_ID")) == ""? 400 : Common.getBaseConfig("treeMaxHeight",Common.getSession("DN_ID")));
	var treeScrollInertia = (Common.getBaseConfig("treeScrollInertia",Common.getSession("DN_ID")) == ""? 300 : Common.getBaseConfig("treeScrollInertia",Common.getSession("DN_ID")));
	
	initLeft();
	
	function initLeft(){
		
		$(".communityMenu01").after("<li class=\"communityMenu02 scrollVType01\" style=\"height: auto; min-height: "+treeMinHeight+"px; max-height: "+treeMaxHeight+"px; overflow: hidden;\"><div id=\"coviTree_FolderMenu\" class=\"treeList radio\" /></li>");
		
		setFavorites();
		setTreeData();
		setEvent();
		
		var opt = {
			lang : "ko",
			isPartial : "true"
		};
		
		var coviMenu = new CoviMenu(opt);
		
		if(leftData.length != 0){
			coviMenu.render('#leftMenu', leftData, 'userLeft');
		}
		
		if(loadContent == 'true'){
			CoviMenu_OpenMenu('/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=' + g_bizSection);
			g_lastURL = '/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=' + g_bizSection;
		}
		
		$('.btnLnbOption').on('click', function(){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$(this).closest('li').removeClass('active');
			}else {
				$(this).addClass('active');
				$(this).closest('li').addClass('active');
			}
		});
		
		$('.mScrollV').mCustomScrollbar({
			axis: 'y',
			scrollInertia: treeScrollInertia
		});
	}
	
	function goMain(){
		CoviMenu_GetContent('/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=' + g_bizSection);
		g_lastURL = '/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=' + g_bizSection;
		//좌측트리 목록 선택 표시 제거
		$(".communityMenu").find(".selected").removeClass("selected");
	}
	
	function setFavorites(){
		var recResourceHTML = "";
		$.ajax({
			url:"/groupware/layout/communityFavoritesSetting.do",
			type:"POST",
			async:false,
			data:{
				
			},
			success:function (cfs) {
				$("#boxList").html("");
				if(cfs.list.length > 0){
					$(cfs.list).each(function(i,v){
						recResourceHTML += "<a href='#'><span onclick='goUserCommunity("+v.CU_ID+")'>"+v.CommunityName+"</span><button class='btnLnbFavoriteRemove' onclick='removeFavorite("+v.CU_ID+")'></button></a>";
					});
				}
				
				$("#boxList").html(recResourceHTML);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/layout/communityFavoritesSetting.do", response, status, error); 
			}
		});
	}
	
	function removeFavorite(communityID){
		$.ajax({
			url:"/groupware/layout/communityFavoritesDelete.do",
			type:"POST",
			async:false,
			data:{
				CU_ID : communityID
			},
			success:function (datac) {
				if(datac.status == "SUCCESS"){
					
				}else{
					alert("<spring:message code='Cache.msg_FailProcess' />");
				}
				setFavorites();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/layout/communityFavoritesDelete.do", response, status, error); 
			}
		});
	}
	
	function setTreeData(){
		$.ajax({
			url:"/groupware/layout/selectCommunityTreeData.do",
			type:"POST",
			data:{},
			async:false,
			success:function (tdata) {
				var List = tdata.list;
				var IsUseCnt = 0;
				
				for(var i = 0; i < List.length; i++) {
					if(List[i].IsUse == "Y") {
						IsUseCnt ++;
					}
				}
				
				var treeHeight = IsUseCnt * 25	
				
				if(treeHeight > treeMaxHeight) {
					$('.treeList').css("height", (treeMaxHeight - 20) + "px");	
				} else {
					$('.treeList').css("height", treeHeight + "px");
				}
				
				$('.treeList').css("max-height", (treeMaxHeight - 10) + "px");
				
				myFolderTree.setTreeList("coviTree_FolderMenu", List, "nodeName", "170", "left", false, false, body);
				myFolderTree.expandAll(1);
			},
			error:function (error){
				CFN_ErrorAjax("/groupware/layout/selectCommunityTreeData.do", response, status, error);
			}
		});
		myFolderTree.displayIcon(true);
		myFolderTree.clearFocus();
		
		$('.treeList').mCustomScrollbar({
 			axis: 'yx',
 			scrollInertia: treeScrollInertia
 		});
	}
	
	function setEvent(){
		$("#selectJoinCommunity").coviCtrl("setSelectOption",
			"/groupware/layout/selectUserJoinCommunity.do",
			{},
			Common.getDic("lbl_MyCommunity"), // 내가 가입한 커뮤니티
			""
		);
		
		$("#selectJoinCommunity").change(function(){
			if($("#selectJoinCommunity").val() != "" ){
				var url = "/groupware/layout/userCommunity/communityMain.do?C="+$("#selectJoinCommunity").val();
				var specs = "left=10,top=10,width=1050,height=900";
				specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
				window.open(url, "community", specs);
				$("#selectJoinCommunity").val("");	//커뮤니티 팝업 호출 이후 초기 값으로 재설정
			}
		});
	}
	
	function selectCommunityTreeListByTree(pFolderID, pFolderType, pFolderPath, pFolderName){
		var path = "";
		var folder = "";
		
		folder = pFolderID;
		path = pFolderPath;
		CoviMenu_OpenMenu('/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&folder='+folder, true, "commu_"+pFolderID,pFolderName);
		g_lastURL = '/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&folder='+folder
	}
	
	function goAddCommunity(){
		CoviMenu_GetContent('/groupware/layout/community_CommunityCreate.do?CLSYS=community&CLMD=user&CLBIZ=Community');
	}
	
	function goUserCommunity(cID){
		var specs = "left=10,top=10,width=1050,height=900";
		specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
		window.open("/groupware/layout/userCommunity/communityMain.do?C="+cID, "community", specs);
	}
</script>
