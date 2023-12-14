/**
 * myContents_ApprovalBox - 마이 컨텐츠 - 결재함
 */
var myContents_ApprovalBox ={
	mode: 'APPROVAL', 
	init: function (data,ext){
		myContents_ApprovalBox.getApprovalList();	// 일정 조회
	},
	// 결재함 조회
	getApprovalList : function() {
		if($("#mycontents_ApprovalBox_List_"+this.mode).html() != ""){
			return; 
		}
		
		$.ajax({
			type:"POST",
			url:"/approval/user/getApprovalListData.do?mode="+ this.mode,
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
					"userID":myContents.sessionObj["USERID"],
					"titleNm":"",
					"userNm":"", 
					"selectDateType":""
			},
			success:function(data) {
				var sHtml = "";
				
				if(data.list != undefined && data.list.length > 0){
					$(data.list).each(function(idx,form){
						/*var approvalStep = [0, 0];
						var approvalStepPer = 0;
						
						if(myContents_ApprovalBox.mode == "APPROVAL" && form.ApprovalStep != undefined && form.ApprovalStep != ''){
							approvalStep = form.ApprovalStep.split("/");
							approvalStepPer = Math.floor(approvalStep[0]/approvalStep[1] *100);
						}*/
						
						var dateKey = "", onclick="";
						switch(myContents_ApprovalBox.mode){
						case "APPROVAL":
							dateKey = "Created"
							break;
						case "COMPLETE":
							dateKey = "EndDate"
							break;
						case "TCINFO":
							dateKey = "RegDate"
							break;
						default: 
							dateKey = "Created"
						}
						
						
						sHtml += '<li>';
						if(myContents_ApprovalBox.mode == "APPROVAL"){
							sHtml += '<a href="#" onclick="myContents_ApprovalBox.onClickPopButton(\''+form.ProcessID+'\',\''+form.WorkItemID+'\',\''+form.PerformerID+'\',\''+form.ProcessDescriptionID+'\',\''+form.FormSubKind+'\',\'\',\''+form.FormInstID+'\',\'\',\'\',\''+form.UserCode+'\',\''+form.FormPrefix+'\',\''+form.BusinessData1+'\',\''+form.BusinessData2+'\',\''+form.TaskID+'\'); return false;">';
						}else if(myContents_ApprovalBox.mode == "COMPLETE"){
							sHtml += '<a href="#" onclick="myContents_ApprovalBox.onClickPopButton(\''+form.ProcessArchiveID+'\',\''+form.WorkitemArchiveID+'\',\''+form.PerformerID+'\',\''+form.ProcessDescriptionArchiveID+'\',\''+form.FormSubKind+'\',\'\',\''+form.FormInstID+'\',\'\',\'\',\''+form.UserCode+'\',\''+form.FormPrefix+'\',\''+form.BusinessData1+'\',\''+form.BusinessData2+'\',\''+form.TaskID+'\'); return false;">';
						}else if(myContents_ApprovalBox.mode == "TCINFO"){
							sHtml += '<a href="#" onclick="myContents_ApprovalBox.onClickPopButton(\''+form.ProcessID+'\',\'\',\'\',\'\',\''+form.Kind+'\',\'\',\''+form.FormInstID+'\',\'\',\'\',\''+form.UserCode+'\',\''+form.FormPrefix+'\',\''+form.BusinessData1+'\',\''+form.BusinessData2+'\',\''+form.TaskID+'\'); return false;">';
						}else{
							sHtml += '<a href="#">';
						}
						
						sHtml += '		<p class="approval_tit">' + form.FormSubject + '</p>';
						sHtml += '		<div class="approval_cont">';
						
						/*if(myContents_ApprovalBox.mode == "APPROVAL"){
							sHtml += '			<div class="approval_progress"><span style="width: ' + approvalStepPer + '%;"></span></div>';
							sHtml += '			<p class="approval_progress_txt"><span>' + approvalStep[0] + '</span>/' + approvalStep[1] + '</p>';
						}*/
						
						sHtml += '			<p class="approval_type" style="margin: 2px 0px 2px 0px;">' + form.SubKind + '</p>';
						sHtml += '			<p class="approval_name" style="margin: 2px 0px 2px 5px;">' + form.InitiatorName + '</p>';
						sHtml += '			<p class="approval_date" style="margin: 2px 0px 2px 5px;">' + getStringDateToString("MM.dd ",form[dateKey]) + '</p>';																
						sHtml += '		</div>';
						sHtml += '	</a>';
						sHtml += '</li>';
					});
					
					$("#mycontents_ApprovalBox_List_"+myContents_ApprovalBox.mode).empty().html(sHtml);
				}else{
					myContents.emptyList("#mycontents_ApprovalBox_List_"+myContents_ApprovalBox.mode);
				}
			}
		});
	},
	clickTab: function(clickObj){
		this.mode = $(clickObj).attr("name");
		
		$(clickObj).parent("li").addClass("active")
				   .siblings("li").removeClass("active");
		
		$("#mycontents_ApprovalBox_List_"+this.mode).show()
													   .siblings("ul").hide();
		
		this.getApprovalList();
	}, 
	onClickPopButton: function(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,FormPrefix,BusinessData1,BusinessData2,TaskID){
		var width;
		var archived = "false";
		var mode, gloct, subkind, userID;
		
		switch (this.mode){
			case "APPROVAL" : mode="APPROVAL"; gloct = "APPROVAL"; subkind=SubKind; userID=UserCode; break;    // 미결함
			case "COMPLETE" : mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;	// 완료함
			case "TCINFO" : mode="COMPLETE"; gloct = "TCINFO"; subkind=SubKind; userID=""; break;		// 참조/회람함
		}
		if(IsWideOpenFormCheck(FormPrefix) == true){
			width = 1070;
		}else{
			width = 790;
		}
		
		CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+""
			+"&ExpAppID="+((typeof BusinessData2!="undefined"&&BusinessData2!="undefined")?BusinessData2:"")+"&taskID="+(typeof TaskID!="undefined"?TaskID:""), "", width, (window.screen.height - 100), "resize");
	}
	
}


