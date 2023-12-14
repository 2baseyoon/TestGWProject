/**
 * smart_exchange.js
 */
var smartExchange = {
	config: {
		apiURL: "https://quotation-api-cdn.dunamu.com/v1/forex/recent?codes=FRX.KRWUSD,FRX.KRWEUR,FRX.KRWCNY,FRX.KRWJPY",
		caller : "",
		preId : "",
		option : "grid"
	},
	data: [],
	init: function (data, ext, caller, webPartID) {
		var _ext = (typeof ext == 'object') ? ext : {};
		smartExchange.config = $.extend(smartExchange.config, _ext);
		smartExchange.config.caller = caller;
		smartExchange.config.preId = webPartID!=undefined?"#"+webPartID+" ":"";
		// 데이터 조회
		smartExchange.getExchangeList();
	},
	getExchangeList: function(){
		$.ajax({
			url: "/covicore/control/getExchangeApi.do",
		    data: { connectUrl: smartExchange.config.apiURL },
			success: function(data){
				if (data.status=="SUCCESS"){
					smartExchange.data = data.result.body;
					smartExchange.render();
				}
			}
		});
	},
	render : function(){
		if (smartExchange.config.caller == "Widget"){
			$.each( smartExchange.data , function(key, exchangeData) {
				//헤더
				if (key == 0){
					$(smartExchange.config.preId + "#smart_exchange_head").closest(".widget_card").find('.action').remove();
					$(smartExchange.config.preId + "#smart_exchange_head .title").after($("<time>", {"class": "extra", "text": smartExchange.getModifiedAtDate(exchangeData.date) + " " +Common.getDic('lbl_Standard')}));
				}

				if(exchangeData.currencyCode == "USD" || exchangeData.currencyCode == "EUR"){
					//통화별 환율
					$(smartExchange.config.preId + "#smart_exchange_content")
					.append($("<dl>", {"class" : smartExchange.getDlClass(exchangeData)})
						.append($("<dt>", {"text" : exchangeData.currencyCode}))
						.append($("<dd>")
							.append($("<span>", {"text" : coviUtil.toAmtFormat(exchangeData.basePrice.toFixed(2))}))
							.append($("<em><span>"))));
				}

			});

		} else { 
			// grid or list
			var widgetExchange = $(smartExchange.config.preId + ".widget_content").empty();
			if(smartExchange.config.option == "grid"){
				// 그리드형
				widgetExchange.append($("<div>",{"class":"grid"}));
				$.each(smartExchange.data, function(i, item) {
					if (i == 0) {
						$(smartExchange.config.preId + ".widget_head .title").after($("<time>", {"class": "extra", "text": smartExchange.getModifiedAtDate(item.date) + " " +Common.getDic('lbl_Standard')}));
					}
					widgetExchange.find(".grid")
						.append($("<dl>", {"class": smartExchange.getDlClass(item)})
							.append($("<dt>",{"text":item.currencyCode}))
							.append($("<dd>")
								.append($("<span>",{"text":coviUtil.toAmtFormat(item.basePrice.toFixed(2))}))
								.append($("<em><span>"))
							)
						);
				});
			} else {
				// 리스트형
				widgetExchange.append($("<div>",{"data-custom-scrollbar":""})
					.append($("<ul>",{"class":"content_list"}))
				);
				$.each(smartExchange.data, function(i, item) {
					if (i == 0) {
						$(smartExchange.config.preId + ".widget_head .title").after($("<time>", {"class": "extra", "text": smartExchange.getModifiedAtDate(item.date) + " " +Common.getDic('lbl_Standard')}));
					}
					widgetExchange.find(".content_list")
						.append($("<li>", {"class": smartExchange.getDlClass(item)})
							.append($("<span>",{"text":item.currencyCode+"/KRW"})
								.append($("<br>"))
								.append(coviUtil.getDic("lbl_exchange_"+item.currencyCode))
							)
							.append($("<strong>",{"text":coviUtil.toAmtFormat(item.basePrice.toFixed(2))}))
							.append($("<em>",{"text":coviUtil.toAmtFormat(item.signedChangePrice.toFixed(2))}))
					);
				});
			}
		}
	},
	getDlClass : function(infodata){
		var dlClass = "";
		dlClass = infodata.currencyCode.toLowerCase();
		if(infodata.signedChangePrice > 0){
			dlClass += " up";
		}else if(infodata.signedChangePrice < 0){
			dlClass += " down";
		}else{
			dlClass += " normal";
		}
		return dlClass;
	},
	getModifiedAtDate : function(modifiedAt){
		// 2022.07.25 형식
		var extModDate = new Date(modifiedAt);
		var extDateStr = schedule_SetDateFormat(extModDate, "."); //날짜포맷변환
		var extDayArr = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
		var extDayStr = Common.getDic("lbl_sch_" + extDayArr[extModDate.getDay()]);
//		var dateTxt = extDateStr + "(" + extDayStr + ")";
		var dateTxt = extDateStr;
		return dateTxt;
	}
}