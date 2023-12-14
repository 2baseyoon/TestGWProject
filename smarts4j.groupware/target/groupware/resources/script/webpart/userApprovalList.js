/**
 * userApprovalList - 전자결재 - 미결함
 */
var userApprovalList ={
		webpartType: '', 
		init: function (data,ext){
		/*	if(this.webpartType>=0){ 
				$.ajax({
					type:"GET",
					url:"/groupware/webpart/getUserApprovalList.do",
					async:false,
					data:{
						"pogeSize":5
					},
					success:function(data){
						debugger;
						listData = data.list.list;
					}
				});
			}*/
			
			$.each( data[0], function(index, value) {
				var create = CFN_TransLocalTime(value.Created, "yyyy.MM.dd");
				
				$("#userApprovalList_list1 > tbody").append('<tr><td height="25"><a href=\'#none\'  style="color:black;" onclick="userApprovalList.clickPopup(\'APPROVAL\',\''+value.ProcessID+'\',\''+value.WorkItemID+'\',\''+value.PerformerID+'\',\''+value.ProcessDescriptionID+'\',\''+value.FormSubKind+'\',\'\',\'\',\'\',\'\',\''+value.UserCode+'\',\''+value.FormPrefix+'\'); return false;"   >'
						+value.FormSubject+
						'</td><td>'
						+value.FormName+
						'</td><td>'
						+value.InitiatorName+
						'</a></td><td style="text-align:center;">'
						+create+
						'</td></tr>');
			});
		
		},
		clickPopup:function (mode,ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,FormPrefix){
			var width;
			var archived = "false";
			var gloct, subkind, userID;
			
			switch(mode){
				case "APPROVAL":  gloct = "APPROVAL"; subkind=SubKind; userID=UserCode; break;// 미결함
				case "PROCESS":  gloct = "PROCESS"; subkind=SubKind; userID=UserCode;  break; //진행함 
			}
			
			CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"", "", width, (window.screen.height - 100), "resize");
		}
}

