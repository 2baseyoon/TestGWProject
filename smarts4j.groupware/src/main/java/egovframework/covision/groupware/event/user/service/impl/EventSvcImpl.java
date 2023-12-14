package egovframework.covision.groupware.event.user.service.impl;

import java.util.Calendar;
import java.util.Date;
import java.util.Objects;
import java.util.Set;

import javax.annotation.Resource;




import org.apache.log4j.LogManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.base.web.MobileCommonCon;
import egovframework.covision.groupware.event.user.service.EventSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("eventService")
public class EventSvcImpl extends EgovAbstractServiceImpl implements EventSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private MessageService messageSvc;

	// Event 데이터
	@Override
	public String insertEvent(CoviMap params) throws Exception {
		if ("".equals(params.getString("OwnerCode"))) params.put("OwnerCode", SessionHelper.getSession("USERID"));
		if ("".equals(params.getString("ModifierCode"))) params.put("ModifierCode", SessionHelper.getSession("USERID"));
		if ("".equals(params.getString("RegisterCode"))) params.put("RegisterCode", SessionHelper.getSession("USERID"));
		if ("".equals(params.getString("MultiRegisterName"))) params.put("MultiRegisterName", SessionHelper.getSession("UR_MultiName"));

		coviMapperOne.insert("user.event.insertEvent", params);
		
		return params.getString("EventID");
	}
	
	// 반복 데이터
	@Override
	public String insertEventRepeat(CoviMap params) throws Exception {
		validateRepeat(params);
		
		CoviMap repeatParams = (CoviMap) params.clone();
		repeatParams.put("RepeatTimeZoneDisplay", SessionHelper.getSession("UR_TimeZoneDisplay"));
		
		coviMapperOne.insert("user.event.insertEventRepeat", repeatParams);
		
		return repeatParams.getString("RepeatID");
	}

	private void validateRepeat(CoviMap params) {
		int repeatAppointType = "A".equalsIgnoreCase(params.getString("RepeatAppointType")) ? 0 : 1;
		params.put("RepeatAppointType", repeatAppointType);
		
		if (!params.containsKey("RepeatType")) {
			params.put("RepeatType", "");
		}
		
		if (!params.containsKey("RepeatEndType")) {
			params.put("RepeatEndType", "");
		}
	}

	// Date 데이터
	@Override
	public String insertEventDate(CoviMap params) throws Exception {
		params = ComUtils.TransServerTimeCoviMapDate(params, "");
		coviMapperOne.insert("user.event.insertEventDate", params);
		
		return params.getString("DateID");
	}
	
	// 반복되는 일정의 Date 데이터
	@Override
	public CoviList setEventRepeatDate(CoviMap repeatObj) throws Exception {
		//반복일정
		CoviList repeatList = new CoviList();
		CoviMap repeatData = new CoviMap();
		String sDate = "";
		String eDate = "";
		
		CoviMap resourceRepeat = repeatObj;
		
		String repetitionType = resourceRepeat.getString("RepeatType");					// 반복 단위 (매일 : D / 매주 : W / 매월 : M / 매년 : Y)
		String repetitionSelType = resourceRepeat.getString("RepeatEndType");		// 반복 범위 (?회 반복 : R / 지정된 일까지 반복 : I)
		String repetitionEveryAtt = ("0".equalsIgnoreCase(resourceRepeat.getString("RepeatAppointType"))) ? "A" : "B";		// 설정 구분값 
		/*
		 * 매일
		 *  - A = 매?일마다
		 *  - B = 매일(평일)
		 *  
		 *  매월/매년
		 *   - A = 날짜
		 *   - B = 요일
		 */
		String startDate = resourceRepeat.getString("RepeatStartDate");				// 반복 시작일
		String endDate = resourceRepeat.getString("RepeatEndDate");					// 반복 종료일
		int repetitionCount = Integer.parseInt(resourceRepeat.getString("RepeatCount"));				// 반복 범위에서 ?회 반복일 경우, 반복 횟수
		String tempDate = startDate;

		String[] repeatWeek = {"N","N","N","N","N","N","N"};				// 일/월/화/수/목/금/토 체크 여부
		repeatWeek[0] = resourceRepeat.getString("RepeatSunday");				// 일
		repeatWeek[1] = resourceRepeat.getString("RepeatMonday");				// 월
		repeatWeek[2] = resourceRepeat.getString("RepeatTuesday");				// 화
		repeatWeek[3] = resourceRepeat.getString("RepeatWednseday");			// 수
		repeatWeek[4] = resourceRepeat.getString("RepeatThursday");			// 목
		repeatWeek[5] = resourceRepeat.getString("RepeatFriday");				// 금
		repeatWeek[6] = resourceRepeat.getString("RepeatSaturday");			// 토
		
		for(int i=0; i<7; i++){
			if(repeatWeek[i].equals("Y")){
				break;
			}
			if(i == 6 && repeatWeek[i].equals("N")){
				repeatWeek = null;
			}
		}
		
		String repetitionEveryDay = resourceRepeat.getString("RepeatDay");				// 매월 ?일에 반복 (매월, 매년)
		
		String repetitionSelectMonthly = resourceRepeat.getString("RepeatMonth");		// 매년 ?월 마다 반복
		int repetitionSelectWeekly = Integer.parseInt(resourceRepeat.getString("RepeatWeek"));				// 선택한 주
		

		// int repetitionPerAtt = Integer.parseInt(resourceRepeat.getString("RepetitionPerAtt"));			// 반복 주기 (매일 : 매?일마다 / 매주 : 매?주마다 / 매년 : 매?년마다)
		int repetitionPerAtt = 0;		// 반복 주기 (매일 : 매?일마다 / 매주 : 매?주마다 / 매년 : 매?년마다)
		try {
			repetitionPerAtt = Integer.parseInt(resourceRepeat.getString("RepetitionPerAtt"));			// 반복 주기 (매일 : 매?일마다 / 매주 : 매?주마다 / 매년 : 매?년마다)
		} catch(NullPointerException ex) {
			String repetitionSelectYear = resourceRepeat.getString("RepeatYear");				// ?년 마다 반복
			switch(repetitionType){
				case "Y": repetitionPerAtt = Integer.parseInt(repetitionSelectYear); break;
				case "M": repetitionPerAtt = Integer.parseInt(repetitionSelectMonthly); break;
				case "W": repetitionPerAtt = repetitionSelectWeekly; break;
				case "D": repetitionPerAtt = Integer.parseInt(repetitionEveryDay); break;
				default : break;
			}
		} catch(Exception ex) {
			String repetitionSelectYear = resourceRepeat.getString("RepeatYear");				// ?년 마다 반복
			switch(repetitionType){
				case "Y": repetitionPerAtt = Integer.parseInt(repetitionSelectYear); break;
				case "M": repetitionPerAtt = Integer.parseInt(repetitionSelectMonthly); break;
				case "W": repetitionPerAtt = repetitionSelectWeekly; break;
				case "D": repetitionPerAtt = Integer.parseInt(repetitionEveryDay); break;
				default : break;
			}
		}
		
		
		String appointmentStartTime = resourceRepeat.getString("AppointmentStartTime");
		String appointmentEndTime = resourceRepeat.getString("AppointmentEndTime");
		
		Date appointmentStartTimeObj = null;
		Date appointmentEndTimeObj = null;
		
		Boolean addEndDate = false;
		
		// 반복월, 반복일이  10보다 작을경우 Zero padding 필요
		try {
			if(Integer.parseInt(repetitionEveryDay) < 10) {
				repetitionEveryDay = StringUtil.pad(repetitionEveryDay, "0", 2, -1);
			}
			
			if(Integer.parseInt(repetitionSelectMonthly) < 10) {
				repetitionSelectMonthly = StringUtil.pad(repetitionSelectMonthly, "0", 2, -1);
			}
		} catch(NullPointerException ex) {
			LogManager.getLogger(EventSvcImpl.class).debug(ex);
		} catch(ArrayIndexOutOfBoundsException ex) {
			LogManager.getLogger(EventSvcImpl.class).debug(ex);
		} catch(Exception ex) {
			LogManager.getLogger(EventSvcImpl.class).debug(ex);
			// 아무 처리도 하지 않음
		}
		
		
		if(appointmentStartTime!=null && !appointmentStartTime.equals("")){
			appointmentStartTimeObj = DateHelper.strToDate(tempDate + " " + appointmentStartTime);
		}
		if(appointmentEndTime!=null && !appointmentEndTime.equals("")){
			appointmentEndTimeObj = DateHelper.strToDate(tempDate + " " + appointmentEndTime);
		}
		
		if(appointmentStartTimeObj != null && appointmentEndTimeObj != null){
			addEndDate = DateHelper.diffMinute(appointmentStartTimeObj, appointmentEndTimeObj) > 0;
		}
		
		if(repetitionType.equals("D")){		// 매일
			if(repetitionEveryAtt.equals("A")){			// 매 ?일마다
				
				
				if(repetitionSelType.equals("R")){				// ?회 반복
					for(int i=0; i<repetitionCount; i++){
						// INSERT
						sDate = DateHelper.getAddDate(startDate, "yyyy-MM-dd", i*repetitionPerAtt, Calendar.DATE);
						
						repeatData = new CoviMap();
						repeatData.put("StartDate", sDate);
						if(addEndDate)
							repeatData.put("EndDate", DateHelper.getAddDate(sDate, "yyyy-MM-dd", 1, Calendar.DATE));
						else
							repeatData.put("EndDate", sDate);
						repeatList.add(repeatData);
					}
				}
				else if(repetitionSelType.equals("I")){			// 지정된 일까지 반복
					
					// 반복 시작일 INSERT
					repeatData = new CoviMap();
					repeatData.put("StartDate", startDate);
					repeatData.put("EndDate", startDate);
					repeatList.add(repeatData);
					
					while(DateHelper.diffDate(endDate, tempDate) >= 0){
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", repetitionPerAtt, Calendar.DATE);
						
						if(DateHelper.diffDate(endDate, tempDate) >= 0){
							repeatData = new CoviMap();
							repeatData.put("StartDate", tempDate);
							if(addEndDate)
								repeatData.put("EndDate", DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE));
							else
								repeatData.put("EndDate", tempDate);
							repeatList.add(repeatData);
						}
					}
				}
			}
			else if(repetitionEveryAtt.equals("B")){			// 매일(평일)
				if(repetitionSelType.equals("R")){				// ?회 반복
					// 반복 시작일 INSERT
					repeatData = new CoviMap();
					repeatData.put("StartDate", startDate);
					repeatData.put("EndDate", startDate);
					repeatList.add(repeatData);
					
					for(int i=1; i<repetitionCount; i++){
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE);
						
						// 토요일과 일요일 제외하고 INSERT
						int dayOfWeek = DateHelper.getDayOfWeek(tempDate, "yyyy-MM-dd");
						if(dayOfWeek != 1 && dayOfWeek != 7){
							repeatData = new CoviMap();
							repeatData.put("StartDate", tempDate);
							if(addEndDate)
								repeatData.put("EndDate", DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE));
							else
								repeatData.put("EndDate", tempDate);
							repeatList.add(repeatData);
						}else{
							++ repetitionCount;
						}
					}
				}
				else if(repetitionSelType.equals("I")){			// 지정된 일까지 반복
					// 반복 시작일 INSERT
					repeatData = new CoviMap();
					repeatData.put("StartDate", startDate);
					repeatData.put("EndDate", startDate);
					repeatList.add(repeatData);
					
					tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE);
					while(DateHelper.diffDate(endDate, tempDate) >= 0){
						// 토요일과 일요일 제외하고 INSERT
						int dayOfWeek = DateHelper.getDayOfWeek(tempDate, "yyyy-MM-dd");
						if(dayOfWeek != 1 && dayOfWeek != 7){
							repeatData = new CoviMap();
							repeatData.put("StartDate", tempDate);
							if(addEndDate)
								repeatData.put("EndDate", DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE));
							else
								repeatData.put("EndDate", tempDate);
							repeatList.add(repeatData);
						}
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE);
					}
				}
			}
		}
		else if(repetitionType.equals("W")){				// 매주 반복
			
			if(repetitionSelType.equals("R")){				// ?회 반복
				
				// 21.11.26, repetitionCount(반복횟수) 만큼만 주를 반복해서 지정 요일이 다음주부터 시작될 때 마지막 주를 처리 못함. 이를 수정.
				int tmpWeekCnt = 0;
				
				for(int i=0; repetitionCount > tmpWeekCnt; i++){	// repetitionCount 만큼 반복하지만 첫 주에 데이터가 없을 시 tmpWeekCnt 값을 증가시키지 않아 반복횟수를 한번 더 추가.
					int tmpLastWeek = 7;
					
					if(i==0){
						tmpLastWeek = 8 - DateHelper.getDayOfWeek(tempDate, "yyyy-MM-dd");			// 반복시작일
					}
					
					for(int j=0; j<tmpLastWeek; j++){				// 한 주를 매일 반복하여 해당 요일 추가.
						int tmpWeek = DateHelper.getDayOfWeek(tempDate, "yyyy-MM-dd") - 1;
						
						//체크된 주 INSERT
						if(repeatWeek[tmpWeek].equals("Y")){
							// repeatWeek : 체크한 반복요일, tmpWeek : loop안의 현재 요일. 같다면 data put.
							repeatData = new CoviMap();
							repeatData.put("StartDate", tempDate);
							if(addEndDate)
								repeatData.put("EndDate", DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE));
							else
								repeatData.put("EndDate", tempDate);
							repeatList.add(repeatData);
						}
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE);
					}
					tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 7*(repetitionPerAtt - 1), Calendar.DATE);
					
					// 21.11.26, 한 주의 반복이 끝났는데, repeatList 에 추가된 데이터가 없다면 tmpWeekCnt는 0. repetitionCount와 tmpWeekCnt 같을 때 escape.
					if (repeatList.size() != 0 ) {
						tmpWeekCnt++;
					}
				}
			}
			else if(repetitionSelType.equals("I")){			// 지정된 일까지 반복
				int i=0;
				while(DateHelper.diffDate(endDate, DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 7*(repetitionPerAtt - 1), Calendar.DATE)) >= 0){
					int tmpLastWeek = 7;
					
					if(i==0){
						tmpLastWeek = 8 - DateHelper.getDayOfWeek(tempDate, "yyyy-MM-dd");			// 반복시작일
					}
					
					for(int j=0; j<tmpLastWeek; j++){
						int tmpWeek = DateHelper.getDayOfWeek(tempDate, "yyyy-MM-dd") - 1;
						
						// 21.08.03. 기존 로직에서 반복을 진행하며 repeatList.add() 진행될 때, 종료일 체크없이 반복 횟수만으로 일정에 넣어주어, 종료일 체크로직 추가.
						// 예) 1월 1일(월) ~ 1월 10일(수)까지 반복일로 정해놓고 매주 월,화,금요일을 반복체크해주면, 12일(금)까지 일정에 추가됨. 이를 수정.
						//체크된 주 INSERT
						if ( (repeatWeek[tmpWeek].equals("Y")) && ( DateHelper.diffDate(endDate, tempDate) >= 0 ) ) {
							repeatData = new CoviMap();
							repeatData.put("StartDate", tempDate);
							if(addEndDate)
								repeatData.put("EndDate", DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE));
							else
								repeatData.put("EndDate", tempDate);
							repeatList.add(repeatData);
						}
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE);
					}
					++i;
					tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 7*(repetitionPerAtt - 1), Calendar.DATE);
				}
			}
		}
		else if(repetitionType.equals("M")){			// 매월
			int repetitionEveryMonth = resourceRepeat.getInt("RepeatMonth");			// ?개월 마다
			if(repetitionSelectWeekly != 5 && repeatWeek == null) repetitionEveryAtt = "A";
			if(repetitionEveryAtt.equals("A")){				// 날짜
				
				tempDate = tempDate.substring(0, tempDate.lastIndexOf('-')) + "-" + repetitionEveryDay;
				
				if(DateHelper.diffDate(startDate, tempDate) > 0){		// 반복일자 시작일의 일자를 반복일로 변경하여 첫번째 생성되는 반복일을 구한 후. 첫번째 반복일이 시작일보다 빠른 경우, 1달을 더하도록 수정
					tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.MONTH);
				}
				
				if(repetitionSelType.equals("R")){				// ?회 반복
					for(int i=0; i<repetitionCount; i++){
						//INSERT
						repeatData = new CoviMap();
						repeatData.put("StartDate", tempDate);
						if(addEndDate)
							repeatData.put("EndDate", DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE));
						else
							repeatData.put("EndDate", tempDate);
						repeatList.add(repeatData);
						
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", repetitionEveryMonth, Calendar.MONTH);
					}
				}
				else if(repetitionSelType.equals("I")){			// 지정된 일까지 반복
					while(DateHelper.diffDate(endDate, tempDate) >= 0){
						//INSERT
						repeatData = new CoviMap();
						repeatData.put("StartDate", tempDate);
						if(addEndDate)
							repeatData.put("EndDate", DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE));
						else
							repeatData.put("EndDate", tempDate);
						repeatList.add(repeatData);
						
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", repetitionEveryMonth, Calendar.MONTH);
					}
				}
			}
			else if(repetitionEveryAtt.equals("B")){			// 요일
				
				String targetDate = "";
				if(repetitionSelType.equals("R")){				// ?회 반복
					
					
					for(int i=0; i<repetitionCount; i++){
						targetDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", repetitionEveryMonth, Calendar.MONTH);
						targetDate = targetDate.substring(0, tempDate.lastIndexOf('-')) + "-01";
						
						if(repetitionSelectWeekly == 5 && repeatWeek == null){		//마지막 날일 경우
							//INSERT
							String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE); 
							
							repeatData = new CoviMap();
							repeatData.put("StartDate", temp2Date);
							if(addEndDate)
								repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
							else
								repeatData.put("EndDate", temp2Date);
							repeatList.add(repeatData);
						}
						else{
							if(repetitionSelectWeekly == 5){		//마지막 주일 경우
								for(int j=0; j<repeatWeek.length; j++){
									if(repeatWeek[j].equals("Y")){
										String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE);
										temp2Date = DateHelper.getFirstDayOfWeek( Integer.parseInt(temp2Date.split("-")[0]), Integer.parseInt(temp2Date.split("-")[1]), j+1, "yyyy-MM-dd");
										
										String repeatDate = DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", (repetitionSelectWeekly-1)*7, Calendar.DATE);
										
										if(!temp2Date.split("-")[1].equals(repeatDate.split("-")[1])){
											repeatDate = DateHelper.getAddDate(repeatDate, "yyyy-MM-dd", -7, Calendar.DATE);
										}
										
										repeatData = new CoviMap();
										repeatData.put("StartDate", repeatDate);
										if(addEndDate)
											repeatData.put("EndDate", DateHelper.getAddDate(repeatDate, "yyyy-MM-dd", 1, Calendar.DATE));
										else
											repeatData.put("EndDate", repeatDate);
										repeatList.add(repeatData);
									}
								}
							}
							else{		//첫째,둘째,셋째,넷째 주일 경우
								boolean isUpdatedCount = false;
								for(int j=0; j<repeatWeek.length; j++){
									if(repeatWeek[j].equals("Y")){
										String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE);
										temp2Date = DateHelper.getFirstDayOfWeek( Integer.parseInt(temp2Date.split("-")[0]), Integer.parseInt(temp2Date.split("-")[1]), j+1, "yyyy-MM-dd");
										
										// 주말반복인 상태에서 1일이 일요일인 경우에 1주일을 더한다.
										if (DateHelper.getDayOfWeek(temp2Date, "yyyy-MM-dd") == 1 && Integer.parseInt(temp2Date.split("-")[2]) == 1 && repeatWeek[0].equals("Y") && repeatWeek[6].equals("Y")) {
											temp2Date = DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 7, Calendar.DATE);
										}
										
										temp2Date = DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", (repetitionSelectWeekly-1)*7, Calendar.DATE);
										
										if(DateHelper.diffDate(startDate, temp2Date) > 0){		// 계산된 반복일자가 시작일보다 빠른 경우, 반복일자를 사용하지 않고 루프를 1회 더 진행
											if (!isUpdatedCount) repetitionCount++;
											isUpdatedCount = true;
										} else {
											repeatData = new CoviMap();
											repeatData.put("StartDate", temp2Date);
											if(addEndDate)
												repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
											else
												repeatData.put("EndDate", temp2Date);
											repeatList.add(repeatData);
										}
									}
								}
							}
						}
						
						tempDate = targetDate;
					}
					
				}
				else if(repetitionSelType.equals("I")){			// 지정된 일까지 반복
					//targetDate = tempDate;
					
					do{
						targetDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", repetitionEveryMonth, Calendar.MONTH);
						targetDate = targetDate.substring(0, tempDate.lastIndexOf('-')) + "-01";
						
						if(repetitionSelectWeekly == 5 && repeatWeek.length == 0){		//마지막 날일 경우
							//INSERT
							String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE); 
							
							repeatData = new CoviMap();
							repeatData.put("StartDate", temp2Date);
							if(addEndDate)
								repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
							else
								repeatData.put("EndDate", temp2Date);
							repeatList.add(repeatData);
						}
						else{
							if(repetitionSelectWeekly == 5){		//마지막 주일 경우
								for(int j=0; j<repeatWeek.length; j++){
									if(repeatWeek[j].equals("Y")){
										String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE);
										temp2Date = DateHelper.getLastDayOfWeek( Integer.parseInt(temp2Date.split("-")[0]), Integer.parseInt(temp2Date.split("-")[1]), j+1, "yyyy-MM-dd");
										
										repeatData = new CoviMap();
										repeatData.put("StartDate", temp2Date);
										if(addEndDate)
											repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
										else
											repeatData.put("EndDate", temp2Date);
										repeatList.add(repeatData);
									}
								}
							}
							else{		//첫째,둘째,셋째,넷째 주일 경우
								for(int j=0; j<repeatWeek.length; j++){
									if(repeatWeek[j].equals("Y")){
										String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE);
										temp2Date = DateHelper.getFirstDayOfWeek( Integer.parseInt(temp2Date.split("-")[0]), Integer.parseInt(temp2Date.split("-")[1]), j+1, "yyyy-MM-dd");
										
										temp2Date = DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", (repetitionSelectWeekly-1)*7, Calendar.DATE);
										
										repeatData = new CoviMap();
										repeatData.put("StartDate", temp2Date);
										if(addEndDate)
											repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
										else
											repeatData.put("EndDate", temp2Date);
										repeatList.add(repeatData);
									}
								}
							}
						}
						
						tempDate = targetDate;
						//targetDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", repetitionEveryMonth, Calendar.MONTH);
						//targetDate = targetDate.substring(0, tempDate.lastIndexOf('-')) + "-01";
					}while(DateHelper.diffDate(endDate, targetDate) >= 0);
				}
			}
		}
		else if(repetitionType.equals("Y")){			// 매년
			if(repetitionSelectWeekly != 5 && repeatWeek == null) repetitionEveryAtt = "A";
			
			if(repetitionEveryAtt.equals("A")){				// 날짜
				
				tempDate = tempDate.substring(0, tempDate.indexOf('-')) + "-" + repetitionSelectMonthly + "-" + repetitionEveryDay;
				
				if(repetitionSelType.equals("R")){				// ?회 반복
					for(int i=0; i<repetitionCount; i++){
						if(DateHelper.diffDate(tempDate, startDate) >= 0){
							//INSERT
							repeatData = new CoviMap();
							repeatData.put("StartDate", tempDate);
							if(addEndDate)
								repeatData.put("EndDate", DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE));
							else
								repeatData.put("EndDate", tempDate);
							repeatList.add(repeatData);
						}else{
							--i;
						}
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", repetitionPerAtt, Calendar.YEAR);
					}
				}
				else if(repetitionSelType.equals("I")){			// 지정된 일까지 반복
					while(DateHelper.diffDate(endDate, tempDate) >= 0){
						//INSERT
						repeatData = new CoviMap();
						repeatData.put("StartDate", tempDate);
						if(addEndDate)
							repeatData.put("EndDate", DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.DATE));
						else
							repeatData.put("EndDate", tempDate);
						repeatList.add(repeatData);
						
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", repetitionPerAtt, Calendar.YEAR);
					}
				}
			}
			else if(repetitionEveryAtt.equals("B")){			// 요일
				if(repetitionSelType.equals("R")){				// ?회 반복
					tempDate = tempDate.substring(0, tempDate.indexOf('-')) + "-" + repetitionSelectMonthly + "-01";
					String targetDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.MONTH);
					targetDate = targetDate.substring(0, targetDate.lastIndexOf('-')) + "-01";
					
					for(int i=0; i<repetitionCount; i++){
						if(repetitionSelectWeekly == 5 && repeatWeek.length == 0){		//마지막 날일 경우
							String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE); 
							
							repeatData = new CoviMap();
							repeatData.put("StartDate", temp2Date);
							if(addEndDate)
								repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
							else
								repeatData.put("EndDate", temp2Date);
							repeatList.add(repeatData);
						}
						else{
							if(repetitionSelectWeekly == 5){		//마지막 주일 경우
								for(int j=0; j<repeatWeek.length; j++){
									if(repeatWeek[j].equals("Y")){
										String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE);
										temp2Date = DateHelper.getLastDayOfWeek( Integer.parseInt(temp2Date.split("-")[0]), Integer.parseInt(temp2Date.split("-")[1]), j+1, "yyyy-MM-dd");
										
										repeatData = new CoviMap();
										repeatData.put("StartDate", temp2Date);
										if(addEndDate)
											repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
										else
											repeatData.put("EndDate", temp2Date);
										repeatList.add(repeatData);
									}
								}
							}
							else{		//첫째,둘째,셋째,넷째 주일 경우
								for(int j=0; j<repeatWeek.length; j++){
									if(repeatWeek[j].equals("Y")){
										String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE);
										temp2Date = DateHelper.getFirstDayOfWeek( Integer.parseInt(temp2Date.split("-")[0]), Integer.parseInt(temp2Date.split("-")[1]), j+1, "yyyy-MM-dd");
										
										temp2Date = DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", (repetitionSelectWeekly-1)*7, Calendar.DATE);
										
										repeatData = new CoviMap();
										repeatData.put("StartDate", temp2Date);
										if(addEndDate)
											repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
										else
											repeatData.put("EndDate", temp2Date);
										repeatList.add(repeatData);
									}
								}
							}
						}
						
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", repetitionPerAtt, Calendar.YEAR);
						targetDate = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", 1, Calendar.YEAR);
						targetDate = targetDate.substring(0, targetDate.lastIndexOf('-')) + "-01";
					}
					
				}
				else if(repetitionSelType.equals("I")){			// 지정된 일까지 반복
					tempDate = tempDate.substring(0, tempDate.indexOf('-')) + "-" + repetitionSelectMonthly + "-01";
					String targetDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", 1, Calendar.MONTH);
					targetDate = targetDate.substring(0, targetDate.lastIndexOf('-')) + "-01";
					
					String tempEndDate = DateHelper.getAddDate(endDate, "yyyy-MM-dd", 1, Calendar.YEAR);
					while(DateHelper.diffDate(tempEndDate, targetDate) >= 0){
						if(repetitionSelectWeekly == 5 && repeatWeek.length == 0){		//마지막 날일 경우
							String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE); 
							
							repeatData = new CoviMap();
							repeatData.put("StartDate", temp2Date);
							if(addEndDate)
								repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
							else
								repeatData.put("EndDate", temp2Date);
							repeatList.add(repeatData);
						}
						else{
							if(repetitionSelectWeekly == 5){		//마지막 주일 경우
								for(int j=0; j<repeatWeek.length; j++){
									if(repeatWeek[j].equals("Y")){
										String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE);
										temp2Date = DateHelper.getLastDayOfWeek( Integer.parseInt(temp2Date.split("-")[0]), Integer.parseInt(temp2Date.split("-")[1]), j+1, "yyyy-MM-dd");
										
										repeatData = new CoviMap();
										repeatData.put("StartDate", temp2Date);
										if(addEndDate)
											repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
										else
											repeatData.put("EndDate", temp2Date);
										repeatList.add(repeatData);
									}
								}
							}
							else{		//첫째,둘째,셋째,넷째 주일 경우
								for(int j=0; j<repeatWeek.length; j++){
									if(repeatWeek[j].equals("Y")){
										String temp2Date = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", -1, Calendar.DATE);
										temp2Date = DateHelper.getFirstDayOfWeek( Integer.parseInt(temp2Date.split("-")[0]), Integer.parseInt(temp2Date.split("-")[1]), j+1, "yyyy-MM-dd");
										
										temp2Date = DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", (repetitionSelectWeekly-1)*7, Calendar.DATE);
										
										repeatData = new CoviMap();
										repeatData.put("StartDate", temp2Date);
										if(addEndDate)
											repeatData.put("EndDate", DateHelper.getAddDate(temp2Date, "yyyy-MM-dd", 1, Calendar.DATE));
										else
											repeatData.put("EndDate", temp2Date);
										repeatList.add(repeatData);
									}
								}
							}
						}
						
						tempDate = DateHelper.getAddDate(tempDate, "yyyy-MM-dd", repetitionPerAtt, Calendar.YEAR);
						targetDate = DateHelper.getAddDate(targetDate, "yyyy-MM-dd", 1, Calendar.YEAR);
						targetDate = targetDate.substring(0, targetDate.lastIndexOf('-')) + "-01";
					}
				}
			}
		}
		
		return repeatList;
		
	}

	// Resource Booking 데이터
	@Override
	public void insertEventResourceBooking(CoviMap params) throws Exception {
		coviMapperOne.insert("user.event.insertEventResourceBooking", params);
	}

	// 연관 이벤트 데이터
	@Override
	public void insertEventRelation(CoviMap params) throws Exception {
		int result = coviMapperOne.update("user.event.updateEventRelation", params);
		if (result == 0) coviMapperOne.insert("user.event.insertEventRelation", params);
	}

	// 알림 데이터
	@Override
	public void insertEventNotification(CoviMap params) throws Exception {
		coviMapperOne.insert("user.event.insertEventNotification", params);
	}

	//Date 테이블 데이터 삭제 -  DateID로
	@Override
	public void deleteEventDateByDateID(CoviMap params) throws Exception {
		coviMapperOne.delete("user.event.deleteEventDateByDateID", params);
	}
	//Date 테이블 데이터 삭제 -  EventID로
		@Override
		public void deleteEventDateByEventID(CoviMap params) throws Exception {
			coviMapperOne.delete("user.event.deleteEventDateByEventID", params);
		}

	@Override
	public void updateEventRepeat(CoviMap params) throws Exception {
		validateRepeat(params);
		
		CoviMap repeatParams = (CoviMap) params.clone();
		repeatParams.put("RepeatTimeZoneDisplay", SessionHelper.getSession("UR_TimeZoneDisplay"));
		
		coviMapperOne.update("user.event.updateEventRepeat", repeatParams);
	}

	@Override
	public CoviList selectResourceList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.event.selectResourceList", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,ResourceName");
	}

	//Resource Booking 테이블 데이터 삭제
	@Override
	public void deleteEventResourceBooking(CoviMap params) throws Exception {
		coviMapperOne.delete("user.event.deleteEventResourceBooking", params);
	}

	//Relation 테이블 데이터 삭제
	@Override
	public void deleteEventRelation(CoviMap params) throws Exception {
		coviMapperOne.delete("user.event.deleteEventRelation", params);
	}

	@Override
	public CoviMap selectNotificationByOne(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
	    CoviMap map = coviMapperOne.selectOne("user.event.selectNotificationByOne", params);
		
	    if(map != null){
	    	returnObj =  CoviSelectSet.coviSelectJSON(map, "IsNotification,IsReminder,ReminderTime,IsCommentNotification,MediumKind").getJSONObject(0);
	    }
	    
		return returnObj;
	}
	
	@Override
	public void updateEvent(CoviMap params) throws Exception {
		coviMapperOne.update("user.event.updateEvent", params);
		coviMapperOne.update("user.event.updateLinkEvent", params);
	}

	//Notification 테이블 데이터 삭제
	@Override
	public void deleteEventNotification(CoviMap params) throws Exception {
		coviMapperOne.delete("user.event.deleteEventNotification", params);
	}

	@Override
	public void updateEventNotification(CoviMap params) throws Exception {
		int cnt = coviMapperOne.update("user.event.updateEventNotification", params);
		
		// 수정되는 Row가 없는경우 해당 Row가 없다고 판단하고 Insert 수행
		if(cnt == 0) {
			params.put("RegisterKind", "A");
			insertEventNotification(params);
		}
	}

	//등록자에 대한 알림 저장. Notification 테이블의 RegisterCode 파라미터 필요없음
	@Override
	public void insertEventNotificationByRegister(CoviMap params) throws Exception {
		coviMapperOne.insert("user.event.insertEventNotificationByRegister", params);
	}

	// Event 조회 
	@Override
	public  CoviMap selectEvent(CoviMap params) throws Exception {
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("UserCode", SessionHelper.getSession("USERID"));
		CoviMap map = coviMapperOne.select("user.event.selectEvent", params);
		
		return CoviSelectSet.coviSelectJSON(map, "FolderID,FolderType,EventID,FolderName,FolderColor,EventType,LinkEventID,MasterEventID,Subject,Description,Place,IsPublic,IsInviteOther,ImportanceState,OwnerCode,RegistDate,RegisterCode,RegisterPhoto,MultiRegisterName,RegisterData,RegisterDept,ModifierCode,MailAddress,MultiJobPositionName,MultiJobLevelName,MultiJobTitleName").getJSONObject(0);
	}

	// Event Date 조회
	@Override
	public CoviMap selectEventDate(CoviMap params) throws Exception{
		CoviMap returnObject = new CoviMap();
		CoviList map = coviMapperOne.list("user.event.selectEventDate", params);
		
		if(map.size() > 0)
			returnObject = CoviSelectSet.coviSelectJSON(map, "RepeatID,StartDate,EndDate,StartTime,EndTime,IsAllDay,IsRepeat,DateID").getJSONObject(0);
		
		return returnObject;
	}
	
	// Event Date 조회
	@Override
	public  CoviList selectEventDateAll(CoviMap params) throws Exception{
		CoviList list = coviMapperOne.list("user.event.selectEventDate", params);
		
		return CoviSelectSet.coviSelectJSON(list, "StartDate,EndDate,StartTime,EndTime,IsAllDay,IsRepeat,DateID");
	}

	// Event Repeat 조회
	@Override
	public  CoviMap selectEventRepeat(CoviMap params) throws Exception{
		CoviMap map = coviMapperOne.select("user.event.selectEventRepeat", params);
		
		return CoviSelectSet.coviSelectJSON(map, "AppointmentStartTime,AppointmentEndTime,AppointmentDuring,RepeatType,RepeatYear,RepeatMonth,RepeatWeek,RepeatDay,RepeatMonday,RepeatTuesday,RepeatWednseday,RepeatThursday,RepeatFriday,RepeatSaturday,RepeatSunday,RepeatStartDate,RepeatEndType,RepeatEndDate,RepeatCount,RepeatAppointType,RepeatTimeZoneDisplay").getJSONObject(0);
	}


	// Event Resource 조회
	@Override
	public  CoviList selectEventResource(CoviMap params) throws Exception{
		CoviList list = coviMapperOne.list("user.event.selectEventResource", params);
		
		return CoviSelectSet.coviSelectJSON(list, "FolderID,ResourceName,TypeName,LeastRentalTime");
	}

	// Event Notification 조회
	@Override
	public  CoviMap selectEventNotification(CoviMap params) throws Exception{
		CoviMap returnObject=new CoviMap();
		CoviList map = coviMapperOne.list("user.event.selectEventNotification", params);
		
		if(map.size() > 0)
			returnObject = CoviSelectSet.coviSelectJSON(map, "IsNotification,IsReminder,ReminderTime,IsCommentNotification,MediumKind").getJSONObject(0);
		
		return returnObject;
		
	}
	
	//자원 정보 조회
	@Override
	public CoviMap selectResourceData(CoviMap params) throws Exception {
		CoviMap returnObject = new CoviMap();
		CoviMap map = coviMapperOne.selectOne("user.event.selectResourceData", params);
		
		if(map != null && map.size() > 0)
			returnObject =  CoviSelectSet.coviSelectJSON(map, "IconPath,BookingType,ReturnType,NotificationState,NotificationKind,LeastRentalTime,LeastPartRentalTime").getJSONObject(0);
	
		return returnObject;
	}
	
	@Override
	public String getACLFolderData(CoviMap userInfoObj, String serviceType, String aclValue) throws Exception{
		Set<String> authObjCodeSet = ACLHelper.getACL(userInfoObj, "FD", serviceType, aclValue);
		String[] folderObjArr = authObjCodeSet.toArray(new String[authObjCodeSet.size()]);
		
		String objectInStr = "";
		if(folderObjArr.length > 0){
			objectInStr = "(" + ACLHelper.join(folderObjArr, ",") + ")";
		}
		else{
			objectInStr = "('')";
		}
		return objectInStr;
	}
	
	@Override
	public String getACLFolderData(Set<String> authObjCodeSet, String aclValue) throws Exception{
		String[] folderObjArr = authObjCodeSet.toArray(new String[authObjCodeSet.size()]);
		
		String objectInStr = "";
		if(folderObjArr.length > 0){
			objectInStr = "(" + ACLHelper.join(folderObjArr, ",") + ")";
		}
		else{
			objectInStr = "('')";
		}
		
		return objectInStr;
	}
	
	// 댓글 알림을 위한 데이터 조회
	@Override
	public CoviList selectNotificationComment(CoviMap params) throws Exception{
		CoviList  list = coviMapperOne.list("user.event.selectNotificationComment", params);
		return CoviSelectSet.coviSelectJSON(list, "RegisterCode");
	}
	
	// 미리알림 보내기
	@Override
	public void sendNotificationMessage(CoviMap params) throws Exception{
		String strServiceType = params.getString("ServiceType");
        String strObjectType = params.getString("ObjectType");
        String strObjectID = params.getString("ObjectID");
        String strMsgType = params.getString("MsgType");
        String strMessageID = params.getString("MessageID");
        String strSubMsgID = params.getString("SubMsgID");
        String strMediaType = params.getString("MediaType");
        String strIsUse = params.getString("IsUse");
        String strIsDelay = params.getString("IsDelay");
        String strApprovalState = params.getString("ApprovalState");
        String strSenderCode = params.getString("SenderCode");
        String strReservedDate = params.getString("ReservedDate");
        String strXSLPath = params.getString("XSLPath");
        String strWidth = params.getString("Width");
        String strHeight = params.getString("Height");
        String strPopupURL = params.getString("PopupURL");
        String strGotoURL = params.getString("GotoURL");
        String strMobileURL = params.getString("MobileURL");
        String strOpenType = params.getString("OpenType");
        String strMessagingSubject = params.getString("MessagingSubject");
        String strMessageContext = params.getString("MessageContext");
        String strReceiverText = params.getString("ReceiverText");
        String strReservedStr1 = params.getString("ReservedStr1");
        String strReservedStr2 = params.getString("ReservedStr2");
        String strReservedStr3 = params.getString("ReservedStr3");
        String strReservedStr4 = params.getString("ReservedStr4");
        String strReservedInt1 = params.getString("ReservedInt1");
        String strReservedInt2 = params.getString("ReservedInt2");
        String strRegistererCode = params.getString("RegisterCode");
        String strReceiversCode = params.getString("ReceiversCode");
        String domainID = SessionHelper.getSession("DN_ID");
        
        // 값이 비어있을경우 NULL 값으로 전달
        strServiceType = strServiceType == null ? null : (strServiceType.isEmpty() ? null : strServiceType);
        strObjectType = strObjectType == null ? null : (strObjectType.isEmpty() ? null : strObjectType);
        strObjectID = strObjectID == null ? null : (strObjectID.isEmpty() ? null : strObjectID);
        strMsgType = strMsgType == null ? null : (strMsgType.isEmpty() ? null : strMsgType);
        strMessageID = strMessageID == null ? null : (strMessageID.isEmpty() ? null : strMessageID);
        strSubMsgID = strSubMsgID == null ? null : (strSubMsgID.isEmpty() ? null : strSubMsgID);
        strMediaType = strMediaType == null ? null : (strMediaType.isEmpty() ? null : strMediaType);
        strIsUse = strIsUse == null ? "Y" : (strIsUse.isEmpty() ? "Y" : strIsUse);
        strIsDelay = strIsDelay == null ? "N" : (strIsDelay.isEmpty() ? "N" : strIsDelay);
        strApprovalState = strApprovalState == null ? "P" : (strApprovalState.isEmpty() ? "P" : strApprovalState);
        strSenderCode = strSenderCode == null ? null : (strSenderCode.isEmpty() ? null : strSenderCode);
        strReservedDate = strReservedDate == null ? null : (strReservedDate.isEmpty() ? null : strReservedDate);
        strXSLPath = strXSLPath == null ? null : (strXSLPath.isEmpty() ? null : strXSLPath);
        strWidth = strWidth == null ? null : (strWidth.isEmpty() ? null : strWidth);
        strHeight = strHeight == null ? null : (strHeight.isEmpty() ? null : strHeight);
        strPopupURL = strPopupURL == null ? null : (strPopupURL.isEmpty() ? null : strPopupURL);
        strGotoURL = strGotoURL == null ? null : (strGotoURL.isEmpty() ? null : strGotoURL);
        strMobileURL = strMobileURL == null ? null : (strMobileURL.isEmpty() ? null : strMobileURL);
        strOpenType = strOpenType == null ? null : (strOpenType.isEmpty() ? null : strOpenType);
        strMessagingSubject = strMessagingSubject == null ? null : (strMessagingSubject.isEmpty() ? null : strMessagingSubject);
        strMessageContext = strMessageContext == null ? null : (strMessageContext.isEmpty() ? null : strMessageContext);
        strReceiverText = strReceiverText == null ? null : (strReceiverText.isEmpty() ? null : strReceiverText);
        strReservedStr1 = strReservedStr1 == null ? null : (strReservedStr1.isEmpty() ? null : strReservedStr1);
        strReservedStr2 = strReservedStr2 == null ? null : (strReservedStr2.isEmpty() ? null : strReservedStr2);
        strReservedStr3 = strReservedStr3 == null ? null : (strReservedStr3.isEmpty() ? null : strReservedStr3);
        strReservedStr4 = strReservedStr4 == null ? null : (strReservedStr4.isEmpty() ? null : strReservedStr4);
        strReservedInt1 = strReservedInt1 == null ? null : (strReservedInt1.isEmpty() ? null : strReservedInt1);
        strReservedInt2 = strReservedInt2 == null ? null : (strReservedInt2.isEmpty() ? null : strReservedInt2);
        strRegistererCode = strRegistererCode == null ? null : (strRegistererCode.isEmpty() ? null : strRegistererCode);
        strReceiversCode = strReceiversCode == null ? null : (strReceiversCode.isEmpty() ? null : strReceiversCode);
        domainID = domainID == null ? null : (domainID.isEmpty() ? null : domainID);
		
		params.put("ServiceType", strServiceType);
        params.put("ObjectType", strObjectType);
        params.put("ObjectID", strObjectID);
        params.put("MsgType", strMsgType);
        params.put("MessageID", strMessageID);
        params.put("SubMsgID", strSubMsgID);
        params.put("MediaType", strMediaType);
        params.put("IsUse", strIsUse);
        params.put("IsDelay", strIsDelay);
        params.put("ApprovalState", strApprovalState);
        params.put("SenderCode", strSenderCode);
        params.put("ReservedDate", strReservedDate);
        params.put("XSLPath", strXSLPath);
        params.put("Width", strWidth);
        params.put("Height", strHeight);
        params.put("PopupURL", strPopupURL);
        params.put("GotoURL", strGotoURL);
        params.put("MobileURL", strMobileURL);
        params.put("OpenType", strOpenType);
        params.put("MessagingSubject", strMessagingSubject);
        params.put("MessageContext", strMessageContext);
        params.put("ReceiverText", strReceiverText);
        params.put("ReservedStr1", strReservedStr1);
        params.put("ReservedStr2", strReservedStr2);
        params.put("ReservedStr3", strReservedStr3);
        params.put("ReservedStr4", strReservedStr4);
        params.put("ReservedInt1", strReservedInt1);
        params.put("ReservedInt2", strReservedInt2);
        params.put("RegistererCode", strRegistererCode);
        params.put("ReceiversCode", strReceiversCode);
        params.put("DomainID", domainID);
		
        messageSvc.insertMessagingData(params);
	}

	/**
	 * 반복 일정, 개별 등록시 자원 데이터 update
	 */
	@Override
	public void updateEachScheduleResource(CoviMap params) throws Exception {
		coviMapperOne.update("user.event.updateEachScheduleResource", params);
	}

	/**
	 * 반복 일정, 개별 등록 시 자원 연결 데이터 insert
	 */
	@Override
	public void insertEachScheduleRelation(CoviMap params) throws Exception {
		coviMapperOne.update("user.event.insertEachScheduleRelation", params);
	}
	
	@Override
	public void deleteRelationByScheduleResourceID(CoviMap params) throws Exception {
		coviMapperOne.delete("user.event.deleteRelationByScheduleResourceID", params);
	}

	@Override
	public void updateResourceRealEndDateTime(CoviMap params) throws Exception {
		coviMapperOne.update("user.event.updateResourceRealEndDateTime", params);
	}
	
	@Override
	public void updateEventRepeatDate(CoviMap params) throws Exception {
		coviMapperOne.update("user.event.updateEventRepeatDate", params);
	}

	@Override
	public void updateMessagingCancelState(CoviMap params) throws Exception {
		String serviceType = params.getString("ServiceType");
		String objectType = params.getString("ObjectType");
		int objectID = params.getInt("ObjectID");
		String searchType = params.getString("SearchType");
		
		messageSvc.updateMessagingState(4, serviceType, objectType, objectID, searchType);
	}
	
	@Override
	public void updateArrMessagingCancelState(CoviMap params) throws Exception {
		String serviceType = params.getString("ServiceType");
		String objectType = params.getString("ObjectType");
		CoviList arrObjectID = (CoviList) params.get("arrObjectID");
		String searchType = params.getString("SearchType");
		
		messageSvc.updateArrMessagingState(4, serviceType, objectType, arrObjectID, searchType);
	}

	@Override
	public CoviList selectAnniversaryList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.event.selectAnniversaryList", params);
		
		return CoviSelectSet.coviSelectJSON(list, "CalendarID,SolarDate,DomainID,AnniversaryType,Anniversary");
	}
	
	@Override
	public String[] getDateIDs(String eventID) throws Exception {
		String[] returnDateIDs;
		
		CoviMap params = new CoviMap();
		params.put("EventID", eventID);
		returnDateIDs = Objects.toString(coviMapperOne.selectOne("user.event.selectDateIDs", params), "") .split(",");
		
		return returnDateIDs;
	}
	
@Override
	public void deleteAllNotification(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		String eventID = params.getString("EventID");
		String dateIDs[] = null; 
		
		dateIDs = getDateIDs(eventID);
		
		// 이전 미리알림 취소 처리
		for(int i=0; i<dateIDs.length; i++){
			CoviMap notiParams = new CoviMap();
			notiParams.put("SearchType", "EQ");
			notiParams.put("ServiceType", params.getString("ServiceType"));
			notiParams.put("ObjectType", "reminder_" + params.getString("UserCode"));			// 참석자 미리알림 삭제
			notiParams.put("ObjectID", dateIDs[i]);
			updateMessagingCancelState(notiParams);
		}
		
		// 기존 알림 세팅 제거
		coviMapperOne.delete("user.event.deleteAllNoti", params);
	}
	
	@Override
	public void modifyAllNotification(CoviMap params) throws Exception {
		String eventID = params.getString("EventID");
		String dateIDs[] = null; 
		
		String eventDateID = params.getString("DateID");
		if (!"".equals(eventDateID)) {
			dateIDs = new String[1];
			dateIDs[0] = eventDateID;
		} else {
			dateIDs = getDateIDs(eventID);
		}
		
		// 이전 미리알림 취소 처리
		for(int i=0; i<dateIDs.length; i++){
			CoviMap notiParams = new CoviMap();
			notiParams.put("SearchType", "EQ");
			notiParams.put("ServiceType", params.getString("ServiceType"));
			notiParams.put("ObjectType", "reminder_" + params.getString("UserCode"));			// 참석자 미리알림 삭제
			notiParams.put("ObjectID", dateIDs[i]);
			updateMessagingCancelState(notiParams);
		}
		
		// 기존 알림 세팅 제거
		coviMapperOne.delete("user.event.deleteAllNoti", params);
		
		// Event 객체 조회 ( 발송하려는 )
		
		CoviMap eventObj = selectEvent(params);
		
		// 제목, 반복여부, 폴더타입, 폴더ID
		String subject = eventObj.getString("Subject");
		String folderID = eventObj.getString("FolderID");
		String folderType = eventObj.getString("FolderType");
		
		String registerCode = params.getString("UserCode");

		// 폴더타입에 따라 ServiceType 재설정
		String serviceType = params.getString("ServiceType");
		
		if("Resource".equals(serviceType)) {
			// 자원예약에서 설정되었지만 Master가 일정관리일 경우
			if(folderType.indexOf("Schedule") > -1) {
				serviceType = "Schedule";
			}
		}
		
		//참석자 날짜별 미리알림 데이터
		for(int i=0; i<dateIDs.length; i++){
			String dateID = dateIDs[i];
			// 알림 다시 세팅
			// 알림 데이터
			CoviMap notiSetParams = new CoviMap();
			notiSetParams.put("EventID", eventID);
			notiSetParams.put("DateID", dateID);
			notiSetParams.put("RegisterCode", params.getString("UserCode"));
			notiSetParams.put("RegisterKind", "A");		// 더이상 사용하지 않는 필드 ( 처리여부 고민 )
			notiSetParams.put("IsNotification", "Y");
			notiSetParams.put("IsReminder", params.getString("IsReminder"));
			notiSetParams.put("ReminderTime", params.getString("ReminderTime"));
			notiSetParams.put("IsCommentNotification", params.getString("IsCommentNotification"));
			notiSetParams.put("MediumKind", "");	// 지정안하면 개인설정
			
			insertEventNotification(notiSetParams);
			
			// Date 시작, 종료 시간, RepeatID 정보 조회
			params.put("DateID", dateID);
			CoviMap dateObj = selectEventDate(params);
			
			String repeatID = dateObj.getString("RepeatID");
			String isRepeat = dateObj.getString("IsRepeat");
			
			String startDate = dateObj.getString("StartDate");
			String startTime = dateObj.getString("StartTime");
			
			int remiderTime = params.getInt("ReminderTime");
			
			// 22.03.14 반복일정 수정시 알림시간에 TimeZone 적용.
			String reservedDate = ComUtils.TransServerTime(DateHelper.getAddDate(startDate + " " + startTime, "yyyy-MM-dd HH:mm", (-1*remiderTime), Calendar.MINUTE));
			
			if(DateHelper.diffMinute(reservedDate, ComUtils.TransServerTime(DateHelper.getCurrentDay("yyyy-MM-dd HH:mm"))) >=0){ //발송 시간이 지나지 않은 항목만 발송
				// 미리알림 사용하는 경우에만
				if(params.getString("IsReminder").equals("Y")){
					CoviMap notiParams = new CoviMap();
					
					String alarmUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
					String mobileAlarmUrl = "";
					if("Schedule".equals(serviceType)){
						// 일정 URL
						alarmUrl += "/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
								 + "&eventID=" + eventID + "&dateID=" + dateID + "&isRepeat=" + isRepeat + "&folderID=" + folderID + "&IsAlarm=R";
						mobileAlarmUrl = "/groupware/mobile/schedule/view.do"  + "?eventid=" + eventID + "&dateid=" + dateID + "&isrepeat=" +isRepeat + "&folderid=" + folderID;
					} else {
						// 자원 URL
						alarmUrl += "/groupware/layout/resource_DetailView.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
								 + "&eventID=" + eventID + "&dateID=" + dateID + "&repeatID=" + repeatID + "&isRepeat=" + isRepeat + "&resourceID=" + folderID;
				
						mobileAlarmUrl = "/groupware/mobile/resource/view.do?" + "?eventid=" + eventID + "&dateid=" + dateID + "&repeatid=" + repeatID + "&isrepeat=" + isRepeat + "&resourceid=" + folderID;
					}
					
					
					
					notiParams.put("ObjectType", "reminder_"+registerCode);
					notiParams.put("ObjectID", dateID);
					notiParams.put("SenderCode", registerCode);
					notiParams.put("RegisterCode", registerCode);
					notiParams.put("ReceiversCode", registerCode);
					notiParams.put("MessagingSubject", subject);
					notiParams.put("ReceiverText", subject);
					notiParams.put("ServiceType", serviceType);
					notiParams.put("MsgType", serviceType + "Reminder");
					notiParams.put("IsDelay", "Y");
					notiParams.put("ReservedDate", reservedDate);
					notiParams.put("GotoURL", alarmUrl);
					notiParams.put("PopupURL", alarmUrl);
					notiParams.put("MobileURL", mobileAlarmUrl);
					
					sendNotificationMessage(notiParams);
				}
			}
		}
	}
	
	// 참석자 조회
	@Override
	public CoviList selectAttendee(CoviMap params) throws Exception {

		CoviList list = coviMapperOne.list("user.event.selectAttendee", params);
		return CoviSelectSet.coviSelectJSON(list, "UserCode,UserName,IsOutsider");
	}
		
	// 참석요청 조회
	public CoviMap selectAttendRequest(CoviMap params) throws Exception {
		CoviMap returnMap = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.event.selectAttendRequest", params);
		params.put("listCount", list.size());
		
		returnMap.put("page", params);
		returnMap.put("list", list);
		
		return returnMap;
	}
}
