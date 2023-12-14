/**
 * myContents - 마이 컨텐츠 - 최근사용양식
 */
var myContents_RecentUseForm ={
	init: function (data,ext){
		 myContents_RecentUseForm.getForm();	// 일정 조회
	},
	// 받은 메일 조회
	getForm : function() {
		$.ajax({
			type:"POST",
			url:"/approval/user/getLastestUsedFormListData.do",
			data: {'userCode' : myContents.sessionObj["UR_Code"]},
			success:function(data) {
				if(data.list != undefined && data.list.length > 0){
					var sHtml = "";
					
					$(data.list).each(function(idx,form){
						sHtml += '<div class="Redocfileitem">';
						sHtml += '	<a href="#" class="Redocfileiteminner" onclick="myContents_RecentUseForm.openFormDraft(\'' + form.FormID + '\',\'' + form.FormPrefix + '\')">';
						sHtml += '		<div class="Redocfilesubject">' + CFN_GetDicInfo(form.LabelText) + '</div>';
						sHtml += '		<p class="Redocdate">' + CFN_TransLocalTime(form.InitiatedDate, "yyyy.MM.dd") + '</p>';
						sHtml += '	</a>';
						sHtml += '</div>';
					});
					
					$("#myContents_RecentUseForm_List").empty().html(sHtml);
				}else{
					myContents.emptyList("#myContents_RecentUseForm_List");
				}
			}
		});
	}, 
	openFormDraft: function(formID,formPrefix){
		var width = "790";
		if(IsWideOpenFormCheck(formPrefix)){
			width = "1070";
		}else{
			width = "790";
		}
		CFN_OpenWindow("/approval/approval_Form.do?formID=" + formID + "&mode=DRAFT", "", width, (window.screen.height - 100), "resize", "false");

	}
}


