/**
 * pnTrend - [포탈개선] My Place - 업계동향
 */
var pnTrend = {
	webpartType: "",
	recentlyDay: 3,
	init: function (data, ext){
		var folderID = ext.TrendFolderID;
		
		pnTrend.setEvent();
		pnTrend.getTrendBoardList(folderID);
	},
	setEvent: function(){
		$(".PN_Trend").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
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

		$(".PN_Trend").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
	},
	getTrendBoardList: function(pFolderID){
		board.getBoardConfig(pFolderID);
		var menuID = g_boardConfig.MenuID;
		var folderUrl = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&menuID=" + menuID + "&folderID=" + pFolderID;
		
		$("#PN_trend_link").attr("href", folderUrl);
		
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
				, "pageSize": 3
				, "pageNo": 1
			},
			success: function(data){
				var listData = data.list;
				
				if(listData != null && listData.length > 0){
					$.each(listData, function(idx, item){
						var liWrap = $("<li>");
						var previewURL = Common.getThumbSrc("Board", item.FileID);
						
						liWrap.append($("<a href='#' onclick='pnTrend.openBoardPopup(" + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");'/>")
									.append($("<span class='tImg'></span>")
										.append($("<img onerror='setNoImage(this);'>").attr("src", previewURL)))
									.append($("<span class='tTitle'></span>").text(item.Subject))
									.append($("<span class='tDate'></span>").text(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"))))
								.append($("<div class='tIcon'></div>"));
						
						if(previewURL.indexOf("no_image.jpg") > -1) setNoImage(liWrap.find(".tImg img"));
						
						var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
						var compareDate = schedule_AddDays(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"), pnTrend.recentlyDay);
						
						if(today.getTime() < compareDate.getTime()){
							var recentlyBadge = $("<span></span>").addClass("countStyle new").text("N");
							
							liWrap.find(".tTitle").prepend(recentlyBadge);
							recentFlag = true;
						}
						
						if(g_boardConfig.UseComment == "Y"){
							liWrap.find(".tIcon")
								.append($("<a href='#' class='btn_comment'></a>")
									.attr("onclick", "javascript:board.replyPopup(" + item.FolderID + ", " + item.MessageID + ", " + item.Version + ", 'Board');"));
						}
						
						if(g_boardConfig.UseRecommend == "Y"){
							liWrap.find(".tIcon")
								.append($("<a href='#' class='btn_like'></a>")
									.attr("onclick", "pnTrend.addLikeCount('Board', '" + item.MessageID + "_" + item.Version + "', " + idx + ");")
									.append($("<span></span>")));
						}
						
						$(".PN_Trend ul").append($(liWrap));
						pnTrend.loadLikeCount("Board", item.MessageID + "_" + item.Version, idx);
					});
				}else{
					$(".PN_Trend").hide();
					$(".PN_Trend").closest(".PN_portlet_contents").find(".PN_nolist").show();
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
	},
	loadLikeCount: function(pTargetType, pTargetID, pIdx){
		$.ajax({
			url: "/covicore/comment/getLike.do",
			type: "POST",
			data: {
				"TargetType": pTargetType,
				"TargetID": pTargetID
			},
			success: function(res){
				if(Number(res.myLike) > 0){
					$(".PN_Trend li").eq(pIdx)
						.find(".btn_like span").addClass("like");
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/comment/getLike.do", response, status, error);
	   		}
	 	});
	},
	addLikeCount: function(pTargetType, pTargetID, pIdx){
		$.ajax({
			url: "/covicore/comment/addLike.do",
			type: "POST",
			data: {
				"TargetType": pTargetType,
				"TargetID": pTargetID,
				"LikeType": "emoticon",
				"Emoticon": "heart",
				"Point": "0"
			},
			success: function(res){
				// 하트 애니메이션
				if(Number(res.myLike) > 0){
					$(".PN_Trend li").eq(pIdx)
						.find(".btn_like span").addClass("like");
				}else{
					$(".PN_Trend li").eq(pIdx)
						.find(".btn_like span").removeClass("like");
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/comment/addLike.do", response, status, error);
	   		}
	 	});
	}
}