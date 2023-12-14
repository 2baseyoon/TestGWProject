/**
 * approvalList - 전자결재
 */
var approvalList = {
	config: {
		pageSize: 5
	},
	data: {},
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;

		$("#approvalList_tab a:first").click();
	},
	getApprovalList:function(pMode){
		$.ajax({
			type:"GET",
			url:"/approval/user/getApprovalListData.do?mode="+ pMode,
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
					"pageSize": approvalList.config.pageSize,
					"pageNo": 1,
					"userID": Common.getSession('USERID'),
					"titleNm":"",
					"userNm":"", 
					"selectDateType":""
			},
			success:function(data){
				approvalList.data[pMode] = data.list;
			}
		}).done(function(){
			approvalList.renderList(pMode);
		});
	},
	getCount:function (){
		var iApproval = 0;
		var iProcess = 0;
		var iPreApproval = 0;
		var iTCInfo;
		
		$.ajax({
			type:"GET",
			url:"/approval/user/getApprovalListCnt.do",
			success:function(data){
				iApproval = data.approval;
				iProcess = data.process;
				iPreApproval = data.preapproval;
				iTCInfo = data.tcinfo;
				
				$("#divApprovalCnt").text(iApproval);
				$("#divProcessCnt").text(iProcess);
				$("#divPreApprovalCnt").text(iPreApproval);
				$("#divTCInfoCnt").text(iTCInfo);
			}
		});
	},
	clickPopup:function (mode,ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,FormPrefix){
		var width;
		var gloct;
		var archived = "false";
		var subkind = SubKind; 
		var userID = UserCode;
		
		switch(mode){
			case "Approval": gloct = "APPROVAL"; break;// 미결함
			case "Process": gloct = "PROCESS"; break; //진행함 
			case "PreApproval": gloct = "PROCESS"; subkind="T010"; break; //예고함
			case "TCInfo": gloct = "TCINFO"; userID=""; break; //참조/회람함
		}
		
		if(IsWideOpenFormCheck(FormPrefix) == true){
			width = 1070;
		}else{
			width = 790;
		}
		
		CFN_OpenWindow("/approval/approval_Form.do?mode="+mode.toUpperCase()+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"", "", width, (window.screen.height - 100), "resize");
	},
	changeTab: function(target) {
		this.config.currentTab = $(target).attr("data-role");
		$.each($("#approvalList_tab [class*=tab_on]"), function(idx, el){
		    $(el).prop("class", $(el).prop("class").replace('on', 'off'));
		});
		
		$(target).prop("class", $(target).prop("class").replace('off', 'on'));
		
		this.getApprovalList(this.config.currentTab);
	},
	renderList: function(pMode){
		$("#approvalList_list").empty();
		$.each(approvalList.data[pMode], function(idx, el){
			var date = "";
			switch(pMode) {
			case "Approval": 
			case "PreApproval":
				date = el.Created; break;
			case "Process": 
				date = el.StartDate; break;
			case "Complete":
				date = el.EndDate; break;
			case "TCInfo":
				date = el.ReceiptDate;
			}
			
			var listHTML = $("#tempalte_approvalList_item").html()
				.replace('{index}', idx)
				.replace('{title}', el.FormSubject)
				.replace('{initiatorName}', CFN_GetDicInfo(el.InitiatorName))
				.replace('{date}', new Date(date).format('MM.dd'));
				
			$("#approvalList_list").append(listHTML);
		});
		if (approvalList.data[pMode].length < 1){
			$("#wp_approval [data-role=result]").hide();
			$("#wp_approval [data-role=no-result]").show();
		}
	},
	goMore: function(){
		location.href = '/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode='+this.config.currentTab
	},
	goView: function(target){
		var targetIndex = $(target).attr("data-index");
		var targetData = this.data[this.config.currentTab][targetIndex];
		
		var mode = this.config.currentTab.toUpperCase();
		var gloct = 'APPROVAL';
		var subkind = targetData.FormSubKind;
		var userID = targetData.PerformerID;
		var archived = "false";
		var processID = targetData.ProcessID;
		var workitemID = targetData.WorkItemID;
		var processDescriptionID = targetData.ProcessDescriptionID
		
		switch(this.config.currentTab){
			case "Approval": gloct = "APPROVAL"; break;// 미결함
			case "Process": gloct = "PROCESS"; break; //진행함 
			case "PreApproval": gloct = "PROCESS"; subkind="T010"; break; //예고함
			case "Complete" : 
				processID = targetData.ProcessArchiveID;
				workitemID = targetData.WorkitemArchiveID;
				processDescriptionID = targetData.ProcessDescriptionArchiveID;
				gloct = "COMPLETE"; 
				archived="true"; 
				break;	// 완료함
			case "TCInfo": 
				mode = "COMPLETE";
				gloct = "TCINFO";
				workitemID = "";
				performerID = "";
				processDescriptionID = "";
				subkind = targetData.kind;
				userID = ""; 
				break; //참조/회람함
		}
		
		var url = '/approval/approval_Form.do';
		var _queryParam = {
			mode: mode,
			processID: processID,
			workitemID: workitemID,
			performerID: userID,
			processdescriptionID: processDescriptionID,
			userCode: targetData.UserCode,
			formID: targetData.FormID,
			forminstanceID: targetData.FormInstID,
			gloct: gloct,
			subkind: subkind,
			usisdocmanager: 'true',
			listpreview: 'N',
			archived: archived
		};
		url += '?' + $(_queryParam).serializeQuery();
		
		var	_width = (typeof IsWideOpenFormCheck == 'function' && IsWideOpenFormCheck(targetData.FormPrefix)) ? 1070 : 790;
		var	_height = window.screen.height - 100;
		
		CFN_OpenWindow(url, "", _width, _height, "resize");
	}
}

