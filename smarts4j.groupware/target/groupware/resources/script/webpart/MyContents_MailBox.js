/**
 * myContents - 마이 컨텐츠 - 받은메일
 */
var myContents_MailBox ={
	sessionObj:{},
	init: function (data,ext){
		myContents_MailBox.getMailList();
	},
	// 받은 메일 조회
	getMailList : function() {
		var sessionObj = Common.getSession();
		
		if (Common.getBaseConfig("isUseMail") != "Y" || sessionObj["UR_Mail"] == ""){
			myContents_MailBox.emptyList();
		}else{
			var params = JSON.stringify({
				"userMail" : sessionObj["UR_Mail"],   			//  메일계정
				"mailBox" : "INBOX",                            //  받은 메일함
				"page" : 1,                                     //  페이지(Default)
				"type" : "MAILLIST",                            //  Default
				"type2" : "ALL",                                //  읽음구분(전체)
				"viewNum" : 4,                   				//  메일갯수
				"sortType" : "A"                                //  정렬순서(내림차순 A, 오름차순 RA)
			});		
			
			$.ajax({
				type:"POST",
				contentType: 'application/json',
				url: "/mail/userMail/selectUserMail.do",
				data: params,
				success:function(data){
					var listData = data[0].mailList;
					if(listData.length > 0){
						var sHtml='';
						for(var i=0; i<listData.length; i++){
							var liClass =  "mailunread";
							var receivedDate = listData[i].mailReceivedDateStr.split(" ")[0].replaceAll("-", ".");
							var imgClass = "ic_w_mailunread";
							
							if(listData[i].flag.indexOf("\\Seen") > -1 ){
								liClass = "mailread"
								imgClass = "ic_w_mailread";
							}
							
							sHtml += '<li class="' + liClass + '">';
							sHtml +=	'<a href="#" onclick=\'myContents_MailBox.showView(this,"'+listData[i].mailId.replace(/\\n|\n/ig, '')+'","'+listData[i].folder_path+'","'+listData[i].uid+'")\'>';
							sHtml +=		'<div class="MailCright">';
							sHtml +=			'<span  class="' + imgClass + '"></span>';
							sHtml +=		'</div>';
							sHtml +=		'<div class="MailCleft">';
							sHtml +=			'<p class="mailtop"><span class="mailname">' + listData[i].mailSender + '</span><span class="maildate">' + receivedDate + '</span></p>';
							sHtml +=			'<p class="mailtitle">'+ MailCommon.convertCode(listData[i].subject)+'</p>';
							sHtml +=		'</div>';
							sHtml +=	'</a>';
							sHtml +='</li>';
							
						}
						$("#myContents_MailBox_List").empty().html(sHtml);
					} else {
						myContents_MailBox.emptyList();
					}
				}
			});
			
		}
	},
	// 메일  팝업 표시
	showView:function(clickObj, mailId, folderTy, uid){
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
	// 목록 없음 표시
	emptyList:function(){
		myContents.emptyList("#myContents_MailBox_List");
	}
	
	
}


