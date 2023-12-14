/**
 * wdg_recentborad - 위젯 최근게시. 게시판에 최근게시 설정되어 있는 게시판의 최근게시물을을 가져온다.
 */
var wdgRecentBoard = {
	init: function (data, ext, pType, pWebpartID) {
		wdgRecentBoard.getList(pWebpartID);
	}
	
	, getList : function(pWebpartID) { 	// 최근게시 불러오기.
		let txtUrl = "/groupware/board/selectLatestMessageList.do";
		let params = {"bizSection" : "Board"
						, "menuID" : Common.getBaseConfig("BoardMenu")
						, "messageCount" : 5
					};
		
		if (coviUtil.isMobile()) {
			params.messageCount = 5; 	// CASE : Mobile mode, 5개. 
		} else {
			params.messageCount = 3; 	// CASE : PC mode, 3개.
		}
		
		$.ajax({
			type : "POST"
			, url : txtUrl
			, data : params
			, async : false
			, success : function(data) {
				if (data.status === "SUCCESS") {
					wdgRecentBoard.renderData(pWebpartID, data);	
				}
			}
			, error : function(response, status, error) {
				CFN_ErrorAjax("/groupware/board/selectLatestMessageList.do", response, status, error);
			}
		});
		
	}
	
	// rendering data.
	, renderData : function(pWebpartID, pData) {
		let $content = $("#"+pWebpartID).find("div .widget_content");
		
		if (pData.status === "SUCCESS") {
			if (pData.list) {
				if (pData.list.length < 1) { 	// case 0.
					$content.hide();
					
					if (coviUtil.isMobile()) {
						$content.siblings(".widget_empty").addClass("ui_empty");
						$content.siblings(".widget_empty").attr("hidden", false);
					} else {
						$content.siblings(".widget_empty").attr("hidden", false);
					}
					
				} else {
					$content.show();
					$content.siblings(".widget_empty").attr("hidden", true);
					
					$content.append($("<ul>"));
					
					let dataList = pData.list;
					dataList.forEach(function(el) {
						$content.find("ul").append($("<li>")
							.append($("<a>", {"href": "#", "class": "post_item ui-link"})
								.append($("<span>", {"class": "item_title", "text": el.Subject}))
								.append($("<span>", {"class": "item_user", "text": el.CreatorName}))
								.append($("<time>", {"class": "item_date", "text": el.CreateDate.split(" ")[0]}))
							)
							.on("click", function() {
								wdgRecentBoard.goViewPopup(el.MenuID, el.Version, el.FolderID, el.MessageID);
							})
						)
					});
				}
			}
		} else {
			$content.hide();
			$content.siblings(".widget_empty").attr("hidden", false);
		}
	}
	
	// 상세 팝업
	, goViewPopup: function(pMenuID, pVersion, pFolderID, pMessageID){
		let pBizSection = 'Board';
		
		if (coviUtil.isMobile()){	// mobile인 경우
			if (mobile_board_checkReadAuth(pBizSection, pFolderID, pMessageID, pVersion)){	//읽기 권한 체크
				var url = "/groupware/mobile/" + pBizSection.toLowerCase() + "/view.do?folderid=" + pFolderID + "&version=" + pVersion + "&messageid=" + pMessageID + "&boardtype=Normal&menucode=Board";
				mobile_comm_go(url, "Y");
			} else {//권한 없음
				alert(mobile_comm_getDicInfo("msg_UNotReadAuth"));
			}
		}	else{
			var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
			Common.open("", "boardViewPop", Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
		}
	}	
}
