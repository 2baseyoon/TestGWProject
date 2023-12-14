/**
 * 위젯 - 받은메일
 */
var widgetMailBox ={
	init: function (data, ext, caller, webPartID){
		var userMail = "";
		if(coviUtil.isMobile()){
			$("#widgetMailBoxCnt").attr("href", "/mail/mobile/mail/List.do");
			userMail = mobile_comm_getSession("UR_Mail")
		}else{
			$("#widgetMailBoxCnt").attr("href", "/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail");
			userMail = Common.getSession("UR_Mail");
		}
		widgetMailBox.getAjaxMailList(caller, webPartID, userMail);
		widgetMailBox.getMailCnt(webPartID); // 메일 count ajax 호출로 변경
	},
		
	// 메일  팝업 표시 (PC)
	showView:function(clickObj, mailId, folderTy, uid){
		var _query = "/mail/userMail/goMailWindowPopup.do?";
		var _queryParam = {
			messageId: mailId.replace("%3C", "<").replace("%3E", ">"),
			folderNm: folderTy,
			viewType: "LST",
			sort: "",
			uid: uid,
			userMail: Common.getSession("UR_Mail"),  
			inputUserId: Common.getSession("DN_Code") + "_" + Common.getSession("UR_Code"),
			popup: "Y",
			CLSYS: "mail",
			isSendMail: undefined,
			callType: "WebPart"
		};
		
		//_query += $(_queryParam).serializeQuery();
		_query += Object.entries(_queryParam).map( ([key,value]) => ( value && key+'='+value )).filter(v=>v).join('&');
		
		var mailWin = window.open(_query, "Mail Read" + widgetMailBox.stringGen(10), "height=700, width=1000");
		mailWin.onload = function() {
			if($(clickObj).parent("li").hasClass("mailunread")){
				widgetMailBox.init();
			}
		};
	},
	stringGen : function(len) {
	    var text = "";
	    var charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	    for( var i=0; i < len; i++ )
	        text += charset.charAt(Math.floor(coviCmn.random() * charset.length));
	
	    return text;
	},
	getAjaxMailList : function(caller, webPartID, userMail) {
		if(coviUtil.getAssignedBizSection("Mail")) { 		
				if (gMailList != null){
					let result = gMailList;
					$.each(result[0].mailList, function(i, item) {
						var liClass = item.flag.indexOf("\\Seen") > -1 ? "post_item read" : "post_item";
						$("#widgetMailBox ul").append(
								$("<li>").append($("<a>",{"href":"#","class":liClass, "data-uid":item.uid, "data-messageid":item.mailId, 
									"data-mailbox":"INBOX", "data-foldertype":item.folder_path, "data-references":""})
										.append($("<strong>",{"class":"item_title","text":item.subject.replace(/&#39;/gi, "\'")}))
										).on("click", function(){
											if (!coviUtil.isMobile()){
												widgetMailBox.showView(this,item.mailId.replace(/\\n|\n/ig, ''),item.folder_path,item.uid);
											} else {
												mobile_portal_MailReadPageGo(this.firstChild);
											}
			
										}));
						if(!coviUtil.isMobile()){
							if(i >= 4) return false;
						}else{
							if(i >= 5) return false;
						}
					});
					coviUtil.webpartDrawEmpty(result[0].mailList, caller, webPartID, Common.getDic("lbl_NoMailList"), "");			
				}else{
					setTimeout(widgetMailBox.getAjaxMailList,500,caller, webPartID, userMail); // 메일함 다시 조회		
				}
		}
	},
	getMailCnt:function (webpartID){
		if(gSystemMailCall === true && gPortalMailCount > 0){		
			var $con = $("#"+webpartID+" #widgetMailBoxCnt");
	    	$con.find('em').text(coviUtil.showCntOver(gPortalMailCount, 99));
    	}else{
			setTimeout(widgetMailBox.getMailCnt,500,webpartID); // 메일함 다시 조회
			/*		
			$.ajax({
				url: "/groupware/longpolling/getMailCnt.do",
				type:"post",
				data:{},
				success:function (data) {
					if(data.status == "SUCCESS") {
						var $con = $("#"+webpartID+" #widgetMailBoxCnt");
				    	$con.find('em').text(coviUtil.showCntOver(data.MailCnt, 99));
					}
				}
			});
			*/
		}
	}
}