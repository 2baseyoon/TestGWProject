var SystemMailCall = {
	init:function() {
		if(coviUtil.getAssignedBizSection("Mail")) { //속도개선
			var params = JSON.stringify({
				"userMail" : Common.getSession("UR_Mail"),
				"mailBox" : "INBOX",
				"page" : 1,
				"type" : "MAILLIST",
				"type2" : "ALL",
				"viewNum" : 10,//6
				"sortType" : "A"
			});
		
			$.ajax({
				url: "/groupware/longpolling/getMailCnt.do",
				type:"post",
				data:{},
				success:function (data) {
					if(data.status == "SUCCESS") {
						gPortalMailCount = data.MailCnt;
						gSystemMailCall = true;
					}
				}
			});
			
			$.ajax({
				type:"POST",
				contentType: 'application/json',
				url: "/mail/userMail/selectWebPartUserMail.do",
				data: params,
				success:function(result){
					gMailList = result;
				}
			});
		}		
	}
}