var webhard = {
	init : function(data, ext) {
		var item = data[0][0];
		
		var maxSizeGB = parseInt(item.BOX_MAX_SIZE / 1024);
		var currentSizeGB = item.BOX_CURRENT_SIZE;
		
		var percent = (currentSizeGB / 1024) / maxSizeGB * 100;

		var webhardUrl = "/webhard/layout/user_BoxList.do?CLSYS=webhard&CLMD=user&CLBIZ=Webhard&boxID="
						+ item.UUID + "&folderID=&folderType=Normal";
						
		var expressionNow = (currentSizeGB / 1024).toFixed(1);
		expressionNow = expressionNow == 0.0 ? 0 : expressionNow;
		
		// 웹하드 드라이브 용량 상태 html
		$("#webhard_progress")
			.append($("<div>", {"class" : "widget_progress"})
				.append($("<div>", {"class" : "bar", "style" : "width:" + percent +"%;max-width:100%;"}))
			)
			.append($("<div>", {"class" : "info"})
				.append($("<dl>")
					.append($("<dt>", {"text" : "현재"}))
					.append($("<dd>", {"text" : expressionNow + "GB"}))
				)
				.append($("<dl>")
					.append($("<dt>", {"text" : "최대"}))
					.append($("<dd>", {"text" : maxSizeGB + "GB"}))
				)
			);
		// 웹하드 포탈로 이동
		if(!coviUtil.isMobile()){//PC
			$("#webhard_progress").closest(".widget_card").find('.widget_more').attr("href", webhardUrl);
		}
	}
}