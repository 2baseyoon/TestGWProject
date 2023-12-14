package egovframework.covision.groupware.attend.user.service.impl;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.StringTokenizer;

import javax.annotation.Resource;

import egovframework.coviframework.util.ACLHelper;
import egovframework.covision.groupware.attend.user.util.AttendUtils;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;

@Service("AttendCommonSvc")
public class AttendCommonSvcImpl extends EgovAbstractServiceImpl implements AttendCommonSvc {
	private static final Logger LOGGER = LogManager.getLogger(AttendCommonSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	private CoviMap paramSet(CoviMap params){
		String lang = SessionHelper.getSession("lang");
		String CompanyCode = SessionHelper.getSession("DN_Code"); //회사코드	
		String UserCode = SessionHelper.getSession("USERID"); //사용자코드		
		String DeptCode = SessionHelper.getSession("GR_Code"); //부서코드
		String DeptPath = SessionHelper.getSession("GR_GroupPath"); //부서depth

		params.put("lang",lang);
		params.put("CompanyCode",CompanyCode);
		params.put("UserCode",UserCode);
		params.put("DeptCode",DeptCode);
		params.put("DeptPath",DeptPath);
		return params;
	}

	@Override
	public String getUserAuthType() throws Exception {
		String attendAuth = "";
		
		CoviMap params = new CoviMap();
		params = paramSet(params);
		String domainID =  SessionHelper.getSession("DN_ID");
		
		//근태관리 관리자 권한조회
		if(ACLHelper.getExitsUserGroup(SessionHelper.getSession(), domainID+"_Attendance_Admin")) {
			attendAuth = "ADMIN";
		}else{	
			attendAuth = "USER";
		}	
		/*
		String AuthType = domainID+"_Attendance_Admin";
		params.put("AuthType", AuthType);
		int adminCnt = coviMapperOne.selectOne("attend.common.getUserAuthType", params);
		if(adminCnt>0){
			attendAuth = "ADMIN";
		}else{
			//관리자 권한 없을 시 Manager 권한확인
			AuthType = domainID+"_Attendance_Manager";
			params.put("AuthType", AuthType);
			int managerCnt = coviMapperOne.selectOne("attend.common.getUserAuthType", params);
			
			if(managerCnt>0){
				attendAuth = "MANAGER";
			}else{
				//Manager 권한 없을 시 일반 사용자
				attendAuth = "USER";
			}
		}
*/
		return attendAuth;
	}
	
	@Override
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

	@Override
	public CoviMap getDeptListByAuth() throws Exception {
		CoviMap returnObj = new CoviMap();
		
		//근태관리 관리자 권한조회
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		returnObj.put("deptList", getSubDeptListByAuth(attendAuth,jobType));
		
		return returnObj;
	}
	@Override
	public CoviList getDeptListByAuthCoviList() throws Exception {
		//근태관리 관리자 권한조회
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		return getSubDeptListByAuthCoviList(attendAuth,jobType);
	}
	
	@Override
	public CoviList getSubDeptListByAuth(String attendAuth,String jobType) throws Exception {
		CoviList returnArray = new CoviList();
		
		CoviMap params = new CoviMap();
		params = paramSet(params);
		params.put("attendAuth", attendAuth==null||"".equals(attendAuth)?"USER":attendAuth);
		params.put("jobType", jobType==null||"".equals(jobType)?"USER":jobType);
		
		CoviList deptList = coviMapperOne.list("attend.common.getSubDeptList", params);
		returnArray = CoviSelectSet.coviSelectJSON(deptList, "GroupID,GroupCode,CompanyCode,GroupType,MemberOf,DisplayName,MultiDisPlayName,TransMultiDisplayName,SortDepth,GroupPath");
		
		return returnArray;
	}
	@Override
	public CoviList getSubDeptListByAuthCoviList(String attendAuth,String jobType) throws Exception {
		CoviMap params = new CoviMap();
		params = paramSet(params);
		params.put("attendAuth", attendAuth==null||"".equals(attendAuth)?"USER":attendAuth);
		params.put("jobType", jobType==null||"".equals(jobType)?"USER":jobType);
		
		CoviList deptList = coviMapperOne.list("attend.common.getSubDeptList", params);
		return deptList;
	}
 
	
	@Override
	public CoviList getUserListByAuth() throws Exception{
		//근태관리 관리자 권한조회
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		
		CoviList userList = getUserListByAuth(attendAuth,jobType);
		return userList;
	}
	
	@Override
	public CoviList getUserListByAuthCoviList() throws Exception{
		//근태관리 관리자 권한조회
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		
		CoviList userList = getUserListByAuthCoviList(attendAuth,jobType);
		return userList;
	}
	
	@Override
	public CoviList getUserListByAuth(String attendAuth,String jobType) throws Exception{
		CoviList deptList = getSubDeptListByAuth(attendAuth,jobType);
		CoviList userList = getUserListByAuth(deptList,attendAuth,jobType);
		return userList;
	}
	@Override
	public CoviList getUserListByAuthCoviList(String attendAuth,String jobType) throws Exception{
		CoviList deptList = getSubDeptListByAuth(attendAuth,jobType);
		CoviList userList = getUserListByAuthCoviList(deptList,attendAuth,jobType);
		return userList;
	}
	
	@Override
	public CoviList getUserListByAuth(CoviList deptList,String attendAuth,String jobType) throws Exception{
		CoviList returnArray = new CoviList();
		
		CoviMap params = new CoviMap();
		params = paramSet(params);
		params.put("deptList", deptList);
		
		params.put("retireUser", "ADMIN".equals(attendAuth)?null:"INOFFICE");
		
		CoviList userList = new CoviList();
		
		if("USER".equals(attendAuth)&&"USER".equals(jobType)){
			userList = coviMapperOne.list("attend.common.getMyUserInfo", params);
		}else{
			userList = coviMapperOne.list("attend.common.getUserListByDept", params);			
		}
		
		returnArray = CoviSelectSet.coviSelectJSON(userList, "UserCode,PhotoPath,EnterDate,DeptName,JobPositionName,DisplayName,DeptFullPath,IsUse,IsDisplay");
		
		return returnArray;
	}
	@Override
	public CoviList getUserListByAuthCoviList(CoviList deptList,String attendAuth,String jobType) throws Exception{
		CoviMap params = new CoviMap();
		params = paramSet(params);
		params.put("deptList", deptList);
		
		params.put("retireUser", "ADMIN".equals(attendAuth)?null:"INOFFICE");
		
		CoviList userList = new CoviList();
		if("USER".equals(attendAuth)&&"USER".equals(jobType)){
			userList = coviMapperOne.list("attend.common.getMyUserInfo", params);
		}else{
			userList = coviMapperOne.list("attend.common.getUserListByDept", params);
		}
		return userList;
	}
	@Override
	public CoviList getUserListByAuthCoviList(String deptList,String attendAuth,String jobType) throws Exception{
		CoviMap params = new CoviMap();
		params = paramSet(params);
		params.put("retireUser", "ADMIN".equals(attendAuth)?null:"INOFFICE");
		params.put("sDeptCode", deptList);
		CoviList userList = new CoviList();
		if("USER".equals(attendAuth)&&"USER".equals(jobType)){
			userList = coviMapperOne.list("attend.common.getMyUserInfo", params);
		}else{
			userList = coviMapperOne.list("attend.common.getUserListByDept", params);
		}
		return userList;
	}
	
	@Override
	public CoviList getUserListByAuth(CoviMap params) throws Exception{
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		CoviList deptList = getSubDeptListByAuth(attendAuth,jobType);
		
		CoviList returnArray = new CoviList();

		params = paramSet(params);
		params.put("deptList", deptList);
		
		/**
		 * PARAMETER SETTING 
		 * sDeptCode : 검색 부서코드
		 * sUserCode : 검색 사용자코드
		 * sUserTxt : 검색 사용자명
		 * retireUser : 전체 (null) 재직자 (INOFFICE) 퇴직자 (RETIRE)
		 * */
		
		CoviList userList = new CoviList();
		if("USER".equals(attendAuth)&&"USER".equals(jobType)){ 
			userList = coviMapperOne.list("attend.common.getMyUserInfo", params);
		}else{
			userList = coviMapperOne.list("attend.common.getUserListByDept", params);			
		}
		
		returnArray = CoviSelectSet.coviSelectJSON(userList, "UserCode,PhotoPath,EnterDate,DeptName,JobPositionName,DisplayName,DeptFullPath,IsUse,IsDisplay");
		
		return returnArray;
	}
	
	@Override
	public CoviList getUserListByAuthCoviList(CoviMap params) throws Exception{
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		CoviList deptList = getSubDeptListByAuth(attendAuth,jobType);
		
		params = paramSet(params);
		params.put("deptList", deptList);
		
		/**
		 * PARAMETER SETTING 
		 * sDeptCode : 검색 부서코드
		 * sUserCode : 검색 사용자코드
		 * sUserTxt : 검색 사용자명
		 * sJobTitleCode : 직책코드
		 * sJobLevelCode : 직급토드
		 * retireUser : 전체 (null) 재직자 (INOFFICE) 퇴직자 (RETIRE)
		 * */

		CoviList userList = new CoviList();
		if("USER".equals(attendAuth)&&"USER".equals(jobType)){
			userList = coviMapperOne.list("attend.common.getMyUserInfo", params);
		}else{
			userList = coviMapperOne.list("attend.common.getUserListByDept", params);
		}
		return userList;
	}


	@Override
	public int getUserListByAuthCoviListCnt(CoviMap params) throws Exception{
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		CoviList deptList = getSubDeptListByAuth(attendAuth,jobType);

		params = paramSet(params);
		params.put("deptList", deptList);

		int cnt	= 0;
		if("USER".equals(attendAuth)&&"USER".equals(jobType)){
			cnt	= (int) coviMapperOne.getNumber("attend.common.getMyUserInfoCnt" , params);
		}else{
			cnt = (int) coviMapperOne.getNumber("attend.common.getUserListByDeptCnt" , params);
		}
		
		return cnt;
	}
	
	// 엑셀 데이터 추출
	public ArrayList<ArrayList<Object>> extractionExcelData(CoviMap params, int headerCnt) throws Exception {
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = prepareAttachment(mFile);	// 파일 생성
		ArrayList<ArrayList<Object>> returnList = new ArrayList<>();
		ArrayList<Object> tempList = null;
		Workbook wb = null;
		try {
			wb = WorkbookFactory.create(file);
			Sheet sheet = wb.getSheetAt(0);
			
			Iterator<Row> rowIterator = sheet.iterator();
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				
				if (row.getRowNum() > (headerCnt - 1)) {	// header 제외
					tempList = new ArrayList<>();
					Iterator<Cell> cellIterator = row.cellIterator();
					while (cellIterator.hasNext()) {
						Cell cell = cellIterator.next();
						
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
					
					returnList.add(tempList);
				}
			}
		} catch (IOException e) {
			LOGGER.debug(e);
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		} finally {
			if (file != null) {
				if(!file.delete()) { 
					LOGGER.warn("Fail to delete file " + file.getName());
				}
			}
			if (wb != null) { try { wb.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
		
		return returnList;
	} 
	
	// 임시파일 생성
	public File prepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        
	        return tmp;
	    } catch (IOException ioE) {
	        if (tmp != null) if(!tmp.delete()) {
	        	LOGGER.warn("Fail to delete file " + tmp.getName());
	        }
	        
	        throw ioE;
	    }
	}
	
	@Override
	public int chkAttendanceBaseInfoYn(CoviMap params) throws Exception {

		String attSeq  = coviMapperOne.selectOne("attend.common.chkAttendanceBaseInfoYn", params);
		int returnAttSeq = attSeq!=null?Integer.parseInt(attSeq):0;
		return returnAttSeq;
	}
	
	@Override
	public CoviList getScheduleList(CoviMap params) throws Exception {
		return coviMapperOne.list("attend.common.getScheduleList", params);
	}
	
	/**
	 * @Method Name : getAttendJobCalendar
	 * @Description : 근무일정 달력사용
	 */
	@Override 
	public CoviMap getAttendJobCalendar(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		if (params.get("mode") == null || !"ONLY".equals((String)params.get("mode"))) resultList.put("jobList", coviMapperOne.list("attend.common.getJobCalendar", params));	
		resultList.put("holiList", coviMapperOne.list("attend.common.getHolidaySchedule", params));	
		return resultList;
	}

	@Override
	public String getDayScope(CoviMap params) throws Exception {
		return coviMapperOne.getString("attend.common.getDayScope",params);
	}

	@Override
	public CoviList getHolidaySchedule(CoviMap params) throws Exception {
		return coviMapperOne.list("attend.common.getHolidaySchedule",params);
	}

	@Override
	public CoviList getOtherJobList(CoviMap params) throws Exception {
		params.put("CompanyCode", SessionHelper.getSession("DN_Code") );
		return coviMapperOne.list("attend.common.getOtherJobList",params);
	}

	@Override
	public String getUserNowDateTime(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("attend.common.getUserNowDateTime",params);
	}


	@Override
	public CoviList getAttendUserGroupAutoTagList(CoviMap params) throws Exception {
		params.put("lang",  SessionHelper.getSession("lang"));
		params.put("CompanyCode",  SessionHelper.getSession("DN_Code"));
		
		String attendAuth = getUserAuthType();
		String jobType = getUserJobAuthType();
		CoviList deptList = getSubDeptListByAuth(attendAuth,jobType);
		
		params = paramSet(params);
		params.put("deptList", deptList);
		CoviList list = coviMapperOne.list("attend.common.getUserListByDept", params);
		
		return CoviSelectSet.coviSelectJSON(list, "UserCode,DisplayName,DeptName");
	}
	
	public CoviMap getMyManagerName(String userCode) throws Exception{
		CoviMap params = new CoviMap();
		params.put("userId", userCode);
		params.put("lang",  SessionHelper.getSession("lang"));
		return coviMapperOne.selectOne("attend.common.getMyManagerName",params);

	}
	
	public CoviList getAssList() throws Exception{
		CoviMap params = new CoviMap();
		params.put("CompanyCode",  SessionHelper.getSession("DN_Code"));
		return coviMapperOne.list("attend.adminSetting.getAssList",params);

	}

	public int getMonthlyMaxWorkTime(String targetDate) throws Exception {
		CoviMap params = new CoviMap();
		params.put("TargetDate", targetDate);
		return coviMapperOne.selectOne("attend.common.getMonthlyMaxWorkTime", params);
	}

	public CoviMap getRewardTimeInfo(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("attend.common.getRewardTimeInfo", params);
	}
	@Override
	public CoviMap getDeptListJobType() throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String attendAuth = "";
		String jobType = getUserJobAuthType();
		returnObj.put("deptList", getSubDeptListByAuth(attendAuth,jobType));
		
		return returnObj;
	}
}
