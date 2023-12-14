/**
 * wdg_notice - 위젯 공지
 */
var widgetNotice ={
	
	init: function (data, ext, pType, pWebpartID){
		
		// title & cnt.
		$("#"+pWebpartID).find("h3").text(Common.getDic("lbl_notice"));
		
		// PC version list count 3, mobile version list count 4.
		let mode = "P";
		if (coviUtil.isMobile()) {
			mode = "M";
			$("#"+ pWebpartID).find(".widget_empty").addClass("ui_empty");
		}
		widgetNotice.getNoticeList(mode, pWebpartID);
	},
	
	getNoticeList : function(pMode, pWebpartID)  {
		let objParam = {};
		if (pMode === "P") {
			objParam = {"pageSize" : "3", "isWebpart" : "Y"};
		} else {
			objParam = { "pageSize" : "4", "isWebpart" : "Y" };
		}
		let $noticeContent = $("#"+pWebpartID).find("ul");
		
		$.ajax({
			type : 'POST'
			, url : "/groupware/board/selectNoticeMessageList.do"
			, data : objParam
			, success : function(result) {
				
				if (result?.list?.length > 0) {
					result.list.forEach(function(el) {
						$noticeContent.append($("<li>")
							.append($("<a>",{"class":"post_item", "href" : "#"})
								.append($("<strong>",{"class":"item_title","text": el.Subject}))
								.append($("<time>",{"class":"item_date","text": el.CreateDate.substring(0,10).replaceAll('-', '.')})).on("click", function(){
									widgetNotice.goViewPopup("Board", el.MenuID, el.Version, el.FolderID, el.MessageID);
								})
							)
						);
					});

					if (result?.cnt != undefined && !isNaN(result.cnt)) {
						$("#"+pWebpartID).find("h3").siblings("a").text(""+coviUtil.showCntOver(result.cnt, 99));	
					}
					
				} else {
					// 빈값일 때.
					$("#"+pWebpartID).find(".widget_empty").attr("hidden", false);
				}
			}
			, error : function(response, status, error) {
				CFN_ErrorAjax("/groupware/board/selectMessageGridList.do", response, status, error);
			}
		});
	}
	
	, goViewPopup: function(pBizSection, pMenuID, pVersion, pFolderID, pMessageID){
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
