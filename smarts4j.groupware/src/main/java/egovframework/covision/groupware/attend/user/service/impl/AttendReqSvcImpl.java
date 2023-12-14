package egovframework.covision.groupware.attend.user.service.impl;

import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.gson.Gson;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.baseframework.util.json.JSONParser;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.attend.user.service.AttendReqSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.covision.groupware.vacation.user.service.VacationSvc;

@Service("AttendReqSvc")
public class AttendReqSvcImpl extends EgovAbstractServiceImpl implements AttendReqSvc {
	private Logger LOGGER = LogManager.getLogger(AttendReqSvcImpl.class);
			
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	VacationSvc vacationSvc;
	/**
	 * @Method Name : requestOverTime
	 * @Description : 연장근무 요청
	 */
	@Override 
	public CoviMap requestOverTime(CoviMap params, List ReqData, String ReqStatus) throws Exception {
		CoviMap resultList	= new CoviMap();
		/**
		 * @author sjhan0418
		 * 등록 구분 추가
		 * */
		String reqGubun = params.get("ReqGubun")!=null && !"".equals(params.get("ReqGubun"))?params.getString("ReqGubun"):"C";
		
		int cnt = 0;
		params.put("ReqData", ReqData);
		params.put("ReqGubun", reqGubun);
		params.put("JobStsName", "O");

		CoviMap coviData = new CoviMap();
		coviData.put("ReqTitle", params.get("ReqTitle"));
		coviData.put("RegisterCode", params.get("RegisterCode"));
		
		coviData.put("UserCode", params.get("UserCode"));
		coviData.put("CompanyCode", params.get("CompanyCode"));
		coviData.put("Comment", params.get("Comment"));

		resultList	=	validateRequest((String)params.get("ReqType"), reqGubun, coviData, ReqData) ;
		if (resultList.get("status")== Return.FAIL){
			return resultList;
		}
		
		//요청관리 테이블 insert
		cnt = coviMapperOne.insert("attend.req.insertAttendRequest", params);
		//승인건이면 연장근무 테이블에 
		if (ReqStatus.equals("Approval")){
			
			CoviMap resultObject = saveOverTime( (String)params.get("ReqType"), reqGubun, coviData, ReqData);
		}

		resultList.put("resultCnt", cnt);
		resultList.put("status", Return.SUCCESS);
		return resultList;
	}
	
	/**
	 * @Method Name : requestHolidayWork
	 * @Description : 휴일근무 요청
	 */
	@Override 
	public CoviMap requestHolidayWork(CoviMap params, List ReqData, String ReqStatus) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		String reqGubun = params.get("ReqGubun")!=null && !"".equals(params.get("ReqGubun"))?params.getString("ReqGubun"):"C";
		int cnt = 0;
		params.put("ReqData", ReqData);
		params.put("ReqGubun", reqGubun);
		params.put("JobStsName", "H");
		
		CoviMap coviData = new CoviMap();
		coviData.put("ReqTitle", params.get("ReqTitle"));
		coviData.put("UserCode", params.get("UserCode"));
		coviData.put("RegisterCode", params.get("RegisterCode"));
		coviData.put("CompanyCode", params.get("CompanyCode"));
		coviData.put("Comment", params.get("Comment"));
		
		resultList	=	validateRequest((String)params.get("ReqType"), reqGubun, coviData, ReqData) ;
		if (resultList.get("status")== Return.FAIL){
			return resultList;
		}
		
		//요청관리 테이블 insert
		cnt = coviMapperOne.insert("attend.req.insertAttendRequest", params);
		
		//승인건이면 연장근무 테이블에 
		if (ReqStatus.equals("Approval")){
			
			CoviMap resultObject = saveHoliday( (String)params.get("ReqType"), reqGubun, coviData, ReqData);
		}

		resultList.put("resultCnt", cnt);
		resultList.put("status", Return.SUCCESS);
		return resultList;
	}
	
	/**
	 * @Method Name : requestCall
	 * @Description : 소명신청 요청
	 */
	@Override 
	public CoviMap requestCall(CoviMap params, List ReqData, String ReqStatus) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		String reqGubun = params.get("ReqGubun")!=null && !"".equals(params.get("ReqGubun"))?params.getString("ReqGubun"):"C";
		int cnt = 0;
		params.put("ReqData", ReqData);
		params.put("ReqGubun", reqGubun);
		params.put("JobStsName", "C");

		//요청관리 테이블 insert
		cnt = coviMapperOne.insert("attend.req.insertAttendRequest", params);
		
		//승인건이면 연장근무 테이블에 
		if (ReqStatus.equals("Approval")){
			CoviMap coviData = new CoviMap();
			coviData.put("ReqTitle", params.get("ReqTitle"));
			coviData.put("UserCode", params.get("UserCode"));
			coviData.put("RegisterCode", params.get("RegisterCode"));
			coviData.put("CompanyCode", params.get("CompanyCode"));
			coviData.put("Comment", params.get("Comment"));
			coviData.put("CommuteIp", params.getString("CommuteIp"));
			coviData.put("CommuteChannel", "I");
			coviData.put("ReqStatus", ReqStatus);
			
			CoviMap resultObject = saveCall((String)params.get("ReqType"), reqGubun, coviData, ReqData);
		}

		resultList.put("resultCnt", cnt);
		resultList.put("status", Return.SUCCESS);
		return resultList;
	}
	/**
	 * @Method Name : requestJobStatus
	 * @Description : 근무 요청
	 */
	@Override 
	public CoviMap requestJobStatus(CoviMap params, List ReqData, String ReqStatus) throws Exception {
		CoviMap resultList = new CoviMap();
		
		/**
		 * @author sjhan0418
		 * 등록 구분 추가
		 * */
		String reqGubun = params.get("ReqGubun") != null && !"".equals(params.get("ReqGubun")) ? params.getString("ReqGubun") : "C";
		
		int cnt = 0;
		params.put("ReqData", ReqData);
		params.put("ReqGubun", reqGubun);
		params.put("StartTime", ((Map)ReqData.get(0)).get("StartTime"));
		
		CoviMap coviData = new CoviMap();
		coviData.put("ReqTitle", params.get("ReqTitle"));
		coviData.put("UserCode", params.get("UserCode"));
		coviData.put("RegisterCode", params.get("RegisterCode"));
		coviData.put("CompanyCode", params.get("CompanyCode"));
		coviData.put("Comment", params.get("Comment"));
		coviData.put("AuthType", params.getString("AuthType"));
		
		resultList = validateRequest((String)params.get("ReqType"), reqGubun, coviData, ReqData);
		if (resultList.get("status") == Return.FAIL) {
			return resultList;
		}
		
		boolean isAdminMode = (StringUtil.isNotNull(params.getString("AuthType")) && params.getString("AuthType").equalsIgnoreCase("ADMIN"));
		
		//요청관리 테이블 insert
		cnt = coviMapperOne.insert("attend.req.insertAttendRequest", params);
		
		//승인건이면 근무이력 테이블로 가기
		if (ReqStatus.equals("Approval") || isAdminMode) {
			CoviMap resultObject = saveJobStatus((String)params.get("ReqType"), reqGubun, coviData, ReqData);
		}

		resultList.put("dupFlag", false);
		resultList.put("resultCnt", cnt);
		resultList.put("status", Return.SUCCESS);
		return resultList;
	}
	
	/**
	 * @Method Name : getVacationInfo
	 * @Description : 근무일정 주간
	 */
	@Override 
	public CoviMap getVacationInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap map			= new CoviMap();
		map	= coviMapperOne.selectOne("attend.req.getVacationInfo", params);	
		resultList.put("data",	map);
		
		return resultList; 
	}

	@Override
	public CoviMap getVacationInfoV2(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap map			= new CoviMap();
		map	= coviMapperOne.selectOne("attend.req.getVacationInfoV2", params);
		resultList.put("data",	map);

		return resultList;
	}
	
	/**
	 * @Method Name : requestVacation
	 * @Description : 휴가 신청
	 */
	@Override 
	public CoviMap requestVacation(CoviMap params, List ReqData, String ReqStatus) throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		
		String reqGubun = params.get("ReqGubun") != null && !"".equals(params.get("ReqGubun")) ? params.getString("ReqGubun") : "C";
		params.put("ReqGubun", reqGubun);
		
		CoviMap coviData = new CoviMap();
		coviData.put("ReqTitle", params.get("ReqTitle"));
		coviData.put("UserCode", params.get("UserCode"));
		coviData.put("RegisterCode", params.get("RegisterCode"));
		coviData.put("CompanyCode", params.get("CompanyCode"));
		coviData.put("DomainID", params.get("DomainID"));
		coviData.put("Comment", params.get("Comment"));
		coviData.put("UrName", params.get("UrName"));
		coviData.put("AuthType", params.getString("AuthType"));
		
		resultList = validateRequest((String)params.get("ReqType"), reqGubun, coviData, ReqData);
		
		if (resultList.get("status") == Return.FAIL) {
			return resultList;
		}
		
		//요청관리 테이블 insert
		cnt = coviMapperOne.insert("attend.req.insertAttendRequest", params);
		resultList.put("ReqSeq", params.get("ReqSeq"));
		if(coviData.get("ReqSeq") == null || coviData.getString("ReqSeq").equals("")){
			coviData.put("ReqSeq", params.get("ReqSeq"));
		}
		
		boolean isAdminMode = (StringUtil.isNotNull(params.getString("AuthType")) && params.getString("AuthType").equalsIgnoreCase("ADMIN"));
		
		//승인건이면 근무이력 테이블로 가기
		if (ReqStatus.equals("Approval") || isAdminMode){
			CoviMap resultObject = saveVacation((String)params.get("ReqType"), reqGubun, coviData, ReqData);
		}
		
		resultList.put("resultCnt", cnt);
		resultList.put("status", Return.SUCCESS);
		return resultList;
	}
	
	/**
	 * @Method Name : requestSchedule
	 * @Description : 근무일정신청서
	 */
	@Override 
	public CoviMap requestSchedule(CoviMap params, List ReqData, String ReqStatus) throws Exception {
		CoviMap resultList	= new CoviMap();
		String reqGubun = params.get("ReqGubun")!=null && !"".equals(params.get("ReqGubun"))?params.getString("ReqGubun"):"C";
		
		int cnt = 0;
		
		//요청관리 테이블 insert
		params.put("ReqGubun", reqGubun);
		cnt = coviMapperOne.insert("attend.req.insertAttendRequest", params);
		StringBuffer trgDates = new StringBuffer();

		//승인건이면 근무생성 테이블로 가기
		if (ReqStatus.equals("Approval")){
			CoviMap coviData = new CoviMap();
			coviData.put("UserCode", params.get("UserCode"));
			coviData.put("USERID", params.get("UserCode"));
			coviData.put("CompanyCode", params.get("CompanyCode"));
			coviData.put("Comment", params.get("Comment"));
			
			CoviMap resultObject =  saveSchedule( (String)params.get("ReqType"), reqGubun, coviData, ReqData);
		}

		resultList.put("resultCnt", cnt);
		resultList.put("status", Return.SUCCESS);
		return resultList;
	}
	
	/**
	 * @Method Name : requestSchedule
	 * @Description : 근무일정신청서
	 */
	@Override 
	public CoviMap requestScheduleRepeat(CoviMap params, List ReqData, String ReqStatus) throws Exception {
		CoviMap resultList	= new CoviMap();
		String reqGubun = params.get("ReqGubun")!=null && !"".equals(params.get("ReqGubun"))?params.getString("ReqGubun"):"C";
		
		int cnt = 0;
		
		params.put("ReqGubun", reqGubun);
		//요청관리 테이블 insert
		cnt = coviMapperOne.insert("attend.req.insertAttendRequest", params);
		StringBuffer trgDates = new StringBuffer();

		//승인건이면 근무생성 테이블로 가기
		if (ReqStatus.equals("Approval")){
			CoviMap coviData = new CoviMap();
			coviData.put("UserCode", params.get("UserCode"));
			coviData.put("CompanyCode", params.get("CompanyCode"));
			coviData.put("USERID", params.get("UserCode"));
			coviData.put("CompanyCode", params.get("CompanyCode"));
			coviData.put("Comment", params.get("Comment"));
			
			CoviMap resultObject =  saveScheduleRepeat((String)params.get("ReqType"), reqGubun, coviData, ReqData);

		}

		resultList.put("resultCnt", cnt);
		resultList.put("status", Return.SUCCESS);
		return resultList;
	}
	
	public CoviMap addCustomSchedule (CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		params.put("ValidYn", "Y");
		String attSeq  = coviMapperOne.selectOne("attend.common.chkAttendanceBaseInfoYn", params);
		int returnAttSeq = attSeq!=null?Integer.parseInt(attSeq):0;
		params.put("AttSeq", returnAttSeq);

		int cnt =0;
		cnt = coviMapperOne.insert("attend.schedule.insertAttendSchedule", params);

		CoviMap placeParams = new CoviMap();
		placeParams.put("SchSeq", params.get("SchSeq"));
		//출근지 정보
		placeParams.put("WorkPlaceType", 0);
		coviMapperOne.delete("attend.schedule.deleteAttSchWorkPlace", placeParams);
		if(params.get("GoWorkPlaceCodes") != null && !"".equals(params.get("GoWorkPlaceCodes"))) {
			String[] goWorkPlaceCodes = params.get("GoWorkPlaceCodes").toString().split(",");
			for(int i=0; i<goWorkPlaceCodes.length; i++) {
				placeParams.put("LocationSeq", goWorkPlaceCodes[i]);
				coviMapperOne.insert("attend.schedule.insertAttSchWorkPlace", placeParams);
			}

		}
		//퇴근지 정보
		placeParams.put("WorkPlaceType", 1);
		coviMapperOne.delete("attend.schedule.deleteAttSchWorkPlace", placeParams);
		if(params.get("OffWorkPlaceCodes") != null && !"".equals(params.get("OffWorkPlaceCodes"))) {
			String[] offWorkPlaceCodes = params.get("OffWorkPlaceCodes").toString().split(",");
			for(int i=0; i<offWorkPlaceCodes.length; i++) {
				placeParams.put("LocationSeq", offWorkPlaceCodes[i]);
				coviMapperOne.insert("attend.schedule.insertAttSchWorkPlace", placeParams);
			}

		}

		cnt = coviMapperOne.insert("attend.schedule.setAttSchAlloc", params);
		
		resultList.put("resultCnt", cnt);
		resultList.put("status", Return.SUCCESS);
		return resultList;
	}
	
	
	
	//승인관련
	public CoviMap approvalAttendRequest(CoviMap reqMap, List objList) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		int resultCnt = 0;
		
		for(int j=0; j<objList.size(); j++){
			CoviMap getMap = new CoviMap();
			getMap.put("ReqSeq", objList.get(j));
			reqMap.put("ReqSeq", objList.get(j));

			CoviMap coviData = coviMapperOne.selectOne("attend.req_mng.getRequestDetail", getMap);

			String reqData = coviData.getString("ReqData");			
			CoviList ReqData = new Gson().fromJson(reqData, CoviList.class);
			
			String reqType = (String)coviData.get("ReqType");
			String reqGubun = (String)coviData.get("ReqGubun");
			
			CoviMap resultObject = new CoviMap();
			
			resultObject = validateRequest(reqType, reqGubun, coviData, ReqData);
			
			if (resultObject.get("status")== Return.FAIL){
				return resultObject;
			}
			
			switch (reqType) {
				case "O":	//연장
					resultObject = saveOverTime(reqType, reqGubun, coviData, ReqData);
					break;
				case "H":	//휴일근무
					resultObject = saveHoliday(reqType, reqGubun, coviData, ReqData);
					break;
				case "J":	//기타근무
					resultObject = saveJobStatus(reqType, reqGubun, coviData, ReqData);
					break;
				case "C":	//소명
					coviData.put("CommuteIp", reqMap.getString("CommuteIp"));
					coviData.put("CommuteChannel", "I");
					
					if(reqMap.has("ApprovalCode") && !"".equals(reqMap.getString("ApprovalCode"))) {
						coviData.put("RegisterCode", reqMap.getString("ApprovalCode"));
					}
					
					resultObject = saveCall(reqType, reqGubun, coviData, ReqData);
					break;
				case "V":	//휴가신청
					resultObject = saveVacation(reqType, reqGubun, coviData, ReqData);
					break;
				case "S":	//근무일정
					Map item = (Map)ReqData.get(0);

					if ("R".equals((String)item.get("Mode")))
						resultObject = saveScheduleRepeat(reqType, reqGubun, coviData, ReqData);
					else
						resultObject = saveSchedule(reqType, reqGubun, coviData, ReqData);
					break;
				case "A" : case "L":	//출/퇴근요청
					resultObject = saveCommute(reqType, reqGubun, coviData, ReqData);
					break;
				default :
					break;
				
			}
			if (resultObject.get("status") == Return.SUCCESS){
				reqMap.put("ReqStatus", "Approval");
				resultCnt += coviMapperOne.update("attend.req_mng.saveAttendRequest", reqMap);
			}
			else{
				return resultObject;
			}
		}
		//resultMap
		resultMap.put("resultCnt", resultCnt);
		resultMap.put("result", "ok");
		resultMap.put("status", Return.SUCCESS);
		
//		resultMap.put("cnt", value)
		return resultMap;
	}
	
	public CoviMap changeAttendRequestStatus (CoviMap reqMap, List objList) throws Exception {
		int cnt = 0;
		int approvalStatusCnt = 0;
		CoviMap data			= new CoviMap();
		CoviMap returnData			= new CoviMap();
		for(int i=0; i<objList.size(); i++){
			reqMap.put("ReqSeq", objList.get(i)); 

			data	= coviMapperOne.selectOne("attend.req_mng.getRequestDetail", reqMap);
			if(!data.getString("ReqStatus").equals("Approval") && !data.getString("ReqStatus").equals("Reject")) {
				// 요청관리에서 취소를 했을 경우,
				if("AttendRequest".equals(reqMap.getString("flag"))) {
					CoviMap reqInfo = new CoviMap();
					reqInfo = coviMapperOne.select("attend.req.selectRequestList", reqMap);
					//출퇴근 요청시만
					if (reqInfo.getString("ReqType").equals("A") || reqInfo.getString("ReqType").equals("L")){
						CoviMap reqData = new CoviMap();
						CoviList list = reqInfo.getJSONArray("ReqData");
						reqData.addAll(list.getJSONObject(0));
						reqData.put("Status", "lbl_ApprovalDeny");
						
						approvalStatusCnt = coviMapperOne.update("attend.req.updateApprovalCommuteStatus", reqData);
					}	
				}
				
				cnt += coviMapperOne.update("attend.req_mng.saveAttendRequest", reqMap); 
			}
		}
		returnData.put("totalCnt", objList.size()); // 총 건수
		returnData.put("cnt", cnt); // 갱신된 건수
		returnData.put("notUpdateCount", objList.size() - cnt); // 갱신되지 않은 건수
		return returnData;
	}

	public CoviMap deleteAttendRequest(CoviMap reqMap, List objList) throws Exception {
		int cnt = 0;
		CoviMap data = new CoviMap();
		CoviMap returnData			= new CoviMap();
		for(int i=0; i<objList.size(); i++){
			reqMap.put("ReqSeq", objList.get(i)); 
//			System.out.println(reqMap);
			data	= coviMapperOne.selectOne("attend.req_mng.getRequestDetail", reqMap);
			if(!data.getString("ReqStatus").equals("Approval") && !data.getString("ReqStatus").equals("Reject")) {
				cnt += coviMapperOne.update("attend.req_mng.deleteAttendRequest", reqMap); 
			}
		}
		returnData.put("totalCnt", objList.size()); // 총 건수
		returnData.put("cnt", cnt); // 갱신된 건수
		returnData.put("notUpdateCount", objList.size() - cnt); // 갱신되지 않은 건수
		return returnData;
	}
	
	public CoviMap validateRequest(String reqType, String reqGubun, CoviMap coviData, List ReqData){
		
		CoviMap resultObject	= new CoviMap();
		CoviMap params = new CoviMap();
		int dupCnt 	=  0;
		switch (reqType)
		{
			case "O":	//연장
			case "H":	//휴일
				params.put("ReqGubun", reqGubun);
				params.put("JobStsName", reqType);
				params.put("ReqData", ReqData);
//				params.put("UserCode", coviData.get("UserCode"));
				if("C".equals(reqGubun)){
					dupCnt = (int) coviMapperOne.getNumber ("attend.req.getExistAttendExtensionHoliday", params);			
				}
				//기존 근무 확인
				if (dupCnt >0)
				{
					resultObject.put("errorCode", 9001);
					resultObject.put("status", Return.FAIL);
					resultObject.put("dupFlag", true);
					return resultObject;
				}	
				else{//연장 가능 시가 확인
					//Map mapMaxTime =  new Map();
					if("C".equals(reqGubun)){
						Map<String, Integer> mapMaxTime = new java.util.HashMap<>();
						for(int i=0; i<ReqData.size(); i++){
							Map item = (Map)ReqData.get(i);
							item.put("JobDate", item.get("WorkDate"));
							//item.put("UserCode", item.get("UR_Code"));	
							//item.put("CompanyCode", item.get("CompanyCode"));	
							String chkStr = coviMapperOne.selectOne("attend.req.getWorkTimeCheck", item);
							String[] checkData = chkStr.split("/");
							if (checkData[0].equals("N")){
								resultObject.put("errorCode", 9002);
								resultObject.put("status", Return.FAIL);
								resultObject.put("errorCode", "lbl_n_att_overTimeHour");
								resultObject.put("errorData", "-1");
								return resultObject;
							}
							else{	
								String key = item.get("UserCode") +":"+checkData[2]+":"+checkData[3];
								String acTime = (String)item.get("AcTime");
								int time = Integer.parseInt(acTime.substring(0,2))*60+Integer.parseInt(acTime.substring(3,4));
								
								if (mapMaxTime.get(key) != null){
									time+= mapMaxTime.get(key);
								}
								
								if (time > Integer.parseInt(checkData[1])){
									resultObject.put("errorCode", 9002);
									resultObject.put("status", Return.FAIL);
									resultObject.put("errorCode", "lbl_n_att_overTimeHour");
									resultObject.put("errorData", checkData[1]);
									return resultObject;
								}
								
								mapMaxTime.put(key, time);
								
							}	
						}	
					}	
				}	
				break;
			case "J":	//기타근무
				params.put("ReqData", ReqData);
				params.put("ReqGubun", reqGubun);
				params.put("StartTime", ((Map)ReqData.get(0)).get("StartTime"));
				params.put("UserCode", ((Map)ReqData.get(0)).get("UserCode"));
				if("C".equals(reqGubun)){
					dupCnt = (int) coviMapperOne.getNumber ("attend.req.getExistAttendJobHistory", params);
				}
				//기존 근무 확인
				if (dupCnt >0)
				{
					resultObject.put("errorCode", 9001);
					resultObject.put("status", Return.FAIL);
					resultObject.put("dupFlag", true);
					return resultObject;
				}
				break;
			case "V"://휴가
				params.put("ReqGubun", "C");
				params.put("StartTime", ((Map)ReqData.get(0)).get("StartTime"));
				params.put("ReqData", ReqData);
				params.put("UserCode", coviData.get("UserCode"));
				params.put("VacYear", ((String)((Map)ReqData.get(0)).get("WorkDate")).substring(0,4));
				params.put("VacFlag", ((Map)ReqData.get(0)).get("VacFlag") );
				params.put("CompanyCode", ((Map)ReqData.get(0)).get("CompanyCode") );

				float sumVanDay =  (float) coviMapperOne.getNumber ("attend.req.getExistAttendVacation", params);
				//기존 휴가 확인
				if (sumVanDay > 0)
				{
					resultObject.put("errorCode", 9001);
					resultObject.put("status", Return.FAIL);
					resultObject.put("dupFlag", true);
					return resultObject;
				}	
				else{
					CoviMap resultMap	= null;
					CoviMap req = new CoviMap();
					req.put("CompanyCode", SessionHelper.getSession("DN_Code"));
					req.put("getName", "CreateMethod");
					String CreateMethod = null;
					try {
						CreateMethod = vacationSvc.getVacationConfigVal(req);
					} catch (ArrayIndexOutOfBoundsException e) {
						throw new RuntimeException(e);
					} catch (NullPointerException e) {
						throw new RuntimeException(e);
					} catch (Exception e) {
						throw new RuntimeException(e);
					}
					if(CreateMethod==null || CreateMethod.equals("")){
						CreateMethod = "F";
					}
					if(CreateMethod.equals("J")){
						resultMap = coviMapperOne.selectOne("attend.req.getVacationInfoV2", params);
					}else {
						resultMap = coviMapperOne.selectOne("attend.req.getVacationInfo", params);
					}
					Map item = (Map)ReqData.get(0);
					String vacFlag = (String)item.get("VacFlag");
					Double remainTot = Double.parseDouble(String.valueOf(resultMap.get("ATot")));
					Double unitDay = Double.parseDouble(String.valueOf(resultMap.get("UnitDay")));
					if (vacFlag.equals("VACATION_REWARD")){
						remainTot = Double.parseDouble(String.valueOf(resultMap.get("RewardATot")));
					}

					if (remainTot < unitDay * ReqData.size()
						&& (StringUtil.isNotNull(coviData.getString("AuthType")) && !coviData.getString("AuthType").equalsIgnoreCase("ADMIN"))) // 관리자가 설정 할 때는 잔여 휴가 상관없이 차감됨
					{
						resultObject.put("errorCode", 9002);	//휴가일 수 부족
						resultObject.put("status", Return.FAIL);
						resultObject.put("errorCode", "msg_apv_chk_vacation");
						resultObject.put("errorData", (unitDay * ReqData.size())+"/"+remainTot);
					}
				}	
				break;
			default :
				break;
		}
		return resultObject;
		
	}
	
	//연장근무 저장
	public CoviMap saveOverTime(String reqType, String reqGubun, CoviMap coviData, List ReqData){

		CoviMap resultObject = new CoviMap();
		for(int i=0; i<ReqData.size(); i++){
			Map item = (Map)ReqData.get(i);
			
			item.put("ReqType", reqType);
			item.put("ReqGubun", reqGubun);
			item.put("JobStsName",  "O");
			
			item.put("JobDate", item.get("WorkDate"));
//			item.put("UserCode", item.get("UserCode"));	
//			item.put("CompanyCode", item.get("CompanyCode"));	
			item.put("Etc", item.get("Comment"));	

			item.put("BillName", coviData.get("ReqTitle"));
			item.put("RegisterCode", coviData.get("RegisterCode"));	
			item.put("orgProcessId", coviData.get("orgProcessId"));	
						

			CoviMap cmap =coviMapperOne.selectOne("attend.req.getExtensionWorkDateTime", item);
			item.put("oAttDayStartTime", cmap.get("oAttDayStartTime"));
			item.put("oAttDayEndTime", cmap.get("oAttDayEndTime"));
			coviMapperOne.insert("attend.req.insertAttendCommutingMst", item);
		}

		resultObject.put("status", Return.SUCCESS);
		return resultObject;
		
	}
	
	//휴일근무저장
	public CoviMap saveHoliday(String reqType, String reqGubun, CoviMap coviData, List ReqData){
		CoviMap resultObject	= new CoviMap();

		
		for(int i=0; i<ReqData.size(); i++){
			Map item = (Map)ReqData.get(i);
			
			item.put("ReqType", reqType);
			item.put("ReqGubun", reqGubun);
			item.put("JobDate", item.get("WorkDate"));
			item.put("JobStsName", "H");
			item.put("UserCode", item.get("UserCode"));	
			item.put("CompanyCode", item.get("CompanyCode"));	
			item.put("Etc", item.get("Comment"));	

			item.put("BillName", coviData.get("ReqTitle"));
			item.put("RegisterCode", coviData.get("RegisterCode"));	
			

			CoviMap cmap =coviMapperOne.selectOne("attend.req.getWorkDateTime", item);
			item.put("oAttDayStartTime", cmap.get("oAttDayStartTime"));
			item.put("oAttDayEndTime", cmap.get("oAttDayEndTime"));
			coviMapperOne.insert("attend.req.insertAttendCommutingMst", item);
		}

		resultObject.put("status", Return.SUCCESS);
		return resultObject;
	}
	
	//소명
	public CoviMap saveCall(String reqType, String reqGubun, CoviMap coviData, List ReqData){
		CoviMap resultObject	= new CoviMap();

		CoviMap params = new CoviMap();
		params.put("ReqGubun", "C");
		params.put("ReqData", ReqData);
		params.put("UserCode", coviData.get("UserCode"));

		for(int i = 0; i < ReqData.size(); i++){
			Map item = (Map)ReqData.get(i);
			item.put("JobDate", item.get("WorkDate"));
			item.put("ReqType", reqType);
			item.put("ReqGubun", reqGubun);
			item.put("UserCode", item.get("UserCode"));	
			item.put("CompanyCode", item.get("CompanyCode"));	
			item.put("Etc", item.get("Comment"));
			item.put("BillName", coviData.get("ReqTitle"));
			
			if(!item.containsKey("RegisterCode") && StringUtil.isNull(item.get("RegisterCode"))) {
				item.put("RegisterCode", coviData.get("RegisterCode"));
			}
			
			if(item.containsKey("ProcessId") && item.get("ProcessId") != null) {
				item.put("HisReqType", "Approval");
			} else {
				if(coviData.has("ReqStatus") && "Approval".equals(coviData.getString("ReqStatus"))) {
					item.put("HisReqType", "None");
				} else {
					item.put("HisReqType", "Request");
				}
			}
			
			item.put("StartTime", item.get("ChgTime"));
			item.put("EndTime", item.get("ChgTime"));
			
			CoviMap cmap = coviMapperOne.selectOne("attend.req.getWorkDateTime", item);
			
			if (item.get("Division").equals("StartSts")) {
				item.put("oAttDayStartTime", cmap.get("oAttDayStartTime"));
				item.put("oStartAddr", coviData.getString("CommuteIp"));
				item.put("oStartChannel", coviData.getString("CommuteChannel"));
				
				// 근태 변경 이력 (출근)
				CoviMap hisParam = new CoviMap();			   
				hisParam.put("oAttDayStartTime", item.get("oAttDayStartTime"));
				hisParam.put("HisReqType", item.get("HisReqType"));
				hisParam.put("BillName", item.get("BillName"));
				hisParam.put("Etc", item.get("Etc"));
				hisParam.put("RegisterCode", item.get("RegisterCode"));
				hisParam.put("Division", item.get("Division"));
				hisParam.put("UserCode", item.get("UserCode"));
				hisParam.put("WorkDate", item.get("WorkDate"));
				
				coviMapperOne.update("attend.req.setAttModifyHistory", hisParam);
			} else {
				item.put("oAttDayEndTime", cmap.get("oAttDayEndTime"));
				item.put("oEndAddr", coviData.getString("CommuteIp"));
				item.put("oEndChannel", coviData.getString("CommuteChannel"));
				
				// 근태 변경 이력 (퇴근)
				CoviMap hisParam = new CoviMap();			   
				hisParam.put("oAttDayEndTime", item.get("oAttDayEndTime"));    
				hisParam.put("HisReqType", item.get("HisReqType"));
				hisParam.put("BillName", item.get("BillName"));
				hisParam.put("Etc", item.get("Etc"));
				hisParam.put("RegisterCode", item.get("RegisterCode"));
				hisParam.put("Division", item.get("Division"));
				hisParam.put("UserCode", item.get("UserCode"));
				hisParam.put("WorkDate", item.get("WorkDate"));
				
				coviMapperOne.update("attend.req.setAttModifyHistory", hisParam);
			}
			
			coviMapperOne.insert("attend.req.insertAttendCommutingMst", item);
		}
		
		resultObject.put("status", Return.SUCCESS);
		return resultObject;
	}
	
	//기타근무저장
	public CoviMap saveJobStatus(String reqType, String reqGubun, CoviMap coviData, List ReqData){
		CoviMap resultObject	= new CoviMap();

		for(int i=0; i<ReqData.size(); i++){
			Map item = (Map)ReqData.get(i);
			item.put("JobDate", item.get("WorkDate"));
			
			item.put("JobStsSeq", item.get("JobStsSeq"));
			item.put("JobStsName", item.get("JobStsName"));
			
			item.put("ReqType", reqType);
			item.put("ReqGubun", reqGubun);
			
			item.put("BillName", coviData.get("ReqTitle"));
			//item.put("UserCode", coviData.get("UserCode"));	
			item.put("RegisterCode", coviData.get("RegisterCode"));	
			//item.put("CompanyCode", coviData.get("CompanyCode"));	
			item.put("Etc", coviData.get("Comment"));	
			item.put("ProcessId", coviData.get("ProcessId"));
			
			if (StringUtil.isNotNull(coviData.getString("AuthType")) && coviData.getString("AuthType").equalsIgnoreCase("ADMIN")) {
				item.put("BillName", item.get("ReqTitle"));
			}
			
			if (reqGubun.equals("D") || reqGubun.equals("U") ){
				item.put("orgProcessId", coviData.get("orgProcessId"));	
				coviMapperOne.insert("attend.req.deleteAttendJobHistory", item);	
			}
			if (reqGubun.equals("U") || reqGubun.equals("C") ){
				coviMapperOne.insert("attend.req.insertAttendJobHistory", item);
			}
		}
		resultObject.put("status", Return.SUCCESS);
		return resultObject;
	}

	//휴가신청
	public CoviMap saveVacation(String reqType, String reqGubun, CoviMap coviData, List ReqData){
		CoviMap resultObject	= new CoviMap();
		String gubun = "VACATION_APPLY";
		String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
		
		for(int i=0; i<ReqData.size(); i++){
			Map item = (Map)ReqData.get(i);
			String userCode = item.get("UserCode").toString();
			String userName = item.get("UrName").toString();
			
			//item.put("JobDate", item.get("WorkDate"));
			item.put("ReqType", reqType);
			item.put("ReqGubun", reqGubun);
			item.put("SDate", item.get("WorkDate"));
			item.put("EDate", item.get("WorkDate"));
			item.put("VacYear", ((String)item.get("WorkDate")).substring(0,4));
			item.put("VacFlag", item.get("VacFlag"));
			item.put("VacOffFlag", item.get("VacOffFlag"));
			item.put("Gubun", gubun);
			item.put("BillName", coviData.get("ReqTitle")); 
			item.put("UserCode", coviData.get("UserCode"));	
			item.put("RegisterCode", coviData.get("RegisterCode"));
			item.put("UrCode", coviData.get("UserCode"));

			if(coviData.get("UrName") != null)
				item.put("UrName", coviData.get("UrName"));
			else
				item.put("UrName", item.get("UrName"));
			
			item.put("CompanyCode", coviData.get("CompanyCode"));
			item.put("Reason", coviData.get("Comment"));
			
			item.put("AppDate", today);
			item.put("EndDate", today);
			item.put("ProcessId", coviData.get("ReqSeq"));

			//vacationinfo_day 정보삽입
			CoviMap paramMap2 = new CoviMap();
			paramMap2.put("gubun", gubun);
			paramMap2.put("VacDate", item.get("WorkDate"));
			paramMap2.put("vacFlag", item.get("VacFlag"));
			paramMap2.put("vacOffFlag", item.get("VacOffFlag"));
			paramMap2.put("startTime", item.get("startTime"));
			paramMap2.put("endTime", item.get("endTime"));
			paramMap2.put("domainID", SessionHelper.getSession("DN_ID"));
			paramMap2.put("sDate", item.get("WorkDate").toString().replace("-",""));
			paramMap2.put("domainCode", SessionHelper.getSession("DN_Code"));
			
			if (coviData.getString("AuthType").equals("ADMIN") ) {
				item.put("Gubun", "VACATION_PUBLIC");
				item.put("UserCode", userCode);
				item.put("UrName", userName);
				
				coviMapperOne.insert("attend.req.insertVacationInfo", item);
				paramMap2.put("vacationInfoID",item.get("vacationInfoID"));
				paramMap2.put("urCode",userCode);
				coviMapperOne.insert("groupware.vacation.insertVacationInfoDayApplyVac", paramMap2);
				coviMapperOne.insert("attend.req.insertAttendCommutingMst", item);
				// 이월연차 갱신
				CoviMap vacConfig = coviMapperOne.selectOne("groupware.vacation.selectConfig", paramMap2);
				if(StringUtil.replaceNull(vacConfig.getString("IsRemRenewal")).equals("Y")) {
				int updateCnt = coviMapperOne.update("groupware.vacation.updateLastVacDay", paramMap2);
				// 이월연차 부여이력
				if (updateCnt > 0 && !StringUtil.replaceNull(vacConfig.getString("RemMethod")).equals("N")) {
					paramMap2.put("vacKind", "PUBLIC");
					paramMap2.put("CompanyCode", coviData.get("CompanyCode"));
					paramMap2.put("vacDay", ((int) coviMapperOne.getNumber("groupware.vacation.selectVacDay", paramMap2))*-1);
					paramMap2.put("sDate", paramMap2.getString("UseStartDate"));
					paramMap2.put("eDate", paramMap2.getString("UseEndDate"));
					paramMap2.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
					paramMap2.put("comment", "이월자동연차["+paramMap2.getDouble("BeforeVacDay")+"=>"+paramMap2.getDouble("AfterVacDay")+"]");
					paramMap2.put("registerCode", "system"); 
					paramMap2.put("modifierCode", "system"); 
					coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap2);
				}
				}
			} else {
				coviMapperOne.insert("attend.req.insertVacationInfo", item);
				paramMap2.put("vacationInfoID",item.get("vacationInfoID"));
				paramMap2.put("urCode", coviData.get("UserCode"));
				coviMapperOne.insert("groupware.vacation.insertVacationInfoDayApplyVac", paramMap2);
				coviMapperOne.insert("attend.req.insertAttendCommutingMst", item);
				// 이월연차 갱신
				CoviMap vacConfig = coviMapperOne.selectOne("groupware.vacation.selectConfig", paramMap2);
				if(StringUtil.replaceNull(vacConfig.getString("IsRemRenewal")).equals("Y")) {
				int updateCnt = coviMapperOne.update("groupware.vacation.updateLastVacDay", paramMap2);
				// 이월연차 부여이력
				if (updateCnt > 0 && !StringUtil.replaceNull(vacConfig.getString("RemMethod")).equals("N")) {
					paramMap2.put("vacKind", "PUBLIC");
					paramMap2.put("CompanyCode", coviData.get("CompanyCode"));
					paramMap2.put("vacDay", ((int) coviMapperOne.getNumber("groupware.vacation.selectVacDay", paramMap2))*-1);
					paramMap2.put("sDate", paramMap2.getString("UseStartDate"));
					paramMap2.put("eDate", paramMap2.getString("UseEndDate"));
					paramMap2.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
					paramMap2.put("comment", "이월자동연차["+paramMap2.getDouble("BeforeVacDay")+"=>"+paramMap2.getDouble("AfterVacDay")+"]");
					paramMap2.put("registerCode", "system"); 
					paramMap2.put("modifierCode", "system"); 
					coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap2);
				}
				}
			}
			
		}
		resultObject.put("status", Return.SUCCESS);
		return resultObject;
	}

	//휴가신청-전자결재용
	public CoviMap saveVacationApp(String reqType, String reqGubun, CoviMap coviData, List ReqData){
		CoviMap resultObject	= new CoviMap();
		String apvMode = (String)coviData.get("ApvMode");
		
		//String gubun = "VACATION_APPLY";
		for(int i=0; i<ReqData.size(); i++){
			Map item = (Map)ReqData.get(i);
			//System.out.println(item);
			
			//item.put("JobDate", item.get("WorkDate"));
			
			item.put("ReqType", reqType);
			item.put("ReqGubun", reqGubun);
			item.put("JobDate", coviData.get("WorkDate"));

			item.put("BillName", coviData.get("ReqTitle"));
			item.put("UserCode", coviData.get("UserCode"));	
			item.put("RegisterCode", coviData.get("RegisterCode"));	
			item.put("CompanyCode", coviData.get("CompanyCode"));	
			item.put("Etc", coviData.get("Comment"));	
			
			item.put("BillName", coviData.get("ReqTitle")); 
			item.put("UserCode", coviData.get("UserCode"));	
			item.put("RegisterCode", coviData.get("RegisterCode"));	
			item.put("UrCode", coviData.get("UserCode"));	
			item.put("UrName", coviData.get("UserName"));	
			
			item.put("CompanyCode", coviData.get("CompanyCode"));	
			item.put("Reason", coviData.get("Comment"));	
			
			coviMapperOne.insert("attend.req.insertVacationInfoApp", item);
			
			// 완료 시 days delete and insert
			if(apvMode.equals("COMPLETE")) {			
				if(!item.get("Gubun").toString().equals("VACATION_CANCEL")) {
					coviMapperOne.insert("attend.req.insertVacationInfoDayApp", item);
				}else {
					coviMapperOne.delete("attend.req.deleteVacationInfoDayApp", item);
				}
				// 이월연차 갱신
				CoviMap paramMap = new CoviMap();
				paramMap.put("urCode", coviData.get("UserCode"));
				CoviMap vacConfig = coviMapperOne.selectOne("groupware.vacation.selectConfig", paramMap);
				if(StringUtil.replaceNull(vacConfig.getString("IsRemRenewal")).equals("Y")) {
				paramMap.put("sDate", item.get("SDate").toString().replace("-", ""));
				int updateCnt = coviMapperOne.update("groupware.vacation.updateLastVacDay", paramMap);
				// 이월연차 부여이력
				if (updateCnt>0 && !StringUtil.replaceNull(vacConfig.getString("RemMethod")).equals("N")) {
					paramMap.put("vacKind", "PUBLIC");
					paramMap.put("vacDay", item.get("VacDay"));
					paramMap.put("sDate", paramMap.getString("UseStartDate"));
					paramMap.put("eDate", paramMap.getString("UseEndDate"));
					paramMap.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
					paramMap.put("comment", "이월자동연차["+paramMap.getDouble("BeforeVacDay")+"=>"+paramMap.getDouble("AfterVacDay")+"]");
					paramMap.put("registerCode", "system"); 
					paramMap.put("modifierCode", "system"); 
					coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap);
				}
				}
			}
			coviMapperOne.insert("attend.req.insertAttendCommutingMstVcation", item);
		}
		resultObject.put("status", Return.SUCCESS);
		return resultObject;
	}
	
	//근무일정신청
	public CoviMap saveSchedule(String reqType, String reqGubun, CoviMap coviData, List ReqData){
		CoviMap resultObject	= new CoviMap();

		CoviMap params = new CoviMap();
		params.put("ReqGubun", "C");
		//params.put("StartTime", ((Map)ReqData.get(0)).get("StartTime"));
		//params.put("HolidayFlag", coviData.get("UR_Code"));
		params.put("ReqData", ReqData);
		params.put("UserCode", coviData.get("UserCode"));
		//CoviMap resultMap	= coviMapperOne.selectOne("attend.req.getVacationInfo", params);	
		
		String SchSeq = "0";
		String HolidayFlag = (String) ((Map)ReqData.get(0)).get("HolidayFlag");
		String StartTime = "";
		String EndTime = "";
		String NextDayYn = "N";

		int cnt = 0;
		java.util.HashMap ht = new java.util.HashMap();
		//스케쥴별로 쪼개기
		for(int i=0; i<ReqData.size(); i++){
			Map item = (Map)ReqData.get(i);

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
					trgDates.append(item.get("WorkDate"));
					tmpMap.put(key, trgDates);
				} else {
					trgDates.append(item.get("WorkDate"));
					tmpMap.put(key, trgDates);
				}
				ht.put(schSeq, tmpMap);

			} else { //선택
				if (ht.get(schSeq) != null) {
					trgDates = (StringBuffer) ht.get(schSeq);
					trgDates.append(":");
				}
				trgDates.append(item.get("WorkDate"));
				ht.put(schSeq, trgDates);
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
					item.put("JobUserCode", coviData.get("UserCode"));
					item.put("TrgDates", value.toString());
					item.put("HolidayFlag", HolidayFlag);
					item.put("CompanyCode", coviData.get("CompanyCode"));
					item.put("USERID", coviData.get("UserCode"));
					item.put("StartTime", paramValues[0]);
					item.put("EndTime", paramValues[1]);
					item.put("NextDayYn", paramValues[2]);
					coviMapperOne.update("attend.job.createScheduleJobDivDirect", item);
					//CoviMap retMap = coviMapperOne.selectOne("attend.job.createScheduleJobDivDirect", item);
					cnt += item.getInt("RetCount");
				}
			} else { // 선택 처리
				StringBuffer value = (StringBuffer)entry.getValue();

				CoviMap item = new CoviMap();
				item.put("SchSeq", key);
				item.put("JobUserCode", coviData.get("UserCode"));
				item.put("TrgDates", value.toString());
				item.put("HolidayFlag", HolidayFlag);
				item.put("CompanyCode", coviData.get("CompanyCode"));
				item.put("USERID", coviData.get("UserCode"));
				//CoviMap retMap = coviMapperOne.selectOne("attend.job.createScheduleJobDiv", item);
				coviMapperOne.update("attend.job.createScheduleJobDiv", item);
				cnt += item.getInt("RetCount");
			}
		}

		resultObject.put("status", Return.SUCCESS);
		return resultObject;
	}

	//근무일정신청
	public CoviMap saveScheduleRepeat(String reqType, String reqGubun, CoviMap coviData, List  ReqData){
		CoviMap resultObject	= new CoviMap();

		Map item = (Map)ReqData.get(0);
		item.put("JobUserCode", coviData.get("UserCode"));
		item.put("CompanyCode", coviData.get("CompanyCode"));
		item.put("USERID", coviData.get("UserCode"));

		String SchSeq = (String)item.get("SchSeq");

		//CoviMap retMap = null;
		if(!"-1".equals(SchSeq)) {
			coviMapperOne.update("attend.job.createScheduleJob", item);
			//retMap = coviMapperOne.selectOne("attend.job.createScheduleJob", item);
		} else {
			coviMapperOne.update("attend.job.createScheduleJobDirect", item);
			//retMap = coviMapperOne.selectOne("attend.job.createScheduleJobDirect", item);
		}

		resultObject.put("status", Return.SUCCESS);
		return resultObject;
	}

	
	@Override
	public CoviMap requestCommute(CoviMap params, CoviMap reqData) throws Exception {
		
		CoviMap resultList = new CoviMap();
		
		String ReqStatus = params.getString("ReqStatus");
		String ReqType = params.getString("ReqType");
		
		reqData.put("Status", "lbl_adstandby"); // 출퇴근 요청에 따라 StartSts 또는 EndSts에 승인대기를 저장
		
		int cnt = 0;
		int approvalStatusCnt = 0;
		// 요청관리 테이블에 해당 출퇴근 요청건 추가
		cnt = coviMapperOne.insert("attend.req.insertAttendRequest", params);
		// 출퇴근 요청을 했을 경우, 승인에 대한 상태 업데이트
		approvalStatusCnt = coviMapperOne.update("attend.req.updateApprovalCommuteStatus", reqData);
		
		// 승인건이면 근무이력 테이블로 가기
		if("Approval".equals(ReqStatus)) {
			CoviMap coviData = new CoviMap();
			coviData.put("ReqTitle", params.getString("ReqTitle"));
			//coviData.put("UR_Code", params.get("UserCode"));
			coviData.put("RegisterCode", params.getString("UserCode"));
			coviData.put("CompanyCode", params.getString("CompanyCode"));
			coviData.put("Comment", params.getString("Comment"));
			coviData.put("CommuteIp", params.getString("CommuteIp"));
			
			CoviMap resultObject = saveCommute(ReqType, "C", coviData, (List) params.get("ReqData"));
		}
		
		resultList.put("resultCnt", cnt);
		resultList.put("status", Return.SUCCESS);
		
		return resultList;
	}

	@Override
	public CoviMap saveCommute(String reqType, String reqGubun, CoviMap coviData, List ReqData) throws Exception {
		CoviMap resultObject	= new CoviMap();

		for(int i=0; i<ReqData.size(); i++){
			Map item = (Map)ReqData.get(i);
			
			String targetDate =  (String) item.get("TargetDate");
			String userCode = (String)item.get("UserCode");
			String commuteChannel = (String)item.get("CommuteChannel");
			String regUserCode = (String) coviData.get("RegisterCode");
			String commuteIp = (String) coviData.get("CommuteIp");
			
			String startDate = null;
			String endDate = null;
			
			String startPointX = null;
			String startPointY = null;
			String endPointX = null;
			String endPointY = null;
			
			if("S".equals(item.get("CommuteType"))){
				startDate = (String) item.get("CommuteTime");				
				startPointX = item.get("CommutePointX")!=null?String.valueOf(item.get("CommutePointX")):null;
				startPointY = item.get("CommutePointY")!=null?String.valueOf(item.get("CommutePointY")):null;
			}else if("E".equals(item.get("CommuteType"))){
				endDate = (String) item.get("CommuteTime");				
				endPointX = item.get("CommutePointX")!=null?String.valueOf(item.get("CommutePointX")):null;
				endPointY = item.get("CommutePointY")!=null?String.valueOf(item.get("CommutePointY")):null;
			}
			
			String etc = (String) coviData.get("Comment");
			String companyCode = (String) coviData.get("CompanyCode");
			
			CoviMap point = new CoviMap();
			point.put("StartPointX", startPointX);
			point.put("StartPointY", startPointY);
			point.put("EndPointX", endPointX);
			point.put("EndPointY", endPointY);
			
			setCommuteMng(targetDate,userCode,regUserCode,startDate,endDate,etc,companyCode,commuteChannel,commuteIp,point);
		}

		resultObject.put("status", Return.SUCCESS);
		return resultObject;
	}

	
	public CoviMap setCommuteMng(String TargetDate, String UserCode, String RegUserCode, String StartDate, String EndDate, String Etc, String CompanyCode, String CommuteChannel, String CommuteIp, CoviMap point) throws Exception {
		
		CoviMap returnMap = new CoviMap();
		
		if (TargetDate == null || "".equals(TargetDate)) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "TargetDate is null");
		} else if (UserCode == null || "".equals(UserCode)) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "UserCode is null");
		} else if (CompanyCode == null || "".equals(CompanyCode)) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", "CompanyCode is null");
		} else {
			try{
				CoviMap params = new CoviMap();
				params.put("TargetDate", TargetDate);
				params.put("UserCode", UserCode);
				params.put("RegUserCode", RegUserCode == null || "".equals(RegUserCode) ? "system" : RegUserCode);
				params.put("StartDate", StartDate);
				params.put("EndDate", EndDate);
				params.put("UserEtc", Etc);
				params.put("CompanyCode", CompanyCode);
				params.put("CommuteIp", CommuteIp);
				params.put("StartPointX", point.get("StartPointX"));
				params.put("StartPointY", point.get("StartPointY"));
				params.put("EndPointX", point.get("EndPointX"));
				params.put("EndPointY", point.get("EndPointY"));
				
				//좌표로 주소 정보 저장
				if( point.get("StartPointX")!=null &&  point.get("StartPointY")!=null){
					params.put("StartAddr", AttendUtils.getCommuteAddr(point.getString("StartPointX"),point.getString("StartPointY")));
				}
				
				if( point.get("EndPointX")!=null &&  point.get("EndPointY")!=null){
					params.put("EndAddr", AttendUtils.getCommuteAddr(point.getString("EndPointX"), point.getString("EndPointY")));
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
				coviMapperOne.update("attend.commute.setAttCommuteMng", params);
				
				//출퇴근 HISTORY
				CoviMap hisParams = new CoviMap();
				CoviList jobJsonArray = getMngJob(UserCode, TargetDate, CompanyCode, params.getString("StartTime"));
				
				if(jobJsonArray.size()>0){				
					CoviMap jobObj = jobJsonArray.getJSONObject(0);
					
					hisParams.put("SchSeq", jobObj.get("SchSeq"));
					hisParams.put("AttDaySts", jobObj.get("WorkSts"));
					
					if (!StringUtil.replaceNull(jobObj.get("AttDayStartTime"),"").equals("")){
						hisParams.put("AttDayStartTime", jobObj.get("AttDayStartTime"));
						hisParams.put("AttDayEndTime", jobObj.get("AttDayEndTime"));
					}	
					
					hisParams.put("AttDayAc", jobObj.get("AttDayAC"));
					hisParams.put("CommuSeq", commuteSeq);
					hisParams.put("CompanyCode", CompanyCode);
					hisParams.put("UserCode", UserCode);
					hisParams.put("TargetDate", TargetDate);
					hisParams.put("RegUserCode", RegUserCode);				
	
					if( params.get("StartPointX") != null && params.get("StartPointY") != null ){
						hisParams.put("StartTime", params.get("StartDate"));
						hisParams.put("StartPointX", params.get("StartPointX"));
						hisParams.put("StartPointY", params.get("StartPointY"));
						hisParams.put("StartIpAddr", params.get("CommuteIp"));
						hisParams.put("StartChannel", CommuteChannel);
						hisParams.put("StartAddr", AttendUtils.getCommuteAddr(params.getString("StartPointX"),params.getString("StartPointY")));				    
					}				
	
					if( params.get("EndPointX") != null && params.get("EndPointY") != null ){
						hisParams.put("EndTime", params.get("EndDate"));
						hisParams.put("EndPointX", params.get("EndPointX"));
						hisParams.put("EndPointY", params.get("EndPointY"));
						hisParams.put("EndIpAddr", params.get("CommuteIp"));
						hisParams.put("EndChannel", CommuteChannel);
						hisParams.put("EndAddr", AttendUtils.getCommuteAddr(params.getString("EndPointX"),params.getString("EndPointY")));
					}
					
					coviMapperOne.insert("attend.commute.setCommuteHistory", hisParams);
				}
				
				//출퇴근 시간 외 정보 재입력
				//coviMapperOne.update("attend.commute.setCommuteMstProc", params);
				//coviMapperOne.selectOne("attend.commute.setCommuteMstProc", params);

				returnMap.put("status", Return.SUCCESS); 
			} catch(NullPointerException e){
				LOGGER.error(e.getLocalizedMessage(), e);
				returnMap.put("status", Return.FAIL); 
				returnMap.put("message", e.toString());
			} catch(Exception e){
				LOGGER.error(e.getLocalizedMessage(), e);
				returnMap.put("status", Return.FAIL); 
				returnMap.put("message", e.toString());
			}
		}
		return returnMap;
	}
	
	//전자결재승인관련
	public CoviMap approvalAttendEApproval (CoviMap reqMap, List objList) throws Exception {
		CoviMap resultMap	= new CoviMap();
		int resultCnt = 0;
		CoviMap getMap = new CoviMap();
		String reqType = (String)reqMap.get("ReqType");
		String reqGubun= (String)reqMap.get("ReqGubun");

		CoviMap resultObject = new CoviMap();
		if (!reqType.equals("V")){//휴가는 체크 제외
			resultObject =validateRequest(reqType, reqGubun, reqMap, objList);
			if (resultObject.get("status")== Return.FAIL){
				return resultObject;
			}
		}
		
		switch (reqType)
		{
			case "O":	//연장
				if (!reqGubun.equals("C")){//기존 정보 삭제
					coviMapperOne.insert("attend.req.deleteAttendExtensionholiday", reqMap);
					reqGubun = "C";
				}
				if (!reqGubun.equals("D")){ 
					reqGubun = "C";
					resultObject =saveOverTime(reqType, reqGubun, reqMap, objList);
				}	
				break;
			case "H":	//휴일근무
				if (!reqGubun.equals("C")){//기존 정보 삭제
					coviMapperOne.insert("attend.req.deleteAttendExtensionholiday", reqMap);
					reqGubun = "C";
				}
				if (!reqGubun.equals("D")){ 
					reqGubun = "C";
					resultObject = saveHoliday(reqType, reqGubun, reqMap, objList);
				}	
				break;
			case "HR":	//휴일대체근무신청서
				resultObject = updateAttendMngJob(reqType, reqGubun, reqMap);
				break;
			case "C":	//소명
				reqMap.put("CommuteIp", reqMap.getString("CommuteIp"));
				reqMap.put("CommuteChannel", "I");
				
				resultObject = saveCall(reqType, reqGubun, reqMap, objList);
				break;
			case "J":	//기타근무
				resultObject = saveJobStatus(reqType, reqGubun, reqMap, objList);
				break;
			case "V":	//휴가신청
				resultObject = saveVacationApp(reqType, reqGubun, reqMap, objList);
				if (reqGubun.equals("D")){	//휴가 취소 신청서이면  
					CoviMap param = new CoviMap();
		    		param.put("RequestFIID", reqMap.getString("HID_REQUEST_FIID")); //의미상 남겨놓음(휴가신청서의 FIID)
		    		param.put("FormInstID", reqMap.getString("HID_REQUEST_FIID"));
		    		
		    		CoviMap formInstData = coviMapperOne.select("attend.req.selectFormInstData", param);
		    		String dbBodyContext = formInstData.getString("BodyContext");

		    		JSONParser parser = new JSONParser();
					CoviMap dbBodyContextObj = (CoviMap)parser.parse(new String(Base64.decodeBase64(dbBodyContext), StandardCharsets.UTF_8)) ;
		        		
		    		//JSONObject dbBodyContextObj = CoviMap.fromObject( new String(Base64.decodeBase64(dbBodyContext)));
		    		dbBodyContextObj.remove("HID_REQUEST_FIID");
		    		dbBodyContextObj.put("HID_CANCLE_FIID", reqMap.getString("formInstID"));
		    		
		    		param.clear();
		    		param.put("BODYCONTEXT", new String( Base64.encodeBase64( dbBodyContextObj.toString().getBytes(StandardCharsets.UTF_8) ), StandardCharsets.UTF_8) );
		    		param.put("FIID", reqMap.getString("HID_REQUEST_FIID"));
		    		
		    		coviMapperOne.update("attend.req.usp_form_UpdateBodyContext", param);

				}
				break;
			case "S":	//근무일정
				for (int i=0; i < objList.size(); i++){
					List dataList = new java.util.ArrayList();
					dataList.add(objList.get(i));
					resultObject = saveScheduleRepeat(reqType, reqGubun, reqMap, dataList);
				}
				break;
			case "A" : case "L":	//출/퇴근요청
				resultObject = saveCommute(reqType, reqGubun, reqMap, objList);
				break;
			
			default :
				break;
		}
		if (resultObject.get("status") == Return.SUCCESS){
			String reqDataStr = "";
			if ( objList.size() > 0){
				reqDataStr = AttendUtils.getJsonArrayFromList(objList).toString();
				reqDataStr = reqDataStr.replace("\"","\\\"");
			}	
			reqMap.put("ReqDataStr", reqDataStr);
			resultCnt = coviMapperOne.insert("attend.req.insertAttendRequest", reqMap);
		}
		else{
			return resultObject;
		}
		//resultMap
		resultMap.put("resultCnt", resultCnt);
		resultMap.put("result", "ok");
		resultMap.put("status", Return.SUCCESS);
		
//			resultMap.put("cnt", value)
		return resultMap;
	}

	// 휴일대체근무신청
	public CoviMap updateAttendMngJob(String reqType, String reqGubun, CoviMap coviData){
		CoviMap resultObject	= new CoviMap();

		CoviMap paramHoli = new CoviMap();
		paramHoli.put("UserCode", coviData.get("UserCode"));
		paramHoli.put("SelectDate", coviData.get("HolidayDate"));
		paramHoli.put("JobDate", coviData.get("AlternativeHolidayDate"));
		paramHoli.put("CompanyCode", coviData.get("CompanyCode"));

		/*holyJob.put("ReqType", reqType);
		holyJob.put("ReqGubun", reqGubun);

		holyJob.put("BillName", coviData.get("ReqTitle"));
		holyJob.put("RegisterCode", coviData.get("RegisterCode"));
		holyJob.put("ProcessId", coviData.get("ProcessId"));*/

		CoviMap holiJob = coviMapperOne.selectOne("attend.req.selectAttendMngJobInfo", paramHoli); //휴일정보


		CoviMap paramWork = new CoviMap();
		paramWork.put("UserCode", coviData.get("UserCode"));
		paramWork.put("SelectDate", coviData.get("AlternativeHolidayDate"));
		paramWork.put("JobDate", coviData.get("HolidayDate"));
		paramWork.put("CompanyCode", coviData.get("CompanyCode"));

		/*workJob.put("ReqType", reqType);
		workJob.put("ReqGubun", reqGubun);

		workJob.put("BillName", coviData.get("ReqTitle"));
		workJob.put("RegisterCode", coviData.get("RegisterCode"));
		workJob.put("ProcessId", coviData.get("ProcessId"));*/

		CoviMap workJob = coviMapperOne.selectOne("attend.req.selectAttendMngJobInfo", paramWork); //대체일 정보

		if(holiJob != null) {
			holiJob.putAll(paramHoli);
			coviMapperOne.update("attend.req.updateAttendMngJob", holiJob); //대체일 -> 휴일
		}

		if(workJob != null) {
			workJob.putAll(paramWork);
			coviMapperOne.update("attend.req.updateAttendMngJob", workJob); //휴일 -> 대체일
		}

		resultObject.put("status", Return.SUCCESS);
		return resultObject;
	}

	/**
	 * 진행중 휴가신청/취소신청 건 정보 
	 */
	@Override
	public CoviMap approvalAttendPApproval(CoviMap reqMap, List objList) throws Exception {
		CoviMap resultMap	= new CoviMap();
		int resultCnt = 0;
		CoviMap getMap = new CoviMap();
		String reqType = (String)reqMap.get("ReqType");

		CoviMap resultObject = new CoviMap();
		
		// vm_vacation_process insert exists / delete
		switch ((String)reqMap.get("ApvMode")) {
		case "COMPLETE":
		case "WITHDRAW":
		case "ABORT":
		case "REJECT":
			// delete
			resultObject = deleteVacationProcess(reqType, reqMap, objList);
			if("COMPLETE".equals((String)reqMap.get("ApvMode")) && "D".equals(reqMap.get("ReqGubun"))) {// 휴가취소신청 완료시.
				reqMap.put("FormInstID", reqMap.getString("HID_REQUEST_FIID"));// 휴가신청서 FormInstID
				resultObject = deleteVacationProcess(reqType, reqMap, objList);
			}
			break;

		default:
			// insert
			resultObject = saveVacationProcess(reqType, reqMap, objList);
			break;
		}

		resultMap.put("result", "ok");
		resultMap.put("status", Return.SUCCESS);
		
		return resultMap;
	}
	
	/**
	 * 
	 * @param reqType
	 * @param coviData
	 * @param ReqData
	 * @return
	 */
	public CoviMap saveVacationProcess(String reqType, CoviMap coviData, List ReqData){
		CoviMap resultObject	= new CoviMap();
		long count = coviMapperOne.getNumber("attend.req.selectVacationProcess", coviData);
		if(count == 0) {
			for(int i=0; i < ReqData.size(); i++){
				Map item = (Map)ReqData.get(i);
				
				item.put("ReqType", reqType);
				item.put("JobDate", coviData.get("WorkDate"));
				
				item.put("BillName", coviData.get("ReqTitle"));
				item.put("UserCode", coviData.get("UserCode"));	
				item.put("RegisterCode", coviData.get("RegisterCode"));	
				item.put("CompanyCode", coviData.get("CompanyCode"));	
				item.put("Etc", coviData.get("Comment"));	
				
				item.put("BillName", coviData.get("ReqTitle")); 
				item.put("UserCode", coviData.get("UserCode"));	
				item.put("RegisterCode", coviData.get("RegisterCode"));	
				item.put("UrCode", coviData.get("UserCode"));	
				item.put("UrName", coviData.get("UserName"));	
				
				item.put("CompanyCode", coviData.get("CompanyCode"));	
				item.put("Reason", coviData.get("Comment"));	
				item.put("FormInstID", coviData.get("FormInstID"));	
				
				coviMapperOne.insert("attend.req.insertVacationProcess", item);
			}
		}
		resultObject.put("status", Return.SUCCESS);
		return resultObject;
	}
	
	/**
	 * 
	 * @param reqType
	 * @param coviData
	 * @param ReqData
	 * @return
	 */
	public CoviMap deleteVacationProcess(String reqType, CoviMap coviData, List ReqData){
		CoviMap resultObject	= new CoviMap();
		coviMapperOne.delete("attend.req.deleteVacationProcess", coviData);
		resultObject.put("status", Return.SUCCESS);
		return resultObject;
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
	public int getUsedVacationListCnt(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("attend.req.getUsedVacListCnt", params);
	}
	
	@Override
	public CoviMap getUsedVacationList(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = getUsedVacationListCnt(params);
			params.addAll(ComUtils.setPagingData(params, cnt));
			returnList.put("page", params);
			returnList.put("cnt", cnt); 
		}
		
		CoviList resultList = coviMapperOne.list("attend.req.getUsedVacList", params);
		returnList.put("list", resultList); 		
		
		return returnList;
	}
	
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
}
