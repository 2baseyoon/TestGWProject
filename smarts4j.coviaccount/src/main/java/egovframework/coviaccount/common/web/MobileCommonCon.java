package egovframework.coviaccount.common.web;

import java.lang.invoke.MethodHandles;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviframework.util.ACLHelper;


@Controller
@RequestMapping("/mobile")
public class MobileCommonCon {
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private AccountUtil accountUtil;
	

	/*
	 *  layout/tiles 처리 시작
	 * 
	 * 
	 */

	//(tiles-left) 햄버거/좌측 메뉴 표시를 위해 메뉴 목록을 조회해서 넘김 
	@RequestMapping(value = "layout/left.do", method = RequestMethod.GET)
	public ModelAndView getLeft(HttpServletRequest request, HttpServletResponse response) throws Exception {
		JSONSerializer jUtil = new JSONSerializer();
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		String domainId = userDataObj.getString("DN_ID");
		
		String menu = ACLHelper.getMenu(userDataObj);
		
		String isAdmin = "N";
		String menuType = "Top";
		String memberOf = "0";
		
		CoviList menuArray = null;
		CoviList queriedMenu = null;
		if (StringUtils.isNoneBlank(menu)) {
			menuArray = jUtil.jsonGetObject(menu);
			queriedMenu = ACLHelper.parseMenu(domainId, isAdmin, menuType, memberOf, menuArray, "M");
		}

		String returnURL = "mobile/MobileLeft";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("MenuData", queriedMenu);
		
		return mav;
	}
	
	//(tiles-content) 상단 메뉴 목록을 조회해서 넘김(list만)
	@RequestMapping(value = "/{programName}/go{pageName}.do", method = RequestMethod.GET)
	public ModelAndView getTopMenu(HttpServletRequest request, HttpServletResponse response,
			@PathVariable String programName,
			@PathVariable String pageName) {
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		
		String domainId = userDataObj.getString("DN_ID");
		String returnURL = "mobile/" + programName + "/" + pageName;
		String hasTopMenu = RedisDataUtil.getBaseConfig("hasTopMenu", domainId);
		if(StringUtils.isBlank(hasTopMenu)) {
			hasTopMenu = "";
		}
		
		ModelAndView mav = new ModelAndView(returnURL);
		if(hasTopMenu.indexOf(programName + "/" + pageName) > -1) {
			mav.addObject("Menu", getTopMenuList(programName, userDataObj));
		}

		if(pageName.equals("write")) {
			//Properties accountProperties = PropertiesUtil.getExtensionProperties();
			
			//mav.addObject("propertyAprv", accountProperties.getProperty("account.approveType.ExpenceApplication"));
			//mav.addObject("propertyOtherApv", accountProperties.getProperty("account.approveType.ExpenceApplication.OtherAPV"));
			
			mav.addObject("propertyAprv", accountUtil.getBaseCodeInfo("eAccApproveType", "ExpenceApplication"));
			mav.addObject("propertyOtherApv", RedisDataUtil.getBaseConfig("eAccOtherApv"));
		}
		
		mav.addObject("useFIDO", PropertiesUtil.getSecurityProperties().getProperty("fido.login.used"));
		mav.addObject("aesSalt", PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt"));
		mav.addObject("aesIv", PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv"));
		mav.addObject("aesKeysize", PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize"));
		mav.addObject("aesIterationCount", PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount"));
		mav.addObject("aesPassPhrase", PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase"));
		
		return mav;
	}
	
	//상단 메뉴를 조회
	private CoviList getTopMenuList(String bizSection, CoviMap userDataObj) {
		CoviList result = null;
		JSONSerializer jUtil = new JSONSerializer();
		String domainId = userDataObj.getString("DN_ID");
		String isAdmin = "N";
		String menuType = "Left";
		
		String menu = "";
		
		try {
			menu = ACLHelper.getMenu(userDataObj);
			
			if (StringUtils.isNoneBlank(menu)) {
				result = jUtil.jsonGetObject(menu);
				result = ACLHelper.parseMenuByBiz(domainId, isAdmin, bizSection, menuType, result, userDataObj.getString("lang"));
			}
		} catch(NullPointerException e){
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return result;
	}
	
	
	
	
	/*
	 *  layout/tiles 처리 끝
	 * 
	 * 
	 */
	
	
	// 일반 페이지 호출 처리 
	// ex> /mobile/board/list.do 
	//       => /mobile/board/list.mobile
	//       => /WEB-INF/views/mobile/board/list.jsp
	@RequestMapping(value = "/{programName}/{pageName}.do", method = RequestMethod.GET)
	public ModelAndView getContent(HttpServletRequest request, HttpServletResponse response, 
				@PathVariable String programName, 
				@PathVariable String pageName) throws Exception {
			
		String returnURL = "mobile/" + programName.toLowerCase() + "/" + pageName + ".mobile";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("QueryString", request.getQueryString());
	
		return mav;
	}
	
	
	

	
	
	
}
