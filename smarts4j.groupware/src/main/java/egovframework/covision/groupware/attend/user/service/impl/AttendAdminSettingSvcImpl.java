package egovframework.covision.groupware.attend.user.service.impl;


import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.covision.groupware.attend.user.service.AttendAdminSettingSvc;

@Service("AttendAdminSettingSvc") 
public class AttendAdminSettingSvcImpl extends EgovAbstractServiceImpl implements AttendAdminSettingSvc {

	private static final Logger LOGGER = LogManager.getLogger(AttendAdminSettingSvc.class);
	
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
 
	@Override
	public int insertWorkInfo(CoviMap params) throws Exception {
		params.put("RegUserCode", SessionHelper.getSession("USERID"));
		return coviMapperOne.insert("attend.adminSetting.insertWorkInfo", params);
	} 
	@Override
	public CoviMap getWorkInfoList(CoviMap params) throws Exception {
		CoviMap resultObject = new CoviMap();
		CoviMap page = new CoviMap();
		
		params.put("CompanyCode", SessionHelper.getSession("DN_Code")); 
		params.put("lang", SessionHelper.getSession("lang"));
		
		if(params.containsKey("pageNo")) {
			int cnt = (int)coviMapperOne.getNumber("attend.adminSetting.getWorkInfoListCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultObject.put("page", page);
 			resultObject.put("cnt", cnt); 
 		}
			
		CoviList workInfoList = coviMapperOne.list("attend.adminSetting.getWorkInfoList", params);		
		resultObject.put("list", CoviSelectSet.coviSelectJSON(workInfoList, "UserCode,DisplayName,DeptName,WorkWeek,WorkTime,WorkCode,UnitTerm,WorkApplyDate,MaxWorkTime,MaxWorkCode,MaxUnitTerm,MaxWorkApplyDate,ApplyDate,ListType,ValidYn,PID,_PID"));
		  
		return resultObject;
	}
	@Override
	public CoviMap getWorkInfoDetail(CoviMap params) throws Exception {
		CoviMap resultObject = new CoviMap();
		params.put("CompanyCode", SessionHelper.getSession("DN_Code")); 
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList workInfoList = coviMapperOne.list("attend.adminSetting.getWorkInfoDetail", params);	
 
		resultObject.put("list", CoviSelectSet.coviSelectJSON(workInfoList, "UserCode,DisplayName,DeptName,WorkWeek,WorkTime,WorkCode,UnitTerm,WorkApplyDate,MaxWorkTime,MaxWorkCode,MaxUnitTerm,MaxWorkApplyDate,MaxWeekWorkTime,ApplyDate,ListType,ValidYn,PID,_PID,UserName"));
		  
		return resultObject;
	}
	@Override
	public int updateWorkInfo(CoviMap params) throws Exception {
		params.put("RegUserCode", SessionHelper.getSession("USERID"));
		return coviMapperOne.insert("attend.adminSetting.updateWorkInfo", params);
	}

	@Override
	public CoviMap getAttendMngMst() throws Exception {
		CoviMap params = new CoviMap();
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		
		return coviMapperOne.selectOne("attend.adminSetting.getAttendMngMst", params);		
	}

	@Override
	public CoviMap getCompanySetting() throws Exception {
		CoviMap resultObject = new CoviMap();
		CoviMap params = new CoviMap();
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		
		/**
		 * @Date : 2020-04-09
		 * @author sjhan0418
		 * 회사 설정 정보가 기초설정 코드로 대체됨 ( cache server 사용을 위함 )  
		 * 출퇴근 기능 설정 정보 조회를 위해 MST테이블 조회가 필요함
		 * */
		CoviMap mngMstMap = coviMapperOne.selectOne("attend.adminSetting.getAttendMngMst", params);			
		params.put("AttSeq", mngMstMap.getString("AttSeq"));

		/*IP설정 조회*/
		CoviList ipList = getIpList(params);
		/*간주*/
		CoviList assList = coviMapperOne.list("attend.adminSetting.getAssList", params);	

		/*휴게시간*/
		params.put("RewardCode", "rest");
		CoviList restList = coviMapperOne.list("attend.adminSetting.getRewardVacList", params);	
		
		/*보상휴가*/
		params.put("RewardCode", "reward");
		params.put("HolidayFlag","1");
		CoviList rewardList = coviMapperOne.list("attend.adminSetting.getRewardVacList", params);	
		params.put("HolidayFlag","0");
		CoviList rewardListHoli = coviMapperOne.list("attend.adminSetting.getRewardVacList", params);	
		params.put("HolidayFlag","2");
		CoviList rewardListOff = coviMapperOne.list("attend.adminSetting.getRewardVacList", params);	
		
		StringBuffer sb = new StringBuffer();
		sb.append("AttSeq"); 
		sb.append(",CompanyCode");
		sb.append(",RewardCode");
		sb.append(",HolidaYn");
		sb.append(",OverTime"); 
		sb.append(",RewardTime");
		sb.append(",OverTimeHour");
		sb.append(",OverTimeMin");
		sb.append(",RewardTimeHour");
		sb.append(",RewardTimeMin");
		sb.append(",MethodType");
		sb.append(",RewardUnit");
		sb.append(",RewardNTime");		
		
		resultObject.put("mngMstMap", getAttendMngMst() );
		
		resultObject.put("ipList", CoviSelectSet.coviSelectJSON(ipList,"IpSeq,SIp,EIp,ValidYn,PcUsedYn,MobileUsedYn,Etc") );
		resultObject.put("assList", CoviSelectSet.coviSelectJSON(assList, "AssSeq,AssName,AssWorkTime,SchSeq"));
		
		resultObject.put("rewardList", CoviSelectSet.coviSelectJSON(rewardList, sb.toString()) );
		resultObject.put("rewardListHoli", CoviSelectSet.coviSelectJSON(rewardListHoli, sb.toString()) );
		resultObject.put("rewardListOff", CoviSelectSet.coviSelectJSON(rewardListOff, sb.toString()) );
		resultObject.put("restList", CoviSelectSet.coviSelectJSON(restList, sb.toString()));
		
		return resultObject;  
	}
	
	@Override
	public int setAttendMngMst(CoviMap params) throws Exception {
		params.put("RegUserCode", SessionHelper.getSession("USERID"));
		return coviMapperOne.update("attend.adminSetting.setAttendMngMst",params);
	}
	
	@Override
	public int setIpMng(CoviMap params) throws Exception {
		params.put("RegUserCode", SessionHelper.getSession("USERID"));
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		return coviMapperOne.update("attend.adminSetting.setIpMng",params);
	}

	
	@Override
	@Transactional
	public void setCompanySetting(CoviMap jo) throws Exception {
		
		CoviMap mngMstMap = getAttendMngMst();	
		String AttSeq = mngMstMap.getString("AttSeq");
		
		CoviList configList = jo.getJSONArray("configList");

		for(int i=0;i<configList.size();i++){
			CoviMap config = configList.getJSONObject(i);
			
			CoviMap params = new CoviMap();
			params.put("SettingKey", config.getString("SettingKey"));
			params.put("SettingValue", config.getString("SettingValue"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			params.put("UserCode",SessionHelper.getSession("USERID"));

			coviMapperOne.update("attend.adminSetting.setCompanySetting",params);
		}

		String CompanyCode = SessionHelper.getSession("DN_Code");
		String UserCode    = SessionHelper.getSession("USERID");
		
		CoviList ja = jo.getJSONArray("assList");
		for(Object o : ja){
			CoviMap assObject = (CoviMap) o;
			CoviMap assMap = new CoviMap();
			assMap.put("CompanyCode", CompanyCode);
			assMap.put("UserCode", UserCode);
			if (assObject.getString("AssMode").equals("D")){
				assMap.put("AssSeq", assObject.getString("AssSeq"));
				coviMapperOne.update("attend.adminSetting.deleteAss",assMap);
			}
			else if (assObject.getString("AssMode").equals("U")){
				assMap.put("AssSeq", assObject.getString("AssSeq"));
				assMap.put("AssName", assObject.getString("AssName"));
				assMap.put("AssWorkTime", assObject.getString("AssWorkTime"));
				coviMapperOne.update("attend.adminSetting.saveAss",assMap);
				
			}
			else{
				assMap.put("AssName", assObject.getString("AssName"));
				assMap.put("AssWorkTime", assObject.getString("AssWorkTime"));
				coviMapperOne.update("attend.adminSetting.addAss",assMap);
				
			}
		}
		
		/*일괄 등록 시 기존 등록건 삭제 후 재등록!!*/
		delRewardVac();
		setRewardVac(jo.getJSONArray("rewardList"));
		setRewardVac(jo.getJSONArray("rewardHoliList"));
		setRewardVac(jo.getJSONArray("rewardOffList"));
		setRewardVac(jo.getJSONArray("restList"));
		
		/*ip일괄 등록 시 기존 등록 건 삭제후 재등록!!*/
		CoviMap ipParams = new CoviMap();
		ipParams.put("AttSeq", AttSeq);
		coviMapperOne.delete("attend.adminSetting.deleteIpMst",ipParams);
		CoviList ipList = jo.getJSONArray("ipList");
		for(int i=0;i<ipList.size();i++){
			CoviMap ipJo = ipList.getJSONObject(i);
			ipParams.put("AttSeq", AttSeq);
			ipParams.put("SIp", ipJo.getString("SIp"));
			ipParams.put("EIp", ipJo.getString("EIp"));
			ipParams.put("PcUsedYn", ipJo.getString("PcUsedYn"));
			ipParams.put("MobileUsedYn", ipJo.getString("MobileUsedYn"));
			ipParams.put("Etc", ipJo.getString("Etc"));
			setIpMng(ipParams);
		}
		
		/*회사 기본정보 수정 ( 출퇴근 기능 ) */
		CoviMap mngMstObj = jo.getJSONObject("mngMstObj");
		CoviMap mngMstParamMap = new CoviMap();
		mngMstParamMap.put("AttSeq", AttSeq);
		mngMstParamMap.put("PcUseYn", mngMstObj.getString("PcUseYn"));
		mngMstParamMap.put("MobileUseYn", mngMstObj.getString("MobileUseYn"));
		mngMstParamMap.put("OthYn", mngMstObj.getString("OthYn"));
		mngMstParamMap.put("IpYn", mngMstObj.getString("IpYn"));

		mngMstParamMap.put("LateSendYn", mngMstObj.getString("LateSendYn"));
		mngMstParamMap.put("AbsentSendYn", mngMstObj.getString("AbsentSendYn"));
		mngMstParamMap.put("EarlySendYn", mngMstObj.getString("EarlySendYn"));
		mngMstParamMap.put("CallingSendYn", mngMstObj.getString("CallingSendYn"));
		mngMstParamMap.put("MailTitle", mngMstObj.getString("MailTitle"));
		mngMstParamMap.put("MailBody", mngMstObj.getString("MailBody"));
		mngMstParamMap.put("AttendPolicy", mngMstObj.getString("AttendPolicy"));
		setAttendMngMst(mngMstParamMap);
	}


	@Override
	@Transactional
	public void setCompanySettingForVacations(CoviMap jo) throws Exception {

		CoviList configList = jo.getJSONArray("configList");

		for(int i=0;i<configList.size();i++){
			CoviMap config = configList.getJSONObject(i);

			CoviMap params = new CoviMap();
			params.put("SettingKey", config.getString("SettingKey"));
			params.put("SettingValue", config.getString("SettingValue"));
			params.put("DN_ID", SessionHelper.getSession("DN_ID"));
			params.put("UserCode",SessionHelper.getSession("USERID"));

			coviMapperOne.update("attend.adminSetting.setCompanySettingForVacation",params);
		}


	}
	

	@Override
	public int setRewardVac(CoviMap params) throws Exception {
		return coviMapperOne.update("attend.adminSetting.setRewardVac",params);
	}
	
	@Override
	public int setRewardVac(CoviList ja) throws Exception {
		String CompanyCode = SessionHelper.getSession("DN_Code");
		int cnt = 0;
		for(Object o : ja){
			CoviMap jo = (CoviMap) o;
			CoviMap rewardMap = new CoviMap();
			rewardMap.put("CompanyCode", CompanyCode);
			rewardMap.put("RewardCode", jo.getString("RewardCode"));
			rewardMap.put("HolidayFlag", jo.getString("HolidayFlag"));
			rewardMap.put("OverTime",jo.getInt("OverTimeHour")*60+jo.getInt("OverTimeMin"));
			if (jo.get("MethodType")!=null && jo.getString("MethodType").equals("RATE")){
				rewardMap.put("RewardTime",jo.getDouble("RewardTime"));
				rewardMap.put("RewardNTime",jo.getDouble("RewardNTime"));
			}	
			else
				rewardMap.put("RewardTime",jo.getInt("RewardTimeHour")*60+jo.getInt("RewardTimeMin"));
			setRewardVac(rewardMap);
			cnt ++;
		}
		return cnt;
	}
	
	@Override
	public int delRewardVac(CoviMap params) throws Exception {
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		return coviMapperOne.update("attend.adminSetting.deleteRewardVac",params);
	}
	
	@Override
	public int delRewardVac() throws Exception {
		CoviMap params = new CoviMap();
		return delRewardVac(params);
	}

	

	@Override
	public CoviMap checkExcelWorkInfoData(ArrayList<ArrayList<Object>> dataList) throws Exception {
		CoviMap returnJson = new CoviMap();
		
		//검증데이터 파싱
		CoviList exArry = new CoviList();
		
		String uploadYn = "Y"; //엑셀데이터에 문제가 없어야 업로드 가능하도록
		
		CoviList workcodeStr = RedisDataUtil.getBaseCode("WorkCode");
		CoviList unittermStr = RedisDataUtil.getBaseCode("UnitTerm");
		
		String attBaseWeek = RedisDataUtil.getBaseConfig("AttBaseWeek");
		
		for (int i=0;i< dataList.size();i++) {
			CoviMap exObj = new CoviMap();
			
			LOGGER.debug(dataList.get(i));
			ArrayList<Object> tempList = dataList.get(i);
			//<!-- 2022.01.04 nkpark 업로드 엑셀 약식 널 체크 공백 로우 체크
			if(tempList.size()!=5){
				continue;
			}
			boolean nullCk = false;
			for(int k=0;k<5;k++){
				String tempVal = String.valueOf(tempList.get(k));
				if(tempVal==null || tempVal.equals("")){
					nullCk = true;
					break;
				}
			}
			if(nullCk){continue;}
			//-->
			String ex_UserCode = String.valueOf(tempList.get(0));
			String ex_WorkWeek = String.valueOf(tempList.get(1));
			String ex_WorkRule = String.valueOf(tempList.get(2));
			String ex_MaxWorkRule = String.valueOf(tempList.get(3));
			String ex_ApplyDate = String.valueOf(tempList.get(4));
			
			// 소정근로요일 데이터 확인
			CoviMap workWeekObj = chkWorkWeek(ex_WorkWeek);
			
			String WorkWeek_valid = workWeekObj.getString("WorkWeek_valid");
			String WorkWeek = workWeekObj.getString("WorkWeek");
			
			//소정근로 규칙 데이터 확인
			String WorkRule_valid = "Y";
			
			String WorkTime = null;
			String WorkCode = null;
			String UnitTerm = null;
			String WorkApplyDate = null;
			
			if(!"".equals(ex_WorkRule)){
				String[] ar_WorkRule = ex_WorkRule.split("/");
				if(ar_WorkRule.length == 4){
					WorkTime = ar_WorkRule[0];
					WorkCode = ar_WorkRule[1];
					UnitTerm = ar_WorkRule[2];
					WorkApplyDate = ar_WorkRule[3];
					CoviMap chkObj = chkRuleParam(ar_WorkRule,workcodeStr,unittermStr,attBaseWeek);
					if(!chkObj.getBoolean("flag")){
						WorkRule_valid = "N";
					}else{
						WorkApplyDate = chkObj.getString("adDate");
					}
				}else{
					WorkRule_valid = "N";
				}
			}else{
				WorkRule_valid = "N";
			}
			if("Y".equals(WorkRule_valid) ){
				ex_WorkRule = WorkTime+"/"+WorkCode+"/"+UnitTerm+"/"+WorkApplyDate;
			}
			
			//소정근로 규칙 데이터 확인
			String MaxWorkRule_valid = "Y";
			
			String MaxWorkTime = null;
			String MaxWorkCode = null;
			String MaxUnitTerm = null;
			String MaxWorkApplyDate = null;
			String MaxWeekWorkTime = null;
			
			if(!"".equals(ex_MaxWorkRule)){
				String[] ar_MaxWorkRule = ex_MaxWorkRule.split("/");
				if(ar_MaxWorkRule.length == 5){
					MaxWorkTime = ar_MaxWorkRule[0];
					MaxWorkCode = ar_MaxWorkRule[1];
					MaxUnitTerm = ar_MaxWorkRule[2];
					MaxWorkApplyDate = ar_MaxWorkRule[3];
					MaxWeekWorkTime = ar_MaxWorkRule[4];

					CoviMap chkObj = chkMaxRuleParam(ar_MaxWorkRule,workcodeStr,unittermStr,attBaseWeek);
					if(!chkObj.getBoolean("flag")){
						MaxWorkRule_valid = "N";
					}else{
						MaxWorkApplyDate = chkObj.getString("adDate");
					}
					
				}else{
					MaxWorkRule_valid = "N";
				}
			}else{ 
				MaxWorkRule_valid = "N";
			}
			if("Y".equals(MaxWorkRule_valid) ){
				ex_MaxWorkRule = MaxWorkTime+"/"+MaxWorkCode+"/"+MaxUnitTerm+"/"+MaxWorkApplyDate+"/"+MaxWeekWorkTime;
			}
			
			//적용시점 데이터 날짜 유효성검사
			String ApplyDate_valid = dateTypeValidCheck(ex_ApplyDate,"yyyy-MM-dd")?"Y":"N";

			exObj.put("UserCode",ex_UserCode);
			exObj.put("WorkWeek",WorkWeek);
			exObj.put("WorkTime",WorkTime);
			exObj.put("WorkCode",WorkCode);
			exObj.put("UnitTerm",UnitTerm);
			exObj.put("WorkApplyDate",WorkApplyDate);
			exObj.put("MaxWorkTime",MaxWorkTime);
			exObj.put("MaxWorkCode",MaxWorkCode);
			exObj.put("MaxUnitTerm",MaxUnitTerm);
			exObj.put("MaxWorkApplyDate",MaxWorkApplyDate);
			exObj.put("MaxWeekWorkTime",MaxWeekWorkTime);
			exObj.put("ApplyDate",ex_ApplyDate);
			
			exObj.put("ex_WorkWeek",ex_WorkWeek);
			exObj.put("ex_WorkRule",ex_WorkRule);
			exObj.put("ex_MaxWorkRule",ex_MaxWorkRule);

			
			exObj.put("WorkWeek_valid",WorkWeek_valid);
			exObj.put("WorkRule_valid",WorkRule_valid);
			exObj.put("MaxWorkRule_valid",MaxWorkRule_valid);
			exObj.put("ApplyDate_valid",ApplyDate_valid);
			
			exArry.add(exObj);
		}
		
		CoviMap ckParams = new CoviMap();
		ckParams.put("workInfoList", exArry);
		ckParams.put("DN_ID", SessionHelper.getSession("DN_ID"));
		ckParams.put("lang", SessionHelper.getSession("lang"));
		
		if ( exArry != null && exArry.size() > 0 ) {
			//사용자와 적용시점 중복 불가 
			CoviList workInfoList = coviMapperOne.list("attend.adminSetting.chkWorkInfoDataValue", ckParams);
			for(int i=0;i<workInfoList.size();i++){
				CoviMap wMap = workInfoList.getMap(i);
				if("N".equals(wMap.get("userCode_validYn"))||"N".equals(wMap.get("applyDate_validYn")) 
						||"N".equals(wMap.get("WorkWeek_valid"))||"N".equals(wMap.get("WorkRule_valid"))
						||"N".equals(wMap.get("MaxWorkRule_valid"))||"N".equals(wMap.get("ApplyDate_valid"))){
					uploadYn = "N";
				}
			}
			
			returnJson.put("list", CoviSelectSet.coviSelectJSON(workInfoList, "UserCode,UserName,ApplyDate,WorkWeek,WorkTime,WorkCode,UnitTerm,WorkApplyDate,MaxWorkTime,MaxWorkCode,MaxUnitTerm,MaxWorkApplyDate,MaxWeekWorkTime,WorkWeek_valid,WorkRule_valid,MaxWorkRule_valid,ex_WorkWeek,ex_WorkRule,ex_MaxWorkRule,userCode_validYn,applyDate_validYn"));
		} else {
			uploadYn = "N";
		}
		returnJson.put("uploadYn",uploadYn);
		return returnJson;
	} 
	
	private CoviMap chkWorkWeek(String workWeek){
		CoviMap returnObj = new CoviMap();
		
		String WorkWeek_valid = "Y";
		StringBuilder sb = new StringBuilder("0000000");
		String[] ar_WorkWeek = workWeek.split(",");
		for(String str : ar_WorkWeek){
			str = str.trim();
			
			if("월".equals(str)) { sb.setCharAt(0, '1');}
			else if("화".equals(str)) { sb.setCharAt(1, '1');}
			else if("수".equals(str)) { sb.setCharAt(2, '1');}
			else if("목".equals(str)) { sb.setCharAt(3, '1');}
			else if("금".equals(str)) { sb.setCharAt(4, '1');}
			else if("토".equals(str)) { sb.setCharAt(5, '1');}
			else if("일".equals(str)) { sb.setCharAt(6, '1');}
			else{
				WorkWeek_valid = "N";
			}
		}
		
		returnObj.put("WorkWeek", sb.toString());
		returnObj.put("WorkWeek_valid", WorkWeek_valid);
		
		return returnObj;
	}
	
	private boolean dateTypeValidCheck(String date,String format){
		boolean flag = true;
		SimpleDateFormat df = new SimpleDateFormat(format);
		df.setLenient(false);
		try {
			Date dt = df.parse(date);
		}catch(ParseException pe){
			flag = false;
		}catch(IllegalArgumentException ae){
			flag = false;
		}
		return flag;
	}
	private int getDayOfWeek(String date,String format){
		int dayOfWeek = 0;
		
		Calendar cal = Calendar.getInstance();
		try {
			cal.setTime(new SimpleDateFormat(format).parse(date));
		} catch (ParseException e) {
			LOGGER.warn(e.getLocalizedMessage(), e);
		}
		
		dayOfWeek = cal.get(Calendar.DAY_OF_WEEK) ;
		
		return dayOfWeek;
	}
	private CoviMap chkRuleParam(String[] ruleParam,CoviList workcodeStr,CoviList unittermStr,String attBaseWeek){
		
		boolean returnFlag = true;
		
		String wc = ruleParam[0];
		String wd = ruleParam[1];
		String ut = ruleParam[2];
		String ad = ruleParam[3];
		
		
		String pUnit = "";

		String regExp = "^[0-9]*$";
		if(!wc.matches(regExp)){
			returnFlag = false;
		}
		
		boolean wdFlag = true;
		for(int i=0;i<workcodeStr.size();i++){
			CoviMap wcObj = workcodeStr.getJSONObject(i);
			if(wcObj.getString("CodeName").equals(wd)){
				wdFlag = false;
			}
		}
		if(wdFlag){
			returnFlag = false;			
		}

		boolean utFlag = true;
		for(int i=0;i<unittermStr.size();i++){
			CoviMap unObj = unittermStr.getJSONObject(i);
			if(unObj.getString("CodeName").equals(ut)){
				utFlag = false;
				pUnit = unObj.getString("Reserved2");
			}
		}
		if(utFlag){
			returnFlag = false;			
		}
		
		/*
		 * 단위기간 별 적용일자 조정
		 * script 에서 막지만.. 데이터 무결성을 위해 한번 더 검증..
		 * */
		String adDate = ad;
		boolean adFlag = dateTypeValidCheck(adDate,"yyyy-MM-dd");
		//System.out.println(adFlag);
		//System.out.println(pUnit);
		if(adFlag){
			//단위기간이 일인 경우 적용 일자 정보 제한 없음
			if("day".equals(pUnit)){
				
			}else if("week".equals(pUnit)){ // 단위기간이 주인 경우 적용시점이 관리자 설정 조회 기준요일과 다르면 조회기준요일로 설정 
				if( getDayOfWeek(ad, "yyyy-MM-dd") != Integer.parseInt(attBaseWeek)) {
					SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd");
			 		Calendar c = Calendar.getInstance();
			 		String[] adSp = ad.split("-");
			 		int y=Integer.parseInt(adSp[0]);
			 		int m=Integer.parseInt(adSp[1])-1;
			 		
			 		c.set(Calendar.YEAR,y);
			 		c.set(Calendar.MONTH,m);
			 		c.set(Calendar.DAY_OF_WEEK,Integer.parseInt(attBaseWeek));
	
			 		adDate = formatter.format(c.getTime());
				}
			}else if("month".equals(pUnit)){ // 단위기간이 월인 경우 적용시점은 지정일 1일 
				String[] adSp = ad.split("-");
				adDate = adSp[0]+"-"+adSp[1]+"-"+"01";	
			}
		}else {
			returnFlag = false;			
		}
		

		CoviMap reutrnObject = new CoviMap();
		reutrnObject.put("flag", returnFlag);
		reutrnObject.put("adDate", adDate);
		return reutrnObject;
	}
	
	private CoviMap chkMaxRuleParam(String[] ruleParam,CoviList workcodeStr,CoviList unittermStr,String attBaseWeek){
		
		boolean returnFlag = true;
		
		String wc = ruleParam[0];
		String wd = ruleParam[1];
		String ut = ruleParam[2];
		String ad = ruleParam[3];
		String wt = ruleParam[4];
		
		
		String pUnit = "";

		String regExp = "^[0-9]*$";
		if(!wc.matches(regExp) || !wt.matches(regExp)){
			returnFlag = false;
		}
		
		boolean wdFlag = true;
		for(int i=0;i<workcodeStr.size();i++){
			CoviMap wcObj = workcodeStr.getJSONObject(i);
			if(wcObj.getString("CodeName").equals(wd)){
				wdFlag = false;
			}
		}
		if(wdFlag){
			returnFlag = false;			
		}

		boolean utFlag = true;
		for(int i=0;i<unittermStr.size();i++){
			CoviMap unObj = unittermStr.getJSONObject(i);
			if(unObj.getString("CodeName").equals(ut)){
				utFlag = false;
				pUnit = unObj.getString("Reserved2");
			}
		}
		if(utFlag){
			returnFlag = false;			
		}
		
		/*
		 * 단위기간 별 적용일자 조정
		 * script 에서 막지만.. 데이터 무결성을 위해 한번 더 검증..
		 * */
		String adDate = ad;
		boolean adFlag = dateTypeValidCheck(adDate,"yyyy-MM-dd");
		//System.out.println(adFlag);
		//System.out.println(pUnit);
		if(adFlag){
			//단위기간이 일인 경우 적용 일자 정보 제한 없음
			if("day".equals(pUnit)){
				
			}else if("week".equals(pUnit)){ // 단위기간이 주인 경우 적용시점이 관리자 설정 조회 기준요일과 다르면 조회기준요일로 설정 
				if( getDayOfWeek(ad, "yyyy-MM-dd") != Integer.parseInt(attBaseWeek)) {
					SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd");
			 		Calendar c = Calendar.getInstance();
			 		String[] adSp = ad.split("-");
			 		int y=Integer.parseInt(adSp[0]);
			 		int m=Integer.parseInt(adSp[1])-1;
			 		
			 		c.set(Calendar.YEAR,y);
			 		c.set(Calendar.MONTH,m);
			 		c.set(Calendar.DAY_OF_WEEK,Integer.parseInt(attBaseWeek));
	
			 		adDate = formatter.format(c.getTime());
				}
			}else if("month".equals(pUnit)){ // 단위기간이 월인 경우 적용시점은 지정일 1일 
				String[] adSp = ad.split("-");
				adDate = adSp[0]+"-"+adSp[1]+"-"+"01";	
			}
		}else {
			returnFlag = false;			
		}
		

		CoviMap reutrnObject = new CoviMap();
		reutrnObject.put("flag", returnFlag);
		reutrnObject.put("adDate", adDate);
		return reutrnObject;
	}
	private String changeWorkCode(String WorkCode,CoviList workcodeStr){
		
		String returnStr = "";
		for(int i=0;i<workcodeStr.size();i++){
			CoviMap wcObj = workcodeStr.getJSONObject(i);
			if(wcObj.getString("CodeName").equals(WorkCode)){
				returnStr = wcObj.getString("Code");
				break;
			}
		}
		
		return returnStr;
	}
	private String changeUnitTerm(String UnitTerm,CoviList unittermStr){
		
		String returnStr = "";
		for(int i=0;i<unittermStr.size();i++){
			CoviMap utObj = unittermStr.getJSONObject(i);
			if(utObj.getString("CodeName").equals(UnitTerm)){
				returnStr = utObj.getString("Code");
				break;
			}
		}
		
		return returnStr;
	}


	@Override
	public int insertWorkInfoExcel(CoviList ja) throws Exception{
		CoviList workcodeStr = RedisDataUtil.getBaseCode("WorkCode");
		CoviList unittermStr = RedisDataUtil.getBaseCode("UnitTerm");
		
		CoviList returnArray = new CoviList();
		
		String regUserCode = SessionHelper.getSession("USERID");
		
		for(int i=0;i<ja.size();i++){
			CoviMap jo = ja.getJSONObject(i);
 
			jo.put("ListType", "UR");
			jo.put("ValidYn", "Y");
			/*jo.put("UserCode", jo.get("UserCode"));
			jo.put("ApplyDate", jo.get("ApplyDate"));
			jo.put("WorkWeek", jo.get("WorkWeek"));
			jo.put("WorkTime", jo.get("WorkTime"));*/
			jo.put("WorkCode", changeWorkCode(jo.getString("WorkCode"),workcodeStr));
			jo.put("UnitTerm", changeUnitTerm(jo.getString("UnitTerm"),unittermStr));
			/*jo.put("MaxWorkTime", jo.get("MaxWorkTime"));*/
			jo.put("MaxWorkCode", changeWorkCode(jo.getString("MaxWorkCode"),workcodeStr));
			jo.put("MaxUnitTerm", changeUnitTerm(jo.getString("MaxUnitTerm"),unittermStr));
			/*jo.put("MaxWorkTime", jo.get("MaxWorkTime"));*/
			
			jo.put("RegUserCode", regUserCode);

			returnArray.add(jo);
		} 
		CoviMap params = new CoviMap();
		params.put("workInfoParams", returnArray);
		return insertWorkInfo(params); 
	}


	@Override
	public CoviMap checkInsertWorkInfoData(CoviMap params) throws Exception {
		CoviMap returnJson = new CoviMap();
		
		params.put("lang", SessionHelper.getSession("lang"));
		CoviList workInfoList = coviMapperOne.list("attend.adminSetting.chkWorkInfo", params);
		returnJson.put("list", CoviSelectSet.coviSelectJSON(workInfoList, "TargetName,ListType"));
		return returnJson; 
	}

	@Override
	public int deleteWorkInfo(CoviMap params) throws Exception {
		return coviMapperOne.delete("attend.adminSetting.deleteWorkInfo", params);
	} 

	@Override
	public CoviMap getHolidayList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
 		
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("attend.adminSetting.getHolidayListCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}
		
		CoviList holidayList = coviMapperOne.list("attend.adminSetting.getHolidayList",params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(holidayList,"CompanyCode,HolidayStart,HolidayEnd,HolidayName,GoogleYn,Etc"));
		
		return resultList;
	}

	@Override 
	public void createHoliday(CoviMap params) throws Exception {
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("UserCode", SessionHelper.getSession("USERID"));
		coviMapperOne.insert("attend.adminSetting.createHoliday",params);
	}

	@Override
	public int deleteHoliday(CoviMap params) throws Exception {
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		coviMapperOne.delete("attend.adminSetting.deleteHoliday",params);
		CoviMap item = new CoviMap();
		item.put("TrgDates", params.get("HolidayStart"));
		item.put("CompanyCode", params.get("CompanyCode"));
		coviMapperOne.update("attend.job.createScheduleOffCancel", item);
		int RetCount = 0;
		RetCount = item.getInt("RetCount");
		return RetCount;
	}


	@Override
	public CoviMap getOtherJobList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
 		
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("attend.adminSetting.getOtherJobListCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}
		
		CoviList otherJobList = coviMapperOne.list("attend.adminSetting.getOtherJobList",params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(otherJobList,"JobStsSeq,JobStsName,ValidYn,Memo,ReqMethod,UpdMethod,DelMethod,MultiDisplayName"));
 
		return resultList;
	}


	@Override
	public int setOtherJob(CoviMap params) throws Exception {
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		params.put("RegUserCode", SessionHelper.getSession("USERID"));
		return coviMapperOne.insert("attend.adminSetting.setOtherJob", params);
	}


	@Override
	public int delteOtherJob(CoviMap params) throws Exception {
		return coviMapperOne.delete("attend.adminSetting.deleteOtherJob", params);
	}

	@Override
	public CoviList getIpList(CoviMap params) throws Exception {
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		return coviMapperOne.list("attend.adminSetting.getIpList",params);	
	}

	@Override
	public CoviMap getWorkPlaceList(CoviMap params) throws Exception {
		CoviMap resultObject = new CoviMap();
		CoviMap page = new CoviMap();
 		
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int)coviMapperOne.getNumber("attend.adminSetting.getWorkPlaceListCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultObject.put("page", page);
 			resultObject.put("cnt", cnt);
 		}
		
		CoviList workPlaceList = coviMapperOne.list("attend.adminSetting.getWorkPlaceList", params);		
		resultObject.put("list", CoviSelectSet.coviSelectJSON(workPlaceList, "LocationSeq,CompanyCode,WorkZoneGroupNm,WorkZone,WorkAddr,WorkPointX,WorkPointY,AllowRadius,ValidYn"));

		return resultObject;
	}

	@Override
	public int insertWorkPlace(CoviMap params) throws Exception {
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		return coviMapperOne.insert("attend.adminSetting.insertWorkPlace",params);
	}

	@Override
	public int updateWorkPlace(CoviMap params) throws Exception {
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		return coviMapperOne.update("attend.adminSetting.updateWorkPlace",params);
	}

	@Override
	public int deleteWorkPlace(CoviMap params) throws Exception {
		return coviMapperOne.delete("attend.adminSetting.deleteWorkPlace", params);
	}
	
	@Override
	public CoviMap selecAttendMaxBaseDatePop(CoviMap params) throws Exception {
		CoviMap rtnObj = new CoviMap();
		CoviList resultList = coviMapperOne.list("attend.adminSetting.selectAttendMaxBaseDate", params);
		rtnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "DayList"));
		return rtnObj;
	}
	
	@Override
	public int insertAttendBaseDate(CoviMap params) throws Exception {
		return coviMapperOne.insert("attend.adminSetting.insertAttendBaseDate", params);
	}
	
	@Override
	public CoviMap getAttModifyHisList(CoviMap params) throws Exception {
		CoviMap resultObject = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = (int)coviMapperOne.getNumber("attend.adminSetting.getAttModifyHisListCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultObject.put("page", page);
 			resultObject.put("cnt", cnt); 
 		}
			
		CoviList attModifyHisList = coviMapperOne.list("attend.adminSetting.getAttModifyHisList", params);		
		resultObject.put("list", CoviSelectSet.coviSelectJSON(attModifyHisList, "HisSeq,Division,UserCode,UserName,DeptName,BeforeAttTime,AttTime,RegistDate,RegisterCode,RegisterName,ReqType,BillName,Etc"));
		  
		return resultObject;
	}
	
	@Override
	public CoviList getAttModifyHisExcelList(CoviMap params) throws Exception {	
		CoviList attModifyHisList = coviMapperOne.list("attend.adminSetting.getAttModifyHisExcelList", params);
		
		for(Object attModifyHis : attModifyHisList) {
			CoviMap attModifyHisMap = (CoviMap)attModifyHis;
			
			if("StartSts".equals(attModifyHisMap.getString("Division"))) {
				attModifyHisMap.put("Division", DicHelper.getDic("lbl_startWorkTime"));
			} else {
				attModifyHisMap.put("Division", DicHelper.getDic("lbl_endWorkTime"));
			}
			
			if("None".equals(attModifyHisMap.getString("ReqType"))) {
				attModifyHisMap.put("ReqTypeName", DicHelper.getDic("lbl_admin"));
			} else if("Request".equals(attModifyHisMap.getString("ReqType"))) {
				attModifyHisMap.put("ReqTypeName", DicHelper.getDic("lbl_apv_normal") + DicHelper.getDic("lbl_apv_Approved"));
			} else {
				attModifyHisMap.put("ReqTypeName", DicHelper.getDic("lbl_apv_approval"));
			}
			
			attModifyHisMap.put("Contents", attModifyHisMap.getString("Etc") + " " + (!"".equals(attModifyHisMap.getString("Etc")) ? " - " : "") + attModifyHisMap.getString("BillName"));
		}
		
		return attModifyHisList;
	}
}
