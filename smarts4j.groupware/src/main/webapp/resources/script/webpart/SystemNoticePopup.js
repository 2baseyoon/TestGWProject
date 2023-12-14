var SystemNoticePopup = {
	init:function() {
		$.ajax({
			url:"/groupware/board/manage/checkSystemNotice.do",
			type:"GET",
			data:{},
			success:function(result) {
				if(result.status == "SUCCESS") {
					Common.open("","SystemNoticePopup",Common.getDic("lbl_Alram"),"/groupware/board/manage/goSystemNoticePopup.do","350px","150px","iframe",true,null,null,true);
					$("#SystemNoticePopup_p").css("z-Index", 1000);
				}
			}
		});
	}
}