package egovframework.covision.coviflow.manage.web;


import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.admin.service.RuleManagementSvc;


 
@Controller
public class RuleManagementManageCon {
	private static final Logger LOGGER = LogManager.getLogger(RuleManagementManageCon.class);
			
	@Autowired
	private RuleManagementSvc ruleManagementSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
 
		
	// 관리자 > 마스터 관리 리스트 
	@RequestMapping(value = "manage/getMasterManagementList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMasterManagementList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			String entCode = request.getParameter("entCode");
			String searchType = StringUtil.replaceNull(request.getParameter("sel_Search"));//검색 구분(구분/명칭)
			String gubun =""; //구분 선택경우
			String search = request.getParameter("search");//검색어
	
			if(searchType.equals("BizRuleType")) {
				gubun = search;
			}
				
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];

			CoviMap params = new CoviMap();

			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("entCode", entCode);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("sel_Search", searchType);
			params.put("sel_Type", gubun);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			
			CoviMap resultList = ruleManagementSvc.getMasterManagementList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 관리자 > 마스터 관리 리스트 > 추가, 수정, 삭제 팝업
	@RequestMapping(value = "manage/getMasterManagementPopup.do", method = RequestMethod.GET)
	public ModelAndView goMasterManagementPopup(Locale locale, Model model) {
		String rtnUrl = "manage/approval/MasterManagementPopup";
		return new ModelAndView(rtnUrl);
	}
	
	// 관리자 > 마스터 관리 리스트 > 추가
	@RequestMapping(value = "manage/insertMasterManagement.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertMasterManagement(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
 
		try {			
			String entCode = request.getParameter("entCode");
			String ruleName = request.getParameter("ruleName");
			String ruleType = request.getParameter("ruleType");
			String mappingCode = request.getParameter("mappingCode");
		 						
			CoviMap params = new CoviMap();
			params.put("entCode", entCode);
			params.put("ruleName", ComUtils.RemoveScriptAndStyle(ruleName));
			params.put("ruleType", ruleType);
			params.put("mappingCode", mappingCode);
			
			int result = ruleManagementSvc.insertMasterManagement(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "추가 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}	
	
	// 관리자 > 마스터 관리 리스트 > 수정
	@RequestMapping(value = "manage/updateMasterManagement.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateMasterManagement(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
	 
		try {
			String ruleId = request.getParameter("ruleId");
			String ruleName = request.getParameter("ruleName");
			String ruleType = request.getParameter("ruleType");
			String mappingCode = request.getParameter("mappingCode");
 
			CoviMap params = new CoviMap();
			params.put("ruleId", ruleId);
			params.put("ruleName", ComUtils.RemoveScriptAndStyle(ruleName));
			params.put("ruleType", ruleType);
			params.put("mappingCode", mappingCode);
 	
			//validation check
			int result = ruleManagementSvc.updateMasterManagement(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 관리자 > 마스터 관리 리스트 > 삭제
	@RequestMapping(value = "manage/deleteMasterManagement.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteMasterManagement(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			String ruleId = request.getParameter("ruleId");
			
			CoviMap params = new CoviMap();
			params.put("ruleId", ruleId);
		
			int result = ruleManagementSvc.deleteMasterManagement(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "삭제 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 관리자 > 마스터 관리 리스트 > mapping 팝업 리스트
	@RequestMapping(value = "manage/getMappingList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getMappingList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String ruleId = request.getParameter("ruleId");
			
			CoviMap params = new CoviMap();
			params.put("ruleId", ruleId);
			
			CoviMap resultList = ruleManagementSvc.getMappingList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 관리자 > 마스터 관리 리스트 > mapping 팝업 > 추가
	@RequestMapping(value = "manage/insertMapping.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertMapping(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="paramArr[]", required=false) String[] paramArr) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("paramArr", paramArr);
		
			int result = ruleManagementSvc.insertMapping(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "추가 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 관리자 > 마스터 관리 리스트 > mapping 팝업 > 삭제
	@RequestMapping(value = "manage/deleteMapping.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteMapping(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="paramArr[]", required=false) String[] paramArr) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("paramArr", paramArr);
		
			int result = ruleManagementSvc.deleteMapping(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "삭제 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 관리자 > 마스터 관리 리스트 > mapping 팝업(직위)
	@RequestMapping(value = "manage/getRankPopup.do", method = RequestMethod.GET)
	public ModelAndView getRankPopup(Locale locale, Model model) {
		String rtnUrl = "manage/approval/MasterManagementRankPopup";
		return new ModelAndView(rtnUrl);
	}
	
	// 관리자 > 마스터 관리 리스트 > mapping 팝업 리스트(직위)
	@RequestMapping(value = "manage/getRankList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getRankList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String dnId = request.getParameter("dnId");
			
			CoviMap params = new CoviMap();
			params.put("dnId", dnId);
			
			CoviMap resultList = ruleManagementSvc.getRankList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 관리자 > 전결 규정 관리 트리 리스트
	@RequestMapping(value = "manage/getRuleTreeList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getRuleTreeList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String entCode = request.getParameter("entCode");
			
			CoviMap params = new CoviMap();
			params.put("entCode", entCode);
			
			CoviMap resultList = ruleManagementSvc.getRuleTreeList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 관리자 > 전결 규정 관리 트리 리스트 > 추가, 수정 팝업
	@RequestMapping(value = "manage/getRuleManagementTreePopup.do", method = RequestMethod.GET)
	public ModelAndView getRuleManagementTreePopup(Locale locale, Model model) {
		String rtnUrl = "manage/approval/RuleManagementTreePopup";
		return new ModelAndView(rtnUrl);
	}
	
	// 관리자 > 전결 규정 관리 트리 리스트 > 추가
	@RequestMapping(value = "manage/insertRuleTree.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertRuleTree(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			String entCode = request.getParameter("entCode");
			String itemName = request.getParameter("itemName");
			String upperItemId = request.getParameter("upperItemId");
			String docKind = request.getParameter("docKind");
			String itemDesc = request.getParameter("itemDesc");
			String itemType = request.getParameter("itemType");
			String itemCode = request.getParameter("itemCode");
			String upperItemCode = request.getParameter("upperItemCode");
			String sortnum = request.getParameter("sortnum");
			
			CoviMap params = new CoviMap();
			params.put("entCode", entCode);
			params.put("itemName", ComUtils.RemoveScriptAndStyle(itemName));
			params.put("upperItemId", upperItemId);
			params.put("docKind", docKind);
			params.put("itemDesc", ComUtils.RemoveScriptAndStyle(itemDesc));
			params.put("itemType", itemType);
			params.put("itemCode", itemCode);
			params.put("upperItemCode", upperItemCode);
			params.put("sortnum", sortnum);
			
			if(StringUtil.replaceNull(request.getParameter("type")).equals("ACCOUNT")) {
				String accountCode = request.getParameter("AccountCode");
				String accountName = request.getParameter("AccountName");
				String standardBriefID = request.getParameter("StandardBriefID");
				String standardBriefName = request.getParameter("StandardBriefName");
				String groupCode = request.getParameter("GroupCode");
				String groupName = request.getParameter("GroupName");
				String maxAmount = request.getParameter("MaxAmount");
				
				params.put("AccountCode", accountCode);
				params.put("AccountName", accountName);
				params.put("StandardBriefID", standardBriefID);
				params.put("StandardBriefName", standardBriefName);
				params.put("GroupCode", groupCode);
				params.put("GroupName", groupName);
				params.put("MaxAmount", maxAmount);
			}
		
			int cnt = ruleManagementSvc.getRuleCount(params);
			if(cnt > 0) {
				throw new IllegalArgumentException(DicHelper.getDic("msg_apv_adminDupChkCode"));
			}
			
			int result = ruleManagementSvc.insertRuleTree(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "추가 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}	
	
	// 관리자 > 전결 규정 관리 트리 리스트 > 수정
	@RequestMapping(value = "manage/updateRuleTree.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateRuleTree(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			String itemId = request.getParameter("itemId");
			String itemName = request.getParameter("itemName");
			String docKind = request.getParameter("docKind");
			String itemDesc = request.getParameter("itemDesc");
			String itemType = request.getParameter("itemType");
			String itemCode = request.getParameter("itemCode");
			String sortnum = request.getParameter("sortnum");
			
			CoviMap params = new CoviMap();
			params.put("itemId", itemId);
			params.put("itemName", ComUtils.RemoveScriptAndStyle(itemName));
			params.put("docKind", docKind);
			params.put("itemDesc", ComUtils.RemoveScriptAndStyle(itemDesc));
			params.put("itemType", itemType);
			params.put("itemCode", itemCode);
			params.put("sortnum", sortnum);
			
			if(StringUtil.replaceNull(request.getParameter("type")).equals("ACCOUNT")) {
				String accountCode = request.getParameter("AccountCode");
				String accountName = request.getParameter("AccountName");
				String standardBriefID = request.getParameter("StandardBriefID");
				String standardBriefName = request.getParameter("StandardBriefName");
				String groupCode = request.getParameter("GroupCode");
				String groupName = request.getParameter("GroupName");
				String maxAmount = request.getParameter("MaxAmount");
				
				params.put("AccountCode", accountCode);
				params.put("AccountName", accountName);
				params.put("StandardBriefID", standardBriefID);
				params.put("StandardBriefName", standardBriefName);
				params.put("GroupCode", groupCode);
				params.put("GroupName", groupName);
				params.put("MaxAmount", maxAmount);
			}
		
			int result = ruleManagementSvc.updateRuleTree(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 관리자 > 전결 규정 관리 트리 리스트 > 삭제
	@RequestMapping(value = "manage/deleteRuleTree.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteRuleTree(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			String itemId = request.getParameter("itemId");
			
			CoviMap params = new CoviMap();
			params.put("itemId", itemId);
		
			int result = ruleManagementSvc.deleteRuleTree(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "삭제 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 관리자 > 전결 규정 관리 리스트
	@RequestMapping(value = "manage/getRuleGridList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getRuleGridList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}

			String itemId = request.getParameter("itemId");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
		
			CoviMap params = new CoviMap();

			params.put("itemId", itemId);
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			CoviMap resultList = ruleManagementSvc.getRuleGridList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 관리자 > 전결 규정 관리 리스트 > 추가
	@RequestMapping(value = "manage/insertRuleManagement.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap insertRuleManagement(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			String apvName = request.getParameter("apvName");
			String itemId = request.getParameter("itemId");
			String itemCode = request.getParameter("itemCode");
			String ruleId = StringUtil.replaceNull(request.getParameter("ruleId"));
			String apvType = request.getParameter("apvType");
			String sort = request.getParameter("sort");
			String apvDesc = request.getParameter("apvDesc");
			String apvClass = request.getParameter("apvClass");
			String apvClassAtt01 = request.getParameter("apvClassAtt01");
			
			CoviMap params = new CoviMap();
			params.put("apvName", ComUtils.RemoveScriptAndStyle(apvName));
			params.put("itemId", itemId);
			params.put("itemCode", itemCode);
			params.put("ruleId", (ruleId.isEmpty()) ?  "0" : ruleId);
			params.put("apvType", apvType);
			params.put("sort", sort);
			params.put("apvDesc", ComUtils.RemoveScriptAndStyle(apvDesc));
			params.put("apvClass", apvClass);
			params.put("apvClassAtt01", apvClassAtt01);
		
			int result = ruleManagementSvc.insertRuleManagement(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "추가 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 관리자 > 전결 규정 관리 리스트 > 수정
	@RequestMapping(value = "manage/updateRuleManagement.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateRuleManagement(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			String apvId = request.getParameter("apvId");
			String apvName = request.getParameter("apvName");
			String ruleId = request.getParameter("ruleId");
			String apvType = request.getParameter("apvType");
			String sort = request.getParameter("sort");
			String apvDesc = request.getParameter("apvDesc");
			String apvClass = request.getParameter("apvClass");
			String apvClassAtt01 = request.getParameter("apvClassAtt01");
			
			CoviMap params = new CoviMap();
			params.put("apvId", apvId);
			params.put("apvName", ComUtils.RemoveScriptAndStyle(apvName));
			params.put("ruleId", ruleId);
			params.put("apvType", apvType);
			params.put("sort", sort);
			params.put("apvDesc", ComUtils.RemoveScriptAndStyle(apvDesc));
			params.put("apvClass", apvClass);
			params.put("apvClassAtt01", apvClassAtt01);
		
			int result = ruleManagementSvc.updateRuleManagement(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "수정 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 관리자 > 전결 규정 관리 리스트 > 삭제
	@RequestMapping(value = "manage/deleteRuleManagement.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteRuleManagement(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="paramArr[]", required=true) String[] paramArr) throws Exception {
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			params.put("paramArr", paramArr);
		
			int result = ruleManagementSvc.deleteRuleManagement(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "삭제 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	// 관리자 > 전결 규정 관리 리스트 > 추가 팝업
	@RequestMapping(value = "manage/getRuleManagementPopup.do", method = RequestMethod.GET)
	public ModelAndView goRuleManagementPopup(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String rtnUrl = "manage/approval/RuleManagementGridPopup";
		ModelAndView mav = new ModelAndView(rtnUrl);
		
		CoviMap params = new CoviMap();
		params.put("EntCode", request.getParameter("entcode"));
		CoviMap resultList = ruleManagementSvc.getRuleForSelBox(params);
		if (((CoviList)resultList.get("list")).isEmpty()) {
			CoviMap tempObj = new CoviMap();
			tempObj.put("RuleID", "-1");
			tempObj.put("RuleName", "");
			resultList.put("list", tempObj);
		}

		String sApvID = request.getParameter("apvid");
		resultList.put("apvId", sApvID);
		
		if (!"".equals(sApvID)) {
			params = new CoviMap();
			params.put("apvId", sApvID);
			CoviMap tempObj = ruleManagementSvc.selectRuleManagement(params);
			resultList.put("info", tempObj);
		}
		else {
			resultList.put("info", "");
		}
		mav.addObject("ruleList", resultList);
		
		return mav;
	}
	
	// 관리자 > 결재양식자동생성 > 양식 관리 리스트 팝업 > 부가 정보 > 전결 규정
	@RequestMapping(value = "manage/getRuleForForm.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getRuleForForm(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String entCode = request.getParameter("entCode");
			String itemType = request.getParameter("itemType");
			
			CoviMap params = new CoviMap();
			params.put("entCode", entCode);
			params.put("itemType", itemType);
			
			CoviMap resultList = ruleManagementSvc.getRuleForForm(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	// 사용자 > 작성 > 전결규정 팝업 > 전결규정 리스트
	@RequestMapping(value = "manage/getApvRuleList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getApvRuleList(HttpServletRequest request, HttpServletResponse response, @RequestParam(value="paramArr[]", required=true) String[] paramArr) throws Exception {
		CoviMap returnList = new CoviMap();
			
		try {
			CoviMap params = new CoviMap();
			params.put("paramArr", paramArr);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
		
			CoviMap resultList = ruleManagementSvc.getApvRuleList(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	// 사용자 > 작성 > 전결규정 팝업 > 선택시 폼에 세팅할 데이터 조회
	@RequestMapping(value = "manage/getApvRuleListForForm.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getApvRuleListForForm(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String itemCode = request.getParameter("itemCode");
			String grCode = request.getParameter("grCode");
			
			CoviMap params = new CoviMap();
			params.put("itemCode", itemCode);
			params.put("grCode", grCode);
		
			CoviMap resultList = ruleManagementSvc.getApvRuleListForForm(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 관리자 > 수정 > 전결규정 수정 팝업 > e-Accounting 등 기타 모듈을 위한 전결규정 추가 데이터 조회
	@RequestMapping(value = "manage/getItemMoreInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getItemMoreInfo(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			//TO-BE : ItemCode 를 유일값으로 변경하여 ItemCode 만으로 조회하도록 개선 필요
			String itemId = request.getParameter("itemId");
			String itemCode = request.getParameter("itemCode");
			String entCode = request.getParameter("entCode");
			
			CoviMap params = new CoviMap();
			params.put("itemId", itemId);
			params.put("itemCode", itemCode);
			params.put("entCode", entCode);
		
			CoviMap resultList = ruleManagementSvc.getItemMoreInfo(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	@RequestMapping(value = "manage/getNextItemCode.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getNextItemCode(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String upperItemCode = request.getParameter("upperItemCode");
			String depth = request.getParameter("depth");
			String entCode = request.getParameter("entCode");
			
			CoviMap params = new CoviMap();
			params.put("upperItemCode", upperItemCode);
			params.put("depth", depth);
			params.put("entCode", entCode);
			
			CoviMap resultList = ruleManagementSvc.getNextItemCode(params);
			
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회 되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	//전결규정 엑셀팝업 창, ysyi
	@RequestMapping(value = "manage/goRuleManageExcelPopup.do", method = RequestMethod.GET)
	public ModelAndView goRuleManageExcelPopup(Locale locale, Model model) {
		String rtnUrl = "manage/approval/RuleManageExcelPopup";
		return new ModelAndView(rtnUrl);
	}
	
	//전결규정 버전관리 창, ysyi
	@RequestMapping(value = "manage/goRuleManageVersionPopup.do", method = RequestMethod.GET)
	public ModelAndView goRuleManageVersionPopup(Locale locale, Model model) {
		String rtnUrl = "manage/approval/RuleManageVersionPopup";
		return new ModelAndView(rtnUrl);
	}	
	
	
	@RequestMapping(value = "manage/decRequestApproval.do" , method = RequestMethod.POST)
	public @ResponseBody CoviMap fileDecRequestApproval(@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile) throws Exception {
		File originFile = null;
		CoviMap returnData = new CoviMap();
		
		try{
			String backPath = "";
			String frontStoragePath = "";
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
			
			if(osType.equals("UNIX")){
				backPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
				frontStoragePath = PropertiesUtil.getGlobalProperties().getProperty("frontUNIX.path");
	    	}else{
	    		backPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
	    		frontStoragePath = PropertiesUtil.getGlobalProperties().getProperty("frontWINDOW.path");
	    	}
			
			//BackPath = BackPath + RedisDataUtil.getBaseConfig("ApprovalDrm_SavePath");
			backPath= frontStoragePath +"/" ;
			
			// 파일 중복명 처리
			String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
			// 본래 파일명
			String originalfileName = uploadfile.getOriginalFilename();
			
			String genId = yyyyMMddhhmmssSSS + "_" + FilenameUtils.getBaseName(originalfileName);
			// 저장되는 파일 이름
			String saveFileName = genId + "." + FilenameUtils.getExtension(originalfileName);

			String savePath = backPath + saveFileName; // 저장 될 파일 경로
			// 한글명저장
			savePath = new String(savePath.getBytes(StandardCharsets.UTF_8), StandardCharsets.UTF_8);
			originFile = new File(FileUtil.checkTraversalCharacter(savePath));
			uploadfile.transferTo(originFile); // 파일 저장

//			String softcamPropertyPath = RedisDataUtil.getBaseConfig("softcam.Property.Path");
//			String softcamKeyFilePath =  RedisDataUtil.getBaseConfig("softcam.KeyFile.Path");

			String encFilepath = backPath + saveFileName;
			String decFilepath = backPath + saveFileName;
			
//			SLDsFile sFile = new SLDsFile();
//			sFile.SettingPathForProperty(softcamPropertyPath); 
//			int retVal = sFile.CreateDecryptFileDAC (softcamKeyFilePath,"SECURITYDOMAIN",
//					encFilepath,
//					decFilepath);
			
			int retVal = 0;//drm 복화화 성공여부,ysyi 
	  
			if(retVal == 0 || retVal == -36){
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", "DRM removal succeeded. : " + retVal);
			}else{
				returnData.put("status", Return.FAIL);
				returnData.put("message", "DRM removal failed. : " + retVal);
			}
			returnData.put("FilePath", decFilepath);
		}catch(NullPointerException npE){
			returnData.put("status", Return.FAIL);
			returnData.put("message", npE.getMessage());
		}catch(Exception e){
			returnData.put("status", Return.FAIL);
			returnData.put("message", e.getMessage());
		}finally{
			//if (originFile != null) originFile.delete();
		}
		
		return returnData;
	 }
	
	//엑셀업로드
	@RequestMapping(value = "manage/excelUploadRuleManage.do")
	public @ResponseBody CoviMap excelUploadRuleManage(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		File file = null;
		CoviMap returnData = new CoviMap();
		
		try {
			String filePath = new String(org.apache.commons.codec.binary.Base64.decodeBase64(request.getParameter("FilePath")), StandardCharsets.UTF_8);
			String entCode = request.getParameter("entcode");
			
			file = new File(FileUtil.checkTraversalCharacter(filePath));
			
			Path path = Paths.get(file.getPath());
			String name = file.getName();
			String originalFileName = file.getName();
			String contentType = "text/plain";
			byte[] content = null;
	
			content = Files.readAllBytes(path);
			MultipartFile uploadfile = new MockMultipartFile(name, originalFileName, contentType, content);
			
			CoviMap params = new CoviMap();
			params.put("uploadfile", uploadfile);
			params.put("EntCode", entCode);
			params.put("InsertUser", SessionHelper.getSession("USERID"));
			
			CoviList result = ruleManagementSvc.insertRuleManageData(params);
			
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "업로드 되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", npE.getCause().getMessage());
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", e.getCause().getMessage());
		} finally {
			if (file != null) {
				if(!file.delete()) {
					LOGGER.debug("Failed to delete file.[" + file.getAbsolutePath() + "]");
				}
			}
		}
		
		return returnData;
	}
	
	// 전결규정 엑셀 다운로드,ysyi
	@RequestMapping(value = "manage/excelRulManageDownload.do", produces="text/plain;charset=UTF-8")
	public ModelAndView excelRulManageDownload(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView mav = new ModelAndView();
		String returnURL = "UtilExcelView";
		CoviMap resultList = new CoviMap();
		CoviMap viewParams = new CoviMap();
		String entcode = ComUtils.RemoveSQLInjection(request.getParameter("entcode"), 100);
		
		try {
			CoviMap params = new CoviMap();
			params.put("EntCode", entcode);
									
			String[] headerNames = null;
			
			headerNames = new String [] {"code01","code02","code03","code04","code05","name01","name02","name03","name04","name05","charge","approval01","approval02","approval03","approval04","approval05","approval06","approval07","approval08","approval09","approval10"};
			resultList = ruleManagementSvc.geRulManageExcel(params);
			
			viewParams.put("title", "RuleManage");			
			
			viewParams.put("list", resultList.get("list"));
			viewParams.put("cnt", resultList.get("cnt"));
			viewParams.put("headerName", headerNames);
			mav = new ModelAndView(returnURL, viewParams);
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			LOGGER.error(aioobE.getLocalizedMessage(), aioobE);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return mav; 
	}
	
	
	//버전관리 화면 조회
	@RequestMapping(value = "manage/getRulHisotryList.do")
	public @ResponseBody CoviMap getBizDocList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
 			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
			
			String startDate = request.getParameter("startDate");
			if (startDate == null){
				startDate = "";	
			}
			
			String endDate = request.getParameter("endDate");
			if (endDate == null){
				endDate = "";	
			}

			String searchVerNum = request.getParameter("serach_vernum");
			String search = request.getParameter("search");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
		
			CoviMap params = new CoviMap();
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("serach_vernum", searchVerNum);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("startDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(startDate.equals("") ? "" : startDate + " 00:00:00")));
			params.put("endDate",  ComUtils.TransServerTime(ComUtils.ConvertDateToDash(endDate.equals("") ? "" : endDate + " 00:00:00")));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			CoviMap resultList = ruleManagementSvc.getRulHistoryList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	/**
	 * goRuleHisotrySetPopup : 버전관리 - 상세페이지
	 */
	@RequestMapping(value = "manage/goRuleHisotrySetPopup.do", method = RequestMethod.GET)
	public ModelAndView goRuleHisotrySetPopup() {
		String returnURL = "manage/approval/RuleHistorySetPopup";		
		return new ModelAndView(returnURL);
	}	
	
	@RequestMapping(value = "manage/getRulHistoryData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getRulHistoryData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String vernum = request.getParameter("vernum");
			
			CoviMap params = new CoviMap();
		
			params.put("vernum", vernum);		
						
			CoviMap resultList = ruleManagementSvc.getRulHistoryData(params);
						
	
			returnList.put("list", resultList.get("map"));			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
		
	}
	
	@RequestMapping(value = "manage/updateRuleHistoryData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateRuleHistoryData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String verNum  = request.getParameter("VerNum");
			String description  = request.getParameter("Description");
			String isUse  = request.getParameter("IsUse");
 			
			CoviMap params = new CoviMap();
			
			params.put("VerNum"  , verNum);
			params.put("Description"  , ComUtils.RemoveScriptAndStyle(description));	
			params.put("IsUse"  , isUse);
			params.put("UpdateUser", SessionHelper.getSession("USERID"));
			
			returnList.put("object", ruleManagementSvc.updateRulHistoryData(params));
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "수정되었습니다.");
			
		} catch (NullPointerException npE) {
			returnList.put("result", "fail");
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("result", "fail");
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	
	
}
