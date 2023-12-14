/**
 * ctn_approval_box - 36.결재함(목록형)
 * @since 2023.4
 */
var ctnApprovalBox = {
	init: function (data, ext, caller, webPartID){
		let $divWebpart = $("#"+webPartID);
		
		// 최초로딩(미결함) 서버랜더링
		/*
		if(data && data[0] && data[0][0] && data[0][0].status && data[0][0].status == "SUCCESS"){
			var listData = data[0][0].list;
			var formHtml = "";
			var lang = Common.getSession("lang");
			
			let $selBox = $divWebpart.find("div[role='tablist'] button[role='tab'][aria-selected='true']");
			var boxType = $selBox.val();
			var boxIdx = $selBox.index();
			ctnApprovalBox.render($divWebpart, boxType, boxIdx, listData); // 리스트 바인딩
		}else{ // 서버랜더링 오류
			//ctnApprovalBox.toggle_empty($divWebpart, true);
			coviCmn.traceLog("webpart" + webPartID + " Data fetch Error.");
			ctnApprovalBox.searchList($divWebpart, boxType, boxIdx); 
		}
		*/
		
		// 결재함 탭 클릭 이벤트
		$divWebpart.find("div[role='tablist'] button[role='tab']").each(function(idx,item){
			$(item).on("click", function(){ 
				ctnApprovalBox.searchList($divWebpart, $(item).val(), idx); // 리스트조회
				$divWebpart.find("div.action a.widget_more").attr("href", ext.targetUrl[idx]); // more url변경 
			}); 
		});
		
		$divWebpart.find("div[role='tablist'] button[role='tab'][aria-selected='true']").trigger("click");
	},
	searchList: function($divWebpart, boxType, boxIdx) { // 결재함 탭 클릭 이벤트
		$.ajax({
			type:"POST",
			url:"/approval/user/getApprovalListData.do?mode="+boxType,
			data: {
					"bstored":false, // 이관문서 여부
					"businessData1":"APPROVAL",
					"pageSize": 5,
					"pageNo": 1,
					"userID":Common.getSession("USERID")
			},
			success:function(data) {
				if(data.status == "SUCCESS"){
					ctnApprovalBox.render($divWebpart, boxType, boxIdx, data.list);	// 리스트 바인딩
				}else{
					ctnApprovalBox.toggle_empty($divWebpart, true);
					Common.Error(data.message);
				}
			},
			error:function(response, status, error) {
				ctnApprovalBox.toggle_empty($divWebpart, true);
	        	CFN_ErrorAjax("/approval/user/getApprovalListData.do", response, status, error);
	        }
		});
	},
	render: function($divWebpart, boxType, boxIdx, listData){ // 리스트 바인딩
		if(listData && listData.length > 0){
			if(boxType && boxIdx > -1){
				let $divContent = $divWebpart.find("div[name='div_content']").eq(boxIdx);
				let $ulContent = $divContent.find("ul[name='ul_content']");
				$ulContent.empty();
				
				$.each(listData, function(idx, item){
					if(idx > 5) return false;
					
					var dateKey = {
						"APPROVAL":	"Created",
						"COMPLETE":	"EndDate",
						"TCINFO":	"RegDate"
					}
					
					var $liContent = $("<li>");
					var $aContent = $('<a href="#" class="post_item"></a>');
					$aContent.append('<strong class="item_title">' + item.FormSubject + '</strong>');
					
					var $meta = $("<span class='meta'></span>");
					$meta.append('<strong>' + item.SubKind + '</strong>');
					$meta.append('<span>' + item.InitiatorName + '</span>');
					$meta.append('<time>' + XFN_getDateTimeString("MM.dd ",new Date(item[dateKey[boxType]])) + '</time>'); // getStringDateToString("MM.dd ",item[dateKey[boxType]])
					var $progress = null;
					if(boxType == "APPROVAL"){
						$meta.append('<em>' + item.ApprovalStep + '</em>');
						
						var percent_step = 0;
						if(item.ApprovalStep && item.ApprovalStep.indexOf("/") > -1) {
							var arr_step = item.ApprovalStep.split("/");
							if(arr_step[1] != "0") percent_step = 100 * arr_step[0] / arr_step[1];
						}
						$progress = $('<span class="widget_progress"><span class="bar" style="width:' + percent_step + '%"></span></span>');	
					}else{
						$meta.append('<em></em><span></span>');
					}
					$aContent.append($meta);
					if($progress != null) $aContent.append($progress);
					
					$aContent.on("click", function() {
						// 미결함
						if (boxType == "APPROVAL") ctnApprovalBox.onClickPopButton($divWebpart, boxType, item.ProcessID, item.WorkItemID, item.PerformerID, item.ProcessDescriptionID, item.FormSubKind, '', item.FormInstID, '', '', item.UserCode, item.FormPrefix, item.BusinessData1, item.BusinessData2, item.TaskID);
						// 완료함
						else if (boxType == "COMPLETE") ctnApprovalBox.onClickPopButton($divWebpart, boxType, item.ProcessArchiveID, item.WorkitemArchiveID, item.PerformerID, item.ProcessDescriptionArchiveID, item.FormSubKind, '', item.FormInstID, '', '', item.UserCode, item.FormPrefix, item.BusinessData1, item.BusinessData2, item.TaskID);
						// 참조/회람함
						else if (boxType == "TCINFO") 	ctnApprovalBox.onClickPopButton($divWebpart, boxType, item.ProcessID, '', '', '', item.Kind, '', item.FormInstID, '', '', item.UserCode, item.FormPrefix, item.BusinessData1, item.BusinessData2, item.TaskID);
						
						return false;
					});
								
					$liContent.append($aContent);
					$ulContent.append($liContent);
				});
				
				$divContent.attr("hidden", false).siblings().attr("hidden", true); // 선택된 탭 내용 표시
				ctnApprovalBox.toggle_empty($divWebpart, false);
		
			}else{ // 선택된 결재함 없음
				ctnApprovalBox.toggle_empty($divWebpart, true);
			}
		}else{ // 건수 없음
			ctnApprovalBox.toggle_empty($divWebpart, true);
		}
	},
	toggle_empty: function($divWebpart, bEmpty){ // 데이터 없음 표시
		//coviUtil.webpartDrawEmpty([], caller, webPartID, Common.getDic("msg_NoDataList"));
		$divWebpart.find(".widget_content").attr("hidden", bEmpty);
		$divWebpart.find(".widget_empty").attr("hidden", !bEmpty);
	},
	onClickPopButton: function($divWebpart,type,ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,FormPrefix,BusinessData1,BusinessData2,TaskID) {
		// 결재문서 오픈
		var isTeams	 = typeof XFN_TeamsOpenGroupware == "function";
		var width 	 = (IsWideOpenFormCheck(FormPrefix)) ? 1070 : 790;
		var archived = "false";
		var ExpAppID = (BusinessData2 && BusinessData2 != "undefined") ? BusinessData2 : "";
		var TaskID 	 = TaskID ? TaskID : "";
		var mode, gloct, subkind, userID, urlParam;
		
		switch(type) {
			// 미결함
			case "APPROVAL" : mode="APPROVAL"; gloct="APPROVAL"; subkind=SubKind; userID=UserCode; break;
			// 완료함
			case "COMPLETE" : mode="COMPLETE"; gloct="COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;
			// 참조/회람함
			case "TCINFO" 	: mode="COMPLETE"; gloct="TCINFO"; subkind=SubKind; userID=""; break;
		}
		
		urlParam = "mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"&ExpAppID="+ExpAppID+"&taskID="+TaskID;
		
		if (coviUtil.isMobile() || isTeams) {
			mobile_comm_go("/approval/mobile/approval/view.do?" + urlParam, "Y");
		} else {
			CFN_OpenWindow("/approval/approval_Form.do?" + urlParam, "", width, (window.screen.height - 100), "resize");
			window.apvRefreshPortal = function(){
	    		//ctnApprovalBox.searchList($divWebpart, "APPROVAL", 0);
				$divWebpart.find("div[role='tablist'] button[role='tab'][value='" + type + "']").trigger("click");
    			window.apvRefreshPortal = null;
			};
		}
	}
}