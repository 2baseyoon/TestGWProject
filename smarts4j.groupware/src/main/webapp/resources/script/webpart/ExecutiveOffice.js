var ExecutiveOffice = {
	init: function (data,ext,caller){
		ExecutiveOffice.caller = caller;
		this.sessionObj = Common.getSession();
		
		if(ExecutiveOffice.caller == 'myPlace'){
			$(".executiveInfo").closest(".PN_myContents_box").find(".PN_portlet_link").text($(".executiveInfo .webpart-top h3").text());
			$(".executiveInfo").removeAttr("style").removeClass("webpart");
			$(".executiveInfo .webpart-content").removeClass("webpart-content");
			$(".executiveInfo .webpart-top").remove();
			$(".executiveInfo, .executiveInfo div:first").css("height", "100%");
		}
		
		ExecutiveOffice.checkManage();
		
		coviCtrl.bindmScrollV($(".exeList"));
				
	},
	// 관리자 페이지 팝업
	goViewAdmin: function(){
		var url = "/groupware/webpart/goOfficerAdminPopup.do";
		parent.Common.open("", "officerManagePop", Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
		if(ExecutiveOffice.caller == 'myPlace'){  $(".executiveInfo").closest(".PN_myContents_box").find(".PN_portlet_btn").click(); }
	},
	// 매니저 페이지 팝업
	goViewManage: function(){
		var url = "/groupware/webpart/goOfficerManagePopup.do";
		parent.Common.open("", "officerManagePop", Common.getDic("lbl_DetailView"), url, "650px", "350px", "iframe", true, null, null, true);
		if(ExecutiveOffice.caller == 'myPlace'){  $(".executiveInfo").closest(".PN_myContents_box").find(".PN_portlet_btn").click(); }
	},
	// 임원 리스트
	getOfficerList : function(){	
		$.ajax({
			type:"POST",
			url:"/groupware/webpart/getOfficerList.do",
			data: "",
			success:function(data){
				if(typeof data.list != 'undefined'){		
					var listData = data.list;
					
					$("#myContents_OfficerList").empty().html(ExecutiveOffice.setList(listData));	
				}
			}
		});
		
		// 60초 마다 한번씩 다시 실행 -> 상태값 현행화
		setTimeout("ExecutiveOffice.getOfficerList()", 60000);
	},
	setList: function(data){
		var listData = data;
		var sHtml = ""; 
		$.each(listData, function(i, item) {
			sHtml += '		<li class="clearFloat">'
			sHtml += '			<div class="exePhoto">'
			sHtml += '				<p><img src="' + coviCmn.loadImage(item.PhotoPath) + '" alt="Photo Profile" onerror="coviCmn.imgError(this, true);"></p>'
			sHtml += '			</div>'
			sHtml += '			<div class="exeInfoTxt">'
			sHtml += '				<p class="exeName"><a href="javascript:ExecutiveOffice.goUserInfoPopup(\'' + item.UserCode + '\')" ><span class="fcStyle">' + item.DisplayName+ ' ' + item.JobPositionName + '</span></a></p>'
			sHtml += '				<p class="exepart">' + item.DeptName + '</p>'
			sHtml += '			</div>'
			sHtml += '			<div class="exeBtnCont">'
			sHtml += ExecutiveOffice.getStateTag(item.State, item.StateName);
			sHtml += '			</div>'														
			sHtml += '		</li>'		
		});
		return sHtml;
	},
	getStateTag : function(sCode, sName){
		var vResult = "";
		var vClass = "";
		switch(sCode.toUpperCase())
		{
			case "ABSENCE": vClass = "btnType02 jinGray";
				break;
			case "MEETING": vClass = "btnType02 lightPurple";
				break;
			case "STAY": vClass = "btnType02 blue";
				break;
			case "VACATION": vClass = "btnType02 lightGrey";
				break;
			default : vClass = "btnType02 blue";
				break;
		}

		vResult = '<span class="' + vClass + '">' + sName + '</span>';
		return vResult;
	},
	goUserInfoPopup : function(userID){
		parent.Common.open("","MyInfo","","/covicore/control/callMyInfo.do?userID="+userID,"810px","500px","iframe",true,null,null,true); //사용자 프로필
	},
	checkManage: function(){
		$.ajax({
			type:"GET",
			url:"/groupware/webpart/getIsAdminUser.do",
			aync: false,
			success:function(data){
				var mlist = data.list;				
				ExecutiveOffice.isManager = (mlist[0].IsManager == "Y");		

				ExecutiveOffice.setManage();
			},
			error: function(){
				ExecutiveOffice.setManage();
			}
		});
	},
	setManage : function(){
		if(ExecutiveOffice.caller == 'myPlace'){
			if (ExecutiveOffice.isManager){
				$(".executiveInfo").closest(".PN_myContents_box").find('.PN_portlet_menu').find("ul").prepend(
					'<li mode="manage"><a href="#" onclick="javascript:ExecutiveOffice.goViewManage();">'+Common.getDic("lbl_Setting")+'</a></li>'
				)
			}
			
			if(sessionObj["isAdmin"] == "Y") {
				$(".executiveInfo").closest(".PN_myContents_box").find('.PN_portlet_menu').find("ul").prepend(
					'<li mode="admin"><a href="#" onclick="javascript:ExecutiveOffice.goViewAdmin();">'+Common.getDic("lblAdminSetting")+'</a></li>'
				)
			}
			
			$(".executiveInfo .btn-area").css({ height: "0px", padding: 0, display: "none" });
		}
		else {
			// 버튼 다국어 설정		
			$('#ExManage').text(Common.getDic("lbl_Setting"));
			$('#ExAdmin').text(Common.getDic("lblAdminSetting"));
			
			if (ExecutiveOffice.isManager){ $('#ExManage').show(); }
			else { $('#ExManage').parent().remove(); }
			
			if(sessionObj["isAdmin"] == "Y") { $('#ExAdmin').show(); }
			else { $('#ExAdmin').parent().remove(); }
		}
		
		$(".exeList").css("height", "calc(100% - " + $(".executiveInfo .btn-area").outerHeight() + "px)")
		
		ExecutiveOffice.getOfficerList();
	}	
}