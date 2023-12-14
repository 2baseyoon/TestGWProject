
//특정일이 속한 일요일
function schedule_GetSunday(d) {
	var date = new Date(d);
	
    var day = date.getDay();
    var diff = date.getDate() - day;
    return new Date(replaceDate(date.setDate(diff)));
}

//해당 달의 첫번째 일요일 조회
function schedule_GetFirstSunOfMonth(selDate) {
    var arrSelDate = selDate.split('.');
    //이달의 첫째 날
    var firstDay = new Date(arrSelDate[0], Number(arrSelDate[1]) - 1, 1);
    //이달의 첫째 날의 일요일
    var firstSun = schedule_GetSunday(firstDay);
    return firstSun;
}

// 해당 달의 마지막 일요일 조회
function schedule_GetLastSunOfMonth(selDate) {
    var arrSelDate = selDate.split('.');
    //이달의 첫째 날
    var strNextFirstDay = arrSelDate[0] + '/' + (Number(arrSelDate[1]) + 1) + '/' + 1;
    var lastDay = schedule_SubtractDays(strNextFirstDay, 1);
    var lastSun = schedule_GetSunday(lastDay);
    return lastSun;
}

//날짜 포멧 변환
function schedule_SetDateFormat(pDate, pType) {
    var formattedDate = '';
    var date = new Date(replaceDate(pDate));
    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    var day = date.getDate();
    if (month < 10) {
        month = '0' + month;
    }
    if (day < 10) {
        day = '0' + day;
    }

    switch (pType) {
        case '.': formattedDate = year + '.' + month + '.' + day;
            break;
        case '/': formattedDate = year + '/' + month + '/' + day;
            break;
        case '-': formattedDate = year + '-' + month + '-' + day;
            break;
        case '': formattedDate = year.toString() + month.toString() + day.toString();
            break;
    }
    return formattedDate;
}

//지정한 만큼 이전 일
function schedule_SubtractDays(strDate, days) {
    var date = new Date(replaceDate(strDate));
    var d = date.getDate() - days;
    date.setDate(d);
    return date;
}

//지정한 만큼 이후 일
function schedule_AddDays(strDate, days) {
    var date = new Date(replaceDate(strDate));
    var d = date.getDate() + days;
    date.setDate(d);
    return date;
}

//지정 주 이후 날일
function schedule_AddWeeks(strDate, weeks) {
    var days = (weeks * 7);
    var date = new Date(replaceDate(strDate));
    var d = date.getDate() + days;
    date.setDate(d);
    return date;
}

//날짜 비교
function schedule_GetDiffDates(date1, date2, type) {
    //날짜 비교
    var ret = '';
    //소수점 발생
    var num_days = ((((date2 - date1) / 1000) / 60) / 60) / 24;
    var num_hours = ((((date2 - date1) / 1000) / 60) / 60);
    var num_minutes = (((date2 - date1) / 1000) / 60);

    switch (type) {
        case 'day': ret = num_days;
            break;
        case 'hour': ret = num_hours;
            break;
        case 'min': ret = num_minutes;
            break;
    }

    return ret;
}

//랜덤 Color 제조기
function schedule_RandomColor(format) {
	var rint = Math.round(0xffffff * coviCmn.random());
	switch (format) {
		case 'hex':
			return ('#0' + rint.toString(16)).replace(/^#0([0-9a-f]{6})$/i, '#$1');
			break;
		case 'rgb':
			return 'rgb(' + (rint >> 16) + ',' + (rint >> 8 & 255) + ',' + (rint & 255) + ')';
			break;
		default:
			return rint;
			break;
	}
}

//.형식의 날짜 반환
function schedule_MakeDateForCompare(date, time) {
    try {
        var arrDate;
        var arrTime;
        if (date.indexOf('-') > -1) {
            arrDate = date.split('-');
        } else {
            arrDate = date.split('.');
        }
        arrTime = time.split(':');
        date = new Date(Number(arrDate[0]), Number(arrDate[1]) - 1, Number(arrDate[2]), Number(arrTime[0]), Number(arrTime[1]));
        return date;
    }  catch (e) { coviCmn.traceLog(e);}
}

//요일 다국어 배열
function schedule_GetWeekDay(date) {
	//개별호출 - 일괄호출
	Common.getDicList(["lbl_sch_sun", "lbl_sch_mon", "lbl_sch_tue", "lbl_sch_wed","lbl_sch_thr", "lbl_sch_fri", "lbl_sch_sat"]);
    var weekday = new Array(coviDic.dicMap["lbl_sch_sun"], coviDic.dicMap["lbl_sch_mon"], coviDic.dicMap["lbl_sch_tue"], coviDic.dicMap["lbl_sch_wed"], coviDic.dicMap["lbl_sch_thr"], coviDic.dicMap["lbl_sch_fri"], coviDic.dicMap["lbl_sch_sat"]);
    var wkd = date.getDay();
    return weekday[wkd];
}

//입력값 앞에 '0'을 붙여서 입력받는 자리수의 문자열을 반환한다.
function AddFrontZero(inValue, digits) {
	var result = '';
	inValue = inValue.toString();

	if (inValue.length < digits) {
		for (var i = 0; i < digits - inValue.length; i++)
			result += '0';
	}
	result += inValue
	return result;
}

//해당 달의 일요일 배열객체 생성
function schedule_MakeSunArray(selDate) {
 var sun = [];
 var firstSun = schedule_GetFirstSunOfMonth(selDate);
 var strFirstSun = schedule_SetDateFormat(firstSun, '/');
 var lastSun = schedule_GetLastSunOfMonth(selDate);
 for (var i = 0; i < 6; i++) {
     var sDay = schedule_AddDays(strFirstSun, i * 7);
     sun.push(sDay);
     if (schedule_GetDiffDates(sDay, lastSun, 'day') == 0) {
         break;
     }
 }
 return sun;
}

// ie, firefox 오류 방지
function replaceDate(dateStr){
	var replaceStr;
	
	if(typeof dateStr == "string"){
		if(dateStr.indexOf("-") > -1){
			replaceStr = "-";
		}else if(dateStr.indexOf(".") > -1){
			replaceStr = ".";
		}else if(dateStr.indexOf("/") > -1){
			replaceStr = "/";
		}else if(dateStr.length===8){
            dateStr = dateStr.substr(0,4)+"."+dateStr.substr(4,2)+"."+dateStr.substr(6);
            replaceStr = ".";
        }
		
		return dateStr.replaceAll(replaceStr, "/");
	}else{
		var tempDate = new Date(dateStr);
		
		dateStr = tempDate.getFullYear() + "/" + (tempDate.getMonth()+1) + "/" + tempDate.getDate() + " " + AddFrontZero(tempDate.getHours(), 2) + ":" + AddFrontZero(tempDate.getMinutes(), 2);
		
		return dateStr;
	}
	
	
}

// 요일 반환 함수
function getWeekOfDayValue(dateStr){
	dateStr = replaceDate(dateStr);
	
	var dateObj = new Date(dateStr);
	var weekOfDay = dateObj.getDay();

	//개별호출 - 일괄호출
    Common.getDicList(["lbl_WPSun","lbl_WPMon","lbl_WPTue","lbl_WPWed","lbl_WPThu","lbl_WPFri","lbl_WPSat"]);
	
	switch (weekOfDay) {
	case 0: return coviDic.dicMap["lbl_WPSun"]; break;
	case 1: return coviDic.dicMap["lbl_WPMon"]; break;
	case 2: return coviDic.dicMap["lbl_WPTue"]; break;
	case 3: return coviDic.dicMap["lbl_WPWed"]; break;
	case 4: return coviDic.dicMap["lbl_WPThu"]; break;
	case 5: return coviDic.dicMap["lbl_WPFri"]; break;
	case 6: return coviDic.dicMap["lbl_WPSat"]; break;
	}
}

//일자의 주차 구하기
function getWeekNo(dateStr, dowOffset) {
	dateStr = replaceDate(dateStr);
	dowOffset = typeof(dowOffset) == 'number' ? dowOffset : 0;
	var date = new Date(dateStr);
	var newYear = new Date(date.getFullYear(),0,1);
	var day = newYear.getDay() - dowOffset; //the day of week the year begins on
	day = (day >= 0 ? day : day + 7);
	var daynum = Math.floor((date.getTime() - newYear.getTime() -	(date.getTimezoneOffset()-newYear.getTimezoneOffset())*60000)/86400000) + 1;

	var weeknum;
	  //if the year starts before the middle of a week
	if(day < 4) {
	    weeknum = Math.floor((daynum+day-1)/7) + 1;
	    if(weeknum > 52) {
	      let nYear = new Date(date.getFullYear() + 1,0,1);
	      let nday = nYear.getDay() - dowOffset;
	      nday = nday >= 0 ? nday : nday + 7;
	      /*if the next year starts before the middle of
	    the week, it is week #1 of that year*/
	      weeknum = nday < 4 ? 1 : 53;
	    }
	}
	else {
	    weeknum = Math.floor((daynum+day-1)/7);
	}
	  
	return weeknum;
}	
