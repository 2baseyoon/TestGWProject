/**
 * 
 */

var wpNotice = {
	config: {
		pageSize: 5,
		noticeURL: "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&CLBIZ=Board&menuCode=BoardMain&folderID={0}",
		noticeFolderID: Common.getBaseConfig("WebpartNotice")
	},
	data: [],
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		if (this.config.noticeFolderID != '') {
			$("#moreNotice").show();
		}
		
		this.getList();
	},
	getList: function() { 	// 공지사항 불러오기.	
		var url = "/groupware/board/selectNoticeMessageList.do";
		$.ajax({
			type: "POST",
			url: url,
			data: {
				pageSize: wpNotice.config.pageSize,
				isWebpart: 'Y'
			}, 
			success: function(data) {
				if (data.status === "SUCCESS") {
					wpNotice.data = data.list;
				}
			},
			error: function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		}).done(function(){
			wpNotice.render();
		});
	},
	render: function(){
		$.each(wpNotice.data, function(idx, el){
			var listHTML = $("#tempalte_notice_item").html()
				.replace('{index}', idx)
				.replace('{title}', el.Subject)
				.replace('{name}', el.CreatorName)
				.replace('{date}', new Date(el.CreateDate).format('MM.dd'));
				
			$("#notice_list").append(listHTML);
		});
		if (wpNotice.data.length < 1){
			$("#wp_notice [data-role=result]").hide();
			$("#wp_notice [data-role=no-result]").show();
		}
	},
	goMore: function(){
		location.href = String.format(this.config.noticeURL, this.config.noticeFolderID);
	},
	viewPopup: function(target){
		var targetIndex = $(target).attr('data-index');
		var targetData = this.data[targetIndex];
		
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ=Board&menuID={0}&version={1}&folderID={2}&messageID={3}&viewType=Popup", 
						targetData.MenuID, targetData.Version, targetData.FolderID, targetData.MessageID);
		Common.open("", "boardViewPop", Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
	}
}