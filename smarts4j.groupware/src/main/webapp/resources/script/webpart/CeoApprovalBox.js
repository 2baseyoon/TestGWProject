/**
 * approvalBox - 전자결재 - 결재함
 */
var ceoApprovalBox ={
		webpartType: '', 
		ProfileImagePath :Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code")),
		UserCode: Common.getSession("UR_Code"),
		
		init: function (data,ext){
			var _this = this;
			$("#ceoApproval .ProjectCEO_CEOrebtn").attr("href", ext.approvalURL);

			$.ajax({
				url	: "/approval/user/getApprovalListData.do",
				type: "POST",
				data: {
						"mode"  :"APPROVAL",
						"userID":_this.UserCode,
						"searchGroupType":'',
						"bstored":"false",
						"pageSize":3,
						"pageNo":1
				},
				success:function (data) {
					
					if(data.status == "SUCCESS"){
						var listCount = data.page.listCount;

						if (listCount== undefined || listCount ==0) $("#ceoApproval .ProjectCEO_none").show();
						if (listCount > 99) $("#ceoApproval .eAPcountStyle").text("99+");
						else	$("#ceoApproval .eAPcountStyle").text(listCount);

						$.each( data.list, function(index, value) {
							$("#ceoApproval .ProjectCEO_Scroll .List").append('<li>'+
									'<div class="listShell">'+
									'	<a class="listcon_link ui-link">'+
									'		<div class="staff_list">'+
									'			<div href="#" class="staff ui-link">'+
									'				<span class="ceoListphoto BGcolorDefault" style="background-image:url(\''+value.PhotoPath+'\')">경</span>'+
									'			</div>'+
									'		</div>'+
									'		<div class="listCleft"  onclick=\'ceoApprovalBox.clickPopup("'+value.ProcessID+'","'+value.WorkItemID+'","'+value.PerformerID+'","'+value.ProcessDescriptionID+'","'+value.FormSubKind+'","'+value.UserCode+'","'+value.FormPrefix+'")\'>'+
									'			<p class="name_unread">'+value.InitiatorName+'</p>'+
									'			<p class="title_unread">'+value.FormSubject+'</p>'+
									'		</div>'+
									'	</a>'+
									'	<a class="bookmark_link ui-link">'+
									'		<div class="listCright">'+
									'			<span class="date">'+value.Created.substring(5,16).replace('-','.')+'</span>'+
									'		</div>'+
									'	</a>'+
									'</div>'+
								'</li>');
						})
					}
				},
				error:function (error){
				}
			});
		},
		clickPopup:function (ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,UserCode,FormPrefix){
			var width = 790;//FormTempInstBoxID,FormInstID,FormID,FormInstTableName,
			var archived = "false";
			var mode ="APPROVAL";
			
			if(IsWideOpenFormCheck(FormPrefix) == true){
				width = 1070;
			}else{
				width = 790;
			}

			CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+UserCode+"&gloct="+mode
						+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+SubKind+"", "", width, (window.screen.height - 100), "resize");
		}
}

