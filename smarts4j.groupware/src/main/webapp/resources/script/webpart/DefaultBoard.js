/**
 * defaultBoard - 게시판 웹파트 기본형 
 */
var defaultBoard ={
	webpartType: '',
	init: function (data,ext){
		var folderID = ext.FolderID;
		defaultBoard.getMessageList(folderID);
	},
	
	getMessageList : function(pFolderID){
		board.getBoardConfig(pFolderID);
		var params = {
			"boardType"	:	"Normal"
			,"bizSection":	"Board"
			,"folderID"	:	pFolderID
			,"folderType":	g_boardConfig.FolderType
			,"startDate": 	""
			,"endDate"	:	""
			,"pageSize"	:	8
			,"pageNo"	:	1
			,"sortBy"	: 	"MessageID desc"
		}
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectMessageGridList.do",
			data: params,
			success:function(data){
				var listData = data.list;
				$("#defaultBoard_messageList").html("");
				$.each( listData, function(i, item) {
					$('#defaultBoard_folderName').text(item.FolderName);
					//게시판 목록 조회 팝업
	            	var prefixURL = '/groupware/layout/board_BoardView.do?CLBIZ=Board&CLSYS=board&CLMD=user&sortBy=MessageID desc&startDate=&endDate=&searchText=&searchType=Subject';
	            	var viewURL = String.format('{0}&menuID={1}&folderID={2}&messageID={3}&version={4}&boardType=Normal', prefixURL, item.MenuID, item.FolderID, item.MessageID, item.Version);
	            	var liWrap = $('<li />');
//	            	var anchorSubject = $('<a onclick="javascript:$(location).attr(\'href\', \''+ viewURL + '\');"/>').text(item.Subject);
	            	var anchorSubject = $('<a onclick="javascript:defaultBoard.goViewPopup(\'Board\', '+item.MenuID+','+item.Version+','+item.FolderID+','+item.MessageID+')"/>').text(item.Subject);
	            	//최근 게시 사용여부, 최근게시 기준일
	            	if(g_boardConfig.UseIncludeRecentReg == "Y" && g_boardConfig.RecentlyDay > 0){
	            		var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
	        			var registDate = new Date(CFN_TransLocalTime(pObj.item.CreateDate));
	        			if(today < registDate.setDate(registDate.getDate()+ pRecentlyDay)){
	        				anchorSubject.prepend(	$("<span />").addClass("cycleNew blue new").text("N") );
	        				liWrap.addClass('new');
	        			}
	        		}
	            	
					var spanDate = $('<span class="date" />').text(CFN_TransLocalTime(item.CreateDate, "yyyy-MM-dd"));
					liWrap.append(anchorSubject, spanDate);
					
					$("#defaultBoard_messageList").append(liWrap);
				});
			}
		});
	},
	
	goViewPopup: function(pBizSection, pMenuID, pVersion, pFolderID, pMessageID){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
		parent.Common.open("", "boardViewPop", Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
	},
}
