<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<input type="hidden" id="noticePage" value="1" />
<input type="hidden" id="newBoardPage" value="1" />
<input type="hidden" id="likeBoardPage" value="1" />
<input type="hidden" id="noticePageSize" value="5" />
<input type="hidden" id="newBoardPageSize" value="5" />
<input type="hidden" id="likeBoardPageSize" value="5" />

<style>
.commInput.rewrite .txtArearBox > textarea {
    width: calc(100% - 67px);
}
</style>

<body>
	<div id="portal_con">${layout}</div>
</body>

<script type="text/javascript">
	${javascriptString}
</script>

<script type="text/javascript">
var _data = '${data}';

$(function(){
	setContentEvent();
});	

function setContentEvent(){
	menuEvent();
	loadPortal();
}

function menuEvent(){
	var str = "";
	
	 $.ajax({
		url:"/groupware/layout/userCommunity/communityAuthCheck.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (a) {
			if(a.value == "N"){
				location.href="/groupware/layout/userCommunity/communityMovePage.do?move=CommunityInfo&C="+cID;
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communityAuthCheck.do", response, status, error); 
		}
	});  
}

function setTagCloud(){
	var str = "";
	
	var tagName = "<spring:message code='Cache.lbl_TagCloud'/>";
	
	$("#cuTagCloudTi").html(tagName);
	
	$.ajax({
		url:"/groupware/layout/userCommunity/communitySelectTagCloud.do",
		type:"POST",
		async:true,
		data:{
			CU_ID : cID
		},
		success:function (z) {
			
			if(z.list.length > 0){
				$(z.list).each(function(i,v){
					
					str += String.format(
							'<li onclick="goBoardView('+"'{0}'"+","+"'{1}'"+","+"'{2}'"+');">'
								,v.Version
								,v.FolderID
								,v.MessageID
					 )
					str += "<a>#"+v.Tag+"</a></li>";
				});
			}
			
			$("#tagCloud").html(str);
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communitySelectTagCloud.do", response, status, error); 
		}
	}); 
}

function setBoard(boardType){
	var str = "";
	var pageNo = "";
	var pageSize = "";
	var folderType = "";
	
	if(boardType == 'N'){
		pageNo = $("#noticePage").val();
		pageSize = $("#noticePageSize").val();
		folderType = "Notice";
		
		$("#cuNoticeBoardTi").html("<spring:message code='Cache.lbl_notice'/>");
	}else if(boardType == 'A'){
		pageNo = $("#newBoardPage").val();
		pageSize = $("#newBoardPageSize").val();
		folderType = "Al";
		
		$("#cuNewBoardTi").html("<spring:message code='Cache.CommunityHomeBoardType_RECENT'/>");
	}else{
		pageNo = $("#likeBoardPage").val();
		pageSize = $("#likeBoardPageSize").val();
		folderType = "Li";
		
		$("#cuStyleBoardTi").html("<spring:message code='Cache.CommunityHomeBoardType_RECOMMEND'/>");
	}
	
	$.ajax({
		url:"/groupware/layout/userCommunity/communitySelectNotice.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID,
			pageNo : pageNo,
			pageSize : pageSize,
			bizSection : 'Board',
			FolderType : folderType
		},
		success:function (n) {
			
			if(n.list.length > 0){
				$(n.list).each(function(i,v){
					
					if(v.IsDisplay == 'N'){
						str += String.format(
								'<li onclick="goCommunityBoardDetail('+"'{0}'"+","+"'{1}'"+","+"'{2}'"+","+"'{3}'"+","+"'{4}'"+","+"'{5}'"+');">'
									,v.Version
									,v.FolderID
									,v.MessageID
									,v.CU_ID
									,v.CommunityName
									,v.boardFolderName
						 )
					} else {
						str += String.format(
								'<li onclick="goBoardView('+"'{0}'"+","+"'{1}'"+","+"'{2}'"+","+');">'
									,v.Version
									,v.FolderID
									,v.MessageID
						 )
					}

					str += "<div class='link'><a href='#'>["+v.boardFolderName+"] "+v.Subject+"</a></div>";
					str += "<div class='nicName'><span>"+v.CreatorName+"</span></div>";
					str += "<div class='date'><span>"+v.RevisionDate+"</span></div>";
					str += "</li>";
				});
			} else {
				var div;
				if(boardType == 'N'){
					div = document.getElementById('noticeList').parentNode;
				}else if(boardType == 'A'){
					div = document.getElementById('newBoardList').parentNode;
				}else {
					div = document.getElementById('newLikeList').parentNode;
				}
				div.style.display = 'none';
			}

			
			if(boardType == 'N'){
				$("#noticeList").html(str);
				selPageBox('N',pageNo,n.pageCount);
				
				//noticePage
			}else if(boardType == 'A'){
				$("#newBoardList").html(str);
				selPageBox('A',pageNo,n.pageCount);
				
				//newBoardPage
			}else{
				$("#newLikeList").html(str);
				selPageBox('L',pageNo,n.pageCount);
				
				//likeBoardPage
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communitySelectNotice.do", response, status, error); 
		}
	}); 	
}

function selPageBox(boardType,pageNo,tNo){
	var str = "";	
	
	if(tNo != "0" && tNo != null){
		
		str =  String.format(
					'<span class="colorTheme"><strong>{0}</strong></span><span>/</span><span>{1}</span>' +
						'<div class="pagingType01 ml10">' +	
						'<a href="#" onclick="movePrePage('+"'{0}'"+","+"'{1}'"+","+"'{2}'"+');" class="pre"></a>' +
						'<a href="#" onclick="moveNextPage('+"'{0}'"+","+"'{1}'"+","+"'{2}'"+');" class="next"></a>' +
						'</div>'
						,pageNo
						,tNo
						,boardType
		 )
	}
		
	if(boardType == 'N'){
		$("#noticePageBox").html(str);
	}else if(boardType == 'A'){
		$("#newBoardPageBox").html(str);
	}else{
		$("#newLikePageBox").html(str);
	}
	
}

function movePrePage(pageNo, totalNo, boardType){
	if(pageNo == "1"){
		pageNo = "1";
	}else{
		pageNo = parseInt(pageNo-1);
	}
	
	if(boardType == 'N'){
		$("#noticePage").val(pageNo);
	}else if(boardType == 'A'){
		$("#newBoardPage").val(pageNo);
	}else{
		$("#likeBoardPage").val(pageNo);
	}
	
	setBoard(boardType);
}

function moveNextPage(pageNo, totalNo, boardType){
	if(pageNo == totalNo){
		
	}else{
		pageNo++;
	}
	
	if(boardType == 'N'){
		$("#noticePage").val(pageNo);
	}else if(boardType == 'A'){
		$("#newBoardPage").val(pageNo);
	}else{
		$("#likeBoardPage").val(pageNo);
		
	}
	
	setBoard(boardType);
}

function setActivityS(){
	var activity = "";
	var splitArr="";
	var check = "1";
	var height = "0";
	
	
	var tagName = "<spring:message code='Cache.CuPoint_Visit'/>"+"(100)";
	
	$("#cuActivitySop").html(tagName);
	
	tagName = "<spring:message code='Cache.lbl_CommunityActivityStatistics'/>";
	
	$("#cuActivitySTi").html(tagName);
	
	$.ajax({
		url:"/groupware/layout/userCommunity/communitySelectActivity.do",
		type:"POST",
		async:true,
		data:{
			CU_ID : cID
		},
		success:function (ac) {
			splitArr = ac.splitDate.split(",");
			for(var i=0;i<splitArr.length;i++){
	        	if(ac.list.length > 0){
					$(ac.list).each(function(j,v){
						if(splitArr[i] == v.sortDate){
							check = 0;
							activity += "<li>";
							activity += "<div>";
							
							if(v.visitCnt > 100){
								height = 100;
							}else{
								height = v.visitCnt;
							}
							
							activity += "<div class='lineBar' style='height:"+height+"%;'>";
							activity += "<class class='graphToolTip'>"+v.visitCnt+"</span>";
							activity += "</div>";
							activity += "</div>";
							activity += "<p><span>"+v.VisitDate+"</span>일</p>";
							activity += "</li>";
						}
						
					});
					
					if(check == "1"){
						check = 1;
						
						activity += "<li>";
						activity += "<div>";
						activity += "<div class='lineBar' style='height:0%;'>";
						activity += "<class class='graphToolTip'>0</span>";
						activity += "</div>";
						activity += "</div>";
						activity += "<p><span>"+splitArr[i].split(".")[2]+"</span>일</p>";
						activity += "</li>";
					}else{
						check = 1;
					}
					
				}else{
					check = 1;
					activity += "<li>";
					activity += "<div>";
					activity += "<div class='lineBar' style='height:0%;'>";
					activity += "<class class='graphToolTip'>0</span>";
					activity += "</div>";
					activity += "</div>";
					activity += "<p><span>"+splitArr[i].split(".")[2]+"</span>일</p>";
					activity += "</li>";
				}
	        }
			
			$("#activityStatistics").html(activity);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communitySelectActivity.do", response, status, error); 
		}
	});
	
}

function goBoardView(pVersion, pFolderID, pMessageID){
 	/* if(!board.checkReadAuth('Board', pFolderID, pMessageID, pVersion)){
		Common.Warning("<spring:message code='Cache.msg_noViewACL'/>");	//읽기 권한이 없습니다.
		return;
	}  */
	
	var bizSection = (cID != null && cID != "") ? "Community" : "Board";
	var url = "/groupware/layout/board_BoardView.do?CLBIZ="+bizSection+"&CLSYS=board&CLMD=user&sortBy=MessageID desc&startDate=&endDate=&searchText=&searchType=Subject&folderID="+pFolderID+"&messageID="+pMessageID+"&version="+pVersion+"&boardType=Normal&menuID="+cID+"&CSMU=C&communityId="+cID;
	CoviMenu_GetContent(url);
}

function goCommunityBoardDetail(pVersion, pFolderID, pMessageID, pCommunityID, pCommunityName, pboardFolderName){
	var url = String.format("/groupware/board/goBoardViewPopup.do?CLSYS=board&CLMD=user&CLBIZ=Community&menuID={0}&version={1}&folderID={2}&messageID={3}&viewType=Popup"
		, pCommunityID, pVersion, pFolderID, pMessageID);
	Common.open("", "boardViewPop", pboardFolderName, url, "1080px", "600px", "iframe", true, null, null, true); // 상세보기
}

function setOneBoard(){
	var lURL = "/groupware/layout/userCommunity/communityLeftUserInfo.do";
	//var isAdmin = CFN_GetQueryString("IsAdmin") !== "undefined" ? CFN_GetQueryString("IsAdmin") : window.sessionStorage.getItem("communityAdmin") ? window.sessionStorage.getItem("communityAdmin") : "N";
	
	if(cType=="T"){
		lURL = "/groupware/layout/userTF/TFLeftUserInfo.do";
	}
	
	$.ajax({
		url:lURL,
		type:"POST",
		async:true,
		data:{
			communityID : cID
		},
		success:function (r) {
			if(r.list.length > 0){
				$(r.list).each(function(i,v){
					if(v.MemberLevel != null && v.MemberLevel != ''){
						// 비회원일 때 한줄게시 조회 시 게시 권한 오류 발생하는 현상 조치
						if(v.MemberLevel === Common.getDic("CuMemberLevel_0")) {
							$("#oneBoardList").hide();
							return false;
						} else {
							if(QuickFolder != "" && QuickFolder != null){
								
								var contents = board.selectContentMessage(QuickFolder);
								
								// MessageID 가 없는 경우 한줄게시판이 생성된게 아니므로 보여주지 않는다.
								if(!contents.MessageID || contents.MessageID == "undefined" || contents.MessageID == "") {
									$("#oneBoardList").hide();
									return false;
								}
								
								var bizSection = (cID != null && cID != "") ? "Community" : "Board";
								var url = "/groupware/layout/board_BoardView.do?CLSYS=board&CLMD=user&CLBIZ="+bizSection+"&sortBy=MessageID desc&startDate=&endDate=&searchText=&searchType=Subject&folderID="+QuickFolder+"&version=1&boardType=Normal&&messageID="+contents.MessageID+"&menuID="+cID+"&CSMU=C&communityId="+cID;
								if(url != null && url != ''){
									var contentUrl = url + "&fragments=content";
									$.ajax({
								        type : "GET",
								        beforeSend : function(req) {
								            req.setRequestHeader("Accept", "text/html;type=ajax");
								        },
								        async:false,
								        url : contentUrl,
								        success : function(res) {
								        	$("#oneBoardList").html(res);
								        	$("#oneBoardList").show();
								        },
								        error : function(response, status, error){
											CFN_ErrorAjax(contentUrl, response, status, error);
								        }
								    });
								}
							}else{
								// 비회원일 때 한줄게시 조회 시 게시 권한 오류 발생하는 현상 조치
								$("#oneBoardList").hide();
								return false;
							}
						}
					}else{
						// 비회원일 때 한줄게시 조회 시 게시 권한 오류 발생하는 현상 조치
						$("#oneBoardList").hide();
						return false;
					}
				});
			}else{
				// 비회원일 때 한줄게시 조회 시 게시 권한 오류 발생하는 현상 조치
				$("#oneBoardList").hide();
				return false;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax(lURL, response, status, error);
		}
	});	
}

function setCommunityDoor(){
	$.ajax({
		url:"/groupware/layout/userCommunity/communitySelectDoor.do",
		type:"POST",
		async:true,
		data:{
			CU_ID : cID
		},
		success:function (d) {
			if(d.BodyText != null && d.BodyText != ''){
				$("#door").html(d.BodyText);
			}else{
				$("#door").html("<img src='/groupware/resources/images/img_sub_banner.png' alt='"+"커뮤니티에 오신것을 환영합니다."+"'>");
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communitySelectDoor.do", response, status, error); 
		}
	});
}


function loadPortal(){
	var oData = JSON.parse(_data);
	
	oData.sort(sortFunc);
	
	$.each(oData, function(idx, value){
		
		// TODO 퍼블리싱 후 하드코딩 제거 - 시작
		/* $("#portal_con").css("overflow-y", "auto"); */
		$("#portal_con").css("height", $(".commContent").css("height"));
		
		window.onresize = function(){
			$("#portal_con").css("height", $(".commContent").css("height"));
		};
		// TODO 퍼블리싱 후 하드코딩 제거 - 끝
		
		try{
			if (parseInt(value.webpartOrder, 10) > 100) {
				setTimeout("loadWebpart('" + JSON.stringify(value) + "')", parseInt(value.webpartOrder, 10));
			}else{
				loadWebpart(value);
			}
		}catch(e){
			$("#WP"+value.webPartID).append("<span>"+e+"</span>");
		}
	});
}

function loadWebpart(value){
	if(typeof(value) === "string"){
		value = $.parseJSON(value);
	}
	var html = Base64.b64_to_utf8(value.viewHtml==undefined?"":value.viewHtml);
	
	//default view로 인한 분기문
	if($("#WP"+value.webPartID).attr("isLoad")=='Y'){
		$("#WP"+value.webPartID).append(html);
	}else{
		$("#WP"+value.webPartID).html(html);
		$("#WP"+value.webPartID).attr("isLoad",'Y');
	}
	
	if(value.jsModuleName != '' && typeof(new Function ("return "+value.jsModuleName+".webpartType").apply()) != 'undefined'){
		new Function (value.jsModuleName+".webpartType = "+ value.webpartOrder).apply();
	}
	
	if(value.initMethod != '' && typeof(value.initMethod) != 'undefined'){		
		if(typeof(value.data)=='undefined'){
			value.data = $.parseJSON("[]");
		}
		
		if(typeof(value.extentionJSON) == 'undefined'){
			value.extentionJSON = $.parseJSON("{}");
		}
		
		if (value.webpartType === "None") {
			let ptFunc = new Function('a', 'b', Base64.b64_to_utf8(value.initMethod)+'(a, b)');
			ptFunc(value.data, value.extentionJSON) ;
		} else {
			new Function (Base64.b64_to_utf8(value.initMethod)).apply();
		}
	}
}

 function sortFunc(a, b) {
       if(a.webpartOrder < b.webpartOrder){
    	   return -1;
       }else if(a.webpartOrder > b.webpartOrder){
    	   return 1;
       }else{
    	   return 0;
       } 
    }

//해상도 다를 경우 조치
$(window).load(function(){
	if(!_ie){
		if (navigator.userAgent.toLowerCase().indexOf("edge/") > -1) 
			window.resizeTo(window.outerWidth, screen.availHeight - 50); 
		else
			window.resizeTo(window.outerWidth, screen.availHeight); // chrome, safari 의 팝업 높이가 더 커서 팝업후 재조정
	}
});

</script>
