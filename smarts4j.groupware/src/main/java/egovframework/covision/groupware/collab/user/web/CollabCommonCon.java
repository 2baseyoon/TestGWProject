package egovframework.covision.groupware.collab.user.web;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.covision.groupware.collab.user.service.CollabCommonSvc;
import egovframework.covision.groupware.collab.user.service.CollabTodoSvc;
import egovframework.covision.groupware.privacy.user.service.PrivacySvc;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;




// 협업 스페이스 
@Controller
@RequestMapping("collab")
public class CollabCommonCon {
	@Autowired
	private PrivacySvc privacySvc;
	
	@Autowired
	private CollabCommonSvc collabCommonSvc;

	@Autowired
	private CollabTodoSvc collabTodoSvc;

	private Logger LOGGER = LogManager.getLogger(CollabCommonCon.class);
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private static final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
		
	// 로그인 사용자 할당  메뉴
	@RequestMapping(value = "/getUserMenu.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getUserMenu(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
			
		try {
				
			boolean isMobile = ClientInfoHelper.isMobile(request);
//			Object userDataObj = SessionHelper.getSession(isMobile);
			
			CoviMap params = new CoviMap();
			params.put("USERID",SessionHelper.getSession("USERID"));
			params.put("CompanyCode",SessionHelper.getSession("DN_Code"));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("isSaas", isSaaS);
			params.put("menulist", "Y");
//			returnData= privacySvc.getUserBaseGroupAll(params).get("list"));
			returnData= collabCommonSvc.getUserProject(params);
			returnData.put("result", "ok");
			returnData.put("status", Return.SUCCESS);
			//returnData.put("message", DicHelper.getDic("lbl_BeenView"));		//조회되었습니다
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			LOGGER.error(e.getLocalizedMessage(), e);
		}
			
		return returnData;
	}
	//CollabTodo
	@RequestMapping(value = "/CollabTodo.do")
	public ModelAndView CollabTodo(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabTodo";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("tag",collabTodoSvc.tag(params));
		return mav;
	}

	//CollabMain
	@RequestMapping(value = "/CollabMain.do")
	public ModelAndView CollabMain(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabMain";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("tag",collabTodoSvc.tag(params));
		return mav;
	}

	//CollabTmplList
	@RequestMapping(value = "/CollabTmplList.do")
	public ModelAndView CollabTmplList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabTmplList";
		ModelAndView mav	= new ModelAndView(returnURL);
		mav.addObject("tmlpKind",RedisDataUtil.getBaseCode("COLLAB_KIND","0"));
		return mav;
	}
	
	@RequestMapping(value = "/CollabTmplRequest.do")
	public ModelAndView CollabTmplRequest(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabTmplRequest";
		ModelAndView mav	= new ModelAndView(returnURL);
//			mav.addObject("tag",collabTodoSvc.tag(params));
		return mav;
	}

	@RequestMapping(value = "/CollabStatis.do")
	public ModelAndView CollabStatis(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabStatis";
		ModelAndView mav	= new ModelAndView(returnURL);
//			mav.addObject("tag",collabTodoSvc.tag(params));
		return mav;
	}
	
	@RequestMapping(value = "/CollabModHist.do")
	public ModelAndView CollabModHist(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabModHist";
		ModelAndView mav	= new ModelAndView(returnURL);
//			mav.addObject("tag",collabTodoSvc.tag(params));
		return mav;
	}

	@RequestMapping(value = "/CollabMainView.do")
	public ModelAndView CollabMainView(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabMainView";
		ModelAndView mav	= new ModelAndView(returnURL);
		/*if (!ComUtils.nullToString(request.getParameter("prjSeq"),"").equals("")){
			CoviMap data = collabProjectSvc.getProject(Integer.parseInt(request.getParameter("prjSeq")));
			mav.addObject("callBackParam", request.getParameter("callBackParam").replaceAll("&quot;", "\""));
			mav.addObject("prjData", data.get("prjData"));
			mav.addObject("memberList", data.get("memberList"));
			mav.addObject("managerList", data.get("managerList"));
			mav.addObject("userformList", data.get("userformList"));
		}*/
		mav.addObject("tag",collabTodoSvc.tag(params));
		mav.addObject("prjType", request.getParameter("prjType")==null?"P":request.getParameter("prjType"));
		mav.addObject("prjSeq", request.getParameter("prjSeq"));
		mav.addObject("prjName", request.getParameter("prjName"));
		return mav;	
	}
	
	// 프로젝트 대상 팝업
	@RequestMapping(value = "/CollabTargetListPopup.do", method = RequestMethod.GET)
	public ModelAndView CollabTargetListPopup(@RequestParam Map<String, String> paramMap, HttpServletRequest request) throws Exception {
		ModelAndView mav = new ModelAndView("user/collab/CollabTargetListPopup");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	// 프로젝트 대상 태그로 선택 팝업
	@RequestMapping(value = "/CollabTargetTagListPopup.do", method = RequestMethod.GET)
	public ModelAndView CollabTargetTagListPopup(@RequestParam Map<String, String> paramMap, HttpServletRequest request) throws Exception {
		ModelAndView mav = new ModelAndView("user/collab/CollabTargetTagListPopup");
		mav.addAllObjects(paramMap);
		return mav;
	}
	
	// 프로젝트 대상 태그로 변경 팝업
	@RequestMapping(value = "/CollabProfileTagListPopup.do", method = RequestMethod.GET)
	public ModelAndView CollabProfileTagListPopup(@RequestParam Map<String, String> paramMap, HttpServletRequest request) throws Exception {
		ModelAndView mav = new ModelAndView("user/collab/CollabProfileTagListPopup");
		mav.addAllObjects(paramMap);
		return mav;
	}

	@RequestMapping(value = "/getDeptList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getDeptList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			returnList.put("deptList", collabCommonSvc.getDeptListByAuth()); 
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS); 
			//returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch (NullPointerException e) { 
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) { 
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList; 
	}
	
	//관리자설정 화면
	@RequestMapping(value = "/CollabAdmin.do")
	public ModelAndView CollabAdmin(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabAdmin";
		ModelAndView mav	= new ModelAndView(returnURL);
		
		//연동설정
		mav.addObject("isUseCollabApproval", RedisDataUtil.getBaseConfig("isUseCollabApproval"));
		mav.addObject("isUseCollabMail", RedisDataUtil.getBaseConfig("isUseCollabMail"));
		mav.addObject("isUseCollabMessenger", RedisDataUtil.getBaseConfig("isUseCollabMessenger"));
		mav.addObject("isUseCollabSurvey", RedisDataUtil.getBaseConfig("isUseCollabSurvey"));
		mav.addObject("isUseCollabSchedule", RedisDataUtil.getBaseConfig("isUseCollabSchedule"));
		
		//메뉴관리
		mav.addObject("isUseCollabStatMenu", RedisDataUtil.getBaseConfig("isUseCollabStatMenu"));
		
		//템플릿 주요카테고리
		mav.addObject("tmlpKind",RedisDataUtil.getBaseCode("COLLAB_KIND","0"));

		return mav;
	}
	
	//개인설정 화면
	@RequestMapping(value = "/CollabPersonSetting.do")
	public ModelAndView CollabPersonSetting(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String,Object> params) throws Exception {
		String returnURL	= "user/collab/CollabPersonSetting";
		ModelAndView mav	= new ModelAndView(returnURL);
		return mav;
	}
	
}
