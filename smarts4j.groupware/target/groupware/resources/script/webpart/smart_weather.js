/**
 * smart_weather.js
 */
var smartWeather = {
	config: {
		caller :"",
		preId : "",
		location: "seoul",
		option : "weather",
		baseTimes: [ '2300', '2000', '1700', '1400', '1100', '0800', '0500', '0200' ]
	},
	location: {
		'seoul': { name: '서울;Seoul;Seoul;Seoul;;;;;;;', nx: '60', ny: '127'},
		'pusan': { name: '부산;Pusan;Pusan;Pusan;;;;;;;', nx: '98', ny: '76' },
		'daegu': { name: '대구;Daegu;Daegu;Daegu;;;;;;;', nx: '89', ny: '90' },
		'incheon': { name: '인천;Incheon;Incheon;Incheon;;;;;;;', nx: '55', ny: '124' }
	},
	data: {},
	init: function (data, ext, caller, webPartID) {
		var _ext = (typeof ext == 'object') ? ext : {};
		smartWeather.config = $.extend(smartWeather.config, _ext);
		smartWeather.config.caller = caller;
		smartWeather.config.preId = webPartID!=undefined?"#"+webPartID+" ":"";
		
		// 지역 좌표
		var _location = Common.getBaseCode('WeatherLocation').CacheData;
		if (_location.length > 0){
			smartWeather.location = {};
			$.each(_location, function(idx, el){
				smartWeather.location[el.Code] = {
					name: el.MultiCodeName,
					nx: el.Reserved1,
					ny: el.Reserved2
				}
			});		
		}
		
		// 날짜별로 날씨데이터 초기화
		for (var i = 0; i < 3; i++) {
			var _date = smartWeather.GetLocalCurrentDate('yyyy-MM-dd',i);
			smartWeather.data[_date] = { temperature: {} }
		}
		
		// 날씨데이터 취득
		smartWeather.setData();
	},
	setData: function(target){
		// 현재 날씨
		var _location = (typeof target != 'undefined') ? target.value : smartWeather.config.location;
		smartWeather.config.location = _location;
		var searchDatetime = CFN_GetLocalCurrentDate('yyyyMMdd HHmm');
		var searchDate = searchDatetime.split(' ')[0];
		var searchTime = searchDatetime.split(' ')[1];
		var _baseTime;
		var isSkipped = false;

		$.each(smartWeather.config.baseTimes, function(idx, el){
			var isFinish = false;
			
			if (el < searchTime) {
				isFinish = true;
				if (!isSkipped && 10 > Number(searchTime.right(2))){
					isFinish = false;
					isSkipped = true;
				}
			}
			if (isFinish) {
				_baseTime = el;
				return false;
			}
		})
		if (typeof _baseTime == 'undefined'){
			searchDate = XFN_addMinusDateByCurrDate(-1, '');
			_baseTime = smartWeather.config.baseTimes[0];
		}
		
		smartWeather.param = {
			'dataType': 'JSON',
			'numOfRows': '12',
			'pageNo': '1',
			'base_date': searchDate, 
			'base_time' : _baseTime, 
			'nx': smartWeather.location[_location].nx, 
			'ny': smartWeather.location[_location].ny,
			'location': _location,
			'apiType': 'kma'
		}

		$.ajax({
		    type: "POST",
		    url: "/covicore/control/getWeatherApi.do",
		    data: { params: JSON.stringify(smartWeather.param) },
		    success: function(data){
				if(data.result.response.header.resultCode != '00'){
					return false;
				} 
				
				var _result = data.result.response.body.items.item;
				var _weatherData = { temperature: {} }
				$.each(_result, function(idx, el){
					if (idx == 0) {
						_weatherData.date = el.fcstDate;
						_weatherData.time = el.fcstTime;
					}
					
					switch(el.category){
						case 'TMP':
							// 현재기온
							_weatherData.temperature.current = el.fcstValue;
							break;
						case 'POP':
							// 강수확률
							_weatherData.rainRate = el.fcstValue + '%';
							break;
						case 'WSD':
							// 풍속
							_weatherData.windSpeed = el.fcstValue;
							break;
						case 'VEC':
							// 풍향
							_weatherData.windDirection = el.fcstValue;
							break;
						case 'SKY':
							// 하늘상태
							_weatherData.sky = el.fcstValue;
							break;
						case 'PTY':
							// 강수형태
							_weatherData.rainStatue = el.fcstValue;
							break;
						default:
							break;
					}
				});
				// 오늘 날씨데이터 설정
				smartWeather.setIcon(_weatherData);
				smartWeather.data[smartWeather.GetLocalCurrentDate('yyyy-MM-dd')] = _weatherData;

				// 최고 최저 내일 모레 데이터
				smartWeather.getTemperatureRange();
		    }
		});
	},
	getTemperatureRange: function(){
		var temperatureParam = $.extend({}, smartWeather.param);
		temperatureParam.location = temperatureParam.location + "_minmax" + "_threedays";
		temperatureParam.base_time = '0200'
		temperatureParam.numOfRows = '834'

		$.ajax({
		    type: "POST",
		    url: "/covicore/control/getWeatherApi.do",
		    data: { params: JSON.stringify(temperatureParam) },
		    success: function(data){
				if(data.result.response.header.resultCode != '00'){
					return false;
				} 
				var _result = data.result.response.body.items.item;
				$.each(_result, function(idx, el){
					var _targetDay = new Date(el.fcstDate.left(4), Number(el.fcstDate.substring(4, 6)) - 1, el.fcstDate.right(2)).format('yyyy-MM-dd');
					var _targetWeatherData = smartWeather.data[_targetDay];
					if (typeof _targetWeatherData != 'undefined'){
						switch(el.category){
							case 'TMN':
								// 최저기온
								_targetWeatherData.temperature.low = el.fcstValue;
								break;
							case 'TMX':
								// 최고기온
								_targetWeatherData.temperature.high = el.fcstValue ;
								break;
							case 'SKY':
								// 하늘상태
								if(_targetDay == smartWeather.GetLocalCurrentDate('yyyy-MM-dd')) break;
								_targetWeatherData.sky = el.fcstValue;
								break;
							case 'PTY':
								// 강수형태
								if(_targetDay == smartWeather.GetLocalCurrentDate('yyyy-MM-dd')) break;
								_targetWeatherData.rainStatue = el.fcstValue;
								break;
							default:
								break;
						}
						smartWeather.setIcon(_targetWeatherData);
					}
				});
				smartWeather.render();
		    }
		});
	},
	render: function(){
		var todayData = smartWeather.data[smartWeather.GetLocalCurrentDate('yyyy-MM-dd')];
		var oneDayData = smartWeather.data[smartWeather.GetLocalCurrentDate('yyyy-MM-dd',1)];
		var twoDayData = smartWeather.data[smartWeather.GetLocalCurrentDate('yyyy-MM-dd',2)];

		if (smartWeather.config.caller == "Widget"){
			// 위젯 

			// 도시명
			$(smartWeather.config.preId + " #smart_weather_title").empty().text(CFN_GetDicInfo(smartWeather.location[smartWeather.config.location].name));
			
			// 오늘 최근
			$(smartWeather.config.preId + ".state").attr("data-weather", todayData.icon);
			$(smartWeather.config.preId + ".state").text(todayData.weather);
			$(smartWeather.config.preId + ".temperature strong").text(todayData.temperature.current+"°");
			
			// 오늘 최고, 최저기온
			$(smartWeather.config.preId + ".temperature .max").text(todayData.temperature.high+"°");
			$(smartWeather.config.preId + ".temperature .min").text(todayData.temperature.low+"°");
			
			// 내일 날씨
			$(smartWeather.config.preId + "#smart_weather_content_day1").attr("data-weather", oneDayData.icon);
			$(smartWeather.config.preId + "#smart_weather_content_day1 span").text(oneDayData.weather);
			
			// 모레 날씨
			$(smartWeather.config.preId + "#smart_weather_content_day2").attr("data-weather", twoDayData.icon);
			$(smartWeather.config.preId + "#smart_weather_content_day2 span").text(twoDayData.weather);

		} else {
			if (smartWeather.config.option == "weather"){
				// 날씨 (주간형)
				$(smartWeather.config.preId + ".weather").empty().append($("<div>", {"class" : "now"})
					.append($("<label>", {"class" : "blind", "for":"weather_location_select" , "text":Common.getDic('lbl_Location')}))
					.append($("<select>", {"class" : "ui_select_field selector", "id":"weather_location_select"}))
					.append($("<div>", {"class" : "state" , "data-weather" : todayData.icon, "text":todayData.weather}))
					.append($("<div>", {"class" : "temperature"})
						.append($("<strong>",{"text" : todayData.temperature.current+"°"}))
						.append($("<em>", {"class":"max" , "text":todayData.temperature.high+"°"}))
						.append($("<em>", {"class":"min" , "text":todayData.temperature.low+"°"}))
					)
				)
				.append($("<div>",{"class":"next"})
					.append($("<dl>")
						.append($("<dt>",{"text":Common.getDic('lbl_Mail_Tomorrow')}))
						.append($("<dd>",{"data-weather":oneDayData.icon})
							.append($("<span>",{"text":oneDayData.weather}))
						)
					)
					.append($("<dl>")
						.append($("<dt>",{"text":Common.getDic('lbl_aftertomorrow')}))
						.append($("<dd>",{"data-weather":twoDayData.icon})
							.append($("<span>",{"text":twoDayData.weather}))
						)
					)
				);

				$.each(smartWeather.location, function(idx, item) {
					$(smartWeather.config.preId + "#weather_location_select")
						.append($("<option>",{"value":idx, "text":CFN_GetDicInfo(item.name)}));
						if(smartWeather.config.location == idx) {
							$(smartWeather.config.preId + "#weather_location_select").find("option[value='"+ idx+"']").attr("selected",true);
						}
				});
				$(smartWeather.config.preId + "#weather_location_select").on("change",function(){
					smartWeather.setData(this);
				});
			} else {
				// 날씨 (일간형)
				$(smartWeather.config.preId + ".weather").empty().append($("<div>", {"class" : "main"})
						.append($("<div>", {"class" : "control"})
							.append($("<label>", {"class" : "blind" , "for" : "weather_location_detail_select", "text":Common.getDic('lbl_Location')}))
							.append($("<select>", {"class" : "ui_select_field location" , "id" : "weather_location_detail_select"}))
							.append($("<div>", {"class":"option"})
								.append($("<span>", {"text":Common.getDic('lbl_today_weather')}))
							)
						)
						.append($("<div>",{"class":"temperature"})
							.append($("<div>",{"class":"state" , "data-weather":todayData.icon, "text":todayData.weather}))
							.append($("<div>",{"class":"value"})
								.append($("<strong>",{"text":todayData.temperature.current})
									.append($("<span>",{"text":"°"}))
								)
								.append($("<em>")
									.append($("<span>",{"class":"max","text":todayData.temperature.high+"°"}))
									.append($("<span>",{"class":"min","text":todayData.temperature.low+"°"}))
								)
							)
						)
					)
					.append($("<div>",{"class":"secondary"})
						.append($("<dl>",{"class":"precipitation"})
							.append($("<dt>",{"text":Common.getDic('lbl_precipitation')}))
							.append($("<dd>",{"text":todayData.rainRate}))
						)
						.append($("<dl>",{"class":"wind_direction"})
							.append($("<dt>",{"text":Common.getDic('lbl_WindDirection')}))
							.append($("<dd>",{"text":smartWeather.chgWindDirectionTxt(todayData.windDirection)}))
						)
						.append($("<dl>",{"class":"wind_speed"})
							.append($("<dt>",{"text":Common.getDic('lbl_WindSpeed')}))
							.append($("<dd>",{"text":todayData.windSpeed})
								.append($("<sub>",{"text":"m/s"}))
							)
						)
					)
					.append($("<div>",{"class":"current_location","text":CFN_GetDicInfo(smartWeather.location[smartWeather.config.location].name)}));

					$.each(smartWeather.location, function(idx, item) {
						$(smartWeather.config.preId + "#weather_location_detail_select")
							.append($("<option>",{"value":idx, "text":CFN_GetDicInfo(item.name)}));
							if(smartWeather.config.location == idx) {
								$(smartWeather.config.preId + "#weather_location_detail_select").find("option[value='"+ idx+"']").attr("selected",true);
							}
					});
					$(smartWeather.config.preId + "#weather_location_detail_select").on("change",function(){
						smartWeather.setData(this);
					});
					
			}
		
		
		}
		
	},
	setIcon: function(pWeatherData){
		if (pWeatherData.rainStatue == 0){
			if (pWeatherData.sky == 3){
				pWeatherData.weather = coviUtil.getDic("lbl_cloudy");
				pWeatherData.icon = 'cloud_sun';
			} else if (pWeatherData.sky == 4){
				pWeatherData.weather = coviUtil.getDic("lbl_cloudy_little");
				pWeatherData.icon = 'cloud';
			} else if (pWeatherData.sky == 1){
				pWeatherData.weather = coviUtil.getDic("lbl_sunny");
				pWeatherData.icon = 'sun';
			}
		} else if (pWeatherData.rainStatue == 1){
			pWeatherData.weather = coviUtil.getDic("lbl_rain");
			pWeatherData.icon = 'cloud_rain';
		} else if (pWeatherData.rainStatue == 2){
			pWeatherData.weather = coviUtil.getDic("lbl_rain_snow");
			pWeatherData.icon = 'cloud_snow';
		} else if (pWeatherData.rainStatue == 3){
			pWeatherData.weather = coviUtil.getDic("lbl_snow");
			pWeatherData.icon = 'cloud_snow';
		} else if (pWeatherData.rainStatue == 4){
			pWeatherData.weather = coviUtil.getDic("lbl_shower");
			pWeatherData.icon = 'cloud_rain';
		}
	},	
	chgWindDirectionTxt : function(windDirection){
		// 풍향 숫자를 방향 문자로 변환
		var rateTxt = "";
		var numDirection = Number(windDirection);
		if(numDirection==360) rateTxt ="N";
		else if(numDirection>270) rateTxt = "NW";
		else if(numDirection>269) rateTxt = "W";
		else if(numDirection>180) rateTxt = "SW";
		else if(numDirection>179) rateTxt = "S";
		else if(numDirection>90) rateTxt = "SE";
		else if(numDirection>89) rateTxt = "E";
		else rateTxt = "NE";
		
		return rateTxt;
	},
	GetLocalCurrentDate : function (pDateFormat, pAddDay){
		if (pAddDay == undefined) pAddDay = 0;
		var _date = new Date().add(pAddDay, 'day').format(pDateFormat);
		return _date;		
	}
}