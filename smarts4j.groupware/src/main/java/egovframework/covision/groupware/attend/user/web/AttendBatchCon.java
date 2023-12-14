package egovframework.covision.groupware.attend.user.web;

import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.text.ParseException;
import java.util.Date;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.baseframework.base.Enums;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.ComUtils;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.covision.groupware.attend.user.service.AttendBatchSvc;
import egovframework.covision.groupware.attend.user.service.AttendCommutingSvc;


@Controller
@RequestMapping("/attendBatch")
public class AttendBatchCon {
	private static final Logger LOGGER = LogManager.getLogger(AttendBatchCon.class);

	@Autowired
	AttendBatchSvc attendBatchSvc;
	@Autowired
	AttendCommutingSvc attendCommutingSvc;

	@Resource(name = "coviMapperOne")
	private CoviMapperOne coviMapperOne;
	/**
	  * @Method Name : setAbsentData
	  * @작성일 : 2020. 4. 17.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 결근처리 
	  * @param request
	  * @param response
	  */
	@RequestMapping(value = "/setAbsentData.do")
	public void setAbsentData(HttpServletRequest request, HttpServletResponse response){
		try {
			//CoviMap domainParams = new CoviMap();
			
			//CoviList domain = attendBatchSvc.getDomainIdList(domainParams);
			
			//for(int i=0;i<domain.size();i++){
				
				CoviMap params =new CoviMap();
				params.put("CompanyCode", request.getParameter("DN_Code"));
				CoviMap absent = attendBatchSvc.setAbsentData(params);
				
				LOGGER.debug("setAbsentData date "+getServerDateTime()+" , domain : "+absent.getString("domain")+", cnt : "+absent.getInt("cnt"));
			//}
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}
	
	/**
	  * @Method Name : setBatchByOtherSys
	  * @작성일 : 2020. 4. 17.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 :
	  * @param request
	  * @param response
	  */
	@RequestMapping(value = "/setBatchByOtherSys.do") 
	public void setBatchByOtherSys(HttpServletRequest request, HttpServletResponse response){
		try{

			if(StringUtils.isNotBlank(request.getParameter("DN_Code")) && 
					Pattern.matches("^[a-zA-Z0-9_]*$", request.getParameter("DN_Code"))) {
				
			CoviMap domainParams = new CoviMap();
//			domainParams.put("OthYn", "Y");
//			CoviList domain = attendBatchSvc.getDomainIdList(domainParams);

//			for(int i=0;i<domain.size();i++){
				CoviMap params =new CoviMap();
				params.put("CompanyCode", request.getParameter("DN_Code"));
				CoviMap othSys = attendBatchSvc.getCommuteDataByOtherSystem(params);
				CoviList othList = othSys.getJSONArray("list");
				for(int j=0;j<othList.size();j++){
					
					CoviMap oth = othList.getJSONObject(j);
					
					CoviMap iParams = new CoviMap();
					iParams.put("CompanyCode", request.getParameter("DN_Code"));
					iParams.put("UserCode",oth.get("usercode"));
					iParams.put("TargetDate",oth.get("workdate"));
					iParams.put("RegUserCode","system");
					
					if("Y".equals(oth.getString("startbatch"))){
						iParams.put("StartTime", oth.get("wstime"));
						iParams.put("StartChannel", "S");
						iParams.put("CommuteType", "S"); //상태 출근
					}
					
					if("Y".equals(oth.getString("endbatch"))){
						iParams.put("EndTime", oth.get("wctime")); 
						iParams.put("EndChannel", "S");
						iParams.put("CommuteType", "E"); //상태 퇴근
					}
					attendCommutingSvc.setCommuteTime(iParams);
				}
			}
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}

	/**
	  * @Method Name : createAutoJob
	  * @작성일 : 2020. 4. 17.
	  * @작성자 : 
	  * @변경이력 : 
	  * @Method 설명 :
	  * @param request
	  * @param response
	  */
	@RequestMapping(value = "/autoCreateScheduleJob.do") 
	public void autoCreateScheduleJob(HttpServletRequest request, HttpServletResponse response){
		try {
			//CoviMap params =new CoviMap();
			//params.put("domain", request.getParameter("DN_Code"));

			
			CoviMap params = new CoviMap();
			String month = request.getParameter("month");
			String compayCode = request.getParameter("DN_Code");
			/*CoviList domain = new CoviList();
			
			if (request.getParameter("DN_Code") == null){
				domain = attendBatchSvc.getDomainIdList(domainParams);
			}
			else{
				CoviMap domainMap = new CoviMap();
				domainMap.put("CompanyCode", compayCode);
				domain.add(domainMap);
			}*/
			if (request.getParameter("month") == null){
				DateFormat df = new SimpleDateFormat("yyyyMM");
				Calendar cal = Calendar.getInstance( );
				cal.add ( cal.MONTH, + 1 ); //다음달
				month= df.format(cal.getTime());
			}
			
			params.put("CompanyCode", compayCode);
			params.put("Month", month);
			params.put("HolidayFlag", "Y");
			params.put("USERID", "SYSTEM");
			
			CoviMap absent = attendBatchSvc.autoCreateScheduleJob(params);
			LOGGER.debug("autoCreateScheduleJob date "+getServerDateTime()+" , domain : "+absent.getString("domain"));
			
		} catch(ParseException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}

	public String getServerDateTime(){
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date d = new Date();
		return sdf.format(d);
	}


	public String getServerDateTimeYYYYMMDD(){
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		Date d = new Date();
		return sdf.format(d);
	}

	public static boolean isBetween(int x, int lower, int upper) {
		return lower <= x && x <= upper;
	}

	public String getMinRangeConverterByUnit5Min(String min){
		int intMin = Integer.parseInt(min);
		if(isBetween(intMin, 1, 5)){
			intMin = 5;
		}else if(isBetween(intMin, 6, 10)){
			intMin = 10;
		}else if(isBetween(intMin, 11, 15)){
			intMin = 15;
		}else if(isBetween(intMin, 16, 20)){
			intMin = 20;
		}else if(isBetween(intMin, 21, 25)){
			intMin = 25;
		}else if(isBetween(intMin, 26, 30)){
			intMin = 30;
		}else if(isBetween(intMin, 31, 35)){
			intMin = 35;
		}else if(isBetween(intMin, 36, 40)){
			intMin = 40;
		}else if(isBetween(intMin, 41, 45)){
			intMin = 45;
		}else if(isBetween(intMin, 46, 50)){
			intMin = 50;
		}else if(isBetween(intMin, 51, 55)){
			intMin = 55;
		}else if(isBetween(intMin, 56, 60)){
			intMin = 60;
		}else{
			intMin = 0;
		}
		return String.valueOf(intMin);
	}
	/**
	 * @Method Name : excuteAttendNotifyPush
	 * @작성일 : 2021. 10. 12.
	 * @작성자 : nkpark
	 * @변경이력 :
	 * @Method 설명 :
	 * @param request
	 * //TODO: lang 부분 하드코딩 추후 정리
	 */
	@RequestMapping(value = "/excuteAttendNotifyPush.do")
	public /*@ResponseBody JSONObject*/void excuteAttendNotifyPush(HttpServletRequest request, HttpServletResponse response){
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap();
		try{
			String DN_ID = request.getParameter("DN_ID");
			String DN_Code = request.getParameter("DN_Code");
			String NowDate = getServerDateTimeYYYYMMDD();
			params.put("TodayDate", NowDate);
			params.put("lang",  "ko");
			//공통 스케쥴어에서 DN_ID=0 으로 주면 DomainID 조건 없이 전체 유저에 대한 매시징 동작됨
			//그룹사별 스케줄러에서 DN_ID가 각 그룹사 코드값으로 들어오면 해당 그룹사 유저 단위로 조회 후 처리됨
			if(DN_ID==null || DN_ID.equals("") ||DN_ID.equals("0")){
				DN_ID = "";
			}
			if(DN_Code==null || DN_Code.equals("")){
				DN_Code = "";
			}
			params.put("DN_ID",  DN_ID);
			params.put("DN_Code",  DN_Code);

			Map<String, String> msgMapAlarmStart = new HashMap<>();
			Map<String, String> msgMapAlarmEnd = new HashMap<>();
			Map<String, String> msgMapAlarmLate = new HashMap<>();
			Map<String, String> msgMapAlarmOvertime = new HashMap<>();

			CoviList attAlarmTime = attendBatchSvc.excuteAttendNotifyPush(params);
			//System.out.println("#####attAlarmTime:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(attAlarmTime));
			//알람 대상별 동작 처리

			String CFG_AlarmAttStartNoticeMin = "0";
			String CFG_AlarmAttEndNoticeMin   = "0";
			String CFG_AlarmAttStartNoticeMinMSG = "0";
			String CFG_AlarmAttEndNoticeMinMSG   = "0";

			Calendar Cal = Calendar.getInstance();
			for(int i=0;i<attAlarmTime.size();i++){
				CoviMap mapAttAlarmTime = attAlarmTime.getMap(i);
				String UserCode = mapAttAlarmTime.getString("UserCode");
				String WorkSts = mapAttAlarmTime.getString("WorkSts");
				int WorkingSystemType = mapAttAlarmTime.getInt("WorkingSystemType");
				String UR_TimeZone = mapAttAlarmTime.getString("UR_TimeZone");
				String nowSystemDateTime = ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm", 0, UR_TimeZone);
				//System.out.println("#####nowSystemDateTime:"+nowSystemDateTime);
				if(WorkingSystemType>0){//2022.05.03 nkpark 지정근무제 아닌 선택/자율 인경우 알람 대상 제외
					continue;
				}

				if(WorkSts.equals("HOL")||WorkSts.equals("OFF")){
					continue;
				}

				if(i==0) {
					CFG_AlarmAttStartNoticeMin = mapAttAlarmTime.getString("CFG_AlarmAttStartNoticeMin");
					CFG_AlarmAttEndNoticeMin   = mapAttAlarmTime.getString("CFG_AlarmAttEndNoticeMin");
					if(CFG_AlarmAttStartNoticeMin.equals("0")) {
						CFG_AlarmAttStartNoticeMinMSG = "시간";
					}else{
						CFG_AlarmAttStartNoticeMinMSG = CFG_AlarmAttStartNoticeMin+"분전";
					}
					if(CFG_AlarmAttEndNoticeMin.equals("0")) {
						CFG_AlarmAttEndNoticeMinMSG = "시간";
					}else{
						CFG_AlarmAttEndNoticeMinMSG = CFG_AlarmAttEndNoticeMin+"분전";
					}

				}

				String AttDayStartTime_F = mapAttAlarmTime.getString("AttDayStartTime_F");
				String AttDayEndTime_F = mapAttAlarmTime.getString("AttDayEndTime_F");
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
				//출근 시간 임박 알림
				String CFG_AlarmAttStartNoticeYn = mapAttAlarmTime.getString("CFG_AlarmAttStartNoticeYn");
				String AttAlarmStartTime_F = mapAttAlarmTime.getString("AttAlarmStartTime_F");
				String AttStartTime_F = mapAttAlarmTime.getString("AttStartTime_F");
				String SET_AlarmAttStartMedia = mapAttAlarmTime.getString("SET_AlarmAttStartMedia");
				if(CFG_AlarmAttStartNoticeYn.equals("Y")
					&& nowSystemDateTime.equals(AttAlarmStartTime_F)
					&& AttStartTime_F.equals("NONETAG")
					&& SET_AlarmAttStartMedia.length()>1){

					//MAP에 메시지 미디어 타입 구분 하여 유저코드 담기
					if(msgMapAlarmStart.get(SET_AlarmAttStartMedia)==null){
						msgMapAlarmStart.put(SET_AlarmAttStartMedia,UserCode);
					}else{
						String UserList = msgMapAlarmStart.get(SET_AlarmAttStartMedia);
						UserList +=";"+UserCode;
						msgMapAlarmStart.replace(SET_AlarmAttStartMedia,UserList);
					}
				}//end if

				//지각 알림
				String CFG_AlarmAttLateYn = mapAttAlarmTime.getString("CFG_AlarmAttLateYn");
				//String AttAlarmLateTime_F = mapAttAlarmTime.getString("AttAlarmLateTime_F");
				String SET_AttLateMedia = mapAttAlarmTime.getString("SET_AttLateMedia");
				String CFG_AttStartTimeTermMin = mapAttAlarmTime.getString("CFG_AttStartTimeTermMin");
				CFG_AttStartTimeTermMin = getMinRangeConverterByUnit5Min(CFG_AttStartTimeTermMin);
				Date dateAttDayStartTime = sdf.parse(AttDayStartTime_F);
				Cal.setTime(dateAttDayStartTime);
				Cal.add(Calendar.MINUTE, Integer.parseInt(CFG_AttStartTimeTermMin));
				String AttAlarmLateTime_F = sdf.format(Cal.getTime());
				//System.out.println("#####AttAlarmLateTime_F:"+AttAlarmLateTime_F);
				if(CFG_AlarmAttLateYn.equals("Y")
						&& nowSystemDateTime.equals(AttAlarmLateTime_F)
						&& AttStartTime_F.equals("NONETAG")
						&& SET_AttLateMedia.length()>1){

					//MAP에 메시지 미디어 타입 구분 하여 유저코드 담기
					if(msgMapAlarmLate.get(SET_AttLateMedia)==null){
						msgMapAlarmLate.put(SET_AttLateMedia,UserCode);
					}else{
						String UserList = msgMapAlarmLate.get(SET_AttLateMedia);
						UserList +=";"+UserCode;
						msgMapAlarmLate.replace(SET_AttLateMedia,UserList);
					}

				}//end if

				//퇴근 시간 임박 알림
				String CFG_AlarmAttEndNoticeYn = mapAttAlarmTime.getString("CFG_AlarmAttEndNoticeYn");
				String AttAlarmEndTime_F = mapAttAlarmTime.getString("AttAlarmEndTime_F");
				String AttEndTime_F = mapAttAlarmTime.getString("AttEndTime_F");
				String SET_AlarmAttEndMedia = mapAttAlarmTime.getString("SET_AlarmAttEndMedia");

				if(CFG_AlarmAttEndNoticeYn.equals("Y")
						&& nowSystemDateTime.equals(AttAlarmEndTime_F)
						&& !AttStartTime_F.equals("NONETAG")
						&& AttEndTime_F.equals("NONETAG")
						&& SET_AlarmAttEndMedia.length()>1) {

					//MAP에 메시지 미디어 타입 구분 하여 유저코드 담기
					if(msgMapAlarmEnd.get(SET_AlarmAttEndMedia)==null){
						msgMapAlarmEnd.put(SET_AlarmAttEndMedia,UserCode);
					}else{
						String UserList = msgMapAlarmEnd.get(SET_AlarmAttEndMedia);
						UserList +=";"+UserCode;
						msgMapAlarmEnd.replace(SET_AlarmAttEndMedia,UserList);
					}
				}//end if

				//초과 근무 알림
				String CFG_AlarmAttOvertimeYn = mapAttAlarmTime.getString("CFG_AlarmAttOvertimeYn");
				//String AttAlarmOverTime_F = mapAttAlarmTime.getString("AttAlarmOverTime_F");
				String SET_AttOvertimeMedia = mapAttAlarmTime.getString("SET_AttOvertimeMedia");
				String CFG_AttEndTimeTermMin = mapAttAlarmTime.getString("CFG_AttEndTimeTermMin");
				CFG_AttEndTimeTermMin = getMinRangeConverterByUnit5Min(CFG_AttEndTimeTermMin);
				Date dateAttDayEndTime = sdf.parse(AttDayEndTime_F);
				Cal.setTime(dateAttDayEndTime);
				Cal.add(Calendar.MINUTE, Integer.parseInt(CFG_AttEndTimeTermMin));
				String AttAlarmOverTime_F = sdf.format(Cal.getTime());
				//System.out.println("#####AttAlarmOverTime_F:"+AttAlarmOverTime_F);
				if(CFG_AlarmAttOvertimeYn.equals("Y")
						&& nowSystemDateTime.equals(AttAlarmOverTime_F)
						&& !AttStartTime_F.equals("NONETAG")
						&& AttEndTime_F.equals("NONETAG")
						&& SET_AttOvertimeMedia.length()>1){

					//MAP에 메시지 미디어 타입 구분 하여 유저코드 담기
					if(msgMapAlarmOvertime.get(SET_AttOvertimeMedia)==null){
						msgMapAlarmOvertime.put(SET_AttOvertimeMedia,UserCode);
					}else{
						String UserList = msgMapAlarmOvertime.get(SET_AttOvertimeMedia);
						UserList +=";"+UserCode;
						msgMapAlarmOvertime.replace(SET_AttOvertimeMedia,UserList);
					}
				}//end if

			}//end for

			//출근 시간 임박 메시지 전송 데이터 전달
			if(msgMapAlarmStart.size()>0){
				for(Map.Entry<String, String> entry : msgMapAlarmStart.entrySet()){
					String msgMediaType = entry.getKey();
					String userList = entry.getValue();
					CoviMap cmAttAlarmStart = new CoviMap();
					cmAttAlarmStart.put("MsgType", "AttWorkStartNotify");
					cmAttAlarmStart.put("MediaType", funReSortingMediaType(msgMediaType));
					cmAttAlarmStart.put("ReceiversCode", userList);
					cmAttAlarmStart.put("MessagingSubject", "[출근시간임박알림]출근 " + CFG_AlarmAttStartNoticeMinMSG + " 입니다.");
					cmAttAlarmStart.put("MessageContext", "출근 시간이 임박 하였습니다.");
					attendBatchSvc.attendAlarmSendMessages(cmAttAlarmStart);
				}
			}

			//퇴근 시간 임박 메시지 전송 데이터 전달

			if(msgMapAlarmEnd.size()>0){
				for(Map.Entry<String, String> entry : msgMapAlarmEnd.entrySet()){
					String msgMediaType = entry.getKey();
					String userList = entry.getValue();
					CoviMap cmap = new CoviMap();
					cmap.put("MsgType",  "AttWorkEndNotify");
					cmap.put("MediaType",  funReSortingMediaType(msgMediaType));
					cmap.put("ReceiversCode",  userList);
					cmap.put("MessagingSubject", "[퇴근시간임박알림]퇴근 "+CFG_AlarmAttEndNoticeMinMSG+" 입니다.");
					cmap.put("MessageContext", "퇴근 시간이 임박 하였습니다.");
					attendBatchSvc.attendAlarmSendMessages(cmap);
				}
			}

			//지각 알림 메시지 전송 데이터 전달
			if(msgMapAlarmLate.size()>0){
				for(Map.Entry<String, String> entry : msgMapAlarmLate.entrySet()){
					String msgMediaType = entry.getKey();
					String userList = entry.getValue();
					CoviMap cmap = new CoviMap();
					cmap.put("MsgType",  "AttLateNotify");
					cmap.put("MediaType", funReSortingMediaType(msgMediaType));
					cmap.put("ReceiversCode",  userList);
					cmap.put("MessagingSubject", "[지각알림]출근시간이 초과 되었습니다.");
					cmap.put("MessageContext", "소명 신청 처리 바랍니다.");
					attendBatchSvc.attendAlarmSendMessages(cmap);
				}
			}

			//초과근무 알림 메시지 전송 데이터 전달
			if(msgMapAlarmOvertime.size()>0){
				for(Map.Entry<String, String> entry : msgMapAlarmOvertime.entrySet()){
					String msgMediaType = entry.getKey();
					String userList = entry.getValue();
					CoviMap cmap = new CoviMap();
					cmap.put("MsgType",  "AttOvertimeNotify");
					cmap.put("MediaType",  funReSortingMediaType(msgMediaType));
					cmap.put("ReceiversCode",  userList);
					cmap.put("MessagingSubject", "[근무시간초과알림]퇴근 시간이 초과 되었습니다.");
					cmap.put("MessageContext", "연장근무 신청을 권장 드립니다.");
					attendBatchSvc.attendAlarmSendMessages(cmap);
				}
			}

			//System.out.println("####attAlarmTime.size():"+attAlarmTime.size());
			//returnObj.put("data", new Gson().newBuilder().create().toJson(attAlarmTime));
			returnObj.put("status", Enums.Return.SUCCESS);

		} catch(ParseException e){
			returnObj.put("status", Enums.Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(NullPointerException e){
			returnObj.put("status", Enums.Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			returnObj.put("status", Enums.Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		//return returnObj;
	}

	public String funReSortingMediaType(String mediaType){
		//TODOLIST;MDM;MESSENGER
		String rtnMediaType = "";
		int putCnt = 0;
		if(mediaType.contains("TODOLIST")){
			if(putCnt>0){
				rtnMediaType += ";TODOLIST";
			}else{
				rtnMediaType += "TODOLIST";
			}
			putCnt++;
		}
		if(mediaType.contains("MDM")){
			if(putCnt>0){
				rtnMediaType += ";MDM";
			}else{
				rtnMediaType += "MDM";
			}
			putCnt++;
		}
		if(mediaType.contains("MESSENGER")){
			if(putCnt>0){
				rtnMediaType += ";MESSENGER";
			}else{
				rtnMediaType += "MESSENGER";
			}
			putCnt++;
		}

		return rtnMediaType;
	}
	
	@RequestMapping(value = "/setRewardVacationData.do")
	public void setRewardVacationData(HttpServletRequest request, HttpServletResponse response){
		try {
			CoviMap params =new CoviMap();
			params.put("CompanyCode", request.getParameter("DN_Code"));
			int cnt = attendBatchSvc.setRewardVacationData(params);
			
			LOGGER.debug("setRewardVacationData date "+getServerDateTime()+" , cnt : "+cnt);
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}
}

