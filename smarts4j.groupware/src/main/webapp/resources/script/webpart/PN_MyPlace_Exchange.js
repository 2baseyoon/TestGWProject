/**
 * pnExchange - [포탈개선] My Place - 환율게시
 */
var pnExchange = {
	webpartType: "",
	clickURL: "",
	attachFileInfoObj: {},
	init: function(data, ext){
		pnExchange.clickURL = ext.clickURL;
		$("#PN_exchange_link").attr("href", pnExchange.clickURL);
		
		pnExchange.setEvent();
		var urlList = ext.urlList;
		$.each(urlList, function(i, item){
			if(item) pnExchange.getExchangeList(item.URL);
		});
	},
	setEvent: function(){
		$(".PN_exchangeRate").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
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
		
		$(".PN_exchangeRate").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
		
		$(".PN_exchangeRate").on("click", function(){
			window.open(pnExchange.clickURL);
		});
	},
	getExchangeList: function(pUrl){
		$.ajax({
			url: "/covicore/control/getExchangeApi.do",
		    data: { 'connectUrl': pUrl },
			success: function(data){
				if (data.status=="SUCCESS"){
					var i=0;
					$.each(data.result.body, function(key, val) {
						var exchangeInfo = val;
						var liObj = $("li[curcode="+exchangeInfo.currencyCode+"]");
						var exClass = "";
						
						if(exchangeInfo.signedChangePrice > 0){
							exClass = "up";
						}else if(exchangeInfo.signedChangePrice < 0){
							exClass = "down";
						}else{
							exClass = "equal";
						}
						
						liObj.find(".eRate").text(exchangeInfo.basePrice.toFixed(2)).addClass(exClass);
						if (i ==0){
							var strTimezoneDisplay = (Common.getBaseConfig("useTimeZone") == "Y") ? Common.getSession("UR_TimeZoneDisplay") : '(GMT)'
							var exchageDate = exchangeInfo.modifiedAt.split("T");
							var nowDate = new Date(exchageDate[0]);
							var nowDateStr = CFN_TransLocalTime(schedule_SetDateFormat(nowDate, "."));
							var nowDay = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
							var nowDayStr = Common.getDic("lbl_sch_" + nowDay[nowDate.getDay()]);
							
							$(".PN_exchangeRate .eDate").text(nowDateStr + " (" + nowDayStr + ") " + CFN_TransLocalTime(exchageDate[1]).substring(0,8)+ " " + strTimezoneDisplay);
						}
						i++;
					});
				}	
			}
		});
	}
}