/**
 * pnNewsLetter - [포탈개선] My Place - 회사사보
 */
var pnNewsLetter = {
	webpartType: "",
	attachFileInfoObj: {},
	recentlyDay: 3,
	init: function (data, ext){
		var folderID = ext.newsLetterFolderID;
		
		pnNewsLetter.setEvent();
		pnNewsLetter.getNewsLetterList(folderID);
	},
	setEvent: function(){
		$(".PN_newsLetter").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
			if(!$(this).hasClass("active")){
				$(this).addClass("active");
				$(this).next(".PN_portlet_menu").stop().slideDown(300);
				$(this).children(".PN_portlet_btn > span").addClass("on");
			}else{
				$(this).removeClass("active");
				$(this).next(".PN_portlet_menu").stop().slideUp(300);
				$(this).children(".PN_portlet_btn > span").removeClass("on");
			}
		});
		
		$(".PN_newsLetter").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
	},
	getNewsLetterList: function(pFolderID){
		board.getBoardConfig(pFolderID);
		var menuID = g_boardConfig.MenuID;
		var folderUrl = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&menuID=" + menuID + "&folderID=" + pFolderID;
		
		$("#PN_news_link").attr("href", folderUrl);
		
		$.ajax({
			type: "POST",
			url: "/groupware/board/selectMessageGridList.do",
			data: {
				  "boardType": "Normal"
				, "bizSection": "Board"
				, "folderID": pFolderID
				, "folderType": g_boardConfig.FolderType
				, "viewType": "Album"
				, "startDate": ""
				, "endDate": ""
				, "pageSize": 2
				, "pageNo": 1
			},
			success: function(data){
				var listData = data.list;
				var newsHtml = "";
				
				if(listData != null && listData.length > 0){
					$.each(listData, function(idx, item){
						var liWrap = $("<li></li>");
						var previewURL = Common.getThumbSrc("Board", item.FileID);
						
						liWrap.append($("<a href='#' onclick='pnNewsLetter.openBoardPopup(" + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");'></a>")
									.append($("<span class='nImg'></span>")
										.append($("<img onerror='setNoImage(this);'>").attr("src", previewURL)))
									.append($("<span class='nTitle'></span>").text(item.Subject)));
						
						if(previewURL.indexOf("no_image.jpg") > -1) setNoImage(liWrap.find(".nImg img"));
						
						var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
						var compareDate = schedule_AddDays(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"), pnNewsLetter.recentlyDay);
						
						if(today.getTime() < compareDate.getTime()){
							var recentlyBadge = $("<span></span>").addClass("countStyle new").text("N");
							
							liWrap.find(".nTitle").prepend(recentlyBadge);
							recentFlag = true;
						}
						
						newsHtml += $(liWrap)[0].outerHTML;
					});
					
					$(".PN_newsLetter ul").empty().append(newsHtml);
				}else{
					$(".PN_newsLetter").hide();
					$(".PN_newsLetter").closest(".PN_portlet_contents").find(".PN_nolist").show();
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/selectMessageGridList.do", response, status, error);
			}
		});
	},
	openBoardPopup: function(pMenuID, pVersion, pFolderID, pMessageID){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", "Board", pMenuID, pVersion, pFolderID, pMessageID);
		Common.open("", "boardViewPop", "<spring:message code='Cache.lbl_DetailView'/>", url, "1080px", "600px", "iframe", true, null, null, true); // 상세보기
	}
}