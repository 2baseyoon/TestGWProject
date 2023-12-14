/**
 * Contents 게시판 연결 (2타입)
 * [확장JSON]
 * 1. option : 표시 형식, 기재 없을땐 썸네일형
 *		thumbnail (썸네일형), book (책자형)
 * 2. settingKey : 기초설정 설정키, 폴더ID와 맵핑
 *		썸네일형: WebpartThumbnailBoard
 *		책자형 : WebpartBookBoard
 * 3. moreUrl : 더보기url, "#"고정
 * 
 * [초기 데이터 조회JSON]
 * 1. queryID : user.portal.selectBoardFolderByType
 * 2. paramData
 *    2-1. domainId : 소속 도메인 아이디
 *    2-2. folderType : Album(앨범 게시판)
 */
var ctnBoardList = {
	config: {
		settingKey:"WebpartThumbnailBoard", // 기초설정 설정키, 확장JSON에 settingKey항목이 없으면 "WebpartThumbnailBoard" 로 설정.
		option:"thumbnail", 				// 표시 옵션, 확장JSON에 option 항목이 없으면 "thumbnail"로 설정.
		webPartID:"", 						// 웹파트ID
		preId : "", 						// 웹파트ID가 undefined 일때는 "", 그 외에는 #웹파트ID 
		folderID: "", 						// 폴더ID, 기초설정 설정키로 폴더ID를 찾아온다
		pageSize : "4"  					// 표시할 게시물 건수, 썸네일형 세로가 길때는 8건
	},
	init: function (data, ext, caller, webPartID){

		// ctnBoardList.config 값 세팅
		var _ext = (typeof ext == 'object') ? ext : {};
		ctnBoardList.config = $.extend(ctnBoardList.config, _ext);
		ctnBoardList.config.webPartID = webPartID;
		ctnBoardList.config.preId = webPartID!=undefined?"#"+webPartID+" ":"";
		ctnBoardList.config.folderID = Common.getBaseConfig(ctnBoardList.config.settingKey);
		
		// 관리자, 간편관리자는 설정 메뉴 표시
		const sessionObj = Common.getSession();
		if(sessionObj["isAdmin"] === "Y" || sessionObj["isEasyAdmin"] === "Y") {
			ctnBoardList.adminSetting(data[0], ctnBoardList.config.settingKey);
		}
		
		// 게시 데이터 조회
		ctnBoardList.setData();
	},
	setData : function() {
		// .widget_content, .widget_empty 지우고 .widget_card에 .widget_content 추가
		$(ctnBoardList.config.preId + ".widget_content," + ctnBoardList.config.preId + ".widget_empty").remove();
		$(ctnBoardList.config.preId + ".widget_card").append($("<div>", {"class" : "widget_content", "id":"contents_boardlist"}));		
		
		// 표시할 게시물 건수, 썸네일형 세로가 길때는 8건
		if(ctnBoardList.config.option == "thumbnail" && 
			$(ctnBoardList.config.preId + ".widget_card").closest(".grid_item").attr("class").includes("y2")){
			ctnBoardList.config.pageSize = "8";
		}
					
		// 폴더ID : 기초설정 값
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectMessageGridList.do",
			data: {
				"boardType"	:	"Normal"
				,"bizSection":	"Board"
				,"folderID"	:	ctnBoardList.config.folderID
				,"folderType":	"Album"
				,"viewType"	: 	""
				,"startDate": 	""
				,"endDate"	:	""
				,"pageSize"	:	ctnBoardList.config.pageSize
				,"pageNo"	:	1
				,"sortBy"	: 	"RegistDate desc"
			},
			success:function(data){
				// 데이터 표시
				ctnBoardList.render(data.list);
			}
		});
	},
	render: function(data) {
		// 데이터 없을때 작성버튼 URL
		var writeUrl = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&menuCode=BoardMain&folderID="+ctnBoardList.config.folderID;
		// 바로가기 URL
		var moreUrl = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&menuCode=BoardMain&folderID="+ctnBoardList.config.folderID;
		$(ctnBoardList.config.preId + "#contents_boardlist").closest(".widget_card").find('.widget_more').attr("href", moreUrl);
		
		// thumbnail (썸네일형), book (책자형)
		if (ctnBoardList.config.option == "thumbnail"){
			// 썸네일형
			ctnBoardList.renderThumbnail(data);

		} else {
			// 책자형
			ctnBoardList.renderBook(data);
		}

		// 데이터 없을 때 : 조회할 목록이 없습니다.
		coviUtil.webpartDrawEmpty(data, "Contents", ctnBoardList.config.webPartID, Common.getDic('msg_NoDataList') , writeUrl);
		
	},
	renderBook : function(data){
		// book (책자형)
		var $targetDiv = $(ctnBoardList.config.preId + "#contents_boardlist");
		$targetDiv.append($("<div>", {"class" : "swiper widget_newsletter_swiper"})
			.append($("<div>", {"class" : "swiper-wrapper"}))
		).append($("<div>",{"class":"swiper-button-next widget_newsletter_button_next"})
			.append($("<span>",{"text":"다음"}))
		).append($("<div>",{"class":"swiper-button-prev widget_newsletter_button_prev"})
			.append($("<span>",{"text":"이전"}))
		);
		
		
		$.each(data, function(i, item) {
			$targetDiv.find(".swiper-wrapper")
				.append($("<div>", {"class" : "swiper-slide"})
					.append($("<a>",{"href":ctnBoardList.getDetailUrl(item.MenuID, item.Version, item.FolderID, item.MessageID), "class":"item"})
						.append($("<span>")
							.append($("<img>", {"src" : Common.getThumbSrc("Board", item.FileID), "onerror" : "coviCmn.imgError(this,false)" , "alt":"image"}))
						)
						.append($("<strong>",{"text":item.Subject}))
					)
				);
		});

		const widgetNewsLetterSwiper = new Swiper(".widget_newsletter_swiper", {
	        threshold: 5,
	        slidesPerView: 2,
	        slidesPerGroup: 2,
	        navigation: {
	            nextEl: ".widget_newsletter_button_next",
	            prevEl: ".widget_newsletter_button_prev",
	        }
	    });

	},
	renderThumbnail : function(data){
		// thumbnail (썸네일형)
		$(ctnBoardList.config.preId + "#contents_boardlist")
			.append($("<div>", {"data-custom-scrollbar" : ""})
				.append($("<div>", {"class":"content_list"}))
			);
		$.each(data, function(i, item) {
			// 좋아요 카운트
			ctnBoardList.getLikeCount("Board", item.MessageID + "_" + item.Version, i);
			// 댓글 카운트
			ctnBoardList.getCommentCount("Board", item.MessageID + "_" + item.Version, i);
			
			$(ctnBoardList.config.preId + "#contents_boardlist").find(".content_list")
				.append($("<div>",{"class":"item"})
					.append($("<a>",{"href":ctnBoardList.getDetailUrl(item.MenuID, item.Version, item.FolderID, item.MessageID), "class":"post_item"})
						.append($("<span>",{"class":"preview"})
							.append($("<img>", {"src" : Common.getThumbSrc("Board", item.FileID), "onerror" : "coviCmn.imgError(this,false)"}))
						)
						.append($("<strong>",{"class":"item_title", "text":item.Subject}))
						.append($("<time>",{"class":"item_date", "text": schedule_SetDateFormat(item.RegistDate, ".")}))
					)
					.append($("<div>",{"class":"action"})
						.append($("<button>",{"type":"button", "class":"like", "id":"likeBtn"+i}).data("typeid",item.MessageID + "_" + item.Version)
							.append($("<span>",{"text":"like"}))
							.append($("<em>"))
						)
						.append($("<a>",{"href":ctnBoardList.getDetailUrl(item.MenuID, item.Version, item.FolderID, item.MessageID), "class":"comments", "id":"comments"+i})
							.append($("<span>",{"text":"comment"}))
							.append($("<em>"))
						)
					)
				);
				
		});
		// 좋아요 클릭시
		$(ctnBoardList.config.preId + ".like").on("click",function(){
			ctnBoardList.addLikeCount('Board', $(this).data('typeid') , this.id);
		});

	},
	getLikeCount: function(pTargetType, pTargetID, pIdx){
		// 썸네일형 좋아요 카운트
		$.ajax({
			url: "/covicore/comment/getLike.do",
			type: "POST",
			data: {
				"TargetType": pTargetType,
				"TargetID": pTargetID
			},
			success: function(res){
			    var $con = $('#likeBtn' + pIdx);
			    $con.find('em').html(res.data);
			     if(Number(res.myLike) > 0){
					$con.attr("aria-pressed","true");
				}
			}
	 	});
	},
	addLikeCount: function(pTargetType, pTargetID, pIdx){
		// 썸네일형 좋아요 클릭시
		$.ajax({
			url: "/covicore/comment/addLike.do",
			type: "POST",
			data: {
				"TargetType": pTargetType,
				"TargetID": pTargetID,
				"LikeType": "emoticon",
				"Emoticon": "heart",
				"Point": "0"
			},
			success: function(res){
			    var $con = $('#' + pIdx);
				$con.find('em').html((res.data > 0 ? res.data : 0));
				if(Number(res.myLike) > 0){
					$con.attr("aria-pressed","true");
				}else{
					$con.attr("aria-pressed","");
				}
			}
	 	});
	},
	getCommentCount : function(pTargetType, pTargetID, pIdx){
		// 썸네일형 댓글 카운트
		$.ajax({
			type : "POST",
		    url : "/covicore/comment/getCommentCount.do",
	        data : {
	        	'TargetType' : pTargetType,
	        	'TargetID' : pTargetID
	        },
	        success : function(res){
			    var $con = $('#comments' + pIdx);
			    $con.find('em').html((res.data > 0 ? res.data : 0));
			}
	 	});
	},
	getDetailUrl: function(pMenuID, pVersion, pFolderID, pMessageID){
		// 썸네일형,책자형  데이터 클릭시 게시판이동 url
		var url = String.format("/groupware/layout/board_BoardView.do?CLSYS=board&CLMD=user&CLBIZ=Board&menuID={0}&version={1}&folderID={2}&messageID={3}&viewType=Album&boardType=Normal&startDate=&endDate=&sortBy=RegistDate%20desc&searchText=&searchType=Subject&page=1&pageSize=10&rNum=1&boxType=Receive&approvalStatus=R&menuCode=BoardMain", pMenuID, pVersion, pFolderID, pMessageID);
		return url;
	},
	adminSetting : function(data, settingKey) {
		// 관리자, 간편관리자 설정메뉴 표시
		$(ctnBoardList.config.preId + " .widget_option").append(
			$("<button>", {"type":"button", "data-action":"setting"}).append($("<span>", {"text" : Common.getDic("btn_Setting")}))
		);
		
		// 설정메뉴 클릭시 팝업 표시
		$(ctnBoardList.config.preId + " .widget_option [data-action='setting']").on("click", function() {
			$(ctnBoardList.config.preId + " .layer_divpop").attr("hidden", false);
		});
		// 팝업 X버튼, 팝업 취소버튼 클릭시 팝업숨기기
		$(ctnBoardList.config.preId + " .layer_divpop .divpop_close, " + ctnBoardList.config.preId + " .layer_divpop #close_popup").on("click", function() {
			$(ctnBoardList.config.preId + " .layer_divpop").attr("hidden", true);
		});
		
		// 게시판 선택지추가
		$.each(data, function(idx, item) {
			if($(ctnBoardList.config.preId + "#folderSelect optgroup[name=optgrp_" + item.GroupValue + "]").length == 0) {
				$(ctnBoardList.config.preId + "#folderSelect").append($("<optgroup>", {"label" : item.GroupText, "name" : "optgrp_" + item.GroupValue}));
			}
			
			if(ctnBoardList.config.folderID == item.FolderID) {
				$(ctnBoardList.config.preId + "#folderName").text(item.DisplayName);
			}
			
			$(ctnBoardList.config.preId + "#folderSelect optgroup[name=optgrp_" + item.GroupValue + "]").append($("<option>", {"value":item.FolderID, "text":item.DisplayName}));
		});
		
		// 팝업 변경버튼 클릭시
		$(ctnBoardList.config.preId + "#saveFolderID").on("click", function() {
			var params = {
				"settingKey":settingKey, "settingVal":$(ctnBoardList.config.preId + "#folderSelect option:selected").val()
			};
			
			$.ajax({
				type:"POST",
				contentType: "application/json",
				url:"/groupware/portal/updateSettingKey.do",
				data:JSON.stringify(params),
				async:false,
				success: function(res) {
					coviCmn.reloadCache("BASECONFIG", sessionObj.DN_ID);
					
					ctnBoardList.config.folderID = $(ctnBoardList.config.preId + "#folderSelect option:selected").val();
					ctnBoardList.setData();
				}
			});
		});
	}
}