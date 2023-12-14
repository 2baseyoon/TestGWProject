package egovframework.covision.groupware.collab.user.web;

import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.attend.user.web.AttendAdminSettingCon;
import egovframework.covision.groupware.collab.user.service.CollabAdminSvc;
import egovframework.covision.groupware.collab.user.service.CollabProjectSvc;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

@Controller
@RequestMapping("collabAdmin")
public class CollabAdminCon {
	
	private Logger LOGGER = LogManager.getLogger(AttendAdminSettingCon.class);

    @Autowired
    private CollabAdminSvc collabAdminSvc;
    
    final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
    
    //관리자설정 > 연동설정, 메뉴관리 조회
    @RequestMapping(value = "/getSyncSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCompanySettings(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();

		try {
			
			CoviMap setData = new CoviMap();
			//연동설정
			setData.put("isUseCollabApproval", RedisDataUtil.getBaseConfig("isUseCollabApproval"));
			setData.put("isUseCollabMail", RedisDataUtil.getBaseConfig("isUseCollabMail"));
			setData.put("isUseCollabMessenger", RedisDataUtil.getBaseConfig("isUseCollabMessenger"));
			setData.put("isUseCollabSurvey", RedisDataUtil.getBaseConfig("isUseCollabSurvey"));
			setData.put("isUseCollabSchedule", RedisDataUtil.getBaseConfig("isUseCollabSchedule"));
			
			//메뉴관리
			setData.put("isUseCollabStatMenu", RedisDataUtil.getBaseConfig("isUseCollabStatMenu"));
			setData.put("isUseCollabDescEditor", RedisDataUtil.getBaseConfig("isUseCollabDescEditor"));
			
			returnList.put("data", setData);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", DicHelper.getDic("lbl_BeenView"));	//조회되었습니다
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
    
    //관리자설정 > 연동설정, 메뉴관리 수정 처리
    @RequestMapping(value = "/setSyncSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setSyncSetting(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
			String[] codeArry = {
					"isUseCollabApproval"		//연동설정
					,"isUseCollabMail"
					,"isUseCollabMessenger"
					,"isUseCollabSurvey"
					,"isUseCollabSchedule"
					
					,"isUseCollabStatMenu"		//메뉴관리
					,"isUseCollabDescEditor" 	// 업무설명 에디터 사용여부
				};
			
				CoviList paramArry = new CoviList();
				for(int i=0;i<codeArry.length;i++){
					CoviMap params = new CoviMap();
					String code = codeArry[i];
					params.put("SettingKey", code);
					params.put("SettingValue", request.getParameter(code)==null?"N":request.getParameter(code));
					
					LOGGER.debug("SettingKey: "+params.get("SettingKey"));
					LOGGER.debug("SettingKey: "+params.get("SettingValue"));

					paramArry.add(params);
				}
				
				CoviMap setParams = new CoviMap();
				setParams.put("configList", paramArry);
				
				collabAdminSvc.setSyncSetting(setParams);
				 
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", DicHelper.getDic("msg_Edited"));	//수정되었습니다
			} catch (NullPointerException e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				LOGGER.error(e.getLocalizedMessage(), e);
			}
			
			return returnList;
    }
    
    //개인설정
    @RequestMapping(value = "getCollabUserConf.do", method = RequestMethod.POST)
	public  @ResponseBody CoviMap getCollabUserConf(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap reqMap = new CoviMap();
			reqMap.put("USERID", SessionHelper.getSession("USERID"));
			
			CoviMap data = collabAdminSvc.getCollabUserConf(reqMap);
					
			returnObj.put("data",   data.get("userConf"));
			returnObj.put("status", Return.SUCCESS);
			
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnObj;
	}
    
    //개인설정 변경 처리
    @RequestMapping(value = "/saveCollabUserConf.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap saveCollabUserConf(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		try {
				CoviMap params = new CoviMap();
				params.put("UserCode", SessionHelper.getSession("USERID"));
				params.put("dashThema", request.getParameter("theme"));
				params.put("taskShowCode", request.getParameter("menu"));
				
//				System.out.println("theme : "+params.get("dashThema"));
//				System.out.println("menu : "+params.get("taskShowCode"));
				
				collabAdminSvc.saveCollabUserConf(params);
				 
				returnList.put("result", "ok");
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", DicHelper.getDic("msg_Edited"));	//수정되었습니다
			} catch (NullPointerException e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
				LOGGER.error(e.getLocalizedMessage(), e);
			}
			
			return returnList;
    }

	
}
