var weather = {
	config: {
		today: CFN_GetLocalCurrentDate('yyyy-MM-dd'),
		type: 'List',
		period: 3,									// 기상청 기준, 3일이후 데이터는 중기예보 api 사용해야함. 별도의 api가 필요..
		multiLocation: false,
		title: 'Y',
		webpartClassName: 'PN_weatherBox',			// 웹파트 최상단 div 클래스명
		webpartTopClassName: 'PN_TitleBox',			// 웹파트 톱영역 클래스명
		webpartContentClassName: 'PN_todayweather',				// 웹파트 컨텐츠영역 클래스명
		location: {
			type: 'selectbox',
			position: 'top'
		},
		weatherClass: 'tWeather',
		api: {
			source: 'kma',
			timeDelay: 10,
			baseTimes: [ '2300', '2000', '1700', '1400', '1100', '0800', '0500', '0200' ]
		}
	},
	location: {			// 사용하는 api에 따라 달라짐. 기상청 단기예보 격자 위경도 자료 참고하여 추가
		'seoul': { name: '서울', nx: '60', ny: '127'},
		'pusan': { name: '부산', nx: '98', ny: '76' },
		'daegu': { name: '대구', nx: '89', ny: '90' },
		'incheon': { name: '인천', nx: '55', ny: '124' },
		'gwangju': { name: '광주', nx: '58', ny: '74' },
		'daejeon': { name: '대전', nx: '67', ny: '100' },
		'ulsan': { name: '울산', nx: '102', ny: '84' }
	},
	data: {
//		'2023-01-01': { date: '1.1', day: '월', weather: 'Clear', temperature: { low: 3, high: 8, type: 'C' }, rainRate: '', humid: '' },
//		'2023-01-02': { date: '1.2', day: '화', weather: 'Clouds', temperature: { low: -8, high: -4, type: 'C' } },
//		'2023-01-03': { date: '1.3', day: '수', weather: 'Snow', temperature: { low: -5, high: -2, type: 'C' } },
//		'2023-01-04': { date: '1.4', day: '목', weather: 'Rain', temperature: { low: -1, high: 5, type: 'C' } },
//		'2023-01-05': { date: '1.5', day: '금', weather: 'Clear', temperature: { low: 3, high: 8, type: 'C' } },
//		'2023-01-06': { date: '1.6', day: '토', weather: 'Clear', temperature: { low: 3, high: 8, type: 'C' } },
//		'2023-01-07': { date: '1.7', day: '일', weather: 'Clear', temperature: { low: 3, high: 8, type: 'C' } }
	},
	init: function(data, ext, caller){
		weather.caller = caller;

		var _ext = (typeof ext == 'object') ? ext : {};
		weather.config = $.extend(weather.config, _ext);
		
		if (weather.config.period > 3) weather.config.period = 3; 	// 기상청 기준, 3일이후 데이터는 중기예보 api 사용해야함. 별도의 api가 필요.. 3일 이상으로 설정한 경우 3일까지만 처리
		
		if (weather.config.title == 'Y') $("#weather .webpart-top").show();
		
		$("#weather.webpart").addClass(weather.config.webpartClassName);
		$("#weather .webpart-top").addClass(weather.config.webpartTopClassName);
		$("#weather .webpart-content").addClass(weather.config.webpartContentClassName);
		
		var _location = Common.getBaseCode('WeatherLocation').CacheData;
		if (_location.length > 0){
			weather.location = {};
			$.each(_location, function(idx, el){
				weather.location[el.Code] = {
					name: el.MultiCodeName,
					nx: el.Reserved1,
					ny: el.Reserved2
				}
			});		
		}

		if (weather.config.location.position == 'top'){
			$("#weather .webpart-top").append('<div class="weather-location ptype02_weather_select_box"></div>')
		}
		
		$("#weather .weather-location").html('<select class="weather-location-selectbox selectType02" id="weatherGroups" onchange="javascript:weather.setData(this);"></select>')
		$.each(weather.location, function(idx, el){
			$("#weather .weather-location-selectbox").append(
				'<option value="'+idx+'">'+ CFN_GetDicInfo(el.name, Common.getSession('lang')) +'</option>'
			)
		});
		
		if (weather.config.type == 'Select2'){
			$("#weather .webpart-content").append('<div class="Weather_sel"></div>');
			$("#weather .weather-location-selectbox").appendTo($("#weather .webpart-content .Weather_sel"));
		}
		
		if (weather.config.type == 'Icon'){
			$("#weather .ptype02_sday").addClass(weather.config.webpartWrapClassName);
		}
		
		for (var i = 0; i < weather.config.period; i++) {
			var _date = new Date().add(i, 'day').format('yyyy-MM-dd');
			weather.data[_date] = { temperature: {} }
		}
		weather.setUI();
		weather.setData();
	},
	setData: function(target){		// 사용하는 api에 따라 달라짐. 기상청 단기예보 기준
		var _location = (typeof target != 'undefined') ? target.value : $("#weather .weather-location-selectbox").val();
		var searchDatetime = CFN_GetLocalCurrentDate('yyyyMMdd HHmm');
		var searchDate = searchDatetime.split(' ')[0];
		var searchTime = searchDatetime.split(' ')[1];
		var _baseTime;
		var isSkipped = false;
		$.each(weather.config.api.baseTimes, function(idx, el){
			var isFinish = false;
			
			if (el < searchTime) {
				isFinish = true;
				if (!isSkipped && weather.config.api.timeDelay > Number(searchTime.right(2))){
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
			_baseTime = weather.config.api.baseTimes[0];
		}
		
		weather.param = {			
			'dataType': 'JSON',
			'numOfRows': '12',
			'pageNo': '1',
			'base_date': searchDate, 
			'base_time' : _baseTime, 
			'nx': weather.location[_location].nx, 
			'ny': weather.location[_location].ny,
			'location': _location,
			apiType: weather.config.api.source
		}

		$.ajax({
		    type: "POST",
		    url: "/covicore/control/getWeatherApi.do",
		    data: { params: JSON.stringify(weather.param) },
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
							_weatherData.temperature.current = el.fcstValue;
							break;
						case 'POP':
							_weatherData.rainRate = el.fcstValue + '%';
							break;
						case 'REH':
							_weatherData.humidRate = el.fcstValue + '%';
							break;
						case 'SKY':
							_weatherData.sky = el.fcstValue;
							break;
						case 'PTY':
							_weatherData.rainStatue = el.fcstValue;
							break;
						case 'WSD':
							_weatherData.windSpeed = el.fcstValue + 'm/s';
							break;
						case 'TMN':
							_weatherData.temperature.low = el.fcstValue;
							break;
						case 'TMX':
							_weatherData.temperature.high = el.fcstValue;
							break;
						default:
							break;
					}
				});
				
				weather.setIcon(_weatherData);
				weather.data[weather.config.today] = _weatherData;
		    }
		}).done(function(){
			if (weather.config.type == 'Select2' || weather.config.type == 'List'){
				weather.getTemperatureRange();
			} else {
				weather.render();
			}
		});
	},
	getTemperatureRange: function(){
		var temperatureParam = $.extend({}, weather.param);
		temperatureParam.location = temperatureParam.location + "_minmax" + "_short";
		temperatureParam.base_time = '0200'
		temperatureParam.numOfRows = (weather.config.period == 2) ? '544' : (weather.config.period > 2) ? '834' : '254'
		// 기상청 기준, 단기예보에 오늘,내일,모레 데이터가 있음. (사단위 예보 -> 데이터를 해당 일자에 대해 전부 가져와서 최고/최저기온을 저장함. 02시발표 데이터에 해당 값이 있음.)

		$.ajax({
		    type: "POST",
		    url: "/covicore/control/getWeatherApi.do",
		    data: { params: JSON.stringify(temperatureParam) },
		    success: function(data){
				try{
					if(data.result.response.header.resultCode != '00'){
						Common.Warning('날씨 API의 응답에 오류가 있습니다. 오류코드 ['+data.result.response.header.resultCode+']', "Warning Dialog", null);
						return false;
					} 
					
					var _result = data.result.response.body.items.item;
					$.each(_result, function(idx, el){
						var _targetDay = new Date(el.fcstDate.left(4), Number(el.fcstDate.substring(4, 6)) - 1, el.fcstDate.right(2)).format('yyyy-MM-dd');
						var _targetWeatherData = weather.data[_targetDay];
						if (typeof _targetWeatherData != 'undefined'){
							switch(el.category){
								case 'TMN':
									_targetWeatherData.temperature.low = el.fcstValue;
									break;
								case 'TMX':
									_targetWeatherData.temperature.high = el.fcstValue ;
									break;
								case 'SKY':
									_targetWeatherData.sky = el.fcstValue;
									break;
								case 'PTY':
									_targetWeatherData.rainStatue = el.fcstValue;
									break;
								default:
									break;
							}
							
							if (weather.config.type == 'List'){
								weather.setIcon(_targetWeatherData);
							}
						}
					});
					
					if (weather.config.period > 3){
						weather.getTemperatureRangeLong();
					} else {
						weather.render();
					}
				}
				catch(e){
					Common.Warning('날씨 정보에 오류가 있습니다.', "Warning Dialog", null);
				}
		    }
		});
	},
	getTemperatureRangeLong: function(){
		// 기상청 기준, 3일이후 데이터는 중기예보 api 사용해야함. 별도의 api가 필요.. 3일 이상으로 설정한 경우 3일까지만 처리
	},
	setUI: function(){
		if (weather.config.type == 'List'){
			if ($("#weather .webpart-content ul").length == 0) {
				$("#weather .webpart-content").html('<div class="PN_weather_box"><div class="PN_week scrollVType01"><ul></ul></div></div>');
				coviCtrl.bindmScrollV($("#weather .PN_week"));
			}
		} else if (weather.config.type == 'Select1'){
			$(".weather-location-selectbox").parent().before(
				'<a class="ptype02_tab_normal" href="#">'+
					'<span>'+
						$(".weather-location-selectbox").closest(".webpart-top").find("h2").text()+
					'</span>'+
				'</a>'
			);
			$(".weather-location-selectbox").closest(".webpart-top").find("h2").remove();
			$("#weather .weather-location-selectbox").addClass('ptype02_weather_select');			
		} else if (weather.config.type == 'Select2'){
			$("#weather .webpart-content .WeatherCont, #weather .webpart-content .weather_condition").remove();
		}
	},
	render: function(){
		if (weather.config.type == 'List'){
			var _week = ['월', '화', '수', '목', '금', '토', '일']
			
			$.each(weather.data, function(idx, el){
				var _date = new Date(idx);
				var _type = (el.temperature.type == 'F') ? '&#8457;' : '&#8451;';
				if (Object.keys(el.temperature).length > 0){
					$("#weather .webpart-content ul").append(
						$("#templateWeatherList").html()
							.replace('{date}', _date.format('M.d'))
							.replace('{day}', _week[_date.getDay()])
							.replace('{weather}', el.icon)
							.replace('{tempLow}', el.temperature.low)
							.replace('{tempHigh}', el.temperature.high)
							.replace(/{type}/g, _type)
					);
				}
			});
		} else if (weather.config.type == 'Icon'){
			var _weatherData = weather.data[weather.config.today];	
			if (Object.keys(_weatherData.temperature).length > 0){
				$("#weather .webpart-content").append(
					$("#templateWeatherIcon").html()
						.replace('{temperature}', _weatherData.temperature.current)
						.replace('{weatherIcon}', _weatherData.icon)
				);
			}
			
		} else if (weather.config.type == 'Select1'){
			var _weatherData = weather.data[weather.config.today];
			if (Object.keys(_weatherData.temperature).length > 0){
				$("#weather .webpart-content").html(
					$("#templateWeatherSelect1").html()
						.replace('{temperature}', _weatherData.temperature.current)
						.replace('{rainRate}', _weatherData.rainRate)
						.replace('{humidRate}', _weatherData.humidRate)
						.replace('{weather}', _weatherData.weather)
						.replace('{weatherIcon}', _weatherData.icon)
				);
			} else {
				$("#weather .webpart-content").html(
					'<table border="0" cellspacing="0" cellpadding="0">' +
         			'	<tbody>'+
              		'		<tr>'+
                  	'			<td class="wp_none ptype02_wp_none">'+Common.getDic('msg_ComNoData')+'</td>'+
					'		</tr>'+
         			'	</tbody>'+
         			'</table>'
				);
			}
			
		} else if (weather.config.type == 'Select2'){
			var _weatherData = weather.data[weather.config.today];
			var _week = ['월', '화', '수', '목', '금', '토', '일']
			var _date = new Date(_weatherData.date.left(4), Number(_weatherData.date.substring(4, 6)) - 1, _weatherData.date.right(2), _weatherData.time.left(2), _weatherData.time.right(2));

			if (Object.keys(_weatherData.temperature).length > 0){
				$("#weather .webpart-content").append(
					$("#templateWeatherSelect2").html()
						.replace('{date}', _date.format('M월 d일({w})').replace('{w}', _week[_date.getDay()]))
						.replace('{time}', _date.format('HH:mm'))
						.replace('{weather}', _weatherData.weather)
						.replace('{temperature}', _weatherData.temperature.current)
						.replace('{tempLow}', Math.round(Number(_weatherData.temperature.low)))
						.replace('{tempHigh}', Math.round(Number(_weatherData.temperature.high)))
						.replace('{humidRate}', _weatherData.humidRate)
						.replace('{windSpeed}', _weatherData.windSpeed)
						.replace('{weatherIcon}', _weatherData.icon)
				);
			}
		}
	},
	setIcon: function(pWeatherData){
		if (weather.config.type == 'Select1' || weather.config.type == 'Select2'){
			if (pWeatherData.rainStatue == 0){
				if (pWeatherData.sky == 3){
					pWeatherData.weather = '구름많음';
					pWeatherData.icon = 'ico_weather02';
				} else if (pWeatherData.sky == 4){
					pWeatherData.weather = '흐림';
					pWeatherData.icon = 'ico_weather03';
				} else if (pWeatherData.sky == 1){
					pWeatherData.weather = '맑음';
					pWeatherData.icon = 'ico_weather01';
				}
			} else if (pWeatherData.rainStatue == 1){
				pWeatherData.weather = '비';
				pWeatherData.icon = 'ico_weather05';
			} else if (pWeatherData.rainStatue == 2){
				pWeatherData.weather = '비/눈';
				pWeatherData.icon = 'ico_weather06';
			} else if (pWeatherData.rainStatue == 3){
				pWeatherData.weather = '눈';
				pWeatherData.icon = 'ico_weather07';
			} else if (pWeatherData.rainStatue == 4){
				pWeatherData.weather = '소나기';
				pWeatherData.icon = 'ico_weather05';
			}
		} else if (weather.config.type == 'Icon'){
			if (pWeatherData.rainStatue == 0){
				if (pWeatherData.sky == 3){
					pWeatherData.weather = '구름많음';
					pWeatherData.icon = 'ic_weather02';
				} else if (pWeatherData.sky == 4){
					pWeatherData.weather = '흐림';
					pWeatherData.icon = 'ic_weather02';
				} else if (pWeatherData.sky == 1){
					pWeatherData.weather = '맑음';
					pWeatherData.icon = 'ic_weather01';
				}
			} else if (pWeatherData.rainStatue == 1){
				pWeatherData.weather = '비';
				pWeatherData.icon = 'ic_weather03';
			} else if (pWeatherData.rainStatue == 2){
				pWeatherData.weather = '비/눈';
				pWeatherData.icon = 'ic_weather04';
			} else if (pWeatherData.rainStatue == 3){
				pWeatherData.weather = '눈';
				pWeatherData.icon = 'ic_weather04';
			} else if (pWeatherData.rainStatue == 4){
				pWeatherData.weather = '소나기';
				pWeatherData.icon = 'ic_weather03';
			}
		}
		else if (weather.config.type == 'List'){
			if (pWeatherData.rainStatue == 0){
				if (pWeatherData.sky == 3){
					pWeatherData.weather = '구름많음';
					pWeatherData.icon = 'tWeather01';
				} else if (pWeatherData.sky == 4){
					pWeatherData.weather = '흐림';
					pWeatherData.icon = 'tWeather04';
				} else if (pWeatherData.sky == 1){
					pWeatherData.weather = '맑음';
					pWeatherData.icon = 'tWeather02';
				}
			} else if (pWeatherData.rainStatue == 1){
				pWeatherData.weather = '비';
				pWeatherData.icon = 'tWeather05';
			} else if (pWeatherData.rainStatue == 2){
				pWeatherData.weather = '비/눈';
				pWeatherData.icon = 'tWeather06';
			} else if (pWeatherData.rainStatue == 3){
				pWeatherData.weather = '눈';
				pWeatherData.icon = 'tWeather06';
			} else if (pWeatherData.rainStatue == 4){
				pWeatherData.weather = '소나기';
				pWeatherData.icon = 'tWeather08';
			}
		}
	}
}