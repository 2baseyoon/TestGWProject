/**
 * myContents - 마이 컨텐츠 - 받은 메일
 */
var ctnReceiveMail ={
	
	init: function (data, ext, caller, webPartID){ 
		if(coviUtil.getAssignedBizSection("Mail")) {	 	
			ctnReceiveMail.getAjaxMailList(caller, webPartID, Common.getSession("UR_Mail"));
		}
	},
	// 메일  팝업 표시
	showView: function(clickObj, mailId, folderTy, uid){
		var _query = "/mail/userMail/goMailWindowPopup.do?";
		var _queryParam = {
			messageId: mailId.replace("%3C", "<").replace("%3E", ">"),
			folderNm: folderTy,
			viewType: "LST",
			sort: "",
			uid: uid,
			userMail: sessionObj["UR_Mail"],
			inputUserId: sessionObj["DN_Code"] + "_" + sessionObj["UR_Code"],
			popup: "Y",
			CLSYS: "mail",
			isSendMail: undefined,
			callType: "WebPart"
		};
		_query += $(_queryParam).serializeQuery();
		
		var mailWin = window.open(_query, "Mail Read" + stringGen(10), "height=700, width=1000");
		mailWin.onload = function() {
			if($(clickObj).parent("li").hasClass("mailunread")){
				myContents_MailBox.getMailList();
			}
		};
	},	
	
	//메일 작성 팝업 표시
	link: function( ) {
		var _query = "/mail/userMail/goMailWindowWritePopup.do?";
		var _queryParam = {
			userMail: sessionObj["UR_Mail"],
			inputUserId: sessionObj["DN_Code"] + "_" + sessionObj["UR_Code"],
			popup: "Y",
			CLSYS: "mail",
			callType: "WebPart"
		};
		_query += $(_queryParam).serializeQuery();
		
		return _query;
		
				
	},
	//ajax 메일리스트 호출
	getAjaxMailList : function(caller, webPartID, userMail) {
			var $_wdg_content = $("#"+webPartID).find(".widget_content");
		if (gMailList != null){
			let result = gMailList;
			$.each(result[0].mailList, function(i, item) {
				var mailReceivedDateStr = item.mailReceivedDateStr.split(" ")[0].replaceAll("-", ".");
				var liClass = item.flag.indexOf("\\Seen") > -1 ? "post_item read" : "post_item";
				$_wdg_content.find("ul").append( $("<li>")
					.append($("<a>", {"class" : liClass, "href":"#"} )
						.append($("<strong>", {"class" : "item_title", "text" : item.subject.replace(/&#39;/gi, "\'") } ))
						.append($("<span>", {"class" : "item_user", "text" : item.mailSender } ))
						.append($("<time>", {"class" : "item_date", "text" : mailReceivedDateStr } ))
					
					 	).on("click", function(){
							ctnReceiveMail.showView(this,item.mailId.replace(/\\n|\n/ig, ''),item.folder_path,item.uid);
						})					
					);
				if(i >= 4) return false;
			});
			if(result[0].mailList == null || result[0].mailList.length == 0) {
				var _query = "/mail/userMail/goMailWindowWritePopup.do?";
				var _queryParam = {
					userMail: sessionObj["UR_Mail"],
					inputUserId: sessionObj["DN_Code"] + "_" + sessionObj["UR_Code"],
					popup: "Y",
					CLSYS: "mail",
					callType: "WebPart"
				};
				_query += $(_queryParam).serializeQuery();
				coviUtil.webpartDrawEmptyToMail(result[0].mailList, caller, webPartID, Common.getDic("lbl_NoMailList"), _query);
			}	
		}else{
			setTimeout(ctnReceiveMail.getAjaxMailList,500,caller, webPartID, userMail); // 메일함 다시 조회
			/*		
			var params = JSON.stringify({
				"userMail" : userMail,
				"mailBox" : "INBOX",
				"page" : 1,
				"type" : "MAILLIST",
				"type2" : "ALL",
				"viewNum" : 5,
				"sortType" : "A"
			});
			
			$.ajax({
				type:"POST",
				contentType: 'application/json',
				url: "/mail/userMail/selectWebPartUserMail.do",
				data: params,
				success:function(result){
					$.each(result[0].mailList, function(i, item) {
						var mailReceivedDateStr = item.mailReceivedDateStr.split(" ")[0].replaceAll("-", ".");
						var liClass = item.flag.indexOf("\\Seen") > -1 ? "post_item read" : "post_item";
						$_wdg_content.find("ul").append( $("<li>")
							.append($("<a>", {"class" : liClass, "href":"#"} )
								.append($("<strong>", {"class" : "item_title", "text" : item.subject.replace(/&#39;/gi, "\'") } ))
								.append($("<span>", {"class" : "item_user", "text" : item.mailSender } ))
								.append($("<time>", {"class" : "item_date", "text" : mailReceivedDateStr } ))
							
							 	).on("click", function(){
									ctnReceiveMail.showView(this,item.mailId.replace(/\\n|\n/ig, ''),item.folder_path,item.uid);
								})					
							)
					});
					if(result[0].mailList == null || result[0].mailList.length == 0) {
						var _query = "/mail/userMail/goMailWindowWritePopup.do?";
						var _queryParam = {
							userMail: sessionObj["UR_Mail"],
							inputUserId: sessionObj["DN_Code"] + "_" + sessionObj["UR_Code"],
							popup: "Y",
							CLSYS: "mail",
							callType: "WebPart"
						};
						_query += $(_queryParam).serializeQuery();
						coviUtil.webpartDrawEmptyToMail(result[0].mailList, caller, webPartID, Common.getDic("lbl_NoMailList"), _query);
					}
				}
			});
			*/
		}
	}
}
