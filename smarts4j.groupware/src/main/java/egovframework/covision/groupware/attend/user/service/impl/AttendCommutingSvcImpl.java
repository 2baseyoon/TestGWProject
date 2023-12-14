package egovframework.covision.groupware.attend.user.service.impl;

import javax.annotation.Resource;

import egovframework.covision.groupware.attend.user.service.AttendReqSvc;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.attend.user.service.AttendCommutingSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service("AttendCommutingSvc")
public class AttendCommutingSvcImpl extends EgovAbstractServiceImpl  implements AttendCommutingSvc {
	private Logger LOGGER = LogManager.getLogger(AttendCommutingSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private AttendReqSvc attendReqSvc;

	@Override
	public String getCommuteMstSeq(CoviMap params) throws Exception {
		if(params.get("TargetDate")==null || params.get("CompanyCode")==null || params.get("UserCode")==null){
			return "";
		}
		String commuteSeq = coviMapperOne.selectOne("attend.commute.getCommuteMstSeq", params);
		return commuteSeq;
	}
	
	@Override
	public CoviMap getCommuteMstData(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		if(params.get("UserCode")==null || params.get("TargetDate")==null ){
			returnObj.put("status", Return.FAIL);
			return returnObj;
		}
		CoviList commuteMstList = coviMapperOne.list("attend.commute.getCommuteMstData", params);
		CoviList commuteJa = CoviSelectSet.coviSelectJSON(commuteMstList, "CommuSeq,UserCode,TargetDate,Etc,CompanyCode,TardyReason,UserEtc,LeaveEarlyReason,RegisterCode,RegistDate,ModifyerCode,ModifyDate,FixWorkTime,MaxWorkTime,AttStartTime,AttEndTime,AttReal,AttAC,AttIdle,ExtenReal,ExtenAC,HolidayYn,AttConfirmYn,AttConfirmTime,StartSts,EndSts,StartPointX,StartPointY,EndPointX,EndPointY,StartTime,EndTime,AttendStatus");
		
		if(commuteJa.size()>0){
			returnObj.put("data", commuteJa.getJSONObject(0));
		}
		returnObj.put("status", Return.SUCCESS); 
		return returnObj;
	}

	//춡퇴근 기록
	@Override
	public CoviMap setCommuteTime(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		String companyCode = params.getString("CompanyCode");
		String userCode = params.getString("UserCode");
		String targetDate = params.getString("TargetDate");
		String regUserCode = params.getString("RegUserCode");

		//attendance commuting history parameters map
		CoviMap hisParams = new CoviMap();

		/**
		 * 근무일정 등록정보 조회
		 * */
		CoviList jobJsonArray = getMngJob(userCode,targetDate,companyCode, params.getString("StartTime"));
		if(jobJsonArray.size()>0){
			/**
			 * 설정된 근무일정 존재시 
			 * */
			CoviMap jobObj = jobJsonArray.getJSONObject(0);
			targetDate = jobObj.getString("JobDate");
			params.put("TargetDate", targetDate);
			hisParams.put("SchSeq", jobObj.get("SchSeq"));
			hisParams.put("AttDaySts", jobObj.get("WorkSts"));
			if (!StringUtil.replaceNull(jobObj.get("AttDayStartTime"),"").equals("")){
				hisParams.put("AttDayStartTime", jobObj.get("AttDayStartTime"));
				hisParams.put("AttDayEndTime", jobObj.get("AttDayEndTime"));
			}	
			hisParams.put("AttDayAc", jobObj.get("AttDayAC"));

			//자동연장근무
			params.put("AutoExtenYn", jobObj.get("AutoExtenYn"));
			params.put("AutoExtenMinTime", jobObj.get("AutoExtenMinTime"));
			params.put("AutoExtenMaxTime", jobObj.get("AutoExtenMaxTime"));
		}else{
			/**
			 * 해당일 근무일정 미 존재시 무일정 근무가 허용되지 않으면 출 퇴근 불가
			 * */
			String noSchYn = RedisDataUtil.getBaseConfig("NoSchYn");
			if (noSchYn.equals("")){
				CoviMap baseParams = new CoviMap();
				baseParams.put("CompanyCode", companyCode);
				baseParams.put("settingVal","NoSchYn");
				CoviMap baseKey = coviMapperOne.selectOne("attend.common.getBaseConfig", baseParams);
				if (baseKey != null) noSchYn = baseKey.getString("SettingValue");
				else noSchYn = "Y";
			}

			if("N".equals(noSchYn)){
				returnObj.put("status", Return.FAIL);
				returnObj.put("msg", DicHelper.getDic("msg_n_att_noSchNotUsed"));//무일정 근무가 비 활성화 되어있습니다.
				return returnObj;
			}
		}

		String commuteSeq = getCommuteMstSeq(params);
		if(commuteSeq==null){
			/**
			 * 해당 일자에 대한  MST TABLE 데이터가 없을경우
			 * MST테이블 정보를 생성
			 * */
			params.put("CompanyCode", companyCode);
			String schSeq = coviMapperOne.selectOne("attend.commute.selectJobScheduleSeq", params);
			if(schSeq==null || schSeq.equals("")){
				schSeq = coviMapperOne.selectOne("attend.commute.selectBaseScheduleSeq", params);
			}
			//System.out.println("####schSeq==>"+schSeq);
			CoviMap item = new CoviMap();
			item.put("SchSeq", Integer.parseInt(schSeq));
			item.put("StartDate", targetDate);
			item.put("EndDate", targetDate);
			item.put("JobUserCode", userCode);
			item.put("HolidayFlag", 'Y');
			item.put("CompanyCode", companyCode);
			item.put("USERID", userCode);
			item.put("RetCount", 0);
			coviMapperOne.update("attend.job.createScheduleJob", item);
			String commuteSeq2 = getCommuteMstSeq(params);
			if(commuteSeq2==null) {
				coviMapperOne.insert("attend.commute.setCommuteMst", params);
			}
			commuteSeq = params.getString("CommuSeq");
		}else if("".equals(commuteSeq)){
			returnObj.put("status", Return.FAIL);
			returnObj.put("msg", "CommuSeq is null");

			return returnObj;
		}

		/**
		 * HISTORY 테이블 정보를 생성
		 * */
		hisParams.put("CommuSeq", commuteSeq);
		hisParams.put("CompanyCode", companyCode);
		hisParams.put("UserCode", userCode);
		hisParams.put("TargetDate", targetDate);
		hisParams.put("RegUserCode", regUserCode);

		hisParams.put("StartTime", params.get("StartTime"));
		hisParams.put("StartChannel", params.get("StartChannel"));
		hisParams.put("StartPointX", params.get("StartPointX"));
		hisParams.put("StartPointY", params.get("StartPointY"));
		hisParams.put("StartIpAddr", params.get("StartIpAddr"));


		if( params.get("StartPointX") != null && params.get("StartPointY") != null ){
			hisParams.put("StartAddr", AttendUtils.getCommuteAddr(params.getString("StartPointX"),params.getString("StartPointY")));
		}


		hisParams.put("EndTime", params.get("EndTime"));
		hisParams.put("EndChannel", params.get("EndChannel"));
		hisParams.put("EndPointX", params.get("EndPointX"));
		hisParams.put("EndPointY", params.get("EndPointY"));
		hisParams.put("EndIpAddr", params.get("EndIpAddr"));

		if( params.get("EndPointX") != null && params.get("EndPointY") != null ){
			hisParams.put("EndAddr", AttendUtils.getCommuteAddr(params.getString("EndPointX"),params.getString("EndPointY")));
		}

		coviMapperOne.insert("attend.commute.setCommuteHistory", hisParams);
		/**
		 * MST TALBE UPDATE
		 * */

		if(params.get("CommuteType") != null && "S".equals(params.get("CommuteType").toString())) {
			setCommuteMstProc(userCode, targetDate, companyCode);
			if("E".equals(params.get("CommuteType").toString())) {
				Thread.sleep(500);//출근 정보와 퇴근 정보가 동시 존재 한는 경우 출근 용 프로시져 처리후 지정 시간 sleep후 퇴근 처리 진행
			}
		}
		//자동연장근무 처리
		if (params.get("CommuteType") != null && "E".equals(params.get("CommuteType").toString())) { //퇴근일 경우
			Thread.sleep(50);
			if (params.get("AutoExtenYn") != null && "Y".equals(params.get("AutoExtenYn").toString())) { //자동연장근무가 활성화 되었을 경우
				DateTimeFormatter dtf1 = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
				DateTimeFormatter dtf2 = DateTimeFormatter.ofPattern("HHmm");
				LocalDateTime endDate = LocalDateTime.parse(params.get("EndTime").toString(), dtf1);
				LocalDateTime attEndDate = LocalDateTime.parse(hisParams.get("AttDayEndTime").toString(), dtf1);

				if (endDate.isAfter(attEndDate)) { //지정근무시간 보다 퇴근 시간이 클 경우
					long minMinutes = Long.parseLong(params.get("AutoExtenMinTime").toString());
					long maxMinutes = Long.parseLong(params.get("AutoExtenMaxTime").toString());

					long extenUnit = 0L;
					if (!"".equals(RedisDataUtil.getBaseConfig("ExtenUnit"))) //설정된 단위 시간
						extenUnit = Long.parseLong(RedisDataUtil.getBaseConfig("ExtenUnit"));

					Duration duration = Duration.between(attEndDate, endDate);
					long calMinutes = duration.getSeconds() / 60;

					if (calMinutes >= minMinutes) { // 근무 시간 차이가 최소 인정 시간보다 클 경우
						if (calMinutes > maxMinutes) { // 근무 시간이 최대 인정 시간보다 클 경우
							calMinutes = maxMinutes; //최대 인정 시간까지만 인정
						} else if (calMinutes >= minMinutes && calMinutes <= maxMinutes) {
							if (extenUnit != 0L) { //  단위 시간이 0이면 분 단위 전체 인정
								calMinutes = (calMinutes / extenUnit) * extenUnit; //단위 시간에 맞춰 자르기
							}
						}
						LocalTime calTime = LocalTime.ofSecondOfDay(calMinutes * 60);

						//reqDataStr 생성
						Map<String, Object> reqData = new HashMap<String, Object>();
						reqData.put("Comment", "");
						reqData.put("NextDayYn", "N"); //익일 근무 인정 안함.
						reqData.put("UserCode", userCode);
						reqData.put("UrName", SessionHelper.getSession("UR_Name"));
						reqData.put("CompanyCode", companyCode);
						reqData.put("WorkDate", targetDate);
						reqData.put("IdleTime", "0");
						reqData.put("StartTime", attEndDate.format(dtf2));
						reqData.put("EndTime", attEndDate.plusMinutes(calMinutes).format(dtf2));
						reqData.put("AcTime", calTime.format(dtf2));

						List<Map<String, Object>> reqDataList = new ArrayList<Map<String, Object>>();
						reqDataList.add(reqData);

						//요청 신청서 생성
						CoviMap reqParams = new CoviMap();
						reqParams.put("ReqType", "O"); //연장근무
						reqParams.put("ReqGubun", "C");
						reqParams.put("ReqMethod", "None"); //자동승인

						reqParams.put("UserCode", userCode);
						reqParams.put("UrName", SessionHelper.getSession("UR_Name"));
						reqParams.put("RegisterCode", SessionHelper.getSession("USERID"));
						reqParams.put("CompanyCode", companyCode);
						reqParams.put("ReqTitle", "자동연장근무_" + SessionHelper.getSession("UR_Name") + "(" + targetDate + ")");
						reqParams.put("ReqStatus", "Approval"); //자동승인
						String reqDataStr = AttendUtils.getJsonArrayFromList(reqDataList).toString();
						reqDataStr = reqDataStr.replace("\"","\\\"");
						reqParams.put("ReqDataStr", reqDataStr);
						reqParams.put("Comment", "");

						CoviMap reqResultObj = attendReqSvc.requestOverTime(reqParams, reqDataList, "Approval");

						Thread.sleep(300);

						setCommuteMstProc(userCode, targetDate, companyCode);

						if (reqResultObj.get("status") == Return.FAIL) { // 자동등록 실패시
							if (reqResultObj.get("dupFlag") != null && (boolean) reqResultObj.get("dupFlag")) { //중복등록
								reqParams.put("Comment", RedisDataUtil.getDicElement("msg_att_overlapping_overtime", "", "KoFull"));
							} else { //초과연장근무
								reqParams.put("Comment", RedisDataUtil.getDicElement("lbl_n_att_overTimeHour", "", "KoFull"));
							}
							reqParams.put("ReqStatus", "Reject"); //반려 처리

							int cnt = coviMapperOne.insert("attend.req.insertAttendRequest", reqParams); // 요청테이블에 반려처리로 등록
						}
					}else{
						setCommuteMstProc(userCode, targetDate, companyCode);
					}
				}else{
					setCommuteMstProc(userCode, targetDate, companyCode);
				}
			}else{
				setCommuteMstProc(userCode, targetDate, companyCode);
			}
		}

		/**
		 * @author sjhan0418
		 * @date : 2020-04-22
		 * @변경이력 : 2020-04-24
		 * 출퇴근 시 대상일 이전 출근/퇴근 미처리 건에 대한 소명신청 대상 처리
		 * */
		setCallingPreTargetDate(userCode,targetDate,companyCode);

		returnObj.put("status", Return.SUCCESS);
		returnObj.put("CommuSeq", commuteSeq);
		return returnObj;
	}

	@Override
	public CoviList getMngJob(String userCode,String targetDate,String companyCode, String startTime) throws Exception {
		CoviMap params = new CoviMap();
		params.put("CompanyCode", companyCode);
		params.put("UserCode", userCode);
		params.put("TargetDate", targetDate);
		if (startTime !=  null && !startTime.equals("")){
			params.put("StartTime", startTime);
		}
		CoviList jobList = coviMapperOne.list("attend.commute.getMngJob", params);
		return CoviSelectSet.coviSelectJSON(jobList,"SchSeq,UserCode,JobDate,WorkSts,AttDayStartTime,AttDayEndTime,NextDayYn,ConfmYn,AttDayAC,WorkTime,WorkCode,UnitTerm,MaxWorkTime,MaxWorkCode,MaxUnitTerm,AssYn,WorkZone,WorkAddr,WorkPointX,WorkPointY,AllowRadius,StartZone,StartAddr,StartPointX,StartPointY,EndZone,EndAddr,EndPointX,EndPointY,Etc,AutoExtenYn,AutoExtenMinTime,AutoExtenMaxTime" );
	} 
	

	@Override
	public CoviMap chkCommuteAllowRadius(String companyCode ,String userCode , String targetDate, String commuteType,String commutePointX, String commutePointY) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		if(
				!(userCode == null || "".equals(userCode))
				&&!(targetDate == null || "".equals(targetDate))
				&&!(commuteType == null || "".equals(commuteType))
				&&!(commutePointX == null || "".equals(commutePointX))
				&&!(commutePointY == null || "".equals(commutePointY))
		){
			CoviList jobJsonArray = getMngJob(userCode,targetDate,companyCode, "");
			if(jobJsonArray.size()>0){
				CoviMap jobObj = jobJsonArray.getJSONObject(0);

				String jobPointX ="";
				String jobPointY ="";
				
				//설정 거리
				String allowRadius = jobObj.getString("AllowRadius");
				int distance = allowRadius != null && !"".equals(allowRadius) ? Integer.parseInt(allowRadius) : 0 ;
				
				if("S".equals(commuteType)){
					jobPointX = jobObj.get("StartPointX")!=null?jobObj.getString("StartPointX"):null;
					jobPointY = jobObj.get("StartPointY")!=null?jobObj.getString("StartPointY"):null;
				}else if("E".equals(commuteType)){
					jobPointX = jobObj.get("EndPointX")!=null?jobObj.getString("EndPointX"):null;    
					jobPointY = jobObj.get("EndPointY")!=null?jobObj.getString("EndPointY"):null;    
				} 
				
				/*
				 * 출퇴근 좌표 제한이 있는경우 근무지 좌표는 확인하지 않음
				 * */
				double lon1 = Double.parseDouble(commutePointX);
				double lat1 = Double.parseDouble(commutePointY);
				boolean pointFlag = true;
				if(
						!(jobPointX==null || "".equals(jobPointX))
						&&!(jobPointY==null || "".equals(jobPointY))
				){  // 우선순위 1차는 job에 등록되어 있는 위치
					double lon2 = Double.parseDouble(jobPointX);
					double lat2 = Double.parseDouble(jobPointY);
					
					pointFlag = AttendUtils.chkPointDistance(lon1,lat1,lon2,lat2,distance);
				}else{
					/*
					 * 2021.10.22 by yhshin
					 *템플릿에 출근지 / 퇴근지 등록 체크로직 추가
					 */
					if(jobObj.getString("SchSeq") != null && !"".equals(jobObj.getString("SchSeq"))) { //job에 출퇴근 좌표 제한이 없으면 템플릿의 정보를 가져와 확인 확인 후 근무지 좌표 확인
						CoviMap placeParams = new CoviMap();
						placeParams.put("SchSeq", jobObj.getString("SchSeq"));

						List<CoviMap> workPlaceList = null;

						if("S".equals(commuteType)){
							placeParams.put("WorkPlaceType", 0); //출근지
						}else if("E".equals(commuteType)){
							placeParams.put("WorkPlaceType", 1); //퇴근지
						}
						workPlaceList = getWorkPlaceList(placeParams);

						if(workPlaceList != null && workPlaceList.size() != 0) {
							for(int i=0; i<workPlaceList.size(); i++) {
								CoviMap workPlace = workPlaceList.get(i);

								String workPlaceWorkPointX = workPlace.get("WorkPointX").toString();
								String workPlaceWorkPointY = workPlace.get("WorkPointY").toString();

								//설정 거리
								String workPlaceAllowRadius = workPlace.getString("AllowRadius");
								int workPlaceDistance = workPlaceAllowRadius != null && !"".equals(workPlaceAllowRadius) ? Integer.parseInt(workPlaceAllowRadius) : 0;

								if (!(workPlaceWorkPointX == null || "".equals(workPlaceWorkPointX)) && !(workPlaceWorkPointY == null || "".equals(workPlaceWorkPointY))) {
									double lon2 = Double.parseDouble(workPlaceWorkPointX);
									double lat2 = Double.parseDouble(workPlaceWorkPointY);

									pointFlag = AttendUtils.chkPointDistance(lon1, lat1, lon2, lat2, workPlaceDistance);
								}

								if(pointFlag) { //체크가 되면 for문 중단
									break;
								}
							}
						} else { // 템플릿에도 없으면 최종적으로 템플릿 근무지 확인
							String workPointX = jobObj.getString("WorkPointX");
							String workPointY = jobObj.getString("WorkPointY");

							if (
									!(workPointX == null || "".equals(workPointX))
											&& !(workPointY == null || "".equals(workPointY))
							) {
								double lon2 = Double.parseDouble(workPointX);
								double lat2 = Double.parseDouble(workPointY);

								pointFlag = AttendUtils.chkPointDistance(lon1, lat1, lon2, lat2, distance);
							}
						}

					} else { //템플릿 없이 job만 있는 경우
						String workPointX = jobObj.getString("WorkPointX");
						String workPointY = jobObj.getString("WorkPointY");

						if (
								!(workPointX == null || "".equals(workPointX))
										&& !(workPointY == null || "".equals(workPointY))
						) {
							double lon2 = Double.parseDouble(workPointX);
							double lat2 = Double.parseDouble(workPointY);

							pointFlag = AttendUtils.chkPointDistance(lon1, lat1, lon2, lat2, distance);
						}
					}
				}

				if(pointFlag){
					returnObj.put("status", Return.SUCCESS);
				}else{
					
					/**
					 * @Date 2020-05-21
					 * @author sjhan0418
					 * 기초설정 내 출 퇴근 허용 여부 관련 제한 추가
					 * 
					 * AttReqMethod 출근 허용여부 
					 * LeaveReqMethod 퇴근 허용여부
					 * ( Disable 사용안함 / None 승인없음  /	Request 승인 / Approval 전자결재 )
					 * */
					
					String methodConfig = "";
					
					if("S".equals(commuteType)){
						methodConfig = RedisDataUtil.getBaseConfig("AttReqMethod");
					}else if("E".equals(commuteType)){
						methodConfig = RedisDataUtil.getBaseConfig("LeaveReqMethod");
					}
					if(!"Disable".equals(methodConfig)){	
						returnObj.put("type", methodConfig);
					}
					returnObj.put("msg", DicHelper.getDic("msg_n_att_pointNotUsed")); //지정 좌표 범위가 아닙니다.
					returnObj.put("status", Return.FAIL);
				}
			}else{ 
				/**
				 * 해당일 근무일정 미 존재시 무일정 근무가 허용되지 않으면 출 퇴근 불가
				 * */
				String noSchYn = RedisDataUtil.getBaseConfig("NoSchYn");
				if(!"Y".equals(noSchYn)){
					returnObj.put("msg",  DicHelper.getDic("msg_n_att_noSchNotUsed")); //무일정 근무가 비 활성화 되어있습니다.
					returnObj.put("status", Return.FAIL);
					return returnObj;
				}else{
					returnObj.put("status", Return.SUCCESS);
				}
			}
		}else{
			returnObj.put("msg", "parameter is null-위치 좌표 확인요");
			returnObj.put("status", Return.FAIL);
		}
		return returnObj;
	}

	
	

	@Override
	public void setCallingPreTargetDate(String userCode, String targetDate,String companyCode) throws Exception {
		CoviMap params = new CoviMap();
		params.put("UserCode", userCode);
		params.put("TargetDate", targetDate);
		params.put("CompanyCode", companyCode);
		CoviList callingList = coviMapperOne.list("attend.commute.getCallingTargetList", params);
		
		for(int i=0;i<callingList.size();i++){
			CoviMap callingMap = callingList.getMap(i);
			coviMapperOne.update("attend.commute.updCallingData", callingMap);
		}
	}

	@Override
	public void setCommuteMstProc(String userCode, String targetDate,
			String companyCode) throws Exception {
		CoviMap params = new CoviMap();
		params.put("UserCode", userCode);
		params.put("TargetDate", targetDate);
		params.put("CompanyCode", companyCode);
		
		coviMapperOne.update("attend.commute.setCommuteMstProc", params);
		//coviMapperOne.selectOne("attend.commute.setCommuteMstProc", params);
	}

	@Override
	public void setCommuteMng(CoviMap params) throws Exception {
		
		if("D".equals(params.get("Type"))){
			coviMapperOne.delete("attend.commute.delAttCommuteMng", params);
		}else{
			String commuteSeq = getCommuteMstSeq(params);
			if(commuteSeq==null){
				/**
				 * 해당 일자에 대한  MST TABLE 데이터가 없을경우
				 * MST테이블 정보를 생성
				 * */
				coviMapperOne.insert("attend.commute.setCommuteMst", params);
				commuteSeq = params.getString("CommuSeq");
			}
			
			params.put("CommuSeq", commuteSeq);
			params.put("HisReqType", "None");
			
			if(params.has("StartDate") && params.get("StartDate") != null) {
				//근태 변경 이력 (출근)
				params.put("Division", "StartSts");
				coviMapperOne.update("attend.commute.setAttModifyHistory", params);
			}
			
			if(params.has("EndDate") && params.get("EndDate") != null) {
				//근태 변경 이력 (퇴근)
				params.put("Division", "EndSts");
				coviMapperOne.update("attend.commute.setAttModifyHistory", params);
			}
			
			//출퇴근 시간 ( 상태 S ) 업데이트 
			coviMapperOne.update("attend.commute.setAttCommuteMng", params);
		}

		//출퇴근 시간 외 정보 재입력
		String userCode = params.getString("UserCode");
		String targetDate = params.getString("TargetDate");
		String companyCode = params.getString("CompanyCode");
		setCommuteMstProc(userCode,targetDate,companyCode);
	}

	@Override
	public CoviMap setCommuteMng(String TargetDate, String UserCode,
			String RegUserCode, String StartDate, String EndDate, String Etc,
			String CompanyCode) throws Exception {
		CoviMap returnMap = new CoviMap();
		if(TargetDate == null || "".equals(TargetDate))  { returnMap.put("status", Return.FAIL); returnMap.put("message", "TargetDate is null"); }
		else if(UserCode == null || "".equals(UserCode)) { returnMap.put("status", Return.FAIL); returnMap.put("message", "UserCode is null"); }
		else if(CompanyCode == null || "".equals(CompanyCode)) { returnMap.put("status", Return.FAIL); returnMap.put("message", "CompanyCode is null"); }
		else{
			try{
				CoviMap params = new CoviMap();
				params.put("TargetDate", TargetDate);
				params.put("UserCode", UserCode);
				params.put("RegUserCode", RegUserCode==null || "".equals(RegUserCode) ? "system" : RegUserCode);
				params.put("StartDate", StartDate);
				params.put("EndDate", EndDate);
				params.put("Etc", Etc);
				params.put("CompanyCode", CompanyCode);
				
				setCommuteMng(params);
				
				returnMap.put("status", Return.SUCCESS); 
			} catch(NullPointerException e){
				LOGGER.error(e.getLocalizedMessage(), e);
				returnMap.put("status", Return.FAIL); 
				returnMap.put("message", e.toString());
			} catch(Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
				returnMap.put("status", Return.FAIL); 
				returnMap.put("message", e.toString());
			}
		}
		return returnMap;
	}

	@Override
	public List<CoviMap> getWorkPlaceList(CoviMap params) throws Exception {
		List<CoviMap> workPlaceList = null;
		workPlaceList = coviMapperOne.list("attend.commute.getWorkPlaceList", params);

		return workPlaceList;
	}

}
