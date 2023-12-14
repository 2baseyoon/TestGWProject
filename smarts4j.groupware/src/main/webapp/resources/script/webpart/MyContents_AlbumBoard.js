/**
 * myContents_AlbumBoard - 마이 컨텐츠 - 앨범게시
 */
var myContents_AlbumBoard ={
	scrollIndex: 0,
	init: function (data,ext){
		myContents_AlbumBoard.getAlbumList(ext.AlbumFolderID);	//앨범 조회
		myContents_AlbumBoard.bindScroll();					//Album 웹파트 위/아래버튼 이벤트 바인드
		
	},
	//앨범 웹파트 항목
	getAlbumList : function(pFolderID){
		if (Common.getBaseConfig("WebpartAlbumBoard")!="")
			pFolderID = Common.getBaseConfig("WebpartAlbumBoard");
		board.getBoardConfig(pFolderID);
		var params = {
			"boardType"	:	"Normal"
			,"bizSection":	"Board"
			,"folderID"	:	pFolderID
			,"folderType":	g_boardConfig.FolderType
			,"viewType"	: 	"Album"
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
					$("#myContents_AlbumBoard_messageList").html("");
					$.each( listData, function(i, item) {
						//게시판 목록 조회 팝업
						//var previewURL = item.FileID==undefined?"/GWStorage/no_image.jpg":String.format("/covicore/common/preview/{0}/{1}.do", "Board", item.FileID);
						var previewURL = Common.getThumbSrc("Board", item.FileID);
		            	var titleAnchor = $("<a href='#' onclick='myContents_AlbumBoard.goImageSlidePopup("+item.MessageID+","+ item.FolderID+")'/>").append($("<img/>").attr("src", previewURL).css("height", "105px"));
						var liWrap = $('<li style="width:107px;height:107px;"/>').append(titleAnchor);
						
						$("#myContents_AlbumBoard_messageList").append(liWrap);
					});
				}
			}
		});
	},
	goImageSlidePopup : function(pMessageID, pFolderID) {
		var contextParam = String.format("&messageID={0}&serviceType={1}&objectID={2}&objectType={3}", pMessageID, "Board", pFolderID, 'FD');
		CFN_OpenWindow("/covicore/control/goImageSlidePopup.do?" + contextParam, Common.getDic("lbl_ImageSliderShow"),800,780,"");
	},
	bindScroll : function(){
		$('.myContAlbum a.abTop').on('click', function(){
			myContents_AlbumBoard.moveScroll(Math.ceil(myContents_AlbumBoard.scrollIndex/2)-1);
		});
		
		$('.myContAlbum a.abDown').on('click', function(){
			myContents_AlbumBoard.moveScroll(Math.ceil(myContents_AlbumBoard.scrollIndex/2)+1);
		});
		
	},
	
	moveScroll : function(pIndex){
		if(pIndex < 0){
			pIndex = 0;
		} else if(pIndex > $('#myContents_AlbumBoard_messageList li').size()-1){
			pIndex = ($('#myContents_AlbumBoard_messageList li').size()/2)+1;
		}
		myContents_AlbumBoard.scrollIndex = pIndex;
		var scrollPosition = pIndex * 120;
		$('#myContents_AlbumBoard_messageList').parent().animate({
	        scrollTop : scrollPosition,
	    }, 200);
	}	
}
