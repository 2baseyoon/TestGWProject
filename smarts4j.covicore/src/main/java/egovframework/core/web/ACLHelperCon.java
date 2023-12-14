package egovframework.core.web;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.CacheLoadService;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.ACLHelperSvc;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ACLSerializeUtil;
import egovframework.coviframework.vo.ACLMapper;

/**
 * @Class Name : CacheCon.java
 * @Description : 캐쉬 제어 컨트롤러
 * @Modification Information 
 * @ 2017.07.24 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 07.24
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class ACLHelperCon {

	private Logger LOGGER = LogManager.getLogger(ACLHelperCon.class);

	@Autowired
	private ACLHelperSvc aclHelperSvc;
	
	@Autowired
	private CacheLoadService cacheLoadSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "aclhelper/getDomainList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getDomainList(HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
			
		try {
			CoviList list = aclHelperSvc.selectDomain(null);
			
			returnList.put("list", list);
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "aclhelper/getSyncKeyList.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getSyncKeyList(HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String pDomainID = request.getParameter("DomainID"); 
		try {
			CoviList serviceTypes = aclHelperSvc.selectServiceType(null);
			
			CoviList aclSyncMap = new CoviList();
			CoviMap menuSyncKey = new CoviMap();
			menuSyncKey.put("Key", "MN");
			menuSyncKey.put("Value", RedisDataUtil.getACLSyncKey(pDomainID, "MN"));
			aclSyncMap.add(menuSyncKey);
			
			CoviMap portalSyncKey = new CoviMap();
			portalSyncKey.put("Key", "PT");
			portalSyncKey.put("Value", RedisDataUtil.getACLSyncKey(pDomainID, "PT"));
			aclSyncMap.add(portalSyncKey);
			
			for(int i=0; i<serviceTypes.size(); i++) {
				CoviMap obj = serviceTypes.getMap(i);
				CoviMap folderSyncKey = new CoviMap();
				String serviceType = "FD_" + obj.getString("ObjectType");
				folderSyncKey.put("Key", serviceType);
				folderSyncKey.put("Value", RedisDataUtil.getACLSyncKey(pDomainID, serviceType));
				
				aclSyncMap.add(folderSyncKey);
			}
			
			
			returnList.put("list", aclSyncMap);
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		} 
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	@RequestMapping(value = "aclhelper/refreshSyncKey.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap refreshSyncKey(HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String pDomainID = request.getParameter("DomainID"); 
		String pKey = request.getParameter("Key");
		
		
		try {
			String refreshSyncKey = RedisDataUtil.refreshACLSyncKey(pDomainID, pKey);
			
			if(StringUtil.replaceNull(pKey).equals("MN")) {
				// MENU Cache Reload
				RedisShardsUtil instance = RedisShardsUtil.getInstance();
				String keyPattern = RedisDataUtil.PRE_MENU + pDomainID + "_*";
				instance.removeAll(pDomainID, keyPattern);
			}
			
			returnList.put("syncKey", refreshSyncKey);
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "aclhelper/refreshSyncKeyAll.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap refreshSyncKeyAll(HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String pDomainID = request.getParameter("DomainID"); 
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		try {
			String keyPattern = RedisDataUtil.PRE_MENU;

			Map<String, String> aclSyncMap = cacheLoadSvc.selectSyncType();

			if(pDomainID == null || pDomainID.isEmpty()) {
				// auth sync 대상 syncKey 등록
				CoviList domainList = cacheLoadSvc.selectDomain(null);
				for(int i = 0; i < domainList.size(); i++) {
					CoviMap domainInfo = domainList.getMap(i);
					pDomainID = domainInfo.getString("DomainID");
					instance.hmset(RedisDataUtil.PRE_H_ACL + pDomainID + "_SYNC_MAP", aclSyncMap);
					/*
					
					// MENU Cache Reload
					keyPattern += pDomainID + "_*";
					instance.removeAll(pDomainID, keyPattern);
					*/
				}
			} else {
				instance.hmset(RedisDataUtil.PRE_H_ACL + pDomainID + "_SYNC_MAP", aclSyncMap);
				/*
				// MENU Cache Reload
				keyPattern += pDomainID + "_*";
				instance.removeAll(pDomainID, keyPattern);
				*/
			}
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	

	@RequestMapping(value = "aclhelper/sampleACLData.do", method = {RequestMethod.GET})
	public @ResponseBody CoviMap sampleACLData(HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		try {
			CoviMap sessionObj = SessionHelper.getSession();
			String userID = sessionObj.getString("USERID");
			String jobSeq = sessionObj.getString("URBG_ID");
			String domainID = sessionObj.getString("DN_ID");
			
			String aclData = instance.hget(RedisDataUtil.PRE_H_ACL + domainID + "_" + userID + "_" + jobSeq, "MN");
			
			returnList.put("aclData", aclData);
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	@RequestMapping(value = "aclhelper/fromObjectACL.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap fromObjectACL(HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String aclData = request.getParameter("aclData"); 
		ACLSerializeUtil sUtil = new ACLSerializeUtil();
		
		try {
			ACLMapper aclMapper = sUtil.deserializeObj(aclData);
			
			CoviMap aclMapperObj = new CoviMap();
			aclMapperObj.put("settingKey", aclMapper.getSettingKey());
			aclMapperObj.put("syncKey", aclMapper.getSynchronizeKey());
			
			String[] aclList = {"S", "C", "D", "M", "E", "V", "R"};
			
			for(String aclCol : aclList) {
				Set<String> aclInfo = aclMapper.getACLInfo(aclCol);
				String[] aclArrObj = aclInfo.toArray(new String[aclInfo.size()]);
				aclMapperObj.put(aclCol, ACLHelper.join((aclArrObj), ","));				
			}
			
			returnList.put("aclData", aclMapperObj);
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		} 
		catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message",isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (ClassNotFoundException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message",isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message",isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	
	
	@RequestMapping(value = "aclhelper/refreshSyncKeyAllByCode.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap refreshSyncKeyAllByCode(HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String pDomainCode = request.getParameter("DomainCode"); 
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		
		try {
			CoviMap params = new CoviMap();
			params.put("DomainCode", pDomainCode);
			String domainID = aclHelperSvc.getDomainID(params);
			Map<String, String> aclSyncMap = cacheLoadSvc.selectSyncType();
			instance.hmset(RedisDataUtil.PRE_H_ACL + domainID + "_SYNC_MAP", aclSyncMap);
			String keyPattern = RedisDataUtil.PRE_MENU + domainID + "_*";
			instance.removeAll(domainID, keyPattern);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("result", "ok");
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
}
