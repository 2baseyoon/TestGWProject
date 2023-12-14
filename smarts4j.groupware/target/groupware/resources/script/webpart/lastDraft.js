/**
 * wpLastDraft -  최근 결재 양식
 */
var wpLastDraft = {
	config: {
		type: 'lastDraft'
	},
	data: [],
	init: function (data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		$("#lastDraft_moreBtn").attr("href", "/approval/layout/approval_FormList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval");
		
		wpLastDraft.getList();
	},
	getList: function(){
		var url = (wpLastDraft.config.type == 'favorite') ? '/approval/user/getFavoriteUsedFormListData.do' : '/groupware/pnPortal/selectLastestUsedFormList.do'
		$.ajax({
			type: "POST",
			url: url,
			data: "",
			success: function(data){
				if(data.status == "SUCCESS"){
					if (wpLastDraft.config.type == 'favorite'){
						wpLastDraft.data.length = 0;
						$.each(data.list, function(idx, el){
							el.FormName = el.LabelText;
							wpLastDraft.data.push(el);
						});
					} else {
						wpLastDraft.data = data.list;
					}
				}else{
					Common.Warning(data.message);
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		}).done(function(){
			wpLastDraft.render();
		});
	},
	render: function(){
		$('#lastDraft_list').empty();
		$.each(wpLastDraft.data, function(idx, el){
			$('#lastDraft_list').append(
				$("#tempate_lastDraft_item").html()
					.replace('{index}', idx)
					.replace('{clickEvent}', 'javascript: wpLastDraft.clickPopup(this);')
					.replace('{draftName}', CFN_GetDicInfo(el.FormName).replace(/ /g, '<br>'))
			);
		});
	},
	changeTab: function(target) {
		this.config.type = $(target).attr("data-role");
		$.each($("#lastDraft_tab [class*=on]"), function(idx, el){
		    $(el).prop("class", $(el).prop("class").replace('on', 'off'));
		});
		
		$(target).prop("class", $(target).prop("class").replace('off', 'on'));
		
		this.getList(this.config.type);
	},
	clickPopup: function(target){
		var targetID = $(target).attr('data-index');
		var targetData = wpLastDraft.data[targetID];
		
		var width = (IsWideOpenFormCheck(targetData.FormPrefix)) ? "1070" : "790";
		
		CFN_OpenWindow("/approval/approval_Form.do?formID=" + targetData.FormID + "&mode=DRAFT", "", width, (window.screen.height - 100), "resize", "false");
	}
}