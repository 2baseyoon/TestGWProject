/**
 * popupFeed - 팝업 공지
 */
var popupFeed ={
	webpartType: '',
	period : 4,
	init: function (data,ext){
		this.setAclEventFolderData();
	},
	
	setAclEventFolderData : function(){
		$.ajax({
		    url: "/feed/user/getACLFolder.do",
		    type: "POST",
		    data: {},
		    async: false,
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		if(res.cnt > 0) {
		    			popupFeed.getShareFeedCount();
		    		}
		    	}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/resource/getACLFolder.do", response, status, error);
			}
		});
	},
	
	getShareFeedCount: function(){
		$.ajax({
			type:"POST",
			url:"/feed/user/selectShareFeedCount.do",
			success:function(data){
				if(data.status == "SUCCESS"){
					if(data.cnt > 0){
						popupFeed.goViewPopup();
					}	
				} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");
				}
			},
			error:function(res, status, error){
				CFN_ErrorAjax("/feed/user/selectShareFeedCount.do", res, status, error);
			}
		});
	},
	
	goViewPopup: function() {
		if (coviCmn.getCookie("POPUPLIMIT_FEED") == "") {
			var url = "/feed/user/goFeedListPopup.do?CLSYS=feed&CLMD=user&CLBIZ=Feed&feedType=Share&viewType=Popup";
			Common.open("", "FeedListPopup", "<spring:message code='Cache.lbl_ShareFeed'/>", url, (window.innerWidth - 500), (window.innerHeight - 100), "iframe", true, null, null, true);
			var sDivID = "FeedListPopup";
			var html = '';
			html =  '<div class="pro_today_x" data-msg="feed">';
			html += '	<a data-period="'+this.period+'">';
			html += '		<p class="pro_today_btn" style="float:right;">' + String.format("<spring:message code='Cache.msg_DoNotOpenWindowHours'/>", this.period) + '</p>';
			html += '	</a>';
			html += '</div>';
			
			$("#" + sDivID + "_pc").parent().append(html);
		}
		
		// 팝업 닫을 날짜를 설정
		$("#" + sDivID + "_p .pro_today_x a").on("click", function() {
			let pStrMsgID = $(this).closest(".pro_today_x").attr("data-msg");
			let period =  $(this).attr("data-period");
		    coviCmn.setCookie("POPUPLIMIT_FEED", pStrMsgID, parseFloat(period/24));
		    Common.Close("FeedListPopup");
		});
		
		//윈도우 팝업 버튼
		$("#FeedListPopup_LayertoWindow").show();
	}
}