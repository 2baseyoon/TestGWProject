/**
 * pnLastDraft - [포탈개선] My Place - 최근 결재 양식
 */
var pnLastDraft = {
	webpartType: "", 
	init: function (data, ext){
		pnLastDraft.setEvent();
		pnLastDraft.getLastDraftList();
	},
	setEvent: function(){
		$(".PN_useForm").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
			if(!$(this).hasClass("active")){
				$(this).addClass("active");
				$(this).next(".PN_portlet_menu").stop().slideDown(300);
				$(this).children(".PN_portlet_btn > span").addClass("on");
			}else{
				$(this).removeClass("active");
				$(this).next(".PN_portlet_menu").stop().slideUp(300);
				$(this).children(".PN_portlet_btn > span").removeClass("on");
			}
		});

		$(".PN_useForm").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
	},
	getLastDraftList: function(){
		$.ajax({
			type: "POST",
			url: "/groupware/pnPortal/selectLastestUsedFormList.do",
			data: "",
			success: function(data){
				if(data.status == "SUCCESS"){
					var listData = data.list;
					var formHtml = "";
					var lang = Common.getSession("lang");
					
					if(listData.length > 0){
						$.each(listData, function(idx, item){
							var liWrap = $("<li></li>");
							if(idx == 3) return false;
							
							liWrap.append($("<a href='#'></a>")
									.attr("onclick", "pnLastDraft.clickPopup(" + item.FormID + ", '" + item.FormPrefix + "')")
									.append($("<span class='uIcon'></span>"))
									.append($("<span class='uTitle'></span>").text(CFN_GetDicInfo(item.FormName, lang)))
									.append($("<span class='uDate'></span>").text(CFN_TransLocalTime(item.EndDate))));
							
							formHtml += $(liWrap)[0].outerHTML;
						});
						
						$(".PN_useForm ul").empty().append(formHtml);
					}else{
						$(".PN_useForm").hide();
						$(".PN_useForm").closest(".PN_portlet_contents").find(".PN_nolist").show();
					}
				}else{
					Common.Warning(data.message);
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/approval/getLastestUsedFormListData.do", response, status, error);
			}
		});
	},
	clickPopup: function(FormID, FormPrefix){
		var width = "790";
		
		if(IsWideOpenFormCheck(FormPrefix)){
			width = "1070";
		}else{
			width = "790";
		}
		
		CFN_OpenWindow("/approval/approval_Form.do?formID=" + FormID + "&mode=DRAFT", "", width, (window.screen.height - 100), "resize", "false");
	}
}