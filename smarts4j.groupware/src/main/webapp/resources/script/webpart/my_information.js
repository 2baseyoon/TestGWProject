var myInformation = {
	init : function(data, ext, caller, webpartID) {
		let preId = webpartID!=undefined?"#"+webpartID+" ":"";
		var linkObj = data[0][0];
		var linkNameList = Object.keys(linkObj);
		var menuList = []; 
		if(ext && ext.menuListStr) menuList = ext.menuListStr.split(";");
		
		// 확장형 - portal_widget 에 long 포함 이면서, grid_item y2 일때 
		if($(preId + ".widget_card").closest(".portal_widget").attr("class").includes("long") && 
				$(preId + ".widget_card").closest(".grid_item").attr("class").includes("y2")){
			
			// 확장형 태그 
			$(preId + ".widget_card").append($("<div>",{"class":"widget_content"})
				.append($("<div>",{"class":"profile"}))
				.append($("<div>",{"class":"count"}))
			);
		
			// 프로필
			myInformation.setprofile(preId + ".profile" ,"long");

			// 최근접속일			
			var RecentLogonDate = Common.getSession('RecentLogonDate');
			$(preId + ".widget_card").find(".info").append($("<span>",{"text":coviUtil.getDic("lbl_last_access_date")+" : " + RecentLogonDate}));
			
			// 메일 건수 
			if(coviUtil.getAssignedBizSection("Mail")) {
				$(preId + ".count")
					.append($("<dl>")
						.append($("<dt>")
							.append($("<span>",{"text":coviUtil.getDic("CPMail_mail_inbox")}))
						)
						.append($("<dd>")
							.append($("<a>",{"id":"mailCnt", "href":"/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail", "text":"0"}))
						)
					);
				myInformation.getMailCnt(webpartID, "y2");
			}
			myInformation.setcount(preId + ".count", linkObj);
			if(menuList.includes("ApprovalCnt")) myInformation.getApprovalCnt(preId + ".count");

		} else {
			// 기본형 태그
			$(preId + ".widget_card").append($("<div>",{"class":"user_info", "id":"user_info"}));
			$(preId + ".widget_card").append($("<nav>",{"class":"link", "id":"user_info_link"}));
		
			// 프로필
			myInformation.setprofile(preId + "#user_info" ,"short");

			var url = "";
			var title = "";
			// 메일 사용 안하면 메일 비표시
			if(coviUtil.getAssignedBizSection("Mail")){
				
				url = !coviUtil.isMobile() ? "/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail" : "/mail/mobile/mail/List.do";
				title = coviUtil.getDic("lbl_Mail");
					
				$(preId + ".widget_card").find("#user_info_link")
					.append($("<a>",{"id":"mailCnt","href":url ,"data-icon":"mail"})
							.append($("<span>",{"text":title}))
							.append($("<em>",{"class":"ui_badge","text":"0"}))
					);
				myInformation.getMailCnt(webpartID, "y1");
			
			}
			
			for(var i = 0; i < linkNameList.length; i++) {
				if(linkNameList[i] == "Approval") {
					url = !coviUtil.isMobile() ? "/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode=Approval" : "/approval/mobile/approval/list.do";
					title = coviUtil.getDic("lbl_apv_doc_approve2");
				} else if(linkNameList[i] == "Schedule") {
					url = !coviUtil.isMobile() ? "/groupware/layout/schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType=M" : "/groupware/mobile/schedule/month.do?viewtype=M";
					title = coviUtil.getDic("lbl_webpart_schedule");
				}
				$(preId + ".widget_card").find("#user_info_link")
				.append($("<a>",{"href":url ,"data-icon":linkNameList[i].toLowerCase()})
						.append($("<span>",{"text":title}))
						.append($("<em>",{"class":"ui_badge","text":linkObj[linkNameList[i]]}))
				);
			}
		}
	},
	setprofile : function(pSelector, classNm){
		//  프로필
		var my_photoPath = Common.getSession("PhotoPath");
		var my_Name = Common.getSession("UR_Name");
		var my_GR_Name = Common.getSession("GR_Name");
		var $profile = $(pSelector);
		var tag = classNm=="long" ? "<em>" : "<span>";
		return $profile
			.append($("<div>", {"class" : "ui_avatar"})
				.append($("<img>", {
					"src" : !coviUtil.isMobile() ? coviCmn.loadImage(my_photoPath) : mobile_comm_getimg(my_photoPath), 
					"onerror": !coviUtil.isMobile() ? "coviCmn.imgError(this,true)" : "mobile_comm_imageerror(this, true)"})
				)
			)
			.append($("<div>", {"class" : "info"})
				.append($("<strong>", {"text" : my_Name}))
				.append($(tag, {"text" : my_GR_Name}))
			);
	},
	getMailCnt:function (webpartID, displayType){
		if(coviUtil.getAssignedBizSection("Mail")) {
			if(gSystemMailCall === true && gPortalMailCount > 0){
				if(displayType == "y2"){
					$("#"+webpartID+" #mailCnt").text(gPortalMailCount);
				}else{
					var $con = $("#"+webpartID+" #mailCnt");
			    	$con.find('em').text(gPortalMailCount);
				}
			}else{
				setTimeout(myInformation.getMailCnt,500,webpartID, displayType);
			}
		}
	},
	getApprovalCnt:function (pSelector){
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
								case "U_Approval": 
									$(pSelector)
										.append($("<dl>")
											.append($("<dt>")
												.append($("<span>",{"text":coviUtil.getDic("lbl_apv_doc_approve2")}))
											)
											.append($("<dd>")
												.append($("<a>",{"href":"/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode=Approval" , "text":boxCnt}))
											)
										);
									break;
								case "U_Process": 
									$(pSelector)
										.append($("<dl>")
											.append($("<dt>")
												.append($("<span>",{"text":coviUtil.getDic("lbl_apv_doc_process2")}))
											)
											.append($("<dd>")
												.append($("<a>",{"href":"/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode=Process" , "text":boxCnt}))
											)
										);
									break;
								case "U_TCInfo": 
									$(pSelector)
										.append($("<dl>")
											.append($("<dt>")
												.append($("<span>",{"text":coviUtil.getDic("lbl_TCInfoListBox")}))
											)
											.append($("<dd>")
												.append($("<a>",{"href":"/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode=TCInfo" , "text":boxCnt}))
											)
										);
									break;
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
	setcount : function(pSelector, linkObj){
		// 건수
		var $return = $(pSelector);
		
		$return
			.append($("<dl>")
				.append($("<dt>")
					.append($("<span>",{"text":coviUtil.getDic("lbl_TodaySchedule")}))
				)
				.append($("<dd>")
					.append($("<a>",{"href":"/groupware/layout/schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType=M" , "text":linkObj["Schedule"]}))
				)
			);
		return $return;
	}
}
