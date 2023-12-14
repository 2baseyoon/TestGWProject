package egovframework.covision.coviflow.manage.web;

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
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.coviflow.admin.service.AdminDocumentInfoSvc;

@Controller
public class ManageDocumentInfoCon {

	@Autowired
	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(ManageDocumentInfoCon.class);

	@Autowired
	private AdminDocumentInfoSvc adminDocumentInfoSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getJobFunctionListData : 관리자 메뉴 - 결재문서관리툴 : 문서속성 팝업 데이터 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/updateDocData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap updateSecureDoc(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			
			//현재 사용자 ID
			String userID = SessionHelper.getSession("USERID");
			String dataType = request.getParameter("dataType");				// 제목 | 연결문서 | 본문 | 기밀여부 | 첨부파일 | 문서번호
			String formInstID = request.getParameter("FormInstID");
			
			String subjecNm = request.getParameter("SubjecNm");
			String docYn = request.getParameter("DocYn");
			String docNo = request.getParameter("DocNo");
			String bodyContext = request.getParameter("BodyContext");
			String docLinks = request.getParameter("DocLinks");
			String attachFileInfo = request.getParameter("AttachFileInfo");
			
			CoviMap params = new CoviMap();
			
			params.put("userID", userID);
			params.put("dataType", dataType);
			params.put("FormInstID", formInstID);
			
			switch (dataType) {
			case "Subject":
				params.put("SubjecNm", ComUtils.RemoveScriptAndStyle(subjecNm));
				break;
			case "IsSecureDoc":
				params.put("DocYn", docYn);
				break;
			case "DocNo":
				params.put("DocNo", ComUtils.RemoveScriptAndStyle(docNo));
				break;
			case "BodyContext":
				params.put("BodyContext", bodyContext);
				break;
			case "DocLinks":
				params.put("DocLinks", ComUtils.RemoveScriptAndStyle(docLinks));
				break;
			case "AttachFileInfo":
				params.put("AttachFileInfo", ComUtils.RemoveScriptAndStyle(attachFileInfo));
				break;
			default:
				break;
			}
			adminDocumentInfoSvc.updateDocData(params);

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	/**
	 * getJobFunctionListData : 관리자 메뉴 - 결재문서관리툴 : 문서속성 팝업 문서삭제마킹
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/deleteMarkingDel.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteMarkingDel(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			//현재 사용자 ID
			String   userID 				= SessionHelper.getSession("USERID");
			String   formInstID 			= request.getParameter("FormInstID");

			CoviMap params = new CoviMap();

			params.put("userID", userID);
			params.put("FormInstID", formInstID);

			int result = adminDocumentInfoSvc.deleteMarkingDel(params);

			returnData.put("data", result);
			returnData.put("result", "ok");

			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	/**
	 * getJobFunctionListData : 관리자 메뉴 - 결재문서관리툴 : 문서속성 팝업 문서삭제마킹
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/markingRollBack.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap markingRollBack(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();
		try {
			//현재 사용자 ID
			String   userID 				= SessionHelper.getSession("USERID");
			String   formInstID 			= request.getParameter("FormInstID");

			CoviMap params = new CoviMap();
			params.put("userID", userID);
			params.put("FormInstID", formInstID);

			int result = adminDocumentInfoSvc.markingRollBack(params);

			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	/**
	 * getJobFunctionListData : 관리자 메뉴 - 결재문서관리툴 : 문서속성 팝업 문서완전삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/deleteClearDel.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteClearDel(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			//현재 사용자 ID
			String   userID 				= SessionHelper.getSession("USERID");
			String   formInstID 			= request.getParameter("FormInstID");

			CoviMap params = new CoviMap();
			params.put("userID", userID);
			params.put("FormInstID", formInstID);

			int result = adminDocumentInfoSvc.deleteClearDel(params);
			returnData.put("data", result);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
}
