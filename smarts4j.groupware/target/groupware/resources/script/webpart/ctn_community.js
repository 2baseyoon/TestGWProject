/**
 * MyContents : 인기 커뮤니티
 */
var ctnCommunity = {
	init: function (data, ext, caller, webPartID) {
		ctnCommunity.getCommunityList(webPartID);
	},
	// 커뮤니티정보 조회
	getCommunityList : function(webPartID) {
		var preId = webPartID!=undefined?"#"+webPartID+" ":"";
		var pButton = coviUtil.isMobile()?"Y":"P";
		var $targetDiv = $(coviUtil.webpartSwiper(preId+".widget_community", 3, 5000, -1 , pButton , "Y", "widget_community"));

		$.ajax({
			type:"POST",
			url:"/groupware/layout/selectCommunityDataWebpart.do",
			data: {},
			success:function(data) {
				if(data.status == "SUCCESS"){
					var list = data.data;
					if(list.length > 0){
						$.each(list, function(i, item) {
							$targetDiv.append($("<div>", {"class" : "swiper-slide"})
									 .append(ctnCommunity.displayCommunityInfo(item))
								);
						});
					}
					var noDataMsg = coviUtil.isMobile()?mobile_comm_getDic("msg_NoDataList"):Common.getDic("msg_NoDataList");
					coviUtil.webpartDrawEmpty(list, "Contents", webPartID, noDataMsg);
					
								
					if (coviUtil.isMobile()){
						new Swiper(".widget_community_swiper", {
						        allowTouchMove: false,
						        effect: 'fade',
						        fadeEffect: {
						            crossFade: true
						        },
						        pagination: {
						            el: ".swiper-pagination",
						        },
						        navigation: {
						            nextEl: ".widget_community_button_next",
						            prevEl: ".widget_community_button_prev",
						        }
						});
					} else {
						const widgetCommunitySwiper = new Swiper(".widget_community_swiper", {
					        threshold: 5,
					        effect: 'fade',
					        fadeEffect: {
					            crossFade: true
					        },
					        loop: true,
					        pagination: {
					            el: '.swiper-pagination',
					            clickable: true,
					        }
						});
					}


				} // status
			}
		});
	},
	// 커뮤니티 정보  표시
	displayCommunityInfo: function(cData) {
		var imgpath = ''; var errorFunc= ''; 
		if(cData.FilePath != null && cData.FilePath != ''){
			if (coviUtil.isMobile()){
				imgpath = mobile_comm_getimg(cData.FilePath);
				errorFunc = "this.onerror=null; this.src='/HtmlSite/smarts4j_n/covicore/resources/images/common/img_main_banner.jpg'";
			}else{
				imgpath = coviCmn.loadImage(cData.FilePath);
				errorFunc = "this.onerror=null; this.src='/HtmlSite/smarts4j_n/covicore/resources/images/common/img_main_banner.jpg'";
			}
		}else{
			imgpath = '/HtmlSite/smarts4j_n/covicore/resources/images/common/img_main_banner.jpg';
		}
		var rtnTags = $("<div>", {"class" : "community_item"});
		rtnTags.append($("<div>", {"class" : "preview"})
					.append($("<img>", {"src" : imgpath , "onerror": errorFunc  , "alt":"image"}))
				)
				.append($("<div>", {"class" : "info"})
					.append($("<h4>")
						.append($("<em>", {"text" : cData.CategoryName}))
						.append($("<strong>", {"text" : cData.CommunityName}))
					)
					.append($("<span>", {"class" : "count", "text" : cData.MemberCNT}))
				)
				.append($("<a>", {"href" : "#", "class" : "link" }).on("click", function(){
						ctnCommunity.goUserCommunity( cData.CU_ID )})
				)
		return rtnTags;
	},
	// 커뮤니티 팝업 표시
	goUserCommunity:function(cID){
		if (coviUtil.isMobile()){
			var sUrl = "/groupware/mobile/community/home.do";
			sUrl += "?cuid=" + cID;
			mobile_comm_go(sUrl);
		} else {
			var specs = "left=10,top=10,width=1050,height=900";
			specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
			window.open("/groupware/layout/userCommunity/communityMain.do?C="+cID, "community", specs);			
		}
	}
}