/**
 * mailList - 메일
 */
var mailList = {
	config: {
		pageSize: 5
	},
	data: {},
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		this.getList();
	},
	setEmpty: function(){
		$("#wp_mailList [data-role=result]").hide();
		$("#wp_mailList [data-role=no-result]").show();
	},
	getList: function(){
		if (Common.getBaseConfig("isUseMail") != "Y" || Common.getSession("UR_Mail") == ""){
			mailList.setEmpty();
		} else {
			var params = JSON.stringify({
				"userMail" : Common.getSession("UR_Mail"),   	//  메일계정
				"mailBox" : "INBOX",                            //  받은 메일함
				"page" : 1,                                     //  페이지(Default)
				"type" : "MAILLIST",                            //  Default
				"type2" : "ALL",                                //  읽음구분(전체)
				"viewNum" : mailList.config.pageSize,	//  메일갯수
				"sortType" : "A"                                //  정렬순서(내림차순 A, 오름차순 RA)
			});		
			
			$.ajax({
				type:"POST",
				contentType: 'application/json',
				url: "/mail/userMail/selectUserMail.do",
				data: params,
				success:function(data){
					mailList.data = data[0].mailList;
				}
			}).done(function(){
				if (typeof mailList.data == 'undefined' || (typeof mailList.data == 'object' && Object.keys(mailList.data) == 0)){
					mailList.setEmpty();
				} else {
					mailList.renderList();
				}
			});
		}
	},
	renderList: function(){
		$("#mailList_list").empty();
		$.each(mailList.data, function(idx, el){	
			var listHTML = $("#tempalte_mailList_item").html()
				.replace('{index}', idx)
				.replace('{title}', (el.flag == "\\Seen") ? el.subject : $("#tempalte_mail_new").html().replace('{title}', el.subject))
				.replace('{name}', CFN_GetDicInfo(el.mailSender))
				.replace('{date}', new Date(el.mailReceivedDateStr).format('MM.dd'));
				
			$("#mailList_list").append(listHTML);
		});
	},
	goMore: function(){
		location.href = '/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail';
	},
	goView: function(target){
		var targetIndex = $(target).attr("data-index");
		var targetData = mailList.data[targetIndex];
		
		var url = "/mail/userMail/goMailWindowPopup.do";

		var _queryParam = {
			messageId: targetData.mailId.replace("%3C", "<").replace("%3E", ">"),
			folderNm: targetData.folderTy,
			viewType: "LST",
			sort: "",
			uid: targetData.uid,
			userMail: Common.getSession('UR_Mail'),
			inputUserId: Common.getSession('DN_Code') + "_" + Common.getSession('UR_Code'),
			popup: "Y",
			CLSYS: "mail",
			isSendMail: undefined,
			callType: "WebPart"
		};
		url += '?' + $(_queryParam).serializeQuery();
		
		var popupTitle = "Mail Read" + stringGen(10);
		window.open(url, popupTitle, "height=700,width=1000");
		
		$("#mailList_list a[data-index="+targetIndex+"]").html(mailList.data[targetIndex].subject);
	}
}

