/**
 * exchange - 환율
 */
var exchange = {
	config: {
		clickURL: "https://finance.naver.com/marketindex/",
		apiURL: "https://quotation-api-cdn.dunamu.com/v1/forex/recent?codes=FRX.KRWCNY,FRX.KRWEUR,FRX.KRWUSD,FRX.KRWJPY",
		tempateID: 'temp_exchagne_li_myContents'
	},
	data: [],
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};		
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
	
		this.setEvent();
		this.getExchangeList();
	},
	setEvent: function(){
		// 유형에 따른 이벤트 셋팅
	},
	getExchangeList: function(){
		$.ajax({
			url: "/covicore/control/getExchangeApi.do",
		    data: { connectUrl: this.config.apiURL },
			success: function(data){
				if (data.status=="SUCCESS"){
					exchange.data = data.result.body;
					exchange.render();
				}	
			}
		});
	},
	render: function(){
		$.each(exchange.data, function(_idx, el){
			var change = (el.change == 'FALL') ? 'fall' : (el.change == 'RISE') ? 'increase' : 'maintenance';
			var changeText = (el.change == 'FALL') ? '감소' : (el.change == 'RISE') ? '증가' : '보합'
			var tempHTML = $(document.getElementById(exchange.config.tempateID)).html()
			$("#portalExchangeRate .webpart-content ul").append(tempHTML
				.replace('{change}', change)
				.replace('{country}', el.country)
				.replace('{currencyLowerCase}', el.currencyCode.toLowerCase())
				.replace('{currency}', el.currencyCode)
				.replace('{rate}', el.basePrice.toFixed(2))
				.replace('{change_text}', changeText)
				.replace('{change_price}', el.changePrice.toFixed(2))
				.replace('{change_rate}', (el.signedChangeRate * 100).toFixed(2))
			);
		});
	}
}