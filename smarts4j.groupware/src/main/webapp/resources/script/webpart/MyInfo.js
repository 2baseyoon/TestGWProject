var webpartMyInfo = {
	config: {
		useAlarm: 'Y'
	},
	data: {},
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;

		if (typeof data == 'object' && Object.keys(data).length > 0 && data.status != 'FAIL'){
			webpartMyInfo.data.quickdata = {};
			$.each(data[0][0], function(idx, el){
				if (idx == 'ApprovalCnt') {
					if (el.status == 'SUCCESS'){
						var approvalCntList = el.list;
						$.each(approvalCntList, function(index, ele){
							webpartMyInfo.data.quickdata[idx+'_'+ele.type] = Number(ele.cnt);	
						})
					}
				} else {
					webpartMyInfo.data.quickdata[idx] = Number(el);	
				}
			});
		}
				
		this.setMyInfo();
		if (this.config.useAlarm == 'Y'){
			this.initAlarm();
		}
	},
	setMyInfo: function(){
		var sesstionObj = Common.getSession();
		$("#webpart-profile-name").text(sesstionObj.UR_Name);
		if ($("#webpart-profile-position").length > 0) {
			$("#webpart-profile-position").text(sesstionObj.UR_JobPositionName);
		} else {
			$("#webpart-profile-name").append('<span style="margin-left: 3px;">' + sesstionObj.UR_JobPositionName + '</span>');
		}
		$("#webpart-profile-team").text(sesstionObj.GR_Name);
		$("#webpart-profile-loginTime").text(new Date(sesstionObj.UR_LoginTime).format('yyyy-MM-dd hh:mm'));
		$("#webpart-profile-photo").attr('style', "background: url("+coviCmn.loadImage(Common.getSession('PhotoPath'))+"); "+ $("#webpart-profile-photo").attr('style'));
	},
	initAlarm: function(){
		$("#webpart-profile-alim").removeClass("none");
		if (!this.data.quickdata){
			this.getAlarm();
		} else {
			this.renderAlarm();
		}
	},
	getAlarm: function(){
		$.ajax({ 
			type: "POST",
			url: "/groupware/longpolling/getQuickData.do",
			data: { "menuListStr": "Mail;Approval;Schedule;" },
			dataType: "json", 
			success: function(data){
				if (data.status == 'SUCCESS'){
					webpartMyInfo.data = data.countObj;
				}
			}
		}).done(function(){
			webpartMyInfo.renderAlarm();
		});
	},
	renderAlarm: function(){
		$.each(webpartMyInfo.data, function(idx, el){
			var cnt = Number(el) >= 100 ? "99+" : el;

			$("#webpart-profile-alim [data-role="+idx+"] [data-role=count]").html(cnt);
		});
		
		$.each($("#webpart-profile-alim [data-role=count]"), function(idx, el){
			if (el.innerHTML == '') el.innerHTML = 0;
		});
	}
}