/**
 * rollingBoard - 게시글 롤링
 */
var rollingBoard = {
	config: {},
	init: function(data, ext, caller){
		rollingBoard.caller = caller;
		
		var _ext = (typeof ext == 'object') ? ext : {};
		rollingBoard.config = $.extend(rollingBoard.config, _ext);

		rollingBoard.getMessageList(rollingBoard.config.folderID);
	},
	getMessageList: function(pFolderID){
		board.getBoardConfig(pFolderID);
		
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
				, "pageSize": 6
				, "pageNo": 1
			},
			success: function(data){
				var listData = data.list;
				var tickerHtml = "";
				
				if(listData != null && listData.length > 0){
					$.each(listData, function(idx, item){
						var titleAnchor = $("<a href='#' onclick='rollingBoard.popup(" + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");'/>").text(item.Subject);
						var liWrap = $("<li></li>").append($("<div></div>").addClass("movieThumb").append(titleAnchor));
						
						tickerHtml += $(liWrap)[0].outerHTML;
					});
					
					$(".rollList ul").append(tickerHtml);
				}
				
				rollingBoard.setSlide();
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/selectMessageGridList.do", response, status, error);
	    	}
		});
	},
	popup: function(pMenuID, pVersion, pFolderID, pMessageID){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", "Board", pMenuID, pVersion, pFolderID, pMessageID);
		Common.open("", "boardViewPop", "<spring:message code='Cache.lbl_DetailView'/>", url, "1080px", "600px", "iframe", true, null, null, true); // 상세보기
	},
	setSlide: function(){
		var startNum = Number(0);	//첫번째 이미지 초기화
		$(".rollList").show();	//일시적으로 깨짐 방지하기 위해 숨겼다 보여짐.
		var visibleCnt = $(".movieThumb").length;
		var visibleNum = 1;

		if (visibleCnt > visibleNum) {	//visibleNum보다 많을경우 이미지 롤링
			$(".rollList").jCarouselLite({
				auto: 1000,
				speed: 1000,
				visible: visibleNum,
				start: startNum,
				vertical: true
			});
		}
	}
}
