package egovframework.covision.groupware.approval.user.web;

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
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.approval.user.service.ApprovalSvc;

@Controller
public class ApprovalDoCon {
	private Logger LOGGER = LogManager.getLogger(ApprovalDoCon.class);
	
	@Autowired
	private ApprovalSvc approvalSvc;
	
	/** 
	 * getLastestUsedFormListData : 결재문서작성 : 최근사용양식조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return JSONObject
	 * @throws Exception
	 */
	
	@RequestMapping(value = "approval/getLastestUsedFormListData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLastestUsedFormListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try
		{
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));

			resultList = approvalSvc.selectLastestUsedFormListData(params);
			
			returnList.put("list",resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}
		
		return returnList;
	}
	
	/** 
	 * getFavoriteUsedFormListData : 결재문서작성 : 즐겨찾기조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return JSONObject
	 * @throws Exception
	 */
	
	@RequestMapping(value = "approval/getFavoriteUsedFormListData.do")
	public @ResponseBody CoviMap getFavoriteUsedFormListData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		
		try
		{
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			resultList = approvalSvc.selectFavoriteUsedFormListData(params);
			returnList.put("list",resultList);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}
		
		return returnList;
	}
	
	/**
	 * 사용자 프로필 개인함 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "approval/getMyInfoProfileApprovalData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyInfoProfileApprovalData(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList returnList = new CoviList();
		
		String targetCode = request.getParameter("userCode");
		
		try {
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("targetCode", targetCode);
			
			returnList = approvalSvc.selectMyInfoProfileApprovalData(params);
			
			returnData.put("list", returnList);
			returnData.put("status", Return.SUCCESS);
		} catch(NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", e.getMessage());
		} catch(Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", e.getMessage());
		}
		return returnData;
	}
	
}
