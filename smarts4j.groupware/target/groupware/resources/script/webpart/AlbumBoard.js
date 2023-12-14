/**
 * albumBoard - 앨범게시판 웹파트
 * config의 viewType 값이 slick인 경우, 앨범 목록을 slick으로 구성. 기본 설정 slidesToShow: 4, slidesToSchroll: 1
 * slick으로 설정하지 않은 경우, 마이컨텐츠처럼 업다운 버튼으로 동작.
 */
var albumBoard ={
	webpartType: '',
	config: {
		viewType: 'slick'
	},
	init: function (data, ext, caller){
		this.config.folderID = Common.getBaseConfig('WebpartAlbumBoard');
		
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		if (Common.getBaseConfig('WebpartAlbumBoard') != '') this.config.folderID = Common.getBaseConfig('WebpartAlbumBoard');
		
		var url = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&folderID="
			+ this.config.folderID +"&menuCode=BoardMain";
			
		$("#albumBoard_more").attr("href", url);

		this.getAlbumList(this.config.folderID);
	},
	getAlbumList : function(pFolderID){
		$("#albumBoard_messageList").html("");
		
		board.getBoardConfig(pFolderID);
		var params = {
			"boardType"	:	"Normal"
			,"bizSection":	"Board"
			,"folderID"	:	pFolderID
			,"folderType":	g_boardConfig.FolderType
			,"viewType"	: 	"Album"
			,"startDate": 	""
			,"endDate"	:	""
			,"pageSize"	:	10
			,"pageNo"	:	1
			,"sortBy"	: 	"MessageID desc"
		}
		
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectMessageGridList.do",
			data: params,
			success:function(data){
				var listData = data.list;
				$.each( listData, function(i, item) {
					var previewURL = Common.getThumbSrc("Board", item.FileID);
					var liHtml = $("#template_album_board_li").html()
						.replace('{clickAction}', "onclick=javascript:albumBoard.goImageSlidePopup(\""+item.MessageID+"\",\""+ item.FolderID+"\");")
						.replace('{image-src}', previewURL)
						.replace('{image-title}', item.Subject)
					
					$("#albumBoard_messageList").append(liHtml);
				});
			}
		}).done(function(){
			if (albumBoard.config.viewType == 'slick') {
				$('#albumBoard_messageList').slick({
					infinite: false,
					slidesToShow: 4,
					slidesToScroll: 1
				});
			} else {
				albumBoard.bindScroll();
			}
		});
	},
	goImageSlidePopup : function(pMessageID, pFolderID) {
		var contextParam = String.format("&messageID={0}&serviceType={1}&objectID={2}&objectType={3}", pMessageID, "Board", pFolderID, 'FD');
		CFN_OpenWindow("/covicore/control/goImageSlidePopup.do?" + contextParam, Common.getDic("lbl_ImageSliderShow"),800,780,"");
	},
	bindScroll : function(){
		$('.myContAlbum a.abTop').on('click', function(){
			albumBoard.moveScroll(Math.ceil(albumBoard.scrollIndex/2)-1);
		});
		
		$('.myContAlbum a.abDown').on('click', function(){
			albumBoard.moveScroll(Math.ceil(albumBoard.scrollIndex/2)+1);
		});
		
	},
	moveScroll : function(pIndex){
		if(pIndex < 0){
			pIndex = 0;
		} else if(pIndex > $('#albumBoard_messageList li').size()-1){
			pIndex = ($('#albumBoard_messageList li').size()/2)+1;
		}
		albumBoard.scrollIndex = pIndex;
		var scrollPosition = pIndex * 120;
		$('#albumBoard_messageList').parent().animate({
	        scrollTop : scrollPosition,
	    }, 200);
	}
}
