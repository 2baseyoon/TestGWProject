/**
 * myContents - 마이 컨텐츠 - 자유 게시
 */
var smartAlert ={
	
	init: function (data, ext, caller, webPartID){
		let preId = webPartID!=undefined?"#"+webPartID+" ":"";
		$(preId + " #smartAlert_Nm").text(Common.getSession("USERNAME")+"님 안녕하세요~");
		var dataAlert = data[0];
		if (coviUtil.isMobile()){
			$(preId + " .alert").append("현재 읽지 않은 메일이 ")
								.append($("<span>")
									.append($("<a>",{"text":dataAlert[0]["Mail"]+"건","href":"javascript: mobile_comm_go('/mail/mobile/mail/List.do')"}))
								.append(" 있습니다.")
								);
		}else{
			$(preId + ".widget_card").closest(".grid_item").addClass("x2");
			$(preId + " .alert").append("현재 읽지 않은 메일이 ")
								.append($("<a>",{"text":dataAlert[0]["Mail"]+"건","href":"/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail"}))
								.append(" 있습니다.");
		}
	}
}
