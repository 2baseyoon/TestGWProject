/* 프로그램 저작권 정보
//이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
//(주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
//(주)코비젼의 지적재산권 침해에 해당됩니다.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

//You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
//as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
//owns the intellectual property rights in and to this program.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>사업지원본부</creator> 
///<createDate>2022.12.09</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.1.0</version>
///<summary> 
///표시용 달력 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/

function CoviCalendar(pTarget, pOption){
	if (typeof pTarget == 'undefined') {
		alert('달력을 생성할 div의 id가 필요합니다.')
	}
	
	var opt = (typeof pOption == 'object') ? pOption : {};
	
	var coviCalendar = {
		calid: pTarget,
		data: {
			weekday: {
				sun: { name: 'S', dicCode: 'lbl_WPSun', order: 1 },
				mon: { name: 'M', dicCode: 'lbl_WPMon', order: 2 },
				tue: { name: 'T', dicCode: 'lbl_WPTue', order: 3 },
				wed: { name: 'W', dicCode: 'lbl_WPWed', order: 4 },
				thu: { name: 'T', dicCode: 'lbl_WPThu', order: 5 },
				fri: { name: 'F', dicCode: 'lbl_WPFri', order: 6 },
				sat: { name: 'S', dicCode: 'lbl_WPSat', order: 7 }
			}
		},
		config: {
			startWeekday: 'sun',
			weekdayDiff: 0,
			dateCnt: 35,
			lineHeight: '30px',
			today: typeof CFN_GetLocalCurrentDate == "function" ? new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat)) : new Date(),
			weekLine: 'auto'
		},
		setConfig: function(conf){
			if (typeof conf != 'object') return false;
			$.each(conf, function(idx, el) {
				coviCalendar.config[idx] = el;
			});
		},
		setStartWeekday: function(weekday){
			var _wd = this.config.startWeekday;
			if (typeof weekday == 'string' && Object.keys(this.data.weekday).indexOf(weekday) > -1){
				_wd = weekday;
			}
			var _wdOrder = this.data.weekday[_wd].order;
			var _diff = this.data.weekday[this.config.startWeekday].order - _wdOrder;
			this.data.weekday[_wd].order = 1;
			
			$.each(this.data.weekday, function(idx, el){
				if (idx != _wd) {
					var neworder = el.order + _diff;
					if (neworder < 1) neworder = neworder + 7;
					else if (neworder > 7) neworder = neworder -7;
					
					el.order = neworder;
				}
			});
			this.config.startWeekday = _wd;
			this.config.weekdayDiff = _diff;
		},
		init: function(date){
			var today = (date) ? date : this.config.today;
			this.current = {
				year: today.getFullYear(),
				month: today.getMonth() + 1,
				day: today.getDate(),
				weekday: today.getDay() + 1,
				date: today.toString()
			};
			
			var first = new Date(this.current.year, this.current.month - 1, 1);
			this.current.firstweekday = first.getDay() + 1;
			
			var last = new Date(this.current.year, this.current.month, 0);
			this.current.lastday = last.getDate();
			
			var prev = new Date(this.current.year, this.current.month - 1, 0);
			this.current.prevlastday = prev.getDate();
			
			this.today = {
				year: this.config.today.getFullYear(),
				month: this.config.today.getMonth() + 1,
				day: this.config.today.getDate(),
				weekday: this.config.today.getDay() + 1,
				date: this.config.today.toString()
			};
			
			if (this.config.weekLine != 'auto' && !isNaN(Number(this.config.weekLine))){
				this.config.dateCnt = Number(this.config.weekLine) * 7 + 1;
			}
			else {
				this.config.dateCnt = (this.current.firstweekday + this.current.lastday > 36) ? 43 : 36;
				if (this.current.firstweekday + this.config.weekdayDiff == 0) this.config.dateCnt = this.config.dateCnt + 7;
			}
		},
		render: function(){
			var target = this.calid;
			var $this = this;
			var targetEl = document.getElementById(target);
			
			if (targetEl){
				var topEl = document.createElement('div');
				topEl.className = 'covi-calendar-top';
				
				var prevEl = document.createElement('a');
				prevEl.className = 'covi-calender-prev';
				//prevEl.innerHTML = '이전';
				prevEl.onclick = function(){
					$this.prev();
				}
				prevEl.setAttribute('href','#');
				topEl.appendChild(prevEl);
				
				var curEl = document.createElement('span');
				curEl.className = 'covi-calender-current';
				topEl.appendChild(curEl);
				
				var nextEl = document.createElement('a');
				nextEl.className = 'covi-calender-next';
				nextEl.setAttribute('href','#');
				//nextEl.innerHTML = '다음';
				nextEl.onclick = function(){
					$this.next();
				}
				topEl.appendChild(nextEl);
				
				
				var contEl = document.createElement('div');
				contEl.className = 'covi-calendar-content';
				
				var tableEl = document.createElement('div');
				tableEl.id = target+'_calenar_header';
				tableEl.className = 'covi-calendar-header';
				
				var trEl = document.createElement('div');
				trEl.id = target+'_weekday';
				trEl.className = 'covi-calendar-tr';
				
				for(var i = 1; i < 8; i++){
					var tdEl = document.createElement('div');
					tdEl.setAttribute('data-weekday-order', i);
					trEl.appendChild(tdEl);
				}
				
				tableEl.appendChild(trEl);
				
				var bodyEl = document.createElement('div');
				bodyEl.id = target+'_calendar_body';
				
				for(var j = 1; j < Math.ceil(this.config.dateCnt/7); j++){
					var bodyTrEl = document.createElement('div');
					bodyTrEl.className = 'covi-calendar-tr';
					
					for(var i = 1; i < 8; i++){
						var bodyTdEl = document.createElement('div');
						bodyTdEl.className = 'covi-calendar-date';
						bodyTdEl.setAttribute('data-week-order', j);
						bodyTdEl.setAttribute('data-day-order', (7*(j-1)) + i);
						bodyTdEl.setAttribute('data-weekday-order', i);
						bodyTdEl.onclick = function(e){
							var newCurrentDate = new Date($(e.currentTarget).attr('data-day'));
							$this.current.date = newCurrentDate.toString();
							$this.current.year = newCurrentDate.getFullYear();
							$this.current.month = newCurrentDate.getMonth() + 1;
							$this.current.day = newCurrentDate.getDate();
							$this.current.weekday = newCurrentDate.getDay() + 1;
							$("#"+$this.calid+" .selected").removeClass("selected");
							$(e.target).closest('.covi-calendar-date').addClass("selected");
						}
						bodyTrEl.appendChild(bodyTdEl);
					}
					bodyEl.appendChild(bodyTrEl);
				}
				
				contEl.appendChild(tableEl);
				contEl.appendChild(bodyEl);
				$(targetEl).html('').append(topEl).append(contEl);

				$.each(this.data.weekday, function(idx, el){
					var weekdayname = el.name;
					if (typeof Common == 'object' && typeof Common.getDic == 'function') weekdayname = Common.getDic(el.dicCode);
					
					$("#"+target+"_weekday div[data-weekday-order="+el.order+"]").attr("data-weekday", idx).html(weekdayname);
					
					if (idx == 'sun') $("#"+target+"_weekday div[data-weekday-order="+el.order+"]").addClass("sunday");
					else if (idx == 'sat') $("#"+target+"_weekday div[data-weekday-order="+el.order+"]").addClass("saturday");
				});
				
				$("#"+target+"_calendar_body div[data-weekday-order="+this.data.weekday.sun.order+"]").addClass("sunday");
				$("#"+target+"_calendar_body div[data-weekday-order="+this.data.weekday.sat.order+"]").addClass("saturday");
				
				$("#"+target+"_calendar_body .covi-calendar-date").css("height", this.config.lineHeight);
			}
		},
		setDate: function(){
			$("#"+this.calid+" .covi-calender-current").text(this.current.year + '.' + this.padding(this.current.month, 2));
			var startDayindex = this.current.firstweekday + this.config.weekdayDiff;
			if (startDayindex == 0) startDayindex = 7;
			
			var isPrevYear = (this.current.month - 1 == 0) ? 1 : 0;
			var isNextYear = (this.current.month + 1 == 13) ? 1 : 0;

			for (var i = 0; i < this.current.lastday; i++){
				$("#"+this.calid+"_calendar_body .covi-calendar-tr div[data-day-order="+(startDayindex + i)+"]")
					.attr('data-day', this.current.year+"-"+this.padding(this.current.month, 2)+"-"+this.padding((i+1), 2))
					.append('<span>'+(i+1)+'</span>');
			}
			for (var i = 0; i < startDayindex; i++){
				$("#"+this.calid+"_calendar_body .covi-calendar-tr div[data-day-order="+(startDayindex - (i+1))+"]").addClass("prev-month")
					.attr('data-day', (this.current.year - isPrevYear)+"-"+this.padding((this.current.month-1 == 0) ? 12 : (this.current.month-1), 2)+"-"+this.padding((this.current.prevlastday - i), 2))
					.append('<span>'+(this.current.prevlastday - i)+'</span>');
			}
			if (startDayindex + this.current.lastday < this.config.dateCnt){
				var lastdayindex = startDayindex + this.current.lastday
				var nextmonthday = this.config.dateCnt - lastdayindex;
				for (var i = 0; i < nextmonthday; i++){
					$("#"+this.calid+"_calendar_body .covi-calendar-tr div[data-day-order="+(lastdayindex + i)+"]").addClass("next-month")
						.attr('data-day', (this.current.year + isNextYear)+"-"+this.padding((this.current.month+1 == 13) ? 1 : (this.current.month+1), 2)+"-"+this.padding((i+1), 2))
						.append('<span>'+(i + 1)+'</span>');
				}
			}
			
			$("#"+this.calid+"_calendar_body .covi-calendar-tr div[data-day="+(this.current.year+'-'+this.padding(this.current.month,2)+'-'+this.padding(this.current.day,2))+"]").addClass("selected");
			$("#"+this.calid+"_calendar_body .covi-calendar-tr div[data-day="+(this.today.year+'-'+this.padding(this.today.month,2)+'-'+this.padding(this.today.day,2))+"]").addClass("today");

			$("#"+this.calid).trigger("load", function(e, callback){
				if(typeof callback == 'function'){
					callback.call(e);
				}
			});
		},
		clearDate: function(){
			$("#"+this.calid+" .covi-calender-current").text('');
			$("#"+this.calid+" .covi-calendar-date").removeClass("prev-month").removeClass("next-month").html("");
		},
		clearCal: function(){
			$("#"+this.calid).html("");
		},
		prev: function(){
			var pm = new Date(this.current.year, (this.current.month - 2));
			this.init(pm);
			this.clearCal();
			this.render(this.calid);
			this.setDate();
		},
		next: function(){
			var nm = new Date(this.current.year, this.current.month);
			this.init(nm);
			this.clearCal();
			this.render(this.calid);
			this.setDate();
		},
		setMark: function(date){
			var $this = this;
			if (Array.isArray(date)) {
				$.each(date, function(idx, el){
					if (!$("#"+$this.calid+" div[data-day="+el+"]").hasClass("mark"))
						$("#"+$this.calid+" div[data-day="+el+"]").addClass("mark");
				});
			}
			else {
				if (!$("#"+$this.calid+" div[data-day="+date+"]").hasClass("mark"))
					$("#"+$this.calid+" div[data-day="+date+"]").addClass("mark");
			}
		},
		clearMark: function(date){
			if (date){
				$("#"+this.calid+" div[data-day="+date+"]").removeClass("mark");
			}
			else {
				$("#"+this.calid+" .mark").removeClass("mark")
			}
		},
		padding: function(inValue, digits, pad) {
			var _pad = (pad) ? pad : '0';
			var result = '';
			inValue = inValue.toString();

			if (inValue.length < digits) {
				for (var i = 0; i < digits - inValue.length; i++)
					result += _pad;
			}
			result += inValue
			return result;
		}
	}
	
	if (opt.startWeekday) coviCalendar.setStartWeekday(opt.startWeekday);
	coviCalendar.setConfig(opt);
	coviCalendar.init();
	coviCalendar.render();
	coviCalendar.setDate();
	
	return coviCalendar;
}