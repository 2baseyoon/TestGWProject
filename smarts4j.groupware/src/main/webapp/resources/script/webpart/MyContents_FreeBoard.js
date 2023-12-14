/**
 * myContents - 마이 컨텐츠 - 자유 게시
 */
var myContents_FreeBoard ={
	
	init: function (data,ext){
		myContents_FreeBoard.getMessageList(ext.FolderID);	//게시판 조회
	},
	//게시판 웹파트 항목
	getMessageList : function(pFolderID){
		if (Common.getBaseConfig("WebpartFreeBoard")!="") {
			// WebpartFreeBoard 설정값이 숫자값이 아닐 경우, 기존값 유지.
			var settingValue = Common.getBaseConfig("WebpartFreeBoard");
			if (!isNaN(parseInt(settingValue))) {
				pFolderID = settingValue;
			}
		}
			
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
					if ($("#myContents_FreeBoard_List").length == 0){
						$(".freeBoad .webpart-content").html("").append('<ul id="myContents_FreeBoard_List"></ul>');
					}
					else {
						$("#myContents_FreeBoard_List").html("");
					}
					
					if (listData.length > 0){
						$.each( listData, function(i, item) {
							//$('#defaultBoard_folderName').text(item.FolderName);
							//게시판 목록 조회 팝업
			            	var prefixURL = '/groupware/layout/board_BoardView.do?CLBIZ=Board&CLSYS=board&CLMD=user&sortBy=MessageID desc&startDate=&endDate=&searchText=&searchType=Subject';
			            	var viewURL = String.format('{0}&menuID={1}&folderID={2}&messageID={3}&version={4}&boardType=Normal', prefixURL, item.MenuID, item.FolderID, item.MessageID, item.Version);
			            	var liWrap = $('<li />');
		            		//var anchorSubject = $('<a onclick="javascript:$(location).attr(\'href\', \''+ viewURL + '\');"/>').text(item.Subject);
			            	var anchorSubject = $('<a onclick="javascript:myContents_FreeBoard.goViewPopup(\'Board\', '+item.MenuID+','+item.Version+','+item.FolderID+','+item.MessageID+')"/>').text(item.Subject).attr('title', item.Subject);
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
							
							$("#myContents_FreeBoard_List").append(liWrap);
						});
					}
					else {
						$(".freeBoad .webpart-content").append('<div class="Board_Nodata"><p class="Board_NodataTxt">'+Common.getDic('msg_NoDataList')+'</p></div></div>');
					}
				}
			},
			error:function(response, status, error){
				$(".freeBoad .webpart-content").append('<div class="Board_Nodata"><p class="Board_NodataTxt">'+Common.getDic('msg_NoDataList')+'</p></div></div>');
       		}
		});
	},
	goViewPopup: function(pBizSection, pMenuID, pVersion, pFolderID, pMessageID){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
		parent.Common.open("", "boardViewPop", Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
	}
}
