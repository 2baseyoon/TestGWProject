/**
 * bnr_banner.js - 배너
 */

var portalBanner = {
	init: function(data, ext, pType, pWebpartID){
		var $targetDiv = $("#"+pWebpartID+" .swiper");
		
		if (data.length>0 && data[0][0].DomainBannerPath != "") {
			$targetDiv.empty();
			
			var domainBannerPathList = data[0][0].DomainBannerPath.split("|");
			var domainBannerLinkList = data[0][0].DomainBannerLink.split("|");
			
			var portalBannerPathList;
			var portalBannerLinkList;
			
			if(pType == "Portal") {
				if(domainBannerPathList[0].replaceAll(";", "") == "") {
					$("#"+pWebpartID+" .portal_banner").remove();
					return;
				}
				
				portalBannerPathList = domainBannerPathList[0].split(";");
				portalBannerLinkList = domainBannerLinkList[0].split(";");
			} else if(pType == "Contents") {
				portalBannerPathList = domainBannerPathList.length == 2 ? domainBannerPathList[1].split(";") : "";
				portalBannerLinkList = domainBannerLinkList.length == 2 ? domainBannerLinkList[1].split(";") : "";
			}
			
			$(portalBannerPathList).each(function(idx, portalBannerPath) {
				var bannerLink = portalBannerLinkList.length>idx?portalBannerLinkList[idx]:"";
				if (portalBannerPath != "") {
					var photoPath = "/covicore/common/banner/" + portalBannerPath +".do";

					$targetDiv.append($("<div>", {"class" : "swiper-slide"})
						.append($("<a>",{"href" : bannerLink, "target" : "_blank","class":pType == "Contents"?"slide_item":""})
							.append($("<img>", {"src" : photoPath, "onerror" : "coviCmn.imgError(this, false)"}))
						)
					);
				}
			});
		}
		if (pType != "Contents"){
			gwWpSwiper[pWebpartID] = coviUtil.drawSwiper(pWebpartID, {"slidesPerGroup":1,"pagination":true,"autoplay":true,"paginationMode":"button"});
			//닫기
		    $(document).on('click', "#"+pWebpartID+" .portal_banner .close", function () {
		    	$("#"+pWebpartID+" .portal_banner").remove();
		    });
		}
	    // 가이드 자동 플레이 버튼
	    $(document).on('click', "#"+pWebpartID+" .swiper .swiper-button-play", function () {
	        if ($(this).attr('data-state') === 'stop') {
	            $(this).attr('data-state', 'start');
	            gwWpSwiper[pWebpartID].autoplay.start();
	        } else {
	            $(this).attr('data-state', 'stop');
	            gwWpSwiper[pWebpartID].autoplay.stop();
	        }
	    });
	}
}