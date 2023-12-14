/**
 * myContents - 마이 컨텐츠 -faq
 */
var myContents_FaqBoard ={
	init: function (data,ext){
		myContents_FaqBoard.getMessageList(ext.FolderID);	//faq
	},
	//게시판 웹파트 항목
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
			,"sortBy"	: 	"RegistDate desc"
		}
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectMessageGridList.do",
			data: params,
			success:function(data){
				if(typeof data.list != 'undefined'){
					var listData = data.list;
					$("#myContents_FaqBoard_List").html("");
					$.each( listData, function(i, item) {
						//$('#defaultBoard_folderName').text(item.FolderName);
						//게시판 목록 조회 팝업
		            	var prefixURL = '/groupware/layout/board_BoardView.do?CLBIZ=Board&CLSYS=board&CLMD=user&sortBy=MessageID desc&startDate=&endDate=&searchText=&searchType=Subject';
		            	var viewURL = String.format('{0}&menuID={1}&folderID={2}&messageID={3}&version={4}&boardType=Normal', prefixURL, item.MenuID, item.FolderID, item.MessageID, item.Version);
		            	var liWrap = $('<li />');
	            		//var anchorSubject = $('<a onclick="javascript:$(location).attr(\'href\', \''+ viewURL + '\');"/>').text(item.Subject);
		            	var anchorSubject = $('<a onclick="javascript:myContents_FaqBoard.goViewPopup(\'Board\', '+item.MenuID+','+item.Version+','+item.FolderID+','+item.MessageID+')"/>').text(item.Subject).attr('title', item.Subject);
		            	//최근 게시 사용여부, 최근게시 기준일
		            	if(g_boardConfig.UseIncludeRecentReg == "Y" && g_boardConfig.RecentlyDay > 0){
		        			var today = new Date(CFN_GetLocalCurrentDate());
		        			var registDate = new Date(CFN_TransLocalTime(item.RegistDate));
		        			if(today < registDate.setDate(registDate.getDate()+ g_boardConfig.RecentlyDay)){
		        				anchorSubject.prepend(	$("<span />").addClass("cycleNew blue new").text("N") );
		        				liWrap.addClass('new');
		        			}
		        		}
		            	
						var spanDate = $('<span class="date" />').text(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"));
						liWrap.append(anchorSubject, spanDate);
						
						$("#myContents_FaqBoard_List").append(liWrap);
					});
				}
			}
		});
	},
	goViewPopup: function(pBizSection, pMenuID, pVersion, pFolderID, pMessageID){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
		parent.Common.open("", "boardViewPop", Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
	}
}
