/**
 * multipleBoardListList - 탭형태 게시판 웹파트
 */
var multipleBoardList ={
	webpartType: '', 
	page : { 
		pageNo: 1,
		pageOffset: 0,
		pageCount: 1,
		pageSize: 10,
		listCount: 0,
	},
	searchParams: {},
	
	init: function (data,ext){
		//수행할 업무
		$.each( data[0], function(index, value) {
			$("#multipleBoardList_tabList").append('<li><a href=\'#\' style="color:black;" onclick="multipleBoardList.changeBoard('+ value.MenuID +','+ value.FolderID +',\''+ value.FolderName +'\')">'
				+value.FolderName+
				'</a></li>');
		});
		$("#multipleBoardList_tabList li:nth(0) a").click();
	},
	
	//페이징처리용 화살표 및 페이지 개수 표시
	renderPageNavi: function(){
		var obj = multipleBoardList;
		var spanColor 	= $('<span class="colorTheme"/>').append('<strong />').text(this.page.pageNo);
		var spanSeparator	= $('<span />').text("\/");
		var spanPageCount = $('<span/>').text(this.page.pageCount);
		
		var divMoveBtn = $('<div class="pagingType01 ml10"/>');
		var prevBtn = $('<a class="pre"/>').click(function () {
			obj.page.pageNo = obj.page.pageNo-1 > 1 ? obj.page.pageNo-1 : 1;
			obj.movePage(obj.searchParam);
        }.bind(this));
		
		var nextBtn = $('<a class="next"/>').click(function () {
			obj.page.pageNo = obj.page.pageNo+1 < obj.page.pageCount ? obj.page.pageNo+1 : obj.page.pageCount;
			obj.movePage(obj.searchParam);
        }.bind(this));
		
		divMoveBtn.append(prevBtn, nextBtn);
		$('#multipleBoardList_pageBox').html("");
		$('#multipleBoardList_pageBox').append(spanColor, spanSeparator, spanPageCount,  divMoveBtn);
	},
	
	//페이지 이동
	movePage: function(){
		var obj = this.searchParams;
		this.getMessageList(obj.menuID, obj.folderID);
	},
	
	//게시판 변경
	changeBoard: function(pMenuID, pFolderID, pFolderName){
		$('.individualAllBoardStyleCont .cycleTitle').text(pFolderName);				//게시판 제목 변경
		this.page.pageNo = 1;				//페이지 초기화
		this.getMessageList(pMenuID, pFolderID);
	},
	
	//게시목록 조회
	getMessageList: function(pMenuID, pFolderID){
		var params = {
			"boardType"	:	"Normal"
			,"bizSection":	"Board"
			,"menuID"	:	pMenuID
			,"folderID"	:	pFolderID
			,"folderType":	"Board"
			,"startDate": 	""
			,"endDate"	:	""
			,"pageSize"	:	10
			,"pageNo"	:	this.page.pageNo
			,"sortBy"	: 	"MessageID desc"
		}
		this.searchParams = params;
		
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectMessageGridList.do",
			async:false,
			data: this.searchParams,
			success:function(data){
				var listData = data.list;
				multipleBoardList.page = data.page;
				$("#multipleBoardList_messageList").html("");
				$.each( listData, function(index, value) {
					//게시판 목록 조회 팝업
	            	var prefixURL = '/groupware/layout/board_BoardView.do?CLBIZ=Board&CLSYS=board&CLMD=user&sortBy=MessageID desc&startDate=&endDate=&searchText=&searchType=Subject';
	            	var viewURL = String.format('{0}&menuID={1}&folderID={2}&messageID={3}&version={4}&boardType=Normal', prefixURL, value.MenuID, value.FolderID, value.MessageID, value.Version);
					
					var divSubject = $('<div class="link" />').text(value.Subject);
					var divCreator = $('<div class="nicName" />').text(value.CreatorName);
					var divDate = $('<div class="date" />').text(CFN_TransLocalTime(value.CreateDate, "yyyy.MM.dd"));
					var liWrap = $('<li onclick="javascript:$(location).attr(\'href\', \''+ viewURL + '\');"/>').append(divSubject, divCreator, divDate);
					$("#multipleBoardList_messageList").append(liWrap);
				});
				multipleBoardList.renderPageNavi();
			}
		});
	},
}
//sourceURL=MultipleBoardList.jsp
