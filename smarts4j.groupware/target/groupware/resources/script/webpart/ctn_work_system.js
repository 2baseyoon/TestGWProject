var workSystem = {
	type: "",
	init: function(data, ext, caller, webpartID) {
		workSystem.type = ext.baseCode == "" ? "board" : ext.baseCode;

		if (caller == "Widget" && coviUtil.isMobile()){			
			$("#"+webpartID).find(".widget_more").remove();
		}
				
		if(workSystem.type == "board") { // baseCode 값이 없는 경우, 게시판 참조		
			const sessionObj = Common.getSession();
			
			if(sessionObj["isAdmin"] === "Y" || sessionObj["isEasyAdmin"] === "Y") {
				$("#" + webpartID + " .widget_option").append(
					$("<button>", {"type":"button", "data-action":"setting"}).append($("<span>", {"text" : "설정"}))
				);
				
				$("#" + webpartID + " .widget_option [data-action='setting']").on("click", function() {
					$("#" + webpartID + " .layer_divpop").attr("hidden", false);
				});
				
				$("#" + webpartID + " .layer_divpop .divpop_close, " + "#" + webpartID + " .layer_divpop #close_popup").on("click", function() {
					$("#" + webpartID + " .layer_divpop").attr("hidden", true);
				});
							
				workSystem.setSelectBox(data[0], caller, webpartID);
			}

			workSystem.setData(Common.getBaseConfig("WebpartLinkBoard"), caller, webpartID);
			
		} else { // baseCode 값이 있는 경우, SiteLinkList, SystemLinkList, MobileLinkList
			var linkList = Common.getBaseCode(ext.baseCode).CacheData;
			workSystem.render(webpartID, caller, linkList);
		}
	},
	render: function(webpartID, caller, data) {
		var $targetCntnsDiv = $("#" +webpartID + " .swiper");
		
		var offset = !coviUtil.isMobile() ? 6 : 4;

		$.each(data, function(i, item) {
			var page = "workSystemPage" + (parseInt(i / offset) + 1).toString();
			
			if(i % offset == 0) {
				$targetCntnsDiv
				.append($("<div>", {"class" : "swiper-slide"})
					.append($("<div>", {"class" : "link", "name" : page}))
				);
			}
			
			//URL 체크-@@ 있으면 기초설정값(BC)에서 조회//@@BC|workSystem_QuickLink_MenuID&@@BC|workSystem_QuickLink_FolderID
			if(!coviUtil.isMobile()){
				if(item.Reserved1.indexOf("@@") > -1) {
					try {
						var arrURL = item.Reserved1.split('@@');
						for(var i = 0; i < arrURL.length; i++) {
							if(arrURL[i] != '' && arrURL[i].indexOf('BC|') > -1) {
								var key = arrURL[i].split('BC|')[1];
								key = key.split('&')[0];
								item.Reserved1 = item.Reserved1.replace('@@BC|' + key, Common.getBaseConfig(key));
							}
						}
					} catch(e) {
						coviCmn.traceLog(e);
					}
				}
			}else{
				if(item.Reserved2.indexOf("@@") > -1) {
					try {
						var arrURL = item.Reserved2.split('@@');
						for(var i = 0; i < arrURL.length; i++) {
							if(arrURL[i] != '' && arrURL[i].indexOf('BC|') > -1) {
								var key = arrURL[i].split('BC|')[1];
								key = key.split('&')[0];
								item.Reserved2 = item.Reserved2.replace('@@BC|' + key, mobile_comm_getBaseConfig(key));
							}
						}
					} catch(e) {
						mobile_comm_log(e);
					}
				}
			}
			
			$targetCntnsDiv.find("div[name=" + page + "]")
			.append($("<a>", {"href" : !coviUtil.isMobile() ? item.Reserved1 : item.Reserved2, "class" : item.Reserved3})
				.append($("<span>", {"text" : CFN_GetDicInfo(item.MultiCodeName)}))
			);
		});
		
		if(workSystem.type == "board") {
			var url = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&folderID="
			+ $("#" + webpartID + " #linkFolderSelect option:selected").val() +"&menuCode=BoardMain";;
			
			coviUtil.webpartDrawEmpty(data, caller, webpartID, Common.getDic("msg_ComNoData"), url);
		} else {
			coviUtil.webpartDrawEmpty(data, caller, webpartID, Common.getDic("msg_ComNoData"));
		}
	},
	setSelectBox: function(data, caller, webpartID) {
		
		$.each(data, function(idx, item) {
			if($("#" + webpartID + " #linkFolderSelect optgroup[name=optgrp_" + item.GroupValue + "]").length == 0) {
				$("#" + webpartID + " #linkFolderSelect").append($("<optgroup>", {"label" : item.GroupText, "name" : "optgrp_" + item.GroupValue}));
			}
			
			if(Common.getBaseConfig("WebpartLinkBoard") == item.FolderID) {
				$("#" + webpartID + " #webpartLinkBoardName").text(item.DisplayName);
			}
			
			$("#" + webpartID + " #linkFolderSelect optgroup[name=optgrp_" + item.GroupValue + "]").append($("<option>", {"value":item.FolderID, "text":item.DisplayName}));
		});

		$("#" + webpartID + " #linkFolderSelect").on("change", function() {
			workSystem.setData($("#" + webpartID + " #linkFolderSelect option:selected").val(), caller, webpartID);
		});
		
		$("#" + webpartID + " #saveLinkFolderID").on("click", function() {
			var params = {
				"settingKey":"WebpartLinkBoard", "settingVal":$("#" + webpartID + " #linkFolderSelect option:selected").val()
			};
			
			$.ajax({
				type:"POST",
				contentType: "application/json",
				url:"/groupware/portal/updateSettingKey.do",
				data:JSON.stringify(params),
				async:false,
				success: function(res) {
					coviCmn.reloadCache("BASECONFIG", sessionObj.DN_ID);

					workSystem.setData(Common.getBaseConfig("WebpartLinkBoard"), caller, webpartID);
				}
			});
		});
	},
	setData: function(folderID, caller, webpartID) {
		$("#" + webpartID + " .widget_content," + "#" + webpartID + " .widget_empty").remove();
		
		$("#" + webpartID + " .widget_card").append(
				$("<div>", {"class" : "widget_content", "id":"work_system_list"}).append($("<div>", {"class" : "swiper work_system_swiper"}))
			);
		
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectMessageGridList.do",
			data: {
				"boardType"	:	"Normal"
				,"bizSection":	"Board"
				,"folderID"	:	Common.getBaseConfig("WebpartLinkBoard")
				,"folderType":	"LinkSite"
				,"viewType"	: 	""
				,"startDate": 	""
				,"endDate"	:	""
				,"pageSize"	:	10
				,"pageNo"	:	1
				,"sortBy"	: 	"MessageID desc"
			},
			success:function(data){
				var linkList = [];
			
				$.each(data.list, function(idx, item) {
					var obj = {};
					obj["MultiCodeName"] = item.Subject;
					obj["Reserved1"] = item.LinkURL;
					obj["Reserved2"] = item.Reserved1;
					obj["Reserved3"] = "i1";
					
					linkList.push(obj);
				});
				
				workSystem.render(webpartID, caller, linkList);
			}
		});
	}
}