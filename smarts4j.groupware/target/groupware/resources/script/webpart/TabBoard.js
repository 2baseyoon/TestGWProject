/**
 * tabBoard - 탭 + 다중 게시판
 */
var tabBoard ={
	config: {
		webpartType: '',
		messageCount: 7,
		noticeCount: 6
	},
	init: function (data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		tabBoard.bindTab();					//회사소식, 인기컨텐츠, 핫키워드 이벤트 바인드
		tabBoard.getNoticeMessageList();	//공지 게시글 웹파트 검색
		
		$("#moreNotice").attr("href", ext.noticeBoardURL.replace("{0}", Common.getBaseConfig("WebpartNotice")));

		var tabList = ext.tabList;
		$.each(tabList, function(_i, item) {	//탭형태 웹파트 검색: 최근게시, 최근문서탭 추가
			var tabName = CFN_GetDicInfo(item.DisplayName);
			var menuID = item.Type === "Board" ? Common.getBaseConfig("BoardMenu") : Common.getBaseConfig("DocMenu");
			
			$("#tabBoard_tabList").append('<li><a class="tabTitle" onclick="tabBoard.changeLatestTab(this, \''+ item.Type +'\',\''+ menuID +'\');"><span>' + tabName + '</span></a><a href="'+item.URL+'" class="btnMainMore">more +</a> </li>');
		});
		//추가된 탭 선택하여 게시글 검색
		$("#tabBoard_tabList li:nth(0) a").click();
	},
	
	bindTab: function(){
		$('.mainTabslideView').slick({
			  arrows: false,
			  dots:true,
			  autoplay: true
		});
		
		//포털 탭메뉴	
		var hotKeyword ;
		$('.mainBoadTabMenu>li').on('click', function(){
			$('.mainBoadTabMenu>li').removeClass('active');
			$('.mainBoardTabCont').removeClass('active');
			$(this).addClass('active');
			$('.mainBoardTabCont').eq($(this).index()).addClass('active');		
			
			//핫키워드 모션 적용 부분 처음 1번 적용 후 반복 모션 진행
			if($('.mainBoardTabCont').eq($(this).index()).hasClass('hotKeyword')) {			
				$('.mainBoardTabCont').eq($(this).index()).addClass('ani');			
				//핫키워드 반복모션
				hotKeyword = setInterval(function(){
					var lenType01 = $('.hotKeyword .cycleMotionType01').length;
					var lenType02 = $('.hotKeyword .cycleMotionType02').length;
					
					var idx01 = Math.floor(coviCmn.random()*(lenType01));
					var idx02 = Math.floor(coviCmn.random()*(lenType02));

					$('.hotKeyword .cycleMotion').each(function(){
						$(this).css("animation","");
					});
					$('.hotKeyword .cycleMotionType01').eq(idx01).css({
						animation:'bounce2 2s 0s'
					});
					$('.hotKeyword .cycleMotionType02').eq(idx02).css({
						animation:'bounce 1s 0s'
					});
					
				}, 4000);
			}else {
				clearInterval(hotKeyword);
			}
		});
	},
	
	//최근게시, 문서 탭 변경
	changeLatestTab: function(pObj, pBizSection, pMenuID){
		$(pObj).parent().parent().find('.active').removeClass('active');
		$(pObj).parent().addClass('active');
		
		tabBoard.getLatestMessageList(pBizSection, pMenuID);
	},
	
	getNoticeMessageList: function(){
		$("#noticeTitle").text(Common.getDic("lbl_notice"));
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectNoticeMessageList.do",
			data: { pageSize: tabBoard.config.noticeCount },
			success:function(data){
				var listData = data.list;
				$("#mainNoticeList").html("");
				$.each( listData, function(index, value) {
					var prefixURL = '/groupware/layout/board_BoardView.do?CLBIZ=Board&CLSYS=board&CLMD=user&sortBy=MessageID desc&startDate=&endDate=&searchText=&searchType=Subject';
	            	var viewURL = String.format('{0}&menuID={1}&folderID={2}&messageID={3}&version={4}&boardType=Normal', prefixURL, value.MenuID, value.FolderID, value.MessageID, value.Version);
	            	var liWrap = $('<li />');	//공지 게시글별 li태그로 묶음
	            	
	            	var pTitle = $('<p class="title" />').append( $('<a onclick="javascript:tabBoard.goViewPopup(\'Board\', '+value.MenuID+','+value.Version+','+value.FolderID+','+value.MessageID+')"/>').text(value.Subject).attr('title', value.Subject) );
	            	if(index == 0){	//첫번째 공지 게시글
						
						var pDate = $('<p class="date" />').append(
								$('<span />').text(value.CreatorName),  
								$('<span />').text(CFN_TransLocalTime(value.CreateDate, "yyyy.MM.dd"))
						);
						liWrap.addClass('first').append(pTitle, pDate);
						
						//이미지를 첨부했을 경우 표시함
						if(value.FileID != undefined && value.FileID != ""){
							var pNotiImage = $('<p class="notiFirstImg" />').append(
									//웹파트 공지사항 이미지 엑박수정
									$('<img />').attr('src', '/covicore/common/preview/Board/' + value.FileID +'.do')
									//$('<img />').attr('src', '/covicore/common/previewsrc/Board/' + value.FileID +'.do')
									//$('<img />').attr('src', Common.getThumbSrc("Board", value.FileID))
							);
							liWrap.append(pNotiImage);
						}
					} else {
						var pDate = $('<p class="date" />').append(		$('<span />').text(CFN_TransLocalTime(value.CreateDate, "yyyy.MM.dd")));
						liWrap.addClass('clearFloat').append(pTitle, pDate);
					}
					//게시판 목록 조회 팝업
//					var liWrap = $('<li onclick="javascript:$(location).attr(\'href\', \''+ viewURL + '\');"/>').append(divSubject, divCreator, divDate);
					$('#mainNoticeList').append(liWrap);
				});

				if(_ie) {
					var firstA = $(".mainNoticeList .first .title a");
					var limit = 32;
					if($(firstA).text().length >= limit) {
						$(firstA).text($(firstA).text().substr(0, limit)+'...');
					}
				}
			}
		});
	},
	
	getLatestMessageList: function(pBizSection, pMenuID){
		var params = {
			bizSection: pBizSection,
			menuID: pMenuID,
			messageCount: this.config.messageCount
		}
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectLatestMessageList.do",
			data: params,
			success:function(data){
				var listData = data.list;
				$("#tabBoard_messageList").html("");
				var mBoardTabView=$('.mBaordTabView');
				if(listData.length > 0)	{
					$.each( listData, function(index, value) {
						var prefixURL = '/groupware/layout/board_BoardView.do?CLBIZ='+ pBizSection +'&CLSYS=' + (pBizSection=='Board'?'board':'doc') + '&CLMD=user&sortBy=MessageID desc&startDate=&endDate=&searchText=&searchType=Subject';
		            	var viewURL = String.format('{0}&menuID={1}&folderID={2}&messageID={3}&version={4}&boardType=Normal', prefixURL, value.MenuID, value.FolderID, value.MessageID, value.Version);
		            	var liWrap = $('<li />');	
		            	var spanFolderName = $('<span class="type"/>').text(value.FolderName);
	//	            	var anchorSubject = $('<a class="title" onclick="javascript:$(location).attr(\'href\', \''+ viewURL + '\');"/>').text(value.Subject);
		            	var anchorSubject = $('<a class="title" onclick="javascript:tabBoard.goViewPopup(\''+pBizSection+'\', '+value.MenuID+','+value.Version+','+value.FolderID+','+value.MessageID+')"/>').text(value.Subject).attr('title', value.Subject);
		            	var spanDate = $('<span class="date" />').text(CFN_TransLocalTime(value.CreateDate, "yyyy.MM.dd"));
		            	mBoardTabView.removeClass('nodata');
						liWrap.addClass('clearFloat').append(spanFolderName, anchorSubject, spanDate);
	//					var liWrap = $('<li onclick="javascript:$(location).attr(\'href\', \''+ viewURL + '\');"/>').append(divSubject, divCreator, divDate);
						$('#tabBoard_messageList').append(liWrap);
					});
				}
				else {
					var liWrap = $('<li style="text-align: center; margin-top: calc(10% - 23px);"/>');
					var spanSubject = $('<span class="" style="color: #999;"/>').text(Common.getDic("msg_NoDataList"));
					mBoardTabView.addClass('nodata');
					liWrap.append(spanSubject);
					$('#tabBoard_messageList').append(liWrap);
				}
					
			}
		});
	},
	
	goViewPopup: function(pBizSection, pMenuID, pVersion, pFolderID, pMessageID){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
		parent.Common.open("", "boardViewPop", "<spring:message code='Cache.lbl_DetailView'/>", url, "1080px", "600px", "iframe", true, null, null, true);

		/*if(board.checkReadAuth(pBizSection, pFolderID, pMessageID, pVersion)){	//읽기 권한 체크
			var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
			parent.Common.open("", "boardViewPop", "<spring:message code='Cache.lbl_DetailView'/>", url, "1080px", "600px", "iframe", true, null, null, true);
		} else {
			Common.Warning("<spring:message code='Cache.msg_UNotReadAuth'/>");
		}*/
	},
}

