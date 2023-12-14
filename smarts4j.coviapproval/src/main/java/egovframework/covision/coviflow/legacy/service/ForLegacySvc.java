package egovframework.covision.coviflow.legacy.service;

import java.util.List;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.web.multipart.MultipartFile;


import egovframework.baseframework.data.CoviMap;

public interface ForLegacySvc {
	public CoviMap getRuleApvLine(CoviMap params) throws Exception;
	public CoviMap getJobFunctionData(CoviMap params) throws Exception;
	public CoviMap goFormLink(CoviMap params) throws Exception;
	public CoviMap goFormLink_GWDB(CoviMap params) throws Exception;
	public CoviMap goFormLink_EXTDB(CoviMap params) throws Exception;
	
	public CoviMap draftForLegacy(CoviMap params, List<MultipartFile> mf) throws Exception;
	public CoviMap draftForLegacy(CoviMap formObj, CoviMap processFormDataReturn) throws Exception;
	public boolean isLegacyFormCheck(String legacyFormID) throws Exception;
	public boolean isLegacyFormCheck(String legacyFormID, String dn_code) throws Exception;
	public CoviMap makeFormObj(CoviMap params) throws Exception;
	public CoviMap getFormLegacyInfo(String processID) throws Exception;
	
	public String setFormLegacyLogin(HttpServletResponse response, HttpSession session, String legacyLogonID, String legacyDeptCode, boolean isMobile, String lang) throws Exception;
	public CoviMap checkAuthetication(String authType, String id, String password, String locale) throws Exception;
	public CoviMap checkAuthetication(String authType, String id, String password, String locale, String deptId) throws Exception;
	public String checkSSO(String OpType) throws Exception;
	public String selectUserMailAddress(String id) throws Exception;
	public boolean insertTokenHistory(String key, String urId, String urName, String urCode, String empNo, String maxAge, String type, String assertion_id) throws Exception;
	public void changeBodyContext(CoviMap params) throws Exception;
	
	public CoviMap selectDraftLegacySystemList(CoviMap params) throws Exception;
	public CoviMap selectDraftLegacySystemData(CoviMap params) throws Exception;
	public int insertDraftLegacySystemData(CoviMap params) throws Exception;
	public int updateDraftLegacySystemData(CoviMap params) throws Exception;
	public int deleteDraftLegacySystemData(CoviMap params) throws Exception;
	
	public CoviMap selectDraftLegacyList(CoviMap params) throws Exception;
	public CoviMap selectDraftSampleList(CoviMap params) throws Exception;
	
	CoviMap selectLogonID(String empno, String logonId) throws Exception;
	CoviMap selectLogonID(String userCode) throws Exception;
	CoviMap selectLogonIDByDept(String empno, String logonId, String deptId) throws Exception;
	CoviMap selectLogonIDByDept(String userCode, String deptId) throws Exception;
	
	public CoviMap getApvLineForDraft(CoviMap params) throws Exception;
}
