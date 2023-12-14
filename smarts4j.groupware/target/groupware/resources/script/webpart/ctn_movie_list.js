/**
 * MyContents : 추천영상
 */
var ctnMovieList = {
	config: {
		caller :"",
		webPartID:"",
		preId : "",
		folderID: "",
		settingKey:"WebpartMovieBoard"
	},
	init: function (data, ext, caller, webPartID){
		var _ext = (typeof ext == 'object') ? ext : {};
		ctnMovieList.config = $.extend(ctnMovieList.config, _ext);
		ctnMovieList.config.caller = caller;
		ctnMovieList.config.webPartID = webPartID;
		ctnMovieList.config.preId = webPartID!=undefined?"#"+webPartID+" ":"";
		ctnMovieList.config.folderID = Common.getBaseConfig(ctnMovieList.config.settingKey);
		
		const sessionObj = Common.getSession();
		if(sessionObj["isAdmin"] === "Y" || sessionObj["isEasyAdmin"] === "Y") {
			ctnMovieList.adminSetting(data[0], ctnMovieList.config.settingKey);
		}
		ctnMovieList.setData();
	},
	// 데이터 조회
	setData : function() {
		$(ctnMovieList.config.preId + ".widget_content," + ctnMovieList.config.preId + ".widget_empty").remove();
		$(ctnMovieList.config.preId + " .widget_card").append($("<div>", {"class" : "widget_content", "id":"contents_movie"}));
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectMovieBoardList.do",
			data: {
				"folderID"	:	ctnMovieList.config.folderID
			},
			success:function(data){
				ctnMovieList.render(data.list);
			}
		});
	},
	render: function(data) {
		var writeUrl = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&menuCode=BoardMain&folderID="+ctnMovieList.config.folderID;
		var moreUrl = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&menuCode=BoardMain&folderID="+ctnMovieList.config.folderID;
			
		$(ctnMovieList.config.preId + "#contents_movie").closest(".widget_card").find('.widget_more').attr("href", moreUrl);

		$(ctnMovieList.config.preId + " #contents_movie")
			.append($("<div>", {"class" : "video"}))
			.append($("<div>", {"class" : "info"}));
				
		$.each(data, function(i, item) {
			// video
			var ext = ctnMovieList.getVideoType(item.Extention);
			
			if(ext != "error") {
				$(ctnMovieList.config.preId + " .video")
					.append($("<video controls preload='none' poster='"+ coviCmn.loadImageIdThumb(item.FileID) +"'>")
						.append($("<source>", {"src" : coviCmn.loadImageId(item.FileID), "type":ctnMovieList.getVideoType(item.Extention)}))
					)
					.append($("<a>", {"href":"#"})
						.append($("<span>", {"text" : item.Subject}))
					)
			} else {
				$(ctnMovieList.config.preId + " .video").removeClass("video").addClass("video_error");
				
				$(ctnMovieList.config.preId + " .video_error")
					.append($("<div>", {"class":"message"})
						.append($("<p>", {"text":Common.getDic("lbl_unsupportedExt")})));
			}
			// info
			$(ctnMovieList.config.preId + " .info")
				.append($("<div>", {"class" : "ui_avatar"})
					.append($("<img>", {"src" : coviCmn.loadImage(Common.getBaseConfig('ProfileImagePath').replace('{0}', Common.getSession('DN_Code')) + item.CreatorCode + '.jpg') , "onerror": "coviCmn.imgError(this,true)" ,"alt" : "avatar"}))
				)
				.append($("<strong>", {"text": ctnMovieList.displayCreatorName(item.CreatorName, item.CreatorLevel, item.CreatorPosition, item.CreatorTitle)}))
				.append($("<time>", {"text": item.RegistDate}))
				.append($("<dl>")
					.append($("<dt>")
						.append($("<span>", {"text": Common.getDic('lbl_ReadCount')}))
					)
					.append($("<dd>", {"text": item.ReadCnt}))
				)
		});
		
	    //영상 재생
		$(ctnMovieList.config.preId + ".video a").on("click",function(){
	        const $video = $(this).siblings('video').get(0);
	        $(this).hide();
	        $video.play();
	        $(this).siblings('video').attr('controls', 'controls');
		});
	
	    //영상 정지
		$(ctnMovieList.config.preId + ".video video").on("pause",function(){
	        $(this).removeAttr('controls').next().show();
	    });

		coviUtil.webpartDrawEmpty(data, ctnMovieList.config.caller, ctnMovieList.config.webPartID, Common.getDic('lbl_NoViewVideos') , writeUrl);
		
	},
	getVideoType : function(pExtention){
		var VideoTypeCase = pExtention.toLowerCase();
		var rtnType = "";
		if (VideoTypeCase == 'mp4') {
			rtnType = "video/mp4";
		} else if (VideoTypeCase == 'ogg') {
			rtnType = "video/ogg";
		} else if (VideoTypeCase == 'webm') {
			rtnType = "video/webm";
		} else {
			rtnType = "error";
		}
		return rtnType
	},
	displayCreatorName: function(pCreatorName, pCreatorLevel, pCreatorPosition, pCreatorTitle){
		var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
		var sRepJobType = pCreatorLevel;
		if(sRepJobTypeConfig == "PN"){
		  	sRepJobType = pCreatorPosition;
		} else if(sRepJobTypeConfig == "TN"){
		    sRepJobType = pCreatorTitle;
		} else if(sRepJobTypeConfig == "LN"){
		    sRepJobType = pCreatorLevel;
		}
		if(sRepJobType == null) { sRepJobType = "" }
		var oCretaorName = pCreatorName+" "+sRepJobType;
		return oCretaorName;
	},
	adminSetting : function(data, settingKey) {
		$(ctnMovieList.config.preId + " .widget_option").append(
			$("<button>", {"type":"button", "data-action":"setting"}).append($("<span>", {"text" : Common.getDic("btn_Setting")}))
		);
		
		$(ctnMovieList.config.preId + " .widget_option [data-action='setting']").on("click", function() {
			$(ctnMovieList.config.preId + " .layer_divpop").attr("hidden", false);
		});
		
		$(ctnMovieList.config.preId + " .layer_divpop .divpop_close, " + ctnMovieList.config.preId + " .layer_divpop #close_popup").on("click", function() {
			$(ctnMovieList.config.preId + " .layer_divpop").attr("hidden", true);
		});
		
		$.each(data, function(idx, item) {
			if($(ctnMovieList.config.preId + "#folderSelect optgroup[name=optgrp_" + item.GroupValue + "]").length == 0) {
				$(ctnMovieList.config.preId + "#folderSelect").append($("<optgroup>", {"label" : item.GroupText, "name" : "optgrp_" + item.GroupValue}));
			}
			if(ctnMovieList.config.folderID == item.FolderID) {
				$(ctnMovieList.config.preId + "#folderName").text(item.DisplayName);
			}
			
			$(ctnMovieList.config.preId + "#folderSelect optgroup[name=optgrp_" + item.GroupValue + "]").append($("<option>", {"value":item.FolderID, "text":item.DisplayName}));
		});
		
		$(ctnMovieList.config.preId + "#saveFolderID").on("click", function() {
			var params = {
				"settingKey":settingKey, "settingVal":$(ctnMovieList.config.preId + "#folderSelect option:selected").val()
			};
			
			$.ajax({
				type:"POST",
				contentType: "application/json",
				url:"/groupware/portal/updateSettingKey.do",
				data:JSON.stringify(params),
				async:false,
				success: function(res) {
					coviCmn.reloadCache("BASECONFIG", sessionObj.DN_ID);
					
					ctnMovieList.config.folderID = $(ctnMovieList.config.preId + "#folderSelect option:selected").val();
					ctnMovieList.setData();
				}
			});
		});
	}
}