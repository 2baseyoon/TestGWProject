/**
 * approvalBox - 전자결재 - 결재함
 */
var ceoMailBox ={
		webpartType: '', 
		UR_Mail : Common.getSession("UR_Mail"),
		DN_Code : Common.getSession("DN_Code"),
		UserCode: Common.getSession("UR_Code"),
		init: function (data,ext){
			var opts = {"mailBox":"ALL","page":1, type: "MAILLIST","type2":"NSL","viewNum":3,"sortType":""};
			if (Common.getSession("UR_Mail") == "")
			{
				$("#ceoMail .ProjectCEO_none").show();
				return;
			}
			$("#ceoMail .ProjectCEO_CEOrebtn").attr("href", ext.mailURL);
			
			MessageAPI.getList( Common.getSession("UR_Mail"),opts ).done(function(data) {

				if (data.length == 0 || data[0]["mailList"].length == undefined || data[0]["mailList"].length ==0) $("#ceoMail .ProjectCEO_none").show();
				
				if (data[0]["mailListLength"] > 99) $("#ceoMail .eAPcountStyle").text("99+");
				else	$("#ceoMail .eAPcountStyle").text(data[0]["mailListLength"]);

				$.each( data[0]["mailList"], function(idx, value) {
					$("#ceoMail .ProjectCEO_Scroll .List").append('<li>'+
							'<div class="listShell">'+
							'	<a class="listcon_link ui-link" onclick="ceoMailBox.ShowView(\''+value.mailId+'\',\''+ MailCommon.convertCode(value.folderTy)+'\','+value.uid+')">'+
							'		<div class="'+(value.flag=='\\Seen'?'mailimg_listunread':'mailimg_listread')+'"></div>'+
							'		<div class="listCleft">'+
							'			<p class="name_unread">'+value.mailSender+'</p>'+
							'			<p class="title_unread">'+value.subject+'</p>'+
							'		</div>'+
							'	</a>'+
							'	<a class="bookmark_link ui-link">'+
							'		<div class="listCright">'+
							'			<span class="date">'+value.sent_date.substring(5,16).replace('-','.')+'</span>'+
							'		</div>'+
							'	</a>'+
							'</div>'+
						'</li>');
				});
	        });;
		},
		ShowView:function(mailId, folderTy, uid){
			var _query = "/mail/userMail/goMailWindowPopup.do?";
			var _queryParam = {
				messageId: mailId.replace("%3C", "<").replace("%3E", ">"),
				folderNm: folderTy,
				viewType: "LST",
				sort: "",
				uid: uid,
				userMail: ceoMailBox.UR_Mail,
				inputUserId: ceoMailBox.DN_Code + "_" + ceoMailBox.UserCode,
				popup: "Y",
				CLSYS: "mail",
				isSendMail: undefined
			};
			_query += $(_queryParam).serializeQuery();
			window.open(_query, "Mail Read" + stringGen(10), "height=700, width=1000");

		}
}

