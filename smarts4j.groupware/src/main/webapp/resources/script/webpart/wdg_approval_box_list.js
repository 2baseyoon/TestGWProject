/**
 * 결재함
 */
var widgetApprovalBox = {
		init: function(data, ext, caller, pWebpartID) {
			var me = this;
			
			me.$_wdg_header = $("#"+pWebpartID).find(".widget_head");
			me.$_wdg_list_div 	= $("#"+pWebpartID).find(".widget_content");
			me.$_wdg_list 	= $("#"+pWebpartID).find(".widget_content ul");
			me.$_wdg_empty 	= $("#"+pWebpartID).find(".widget_empty");
			me.$_wdg_templ 	= $("#"+pWebpartID).find("[template]");
			me.extData = ext;
			
			// 헤더 타이틀에 먹힌 탭 그리기
			me.makeHeader();
			
			// 첫번째 탭 조회
			me.$_wdg_header.find(".tabs button")[0].click();
		},
		makeHeader: function() {
			var me = this;
			
			me.$_wdg_header.find(".title")
			.addClass("blind")
			.after($("<div>",{"class":"tabs ui_tabs", "role":"tablist" }));
			
			var tabArr = [
				{ key : "APPROVAL", val : Common.getDic("lbl_apv_doc_approve2") , idx : 0 }, 	//미결함
				{ key : "COMPLETE", val : Common.getDic("lbl_apv_doc_complete2") , idx : 1 }, //완료함
				{ key : "TCINFO", 	val : Common.getDic("lbl_apv_doc_circulation") , idx : 2 }//참조/회람함
			];

			tabArr.forEach((tab) => {
				var tabBtn = $("<button>", { "type":"button", "class":"tab ui-btn ui-shadow ui-corner-all", "role":"tab", "aria-selected":"false", "value":tab.key })
								.on("click", function(){ 
									me.searchList(this.value); $(this).attr("aria-selected", "true").siblings().attr("aria-selected", "false");
									me.$_wdg_header.find("div.action a.widget_more").attr("href", me.extData.mobileTargetUrl[tab.idx]); // more url변경 
								})
								.append($("<span>", { "text":tab.val }));
				
				me.$_wdg_header.find(".tabs").append(tabBtn);
			});
		},
		searchList: function(type) {
			var me = this;
			if(!type) return;
			
			$.ajax({
				type:"POST",
				url:"/approval/user/getApprovalListData.do?mode="+type,
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
						"pageSize": 5,
						"pageNo": 1,
						"userID":Common.getSession("USERID"),
						"titleNm":"",
						"userNm":"", 
						"selectDateType":""
				},
				success:function(data) {
					me.$_wdg_list.empty();
					
					
					// 조회된 데이터 없을 때
					if (!data.list || data.list.length == 0) {
						me.$_wdg_empty.removeAttr("hidden");
						me.$_wdg_list_div.attr("hidden",true);
						return;
					}else{
						me.$_wdg_empty.attr("hidden", true);
						me.$_wdg_list_div.removeAttr("hidden");
					}
					
					// 목록 출력
					$(data.list).each(function(idx, form) {
						if (idx > 2) return;

						var dateKey = {
							"APPROVAL":	"Created",
							"COMPLETE":	"EndDate",
							"TCINFO":	"RegDate"
						}
						var progress = "";
						var progressPer = 0;
						
						dateKey = XFN_getDateTimeString("MM.dd ",new Date(form[dateKey[type]]));
						
						// 미결함 progressbar 만들기
						if (type == "APPROVAL" && form.ApprovalStep) {
							var stepArr = form.ApprovalStep.split("/");
							var totalStepCnt = stepArr[1];
							var nowStepIdx = stepArr[0]-1;
							
							progress = nowStepIdx + "/" + totalStepCnt;
							progressPer = Math.floor(nowStepIdx/totalStepCnt *100);
						}
						
						var liHtml = me.$_wdg_templ.html()
							.replace('{subject}', form.FormSubject)
							.replace('{subKind}', form.SubKind)
							.replace('{initiatorName}', form.InitiatorName)
							.replace('{dateKey}', dateKey)
							.replace('{progress}', progress)
							.replace('{progressPer}', progressPer);
						
						me.$_wdg_list.append(liHtml);
						
						me.$_wdg_list.find("li:last-child > a").on("click", function() {
							// 미결함
							if (type == "APPROVAL") me.onClickPopButton(type, form.ProcessID, form.WorkItemID, form.PerformerID, form.ProcessDescriptionID, form.FormSubKind, '', form.FormInstID, '', '', form.UserCode, form.FormPrefix, form.BusinessData1, form.BusinessData2, form.TaskID);
							// 완료함
							if (type == "COMPLETE") me.onClickPopButton(type, form.ProcessArchiveID, form.WorkitemArchiveID, form.PerformerID, form.ProcessDescriptionArchiveID, form.FormSubKind, '', form.FormInstID, '', '', form.UserCode, form.FormPrefix, form.BusinessData1, form.BusinessData2, form.TaskID);
							// 참조/회람함
							if (type == "TCINFO") 	me.onClickPopButton(type, form.ProcessID, '', '', '', form.Kind, '', form.FormInstID, '', '', form.UserCode, form.FormPrefix, form.BusinessData1, form.BusinessData2, form.TaskID);
							
							return false;
						});
					});
					
					// 미결함 progressbar show
					if (type == "APPROVAL") {
						me.$_wdg_list.find("li .item_title").removeAttr('style');
						me.$_wdg_list.find("li *").removeAttr('hidden');
					}
				}
			});
		},
		onClickPopButton: function(type,ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,FormPrefix,BusinessData1,BusinessData2,TaskID) {
			var isTeams	 = typeof XFN_TeamsOpenGroupware == "function";
			var width 	 = (IsWideOpenFormCheck(FormPrefix)) ? 1070 : 790;
			var archived = "false";
			var ExpAppID = BusinessData2 ? BusinessData2 : "";
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
			}
		}
}