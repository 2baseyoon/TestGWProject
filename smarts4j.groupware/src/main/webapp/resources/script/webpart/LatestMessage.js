/**
 * approvalAndMail - 전자결재/메일
 */
var wpLatestMessage = {
	config: {
		messageCount: 5,
		BoardMenuID: Common.getBaseConfig('BoardMenu'),
		DocMenuID: Common.getBaseConfig('DocMenu')
	},
	data: [],
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;

		$("#latestMessage_tab a:first").click();
	},
	getList: function(pMode){
		$.ajax({
			type: "POST",
			url: "/groupware/board/selectLatestMessageList.do",
			data: {
				bizSection: pMode,
				menuID: this.config[pMode+'MenuID'],
				messageCount: this.config.messageCount
			},
			success: function(data){
				wpLatestMessage.data = data.list;
			}
		}).done(function(){
			wpLatestMessage.render();
		});
	},
	changeTab: function(target) {
		this.config.currentTab = $(target).attr("data-role");
		$.each($("#latestMessage_tab [class*=tab_on]"), function(idx, el){
		    $(el).prop("class", $(el).prop("class").replace('on', 'off'));
		});
		
		$(target).prop("class", $(target).prop("class").replace('off', 'on'));
		
		this.getList(this.config.currentTab);
	},
	render: function(){
		$("#latestMessage_list").empty();
		$("#wp_latestMessage [data-role=result]").show();
		$("#wp_latestMessage [data-role=no-result]").hide();
		
		$.each(wpLatestMessage.data, function(idx, el){	
			var listHTML = $("#tempalte_latestMessage_item").html()
				.replace('{index}', idx)
				.replace('{title}', el.Subject)
				.replace('{name}', el.CreatorName)
				.replace('{date}', new Date(el.CreateDate).format('MM.dd'));
				
			$("#latestMessage_list").append(listHTML);
		});
		
		if (wpLatestMessage.data.length < 1){
			$("#wp_latestMessage [data-role=result]").hide();
			$("#wp_latestMessage [data-role=no-result]").show();
		}
	},
	goMore: function(){
		if (this.config.currentTab == 'Board'){
			location.href = '/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuCode=BoardMain';
		} else if (this.config.currentTab == 'Doc'){
			location.href = '/groupware/layout/board_BoardList.do?CLSYS=Doc&CLMD=user&CLBIZ=Doc&boardType=DocTotal&menuCode=DocMain'
		}
	},
	goView: function(target){
		var targetIndex = $(target).attr('data-index');
		var targetData = this.data[targetIndex];
		
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&CLMD=user&CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", 
						this.config.currentTab, targetData.MenuID, targetData.Version, targetData.FolderID, targetData.MessageID);
		Common.open("", "boardViewPop", Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
	}
}

