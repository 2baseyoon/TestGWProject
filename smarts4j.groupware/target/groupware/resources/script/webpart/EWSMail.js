/**
 * Exch 메일
 */
var ExchMail = {
	init: function(data, ext) {
		//메일 목록 API 호출
		ExchMail.setMailList();
	},
	mailLiHTML : '<li><a class="title" onclick="ExchMail.mailPopup(\'{0}\',\'{1}\'); return false;">{2}{3}</a><span class="name">{4}</span><span class="date">{5}</span></li>',
	setMoreURL:function(){
		var pDNCode = Common.getSession("DN_Code");
		var pEmpNo = Common.getSession("LogonID");
		var result = GetEncryptToken();
		
		// 메일 SLO URL // 기초코드 
		var MailSvcUrl = Common.getBaseConfig("Exch_mailSvcUrl") + Common.getBaseConfig("Exch_MailServerSLOUrl");
		
		var MailListUrl = "";
		var qMenu = Common.getBaseCode("QuickNotification");
		
		$(qMenu.CacheData).each(function(idx, obj){
			if(obj.Code == "Mail"){
				MailListUrl =obj.Reserved1;
			}
		});
		window.open(MailSvcUrl+"?ReturnUrl="+MailListUrl+"&token="+result, '_blank');
	},
	setMailList:function(){
		$.ajax({
				type : "POST",
				header:{"Content-Type":"application/json"},
				data : {
					"PageCount":4
					},
				url : '/groupware/portal/getMailList.do',
				success : function(data) {
					var LIsHTML = '';
					var ul  = document.querySelector('#ExchMail');
					if(data.data && data.data.length > 0){
						data.data.forEach(function(mail,i){
							var mailIsRead = mail.IsRead === 'Y' ? '': '<span class="cycleNew new">N</span>';
							var receiveDate = mail.DateReceive;
							
							LIsHTML += String.format(ExchMail.mailLiHTML
									,mail.mid
									,mail.mck
									,mailIsRead
									,mail.Subject
									,mail.FromName
									,receiveDate
							);
						});
					}
					ul.innerHTML = LIsHTML;
				},
				error : function(response, status, error) {
					console.error(response,status,error);
				}
			});
	},
	mailPopup:function(mid,mck){
		// 메일 SLO URL // 기초코드 
		var MailSvcUrl = Common.getBaseConfig("Exch_mailSvcUrl") + Common.getBaseConfig("Exch_MailServerSLOUrl");
		
		var token = GetEncryptToken();
		var urlValue = "/WebSite/Mail/MailView_WindowPop.aspx?system=Mail&mid="+mid+"&mck="+mck;
		urlValue = encodeURIComponent(urlValue);
		var LinkUrl = MailSvcUrl + "?ReturnUrl=" + urlValue +"&Token="+token;
		//CFN_OpenWindow(LinkUrl,"",850,700,"fix");
		window.open(LinkUrl,'_blank', 'width=850, height=700');
	}
}