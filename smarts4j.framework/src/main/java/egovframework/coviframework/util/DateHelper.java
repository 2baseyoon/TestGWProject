package egovframework.coviframework.util;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Set;
import java.util.TimeZone;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;
import org.joda.time.LocalDateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

/**
 * timezone 관련 정책
 * http://joda-time.sourceforge.net/timezones.html
 * http://lifeiscool.tistory.com/118
 * 
 */
public class DateHelper {
	//properties로 부터 가져 오도록 변경할 것.
	private static final String DEFAULT_FORMAT = "yyyy-MM-dd HH:mm:ss";
	private static final String DEFAULT_TIMEZONE = "Asia/Seoul";
	
	// 참고 : https://github.com/sid2656/utils_utils/blob/master/code/utils/src/main/java/utils/utils/DateUtil.java
	private DateHelper(){}
	
	/**
	 * 타임존 목록 조회
	 * @return
	 */
	public static CoviList getAvailableTimeZones(){
		CoviList timezoneInfos = new CoviList();
		
		Set<String> zoneIds = DateTimeZone.getAvailableIDs();
		DateTimeFormatter dateTimeFormatter = DateTimeFormat.forPattern("ZZ");

		for (String zoneId : zoneIds) {
		    String offset = dateTimeFormatter.withZone(DateTimeZone.forID(zoneId)).print(0);
		    String longName = TimeZone.getTimeZone(zoneId).getDisplayName();
		    CoviMap timezoneObj = new CoviMap();
			timezoneObj.put("id", zoneId);
			timezoneObj.put("offset", offset);
			timezoneObj.put("name", longName);
			
			timezoneInfos.add(timezoneObj);
		}
		
		return timezoneInfos;
	}
	
	/**
	 * UTC datetime yyyy-MM-dd HH:mm:ss 포멧으로 조회
	 * @return
	 */
	public static String getUTCString(){
		DateTime dt = new DateTime(DateTimeZone.UTC);
		return dt.toString(DEFAULT_FORMAT);
	}
	
	/**
	 * 요청한 dateFormat으로 UTC 시간 조회
	 * @param dateFormat
	 * @return
	 */
	public static String getUTCString(String dateFormat){
		DateTime dt = new DateTime(DateTimeZone.UTC);
		return dt.toString(dateFormat);
	}
	
	/**
	 * 현재 UTC 시간 조회
	 * @return
	 */
	public static DateTime getUTCTime(){
		return DateTime.now(DateTimeZone.UTC);
	}
	
	/**
	 * 문자열 시간 정보를 서버의 Timezone으로 조회 
	 * @param dt
	 * @return
	 */
	public static String getLocalString(String dt){
		DateTimeFormatter formatter = DateTimeFormat.forPattern(DEFAULT_FORMAT);
		DateTime paramdt = formatter.withZoneUTC().parseDateTime(dt);
		DateTime localdt = new DateTime(paramdt, DateTimeZone.forID(DEFAULT_TIMEZONE));
		return localdt.toString(DEFAULT_FORMAT);
	}
	
	/**
	 * datetime 포멧의 시간정보를 현재 Timezone으로 조회
	 * @param dt
	 * @return
	 */
	public static String getLocalString(DateTime dt){
		DateTime localdt = new DateTime(dt, DateTimeZone.forID(DEFAULT_TIMEZONE));
		return localdt.toString(DEFAULT_FORMAT);
	}
	
	/**
	 * 문자열의 시간정보를 datetime 포멧으로 조회
	 * @param dt
	 * @return
	 */
	public static DateTime getLocalTime(String dt){
		DateTimeFormatter formatter = DateTimeFormat.forPattern(DEFAULT_FORMAT);
		DateTime paramdt = formatter.withZoneUTC().parseDateTime(dt);
		return new DateTime(paramdt, DateTimeZone.forID(DEFAULT_TIMEZONE));
	}
	
	public static DateTime getLocalTime(DateTime dt){
		return new DateTime(dt, DateTimeZone.forID(DEFAULT_TIMEZONE));
	}
	
	public static String getLocalString(String dt, String dateFormat){
		DateTimeFormatter formatter = DateTimeFormat.forPattern(dateFormat);
		DateTime paramdt = formatter.withZoneUTC().parseDateTime(dt);
		DateTime localdt = new DateTime(paramdt, DateTimeZone.forID(DEFAULT_TIMEZONE));
		return localdt.toString(dateFormat);
	}
	
	public static String getLocalString(DateTime dt, String dateFormat){
		DateTime localdt = new DateTime(dt, DateTimeZone.forID(DEFAULT_TIMEZONE));
		return localdt.toString(dateFormat);
	}
	
	public static DateTime getLocalTime(String dt, String dateFormat){
		DateTimeFormatter formatter = DateTimeFormat.forPattern(dateFormat);
		DateTime paramdt = formatter.withZoneUTC().parseDateTime(dt);
		return new DateTime(paramdt, DateTimeZone.forID(DEFAULT_TIMEZONE));
	}
	
	public static String getLocalString(String dt, String dateFormat, String timeZone){
		DateTimeFormatter formatter = DateTimeFormat.forPattern(dateFormat);
		DateTime paramdt = formatter.withZoneUTC().parseDateTime(dt);
		DateTime localdt = new DateTime(paramdt, DateTimeZone.forID(timeZone));
		return localdt.toString(dateFormat);
	}
	
	public static String getLocalString(DateTime dt, String dateFormat, String timeZone){
		DateTime localdt = new DateTime(dt, DateTimeZone.forID(timeZone));
		return localdt.toString(dateFormat);
	}
	
	public static DateTime getLocalTime(String dt, String dateFormat, String timeZone){
		DateTimeFormatter formatter = DateTimeFormat.forPattern(dateFormat);
		DateTime paramdt = formatter.withZoneUTC().parseDateTime(dt);
		return new DateTime(paramdt, DateTimeZone.forID(timeZone));
	}
	
	public static DateTime getLocalTime(DateTime dt, String timeZone){
		return new DateTime(dt, DateTimeZone.forID(timeZone));
	}
	
	/**
	 * 오늘날짜
	 * @param dateFormat
	 * @return
	 */
	public static String getCurrentDay(String dateFormat){
		
		Calendar cal = Calendar.getInstance();
		cal.setTime(new Date(System.currentTimeMillis()));
		String date = new SimpleDateFormat(dateFormat).format(cal.getTime());	//yyyy-MM-dd hh:mm:ss
		
		return date;
	}
	
	/**
	 * 일단위계산 - YYYY-MM-dd
	 * @return
	 */
	public static String getAddDate(String dateFormat, int del){
		
		Calendar cal = Calendar.getInstance();
		cal.setTime(new Date(System.currentTimeMillis()));
		cal.add(Calendar.DATE, del);
		String date = new SimpleDateFormat(dateFormat).format(cal.getTime());
		
		return date;
	}
	
	
	/**
	 * 일시 더하기
	 * @param sDate
	 * @param dateFormat
	 * @param del
	 * @param dateType 
	 * 년 : Calendar.YEAR
	 * 월 : Calendar.MONTH
	 * 일 : Calendar.DATE
	 * 시 : Calendar.HOUR
	 * 분 : Calendar.MINUTE
	 * @return
	 * @throws Exception
	 */
	public static String getAddDate(String sDate, String dateFormat, int del, int dateType) throws Exception{
		
		String date = "";
		
		if(del == 0){
			date = sDate;
		}else{
			Calendar cal = Calendar.getInstance();
			cal.setTime(new SimpleDateFormat(dateFormat).parse(sDate));
			cal.add(dateType, del);
			date = new SimpleDateFormat(dateFormat).format(cal.getTime());
		}
		
		return date;
	}
	
	/**
	 * 월단위계산 - YYYY-MM-dd
	 * @return
	 */
	public static String getMonthAgoDate(String dateFormat, int del){
		
		Calendar cal = Calendar.getInstance();
		cal.setTime(new Date(System.currentTimeMillis()));
		cal.add(Calendar.MONTH, del);
		String date = new SimpleDateFormat(dateFormat).format(cal.getTime());
		
		return date;
	}
	
	/**
	 * 요일 구하기
	 * @param sDate
	 * @param dateFormat
	 * @return
	 */
	public static int getDayOfWeek(String sDate, String dateFormat) throws Exception{
		int dayOfWeek = 0;
		
		Calendar cal = Calendar.getInstance();
		cal.setTime(new SimpleDateFormat(dateFormat).parse(sDate));
		
		dayOfWeek = cal.get(Calendar.DAY_OF_WEEK) ;
		
		return dayOfWeek;
	}
	
	/**
	 * 특정 년, 월, 주 차의 특정 요일 날짜 구하기
	 * @param datetime
	 * @param UTC
	 * @return
	 * @throws Exception
	 */
	public static String getDateByDateOfWeek(String year,String month, String week, int dateOfWeek, String dateFormat){
 		Calendar c = Calendar.getInstance();
 		
 		int y=Integer.parseInt(year);
 		int m=Integer.parseInt(month)-1;
 		int w=Integer.parseInt(week);
 		
 		c.set(Calendar.YEAR,y);
 		c.set(Calendar.MONTH,m);
 		c.set(Calendar.WEEK_OF_MONTH,w);
 		
 		switch (dateOfWeek) {
		case 0:
			c.set(Calendar.DAY_OF_WEEK,Calendar.SUNDAY);
			break;
		case 1:
			c.set(Calendar.DAY_OF_WEEK,Calendar.MONDAY);
			break;
		case 2:
			c.set(Calendar.DAY_OF_WEEK,Calendar.TUESDAY);
			break;
		case 3:
			c.set(Calendar.DAY_OF_WEEK,Calendar.WEDNESDAY);
			break;
		case 4:
			c.set(Calendar.DAY_OF_WEEK,Calendar.THURSDAY);
			break;
		case 5:
			c.set(Calendar.DAY_OF_WEEK,Calendar.FRIDAY);
			break;
		case 6:
			c.set(Calendar.DAY_OF_WEEK,Calendar.SATURDAY);
			break;
		default:
			throw new NullPointerException();
		}
 		
 		return new SimpleDateFormat(dateFormat).format(c.getTime());
 	}
	
	/**
	 * 마지막 요일
	 * @param month
	 * @param year
	 * @param dayOfWeek
	 * @param dateFormat
	 * @return
	 */
	public static String getLastDayOfWeek( int year, int month , int dayOfWeek, String dateFormat) {
	   Calendar cal = Calendar.getInstance();
	   cal.set( year, month-1, 1 );
	   
	   int nowDayOfWeek = cal.get( Calendar.DAY_OF_WEEK );
	   if(nowDayOfWeek > dayOfWeek){
		   cal.add( Calendar.DAY_OF_MONTH, -( nowDayOfWeek - dayOfWeek ) );
	   }else{
		   cal.add( Calendar.DAY_OF_MONTH, -( 7 - dayOfWeek ) );
	   }
	   
	   return new SimpleDateFormat(dateFormat).format(cal.getTime());
	}
	
	/**
	 * 첫번째 요일
	 * @param month
	 * @param year
	 * @param dayOfWeek
	 * @param dateFormat
	 * @return
	 */
	public static String getFirstDayOfWeek( int year, int month , int dayOfWeek, String dateFormat) {
	   Calendar cal = Calendar.getInstance();
	   cal.set( year, month-1, 1 );
	   
	   int nowDayOfWeek = cal.get( Calendar.DAY_OF_WEEK );
	   if(nowDayOfWeek > dayOfWeek){
		   cal.add( Calendar.DAY_OF_MONTH, (( 7 - nowDayOfWeek) + dayOfWeek ) );
	   }else{
		   cal.add( Calendar.DAY_OF_MONTH, ( dayOfWeek - nowDayOfWeek ) );
	   }
	   
	   return new SimpleDateFormat(dateFormat).format(cal.getTime());
	}
	
	/**
	 * 기간별 날짜 - YYYY-MM-dd
	 * @return
	 * @throws ParseException 
	 */
	public static List getPeriodDay(String str_date, String end_date) throws ParseException{
		
		List<Date> dates = new ArrayList<Date>();
        List dateList = new ArrayList();

        DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        Date startDate = (Date)formatter.parse(str_date); 
        Date endDate = (Date)formatter.parse(end_date);
        long interval = 24*1000 * 60 * 60; 
        long endTime = endDate.getTime() ; 
        long curTime = startDate.getTime();
        while (curTime <= endTime) {
            dates.add(new Date(curTime));
            curTime += interval;
        }
        for(int i=0;i<dates.size();i++){
            Date lDate =(Date)dates.get(i);
            String ds = formatter.format(lDate);
            dateList.add(ds);
        }
		
		return dateList;
	}
	
	/*
	 * Timezone 적용하기 - http://stackoverflow.com/questions/21258214/convert-one-time-zone-to-another-using-joda-time
	 * UTC 값이 true인 경우 local time 리턴
	 * UTC 값이 false인 경우 UTC time 리턴
	 * timestamp 관련 참고 - http://jsonobject.tistory.com/34
	 * */
	public static String formatUTCToLocalAndBackTime(String datetime, boolean UTC) throws Exception{ 
	    String returnTimeDate = "";
	    DateTime dtUTC = null;
	    DateTimeZone timezone = DateTimeZone.getDefault();
	    DateTimeFormatter formatDT = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss");
	    DateTime dateDateTime1 = formatDT.parseDateTime(datetime);
	    DateTime now = new DateTime();
	    DateTime nowUTC = new LocalDateTime(now).toDateTime(DateTimeZone.UTC);
	    long instant = now.getMillis();
	    long instantUTC = nowUTC.getMillis();
	    long offset = instantUTC - instant;

	    if (UTC) { 
	        //convert to local time
	        dtUTC = dateDateTime1.withZoneRetainFields(DateTimeZone.UTC);
	        //dtUTC = dateDateTime1.toDateTime(timezone);
	        dtUTC = dtUTC.plusMillis((int) offset);
	    } else { 
	        //convert to UTC time
	        dtUTC = dateDateTime1.withZoneRetainFields(timezone);
	        dtUTC = dtUTC.minusMillis((int) offset);        
	    }

	    returnTimeDate = dtUTC.toString(formatDT);

	    return returnTimeDate;
	}
	
	/*
    *@param  strDate  Description of Parameter
    *@return          Description of the Returned Value
    */
   public static Date strToDate(String strDate) {
       if (strDate == null || strDate.length() < 6) {
           throw new IllegalArgumentException("illeage date format");
       }
       
       String fmt = "yyyy-MM-dd HH:mm:ss";

       if (strDate.length() == 19) {
           if (strDate.indexOf("-") > 0) {
               fmt = "yyyy-MM-dd HH:mm:ss";
           } else if (strDate.indexOf("/") > 0) {
               fmt = "yyyy/MM/dd HH:mm:ss";
           }
       } else if (strDate.length() == 18) {
           if (strDate.indexOf("-") > 0) {
               fmt = "yyyy-MM-dd HH:mm:ss";
           } else if (strDate.indexOf("/") > 0) {
               fmt = "yyyy/MM/dd HH:mm:ss";
           }
       }else if (strDate.length() == 16) {
           if (strDate.indexOf("-") > 0) {
               fmt = "yyyy-MM-dd HH:mm";
           } else if (strDate.indexOf("/") > 0) {
               fmt = "yyyy/MM/dd HH:mm";
           }
       } else if (strDate.length() == 14) {

           fmt = "yyyyMMddHHmmss";
       } else if (strDate.length() == 10) {
           if (strDate.indexOf("-") > 0) {
               fmt = "yyyy-MM-dd";
           } else if (strDate.indexOf("/") > 0) {
               fmt = "yyyy/MM/dd";
           } else if (strDate.indexOf(".") > 0) {
               fmt = "yyyy.MM.dd";
           }
       } else if (strDate.length() == 8||strDate.length() == 9) {
           if (strDate.indexOf("-") > 0) {
               fmt = "yy-MM-dd";
           } else if (strDate.indexOf("/") > 0) {
               fmt = "yy/MM/dd";
           } else if (strDate.indexOf(".") > 0) {
               fmt = "yy.MM.dd";
           } else {
               fmt = "yyyyMMdd";
           }
       }

       SimpleDateFormat formatter = new SimpleDateFormat(fmt);
       ParsePosition pos = new ParsePosition(0);
       Date strtodate = formatter.parse(strDate, pos);
       return strtodate;
   }
   
   public static Date strToDate(String strDate, String fmt) {
	   SimpleDateFormat formatter = new SimpleDateFormat(fmt);
       ParsePosition pos = new ParsePosition(0);
       Date strtodate = formatter.parse(strDate, pos);
       return strtodate;
   }
   
   /**
    *  
    *
    *@param  date1  Description of Parameter
    *@param  date2  Description of Parameter
    *@return        일
    */
   public static int diffDate(java.util.Date date1, java.util.Date date2) {
       return (int) ((date1.getTime() - date2.getTime()) / (24 * 60 * 60 * 1000));
   }

   public static int diffDate(String date1, String date2) {
       return diffDate(strToDate(date1), strToDate(date2));
   }
   
   /**
    *  
    *
    *@param  date1  Description of Parameter
    *@param  date2  Description of Parameter
    *@return        시간
    */
   public static int diffHour(java.util.Date date1, java.util.Date date2) {
       return (int) ((date1.getTime() - date2.getTime()) / (60 * 60 * 1000));
   }

   public static int diffHour(String date1, String date2) {
       return diffHour(strToDate(date1), strToDate(date2));
   }
   
   /**
    *  
    *
    *@param  date1  Description of Parameter
    *@param  date2  Description of Parameter
    *@return        분
    */
   public static int diffMinute(java.util.Date date1, java.util.Date date2) {
       return (int) ((date1.getTime() - date2.getTime()) / (60 * 1000));
   }

   public static int diffMinute(String date1, String date2) {
       return diffMinute(strToDate(date1), strToDate(date2));
   }
   
   
   /**
    * 문자열 날짜 포맷 변경
    * @param strDate 문자열 날짜
    * @param strOrginFormat 기존 포맷
    * @param strNewFormat 변경될 포맷
    * @return dateString 
    */
   public static String convertDateFormat(String strDate, String strOrginFormat, String strNewFormat) {
       String dateString = "";
       
       try {
    	   
	       SimpleDateFormat originFormat = new SimpleDateFormat(strOrginFormat);
	       Date date = originFormat.parse(strDate);
	       SimpleDateFormat format2 = new SimpleDateFormat(strNewFormat);
	       dateString = format2.format(date);
	       
		} catch (ParseException e) {
			return strDate;
		}
      
       return dateString;
   }
}
