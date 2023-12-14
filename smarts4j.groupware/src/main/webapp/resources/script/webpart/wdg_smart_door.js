/**
 * myContents - 마이 컨텐츠 - 자유 게시
 */
var smartDoor ={
	config: {
		webpartID : "",
		location: "seoul",
		baseTimes: [ '2300', '2000', '1700', '1400', '1100', '0800', '0500', '0200' ]
	},
	location: {
		'seoul': { name: '서울', nx: '60', ny: '127'},
		'pusan': { name: '부산', nx: '98', ny: '76' },
		'daegu': { name: '대구', nx: '89', ny: '90' },
		'incheon': { name: '인천', nx: '55', ny: '124' }
	},
	data: {},
	init: function (data,ext, caller, webpartID){
		if (data != null && data != undefined) {
		var _ext = (typeof ext == 'object') ? ext : {};
		smartDoor.config = $.extend(smartDoor.config, _ext);
		smartDoor.config.webpartID = webpartID;
		
		var dataDoor = data[0];

		// 메일
		if(coviUtil.getAssignedBizSection("Mail")){
			$("#"+webpartID+" .portal_smart_swiper .swiper-wrapper")
				.append($("<div>", {"class" : "swiper-slide"})
					.append($("<div>", {"class":"smart_root mail"})
						.append($("<div>", {"class":"smart_content"})
							.append($("<div>",{"class":"greetings"}))
							.append($("<div>",{"class":"notice"})
								.append($("<a>",{"id":"mailCnt","href":"#","html": smartDoor.setMsg("PT_GreetMail",0)}))
							)
						)
					)
				);
			smartDoor.link("#"+webpartID+" .mail .notice a", smartDoor.config.mailUrl);
			smartDoor.getMailCnt(webpartID);
		}

		// 일정
		$("#"+webpartID+" .portal_smart_swiper .swiper-wrapper")
			.append($("<div>", {"class" : "swiper-slide"})
				.append($("<div>", {"class":"smart_root mail_weather"})
					.append($("<div>", {"class":"smart_content"})
						.append($("<div>",{"class":"weather"})
							.append($("<div>",{"class":"icon", "data-weather":"cloud_sun"})
								.append($("<span>",{"class":"blind"}))
							)
							.append($("<div>",{"class":"info"})
								.append($("<strong>"))
								.append($("<em>"))
							)
						)
						.append($("<div>",{"class":"greetings"}))
						.append($("<div>",{"class":"notice"})
							.append($("<a>",{"href":"#","html":smartDoor.setMsg("PT_GreetSchedule",dataDoor[0]["Schedule"])}))
						)
					)
				)
			);
		smartDoor.link("#"+webpartID+" .mail_weather .notice a", smartDoor.config.scheduleUrl);
		
		
		// 결재
		$("#"+webpartID+" .portal_smart_swiper .swiper-wrapper")
			.append($("<div>", {"class" : "swiper-slide"})
				.append($("<div>", {"class":"smart_root approval"})
					.append($("<div>", {"class":"smart_content"})
						.append($("<div>",{"class":"greetings"}))
						.append($("<div>",{"class":"notice"})
							.append($("<a>",{"href":"#","html":smartDoor.setMsg("PT_GreetApproval",dataDoor[0]["Approval"])}))
						)
					)
				)
			);
		smartDoor.link("#"+webpartID+" .approval .notice a", smartDoor.config.approvalUrl);
		

		// 최신게시
		let notice = dataDoor[0]["Notice"]
		if (notice.length>0){
			$("#"+webpartID+" .portal_smart_swiper .swiper-wrapper")
				.append($("<div>", {"class" : "swiper-slide"})
					.append($("<div>", {"class":"smart_root must"})
						.append($("<div>", {"class":"smart_content"})
							.append($("<div>",{"class":"greetings"}))
							.append($("<div>",{"class":"notice"})
								.append($("<a>",{"href":"#","text":notice[0]["Subject"] }))
							)
						)
					)
				);

			$("#"+webpartID+" .must .notice a").on("click", function(){
				smartDoor.openBoardPopup(notice[0]["MenuID"], notice[0]["Version"], notice[0]["FolderID"], notice[0]["MessageID"]) 
			});
		}

		//PT_GreetMsg
		$("#"+webpartID+" .greetings").text(Common.getSession("USERNAME")+coviUtil.getDic("lbl_Sir") + ". "+ coviUtil.getDic("PT_GreetMsg"));

		// 날씨
		// 지역 좌표
		var _location = Common.getBaseCode('WeatherLocation').CacheData;
		if (_location.length > 0){
			smartDoor.location = {};
			$.each(_location, function(idx, el){
				smartDoor.location[el.Code] = {
					name: el.MultiCodeName,
					nx: el.Reserved1,
					ny: el.Reserved2
				}
			});		
		}
		// 날씨데이터 취득
		smartDoor.setData();
		}
		// 오늘도 즐거운 하루 시작하세요~!
	    const mainSmartSwiper = new Swiper(".portal_smart_swiper", {
	        threshold: 5,
	        effect: 'fade',
	        fadeEffect: {
	            crossFade: true
	        },
	        loop: true,
	        autoplay: {
	            delay: 10000,
	            disableOnInteraction: false,
	        },
	        pagination: {
	            el: ".swiper-pagination",
	            clickable: true,
	        }
	    });
	
	    // 오늘도 즐거운 하루 시작하세요~! 자동 플레이 버튼
	    $(document).on('click', '.portal_smart_swiper .swiper-button-play', function () {
	        if ($(this).attr('data-state') === 'stop') {
	            $(this).attr('data-state', 'start');
	            mainSmartSwiper.autoplay.start();
	        } else {
	            $(this).attr('data-state', 'stop');
	            mainSmartSwiper.autoplay.stop();
	        }
	    });
	},
	link: function(tag, url){
		if (url != undefined && url != ""){
			$(tag).attr("href", url);
		}
	},
	openBoardPopup: function(pMenuID, pVersion, pFolderID, pMessageID){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", "Board", pMenuID, pVersion, pFolderID, pMessageID);
		Common.open("", "boardViewPop", coviUtil.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true); // 상세보기
	},
	setData: function(){
		// 현재 날씨
		var _location =  smartDoor.config.location;
		var searchDatetime = CFN_GetLocalCurrentDate('yyyyMMdd HHmm');
		var searchDate = searchDatetime.split(' ')[0];
		var searchTime = searchDatetime.split(' ')[1];
		var _baseTime;
		var isSkipped = false;

		$.each(smartDoor.config.baseTimes, function(idx, el){
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
			_baseTime = smartDoor.config.baseTimes[0];
		}
		
		smartDoor.param = {
			'dataType': 'JSON',
			'numOfRows': '12',
			'pageNo': '1',
			'base_date': searchDate, 
			'base_time' : _baseTime, 
			'nx': smartDoor.location[_location].nx, 
			'ny': smartDoor.location[_location].ny,
			'location': _location,
			'apiType': 'kma'
		}

		$.ajax({
		    type: "POST",
		    url: "/covicore/control/getWeatherApi.do",
		    data: { params: JSON.stringify(smartDoor.param) },
		    success: function(data){
				if(data.result.response.header.resultCode != '00'){
					return false;
				} 
				
				var _result = data.result.response.body.items.item;
				var _weatherData = {}
				$.each(_result, function(idx, el){
					if (idx == 0) {
						_weatherData.date = el.fcstDate;
						_weatherData.time = el.fcstTime;
					}
					
					switch(el.category){
						case 'TMP':
							// 현재기온
							_weatherData.current = el.fcstValue;
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
				smartDoor.setIcon(_weatherData);
				smartDoor.data = _weatherData;
				
				if ( Object.keys(smartDoor.data).length > 0 ){
					$("#"+smartDoor.config.webpartID+" .mail_weather .icon").attr("data-weather",smartDoor.data.icon);
					$("#"+smartDoor.config.webpartID+" .mail_weather .info strong").text(smartDoor.data.current+"°");
					$("#"+smartDoor.config.webpartID+" .mail_weather .info em").text(smartDoor.data.weather);
				}
		    }
		});
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
	setMsg: function(msg,num){
		var msg = Common.getDic(msg);
		msg = msg.replace("<em></em>", "<em>"+num+"</em>");
		return msg;
	},
	getMailCnt:function (webpartID){
		if(gSystemMailCall == null){ // 메일카운트 다시 조회 
			$.ajax({
				url: "/groupware/longpolling/getMailCnt.do",
				type:"post",
				data:{},
				success:function (data) {
					if(data.status == "SUCCESS") {
						 var $con = $("#"+webpartID+" #mailCnt");
				    	$con.find('em').text(data.MailCnt);
					}
				}
			});
		}else if(gSystemMailCall === false){
			setTimeout(smartDoor.getMailCnt,500,webpartID); // 메일카운트 다시 조회
		}else if(gSystemMailCall === true ){
			var $con = $("#"+webpartID+" #mailCnt");
			$con.find('em').text(gPortalMailCount);
		}
	}
}
