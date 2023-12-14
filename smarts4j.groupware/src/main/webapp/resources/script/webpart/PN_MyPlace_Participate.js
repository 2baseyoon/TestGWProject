/**
 * pnParti - [포탈개선] My Place - 참여게시
 */
var pnParti = {
	webpartType: "",
	recentlyDay: 3,
	init: function (data, ext){
		var folderID = ext.PartiFolderID;
		
		pnParti.setEvent();
		pnParti.getPartiBoardList(folderID);
	},
	setEvent: function(){
		$(".PN_participate").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
			if(!$(this).hasClass("active")){
				$(this).addClass("active");
				$(this).next(".PN_portlet_menu").stop().slideDown(300);
				$(this).children(".PN_portlet_btn > span").addClass("on")
			}else{
				$(this).removeClass("active");
				$(this).next(".PN_portlet_menu").stop().slideUp(300);
				$(this).children(".PN_portlet_btn > span").removeClass("on")
			}
		});

		$(".PN_participate").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on")
		});
	},
	getPartiBoardList: function(pFolderID){
		board.getBoardConfig(pFolderID);
		var menuID = g_boardConfig.MenuID;
		var folderUrl = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&menuID=" + menuID + "&folderID=" + pFolderID;
		
		$("#PN_parti_link").attr("href", folderUrl);
		
		$(".PN_participate").closest(".PN_myContents_box").find(".PN_portlet_menu li[mode=write]").off("click").on("click", function(){
			var wUrl = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&menuID=" + menuID + "&folderID=" + pFolderID;
			window.open(wUrl);
		});
		
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
				, "pageSize": 4
				, "pageNo": 1
			},
			success: function(data){
				var listData = data.list;
				var partiHtml = "";
				
				if(listData != null && listData.length > 0){
					$.each(listData, function(idx, item){
						var liWrap = $("<li></li>");
						
						liWrap.append($("<a href='#' onclick='pnParti.openBoardPopup(" + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");'/>")
									.append($("<span class='pTitle'></span>").text(item.Subject))
									.append($("<span class='pDate'></span>").text(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"))));
						
						if(item.IsRead == "Y") liWrap.find("a").addClass("read");
						
						var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
						var compareDate = schedule_AddDays(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"), pnParti.recentlyDay);
						
						if(today.getTime() < compareDate.getTime()){
							var recentlyBadge = $("<span></span>").addClass("countStyle new").text("N");
							
							liWrap.find(".pTitle").prepend(recentlyBadge);
							recentFlag = true;
						}
						
						partiHtml += $(liWrap)[0].outerHTML;
					});
					
					$(".PN_participate ul").empty().append(partiHtml);
				}else{
					var wUrl = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&menuID=" + menuID + "&folderID=" + pFolderID;
					
					$(".PN_participate").hide();
					$(".PN_participate").closest(".PN_portlet_contents").find(".PN_nolist").show();
					$(".PN_participate").closest(".PN_portlet_contents").find(".PN_nolist .PN_btnType01")
						.attr("href", wUrl);
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