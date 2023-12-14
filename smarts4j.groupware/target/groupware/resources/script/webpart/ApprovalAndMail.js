/**
 * approvalAndMail - 전자결재/메일
 */
var approvalAndMail = {
	config: {
		pageSize: 5
	},
	data: {},
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		if (typeof Common.getSession("PortalOption") == 'object' && typeof Common.getSession("PortalOption").theme != 'undefined') {
			this.config.theme = Common.getSession("PortalOption").theme;
		} else if (Common.getSession("UR_ThemeType") != '') {
			this.config.theme = Common.getSession("UR_ThemeType")
		} else {
			this.config.theme = 'purple';
		}

		$("#approvalAndMail_tab a:first").click();
	},
	setEmpty: function(){
		$("#approvalAndMail_list").empty();
		$("#approvalAndMail_list").append(
			'<tr>'+
			'	<td class="ptype01_wp_none">'+Common.getDic('msg_NoDataList')+'</td>'+
			'</tr>'
		);
	},
	getList: function(pMode){
		switch(pMode){
		case 'Mail':
			this.getMailList();
			break;
		case 'Approval':
			this.getApprovalList();
			break;
		}
	},
	getMailList: function(){
		if (Common.getBaseConfig("isUseMail") != "Y" || Common.getSession("UR_Mail") == ""){
			approvalAndMail.setEmpty();
		} else {
			var params = JSON.stringify({
				"userMail" : Common.getSession("UR_Mail"),   	//  메일계정
				"mailBox" : "INBOX",                            //  받은 메일함
				"page" : 1,                                     //  페이지(Default)
				"type" : "MAILLIST",                            //  Default
				"type2" : "ALL",                                //  읽음구분(전체)
				"viewNum" : approvalAndMail.config.pageSize,	//  메일갯수
				"sortType" : "A"                                //  정렬순서(내림차순 A, 오름차순 RA)
			});		
			
			$.ajax({
				type:"POST",
				contentType: 'application/json',
				url: "/mail/userMail/selectUserMail.do",
				data: params,
				success:function(data){
					approvalAndMail.data.Mail = data[0].mailList;
				}
			}).done(function(){
				if (typeof approvalAndMail.data.Mail == 'undefined' || (typeof approvalAndMail.data.Mail == 'object' && Object.keys(approvalAndMail.data.Mail) == 0)){
					approvalAndMail.setEmpty();
				} else {
					approvalAndMail.renderMailList();
				}
			});
			
		}
	},
	getApprovalList: function(){
		$.ajax({
			type:"GET",
			url:"/approval/user/getApprovalListData.do?mode=Approval",
			data: {
					"searchType":"",
					"searchWord":"",
					"searchGroupType":"all",
					"searchGroupWord":"",
					"startDate":"",
					"endDate":"",
					"sortColumn":"",
					"sortDirection":"",
					"isCheckSubDept":0,
					"bstored":false, // 이관문서 여부
					"businessData1":"APPROVAL",
					"pageSize": approvalAndMail.config.pageSize,
					"pageNo": 1,
					"userID": Common.getSession('USERID'),
					"titleNm":"",
					"userNm":"", 
					"selectDateType":""
			},
			success:function(data){
				approvalAndMail.data.Approval = data.list;
			}
		}).done(function(){
			if (typeof approvalAndMail.data.Approval == 'undefined' || (typeof approvalAndMail.data.Approval == 'object' && Object.keys(approvalAndMail.data.Approval) == 0)){
				approvalAndMail.setEmpty();
			} else {
				approvalAndMail.renderApprovalList();
			}
		});
	},
	changeTab: function(target) {
		this.config.currentTab = $(target).attr("data-role");
		$.each($("#approvalAndMail_tab [class*=tab_on]"), function(idx, el){
		    $(el).prop("class", $(el).prop("class").replace('on', 'off'));
		});
		
		$(target).prop("class", $(target).prop("class").replace('off', 'on'));
		
		this.getList(this.config.currentTab);
	},
	renderMailList: function(){
		$("#approvalAndMail_list").empty();
		$.each(approvalAndMail.data.Mail, function(idx, el){	
			var listHTML = $("#tempalte_approvalAndMail_item").html()
				.replace('{index}', idx)
				.replace('{title}', (el.flag == "\\Seen") ? el.subject : $("#tempalte_mail_new").html().replace('{title}', el.subject))
				.replace('{name}', CFN_GetDicInfo(el.mailSender))
				.replace('{date}', new Date(el.mailReceivedDateStr).format('MM.dd'));
				
			$("#approvalAndMail_list").append(listHTML);
		});
	},
	renderApprovalList: function(){
		$("#approvalAndMail_list").empty();
		$.each(approvalAndMail.data.Approval, function(idx, el){	
			var listHTML = $("#tempalte_approvalAndMail_item").html()
				.replace('{index}', idx)
				.replace('{title}', el.FormSubject)
				.replace('{name}', CFN_GetDicInfo(el.InitiatorName))
				.replace('{date}', new Date(el.Created).format('MM.dd'));
				
			$("#approvalAndMail_list").append(listHTML);
		});
	},
	goMore: function(){
		if (this.config.currentTab == 'Mail'){
			location.href = '/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail';
		} else if (this.config.currentTab == 'Approval'){
			location.href = '/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode=Approval'
		}
	},
	goView: function(target){
		var targetIndex = $(target).attr("data-index");
		var targetData = this.data[this.config.currentTab][targetIndex];
		
		var url = (this.config.currentTab == 'Mail') ? "/mail/userMail/goMailWindowPopup.do" : '/approval/approval_Form.do';

		var _queryParam = (this.config.currentTab == 'Mail') ? {
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
		} : {
			mode: 'APPROVAL',
			processID: targetData.ProcessID,
			workitemID: targetData.WorkItemID,
			performerID: targetData.PerformerID,
			processdescriptionID: targetData.ProcessDescriptionID,
			userCode: targetData.UserCode,
			formID: targetData.FormID,
			forminstanceID: targetData.FormInstID,
			gloct: 'APPROVAL',
			subkind: targetData.FormSubKind,
			usisdocmanager: 'true',
			listpreview: 'N'
		};
		url += '?' + $(_queryParam).serializeQuery();
		
		var _width = 1000;
		var _height = 700;
		if (this.config.currentTab == 'Approval') {
			_width = (typeof IsWideOpenFormCheck == 'function' && IsWideOpenFormCheck(targetData.FormPrefix)) ? 1070 : 790;
			_height = window.screen.height - 100;
		}
		var optionStr = "height="+_height+",width=" + _width;
		
		var popupTitle = (this.config.currentTab == 'Mail') ? "Mail Read" + stringGen(10) : '';
		window.open(url, popupTitle, optionStr);
		
		if (this.config.currentTab == 'Mail') {
			$("#approvalAndMail_list a[data-index="+targetIndex+"]").html(approvalAndMail.data.Mail[targetIndex].subject);
		} 
	}
}

