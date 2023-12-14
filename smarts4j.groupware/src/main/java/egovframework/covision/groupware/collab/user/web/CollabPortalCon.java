package egovframework.covision.groupware.collab.user.web;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.covision.groupware.collab.user.service.CollabPortalSvc;
import egovframework.covision.groupware.collab.user.service.CollabCommonSvc;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;


// 협업 스페이스 
@Controller
@RequestMapping("collabPortal")
public class CollabPortalCon {
	@Autowired
	private CollabPortalSvc collabPortalSvc;

	@Autowired
	private CollabCommonSvc collabCommonSvc;
	
	private Logger LOGGER = LogManager.getLogger(CollabCommonCon.class);
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
		
	//포탈 메인
	@RequestMapping(value = "/getPortalMain.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getPortalMain(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String userAuth  = collabCommonSvc.getUserAuthType();
		SessionHelper.setSession("isCollabAdmin", userAuth);
		
		CoviMap returnObj = new CoviMap();
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("lang", SessionHelper.getSession("lang"));
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			reqMap.put("pageSize", 4);
			reqMap.put("pageOffset", 0);
			reqMap.put("prjStatus","P".split(","));

			CoviMap data = collabPortalSvc.getPortalMain(reqMap);
			returnObj.put("prjList", data.get("prjList"));
			returnObj.put("deptList", data.get("deptList"));
			returnObj.put("myTaskCnt", data.get("myTaskCnt"));
			returnObj.put("myTaskList", data.get("myTaskList"));
			returnObj.put("myFavorite", data.get("myFavorite"));
			returnObj.put("tmplList", data.get("tmplList"));
			returnObj.put("myConf", data.get("myConf"));
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
		}
		return returnObj;		
	}
}