/**
 * 
 */

var worldTime = {
	timer: '',
	config: {
		type: 'Card',			// 웹파트 표시 유형	Card/List/Selectable/Fixed
		currentCountry: 'ko',	// 기초코드 'GlobalTime'의 Reserved1 중 1
		currentCity: 'Asia/Seoul',	// 기초코드 'GlobalTime'의 Code 중 1
		cityClassName: 'ptype02_c_t03',
		citySelectClassName: 'ptype02_c_select',
		dateTimeClassName: 'ptype02_c_t04',
		preId:'',
		selectedCountry: 'us', // 표시할 나라 기초코드 'GlobalTime'의 Reserved1 중 1
		selectedCity: 'America/Los_Angeles' // 표시할 나라 기초코드 'GlobalTime'의 Code 중 1 
	},
	
	timezone: {
		/* 시간존
		Intl.supportedValuesOf('timeZone')		//IannaTimeZones
		*/
		'ko': { name: '대한민국;South Korea;South Korea;South Korea;;;;;;;', zone: { 'Asia/Souel': '서울;Seoul;Seoul;Seoul;;;;;;;' } },
		'us': { name: '미국;USA;USA;USA;;;;;;;', zone: { 'America/Los_Angeles': 'LA;LA;LA;LA;;;;;;;' } }
	},				// 타임존 객체 { name: 국가코드, zone: { 타임존코드1: 도시명1 ... } ... }
	extDayArr : ["sun", "mon", "tue", "wed", "thu", "fri", "sat"],
	exeDataName : [Common.getDic("lbl_sch_sun"), Common.getDic("lbl_sch_mon"), Common.getDic("lbl_sch_tue"), Common.getDic("lbl_sch_wed"), Common.getDic("lbl_sch_thu"), Common.getDic("lbl_sch_fri"), Common.getDic("lbl_sch_sat")],
	init: function(data, ext, caller, webPartID){
		worldTime.preId = webPartID!=undefined?"#"+webPartID+" ":"";
		var _ext = (typeof ext == 'object') ? ext : {};
		worldTime.caller = caller;
		
		worldTime.config = $.extend(worldTime.config, _ext);
		
		if(worldTime.caller == 'myPlace'){
			$("#worldTime.webpart").closest(".PN_myContents_box").find(".PN_portlet_link").text($("#worldTime .webpart-top h2").text());
			$("#worldTime .webpart-top").remove();
		}
		
		if(worldTime.caller == 'myContents'){
			$("#worldTime .webpart-top h2").replaceWith('<h3>'+ $("#worldTime .webpart-top h2").text() +'</h3>');
		}
		
		var _timezone = Common.getBaseCode('GlobalTime').CacheData;
		if (_timezone.length > 0){
			worldTime.timezone = {};
			$.each(_timezone, function(idx, el){
				if (typeof worldTime.timezone[el.Reserved1] == 'undefined'){
					worldTime.timezone[el.Reserved1] = {
						name: el.Reserved2,
						zone: {}
					}
				}
				worldTime.timezone[el.Reserved1].zone[el.Code] = el.MultiCodeName;
			});		
		}
		
		if (worldTime.config.type == 'Card'){
			$("#worldTime.webpart").addClass("Worldtime");
				
			$("#worldTime .seoul_time_wrap").append(
				$("#tempateWorldTimeCard").html()
					.replace('{country}', CFN_GetDicInfo(worldTime.timezone[worldTime.config.currentCountry].name, Common.getSession('lang')))
					.replace('{city}', CFN_GetDicInfo(worldTime.timezone[worldTime.config.currentCountry].zone[worldTime.config.currentCity], Common.getSession('lang')))
			);
			
			$("#worldTime .select_time_wrap").append(
				$("#tempateWorldTimeCard").html()
					.replace('{country}', '')
					.replace('{city}', '')
			);
			$("#worldTime .select_time_wrap .tx_country").addClass('sel_country');
			$("#worldTime .select_time_wrap .tx_city").addClass('sel_city');
			
			worldTime.setCountry();
		}
		else if (worldTime.config.type == 'List'){
			$("#worldTime .webpart-top").remove();
			$("#worldTime.webpart").addClass("ptype02_universal_time");
			$("#worldTime.ptype02_universal_time .seoul_time_wrap, #worldTime.ptype02_universal_time .select_time_wrap").addClass("ptype02_timebox");
			
			$("#worldTime .seoul_time_wrap").append(
				$("#tempateWorldTimeList").html()
					.replace('{cityClassName}', worldTime.config.cityClassName)
					.replace('{dateTimeClassName}', worldTime.config.dateTimeClassName)
					.replace('{city}', CFN_GetDicInfo(worldTime.timezone[worldTime.config.currentCountry].zone[worldTime.config.currentCity], Common.getSession('lang')))
			);
			
			$("#worldTime .select_time_wrap").append(
				$("#tempateWorldTimeList").html()
					.replace('{cityClassName}', worldTime.config.citySelectClassName)
					.replace('{dateTimeClassName}', worldTime.config.dateTimeClassName)
			);
			
			worldTime.setCity('all');
		}
		else if (worldTime.config.type == 'Selectable' || worldTime.config.type == 'Fixed'){
			$(worldTime.preId + "#worldTime .seoul_time_wrap").empty();
			$(worldTime.preId + "#worldTime .seoul_time_wrap")
				.append($("<h4>")
					.append($("<em>",{"text": CFN_GetDicInfo(worldTime.timezone[worldTime.config.currentCountry].name, Common.getSession('lang'))}))
					.append($("<span>",{"text": CFN_GetDicInfo(worldTime.timezone[worldTime.config.currentCountry].zone[worldTime.config.currentCity], Common.getSession('lang'))}))
				)
				.append($("<time>")
					.append($("<span>"))
					.append($("<em>"))
					.append($("<strong>"))
				);
			$(worldTime.preId + "#worldTime .select_time_wrap").empty();
			if(worldTime.config.type == 'Selectable'){
				$(worldTime.preId + "#worldTime .select_time_wrap")
					.addClass('selectable')
					.append($("<div>", {"class":"selector"}))
					.append($("<time>")
						.append($("<span>"))
						.append($("<em>"))
						.append($("<strong>"))
					);

					worldTime.setCountry();
			}else{
				$(worldTime.preId + "#worldTime .select_time_wrap")
					.append($("<input>", {"type":"hidden", "class":"city_select", "value":worldTime.config.selectedCity}))
					.append($("<h4>")
						.append($("<em>",{"text":CFN_GetDicInfo(worldTime.timezone[worldTime.config.selectedCountry].name, Common.getSession('lang'))}))
						.append($("<span>",{"text":CFN_GetDicInfo(worldTime.timezone[worldTime.config.selectedCountry].zone[worldTime.config.selectedCity], Common.getSession('lang'))}))
					)
					.append($("<time>")
						.append($("<span>"))
						.append($("<em>"))
						.append($("<strong>"))
					);
			}
		}
		
		worldTime.getTime();
	},
	getTime: function(){
		if ($(worldTime.preId + "#worldTime").length == 0){
			clearTimeout(worldTime.timer);
			return false;
		}
		
		var current = new Date();
		worldTime.date = current.format('yyyy.MM.dd');
		worldTime.time = current.format('hh:mm');
		worldTime.ampm = (current.getHours() < 12) ? 'AM' : 'PM' 
		worldTime.extday =worldTime.exeDataName[current.getDay()];

		var selected = worldTime.changeTimeZone(current, $(worldTime.preId + "#worldTime .city_select").val());
		worldTime.selectedDate = selected.format('yyyy.MM.dd');
		worldTime.selectedTime = selected.format('hh:mm');
		worldTime.selectedAmpm = (selected.getHours() < 12) ? 'AM' : 'PM' 
		worldTime.selectedExtday = worldTime.exeDataName[selected.getDay()];
		
		worldTime.setTime();

		worldTime.timer = setTimeout(worldTime.getTime, 1000);
	},
	setTime: function(){
		if (worldTime.config.type == 'Card'){
			$("#worldTime .seoul_time_wrap .tx_date").text(worldTime.date);
			$("#worldTime .seoul_time_wrap .tx_time").contents()[0].textContent = worldTime.time
			$("#worldTime .seoul_time_wrap .tx_ampm").text(worldTime.ampm);
			
			$("#worldTime .select_time_wrap .tx_date").text(worldTime.selectedDate);
			$("#worldTime .select_time_wrap .tx_time").contents()[0].textContent = worldTime.selectedTime
			$("#worldTime .select_time_wrap .tx_ampm").text(worldTime.selectedAmpm);
		}
		else if (worldTime.config.type == 'List'){
			$("#worldTime .seoul_time_wrap .tx_time").text(worldTime.date+' '+worldTime.time);
			$("#worldTime .select_time_wrap .tx_time").text(worldTime.selectedDate+' '+worldTime.selectedTime);
		}
		else if (worldTime.config.type == 'Selectable' || worldTime.config.type == 'Fixed'){
			$(worldTime.preId + "#worldTime .seoul_time_wrap time span").text(worldTime.date+"("+worldTime.extday+")");
			$(worldTime.preId + "#worldTime .seoul_time_wrap time em").attr("class",worldTime.ampm.toLowerCase());
			$(worldTime.preId + "#worldTime .seoul_time_wrap time em").text(worldTime.ampm);
			$(worldTime.preId + "#worldTime .seoul_time_wrap time strong").text(worldTime.time);
			
			$(worldTime.preId + "#worldTime .select_time_wrap time span").text(worldTime.selectedDate+"("+worldTime.selectedExtday+")");
			$(worldTime.preId + "#worldTime .select_time_wrap time em").attr("class",worldTime.selectedAmpm.toLowerCase());
			$(worldTime.preId + "#worldTime .select_time_wrap time em").text(worldTime.selectedAmpm);
			$(worldTime.preId + "#worldTime .select_time_wrap time strong").text(worldTime.selectedTime);
		}
	},
	changeTimeZone: function(date, timeZone) {
		if (typeof date === 'string') {
			return new Date(new Date(date).toLocaleString('en-US', { timeZone }));
		}

		return new Date(date.toLocaleString('en-US', { timeZone }));
	},
	setCountry: function(){
		if (worldTime.config.type == 'Selectable'){
		if ($(worldTime.preId + "#worldTime .select_time_wrap .selector .country_select").length == 0) {
			$(worldTime.preId + "#worldTime .select_time_wrap .selector").append('<label class="blind" for="worldTimeCountry"><spring:message code="Cache.lbl_Location"/></label>');
			$(worldTime.preId + "#worldTime .select_time_wrap .selector").append('<select class="country_select ui_select_field" id="worldTimeCountry"></select>');
			$(worldTime.preId + "#worldTime .select_time_wrap .selector .country_select").on("change", function(){ worldTime.setCity(this); });
		}
		
		$.each(worldTime.timezone, function(idx, el){
			if (idx != worldTime.config.currentCountry){
				$(worldTime.preId + "#worldTime .select_time_wrap .selector .country_select").append(
					'<option value="' + idx + '">' + CFN_GetDicInfo(el.name, Common.getSession('lang')) + '</option>'
				);
			}
		});
		if (worldTime.config.targetCity) $(worldTime.preId + "#worldTime .select_time_wrap .selector .country_select").val(worldTime.config.targetCity);
		$(worldTime.preId + "#worldTime .select_time_wrap .selector .country_select").change();
		} else {
		if ($("#worldTime .select_time_wrap .sel_country country_select").length == 0) {
			$("#worldTime .select_time_wrap .sel_country").html('<select class="country_select" onchange="javascreipt:worldTime.setCity(this);"></select>')
		}
		$.each(worldTime.timezone, function(idx, el){
			if (idx != worldTime.config.currentCountry){
				$("#worldTime .select_time_wrap .sel_country .country_select").append(
					'<option value="' + idx + '">' + CFN_GetDicInfo(el.name, Common.getSession('lang')) + '</option>'
				);
			}
		});
		if (worldTime.config.targetCity) $("#worldTime .select_time_wrap .sel_country .country_select").val(worldTime.config.targetCity);
		$("#worldTime .select_time_wrap .sel_country .country_select").change();
		}
	},
	setCity: function(country){
		var _country = (typeof country == 'string') ? country : country.value;
		if (worldTime.config.type == 'Selectable'){
		if ($(worldTime.preId + "#worldTime .select_time_wrap .selector .city_select").length == 0) {
			$(worldTime.preId + "#worldTime .select_time_wrap .selector").append('<label class="blind" for="worldTimeCity"><spring:message code="Cache.lbl_Location"/></label>');
			$(worldTime.preId + "#worldTime .select_time_wrap .selector").append('<select class="city_select ui_select_field" id="worldTimeCity"></select>');
			$(worldTime.preId + "#worldTime .select_time_wrap .selector .city_select").on("change", function(){ worldTime.getTime(); });
		}

		$(worldTime.preId + "#worldTime .select_time_wrap .selector .city_select").empty();
		$.each(worldTime.timezone, function(countryIdx, countries){
			if ((countryIdx == _country || _country == 'all') && countryIdx != worldTime.config.currentCountry){
				$.each(countries.zone, function(idx, el){
					$(worldTime.preId + "#worldTime .select_time_wrap .selector .city_select").append(
						'<option value="' + idx + '">' + CFN_GetDicInfo(el, Common.getSession('lang')) + '</option>'
					)	
				})
			}
		});
		} else {
		if ($("#worldTime .select_time_wrap .sel_city city_select").length == 0) {
			$("#worldTime .select_time_wrap .sel_city").html('<select class="city_select ptype02_time_select" onchange="javascreipt:worldTime.getTime();"></select>')
		}

		$("#worldTime .select_time_wrap .sel_city .city_select").empty();
		$.each(worldTime.timezone, function(countryIdx, countries){
			if ((countryIdx == _country || _country == 'all') && countryIdx != worldTime.config.currentCountry){
				$.each(countries.zone, function(idx, el){
					$("#worldTime .select_time_wrap .sel_city .city_select").append(
						'<option value="' + idx + '">' + CFN_GetDicInfo(el, Common.getSession('lang')) + '</option>'
					)	
				})
			}
		});
		}
	}
}
