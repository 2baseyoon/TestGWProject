var systemShortcut = {
	data:[],
	drawDesign:function() { //html 그려주는 함수
		$("#contents_system_link").append($("<div>", {"data-custom-scrollbar":"", "data-simplebar":"init"})
			.append($("<div>", {"class":"simplebar-wrapper", "style":"margin: 0px;"})
				.append($("<div>", {"class":"simplebar-height-auto-observer-wrapper"})
					.append($("<div>", {"class":"simplebar-height-auto-observer"}))
				)
				.append($("<div>", {"class":"simplebar-mask"})
					.append($("<div>", {"class":"simplebar-offset", "style":"right: 0px; bottom: 0px;"})
						.append($("<div>", {"class":"simplebar-content-wrapper", "tabindex":"0", "role":"region", "aria-label":"scrollable content", "style":"height: 100%; overflow: hidden scroll;"})
							.append($("<div>", {"class":"simplebar-content", "style":"padding: 0px;"})
								.append($("<ul>", {"id":"systemShortcutList","class":"content_list"}))							
							)
						)
					)
				)
				.append($("<div>", {"class":"simplebar-placeholder", "style":"width: auto; height: 238px;"}))
			)
		);
		
		return;
	},
	setData: function() {
		$.ajax({
			url: "/groupware/pnPortal/selectSiteLinkWebpartList.do",
			type: "POST",
			async: false,
			success:function(res) {
				systemShortcut.data = res.list;
			}
		});
	},
	init: function(data, ext, caller, webpartID) {
		systemShortcut.data = data[0];
		
		$("#" + webpartID + " .widget_option [data-action=setting]").on("click", function() {
			Common.open("", "SiteLink", "<spring:message code='Cache.lbl_SiteLink'/>", "/groupware/pnPortal/goSiteLinkListPopup.do?" +
				"returnMode=Personal&popupID=SiteLink", "500px", "500px", "iframe", true, null, null, true); // 사이트링크
		}); // option > 설정 버튼 이벤트
		
		window.addEventListener('message', function(e) {
			if(e.data.functionName == "systemShortcut") {
				systemShortcut.render(caller, webpartID);
			}
		});
		
		systemShortcut.render(caller, webpartID);
	},
	render: function(caller, webpartID) {
		
		$("#" + webpartID + " .widget_content, " + " #" + webpartID + " .widget_empty").remove();
		
		$("#" + webpartID + " .widget_card").append(
			$("<div>", {"class" : "widget_content", "id":"contents_system_link"})
		);
		
		systemShortcut.setData();
		
		if( systemShortcut.data.length > 0) {
			systemShortcut.drawDesign(); //html 그려주는 함수
			
			$.each(systemShortcut.data, function(idx, item) {
				$("#" + webpartID + " #systemShortcutList").append($("<li>")
					.append($("<a>", {"href":item.SiteLinkURL, "class":"post_item" , "target" : "_blank"})
						.append($("<strong>", {"class":"item_title", "text":item.SiteLinkName}))
					)
				);
			});
		}
		
		coviUtil.webpartDrawEmpty(systemShortcut.data, caller, webpartID, Common.getDic("msg_ComNoData"));
	}
}