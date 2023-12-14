package egovframework.covision.groupware.attend.user.service.impl;

import javax.annotation.Resource;

import egovframework.coviframework.util.RedisDataUtil;
import egovframework.covision.groupware.attend.user.util.AttendUtils;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.attend.user.service.AttendExHoSvc;
import egovframework.covision.groupware.attend.user.util.AuthCheckUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("AttendExHoSvc")
public class AttendExHoSvcImpl extends EgovAbstractServiceImpl  implements AttendExHoSvc {

	private Logger LOGGER = LogManager.getLogger(AttendExHoSvcImpl.class); 
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override 
	public CoviMap getExHoInfoList(CoviMap params) throws Exception {
		
		CoviMap resultList = new CoviMap();
		if (params.get("ExHoSeq") == null && params.get("pageSize") != null){
			params.put("isAdmin", SessionHelper.getSession("isAdmin")); 
			params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
			params.put("JobTitleCode", AuthCheckUtils.getAttendanceAuthCheck());
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			int adminCnt = coviMapperOne.selectOne("attend.common.selectGroupMemberList", params);
			
			if(adminCnt > 0) {
				params.put("JobTitleCode","Admin");
				params.put("isAdmin","Y"); 
			}else{
				params.put("isAdmin","N");
			}
			
			params.put("DEPTIDORI", SessionHelper.getSession("DEPTID"));
			params.put("lang",  SessionHelper.getSession("lang"));
			
			CoviMap cMap = null;

			if("Y".equals(RedisDataUtil.getBaseConfig("ExtenHoliTimeMethod")))
				cMap = coviMapperOne.selectOne("attend.exho.selectExHoInfoListCnt2", params);
			else
				cMap = coviMapperOne.selectOne("attend.exho.selectExHoInfoListCnt", params);

			CoviMap page = new CoviMap();
			int cnt = 0;
			if (cMap != null) {
				cnt = cMap.getInt("ExHoCnt");
				page = ComUtils.setPagingCoviData(params, cnt);
			 	params.addAll(page);
				resultList.put("page", page);
				resultList.put("cnt", cnt);
			} else {
				page = ComUtils.setPagingCoviData(params, cnt);
			 	params.addAll(page);
				resultList.put("page", page);
				resultList.put("cnt", cnt);
			}
			
			resultList.put("tot", cMap);			
		}	
		
		params.put("CompanyCode",  SessionHelper.getSession("DN_Code")); 
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));

		CoviList list = null;
		
		if("Y".equals(RedisDataUtil.getBaseConfig("ExtenHoliTimeMethod")))
			list = coviMapperOne.list("attend.exho.selectExHoInfoList2", params);
		else
			list = coviMapperOne.list("attend.exho.selectExHoInfoList", params);

		resultList.put("list", list);
		
		return resultList;
	}

	@Override 
	public void updExHoInfo(CoviMap params) throws Exception {
		if (params.getString("ApprovalSts").equals("N")){	//취소건은 삭제 후 근태 마스터 변경
			coviMapperOne.delete("attend.exho.deleteExHoInfo",params);

			params.put("UserCode", params.get("TargetUserCode"));
			coviMapperOne.update("attend.commute.setCommuteMstProc", params);
		} else {
			coviMapperOne.update("attend.exho.updExHoInfo",params);
		}
		
	}

/*
	@Override
	public CoviMap getExHoInfoExcelList(CoviMap params) throws Exception {
		params.put("JobTitleCode", AuthCheckUtils.getAttendanceAuthCheck());
		params.put("isAdmin", SessionHelper.getSession("isAdmin")); 
		params.put("UserCode", SessionHelper.getSession("USERID"));
		int adminCnt = coviMapperOne.selectOne("attend.common.selectGroupMemberList", params);
		if(adminCnt > 0) {
			params.put("JobTitleCode","Admin");
			params.put("isAdmin", "Y");
		}else{
			params.put("isAdmin", "N");
		}
		params.put("DEPTIDORI", SessionHelper.getSession("DEPTID")); 
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("CompanyCode",  SessionHelper.getSession("DN_Code"));
		
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));
		
		CoviList list = coviMapperOne.list("attend.exho.selectExHoInfoList", params);
		CoviMap resultList = new CoviMap();
	     
		resultList.put("list", list);
		
		LOGGER.error(resultList.get("list"));
		return resultList;
	}
*/
	@Override
	public CoviMap getCallingInfoList(CoviMap params) throws Exception {
		
		params.put("isAdmin", SessionHelper.getSession("isAdmin")); 
		params.put("JobTitleCode", AuthCheckUtils.getAttendanceAuthCheck());
		params.put("UserCode", SessionHelper.getSession("USERID"));
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		
		int adminCnt = coviMapperOne.selectOne("attend.common.selectGroupMemberList", params);
		
		if(adminCnt > 0) {
			params.put("JobTitleCode","Admin");
			params.put("isAdmin","Y");  
		}else{
			params.put("isAdmin","N"); 
		}
		
		params.put("DEPTIDORI", SessionHelper.getSession("DEPTID"));  
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("CompanyCode",  SessionHelper.getSession("DN_Code")); 
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));

		CoviMap resultList = new CoviMap();
		if (params.get("pageSize") != null){
			int cnt = (int) coviMapperOne.getNumber("attend.exho.getCallingListCnt", params);
		 	params.addAll(ComUtils.setPagingData(params,cnt));
		 	resultList.put("page", params);
			resultList.put("cnt", cnt);			
		}

		CoviList list = coviMapperOne.list("attend.exho.getCallingList", params);
		resultList.put("list", list);
		
		return resultList;
	}
	
	/**
	 * @Method Name : getAttendExcelList 
	 * @Description : 감사레포트 목록 조회
	 */
	@Override
	public CoviMap getAttendExcelList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();
		
		params.put("lang", SessionHelper.getSession("lang"));
		String ExcelType = params.getString("ExcelType");
		
		String queryId = "attend.exho.getAttend"+ExcelType+"List";
		list	= coviMapperOne.list(queryId, params);				
		resultList.put("list",	list);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getExHoTimeInfo 
	 * @Description : 연장/휴일 근무 신청 시간 조회
	 */
	@Override
	public CoviMap getExHoTimeInfo(CoviMap params) throws Exception {
		CoviMap resultMap = new CoviMap();
		resultMap.put("list", coviMapperOne.list("attend.exho.selectExHoTimeInfo", params));
		return resultMap;
	}
	
/*
	@Override
	public CoviMap getCallingInfoExcelList(CoviMap params) throws Exception {
		params.put("JobTitleCode", AuthCheckUtils.getAttendanceAuthCheck());
		params.put("isAdmin", SessionHelper.getSession("isAdmin")); 
		params.put("UserCode", SessionHelper.getSession("USERID"));
		int adminCnt = coviMapperOne.selectOne("attend.common.selectGroupMemberList", params);
		if(adminCnt > 0) {
			params.put("JobTitleCode","Admin");
			params.put("isAdmin", "Y");
		}else{
			params.put("isAdmin", "N");
		}
		params.put("DEPTIDORI", SessionHelper.getSession("DEPTID")); 
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("CompanyCode",  SessionHelper.getSession("DN_Code"));
		params.put("UR_TimeZone", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat));

		CoviList list = coviMapperOne.list("attend.exho.getCallingList", params);
		CoviMap resultList = new CoviMap();
	     
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,CallingSeq,TransMultiDisplayName,TransMultiDeptName,TargetDate,CommuteYnStr,PreChangeTime,ChangeTime,Etc,BillName,ProcessId,RegistDate,DeptFullPath,TransMultiJobPositionName,EnterDate"));
		LOGGER.error(resultList.get("list"));
		return resultList;
	}
 */
}
