package egovframework.covision.groupware.attend.user.service.impl;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.covision.groupware.attend.user.service.AttendUserStatusSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


import static org.apache.poi.ss.usermodel.CellType.*;

@Service("AttendUserStatus")
public class AttendUserStatusSvcImpl extends EgovAbstractServiceImpl implements AttendUserStatusSvc {
	private Logger LOGGER = LogManager.getLogger(AttendUserStatusSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	AwsS3 awsS3 = AwsS3.getInstance();
	
	@Override
	public String getDayScope(String dateTerm,String targetDate,String companyCode) throws Exception {
		CoviMap params = new CoviMap();
		params.put("DateTerm", dateTerm);
		params.put("TargetDate", targetDate);
		params.put("CompanyCode", companyCode);
		return coviMapperOne.selectOne("attend.status.getDayScope", params);
	}
 

	@Override
	public CoviList getUserAttStatus(CoviList userCodeList,String companyCode,String startDate,String endDate) throws Exception {
		CoviMap params = new CoviMap();
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
		params.put("userCodeList", userCodeList);
		params.put("CompanyCode", companyCode);
		params.put("StartDate", startDate);
		params.put("EndDate", endDate);
		
		String domainID = SessionHelper.getSession("DN_ID");
		String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
		if(!orgMapOrderSet.equals("")) {
            String[] orgOrders = orgMapOrderSet.split("\\|");
            params.put("orgOrders", orgOrders);
		}
		
		return coviMapperOne.list("attend.status.getUserAttStatus", params);
	}


	@Override
	public CoviList getUserAttStatusV2(CoviList userCodeList,String companyCode,String startDate,String endDate) throws Exception {
		CoviMap params = new CoviMap();
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateSimpleFormat));
		params.put("userCodeList", userCodeList);
		params.put("CompanyCode", companyCode);
		params.put("StartDate", startDate);
		params.put("EndDate", endDate);
		String DayNightStartTime = RedisDataUtil.getBaseConfig("DayNightStartTime")+"";
		String DayNightEndTime = RedisDataUtil.getBaseConfig("DayNightEndTime")+"";
		if(DayNightStartTime.equals("")){
			DayNightStartTime = RedisDataUtil.getBaseConfig("NightStartTime")+"";
		}
		if(DayNightEndTime.equals("")){
			DayNightEndTime = RedisDataUtil.getBaseConfig("NightEndTime")+"";
		}
		params.put("NightStartDate", DayNightStartTime);
		params.put("NightEndDate", DayNightEndTime);
		params.put("HolNightStartDate", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
		params.put("HolNightEndDate", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
		params.put("ExtNightStartDate", RedisDataUtil.getBaseConfig("NightStartTime"));
		params.put("ExtNightEndDate", RedisDataUtil.getBaseConfig("NightEndTime"));

		return coviMapperOne.list("attend.status.getUserAttStatusV2", params);
	}

	@Override
	public CoviList getUserAttStatusWeekly(CoviList userCodeList,String companyCode, List<Map<String, String>> listRangeFronToDate, List WeeksNum, String weeklyWorkValue, String weeklyWorkType) throws Exception {
		CoviMap params = new CoviMap();

		params.put("weeklyWorkType", weeklyWorkType);
		params.put("weeklyWorkValue", weeklyWorkValue);
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
		params.put("userCodeList", userCodeList);
		params.put("CompanyCode", companyCode);
		params.put("listRangeFronToDate", listRangeFronToDate);
		params.put("WeeksNum", WeeksNum);
		Map<String, String> rangeDateStart = listRangeFronToDate.get(0);
		String StartDate_key = rangeDateStart.keySet().toString().replace("[","").replace("]","");

		Map<String, String> rangeDateEnd = listRangeFronToDate.get(listRangeFronToDate.size()-1);
		String EndDate_key = rangeDateEnd.keySet().toString().replace("[","").replace("]","");
		String EndDate_val = rangeDateEnd.get(EndDate_key);
		/*System.out.println("#####StartDate_key:"+StartDate_key);
		System.out.println("#####EndDate_val:"+EndDate_val);*/
		params.put("StartDate", StartDate_key);
		params.put("EndDate", EndDate_val);
		String DayNightStartTime = RedisDataUtil.getBaseConfig("DayNightStartTime")+"";
		String DayNightEndTime = RedisDataUtil.getBaseConfig("DayNightEndTime")+"";
		if(DayNightStartTime.equals("")){
			DayNightStartTime = RedisDataUtil.getBaseConfig("NightStartTime")+"";
		}
		if(DayNightEndTime.equals("")){
			DayNightEndTime = RedisDataUtil.getBaseConfig("NightEndTime")+"";
		}
		params.put("NightStartDate", DayNightStartTime);
		params.put("NightEndDate", DayNightEndTime);
		params.put("HolNightStartDate", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
		params.put("HolNightEndDate", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
		params.put("ExtNightStartDate", RedisDataUtil.getBaseConfig("NightStartTime"));
		params.put("ExtNightEndDate", RedisDataUtil.getBaseConfig("NightEndTime"));
		
		String domainID = SessionHelper.getSession("DN_ID");

		String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
		if(!orgMapOrderSet.equals("")) {
		                String[] orgOrders = orgMapOrderSet.split("\\|");
		                params.put("orgOrders", orgOrders);
		}

		CoviList userAttStatusWeeklyList =  coviMapperOne.list("attend.status.getUserAttStatusWeekly", params);
		CoviList rtn_userAttStatusWeeklyList = new CoviList();
		for(int i=0;i<userAttStatusWeeklyList.size();i++){
			CoviMap cmap = userAttStatusWeeklyList.getMap(i);
			CoviMap sumMap = new CoviMap();
			String summary = cmap.getString("summary");
			if(summary.contains("|")){
				String[] arrSummary = summary.split("\\|");
				sumMap.put("Sum_TargetUserCode", arrSummary[0]);
				sumMap.put("Sum_WorkDay", arrSummary[1]);
				sumMap.put("Sum_WorkTime", arrSummary[2]);
				sumMap.put("Sum_TotWorkTime", arrSummary[3]);
				sumMap.put("Sum_TotAcWorkTime", arrSummary[4]);
				sumMap.put("Sum_AttRealTime", arrSummary[5]);
				sumMap.put("Sum_AttRealDTime", arrSummary[6]);
				sumMap.put("Sum_AttRealNTime", arrSummary[7]);
				sumMap.put("Sum_ExtenAc", arrSummary[8]);
				sumMap.put("Sum_ExtenAcD", arrSummary[9]);
				sumMap.put("Sum_ExtenAcN", arrSummary[10]);
				sumMap.put("Sum_HoliAc", arrSummary[11]);
				sumMap.put("Sum_HoliAcD", arrSummary[12]);
				sumMap.put("Sum_HoliAcN", arrSummary[13]);
				sumMap.put("Sum_AttAc", arrSummary[14]);
				sumMap.put("Sum_AttAcD", arrSummary[15]);
				sumMap.put("Sum_AttAcN", arrSummary[16]);
				sumMap.put("Sum_JobStsSumTime", arrSummary[17]);
				sumMap.put("Sum_TotConfWorkTime", arrSummary[18]);
				sumMap.put("Sum_RemainTime", arrSummary[19]);
				sumMap.put("Sum_NormalCnt", arrSummary[20]);
				sumMap.put("Sum_FixWorkTime", arrSummary[21]);
				sumMap.put("Sum_TotRealWorkTime", arrSummary[22]);
				sumMap.put("Sum_k", arrSummary[23]);
			}
			cmap.addAll(sumMap);
			rtn_userAttStatusWeeklyList.add(cmap);
		}
		return rtn_userAttStatusWeeklyList;
	}


	@Override
	public CoviList getUserAttStatusDaily(CoviList userCodeList,String companyCode, List<Map<String, String>> listRangeFronToDate, List WeeksNum, String weeklyWorkValue, String weeklyWorkType) throws Exception {
		CoviMap params = new CoviMap();

		params.put("weeklyWorkType", weeklyWorkType);
		params.put("weeklyWorkValue", weeklyWorkValue);
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateSimpleFormat));
		params.put("userCodeList", userCodeList);
		params.put("CompanyCode", companyCode);
		params.put("listRangeFronToDate", listRangeFronToDate);
		params.put("WeeksNum", WeeksNum);
		Map<String, String> rangeDateStart = listRangeFronToDate.get(0);
		String StartDate_key = rangeDateStart.keySet().toString().replace("[","").replace("]","");

		Map<String, String> rangeDateEnd = listRangeFronToDate.get(listRangeFronToDate.size()-1);
		String EndDate_key = rangeDateEnd.keySet().toString().replace("[","").replace("]","");
		String EndDate_val = rangeDateEnd.get(EndDate_key);
		/*System.out.println("#####StartDate_key:"+StartDate_key);
		System.out.println("#####EndDate_val:"+EndDate_val);*/
		params.put("StartDate", StartDate_key);
		params.put("EndDate", EndDate_val);
		String DayNightStartTime = RedisDataUtil.getBaseConfig("DayNightStartTime")+"";
		String DayNightEndTime = RedisDataUtil.getBaseConfig("DayNightEndTime")+"";
		if(DayNightStartTime.equals("")){
			DayNightStartTime = RedisDataUtil.getBaseConfig("NightStartTime")+"";
		}
		if(DayNightEndTime.equals("")){
			DayNightEndTime = RedisDataUtil.getBaseConfig("NightEndTime")+"";
		}
		params.put("NightStartDate", DayNightStartTime);
		params.put("NightEndDate", DayNightEndTime);
		params.put("HolNightStartDate", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
		params.put("HolNightEndDate", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
		params.put("ExtNightStartDate", RedisDataUtil.getBaseConfig("NightStartTime"));
		params.put("ExtNightEndDate", RedisDataUtil.getBaseConfig("NightEndTime"));
		
		String domainID = SessionHelper.getSession("DN_ID");

		String orgMapOrderSet = RedisDataUtil.getBaseConfig("OrgMapOrderSet", domainID);
		if(!orgMapOrderSet.equals("")) {
		                String[] orgOrders = orgMapOrderSet.split("\\|");
		                params.put("orgOrders", orgOrders);
		}

		CoviList userAttStatusWeeklyList =  coviMapperOne.list("attend.status.getUserAttStatusDaily", params);
		CoviList rtn_userAttStatusWeeklyList = new CoviList();
		for(int i=0;i<userAttStatusWeeklyList.size();i++){
			CoviMap cmap = userAttStatusWeeklyList.getMap(i);
			//System.out.println("#####cmap:"+new GsonBuilder().setPrettyPrinting().create().toJson(cmap));

			rtn_userAttStatusWeeklyList.add(cmap);
		}
		return rtn_userAttStatusWeeklyList;
	}

	@Override
	public CoviMap getMyAttStatus(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String UserCode = params.getString("UserCode");
		String CompanyCode = params.getString("CompanyCode");
		return returnObj;
	} 


	@Override 
	public CoviList getUserJobHistory(CoviMap params) throws Exception {
		return coviMapperOne.list("attend.status.getUserJobHistory", params);
	}
	
	@Override 
	public CoviMap setDayParams(String dateTerm,String targetDate,String companyCode) throws Exception{
		CoviMap returnMap = new CoviMap();
		
		String dayScope = getDayScope(dateTerm,targetDate,companyCode);
		String sDate = dayScope.split("/")[0];
		String eDate = dayScope.split("/")[1]; 
		
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		SimpleDateFormat sdf2 = new SimpleDateFormat("yyyy.MM.dd");
		SimpleDateFormat sdfM = new SimpleDateFormat("MM.dd");
		
		SimpleDateFormat sdfMonth = new SimpleDateFormat("yyyy.MM");
		
		SimpleDateFormat sdfWeek = new SimpleDateFormat("E", java.util.Locale.ENGLISH);
		
		Date startDate = null;
		Date endDate = null;
		String dayTitle = "";
		String dayMobileTitle = "";
		String dayTitleMonth = "";
		String dayWeek = "0";
		startDate = sdf.parse(AttendUtils.removeMaskAll(sDate));
		endDate = sdf.parse(AttendUtils.removeMaskAll(eDate));
		try{

			dayTitle = sdf2.format(startDate)+"~"+sdf2.format(endDate);
			dayMobileTitle = sdfM.format(startDate)+"~"+sdfM.format(endDate);
			dayTitleMonth = sdfMonth.format(startDate);

			Date  tDate = sdf.parse(AttendUtils.removeMaskAll(targetDate));
			dayWeek = sdfWeek.format(tDate);
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(ParseException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		cal.setTime(startDate);
		cal.add(Calendar.DATE, -1);
		String p_sDate = sdf.format(cal.getTime());
		
		cal.setTime(endDate);
		cal.add(Calendar.DATE, 1);
		String p_eDate = sdf.format(cal.getTime());
		
		CoviMap dayParams = new CoviMap(); 
		dayParams.put("StartDate", sDate);
		dayParams.put("EndDate", eDate);
		CoviList dayList = coviMapperOne.list("attend.status.getDayList", dayParams);
		
		/*
		 * 두 날짜 사이 일수
		 * */
		long diffSec = (endDate.getTime() - startDate.getTime())/(24*60*60*1000);
	

		returnMap.put("dayList", dayList);
		returnMap.put("sDate", sDate); 
		returnMap.put("eDate", eDate);
		returnMap.put("p_sDate", p_sDate);
		returnMap.put("p_eDate", p_eDate);
		returnMap.put("dayTitle", dayTitle);
		returnMap.put("dayMobileTitle", dayMobileTitle);
		returnMap.put("dayTitleMonth", dayTitleMonth);
		returnMap.put("dayScopeCnt", diffSec);
		returnMap.put("dayWeek", dayWeek);
		
		return returnMap;
	}

	@Override
	public CoviMap setDayParamsWithoutDaylist(String dateTerm,String targetDate,String companyCode) throws Exception{
		CoviMap returnMap = new CoviMap();

		String dayScope = getDayScope(dateTerm,targetDate,companyCode);
		String sDate = dayScope.split("/")[0];
		String eDate = dayScope.split("/")[1];

		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		SimpleDateFormat sdf2 = new SimpleDateFormat("yyyy.MM.dd");

		SimpleDateFormat sdfMonth = new SimpleDateFormat("yyyy.MM");

		SimpleDateFormat sdfWeek = new SimpleDateFormat("E", java.util.Locale.ENGLISH);

		Date startDate = null;
		Date endDate = null;
		String dayTitle = "";
		String dayTitleMonth = "";
		String dayWeek = "0";
		startDate = sdf.parse(AttendUtils.removeMaskAll(sDate));
		endDate = sdf.parse(AttendUtils.removeMaskAll(eDate));
		try{

			dayTitle = sdf2.format(startDate)+"~"+sdf2.format(endDate);
			dayTitleMonth = sdfMonth.format(startDate);

			Date  tDate = sdf.parse(AttendUtils.removeMaskAll(targetDate));
			dayWeek = sdfWeek.format(tDate);
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(ParseException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		cal.setTime(startDate);
		cal.add(Calendar.DATE, -1);
		String p_sDate = sdf.format(cal.getTime());

		cal.setTime(endDate);
		cal.add(Calendar.DATE, 1);
		String p_eDate = sdf.format(cal.getTime());

		/*
		 * 두 날짜 사이 일수
		 * */
		long diffSec = (endDate.getTime() - startDate.getTime())/(24*60*60*1000);


		returnMap.put("sDate", sDate);
		returnMap.put("eDate", eDate);
		returnMap.put("p_sDate", p_sDate);
		returnMap.put("p_eDate", p_eDate);
		returnMap.put("dayTitle", dayTitle);
		returnMap.put("dayTitleMonth", dayTitleMonth);
		returnMap.put("dayScopeCnt", diffSec);
		returnMap.put("dayWeek", dayWeek);

		return returnMap;
	}

	@Override
	public CoviMap getUserAttendance(CoviMap params) throws Exception {
		CoviMap returnMap = new CoviMap();
		
		/*검색일*/
		String DateTerm = params.getString("DateTerm");
		String TargetDate = params.getString("TargetDate");
		String CompanyCode = params.getString("CompanyCode");
		
		String sDate ;
		String eDate ;
		int diffDay ;
		returnMap.addAll(setDayParams(DateTerm,TargetDate,CompanyCode));
		
		sDate = returnMap.getString("sDate");
		eDate = returnMap.getString("eDate");
		diffDay = returnMap.getInt("dayScopeCnt")+1;
		
		/*검색일 end*/
	
		CoviList userCodeList = (CoviList) params.get("userCodeList");
		/**
		 * @author sjhan0418
		 * */
		CoviList userAttStatus = getUserAttStatus(userCodeList, CompanyCode, sDate, eDate);
		CoviList userAttList = new CoviList();
		
		CoviList tempUserAtt = new CoviList();
		for(int i=0;i<userAttStatus.size();i++){
			CoviMap userAtt = userAttStatus.getMap(i);
			tempUserAtt.add(userAtt);
			if((i+1)%diffDay == 0){
				CoviMap tempMap = new CoviMap();
				tempMap.put("userCode",				userAtt.get("UserCode"));
				tempMap.put("displayName", 			userAtt.get("DisplayName"));
				tempMap.put("jobPositionName",      userAtt.get("JobPositionName"));
				tempMap.put("JobLevelName",      userAtt.get("JobLevelName"));
				tempMap.put("JobTitleName",      userAtt.get("JobTitleName"));
				tempMap.put("JobPositionName",      userAtt.get("JobPositionName"));
				tempMap.put("deptName",             userAtt.get("DeptName"));
				tempMap.put("photoPath",            userAtt.get("PhotoPath"));
				tempMap.put("enterDate",            userAtt.get("EnterDate"));

				tempMap.put("userAttList",tempUserAtt);
				CoviMap userAttWorkTime =  getUserAttWorkWithDayAndNightTimeProc(userAtt.getString("UserCode"),CompanyCode,sDate,eDate);
				tempMap.put("userAttWorkTime",userAttWorkTime);
				userAttList.add(tempMap);
				tempUserAtt = new CoviList();
			}
			
		}
	
		//회사 휴무일 리스트 조회 
		CoviMap holiParams = new CoviMap();
		holiParams.put("CompanyCode", CompanyCode);
		holiParams.put("StartDate", sDate);
		holiParams.put("EndDate", eDate);
		CoviList holiSchList =  coviMapperOne.list("attend.status.getHolidaySchList", holiParams);
		
		returnMap.put("userAtt", userAttList); 
		returnMap.put("holiSch", holiSchList); 
		
		return returnMap;
	}


	@Override
	public CoviMap getUserAttWorkTime(String userCode,String companyCode,String startDate,String endDate) throws Exception {
		
		CoviMap params = new CoviMap();
		params.put("UserCode", userCode);
		params.put("CompanyCode", companyCode);
		params.put("StartDate", startDate);
		params.put("EndDate", endDate);
		double remainTime = 0;
		CoviList workTimeList = coviMapperOne.list("attend.status.getUserWorkTime", params);
		for(int i=0;i<workTimeList.size();i++){
			CoviMap workTimeMap = workTimeList.getMap(i);
			int workTime = workTimeMap.getInt("WorkTime");
			int workWeek = workTimeMap.getInt("WorkWeek");
			String workCode = workTimeMap.getString("WorkCode");
			String workSts = workTimeMap.getString("WorkSts");
			
			//근무일정 내 근무일로 지정 된 기간 만 업무 시간으로 지정
			if("ON".equals(workSts)){
				if("day".equals(workCode)){
					remainTime += workTime;
				}else if("week".equals(workCode)){
					remainTime += workTime/workWeek; 
				}
			}
		}
		params.put("RemainTime", remainTime);
		
		return coviMapperOne.selectOne("attend.status.getUserAttWorkTime", params);
		
	} 
	
	public CoviMap getUserAttWorkTimeProc(String userCode,String companyCode,String startDate,String endDate) throws Exception {
		
		CoviMap params = new CoviMap();
		params.put("UserCode", userCode);
		params.put("CompanyCode", companyCode);
		params.put("StartDate", startDate);
		params.put("EndDate", endDate);

		coviMapperOne.update("attend.status.getUserAttWorkTimeProc", params);
		//coviMapperOne.selectOne("attend.status.getUserAttWorkTimeProc", params);

		//System.err.println("test : " + params.toString());
		//return coviMapperOne.selectOne("attend.status.getUserAttWorkTimeProc", params);
		return params;
	} 
	
	@Override
	public CoviMap getUserAttData(String userCode,String companyCode, String targetDate)
			throws Exception {
		 
		CoviMap params = new CoviMap(); 
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("UserCode", userCode);
		params.put("CompanyCode", companyCode);
		params.put("TargetDate", targetDate); 
		
		return coviMapperOne.selectOne("attend.status.getUserAttData", params);
	}


	@Override
	public CoviMap getUserAttJobSts(CoviMap params) throws Exception {
		String userCode = params.getString("UserCode");
		String targetDate = params.getString("TargetDate");
		String companyCode = params.getString("CompanyCode");
		String jobHisSeq = params.getString("JobHisSeq");
		//사용자 기본정보 , 근무일정
		CoviMap userAtt = getUserAttData(userCode,companyCode,targetDate);
		//사용자 기타근무 정보
		CoviMap jhParams = new CoviMap();
		jhParams.put("lang",  SessionHelper.getSession("lang"));
		jhParams.put("CompanyCode", companyCode);
		jhParams.put("JobStsHisSeq", jobHisSeq);
		CoviList userJobHisList = getUserJobHistory(jhParams);
		CoviMap jobHistory = userJobHisList.getMap(0);
		//기타근무 리스트
		CoviMap jsMap = new CoviMap();
		jsMap.put("CompanyCode", companyCode);
		//jsMap.put("ValidYn", "Y");
		CoviList jobStsList = coviMapperOne.list("attend.status.getJobStatus", jsMap);
		
		
		CoviMap returnMap = new CoviMap();
		returnMap.put("userAtt", userAtt);
		returnMap.put("jobHistory", jobHistory);
		returnMap.put("jobStsList", jobStsList);
		
		return returnMap;
	}


	@Override
	public CoviList getUserExtentionInfo(CoviMap params) throws Exception {
		params.put("lang", SessionHelper.getSession("lang"));
		return coviMapperOne.list("attend.status.getExtensionInfo", params);
	}
	

	@Override
	public CoviMap getUserAttendanceList(CoviMap params) throws Exception {
		CoviMap returnMap = new CoviMap();
		
		/*검색일*/
		String DateTerm = params.getString("DateTerm");
		String TargetDate = params.getString("TargetDate");
		String CompanyCode = params.getString("CompanyCode");
		String GroupPath = params.getString("GroupPath");
		String sDate = "";
		String eDate = ""; 
		if (DateTerm.equals("")){
			sDate = params.getString("StartDate");
			eDate = params.getString("EndDate");
		}
		else{
			returnMap.addAll(setDayParams(DateTerm,TargetDate,CompanyCode));
			
			sDate = returnMap.getString("sDate");
			eDate = returnMap.getString("eDate");
			/*검색일 end*/
		}
			
		//CoviList userCodeList = (CoviList) params.get("userCodeList");
		CoviMap attParams = new CoviMap();
		//attParams.put("userCodeList", userCodeList);
		attParams.put("CompanyCode", CompanyCode); 
		attParams.put("StartDate", sDate);
		attParams.put("EndDate", eDate);  
		attParams.put("GroupPath", GroupPath);  
		attParams.put("lang", SessionHelper.getSession("lang"));
		attParams.put("domainID", SessionHelper.getSession("DN_ID"));
		attParams.put("AttStatus", params.getString("AttStatus"));
		attParams.put("sUserTxt", params.getString("sUserTxt"));
		attParams.put("sJobTitleCode", params.getString("sJobTitleCode"));
		attParams.put("sJobLevelCode", params.getString("sJobLevelCode"));
		attParams.put("SchSeq", params.getString("SchSeq"));
		attParams.put("RetireUser",params.getString("RetireUser"));


		String firstWeek = params.getString("FirstWeek");
		if(firstWeek == null || "".equals(firstWeek)) {
			firstWeek = "0"; // oracle에서는 null이나 ''면 에러가 나기 때문에 값이 없으면 0으로 세팅 / mysql에서도 이상 없음.
		}
		attParams.put("FirstWeek", firstWeek);
		attParams.put("sortColumn", params.getString("sortColumn"));
		attParams.put("sortDirection", params.getString("sortDirection"));
		
		CoviMap page = new CoviMap();

		if(params.containsKey("pageNo")) {
		 	int cnt = (int)coviMapperOne.getNumber("attend.status.getUserAttStatusByListCnt", attParams);
		 	page = ComUtils.setPagingCoviData(params, cnt);
			attParams.addAll(page);
		 	returnMap.put("page", page);
			returnMap.put("cnt", cnt); 
		}
		
		CoviList userAttList = coviMapperOne.list("attend.status.getUserAttStatusByList", attParams);
		returnMap.put("list", userAttList); 
		 
		return returnMap;
	}


	@Override
	public void setExHoData(CoviMap params,List reqData) throws Exception {
		CoviList ja = AttendUtils.getJsonArrayFromList(reqData);
		for(int i=0;i<ja.size();i++){
			CoviMap jo = (CoviMap) ja.get(i);
			
			CoviMap item = new CoviMap();
			item.put("JobDate",jo.get("WorkDate"));
			item.put("StartTime",jo.get("StartTime"));
			item.put("EndTime",jo.get("EndTime"));
			item.put("NextDayYn",jo.get("NextDayYn"));
			CoviMap cmap =coviMapperOne.selectOne("attend.req.getWorkDateTime", item);

			CoviMap ehParmas = new CoviMap();
			ehParmas.put("CompanyCode", params.get("CompanyCode"));
			ehParmas.put("ReqType", params.get("ReqType"));
			ehParmas.put("ReqGubun", params.get("ReqGubun"));
			ehParmas.put("Etc", params.get("Comment"));
			ehParmas.put("StartTime", cmap.get("oAttDayStartTime"));
			ehParmas.put("EndTime", cmap.get("oAttDayEndTime"));
			ehParmas.put("UserCode", jo.get("UserCode"));
			ehParmas.put("ExHoSeq", jo.get("ExHoSeq"));
			ehParmas.put("TargetDate", jo.get("WorkDate"));
			ehParmas.put("AcTime", jo.get("AcTime"));
			ehParmas.put("IdleTime", jo.get("IdleTime"));
			coviMapperOne.insert("attend.status.setExHoDataProc", ehParmas);	
		}	
	}


	@Override
	public CoviMap setJobHisData(CoviMap params, List reqData) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList ja = AttendUtils.getJsonArrayFromList(reqData);
		for(int i=0;i<ja.size();i++){
			CoviMap jo = (CoviMap) ja.get(i);
			if("D".equals(params.get("ReqGubun"))){
				String JobStsHisSeq = String.valueOf(jo.get("JobStsHisSeq"));
				coviMapperOne.insert("attend.status.deleteJobHisData", JobStsHisSeq);	
			}else if("U".equals(params.get("ReqGubun"))){
				int cnt = 0;
				params.put("ReqData", reqData);
				params.put("StartTime", ((Map)reqData.get(i)).get("StartTime"));
				int dupCnt = (int) coviMapperOne.getNumber ("attend.req.getExistAttendJobHistory", params);
				if (dupCnt >0)
				{
					resultList.put("dupFlag", true);
					resultList.put("status", Return.FAIL);
					return resultList;
				}else{
					CoviMap jobParams = new CoviMap();
					jobParams.put("RegUserCode", params.get("RegUserCode"));
					jobParams.put("CompanyCode", params.get("CompanyCode"));
					jobParams.put("JobStsHisSeq", jo.get("JobStsHisSeq"));
					jobParams.put("JobStsSeq", jo.get("JobStsSeq"));
					jobParams.put("JobStsName", jo.get("JobStsName"));
					jobParams.put("StartTime", jo.get("StartTime"));
					jobParams.put("EndTime", jo.get("EndTime"));
					jobParams.put("Etc",  params.get("Comment"));
					coviMapperOne.insert("attend.status.updateJobHisData", jobParams);
				}
			}
		}
		resultList.put("dupFlag", false);
		resultList.put("status", Return.SUCCESS);
		return resultList;
		
	}

	@Override
	public CoviMap getMngAttStatusExcelList(CoviList userCodeList,
			String companyCode, String targetDate, String dateTerm) throws Exception {
		CoviMap returnMap = new CoviMap();
		
		/*검색일*/
		returnMap.addAll(setDayParams(dateTerm,targetDate,companyCode));
		String sDate = returnMap.getString("sDate");
		String eDate = returnMap.getString("eDate");
		
		/*검색일 end*/
		CoviMap attParams = new CoviMap();
		attParams.put("userCodeList", userCodeList);
		attParams.put("CompanyCode", companyCode); 
		attParams.put("StartDate", sDate);
		attParams.put("EndDate", eDate);  
		attParams.put("lang", SessionHelper.getSession("lang"));
		/*attParams.put("pageOffset", params.getInt("pageOffset"));
		attParams.put("pageSize", params.getInt("pageSize"));*/
		CoviList userAttList = new CoviList();
		if(userCodeList.size()>0){
			userAttList = coviMapperOne.list("attend.status.getUserAttStatusByList", attParams);	
		}
		returnMap.put("list", userAttList); 
		
		return returnMap;
	}


	@Override
	public int setUserEtc(CoviMap params) throws Exception {
		String commuteSeq = coviMapperOne.selectOne("attend.commute.getCommuteMstSeq", params);	
		if(commuteSeq==null){
			/**
			 * 해당 일자에 대한  MST TABLE 데이터가 없을경우
			 * MST테이블 정보를 생성
			 * */
			coviMapperOne.insert("attend.commute.setCommuteMst", params);
			commuteSeq = params.getString("CommuSeq");
		}
		params.put("CommuSeq", commuteSeq);
		return coviMapperOne.update("attend.status.setUserEtc",params);
	}
 

	@Override
	public CoviMap getMyAttExcelInfo(String userCode,String deptCode, String companyCode, String companyId,
			String startDate, String endDate) throws Exception {
		CoviMap resultMap = new CoviMap();
		CoviList resultList = new CoviList();
		
		CoviMap params = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("UserCode", userCode);
		params.put("DeptCode", deptCode);
		CoviList userCodeList = new CoviList();
		CoviMap cmap = new CoviMap();
		cmap.put("UserCode", userCode);
		cmap.put("DeptCode", deptCode);
		userCodeList.add(cmap);
		params.put("userCodeList", userCodeList);
		params.put("CompanyCode", companyCode);
		params.put("CompanyId", companyId);
		params.put("StartDate", startDate); 
		params.put("EndDate", endDate);
		String DayNightStartTime = RedisDataUtil.getBaseConfig("DayNightStartTime")+"";
		String DayNightEndTime = RedisDataUtil.getBaseConfig("DayNightEndTime")+"";
		if(DayNightStartTime.equals("")){
			DayNightStartTime = RedisDataUtil.getBaseConfig("NightStartTime")+"";
		}
		if(DayNightEndTime.equals("")){
			DayNightEndTime = RedisDataUtil.getBaseConfig("NightEndTime")+"";
		}
		params.put("NightStartDate", DayNightStartTime);
		params.put("NightEndDate", DayNightEndTime);
		params.put("HolNightStartDate", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
		params.put("HolNightEndDate", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
		params.put("ExtNightStartDate", RedisDataUtil.getBaseConfig("NightStartTime"));
		params.put("ExtNightEndDate", RedisDataUtil.getBaseConfig("NightEndTime"));
		CoviList userAttList = coviMapperOne.list("attend.status.getUserAttStatusV2", params);
		
		
		CoviList jobHisList = getUserJobHistory(params);
		
		
		for(int i=0;i<userAttList.size();i++){
			CoviMap userAtt = userAttList.getMap(i);
			String dayList = userAtt.getString("dayList");

			String jobSts = "";
			StringBuffer buf = new StringBuffer();
			for(int j=0;j<jobHisList.size();j++){
				CoviMap jobHisObj = jobHisList.getMap(j);  
				String jobDate = jobHisObj.getString("JobDate");
				if(dayList.equals(jobDate)){
					if(!"".equals(jobSts)){
						buf.append(",");
					}
					//jobSts += jobHisObj.getString("JobStsName") + "["+jobHisObj.getString("v_StartTime")+"~"+jobHisObj.getString("v_EndTime")+"]";
					buf.append(jobHisObj.getString("JobStsName")).append("[").append(jobHisObj.getString("v_StartTime")).append("~").append(jobHisObj.getString("v_EndTime")).append("]");
				}
			}
			jobSts= buf.toString();
			userAtt.put("JobStatus", jobSts);
			resultList.add(userAtt);
		}
		resultMap.put("StartDate", startDate);
		resultMap.put("EndDate", endDate);
		resultMap.put("list", resultList);
		
		CoviMap userAttWorkTime =  getUserAttWorkWithDayAndNightTimeProc(userCode,companyCode,startDate,endDate);
		userAttWorkTime.put("TotWorkTime_F", AttendUtils.convertSecToStr(userAttWorkTime.get("TotWorkTime").toString(),"hh"));
		int remainTime = userAttWorkTime.getInt("RemainTime");
		String remainTimeStr = "";
		if(remainTime<0){
			remainTime = Math.abs(remainTime);
			remainTimeStr = AttendUtils.convertSecToStr(remainTime,"hh")+" 초과";
		}else{
			remainTimeStr = AttendUtils.convertSecToStr(userAttWorkTime.get("RemainTime").toString(),"hh");
		}
		resultMap.putAll(userAttWorkTime);
		return resultMap;
	}
	
	

	@Override
	public CoviList getMngAttExcelInfo(CoviList userCodeList,
			String companyCode, String startDate, String endDate)
			throws Exception {
		CoviList resultList = new CoviList();
		
		CoviMap params = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));  
		params.put("userCodeList", userCodeList); 
		params.put("CompanyCode", companyCode); 
		params.put("StartDate", startDate); 
		params.put("EndDate", endDate); 
		//사용자 코드로 order by 필수
		CoviList userAttList = coviMapperOne.list("attend.status.getMngAttExcelInfo", params);	
		return userAttList;
	/*	SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		Date sDate = null;
		Date eDate = null;
		try{
			sDate = sdf.parse(AttendUtils.removeMaskAll(startDate));
			eDate = sdf.parse(AttendUtils.removeMaskAll(endDate));
		}catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		long diffDay = (eDate.getTime() - sDate.getTime())/(24*60*60*1000)+1;
		
		CoviList tempUserAtt = new CoviList();
		CoviMap tempUserInfo = new CoviMap();
		
		int totWorkTime = 0;
		int totAttRealTime = 0;
		int totExtenAc = 0;
		int totHoliAc = 0;
		
		for(int i=0;i<userAttList.size();i++){
			CoviMap userAtt = userAttList.getMap(i);
			
			totWorkTime 		+= userAtt.getInt("TotWorkTime");
			totAttRealTime 		+= userAtt.getInt("AttRealTime");
			totExtenAc 			+= userAtt.getInt("ExtenAc");
			totHoliAc 			+= userAtt.getInt("HoliAc");
			tempUserAtt.add(userAtt);
			
			if((i+1)%diffDay==0){
				CoviMap tempMap = new CoviMap();
				
				tempUserInfo.put("UserCode", 				userAtt.get("TargetUserCode"));
				tempUserInfo.put("DeptFullPath", 			userAtt.get("DeptFullPath"));
				tempUserInfo.put("DeptName", 				userAtt.get("DeptName"));
				tempUserInfo.put("DisplayName", 			userAtt.get("DisplayName"));
				tempUserInfo.put("JobPositionName", 		userAtt.get("JobPositionName"));
				tempUserInfo.put("EnterDate", 				userAtt.get("EnterDate"));
				
				tempUserInfo.put("TotWorkTime",				minToAttendFormat(totWorkTime));		//총 근무시간 (시간)
				tempUserInfo.put("TotWorkTimeHour",			minToAttendFormat(totWorkTime,"H"));		//총 근무시간 (시간)
				tempUserInfo.put("TotWorkTimeMin",			minToAttendFormat(totWorkTime,"M"));		//총 근무시간 (분)
				tempUserInfo.put("TotAttRealTime",			minToAttendFormat(totAttRealTime));	//인정근무
				tempUserInfo.put("TotExtenAc",				minToAttendFormat(totExtenAc));		//연장근무
				tempUserInfo.put("TotHoliAc", 				minToAttendFormat(totHoliAc));			//휴일근무
				
				tempMap.put("list",tempUserAtt);
				tempMap.put("info",tempUserInfo);
				resultList.add(tempMap);
 
				//초기화
				totWorkTime = 0; 
				totAttRealTime = 0; 
				totExtenAc = 0;
				totHoliAc = 0;

				tempUserAtt = new CoviList();
				tempUserInfo = new CoviMap();
			}
		}
		return resultList;*/
	}
	
	public String minToAttendFormat(int min){
		String result = "";
		if(min == 0 ){
			return result;
		}
		long hour = TimeUnit.MINUTES.toHours(min);
		long minutes = TimeUnit.MINUTES.toMinutes(min) - TimeUnit.HOURS.toMinutes(hour);
		result = ( hour < 10 ? "0"+hour : hour )+":"+( minutes < 10 ? "0"+minutes : minutes );
		return result;
	}
	
	public String minToAttendFormat(int min,String type){
		String result = "";
		String time = minToAttendFormat(min);
		if("".equals(time)){
			return result;
		}
		String hour = time.split(":")[0];
		String minutes = time.split(":")[1];
		
		if("H".equals(type)){
			result = hour;
		}else if("M".equals(type)){
			result = minutes;
		}else{
			result =  time;
		}
		return result;
	}
	
	@Override
	public CoviList getUserApprovalList(CoviMap params) throws Exception {
		params.put("lang", SessionHelper.getSession("lang"));
		return coviMapperOne.list("attend.status.getUserApprovalList", params);
	}

	@Override
	public CoviMap getUserAttendanceWeeklyViewer(CoviMap params) throws Exception {
		boolean incld_weeks = Boolean.parseBoolean(params.getString("incld_weeks"));
		CoviMap returnMap = new CoviMap();
		String dayTitleMonth = "";
		SimpleDateFormat informat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
		SimpleDateFormat formatyyyy = new SimpleDateFormat("yyyy");
		/*검색일*/
		String TargetDate = params.getString("TargetDate");
		String req_rangeStartDate = params.getString("rangeStartDate");
		String req_rangeEndDate = params.getString("rangeEndDate");
		int req_rangeWeekNum = Integer.parseInt(params.getString("rangeWeekNum"));
		String CompanyCode = params.getString("CompanyCode");
		dayTitleMonth = req_rangeStartDate.replaceAll("-",".")+"~"+req_rangeEndDate.replaceAll("-",".");
		String sDate = req_rangeStartDate.replaceAll("-","");
		String eDate = req_rangeEndDate.replaceAll("-","");
		Calendar cal = Calendar.getInstance();
		Date date_Startdate = format.parse(sDate);
		cal.setTime(date_Startdate);
		cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));

		cal.setTime(date_Startdate);
		cal.add(Calendar.DATE, -1);
		String p_sDate = format.format(cal.getTime());
		returnMap.put("p_sDate", p_sDate);
		Date date_Enddate = format.parse(eDate);
		cal.setTime(date_Enddate);
		cal.add(Calendar.DATE, +1);
		String p_eDate = format.format(cal.getTime());
		returnMap.put("p_eDate", p_eDate);

		/*검색일 end*/
		//월별 주단위 날짜 정보 확인
		int thisYear = Integer.parseInt(eDate.substring(0, 4));
		int lastYear = thisYear - 1;
		int snum = 0;
		int colNumWeeks = 0;
		int LastYearWeeksNum = 52;

		List<Map<String, String>> listRangeFronToDate = new ArrayList<>();
		List WeeksNum = new ArrayList();
//		List WeeksCnt = new ArrayList();
		int tLoop = 0;
		int newYearCnt = 1;
		Date Sdate = informat.parse(req_rangeStartDate);
		Date Edate = informat.parse(req_rangeEndDate);
		Calendar calReq = Calendar.getInstance();
		calReq.setTime(Sdate);
		snum = calReq.get(Calendar.WEEK_OF_YEAR);
		//System.out.println("####RSDate:"+beforeFormat.format(Sdate)+"/"+calReq.get(Calendar.WEEK_OF_YEAR));
		//ThisYearWeeksNum = calReq.getWeeksInWeekYear();
		Date lastyeatDate = formatyyyy.parse(String.valueOf(lastYear));
		calReq.setTime(lastyeatDate);
		LastYearWeeksNum = calReq.getWeeksInWeekYear();
		calReq.setTime(Edate);
		//System.out.println("####REDate:"+beforeFormat.format(Edate)+"/"+calReq.get(Calendar.WEEK_OF_YEAR));
		tLoop = calReq.get(Calendar.WEEK_OF_YEAR);
		if(snum>tLoop){//전년 부터 올해 경계 조회시
			tLoop = LastYearWeeksNum + tLoop;
		}
		Calendar Cal = Calendar.getInstance();
		int weekOver = 0;
		for (int i = snum; i <= tLoop; i++) {
			if(req_rangeWeekNum==weekOver){
				break;
			}
			Cal.setTime(Sdate);
			Cal.add(Calendar.DAY_OF_MONTH, 6);
			Edate = Cal.getTime();

			Map<String, String> newRange = new HashMap<>();
			if (!incld_weeks && i == snum){
				newRange.put(sDate, format.format(Edate));
			}else if (!incld_weeks && i == tLoop){
				newRange.put(format.format(Sdate), eDate);
			}else{
				newRange.put(format.format(Sdate), format.format(Edate));
			}
			listRangeFronToDate.add(newRange);


			if(i<=LastYearWeeksNum) {
				WeeksNum.add(i);

			}else{
				WeeksNum.add(newYearCnt);
				newYearCnt++;
			}
//			WeeksCnt.add(colNumWeeks);
			colNumWeeks++;


			Cal.setTime(Edate);
			Cal.add(Calendar.DAY_OF_MONTH, 1);
			Sdate = Cal.getTime();
			weekOver++;
		}
		//-->

		CoviList userCodeList = (CoviList) params.get("userCodeList");

		String weeklyWorkValue = params.getString("weeklyWorkValue");
		String weeklyWorkType  = params.getString("weeklyWorkType");
		if(!weeklyWorkValue.equals("")){
			weeklyWorkValue = String.valueOf(Integer.parseInt(weeklyWorkValue) * 60);
		}
		CoviList userAttStatusInfo = getUserAttStatusWeekly(userCodeList, CompanyCode, listRangeFronToDate, WeeksNum, weeklyWorkValue, weeklyWorkType);


		CoviMap coviMap = new CoviMap();
		returnMap.addAll(coviMap);
		returnMap.put("userAttStatusInfo", userAttStatusInfo);
		returnMap.put("dayTitleMonth", dayTitleMonth);
		returnMap.put("WeeksNum", WeeksNum);
		returnMap.put("listRangeFronToDate", listRangeFronToDate);

		returnMap.put("sDate", informat.format(date_Startdate));
		returnMap.put("eDate", informat.format(date_Enddate));

		return returnMap;
	}

	@Override
	public CoviList getUserAttStatusInfo(CoviMap reqparam, CoviList userCodeList,String companyCode, List WeeksNum) {
		CoviMap params = new CoviMap();
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
		params.put("userCodeList", userCodeList);
		params.put("CompanyCode", companyCode);
		params.put("weeklyWorkType", reqparam.getString("weeklyWorkType"));
		params.put("weeklyWorkValue", reqparam.getString("weeklyWorkValue"));
		params.put("WeeksNum", WeeksNum);

		CoviList coviList = coviMapperOne.list("attend.status.getUserAttStatusInfo", params);
		return coviList;
	}

	@Override
	public CoviMap getUserAttendanceViewerExcelData(CoviMap params) throws Exception {
		boolean incld_weeks = Boolean.parseBoolean(params.getString("incld_weeks"));
		CoviMap returnMap = new CoviMap();
		String dayTitleMonth = "";
		SimpleDateFormat sdfMonth = new SimpleDateFormat("yyyy.MM");
		SimpleDateFormat informat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat nondashformat = new SimpleDateFormat("yyyyMMdd");
		SimpleDateFormat dotformat = new SimpleDateFormat("yyyy.MM.dd");
		SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
		SimpleDateFormat formatyyyy = new SimpleDateFormat("yyyy");
		/*검색일*/
		String req_rangeStartDate = params.getString("StartDate");
		String req_rangeEndDate = params.getString("EndDate");
		String CompanyCode = params.getString("CompanyCode");
		dayTitleMonth = req_rangeStartDate.replaceAll("-",".")+"~"+req_rangeEndDate.replaceAll("-",".");
		String sDate = req_rangeStartDate.replaceAll("-","");
		String eDate = req_rangeEndDate.replaceAll("-","");
		Calendar cal = Calendar.getInstance();
		Date date_Startdate = format.parse(sDate);
		cal.setTime(date_Startdate);
		cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));

		cal.setTime(date_Startdate);
		cal.add(Calendar.DATE, -1);
		String p_sDate = format.format(cal.getTime());
		returnMap.put("p_sDate", p_sDate);
		Date date_Enddate = format.parse(eDate);
		cal.setTime(date_Enddate);
		cal.add(Calendar.DATE, +1);
		String p_eDate = format.format(cal.getTime());
		returnMap.put("p_eDate", p_eDate);
		/*검색일 end*/
		//월별 주단위 날짜 정보 확인
		CoviList clMonthlyInfo = new CoviList();
		CoviMap reqParam = new CoviMap();
		reqParam.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqParam.put("DomainCode", SessionHelper.getSession("DN_ID"));
		reqParam.put("StartDate", sDate.substring(0,6));
		reqParam.put("EndDate", eDate.substring(0,6));
		int thisYear = Integer.parseInt(sDate.substring(0, 4));
		int lastYear = thisYear - 1;
		reqParam.put("ThisYear", thisYear);
		reqParam.put("LastYear", lastYear);
		clMonthlyInfo = coviMapperOne.list("attend.job.getJobViewMonthlyInfo", reqParam);
		CoviList jObjMonthlyInfo = CoviSelectSet.coviSelectJSON(clMonthlyInfo, "StartDate,StartWeekNum,EndDate,EndWeekNum,ThisYearWeeksNum,LastYearWeeksNum");

		int sweeknum = 0;
		int eweeknum = 0;
		int loopnum = 0;
		int snum = 0;
		int colNumWeeks = 0;
		String rangeStartDate = "";
		String rangeEndDate = "";
		int ThisYearWeeksNum = 52;
		int LastYearWeeksNum = 52;

		String schStartDate = "";

		if (jObjMonthlyInfo.size() > 0) {
			int i = 0;
			while (i < jObjMonthlyInfo.size()) {
				sweeknum = Integer.parseInt(((CoviMap) jObjMonthlyInfo.get(i)).getString("StartWeekNum"));
				eweeknum = Integer.parseInt(((CoviMap) jObjMonthlyInfo.get(i)).getString("EndWeekNum"));
				rangeStartDate = ((CoviMap) jObjMonthlyInfo.get(i)).getString("StartDate");
				schStartDate = rangeStartDate;
				rangeEndDate = ((CoviMap) jObjMonthlyInfo.get(i)).getString("EndDate");
				ThisYearWeeksNum = Integer.parseInt(((CoviMap) jObjMonthlyInfo.get(i)).getString("ThisYearWeeksNum"));
				LastYearWeeksNum = Integer.parseInt(((CoviMap) jObjMonthlyInfo.get(i)).getString("LastYearWeeksNum"));
				snum = sweeknum;
				i++;
			}
		}
		if (eweeknum > sweeknum) {
			loopnum = eweeknum - sweeknum;
		} else {//년도 바뀌면 52주 더해서 주차 구함
			loopnum = (eweeknum + LastYearWeeksNum) - sweeknum;
		}
		List<Map<String, String>> listRangeFronToDate = new ArrayList<>();
		List WeeksNum = new ArrayList();
		List WeeksCnt = new ArrayList();
		int tLoop = snum + loopnum;
		int newYearCnt = 1;
		SimpleDateFormat beforeFormat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat afterFormat = new SimpleDateFormat("yyyyMMdd");
		Date Sdate = informat.parse(req_rangeStartDate);
		Date Edate = informat.parse(req_rangeEndDate);
		Calendar calReq = Calendar.getInstance();
		calReq.setTime(Sdate);
		snum = calReq.get(Calendar.WEEK_OF_YEAR);
		//System.out.println("####RSDate:"+beforeFormat.format(Sdate)+"/"+calReq.get(Calendar.WEEK_OF_YEAR));
		ThisYearWeeksNum = calReq.getWeeksInWeekYear();
		Date lastyeatDate = formatyyyy.parse(String.valueOf(lastYear));
		calReq.setTime(lastyeatDate);
		LastYearWeeksNum = calReq.getWeeksInWeekYear();
		calReq.setTime(Edate);
		//System.out.println("####REDate:"+beforeFormat.format(Edate)+"/"+calReq.get(Calendar.WEEK_OF_YEAR));
		tLoop = calReq.get(Calendar.WEEK_OF_YEAR);
		if(snum>tLoop){
			tLoop = LastYearWeeksNum + snum;
		}
		Calendar Cal = Calendar.getInstance();
		int weekOver = 0;
		for (int i = snum; i <= tLoop; i++) {
			Cal.setTime(Sdate);
			Cal.add(Calendar.DAY_OF_MONTH, 6);
			Edate = Cal.getTime();

			Map<String, String> newRange = new HashMap<>();
			if (!incld_weeks && i == snum){
				newRange.put(sDate, afterFormat.format(Edate));
			}else if (!incld_weeks && i == tLoop){
				newRange.put(afterFormat.format(Sdate), eDate);
			}else{
				newRange.put(afterFormat.format(Sdate), afterFormat.format(Edate));
			}
			listRangeFronToDate.add(newRange);


			if(i<=LastYearWeeksNum) {
				WeeksNum.add(i);

			}else{
				WeeksNum.add(newYearCnt);
				newYearCnt++;
			}
			WeeksCnt.add(colNumWeeks);
			colNumWeeks++;


			Cal.setTime(Edate);
			Cal.add(Calendar.DAY_OF_MONTH, 1);
			Sdate = Cal.getTime();
			//System.out.println("######Edate:"+informat.format(Edate)+"/"+req_rangeEndDate);
			if(informat.format(Edate).equals(req_rangeEndDate)){
				break;
			}
		}
		//-->

		boolean bOutputNumtype = false;
		if(params.getString("outputNumtype").equals("Y")){
			bOutputNumtype = true;
		}
		CoviList userCodeList = (CoviList) params.get("userCodeList");

		String weeklyWorkValue = params.getString("weeklyWorkValue");
		String weeklyWorkType  = params.getString("weeklyWorkType");
		if(!weeklyWorkValue.equals("")){
			weeklyWorkValue = String.valueOf(Integer.parseInt(weeklyWorkValue) * 60);
		}
		CoviList userAttStatusInfo = getUserAttStatusWeekly(userCodeList, CompanyCode, listRangeFronToDate, WeeksNum, weeklyWorkValue, weeklyWorkType);

		ArrayList excelHCol	=  new ArrayList();

		Date tempDate = new Date();
		for(int k=0;k<listRangeFronToDate.size();k++){
			Map<String, String> eHCol = new HashMap<>();
			Map<String, String> rangeDate = listRangeFronToDate.get(k);
			String key = rangeDate.keySet().toString().replace("[","").replace("]","");
			String value = rangeDate.get(key);
			tempDate = nondashformat.parse(key);
			String StartRangeDate = informat.format(tempDate);
			tempDate = nondashformat.parse(value);
			String EndRangeDate = informat.format(tempDate);
			eHCol.put("AttDayStartTime", StartRangeDate);
			eHCol.put("AttDayEndTime", EndRangeDate);
			eHCol.put("AttDayWeeksNum", WeeksNum.get(k).toString());
			excelHCol.add(eHCol);
		}
		//userAttWeekly
		CoviList exData = new CoviList();
		for(int j=0;j<userAttStatusInfo.size();j++){
			CoviMap cmap = userAttStatusInfo.getMap(j);
			CoviMap exMap = new CoviMap();
			exMap.put("UserCode", cmap.getString("UserCode"));
			exMap.put("UserName", cmap.getString("UserName"));
			exMap.put("JobPositionName", cmap.getString("JobPositionName"));
			exMap.put("JobLevelName", cmap.getString("JobLevelName"));
			exMap.put("JobTitleName", cmap.getString("JobTitleName"));
			exMap.put("StartDate", cmap.getString("StartDate"));
			exMap.put("EndDate", cmap.getString("EndDate"));
			//TotWorkTime_F AttRealTime_F ExtenAc_F HoliAc_F TotConfWorkTime_F
			int Sum_AttRealTime   = (int) cmap.getDouble("Sum_AttRealTime");
			int Sum_ExtenAc       = (int) cmap.getDouble("Sum_ExtenAc");
			int Sum_ExtenAcD      = (int) cmap.getDouble("Sum_ExtenAcD");
			int Sum_ExtenAcN      = (int) cmap.getDouble("Sum_ExtenAcN");
			int Sum_HoliAc        = (int) cmap.getDouble("Sum_HoliAc");
			int Sum_HoliAcD       = (int) cmap.getDouble("Sum_HoliAcD");
			int Sum_HoliAcN       = (int) cmap.getDouble("Sum_HoliAcN");
			int Sum_TotConfWorkTime = (int) cmap.getDouble("Sum_TotConfWorkTime");
			int Sum_AttAcN        = (int) cmap.getDouble("Sum_AttAcN")+Sum_ExtenAcN+Sum_HoliAcN;
			int Sum_TotWorkTime   = (int) cmap.getDouble("Sum_TotWorkTime");
			int Sum_AvgWeeklyWorkTime = Sum_TotWorkTime/WeeksCnt.size();
			int Sum_TotWorkDTime  = Sum_TotWorkTime - Sum_AttAcN;
			int Sum_TotWorkNTime  = Sum_AttAcN;
			int Sum_AttRealDTime  = Sum_AttRealTime - Sum_AttAcN;
			int Sum_AttRealNTime  = Sum_AttAcN;
			int Sum_TotConfWorkDTime = Sum_TotConfWorkTime - Sum_AttAcN;
			int Sum_TotConfWorkNTime = Sum_AttAcN;
			exMap.put("Sum_TotWorkTime_F", bOutputNumtype?String.valueOf(Sum_TotWorkTime):AttendUtils.convertSecToStr(Sum_TotWorkTime,"H"));
			exMap.put("Sum_TotWorkDTime_F", bOutputNumtype?String.valueOf(Sum_TotWorkDTime):AttendUtils.convertSecToStr(Sum_TotWorkDTime,"H"));
			exMap.put("Sum_TotWorkNTime_F", bOutputNumtype?String.valueOf(Sum_TotWorkNTime):AttendUtils.convertSecToStr(Sum_TotWorkNTime,"H"));
			exMap.put("Sum_AttRealTime_F", bOutputNumtype?String.valueOf(Sum_AttRealTime):AttendUtils.convertSecToStr(Sum_AttRealTime,"H"));
			exMap.put("Sum_AttRealDTime_F", bOutputNumtype?String.valueOf(Sum_AttRealDTime):AttendUtils.convertSecToStr(Sum_AttRealDTime,"H"));
			exMap.put("Sum_AttRealNTime_F", bOutputNumtype?String.valueOf(Sum_AttRealNTime):AttendUtils.convertSecToStr(Sum_AttRealNTime,"H"));
			exMap.put("Sum_ExtenAc_F", bOutputNumtype?String.valueOf(Sum_ExtenAc):AttendUtils.convertSecToStr(Sum_ExtenAc,"H"));
			exMap.put("Sum_ExtenAcD_F", bOutputNumtype?String.valueOf(Sum_ExtenAcD):AttendUtils.convertSecToStr(Sum_ExtenAcD,"H"));
			exMap.put("Sum_ExtenAcN_F", bOutputNumtype?String.valueOf(Sum_ExtenAcN):AttendUtils.convertSecToStr(Sum_ExtenAcN,"H"));
			exMap.put("Sum_HoliAc_F", bOutputNumtype?String.valueOf(Sum_HoliAc):AttendUtils.convertSecToStr(Sum_HoliAc,"H"));
			exMap.put("Sum_HoliAcD_F", bOutputNumtype?String.valueOf(Sum_HoliAcD):AttendUtils.convertSecToStr(Sum_HoliAcD,"H"));
			exMap.put("Sum_HoliAcN_F", bOutputNumtype?String.valueOf(Sum_HoliAcN):AttendUtils.convertSecToStr(Sum_HoliAcN,"H"));
			exMap.put("Sum_TotConfWorkTime_F", bOutputNumtype?String.valueOf(Sum_TotConfWorkTime):AttendUtils.convertSecToStr(Sum_TotConfWorkTime,"H"));
			exMap.put("Sum_TotConfWorkDTime_F", bOutputNumtype?String.valueOf(Sum_TotConfWorkDTime):AttendUtils.convertSecToStr(Sum_TotConfWorkDTime,"H"));
			exMap.put("Sum_TotConfWorkNTime_F", bOutputNumtype?String.valueOf(Sum_TotConfWorkNTime):AttendUtils.convertSecToStr(Sum_TotConfWorkNTime,"H"));
			exMap.put("Sum_AvgWeeklyWorkTime_F", bOutputNumtype?String.valueOf(Sum_AvgWeeklyWorkTime):AttendUtils.convertSecToStr(Sum_AvgWeeklyWorkTime,"H"));

			CoviList userAttWeekly = new CoviList();
			for(int k=0;k<listRangeFronToDate.size();k++){
				CoviMap exWeeklyMap = new CoviMap();
				exWeeklyMap.put("AttDayWeeksNum", cmap.getString("AttDayWeeksNum_"+k));
				exWeeklyMap.put("AttDayStartTime", cmap.getString("AttDayStartTime_"+k));
				exWeeklyMap.put("AttDayEndTime", cmap.getString("AttDayEndTime_"+k));
				exWeeklyMap.put("userWorkInfo", cmap.getString("userWorkInfo_"+k));
				int AttAcN        = (int) cmap.getDouble("AttAcN_"+k) +(int) cmap.getDouble("ExtenAcN_"+k)+(int) cmap.getDouble("HoliAcN_"+k);
				int TotWorkTime   = (int) cmap.getDouble("TotWorkTime_"+k);
				int TotWorkDTime  = TotWorkTime - AttAcN;
				int TotWorkNTime  = AttAcN;
				int AttRealConfTime  = (int) cmap.getDouble("AttRealConfTime_"+k);
				int AttRealConfDTime = AttRealConfTime - AttAcN;
				int AttRealConfNTime = AttAcN;
				int AttReal       = (int) cmap.getDouble("AttReal_"+k);
				int AttRealD      = AttReal -  AttAcN;
				int AttRealN      = AttAcN;
				exWeeklyMap.put("TotWorkTime_F", bOutputNumtype?String.valueOf(TotWorkTime):AttendUtils.convertSecToStr(TotWorkTime,"H"));
				exWeeklyMap.put("TotWorkDTime_F", bOutputNumtype?String.valueOf(TotWorkDTime):AttendUtils.convertSecToStr(TotWorkDTime,"H"));
				exWeeklyMap.put("TotWorkNTime_F", bOutputNumtype?String.valueOf(TotWorkNTime):AttendUtils.convertSecToStr(TotWorkNTime,"H"));
				exWeeklyMap.put("AttRealConfTime_F", bOutputNumtype?String.valueOf(AttRealConfTime):AttendUtils.convertSecToStr(AttRealConfTime,"H"));
				exWeeklyMap.put("AttRealConfDTime_F", bOutputNumtype?String.valueOf(AttRealConfDTime):AttendUtils.convertSecToStr(AttRealConfDTime,"H"));
				exWeeklyMap.put("AttRealConfNTime_F", bOutputNumtype?String.valueOf(AttRealConfNTime):AttendUtils.convertSecToStr(AttRealConfNTime,"H"));
				exWeeklyMap.put("AttReal_F", bOutputNumtype?String.valueOf(AttReal):AttendUtils.convertSecToStr(AttReal,"H"));
				exWeeklyMap.put("AttRealD_F", bOutputNumtype?String.valueOf(AttRealD):AttendUtils.convertSecToStr(AttRealD,"H"));
				exWeeklyMap.put("AttRealN_F", bOutputNumtype?String.valueOf(AttRealN):AttendUtils.convertSecToStr(AttRealN,"H"));
				exWeeklyMap.put("ExtenAc_F", bOutputNumtype?cmap.getString("ExtenAc_"+k):AttendUtils.convertSecToStr(cmap.getString("ExtenAc_"+k),"H"));
				exWeeklyMap.put("ExtenAcD_F", bOutputNumtype?cmap.getString("ExtenAcD_"+k):AttendUtils.convertSecToStr(cmap.getString("ExtenAcD_"+k),"H"));
				exWeeklyMap.put("ExtenAcN_F", bOutputNumtype?cmap.getString("ExtenAcN_"+k):AttendUtils.convertSecToStr(cmap.getString("ExtenAcN_"+k),"H"));
				exWeeklyMap.put("HoliAc_F", bOutputNumtype?cmap.getString("HoliAc_"+k):AttendUtils.convertSecToStr(cmap.getString("HoliAc_"+k),"H"));
				exWeeklyMap.put("HoliAcD_F", bOutputNumtype?cmap.getString("HoliAcD_"+k):AttendUtils.convertSecToStr(cmap.getString("HoliAcD_"+k),"H"));
				exWeeklyMap.put("HoliAcN_F", bOutputNumtype?cmap.getString("HoliAcN_"+k):AttendUtils.convertSecToStr(cmap.getString("HoliAcN_"+k),"H"));
				exWeeklyMap.put("MonthlyAttAcSum_F", bOutputNumtype?cmap.getString("MonthlyAttAcSum_"+k):AttendUtils.convertSecToStr(cmap.getString("MonthlyAttAcSum_"+k),"H"));
				userAttWeekly.add(exWeeklyMap);
			}
			exMap.put("userAttWeekly",userAttWeekly);
			exData.add(exMap);

		}

		returnMap.put("userAtt", exData);
		returnMap.put("dayTitleMonth", dayTitleMonth);
		//returnMap.put("holiSch", holiSchList);
		returnMap.put("WeeksNum", WeeksNum);
		returnMap.put("excelHCol",	excelHCol);
		returnMap.put("listRangeFronToDate", listRangeFronToDate);
		returnMap.put("sDate", informat.format(date_Startdate));
		returnMap.put("eDate", informat.format(date_Enddate));

		return returnMap;
	}

	@Override
	public CoviMap getUserAttWorkWithDayAndNightTimeProc(String userCode,String companyCode,String startDate,String endDate) throws Exception {

		CoviMap params = new CoviMap();
		params.put("UserCode", userCode);
		params.put("CompanyCode", companyCode);
		params.put("StartDate", startDate);
		params.put("EndDate", endDate);
		String DayNightStartTime = RedisDataUtil.getBaseConfig("DayNightStartTime")+"";
		String DayNightEndTime = RedisDataUtil.getBaseConfig("DayNightEndTime")+"";
		if(DayNightStartTime.equals("")){
			DayNightStartTime = RedisDataUtil.getBaseConfig("NightStartTime")+"";
		}
		if(DayNightEndTime.equals("")){
			DayNightEndTime = RedisDataUtil.getBaseConfig("NightEndTime")+"";
		}
		params.put("NightStartDate", DayNightStartTime);
		params.put("NightEndDate", DayNightEndTime);
		params.put("HolNightStartDate", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
		params.put("HolNightEndDate", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
		params.put("ExtNightStartDate", RedisDataUtil.getBaseConfig("NightStartTime"));
		params.put("ExtNightEndDate", RedisDataUtil.getBaseConfig("NightEndTime"));

		coviMapperOne.update("attend.status.getUserAttWorkWithDayAndNightTimeProc", params);
		//coviMapperOne.selectOne("attend.status.getUserAttWorkWithDayAndNightTimeProc", params);

		return params;
	}

	@Override
	public CoviMap getRangeFronToDate(String TargetDate, boolean incld_weeks) throws Exception {
		CoviMap returnMap = new CoviMap();
		SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
		String sDate;
		String eDate;
		String YM = TargetDate.replaceAll("-", "").substring(0, 6);
		sDate = YM + "01";
		Calendar cal = Calendar.getInstance();
		Date date_Startdate = format.parse(sDate);
		cal.setTime(date_Startdate);
		cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
		eDate = format.format(cal.getTime());

		cal.setTime(date_Startdate);
		cal.add(Calendar.DATE, -1);
		String p_sDate = format.format(cal.getTime());
		returnMap.put("p_sDate", p_sDate);
		Date date_Enddate = format.parse(eDate);
		cal.setTime(date_Enddate);
		cal.add(Calendar.DATE, +1);
		String p_eDate = format.format(cal.getTime());
		returnMap.put("p_eDate", p_eDate);
		/*검색일 end*/
		//월별 주단위 날짜 정보 확인
		CoviList clMonthlyInfo = new CoviList();
		CoviMap reqParam = new CoviMap();
		reqParam.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqParam.put("DomainCode", SessionHelper.getSession("DN_ID"));
		reqParam.put("StartDate", sDate.substring(0,6));
		reqParam.put("EndDate", eDate.substring(0,6));
		int thisYear = Integer.parseInt(sDate.substring(0, 4));
		int lastYear = thisYear - 1;
		reqParam.put("ThisYear", thisYear);
		reqParam.put("LastYear", lastYear);
		clMonthlyInfo = coviMapperOne.list("attend.job.getJobViewMonthlyInfo", reqParam);
		CoviList jObjMonthlyInfo = CoviSelectSet.coviSelectJSON(clMonthlyInfo, "StartDate,StartWeekNum,EndDate,EndWeekNum,ThisYearWeeksNum,LastYearWeeksNum");

		int sweeknum = 0;
		int eweeknum = 0;
		int loopnum = 0;
		int snum = 0;
		int colNumWeeks = 0;
		String rangeStartDate = "";
		String rangeEndDate = "";
		int LastYearWeeksNum = 52;

		String schStartDate = "";

		if (jObjMonthlyInfo.size() > 0) {
			int i = 0;
			while (i < jObjMonthlyInfo.size()) {
				rangeStartDate = ((CoviMap) jObjMonthlyInfo.get(i)).getString("StartDate");
				rangeEndDate = ((CoviMap) jObjMonthlyInfo.get(i)).getString("EndDate");
				//2021.12.30 dbms 별 주차 계산 로직 상이로 자바 날짜 계산로직기준으로 주차 계산 처리 공통화
				String[] arrRangeStartDate = rangeStartDate.split("-");
				String[] arrRangeEndDate   = rangeEndDate.split("-");
				//System.out.println("#####arrRangeStartDate:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(arrRangeStartDate));
				//System.out.println("#####arrRangeEndDate:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(arrRangeEndDate));

				int rangeStartWeeksNum = AttendUtils.getCurrentWeekOfYear(
						 Integer.parseInt(arrRangeStartDate[0])
						,Integer.parseInt(arrRangeStartDate[1])
						,Integer.parseInt(arrRangeStartDate[2])
				);
				//System.out.println("#####rangeStartWeeksNum:"+rangeStartWeeksNum);

				int rangeEndWeeksNum = AttendUtils.getCurrentWeekOfYear(
						Integer.parseInt(arrRangeEndDate[0])
						,Integer.parseInt(arrRangeEndDate[1])
						,Integer.parseInt(arrRangeEndDate[2])
				);
				//System.out.println("#####rangeEndWeeksNum:"+rangeEndWeeksNum);

				sweeknum = rangeStartWeeksNum;
				eweeknum = rangeEndWeeksNum;
				schStartDate = rangeStartDate;
				LastYearWeeksNum = AttendUtils.getMaxWeekOfYear(lastYear);
				//System.out.println("#####LastYearWeeksNum:"+LastYearWeeksNum);
				snum = sweeknum;
				i++;
			}
		}
		if (eweeknum > sweeknum) {
			loopnum = eweeknum - sweeknum;
		} else {//년도 바뀌면 52주 더해서 주차 구함
			loopnum = (eweeknum + LastYearWeeksNum) - sweeknum;
		}
		List<Map<String, String>> listRangeFronToDate = new ArrayList<>();
		List WeeksNum = new ArrayList();
		List WeeksCnt = new ArrayList();
		int tLoop = snum + loopnum;
		int newYearCnt = 1;
		SimpleDateFormat beforeFormat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat afterFormat = new SimpleDateFormat("yyyyMMdd");
		Date Sdate = null;
		Date Edate = null;
		int diffDay = 0;
		Calendar Cal = Calendar.getInstance();
		Sdate = beforeFormat.parse(schStartDate);
		int weekOver = 0;
		for (int i = snum; i <= tLoop; i++) {
			Cal.setTime(Sdate);
			Cal.add(Calendar.DAY_OF_MONTH, 6);
			Edate = Cal.getTime();

			Map<String, String> newRange = new HashMap<>();
			if (!incld_weeks && i == snum){
				newRange.put(sDate, afterFormat.format(Edate));
			}else if (!incld_weeks && i == tLoop){
				newRange.put(afterFormat.format(Sdate), eDate);
			}else{
				if(weekOver>0){
					break;
				}
				newRange.put(afterFormat.format(Sdate), afterFormat.format(Edate));
				if(p_eDate.substring(0,6).equals(afterFormat.format(Edate).substring(0,6))){
					weekOver++;
				}
			}
			listRangeFronToDate.add(newRange);

			Cal.setTime(Edate);
			Cal.add(Calendar.DAY_OF_MONTH, 1);
			Sdate = Cal.getTime();

			if(i<=LastYearWeeksNum) {
				WeeksNum.add(i);

			}else{
				WeeksNum.add(newYearCnt);
				newYearCnt++;
			}
			WeeksCnt.add(colNumWeeks);
			colNumWeeks++;
		}
		returnMap.put("RangeFronToDate",listRangeFronToDate);
		returnMap.put("WeeksNum",WeeksNum);
		returnMap.put("WeeksCnt",WeeksCnt);
		Map<String, String> firstRangeDate = listRangeFronToDate.get(0);
		Map<String, String> lastRangeDate = listRangeFronToDate.get(listRangeFronToDate.size()-1);
		String sdate = firstRangeDate.keySet().toString().replace("[","").replace("]","");
		String ekey = lastRangeDate.keySet().toString().replace("[","").replace("]","");
		String edate = lastRangeDate.get(ekey);
		Date sDATE = new Date();
		Date eDATE = new Date();
		sDATE = afterFormat.parse(sdate);
		eDATE = afterFormat.parse(edate);
		returnMap.put("RangeStartDate_F",beforeFormat.format(sDATE));
		returnMap.put("RangeEndDate_F",beforeFormat.format(eDATE));
		returnMap.put("RangeStartDate",sdate);
		returnMap.put("RangeEndDate",edate);
		returnMap.put("incld_weeks",incld_weeks);
		String rtnTargetDate = "";
		if(TargetDate.contains("-")){
			rtnTargetDate = TargetDate;
		}else if(TargetDate.length()==8){
			Date tDATE = afterFormat.parse(TargetDate);
			rtnTargetDate = beforeFormat.format(tDATE);
		}
		returnMap.put("TargetDate",rtnTargetDate);


		return returnMap;
	}
	
	// 일괄 출퇴근 적용
	@Override
	public CoviMap setAllCommute(CoviMap params, List ReqData, CoviList TargetUserList) throws Exception {
		CoviMap returnMap = new CoviMap();
		int result = 0;
		
		for (int i = 0; i < TargetUserList.size(); i++) {
			params.put("UserCode", TargetUserList.getMap(i).getString("Code"));
			
			for (int j = 0; j < ReqData.size(); j++) {
				params.put("TargetDate", ((Map)ReqData.get(j)).get("WorkDate"));
				params.put("RegUserCode", params.getString("RegisterCode"));
				
				CoviMap attJob = null;
				CoviList jobList = coviMapperOne.list("attend.commute.getMngJob", params);
				
				if (jobList != null && jobList.size() > 0) { // 근무 일정이 있을 때
					attJob = jobList.getMap(0);
				} else { // 근무 일정이 없을 때
					params.put("SetDate",((Map)ReqData.get(j)).get("WorkDate").toString());
					CoviList scheduleList = coviMapperOne.list("attend.schedule.getBaseSchedule", params);
					attJob = scheduleList.getMap(0);
					
					// 근무 일정 생성
					CoviMap item = new CoviMap();
					item.put("SchSeq", attJob.getString("SchSeq"));
					item.put("JobUserCode", params.getString("UserCode"));
					item.put("TrgDates", params.getString("TargetDate"));
					item.put("HolidayFlag", "Y");
					item.put("WeekFlag", "Y");
					item.put("CompanyCode", params.getString("CompanyCode"));
					item.put("USERID", params.getString("RegisterCode"));
					
					coviMapperOne.update("attend.job.createScheduleJobDiv", item);
				}
				
				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				Calendar cal = Calendar.getInstance();
				
				if (params.getString("IsGoWork").equals("Y")) { // 일괄출근
					int min = Integer.parseInt(RedisDataUtil.getBaseConfig("AllGoWorkApplyTime", SessionHelper.getSession("DN_ID")));
					
					Date startDate = dateFormat.parse(attJob.getString("AttDayStartTime"));
					cal.setTime(startDate);
					cal.add(Calendar.MINUTE, (min * -1));

					params.put("StartDate", dateFormat.format(cal.getTime()));
				}
				
				if (params.getString("IsOffWork").equals("Y")) { // 일괄퇴근
					int min = Integer.parseInt(RedisDataUtil.getBaseConfig("AllOffWorkApplyTime", SessionHelper.getSession("DN_ID")));
					
					Date endDate = dateFormat.parse(attJob.getString("AttDayEndTime"));
					cal.setTime(endDate);
					cal.add(Calendar.MINUTE, min);
					
					params.put("EndDate", dateFormat.format(cal.getTime()));
				}
				
				String commuteSeq = coviMapperOne.selectOne("attend.commute.getCommuteMstSeq", params);
				
				if(commuteSeq == null){
					/**
					 * 해당 일자에 대한  MST TABLE 데이터가 없을경우
					 * MST테이블 정보를 생성
					 * */
					coviMapperOne.insert("attend.commute.setCommuteMst", params);
					commuteSeq = params.getString("CommuSeq");
				}
				
				params.put("CommuSeq", commuteSeq);
				
				//출퇴근 시간 ( 상태 S ) 업데이트 
				result += coviMapperOne.update("attend.commute.setAttCommuteMng", params);

				//출퇴근 시간 외 정보 재입력
				coviMapperOne.update("attend.commute.setCommuteMstProc", params);
				
				// 수정자 업데이트
				coviMapperOne.update("attend.commute.updateAllCommute", params);
			}
		}
		
		returnMap.put("cnt", result);
		
		return returnMap;
	}
	
	@Override
	public CoviList getTargetUserList(List TargetData) {
		CoviList returnList = new CoviList();
		
		if (TargetData != null) {
			CoviMap cMap = null;
			
			for (int k = 0; k < TargetData.size(); k++){
				Map target = (Map)TargetData.get(k);
				
				if (target.get("Type").equals("UR")) {
					cMap = new CoviMap();
					
					cMap.put("Code", target.get("Code"));
					cMap.put("Name", target.get("Name"));
					
					returnList.add(cMap);
				} else {
					CoviMap deptParam = new CoviMap();
					deptParam.put("CompanyCode", SessionHelper.getSession("DN_Code"));
					deptParam.put("sDeptCode", target.get("Code"));
					
					CoviList userList = coviMapperOne.list("attend.common.getUserListByDept", deptParam);
					
					for (int i = 0; i < userList.size(); i++) {
						CoviMap userMap = userList.getMap(i);
						cMap = new CoviMap();
						
						cMap.put("Code", userMap.getString("UserCode"));
						cMap.put("Name", userMap.getString("DisplayName"));
						
						returnList.add(cMap);
					}
				}
			}
		}
		
		return returnList;
	}
	
	@Override
	public CoviMap getUserAttendanceDailyViewer(CoviMap params) throws Exception {
		boolean incld_weeks = Boolean.parseBoolean(params.getString("incld_weeks"));
		int pageSize = params.getInt("pageSize");
		CoviMap returnMap = new CoviMap();
		String dayTitleMonth = "";
		SimpleDateFormat sdfMonth = new SimpleDateFormat("yyyy.MM");
		SimpleDateFormat informat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
		/*검색일*/
		String TargetDate = params.getString("TargetDate");
		String CompanyCode = params.getString("CompanyCode");
		Date dateTitleMonth = new Date();
		if (TargetDate.contains("-")) {
			dateTitleMonth = informat.parse(TargetDate);
		} else {
			dateTitleMonth = format.parse(TargetDate);
		}
		dayTitleMonth = sdfMonth.format(dateTitleMonth);
		String sDate;
		String eDate;
		String YM = TargetDate.replaceAll("-", "").substring(0, 6);
		sDate = YM + "01";
		Calendar cal = Calendar.getInstance();
		Date date_Startdate = format.parse(sDate);
		cal.setTime(date_Startdate);
		cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
		eDate = format.format(cal.getTime());

		cal.setTime(date_Startdate);
		cal.add(Calendar.DATE, -1);
		String p_sDate = format.format(cal.getTime());
		returnMap.put("p_sDate", p_sDate);
		Date date_Enddate = format.parse(eDate);
		cal.setTime(date_Enddate);
		cal.add(Calendar.DATE, +1);
		String p_eDate = format.format(cal.getTime());
		returnMap.put("p_eDate", p_eDate);
		/*검색일 end*/
		//월별 주단위 날짜 정보 확인
		CoviList clMonthlyInfo = new CoviList();
		CoviMap reqParam = new CoviMap();
		reqParam.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqParam.put("DomainCode", SessionHelper.getSession("DN_ID"));
		reqParam.put("StartDate", sDate.substring(0,6));
		reqParam.put("EndDate", eDate.substring(0,6));
		int thisYear = Integer.parseInt(sDate.substring(0, 4));
		int lastYear = thisYear - 1;
		reqParam.put("ThisYear", thisYear);
		reqParam.put("LastYear", lastYear);
		clMonthlyInfo = coviMapperOne.list("attend.job.getJobViewMonthlyInfo", reqParam);
		CoviList jObjMonthlyInfo = CoviSelectSet.coviSelectJSON(clMonthlyInfo, "StartDate,StartWeekNum,EndDate,EndWeekNum,ThisYearWeeksNum,LastYearWeeksNum");

		int sweeknum = 0;
		int eweeknum = 0;
		int loopnum = 0;
		int snum = 0;
		int colNumWeeks = 0;
		String rangeStartDate = "";
		String rangeEndDate = "";
		int LastYearWeeksNum = 52;

		String schStartDate = "";

		if (jObjMonthlyInfo.size() > 0) {
			int i = 0;
			while (i < jObjMonthlyInfo.size()) {
				rangeStartDate = ((CoviMap) jObjMonthlyInfo.get(i)).getString("StartDate");
				rangeEndDate = ((CoviMap) jObjMonthlyInfo.get(i)).getString("EndDate");
				//2021.12.30 dbms 별 주차 계산 로직 상이로 자바 날짜 계산로직기준으로 주차 계산 처리 공통화
				String[] arrRangeStartDate = rangeStartDate.split("-");
				String[] arrRangeEndDate   = rangeEndDate.split("-");
				//System.out.println("#####arrRangeStartDate:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(arrRangeStartDate));
				//System.out.println("#####arrRangeEndDate:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(arrRangeEndDate));

				int rangeStartWeeksNum = AttendUtils.getCurrentWeekOfYear(
						Integer.parseInt(arrRangeStartDate[0])
						,Integer.parseInt(arrRangeStartDate[1])
						,Integer.parseInt(arrRangeStartDate[2])
				);
				//System.out.println("#####rangeStartWeeksNum:"+rangeStartWeeksNum);

				int rangeEndWeeksNum = AttendUtils.getCurrentWeekOfYear(
						Integer.parseInt(arrRangeEndDate[0])
						,Integer.parseInt(arrRangeEndDate[1])
						,Integer.parseInt(arrRangeEndDate[2])
				);
				//System.out.println("#####rangeEndWeeksNum:"+rangeEndWeeksNum);

				sweeknum = rangeStartWeeksNum;
				eweeknum = rangeEndWeeksNum;
				schStartDate = rangeStartDate;
				LastYearWeeksNum = AttendUtils.getMaxWeekOfYear(lastYear);
				//System.out.println("#####LastYearWeeksNum:"+LastYearWeeksNum);
				snum = sweeknum;
				i++;
			}
		}
		if (eweeknum > sweeknum) {
			loopnum = eweeknum - sweeknum;
		} else {//년도 바뀌면 52주 더해서 주차 구함
			loopnum = (eweeknum + LastYearWeeksNum) - sweeknum;
		}
		List<Map<String, String>> listRangeFronToDate = new ArrayList<>();
		List WeeksNum = new ArrayList();
//		List WeeksCnt = new ArrayList();
		int tLoop = snum + loopnum;
		int newYearCnt = 1;
		SimpleDateFormat beforeFormat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat afterFormat = new SimpleDateFormat("yyyyMMdd");
		Date Sdate = null;
		Date Edate = null;
		int diffDay = 0;
		Calendar Cal = Calendar.getInstance();
		Sdate = beforeFormat.parse(schStartDate);
		int weekOver = 0;
		for (int i = snum; i <= tLoop; i++) {
			Cal.setTime(Sdate);
			Cal.add(Calendar.DAY_OF_MONTH, 6);
			Edate = Cal.getTime();

			Map<String, String> newRange = new HashMap<>();
			if (!incld_weeks && i == snum){
				newRange.put(sDate, afterFormat.format(Edate));
			}else if (!incld_weeks && i == tLoop){
				newRange.put(afterFormat.format(Sdate), eDate);
			}else{
				if(weekOver>0){
					break;
				}
				newRange.put(afterFormat.format(Sdate), afterFormat.format(Edate));
				if(p_eDate.substring(0,6).equals(afterFormat.format(Edate).substring(0,6))){
					weekOver++;
				}
			}
			listRangeFronToDate.add(newRange);

			Cal.setTime(Edate);
			Cal.add(Calendar.DAY_OF_MONTH, 1);
			Sdate = Cal.getTime();

			if(i<=LastYearWeeksNum) {
				WeeksNum.add(i);

			}else{
				WeeksNum.add(newYearCnt);
				newYearCnt++;
			}
//			WeeksCnt.add(colNumWeeks);
			colNumWeeks++;
		}
		//-->

		CoviList userCodeList = (CoviList) params.get("userCodeList");

		CoviList userAttStatusInfo = getUserAttStatusInfo(params, userCodeList, CompanyCode, WeeksNum);

		String weeklyWorkValue = params.getString("weeklyWorkValue");
		String weeklyWorkType  = params.getString("weeklyWorkType");

		boolean weekTimeCheckMode = false;
		if(!weeklyWorkValue.equals("")&&!weeklyWorkValue.equals("0")){
			weeklyWorkValue = String.valueOf(Integer.parseInt(weeklyWorkValue) * 60);
			weekTimeCheckMode = true;
		}
		CoviList userAttInfo = getUserAttStatusDaily(userCodeList, CompanyCode, listRangeFronToDate, WeeksNum, weeklyWorkValue, weeklyWorkType);

		CoviList userAttList = new CoviList();

		diffDay = returnMap.getInt("dayScopeCnt")+1;
		Calendar CalStart = Calendar.getInstance();
		Calendar CalEnd = Calendar.getInstance();
		int putCnt = 0;
		for(int i=0;i<userAttStatusInfo.size();i++){
			int ckTimeCnt = 0;
			CoviMap userAtt = userAttStatusInfo.getMap(i);
			CoviMap userAttWorkTotalTime = new CoviMap();

			List userAttWeeklyList = new ArrayList();
			List userAttDailyList = new ArrayList();
			for(int k=0;k<listRangeFronToDate.size();k++){
				Map<String, String> rangeDate = listRangeFronToDate.get(k);
				String key = rangeDate.keySet().toString().replace("[","").replace("]","");
				String value = rangeDate.get(key);
				//주단위
				CoviMap userAttWeekly = getUserAttWorkWithDayAndNightTimeProc(userAtt.getString("UserCode"), CompanyCode, key, value);
				if(weekTimeCheckMode){//주단위 시간 조건 검색시
					if(weeklyWorkType.equals("over")
							&& userAttWeekly.getInt("TotWorkTime")>Integer.parseInt(weeklyWorkValue)){
						ckTimeCnt++;
					}else if(weeklyWorkType.equals("under")
							&& userAttWeekly.getInt("TotWorkTime")<=Integer.parseInt(weeklyWorkValue)){
						ckTimeCnt++;
					}
				}
				userAttWeeklyList.add(userAttWeekly);
				//주단위 내에서 일단위조회 처리
				Map WeekInfoMap = new HashMap();
				Date daily_rangeDate = format.parse(key);
				Cal.setTime(daily_rangeDate);

				Date rngStartDate = format.parse(key);
				CalStart.setTime(rngStartDate);
				Date rngEndDate = format.parse(value);
				CalEnd.setTime(rngEndDate);
				long rngDiff = CalEnd.getTimeInMillis() - CalStart.getTimeInMillis();
				long rngDiffDays = rngDiff / (24 * 60 * 60 * 1000);
				int rngDiffDayInt = Math.toIntExact(rngDiffDays)+1;
				for(int w=0;w<rngDiffDayInt;w++){
					if(w>0){
						Cal.add(Calendar.DATE, +1);
					}
					daily_rangeDate = Cal.getTime();
					CoviMap userAttDaily = new CoviMap();
					for(int z=0;z<userAttInfo.size();z++){
						CoviMap cmap = userAttInfo.getMap(z);
						if(cmap.getString("UserCode").equals(userAtt.getString("UserCode"))
						  && cmap.getString("dayList").equals(informat.format(daily_rangeDate))){
							userAttDaily.putAll(cmap);
							userAttInfo.remove(z);
							break;
						}
					}
					//일별데이터내에 주차수 넣기
					WeekInfoMap.clear();
					WeekInfoMap.put("WeekNum",WeeksNum.get(k));
					WeekInfoMap.put("DayOfWeek",Cal.get(Calendar.DAY_OF_WEEK));
					userAttDaily.addAll(WeekInfoMap);

					userAttDailyList.add(userAttDaily);
				}//end loop a week
			}
			if(pageSize<=putCnt){
				break;
			}
			if((weekTimeCheckMode && ckTimeCnt == 0)) {//주단위 시간 조건 검색시
				continue;
			}
			userAtt.put("userAttDaily",userAttDailyList);
			userAtt.put("userAttWeekly",userAttWeeklyList);

			//해당 사용자에 대한 전체 근태 정보 추출
			if (incld_weeks) {
				userAttWorkTotalTime = getUserAttWorkWithDayAndNightTimeProc(userAtt.getString("UserCode"), CompanyCode, rangeStartDate, rangeEndDate);
			} else {
				userAttWorkTotalTime = getUserAttWorkWithDayAndNightTimeProc(userAtt.getString("UserCode"), CompanyCode, sDate, eDate);
			}
			userAtt.put("userAttWorkTotalTime", userAttWorkTotalTime);
			userAttList.add(userAtt);
			putCnt++;
		}

		CoviMap coviMap = new CoviMap();
		returnMap.addAll(coviMap);
		returnMap.put("userAtt", userAttList);
		returnMap.put("dayTitleMonth", dayTitleMonth);
		returnMap.put("WeeksNum", WeeksNum);
		returnMap.put("listRangeFronToDate", listRangeFronToDate);
		returnMap.put("sDate", informat.format(date_Startdate));
		returnMap.put("eDate", informat.format(date_Enddate));

		return returnMap;
	}

	@Override
	public CoviMap getUserAttendanceDailyViewerExcelData(CoviMap params) throws Exception {
		boolean incld_weeks = Boolean.parseBoolean(params.getString("incld_weeks"));
		CoviMap returnMap = new CoviMap();
		String dayTitleMonth = "";
		SimpleDateFormat sdfMonth = new SimpleDateFormat("yyyy.MM");
		SimpleDateFormat informat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
		/*검색일*/
		String DateTerm = params.getString("DateTerm");
		String TargetDate = params.getString("TargetDate");
		String StartDate = params.getString("StartDate");
		String EndDate = params.getString("EndDate");
		String p_StartDate = params.getString("p_StartDate");
		String p_EndDate = params.getString("p_EndDate");
		String CompanyCode = params.getString("CompanyCode");
		boolean bOutputNumtype = false;
		if(params.getString("outputNumtype").equals("Y")){
			bOutputNumtype = true;
		}
		boolean printDN = Boolean.parseBoolean(params.getString("printDN"));
		Date dateTitleMonth = new Date();
		if (TargetDate.contains("-")) {
			dateTitleMonth = informat.parse(TargetDate);
		} else {
			dateTitleMonth = format.parse(TargetDate);
		}
		dayTitleMonth = sdfMonth.format(dateTitleMonth);
		String sDate;
		String eDate;
		sDate = StartDate.replaceAll("-", "").substring(0,8);
		Date date_Startdate = format.parse(sDate);
		eDate = EndDate.replaceAll("-", "").substring(0,8);

		Calendar Cal = Calendar.getInstance();

		Cal.setTime(date_Startdate);
		Cal.add(Calendar.DATE, -1);
		String p_sDate = format.format(Cal.getTime());
		returnMap.put("p_sDate", p_sDate);
		Date date_Enddate = format.parse(eDate);
		Cal.setTime(date_Enddate);
		Cal.add(Calendar.DATE, +1);
		String p_eDate = format.format(Cal.getTime());
		returnMap.put("p_eDate", p_eDate);
		/*검색일 end*/
		//월별 주단위 날짜 정보 확인
		CoviList clMonthlyInfo = new CoviList();
		CoviMap reqParam = new CoviMap();
		reqParam.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqParam.put("DomainCode", SessionHelper.getSession("DN_ID"));
		reqParam.put("StartDate", StartDate);
		reqParam.put("EndDate", EndDate);
		int thisYear = Integer.parseInt(sDate.substring(0, 4));
		int lastYear = thisYear - 1;
		reqParam.put("ThisYear", thisYear);
		reqParam.put("LastYear", lastYear);
		clMonthlyInfo = coviMapperOne.list("attend.job.getJobViewMonthlyInfo", reqParam);
		CoviList jObjMonthlyInfo = CoviSelectSet.coviSelectJSON(clMonthlyInfo, "StartDate,StartWeekNum,EndDate,EndWeekNum,ThisYearWeeksNum,LastYearWeeksNum");

		int sweeknum = 0;
		int eweeknum = 0;
		int loopnum = 0;
		int snum = 0;
		int colNumWeeks = 0;
		String rangeStartDate = "";
		String rangeEndDate = "";
		int LastYearWeeksNum = 52;

		String schStartDate = "";

		if (jObjMonthlyInfo.size() > 0) {
			int i = 0;
			while (i < jObjMonthlyInfo.size()) {
				rangeStartDate = ((CoviMap) jObjMonthlyInfo.get(i)).getString("StartDate");
				rangeEndDate = ((CoviMap) jObjMonthlyInfo.get(i)).getString("EndDate");
				//2021.12.30 dbms 별 주차 계산 로직 상이로 자바 날짜 계산로직기준으로 주차 계산 처리 공통화
				String[] arrRangeStartDate = rangeStartDate.split("-");
				String[] arrRangeEndDate   = rangeEndDate.split("-");
				//System.out.println("#####arrRangeStartDate:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(arrRangeStartDate));
				//System.out.println("#####arrRangeEndDate:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(arrRangeEndDate));

				int rangeStartWeeksNum = AttendUtils.getCurrentWeekOfYear(
						Integer.parseInt(arrRangeStartDate[0])
						,Integer.parseInt(arrRangeStartDate[1])
						,Integer.parseInt(arrRangeStartDate[2])
				);
				//System.out.println("#####rangeStartWeeksNum:"+rangeStartWeeksNum);

				int rangeEndWeeksNum = AttendUtils.getCurrentWeekOfYear(
						Integer.parseInt(arrRangeEndDate[0])
						,Integer.parseInt(arrRangeEndDate[1])
						,Integer.parseInt(arrRangeEndDate[2])
				);
				//System.out.println("#####rangeEndWeeksNum:"+rangeEndWeeksNum);

				sweeknum = rangeStartWeeksNum;
				eweeknum = rangeEndWeeksNum;
				schStartDate = rangeStartDate;
				LastYearWeeksNum = AttendUtils.getMaxWeekOfYear(lastYear);
				//System.out.println("#####LastYearWeeksNum:"+LastYearWeeksNum);
				snum = sweeknum;
				i++;
			}
		}
		if (eweeknum > sweeknum) {
			loopnum = eweeknum - sweeknum;
		} else {//년도 바뀌면 52주 더해서 주차 구함
			loopnum = (eweeknum + LastYearWeeksNum) - sweeknum;
		}
		List<Map<String, String>> listRangeFronToDate = new ArrayList<>();
		List WeeksNum = new ArrayList();
//		List WeeksCnt = new ArrayList();
		int tLoop = snum + loopnum;
		int newYearCnt = 1;
		SimpleDateFormat beforeFormat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat afterFormat = new SimpleDateFormat("yyyyMMdd");
		Date Sdate = null;
		Date Edate = null;
		Calendar CalpStart = Calendar.getInstance();
		Calendar CalpEnd = Calendar.getInstance();
		Sdate = beforeFormat.parse(schStartDate);
		Date ckEdate = informat.parse(EndDate);
		int weekOver = 0;
		for (int i = snum; i <= tLoop; i++) {
			Cal.setTime(Sdate);
			if (!incld_weeks && i == snum && !p_StartDate.equals("")){//주단위 체크 해제시 해당 주일자 체크 로직
				Date pStartDate = informat.parse(p_StartDate);
				CalpStart.setTime(pStartDate);
				Date oriStartDate = informat.parse(StartDate);
				CalpEnd.setTime(oriStartDate);
				long rngDiff = CalpEnd.getTimeInMillis() - CalpStart.getTimeInMillis();
				long rngDiffDays = rngDiff / (24 * 60 * 60 * 1000);
				int rngDiffDayInt = 6 - (Math.toIntExact(rngDiffDays));

				Cal.add(Calendar.DAY_OF_MONTH, rngDiffDayInt);
			}else{
				Cal.add(Calendar.DAY_OF_MONTH, 6);
			}
			Edate = Cal.getTime();

			Map<String, String> newRange = new HashMap<>();
			if (!incld_weeks && i == snum){
				newRange.put(sDate, afterFormat.format(Edate));
			}else if (!incld_weeks && i == tLoop){
				newRange.put(afterFormat.format(Sdate), eDate);
			}else{
				if(weekOver>0){
					break;
				}
				newRange.put(afterFormat.format(Sdate), afterFormat.format(Edate));
				if(p_eDate.substring(0,6).equals(afterFormat.format(Edate).substring(0,6))){
					weekOver++;
				}
			}

			if(ckEdate.getTime()>=Edate.getTime() || (ckEdate.getTime()-Edate.getTime())>(6*24*60*60*1000*-1)) {
				listRangeFronToDate.add(newRange);
			}else{
				break;
			}

			Cal.setTime(Edate);
			Cal.add(Calendar.DAY_OF_MONTH, 1);
			Sdate = Cal.getTime();

			if(i<=LastYearWeeksNum) {
				WeeksNum.add(i);

			}else{
				WeeksNum.add(newYearCnt);
				newYearCnt++;
			}
//			WeeksCnt.add(colNumWeeks);
			colNumWeeks++;
		}
		//-->

		CoviList userCodeList = (CoviList) params.get("userCodeList");

		CoviList userAttStatusInfo = getUserAttStatusInfo(params, userCodeList, CompanyCode, WeeksNum);

		String weeklyWorkValue = params.getString("weeklyWorkValue");
		String weeklyWorkType  = params.getString("weeklyWorkType");
		boolean weeklyOverUnderMode = false;
		if(!weeklyWorkValue.equals("") && !weeklyWorkValue.equals("0")){
			weeklyWorkValue = String.valueOf(Integer.parseInt(weeklyWorkValue) * 60);
			weeklyOverUnderMode = true;
		}
		CoviList userAttInfo = getUserAttStatusDaily(userCodeList, CompanyCode, listRangeFronToDate, WeeksNum, weeklyWorkValue, weeklyWorkType);

		CoviList userAttList = new CoviList();

		List eHColList = new ArrayList();

		Calendar CalStart = Calendar.getInstance();
		Calendar CalEnd = Calendar.getInstance();
		for(int i=0;i<userAttStatusInfo.size();i++){
			CoviMap userAtt = userAttStatusInfo.getMap(i);
			CoviMap userAttWorkTotalTime = new CoviMap();
			int checkCnt = 0;
			List userAttDailyList = new ArrayList();

			for(int k=0;k<listRangeFronToDate.size();k++){
				int hIdx = 0;
				Map<String, Object> eHCol = new HashMap<>();
				List eHColDayList = new ArrayList();
				Map<String, String> rangeDate = listRangeFronToDate.get(k);
				String key = rangeDate.keySet().toString().replace("[","").replace("]","");
				String value = rangeDate.get(key);

				//주단위 내에서 일단위조회 처리
				Map WeekInfoMap = new HashMap();
				Date daily_rangeDate = format.parse(key);
				Cal.setTime(daily_rangeDate);

				Date rngStartDate = format.parse(key);
				CalStart.setTime(rngStartDate);
				Date rngEndDate = format.parse(value);
				CalEnd.setTime(rngEndDate);
				long rngDiff = CalEnd.getTimeInMillis() - CalStart.getTimeInMillis();
				long rngDiffDays = rngDiff / (24 * 60 * 60 * 1000);
				int rngDiffDayInt = Math.toIntExact(rngDiffDays)+1;
				//
				if(i==0) {
					eHCol.put("AttDayStartTime", informat.format(rngStartDate));
					eHCol.put("AttDayEndTime", informat.format(rngEndDate));
					eHCol.put("DaysCount", rngDiffDayInt);
					eHCol.put("AttDayWeeksNum", WeeksNum.get(k).toString());
				}

				//해당 주에 포함된 날수 많큼 loop
				for(int w=0;w<rngDiffDayInt;w++){
					if(w>0){
						Cal.add(Calendar.DATE, +1);
					}
					daily_rangeDate = Cal.getTime();
					CoviMap userAttDaily = new CoviMap();
					for(int z=0;z<userAttInfo.size();z++){
						CoviMap cmap = userAttInfo.getMap(z);
						if(cmap.getString("UserCode").equals(userAtt.getString("UserCode"))
								&& cmap.getString("dayList").equals(informat.format(daily_rangeDate))){
							userAttDaily.putAll(cmap);
							userAttInfo.remove(z);
							break;
						}
					}
					//일별데이터내에 주차수 넣기
					WeekInfoMap.clear();
					WeekInfoMap.put("WeekNum",String.valueOf(WeeksNum.get(k)));
					WeekInfoMap.put("DayOfWeek",Cal.get(Calendar.DAY_OF_WEEK));
					userAttDaily.addAll(WeekInfoMap);
					//헤더용 날일 정보 넣기
					if(i==0) {
						CoviMap eHColDay = new CoviMap();
						eHColDay.put("Idx", hIdx);
						hIdx++;
						eHColDay.put("DataType", "DailyData");
						eHColDay.put("WeekNum",String.valueOf(WeeksNum.get(k)));
						eHColDay.put("DayOfWeek",Cal.get(Calendar.DAY_OF_WEEK));
						eHColDay.put("DD",String.valueOf(Integer.parseInt(userAttDaily.get("dayList").toString().substring(8))));
						eHColDayList.add(eHColDay);
					}
					//userAttDaily.put("ExtenAc_F", AttendUtils.convertSecToStr(userAttDaily.get("ExtenAc").toString(), "H"));

					String extenAcD = AttendUtils.convertSecToStr(userAttDaily.getDouble("ExtenAcD"),"H");
					String extenAcN = AttendUtils.convertSecToStr(userAttDaily.getDouble("ExtenAcN"),"H");
					String extenAcDN = "";
					if(printDN){
						if(!extenAcD.equals("") || !extenAcN.equals("")){
							extenAcDN = AttendUtils.convertSecToStr(userAttDaily.getDouble("ExtenAcD"),"hh")+" /"+AttendUtils.convertSecToStr(userAttDaily.getDouble("ExtenAcN"),"hh");
						}
					}else {
						extenAcDN = bOutputNumtype?String.valueOf((int) userAttDaily.getDouble("ExtenAc")):AttendUtils.convertSecToStr(userAttDaily.getDouble("ExtenAc"),"H");
					}
					userAttDaily.put("ExtenAcDN_F", extenAcDN);
					//userAttDaily.put("HoliAc_F", AttendUtils.convertSecToStr(userAttDaily.get("HoliAc").toString(),"H"));
					String holiAcD = AttendUtils.convertSecToStr(userAttDaily.getDouble("HoliAcD"),"H");
					String holiAcN = AttendUtils.convertSecToStr(userAttDaily.getDouble("HoliAcN"),"H");
					String holiAcDN = "";
					if(printDN){
						if(!holiAcD.equals("") || !holiAcN.equals("")){
							holiAcDN = AttendUtils.convertSecToStr(userAttDaily.getDouble("HoliAcD"),"hh")+" /"+AttendUtils.convertSecToStr(userAttDaily.getDouble("HoliAcN"),"hh");
						}
					}else {
						holiAcDN = bOutputNumtype?String.valueOf((int) userAttDaily.getDouble("HoliAc")):AttendUtils.convertSecToStr(userAttDaily.getDouble("HoliAc"),"H");
					}
					userAttDaily.put("HoliAcDN_F", holiAcDN);

					int attAcN = (int) userAttDaily.getDouble("AttAcN") + (int) userAttDaily.getDouble("HoliAcN") +(int) userAttDaily.getDouble("ExtenAcN");
					String vTotWorkTime_F = "";
					int totWorkTime = (int) userAttDaily.getDouble("TotWorkTime");
					if(printDN){
						int totWorkTimeD = totWorkTime - attAcN;
						if(totWorkTimeD>0 || attAcN>0){
							vTotWorkTime_F = AttendUtils.convertSecToStr(totWorkTimeD,"hh")+" /"+AttendUtils.convertSecToStr(attAcN,"hh");
						}
					}else {
						vTotWorkTime_F = bOutputNumtype?String.valueOf(totWorkTime):AttendUtils.convertSecToStr(totWorkTime,"H");
					}
					userAttDaily.put("TotWorkTime_F", vTotWorkTime_F);
					//userAttDaily.put("TotRealWorkTime_F", AttendUtils.convertSecToStr(userAttDaily.get("AttRealTime").toString(),"H"));
					String vTotConfWorkTime_F = "";
					int attRealConfTime = (int) userAttDaily.getDouble("AttRealConfTime");
					if(printDN){
						int attRealConfTimeD = attRealConfTime - attAcN;
						if(attRealConfTimeD>0 || attAcN>0){
							vTotConfWorkTime_F = AttendUtils.convertSecToStr(attRealConfTimeD,"hh")+" /"+AttendUtils.convertSecToStr(attAcN,"hh");
						}
					}else {
						vTotConfWorkTime_F = bOutputNumtype?String.valueOf(attRealConfTime):AttendUtils.convertSecToStr(attRealConfTime,"H");
					}
					userAttDaily.put("TotConfWorkTime_F", vTotConfWorkTime_F);
					//userAttDaily.put("TotAcWorkTime_F", AttendUtils.convertSecToStr(userAttDaily.get("AttAc").toString(),"H"));
					//userAttDaily.put("RemainTime_F", AttendUtils.convertSecToStr(userAttDaily.get("RemainTime").toString(),"H"));
					String vAttRealTime_F = "";
					int attRealTime = (int) userAttDaily.getDouble("AttRealTime");
					if(printDN){
						int attRealTimeD = attRealTime - attAcN;
						if(attRealTimeD>0 || attAcN>0){
							vAttRealTime_F = AttendUtils.convertSecToStr(attRealTimeD,"hh")+" /"+AttendUtils.convertSecToStr(attAcN,"hh");
						}
					}else {
						vAttRealTime_F = bOutputNumtype?String.valueOf(attRealTime):AttendUtils.convertSecToStr(attRealTime,"H");
					}

					String monthlyAttAcSum =  AttendUtils.convertSecToStr(userAttDaily.get("MonthlyAttAcSum").toString(),"H");
					userAttDaily.put("MonthlyAttAcSum_F", monthlyAttAcSum);

					userAttDaily.put("AttRealTime_F", vAttRealTime_F);

					userAttDaily.put("DataType", "DailyData");

					userAttDailyList.add(userAttDaily);
				}//end loop a week

				//주단위
				CoviMap userAttWeekly = getUserAttWorkWithDayAndNightTimeProc(userAtt.getString("UserCode"), CompanyCode, key, value);
				userAttWeekly.put("DataType", "WeeklyTotal");
				userAttWeekly.put("ExtenAc_F", AttendUtils.convertSecToStr(userAttWeekly.get("ExtenAc").toString(),"H"));
				String extenAcD = AttendUtils.convertSecToStr(userAttWeekly.getDouble("ExtenAcD"),"H");
				String extenAcN = AttendUtils.convertSecToStr(userAttWeekly.getDouble("ExtenAcN"),"H");
				String extenAcDN = "";
				if(printDN){
					if(!extenAcD.equals("") || !extenAcN.equals("")){
						extenAcDN = AttendUtils.convertSecToStr(userAttWeekly.getDouble("ExtenAcD"),"hh")+" /"+AttendUtils.convertSecToStr(userAttWeekly.getDouble("ExtenAcN"),"hh");
					}
				}else {
					extenAcDN = bOutputNumtype?String.valueOf((int) userAttWeekly.getDouble("ExtenAc")):AttendUtils.convertSecToStr(userAttWeekly.getDouble("ExtenAc"),"H");
				}
				userAttWeekly.put("ExtenAcDN_F", extenAcDN);
				userAttWeekly.put("HoliAc_F", AttendUtils.convertSecToStr(userAttWeekly.get("HoliAc").toString(),"H"));
				String holiAcD = AttendUtils.convertSecToStr(userAttWeekly.getDouble("HoliAcD"),"H");
				String holiAcN = AttendUtils.convertSecToStr(userAttWeekly.getDouble("HoliAcN"),"H");
				String holiAcDN = "";
				if(printDN){
					if(!holiAcD.equals("") || !holiAcN.equals("")){
						holiAcDN = AttendUtils.convertSecToStr(userAttWeekly.getDouble("HoliAcD"),"hh")+" /"+AttendUtils.convertSecToStr(userAttWeekly.getDouble("HoliAcN"),"hh");
					}
				}else {
					holiAcDN = bOutputNumtype?String.valueOf((int) userAttWeekly.getDouble("HoliAc")):AttendUtils.convertSecToStr(userAttWeekly.getDouble("HoliAc"),"H");
				}
				userAttWeekly.put("HoliAcDN_F", holiAcDN);

				int attAcN = (int) userAttWeekly.getDouble("AttAcN") + (int) userAttWeekly.getDouble("ExtenAcN") + (int) userAttWeekly.getDouble("HoliAcN");
				String vTotWorkTime_F = "";
				int totWorkTime = (int) userAttWeekly.getDouble("TotWorkTime");
				if(printDN){
					int totWorkTimeD = totWorkTime - attAcN;
					if(totWorkTimeD>0 || attAcN>0){
						vTotWorkTime_F = AttendUtils.convertSecToStr(totWorkTimeD,"hh")+" /"+AttendUtils.convertSecToStr(attAcN,"hh");
					}
				}else {
					vTotWorkTime_F = bOutputNumtype?String.valueOf(totWorkTime):AttendUtils.convertSecToStr(totWorkTime,"H");
				}
				userAttWeekly.put("TotWorkTime_F", vTotWorkTime_F);
				//시간 초과 미만 체크 모드시
				if(weeklyOverUnderMode){
					if(weeklyWorkType.equals("over") && Integer.parseInt(weeklyWorkValue) < totWorkTime){
						checkCnt++;
					}else if(weeklyWorkType.equals("under") && Integer.parseInt(weeklyWorkValue) >= totWorkTime){
						checkCnt++;
					}
				}
				//userAttWeekly.put("TotRealWorkTime_F", AttendUtils.convertSecToStr(userAttWeekly.get("TotRealWorkTime").toString(),"H"));
				String vTotConfWorkTime_F = "";
				int totConfWorkTime = (int) userAttWeekly.getDouble("TotConfWorkTime");
				if(printDN){
					int totConfWorkTimeD = totConfWorkTime - attAcN;
					if(totConfWorkTimeD>0 || attAcN>0){
						vTotConfWorkTime_F = AttendUtils.convertSecToStr(totConfWorkTimeD,"hh")+" /"+AttendUtils.convertSecToStr(attAcN,"hh");
					}
				}else {
					vTotConfWorkTime_F = bOutputNumtype?String.valueOf(totConfWorkTime):AttendUtils.convertSecToStr(totConfWorkTime,"H");
				}
				userAttWeekly.put("TotConfWorkTime_F", vTotConfWorkTime_F);
				//userAttWeekly.put("TotAcWorkTime_F", AttendUtils.convertSecToStr(userAttWeekly.get("TotAcWorkTime").toString(),"H"));
				//userAttWeekly.put("RemainTime_F", AttendUtils.convertSecToStr(userAttWeekly.get("RemainTime").toString(),"H"));
				String vAttRealTime_F = "";
				int attRealTime = (int) userAttWeekly.getDouble("AttRealTime");
				if(printDN){
					int attRealTimeD = attRealTime - attAcN;
					if(attRealTime>0 || attAcN>0){
						vAttRealTime_F = AttendUtils.convertSecToStr(attRealTimeD,"hh")+" /"+AttendUtils.convertSecToStr(attAcN,"hh");
					}
				}else {
					vAttRealTime_F = bOutputNumtype?String.valueOf(totConfWorkTime):AttendUtils.convertSecToStr(totConfWorkTime,"H");
				}
				userAttWeekly.put("AttRealTime_F", vAttRealTime_F);
				userAttDailyList.add(userAttWeekly);

				//헤더용 날일 정보 넣기
				if(i==0) {
					CoviMap eHColDay = new CoviMap();
					eHColDay.put("DataType", "WeeklyTotal");
					eHColDay.put("Idx", hIdx);
					eHColDay.put("WeekNum",String.valueOf(WeeksNum.get(k)));
					eHColDay.put("DayOfWeek",-1);
					eHColDay.put("DD","합계");
					eHColDayList.add(eHColDay);

					eHCol.put("eHColDayList", eHColDayList);
					eHColList.add(eHCol);
				}
			}//end for range weekly

			if(checkCnt>0||!weeklyOverUnderMode) {//초과 미만 시간 모드 포암 안될시 다음 사용자로 next.
				userAtt.put("userAttDaily", userAttDailyList);
			}else{
				continue;
			}

			//해당 사용자에 대한 전체 근태 정보 추출
			if (incld_weeks) {
				userAttWorkTotalTime = getUserAttWorkWithDayAndNightTimeProc(userAtt.getString("UserCode"), CompanyCode, rangeStartDate, rangeEndDate);
			} else {
				userAttWorkTotalTime = getUserAttWorkWithDayAndNightTimeProc(userAtt.getString("UserCode"), CompanyCode, sDate, eDate);
			}
			//userAttWorkTotalTime.put("ExtenAc_F", AttendUtils.convertSecToStr(userAttWorkTotalTime.get("ExtenAc").toString(),"H"));
			String extenAcD = AttendUtils.convertSecToStr(userAttWorkTotalTime.getDouble("ExtenAcD"),"H");
			String extenAcN = AttendUtils.convertSecToStr(userAttWorkTotalTime.getDouble("ExtenAcN"),"H");
			String extenAcDN = "";
			if(printDN){
				if(!extenAcD.equals("") || !extenAcN.equals("")){
					extenAcDN = AttendUtils.convertSecToStr(userAttWorkTotalTime.getDouble("ExtenAcD"),"hh")+" /"+AttendUtils.convertSecToStr(userAttWorkTotalTime.getDouble("ExtenAcN"),"hh");
				}
			}else {
				extenAcDN = bOutputNumtype?String.valueOf((int) userAttWorkTotalTime.getDouble("ExtenAc")):AttendUtils.convertSecToStr(userAttWorkTotalTime.getDouble("ExtenAc"),"H");
			}
			userAttWorkTotalTime.put("ExtenAcDN_F", extenAcDN);
			//userAttWorkTotalTime.put("HoliAc_F", AttendUtils.convertSecToStr(userAttWorkTotalTime.get("HoliAc").toString(),"H"));
			String holiAcD = AttendUtils.convertSecToStr(userAttWorkTotalTime.getDouble("HoliAcD"),"H");
			String holiAcN = AttendUtils.convertSecToStr(userAttWorkTotalTime.getDouble("HoliAcN"),"H");
			String holiAcDN = "";
			if(printDN){
				if(!holiAcD.equals("") || !holiAcN.equals("")){
					holiAcDN = AttendUtils.convertSecToStr(userAttWorkTotalTime.getDouble("HoliAcD"),"hh")+" /"+AttendUtils.convertSecToStr(userAttWorkTotalTime.getDouble("HoliAcN"),"hh");
				}
			}else {
				holiAcDN = bOutputNumtype?String.valueOf((int) userAttWorkTotalTime.getDouble("HoliAc")):AttendUtils.convertSecToStr(userAttWorkTotalTime.getDouble("HoliAc"),"H");
			}
			userAttWorkTotalTime.put("HoliAcDN_F", holiAcDN);

			int attAcN = (int) userAttWorkTotalTime.getDouble("AttAcN") + (int) userAttWorkTotalTime.getDouble("ExtenAcN") + (int) userAttWorkTotalTime.getDouble("HoliAcN");
			String vTotWorkTime_F = "";
			int totWorkTime = (int) userAttWorkTotalTime.getDouble("TotWorkTime");
			if(printDN){
				int totWorkTimeD = totWorkTime - attAcN;
				if(totWorkTimeD>0 || attAcN>0){
					vTotWorkTime_F = AttendUtils.convertSecToStr(totWorkTimeD,"hh")+" /"+AttendUtils.convertSecToStr(attAcN,"hh");
				}
			}else {
				vTotWorkTime_F = bOutputNumtype?String.valueOf(totWorkTime):AttendUtils.convertSecToStr(totWorkTime,"H");
			}
			userAttWorkTotalTime.put("TotWorkTime_F", vTotWorkTime_F);

			int avgWorkTime = totWorkTime/listRangeFronToDate.size();
			String vAvgWorkTime_F = bOutputNumtype?String.valueOf(avgWorkTime):AttendUtils.convertSecToStr(avgWorkTime,"H");
			userAttWorkTotalTime.put("AvgWorkTime_F", vAvgWorkTime_F);

			//userAttWorkTotalTime.put("TotRealWorkTime_F", AttendUtils.convertSecToStr(userAttWorkTotalTime.get("TotRealWorkTime").toString(),"H"));
			String vTotConfWorkTime_F = "";
			int totConfWorkTime = (int) userAttWorkTotalTime.getDouble("TotConfWorkTime");
			if(printDN){
				int totConfWorkTimeD = totConfWorkTime - attAcN;
				if(totConfWorkTimeD>0 || attAcN>0){
					vTotConfWorkTime_F = AttendUtils.convertSecToStr(totConfWorkTimeD,"hh")+" /"+AttendUtils.convertSecToStr(attAcN,"hh");
				}
			}else {
				vTotConfWorkTime_F = bOutputNumtype?String.valueOf(totConfWorkTime):AttendUtils.convertSecToStr(totConfWorkTime,"H");
			}
			userAttWorkTotalTime.put("TotConfWorkTime_F", vTotConfWorkTime_F);
			//userAttWorkTotalTime.put("TotAcWorkTime_F", AttendUtils.convertSecToStr(userAttWorkTotalTime.get("TotAcWorkTime").toString(),"H"));
			//userAttWorkTotalTime.put("RemainTime_F", AttendUtils.convertSecToStr(userAttWorkTotalTime.get("RemainTime").toString(),"H"));
			String vAttRealTime_F = "";
			int attRealTime = (int) userAttWorkTotalTime.getDouble("AttRealTime");
			if(printDN){
				int attRealTimeD = attRealTime - attAcN;
				if(attRealTime>0 || attAcN>0){
					vAttRealTime_F = AttendUtils.convertSecToStr(attRealTimeD,"hh")+" /"+AttendUtils.convertSecToStr(attAcN,"hh");
				}
			}else {
				vAttRealTime_F = bOutputNumtype?String.valueOf(totConfWorkTime):AttendUtils.convertSecToStr(totConfWorkTime,"H");
			}
			userAttWorkTotalTime.put("AttRealTime_F", vAttRealTime_F);
			userAtt.addAll(userAttWorkTotalTime);
			userAttList.add(userAtt);

		}

		CoviMap coviMap = new CoviMap();
		returnMap.addAll(coviMap);
		returnMap.put("userAtt", userAttList);
		returnMap.put("dayTitleMonth", dayTitleMonth);
		returnMap.put("WeeksNum", WeeksNum);
		returnMap.put("excelHCol", eHColList);
		returnMap.put("listRangeFronToDate", listRangeFronToDate);
		returnMap.put("sDate", informat.format(date_Startdate));
		returnMap.put("eDate", informat.format(date_Enddate));

		return returnMap;
	}

	@Override
	public CoviMap getUserAttendanceDailyViewerExcelDataDetail(CoviMap params) throws Exception {
		boolean incld_weeks = Boolean.parseBoolean(params.getString("incld_weeks"));
		CoviMap returnMap = new CoviMap();
		String dayTitleMonth = "";
		SimpleDateFormat sdfMonth = new SimpleDateFormat("yyyy.MM");
		SimpleDateFormat informat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
		/*검색일*/
		String DateTerm = params.getString("DateTerm");
		String TargetDate = params.getString("TargetDate");
		String StartDate = params.getString("StartDate");
		String EndDate = params.getString("EndDate");
		String p_StartDate = params.getString("p_StartDate");
		String p_EndDate = params.getString("p_EndDate");
		String CompanyCode = params.getString("CompanyCode");
		boolean bOutputNumtype = false;
		if(params.getString("outputNumtype").equals("Y")){
			bOutputNumtype = true;
		}
		boolean printDN = Boolean.parseBoolean(params.getString("printDN"));
		Date dateTitleMonth = new Date();
		if (TargetDate.contains("-")) {
			dateTitleMonth = informat.parse(TargetDate);
		} else {
			dateTitleMonth = format.parse(TargetDate);
		}
		dayTitleMonth = sdfMonth.format(dateTitleMonth);
		String sDate;
		String eDate;
		sDate = StartDate.replaceAll("-", "").substring(0,8);
		Date date_Startdate = format.parse(sDate);
		eDate = EndDate.replaceAll("-", "").substring(0,8);

		Calendar Cal = Calendar.getInstance();
		Calendar CalStart = Calendar.getInstance();
		Calendar CalEnd = Calendar.getInstance();

		Cal.setTime(date_Startdate);
		Cal.add(Calendar.DATE, -1);
		String p_sDate = format.format(Cal.getTime());
		returnMap.put("p_sDate", p_sDate);
		Date date_Enddate = format.parse(eDate);
		Cal.setTime(date_Enddate);
		Cal.add(Calendar.DATE, +1);
		String p_eDate = format.format(Cal.getTime());
		returnMap.put("p_eDate", p_eDate);
		/*검색일 end*/
		//월별 주단위 날짜 정보 확인
		CoviList clMonthlyInfo = new CoviList();
		CoviMap reqParam = new CoviMap();
		reqParam.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqParam.put("DomainCode", SessionHelper.getSession("DN_ID"));
		reqParam.put("StartDate", StartDate);
		reqParam.put("EndDate", EndDate);
		int thisYear = Integer.parseInt(sDate.substring(0, 4));
		int lastYear = thisYear - 1;
		reqParam.put("ThisYear", thisYear);
		reqParam.put("LastYear", lastYear);
		clMonthlyInfo = coviMapperOne.list("attend.job.getJobViewMonthlyInfo", reqParam);
		CoviList jObjMonthlyInfo = CoviSelectSet.coviSelectJSON(clMonthlyInfo, "StartDate,StartWeekNum,EndDate,EndWeekNum,ThisYearWeeksNum,LastYearWeeksNum");

		int sweeknum = 0;
		int eweeknum = 0;
		int loopnum = 0;
		int snum = 0;
		int colNumWeeks = 0;
		String rangeStartDate = "";
		String rangeEndDate = "";
		int LastYearWeeksNum = 52;

		String schStartDate = "";

		if (jObjMonthlyInfo.size() > 0) {
			int i = 0;
			while (i < jObjMonthlyInfo.size()) {
				rangeStartDate = ((CoviMap) jObjMonthlyInfo.get(i)).getString("StartDate");
				rangeEndDate = ((CoviMap) jObjMonthlyInfo.get(i)).getString("EndDate");
				//2021.12.30 dbms 별 주차 계산 로직 상이로 자바 날짜 계산로직기준으로 주차 계산 처리 공통화
				String[] arrRangeStartDate = rangeStartDate.split("-");
				String[] arrRangeEndDate   = rangeEndDate.split("-");
				//System.out.println("#####arrRangeStartDate:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(arrRangeStartDate));
				//System.out.println("#####arrRangeEndDate:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(arrRangeEndDate));

				int rangeStartWeeksNum = AttendUtils.getCurrentWeekOfYear(
						Integer.parseInt(arrRangeStartDate[0])
						,Integer.parseInt(arrRangeStartDate[1])
						,Integer.parseInt(arrRangeStartDate[2])
				);
				//System.out.println("#####rangeStartWeeksNum:"+rangeStartWeeksNum);

				int rangeEndWeeksNum = AttendUtils.getCurrentWeekOfYear(
						Integer.parseInt(arrRangeEndDate[0])
						,Integer.parseInt(arrRangeEndDate[1])
						,Integer.parseInt(arrRangeEndDate[2])
				);
				//System.out.println("#####rangeEndWeeksNum:"+rangeEndWeeksNum);

				sweeknum = rangeStartWeeksNum;
				eweeknum = rangeEndWeeksNum;
				schStartDate = rangeStartDate;
				LastYearWeeksNum = AttendUtils.getMaxWeekOfYear(lastYear);
				//System.out.println("#####LastYearWeeksNum:"+LastYearWeeksNum);
				snum = sweeknum;
				i++;
			}
		}
		if (eweeknum > sweeknum) {
			loopnum = eweeknum - sweeknum;
		} else {//년도 바뀌면 52주 더해서 주차 구함
			loopnum = (eweeknum + LastYearWeeksNum) - sweeknum;
		}
		List<Map<String, String>> listRangeFronToDate = new ArrayList<>();
		List WeeksNum = new ArrayList();
//		List WeeksCnt = new ArrayList();
		int tLoop = snum + loopnum;
		int newYearCnt = 1;
		SimpleDateFormat beforeFormat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat afterFormat = new SimpleDateFormat("yyyyMMdd");
		Date Sdate = null;
		Date Edate = null;
		Calendar CalpStart = Calendar.getInstance();
		Calendar CalpEnd = Calendar.getInstance();
		Sdate = beforeFormat.parse(schStartDate);
		Date ckEdate = informat.parse(EndDate);
		int weekOver = 0;
		for (int i = snum; i <= tLoop; i++) {
			Cal.setTime(Sdate);
			if (!incld_weeks && i == snum && !p_StartDate.equals("")){//주단위 체크 해제시 해당 주일자 체크 로직
				Date pStartDate = informat.parse(p_StartDate);
				CalpStart.setTime(pStartDate);
				Date oriStartDate = informat.parse(StartDate);
				CalpEnd.setTime(oriStartDate);
				long rngDiff = CalpEnd.getTimeInMillis() - CalpStart.getTimeInMillis();
				long rngDiffDays = rngDiff / (24 * 60 * 60 * 1000);
				int rngDiffDayInt = 6 - (Math.toIntExact(rngDiffDays));

				Cal.add(Calendar.DAY_OF_MONTH, rngDiffDayInt);
			}else{
				Cal.add(Calendar.DAY_OF_MONTH, 6);
			}
			Edate = Cal.getTime();

			Map<String, String> newRange = new HashMap<>();
			if (!incld_weeks && i == snum){
				newRange.put(sDate, afterFormat.format(Edate));
			}else if (!incld_weeks && i == tLoop){
				newRange.put(afterFormat.format(Sdate), eDate);
			}else{
				if(weekOver>0){
					break;
				}
				newRange.put(afterFormat.format(Sdate), afterFormat.format(Edate));
				if(p_eDate.substring(0,6).equals(afterFormat.format(Edate).substring(0,6))){
					weekOver++;
				}
			}

			if(ckEdate.getTime()>=Edate.getTime() || (ckEdate.getTime()-Edate.getTime())>(6*24*60*60*1000*-1)) {
				listRangeFronToDate.add(newRange);
			}else{
				break;
			}

			Cal.setTime(Edate);
			Cal.add(Calendar.DAY_OF_MONTH, 1);
			Sdate = Cal.getTime();

			if(i<=LastYearWeeksNum) {
				WeeksNum.add(i);

			}else{
				WeeksNum.add(newYearCnt);
				newYearCnt++;
			}
//			WeeksCnt.add(colNumWeeks);
			colNumWeeks++;
		}
		//-->

		CoviList userCodeList = (CoviList) params.get("userCodeList");

		String _commuteTimeYn = RedisDataUtil.getBaseConfig("CommuteTimeYn");
		String weeklyWorkValue = params.getString("weeklyWorkValue");
		String weeklyWorkType  = params.getString("weeklyWorkType");
		boolean weeklyOverUnderMode = false;
		if(!weeklyWorkValue.equals("") && !weeklyWorkValue.equals("0")){
			weeklyWorkValue = String.valueOf(Integer.parseInt(weeklyWorkValue) * 60);
			weeklyOverUnderMode = true;
		}
		CoviList userAttList = getUserAttStatusDaily(userCodeList, CompanyCode, listRangeFronToDate, WeeksNum, weeklyWorkValue, weeklyWorkType);

		CoviList userAttListRender = new CoviList();

		String userCodeCk = "";
		CoviList jobHisList = new CoviList();
		for(int i=0;i<userAttList.size();i++){
			CoviMap userAtt = userAttList.getMap(i);
			if(!userCodeCk.equals(userAtt.getString("UserCode"))){
				userCodeCk = userAtt.getString("UserCode");
				//기타근무상태
				CoviMap jobHisParmas = new CoviMap();
				jobHisParmas.put("lang",  SessionHelper.getSession("lang"));
				jobHisParmas.put("UserCode", userAtt.getString("UserCode"));
				jobHisParmas.put("CompanyCode", CompanyCode);
				jobHisParmas.put("StartDate", sDate);
				jobHisParmas.put("EndDate", eDate);
				jobHisList = getUserJobHistory(jobHisParmas);
			}

			//날짜별 주차정보 추가
			for(int k=0;k<listRangeFronToDate.size();k++){
				Map<String, String> rangeDate = listRangeFronToDate.get(k);
				String key = rangeDate.keySet().toString().replace("[","").replace("]","");
				String value = rangeDate.get(key);

				//주단위 내에서 일단위조회 처리
				Map WeekInfoMap = new HashMap();
				Date daily_rangeDate = informat.parse(userAtt.getString("dayList"));
				Cal.setTime(daily_rangeDate);

				Date rngStartDate = format.parse(key);
				CalStart.setTime(rngStartDate);
				Date rngEndDate = format.parse(value);
				CalEnd.setTime(rngEndDate);
				CalEnd.add(Calendar.DATE, +1);
				CalEnd.add(Calendar.SECOND, -1);
				//
				if(CalStart.getTimeInMillis()<=Cal.getTimeInMillis() && CalEnd.getTimeInMillis()>=Cal.getTimeInMillis()) {
					//일별데이터내에 주차수 넣기
					WeekInfoMap.put("WeekNum", String.valueOf(WeeksNum.get(k)));
					WeekInfoMap.put("DayOfWeek", Cal.get(Calendar.DAY_OF_WEEK));
					userAtt.addAll(WeekInfoMap);
					break;
				}
			}

			//시작 출근 퇴근 상태
			int spNum = 10;
			String schName = userAtt.getString("SchName");
			if(schName == null) {
				schName = "";
			}else {
				schName = schName.length() > spNum ? schName.substring(0, spNum) + ".." : schName;
			}
			String startDt = "";
			String startDd ="";
			String endDt = "";
			String endDd = "";

			startDt = schName;	//근무제
			startDd = userAtt.get("v_AttDayStartTime")!=null?userAtt.getString("v_AttDayStartTime"):"";	//출근일정시간
			if(userAtt.get("StartSts")!=null){
				if(userAtt.getString("StartSts").equals("lbl_n_att_absent")){	//결근
					startDt = DicHelper.getDic("lbl_n_att_absent");
				}else if(userAtt.getString("StartSts").equals("lbl_n_att_callingTarget")){ //소명
					startDt = DicHelper.getDic("lbl_n_att_callingTarget");
				}else if(userAtt.getString("StartSts").equals("lbl_att_beingLate")){	//지각
					startDt = DicHelper.getDic("lbl_att_beingLate");
					startDd = userAtt.getString("v_AttStartTime");	//출근시간
				}

				if(_commuteTimeYn.equals("Y")){
					startDd = "";
				}
			}

			endDt = schName;	//근무제
			endDd = !userAtt.getString("v_AttDayEndTime").equals("")?userAtt.getString("v_AttDayEndTime"):"";	//출근일정시간
			if(userAtt.get("EndSts")!=null){
				if(userAtt.getString("EndSts").equals("lbl_n_att_absent")){	//결근
					endDt = DicHelper.getDic("lbl_n_att_absent");
				}else if(userAtt.getString("EndSts").equals("lbl_n_att_callingTarget")){ //소명
					endDt = DicHelper.getDic("lbl_n_att_callingTarget");
				}else if(userAtt.getString("EndSts").equals("lbl_att_leaveErly")){	//조퇴
					endDt = DicHelper.getDic("lbl_att_leaveErly");
					endDd = userAtt.getString("v_AttEndTime");	//퇴근시간
				}
				if(_commuteTimeYn.equals("Y")){
					endDd = "";
				}
			}

			//연장 근무
			if(userAtt.get("ExtenAc")!=null && userAtt.getInt("ExtenAc")>0){
				endDt = DicHelper.getDic("lbl_att_overtime_work");
				endDd = AttendUtils.maskTime(userAtt.getString("v_ExtenEndTime"));
			}


			//휴무일
			if(userAtt.get("WorkSts")!=null && (userAtt.get("WorkSts").toString().equals("OFF") || userAtt.get("WorkSts").toString().equals("HOL"))){
				startDt = userAtt.get("WorkSts").toString().equals("OFF")? DicHelper.getDic("lbl_att_sch_holiday"):DicHelper.getDic("lbl_Holiday");
				startDd = "";

				endDt = userAtt.get("WorkSts").toString().equals("OFF") ? DicHelper.getDic("lbl_att_sch_holiday"):DicHelper.getDic("lbl_Holiday");
				endDd = "";
			}
			//휴가
			if(userAtt.get("VacFlag") != null && !userAtt.get("VacFlag").toString().equals("")){
				//연차종류
				//반차
				if(userAtt.getInt("VacCnt")  == 1){
					startDt = AttendUtils.vacNameConvertor(userAtt.getString("VacOffFlag")
							,userAtt.getString("VacCodeName")
							,"AM", 0);
					startDd = "";
					endDt = AttendUtils.vacNameConvertor(userAtt.getString("VacOffFlag")
							,userAtt.getString("VacCodeName")
							,"PM", 0);
					endDd = "";
				}else{
					String vacAmPmVacDay = userAtt.getString("VacAmPmVacDay");
					String[] arrVacAmPmVacDay = null;
					if(vacAmPmVacDay.contains("|")) {
						arrVacAmPmVacDay = vacAmPmVacDay.split("\\|");
					}else {
						arrVacAmPmVacDay = new String[]{vacAmPmVacDay};
					}
					if(userAtt.getString("VacOffFlag").contains("AM") && Double.parseDouble(arrVacAmPmVacDay[0])==0.5){
						startDt = AttendUtils.vacNameConvertor(userAtt.getString("VacOffFlag")
								,userAtt.getString("VacCodeName")
								,"AM", 0) + (!startDt.equals("") && !userAtt.getString("StartSts").equals("lbl_att_normal_goWork")? "("+ startDt +")":"");
					}
					if(userAtt.getString("VacOffFlag").contains("PM") && Double.parseDouble(arrVacAmPmVacDay[1])==0.5){
						endDt = AttendUtils.vacNameConvertor(userAtt.getString("VacOffFlag")
									,userAtt.getString("VacCodeName")
									,"PM", 0)
								+ (!endDt.equals("") && !userAtt.getString("EndSts").equals("lbl_att_normal_offWork")? "("+ endDt +")":"");
					}
				}

			}

			userAtt.put("startDt", startDt);
			userAtt.put("startDd", startDd);
			userAtt.put("endDt", endDt);
			userAtt.put("endDd", endDd);
			//끝 출근 퇴근 상태 -->
			//데이터 가공
			int totWorkTime = (int) userAtt.getDouble("TotWorkTime");
			userAtt.put("TotWorkTime_F", bOutputNumtype?totWorkTime:AttendUtils.convertSecToStr(totWorkTime,"H"));
			int attAcN = (int) userAtt.getDouble("AttAcN")+(int) userAtt.getDouble("ExtenAcN")+(int) userAtt.getDouble("HoliAcD");
			int totWorkDTime = totWorkTime - attAcN;
			userAtt.put("TotWorkTimeD_F", bOutputNumtype?totWorkDTime:AttendUtils.convertSecToStr(totWorkDTime,"H"));
			userAtt.put("TotWorkTimeN_F", bOutputNumtype?attAcN:AttendUtils.convertSecToStr(attAcN,"H"));

			int attRealTime = (int) userAtt.getDouble("AttRealTime");
			userAtt.put("AttRealTime_F", bOutputNumtype?attRealTime:AttendUtils.convertSecToStr(attRealTime,"H"));
			int attRealDTime = attRealTime - attAcN;
			userAtt.put("AttRealDTime_F", bOutputNumtype?attRealDTime:AttendUtils.convertSecToStr(attRealDTime,"H"));
			userAtt.put("AttRealNTime_F", bOutputNumtype?attAcN:AttendUtils.convertSecToStr(attAcN,"H"));

			userAtt.put("ExtenAc_F", bOutputNumtype?(int) userAtt.getDouble("ExtenAc"):AttendUtils.convertSecToStr(userAtt.getDouble("ExtenAc"),"H"));
			userAtt.put("ExtenAcD_F", bOutputNumtype?(int) userAtt.getDouble("ExtenAcD"):AttendUtils.convertSecToStr(userAtt.getDouble("ExtenAcD"),"H"));
			userAtt.put("ExtenAcN_F", bOutputNumtype?(int) userAtt.getDouble("ExtenAcN"):AttendUtils.convertSecToStr(userAtt.getDouble("ExtenAcN"),"H"));

			userAtt.put("HoliAc_F", bOutputNumtype?(int) userAtt.getDouble("HoliAc"):AttendUtils.convertSecToStr(userAtt.getDouble("HoliAc"),"H"));
			userAtt.put("HoliAcD_F", bOutputNumtype?(int) userAtt.getDouble("HoliAcD"):AttendUtils.convertSecToStr(userAtt.getDouble("HoliAcD"),"H"));
			userAtt.put("HoliAcN_F", bOutputNumtype?(int) userAtt.getDouble("HoliAcN"):AttendUtils.convertSecToStr(userAtt.getDouble("HoliAcN"),"H"));

			userAtt.put("MonthlyAttAcSum_F", bOutputNumtype?userAtt.get("MonthlyAttAcSum"):AttendUtils.convertSecToStr(userAtt.get("MonthlyAttAcSum"),"H"));

			String startPointX = userAtt.getString("StartPointX");
			String startPointY = userAtt.getString("StartPointY");
			String endPointX = userAtt.getString("EndPointX");
			String endPointY = userAtt.getString("EndPointY");
			String startGps = "";
			String endGps = "";
			if(startPointX!=null&&!startPointX.equals("")&&startPointY!=null&&!startPointY.equals("")){
				startGps = "Y";
			}
			if(endPointX!=null&&!endPointX.equals("")&&endPointY!=null&&!endPointY.equals("")){
				endGps = "Y";
			}
			userAtt.put("StartGps", startGps);
			userAtt.put("EndGps", endGps);

			String dayList = userAtt.getString("dayList");

			String jobSts = "";
			StringBuffer buf = new StringBuffer();
			for(int j=0;j<jobHisList.size();j++){
				CoviMap jobHisObj = jobHisList.getMap(j);
				String jobDate = jobHisObj.getString("JobDate");
				if(dayList.equals(jobDate)){
					if(!"".equals(jobSts)){
						buf.append(",");
					}
					//jobSts += jobHisObj.getString("JobStsName") + "["+jobHisObj.getString("v_StartTime")+"~"+jobHisObj.getString("v_EndTime")+"]";
					buf.append(jobHisObj.getString("JobStsName")).append("[").append(jobHisObj.getString("v_StartTime")).append("~").append(jobHisObj.getString("v_EndTime")).append("]");
				}
			}
			jobSts= buf.toString();
			userAtt.put("JobStatus", jobSts);


			userAttListRender.add(userAtt);
		}
		CoviList tempUserAttData = (CoviList) userAttListRender.clone();
		CoviList resultUserAttData = new CoviList();
				//필터 처리 - 시간 초과 미만 체크 모드시
		ArrayList<String> choiceUserCodeArray = new ArrayList<>();
		if(weeklyOverUnderMode){
			for(int i=0;i<userCodeList.size();i++) {
				CoviMap userMap = (CoviMap) userCodeList.get(i);
				String userCode = userMap.getString("UserCode");
				int checkCnt = 0;
				for(int k=0;k<WeeksNum.size();k++) {
					int userTotWorkTime = 0;
					for(int j=0;j<tempUserAttData.size();j++){
						CoviMap dailyMap = (CoviMap) tempUserAttData.get(j);
						if (dailyMap.getString("UserCode").equals(userCode) && dailyMap.getString("WeekNum").equals(String.valueOf(WeeksNum.get(k)))) {
							userTotWorkTime += dailyMap.getInt("TotWorkTime");
							//tempUserAttDat.remove(j);
						}
					}
					if (weeklyWorkType.equals("over") && Integer.parseInt(weeklyWorkValue) < userTotWorkTime) {
						checkCnt++;
						//System.out.println("####userTotWorkTime:"+userCode+"["+k+"]"+userTotWorkTime);
					} else if (weeklyWorkType.equals("under") && Integer.parseInt(weeklyWorkValue) >= userTotWorkTime) {
						checkCnt++;
					}
				}
				if(checkCnt>0) {
					choiceUserCodeArray.add(userCode);
				}

			}
			//System.out.println("####gson:"+new GsonBuilder().setPrettyPrinting().create().toJson(userCodeList));

			for(int i=0;i<choiceUserCodeArray.size();i++) {
				String userCode = choiceUserCodeArray.get(i);
				for(int j=0;j<userAttListRender.size();j++) {
					CoviMap dailyMap = (CoviMap) userAttListRender.get(j);
					if (dailyMap.getString("UserCode").equals(userCode)) {
						//System.out.println("####put:"+j);
						resultUserAttData.add(dailyMap);
					}
				}
			}
			//System.out.println("####gson2:"+new GsonBuilder().setPrettyPrinting().create().toJson(resultUserAttData));
		}else {
			resultUserAttData = (CoviList) userAttListRender.clone();
		}



		returnMap.put("userAttDaily", resultUserAttData);
		returnMap.put("sDate", informat.format(date_Startdate));
		returnMap.put("eDate", informat.format(date_Enddate));

		return returnMap;
	}

	@Override
	public CoviMap getUserAttendanceV2Month(CoviMap params) throws Exception {
		CoviMap returnMap = new CoviMap();
		/*검색일*/
		String CompanyCode = params.getString("CompanyCode");
		String userCode = params.getString("userCode");
		String StartDate = setDayParams(params.getString("DateTerm"), params.getString("TargetDate"), params.getString("CompanyCode")).getString("sDate");
		String EndDate = setDayParams(params.getString("DateTerm"), params.getString("TargetDate"), params.getString("CompanyCode")).getString("eDate");

		CoviMap userAttWorkTime =  getUserAttWorkWithDayAndNightTimeProc(userCode,CompanyCode,StartDate,EndDate);

		returnMap.put("userAttWorkTime", userAttWorkTime);

		return returnMap;
	}

	@Override
	public CoviMap getUserAttendanceV2(CoviMap params) throws Exception {
		CoviMap returnMap = new CoviMap();
		/*검색일*/
		String DateTerm = params.getString("DateTerm");
		String TargetDate = params.getString("TargetDate");
		String CompanyCode = params.getString("CompanyCode");

		String sDate ;
		String eDate ;
		int diffDay ;
		returnMap.addAll(setDayParams(DateTerm,TargetDate,CompanyCode));

		sDate = returnMap.getString("sDate");
		eDate = returnMap.getString("eDate");
		diffDay = returnMap.getInt("dayScopeCnt")+1;

		CoviList userCodeList = (CoviList) params.get("userCodeList");
		CoviList userAttStatus = getUserAttStatusV2(userCodeList, CompanyCode, sDate, eDate);
		CoviList userAttList = new CoviList();

		CoviList tempUserAtt = new CoviList();
		for(int i=0;i<userAttStatus.size();i++){
			CoviMap userAtt = userAttStatus.getMap(i);
			tempUserAtt.add(userAtt);
			if((i+1)%diffDay == 0){
				CoviMap tempMap = new CoviMap();
				tempMap.put("userCode",				userAtt.get("UserCode"));
				tempMap.put("displayName", 			userAtt.get("DisplayName"));
				tempMap.put("jobPositionName",      userAtt.get("JobPositionName"));
				tempMap.put("deptName",             userAtt.get("DeptName"));
				tempMap.put("photoPath",            userAtt.get("PhotoPath"));
				tempMap.put("enterDate",            userAtt.get("EnterDate"));

				tempMap.put("userAttList",tempUserAtt);
				CoviMap userAttWorkTime =  getUserAttWorkWithDayAndNightTimeProc(userAtt.getString("UserCode"),CompanyCode,sDate,eDate);
				tempMap.put("userAttWorkTime",userAttWorkTime);
				userAttList.add(tempMap);
				tempUserAtt = new CoviList();
			}

		}

		//회사 휴무일 리스트 조회
		CoviMap holiParams = new CoviMap();
		holiParams.put("CompanyCode", CompanyCode);
		holiParams.put("StartDate", sDate);
		holiParams.put("EndDate", eDate);
		CoviList holiSchList =  coviMapperOne.list("attend.status.getHolidaySchList", holiParams);

		returnMap.put("userAtt", userAttList);
		returnMap.put("holiSch", holiSchList);

		return returnMap;
	}


	@Override
	public CoviMap getUserAttendanceV2Range(CoviMap params) throws Exception {
		CoviMap returnMap = new CoviMap();
		/*검색일*/
		String DateTerm = params.getString("DateTerm");
		String CompanyCode = params.getString("CompanyCode");

		String sDate = params.getString("StartDate");
		String eDate = params.getString("EndDate");
		String StartDateR = params.getString("StartDateR");
		String EndDateR = params.getString("EndDateR");
		String TargetDate = params.getString("TargetDate");
		returnMap.addAll(setDayParamsWithoutDaylist(DateTerm,TargetDate,CompanyCode));

		CoviList userCodeList = (CoviList) params.get("userCodeList");
		CoviList userAttStatus = getUserAttStatusV2(userCodeList, CompanyCode, sDate, eDate);
		CoviList userAttList = new CoviList();
		CoviList tempUserAtt = new CoviList();
		for(int i=0;i<userAttStatus.size();i++){
			CoviMap userAtt = userAttStatus.getMap(i);
			int weekd = userAtt.getInt("weekd")+1;
			tempUserAtt.add(userAtt);
			if(i == userAttStatus.size()-1){
				CoviMap tempMap = new CoviMap();
				tempMap.put("userCode",				userAtt.get("UserCode"));
				tempMap.put("displayName", 			userAtt.get("DisplayName"));
				tempMap.put("jobPositionName",      userAtt.get("JobPositionName"));
				tempMap.put("deptName",             userAtt.get("DeptName"));
				tempMap.put("photoPath",            userAtt.get("PhotoPath"));
				tempMap.put("enterDate",            userAtt.get("EnterDate"));

				tempMap.put("userAttList",tempUserAtt);
				CoviMap userAttWorkTime =  getUserAttWorkWithDayAndNightTimeProc(userAtt.getString("UserCode"),CompanyCode,StartDateR,EndDateR);
				tempMap.put("userAttWorkTime",userAttWorkTime);
				userAttList.add(tempMap);
				tempUserAtt = new CoviList();
			}

		}

		//회사 휴무일 리스트 조회
		CoviMap holiParams = new CoviMap();
		holiParams.put("CompanyCode", CompanyCode);
		holiParams.put("StartDate", sDate);
		holiParams.put("EndDate", eDate);
		CoviList holiSchList =  coviMapperOne.list("attend.status.getHolidaySchList", holiParams);

		returnMap.put("userAtt", userAttList);
		returnMap.put("holiSch", holiSchList);

		return returnMap;
	}

	@Override
	public CoviMap getMyAttExcelInfoV2(String userCode,String deptCode, String companyCode, String companyId,
									 String startDate, String endDate) throws Exception {
		CoviMap resultMap = new CoviMap();
		CoviList resultList = new CoviList();

		CoviMap params = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("UserCode", userCode);
		params.put("DeptCode", deptCode);
		CoviList userCodeList = new CoviList();
		CoviMap cmap = new CoviMap();
		cmap.put("UserCode", userCode);
		cmap.put("DeptCode", deptCode);
		userCodeList.add(cmap);
		params.put("userCodeList", userCodeList);
		params.put("CompanyCode", companyCode);
		params.put("CompanyId", companyId);
		params.put("StartDate", startDate);
		params.put("EndDate", endDate);
		String DayNightStartTime = RedisDataUtil.getBaseConfig("DayNightStartTime")+"";
		String DayNightEndTime = RedisDataUtil.getBaseConfig("DayNightEndTime")+"";
		if(DayNightStartTime.equals("")){
			DayNightStartTime = RedisDataUtil.getBaseConfig("NightStartTime")+"";
		}
		if(DayNightEndTime.equals("")){
			DayNightEndTime = RedisDataUtil.getBaseConfig("NightEndTime")+"";
		}
		params.put("NightStartDate", DayNightStartTime);
		params.put("NightEndDate", DayNightEndTime);
		params.put("HolNightStartDate", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
		params.put("HolNightEndDate", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
		params.put("ExtNightStartDate", RedisDataUtil.getBaseConfig("NightStartTime"));
		params.put("ExtNightEndDate", RedisDataUtil.getBaseConfig("NightEndTime"));

		CoviList userAttList = coviMapperOne.list("attend.status.getUserAttStatusV2", params);
		CoviList jobHisList = getUserJobHistory(params);

		String _commuteTimeYn = RedisDataUtil.getBaseConfig("CommuteTimeYn");

		for(int i=0;i<userAttList.size();i++){
			CoviMap userAtt = userAttList.getMap(i);

			//시작 출근 퇴근 상태
			int spNum = 10;
			String schName = userAtt.getString("SchName");
			if(schName == null) {
				schName = "";
			}else {
				schName = schName.length() > spNum ? schName.substring(0, spNum) + ".." : schName;
			}
			String startDt = "";
			String startDd ="";
			String endDt = "";
			String endDd = "";

			startDt = schName;	//근무제
			startDd = userAtt.get("v_AttDayStartTime")!=null?userAtt.getString("v_AttDayStartTime"):"";	//출근일정시간
			if(userAtt.get("StartSts")!=null){
				if(userAtt.getString("StartSts").equals("lbl_n_att_absent")){	//결근
					startDt = DicHelper.getDic("lbl_n_att_absent");
				}else if(userAtt.getString("StartSts").equals("lbl_n_att_callingTarget")){ //소명
					startDt = DicHelper.getDic("lbl_n_att_callingTarget");
				}else if(userAtt.getString("StartSts").equals("lbl_att_beingLate")){	//지각
					startDt = DicHelper.getDic("lbl_att_beingLate");
					startDd = userAtt.getString("v_AttStartTime");	//출근시간
				}

				if(_commuteTimeYn.equals("Y")){
					startDd = "";
				}
			}

			endDt = schName;	//근무제
			endDd = !userAtt.getString("v_AttDayEndTime").equals("")?userAtt.getString("v_AttDayEndTime"):"";	//출근일정시간
			if(userAtt.get("EndSts")!=null){

				if(userAtt.getString("EndSts").equals("lbl_n_att_absent")){	//결근
					endDt = DicHelper.getDic("lbl_n_att_absent");
				}else if(userAtt.getString("EndSts").equals("lbl_n_att_callingTarget")){ //소명
					endDt = DicHelper.getDic("lbl_n_att_callingTarget");
				}else if(userAtt.getString("EndSts").equals("lbl_att_leaveErly")){	//조퇴
					endDt = DicHelper.getDic("lbl_att_leaveErly");
					endDd = userAtt.getString("v_AttEndTime");	//퇴근시간
				}
				if(_commuteTimeYn.equals("Y")){
					endDd = "";
				}
			}

			//연장 근무
			if(userAtt.get("ExtenAc")!=null && userAtt.getInt("ExtenAc")>0){
				endDt = DicHelper.getDic("lbl_att_overtime_work");
				endDd = AttendUtils.maskTime(userAtt.getString("v_ExtenEndTime"));
			}


			//휴무일
			if(userAtt.get("WorkSts")!=null && (userAtt.get("WorkSts").toString().equals("OFF") || userAtt.get("WorkSts").toString().equals("HOL"))){
				startDt = userAtt.get("WorkSts").toString().equals("OFF")? DicHelper.getDic("lbl_att_sch_holiday"):DicHelper.getDic("lbl_Holiday");
				startDd = "";

				endDt = userAtt.get("WorkSts").toString().equals("OFF") ? DicHelper.getDic("lbl_att_sch_holiday"):DicHelper.getDic("lbl_Holiday");
				endDd = "";
			}
			//휴가
			if(userAtt.get("VacFlag") != null && !userAtt.get("VacFlag").toString().equals("")){
				//연차종류
				//반차
				if(userAtt.getInt("VacCnt")  == 1){
					startDt = userAtt.getString("VacName");
					startDd = "";
					endDt = userAtt.getString("VacName");
					endDd = "";
				}else{
					if(userAtt.getString("VacOffFlag").contains("AM")){
						startDt = userAtt.getString("VacName") + (!startDt.equals("") && !userAtt.getString("StartSts").equals("lbl_att_normal_goWork")? "("+ startDt +")":"");
					}
					if(userAtt.getString("VacOffFlag").contains("PM")){
						endDt = userAtt.getString("VacName2")  + (!endDt.equals("") && !userAtt.getString("EndSts").equals("lbl_att_normal_offWork")? "("+ endDt +")":"");
					}
				}

			}

			userAtt.put("startDt", startDt);
			userAtt.put("startDd", startDd);
			userAtt.put("endDt", endDt);
			userAtt.put("endDd", endDd);
			//끝 출근 퇴근 상태 -->
			//데이터 가공
			int totWorkTime = userAtt.getInt("TotWorkTime");
			userAtt.put("TotWorkTime_F", AttendUtils.convertSecToStr(totWorkTime,"H"));
			int attAcN = userAtt.getInt("AttAcN") + userAtt.getInt("ExtenAcN") + userAtt.getInt("HoliAcN");
			int totWorkDTime = totWorkTime - attAcN;
			userAtt.put("TotWorkTimeD_F", AttendUtils.convertSecToStr(totWorkDTime,"H"));
			userAtt.put("TotWorkTimeN_F", AttendUtils.convertSecToStr(attAcN,"H"));

			int attRealTime = userAtt.getInt("AttRealTime");
			userAtt.put("AttRealTime_F", AttendUtils.convertSecToStr(attRealTime,"H"));
			int attRealDTime = attRealTime - attAcN;
			userAtt.put("AttRealDTime_F", AttendUtils.convertSecToStr(attRealDTime,"H"));
			userAtt.put("AttRealNTime_F", AttendUtils.convertSecToStr(attAcN,"H"));

			userAtt.put("ExtenAc_F", AttendUtils.convertSecToStr(userAtt.get("ExtenAc"),"H"));
			userAtt.put("ExtenAcD_F", AttendUtils.convertSecToStr(userAtt.get("ExtenAcD"),"H"));
			userAtt.put("ExtenAcN_F", AttendUtils.convertSecToStr(userAtt.get("ExtenAcN"),"H"));

			userAtt.put("HoliAc_F", AttendUtils.convertSecToStr(userAtt.get("HoliAc"),"H"));
			userAtt.put("HoliAcD_F", AttendUtils.convertSecToStr(userAtt.get("HoliAcD"),"H"));
			userAtt.put("HoliAcN_F", AttendUtils.convertSecToStr(userAtt.get("HoliAcN"),"H"));

			//월 누적근무
			userAtt.put("MonthlyAttAcSum_F", AttendUtils.convertSecToStr(userAtt.get("MonthlyAttAcSum"), "H"));

			String startPointX = userAtt.getString("StartPointX");
			String startPointY = userAtt.getString("StartPointY");
			String endPointX = userAtt.getString("EndPointX");
			String endPointY = userAtt.getString("EndPointY");
			String startGps = "";
			String endGps = "";
			if(startPointX!=null&&!startPointX.equals("")&&startPointY!=null&&!startPointY.equals("")){
				startGps = "Y";
			}
			if(endPointX!=null&&!endPointX.equals("")&&endPointY!=null&&!endPointY.equals("")){
				endGps = "Y";
			}
			userAtt.put("StartGps", startGps);
			userAtt.put("EndGps", endGps);

			String dayList = userAtt.getString("dayList");

			String jobSts = "";
			StringBuffer buf = new StringBuffer();
			for(int j=0;j<jobHisList.size();j++){
				CoviMap jobHisObj = jobHisList.getMap(j);
				String jobDate = jobHisObj.getString("JobDate");
				if(dayList.equals(jobDate)){
					if(!"".equals(jobSts)){
						buf.append(",");
					}
					//jobSts += jobHisObj.getString("JobStsName") + "["+jobHisObj.getString("v_StartTime")+"~"+jobHisObj.getString("v_EndTime")+"]";
					buf.append(jobHisObj.getString("JobStsName")).append("[").append(jobHisObj.getString("v_StartTime")).append("~").append(jobHisObj.getString("v_EndTime")).append("]");
				}
			}
			jobSts= buf.toString();
			userAtt.put("JobStatus", jobSts);
			resultList.add(userAtt);
		}
		resultMap.put("StartDate", startDate);
		resultMap.put("EndDate", endDate);
		resultMap.put("list", resultList);

		CoviMap userAttWorkTime =  getUserAttWorkWithDayAndNightTimeProc(userCode,companyCode,startDate,endDate);
		userAttWorkTime.put("TotWorkTime_F", AttendUtils.convertSecToStr(userAttWorkTime.get("TotWorkTime").toString(),"hh"));
		int remainTime = userAttWorkTime.getInt("RemainTime");
		String remainTimeStr = "";
		if(userAttWorkTime.getString("RemainTime") != null && !userAttWorkTime.getString("RemainTime").equals("")) {
			if (remainTime < 0) {
				remainTime = Math.abs(remainTime);
				remainTimeStr = AttendUtils.convertSecToStr(remainTime, "hh") + " 초과";
			} else {
				remainTimeStr = AttendUtils.convertSecToStr(userAttWorkTime.get("RemainTime").toString(), "hh");
			}
		}
		userAttWorkTime.put("RemainTime_F", remainTimeStr);
		userAttWorkTime.put("HoliAc_F", AttendUtils.convertSecToStr(userAttWorkTime.get("HoliAc").toString(),"hh"));
		userAttWorkTime.put("HoliAcD_F", AttendUtils.convertSecToStr(userAttWorkTime.get("HoliAcD").toString(),"hh"));
		userAttWorkTime.put("HoliAcN_F", AttendUtils.convertSecToStr(userAttWorkTime.get("HoliAcN").toString(),"hh"));
		userAttWorkTime.put("ExtenAc_F", AttendUtils.convertSecToStr(userAttWorkTime.get("ExtenAc").toString(),"hh"));
		userAttWorkTime.put("ExtenAcD_F", AttendUtils.convertSecToStr(userAttWorkTime.get("ExtenAcD").toString(),"hh"));
		userAttWorkTime.put("ExtenAcN_F", AttendUtils.convertSecToStr(userAttWorkTime.get("ExtenAcN").toString(),"hh"));
		userAttWorkTime.put("AttRealTime_F", AttendUtils.convertSecToStr(userAttWorkTime.get("AttRealTime").toString(),"hh"));
		int attRealTime = (int) userAttWorkTime.getDouble("AttRealTime");
		int attAcN = userAttWorkTime.getInt("AttAcN") + userAttWorkTime.getInt("ExtenAcN") + userAttWorkTime.getInt("HoliAcN");
		int attRealDTime = attRealTime - attAcN;
		userAttWorkTime.put("AttRealDTime_F", AttendUtils.convertSecToStr(attRealDTime,"hh"));
		userAttWorkTime.put("AttRealNTime_F", AttendUtils.convertSecToStr(attAcN,"hh"));
		int totWorkTime = (int) userAttWorkTime.getDouble("TotWorkTime");
		int totWorkDTime = totWorkTime - attAcN;
		userAttWorkTime.put("TotWorkTimeD_F", AttendUtils.convertSecToStr(String.valueOf(totWorkDTime),"hh"));
		userAttWorkTime.put("TotWorkTimeN_F", AttendUtils.convertSecToStr(String.valueOf(attAcN),"hh"));
		String strJobStsSumTime = userAttWorkTime.getString("JobStsSumTime");
		double jobStsSumTime = Double.parseDouble(strJobStsSumTime);
		if(jobStsSumTime>0){
			jobStsSumTime = jobStsSumTime/60;
		}
		String JobStsSumTime_F = AttendUtils.convertSecToStr(jobStsSumTime,"hh");
		userAttWorkTime.put("JobStsSumTime_F", JobStsSumTime_F);
		resultMap.putAll(userAttWorkTime);
		return resultMap;
	}

	@Override
	public CoviMap getUserAttExcelInfoV2(String groupPath, String companyCode, String companyId,
									   String startDate, String endDate, String attStatus, String outputNumtype) throws Exception {
		CoviMap resultMap = new CoviMap();
		CoviList resultList = new CoviList();
		boolean bOutputNumtype = false;
		if(outputNumtype.equals("Y")){
			bOutputNumtype = true;
		}

		CoviMap params = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("groupPath", groupPath);
		params.put("AttStatus", attStatus);
		params.put("CompanyCode", companyCode);
		params.put("CompanyId", companyId);
		params.put("StartDate", startDate);
		params.put("EndDate", endDate);
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
		String DayNightStartTime = RedisDataUtil.getBaseConfig("DayNightStartTime") + "";
		String DayNightEndTime = RedisDataUtil.getBaseConfig("DayNightEndTime") + "";
		if (DayNightStartTime.equals("")) {
			DayNightStartTime = RedisDataUtil.getBaseConfig("NightStartTime") + "";
		}
		if (DayNightEndTime.equals("")) {
			DayNightEndTime = RedisDataUtil.getBaseConfig("NightEndTime") + "";
		}
		params.put("NightStartDate", DayNightStartTime);
		params.put("NightEndDate", DayNightEndTime);
		params.put("HolNightStartDate", RedisDataUtil.getBaseConfig("HoliNightStartTime"));
		params.put("HolNightEndDate", RedisDataUtil.getBaseConfig("HoliNightEndTime"));
		params.put("ExtNightStartDate", RedisDataUtil.getBaseConfig("NightStartTime"));
		params.put("ExtNightEndDate", RedisDataUtil.getBaseConfig("NightEndTime"));

		CoviList userAttList = coviMapperOne.list("attend.status.getUserAttExcelInfoV2", params);
		CoviList jobHisList = getUserJobHistory(params);

		String _commuteTimeYn = RedisDataUtil.getBaseConfig("CommuteTimeYn");
		String userCodeId0 = "temp";
		String userCodeId1 = "";
		String userSumCallId = "";
		boolean userChangeFlag = false;

		CoviList userDataList = new CoviList();
		for (int i = 0; i < userAttList.size(); i++) {
			CoviMap userAtt = userAttList.getMap(i);

			//시작 출근 퇴근 상태
			int spNum = 10;
			String schName = userAtt.getString("SchName");
			if (schName == null) {
				schName = "";
			} else {
				schName = schName.length() > spNum ? schName.substring(0, spNum) + ".." : schName;
			}
			String startDt = "";
			String startDd = "";
			String endDt = "";
			String endDd = "";

			startDt = schName;    //근무제
			startDd = userAtt.get("v_AttStartTime") != null ? userAtt.getString("v_AttStartTime") : "";    //출근일정시간
			if (userAtt.get("StartSts") != null) {
				if (userAtt.getString("StartSts").equals("lbl_n_att_absent")) {    //결근
					startDt = DicHelper.getDic("lbl_n_att_absent");
				} else if (userAtt.getString("StartSts").equals("lbl_n_att_callingTarget")) { //소명
					startDt = DicHelper.getDic("lbl_n_att_callingTarget");
				} else if (userAtt.getString("StartSts").equals("lbl_att_beingLate")) {    //지각
					startDt = DicHelper.getDic("lbl_att_beingLate");
					startDd = userAtt.getString("v_AttStartTime");    //출근시간
				}

				/*if(_commuteTimeYn.equals("Y")){
					startDd = "";
				}*/
			}

			endDt = schName;    //근무제
			endDd = !userAtt.getString("v_AttEndTime").equals("") ? userAtt.getString("v_AttEndTime") : "";    //출근일정시간
			if (userAtt.get("EndSts") != null) {

				if (userAtt.getString("EndSts").equals("lbl_n_att_absent")) {    //결근
					endDt = DicHelper.getDic("lbl_n_att_absent");
				} else if (userAtt.getString("EndSts").equals("lbl_n_att_callingTarget")) { //소명
					endDt = DicHelper.getDic("lbl_n_att_callingTarget");
				} else if (userAtt.getString("EndSts").equals("lbl_att_leaveErly")) {    //조퇴
					endDt = DicHelper.getDic("lbl_att_leaveErly");
					endDd = userAtt.getString("v_AttEndTime");    //퇴근시간
				}
				/*if(_commuteTimeYn.equals("Y")){
					endDd = "";
				}*/
			}

			//연장 근무
			if (userAtt.get("ExtenAc") != null && userAtt.getInt("ExtenAc") > 0) {
				endDt = DicHelper.getDic("lbl_att_overtime_work");
				endDd = AttendUtils.maskTime(userAtt.getString("v_ExtenEndTime"));
			}


			//휴무일
			if (userAtt.get("WorkSts") != null && (userAtt.get("WorkSts").toString().equals("OFF") || userAtt.get("WorkSts").toString().equals("HOL"))) {
				startDt = userAtt.get("WorkSts").toString().equals("OFF") ? DicHelper.getDic("lbl_att_sch_holiday") : DicHelper.getDic("lbl_Holiday");
				startDd = "";

				endDt = userAtt.get("WorkSts").toString().equals("OFF") ? DicHelper.getDic("lbl_att_sch_holiday") : DicHelper.getDic("lbl_Holiday");
				endDd = "";
			}
			//휴가
			if (userAtt.get("VacFlag") != null && !userAtt.get("VacFlag").toString().equals("")) {
				//연차종류
				//반차
				if (userAtt.getInt("VacCnt") == 1) {
					startDt = userAtt.getString("VacName");
					startDd = "";
					endDt = userAtt.getString("VacName");
					endDd = "";
				} else {
					if (userAtt.getString("VacOffFlag").contains("AM")) {
						startDt = userAtt.getString("VacName") + (!startDt.equals("") && !userAtt.getString("StartSts").equals("lbl_att_normal_goWork") ? "(" + startDt + ")" : "");
					}
					if (userAtt.getString("VacOffFlag").contains("PM")) {
						endDt = userAtt.getString("VacName2") + (!endDt.equals("") && !userAtt.getString("EndSts").equals("lbl_att_normal_offWork") ? "(" + endDt + ")" : "");
					}
				}

			}

			userAtt.put("startDt", startDt);
			userAtt.put("startDd", startDd);
			userAtt.put("endDt", endDt);
			userAtt.put("endDd", endDd);
			//끝 출근 퇴근 상태 -->
			//데이터 가공
			int totWorkTime = userAtt.getInt("TotWorkTime");
			userAtt.put("TotWorkTime_F", bOutputNumtype?totWorkTime:AttendUtils.convertSecToStr(totWorkTime, "H"));
			int attAcN = userAtt.getInt("AttAcN");
			int totWorkDTime = totWorkTime - attAcN;
			userAtt.put("TotWorkTimeD_F", bOutputNumtype?totWorkDTime:AttendUtils.convertSecToStr(totWorkDTime, "H"));
			userAtt.put("TotWorkTimeN_F", bOutputNumtype?attAcN:AttendUtils.convertSecToStr(attAcN, "H"));

			int attRealTime = userAtt.getInt("AttRealTime");
			userAtt.put("AttRealTime_F", bOutputNumtype?attRealTime:AttendUtils.convertSecToStr(attRealTime, "H"));
			int attRealDTime = attRealTime - attAcN;
			userAtt.put("AttRealDTime_F", bOutputNumtype?attRealDTime:AttendUtils.convertSecToStr(attRealDTime, "H"));
			userAtt.put("AttRealNTime_F", bOutputNumtype?attAcN:AttendUtils.convertSecToStr(attAcN, "H"));

			userAtt.put("ExtenAc_F", bOutputNumtype?userAtt.get("ExtenAc"):AttendUtils.convertSecToStr(userAtt.get("ExtenAc"), "H"));
			userAtt.put("ExtenAcD_F", bOutputNumtype?userAtt.get("ExtenAcD"):AttendUtils.convertSecToStr(userAtt.get("ExtenAcD"), "H"));
			userAtt.put("ExtenAcN_F", bOutputNumtype?userAtt.get("ExtenAcN"):AttendUtils.convertSecToStr(userAtt.get("ExtenAcN"), "H"));

			userAtt.put("HoliAc_F", bOutputNumtype?userAtt.get("HoliAc"):AttendUtils.convertSecToStr(userAtt.get("HoliAc"), "H"));
			userAtt.put("HoliAcD_F", bOutputNumtype?userAtt.get("HoliAcD"):AttendUtils.convertSecToStr(userAtt.get("HoliAcD"), "H"));
			userAtt.put("HoliAcN_F", bOutputNumtype?userAtt.get("HoliAcN"):AttendUtils.convertSecToStr(userAtt.get("HoliAcN"), "H"));

			//월 누적근무
			userAtt.put("MonthlyAttAcSum_F", bOutputNumtype?userAtt.get("MonthlyAttAcSum"):AttendUtils.convertSecToStr(userAtt.get("MonthlyAttAcSum"), "H"));

			String startPointX = userAtt.getString("StartPointX");
			String startPointY = userAtt.getString("StartPointY");
			String endPointX = userAtt.getString("EndPointX");
			String endPointY = userAtt.getString("EndPointY");
			String startGps = "";
			String endGps = "";
			if (startPointX != null && !startPointX.equals("") && startPointY != null && !startPointY.equals("")) {
				startGps = "Y";
			}
			if (endPointX != null && !endPointX.equals("") && endPointY != null && !endPointY.equals("")) {
				endGps = "Y";
			}
			userAtt.put("StartGps", startGps);
			userAtt.put("EndGps", endGps);

			String dayList = userAtt.getString("dayList");

			String jobSts = "";
			StringBuffer buf = new StringBuffer();
			for (int j = 0; j < jobHisList.size(); j++) {
				CoviMap jobHisObj = jobHisList.getMap(j);
				String jobDate = jobHisObj.getString("JobDate");
				if (dayList.equals(jobDate)) {
					if (!"".equals(jobSts)) {
						buf.append(",");
					}
					//jobSts += jobHisObj.getString("JobStsName") + "["+jobHisObj.getString("v_StartTime")+"~"+jobHisObj.getString("v_EndTime")+"]";
					buf.append(jobHisObj.getString("JobStsName")).append("[").append(jobHisObj.getString("v_StartTime")).append("~").append(jobHisObj.getString("v_EndTime")).append("]");
				}
			}
			jobSts = buf.toString();
			userAtt.put("JobStatus", jobSts);
			//--
			//-->
			userDataList.add(userAtt);
		}

		for (int i = 0; i < userDataList.size(); i++) {
			CoviMap userAtt = userDataList.getMap(i);
			userCodeId1 = userAtt.getString("UserCode");
			if (i == 0) {
				userCodeId0 = userCodeId1;
			}
			if (!userCodeId0.equals("") && !userCodeId1.equals("") && !userCodeId0.equals(userCodeId1)) {
				userSumCallId = userCodeId0;
				userCodeId0 = userCodeId1;
				userChangeFlag = true;
			} else {
				userChangeFlag = false;
			}
			if (userChangeFlag) {
				//System.out.println("#####userSumCallId:" + userSumCallId);
				CoviMap userAttWorkTime = getUserAttWorkWithDayAndNightTimeProc(userSumCallId, companyCode, startDate, endDate);
				userAttWorkTime.put("TotWorkTime_F", bOutputNumtype?userAttWorkTime.getString("TotWorkTime"):AttendUtils.convertSecToStr(userAttWorkTime.get("TotWorkTime").toString(), "hh"));
				int remainTime = userAttWorkTime.getInt("RemainTime");
				String remainTimeStr = "";
				if (remainTime < 0) {
					remainTime = Math.abs(remainTime);
					remainTimeStr = AttendUtils.convertSecToStr(remainTime, "hh") + " 초과";
				} else {
					remainTimeStr = AttendUtils.convertSecToStr(userAttWorkTime.get("RemainTime").toString(), "hh");
				}
				userAttWorkTime.put("RemainTime_F", remainTimeStr);
				userAttWorkTime.put("HoliAc_F", bOutputNumtype?userAttWorkTime.getString("HoliAc"):AttendUtils.convertSecToStr(userAttWorkTime.get("HoliAc").toString(), "hh"));
				userAttWorkTime.put("HoliAcD_F", bOutputNumtype?userAttWorkTime.getString("HoliAcD"):AttendUtils.convertSecToStr(userAttWorkTime.get("HoliAcD").toString(), "hh"));
				userAttWorkTime.put("HoliAcN_F", bOutputNumtype?userAttWorkTime.getString("HoliAcN"):AttendUtils.convertSecToStr(userAttWorkTime.get("HoliAcN").toString(), "hh"));
				userAttWorkTime.put("ExtenAc_F", bOutputNumtype?userAttWorkTime.getString("ExtenAc"):AttendUtils.convertSecToStr(userAttWorkTime.get("ExtenAc").toString(), "hh"));
				userAttWorkTime.put("ExtenAcD_F", bOutputNumtype?userAttWorkTime.getString("ExtenAcD"):AttendUtils.convertSecToStr(userAttWorkTime.get("ExtenAcD").toString(), "hh"));
				userAttWorkTime.put("ExtenAcN_F", bOutputNumtype?userAttWorkTime.getString("ExtenAcN"):AttendUtils.convertSecToStr(userAttWorkTime.get("ExtenAcN").toString(), "hh"));
				userAttWorkTime.put("AttRealTime_F", bOutputNumtype?userAttWorkTime.getString("AttRealTime"):AttendUtils.convertSecToStr(userAttWorkTime.get("AttRealTime").toString(), "hh"));
				int t_attRealTime = userAttWorkTime.getInt("AttRealTime");
				int t_attAcN = userAttWorkTime.getInt("AttAcN");
				int t_attRealDTime = t_attRealTime - t_attAcN;
				userAttWorkTime.put("AttRealDTime_F", bOutputNumtype?t_attRealDTime:AttendUtils.convertSecToStr(t_attRealDTime, "hh"));
				userAttWorkTime.put("AttRealNTime_F", bOutputNumtype?t_attAcN:AttendUtils.convertSecToStr(t_attAcN, "hh"));
				int t_totWorkTime = userAttWorkTime.getInt("TotWorkTime");
				int t_totWorkDTime = t_totWorkTime - t_attAcN;
				userAttWorkTime.put("TotWorkTimeD_F", bOutputNumtype?t_totWorkDTime:AttendUtils.convertSecToStr(t_totWorkDTime, "hh"));
				userAttWorkTime.put("TotWorkTimeN_F", bOutputNumtype?t_attAcN:AttendUtils.convertSecToStr(t_attAcN, "hh"));
				String strJobStsSumTime = userAttWorkTime.getString("JobStsSumTime");
				double t_jobStsSumTime = Double.parseDouble(strJobStsSumTime);
				if (t_jobStsSumTime > 0) {
					t_jobStsSumTime = t_jobStsSumTime / 60;
				}
				int int_t_jobStsSumTime = (int)t_jobStsSumTime;
				String JobStsSumTime_F = bOutputNumtype?String.valueOf(int_t_jobStsSumTime):AttendUtils.convertSecToStr(int_t_jobStsSumTime, "hh");
				userAttWorkTime.put("JobStsSumTime_F", JobStsSumTime_F);
				CoviMap userDataMap = new CoviMap();
				userDataMap.addAll(userAttWorkTime);
				//사용자 데이터 추출
				CoviList userDataListTemp= new CoviList();
				for(int k=0;k<userDataList.size();k++){
					CoviMap cmapTemp = userDataList.getMap(k);
					if(cmapTemp.getString("UserCode").equals(userSumCallId)){
						userDataListTemp.add(cmapTemp);
					}
				}
				userDataMap.put("list", userDataListTemp);
				resultList.add(userDataMap);
			}
		}
		resultMap.put("StartDate", startDate);
		resultMap.put("EndDate", endDate);
		resultMap.put("datalist", resultList);


		return resultMap;
	}
	
	// 일괄 출퇴근 엑셀 업로드
	@Override
	public int setAllCommuteByExcel(CoviMap params) throws Exception {
		int result = 0;
		CoviList dataList = extractionExcelData(params, 0);	// 엑셀 데이터 추출
		
		for (int i = 0; i < dataList.size(); i++) {
			CoviMap dataMap = dataList.getMap(i);
			if(dataMap.getString("UserCode").equals("")||dataMap.getString("TargetDate").equals("")){
				continue;
			}
			dataMap.put("CompanyCode", params.getString("CompanyCode"));
			dataMap.put("RegUserCode", params.getString("RegisterCode"));
			
			CoviMap attJob = null;
			CoviList jobList = coviMapperOne.list("attend.commute.getMngJob", dataMap);
			
			if (jobList != null && jobList.size() > 0) { // 근무 일정이 있을 때
				attJob = jobList.getMap(0);
			} else { // 근무 일정이 없을 때
				params.put("SetDate",dataMap.getString("TargetDate"));
				CoviList scheduleList = coviMapperOne.list("attend.schedule.getBaseSchedule", params);
				attJob = scheduleList.getMap(0);
				
				// 근무 일정 생성
				CoviMap item = new CoviMap();
				item.put("SchSeq", attJob.getString("SchSeq"));
				item.put("JobUserCode", dataMap.getString("UserCode"));
				item.put("TrgDates", dataMap.getString("TargetDate"));
				item.put("HolidayFlag", "Y");
				item.put("WeekFlag", "Y");
				item.put("CompanyCode", params.getString("CompanyCode"));
				item.put("USERID", params.getString("RegisterCode"));
				
				coviMapperOne.update("attend.job.createScheduleJobDiv", item);
			}
			
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			Calendar cal = Calendar.getInstance();
			
			if (dataMap.getString("IsGoWork").equals("Y")) { // 일괄출근
				if (StringUtil.isNull(dataMap.getString("sTime"))) {
					int min = Integer.parseInt(RedisDataUtil.getBaseConfig("AllGoWorkApplyTime", SessionHelper.getSession("DN_ID")));
					
					Date startDate = dateFormat.parse(attJob.getString("AttDayStartTime"));
					cal.setTime(startDate);
					cal.add(Calendar.MINUTE, (min * -1));
					
					dataMap.put("StartDate", dateFormat.format(cal.getTime()));
				} else {
					dataMap.put("StartDate", dataMap.getString("TargetDate") + " " + dataMap.getString("sTime"));
				}
			}
			
			if (dataMap.getString("IsOffWork").equals("Y")) { // 일괄퇴근
				if (StringUtil.isNull(dataMap.getString("eTime"))) {
					int min = Integer.parseInt(RedisDataUtil.getBaseConfig("AllOffWorkApplyTime", SessionHelper.getSession("DN_ID")));
					
					Date endDate = dateFormat.parse(attJob.getString("AttDayEndTime"));
					cal.setTime(endDate);
					cal.add(Calendar.MINUTE, min);
					
					dataMap.put("EndDate", dateFormat.format(cal.getTime()));
				} else {
					dataMap.put("EndDate", dataMap.getString("TargetDate") + " " + dataMap.getString("eTime"));
				}
			}
			
			String commuteSeq = coviMapperOne.selectOne("attend.commute.getCommuteMstSeq", dataMap);
			
			if(commuteSeq == null){
				/**
				 * 해당 일자에 대한  MST TABLE 데이터가 없을경우
				 * MST테이블 정보를 생성
				 * */
				coviMapperOne.insert("attend.commute.setCommuteMst", dataMap);
				commuteSeq = dataMap.getString("CommuSeq");
			}
			
			dataMap.put("CommuSeq", commuteSeq);
			
			//출퇴근 시간 ( 상태 S ) 업데이트 
			result += coviMapperOne.update("attend.commute.setAttCommuteMng", dataMap);
			
			//출퇴근 시간 외 정보 재입력
			coviMapperOne.update("attend.commute.setCommuteMstProc", dataMap);
			
			// 수정자 업데이트
			coviMapperOne.update("attend.commute.updateAllCommute", dataMap);
		}
		
		return result;
	}
	
	// 엑셀 임시파일 생성
	private File prepareAttachment(final MultipartFile mFile) throws IOException {
		File tmp = null;
		
		try {
			tmp = File.createTempFile("upload", ".tmp");
			mFile.transferTo(tmp);
			
			return tmp;
		} catch (IOException ioE) {
			if (tmp != null){
				if(tmp.delete()) {
					LOGGER.debug("file : " + tmp.toString() + " delete();");
				}
			}
			
			throw ioE;
		}
	}
	
	// 엑셀 데이터 추출
	private CoviList extractionExcelData(CoviMap params, int headerIndex) throws Exception {
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = null;
		InputStream inputStream = null;
		
		CoviList returnList = new CoviList();
		Workbook wb = null;
		try {
			if(awsS3.getS3Active()){
				inputStream = mFile.getInputStream();
				wb = WorkbookFactory.create(inputStream);
			}else {
				file = prepareAttachment(mFile);
				wb = WorkbookFactory.create(file);
			}
			
			Sheet sheet = wb.getSheetAt(0);
			CoviMap dataMap = null;
			Iterator<Row> rowIterator = sheet.iterator();
			int cellNum = 0;
			
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				int rowNum = row.getRowNum();
				
				if (rowNum == headerIndex) {
					cellNum = row.getLastCellNum();	
				} else if (rowNum > headerIndex) {	// header 제외
					dataMap = new CoviMap();
					
					for (int colNum = 0; colNum < cellNum; colNum++) {
						String key = "";
						switch (colNum) {
							case 0 : key = "UserCode"; break;
							case 1 : key = "TargetDate"; break;
							case 2 : key = "IsGoWork"; break;
							case 3 : key = "IsOffWork"; break;
							case 4 : key = "sTime"; break;
							case 5 : key = "eTime"; break;
							default : break;
						}
						
						Cell cell = row.getCell(colNum, Row.MissingCellPolicy.CREATE_NULL_AS_BLANK);

						switch (cell.getCellTypeEnum()) {
							case BOOLEAN:
								dataMap.put(key, cell.getBooleanCellValue());
								break;
							case NUMERIC:
								dataMap.put(key, cell.getNumericCellValue());
								break;
							case STRING:
								dataMap.put(key, cell.getStringCellValue());
								break;
							case FORMULA:
								dataMap.put(key, cell.getCellFormula());
								break;
							case BLANK:
								dataMap.put(key, "");
								break;
							default :
								break;
						}
					}
					
					returnList.add(dataMap);
				}
			}
		} catch (NullPointerException e) {
			throw(e);
		} catch (IOException e) {
			throw(e);
		} catch (Exception e) {
			throw(e);
		} finally {
			if (wb != null) { try { wb.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }			
			if (awsS3.getS3Active()){
				if (inputStream != null) { try { inputStream.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			} else {
				if (file != null) {
					if (file.delete()) {
						LOGGER.debug("file : " + file.toString() + " delete();");
					}
				}
			}
		}
		
		return returnList;
	}
	
	@Override
	public CoviMap getUserAttendanceExcelList(CoviMap params) throws Exception {
		CoviMap returnMap = new CoviMap();
		
		/*검색일*/
		String DateTerm = params.getString("DateTerm");
		String TargetDate = params.getString("TargetDate");
		String CompanyCode = params.getString("CompanyCode");
		String GroupPath = params.getString("GroupPath");
		String sDate = "";
		String eDate = ""; 
		if (DateTerm.equals("")){
			sDate = params.getString("StartDate");
			eDate = params.getString("EndDate");
		}
		else{
			returnMap.addAll(setDayParams(DateTerm,TargetDate,CompanyCode));
			
			sDate = returnMap.getString("sDate");
			eDate = returnMap.getString("eDate");
		}
			
		CoviMap attParams = new CoviMap();
		attParams.put("CompanyCode", CompanyCode); 
		attParams.put("StartDate", sDate);
		attParams.put("EndDate", eDate);  
		attParams.put("GroupPath", GroupPath);  
		attParams.put("lang", SessionHelper.getSession("lang"));
		attParams.put("domainID", SessionHelper.getSession("DN_ID"));
		attParams.put("AttStatus", params.getString("AttStatus"));
		attParams.put("sUserTxt", params.getString("sUserTxt"));
		attParams.put("sJobTitleCode", params.getString("sJobTitleCode"));
		attParams.put("sJobLevelCode", params.getString("sJobLevelCode"));
		attParams.put("SchSeq", params.getString("SchSeq"));
		attParams.put("RetireUser",params.getString("RetireUser"));


		String firstWeek = params.getString("FirstWeek");
		if(firstWeek == null || "".equals(firstWeek)) {
			firstWeek = "0"; // oracle에서는 null이나 ''면 에러가 나기 때문에 값이 없으면 0으로 세팅 / mysql에서도 이상 없음.
		}
		
		attParams.put("FirstWeek", firstWeek);
		attParams.put("sortColumn", params.getString("sortColumn"));
		attParams.put("sortDirection", params.getString("sortDirection"));
		
		CoviList userAttList = coviMapperOne.list("attend.status.getUserAttStatusByExcelList", attParams);
		returnMap.put("list", userAttList); 
		 
		return returnMap;
	}
	
	public int updateAttConfirm(CoviMap params) throws Exception {
		params.addAll(setDayParams(params.getString("dateTerm"), params.getString("targetDate"), "GENERAL"));
		return coviMapperOne.update("attend.status.updateAttConfirm", params);
	}
	
}