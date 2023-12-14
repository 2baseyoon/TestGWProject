/**
 * pnMovieList - [포탈개선] My Place - 진행중인 설문
 */
var pnMovieList = {
	webpartType: "",
	recentlyDay: 3,
	init: function (data, ext){
		var folderID = ext.FolderID;
		
		pnMovieList.setEvent();
		pnMovieList.getVideoList(folderID);
	},
	setEvent: function(){
		$(".PN_Movie").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
			if(!$(this).hasClass("active")){
				$(this).addClass("active");
				$(this).next(".PN_portlet_menu").stop().slideDown(300);
				$(this).children(".PN_portlet_btn > span").addClass("on");
			}else{
				$(this).removeClass("active");
				$(this).next(".PN_portlet_menu").stop().slideUp(300);
				$(this).children(".PN_portlet_btn > span").removeClass("on");
			}
		});

		$(".PN_Movie").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
		
		$(".PN_btnArea .btnOpen").on("click", function(){
			if($(this).parents().find(".PN_mainLeft").is(":hidden") == false){
				var orgWidth = Number($(".PN_Movie .slick-list").css("width").replace(/[^\-\.0-9]/g, ""));
				var len = $(".PN_Movie .slick-slide").length;
				var trackWidth = 100 * len;
				var slideWidth = 100 / len;
				var width = orgWidth - (Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, "")) / 2);
				var mNum = $(".PN_Movie").slick("slickCurrentSlide");
				
				$(".PN_Movie .slick-track").css({"width": trackWidth + "%", "transform": "translate3d(-" + (width * mNum) + "px, 0px, 0px)"});
				$(".PN_Movie .slick-slide").css("width", slideWidth + "%");
				
				$(".PN_Movie").slick("getSlick").slideWidth = Number($(".PN_Movie .slick-slide").css("width").replace(/[^\-\.0-9]/g, ""))
																- (Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, "")) / 2);
			}
		});
		
		$(".PN_btnArea .btnClose").on("click", function(){
			if($(this).parents().find(".PN_mainLeft").is(":hidden") == false){
				var orgWidth = Number($(".PN_Movie .slick-list").css("width").replace(/[^\-\.0-9]/g, ""));
				var len = $(".PN_Movie .slick-slide").length;
				var trackWidth = 100 * len;
				var slideWidth = 100 / len;
				var width = orgWidth + (Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, "")) / 2);
				var mNum = $(".PN_Movie").slick("slickCurrentSlide");
				
				$(".PN_Movie .slick-track").css({"width": trackWidth + "%", "transform": "translate3d(-" + (width * mNum) + "px, 0px, 0px)"});
				$(".PN_Movie .slick-slide").css("width", slideWidth + "%");
				
				$(".PN_Movie").slick("getSlick").slideWidth = Number($(".PN_Movie .slick-slide").css("width").replace(/[^\-\.0-9]/g, ""))
																+ (Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, "")) / 2);
			}
		});
		
		$(".PN_Movie").on("beforeChange", function(event, slick, currentSlide, nextSlide){
			$(".PN_MovList video").trigger("pause");
		});
	},
	getVideoList: function(pFolderID){
		board.getBoardConfig(pFolderID);
		//var backStorage = Common.getBaseConfig("BackStorage");
		var menuID = g_boardConfig.MenuID;
		var folderUrl = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&menuID=" + menuID + "&folderID=" + pFolderID;
		
		$("#PN_movie_link").attr("href", folderUrl);

		$(".PN_Movie").closest(".PN_myContents_box").find(".PN_portlet_menu li[mode=write]").off("click").on("click", function(){
			var wUrl = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&menuID=" + menuID + "&folderID=" + pFolderID;
			window.open(wUrl);
		});
		
		$.ajax({
			url: "/groupware/pnPortal/selectMovieBoardList.do",
			type: "POST",
			data: {
				  "boardType": "Normal"
				, "bizSection": "Board"
				, "folderID": pFolderID
				, "folderType": g_boardConfig.FolderType
				, "viewType": "List"
				, "startDate": ""
				, "endDate": ""
				, "pageNo": 1
				, "pageSize": 3
				, "sortBy": "RegistDate desc"
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					if(data != null && data.list.length != 0){
						$.each(data.list, function(idx, item){
							var divWrap = $("<div class='PN_MovList'>");
							var registDate = CFN_TransLocalTime(item.RegistDate).split(" ")[0];
							var videoUrl = "";
							var videoThumbnailUrl = "";
							if(item.fileList != undefined && item.fileList != ""){
								var fileInfo = item.fileList[0];
								videoUrl = coviCmn.loadImageId(fileInfo.FileID);
								videoThumbnailUrl = coviCmn.loadImageIdThumb(fileInfo.FileID);
							}
							
							// 내용에 비디오 추가 (HTML5 재생 지원하는 확장자만) 
							var VideoTypeCase = fileInfo.Extention.toLowerCase();
							if(VideoTypeCase == "mp4"){
								divWrap.append($("<div class='tMovie'></div>").append($("<video width='100%' height='100%' controls preload='none' poster='"+videoThumbnailUrl+"'></video>").append($("<source>").attr("src", videoUrl).attr("type","video/mp4"))))
								.append($("<a href='#'></a>").attr("onclick", "board.goViewPopup('Board', " + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");")
								.append($("<strong class='tTxt'></strong>").append($("<span class='tTitle'></span>").text(item.Subject)).append($("<span class='tDate'></span>").text(registDate))))
								.append($("<div class='tIcon'></div>"));
							}else if(VideoTypeCase == "ogg"){
								divWrap.append($("<div class='tMovie'></div>").append($("<video width='100%' height='100%' controls preload='none' poster='"+videoThumbnailUrl+"'></video>").append($("<source>").attr("src", videoUrl).attr("type","video/ogg"))))
								.append($("<a href='#'></a>").attr("onclick", "board.goViewPopup('Board', " + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");")
								.append($("<strong class='tTxt'></strong>").append($("<span class='tTitle'></span>").text(item.Subject)).append($("<span class='tDate'></span>").text(registDate))))
								.append($("<div class='tIcon'></div>"));
							}else if(VideoTypeCase == "webm"){
								divWrap.append($("<div class='tMovie'></div>").append($("<video width='100%' height='100%' controls preload='none' poster='"+videoThumbnailUrl+"'></video>").append($("<source>").attr("src", videoUrl).attr("type","video/webm"))))
								.append($("<a href='#'></a>").attr("onclick", "board.goViewPopup('Board', " + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");")
								.append($("<strong class='tTxt'></strong>").append($("<span class='tTitle'></span>").text(item.Subject)).append($("<span class='tDate'></span>").text(registDate))))
								.append($("<div class='tIcon'></div>"));
							}else{ //비디오를 지원하지 않는 경우
								var VideoNoData = Common.getGlobalProperties("css.path") + "/covicore/resources/images/common/no_photo.png";
								divWrap.append($("<div class='tMovie'></div>").append($("<div class='movie_error'></div>").append($("<div class='message'></div>").append($("<p>"+ Common.getDic("lbl_WebVideoUnSupport") +"</p>")))))
								.append($("<a href='#'></a>").attr("onclick", "board.goViewPopup('Board', " + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");")
								.append($("<strong class='tTxt'></strong>").append($("<span class='tTitle'></span>").text(item.Subject)).append($("<span class='tDate'></span>").text(registDate))))
								.append($("<div class='tIcon'></div>"));
							}
							
							var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
							var compareDate = schedule_AddDays(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"), pnMovieList.recentlyDay);
							
							if(today.getTime() < compareDate.getTime()){
								var recentlyBadge = $("<span></span>").addClass("countStyle new").text("N");
								
								divWrap.find(".tTitle").prepend(recentlyBadge);
								recentFlag = true;
							}
							
							if(g_boardConfig.UseComment == "Y"){
								divWrap.find(".tIcon")
									.append($("<a href='#' class='btn_comment'></a>")
										.attr("onclick", "javascript:board.replyPopup(" + item.FolderID + ", " + item.MessageID + ", " + item.Version + ", 'Board');"));
							}
							
							if(g_boardConfig.UseRecommend == "Y"){
								divWrap.find(".tIcon")
									.append($("<a href='#' class='btn_like'></a>")
										.attr("onclick", "pnMovieList.addLikeCount('Board', '" + item.MessageID + "_" + item.Version + "', " + idx + ");")
										.append($("<span></span>")));
							}
							
							$(".PN_Movie").not(".PN_nolist").append(divWrap);
							pnMovieList.loadLikeCount("Board", item.MessageID + "_" + item.Version, idx);
						});
						
						// video context menu 안보이게 처리(클릭 시 오류 발생)
						$("video").on("loadeddata", function(){
							$("video").attr("controlsList", "nodownload");
							$("video").bind("contextmenu", function(){return false;});
							$("video").attr("disablePictureInPicture", "true");
						});
						
						if(data.list.length <= 1){
							$(".PN_Movie").closest(".PN_myContents_box").find(".PN_portlet_function").removeClass("PN_pos");
						}
						
						pnMovieList.setSlideMovieList();
					}else{
						$(".PN_Movie").hide();
						$(".PN_Movie").closest(".PN_portlet_contents").find(".PN_nolist").show();
					}
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/pnPortal/selectMovieBoardList.do", response, status, error);
			}
		});
	},
	setSlideMovieList: function(){
		const slider = $(".PN_Movie");
		
		slider.slick({
			slide: "div",			// 슬라이드 되어야 할 태그 ex) div, li
			infinite: false,		// 무한 반복 옵션
			slidesToShow: 1,		// 한 화면에 보여질 컨텐츠 개수
			slidesToScroll: 1,		// 스크롤 한번에 움직일 컨텐츠 개수
			speed: 500,				// 다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
			arrows: true,			// 옆으로 이동하는 화살표 표시 여부
			dots: false,			// 스크롤바 아래 점으로 페이지네이션 여부
			autoplay: true,			// 자동 스크롤 사용 여부
			autoplaySpeed: 3000,	// 자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
			pauseOnHover: true,		// 슬라이드 이동	시 마우스 호버하면 슬라이더 멈추게 설정
			vertical: false,		// 세로 방향 슬라이드 옵션
			draggable: false,		// 드래그 가능 여부
			variableWidth: false
		});
	},
	loadLikeCount: function(pTargetType, pTargetID, pIdx){
		$.ajax({
			url: "/covicore/comment/getLike.do",
			type: "POST",
			data: {
				"TargetType": pTargetType,
				"TargetID": pTargetID
			},
			success: function(res){
				if(Number(res.myLike) > 0){
					$(".PN_MovList").eq(pIdx)
						.find(".btn_like span").addClass("like");
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/comment/getLike.do", response, status, error);
	   		}
	 	});
	},
	addLikeCount: function(pTargetType, pTargetID, pIdx){
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
				// 하트 애니메이션
				if(Number(res.myLike) > 0){
					$(".PN_MovList").eq(pIdx)
						.find(".btn_like span").addClass("like");
				}else{
					$(".PN_MovList").eq(pIdx)
						.find(".btn_like span").removeClass("like");
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/comment/addLike.do", response, status, error);
	   		}
	 	});
	}
}
