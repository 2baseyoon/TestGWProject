var albumBoard = {
	folderID: "",
	init: function(data, ext, caller, webpartID) {
		
		const sessionObj = Common.getSession();
		
		albumBoard.folderID = Common.getBaseConfig(ext.settingKey);
		
		if(sessionObj["isAdmin"] === "Y" || sessionObj["isEasyAdmin"] === "Y") {
			albumBoard.adminSetting(data[0], webpartID, caller, ext.settingKey);
		}
		
		albumBoard.setData(caller, webpartID);
	},
	adminSetting : function(data, webpartID, caller, settingKey) {
		$("#" + webpartID + " .widget_option").append(
			$("<button>", {"type":"button", "data-action":"setting"}).append($("<span>", {"text" : Common.getDic("btn_Setting")}))
		);
		
		$("#" + webpartID + " .widget_option [data-action='setting']").on("click", function() {
			$("#" + webpartID + " .layer_divpop").attr("hidden", false);
		});
		
		$("#" + webpartID + " .layer_divpop .divpop_close, " + "#" + webpartID + " .layer_divpop #close_popup").on("click", function() {
			$("#" + webpartID + " .layer_divpop").attr("hidden", true);
		});
		
		$.each(data, function(idx, item) {
			if($("#" + webpartID + " #albumFolderSelect optgroup[name=optgrp_" + item.GroupValue + "]").length == 0) {
				$("#" + webpartID + " #albumFolderSelect").append($("<optgroup>", {"label" : item.GroupText, "name" : "optgrp_" + item.GroupValue}));
			}

			if(item.FolderID == albumBoard.folderID) {
				$("#" + webpartID + " #webpartAlbumBoardName").text(item.DisplayName);
			}
			
			$("#" + webpartID + " #albumFolderSelect optgroup[name=optgrp_" + item.GroupValue + "]").append($("<option>", {"value":item.FolderID, "text":item.DisplayName}));
		});
		
		$("#" + webpartID + " #saveAlbumFolderID").on("click", function() {
			var params = {
				"settingKey":settingKey, "settingVal":$("#" + webpartID + " #albumFolderSelect option:selected").val()
			};
			
			$.ajax({
				type:"POST",
				contentType: "application/json",
				url:"/groupware/portal/updateSettingKey.do",
				data:JSON.stringify(params),
				async:false,
				success: function(res) {
					coviCmn.reloadCache("BASECONFIG", sessionObj.DN_ID);
					
					albumBoard.folderID = $("#" + webpartID + " #albumFolderSelect option:selected").val();
					albumBoard.setData(caller, webpartID);
				}
			});
		});
	},
	setData : function(caller, webpartID) {
		$("#" + webpartID + " .widget_content," + "#" + webpartID + " .widget_empty").remove();
		
		$("#" + webpartID + " .widget_card").append(
				$("<div>", {"class" : "widget_content", "id":"contents_gallery_list"}).append($("<ul>"))
			);		
		
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectMessageGridList.do",
			data: {
				"boardType"	:	"Normal"
				,"bizSection":	"Board"
				,"folderID"	:	albumBoard.folderID
				,"folderType":	"Album"
				,"viewType"	: 	""
				,"startDate": 	""
				,"endDate"	:	""
				,"pageSize"	:	10
				,"pageNo"	:	1
				,"sortBy"	: 	"MessageID desc"
			},
			success:function(data){
				albumBoard.render(data.list, caller, webpartID);
			}
		});
	},
	render: function(data, caller, webpartID) {
		var url = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&folderID="
			+ albumBoard.folderID +"&menuCode=BoardMain";
			
		$("#" + webpartID + " #contents_gallery_list").closest(".widget_card").find('.widget_more').attr("href", url);
		
		$.each(data, function(i, item) {
			$("#" + webpartID + " #contents_gallery_list ul")
			.append($("<li>")
				.append($("<a>", {"href":"#", "id":"albumData_" + item.MessageID})
					.append($("<img>", {"src" : Common.getThumbSrc("Board", item.FileID), "onerror" : "coviCmn.imgError(this,false)"}))
				)
			);
			
			$("#" + webpartID + " #albumData_" + item.MessageID).on("click", function() {
				albumBoard.goImageSlidePopup(item.MessageID, item.FolderID);
			});
		});

		coviUtil.webpartDrawEmpty(data, caller, webpartID, Common.getDic("msg_ComNoData"), url);
	},
	goImageSlidePopup : function(pMessageID, pFolderID) {
		var contextParam = String.format("&messageID={0}&serviceType={1}&objectID={2}&objectType={3}", pMessageID, "Board", pFolderID, 'FD');
		CFN_OpenWindow("/covicore/control/goImageSlidePopup.do?" + contextParam, Common.getDic("lbl_ImageSliderShow"),800,780,"");
	}
}