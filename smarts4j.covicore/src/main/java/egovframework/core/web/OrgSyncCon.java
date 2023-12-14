package egovframework.core.web;

import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.core.manage.service.OrganizationManageSvc;
import egovframework.core.sevice.OrgSyncManageSvc;
import egovframework.core.sevice.OrganizationADSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

/**
 * @Class Name : OrgSyncCon.java
 * @Description : 조직관리
 * @Modification Information 
 * @ 2016.05.03 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.07
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

//동기화 중지 Exception 클래스
//중단시점 line의 count가 필요한지 검토 부탁드립니다.
@SuppressWarnings("serial")
class stopException extends Exception {
	public stopException() {}
	public stopException(String msg) { super(msg); }
}
class OrgSyncConfig {
	public String syncMode="";
	public int SyncMasterID = 0;

	public boolean IsSyncDB;
	public boolean IsSyncIndi;
	public boolean IsSyncAD;
	public boolean IsSyncMail;
	public boolean IsSyncMessenger;

	public boolean IsDeptSync;
	public boolean IsJobLevelSync;
	public boolean IsJobTitleSync;
	public boolean IsJobPositionSync;
	public boolean IsUserSync;
	public boolean IsAddJobSync;

	public CoviMap configDeptSync;
	public CoviMap configJobLevelSync;
	public CoviMap configJobTitleSync;
	public CoviMap configJobPositionSync;
	public CoviMap configUserSync;
	public CoviMap configAddJobSync;
	
	public OrgSyncConfig() {
		this.IsSyncDB = true;
		this.IsSyncIndi = false;
		this.IsSyncAD = false;
		this.IsSyncMail = false;
		this.IsSyncMessenger = false;
		
		this.IsDeptSync = false;
		this.IsJobLevelSync = false;
		this.IsJobTitleSync = false;
		this.IsJobPositionSync = false;
		this.IsUserSync = false;
		this.IsAddJobSync = false;
		
		this.configDeptSync = new CoviMap();
		this.configDeptSync.put("all", true);
		this.configDeptSync.put("add", true);
		this.configDeptSync.put("delete", true);
		this.configDeptSync.put("modify", true);
		
		this.configJobLevelSync = new CoviMap();
		this.configJobLevelSync.put("all", true);
		this.configJobLevelSync.put("add", true);
		this.configJobLevelSync.put("delete", true);
		this.configJobLevelSync.put("modify", true);
		
		this.configJobTitleSync = new CoviMap();
		this.configJobTitleSync.put("all", true);
		this.configJobTitleSync.put("add", true);
		this.configJobTitleSync.put("delete", true);
		this.configJobTitleSync.put("modify", true);
		
		this.configJobPositionSync = new CoviMap();
		this.configJobPositionSync.put("all", true);
		this.configJobPositionSync.put("add", true);
		this.configJobPositionSync.put("delete", true);
		this.configJobPositionSync.put("modify", true);
		
		this.configUserSync = new CoviMap();
		this.configUserSync.put("all", true);
		this.configUserSync.put("add", true);
		this.configUserSync.put("delete", true);
		this.configUserSync.put("modify", true);
		
		this.configAddJobSync = new CoviMap();
		this.configAddJobSync.put("all", true);
		this.configAddJobSync.put("add", true);
		this.configAddJobSync.put("delete", true);
	}
}

@Controller
public class OrgSyncCon {	
	private Logger LOGGER = LogManager.getLogger(OrgSyncCon.class);
	
	@Autowired
	private OrgSyncManageSvc orgSyncManageSvc;

	@Autowired
	private OrganizationADSvc orgADSvc;
	@Autowired
	private OrganizationManageSvc OrganizationManageSvc;
	
	private final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	private final String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
	

	
	/*미사용
	@RequestMapping(value = "admin/orgmanage/orgSync.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap orgSync(@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		
		this.setConfigByBaseConfig();
		this.setConfigByRequest(paramMap);
		
		returnList.put("status", Return.SUCCESS);
		returnList.put("param", paramMap);
		returnList.put("IsSyncDB", IsSyncDB);
		returnList.put("IsSyncIndi", IsSyncIndi);
		returnList.put("IsSyncAD", IsSyncAD);
		returnList.put("IsSyncMail", IsSyncMail);
		returnList.put("IsSyncMessenger", IsSyncMessenger);
		returnList.put("IsDeptSync", IsDeptSync);
		returnList.put("IsJobLevelSync", IsJobLevelSync);
		returnList.put("IsJobTitleSync", IsJobTitleSync);
		returnList.put("IsJobPositionSync", IsJobPositionSync);
		returnList.put("IsUserSync", IsUserSync);
		returnList.put("IsAddJobSync", IsAddJobSync);
		returnList.put("configDeptSync", configDeptSync);
		returnList.put("configJobLevelSync", configJobLevelSync);
		returnList.put("configJobTitleSync", configJobTitleSync);
		returnList.put("configJobPositionSync", configJobPositionSync);
		returnList.put("configUserSync", configUserSync);
		returnList.put("configAddJobSync", configAddJobSync);
		
		return returnList;
	}*/
	
	@SuppressWarnings("unchecked")
	private void setConfigByRequest(Map<String, String> paramMap,OrgSyncConfig orgSyncConfig) {
		orgSyncConfig.IsSyncDB = "Y".equals(paramMap.get("IsSyncDB")) ? true : false;
		orgSyncConfig.IsSyncIndi = "Y".equals(paramMap.get("IsSyncIndi")) ? true : false;
		orgSyncConfig.IsSyncAD = "Y".equals(paramMap.get("IsSyncAD")) ? true : false;
		orgSyncConfig.IsSyncMail = "Y".equals(paramMap.get("IsSyncMail")) ? true : false;
		orgSyncConfig.IsSyncMessenger = "Y".equals(paramMap.get("IsSyncMessenger")) ? true : false;
		
		String opers = paramMap.get("sChkBoxConfig");
		orgSyncConfig.IsDeptSync = (opers.indexOf("Dept") > 0) ? true : false;
		orgSyncConfig.IsJobLevelSync = (opers.indexOf("JobLevel") > 0) ? true : false;
		orgSyncConfig.IsJobTitleSync = (opers.indexOf("JobTitle") > 0) ? true : false;
		orgSyncConfig.IsJobPositionSync = (opers.indexOf("JobPosition") > 0) ? true : false;
		orgSyncConfig.IsUserSync = (opers.indexOf("User") > 0) ? true : false;
		orgSyncConfig.IsAddJobSync = (opers.indexOf("AddJob") > 0) ? true : false;
		
		orgSyncConfig.configDeptSync.replace("add", (opers.contains("chkDeptAdd")) ? true : false);
		orgSyncConfig.configDeptSync.replace("modify", (opers.contains("chkDeptMod")) ? true : false);
		orgSyncConfig.configDeptSync.replace("delete", (opers.contains("chkDeptDel")) ? true : false);
		orgSyncConfig.configDeptSync.replace("all", (!opers.contains("chkDeptAdd") && !opers.contains("chkDeptMod") && !opers.contains("chkDeptDel")) ? false : true);
		
		orgSyncConfig.configJobLevelSync.replace("add", (opers.contains("chkJobLevelAdd")) ? true : false);
		orgSyncConfig.configJobLevelSync.replace("modify", (opers.contains("chkJobLevelMod")) ? true : false);
		orgSyncConfig.configJobLevelSync.replace("delete", (opers.contains("chkJobLevelDel")) ? true : false);
		orgSyncConfig.configJobLevelSync.replace("all", (!opers.contains("chkJobLevelAdd") && !opers.contains("chkJobLevelMod") && !opers.contains("chkJobLevelDel")) ? false : true);

		orgSyncConfig.configJobTitleSync.replace("add", (opers.contains("chkJobTitleAdd")) ? true : false);
		orgSyncConfig.configJobTitleSync.replace("modify", (opers.contains("chkJobTitleMod")) ? true : false);
		orgSyncConfig.configJobTitleSync.replace("delete", (opers.contains("chkJobTitleDel")) ? true : false);
		orgSyncConfig.configJobTitleSync.replace("all", (!opers.contains("chkJobTitleAdd") && !opers.contains("chkJobTitleMod") && !opers.contains("chkJobTitleDel")) ? false : true);

		orgSyncConfig.configJobPositionSync.replace("add", (opers.contains("chkJobPositionAdd")) ? true : false);
		orgSyncConfig.configJobPositionSync.replace("modify", (opers.contains("chkJobPositionMod")) ? true : false);
		orgSyncConfig.configJobPositionSync.replace("delete", (opers.contains("chkJobPositionDel")) ? true : false);
		orgSyncConfig.configJobPositionSync.replace("all", (!opers.contains("chkJobPositionAdd") && !opers.contains("chkJobPositionMod") && !opers.contains("chkJobPositionDel")) ? false : true);

		orgSyncConfig.configUserSync.replace("add", (opers.contains("chkUserAdd")) ? true : false);
		orgSyncConfig.configUserSync.replace("modify", (opers.contains("chkUserMod")) ? true : false);
		orgSyncConfig.configUserSync.replace("delete", (opers.contains("chkUserDel")) ? true : false);
		orgSyncConfig.configUserSync.replace("all", (!opers.contains("chkUserAdd") && !opers.contains("chkUserMod") && !opers.contains("chkUserDel")) ? false : true);

		orgSyncConfig.configAddJobSync.replace("add", (opers.contains("chkAddJobAdd")) ? true : false);
		orgSyncConfig.configAddJobSync.replace("delete", (opers.contains("chkAddJobDel")) ? true : false);
		orgSyncConfig.configAddJobSync.replace("all", (!opers.contains("chkAddJobAdd") && !opers.contains("chkAddJobMod") && !opers.contains("chkAddJobDel")) ? false : true);
	}
	
	@SuppressWarnings("unchecked")
	private void setConfigByBaseConfig(OrgSyncConfig orgSyncConfig) {
		CoviMap configMap = new CoviMap();
		try {
			configMap = orgSyncManageSvc.getIsSyncList();
			 
			orgSyncConfig.IsSyncDB = "Y".equals(configMap.get("IsSyncDB")) ? true : false;
			orgSyncConfig.IsSyncIndi = "Y".equals(configMap.get("IsSyncIndi")) ? true : false;
			orgSyncConfig.IsSyncAD = "Y".equals(configMap.get("IsSyncAD")) ? true : false;
			orgSyncConfig.IsSyncMail = "Y".equals(configMap.get("IsSyncMail")) ? true : false;
			orgSyncConfig.IsSyncMessenger = "Y".equals(configMap.get("IsSyncMessenger")) ? true : false;
			orgSyncConfig.IsDeptSync = "Y".equals(configMap.get("IsDeptSync")) ? true : false;
			orgSyncConfig.IsJobLevelSync = "Y".equals(configMap.get("IsJobLevelSync")) ? true : false;
			orgSyncConfig.IsJobTitleSync = "Y".equals(configMap.get("IsJobTitleSync")) ? true : false;
			orgSyncConfig.IsJobPositionSync = "Y".equals(configMap.get("IsJobPositionSync")) ? true : false;
			orgSyncConfig.IsUserSync = "Y".equals(configMap.get("IsUserSync")) ? true : false;
			orgSyncConfig.IsAddJobSync = "Y".equals(configMap.get("IsAddJobSync")) ? true : false;
			
			orgSyncConfig.configDeptSync.replace("add", (orgSyncConfig.IsDeptSync) ? true : false);
			orgSyncConfig.configDeptSync.replace("modify", (orgSyncConfig.IsDeptSync) ? true : false);
			orgSyncConfig.configDeptSync.replace("delete", (orgSyncConfig.IsDeptSync) ? true : false);
			orgSyncConfig.configDeptSync.replace("all", (orgSyncConfig.IsDeptSync) ? true : false);
			
			orgSyncConfig.configJobLevelSync.replace("add", (orgSyncConfig.IsJobLevelSync) ? true : false);
			orgSyncConfig.configJobLevelSync.replace("modify", (orgSyncConfig.IsJobLevelSync) ? true : false);
			orgSyncConfig.configJobLevelSync.replace("delete", (orgSyncConfig.IsJobLevelSync) ? true : false);
			orgSyncConfig.configJobLevelSync.replace("all", (orgSyncConfig.IsJobLevelSync) ? true : false);
			
			orgSyncConfig.configJobTitleSync.replace("add", (orgSyncConfig.IsJobTitleSync) ? true : false);
			orgSyncConfig.configJobTitleSync.replace("modify", (orgSyncConfig.IsJobTitleSync) ? true : false);
			orgSyncConfig.configJobTitleSync.replace("delete", (orgSyncConfig.IsJobTitleSync) ? true : false);
			orgSyncConfig.configJobTitleSync.replace("all", (orgSyncConfig.IsJobTitleSync) ? true : false);
			
			orgSyncConfig.configJobPositionSync.replace("add", (orgSyncConfig.IsJobPositionSync) ? true : false);
			orgSyncConfig.configJobPositionSync.replace("modify", (orgSyncConfig.IsJobPositionSync) ? true : false);
			orgSyncConfig.configJobPositionSync.replace("delete", (orgSyncConfig.IsJobPositionSync) ? true : false);
			orgSyncConfig.configJobPositionSync.replace("all", (orgSyncConfig.IsJobPositionSync) ? true : false);
			
			orgSyncConfig.configUserSync.replace("add", (orgSyncConfig.IsUserSync) ? true : false);
			orgSyncConfig.configUserSync.replace("modify", (orgSyncConfig.IsUserSync) ? true : false);
			orgSyncConfig.configUserSync.replace("delete", (orgSyncConfig.IsUserSync) ? true : false);
			orgSyncConfig.configUserSync.replace("all", (orgSyncConfig.IsUserSync) ? true : false);
			
			orgSyncConfig.configAddJobSync.replace("add", (orgSyncConfig.IsAddJobSync) ? true : false);
			orgSyncConfig.configAddJobSync.replace("delete", (orgSyncConfig.IsAddJobSync) ? true : false);
			orgSyncConfig.configAddJobSync.replace("all", (orgSyncConfig.IsAddJobSync) ? true : false);
		} catch (NullPointerException e) {
			LOGGER.error("Fail to set sync orgSyncConfig... [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			LOGGER.error("Fail to set sync orgSyncConfig... [" + e.getMessage() + "]", e);
		}
		
	}
	
	/**
	 * organizationSynchronize : 전체 동기화
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/organizationsynchronize.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap organizationSynchronize(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap tempList = new CoviMap();

			LOGGER.debug("Start OrganizationSynchronize execute");
			orgSyncManageSvc.insertLogList();
			
			tempList = this.createSyncData(null, null, paramMap);
			if(tempList.get("status").toString().equals("SUCCESS")) {
				returnList = this.synchronize(null, null, paramMap);
			} 
			else {
				LOGGER.debug("Start OrganizationSynchronize Failed");
			}
		}  
		catch (NullPointerException e) {
			LOGGER.error("Start OrganizationSynchronize Failed [" + e.getMessage() + "]", e);
		}
		catch (Exception e) {
			LOGGER.error("Start OrganizationSynchronize Failed [" + e.getMessage() + "]", e);
		} 
		finally {
			orgSyncManageSvc.updateSyncProgress("N");
		}
		return returnList;
	}
	
	/**
	 * stopSync : 동기화 일시중지 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/stopSync.do", method = {RequestMethod.GET, RequestMethod.POST})
	public @ResponseBody CoviMap stopSync(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		SessionHelper.setSession("isStopped", "Y");
		
		String isStopped = SessionHelper.getSession("isStopped");
		LOGGER.debug("{\"isStopped\":\"" + isStopped + "\"}");

		try {
			LOGGER.debug("StopSynchronized execute");
			throw new stopException("동기화 중지");
		} catch (NullPointerException e) {
			LOGGER.error("StopSynchronized Failed [" + e.getMessage() + "]", e);
		} catch (Exception e) {
			LOGGER.error("StopSynchronized Failed [" + e.getMessage() + "]", e);
		} finally {
			
		}
		return null;
	}
	
	/**
	 * createSyncData  인사데이터를 가져온 후 동기화 설정에 따라 현재 조직도 정보와 비교하여 동기화 대상을 생성한다. 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/createsyncdata.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap createSyncData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			LOGGER.debug("createSyncData execute");
			returnList.put("status", Return.SUCCESS);

			CoviMap tempList = new CoviMap();
			CoviMap compareList = new CoviMap();
			
			orgSyncManageSvc.insertLogList();
			
			 
			
			try{
				tempList = orgSyncManageSvc.syncTempObject();		
			}catch(NullPointerException ex){
				LOGGER.error("syncTempObject Failed [" + ex.getMessage() + "]", ex);
				returnList.put("status", Return.FAIL);
				returnList.put("message", "syncTempObject : "+(isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030")));
				return returnList;
			}catch(Exception ex){
				LOGGER.error("syncTempObject Failed [" + ex.getMessage() + "]", ex);
				returnList.put("status", Return.FAIL);
				returnList.put("message", "syncTempObject : "+(isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030")));
				return returnList;
			}
			try{
				compareList = orgSyncManageSvc.syncCompareObject();
			}catch(NullPointerException ex){
				LOGGER.error("syncCompareObject Failed [" + ex.getMessage() + "]", ex);
				returnList.put("status", Return.FAIL);
				returnList.put("message", "syncCompareObject : "+(isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030")));
				return returnList;
			}catch(Exception ex){
				LOGGER.error("syncCompareObject Failed [" + ex.getMessage() + "]", ex);
				returnList.put("status", Return.FAIL);
				returnList.put("message", "syncCompareObject : "+(isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030")));
				return returnList;
			}
			returnList.put("tempList", tempList);
			returnList.put("compareList", compareList);
			
			LOGGER.debug("createSyncData execute complete");
			if ("Y".equals(paramMap.get("Web"))) {
				orgSyncManageSvc.updateLogList();
			}
		}
		catch (NullPointerException ex) {
			LOGGER.error("createSyncData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception ex) {
			LOGGER.error("createSyncData Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * synchronize : 조직데이터 동기화 (스케줄러)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/synchronize.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap synchronize(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			boolean bIsSyncProgress = orgSyncManageSvc.isSyncProgress();
			
			if(bIsSyncProgress) {
				orgSyncManageSvc.updateSyncProgress("Y");
				OrgSyncConfig orgSyncConfig  = new OrgSyncConfig();
				orgSyncConfig.syncMode = "S";
				this.setConfigByBaseConfig(orgSyncConfig);
				
				returnList.put("isStopped", SessionHelper.getSession("isStopped"));
				
				//전체 퇴사 방지
				int cntRetire = orgSyncManageSvc.checkRetireCount();
				
				if(cntRetire < Integer.parseInt(RedisDataUtil.getBaseConfig("MaxRetireCount"))) {
					LOGGER.debug("start synchronize...");
					
					sync(orgSyncConfig);
					
					returnList.put("status", Return.SUCCESS);
					returnList.put("isStopped", SessionHelper.getSession("isStopped"));
					
					LOGGER.debug("complete synchronize...");		
					
					orgSyncManageSvc.insertDeptScheduleInfo();
				}
				else {
					returnList.put("status", Return.FAIL);
					LOGGER.error("Unable to sink! Retire List User Count : " + cntRetire);
					throw new Exception("Unable to sink! Retire List User Count : " + cntRetire);
				}
			}
			else {
				LOGGER.error("OrganizationSynchronization is already in progress");
				throw new Exception("OrganizationSynchronization is already in progress");
			}
			
		}
		catch (NullPointerException ex) {
			LOGGER.error("startSynchronize Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception ex) {
			LOGGER.error("startSynchronize Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030"));
		} 
		finally {
			orgSyncManageSvc.updateSyncProgress("N");
		}
		return returnList;
	}
	
	/**
	 * synchronizeByweb : 조직데이터 동기화 (웹)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/synchronizeByweb.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap synchronizeByweb(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String sMessage = "";
		
		try {
			boolean bIsSyncProgress = orgSyncManageSvc.isSyncProgress();
			
			if(bIsSyncProgress) {
				orgSyncManageSvc.updateSyncProgress("Y");
				OrgSyncConfig orgSyncConfig  = new OrgSyncConfig();
				orgSyncConfig.syncMode = "W";
				this.setConfigByBaseConfig(orgSyncConfig);
				this.setConfigByRequest(paramMap,orgSyncConfig);
				
				returnList.put("isStopped", SessionHelper.getSession("isStopped"));
				
				//전체 퇴사 방지
				int cntRetire = orgSyncManageSvc.checkRetireCount();
				
				if (cntRetire < Integer.parseInt(RedisDataUtil.getBaseConfig("MaxRetireCount"))) {

					sync(orgSyncConfig);

					returnList.put("status", Return.SUCCESS);
					returnList.put("isStopped", SessionHelper.getSession("isStopped"));
					
					orgSyncManageSvc.insertDeptScheduleInfo();
				} 
				else {
					returnList.put("status", Return.FAIL);
					sMessage = "Unable to sink! Retire List User Count : " + cntRetire;
					LOGGER.error(sMessage);
					throw new Exception(sMessage);
				}
				
			} else {
				sMessage = "OrganizationSynchronization is already in progress";
				LOGGER.error(sMessage);
				throw new Exception(sMessage);
			}
			
		}
		catch (NullPointerException ex) {
			LOGGER.error("startSynchronize Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? sMessage : DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception ex) {
			LOGGER.error("startSynchronize Failed [" + ex.getMessage() + "]", ex);
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? sMessage : DicHelper.getDic("msg_apv_030"));
		}
		finally {
			orgSyncManageSvc.updateSyncProgress("N");
		}
		
		return returnList;
	}
	
	/**
	 * MoniterSyncStatus : 동기화 진행상태 조회 (웹)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "admin/orgmanage/MoniterSyncStatus.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap moniterSyncStatus(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap params = new CoviMap();
		params.putAll(paramMap);
		
		CoviMap listData = null;
		listData = orgSyncManageSvc.selectMoniterCompareCount(params);
		
		CoviMap returnObj = new CoviMap(); 
		returnObj.put("SyncMasterID", listData.get("SyncMasterID").toString());
		returnObj.put("GR_Cnt", listData.get("GR_Cnt").toString());
		returnObj.put("UR_Cnt", listData.get("UR_Cnt").toString());
		returnObj.put("Add_Cnt", listData.get("Add_Cnt").toString());
		returnObj.put("result", "ok");
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	/**
	 * @description 공통 동기화 모듈
	 * @param params 
	 * @return void
	 * @throws Exception
	 */
	public void sync(OrgSyncConfig orgSyncConfig) throws Exception {
		CoviMap params = new CoviMap();
		
		params.put("IsSyncDB", orgSyncConfig.IsSyncDB);
		params.put("IsSyncIndi", orgSyncConfig.IsSyncIndi);
		params.put("IsSyncAD", orgSyncConfig.IsSyncAD);
		params.put("IsSyncMail", orgSyncConfig.IsSyncMail);
		params.put("IsSyncMessenger", orgSyncConfig.IsSyncMessenger);
		params.put("IsDeptSync", orgSyncConfig.IsDeptSync);
		params.put("IsJobLevelSync", orgSyncConfig.IsJobLevelSync);
		params.put("IsJobTitleSync", orgSyncConfig.IsJobTitleSync);
		params.put("IsJobPositionSync", orgSyncConfig.IsJobPositionSync);
		params.put("IsUserSync", orgSyncConfig.IsUserSync);
		params.put("IsAddJobSync", orgSyncConfig.IsAddJobSync);
		
		params.put("AD_ISUSE", orgSyncConfig.IsSyncAD);
		params.put("EX_ISUSE", orgSyncConfig.IsSyncMail);
		params.put("MSN_ISUSE", orgSyncConfig.IsSyncMessenger);
		
		LOGGER.info("startSync execute");
		
		//로그 추가
		if (orgSyncConfig.SyncMasterID == 0) orgSyncConfig.SyncMasterID = orgSyncManageSvc.insertLogList();
		orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID,"Start",("W".equals(orgSyncConfig.syncMode)) ? "관리자 화면" : "스케줄러","",
			"[조직도 동기화 실행] 시작<br>" + toString()
		,"");
		
		if((boolean) orgSyncConfig.configJobTitleSync.get("add")) 
			syncGroup("JOBTITLE", "INSERT",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configJobTitleSync.get("modify")) 
			syncGroup("JOBTITLE", "UPDATE",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configJobPositionSync.get("add")) 
			syncGroup("JOBPOSITION", "INSERT",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configJobPositionSync.get("modify")) 
			syncGroup("JOBPOSITION", "UPDATE",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configJobLevelSync.get("add")) 
			syncGroup("JOBLEVEL", "INSERT",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configJobLevelSync.get("modify")) 
			syncGroup("JOBLEVEL", "UPDATE",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configDeptSync.get("add")) 
			syncGroup("DEPT", "INSERT",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configDeptSync.get("modify")) 
			syncGroup("DEPT", "UPDATE",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configUserSync.get("add")) 
			syncUser("INSERT",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configUserSync.get("modify")) 
			syncUser("UPDATE",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configAddJobSync.get("add")) 
			syncAddjob("INSERT",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configAddJobSync.get("delete")) 
			syncAddjob("DELETE",orgSyncConfig);
			
		if((boolean) orgSyncConfig.configUserSync.get("delete")) 
			syncUser("DELETE",orgSyncConfig);

		if((boolean) orgSyncConfig.configDeptSync.get("delete")) 
			syncGroup("DEPT", "DELETE",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configJobLevelSync.get("delete")) 
			syncGroup("JOBLEVEL", "DELETE",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configJobPositionSync.get("delete")) 
			syncGroup("JOBPOSITION", "DELETE",orgSyncConfig);
		
		if((boolean) orgSyncConfig.configJobTitleSync.get("delete")) 
			syncGroup("JOBTITLE", "DELETE",orgSyncConfig);
	
			
		if(orgSyncConfig.IsSyncDB && RedisDataUtil.getBaseConfig("IsRebuildDeptPath").equals("Y")) {
			if((boolean) orgSyncConfig.configDeptSync.get("add") || (boolean) orgSyncConfig.configDeptSync.get("modify") || (boolean) orgSyncConfig.configDeptSync.get("delete")) {
				orgSyncManageSvc.updateDeptPathInfoAll();
			}
		}
		
		LOGGER.info("startSync execute complete");
		orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID,"End",("W".equals(orgSyncConfig.syncMode)) ? "관리자 화면" : "스케줄러","","[조직도 동기화 실행] 종료","");
		orgSyncManageSvc.updateLogList();
		orgSyncConfig.SyncMasterID = 0;
	}
	
	/**
	 * @description group 동기화
	 * @param params 
	 * @return void
	 * @throws Exception
	 */
	public void syncGroup(String sObjectType, String sSyncType,OrgSyncConfig orgSyncConfig) throws Exception {
		LOGGER.info("syncGroup execute [ObjectType : "+ sObjectType + " / SyncType : " + sSyncType + "]");
		
		CoviMap param = new CoviMap();
		String isStopped = "";
		
		String strLog = "";
		if ("DEPT".equals(sObjectType)) strLog = "부서 ";
		else if ("JOBLEVEL".equals(sObjectType)) strLog = "직급 ";
		else if ("JOBPOSITION".equals(sObjectType)) strLog = "직위 ";
		else if ("JOBTITLE".equals(sObjectType)) strLog = "직책 ";
		if ("INSERT".equals(sSyncType)) strLog += "추가 시작";
		else if ("UPDATE".equals(sSyncType)) strLog += "수정 시작";
		else if ("DELETE".equals(sSyncType)) strLog += "삭제 시작";
		strLog += "----------------------------------------------------------------";
		orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID, "Info", sObjectType, "", strLog,"");
		
		param.put("GroupType", sObjectType);
		param.put("SyncType", sSyncType);
		
 		CoviList groupList = new CoviList();
		groupList = (CoviList) orgSyncManageSvc.selectCompareObjectGroupList(param).get("list");
		
		//Sync execution		 
		for(Object group : groupList) {		
			isStopped = SessionHelper.getSession("isStopped");
			if(isStopped.equals("Y")) {
				orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID,"Stop","관리자 화면","","동기화 중지","");
				SessionHelper.setSession("isStopped", "N");
				throw new stopException("동기화 중지");
			}
			
			CoviMap groupParams = new CoviMap();
			CoviMap groupObj = new CoviMap();
			groupObj = (CoviMap) group;
			
			//	GroupPath, SortPath, OUPath Create
			String[] resultString = orgSyncManageSvc.getGroupPath(groupObj.get("CompanyCode").toString(), groupObj.get("MemberOf").toString()).split("&");
			
			String strGroupPath = "";
			String strSortPath = "";
			String strOUPath = "";
			
			if("UPDATE".equals(sSyncType)) {
				if(resultString.length > 0 && (resultString[1].isEmpty()!=true) && (resultString[2].isEmpty()!=true)) {
					strGroupPath = resultString[0] + groupObj.get("GroupCode") + ";";
					strSortPath = resultString[1] + String.format("%015d", Integer.parseInt((String) groupObj.get("SortKey"))) + ";";
					strOUPath = resultString[2] + groupObj.get("OUName") + ";";
				}
			}
			
			//hash-map for sys_object insert
			groupParams.put("ObjectCode", groupObj.get("GroupCode"));
			groupParams.put("ObjectType", "GR");
			groupParams.put("SyncMasterID", orgSyncConfig.SyncMasterID);
			groupParams.put("SyncManage", "Sync");
			groupParams.put("IsSync", "Y");
			//hash-map for sys_object_group insert
			groupParams.put("SyncType", groupObj.get("SyncType"));
			groupParams.put("GroupCode", groupObj.get("GroupCode"));
			groupParams.put("CompanyCode", groupObj.get("CompanyCode"));
			groupParams.put("GroupType", groupObj.get("GroupType"));
			groupParams.put("MemberOf", groupObj.get("MemberOf"));
			groupParams.put("GroupPath", groupObj.get("GroupPath") == null || groupObj.get("GroupPath").equals("") ? strGroupPath : groupObj.get("GroupPath")); 
			groupParams.put("RegionCode", groupObj.get("RegionCode"));
			groupParams.put("DisplayName", groupObj.get("DisplayName"));
			groupParams.put("MultiDisplayName", groupObj.get("MultiDisplayName"));
			groupParams.put("ShortName", groupObj.get("ShortName"));
			groupParams.put("MultiShortName", groupObj.get("MultiShortName"));
			groupParams.put("OUName", groupObj.get("OUName"));
			groupParams.put("OUPath", groupObj.get("OUPath") == null  || groupObj.get("OUPath").equals("") ? strOUPath : groupObj.get("OUPath"));
			groupParams.put("SortKey", groupObj.get("SortKey"));
			groupParams.put("SortPath", groupObj.get("SortPath") == null || groupObj.get("SortPath").equals("") ? strSortPath : groupObj.get("SortPath"));
			groupParams.put("IsUse", groupObj.get("IsUse"));
			groupParams.put("IsDisplay", groupObj.get("IsDisplay"));
			groupParams.put("IsMail", groupObj.get("IsMail"));
			groupParams.put("IsHR", groupObj.get("IsHR"));
			groupParams.put("PrimaryMail", groupObj.get("PrimaryMail"));			
			groupParams.put("SecondaryMail", groupObj.get("SecondaryMail"));
			groupParams.put("ManagerCode", groupObj.get("ManagerCode"));
			groupParams.put("Description", groupObj.get("Description"));
			groupParams.put("ReceiptUnitCode", groupObj.get("ReceiptUnitCode"));
			groupParams.put("ApprovalUnitCode", groupObj.get("ApprovalUnitCode"));
			groupParams.put("Receivable", groupObj.get("Receivable"));
			groupParams.put("Approvable", groupObj.get("Approvable"));
			groupParams.put("Reserved1", groupObj.get("Reserved1"));
			groupParams.put("Reserved2", groupObj.get("Reserved2"));
			groupParams.put("Reserved3", groupObj.get("Reserved3"));
			groupParams.put("Reserved4", groupObj.get("Reserved4"));
			groupParams.put("Reserved5", groupObj.get("Reserved5"));
			
			//Old Data
			CoviList arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(groupParams).get("list");
			String sOUPath_Temp = "";
			String sCompanyName_Temp = "";
			if(!arrGroupList.isEmpty()) {
				sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
				sCompanyName_Temp = arrGroupList.getJSONObject(0).getString("CompanyName").split(";")[0];				
			}
			
			switch(groupObj.get("SyncType").toString().toUpperCase())
			{
				case "INSERT":
					LOGGER.info("Start Group [INSERT] Sync");
					if(orgSyncConfig.IsSyncDB) {
						orgSyncManageSvc.insertGroup(groupParams);
						
						if(sObjectType.equalsIgnoreCase("DEPT")) {
							if(RedisDataUtil.getBaseConfig("DeptScheuleAutoCreation").equals("Y")) {
								groupParams.put("FolderType", "Schedule");
								groupParams.put("OwnerCode", groupObj.get("ManagerCode") != null && !groupObj.get("ManagerCode").equals("") ? groupObj.get("ManagerCode") : "superadmin");
								groupParams.put("CreateYN", "N");
								
								orgSyncManageSvc.insertDeptScheduleCreation(groupParams);
							}
						}
					}
					if(orgSyncConfig.IsSyncAD) {
						//각각 AD Sync true 인 경우에만
						if((orgSyncConfig.IsDeptSync && sObjectType.equalsIgnoreCase("DEPT")) 
								|| (orgSyncConfig.IsJobPositionSync && sObjectType.equalsIgnoreCase("JOBPOSITION"))
								|| (orgSyncConfig.IsJobLevelSync && sObjectType.equalsIgnoreCase("JOBLEVEL"))
								|| (orgSyncConfig.IsJobTitleSync && sObjectType.equalsIgnoreCase("JOBTITLE"))) {
							groupParams.put("gr_code", groupObj.get("GroupCode"));
							
							//JSONObject resultList = orgADSvc.adAddDept(strGroupCode,strDisplayName,sCompanyName_Temp,strMemberOf,strOUName,sOUPath_Temp,strPrimaryMail);
							CoviMap resultList = orgADSvc.adAddDept(groupParams.get("GroupCode").toString(), groupParams.get("DisplayName").toString(), sCompanyName_Temp, 
									groupParams.get("MemberOf").toString(), groupParams.get("OUName").toString(), sOUPath_Temp, groupParams.get("PrimaryMail").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								LOGGER.error("[AD Sync add] " + groupParams.get("GroupCode").toString() + " : " + resultList.getString("Reason"));
								throw new Exception();
							}
						}
					}
					if(orgSyncConfig.IsSyncMail) {
						//각각 AD Sync true 인 경우에만
						if((orgSyncConfig.IsDeptSync && sObjectType.equalsIgnoreCase("DEPT")) 
								|| (orgSyncConfig.IsJobPositionSync && sObjectType.equalsIgnoreCase("JOBPOSITION"))
								|| (orgSyncConfig.IsJobLevelSync && sObjectType.equalsIgnoreCase("JOBLEVEL"))
								|| (orgSyncConfig.IsJobTitleSync && sObjectType.equalsIgnoreCase("JOBTITLE"))) {
							if(groupObj.get("IsMail").toString().equalsIgnoreCase("Y") && !groupObj.get("PrimaryMail").toString().equals("")) {
								CoviMap resultList = new CoviMap();
								resultList = orgADSvc.exchEnableGroup(groupParams.get("GroupCode").toString(), groupParams.get("PrimaryMail").toString(), groupParams.get("SecondaryMail").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
								
								if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
									LOGGER.error("[Exch Sync add] " + groupParams.get("GroupCode").toString() + " : " + resultList.getString("Reason"));
									throw new Exception();
								}
							}
						}
					}
					if(orgSyncConfig.IsSyncIndi && groupObj.get("IsMail").toString().equalsIgnoreCase("Y") && !groupObj.get("PrimaryMail").toString().equals("")) {
						orgSyncManageSvc.addGroup(groupParams);
					}
					break;
				case "UPDATE":
					LOGGER.info("Start Group [UPDATE] Sync");
					if(orgSyncConfig.IsSyncDB) {
						orgSyncManageSvc.updateGroup(groupParams);
						if(sObjectType.equalsIgnoreCase("DEPT")) {
							if(RedisDataUtil.getBaseConfig("DeptScheuleAutoCreation").equals("H")) {
								groupParams.put("FolderType", "Schedule");
								groupParams.put("OwnerCode", !groupObj.get("ManagerCode").equals("") && groupObj.get("ManagerCode") != null ? groupObj.get("ManagerCode") : "superadmin");
								groupParams.put("CreateYN", "N");
								
								orgSyncManageSvc.insertDeptScheduleCreation(groupParams);
							} else if(RedisDataUtil.getBaseConfig("DeptScheuleAutoCreation").equals("Y")) {
								orgSyncManageSvc.updateDeptScheduleInfo(groupParams);
							}
						}
					}
					if(orgSyncConfig.IsSyncAD) {
						//각각 AD Sync true 인 경우에만
						if((orgSyncConfig.IsDeptSync && sObjectType.equalsIgnoreCase("DEPT")) 
								|| (orgSyncConfig.IsJobPositionSync && sObjectType.equalsIgnoreCase("JOBPOSITION"))
								|| (orgSyncConfig.IsJobLevelSync && sObjectType.equalsIgnoreCase("JOBLEVEL"))
								|| (orgSyncConfig.IsJobTitleSync && sObjectType.equalsIgnoreCase("JOBTITLE"))) {
							groupParams.put("gr_code", groupObj.get("GroupCode"));
							CoviMap resultList = new CoviMap();
							
							if(groupObj.get("IsUse").equals("Y")) {
								resultList = orgADSvc.adModifyDept(groupParams.get("GroupCode").toString(), groupParams.get("DisplayName").toString(), sCompanyName_Temp, groupParams.get("MemberOf").toString(), groupParams.get("OUName").toString(), strOUPath, sOUPath_Temp, groupParams.get("PrimaryMail").toString(), "Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							} else if(groupObj.get("IsUse").equals("N") && !groupObj.get("IsUse").equals(arrGroupList.getJSONObject(0).getString("IsUse"))) {
								resultList = orgADSvc.adDeleteDept(groupParams.get("GroupCode").toString(), groupParams.get("DisplayName").toString(), sCompanyName_Temp, groupParams.get("OUName").toString(), sOUPath_Temp, "Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							}
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								LOGGER.error("[AD Sync update] " + groupParams.get("GroupCode").toString() + " : " + resultList.getString("Reason"));
								throw new Exception();
							}
						}
					}
					if(orgSyncConfig.IsSyncMail) {
						//각각 AD Sync true 인 경우에만
						if((orgSyncConfig.IsDeptSync && sObjectType.equalsIgnoreCase("DEPT")) 
								|| (orgSyncConfig.IsJobPositionSync && sObjectType.equalsIgnoreCase("JOBPOSITION"))
								|| (orgSyncConfig.IsJobLevelSync && sObjectType.equalsIgnoreCase("JOBLEVEL"))
								|| (orgSyncConfig.IsJobTitleSync && sObjectType.equalsIgnoreCase("JOBTITLE"))) {
							CoviMap resultList = new CoviMap();
							
							if(groupObj.get("IsMail").toString().equals("Y") && !groupObj.get("PrimaryMail").toString().equals("")){
								resultList = orgADSvc.exchEnableGroup(groupParams.get("GroupCode").toString(), groupParams.get("PrimaryMail").toString(), groupParams.get("SecondaryMail").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							}else if(!groupObj.get("IsMail").toString().equals("Y")){
								resultList = orgADSvc.exchDisableGroup(groupParams.get("GroupCode").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							}
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								LOGGER.error("[Exch Sync update] " + groupParams.get("GroupCode").toString() + " : " + resultList.getString("Reason"));
								throw new Exception();
							}
						}
					}
					if(orgSyncConfig.IsSyncIndi && !groupObj.get("PrimaryMail").toString().equals("")) {
						if(groupObj.get("IsMail").toString().equalsIgnoreCase("Y")) {
							groupParams.put("GroupStatus","A");
						} else {
							groupParams.put("GroupStatus","S");
						}
						orgSyncManageSvc.modifyGroup(groupParams);						
					}
					break;
				case "DELETE":
					LOGGER.info("Start Group [DELETE] Sync");
					if(orgSyncConfig.IsSyncDB) {
						orgSyncManageSvc.deleteGroup(groupParams);												
					}
					if(orgSyncConfig.IsSyncAD) {
						//각각 AD Sync true 인 경우에만
						if((orgSyncConfig.IsDeptSync && sObjectType.equalsIgnoreCase("DEPT")) 
								|| (orgSyncConfig.IsJobPositionSync && sObjectType.equalsIgnoreCase("JOBPOSITION"))
								|| (orgSyncConfig.IsJobLevelSync && sObjectType.equalsIgnoreCase("JOBLEVEL"))
								|| (orgSyncConfig.IsJobTitleSync && sObjectType.equalsIgnoreCase("JOBTITLE"))) {
							groupParams.put("gr_code", groupObj.get("GroupCode"));
							CoviMap resultList = orgADSvc.adDeleteDept(groupParams.get("GroupCode").toString(), groupParams.get("DisplayName").toString(), sCompanyName_Temp, groupParams.get("OUName").toString(), groupParams.get("OUPath").toString(), "Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								LOGGER.error("[AD Sync delete] " + groupParams.get("GroupCode").toString() + " : " + resultList.getString("Reason"));
								throw new Exception();
							}
						}
					}
					if(orgSyncConfig.IsSyncIndi && groupObj.get("IsMail").toString().equalsIgnoreCase("Y") && !groupObj.get("PrimaryMail").toString().equals("")) {
						groupParams.put("GroupStatus","S");
						orgSyncManageSvc.modifyGroup(groupParams);						
					}
					break;
				default :
					break;
			}
			//compare 테이블에서 삭제
			groupParams.put("DataType", "Group");
			orgSyncManageSvc.deleteCompareObjectOne(groupParams);
		}
		
		SessionHelper.setSession("isStopped", "N");
		LOGGER.info("syncGroup execute [ObjectType : "+ sObjectType + " / SyncType : " + sSyncType + "] complete");
			
		orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID, "Info", sObjectType, "", strLog.replace("시작", "종료"), "");
	}
	
	/**
	 * @description 사용자 동기화
	 * @param params 
	 * @return JSONObject
	 * @throws Exception
	 */
	public void syncUser(String sSyncType,OrgSyncConfig orgSyncConfig) throws Exception {	
		CoviMap param = new CoviMap();
		String isStopped = "";
		
		String strLog = "사용자 ";
		if ("INSERT".equals(sSyncType)) strLog += "추가 시작";
		else if ("UPDATE".equals(sSyncType)) strLog += "수정 시작";
		else if ("DELETE".equals(sSyncType)) strLog += "삭제 시작";
		strLog += "----------------------------------------------------------------";
		orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID, "Info", "USER", "", strLog, "");
				
		LOGGER.info("syncUser execute [syncType : " + sSyncType + "]");
		
		param.put("SyncType", sSyncType);
		
		CoviList userList = new CoviList();
		userList = (CoviList) orgSyncManageSvc.selectCompareObjectUserList(param).get("list");
		
		//Sync execution
		for(Object user : userList) {		
			isStopped = SessionHelper.getSession("isStopped");
			if(isStopped.equals("Y")) {
				orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID,"Stop","관리자 화면","","동기화 중지","");
				SessionHelper.setSession("isStopped", "N");		
				throw new stopException("동기화 중지");
			}
			
			CoviMap userParams = new CoviMap();
			CoviMap userObj = new CoviMap();
			userObj = (CoviMap) user;
			
			//hash-map for sys_object insert
			userParams.put("LicSeq", userObj.get("LicSeq"));
			userParams.put("ObjectCode", userObj.get("UserCode"));
			userParams.put("ObjectType", "UR");
			userParams.put("SyncMasterID", orgSyncConfig.SyncMasterID);
			userParams.put("IsSync", "Y");
			//hash-map for sys_object_user insert
			userParams.put("SyncType", userObj.get("SyncType"));
			userParams.put("SyncManage",  "Sync");
			userParams.put("UserCode", userObj.get("UserCode"));
			userParams.put("LogonID", userObj.get("LogonID"));
			userParams.put("LogonPassword", userObj.get("LogonPassword")); //1 //userParams.put("LogonPassword", userObj.get("LogonPassword")); 비밀번호 암호화 필요
			userParams.put("DecLogonPassword", userObj.get("LogonPassword")); //1 //userParams.put("LogonPassword", userObj.get("LogonPassword")); 비밀번호 암호화 필요			
			userParams.put("EmpNo", userObj.get("EmpNo"));
			userParams.put("DisplayName", userObj.get("DisplayName"));
			userParams.put("NickName", userObj.get("NickName"));
			userParams.put("MultiDisplayName", userObj.get("MultiDisplayName"));
			userParams.put("CompanyCode", userObj.get("CompanyCode"));
			userParams.put("DeptCode", userObj.get("DeptCode"));
			userParams.put("JobTitleCode", userObj.get("JobTitleCode"));
			userParams.put("JobPositionCode", userObj.get("JobPositionCode"));
			userParams.put("JobLevelCode", userObj.get("JobLevelCode"));
			userParams.put("RegionCode", userObj.get("RegionCode"));
			userParams.put("Address", userObj.get("Address"));
			userParams.put("MultiAddress", userObj.get("MultiAddress"));
			userParams.put("HomePage", userObj.get("HomePage"));
			userParams.put("PhoneNumber", userObj.get("PhoneNumber"));
			userParams.put("Mobile", userObj.get("Mobile"));
			userParams.put("Fax", userObj.get("Fax"));
			userParams.put("IPPhone", userObj.get("IPPhone"));
			userParams.put("UseMessengerConnect", userObj.get("UseMessengerConnect"));
			userParams.put("SortKey", userObj.get("SortKey"));
			userParams.put("SecurityLevel", userObj.get("SecurityLevel"));
			userParams.put("Description", userObj.get("Description"));
			userParams.put("IsUse", userObj.get("IsUse"));			
			userParams.put("IsHR", userObj.get("IsHR"));
			userParams.put("IsDisplay", userObj.get("IsDisplay"));
			userParams.put("EnterDate", userObj.get("EnterDate"));
			userParams.put("RetireDate", userObj.get("RetireDate"));
			userParams.put("PhotoPath", userObj.get("PhotoPath"));
			userParams.put("BirthDiv", userObj.get("BirthDiv"));
			userParams.put("BirthDate", userObj.get("BirthDate"));
			userParams.put("UseMailConnect", userObj.get("UseMailConnect"));
			userParams.put("MailAddress", userObj.get("MailAddress"));
			userParams.put("ExternalMailAddress", userObj.get("ExternalMailAddress"));
			userParams.put("ChargeBusiness", userObj.get("ChargeBusiness"));
			userParams.put("PhoneNumberInter", userObj.get("PhoneNumberInter"));
			userParams.put("LanguageCode", userObj.get("LanguageCode"));
			userParams.put("MobileThemeCode", userObj.get("MobileThemeCode"));
			userParams.put("TimeZoneCode", userObj.get("TimeZoneCode"));
			userParams.put("InitPortal", userObj.get("InitPortal"));
			userParams.put("RegistDate", userObj.get("RegistDate"));
			userParams.put("ModifyDate", userObj.get("ModifyDate"));			
			userParams.put("Reserved1", userObj.get("Reserved1"));
			userParams.put("Reserved2", userObj.get("Reserved2"));
			userParams.put("Reserved3", userObj.get("Reserved3"));
			userParams.put("Reserved4", userObj.get("Reserved4"));
			userParams.put("Reserved5", userObj.get("Reserved5"));
			userParams.put("oldDeptCode", userObj.get("oldDeptCode"));
			userParams.put("oldJobPositionCode", userObj.get("oldJobPositionCode"));
			userParams.put("oldJobTitleCode", userObj.get("oldJobTitleCode"));
			userParams.put("oldJobLevelCode", userObj.get("oldJobLevelCode"));
			//hash-map for sys_object_user_basegroup insert
			userParams.put("JobType", "Origin");
			userParams.put("aeskey", aeskey);
			userParams.put("BySaml", RedisDataUtil.getBaseConfig("UseSaml"));
			
			//AD
			userParams.put("AD_IsUse", userObj.get("AD_IsUse"));
			userParams.put("AD_DisplayName", userObj.get("AD_DisplayName"));
			userParams.put("AD_FirstName", userObj.get("AD_FirstName"));
			userParams.put("AD_LastName", userObj.get("AD_LastName"));
			userParams.put("AD_Initials", userObj.get("AD_Initials"));
			userParams.put("AD_Office", userObj.get("AD_Office"));
			userParams.put("AD_HomePage", userObj.get("AD_HomePage"));
			userParams.put("AD_Country", userObj.get("AD_Country"));
			userParams.put("AD_CountryID", userObj.get("AD_CountryID"));
			userParams.put("AD_CountryCode", userObj.get("AD_CountryCode"));
			userParams.put("AD_State", userObj.get("AD_State"));
			userParams.put("AD_City", userObj.get("AD_City"));
			userParams.put("AD_StreetAddress", userObj.get("AD_StreetAddress"));
			userParams.put("AD_PostOfficeBox", userObj.get("AD_PostOfficeBox"));
			userParams.put("AD_PostalCode", userObj.get("AD_PostalCode"));
			userParams.put("AD_UserAccountControl", userObj.get("AD_UserAccountControl"));
			userParams.put("AD_AccountExpires", userObj.get("AD_AccountExpires"));
			userParams.put("AD_PhoneNumber", userObj.get("AD_PhoneNumber"));
			userParams.put("AD_HomePhone", userObj.get("AD_HomePhone"));
			userParams.put("AD_Pager", userObj.get("AD_Pager"));
			userParams.put("AD_Mobile", userObj.get("AD_Mobile"));
			userParams.put("AD_Fax", userObj.get("AD_Fax"));
			userParams.put("AD_Info", userObj.get("AD_Info"));
			userParams.put("AD_Title", userObj.get("AD_Title"));
			userParams.put("AD_Department", userObj.get("AD_Department"));
			userParams.put("AD_Company", userObj.get("AD_Company"));
			userParams.put("AD_ManagerCode", userObj.get("AD_ManagerCode"));
			userParams.put("AD_CN", userObj.get("AD_CN"));
			userParams.put("AD_SamAccountName", userObj.get("AD_SamAccountName"));
			userParams.put("AD_UserPrincipalName", userObj.get("AD_UserPrincipalName"));
			
			//Exch
			userParams.put("EX_IsUse", userObj.get("EX_IsUse"));
			userParams.put("EX_PrimaryMail", userObj.get("EX_PrimaryMail"));
			userParams.put("EX_SecondaryMail", userObj.get("EX_SecondaryMail"));
			userParams.put("EX_StorageServer", userObj.get("EX_StorageServer"));
			userParams.put("EX_StorageGroup", userObj.get("EX_StorageGroup"));
			userParams.put("EX_StorageStore", userObj.get("EX_StorageStore"));
			userParams.put("EX_CustomAttribute01", "");
			userParams.put("EX_CustomAttribute02", "");
			userParams.put("EX_CustomAttribute03", "");
			userParams.put("EX_CustomAttribute04", "");
			userParams.put("EX_CustomAttribute05", "");
			userParams.put("EX_CustomAttribute06", "");
			userParams.put("EX_CustomAttribute07", "");
			userParams.put("EX_CustomAttribute08", "");
			userParams.put("EX_CustomAttribute09", "");
			userParams.put("EX_CustomAttribute10", "");
			userParams.put("EX_CustomAttribute11", "");
			userParams.put("EX_CustomAttribute12", "");
			userParams.put("EX_CustomAttribute13", "");
			userParams.put("EX_CustomAttribute14", "");
			userParams.put("EX_CustomAttribute15", "");
			
			//SFB
			userParams.put("MSN_IsUse", userObj.get("MSN_IsUse"));
			userParams.put("MSN_PoolServerName", userObj.get("MSN_PoolServerName"));
			userParams.put("MSN_PoolServerDN", userObj.get("MSN_PoolServerDN"));
			userParams.put("MSN_SIPAddress", userObj.get("MSN_SIPAddress"));
			userParams.put("MSN_Anonmy", userObj.get("MSN_Anonmy"));
			userParams.put("MSN_MeetingPolicyName", userObj.get("MSN_MeetingPolicyName"));
			userParams.put("MSN_MeetingPolicyDN", userObj.get("MSN_MeetingPolicyDN"));
			userParams.put("MSN_PhoneCommunication", userObj.get("MSN_PhoneCommunication"));
			userParams.put("MSN_PBX", userObj.get("MSN_PBX"));
			userParams.put("MSN_LinePolicyName", "");
			userParams.put("MSN_LinePolicyDN", "");
			userParams.put("MSN_LineURI", "");
			userParams.put("MSN_LineServerURI", "");
			userParams.put("MSN_Federation", "");
			userParams.put("MSN_RemoteAccess", "");
			userParams.put("MSN_PublicIMConnectivity", "");
			userParams.put("MSN_InternalIMConversation", "");
			userParams.put("MSN_FederatedIMConversation", "");

			switch(userObj.get("SyncType").toString().toUpperCase())
			{
				case "INSERT":
					LOGGER.info("Start User [INSERT] Sync");
					
					if(orgSyncConfig.IsSyncDB) {
						userParams.put("AD_ISUSE", RedisDataUtil.getBaseConfig("IsSyncAD"));
						userParams.put("EX_ISUSE", RedisDataUtil.getBaseConfig("IsSyncMail"));
						userParams.put("MSN_ISUSE", RedisDataUtil.getBaseConfig("IsSyncMessenger"));
						//hash-map for sys_object_user_approval insert 2018-01-10
						userParams.put("UseDeputy", "N");
						userParams.put("DeputyCode", "");
						userParams.put("DeputyName", "");
						userParams.put("DeputyFromDate", "");
						userParams.put("DeputyToDate", "");
						userParams.put("AlertConfig", RedisDataUtil.getBaseConfig("SyncUserInsertAlertConfigDefault"));
						userParams.put("ApprovalUnitCode", userObj.get("DeptCode"));
						userParams.put("ReceiptUnitCode", userObj.get("DeptCode"));
						userParams.put("ApprovalCode", userObj.get("UserCode"));
						userParams.put("ApprovalFullCode", userObj.get("UserCode"));
						userParams.put("ApprovalFullName", userObj.get("DisplayName"));
						userParams.put("UseApprovalMessageBoxView", "Y");
						userParams.put("UseMobile", "N");
						userParams.put("UseApprovalPassword", "N");
						orgSyncManageSvc.insertUser(userParams);						
					}
					CoviList jArrTemp = ((CoviList) orgSyncManageSvc.selectUserInfo(userParams).get("list"));
					if(jArrTemp.size()==0){
						break;
					}
					if(orgSyncConfig.IsSyncAD && orgSyncConfig.IsUserSync && userObj.get("AD_IsUse").toString().equals("Y")) {
						CoviMap params_old = new CoviMap();
						CoviList  arrresultList_old = new CoviList();
						params_old.put("UserCode", userObj.get("UserCode"));
						arrresultList_old = (CoviList) orgADSvc.selectUserInfoByAdmin(params_old).get("list");
						int icheckad = 0;
						if(arrresultList_old.getJSONObject(0).getString("AD_USERID").equals("")){
							icheckad = orgADSvc.insertUserADInfo(userParams);
						}else{
							icheckad = orgADSvc.updateUserADInfo(userParams);
						}
						
						if(icheckad != 0){	//sys_object_user_ad
							userParams.put("gr_code", userObj.get("DeptCode"));
							String sOUPath_Temp = "";
							CoviList arrGroupList = new CoviList();
							CoviMap resultList = new CoviMap();
							arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(userParams).get("list");
							sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
							
							resultList = orgADSvc.adAddUser(userParams.get("UserCode").toString(), userParams.get("CompanyCode").toString(), userParams.get("DeptCode").toString(), sOUPath_Temp, userParams.get("LogonID").toString(), 
									!userParams.get("LogonPassword").equals("") ? userParams.get("LogonPassword").toString() : RedisDataUtil.getBaseConfig("InitPassword"), userParams.get("EmpNo").toString(), userParams.get("AD_DisplayName").toString(),
									userParams.get("JobPositionCode").toString(), userParams.get("JobTitleCode").toString(), userObj.get("JobLevelCode").toString(), userObj.get("RegionCode").toString(), userParams.get("AD_FirstName").toString(), userParams.get("AD_LastName").toString(), userParams.get("AD_UserAccountControl").toString(), userParams.get("AD_AccountExpires").toString(),
									userParams.get("AD_PhoneNumber").toString(), userParams.get("AD_Mobile").toString(), userParams.get("AD_Fax").toString(), userParams.get("AD_Info").toString(), userObj.get("AD_Title").toString(), userObj.get("AD_Department").toString(), userObj.get("AD_Company").toString(),
									userObj.get("EX_PrimaryMail").toString(), userObj.get("EX_SecondaryMail").toString(), userObj.get("AD_CN").toString(), userObj.get("AD_SamAccountName").toString(), userObj.get("AD_SamAccountName").toString(), 
									userObj.get("PhotoPath").toString(), userObj.get("AD_ManagerCode").toString(), "N","Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							
							if(!Boolean.valueOf((String) resultList.getString("result"))) { //실패
								LOGGER.error("[AD Sync add] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
								throw new Exception();
							}
						}
					}
					
					if(orgSyncConfig.IsSyncMail && orgSyncConfig.IsUserSync && userObj.get("EX_IsUse").toString().equals("Y") && !userObj.get("EX_PrimaryMail").equals("")) {
						CoviMap params_old = new CoviMap();
						CoviList  arrresultList_old = new CoviList();
						params_old.put("UserCode", userObj.get("UserCode"));
						arrresultList_old = (CoviList) orgADSvc.selectUserInfoByAdmin(params_old).get("list");
						int icheckexch = 0;
						if(arrresultList_old.getJSONObject(0).getString("AD_USERID").equals("")){
							icheckexch = orgADSvc.insertUserExchInfo(userParams);
						}else{
							icheckexch = orgADSvc.updateUserExchInfo(userParams);
						}
						
						if(icheckexch != 0){	//sys_object_user_exchange 정보 입력 성공
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.exchEnableUser(userParams.get("UserCode").toString(),userObj.get("EX_StorageServer").toString(),userObj.get("EX_StorageGroup").toString(), userObj.get("EX_StorageStore").toString(), 
									userObj.get("EX_PrimaryMail").toString(), userObj.get("EX_SecondaryMail").toString(), userObj.get("MSN_SIPAddress").toString(), userObj.get("AD_CN").toString(), userObj.get("AD_SamAccountName").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								LOGGER.error("[Exch Sync add] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
								throw new Exception();
							}
						}
					}
					
					if(orgSyncConfig.IsSyncMessenger && orgSyncConfig.IsUserSync && userObj.get("MSN_IsUse").equals("Y")) {
						CoviMap params_old = new CoviMap();
						CoviList  arrresultList_old = new CoviList();
						params_old.put("UserCode", userObj.get("UserCode"));
						arrresultList_old = (CoviList) orgADSvc.selectUserInfoByAdmin(params_old).get("list");
						int icheckmsn = 0;
						if(arrresultList_old.getJSONObject(0).getString("MSN_USERID").equals("")){
							icheckmsn = orgADSvc.insertUserMSNInfo(userParams);
						}else{
							icheckmsn = orgADSvc.updateUserMSNInfo(userParams);
						}
						
						if(icheckmsn != 0) {
							CoviMap resultList = new CoviMap();
							resultList = orgADSvc.msnEnableUser(userParams.get("AD_SamAccountName").toString(),userObj.get("MSN_SIPAddress").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							
							if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
								LOGGER.error("[SFB Sync add] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
								throw new Exception();
							}
						}
					}
					
					if(orgSyncConfig.IsSyncIndi) {
						if(userObj.get("UseMailConnect").toString().equals("Y") && !userObj.get("MailAddress").toString().equals("")) {
							CoviMap reObject = orgSyncManageSvc.getUserStatus(userParams);
							if(reObject.has("returnCode") && reObject.has("result")){
								
								CoviMap oUserSyncData = ((CoviList) orgSyncManageSvc.selectUserInfo(userParams).get("list")).getJSONObject(0);
								String strDepName = oUserSyncData.getString("DeptName");
								userParams.put("DeptName", strDepName);
								
								userParams.put("GroupCode", userParams.get("DeptCode"));
								String sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
								
								userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
								userParams.put("oldGroupMailAddress", "");
								
								if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
									userParams.put("mailStatus", "A");
									reObject = orgSyncManageSvc.modifyUser(userParams);
									
									//그룹 메일 추가
									if(reObject.get("returnCode").toString().equals("0")) {
										if(!userObj.get("JobTitleCode").toString().equals("") && !userObj.get("JobTitleCode").toString().isEmpty()) {
											userParams.put("GroupCode", userParams.get("JobTitleCode"));
											sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											
											userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											userParams.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
										if(!userObj.get("JobPositionCode").toString().equals("") && !userObj.get("JobPositionCode").toString().isEmpty()) {
											userParams.put("GroupCode", userParams.get("JobPositionCode"));
											sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											
											userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											userParams.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
										if(!userObj.get("JobLevelCode").toString().equals("") && !userObj.get("JobLevelCode").toString().isEmpty()) {
											userParams.put("GroupCode", userParams.get("JobLevelCode"));
											sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											
											userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											userParams.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
									}
								}
								else if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("-1")) { //응답코드0:성공  result-1:계정없음
									reObject = orgSyncManageSvc.addUser(userParams);
									
									//그룹 메일 추가
									if(reObject.get("returnCode").toString().equals("0")) {
										if(!userObj.get("JobTitleCode").toString().equals("") && !userObj.get("JobTitleCode").toString().isEmpty()) {
											userParams.put("GroupCode", userParams.get("JobTitleCode"));
											sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											
											userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											userParams.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
										if(!userObj.get("JobPositionCode").toString().equals("") && !userObj.get("JobPositionCode").toString().isEmpty()) {
											userParams.put("GroupCode", userParams.get("JobPositionCode"));
											sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											
											userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											userParams.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
										if(!userObj.get("JobLevelCode").toString().equals("") && !userObj.get("JobLevelCode").toString().isEmpty()) {
											userParams.put("GroupCode", userParams.get("JobLevelCode"));
											sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											
											userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											userParams.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
									}
								}
							
							}
						}						
					}
					break;
				case "UPDATE":
					LOGGER.info("Start User [UPDATE] Sync");
					
					if(orgSyncConfig.IsSyncDB) {
						userParams.put("ApprovalUnitCode", userObj.get("DeptCode"));
						userParams.put("ReceiptUnitCode", userObj.get("DeptCode"));
						userParams.put("ApprovalCode", userObj.get("UserCode"));
						userParams.put("ApprovalFullCode", userObj.get("UserCode"));
						userParams.put("ApprovalFullName", userObj.get("DisplayName"));
						orgSyncManageSvc.updateUser(userParams);						
					}

					CoviMap params_old = new CoviMap();
					CoviList arrresultList_old = new CoviList();
					params_old.put("UserCode", userObj.get("UserCode"));
					arrresultList_old = (CoviList) orgADSvc.selectUserInfoByAdmin(params_old).get("list");
					
					if(orgSyncConfig.IsSyncAD && orgSyncConfig.IsUserSync) {
						int icheckad = 0;
						if(arrresultList_old.getJSONObject(0).getString("AD_USERID").equals("")){
							icheckad = orgADSvc.insertUserADInfo(userParams);
						}else{
							icheckad = orgADSvc.updateUserADInfo(userParams);
						}
						
						if(icheckad > 0) {
							userParams.put("gr_code", userParams.get("DeptCode").toString());
							String sOUPath_Temp = "";
							CoviList arrGroupList = new CoviList();
							CoviMap resultList = new CoviMap();
							arrGroupList = (CoviList) orgSyncManageSvc.selectDeptInfo(userParams).get("list");
							sOUPath_Temp = arrGroupList.getJSONObject(0).getString("OUPath");
							
							if(userObj.get("AD_IsUse").toString().equals("Y")) {
								resultList = orgADSvc.adModifyUser(userParams.get("UserCode").toString(), userParams.get("CompanyCode").toString(), userParams.get("DeptCode").toString(), userParams.get("oldDeptCode").toString(), sOUPath_Temp, userParams.get("LogonID").toString(), 
										!userParams.get("LogonPassword").equals("") ? userParams.get("LogonPassword").toString() : RedisDataUtil.getBaseConfig("InitPassword"), userParams.get("EmpNo").toString(), userParams.get("AD_DisplayName").toString(),
												userParams.get("JobPositionCode").toString(), userParams.get("JobTitleCode").toString(), userObj.get("JobLevelCode").toString(), userObj.get("RegionCode").toString(), userParams.get("AD_FirstName").toString(), userParams.get("AD_LastName").toString(), userParams.get("AD_UserAccountControl").toString(), userParams.get("AD_AccountExpires").toString(), 
												userParams.get("AD_PhoneNumber").toString(), userParams.get("AD_Mobile").toString(), userParams.get("AD_Fax").toString(), userParams.get("AD_Info").toString(), userParams.get("Reserved3").toString(), userParams.get("Reserved2").toString(), userParams.get("Reserved1").toString(), 
												userObj.get("EX_PrimaryMail").toString(), userObj.get("EX_SecondaryMail").toString(), userParams.get("AD_CN").toString(), userParams.get("AD_SamAccountName").toString(), userParams.get("AD_UserPrincipalName").toString(), "", "", "Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							}
							else {
								CoviMap params2 = new CoviMap();
								params2.put("gr_code", userParams.get("DeptCode").toString());
								CoviList arrGroupList2 = (CoviList) orgSyncManageSvc.selectDeptInfo(userParams).get("list");
								String strOupath = arrGroupList2.getJSONObject(0).getString("OUPath");
								resultList = orgADSvc.adDeleteUser(userParams.get("UserCode").toString(), userParams.get("CompanyCode").toString(), userParams.get("DeptCode").toString(),
										userParams.get("JobPositionCode").toString(), userParams.get("JobTitleCode").toString(), userObj.get("JobLevelCode").toString(), userObj.get("RegionCode").toString(), userParams.get("DeptCode").toString(), strOupath,
										userParams.get("AD_CN").toString(), userParams.get("AD_SamAccountName").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
							}
							
							if(Boolean.valueOf((String) resultList.getString("result"))){ //성공
								if(RedisDataUtil.getBaseConfig("PERMISSION_AD_PWD_CHG").equals("Y")){	//비밀번호 변경
		                            String sOldLogonPW = arrresultList_old.getJSONObject(0).getString("LOGONPASSWORD");
		                            AES aes = new AES(aeskey, "N");
		                            sOldLogonPW = aes.decrypt(sOldLogonPW);
		                            
		                            if (!sOldLogonPW.equals(userParams.get("DecLogonPassword").toString())) {
		                            	CoviMap resultList2 = new CoviMap();
		    							resultList2 = resultList = orgADSvc.adChangePassword(userParams.get("AD_SamAccountName").toString(), sOldLogonPW, userParams.get("DecLogonPassword").toString());
		    							if(!Boolean.valueOf((String) resultList2.getString("result"))){ //실패
		    								LOGGER.error("[AD PWD CHG] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
		    								throw new Exception();
		    							}
		                            }
								}
							}
							else {
								LOGGER.error("[AD Sync update] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
								throw new Exception();
							}
						}
					}
					if(orgSyncConfig.IsSyncMail && orgSyncConfig.IsUserSync && !userObj.get("EX_PrimaryMail").toString().equals("")) {
						 int icheckexch = 0;
							if(arrresultList_old.getJSONObject(0).getString("EX_USERID").equals("")){
								icheckexch = orgADSvc.insertUserExchInfo(userParams);
							}
							else{
								icheckexch = orgADSvc.updateUserExchInfo(userParams);
							}
							
							if(icheckexch != 0) {
								if(userObj.get("EX_IsUse").toString().equals("Y")) {
									CoviMap resultList = new CoviMap();
									resultList = orgADSvc.exchModifyUser(userParams.get("UserCode").toString(),userObj.get("EX_StorageServer").toString(),userObj.get("EX_StorageGroup").toString(),userObj.get("EX_StorageStore").toString(),
											userObj.get("EX_PrimaryMail").toString(), userObj.get("EX_SecondaryMail").toString(),userObj.get("MSN_SIPAddress").toString(),userParams.get("AD_CN").toString(),userParams.get("AD_SamAccountName").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
									
									if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
										LOGGER.error("[Exch Sync update] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
										throw new Exception();
									}
								} 
								else { //비활성화
									CoviMap resultList = new CoviMap();
									resultList = orgADSvc.exchDisableUser(userParams.get("AD_SamAccountName").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
									
									if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
										LOGGER.error("[Exch Sync delete] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
										throw new Exception();
									}
								}
							}
					}
					
					if(orgSyncConfig.IsSyncMessenger && orgSyncConfig.IsUserSync && !userObj.get("MSN_SIPAddress").toString().equals("")) {
						int icheckmsn = 0;
						if(arrresultList_old.getJSONObject(0).getString("MSN_USERID").equals("")){
							icheckmsn = orgADSvc.insertUserMSNInfo(userParams);
						}
						else{
							icheckmsn = orgADSvc.updateUserMSNInfo(userParams);
						}
						
						if(icheckmsn != 0) {
							if(userObj.get("MSN_IsUse").toString().equals("Y")) {
								CoviMap resultList = new CoviMap();
								resultList = orgADSvc.msnEnableUser(userParams.get("AD_SamAccountName").toString(),userObj.get("MSN_SIPAddress").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
								
								if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패	
									LOGGER.error("[MSN Sync update] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
									throw new Exception();
								}
							} 
							else {
								CoviMap resultList = new CoviMap();
								resultList = orgADSvc.msnDisableUser(userParams.get("AD_SamAccountName").toString(),userObj.get("MSN_SIPAddress").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
								
								if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패	
									LOGGER.error("[MSN Sync delete] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
									throw new Exception();
								}
							}
						}
					}
					
					if(orgSyncConfig.IsSyncIndi) {
						if(userObj.get("UseMailConnect").toString().equals("Y") && !userObj.get("MailAddress").toString().equals("")) {
							CoviMap reObject = orgSyncManageSvc.getUserStatus(userParams);
							if(reObject.has("returnCode") && reObject.has("result")){
								
								CoviMap oUserSyncData = ((CoviList) orgSyncManageSvc.selectUserInfo(userParams).get("list")).getJSONObject(0);
								String strDepName = oUserSyncData.getString("DeptName");
								userParams.put("DeptName", strDepName);
								
								userParams.put("GroupCode", userParams.get("DeptCode"));
								String sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
								userParams.put("GroupCode", userParams.get("oldDeptCode"));
								String sOldGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
								
								userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
								userParams.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
								
								if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
									userParams.put("mailStatus", "A");
									reObject = orgSyncManageSvc.modifyUser(userParams);
									
									//그룹 메일 추가
									if(reObject.get("returnCode").toString().equals("0")) {
										userParams.put("mailStatus", "A");
										if(!userObj.get("JobTitleCode").toString().equalsIgnoreCase(userObj.get("oldJobTitleCode").toString())) {
											if(!userObj.get("JobTitleCode").toString().isEmpty()) {
												userParams.put("GroupCode", userParams.get("JobTitleCode"));
												sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											} 
											else sGroupMail = "";
											
											if(!userObj.get("oldJobTitleCode").toString().isEmpty()) {
												userParams.put("GroupCode", userParams.get("oldJobTitleCode"));
												sOldGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											} 
											else sOldGroupMail = "";
											
											userParams.put("GroupMailAddress", sGroupMail);
											userParams.put("oldGroupMailAddress", sOldGroupMail);
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
										if(!userObj.get("JobPositionCode").toString().equalsIgnoreCase(userObj.get("oldJobPositionCode").toString())) {
											if(!userObj.get("JobPositionCode").toString().isEmpty()) {
												userParams.put("GroupCode", userParams.get("JobPositionCode"));
												sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											} 
											else sGroupMail = "";
											
											if(!userObj.get("oldJobPositionCode").toString().isEmpty()) {
												userParams.put("GroupCode", userParams.get("oldJobPositionCode"));
												sOldGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											} 
											else sOldGroupMail = "";
											
											userParams.put("GroupMailAddress", sGroupMail);
											userParams.put("oldGroupMailAddress", sOldGroupMail);
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
										if(!userObj.get("JobLevelCode").toString().equalsIgnoreCase(userObj.get("oldJobLevelCode").toString())) {
											if(!userObj.get("JobLevelCode").toString().isEmpty()) {
												userParams.put("GroupCode", userParams.get("JobLevelCode"));
												sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											} 
											else sGroupMail = "";
											
											if(!userObj.get("oldJobLevelCode").toString().isEmpty()) {
												userParams.put("GroupCode", userParams.get("oldJobLevelCode"));
												sOldGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											} 
											else sOldGroupMail = "";
											
											userParams.put("GroupMailAddress", sGroupMail);
											userParams.put("oldGroupMailAddress", sOldGroupMail);
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
									}
								} 
								else if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("-1")) { //응답코드0:성공  result-1:계정없음
									reObject = orgSyncManageSvc.addUser(userParams);
									
									//그룹 메일 추가
									if(reObject.get("returnCode").toString().equals("0")) {
										userParams.put("mailStatus", "A");
										
										if(userObj.get("JobTitleCode").toString() != null && !userObj.get("JobTitleCode").toString().equals("")) {
											userParams.put("GroupCode", userParams.get("JobTitleCode"));
											sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											
											userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											userParams.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
										
										if(userObj.get("JobPositionCode").toString() != null && !userObj.get("JobPositionCode").toString().equals("")) {
											userParams.put("GroupCode", userParams.get("JobPositionCode"));
											sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											
											userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											userParams.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
										
										if(userObj.get("JobLevelCode").toString() != null && !userObj.get("JobLevelCode").toString().equals("")) {
											userParams.put("GroupCode", userParams.get("JobLevelCode"));
											sGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
											
											userParams.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											userParams.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(userParams);
										}
									}
								}
							
							}
						}
					}
					break;
				case "DELETE":
					LOGGER.info("Start User [DELETE] Sync");
					
					if(orgSyncConfig.IsSyncDB) {
						orgSyncManageSvc.deleteUser(userParams);						
					}
					
					if(orgSyncConfig.IsSyncAD && orgSyncConfig.IsUserSync) {
						CoviMap params2 = new CoviMap();
						params2.put("gr_code", userParams.get("DeptCode").toString());
						CoviList arrGroupList2 = (CoviList) orgSyncManageSvc.selectDeptInfo(userParams).get("list");
						String strOupath = arrGroupList2.getJSONObject(0).getString("OUPath");
						CoviMap resultList = new CoviMap();
						resultList = orgADSvc.adDeleteUser(userParams.get("UserCode").toString(), userParams.get("CompanyCode").toString(), userParams.get("DeptCode").toString(),
								userParams.get("JobPositionCode").toString(), userParams.get("JobTitleCode").toString(), userObj.get("JobLevelCode").toString(), userObj.get("RegionCode").toString(), userParams.get("DeptCode").toString(), strOupath,
								userParams.get("AD_CN").toString(), userParams.get("AD_SamAccountName").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
						
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패	
							LOGGER.error("[AD Sync delete] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
							throw new Exception();
						}
					}
					
					if(orgSyncConfig.IsSyncMail && orgSyncConfig.IsUserSync && !userObj.get("EX_PrimaryMail").toString().equals("")) {
						CoviMap resultList = new CoviMap();
						resultList = orgADSvc.exchDisableUser(userParams.get("AD_SamAccountName").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
						
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							LOGGER.error("[Exch Sync delete] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
							throw new Exception();
						}
					}
					
					if(orgSyncConfig.IsSyncMessenger && orgSyncConfig.IsUserSync && !userObj.get("MSN_SIPAddress").toString().equals("")) {
						CoviMap resultList = new CoviMap();
						resultList = orgADSvc.msnEnableUser(userParams.get("AD_SamAccountName").toString(),userObj.get("MSN_SIPAddress").toString(),"Sync",Integer.toString(orgSyncConfig.SyncMasterID));
						
						if(!Boolean.valueOf((String) resultList.getString("result"))){ //실패
							LOGGER.error("[SFB Sync delete] " + userParams.get("UserCode").toString() + " : " + resultList.getString("Reason"));
							throw new Exception();
						}
					}
					
					if(orgSyncConfig.IsSyncIndi) {
						if(userObj.get("UseMailConnect").toString().equals("Y") && !userObj.get("MailAddress").toString().equals("")) {
							userParams.put("GroupCode", userParams.get("oldDeptCode"));
							String sOldGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
							
							userParams.put("GroupMailAddress", "");
							userParams.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
							
							userParams.put("mailStatus", "S");
							CoviMap reObject = orgSyncManageSvc.modifyUser(userParams);
							
							if(reObject.get("returnCode").toString().equals("0") && !userParams.get("oldJobTitleCode").toString().isEmpty()){
								userParams.put("GroupCode", userParams.get("oldJobTitleCode"));
								sOldGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
								
								userParams.put("GroupMailAddress", "");
								userParams.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
								
								reObject = orgSyncManageSvc.modifyUser(userParams);
							}
							
							if(reObject.get("returnCode").toString().equals("0") && !userParams.get("oldJobPositionCode").toString().isEmpty()){
								userParams.put("GroupCode", userParams.get("oldJobPositionCode"));
								sOldGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
								
								userParams.put("GroupMailAddress", "");
								userParams.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
								
								reObject = orgSyncManageSvc.modifyUser(userParams);
							}
							
							if(reObject.get("returnCode").toString().equals("0") && !userParams.get("oldJobLevelCode").toString().isEmpty()){
								userParams.put("GroupCode", userParams.get("oldJobLevelCode"));
								sOldGroupMail = orgSyncManageSvc.selectGroupMail(userParams); // 그룹의 메일주소
								
								userParams.put("GroupMailAddress", "");
								userParams.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
								
								reObject = orgSyncManageSvc.modifyUser(userParams);
							}
						}						
					}
					break;
				default :
					break;
			}
			//compare 테이블에서 삭제
			userParams.put("DataType", "User");
			orgSyncManageSvc.deleteCompareObjectOne(userParams);
		}
		
		SessionHelper.setSession("isStopped", "N");
		LOGGER.info("syncUser execute [syncType : " + sSyncType + "] complete");
		
		orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID, "Info", "USER", "", strLog.replace("시작", "종료"), "");
	}
	
	/**
	 * @description 겸직 동기화
	 * @param params 
	 * @return void
	 * @throws Exception
	 */
	public void syncAddjob(String sSyncType,OrgSyncConfig orgSyncConfig) throws Exception {
		Boolean bDept = true;
		Boolean bJTitle = true;
		Boolean bJPosition = true;
		Boolean bJLevel = true;
		
		CoviMap param = new CoviMap();
		String isStopped =	"";
		
		String strLog = "겸직 ";
		if ("INSERT".equals(sSyncType)) strLog += "추가 시작";
		else if ("UPDATE".equals(sSyncType)) strLog += "수정 시작";
		else if ("DELETE".equals(sSyncType)) strLog += "삭제 시작";
		strLog += "----------------------------------------------------------------";
		orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID, "Info", "ADDJOB", "", strLog, "");
		
		LOGGER.info("syncAddjob execute [syncType:" + sSyncType + "]");

		param.put("SyncType", sSyncType);
		
		CoviList addjobList = new CoviList();
		addjobList = (CoviList) orgSyncManageSvc.selectCompareObjectAddJobList(param).get("list");
		
		//Sync execution
		for(Object addjob : addjobList) {		
			isStopped = SessionHelper.getSession("isStopped");
			if(isStopped.equals("Y")) {
				orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID,"Stop","관리자 화면","","동기화 중지","");
				SessionHelper.setSession("isStopped", "N");
				throw new stopException("동기화 중지");
			}		
			bDept = true;
			bJTitle = true;
			bJPosition = true;
			bJLevel = true;
			
			CoviMap addjobParam = new CoviMap();
			CoviMap addjobObj = new CoviMap();
			addjobObj = (CoviMap) addjob; 
			CoviList arrresultList = null;
			
			//hash-map for sys_object_user_basegroup
			addjobParam.put("UserCode",  addjobObj.get("UserCode"));
			addjobParam.put("LogonID", addjobObj.get("LogonID"));
			addjobParam.put("SyncMasterID", orgSyncConfig.SyncMasterID);
			addjobParam.put("SyncManage",  "Sync");
			addjobParam.put("SyncType", addjobObj.get("SyncType"));
			addjobParam.put("JobType",  addjobObj.get("JobType"));
			addjobParam.put("SortKey",  addjobObj.get("SortKey"));
			addjobParam.put("CompanyCode",  addjobObj.get("CompanyCode"));
			addjobParam.put("DeptCode",  addjobObj.get("DeptCode"));
			addjobParam.put("RegionCode",  addjobObj.get("RegionCode"));
			addjobParam.put("JobPositionCode",  addjobObj.get("JobPositionCode"));
			addjobParam.put("JobTitleCode",  addjobObj.get("JobTitleCode"));			
			addjobParam.put("JobLevelCode",  addjobObj.get("JobLevelCode"));
			addjobParam.put("Reserved1",  addjobObj.get("Reserved1"));
			addjobParam.put("Reserved2",  addjobObj.get("Reserved2"));
			addjobParam.put("Reserved3",  addjobObj.get("Reserved3"));
			addjobParam.put("Reserved4",  addjobObj.get("Reserved4"));
			addjobParam.put("Reserved5",  addjobObj.get("Reserved5"));
			addjobParam.put("IsHR",  addjobObj.get("IsHR"));
			addjobParam.put("Seq",  addjobObj.get("Seq"));
			addjobParam.put("JobTitleName",  addjobObj.get("JobTitleName"));
			addjobParam.put("JobPositionName",  addjobObj.get("JobPositionName"));
			addjobParam.put("JobLevelName",  addjobObj.get("JobLevelName"));
			addjobParam.put("DisplayName",  addjobObj.get("DisplayName"));
			addjobParam.put("PhoneNumberInter", "");
			addjobParam.put("PhoneNumber", "");
			addjobParam.put("DecLogonPassword", "");
			
			arrresultList = (CoviList) orgSyncManageSvc.selectUserInfo(addjobParam).get("list");
			String strOriginDisplayName =arrresultList.getJSONObject(0).getString("DisplayName");
			String strOriginDeptCode =arrresultList.getJSONObject(0).getString("DeptCode");
			String strOriginJobPositionCode =arrresultList.getJSONObject(0).getString("JobPositionCode");
			String strOriginJobTitleCode =arrresultList.getJSONObject(0).getString("JobTitleCode");
			String strOriginJobLevelCode =arrresultList.getJSONObject(0).getString("JobLevelCode");
			String strOriginMailAddress = arrresultList.getJSONObject(0).getString("MailAddress");
			String strUseMailConnect = arrresultList.getJSONObject(0).getString("UseMailConnect");

			CoviMap params2 = new CoviMap();
			params2.put("DisplayName", strOriginDisplayName);
			params2.put("OriginGroupCode", strOriginDeptCode);
			params2.put("OriginJobPositionCode", strOriginJobPositionCode);
			params2.put("OriginJobTitleCode", strOriginJobTitleCode);
			params2.put("OriginJobLevelCode", strOriginJobLevelCode);
			params2.put("MailAddress", strOriginMailAddress);
			params2.put("DecLogonPassword", "");
			params2.put("mailStatus", "A");
			params2.put("UserCode", addjobObj.get("UserCode"));
			
			//hash-map for sys_object_user_basegroup insert
			addjobParam.put("JobType", "AddJob");
			
			switch(addjobObj.get("SyncType").toString().toUpperCase())
			{
				case "INSERT":
					LOGGER.info("Start AddJob [INSERT] Sync");
					
					if(orgSyncConfig.IsSyncDB) {
						orgSyncManageSvc.insertAddjob(addjobParam);						
					}
					
					if(orgSyncConfig.IsSyncIndi) {
						if(strUseMailConnect.equals("Y") && strOriginMailAddress != null && !strOriginMailAddress.equals("")) {
							CoviMap reObject = orgSyncManageSvc.getUserStatus(params2);
							if(reObject.has("returnCode") && reObject.has("result")){
								
								if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
									if(!addjobObj.get("DeptCode").toString().equalsIgnoreCase(strOriginDeptCode)) {
										params2.put("GroupCode", addjobObj.get("DeptCode").toString());
										String sGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
										
										params2.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
										params2.put("oldGroupMailAddress", "");
										
										reObject = orgSyncManageSvc.modifyUser(params2);
										
										if(reObject.get("returnCode").toString().equals("0") && !"".equals(addjobParam.get("JobPositionCode").toString()) 
												&& !addjobParam.get("JobPositionCode").toString().equalsIgnoreCase(strOriginJobPositionCode)) {
											params2.put("GroupCode", addjobObj.get("JobPositionCode").toString());
											sGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
											
											params2.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											params2.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(params2);
										}
										
										if(reObject.get("returnCode").toString().equals("0") && !"".equals(addjobParam.get("JobTitleCode").toString()) 
												&& !addjobParam.get("JobTitleCode").toString().equalsIgnoreCase(strOriginJobTitleCode)) {
											params2.put("GroupCode", addjobObj.get("JobTitleCode").toString());
											sGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
											
											params2.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											params2.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(params2);
										}
										
										if(reObject.get("returnCode").toString().equals("0") && !"".equals(addjobParam.get("JobLevelCode").toString()) 
												&& !addjobParam.get("JobLevelCode").toString().equalsIgnoreCase(strOriginJobLevelCode)) {
											params2.put("GroupCode", addjobObj.get("JobLevelCode").toString());
											sGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
											
											params2.put("GroupMailAddress", sGroupMail.isEmpty() ? "" : sGroupMail);
											params2.put("oldGroupMailAddress", "");
											
											reObject = orgSyncManageSvc.modifyUser(params2);
										}
									}
								}
							
							}
						}
					}
					break;
				case "DELETE":
					LOGGER.info("Start AddJob [DELETE] Sync");
					
					if(orgSyncConfig.IsSyncDB) {
						orgSyncManageSvc.deleteAddjobSync(addjobParam);												
					}
					
					if(orgSyncConfig.IsSyncIndi) {
						if(strUseMailConnect.equals("Y") && strOriginMailAddress != null && !strOriginMailAddress.equals("")) {
							CoviMap reObject = orgSyncManageSvc.getUserStatus(params2);
							if(reObject.has("returnCode") && reObject.has("result")){
								
								if(reObject.get("returnCode").toString().equals("0") && reObject.get("result").toString().equals("0")) { //응답코드0:성공  result0:계정있음
									CoviList listUserGroupInfo = (CoviList) OrganizationManageSvc.selectUserGroupList(params2).get("list");
									for (int j = 0; j < listUserGroupInfo.size(); j++) {
										String strGroupCode = listUserGroupInfo.getMap(j).getString("groupCode");
										if(bDept&&strGroupCode.equals(addjobObj.getString("DeptCode")))bDept = false;
										if(bJPosition&&strGroupCode.equals(addjobObj.getString("JobPositionCode")))bJPosition = false;
										if(bJTitle&&strGroupCode.equals(addjobObj.getString("JobTitleCode")))bJTitle = false;
										if(bJLevel&&strGroupCode.equals(addjobObj.getString("JobLevelCode")))bJLevel = false;
										if(!bDept&&!bJPosition&&!bJTitle&&!bJLevel)
											break;
									}
									
									if(!addjobObj.get("DeptCode").toString().equalsIgnoreCase(strOriginDeptCode)) {
										params2.put("GroupCode", addjobObj.get("DeptCode").toString());
										String sOldGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
										sOldGroupMail=bDept?sOldGroupMail:"";
										
										params2.put("GroupMailAddress", "");
										params2.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);
										
										reObject = orgSyncManageSvc.modifyUser(params2);
										
										if(reObject.get("returnCode").toString().equals("0") && !"".equals(addjobParam.get("JobPositionCode").toString()) 
												&& !addjobParam.get("JobPositionCode").toString().equalsIgnoreCase(strOriginJobPositionCode)) {
											params2.put("GroupCode", addjobObj.get("JobPositionCode").toString());
											sOldGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
											sOldGroupMail=bJPosition?sOldGroupMail:"";
											
											params2.put("GroupMailAddress", "");
											params2.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);

											reObject = orgSyncManageSvc.modifyUser(params2);
										}
										
										if(reObject.get("returnCode").toString().equals("0") && !"".equals(addjobParam.get("JobTitleCode").toString()) 
												&& !addjobParam.get("JobTitleCode").toString().equalsIgnoreCase(strOriginJobTitleCode)) {
											params2.put("GroupCode", addjobObj.get("JobTitleCode").toString());
											sOldGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
											sOldGroupMail=bJTitle?sOldGroupMail:"";
											
											params2.put("GroupMailAddress", "");
											params2.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);

											reObject = orgSyncManageSvc.modifyUser(params2);
										}
										
										if(reObject.get("returnCode").toString().equals("0") && !"".equals(addjobParam.get("JobLevelCode").toString()) 
												&& !addjobParam.get("JobLevelCode").toString().equalsIgnoreCase(strOriginJobLevelCode)) {
											params2.put("GroupCode", addjobObj.get("JobLevelCode").toString());
											sOldGroupMail = orgSyncManageSvc.selectGroupMail(params2); // 그룹의 메일주소
											sOldGroupMail=bJLevel?sOldGroupMail:"";
											
											params2.put("GroupMailAddress", "");
											params2.put("oldGroupMailAddress", sOldGroupMail.isEmpty() ? "" : sOldGroupMail);

											reObject = orgSyncManageSvc.modifyUser(params2);
										}
									}
								}
							
							}
						}
					}
					break;
				default :
					break;
			}	
			//compare 테이블에서 삭제
			addjobParam.put("DataType", "AddJob");
			orgSyncManageSvc.deleteCompareObjectOne(addjobParam);
		}


		SessionHelper.setSession("isStopped", "N");
		
		LOGGER.info("syncAddjob execute [syncType:" + sSyncType + "] complete");
		orgSyncManageSvc.insertLogListLog(orgSyncConfig.SyncMasterID, "Info", "ADDJOB", "", strLog.replace("시작", "종료"), "");
	}
	
	/**
	 * getTitleLogList : 동기화 - 로그 리스트 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getTitleLogList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getTitleLogList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{	
		String strFirstDate = StringUtil.replaceNull(request.getParameter("FirstDate"), "").replace('.', '-');
		String strLastDate = StringUtil.replaceNull(request.getParameter("LastDate"), "").replace('.', '-');
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "StartDate";
		String strSortDirection = "DESC";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = setRegexString(strSort.split(" ")[0]);
			strSortDirection = setRegexString(strSort.split(" ")[1]);
		}
		 
		// DB Parameter Setting
		CoviMap params = new CoviMap();

		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		params.put("FirstDate", strFirstDate);
		params.put("LastDate", strLastDate);
		
		CoviMap jobjResult = orgSyncManageSvc.selectLogList(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 

		returnObj.put("page", jobjResult.get("page"));
		returnObj.put("list", jobjResult.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	/**
	 * getGroupLogList : 동기화 - 로그 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/getLogList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getLogList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{		
		
		String strObjectType = StringUtil.replaceNull(request.getParameter("ObjectType"), "");
		String strInsertDate = StringUtil.replaceNull(request.getParameter("InsertDate"), "");
		String strSyncType = StringUtil.replaceNull(request.getParameter("SyncType"), "");
		String strIsUse = StringUtil.replaceNull(request.getParameter("IsUse"), "");
		String strSyncStatus = StringUtil.replaceNull(request.getParameter("SyncStatus"), "");
		String strObjectCode = StringUtil.replaceNull(request.getParameter("ObjectCode"), "");
		String strSyncMasterID = StringUtil.replaceNull(request.getParameter("SyncMasterID"), "");		
		
		//정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strSortColumn = "Seq";
		String strSortDirection = "DESC";
		
		if(strSort != null && !strSort.isEmpty()) {
			strSortColumn = setRegexString(strSort.split(" ")[0]);
			strSortDirection = setRegexString(strSort.split(" ")[1]);
		}
		 
		// DB Parameter Setting
		CoviMap params = new CoviMap();

		params.put("pageNo", request.getParameter("pageNo"));
		params.put("pageSize", request.getParameter("pageSize"));
		params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
		params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
		 
		
		params.put("InsertDate", strInsertDate);
		params.put("SyncType", strSyncType);
		params.put("IsUse", strIsUse);
		params.put("SyncStatus", strSyncStatus);
		params.put("ObjectCode", strObjectCode);
		params.put("SyncMasterID", strSyncMasterID);		
		
		
		CoviMap jobjResult = new CoviMap();
		
		if(strObjectType.equals("GR")) {
			jobjResult=orgSyncManageSvc.selectGroupLogList(params);
		}
		else if(strObjectType.equals("UR")) {
			jobjResult=orgSyncManageSvc.selectUserLogList(params);
		}
		else if(strObjectType.equals("AddJob")) {
			jobjResult=orgSyncManageSvc.selectAddJobLogList(params);
		} else {
			params.put("ObjectCode", "");
			params.put("SyncMasterID", "0");
			jobjResult=orgSyncManageSvc.selectAddJobLogList(params);
		}
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 

		returnObj.put("page", jobjResult.get("page"));
		returnObj.put("list", jobjResult.get("list"));
		returnObj.put("result", "ok");
		
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	/**
	 * getSyncHistory : 동기화 - 이력 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/selectSyncHitory.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectSyncHitory(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{		
		
		int iTopCount = Integer.parseInt(request.getParameter("Cnt"));
			
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("TopCnt", iTopCount); // 가져오는 갯수
		
		CoviMap listData = null;
		listData = orgSyncManageSvc.selectSyncHitory(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	/**
	 * selectSyncItemLog : 동기화 - 회차별 이력 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/selectSyncItemLog.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectSyncItemLog(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{		
		int SyncMasterID = Integer.parseInt(request.getParameter("SyncMasterID"));
			
		// DB Parameter Setting
		CoviMap params = new CoviMap();
		params.put("SyncMasterID", SyncMasterID); // 가져오 갯수
		
		CoviMap listData = null;
		listData = orgSyncManageSvc.selectSyncItemLog(params);
		
		// 결과 반환
		CoviMap returnObj = new CoviMap(); 
		returnObj.put("list", listData.get("list"));
		returnObj.put("result", "ok");
		returnObj.put("status", Return.SUCCESS);
		returnObj.put("message", "조회 성공");
		
		return returnObj;
	}
	
	/**
	 * getCompareList : 동기화 - 이력 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/selectCompareList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap selectCompareList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception {		
		CoviMap returnObj = new CoviMap(); 
		String type = StringUtil.replaceNull(request.getParameter("type"), "");
		
		if (!type.equals("Group") && !type.equals("User") && !type.equals("Addjob")) {
			returnObj.put("result", "ok");
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "잘못된 요청 파라미터");
		}
		else {
			returnObj.put("list", orgSyncManageSvc.selectCompareList(type));
			returnObj.put("result", "ok");
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회 성공");
		}
		
		return returnObj;
	}
	
	//페이지 이동
	@RequestMapping(value="loglistpop.do", method=RequestMethod.GET)
	public ModelAndView showLogListPop(HttpServletRequest request, HttpServletResponse response) throws Exception
	{	
		request.setCharacterEncoding("UTF-8");
		
		String strObjectType = StringUtil.replaceNull(request.getParameter("ObjectType"), "");
		strObjectType = new String(strObjectType.getBytes("8859_1"),"UTF-8"); //이거만 추가
		
		String strInsertDate = request.getParameter("InsertDate");
		
		String returnURL = "core/organization/loglistpop";
		String strSyncType = request.getParameter("SyncType");
		String strSyncMasterID = request.getParameter("SyncMasterID");		
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("ObjectType", strObjectType);
		mav.addObject("SyncType", strSyncType);
		mav.addObject("SyncMasterID", strSyncMasterID);		
		mav.addObject("InsertDate", strInsertDate);		
		
		return mav;
	}
	
	// 파라미터로 넘어온 문자열을 영문 대소문자, 숫자, _ 이외의 값 전부 치환하여 리턴
	private String setRegexString(String paramStr) throws Exception {
		String result = "";
		Pattern regPattern = Pattern.compile("[^a-zA-Z0-9\\_]");
		
		result = regPattern.matcher(paramStr).replaceAll("");
		
		return result;
	}
	/*미사용
	private String toStringSyncConfig(OrgSyncConfig orgSyncConfig) {
		String strReturn = "";
		if (orgSyncConfig.IsDeptSync || orgSyncConfig.IsJobLevelSync || orgSyncConfig.IsJobTitleSync || orgSyncConfig.IsJobPositionSync || orgSyncConfig.IsUserSync || orgSyncConfig.IsAddJobSync) {
			strReturn += "연동범위 - ";
			String strOper = "";
			if ((boolean) orgSyncConfig.configDeptSync.get("all")) { strOper = "전체"; }
			else {
				if ((boolean) orgSyncConfig.configDeptSync.get("add")) { strOper += "추가"; }
				if ((boolean) orgSyncConfig.configDeptSync.get("modify")) { strOper += (((boolean) orgSyncConfig.configDeptSync.get("add")) ? "/" : "") + "수정"; }
				if ((boolean) orgSyncConfig.configDeptSync.get("delete")) { strOper += (((boolean) orgSyncConfig.configDeptSync.get("add") || (boolean) orgSyncConfig.configDeptSync.get("modify")) ? "/" : "") + "삭제"; }
			}
			if ((boolean) orgSyncConfig.configDeptSync.get("all") || (boolean) orgSyncConfig.configDeptSync.get("add") || (boolean) orgSyncConfig.configDeptSync.get("modify") || (boolean) orgSyncConfig.configDeptSync.get("delete")) {
				strOper = "부서[" + strOper + "]";
			}
			strReturn += strOper;
			
			strOper = "";
			if ((boolean) orgSyncConfig.configJobLevelSync.get("all")) { strOper = "전체"; }
			else {
				if ((boolean) orgSyncConfig.configJobLevelSync.get("add")) { strOper += "추가"; }
				if ((boolean) orgSyncConfig.configJobLevelSync.get("modify")) { strOper += (((boolean) orgSyncConfig.configJobLevelSync.get("add")) ? "/" : "") + "수정"; }
				if ((boolean) orgSyncConfig.configJobLevelSync.get("delete")) { strOper += (((boolean) orgSyncConfig.configJobLevelSync.get("add") || (boolean) orgSyncConfig.configJobLevelSync.get("modify")) ? "/" : "") + "삭제"; }
			}
			if ((boolean) orgSyncConfig.configJobLevelSync.get("all") || (boolean) orgSyncConfig.configJobLevelSync.get("add") || (boolean) orgSyncConfig.configJobLevelSync.get("modify") || (boolean) orgSyncConfig.configJobLevelSync.get("delete")) {
				strOper = "직급[" + strOper + "]";
			}
			strReturn += strOper;
			
			strOper = "";
			if ((boolean) orgSyncConfig.configJobPositionSync.get("all")) { strOper = "전체"; }
			else {
				if ((boolean) orgSyncConfig.configJobPositionSync.get("add")) { strOper += "추가"; }
				if ((boolean) orgSyncConfig.configJobPositionSync.get("modify")) { strOper += (((boolean) orgSyncConfig.configJobPositionSync.get("add")) ? "/" : "") + "수정"; }
				if ((boolean) orgSyncConfig.configJobPositionSync.get("delete")) { strOper += (((boolean) orgSyncConfig.configJobPositionSync.get("add") || (boolean) orgSyncConfig.configJobPositionSync.get("modify")) ? "/" : "") + "삭제"; }
			}
			if ((boolean) orgSyncConfig.configJobPositionSync.get("all") || (boolean) orgSyncConfig.configJobPositionSync.get("add") || (boolean) orgSyncConfig.configJobPositionSync.get("modify") || (boolean) orgSyncConfig.configJobPositionSync.get("delete")) {
				strOper = "직위[" + strOper + "]";
			}
			strReturn += strOper;
			
			strOper = "";
			if ((boolean) orgSyncConfig.configJobTitleSync.get("all")) { strOper = "전체"; }
			else {
				if ((boolean) orgSyncConfig.configJobTitleSync.get("add")) { strOper += "추가"; }
				if ((boolean) orgSyncConfig.configJobTitleSync.get("modify")) { strOper += (((boolean) orgSyncConfig.configJobTitleSync.get("add")) ? "/" : "") + "수정"; }
				if ((boolean) orgSyncConfig.configJobTitleSync.get("delete")) { strOper += (((boolean) orgSyncConfig.configJobTitleSync.get("add") || (boolean) orgSyncConfig.configJobTitleSync.get("modify")) ? "/" : "") + "삭제"; }
			}
			if ((boolean) orgSyncConfig.configJobTitleSync.get("all") || (boolean) orgSyncConfig.configJobTitleSync.get("add") || (boolean) orgSyncConfig.configJobTitleSync.get("modify") || (boolean) orgSyncConfig.configJobTitleSync.get("delete")) {
				strOper = "직책[" + strOper + "]";
			}
			strReturn += strOper;
			
			strOper = "";
			if ((boolean) orgSyncConfig.configUserSync.get("all")) { strOper = "전체"; }
			else {
				if ((boolean) orgSyncConfig.configUserSync.get("add")) { strOper += "추가"; }
				if ((boolean) orgSyncConfig.configUserSync.get("modify")) { strOper += (((boolean) orgSyncConfig.configUserSync.get("add")) ? "/" : "") + "수정"; }
				if ((boolean) orgSyncConfig.configUserSync.get("delete")) { strOper += (((boolean) orgSyncConfig.configUserSync.get("add") || (boolean) orgSyncConfig.configUserSync.get("modify")) ? "/" : "") + "삭제"; }
			}
			if ((boolean) orgSyncConfig.configUserSync.get("all") || (boolean) orgSyncConfig.configUserSync.get("add") || (boolean) orgSyncConfig.configUserSync.get("modify") || (boolean) orgSyncConfig.configUserSync.get("delete")) {
				strOper = "사용자[" + strOper + "]";
			}
			strReturn += strOper;
			
			strOper = "";
			if ((boolean) orgSyncConfig.configAddJobSync.get("all")) { strOper = "전체"; }
			else {
				if ((boolean) orgSyncConfig.configAddJobSync.get("add")) { strOper += "추가"; }
				if ((boolean) orgSyncConfig.configAddJobSync.get("delete")) { strOper += (((boolean) orgSyncConfig.configAddJobSync.get("add")) ? "/" : "") + "삭제"; }
			}
			if ((boolean) orgSyncConfig.configAddJobSync.get("all") || (boolean) orgSyncConfig.configAddJobSync.get("add") || (boolean) orgSyncConfig.configAddJobSync.get("delete")) {
				strOper = "겸직[" + strOper + "]";
			}
			strReturn += strOper;
		}
		
		if (orgSyncConfig.IsSyncDB || orgSyncConfig.IsSyncIndi || orgSyncConfig.IsSyncMail || orgSyncConfig.IsSyncAD || orgSyncConfig.IsSyncMessenger) {
			if (orgSyncConfig.IsDeptSync || orgSyncConfig.IsJobLevelSync || orgSyncConfig.IsJobTitleSync || orgSyncConfig.IsJobPositionSync || orgSyncConfig.IsUserSync || orgSyncConfig.IsAddJobSync) {
				strReturn += "<br>";
			}
			strReturn += "동기화범위 - ";
			
			if (orgSyncConfig.IsSyncDB) { strReturn += "DB"; }
			if (orgSyncConfig.IsSyncIndi) { strReturn += ((orgSyncConfig.IsSyncDB) ? "/" : "") + "CoviMail"; }
			if (orgSyncConfig.IsSyncMail) { strReturn += ((orgSyncConfig.IsSyncDB || orgSyncConfig.IsSyncIndi) ? "/" : "") + "Exchange"; }
			if (orgSyncConfig.IsSyncAD) { strReturn += ((orgSyncConfig.IsSyncDB || orgSyncConfig.IsSyncIndi || orgSyncConfig.IsSyncMail) ? "/" : "") + "AD"; }
			if (orgSyncConfig.IsSyncMessenger) { strReturn += ((orgSyncConfig.IsSyncDB || orgSyncConfig.IsSyncIndi || orgSyncConfig.IsSyncMail || orgSyncConfig.IsSyncAD) ? "/" : "") + "SFB"; }
		}
		
		return strReturn;
	}*/
	
	

	/**
	 * deleteCompareObject : 동기화 - 항목삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/deleteCompareObject.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteCompareObject(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{		
		
		CoviMap returnList = new CoviMap();
		String strCodes = StringUtil.replaceNull(request.getParameter("Codes"), "");
		String strObjectType = StringUtil.replaceNull(request.getParameter("ObjectType"), "");
		try {
			
			CoviMap params = new CoviMap();
			String arrCodes[] = strCodes.isEmpty() ? null : strCodes.split(";");
			params.put("Codes", arrCodes);
			params.put("ObjectType", strObjectType);
			
			orgSyncManageSvc.deleteCompareObject(params);			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} 
		return returnList;
	}
}
