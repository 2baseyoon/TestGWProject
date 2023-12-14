package egovframework.covision.coviflow.admin.web;


import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.coviframework.util.s3.AwsS3;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.coviflow.admin.service.StampManagerSvc;

@Controller
public class StampManagerCon {
	
	private Logger LOGGER = LogManager.getLogger(StampManagerCon.class);

	AwsS3 awsS3 = AwsS3.getInstance();

	@Autowired
	private StampManagerSvc stampManagerSvc;

	@Autowired
	private FileUtilService fileUtilService;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private static final String SERVICE_TYPE = "ApprovalStamp";
	
	
	/**
	 * getStampList : 직인관리 - 직인 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "admin/getStampList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getStampList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			int pageSize = 1;
			int pageNo =  Integer.parseInt(request.getParameter("pageNo"));
			if (request.getParameter("pageSize") != null && request.getParameter("pageSize").length() > 0){
				pageSize = Integer.parseInt(request.getParameter("pageSize"));	
			}
		
			String entCode = request.getParameter("EntCode");		
			String searchType = request.getParameter("sel_Search");
			String search = request.getParameter("search");
			String sortColumn = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[0];
			String sortDirection = StringUtil.replaceNull(request.getParameter("sortBy")).split(" ")[1];
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("EntCode", entCode);			
			params.put("sel_Search", searchType);
			params.put("search", ComUtils.RemoveSQLInjection(search, 100));
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			
			resultList = stampManagerSvc.getStampList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}
	
	/**
	 * goStampManagerSetPopup : 직인관리 - 직인 정보를 입력하는 팝업 창 표시
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "admin/goStampManagerSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goStampManagerSetPopup(Locale locale, Model model) {
		String returnURL = "admin/approval/StampManagerSetPopup";
		return new ModelAndView(returnURL);
	}
	
	/**
	 * getStampData : 직인관리 - 특정 사용자의 직인 정보 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/getStampData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getStampData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String stampID = request.getParameter("StampID");		
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("StampID", stampID);
			
			resultList = stampManagerSvc.getStampData(params);
			returnList.put("list", resultList.get("map"));	
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;		
	}
	
	/**
	 * insertStampData : 직인관리 - 직인 추가
	 * @param req MultipartHttpServletRequest
	 * @param request HttpServletRequest
	 * @return CoviMap CoviMap
	 */	
	@RequestMapping(value = "admin/insertStampData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertStampData(MultipartHttpServletRequest req,HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			MultipartFile fileInfo = req.getFile("FileInfo");
			
			String stampID = req.getParameter("StampID");
			String entCode = req.getParameter("EntCode");
			String entName = req.getParameter("EntName");
			String stampName = req.getParameter("StampName");
			
			String orderNo  = req.getParameter("OrderNo");
			String useYn = req.getParameter("UseYn");
			String registerID = Objects.toString(SessionHelper.getSession("USERID"),"");
			String modifierID = registerID;
			
			List<MultipartFile> list = new ArrayList<>();
			list.add(fileInfo);
			CoviList savedArray = fileUtilService.uploadToBack(null, list, null, SERVICE_TYPE, "0", "NONE", "0", false, false);
			CoviMap savedFile = savedArray.getJSONObject(0);
			int fileId = savedFile.getInt("FileID");
			
			CoviMap params = new CoviMap();
			params.put("FileInfo", "");
			params.put("FileID", fileId);
			
			params.put("StampID", stampID);
			params.put("EntCode", entCode);
			params.put("EntName", entName);
			params.put("StampName", ComUtils.RemoveScriptAndStyle(stampName));
			
			params.put("OrderNo", orderNo);
			params.put("UseYn", useYn);
			params.put("RegID", registerID);
			params.put("ModID", modifierID);
						
			returnList.put("object", stampManagerSvc.insertStampData(params));		
					
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_Common_10"));// 저장되었습니다.
			
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			LOGGER.error(aioobE.getLocalizedMessage(), aioobE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?aioobE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	
	/**
	 * updateStampData : 직인관리 - 직인 수정
	 * @param req MultipartHttpServletRequest
	 * @param request HttpServletRequest
	 * @return CoviMap CoviMap
	 */	
	@RequestMapping(value = "admin/updateStampData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateStampData(MultipartHttpServletRequest req,HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			MultipartFile fileInfo = req.getFile("FileInfo");
			
			String stampID = req.getParameter("StampID");  
			String entCode = req.getParameter("EntCode");  
			String entName = req.getParameter("EntName");  
			String stampName = req.getParameter("StampName");  
			
			String orderN  = req.getParameter("OrderNo");
			String useYn = req.getParameter("UseYn");
			String modifierID = Objects.toString(SessionHelper.getSession("USERID"),"");
			
			CoviMap params = new CoviMap();
			if(fileInfo != null) {
				List<MultipartFile> list = new ArrayList<>();
				list.add(fileInfo);
				CoviList savedArray = fileUtilService.uploadToBack(null, list, null, SERVICE_TYPE, "0", "NONE", "0", false, false);
				CoviMap savedFile = savedArray.getJSONObject(0);
				int fileId = savedFile.getInt("FileID");
				params.put("FileID", fileId);
			}
			
			params.put("StampID", stampID);
			params.put("EntCode", entCode);
			params.put("EntName", entName);
			params.put("StampName", ComUtils.RemoveScriptAndStyle(stampName));
			
			params.put("OrderNo", orderN);
			params.put("UseYn", useYn);
			params.put("RegID", modifierID);
			params.put("ModID", modifierID);
			
			returnList.put("object", stampManagerSvc.updateStampData(params));		
			
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_Common_10"));// 저장되었습니다.
			
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			LOGGER.error(aioobE.getLocalizedMessage(), aioobE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?aioobE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	/**
	 * deleteStampData : 직인관리 - 직인 삭제
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@javax.transaction.Transactional
	@RequestMapping(value = "admin/deleteStampData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteStampData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String stampID   = request.getParameter("StampID");
			final String FileID   = request.getParameter("FileID");
			String modifierID = Objects.toString(SessionHelper.getSession("USERID"),"");
			
			CoviMap params = new CoviMap();			
			params.put("StampID", stampID);
			params.put("ModID", modifierID);
			
			returnList.put("object", stampManagerSvc.deleteStampData(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_Deleted"));// 삭제되었습니다.

			if(FileID != null && !"".equals(FileID)) {
				fileUtilService.deleteFileByID(FileID, true);
			}
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}	
	
	/**
	 * setUseStampUse : 직인관리 - 직인 사용 여부 변경
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "admin/setUseStampUse.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap setUseStampUse(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String stampID   = request.getParameter("StampID");
			String entCode   = request.getParameter("EntCode");
			String useYn   = request.getParameter("UseYn");
			String modifierID = Objects.toString(SessionHelper.getSession("USERID"),"");
			
			CoviMap params = new CoviMap();
			params.put("StampID",stampID);
			params.put("EntCode",entCode);
			params.put("UseYn", useYn);
			params.put("ModID",modifierID);
			
			returnList.put("object", stampManagerSvc.setUseStampUse(params));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("msg_Common_10"));// 저장되었습니다.
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}		
		return returnList;	
	}	
}
