/**74
 * 좌우분할형 - 멀티 게사판
[{"Type":"Board","DisplayName":"전체공지;Full notice;全体公示;整个公告;;;;;;;","MenuID":"10","FolderID":"6493"}...]
board.js - 필수조건
 */
var MultiTabBoard = {
	config: {
		webpartType: '',
		recentlyDay: 3,
		webpartClassName: 'ptype02',
		webpartBoardClassName: 'ptype02_Notice', 
		webpartTopClassName: 'ptype02_tab',
		webpartContentClassName: 'ptype02_wp',
		webpartTableClassName : 'ptype02_sday',
		webpartTableHeight: 'ptype02_wp_height', 
		webpartTabActive: 'ptype02_tab_on'
	},
	init: function(data,ext,caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		MultiTabBoard.caller = caller;
		
		MultiTabBoard.config = $.extend(MultiTabBoard.config, _ext);
		var folderInfo = ext.FolderInfo;	
		var templateList = ''
			
		MultiTabBoard.setBoardTab(folderInfo);
		
		if(MultiTabBoard.config.webpartType=='Ptype05'){ 
			templateList = document.querySelector("#Ptype05_board").innerHTML;
		}else{
			templateList = document.querySelector("#board").innerHTML; 
		}
		
		$("#TabBoard > div:first-child").addClass(MultiTabBoard.config.webpartTableClassName); 
		$("#TabBoard .webpart-content").html('').append(templateList); 
		$("#TabBoard .webpart-content").addClass(MultiTabBoard.config.webpartTableHeight);
		$("#TabBoard .PN_boardCont").appendTo("#TabBoard");
		$("#TabBoard.webpart").addClass(MultiTabBoard.config.webpartBoardClassName); 
		$("#TabBoard .webpart-top").addClass(MultiTabBoard.config.webpartTopClassName);
		$("#TabBoard .webpart-content table:first-child").addClass(MultiTabBoard.config.webpartTableClassName+"_table");
		$("#TabBoard table:last-child .wp_none").addClass(MultiTabBoard.config.webpartContentClassName+"_none");
	},	
	tabClick: function(target){	
		//선택된 게시판 색상 표시/글씨 색상 변경 및 게시글 호출
		if(MultiTabBoard.config.webpartType == 'Ptype05'){
			$(target).closest('div').children().removeClass("active");
			MultiTabBoard.getMessageList($(target).children().attr("id"));
			$(target).addClass("active"); 
		}else{
			$(target).closest('div').children('a').attr("class",MultiTabBoard.config.webpartClassName+"_tab_off");
			MultiTabBoard.getMessageList($(target).attr("id"));
			$(target).attr("class",MultiTabBoard.config.webpartClassName+"_tab_on");		
		}
	},
	setBoardTab: function(folderInfo){
		var lang = Common.getSession("LanguageCode"); 
		var firstFolderID = "";
		var linkUrl = "";
		var positionMore = "";
		var moreView = "";
		
		positionMore = $("#dBoardTab");
		moreView = "more&nbsp;&gt;";
		
		if(MultiTabBoard.config.webpartType == 'Ptype03'){ 
			positionMore = $("#TabBoard > div");
			moreView = '<img src="/HtmlSite/smarts4j_n/customizing/Ptype03/images/project/cv_more.gif" alt="More" title="More">';
			$("#TabBoard > div").prepend("<h3>사내소식</h3>");
		}else if(MultiTabBoard.config.webpartType == 'Ptype05'){ 
			positionMore = $("");
		}
		
		$("#dBoardTab").text("");
		$.each(folderInfo, function(idx, item){
			var folderName = CFN_GetDicInfo(item.DisplayName, lang);			
			$("#dBoardTab").append("<a class='"+MultiTabBoard.config.webpartClassName+"_tab_off' id='" + item.FolderID + "' href='#'><span>" + folderName + "</span></a>");									
		});		

		if(MultiTabBoard.config.webpartType=='Ptype05'){ 
			$("#dBoardTab > a").wrap("<li></li>")
		}
		$("#dBoardTab").children().attr("onclick","MultiTabBoard.tabClick(this)");	
		
		//첫번째 탭 default 
		$("#dBoardTab").children().not("p").first().addClass(MultiTabBoard.config.webpartClassName+"_tab_on active"); 

		//게시판 more버튼
		positionMore.prepend("<p class='"+MultiTabBoard.config.webpartClassName+"_more' ><a href='#' id='aBoardMore' alt='More' title='More'>"+moreView+"</a></p>");		
			
		//첫번 째 게시 탭 list목록 조회
		firstFolderID = $("#dBoardTab [class*='_tab']").not('li').first().attr('id'); 
		MultiTabBoard.getMessageList(firstFolderID);	
			
		// 필요 시 게시판 안읽은 카운트 표시 개발 필요(카운트 가져오는 조건 정해야함 - ex : 읽음여부, 게시날짜 조건 등..))			
	},
	getMessageList: function(pFolderID){
		board.getBoardConfig(pFolderID);
		
		//한페이지에 보여질 게시의 개수
		var pageSize = 0;
		if(MultiTabBoard.config.webpartType == 'Ptype05'){
			pageSize = 6;
		}else{
			pageSize = 5;
		}
		//게시 리스트 초기화
		$("#tbBoard").text("");
		
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
				, "pageSize": pageSize
				, "pageNo": 1
			},
			success: function(data){
				var listData = data.list;
				var liHtml = "";
				var listHTML = "";
				
				var recentFlag = false;
				
				if(MultiTabBoard.config.webpartType == 'Ptype05'){
					if(listData != null && listData.length > 0){
						$.each(listData, function(idx, item){
							var bSubject = "";       //new icon
							var bSubjectStyle = "";  //게시글 미확인 시 bold

							var listDate = (CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"));
							var listTime = (CFN_TransLocalTime(item.CreateDate, "HH:mm"));
							
							var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
							var compareDate = schedule_AddDays(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"), MultiTabBoard.config.recentlyDay);
							
							var ImagePath = "";
							if(idx == 0) {
								if(item.ThumbImageID != '') {
									ImagePath = coviCmn.loadImageId(item.ThumbImageID);
								} else ImagePath = "/HtmlSite/smarts4j_n/customizing/ptype05/images/project/noimg02.jpg";
							}
							
							//new icon
							if(today.getTime() < compareDate.getTime()){ 
								bSubject += '<span class="countStyle new">N</span>';
							}else{
								bSubject = "";
							}
							
							var templateList = document.querySelector("#Ptype05_board_list").innerHTML;
							var replaceList = templateList.replace("{event}","MultiTabBoard.openBoardPopup(" + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");")
											 .replace("{titleStyle}",item.IsRead == "N" ? "bold" : "")
											 .replace("{subject}",bSubject)
											 .replace("{description}",item.Subject)
											 .replace("{name}",item.CreatorName)
											 .replace("{date}",listDate)
											 .replace("{time}",listTime)
											 .replace("{firstClass}",idx==0?"first":"")
											 .replace("{fistImage}",idx==0?'<span class="boImg"><img src='+ImagePath+' alt=""></span>':"");
							listHTML += replaceList;
							
						});
						$("#TabBoard .PN_boardList").html('').append(listHTML);
						$("#TabBoard .PN_nolist").hide();	
					}else{
						$("#TabBoard .PN_boardList").html('').append(listHTML);
						$("#TabBoard .PN_nolist").show();	
					}
				}else{
					if(listData != null && listData.length > 0){
						var vTbody = $("<tbody></tbody>");
						$.each(listData, function(idx, item){
							var bSubject = "";						
							if(item.IsRead == "N") 
								bSubject = "<strong>" + item.Subject + "<strong>";
							else
								bSubject =  item.Subject;
								
							var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
							var compareDate = schedule_AddDays(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"), MultiTabBoard.config.recentlyDay);							
							if(today.getTime() < compareDate.getTime()){ 
								bSubject += "<span class='"+MultiTabBoard.config.webpartClassName+"_newicon'>N</span>"
							}
							
							var templateList = document.querySelector("#board_list").innerHTML;
							var replaceList = templateList.replace("{descriptionTopClass}",MultiTabBoard.config.webpartContentClassName+"_ta01")
												.replace("{descriptionClass}",MultiTabBoard.config.webpartClassName+"_ellipsis_n")
												.replace("{popupFuntion}","MultiTabBoard.openBoardPopup(" + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");")
												.replace("{description}",bSubject)
												.replace("{createNameClass}",MultiTabBoard.config.webpartContentClassName+"_ta02")
												.replace("{createName}",item.CreatorName)
												.replace("{createDateClass}",MultiTabBoard.config.webpartContentClassName+"_ta03")
												.replace("{createDate}",CFN_TransLocalTime(item.CreateDate, "MM.dd"));
							listHTML += replaceList;
						});
						$("#tbBoard").append(listHTML);
						$("#tbBoardNoContents").hide();
					}else{
						$("#tbBoardNoContents").show();	
					}
				}
					
				linkUrl = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&menuID=" + g_boardConfig.MenuID + "&folderID=" + pFolderID;
				$("#TabBoard #aBoardMore").attr("href", linkUrl);
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/selectMessageGridList.do", response, status, error);
	    	}
		});
	},
	
	openBoardPopup: function(pMenuID, pVersion, pFolderID, pMessageID){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", "Board", pMenuID, pVersion, pFolderID, pMessageID);
		Common.open("", "boardViewPop", "<spring:message code='Cache.lbl_DetailView'/>", url, "1080px", "600px", "iframe", true, null, null, true); // 상세보기
	}
}
