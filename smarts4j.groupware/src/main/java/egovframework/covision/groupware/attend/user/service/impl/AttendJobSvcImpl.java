package egovframework.covision.groupware.attend.user.service.impl;

import javax.annotation.Resource;

import com.google.gson.Gson;
import egovframework.baseframework.data.CoviSelectSet;


import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.covision.groupware.attend.user.service.AttendJobSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.RedisDataUtil;

@Service("AttendJobSvc")
public class AttendJobSvcImpl extends EgovAbstractServiceImpl implements AttendJobSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * @Method Name : createAttendScheduleJob
	 * @Description : 근무일정 생성
	 */
	@Override 
	public CoviMap createAttendScheduleJob(CoviMap params, List objTrges) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt = 0;
		List objUsers = new ArrayList();
		for (int k=0; k < objTrges.size();k++){
			Map itemUser = (Map)objTrges.get(k);
			if (itemUser.get("Type").equals("UR")){
				objUsers.add(itemUser.get("Code"));
			}
			else{
				CoviMap deptParam = new CoviMap();
				deptParam.put("CompanyCode",params.get("CompanyCode"));
				deptParam.put("sDeptCode", itemUser.get("Code"));
				
				CoviList userList = coviMapperOne.list("attend.common.getUserListByDept", deptParam);
				for (int i = 0; i < userList.size(); i++){
					objUsers.add(userList.getMap(i).getString("UserCode"));
				}
			}
		}
		
		for(int i=0; i<objUsers.size(); i++){
			CoviMap item = new CoviMap();
			item.put("SchSeq", params.get("SchSeq"));
			item.put("StartDate", params.get("StartDate"));
			item.put("EndDate", params.get("EndDate"));
			item.put("JobUserCode", objUsers.get(i));
			item.put("HolidayFlag", params.get("HolidayFlag"));
			item.put("CompanyCode", params.get("CompanyCode"));
			item.put("USERID", params.get("USERID"));

			CoviMap retMap = null;
			if("-1".equals(params.get("SchSeq").toString())) {
				item.put("StartTime",  params.get("StartTime"));
				item.put("EndTime",  params.get("EndTime"));
				item.put("NextDayYn",  params.get("NextDayYn"));

//				retMap = coviMapperOne.selectOne("attend.job.createScheduleJobDirect", item);
				coviMapperOne.update("attend.job.createScheduleJobDirect", item);
			} else {
//				retMap = coviMapperOne.selectOne("attend.job.createScheduleJob", item);
				coviMapperOne.update("attend.job.createScheduleJob", item);
			}
			cnt += item.getInt("RetCount");
		}
		resultList.put("resultCnt", String.valueOf(cnt));
		resultList.put("result", "OK");
		return resultList;
	}
	
	/**
	 * @Method Name : createAttendScheduleJob
	 * @Description : 근무일정 생성
	 */
	@Override 
	public CoviMap createAttendScheduleJobDiv(CoviMap params, List objTrges, List objLists) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt = 0;
		List objUsers = new ArrayList();
		for (int k=0; k < objTrges.size();k++){
			Map itemUser = (Map)objTrges.get(k);
			if (itemUser.get("Type").equals("UR")){
				objUsers.add(itemUser.get("Code"));
			}
			else{
				CoviMap deptParam = new CoviMap();
				deptParam.put("CompanyCode",params.get("CompanyCode"));
				deptParam.put("sDeptCode", itemUser.get("Code"));
				
				CoviList userList = coviMapperOne.list("attend.common.getUserListByDept", deptParam);		
				for (int i = 0; i < userList.size(); i++){
					objUsers.add(userList.getMap(i).getString("UserCode"));
				}
			}
		}
		
		for(int i=0; i<objUsers.size(); i++){
			java.util.HashMap ht = new java.util.HashMap();
			StringBuffer offDates = new StringBuffer();
			//스케쥴별로 쪼개기
			for(int j=0; j<objLists.size(); j++){
				Map item = (Map)objLists.get(j);
				String workSts = (String)item.get("WorkSts");
				if (workSts.equals("ON")){
					String schSeq = (String)item.get("SchSeq");
					StringBuffer trgDates = new StringBuffer();
					java.util.HashMap tmpMap = new java.util.HashMap();
					if("-1".equals(schSeq)) { //직접 입력
						String key = item.get("StartTime").toString() + "_" + item.get("EndTime").toString() + "_" + item.get("NextDayYn").toString();
						if(ht.get(schSeq) != null) {
							tmpMap = (java.util.HashMap) ht.get(schSeq);
							if(tmpMap.get(key) != null) {
								trgDates = (StringBuffer) tmpMap.get(key);
								trgDates.append(":");
							}
							trgDates.append(item.get("TargetDate"));
							tmpMap.put(key, trgDates);
						} else {
							trgDates.append(item.get("TargetDate"));
							tmpMap.put(key, trgDates);
						}
						ht.put(schSeq, tmpMap);

					} else { //선택
						if (ht.get(schSeq) != null) {
							trgDates = (StringBuffer) ht.get(schSeq);
							trgDates.append(":");
						}
						trgDates.append(item.get("TargetDate"));
						ht.put(schSeq, trgDates);
					}
				}	
				else{
					if (offDates != null && !offDates.toString().equals("")) offDates.append(":");
					offDates.append(item.get("TargetDate"));
				}
			}	

			java.util.Iterator<Map.Entry<String, Object>> iteratorE  = ht.entrySet().iterator();
			while (iteratorE .hasNext()){
				Map.Entry<String, Object> entry = (Map.Entry<String, Object>) iteratorE.next();
			    String key = entry.getKey();

			    if("-1".equals(key)) { //직접 입력 처리
			    	java.util.HashMap tmpMap = (java.util.HashMap) entry.getValue();
					java.util.Iterator<Map.Entry<String, StringBuffer>> tmpIteratorE  = tmpMap.entrySet().iterator();
					while (tmpIteratorE .hasNext()) {
						Map.Entry<String, StringBuffer> tmpEntry = (Map.Entry<String, StringBuffer>) tmpIteratorE.next();
						String tmpKey = tmpEntry.getKey();
						String[] paramValues = tmpKey.split("_");
						StringBuffer value = tmpEntry.getValue();

						CoviMap item = new CoviMap();
						item.put("SchSeq", key);
						item.put("JobUserCode", objUsers.get(i));
						item.put("TrgDates", value.toString());
						item.put("HolidayFlag", params.get("HolidayFlag"));
						item.put("WeekFlag", params.get("WeekFlag"));
						item.put("CompanyCode", params.get("CompanyCode"));
						item.put("USERID", params.get("USERID"));
						item.put("StartTime", paramValues[0]);
						item.put("EndTime", paramValues[1]);
						item.put("NextDayYn", paramValues[2]);
						//CoviMap retMap = coviMapperOne.selectOne("attend.job.createScheduleJobDivDirect", item);
						coviMapperOne.update("attend.job.createScheduleJobDivDirect", item);
						cnt += item.getInt("RetCount");
					}
				} else { // 선택 처리
					StringBuffer value = (StringBuffer)entry.getValue();

					CoviMap item = new CoviMap();
					item.put("SchSeq", key);
					item.put("JobUserCode", objUsers.get(i));
					item.put("TrgDates", value.toString());
					item.put("HolidayFlag", params.get("HolidayFlag"));
					item.put("WeekFlag", params.get("WeekFlag"));
					item.put("CompanyCode", params.get("CompanyCode"));
					item.put("USERID", params.get("USERID"));
					//CoviMap retMap = coviMapperOne.selectOne("attend.job.createScheduleJobDiv", item);
					coviMapperOne.update("attend.job.createScheduleJobDiv", item);
					cnt += item.getInt("RetCount");
				}
			}
            
            //휴무 데이타
            if (offDates != null && !offDates.toString().equals("")) {
                CoviMap item = new CoviMap();
    			item.put("JobUserCode", objUsers.get(i));
    			item.put("TrgDates", offDates.toString());
    			item.put("CompanyCode", params.get("CompanyCode"));
    			item.put("WorkSts", "OFF");
    			item.put("USERID", params.get("USERID"));
    			coviMapperOne.update("attend.job.createScheduleOff", item);
    			//CoviMap retMap = coviMapperOne.selectOne("attend.job.createScheduleOff", item);
    			cnt += item.getInt("RetCount");
            }
		}
		resultList.put("resultCnt", cnt);
		resultList.put("result", "OK");
		return resultList;
	}
	
	/**
	 * @Method Name : copyAttendScheduleJob
	 * @Description : 근무일정 생성
	 */
	@Override 
	public CoviMap copyAttendScheduleJob(CoviMap params, List objTrges, List objDates) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt = 0;
		List objUsers = new ArrayList();
		for (int k=0; k < objTrges.size();k++){
			Map itemUser = (Map)objTrges.get(k);
			if (itemUser.get("Type").equals("UR")){
				objUsers.add(itemUser.get("Code"));
			}
			else{
				CoviMap deptParam = new CoviMap();
				deptParam.put("CompanyCode",params.get("CompanyCode"));
				deptParam.put("sDeptCode", itemUser.get("Code"));
				
				CoviList userList = coviMapperOne.list("attend.common.getUserListByDept", deptParam);		
				for (int i = 0; i < userList.size(); i++){
					objUsers.add(userList.getMap(i).getString("UserCode"));
				}
			}
		}
		
		StringBuffer trgDates = new StringBuffer();
		for (int j=0; j < objDates.size(); j++){
			if (j>0) trgDates.append(":");
			trgDates.append(objDates.get(j));
		}

		for(int i=0; i<objUsers.size(); i++){
			CoviMap item = new CoviMap();
			item.put("orgJobDate", params.get("orgJobDate"));
			item.put("orgUserCode", params.get("orgUserCode"));
			item.put("JobUserCode", objUsers.get(i));
			item.put("TrgDates", trgDates.toString());
			item.put("CompanyCode", params.get("CompanyCode"));
			item.put("USERID", params.get("USERID"));
			item.put("HolidayFlag", params.get("HolidayFlag"));
			item.put("WeekFlag", params.get("WeekFlag"));
			coviMapperOne.update("attend.job.copyScheduleJob", item);
			//CoviMap retMap = coviMapperOne.selectOne("attend.job.copyScheduleJob", item);
			cnt += item.getInt("RetCount");
		}
		resultList.put("resultCnt", cnt);
		resultList.put("result", "OK");
		return resultList;
	}
	
	/**
	 * @Method Name : reapplyAttendScheduleJob
	 * @Description : 근무일정 재반영
	 */
	@Override 
	public CoviMap reapplyAttendScheduleJob(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		coviMapperOne.update("attend.job.reapplyScheduleJob", params);
		//CoviMap retMap = coviMapperOne.selectOne("attend.job.reapplyScheduleJob", params);
		resultList.put("resultCnt", params.getInt("RetCount"));
		resultList.put("result", "OK");
		return resultList;
	}
	
	@Override 
	public CoviMap reapplyAttendHolidayJob(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList userList	= coviMapperOne.list("attend.job.getScheduleJobUser", params);
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		Date startDate = null;
		Date endDate = null;
		String dayTitle = "";
		String dayTitleMonth = "";
		String dayWeek = "0";
		StringBuffer offDates = new StringBuffer();

		startDate = sdf.parse(AttendUtils.removeMaskAll(params.getString("HolidayStart")));
		endDate = sdf.parse(AttendUtils.removeMaskAll(params.getString("HolidayEnd")));
		if (!startDate.equals(endDate)){
			long diffSec = (endDate.getTime() - startDate.getTime())/(24*60*60*1000);
			Calendar cal = Calendar.getInstance();
			cal.setTime(startDate);
			offDates.append(sdf.format(startDate));
			for (int i=1; i <= diffSec ; i++){
				cal.add(Calendar.DATE, 1);
				offDates.append(":"+sdf.format(cal.getTime()));
			}
		}
		else{
			offDates.append(sdf.format(startDate));
		}
		
		int cnt = 0;
		 //휴무 데이타
	    if (offDates != null && !offDates.toString().equals("")) {
	    	for (int i=0; i < userList.size(); i++){
		        CoviMap item = new CoviMap();
		        
				item.put("JobUserCode", userList.getMap(i).get("UserCode"));
				item.put("TrgDates", offDates.toString());
				item.put("CompanyCode", params.get("CompanyCode"));
				item.put("USERID", params.get("USERID"));
    			item.put("WorkSts", "HOL");
    			coviMapperOne.update("attend.job.createScheduleOff", item);
				//CoviMap retMap = coviMapperOne.selectOne("attend.job.createScheduleOff", item);
				cnt += item.getInt("RetCount");
	    	}	
	    }	
		resultList.put("resultCnt", cnt);
		resultList.put("result", "OK");
		return resultList;
    }
    
	/**
	 * @Method Name : getAttendJobDay
	 * @Description : 근무일정 주간
	 */
	@Override 
	public CoviMap getAttendJobDay(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap avg			= new CoviMap();
		String[] Days = {"00", "01", "02", "03", "04", "05", "06", "07", "08", "09"
						, "10", "11", "12", "13", "14", "15", "16", "17", "18", "19"
						, "20", "21", "22", "23" };
		params.put("Days", Days);
		
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		params.put("attendAuth", attendAuth);
		params.put("jobType", jobType);
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.job.getJobDayCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}
		list	= coviMapperOne.list("attend.job.getJobDay", params);	
		if (params.get("pageNo") == null || params.getInt("pageNo")==1) avg	= coviMapperOne.selectOne("attend.job.getJobDayAvg", params);	
		resultList.put("list",	list);
		resultList.put("avg",	avg);
		resultList.put("page",	page);
		
		return resultList; 
	}

	
	/**
	 * @Method Name : getAttendJobWeek
	 * @Description : 근무일정 주간
	 */
	@Override 
	public CoviMap getAttendJobWeek(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page		= new CoviMap();
		CoviList list		= new CoviList();
		CoviMap avg			= new CoviMap();		
		
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
		
		List<String> weekDate = AttendUtils.getDatesBetweenTwoDates(params.getString("StartDate"), params.getString("EndDate"));
		
		int attBaseWeek = Integer.parseInt(RedisDataUtil.getBaseConfig("AttBaseWeek"));
		int sunIdx = (1 - attBaseWeek) == 0 ? 0 : (1 - attBaseWeek) + 7;
		
		String[][] Weeks = {
			{"6", "Sun", weekDate.get(sunIdx < weekDate.size() ? sunIdx : sunIdx - weekDate.size())},
			{"0", "Mon", weekDate.get((sunIdx + 1) < weekDate.size() ? sunIdx + 1 : (sunIdx + 1) - weekDate.size())},
			{"1", "Tue", weekDate.get((sunIdx + 2) < weekDate.size() ? sunIdx + 2 : (sunIdx + 2) - weekDate.size())},
			{"2", "Wed", weekDate.get((sunIdx + 3) < weekDate.size() ? sunIdx + 3 : (sunIdx + 3) - weekDate.size())},
			{"3", "Thu", weekDate.get((sunIdx + 4) < weekDate.size() ? sunIdx + 4 : (sunIdx + 4) - weekDate.size())},
			{"4", "Fri", weekDate.get((sunIdx + 5) < weekDate.size() ? sunIdx + 5 : (sunIdx + 5) - weekDate.size())}, 
			{"5", "Sat", weekDate.get((sunIdx + 6) < weekDate.size() ? sunIdx + 6 : (sunIdx + 6) - weekDate.size())}
		};
		
		params.put("Weeks", Weeks);
		
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		params.put("attendAuth", attendAuth);
		params.put("jobType", jobType);
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.job.getJobWeekCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}
		list	= coviMapperOne.list("attend.job.getJobWeek", params);	
		if (params.get("pageNo") == null || params.getInt("pageNo")==1) avg	= coviMapperOne.selectOne("attend.job.getJobWeekAvg", params);	
		resultList.put("avg",	avg);
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getAttendJobMonth
	 * @Description : 근무일정 월간
	 */
	@Override 
	public CoviMap getAttendJobMonth(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		params.put("attendAuth", attendAuth);
		params.put("jobType", jobType);
		
		CoviList list	= coviMapperOne.list("attend.job.getJobMonth", params);	
		CoviList holiList	= coviMapperOne.list("attend.common.getHolidaySchedule", params);
		resultList.put("list",	list);
		resultList.put("holiList",	holiList);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getAttendJobList
	 * @Description : 근무일정 목록
	 */
	@Override 
	public CoviMap getAttendJobList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		params.put("attendAuth", attendAuth);
		params.put("jobType", jobType);
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.job.getJobListCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}
		list	= coviMapperOne.list("attend.job.getJobList", params);	
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getAttendDetail
	 * @Description : 근무일정 주간
	 */
	@Override 
	public CoviMap getAttendDetail(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap data			= new CoviMap();

		data	= coviMapperOne.selectOne("attend.job.getJobDetail", params);	
		resultList.put("data",	data);
		
		return resultList; 
	}
	
	public int saveAttendJob(CoviMap params) throws Exception {
		return coviMapperOne.update("attend.job.updateJob", params);
	}
	
	public int delAttendJob(List objList) throws Exception {
		int cnt = 0;
		for(int i=0; i<objList.size(); i++){
			Map item = (Map)objList.get(i);
			item.put("schConfmYn",RedisDataUtil.getBaseConfig("SchConfmYn"));
			cnt += coviMapperOne.delete("attend.job.delJob", item);
		}

		return cnt;
	}
	
	public int confirmAttendJob  (List objList, String confirmYn) throws Exception {
		int cnt = 0;
		for(int i=0; i<objList.size(); i++){
			Map item = (Map)objList.get(i);
			item.put("USERID", SessionHelper.getSession("USERID"));
			item.put("ConfmYn",confirmYn);
			cnt += coviMapperOne.update("attend.job.confirmJob", item);
		}
		return cnt;
	}

	/**
	 * @Method Name : uploadExcel
	 * @Description : 엑셀 다운로드
	 */
	@Override
	public CoviMap uploadExcel(CoviMap params) throws Exception{
		int cnt = 0;
		CoviMap resultList	= new CoviMap();
		
		ArrayList<ArrayList<Object>> dataList = AttendUtils.extractionExcelData(params, 1);	// 엑셀 데이터 추출

		int totalCnt   =0 ;
		int successCnt =0;
		int failCnt = 0;

		for (ArrayList list : dataList) { // 추가
			
			CoviMap item = new  CoviMap();
			
			item.put("JobUserCode", list.get(0));
			item.put("JobDate", list.get(1));
			item.put("StartTime", list.get(2));
			item.put("EndTime", list.get(3));
			item.put("NextDayYn", list.get(4));
			item.put("WorkSts", list.get(5));

			item.put("USERID", SessionHelper.getSession("UR_Code"));
			item.put("CompanyCode",SessionHelper.getSession("DN_Code"));
			
			coviMapperOne.update("attend.job.uploadScheduleJob", item);
			cnt += item.getInt("RetCount");
			if (cnt >0) successCnt++;
			else failCnt++;		
			totalCnt++;
		}
		
		resultList.put("totalCnt", totalCnt);
		resultList.put("successCnt", successCnt);
		resultList.put("failCnt", failCnt);
		return resultList;
	}

	/**
	 * @Method Name : getAttendJobViewDay
	 * @Description : 근무일정 일간
	 */
	@Override
	public CoviMap getAttendJobViewDay(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap avg			= new CoviMap();
		String[] Days = {"00", "01", "02", "03", "04", "05", "06", "07", "08", "09"
				, "10", "11", "12", "13", "14", "15", "16", "17", "18", "19"
				, "20", "21", "22", "23" };
		params.put("Days", Days);
		
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		params.put("attendAuth", attendAuth);
		params.put("jobType", jobType);

		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.job.getJobViewDayCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}
		list	= coviMapperOne.list("attend.job.getJobViewDay", params);
		if (params.get("pageNo") == null || params.getInt("pageNo")==1) avg	= coviMapperOne.selectOne("attend.job.getJobViewDayAvg", params);
		resultList.put("list",	list);
		resultList.put("avg",	avg);
		resultList.put("page",	page);

		return resultList;
	}


	/**
	 * @Method Name : getAttendJobViewWeek
	 * @Description : 근무일정 주간
	 */
	@Override
	public CoviMap getAttendJobViewWeek(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap avg			= new CoviMap();
		String[][] Weeks = { {"0", "Mon"}, {"1", "Tue"}, {"2", "Wed"}, {"3", "Thu"}, {"4", "Fri"}, {"5", "Sat"}, {"6", "Sun"}};
		params.put("Weeks", Weeks);
		
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		params.put("attendAuth", attendAuth);
		params.put("jobType", jobType);
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.job.getJobViewWeekCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}
		list	= coviMapperOne.list("attend.job.getJobViewWeek", params);
		if (params.get("pageNo") == null || params.getInt("pageNo")==1) avg	= coviMapperOne.selectOne("attend.job.getJobViewWeekAvg", params);
		resultList.put("avg",	avg);
		resultList.put("list",	list);
		resultList.put("page",	page);

		return resultList;
	}


	/**
	 * @Method Name : getAttendJobViewMonth
	 * @Description : 근무일정 월간
	 */
	@Override
	public CoviMap getAttendJobViewMonth(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap avg			= new CoviMap();
		CoviList clMonthlyInfo			= new CoviList();
		CoviMap reqParam = new CoviMap();
		reqParam.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqParam.put("DomainCode", SessionHelper.getSession("DN_ID"));
		reqParam.put("StartDate", params.get("StartDate").toString().replaceAll("-","").substring(0,6));
		reqParam.put("EndDate", params.get("EndDate").toString().replaceAll("-","").substring(0,6));
		int thisYear = Integer.parseInt(params.get("StartDate").toString().replaceAll("-","").substring(0,4));
		int lastYear = thisYear-1;
		reqParam.put("ThisYear", thisYear);
		reqParam.put("LastYear", lastYear);
		
		clMonthlyInfo	= coviMapperOne.list("attend.job.getJobViewMonthlyInfo", reqParam);
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

		if(jObjMonthlyInfo.size()>0){
			int i = 0;
			while (i < jObjMonthlyInfo.size()) {
				sweeknum = Integer.parseInt(((egovframework.baseframework.data.CoviMap)jObjMonthlyInfo.get(i)).getString("StartWeekNum"));
				eweeknum = Integer.parseInt(((egovframework.baseframework.data.CoviMap)jObjMonthlyInfo.get(i)).getString("EndWeekNum"));
				rangeStartDate = ((egovframework.baseframework.data.CoviMap)jObjMonthlyInfo.get(i)).getString("StartDate");
				schStartDate = rangeStartDate;
				rangeEndDate = ((egovframework.baseframework.data.CoviMap)jObjMonthlyInfo.get(i)).getString("EndDate");
				ThisYearWeeksNum = Integer.parseInt(((egovframework.baseframework.data.CoviMap)jObjMonthlyInfo.get(i)).getString("ThisYearWeeksNum"));
				LastYearWeeksNum = Integer.parseInt(((egovframework.baseframework.data.CoviMap)jObjMonthlyInfo.get(i)).getString("LastYearWeeksNum"));
				snum = sweeknum;
				i++;
			}
		}
		if(eweeknum>sweeknum) {
			loopnum = eweeknum - sweeknum;
		}else{//년도 바뀌면 52주 더해서 주차 구함
			loopnum = (eweeknum+LastYearWeeksNum) - sweeknum;
		}
		List<Map<String, String>> listRangeFronToDate = new ArrayList<>();
		List WeeksNum = new ArrayList();
		List WeeksCnt = new ArrayList();
		int tLoop = snum+loopnum;
		int newYearCnt = 1;
		SimpleDateFormat beforeFormat  = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat afterFormat  = new SimpleDateFormat("yyyyMMdd");
		Date Sdate = null;
		Date Edate = null;
		Calendar Cal = Calendar.getInstance();
		Sdate = beforeFormat.parse(schStartDate);
		for(int i=snum;i<=tLoop;i++){
			Cal.setTime(Sdate);
			Cal.add(Calendar.DAY_OF_MONTH, 6);
			Edate = Cal.getTime();

			Map<String, String> newRange = new HashMap<>();
			newRange.put(afterFormat.format(Sdate),afterFormat.format(Edate));
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
		params.put("WeeksNum", WeeksNum);
		params.put("listRangeFronToDate", listRangeFronToDate);
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("DomainCode", SessionHelper.getSession("DN_ID"));
		params.put("StartDate",	rangeStartDate.replaceAll("-",""));
		params.put("EndDate",	rangeEndDate.replaceAll("-",""));

		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		params.put("attendAuth", attendAuth);
		params.put("jobType", jobType);
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.job.getJobViewMonthCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}

		list	= coviMapperOne.list("attend.job.getJobViewMonth", params);

		//엑셀용 데이터 담기
		ArrayList excelList = new ArrayList();
		ArrayList excelHCol	=  new ArrayList();
		for(int z=0;z<list.size();z++) {
			CoviMap excelRow	= new CoviMap();
			List excelCol = new ArrayList();
			CoviMap rowmap = list.getMap(z);
			int TotAttDayAC = 0;
			int TotAttDayEX = 0;
			int TotAttDayHO = 0;
			int TotAttDayTO = 0;
			for (int y=0; y < colNumWeeks; y++) {
				Map<String, String> eRow = new HashMap<>();
				eRow.put("AttDayAC", rowmap.get("AttDayAC_"+y).toString());
				eRow.put("AttDayAC_F",AttendUtils.convertSecToStr(rowmap.get("AttDayAC_"+y).toString(),"H"));
				eRow.put("AttDayEX", rowmap.get("AttDayEX_"+y).toString());
				eRow.put("AttDayEX_F",AttendUtils.convertSecToStr(rowmap.get("AttDayEX_"+y).toString(),"H"));
				eRow.put("AttDayHO", rowmap.get("AttDayHO_"+y).toString());
				eRow.put("AttDayHO_F",AttendUtils.convertSecToStr(rowmap.get("AttDayHO_"+y).toString(),"H"));
				eRow.put("AttDayTO", rowmap.get("AttDayTO_"+y).toString());
				eRow.put("AttDayTO_F",AttendUtils.convertSecToStr(rowmap.get("AttDayTO_"+y).toString(),"H"));
				excelCol.add(eRow);
				TotAttDayAC += Integer.parseInt(rowmap.get("AttDayAC_"+y).toString());
				TotAttDayEX += Integer.parseInt(rowmap.get("AttDayEX_"+y).toString());
				TotAttDayHO += Integer.parseInt(rowmap.get("AttDayHO_"+y).toString());
				if(z==0) {
					Map<String, String> eHCol = new HashMap<>();
					eHCol.put("AttDayStartTime", rowmap.get("AttDayStartTime_" + y).toString());
					eHCol.put("AttDayEndTime", rowmap.get("AttDayEndTime_" + y).toString());
					eHCol.put("AttDayWeeksNum", rowmap.get("AttDayWeeksNum_" + y).toString());
					excelHCol.add(eHCol);
				}
			}
			TotAttDayTO = TotAttDayAC+TotAttDayEX+TotAttDayHO;
			excelRow.put("excelCol",excelCol);
			excelRow.put("UserCode",rowmap.get("UserCode"));
			excelRow.put("UserName",rowmap.get("UserName"));
			excelRow.put("JobTitleName",rowmap.get("JobTitleName"));
			excelRow.put("DeptName",rowmap.get("DeptName"));
			excelRow.put("JobLevelName",rowmap.get("JobLevelName"));
			excelRow.put("JobPositionName",rowmap.get("JobPositionName"));
			excelRow.put("TotAttDayAC",TotAttDayAC);
			excelRow.put("TotAttDayAC_F",AttendUtils.convertSecToStr(TotAttDayAC,"H"));
			excelRow.put("TotAttDayEX",TotAttDayEX);
			excelRow.put("TotAttDayEX_F",AttendUtils.convertSecToStr(TotAttDayEX,"H"));
			excelRow.put("TotAttDayHO",TotAttDayHO);
			excelRow.put("TotAttDayHO_F",AttendUtils.convertSecToStr(TotAttDayHO,"H"));
			excelRow.put("TotAttDayTO",TotAttDayTO);
			excelRow.put("TotAttDayTO_F",AttendUtils.convertSecToStr(TotAttDayTO,"H"));
			excelList.add(excelRow);
		}
		//-->

		resultList.put("list",	list);
		resultList.put("page",	page);
		resultList.put("colNumWeeks",	colNumWeeks);
		resultList.put("weeksNum",	WeeksNum);
		resultList.put("weeksCnt", WeeksCnt);
		resultList.put("rangeStartDate",	rangeStartDate);
		resultList.put("rangeEndDate",	rangeEndDate);
		resultList.put("listRangeFronToDate", listRangeFronToDate);
		resultList.put("ThisYearWeeksNum",	ThisYearWeeksNum);
		resultList.put("LastYearWeeksNum",	LastYearWeeksNum);
		resultList.put("excelList",	excelList);
		resultList.put("excelHCol",	excelHCol);
		//if (params.get("pageNo") == null || params.getInt("pageNo")==1) avg	= coviMapperOne.selectOne("attend.job.getJobViewWeekAvg", params);
		resultList.put("avg",	avg);

		return resultList;
	}


	/**
	 * @Method Name : getAttendJobViewMonthlyInfo
	 * @Description : 근무일정 월간
	 */
	public CoviMap getAttendJobViewMonthlyInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();
		
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		params.put("attendAuth", attendAuth);
		params.put("jobType", jobType);
		
		list	= coviMapperOne.list("attend.job.getJobViewMonthlyInfo", params);
		resultList.put("list",	list);

		return resultList;
	}

	@Override
	public List<CoviMap> getWorkPlaceList(CoviMap params) throws Exception {
		List<CoviMap> result;
		result = coviMapperOne.list("attend.schedule.getAddWorkPlaceList", params);

		return result;
	}

	public String getUserAuthType() throws Exception {
		String attendAuth = "";
		String domainID =  SessionHelper.getSession("DN_ID");
		
		//근태관리 관리자 권한조회
		if(ACLHelper.getExitsUserGroup(SessionHelper.getSession(), domainID+"_Attendance_Admin")) {
			attendAuth = "ADMIN";
		}else{	
			attendAuth = "USER";
		}	

		return attendAuth;
	}
	
	public String getUserJobAuthType() throws Exception {
		String jobType = "";
		String jobTitle =  SessionHelper.getSession("UR_JobTitleCode");	//직책코드
		/**
		 * 사용자 권한은 조직도 내 직책에 따라 조회 가능 부서가 다름
		 * 본부장 : 본인부서 포함 본인부서 하위 부서 리스트 조회 가능
		 * 팀장 : 본인부서만 조회 가능
		 **/
		String gmJobArray = RedisDataUtil.getBaseConfig("AttendanceGMJobTiltle");	//기초설정코드  본부장 구분
		String tmJobArray = RedisDataUtil.getBaseConfig("AttendanceTMJobTiltle");	//기초설정코드 팀장 구분
		StringTokenizer tmJob = new StringTokenizer(tmJobArray, "|");
		StringTokenizer gmJob = new StringTokenizer(gmJobArray, "|");
		jobType = "USER";
		
		// 팀장 권한 확인
		while(tmJob.hasMoreTokens()) {
			String strJobTitle = tmJob.nextToken();
			if(jobTitle.equalsIgnoreCase(strJobTitle)) {
				jobType = "TEAM";
				break;
			}
		}
		
		// 본부장 권한 확인 
		// 팀잠,본부장 동시 권한일 시 본부장 권한 조회
		while(gmJob.hasMoreTokens()) {
			String strJobTitle = gmJob.nextToken();
			if(jobTitle.equalsIgnoreCase(strJobTitle)) {
				jobType = "DEVISION";
				break; 
			}
		}
		
		return jobType;
	}
}
