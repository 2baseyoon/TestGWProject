/**
 * mainBanner.js - 메인 배너
 */
var mainBanner = {
	config: {
		data: 'manage',		// mamage: 그룹웨어 관리, webpart: 확장JSON
		slideType: 'dots'
	},
	data: [],
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;

		mainBanner.setData(data);
	},
	setData: function(data){
		if (mainBanner.config.data == 'manage'){
			if (data.length>0 && data[0][0].DomainBannerPath != ""){		// 서버에서 데이터가 전달된 경우
				mainBanner.setDomainBannerData(data[0][0]);
				mainBanner.render();
			} else {	// 서버 데이터가 없는 경우 조회
				mainBanner.getPortalBanner(Common.getSession('DN_ID'));
			}
		} else {
			mainBanner.data = mainBanner.config.imageJson;
			mainBanner.render();
		}
	},
	setDomainBannerData: function(data){
		mainBanner.data.length = 0;
		
		var domainBannerPathList = data.DomainBannerPath.split("|");
		var domainBannerLinkList = data.DomainBannerLink.split("|");
		
		var portalBannerPathList = domainBannerPathList[0].split(";");
		var portalBannerLinkList = domainBannerLinkList[0].split(";");

		$(portalBannerPathList).each(function(idx, portalBanner){
			var bannerLink = portalBannerLinkList.length > idx ? portalBannerLinkList[idx] : "";
			if (portalBanner != ""){
				mainBanner.data.push({"href": bannerLink, "target": bannerLink==""?"":"_blank", "src": "/covicore/common/banner/" + portalBanner+".do"});
			}	
		});
	},
	render: function(){
		$("#mainBanner_Container").empty();
		$.each(this.data, function(idx, el){
			$("#mainBanner_Container").append(
				$("#mainBanner_item").html()
					.replace('{link}', (el.href != undefined && el.href != '') ? el.href : "javascript:void(0);" )
					.replace('{target}', (el.target != undefined && el.target != '') ? el.target : "_self" )
					.replace('{imgSrc}', el.src)
			);
		});
		
		if (this.data.length > 1){
			$("#mainBanner_Container").slick({
				arrows: (mainBanner.config.slideType == 'arrows'),
				autoplay: true,
				dots: (mainBanner.config.slideType == 'dots')
			});
		}
	},
	getPortalBanner: function(domainID){
		$.ajax({
			type: "POST",
			data: {
				"DomainID": domainID
			},
			async: true,
			url: "/covicore/domain/get.do",
			success: function(data){
				mainBanner.setDomainBannerData(data.list[0]);
			},
			error: function(response, status, error){
			     CFN_ErrorAjax("/covicore/domain/get.do", response, status, error);
			}
		}).done(function(){
			mainBanner.render();
		});
	}
}