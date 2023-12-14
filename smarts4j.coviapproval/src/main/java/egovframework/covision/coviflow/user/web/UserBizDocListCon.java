package egovframework.covision.coviflow.user.web;


import java.util.Map;

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

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.user.service.UserBizDocListSvc;


@Controller
public class UserBizDocListCon {

	@Autowired
	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(UserBizDocListCon.class);

	@Autowired
	private UserBizDocListSvc userBizDocListSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");

	/**
	 * getBizDocCount : 사용자 메뉴 -업무문서함 : 해당 사용자에게 권한이 부여된 담당업무 개수 조회
	 * @param request
	 * @param response
	 * @param paramMapgetgetBizDocCount
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getBizDocCount.do")
	public @ResponseBody CoviMap getBizDocCount(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();

		try{
			String userCode = SessionHelper.getSession("USERID");
			String bizDocType = request.getParameter("BizDocType");
			if (bizDocType == null) bizDocType = "APPROVAL";

			CoviMap params = new CoviMap();
			params.put("userCode", userCode);
			params.put("bizDocType", bizDocType);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);
			
			int cnt = userBizDocListSvc.selectBizDocCount(params);

			returnList.put("cnt",cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getJobFunctionListData : 사용자 메뉴 -업무문서함 : 해당 사용자에게 권한이 부여된 담당업무 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getBizDocListData.do")
	public @ResponseBody CoviMap getBizDocListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			String userCode = SessionHelper.getSession("USERID");
			String bizDocType = request.getParameter("BizDocType");
			if (bizDocType == null) bizDocType = "APPROVAL";
			
			CoviMap params = new CoviMap();
			params.put("userCode", userCode);
			params.put("bizDocType", bizDocType);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);
			
			resultList = userBizDocListSvc.selectBizDocListData(params);

			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	@RequestMapping(value = "user/getBizDocGroupList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getBizDocGroupList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();

		try	{
			//현재 사용자 ID
			String bizDocCode = request.getParameter("bizDocCode");
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String searchGroupType = StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord = request.getParameter("searchGroupWord");
			String clcikTab	= request.getParameter("clickTab");
			String userCode = SessionHelper.getSession("USERID");
			
			CoviMap params = new CoviMap();

			params.put("userCode", userCode);
			
			params.put("bizDocCode", bizDocCode);
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			params.put("clickTab", clcikTab);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			params.put("isSaaS", isSaaS);


			resultList = userBizDocListSvc.selectBizDocGroupList(params);

			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getJobFunctionApprovalListData : 사용자 메뉴 -업무문서함 : 진행함 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getBizDocProcessListData.do")
	public @ResponseBody CoviMap getBizDocProcessListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{
			String userCode = SessionHelper.getSession("USERID");
			String bizDocCode = StringUtil.replaceNull(request.getParameter("bizDocCode"));
			String searchType =  request.getParameter("searchType");
			String searchWord =  request.getParameter("searchWord");
			String searchGroupType =  StringUtil.replaceNull(request.getParameter("searchGroupType"));
			String searchGroupWord =  request.getParameter("searchGroupWord");
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];

			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}
			
			CoviMap params = new CoviMap();

			params.put("userCode", userCode);
			params.put("isSaaS", isSaaS);
			if(bizDocCode.equals("")){ //bizDocCode값이 없는경우 조회
				CoviList  result 	= new CoviList();
				result = (CoviList) userBizDocListSvc.selectBizDocListData(params).get("list");
				CoviMap jsonobj = result.getJSONObject(0);
				bizDocCode = (String)jsonobj.get("BizDocCode");
				params.put("bizDocCode", bizDocCode);
			}else{
				params.put("bizDocCode", bizDocCode);
			}
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord,100));
			params.put("searchGroupType", searchGroupType);
			if(searchGroupType.equalsIgnoreCase("date") && StringUtil.isNotEmpty(searchGroupWord)) {
				params.put("searchGroupWord", ComUtils.TransServerTime(ComUtils.ConvertDateToDash(searchGroupWord.equals("") ? "" : searchGroupWord + " 00:00:00")));
			}
			else {
				params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			}
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey,100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec,100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("entCode", SessionHelper.getSession("DN_Code"));

			resultList = userBizDocListSvc.selectBizDocProcessListData(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");

		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}

	/**
	 * getJobFunctionApprovalListData : 사용자 메뉴 -업무문서함 : 완료함 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getBizDocCompleteListData.do")
	public @ResponseBody CoviMap getBizDocCompleteListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();

		try{

			String userCode = SessionHelper.getSession("USERID");
			String bizDocCode = StringUtil.replaceNull(request.getParameter("bizDocCode"));
			String searchType =  request.getParameter("searchType");
			String searchWord =  request.getParameter("searchWord");
			String searchGroupType =  request.getParameter("searchGroupType");
			String searchGroupWord =  request.getParameter("searchGroupWord");
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			
			String pageSizeStr = request.getParameter("pageSize");
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (pageSizeStr != null && pageSizeStr.length() > 0){
				pageSize = Integer.parseInt(pageSizeStr);	
			}
			
			CoviMap params = new CoviMap();

			params.put("userCode", userCode);
			params.put("isSaaS", isSaaS);
			if(bizDocCode.equals("")){ //bizDocCode값이 없는경우 조회
				CoviList  result 	= new CoviList();
				result = (CoviList) userBizDocListSvc.selectBizDocListData(params).get("list");
				CoviMap jsonobj = result.getJSONObject(0);
				bizDocCode = (String)jsonobj.get("BizDocCode");
				params.put("bizDocCode", bizDocCode);
			}else{
				params.put("bizDocCode", bizDocCode);
			}
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("searchGroupType", searchGroupType);
			params.put("searchGroupWord", ComUtils.RemoveSQLInjection(searchGroupWord, 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("entCode", SessionHelper.getSession("DN_Code"));
			
			resultList = userBizDocListSvc.selectBizDocCompleteLisData(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list",resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");

		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}
}
