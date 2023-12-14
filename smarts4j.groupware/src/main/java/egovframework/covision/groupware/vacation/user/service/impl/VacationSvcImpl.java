package egovframework.covision.groupware.vacation.user.service.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Date;

import javax.annotation.Resource;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;

import egovframework.baseframework.base.Enums;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import egovframework.baseframework.data.CoviList;

import org.json.simple.parser.JSONParser;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.vacation.user.service.VacationSvc;
import egovframework.covision.groupware.vacation.user.web.VacationListVO;
import egovframework.covision.groupware.vacation.user.web.VacationVO;

@Service("vacationSvc")
public class VacationSvcImpl extends EgovAbstractServiceImpl implements VacationSvc {
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	private static final String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
	
	private static final Logger LOGGER = LogManager.getLogger(VacationSvcImpl.class);
	
	// 연차관리 조회
	@Override
	public CoviMap getVacationDayList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = 0;
		if(params.containsKey("pageNo")) {
			cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationDayListCnt", params);
			page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			resultList.put("page", page);
		}
		CoviList list = new CoviList();
		list = coviMapperOne.list("groupware.vacation.selectVacationDayList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,VacDay,DeptName,JobPositionName,DisplayName,EnterDate,RetireDate,YEAR,ExpDateStart,ExpDateEnd,UseVacDay,RemainVacDay,Reason,UseStartDate,UseEndDate,RegisterCode,LastVacDay,LongVacDay"));
		
		return resultList;
	}
	
	// 내년도 휴가 등록
	@Override
	public int insertNextVacation(CoviMap params) throws Exception {
		int rtn = 0;
		CoviMap req = new CoviMap();
		req.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		req.put("getName", "CreateMethod");
		String CreateMethod = getVacationConfigVal(req);
		if(CreateMethod==null || CreateMethod.equals("")){
			CreateMethod = "F";
		}
		CoviMap paramMap = new CoviMap();
		VacationListVO listVO = (VacationListVO) params.get("vacationListVo");
		List<VacationVO> vacationList= listVO.getVacations();
		
		for(VacationVO vo : vacationList) {
			paramMap.clear();
			paramMap.put("urCode", vo.getUrCode());
			paramMap.put("longVacDay", vo.getVacDay());
			paramMap.put("lang", SessionHelper.getSession("lang"));
			paramMap.put("year", vo.getYear());
			paramMap.put("vacKind", "PUBLIC");
			paramMap.put("registerCode", SessionHelper.getSession("UR_Code"));
			paramMap.put("domainCode", SessionHelper.getSession("DN_Code"));
			if(CreateMethod.equals("F")) {
				rtn += coviMapperOne.update("groupware.vacation.updateVacationPlan", paramMap);
			}else{
				rtn += coviMapperOne.update("groupware.vacation.updateVacationPlanV2", paramMap);
			}
			paramMap.put("sDate", paramMap.getString("FromDate"));
			paramMap.put("eDate", paramMap.getString("ToDate"));
			paramMap.put("vacDay", vo.getVacDay());
			paramMap.put("vmMethod", "MNL"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
			paramMap.put("comment","연차등록");
			coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap);
		}
		
		return rtn;
	}


	public boolean duplicateUserCheck(List objUsers, String userCode){
		boolean duplicateUser = false;
		for (int j = 0; j < objUsers.size(); j++) {
			if (objUsers.get(j).toString().equals(userCode)) {
				duplicateUser = true;
				break;
			}
		}
		return duplicateUser;
	}
	// 기타 휴가 체크
	@Override
	public CoviMap checkExtraVacation(CoviMap params, List userCodeList) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		CoviMap paramMap = new CoviMap();

		List objUsers = new ArrayList();
		for (int k=0; k < userCodeList.size();k++){
			Map itemUser = (Map)userCodeList.get(k);
			if (itemUser.get("Type").equals("UR")){
				if(!duplicateUserCheck(objUsers, itemUser.get("Code").toString())){
					objUsers.add(itemUser.get("Code"));
				}
			}
			else{
				CoviMap deptParam = new CoviMap();
				deptParam.put("CompanyCode",params.get("CompanyCode"));
				deptParam.put("sDeptCode", itemUser.get("Code"));

				CoviList userList = coviMapperOne.list("attend.common.getUserListByDept", deptParam);
				for (int i = 0; i < userList.size(); i++){
					if(!duplicateUserCheck(objUsers, userList.getMap(i).getString("UserCode"))) {
						objUsers.add(userList.getMap(i).getString("UserCode"));
					}
				}
			}
		}

		paramMap.put("urCode", objUsers);
		paramMap.put("vacDay", params.getString("vacDay"));
		paramMap.put("year", params.getString("year"));
		paramMap.put("vacKind", params.getString("vacKind"));
		paramMap.put("sDate", params.getString("sDate"));
		paramMap.put("eDate", params.getString("eDate"));
		paramMap.put("domainID", params.getString("CompanyCode"));

		if(params.containsKey("pageNo")) {
			int cnt = objUsers.size();
			// System.out.println("#####cnt:"+cnt);
			page = ComUtils.setPagingData(params,cnt);
			paramMap.addAll(page);
			resultList.put("page", page);
		}
		CoviList list = coviMapperOne.list("groupware.vacation.checkVacationExtraPlan", paramMap);
		if(list.size()>0) {
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,VacDay,DeptName,JobPositionName,DisplayName,Year,TotVacDay,ExistDate"));
			resultList.put("status", Enums.Return.SUCCESS);
		}else{
			resultList.put("status", Enums.Return.FAIL);
		}
		return resultList;
	}

	// 기타 휴가 등록
	@Override
	public int insertExtraVacation(CoviMap params, List userCodeList) throws Exception {
		int rtn = 0;

		CoviMap paramMap = new CoviMap();

		List objUsers = new ArrayList();
		for (int k=0; k < userCodeList.size();k++){
			Map itemUser = (Map)userCodeList.get(k);
			if (itemUser.get("Type").equals("UR")){
				if(!duplicateUserCheck(objUsers, itemUser.get("Code").toString())){
					objUsers.add(itemUser.get("Code"));
				}
			}
			else{
				CoviMap deptParam = new CoviMap();
				deptParam.put("CompanyCode",params.get("CompanyCode"));
				deptParam.put("sDeptCode", itemUser.get("Code"));

				CoviList userList = coviMapperOne.list("attend.common.getUserListByDept", deptParam);
				for (int i = 0; i < userList.size(); i++){
					if(!duplicateUserCheck(objUsers, userList.getMap(i).getString("UserCode"))) {
						objUsers.add(userList.getMap(i).getString("UserCode"));
					}
				}
			}
		}

		for(int i=0; i<objUsers.size(); i++) {
			paramMap.clear();
			paramMap.put("urCode", objUsers.get(i));
			paramMap.put("vacDay", params.getString("vacDay"));
			paramMap.put("year", params.getString("year"));
			paramMap.put("comment", params.getString("comment"));
			paramMap.put("sDate", params.getString("sDate"));
			paramMap.put("eDate", params.getString("eDate"));
			paramMap.put("vacKind", params.getString("vacKind"));
			paramMap.put("registerCode", SessionHelper.getSession("UR_Code"));
			paramMap.put("vmMethod", "MNL"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
			rtn += coviMapperOne.update("groupware.vacation.insertExtraVacationPlan", paramMap);
			coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap);
		}

		return rtn;
	}
	
	// 보상 휴가 등록
	@Override
	public int insertRewardVacation(CoviMap params, List userCodeList) throws Exception {
		int rtn = 0;

		CoviMap paramMap = new CoviMap();

		List objUsers = new ArrayList();
		for (int k=0; k < userCodeList.size();k++){
			Map itemUser = (Map)userCodeList.get(k);
			if (itemUser.get("Type").equals("UR")){
				if(!duplicateUserCheck(objUsers, itemUser.get("Code").toString())){
					objUsers.add(itemUser.get("Code"));
				}
			}
			else{
				CoviMap deptParam = new CoviMap();
				deptParam.put("CompanyCode",params.get("CompanyCode"));
				deptParam.put("sDeptCode", itemUser.get("Code"));

				CoviList userList = coviMapperOne.list("attend.common.getUserListByDept", deptParam);
				for (int i = 0; i < userList.size(); i++){
					if(!duplicateUserCheck(objUsers, userList.getMap(i).getString("UserCode"))) {
						objUsers.add(userList.getMap(i).getString("UserCode"));
					}
				}
			}
		}

		for(int i=0; i<objUsers.size(); i++) {
			paramMap.clear();
			paramMap.put("urCode", objUsers.get(i));
			paramMap.put("vacDay", params.getString("vacDay"));
			paramMap.put("rewardVacDay", params.getString("rewardVacDay"));
			paramMap.put("year", params.getString("year"));
			paramMap.put("comment", params.getString("comment"));
			paramMap.put("sDate", params.getString("sDate"));
			paramMap.put("eDate", params.getString("eDate"));
			paramMap.put("vacKind", params.getString("vacKind"));
			paramMap.put("registerCode", SessionHelper.getSession("UR_Code"));
			paramMap.put("vmMethod", "MNL"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
			rtn += coviMapperOne.update("groupware.vacation.insertRewardVacation", paramMap);
			coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap);
		}

		return rtn;
	}
	
	// 보상 휴가 등록 API
	@Override
	public int insertRewardVacationAPI(CoviList paramsList) throws Exception {
		int rtn = 0;
		
		for(int i = 0; i < paramsList.size(); i++){
			CoviMap params  = (CoviMap) paramsList.getJSONObject(i);
			CoviMap paramMap = new CoviMap();
			paramMap.put("urCode", params.getString("urCode"));
			paramMap.put("vacKind", params.getString("vacKind"));
			paramMap.put("comment", params.getString("comment"));
			paramMap.put("eDate", params.getString("eDate"));
			paramMap.put("sDate", params.getString("sDate"));
			paramMap.put("year", params.getString("year"));
			paramMap.put("vmMethod", "MNL");

			int cnt = (int) coviMapperOne.getNumber("groupware.vacation.checkRewardVacation", params);
			
			if(cnt > 0) {
				int currentRewardVacDay = (int) coviMapperOne.getNumber("groupware.vacation.selectRewardVacDay", params);
				double oriVacDay = ((int)(currentRewardVacDay / 60)) * 0.125;
				
				int addRewardVacDay = currentRewardVacDay + params.getInt("rewardVacDay");
				double addVacDay = ((int)(addRewardVacDay / 60)) * 0.125;
				
				paramMap.put("vacDay", addVacDay);
				paramMap.put("rewardVacDay", addRewardVacDay);
				paramMap.put("extSdate", params.getString("sDate"));
				paramMap.put("extEdate", params.getString("eDate"));
				paramMap.put("comment",  "["+oriVacDay+"=>"+addVacDay+"] " + params.getString("comment"));
				
				rtn += coviMapperOne.update("groupware.vacation.updateRewardVacDay", paramMap);
			} else {
				//최초등록
				double vacDay = ((int)(params.getInt("rewardVacDay") / 60)) * 0.125;
				
				paramMap.put("vacDay", vacDay);
				paramMap.put("rewardVacDay", params.getInt("rewardVacDay"));
				
				rtn += coviMapperOne.update("groupware.vacation.insertRewardVacation", paramMap);
			}
			coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap);
		}

		return rtn;
	}
	
	// 보상 휴가 등록 취소 API
	@Override
	public int cancelRewardVacationAPI(CoviList paramsList) throws Exception {
		int rtn = 0;
		
		for(int i = 0; i < paramsList.size(); i++){
			CoviMap params  = (CoviMap) paramsList.getJSONObject(i);
			CoviMap paramMap = new CoviMap();
			paramMap.put("urCode", params.getString("urCode"));
			paramMap.put("comment", params.getString("comment"));
			paramMap.put("sDate", params.getString("sDate"));
			paramMap.put("eDate", params.getString("eDate"));
			paramMap.put("vacKind", params.getString("vacKind"));
			paramMap.put("vmMethod", "MNL");

			int cnt = (int) coviMapperOne.getNumber("groupware.vacation.checkRewardVacation", params);
			if(cnt > 0) {
				int currentRewardVacDay = (int) coviMapperOne.getNumber("groupware.vacation.selectRewardVacDay", params);
				double oriVacDay = ((int)(currentRewardVacDay / 60)) * 0.125;
				
				int minRewardVacDay = currentRewardVacDay - params.getInt("rewardVacDay");
				double minVacDay = ((int)(minRewardVacDay / 60)) * 0.125;
				
				paramMap.put("vacDay", minVacDay);
				paramMap.put("rewardVacDay", minRewardVacDay);
				paramMap.put("extSdate", params.getString("sDate"));
				paramMap.put("extEdate", params.getString("eDate"));
				paramMap.put("comment",  "["+oriVacDay+"=>"+minVacDay+"] " + params.getString("comment"));
				
				rtn += coviMapperOne.update("groupware.vacation.updateRewardVacDay", paramMap);
			} else {
				//취소 대상이 없음
				return rtn;
			}
			coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap);
		}
		
		return rtn;
	}

	// 휴가 수정
	@Override
	public int updateVacDay(CoviMap params) throws Exception {
		 int rtn = coviMapperOne.update("groupware.vacation.updateVacDay", params);
		 coviMapperOne.update("groupware.vacation.updateLastVacDay", params);
		 return rtn;
	}

	// 기타 휴가 수정
	@Override
	public int updateExtraVacDay(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.vacation.updateExtraVacDay", params);
	}
	// 보상 휴가 수정
	@Override
	public int updateRewardVacDay(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.vacation.updateRewardVacDay", params);
	}
	// 휴가 정보 등록/갱신 히스토리
	@Override
	public int insertVmPlanHist(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.vacation.insertVmPlanHist", params);
	}
	// 휴가 정보 등록/갱신 히스토리
	@Override
	public int updateVmPlanHist(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.vacation.updateVmPlanHist", params);
	}

	// 연차기간 수정
	@Override
	public int updateVacationPeriod(CoviMap params) throws Exception {
		int rtn = 0;
		
		String insertedPeriod = coviMapperOne.getString("groupware.vacation.selectVacPeriodCode", params);
		
		List<CoviMap> periodList = (List<CoviMap>) params.get("periodList");
		List<CoviMap> insertPeriodList = new ArrayList<CoviMap>();
		List<CoviMap> updatePeriodList = new ArrayList<CoviMap>();
		
		for(CoviMap period : periodList) {
			String code = period.getString("Code");
			
			if(insertedPeriod.indexOf(code) > -1) {
				updatePeriodList.add(period);
			}else {
				insertPeriodList.add(period);
			}
		}
		
		params.put("insertPeriodList", insertPeriodList);
		params.put("updatePeriodList", updatePeriodList);
		
		if(!insertPeriodList.isEmpty()) {
			rtn += coviMapperOne.insert("groupware.vacation.insertVacPeriodCode", params);
		}
		
		if(!updatePeriodList.isEmpty()) {
			rtn += coviMapperOne.update("groupware.vacation.updateVacPeriodCode", params);
		}

		return rtn;
	}
	
	// 나의휴가현황
	@Override
	public CoviMap getMyVacationInfoList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectMyVacationInfoListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("groupware.vacation.selectMyVacationInfoList", params);
		   
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,APPDATE,ENDDATE,GUBUN,VacYear,Sdate,Edate,VacDay,Reason,WorkItemID,ProcessID,VacFlag,VacOffFlag,DeptName,JobPositionName,VacationInfoID,VACTEXT,VacFlagName,GubunName,EXIST_APPROVAL_FORM,EXIST_REQUEST_FORM,ReqTitle"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	// 나의 휴가 발생 현황
	@Override
	public CoviMap getMyVacationCreateInfoList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectMyVacationCreateInfoListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("groupware.vacation.selectMyVacationCreateInfoList", params);
		   
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,DeptName,JobPositionName,JobPositionSortKey,JobLevelSortKey,JobTitleSortKey,ExtVacName,IsUse,VacYear,Sdate,Edate,VacType,VacDay,Reason,RegisterName,RegisterCode,RegistDate,ExpDate,RemainVacDay"));
		resultList.put("page", page);
		
		return resultList;
	}

	// 휴가신청 조회
	@Override
	public CoviMap getVacationInfoList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationInfoListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationInfoList", params);
		   
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,APPDATE,ENDDATE,GUBUN,VacYear,Sdate,Edate,VacDay,Reason,WorkItemID,ProcessID,VacFlag,VacOffFlag,DeptName,JobPositionName,VacationInfoID,VACTEXT,VacFlagName,GubunName,EXIST_APPROVAL_FORM,EXIST_REQUEST_FORM,ReqTitle"));
		resultList.put("page", page);
		
		return resultList;
	}

	// 휴가신청/취소 조회, 공동연차등록, 나의휴가현황, 휴가취소처리
	@Override
	public CoviMap getVacationInfoListV2(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationInfoListCntV2", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationInfoListV2", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,APPDATE,ENDDATE,GUBUN,VacYear,Sdate,Edate,VacDay,Reason,WorkItemID,ProcessID,VacFlag,VacOffFlag,DeptName,JobPositionName,VacationInfoID,VACTEXT,VacFlagName,GubunName,EXIST_APPROVAL_FORM,EXIST_REQUEST_FORM,ReqTitle"));
		resultList.put("page", page);

		return resultList;
	}
	// 휴가신청/취소 조회
	@Override
	public CoviMap getVacationCancelList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(params.getInt("pageSize")>0) {
			int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationCancelListCnt", params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationCancelList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,APPDATE,ENDDATE,GUBUN,VacYear,Sdate,Edate,VacDay,Reason,WorkItemID,ProcessID,VacFlag,VacDayCancel,VacDayTot,VacOffFlag,DeptName,JobPositionName,VacationInfoID,VACTEXT,VacFlagName,GubunName,CancelProcessID,CancelWorkItemID"));
		if(params.getInt("pageSize")>0) {
			resultList.put("page", page);
		}
		return resultList;
	}


	// 휴가신청/취소 조회
	@Override
	public CoviMap getVacationCancelCheck(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationCancelCheckCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
			resultList.put("page", page);
		}

		params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationCancelCheck", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,APPDATE,ENDDATE,GUBUN,VacYear,Sdate,Edate,VacDay,Reason,WorkItemID,ProcessID,VacFlag,VacDayTot,VacDayUse,VacDayRemain,VacOffFlag,DeptName,JobPositionName,VacationInfoID,VACTEXT,VacFlagName,GubunName,CancelProcessID,CancelWorkItemID"));

		return resultList;
	}
	// 공동연차등록 템플릿 엑셀
	@Override
	public CoviMap getTargetUserListForExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectTargetUserListForExcel", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DeptName,DisplayName,JobPositionName,UserCode"));
		
		return resultList;
	}
	
	// 연차관리 템플릿 엑셀
	@Override
	public CoviMap getNextVacationListForExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectNextVacationListForExcel", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CompanyName,UserCode,EnterDate,DisplayName,DeptName,year,vacDay"));
		
		return resultList;
	}
	
	// 공동연차취소 엑셀 업로드
	@Override
	public CoviMap insertVacationCancelByExcel(CoviMap params) throws Exception{
		CoviMap returnData = new CoviMap();
		int rtn = 0;
		String sDate = params.getString("sDate");
		String eDate = params.getString("eDate");
		String reason = params.getString("reason");
		int year = Calendar.getInstance().get(Calendar.YEAR);
		
		ArrayList<ArrayList<Object>> dataList = extractionExcelData(params, 1);	// 엑셀 데이터 추출
		
		CoviMap paramMap = null;
		CoviMap param = null;
		for (ArrayList list : dataList) {
			paramMap=null;
			paramMap = new CoviMap();
			paramMap.put("vacYear", year);
			paramMap.put("urCode", list.get(3).toString());
			paramMap.put("sDate", sDate);
			paramMap.put("eDate", eDate);
			paramMap.put("reason", reason);
			paramMap.put("gubun", "VACATION_PUBLIC_CANCEL");
			List Maplist = new ArrayList();
			
			Maplist = coviMapperOne.selectList("groupware.vacation.selectCommonVacationInfoList", paramMap);
			if(Maplist.size() > 0 ){

				SimpleDateFormat dformat = new SimpleDateFormat("yyyy-MM-dd");
				Date startDate = new SimpleDateFormat("yyyy-MM-dd").parse(sDate);
				Date endDate = new SimpleDateFormat("yyyy-MM-dd").parse(eDate);
				Calendar calStartDate = Calendar.getInstance();
				calStartDate.setTime(startDate);
				Calendar calEndDate = Calendar.getInstance();
				calEndDate.setTime(endDate);

				long diffSec = (calEndDate.getTimeInMillis() - calStartDate.getTimeInMillis()) / 1000;
				long diffDays = diffSec / (24*60*60); //일자수 차이
				int loopCnt = 1;
				loopCnt += (int) diffDays;

				for(int j = 0; j < Maplist.size(); j ++){
					param = (CoviMap) Maplist.get(j);
					String VacFlag = param.get("VacFlag").toString();
					double vacDay = Double.parseDouble(param.get("VacDay").toString());
					paramMap.put("vacFlag",VacFlag);
					paramMap.put("vacDay",-1*vacDay);
					int cancelRst = coviMapperOne.insert("groupware.vacation.insertVacationCancel", paramMap);
					if(cancelRst>0){
						rtn++;

						int vacationInfoID = paramMap.getInt("VacationInfoID");

						if(loopCnt>1){
							for(int i=0;i<loopCnt;i++) {
								String vacDate = dformat.format(calStartDate.getTime());
								CoviMap paramMap2 = new CoviMap();
								paramMap2.put("urCode", list.get(3).toString());
								paramMap2.put("gubun", "VACATION_PUBLIC");
								paramMap2.put("VacDate", vacDate);
								paramMap2.put("vacFlag", VacFlag);
								paramMap2.put("vacDay", vacDay/loopCnt);

								coviMapperOne.insert("groupware.vacation.deleteVacationInfoDayPublicVac", paramMap2);
								calStartDate.add(Calendar.DATE, 1);
							}
						}else {
							CoviMap paramMap2 = new CoviMap();
							paramMap2.put("urCode", list.get(3).toString());
							paramMap2.put("gubun", "VACATION_PUBLIC");
							paramMap2.put("VacDate", sDate);
							paramMap2.put("vacFlag", VacFlag);
							paramMap2.put("vacDay", vacDay);
							paramMap2.put("vacationInfoID", vacationInfoID);
							coviMapperOne.insert("groupware.vacation.deleteVacationInfoDayPublicVac", paramMap2);
						}
						// 이월연차 갱신
						CoviMap paramMap3 = new CoviMap();
						paramMap3.put("urCode", list.get(3).toString());
						CoviMap vacConfig = coviMapperOne.selectOne("groupware.vacation.selectConfig", paramMap3);
						if(StringUtil.replaceNull(vacConfig.getString("IsRemRenewal")).equals("Y")) {
						paramMap3.put("sDate", sDate.replace("-",""));
						int updateCnt = coviMapperOne.update("groupware.vacation.updateLastVacDay", paramMap3);
						// 이월연차 부여이력
						if (updateCnt > 0 && !StringUtil.replaceNull(vacConfig.getString("RemMethod")).equals("N")) {
							paramMap3.put("vacKind", "PUBLIC");
							paramMap3.put("vacDay", vacDay);
							paramMap3.put("sDate", paramMap3.getString("UseStartDate"));
							paramMap3.put("eDate", paramMap3.getString("UseEndDate"));
							paramMap3.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
							paramMap3.put("comment", "이월자동연차["+paramMap3.getDouble("BeforeVacDay")+"=>"+paramMap3.getDouble("AfterVacDay")+"]");
							paramMap3.put("registerCode", "system"); 
							paramMap3.put("modifierCode", "system"); 
							coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap3);
						}
						}
					}

				}
			}			
		}
		
		returnData.put("totalCount", dataList.size());
		returnData.put("insertCount", rtn);
		returnData.put("notInsertCount", dataList.size()-rtn);
		
		return returnData;
	}
	
	// 공동연차등록 (Web)
	@Override
	public CoviMap insertJointVacation(CoviMap params) throws Exception {
		CoviMap returnData = new CoviMap();
		
		int rtn = 0;
		
		String sDate = params.getString("sDate");
		String eDate = params.getString("eDate");
		double vacDay = params.getDouble("vacDay");
		String reason = params.getString("reason");
		String vacFlag = params.getString("vacFlag");
		int year = Calendar.getInstance().get(Calendar.YEAR);
		
		if(params.getInt("vacYear") > 0) {
			year = params.getInt("vacYear");
		}
		
		CoviMap paramMap = null;
		CoviList usList = params.getJSONArray("urList");
		CoviList exList = params.getJSONArray("exList");
		
		//부서일 경우
		List objUsers = new ArrayList();
		for (int k=0; k < usList.size();k++){
			Map itemUser = (Map)usList.get(k);
			if (itemUser.get("Type").equals("UR")){
				if(!duplicateUserCheck(objUsers, itemUser.get("urCode").toString())){
					objUsers.add(itemUser);
				}
			}
			else{
				CoviMap deptParam = new CoviMap();
				deptParam.put("CompanyCode",itemUser.get("CompanyCode"));
				deptParam.put("groupPath", "%;" + itemUser.get("urCode") + ";");
				deptParam.put("retireUser", "INOFFICE");
				
				CoviList userList = coviMapperOne.list("attend.common.getUserListByDept", deptParam);
				
				for (int i = 0; i < userList.size(); i++){
					if(!duplicateUserCheck(objUsers, userList.getMap(i).getString("UserCode"))) {
						CoviMap objUser = new CoviMap();
						objUser.put("urCode", userList.getMap(i).getString("UserCode"));
						objUser.put("urName", userList.getMap(i).getString("DisplayName"));
						objUser.put("Type", "UR");
						objUsers.add(objUser);
					}
				}
			}
		}
		
		//부서일 경우
		List objExUsers = new ArrayList();
		for (int k=0; k < exList.size();k++){
			Map exUser = (Map)exList.get(k);
			if (exUser.get("Type").equals("UR")){
				if(!duplicateUserCheck(objExUsers, exUser.get("urCode").toString())){
					objExUsers.add(exUser);
				}
			}
			else{
				CoviMap deptParam = new CoviMap();
				deptParam.put("CompanyCode",exUser.get("CompanyCode"));
				deptParam.put("groupPath", "%;" + exUser.get("urCode") + ";");
				deptParam.put("retireUser", "INOFFICE");
				
				CoviList exUserList = coviMapperOne.list("attend.common.getUserListByDept", deptParam);
				
				for (int i = 0; i < exUserList.size(); i++){
					if(!duplicateUserCheck(objExUsers, exUserList.getMap(i).getString("UserCode"))) {
						CoviMap objExUser = new CoviMap();
						objExUser.put("urCode", exUserList.getMap(i).getString("UserCode"));
						objExUser.put("urName", exUserList.getMap(i).getString("DisplayName"));
						objExUser.put("Type", "UR");
						objExUsers.add(objExUser);
					}
				}
			}
		}
		
		//제외자 제외
		Iterator<Map> iterator = objUsers.iterator();
		while(iterator.hasNext()) {
			Map checkEx = iterator.next();
			if(objExUsers.contains(checkEx)) {
				iterator.remove();
			}
		}
		
		for(int idx = 0; idx < objUsers.size(); idx++) {
	    	CoviMap userMap = (CoviMap) objUsers.get(idx);
		
			paramMap = new CoviMap();
			paramMap.put("vacYear", year);
			paramMap.put("urCode", userMap.getString("urCode"));
			paramMap.put("urName", userMap.getString("urName"));
			paramMap.put("sDate", sDate);
			paramMap.put("eDate", eDate);
			paramMap.put("reason", reason);
			paramMap.put("gubun", "VACATION_PUBLIC");
			
			// 시작일자, 종료일자로 기존 휴가일자와 비교. Count가 0 이상이면 겹치는 일정 존재.  
			int vacCnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationInfoCnt", paramMap);
			
			// 취소된 일정 확인
			CoviMap cancelMap = new CoviMap();
			cancelMap.put("urCode", userMap.getString("urCode"));
			cancelMap.put("sDate", sDate);
			cancelMap.put("eDate", eDate);
			cancelMap.put("gubun", "VACATION_PUBLIC_CANCEL");
			int vacCancelCnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationInfoCnt", cancelMap);
			
			if((vacCnt - vacCancelCnt) <= 0){
				// 21.10.14, 겹치는 일정 없을 시, 남은 연차수에 상관 없이 휴가신청 일 만큼 휴가 계산(선연차/선반차 개념 없이).
				paramMap.put("vacFlag", vacFlag);	// client side에서 선반차/선연차를 반차/연차로 변경하여 서버로 전달.
				paramMap.put("vacDay", vacDay);		// vacDay : 휴가일 수.

				rtn += coviMapperOne.insert("groupware.vacation.insertVacationInfo", paramMap);
				int vacationInfoID = paramMap.getInt("VacationInfoID");

				Date startDate = new SimpleDateFormat("yyyy-MM-dd").parse(sDate);
				Date endDate = new SimpleDateFormat("yyyy-MM-dd").parse(eDate);
				Calendar calStartDate = Calendar.getInstance();
				calStartDate.setTime(startDate);
				Calendar calEndDate = Calendar.getInstance();
				calEndDate.setTime(endDate);

				long diffSec = (calEndDate.getTimeInMillis() - calStartDate.getTimeInMillis()) / 1000;
				long diffDays = diffSec / (24*60*60); //일자수 차이
				int loopCnt = 1;
				loopCnt += (int) diffDays;

				SimpleDateFormat dformat = new SimpleDateFormat("yyyy-MM-dd");
				if(loopCnt>1){
					for(int i=0;i<loopCnt;i++) {
						String vacDate = dformat.format(calStartDate.getTime());
						CoviMap paramMap2 = new CoviMap();
						paramMap2.put("urCode", userMap.getString("urCode"));
						paramMap2.put("gubun", "VACATION_PUBLIC");
						paramMap2.put("VacDate", vacDate);
						paramMap2.put("vacFlag", vacFlag);
						paramMap2.put("vacDay", vacDay/loopCnt);
						paramMap2.put("vacationInfoID", vacationInfoID);

						coviMapperOne.insert("groupware.vacation.insertVacationInfoDayPublicVac", paramMap2);
						calStartDate.add(Calendar.DATE, 1);
					}
				}else {
					CoviMap paramMap2 = new CoviMap();
					paramMap2.put("urCode", userMap.getString("urCode"));
					paramMap2.put("gubun", "VACATION_PUBLIC");
					paramMap2.put("VacDate", sDate);
					paramMap2.put("vacFlag", vacFlag);
					paramMap2.put("vacDay", vacDay);
					paramMap2.put("vacationInfoID", vacationInfoID);
					coviMapperOne.insert("groupware.vacation.insertVacationInfoDayPublicVac", paramMap2);
				}
				
				// 이월연차 갱신
				CoviMap paramMap3 = new CoviMap();
				paramMap3.put("urCode", userMap.getString("urCode"));
				CoviMap vacConfig = coviMapperOne.selectOne("groupware.vacation.selectConfig", paramMap3);
				if(StringUtil.replaceNull(vacConfig.getString("IsRemRenewal")).equals("Y")) {
					paramMap3.put("sDate", sDate.replace("-","")); 
					int updateCnt = coviMapperOne.update("groupware.vacation.updateLastVacDay", paramMap3);
					// 이월연차 부여이력
					if (updateCnt>0 && !StringUtil.replaceNull(vacConfig.getString("RemMethod")).equals("N")) {
						paramMap3.put("vacKind", "PUBLIC");
						paramMap3.put("vacDay", -1*vacDay);
						paramMap3.put("sDate", paramMap3.getString("UseStartDate"));
						paramMap3.put("eDate", paramMap3.getString("UseEndDate"));
						paramMap3.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
						paramMap3.put("comment", "이월자동연차["+paramMap3.getDouble("BeforeVacDay")+"=>"+paramMap3.getDouble("AfterVacDay")+"]");
						paramMap3.put("registerCode", "system"); 
						paramMap3.put("modifierCode", "system"); 
						coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap3);
					}						
				}
			}
		}
		
		returnData.put("totalCount", objUsers.size());
		returnData.put("insertCount", rtn);
		returnData.put("duplicateCount", objUsers.size() - rtn);
		
		return returnData;
	}
	
	// 공동연차등록 엑셀 업로드
	@Override
	public CoviMap insertVacationByExcel(CoviMap params) throws Exception {
		CoviMap returnData = new CoviMap();
		
		int rtn = 0;
		
		String sDate = params.getString("sDate");
		String eDate = params.getString("eDate");
		double vacDay = params.getDouble("vacDay");
		String reason = params.getString("reason");
		String vacFlag = params.getString("vacFlag");
		int year = Calendar.getInstance().get(Calendar.YEAR);
		if(params.getInt("vacYear") > 0) {
			year = params.getInt("vacYear");
		}
		
		ArrayList<ArrayList<Object>> dataList = extractionExcelData(params, 1);	// 엑셀 데이터 추출
		
		CoviMap paramMap = null;
		
		for (ArrayList<Object> list : dataList) {		// dataList : 엑셀 데이터(구성원 정보).
			paramMap = new CoviMap();
			paramMap.put("vacYear", year);
			paramMap.put("urCode", list.get(3).toString());
			paramMap.put("urName", list.get(1).toString());
			paramMap.put("sDate", sDate);
			paramMap.put("eDate", eDate);
			paramMap.put("reason", reason);
			paramMap.put("gubun", "VACATION_PUBLIC");
			
			// 시작일자, 종료일자로 기존 휴가일자와 비교. Count가 0 이상이면 겹치는 일정 존재.  
			int vacCnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationInfoCnt", paramMap);
			
			// 취소된 일정 확인
			CoviMap cancelMap = new CoviMap();
			cancelMap.put("urCode", list.get(3).toString());
			cancelMap.put("sDate", sDate);
			cancelMap.put("eDate", eDate);
			cancelMap.put("gubun", "VACATION_PUBLIC_CANCEL");
			int vacCancelCnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationInfoCnt", cancelMap);
			
			if((vacCnt - vacCancelCnt) <= 0){
				// 21.10.14, 겹치는 일정 없을 시, 남은 연차수에 상관 없이 휴가신청 일 만큼 휴가 계산(선연차/선반차 개념 없이).
				paramMap.put("vacFlag", vacFlag);	// client side에서 선반차/선연차를 반차/연차로 변경하여 서버로 전달.
				paramMap.put("vacDay", vacDay);		// vacDay : 휴가일 수.

				rtn += coviMapperOne.insert("groupware.vacation.insertVacationInfo", paramMap);
				int vacationInfoID = paramMap.getInt("VacationInfoID");

				Date startDate = new SimpleDateFormat("yyyy-MM-dd").parse(sDate);
				Date endDate = new SimpleDateFormat("yyyy-MM-dd").parse(eDate);
				Calendar calStartDate = Calendar.getInstance();
				calStartDate.setTime(startDate);
				Calendar calEndDate = Calendar.getInstance();
				calEndDate.setTime(endDate);

				long diffSec = (calEndDate.getTimeInMillis() - calStartDate.getTimeInMillis()) / 1000;
				long diffDays = diffSec / (24*60*60); //일자수 차이
				int loopCnt = 1;
				loopCnt += (int) diffDays;

				SimpleDateFormat dformat = new SimpleDateFormat("yyyy-MM-dd");
				if(loopCnt>1){
					for(int i=0;i<loopCnt;i++) {
						String vacDate = dformat.format(calStartDate.getTime());
						CoviMap paramMap2 = new CoviMap();
						paramMap2.put("urCode", list.get(3).toString());
						paramMap2.put("gubun", "VACATION_PUBLIC");
						paramMap2.put("VacDate", vacDate);
						paramMap2.put("vacFlag", vacFlag);
						paramMap2.put("vacDay", vacDay/loopCnt);
						paramMap2.put("vacationInfoID", vacationInfoID);

						coviMapperOne.insert("groupware.vacation.insertVacationInfoDayPublicVac", paramMap2);
						calStartDate.add(Calendar.DATE, 1);
					}
				}else {
					CoviMap paramMap2 = new CoviMap();
					paramMap2.put("urCode", list.get(3).toString());
					paramMap2.put("gubun", "VACATION_PUBLIC");
					paramMap2.put("VacDate", sDate);
					paramMap2.put("vacFlag", vacFlag);
					paramMap2.put("vacDay", vacDay);
					paramMap2.put("vacationInfoID", vacationInfoID);
					coviMapperOne.insert("groupware.vacation.insertVacationInfoDayPublicVac", paramMap2);
				}
				// 이월연차 갱신
				CoviMap paramMap3 = new CoviMap();
				paramMap3.put("urCode", list.get(3).toString());
				CoviMap vacConfig = coviMapperOne.selectOne("groupware.vacation.selectConfig", paramMap3);
				if(StringUtil.replaceNull(vacConfig.getString("IsRemRenewal")).equals("Y")) {
					paramMap3.put("sDate", sDate.replace("-","")); 
					int updateCnt = coviMapperOne.update("groupware.vacation.updateLastVacDay", paramMap3);
					// 이월연차 부여이력
					if (updateCnt>0 && !StringUtil.replaceNull(vacConfig.getString("RemMethod")).equals("N")) {
						paramMap3.put("vacKind", "PUBLIC");
						paramMap3.put("vacDay", -1*vacDay);
						paramMap3.put("sDate", paramMap3.getString("UseStartDate"));
						paramMap3.put("eDate", paramMap3.getString("UseEndDate"));
						paramMap3.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
						paramMap3.put("comment", "이월자동연차["+paramMap3.getDouble("BeforeVacDay")+"=>"+paramMap3.getDouble("AfterVacDay")+"]");
						paramMap3.put("registerCode", "system"); 
						paramMap3.put("modifierCode", "system"); 
						coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap3);
					}						
				}
			}
		}
		
		returnData.put("totalCount", dataList.size());
		returnData.put("insertCount", rtn);
		returnData.put("duplicateCount", dataList.size()-rtn);
		
		return returnData;
	}
	
	// 엑셀 데이터 추출
	private ArrayList<ArrayList<Object>> extractionExcelData(CoviMap params, int headerCnt) throws Exception {
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = prepareAttachment(mFile);	// 파일 생성
		ArrayList<ArrayList<Object>> returnList = new ArrayList<>();
		Workbook wb = null;
		
		try {
			wb = WorkbookFactory.create(file);
			Sheet sheet = wb.getSheetAt(0);
			
			ArrayList<Object> tempList = null;
			Iterator<Row> rowIterator = sheet.iterator();
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				
				if (row.getRowNum() > (headerCnt - 1)) {	// header 제외
					tempList = new ArrayList<>();
					Iterator<Cell> cellIterator = row.cellIterator();
					
					int celllength = (int)row.getLastCellNum(); // 열의 총 개수 
					
					for(int c = 0; c < celllength; c++){
						 Cell cell = row.getCell(c);
						 
						 if (cell == null || cell.getCellType() == Cell.CELL_TYPE_BLANK) {
							 tempList.add("");
						 } else {
							 switch (cell.getCellType()) {
								case Cell.CELL_TYPE_BOOLEAN :
									tempList.add(cell.getBooleanCellValue());
									break;
								case Cell.CELL_TYPE_NUMERIC : 
									tempList.add(cell.getNumericCellValue());
									break;
								case Cell.CELL_TYPE_STRING : 
									tempList.add(cell.getStringCellValue());
									break;
								case Cell.CELL_TYPE_FORMULA : 
									tempList.add(cell.getCellFormula());
									break;
								default : 
									break;
								}
						 }
					}
					
					returnList.add(tempList);
				}
			}
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if (wb != null) { try { wb.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (file != null) {
				if(file.delete()) {
					LOGGER.info("file : " + file.toString() + " delete();");
				}
			}
		}
		
		return returnList;
	}
	
	// 임시파일 생성
	private File prepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        
	        return tmp;
	    } catch (IOException ioE) {
	        if (tmp != null) {
	        	if(tmp.delete()) {
	        		LOGGER.info("file : " + tmp.toString() + " delete();");
	        	}
	        }
	        
	        throw ioE;
	    }
	}
	
	// 공동연차등록 > 휴가취소
	@Override
	public int insertVacationCancel(CoviMap params) throws Exception {
		if(params.getString("gubun").equals("VACATION_PUBLIC")){
			params.put("applyGubun", "VACATION_PUBLIC");
			params.put("cancelGubun", "VACATION_PUBLIC_CANCEL");
			params.put("gubun", "VACATION_PUBLIC_CANCEL");
		}else if(params.getString("gubun").contains("EXTRA_")){
			params.put("applyGubun", params.getString("gubun"));
			params.put("cancelGubun", params.getString("gubun")+"_CANCEL");
			params.put("gubun", params.getString("gubun")+"_CANCEL");
		}else{
			params.put("applyGubun", "VACATION_APPLY");
			params.put("cancelGubun", "VACATION_CANCEL");
			params.put("gubun", "VACATION_CANCEL");
		}
		
		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectCommonVacationInfoCnt", params);
		
		if(cnt > 0){
			cnt = coviMapperOne.insert("groupware.vacation.insertVacationCancel", params);
			//2022.04.01 관리자 휴가취소 처리 시 vm_vacationinfo_day 데이터도 삭제 처리
			CoviMap coviMap = new CoviMap();
			coviMap.put("processId", params.get("vacationInfoID"));
			coviMapperOne.delete("attend.req.deleteVacationInfoDayAppById", coviMap);
			// 이월연차 갱신
			CoviMap vacConfig = coviMapperOne.selectOne("groupware.vacation.selectConfig", params);
			if(StringUtil.replaceNull(vacConfig.getString("IsRemRenewal")).equals("Y")) {
			params.put("sDate", params.getString("sDate").replace("-", ""));
			int updateCnt=coviMapperOne.update("groupware.vacation.updateLastVacDay", params);
			// 이월연차 부여이력
			if (updateCnt>0 && !StringUtil.replaceNull(vacConfig.getString("RemMethod")).equals("N")) {
				params.put("vacKind", "PUBLIC");
				params.put("vacDay", params.getDouble("vacDay")*-1);
				params.put("sDate", params.getString("UseStartDate"));
				params.put("eDate", params.getString("UseEndDate"));
				params.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
				params.put("comment", "이월자동연차["+params.getDouble("BeforeVacDay")+"=>"+params.getDouble("AfterVacDay")+"]");
				params.put("registerCode", "system"); 
				params.put("modifierCode", "system"); 
				coviMapperOne.update("groupware.vacation.insertVmPlanHist", params);
			}
			}
		}
		
		return cnt;
	}
	
	// 나의휴가현황 > 사용휴가일수
	@Override
	public CoviMap getUserVacationInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectUserVacationInfo", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,DisplayName,EnterDate,DeptName,JobPositionName,OWNDAYS,USEDAYS,REMINDDAYS,YESTERYEAR,NOWYEAR,TODAY,YEAR,TargetYear,MONTH,PER,VACPLAN,VacLimitDayFrom,VacLimitDayTo,VacLimitOneFrom,VacLimitOneTo,VacLimitTwoFrom,VacLimitTwoTo,VacLimitLessFrom,VacLimitLessTo,VacLimit091From,VacLimit091To,VacLimit092From,VacLimit092To,VacLimit021From,VacLimit021To,VacLimit022From,VacLimit022To"));
		
		return resultList;
	}
	// 나의휴가현황 > 사용휴가일수 일반휴가 VacKind=Public
	@Override
	public CoviMap getUserVacationInfoV2(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectUserVacationInfoV2", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,DisplayName,EnterDate,DeptName,JobPositionName,OWNDAYS,USEDAYS,REMINDDAYS,YESTERYEAR,NOWYEAR,TODAY,YEAR,TargetYear,MONTH,PER,VACPLAN,VacLimitDayFrom,VacLimitDayTo,VacLimitOneFrom,VacLimitOneTo,VacLimitTwoFrom,VacLimitTwoTo,VacLimitLessFrom,VacLimitLessTo,VacLimit091From,VacLimit091To,VacLimit092From,VacLimit092To,VacLimit021From,VacLimit021To,VacLimit022From,VacLimit022To"));

		return resultList;
	}

	// 휴가현황 > 부서휴가유형별조회, 휴가관리 > 휴가유형별현황
	@Override
	public CoviMap getVacationDayListByType(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		CoviMap colParams =  new CoviMap();
		String hideExtraVacation = params.getString("hideExtraVacation");
		
		colParams.put("lang", SessionHelper.getSession("lang"));
		colParams.put("domainID", SessionHelper.getSession("DN_ID"));
		if (params.get("EXCEL") == null || !params.get("EXCEL").equals("true")) {
			colParams.put("pageSize", 5);
			colParams.put("columnYn", "Y");
		}
		else {
			colParams.put("pageSize", 999);
		}
		colParams.put("pageNo", 1);
		colParams.put("hideExtraVacation", hideExtraVacation);
		colParams.put("pageOffset", 0);
		
		CoviList colList = coviMapperOne.list("groupware.vacation.selectVacTypeList", colParams);

		params.put("colList", colList);

		if (params.get("EXCEL") == null || !params.get("EXCEL").equals("true")){
			int cnt = 0;
			cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationListCntByType", params);
			page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			
			resultList.put("page",page);
		}

		CoviList list = new CoviList();
		list = coviMapperOne.list("groupware.vacation.selectVacationListByType", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("colList", colList);
		 
		return resultList; 
	}
	
	// 연차관리 엑셀 업로드
	@Override
	public int insertVacationPlan(CoviMap params) throws Exception {
		int rtn = 0;
		
		ArrayList<ArrayList<Object>> dataList = extractionExcelData(params, 1);	// 엑셀 데이터 추출
		
		CoviMap paramMap = null;

		CoviMap req = new CoviMap();
		req.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		req.put("getName", "CreateMethod");
		String CreateMethod = getVacationConfigVal(req);
		if(CreateMethod==null || CreateMethod.equals("")){
			CreateMethod = "F";
		}

		for (ArrayList<Object> list : dataList) {
			if(list.size() > 5) {
				String urCode = list.get(0).toString();
				String year =  String.valueOf((int)Math.round(Double.parseDouble(list.get(4).toString())));
				String longVacDay = list.get(5).toString();
				
				if (!StringUtil.isNull(urCode) && !StringUtil.isNull(year) && !StringUtil.isNull(longVacDay)) {
					paramMap = new CoviMap();
					paramMap.put("registerCode", SessionHelper.getSession("UR_Code"));
					paramMap.put("urCode", urCode);
					paramMap.put("year", year);
					paramMap.put("longVacDay", longVacDay);
					paramMap.put("domainCode",SessionHelper.getSession("DN_Code"));

					if(CreateMethod.equals("F")) {
						rtn += coviMapperOne.update("groupware.vacation.updateVacationPlan", paramMap);
					}else{
						rtn += coviMapperOne.update("groupware.vacation.updateVacationPlanV2", paramMap);
					}
					paramMap.put("vacKind", "PUBLIC");
					paramMap.put("vacDay", longVacDay);
					paramMap.put("sDate", paramMap.getString("FromDate"));
					paramMap.put("eDate", paramMap.getString("ToDate"));
					paramMap.put("vmMethod", "EXCEL"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
					paramMap.put("comment","연차등록");
					coviMapperOne.update("groupware.vacation.insertVmPlanHist", paramMap);
				}
			}
		}
		
		return rtn;
	}
	
	// 읽음 테이블에 입력
	@Override
	public int insertVacationMessageRead(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.vacation.updateVacationMessageRead", params);
	}
	
	// 휴가현황 > 부서휴가월별현황, 휴가관리 > 휴가월별현황
	@Override
	public CoviMap getVacationListByMonth(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviMap req = new CoviMap();

		if (params.get("EXCEL") == null || !params.get("EXCEL").equals("true")){
			int cnt = 0;
			cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationListCntByMonth", params);
			page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			resultList.put("page",page);
		}
		
		CoviList list = new CoviList();
		list = coviMapperOne.list("groupware.vacation.selectVacationListByMonth", params);
		resultList.put("list", list);
		
		return resultList;
	}
	
	// 연차촉진제 1차 조회내역, 연차촉진제 2차 조회내역, 사용시기 지정통보 조회내역
	@Override
	public CoviMap getVacationMessageReadList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationMessageReadListCnt", params);
		if(!params.containsKey("pageNo")) {
			params.put("pageNo", 1);
			params.put("pageSize", cnt);
		}
		
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationMessageReadList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,DisplayName,DeptName,JobPositionName,EnterDate,RetireDate,ReadDate"));
		resultList.put("page", page);
		resultList.put("cnt", cnt);
		
		return resultList;
	}
	
	// 연차사용시기 
	@Override
	public CoviMap getVacationUsePlan(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationUsePlanList", params);
		
		CoviMap resultList = new CoviMap();
		   
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,YEAR,VACPLAN,TargetYear,EnterDate"));
		
		return resultList;
	}
	
	// 연차사용시기 등록
	@Override
	public int insertVacationUsePlan(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.vacation.updateVacationUsePlan", params);
	}
	
	// 휴가취소처리 > 문서연결
	@Override
	public CoviMap getVacationCancelDocList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationCancelDocListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
			resultList.put("page", page);
			resultList.put("cnt", cnt);
		}

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationCancelDocList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,formKey,DocSubject,InitiatorUnitName,InitiatorName,FormName,EndDate"));
		
		return resultList;
	}
	
	// 연차촉진제관리 > 미사용연차계획 저장내역 조회
	@Override
	public CoviMap getVacationUsePlanList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		int cnt =0;
		
		if(params.get("pageNo") != null) {
			cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationUsePlanListCnt", params);
			page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
		}
		
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationUsePlanList", params);

		for (int i=0; i<list.size(); i++) {
			CoviList dataArr = new CoviList();
			CoviMap map = list.getMap(i);
			//2021.07.27 nkpark 업무 스케쥴 취득
			CoviMap reqParams = new CoviMap();
			reqParams.put("urCode", map.get("UserCode"));
			reqParams.put("domainCode", params.get("domainCode"));
			reqParams.put("StartDate",params.get("year")+"0101");
			reqParams.put("EndDate",params.get("year")+"1231");

			/* 미사용코드 주석처리.
			CoviList workOnDayList = coviMapperOne.list("attend.job.getJobWorkOnDays", reqParams);
			Map<String, String> dayOffList = new HashMap<>();

			for (int k=0; k<workOnDayList.size(); k++) {
				CoviMap workOnDayMap = workOnDayList.getMap(k);
				dayOffList.put(workOnDayMap.getString("JobDate").replaceAll("-",""), workOnDayMap.getString("WorkSts"));
			}
			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
			 */
			
			map.put("janDate", "");
			map.put("febDate", "");
			map.put("marDate", "");
			map.put("aprDate", "");
			map.put("mayDate", "");
			map.put("junDate", "");
			map.put("julDate", "");
			map.put("augDate", "");
			map.put("sepDate", "");
			map.put("octDate", "");
			map.put("novDate", "");
			map.put("decDate", "");

			Gson gson = new Gson();
			if(map.get("VACPLAN") != null) {
				String key = "months";
				String vacPlan = map.getString("VACPLAN");

				CoviMap dataObj = gson.fromJson(vacPlan, CoviMap.class);
				
							
				if(params.getString("term").equalsIgnoreCase("2020")) {
					if (dataObj.containsKey(params.getString("formType"))){
						CoviMap tempObj = gson.fromJson(dataObj.get(params.getString("formType")).toString(), CoviMap.class);
						if (tempObj != null && dataObj.containsKey(params.getString("empType"))) {
							tempObj = gson.fromJson(tempObj.get(params.getString("empType")).toString(), CoviMap.class);
							if (tempObj != null && dataObj.containsKey(key)) {
								dataArr = (CoviList) tempObj.get(key);
							}
						}
					}
				}else {
					if(dataObj.get(key) != null) {
						dataArr = (CoviList) dataObj.get(key);
					}
				}
				
			}

			CoviMap newMap = new CoviMap();
			for (int j=0; j<dataArr.size(); j++) {
				CoviMap jsonObj = (CoviMap) dataArr.get(j);
				String month = (String) jsonObj.get("month");
				CoviList vacPlanArr = (CoviList) jsonObj.get("vacPlan");
				
				int tempCnt = 0;
				
				for(Object obj : vacPlanArr) {
					CoviMap vacPlanObj = (CoviMap) obj;
					String startDate = StringUtil.replaceNull(vacPlanObj.get("startDate"));
					String endDate = StringUtil.replaceNull(vacPlanObj.get("endDate"));
					
					if(!startDate.isEmpty() && !endDate.isEmpty()) {
						//2021.07.27 nkpark 업무 스케쥴 데이터 기준 휴무일 카운팅
						//기존 :tempCnt += ( DateHelper.diffDate(endDate, startDate) + 1 );
						int workingDays = 0;
						try {
							Calendar start = Calendar.getInstance();
							start.setTime(DateHelper.strToDate(startDate)); //시작일 날짜 설정

							Calendar end = Calendar.getInstance();
							end.setTime(DateHelper.strToDate(endDate)); //종료일 날짜 설정

							Calendar hol = Calendar.getInstance();

							//int holDays = 0;
							/*for(int l=0;l<loopCnt;l++){
								String checkDays = sdf.format(start.getTime());
								//System.out.println("#####dayOffList:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(dayOffList));
								String val = dayOffList.get(checkDays);
								if (val!=null && !val.equals("null") && !val.equals("HOL")) {
									workingDays++;    //근무일 수 추가
								}
								start.add(Calendar.DATE, 1);
							}*/
							//주말 포함 하여 휴가일로 포함 시킬지 확인 필요 일단 기존대로 휴일 빼지 않음
							workingDays = DateHelper.diffDate(endDate, startDate) + 1;

						} catch (NullPointerException e) {
							LOGGER.error(e.getLocalizedMessage(), e);
						} catch (Exception e) {
							LOGGER.error(e.getLocalizedMessage(), e);
						}
						tempCnt += workingDays;
						//-->
					}
				}
				
				switch(month) {
					case "1" : newMap.put("janDate", StringUtil.isOneNull(tempCnt)); break;
					case "2" : newMap.put("febDate", StringUtil.isOneNull(tempCnt)); break;
					case "3" : newMap.put("marDate", StringUtil.isOneNull(tempCnt)); break;
					case "4" : newMap.put("aprDate", StringUtil.isOneNull(tempCnt)); break;
					case "5" : newMap.put("mayDate", StringUtil.isOneNull(tempCnt)); break;
					case "6" : newMap.put("junDate", StringUtil.isOneNull(tempCnt)); break;
					case "7" : newMap.put("julDate", StringUtil.isOneNull(tempCnt)); break;
					case "8" : newMap.put("augDate", StringUtil.isOneNull(tempCnt)); break;
					case "9" : newMap.put("sepDate", StringUtil.isOneNull(tempCnt)); break;
					case "10" : newMap.put("octDate", StringUtil.isOneNull(tempCnt)); break;
					case "11" : newMap.put("novDate", StringUtil.isOneNull(tempCnt)); break;
					case "12" : newMap.put("decDate", StringUtil.isOneNull(tempCnt)); break;
					default : break;
				}
			}
			
			map.putAll(newMap);
		}
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DeptName,JobPositionName,DisplayName,EnterDate,BaseDate,YEAR,OWNDAYS,USEDAYS,REMINDDAYS,janDate,febDate,marDate,aprDate,mayDate,junDate,julDate,augDate,sepDate,octDate,novDate,decDate"));
		resultList.put("page", page);
		resultList.put("cnt", cnt);
		
		return resultList;
	}
	
	// 휴가조회
	@Override
	public CoviList getVacationData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		return coviMapperOne.list("groupware.vacation.selectVacationListByKindAll", params);
	}

	@Override
	public CoviList getVacationInfo(CoviMap params) throws Exception {
		CoviList returnArr = new CoviList();
		CoviList vacationInfo = CoviList.fromObject(params.getString("vacationInfo"));
		String chkType = params.getString("chkType", "");
		String userCode = params.getString("userCode", SessionHelper.getSession("USERID"));
		
		for(Object obj : vacationInfo){
			CoviMap vacationInfoObj = (CoviMap)obj;
			
			CoviMap paramMap = new CoviMap();
			paramMap.put("StartDate", vacationInfoObj.getString("_MULTI_VACATION_SDT"));
			paramMap.put("EndDate", vacationInfoObj.getString("_MULTI_VACATION_EDT"));
			paramMap.put("STime", vacationInfoObj.getString("_MULTI_VACATION_STIME"));
			paramMap.put("ETime", vacationInfoObj.getString("_MULTI_VACATION_ETIME"));
			paramMap.put("UserCode", userCode);
			paramMap.put("VacDay", Float.parseFloat(vacationInfoObj.getString("_MULTI_DAYS").replaceAll("[^0-9.]", "")));
			
			if(vacationInfoObj.containsKey("VACATION_OFF_TYPE")) {
				paramMap.put("VacOffFlag", vacationInfoObj.getString("VACATION_OFF_TYPE"));	
			}
			
			if(paramMap.getDouble("VacDay")==0.5) {
				if(paramMap.getString("VacOffFlag").equals("AM")) {
					paramMap.put("STime", "00:00");
					paramMap.put("ETime", "12:00");
				} else if(paramMap.getString("VacOffFlag").equals("PM")) {
					paramMap.put("STime", "12:00");
					paramMap.put("ETime", "24:00");
				}
			}
			
			paramMap.put("VacFlag", vacationInfoObj.optString("VACATION_TYPE"));	
			
			long cnt = 0L;
			if("CANCEL".equals(chkType)) {
				// 휴가일체크(휴가취소신청시), 전체 휴가일
				cnt = coviMapperOne.getNumber("groupware.vacation.selectVacationCancelInfo", paramMap);
				if(cnt != 0){
					returnArr.add(vacationInfoObj);
				}
			}else {
				// 중복체크
				// 완료된 휴가 신청서에 연차기간을 비교
				cnt = coviMapperOne.getNumber("groupware.vacation.selectVacationInfo", paramMap);	
				
				// 휴가 신청하고, 아직 진행함에 있는 휴가 신청서에 연차기간과 비교
				if("DRAFT".equals(chkType) && cnt == 0) {
					cnt = coviMapperOne.getNumber("groupware.vacation.selectVacationProcessInfo", paramMap);
				}
				
				if(cnt > 0 ){
					returnArr.add(vacationInfoObj);
				}
			}
		}
		
		return returnArr;
	}
	
	// 휴가관리 홈
	@Override
	public CoviMap getVacationInfoForHome(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();

		params.put("mySummary", "Y");
		params.put("schTxt", params.getString("urCode"));
		
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationListByKindAll", params);
		resultList.put("list", list);
		if(params.getString("domainID")!=null && !params.getString("domainID").equals("") ) {
			list = coviMapperOne.list("groupware.vacation.selectVacationToday", params);
			resultList.put("todayList", CoviSelectSet.coviSelectJSON(list, "UR_Code,UR_Name,VacFlag,period,DeptName,JobPositionName,DEPUTY_NAME,VacFlagName,GUBUN,JobLevelName,JobTitleName"));
		}
		return resultList;
	}
	// 나의휴가현황 > 버튼 visible
	@Override
	public CoviMap getPromotionBtnVisible(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.vacation.selectPromotionBtnVisible", params)
																	,"Code,Reserved1,Reserved2");	
		
		for(Object obj : list) {
			CoviMap codeObj = (CoviMap)obj;
			
			String today = ComUtils.GetLocalCurrentDate("MM.dd");
			String startDate =  StringUtil.replaceNull(codeObj.getString("Reserved1"), "01.01");
			String endDate =  StringUtil.replaceNull(codeObj.getString("Reserved2"), "12.31");
			
			if(startDate.compareTo(today) <= 0 && endDate.compareTo(today) >= 0) {
				codeObj.put("BtnVisible", "Y");
			}else {
				codeObj.put("BtnVisible", "N");
			}
		}
		
		resultList.put("list", list);	
		
		return resultList;
	}
	
	@Override
	public void autoIncreaseMonthlyVacation(CoviMap param) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectAutoIncreaseMonthlyVacation", param);
		CoviList vacUpdateList = CoviSelectSet.coviSelectJSON(list, "Vacday,VmComment,UrCode,VacKind,Year,UseStartDate,UseEndDate");
		for(Object vacInfo : vacUpdateList) {
			CoviMap obj = new CoviMap();
			obj = (CoviMap) vacInfo;
			CoviMap par = new CoviMap();
			par.put("vacday", obj.getDouble("Vacday"));
			par.put("urCode", obj.getString("UrCode"));
			par.put("vacKind", obj.getString("VacKind"));
			par.put("year", obj.getInt("Year"));
			coviMapperOne.insert("groupware.vacation.updateAutoIncreaseMonthlyVacation", par);
			par.put("vacDay", "1");
			par.put("sDate", obj.getString("UseStartDate"));
			par.put("eDate", obj.getString("UseEndDate"));
			par.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
			par.put("comment", obj.getString("VmComment"));
			par.put("registerCode", "system"); 
			par.put("modifierCode", "system"); 
			coviMapperOne.update("groupware.vacation.insertVmPlanHist", par);
			// 차년도 이월연차 갱신
			if(StringUtil.replaceNull(param.getString("IsRemRenewal")).equals("Y")) { 
				int updateCnt = coviMapperOne.update("groupware.vacation.updateLastVacDay", par);
				// 이월연차 부여이력
				if (updateCnt > 0 && !StringUtil.replaceNull(param.getString("RemMethod")).equals("N")) {
					par.put("sDate", par.getString("UseStartDate"));
					par.put("eDate", par.getString("UseEndDate"));
					par.put("comment", "이월자동연차["+par.getDouble("BeforeVacDay")+"=>"+par.getDouble("AfterVacDay")+"]");
					coviMapperOne.update("groupware.vacation.insertVmPlanHist", par);
				}
			}
		}
	}

	@Override
	public void autoIncreaseMonthlyVacationV2(CoviMap param) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectAutoIncreaseMonthlyVacationV2", param);
		CoviList vacUpdateList = CoviSelectSet.coviSelectJSON(list, "UserCode,DeptCode,DeptName,YEAR,VacDay,VacKind,UseStartDate,UseEndDate,VmComment");
		for(Object vacInfo : vacUpdateList) {
			CoviMap obj = new CoviMap();
			obj = (CoviMap) vacInfo;
			CoviMap par = new CoviMap();
			par.put("year", obj.getInt("YEAR"));
			par.put("urCode", obj.getString("UserCode"));
			par.put("vacKind", obj.getString("VacKind"));
			par.put("useStartDate", obj.getString("UseStartDate"));
			par.put("useEndDate", obj.getString("UseEndDate"));
			par.put("vacDay", obj.getDouble("VacDay"));
			coviMapperOne.insert("groupware.vacation.updateAutoIncreaseMonthlyVacationV2", par);

			par.put("vacDay", "1");
			par.put("sDate", obj.getString("UseStartDate"));
			par.put("eDate", obj.getString("UseEndDate"));
			par.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
			par.put("comment", obj.getString("VmComment"));
			par.put("registerCode", "system"); 
			par.put("modifierCode", "system"); 
			coviMapperOne.update("groupware.vacation.insertVmPlanHist", par);
			// 차년도 이월연차 갱신
			if(StringUtil.replaceNull(param.getString("IsRemRenewal")).equals("Y")) { 
				int updateCnt = coviMapperOne.update("groupware.vacation.updateLastVacDay", par);
				// 이월연차 부여이력
				if (updateCnt > 0 && !StringUtil.replaceNull(param.getString("RemMethod")).equals("N")) {
					par.put("sDate", par.getString("UseStartDate"));
					par.put("eDate", par.getString("UseEndDate"));
					par.put("comment", "이월자동연차["+par.getDouble("BeforeVacDay")+"=>"+par.getDouble("AfterVacDay")+"]");
					coviMapperOne.update("groupware.vacation.insertVmPlanHist", par);
				}
			}
		}
	}

	@Override
	public void autoUpdateAnnualVacation(CoviMap param) throws Exception {
		coviMapperOne.update("groupware.vacation.updateAutoUpdateAnnualVacation", param);
	}
	
	@Override
	public void autoCreateAnnualVacation(CoviMap param) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectAutoCreateAnnualVacation", param);
		CoviList vacUpdateList = CoviSelectSet.coviSelectJSON(list, "YEAR,UR_Code,VacKind,UseStartDate,UseEndDate,DeptCode,DeptName,LongVacDay,LastVacDay,RewardVacDay,RegisterCode");
		for(Object vacInfo : vacUpdateList) {
			CoviMap obj = new CoviMap();
			obj = (CoviMap) vacInfo;
			CoviMap par = new CoviMap();
			par.put("year", obj.getInt("YEAR"));
			par.put("urCode", obj.getString("UR_Code"));
			par.put("vacKind", obj.getString("VacKind"));
			par.put("useStartDate", obj.getString("UseStartDate"));
			par.put("useEndDate", obj.getString("UseEndDate"));
			par.put("deptCode", obj.getString("DeptCode"));
			par.put("deptName", obj.getString("DeptName"));			
			par.put("longVacDay", obj.getDouble("LongVacDay"));
			par.put("lastVacDay", obj.getDouble("LastVacDay"));			
			par.put("rewardVacDay", obj.getDouble("RewardVacDay"));
			par.put("registerCode", obj.getString("RegisterCode"));

			coviMapperOne.insert("groupware.vacation.insertAutoCreateAnnualVacation", par);	
			par.put("vacDay", obj.getDouble("LongVacDay"));
			par.put("sDate", obj.getString("UseStartDate"));
			par.put("eDate", obj.getString("UseEndDate"));
			par.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
			par.put("comment", "연차 자동생성(이월:" + obj.getDouble("LastVacDay") + ")");
			par.put("modifierCode", obj.getString("RegisterCode")); 
			coviMapperOne.update("groupware.vacation.insertVmPlanHist", par);
		}
	}

	@Override
	public int insertCreateAnnualVacationV2(CoviMap param) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectAutoCreateAnnualVacationV2", param);
		int rtnCnt = 0;

		CoviList vacList = CoviSelectSet.coviSelectJSON(list, "YEAR,UR_Code,VacKind,UseStartDate,UseEndDate,DeptCode,DeptName,LongVacDay,LastVacDay,RewardVacDay,RegisterCode,RegistDate");

		for(Object vacInfo : vacList) {
			CoviMap obj = new CoviMap();
			obj = (CoviMap) vacInfo;
			CoviMap par = new CoviMap();
			par.put("year", obj.getInt("YEAR"));
			par.put("urCode", obj.getString("UR_Code"));
			par.put("vacKind", obj.getString("VacKind"));
			par.put("useStartDate", obj.getString("UseStartDate"));
			par.put("useEndDate", obj.getString("UseEndDate"));
			par.put("deptCode", obj.getString("DeptCode"));
			par.put("deptName", obj.getString("DeptName"));
			par.put("longVacDay", obj.getDouble("LongVacDay"));
			par.put("lastVacDay", obj.getDouble("LastVacDay"));
			rtnCnt += coviMapperOne.insert("groupware.vacation.insertAutoCreateAnnualVacationV2", par);
			par.put("vacDay", obj.getDouble("LongVacDay"));
			par.put("sDate", obj.getString("UseStartDate"));
			par.put("eDate", obj.getString("UseEndDate"));
			par.put("vmMethod", "AUTO"); // AUTO(자동), EXCEL(엑셀), MNL(수기)
			par.put("comment", "입사일기준 년단위 만근 연차 자동생성[이월:"+obj.getDouble("LastVacDay")+"]");
			par.put("registerCode", "system"); 
			par.put("modifierCode", "system"); 
			coviMapperOne.update("groupware.vacation.insertVmPlanHist", par);
		}
		return rtnCnt;
	}

	@Override
	public void insertNewAnnualVacation(CoviMap param) throws Exception {
		coviMapperOne.insert("groupware.vacation.insertNewAnnualVacation", param);
	}

	@Override
	public void insertNewAnnualVacationV2(CoviMap param) throws Exception {
		coviMapperOne.insert("groupware.vacation.insertNewAnnualVacationV2", param);
	}

	@Override
	public void updateDeptInfo(CoviMap param) throws Exception {
		coviMapperOne.insert("groupware.vacation.updateDeptInfo", param);
	}

	@Override
	public String getVacationPolicy() throws Exception {
		
		String filePath = RedisDataUtil.getBaseConfig("vactionPolicyPath");
		String lineSeparator = System.getProperty("line.separator");
		FileInputStream fis = null;
		InputStreamReader isr = null;
		BufferedReader br = null;
		StringBuffer result = null;
		
		try {
			
/*			if(osType.equals("WINDOWS")){
				filePath = RedisDataUtil.getBaseConfig("vactionPolicyPath_Windows");
			} else {
				filePath = RedisDataUtil.getBaseConfig("vactionPolicyPath_Unix");
			}
*/			
			File file = new File(FileUtil.checkTraversalCharacter(filePath));
			
			if(filePath.isEmpty() || !file.exists() ){
				return "";
			}
			
			fis = new FileInputStream(filePath);
			isr = new InputStreamReader(fis, "UTF8");
			br = new BufferedReader(isr);
			
			StringBuilder builder = new StringBuilder();
			String sCurrentLine;
			
			while ((sCurrentLine = br.readLine()) != null) {
				builder.append(sCurrentLine + lineSeparator);
			}
			String text = builder.toString();
			Pattern p = Pattern.compile("<spring:message[^>]*code=[\"']?([^>\"']+)[\"']?[^>]*(/>|></spring>|></spring:message>)");
			Matcher m = p.matcher(text);
			
			result = new StringBuffer(text.length());
			while(m.find()){
				String key = m.group(1).replace("Cache.", "");
				//tempDic 부분을 redis 다국어 가져 오는 걸로 대체
				m.appendReplacement(result, DicHelper.getDic(key));
			}
			m.appendTail(result);
			
		} catch(IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return "";
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return "";
		}catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return "";
		}finally {
			if (fis != null) { try { fis.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (isr != null) { try { isr.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (br != null) { try { br.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}		
		
		return result.toString();
		
	}

	@Override
	public CoviMap getVacationTypeList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		params.put("lang",SessionHelper.getSession("lang"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));

		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacTypeListCnt", params);
			page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			resultList.put("page", page);
			resultList.put("cnt", cnt);
		}
		
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacTypeList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		
		return resultList;
	} 
   
	@Override
	public int updVacationType(CoviMap params) throws Exception {
		params.put("RegUserCode", SessionHelper.getSession("USERID"));
		return 	coviMapperOne.update("groupware.vacation.updVacationType", params);
	}

	@Override
	public int setVacationType(CoviMap params) throws Exception {
		params.put("RegUserCode", SessionHelper.getSession("USERID"));
		params.put("DomainID", SessionHelper.getSession("DN_ID"));
		return 	coviMapperOne.update("groupware.vacation.setVacationType", params);
	}

	@Override
	public int delVacationType(CoviMap params) throws Exception {
		return 	coviMapperOne.delete("groupware.vacation.delVacationType", params);
	}

	@Override
	public CoviMap getDeptList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();

		CoviList deptList = coviMapperOne.list("groupware.vacation.selectDeptList", params);
		resultList.put("deptList",CoviSelectSet.coviSelectJSON(deptList));

		return resultList; 
	}

	@Override
	public CoviMap getJobWorkOnDays(CoviMap params) {
		CoviMap resultList = new CoviMap();

		Map<String, String> dayOffList = new HashMap<>();
		params.put("StartDate",params.get("year")+"0101");
		params.put("EndDate",params.get("year")+"1231");
		CoviList workOnDayList = coviMapperOne.list("attend.job.getJobWorkOnDays", params);
		for (int k=0; k<workOnDayList.size(); k++) {
			CoviMap map = workOnDayList.getMap(k);
			dayOffList.put(map.getString("JobDate").replaceAll("-",""), map.getString("WorkSts"));
		}
		resultList.put("dayOffList", dayOffList);
		return resultList;
	}

	@Override
	public CoviMap getVacTypeDomain() throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap paramMap4Type = new CoviMap();
		paramMap4Type.put("domainId", SessionHelper.getSession("DN_ID"));
		paramMap4Type.put("lang", SessionHelper.getSession("lang"));
		// DomainID로 각 도메인에 맞는 휴가관련의 코드 조회.
		// 휴가 유형이 추가되면서, 연차소진대상(Reserved1 = '+') 조건 추가. 연차계산은 Reserved3을 이용.
		CoviList vacationType = coviMapperOne.list("groupware.vacation.selectVacationType", paramMap4Type);
		
		resultList.put("vacationType",CoviSelectSet.coviSelectJSON(vacationType));
		return resultList;
	}

	@Override
	public CoviMap getExtraVacKind(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		CoviList vacationType = coviMapperOne.list("groupware.vacation.selectExtraVacationKind", params);

		resultList.put("list",CoviSelectSet.coviSelectJSON(vacationType));
		return resultList;
	}
	
	@Override
	public CoviMap getRewardVacKind(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		CoviList vacationType = coviMapperOne.list("groupware.vacation.selectRewardVacationKind", params);

		resultList.put("list",CoviSelectSet.coviSelectJSON(vacationType));
		return resultList;
	}

	// 회사 휴가/근태 현황 조회
	@Override
	public CoviMap selectVacationListByAll(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		resultList.put("deptList", CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.vacation.selectDeptList", params)));
		resultList.put("vacList", CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.vacation.selectVacationListByAll", params)));
		return resultList;
	}	

	// 휴가사용리스트
	@Override
	public CoviMap getVacationListByUse(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(params.get("pageNo") != null) {
			int cnt = (int) coviMapperOne.getNumber("groupware.vacation.getVacationListByUseHistCnt", params);
			page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
		}
		CoviList list = coviMapperOne.list("groupware.vacation.getVacationListByUseHist", params);
		   
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}
	// 기타휴가목록 조회
	@Override
	public CoviMap getVacationExtraList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationExtraListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationExtraList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,DeptName,JobPositionName,ExtVacName,ExtVacYear,ExtSdate,ExtEdate,ExtVacType,ExtVacDay,ExtUseVacDay,ExtRemainVacDay,ExtReason,RegisterName,RegistDate,ExpDate,RegisterCode,IsUse,ExpYN"));
		resultList.put("page", page);

		return resultList;
	}
	// 보상목록 조회
	@Override
	public CoviMap getVacationRewardList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationRewardListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationRewardList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,DeptName,JobPositionName,ExtVacName,ExtVacYear,ExtSdate,ExtEdate,ExtVacType,ExtVacDay,ExtUseVacDay,ExtRemainVacDay,ExtReason,RegisterName,RegistDate,ExpDate,RegisterCode,IsUse,ExpYN,RewardVacDay"));
		resultList.put("page", page);

		return resultList;
	}
	// 공동휴가목록 조회
	@Override
	public CoviMap getVacationManageList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationManageListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationManageList", params);

		resultList.put("list",list);
		resultList.put("page", page);

		return resultList;
	}	
	// 기타휴가목록 조회
	@Override
	public CoviMap getVacationListByKind(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviMap req = new CoviMap();
		/*
		req.put("CompanyCode", params.getString("domainCode"));
		req.put("getName", "CreateMethod");
		String CreateMethod = getVacationConfigVal(req);
		if(CreateMethod==null || CreateMethod.equals("")){
			CreateMethod = "F";
		}

		int cnt = 0;
		if(CreateMethod.equals("J")){
			cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationListByKindCntV2", params);
		}else {
			cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationListByKindCnt", params);
		}
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);

		CoviList list = new CoviList();
		if(CreateMethod.equals("J")){
			CoviList listP = coviMapperOne.list("groupware.vacation.selectVacationListByKindV2", params);
			for(int i=0;i<listP.size();i++){
				list.add(listP.getMap(i));
			}
			CoviList listE = coviMapperOne.list("groupware.vacation.selectVacationListByKindV3", params);
			for(int i=0;i<listE.size();i++){
				list.add(listE.getMap(i));
			}
		}else {
			list = coviMapperOne.list("groupware.vacation.selectVacationListByKind", params);
		}

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,DeptName,JobPositionName,VacName,VacYear,Sdate,Edate,VacKind,VacDay,UseVacDay,RemainVacDay,Reason,RegisterName,RegistDate,ExpDate,RegisterCode"));
		resultList.put("page", page);
*/
		resultList.put("list", coviMapperOne.list("groupware.vacation.selectVacationListByKindAll", params));
		return resultList;
	}

	@Override
	public CoviMap getVacationByCode(CoviMap params, List userCodeList) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(userCodeList!=null && userCodeList.size()>0) {
			ArrayList<String> objUsers = new ArrayList();
			for (int k = 0; k < userCodeList.size(); k++) {
				Map itemUser = (Map) userCodeList.get(k);
				if (itemUser.get("Type").equals("UR")) {
					if (!duplicateUserCheck(objUsers, itemUser.get("Code").toString())) {
						objUsers.add(itemUser.get("Code").toString());
					}
				} else {
					CoviMap deptParam = new CoviMap();
					deptParam.put("CompanyCode", params.get("CompanyCode"));
					deptParam.put("sDeptCode", itemUser.get("Code"));

					CoviList userList = coviMapperOne.list("attend.common.getUserListByDept", deptParam);
					for (int i = 0; i < userList.size(); i++) {
						if (!duplicateUserCheck(objUsers, userList.getMap(i).getString("UserCode"))) {
							objUsers.add(userList.getMap(i).getString("UserCode"));
						}
					}
				}
			}

			params.put("userList", objUsers.toArray());
		}

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationByCode", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DeptName,CodeName,Sdate,Edate,VacKind,VacDay,VacDayUse,VacDayRemain,EachVacDay,EachUseVacDay"));
		resultList.put("page", page);

		return resultList;
	}
	
	//발생이력 목록 조회
	public CoviMap getVacationPlanHistList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationPlanHistListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationPlanHistList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,DeptName,JobPositionName,ExtVacName,ExtVacYear,ExtSdate,ExtEdate,ExtVacType,ExtVacDay,ExtUseVacDay,ExtRemainVacDay,ExtReason,RegisterName,RegistDate,ExpDate,VmComment,ChangeDate,RegisterCode"));
		resultList.put("page", page);

		return resultList;
	}	
	
	//발생이력 휴가유형 필터 조회
	public CoviMap selectVacationFlagSelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationFlagSelList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "OptionName,OptionValue"));
		
		return resultList;
	}
	
	//연차촉진 기간설정 목록 조회
	public CoviMap getVacationPromotionDateList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationPromotionDateList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CompanyCode,ReqType,ReqTypeName,ReqOrd,ReqMonth,ReqTermDay,ReqOrder,CompanyCode2,ReqType2,ReqTypeName2,ReqOrd2,ReqMonth2,ReqTermDay2,ReqOrder2"));
		
		return resultList;
	}

	public int initVacationPromotionDate(CoviMap params) throws Exception{
		int rtn = coviMapperOne.insert("groupware.vacation.initVacationPromotionDate", params);
		return rtn;
	}
	
	//연차촉진 기간설정 조회
	@Override 
	public CoviMap getVacationPromotionDate(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap map			= new CoviMap();
		map	= coviMapperOne.selectOne("groupware.vacation.selectVacPromotionDate", params);	
		resultList.put("data",	map);
		
		return resultList; 
	}
	
	// 연차촉진 기간설정 수정
	@Override
	public int updateVacationPromotionDate(CoviMap params) throws Exception {
		int rtn = coviMapperOne.update("groupware.vacation.updateVacPromotionDate", params);
		return rtn;
	}

	public int initVacationConfig(CoviMap params) throws Exception{
		int rtn = coviMapperOne.insert("groupware.vacation.initVacationConfig", params);
		return rtn;
	}

	@Override
	public String getVacationConfigVal(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.getVacationConfig", params);
		CoviList returnJsonArray = CoviSelectSet.coviSelectJSON(list, "CompanyCode,CreateMethod,InitCnt,IncTerm,IncCnt,MaxCnt,RemMethod,ReqInfoMethod,IsAuto,FormTitle090,FormTitle091,FormTitle092,FormTitle021,FormTitle022,FormTitle100,FormTitle101,FormTitle102,FormBody090,FormBody091,FormBody092,FormBody021,FormBody022,FormBody100,FormBody101,FormBody102,MailSenderName,MailSenderAddr,useYn090,useYn091,useYn092,useYn021,useYn022,useYn100,useYn101,useYn102");
		CoviMap vacConfigMap = (CoviMap) returnJsonArray.get(0);
		return vacConfigMap.getString(params.getString("getName"));
	}
	//휴가생성 자동 규칙설정 조회
	@Override
	public CoviList getVacationConfig(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.getVacationConfig", params);
		return CoviSelectSet.coviSelectJSON(list, "CompanyCode,CreateMethod,InitCnt,IncTerm,IncCnt,MaxCnt,RemMethod,YearRemMethod,IsRemRenewal,YearCreateAnnualVacation,ReqInfoMethod,IsAuto,FormTitle090,FormTitle091,FormTitle092,FormTitle021,FormTitle022,FormTitle100,FormTitle101,FormTitle102,FormBody090,FormBody091,FormBody092,FormBody021,FormBody022,FormBody100,FormBody101,FormBody102,MailSenderName,MailSenderAddr,useYn090,useYn091,useYn092,useYn021,useYn022,useYn100,useYn101,useYn102");
	}
	
	@Override
	public CoviList getUserDisplayName(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.getUserDisplayName", params);
		return CoviSelectSet.coviSelectJSON(list, "UserCode,DisplayName");
	}
	
	// 연차촉진 기간설정 수정
	@Override
	public int updateVacationConfig(CoviMap params) throws Exception {
		int rtn = coviMapperOne.update("groupware.vacation.updateVacationConfig", params);
		return rtn;
	}
	
	// 선연차 설정 수정
	@Override
	public int updateBeforeAnnual(CoviMap params) throws Exception {
			
		CoviMap isUseParams = new CoviMap();
		isUseParams.put("SettingKey", "isUseBeforeAnnual");
		isUseParams.put("SettingValue", params.getString("isBeforeAnnual"));
		isUseParams.put("DN_ID", SessionHelper.getSession("DN_ID"));
		isUseParams.put("UserCode",SessionHelper.getSession("USERID"));
		int rtn = coviMapperOne.update("groupware.vacation.updateBeforeAnnual",isUseParams);
		
		CoviMap memberParams = new CoviMap();
		memberParams.put("SettingKey", "BeforeAnnualMember");
		memberParams.put("SettingValue", params.getString("beforeAnnualMember"));
		memberParams.put("DN_ID", SessionHelper.getSession("DN_ID"));
		memberParams.put("UserCode",SessionHelper.getSession("USERID"));
		rtn += coviMapperOne.update("groupware.vacation.updateBeforeAnnual", memberParams);
		
		return rtn;
	}

	// 휴가 유효기간 회계년도/입사일 기준으로 업데이트
	@Override
	public int updateVacationExpireDateRange(CoviMap params) throws Exception {
		int rtn = coviMapperOne.update("groupware.vacation.updateVacationExpireDateRange", params);
		return rtn;
	}

	@Override
	public int deleteVacationPlanHist(CoviMap params) throws Exception {
		return 	coviMapperOne.delete("groupware.vacation.deleteVacationPlanHist", params);
	}

	public int updateResetVacationDays(CoviMap params) throws Exception {
		coviMapperOne.update("groupware.vacation.updateResetVacationDays", params);
		return 0;
	}

	// 연차 촉진 대상자 목록 금일 기준(now())
	@Override
	public CoviList getVacationPromotionTargetList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationPromotionTargetList", params);
		return CoviSelectSet.coviSelectJSON(list, "UserCode,DisplayName,MailAddress,EnterDate,ReqType,RetireDate,CreateMethod,IsOneYear,VacDate,OneDate,TwoDate,LessVacDate,LessOneDate9,LessTwoDate9,LessOneDate2,LessTwoDate2");
	}

	@Override
	public CoviList getVacationPromotionTargetUserInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationPromotionTargetUserInfo", params);
		return CoviSelectSet.coviSelectJSON(list, "UserCode,UR_Name,JobPositionName,EnterDate,RetireDate,CreateMethod,JobPositionSortKey,TYEAR,YYYY,IsOneYear,VacDateFrom,VacDateTo,VacDateRange,OneDateFrom,OneDateTo,OneDateRange,TwoDateFrom,TwoDateTo,TwoDateRange,LessVacDateFrom,LessVacDateTo,LessOneDate9From,LessOneDate9To,LessOneDate9Range,LessTwoDate9From,LessTwoDate9To,LessTwoDate9Range,LessOneDate2From,LessOneDate2To,LessOneDate2Range,LessTwoDate2From,LessTwoDate2To,LessTwoDate2Range");
	}

	//사용자별 연차촉진일 목록 조회
	@Override
	public CoviMap getVacationFacilitatingDateList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		if(params.getString("urCode").equals("") && params.getString("emailReSend").equals("") ) {//urcode 로 검색 하는 케이스는 1개 row
			int cnt = (int) coviMapperOne.getNumber("groupware.vacation.selectVacationFacilitatingDateCnt", params);
			page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			resultList.put("page", page);
			resultList.put("cnt", cnt);
		}

		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationFacilitatingDateList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,DisplayName,DeptName,JobPositionName,EnterDate,RetireDate,MailAddress,CreateMethod,TargetYear,IsOneYear,VacDate,VacDateUntil,OneDate,OneDateUntil,TwoDate,TwoDateUntil,LessVacDate,LessVacDateUntil,LessOneDate9,LessOneDate9Until,LessTwoDate9,LessTwoDate9Until,LessOneDate2,LessOneDate2Until,LessTwoDate2,LessTwoDate2Until,Read10,Read11,Read12,Read13,Read14,Read18,Read19,Read20,VACPLAN,VACPLAN1,VACPLAN2,NEXT_VACPLAN"));

		return resultList;
	}

	@Override
	public CoviList getVacationUsePlanMigrationList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectVacationUsePlanMigrationList", params);
		return list;
	}

	//사용자별 연차촉진일 목록 조회
	@Override
	public int updateVacPlanMigration(CoviMap param) throws Exception {
		CoviMap req = new CoviMap();
		int rtn = -1;
		req.put("urCode","");
		req.put("year", param.getInt("year"));
		req.put("domainCode", param.getString("domainCode"));
		CoviList vacPlanList = getVacationUsePlanMigrationList(req);
		Gson gson = new Gson();
		ObjectMapper objectMapper = new ObjectMapper();
		for(int i=0;i<vacPlanList.size();i++) {
			CoviMap cmapVacPlan = vacPlanList.getMap(i);
			String VACPLAN = cmapVacPlan.getString("VACPLAN");
			String NEXT_VACPLAN = cmapVacPlan.getString("NEXT_VACPLAN");
			CoviMap cVACPLAN = gson.fromJson(VACPLAN, CoviMap.class);
			CoviMap cVACNEXT = gson.fromJson(NEXT_VACPLAN, CoviMap.class);
			boolean isUpdate = false;
			if(cVACNEXT!=null) {
				if(cVACPLAN==null){
					cVACPLAN = cVACNEXT;
					isUpdate = true;
				}
				/*System.out.println("####UserCode:" + cmapVacPlan.getString("UserCode"));
				System.out.println("####cVACPLAN:" + cVACPLAN);
				System.out.println("####cVACNEXT:" + cVACNEXT);*/
				Object next_notification1 = cVACNEXT.get("notification1");
				Object next_notification2 = cVACNEXT.get("notification2");
				Object next_plan = cVACNEXT.get("plan");


				Object ori_notification1 = cVACPLAN.get("notification1");
				Object ori_notification2 = cVACPLAN.get("notification2");
				Object ori_plan = cVACPLAN.get("plan");

				if(next_notification1!=null){
					if(ori_notification1==null){
						cVACPLAN.put("notification1",next_notification1);
						isUpdate = true;
					}else{
						CoviMap orimap = objectMapper.convertValue(ori_notification1, CoviMap.class);
						CoviMap nextmap = objectMapper.convertValue(next_notification1, CoviMap.class);
						Object obj2 = orimap.get("newEmpForNine");
						if(obj2==null){
							orimap.put("newEmpForNine",nextmap.get("newEmpForNine"));
							isUpdate = true;
						}
						Object obj3 = orimap.get("newEmpForTwo");
						if(obj3==null){
							orimap.put("newEmpForTwo",nextmap.get("newEmpForTwo"));
							isUpdate = true;
						}
						cVACPLAN.replace("notification1", orimap);
					}
				}
				if(next_notification2!=null){
					if(ori_notification2==null){
						cVACPLAN.put("notification2",next_notification2);
						isUpdate = true;
					}else{
						CoviMap orimap = objectMapper.convertValue(ori_notification2, CoviMap.class);
						CoviMap nextmap = objectMapper.convertValue(next_notification2, CoviMap.class);
						Object obj2 = orimap.get("newEmpForNine");
						if(obj2==null){
							orimap.put("newEmpForNine",nextmap.get("newEmpForNine"));
							isUpdate = true;
						}
						Object obj3 = orimap.get("newEmpForTwo");
						if(obj3==null){
							orimap.put("newEmpForTwo",nextmap.get("newEmpForTwo"));
							isUpdate = true;
						}
						cVACPLAN.replace("notification2", orimap);
					}
				}
				if(next_plan!=null){
					if(ori_plan==null){
						cVACPLAN.put("plan",next_plan);
						isUpdate = true;
					}else{
						CoviMap orimap = objectMapper.convertValue(ori_plan, CoviMap.class);
						CoviMap nextmap = objectMapper.convertValue(next_plan, CoviMap.class);
						Object obj2 = orimap.get("newEmp");
						if(obj2==null){
							orimap.put("newEmp",nextmap.get("newEmp"));
							cVACPLAN.replace("plan", orimap);
							isUpdate = true;
						}
					}

				}

			}

			if(isUpdate){
				//System.out.println("######cVACPLAN>>"+gson.newBuilder().setPrettyPrinting().create().toJson(cVACPLAN));
				CoviMap params = new CoviMap();
				params.put("updateVacPlan",gson.newBuilder().create().toJson(cVACPLAN));
				params.put("TargetYear",cmapVacPlan.getInt("TargetYear"));
				params.put("UserCode",cmapVacPlan.getString("UserCode"));
				params.put("UserName",cmapVacPlan.getString("DisplayName"));
				params.put("GrCode",cmapVacPlan.getString("DeptCode"));
				params.put("GrName",cmapVacPlan.getString("DeptName"));
				rtn +=  coviMapperOne.update("groupware.vacation.updateVacPlanMigration", params);
			}
		}
		return rtn;
	}
	// 휴가부여이력팝업 조회
	@Override
	public CoviMap getVacationPlanHist(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		int cnt = (int) coviMapperOne.getNumber("groupware.vacation.getVacationPlanHistCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("groupware.vacation.getVacationPlanHist", params);
		   
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,DisplayName,UseDate,VacDay,Comment,ChangeDate,VmMethod"));
		resultList.put("page", page);
		
		return resultList;
	}
	@Override
	public void updateLastLongVacDay(CoviMap param) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectLastLongVacDay", param);
		CoviList vacUpdateList = CoviSelectSet.coviSelectJSON(list, "UR_Code,YEAR,VacDay");
		for(Object vacInfo : vacUpdateList) {
			CoviMap obj = new CoviMap();
			obj = (CoviMap) vacInfo;
			CoviMap par = new CoviMap();
			par.put("userCode", obj.getString("UR_Code"));
			par.put("year", obj.getInt("YEAR"));
			par.put("domainCode", param.getString("domainCode"));
			coviMapperOne.update("groupware.vacation.updateLastLongVacDay", par);
		}
	}
	@Override
	public void updateLastLongVacDayV2(CoviMap param) throws Exception {
		CoviList list = coviMapperOne.list("groupware.vacation.selectLastLongVacDayV2", param);
		CoviList vacUpdateList = CoviSelectSet.coviSelectJSON(list, "UserCode,YEAR,VacDay");
		for(Object vacInfo : vacUpdateList) {
			CoviMap obj = new CoviMap();
			obj = (CoviMap) vacInfo;
			CoviMap par = new CoviMap();
			par.put("userCode", obj.getString("UserCode"));
			par.put("year", obj.getInt("YEAR"));
			par.put("domainCode", param.getString("domainCode"));
			coviMapperOne.update("groupware.vacation.updateLastLongVacDay", par);
		}
	}
}
