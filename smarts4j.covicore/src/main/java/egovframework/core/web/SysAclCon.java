package egovframework.core.web;

import java.util.List;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.CacheLoadService;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.SysAclSvc;
import egovframework.coviframework.util.ComUtils;

/**
 * @Class Name : SysAclCon.java
 * @Description : 시스템 - 권한 관리
 * @Modification Information 
 * @ 2022.02.04 최초생성
 *
 * @author 코비젼 연구소
 * @since 2022.02.04
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class SysAclCon {
	
	private Logger LOGGER = LogManager.getLogger(SysAclCon.class);
	
	@Autowired
	private SysAclSvc sysAclSvc;
	
	@Autowired
	private CacheLoadService cacheLoadSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * goAclManageAddPopup : 권한 추가 팝업 호출
	 * @param request
	 * @param paramMap
	 * @return ModelAndView
	 */
	@RequestMapping(value = "aclManage/goAclManageAddPopup.do", method = RequestMethod.GET)
	public ModelAndView goAclManageAddPopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView("core/system/AclManageAddPopup");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	/**
	 * goAclManageEditPopup : 권한 수정 팝업 호출
	 * @param request
	 * @param paramMap
	 * @return ModelAndView
	 */
	@RequestMapping(value = "aclManage/goAclManageEditPopup.do", method = RequestMethod.GET)
	public ModelAndView goAclManageEditPopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView("core/system/AclManageEditPopup");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	/**
	 * goAclTargetAddPopup : 권한 추가 대상 팝업 호출
	 * @param request
	 * @param paramMap
	 * @return ModelAndView
	 */
	@RequestMapping(value = "aclManage/goAclTargetAddPopup.do", method = RequestMethod.GET)
	public ModelAndView goAclTargetAddPopup(HttpServletRequest request, @RequestParam Map<String, String> paramMap) {
		ModelAndView mav = new ModelAndView("core/system/AclTargetAddPopup");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	/**
	 * getAclList : 권한 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "aclManage/getAclList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAclList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			String domain = request.getParameter("domain");
			String aclType = request.getParameter("aclType");
			String aclText = request.getParameter("aclText");
			
			String sortColumn = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[0]:"";
			String sortDirection = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[1]:"";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("domain", domain);
			params.put("aclType", aclType);
			params.put("aclText", ComUtils.RemoveSQLInjection(aclText, 100));
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			returnList = sysAclSvc.getAclList(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * getAclTarget : 사용자 상세 권한 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "aclManage/getAclTarget.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAclTarget(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			String subjectType = request.getParameter("subjectType");
			String subjectCode = request.getParameter("subjectCode");
			
			String sortColumn = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[0]:"";
			String sortDirection = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[1]:"";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("subjectType", subjectType);
			params.put("subjectCode", subjectCode);
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			returnList = sysAclSvc.getAclTarget(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getAclDetail : 권한 상세 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "aclManage/getAclDetail.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAclDetail(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			String objectType = request.getParameter("objectType");
			String subjectType = request.getParameter("subjectType");
			String subjectCode = request.getParameter("subjectCode");
			
			String sortColumn = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[0]:"";
			String sortDirection = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[1]:"";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("objectType", objectType);
			params.put("subjectType", subjectType);
			params.put("subjectCode", subjectCode);
			
			params.put("searchText", ComUtils.RemoveSQLInjection(request.getParameter("searchText"), 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			if (StringUtil.isNotNull(request.getParameter("folderType"))) {
				params.put("folderType", request.getParameter("folderType"));
			}
			
			if (StringUtil.isNotNull(request.getParameter("isAdmin"))) {
				params.put("isAdmin", request.getParameter("isAdmin"));
			}
			
			returnList = sysAclSvc.getAclDetail(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * deleteAcl : 권한 삭제
	 * @param paramMap
	 * @param request
	 * @return returnList
	 */
	@RequestMapping(value = "aclManage/deleteAcl.do")
	public @ResponseBody CoviMap deleteAcl(@RequestBody Map<String, Object> params, HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap reqMap = new CoviMap();
			
			reqMap.put("aclList", (List) params.get("aclList"));
			returnList = sysAclSvc.deleteAcl(reqMap);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제");
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getFolderType : 폴더 타입 조회
	 * @param request
	 * @return returnList
	 */
	@RequestMapping(value = "aclManage/getFolderType.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getFolderType(HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			returnList = sysAclSvc.getFolderType(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getFolderType : 권한 정보 조회
	 * @param request
	 * @return returnList
	 */
	@RequestMapping(value = "aclManage/getACLInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getACLInfo(HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("AclID", request.getParameter("aclID"));
			
			returnList = sysAclSvc.getACLInfo(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * addAclInfo : 권한 추가
	 * @param request
	 * @return returnList
	 */
	@RequestMapping(value = "aclManage/addAclInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap addAclInfo(HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("aclList", "SCDMEVR");
			params.put("security", "S");
			params.put("create", "C");
			params.put("delete", "D");
			params.put("modify", "M");
			params.put("execute", "E");
			params.put("view", "V");
			params.put("read", "R");
			
			params.put("objectType", request.getParameter("objectType"));
			params.put("subjectType", request.getParameter("subjectType"));
			params.put("subjectCode", request.getParameter("subjectCode"));
			params.put("objectIDList", request.getParameter("objectIDList"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			returnList = sysAclSvc.addAclInfo(params);
			
			// acl 동기화
			sysAclSvc.syncAclData(StringUtil.replaceNull(request.getParameter("objectType")), sysAclSvc.getDomainID(StringUtil.replaceNull(request.getParameter("domain"))));
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * setACLInfo : 권한 수정
	 * @param request
	 * @return returnList
	 */
	@RequestMapping(value = "aclManage/setACLInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setACLInfo(HttpServletRequest request) {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			params.put("AclID", request.getParameter("aclID"));
			params.put("AclList", request.getParameter("AclList"));
			params.put("Security", request.getParameter("Security"));
			params.put("Create", request.getParameter("Create"));
			params.put("Delete", request.getParameter("Delete"));
			params.put("Modify", request.getParameter("Modify"));
			params.put("Execute", request.getParameter("Execute"));
			params.put("View", request.getParameter("View"));
			params.put("Read", request.getParameter("Read"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			returnList = sysAclSvc.setACLInfo(params);
			
			// acl 동기화
			sysAclSvc.syncAclData(StringUtil.replaceNull(request.getParameter("objectType")), sysAclSvc.getDomainID(StringUtil.replaceNull(request.getParameter("domain"))));
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getAddList : 권한 추가 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "aclManage/getAddList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAddList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			
			String objectType = request.getParameter("objectType");
			String subjectType = request.getParameter("subjectType");
			String subjectCode = request.getParameter("subjectCode");
			String domain = request.getParameter("domain");
			
			String sortColumn = request.getParameter("sortBy") != null ? request.getParameter("sortBy").split(" ")[0] : "";
			String sortDirection = request.getParameter("sortBy") != null ? request.getParameter("sortBy").split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("objectType", objectType);
			params.put("subjectType", subjectType);
			params.put("subjectCode", subjectCode);
			params.put("domain", domain);
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			if (StringUtil.isNotNull(request.getParameter("searchText"))) {
				params.put("searchText", ComUtils.RemoveSQLInjection(request.getParameter("searchText"), 100));
			}
			
			if (StringUtil.isNotNull(request.getParameter("folderType"))) {
				params.put("folderType", request.getParameter("folderType"));
			}
			
			if (StringUtil.isNotNull(request.getParameter("isAdmin"))) {
				params.put("isAdmin", request.getParameter("isAdmin"));
			}
			
			returnList = sysAclSvc.getAddList(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * getAddTargetList : 권한 추가 대상 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "aclManage/getAddTargetList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getAddTargetList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			
			String sortColumn = request.getParameter("sortBy") != null ? request.getParameter("sortBy").split(" ")[0] : "";
			String sortDirection = request.getParameter("sortBy") != null ? request.getParameter("sortBy").split(" ")[1] : "";
			
			CoviMap params = new CoviMap();
			
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("aclType", request.getParameter("aclType"));
			params.put("domain", request.getParameter("domain"));
			
			params.put("searchText", ComUtils.RemoveSQLInjection(request.getParameter("searchText"), 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			
			returnList = sysAclSvc.getAddTargetList(params);
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * resetAclCache : 권한 캐시 초기화
	 * @param request
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "aclManage/resetAclCache.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap resetAclCache(HttpServletRequest request) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String domainID = sysAclSvc.getDomainID(request.getParameter("domain"));
			
			if (StringUtil.isNull(domainID)) {
				CoviList domainList = cacheLoadSvc.selectDomain(null);
				
				for (int i = 0; i < domainList.size(); i++) {
					CoviMap domainInfo = domainList.getMap(i);
					domainID = domainInfo.getString("DomainID");
					
					sysAclSvc.syncAclData("FD", domainID);
					sysAclSvc.syncAclData("MN", domainID);
				}
			} else {
				sysAclSvc.syncAclData("FD", domainID);
				sysAclSvc.syncAclData("MN", domainID);;
			}
			
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
}
