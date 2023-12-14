/**
 * popupNotice - 팝업 공지
 */
var popupNotice ={
	webpartType: '',
	period : Common.getBaseConfig("PopupLimit_Portal"),
	init: function (data,ext){
		var $this = this;
		$this.getNoticeMessageList();
	},
	
	getNoticeMessageList: function(){
		var bizSection = "Board";
		var communityID = "";
		var params = { "bizSection": "Board" };
		
		if (CFN_GetQueryString("C") != "undefined") {
			params["bizSection"] = "Community";
			params["communityID"] = CFN_GetQueryString("C");
			
			bizSection = "Community";
			communityID = CFN_GetQueryString("C");
		}
		
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectPopupNoticeList.do",
			data: params,
			success:function(data){
				var listData = data.list;
				
				$.each(listData, function(i, item) {	//탭형태 웹파트 검색: 최근게시, 최근문서탭 추가
					popupNotice.goViewPopup(bizSection, item.Subject, item.MenuID, item.Version, item.FolderID, item.MessageID, communityID);
				});				
			}
		});
	},
	
	goViewPopup: function(pBizSection, pSubject, pMenuID, pVersion, pFolderID, pMessageID, pCommunityID) {
		if (coviCmn.getCookie("POPUPLIMIT_PORTAL_" + pMessageID) == "") {
			var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
			
			if(pCommunityID != null && pCommunityID != "" && pCommunityID != "undefined") {
				url += "&communityId="+pCommunityID
			}
			
			parent.Common.open("", "boardViewPop"+pMessageID, pSubject, url, "925px", "580px", "iframe", true, null, null, true);
			
			var sDivID = "boardViewPop" + pMessageID;
			var html = '';
			html =  '<div class="pro_today_x" data-msg="'+pMessageID+'">';
			html += '	<a data-period="1">';
			html += '		<p class="pro_today_btn" style="float:left;margin-left: 500px;">' + String.format("<spring:message code='Cache.msg_DoNotOpenWindow'/>", 1) + '</p>';
			html += '	</a>';
			html += '	<a data-period="'+this.period+'">';
			html += '		<p class="pro_today_btn" style="float:left;margin-left:10px">' + String.format("<spring:message code='Cache.msg_DoNotOpenWindow'/>", this.period) + '</p>';
			html += '	</a>';
			html += '</div>';
			
			$("#" + sDivID + "_pc").parent().append(html);
		}
		
		// 팝업 닫을 날짜를 설정
		$(".pro_today_x a").on("click", function() {
			let pStrMsgID = $(this).closest(".pro_today_x").attr("data-msg");
			let period =  $(this).attr("data-period");
		    coviCmn.setCookie("POPUPLIMIT_PORTAL_" + pStrMsgID, pStrMsgID, parseInt(period, 10));	    
		    Common.Close("boardViewPop"+pStrMsgID);
		});
	}
}