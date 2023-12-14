/**
 * pnSiteLink - [포탈개선] My Place - 사이트링크
 */
var pnSiteLink = {
	webpartType: "",
	attachFileInfoObj: {},
	init: function (data, ext){
		pnSiteLink.setEvent();
		pnSiteLink.getSiteLinkList();
	},
	setEvent: function(){
		$(".PN_siteLink").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
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
		
		$(".PN_siteLink").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
		
		$(".PN_siteLink").closest(".PN_portlet").find(".PN_nolist .PN_btnType01").on("click", pnSiteLink.openAddSiteLinkPopup);
		
		$(".PN_siteLink").closest(".PN_portlet").find(".PN_portlet_menu li[mode=write]").on("click", pnSiteLink.openAddSiteLinkPopup);
		
		$(".PN_siteLink").closest(".PN_portlet").find(".PN_portlet_menu li[mode=config]").on("click", pnSiteLink.openSiteLinkListPopup);
	},
	getSiteLinkList: function(){
		
		$.ajax({
			url: "/groupware/pnPortal/selectSiteLinkWebpartList.do",
			type: "POST",
			success: function(data){
				if(data.status == "SUCCESS"){
					if(data && data.list.length > 0){
						var listData = data.list;
						var linkHtml = "";
						
						$.each(listData, function(idx, item){
							var liWrap = $("<li></li>");
							
							liWrap.append($("<a target='_blank'></a>").attr("href", item.SiteLinkURL)
										.append($("<span class='sImg'></span>"))
										.append($("<span class='sTxt'></span>").text(item.SiteLinkName)));
							
							if(item.Thumbnail != "" && item.Thumbnail != undefined){
								var imgpath = coviCmn.loadImage("/" + item.Thumbnail);
								liWrap.find(".sImg").append($("<img/>").attr("src", imgpath));
							}else{
								liWrap.find(".sImg").append($("<img/>").attr("src", "/HtmlSite/smarts4j_n/customizing/ptype05/images/project/noimg01.jpg"));	
							}
							
							if(data.list.length > 5){
								coviCtrl.bindmScrollV($('.PN_siteLink'));
							};
							
							linkHtml += $(liWrap)[0].outerHTML;
						});
						
						$(".PN_siteLink ul").empty().append(linkHtml);
						$(".PN_siteLink").show();
						$(".PN_siteLink").closest(".PN_portlet_contents").find(".PN_nolist").hide();
					}else{
						$(".PN_siteLink").hide();
						$(".PN_siteLink").closest(".PN_portlet_contents").find(".PN_nolist").show();
					}
				}else{
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생하였습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/task/getTaskData.do", response, status, error);
			}
		});
	},
	openSiteLinkListPopup: function(){
		Common.open("", "SiteLink", "<spring:message code='Cache.lbl_SiteLink'/>", "/groupware/pnPortal/goSiteLinkListPopup.do?returnMode=Webpart&popupID=SiteLink", "500px", "500px", "iframe", true, null, null, true); // 사이트링크
	},
	openAddSiteLinkPopup: function(){
		Common.open("", "SiteLinkAdd", "<spring:message code='Cache.lbl_AddSiteLink'/>", "/groupware/pnPortal/goSiteLinkAddPopup.do?mode=Add&callBackFunc=pnSiteLink.getSiteLinkList", "500px", "240px", "iframe", true, null, null, true); // 사이트링크 추가
	}
}