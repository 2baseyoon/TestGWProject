/**
 * myContents - 마이 컨텐츠 - 자유 게시
 */
var mobileDoor ={
	
	init: function (data,ext){
		var _ext = (typeof ext == 'object') ? ext : {};
		mobileDoor.config = $.extend(mobileDoor.config, _ext);
		
		$("#mobileDoor .greetings strong").text(Common.getSession("USERNAME") + mobile_comm_getDic('lbl_Sir') + ". ");
		var dataDoor = data[0];
		// 메일사용시에만 메일 건수 표시.
		if(coviUtil.getAssignedBizSection("Mail")){
			mobileDoor.getMailCnt();
		} else {
			$("#mobileDoor #mailCnt").empty();
		}
		
		$("#mobileDoor #door_schedule").text(dataDoor[0]["Schedule"]);
		
		
		var menuList = []; 
		if(mobileDoor.config.menuListStr) menuList = mobileDoor.config.menuListStr.split(";");
		
		if(menuList.includes("ApprovalCnt")) mobileDoor.getApprovalCnt();
	},
	getApprovalCnt:function (){
		$.ajax({
			url: "/approval/user/getApprovalCntAll.do",
			type:"post",
			data:{
				businessData1 : "APPROVAL",
				listType : "ALL",
				boxList : "U_Approval;U_Process;U_TCInfo"
			},
			success:function (data) {
				if(data.status == "SUCCESS" && data.list && data.list.length > 0) {
					for(var boxInfo of data.list){
						var boxAlias = boxInfo.type;
						var boxCnt = boxInfo.cnt;
						if(boxAlias && boxCnt != undefined){
							switch(boxAlias){
								case "U_Approval": $("#mobileDoor #door_approval").text(boxCnt); break;
								case "U_Process": $("#mobileDoor #door_apping").text(boxCnt); break;
								case "U_TCInfo": $("#mobileDoor #door_appre").text(boxCnt); break;
							}
						}	
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getApprovalCntAll.do", response, status, error);
			}
		});
	},
	getMailCnt:function (){
		$.ajax({
			url: "/groupware/longpolling/getMailCnt.do",
			type:"post",
			data:{},
			success:function (data) {
				if(data.status == "SUCCESS") {
					$("#mobileDoor #door_mail").text(data.MailCnt);
				}
			}
		});
	}
	
	
}
