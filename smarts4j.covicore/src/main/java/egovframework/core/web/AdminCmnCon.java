package egovframework.core.web;

import java.util.Locale;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.core.sevice.OrganizationManageSvc;
import egovframework.coviframework.util.AuthHelper;

/**
 * @Class Name : AdminCmnCon.java
 * @Description : 관리자 페이지 이동 요청 처리
 * @Modification Information 
 * @ 2016.04.04 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.04
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class AdminCmnCon {

	private Logger LOGGER = LogManager.getLogger(AdminCmnCon.class);
	
	@Autowired
	private OrganizationManageSvc organizationManageSvc;
	
	@Autowired
	private AuthHelper authHelper;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	//관리자 메인
	@RequestMapping(value = "/admin.do")
	public ModelAndView adminPage(Locale locale, Model model) {

		String returnURL = "home/adminhome.admin";
		ModelAndView mav = new ModelAndView(returnURL);

		return mav;
	}
	
	/**
	 * 관리자 레이아웃  Header 조회
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/adminheader.do")
	public ModelAndView adminHeader(Locale locale, Model model) throws Exception {
		//전체 메뉴에서 home의 top값과 topsub값을 쿼리
	    CoviList jsonList = new CoviList();
	    //jsonList = authHelper.getCachedTopMenu(SessionHelper.getSession("USERID"), locale.getLanguage());
	    jsonList = authHelper.getRedisCachedTopMenu(SessionHelper.getSession("USERID"), locale.getLanguage()); //하드코딩을 제거 할 것
	    
		String returnURL = "cmmn/menu/adminheader";
		//String listdata = "[{label:'관리홈', url:'admin.do'},{label:'시스템 관리', url:'systemadmin_systemadmin.do'},{label:'메뉴 관리', url:'menumanage_usermenuadmin.do'},{label:'업무시스템 관리', url:'#', cn:[{label:'전자결재', url:'#'},{label:'메일', url:'http://localhost:8080/mail/mailadmin_mailadmin.do?language=" + loc.toString() + "'},{label:'게시', url:'#'}]},{label:'로그 관리', url:'logadmin_logadmin.do'},{label:'통계 관리', url:'staticadmin_staticadmin.do'},{label:'개발지원', url:'devhelper_grid.do'}];";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("adminheader", jsonList);
		
		return mav;
	}
	
	/* 관리자 좌측 공통 요청 처리
	 * 구현 중 - 좌측메뉴의 공통화가 필요 없을 경우 폐기할 것
	 * */
	/*
	@RequestMapping(value = "/adminleft.do", method = RequestMethod.GET)
	public ModelAndView adminLeft(Locale locale, Model model) throws Exception {
		
		String lang;
		Locale loc = LocaleContextHolder.getLocale();
		lang = loc.getLanguage();
		
		Cache cacheAdminMenu = cacheManager.getCache("cacheAdminMenu");
		Element element = cacheAdminMenu.get("AdminTopMenuAuth_" + "Admin"); //하드코딩을 제거 할 것
		CoviList jsonList = new CoviList();
	    if (element != null) {
	    	jsonList = (CoviList)element.getObjectValue();
	    }
	    
		String returnURL = "cmmn/menu/adminheader";
		String listdata = "[{label:'관리홈', url:'admin.do'},{label:'시스템 관리', url:'systemadmin_systemadmin.do'},{label:'메뉴 관리', url:'menumanage_usermenuadmin.do'},{label:'업무시스템 관리', url:'#', cn:[{label:'전자결재', url:'#'},{label:'메일', url:'http://localhost:8080/mail/mailadmin_mailadmin.do?language=" + loc.toString() + "'},{label:'게시', url:'#'}]},{label:'로그 관리', url:'logadmin_logadmin.do'},{label:'통계 관리', url:'staticadmin_staticadmin.do'},{label:'개발지원', url:'devhelper_grid.do'}];";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("adminheader", listdata);
		
		return mav;
	}
	*/
	
	/**
	 * 관리자 레이아웃 Left Menu 조회
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/adminhomeleft.do")
	public ModelAndView adminHomeLeft(Locale locale, Model model) throws Exception{
		
		String returnURL = "cmmn/menu/adminhomeleft";
		
		//전체 메뉴에서 home의 left값과 left의 left값을 쿼리
	    CoviList resultList = new CoviList();
	    //resultList = authHelper.getCachedLeftMenu(SessionHelper.getSession("USERID"), "1", locale.getLanguage());
	    resultList = authHelper.getRedisCachedLeftMenu(SessionHelper.getSession("USERID"), "1", locale.getLanguage());
	    
		//String listdata = "[{label:'라이선스 관리', url:'#'},{label:'사용자 정보', url:'#'}]";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("adminleft", resultList);
		
		return mav;
	}
	
	
	/**
	 * 개발 지원 메뉴 페이지 호출 처리 {strPage}에 들어가는 이름의 jsp파일 호출
	 * @param strPage
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "/devhelper_{strPage}.do", method = RequestMethod.GET)
	public ModelAndView devhelperadminview(@PathVariable String strPage, Locale locale, Model model) {
		String returnURL = "devhelper/" + strPage + ".admin";
		
		ModelAndView mav = new ModelAndView(returnURL);

		return mav;
	}	
	
	
	/**
	 * 개발 지원 Left Menu
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/admindevhelperleft.do", method = RequestMethod.GET)
	public ModelAndView admindevhelperLeft(Locale locale, Model model) throws Exception {
		
		String returnURL = "cmmn/menu/admindevhelperleft";
		//전체 메뉴에서 home의 left값과 left의 left값을 쿼리
	    CoviList resultList = new CoviList();
	    //resultList = authHelper.getCachedLeftMenu(SessionHelper.getSession("USERID"), "24", locale.getLanguage());
	    resultList = authHelper.getRedisCachedLeftMenu(SessionHelper.getSession("USERID"), "24", locale.getLanguage());
	    
		//String listdata = "[{label:'컨트롤', url:'#', menuid:560, cn:[{label:'Grid', url:'devhelper_grid.do'},{label:'Layer Popup', url:'devhelper_layerpopup.do'}, {label:'Tree', url:'devhelper_tree.do'}, {label:'Input', url:'devhelper_input.do'}, {label:'Select', url:'devhelper_select.do'}, {label:'Chart', url:'devhelper_chart.do'}, {label:'Tab', url:'devhelper_tab.do'}]}, {label:'스크립트함수', url:'#', menuid:570, cn:[{label:'문자열', url:'devhelper_string.do'}, {label:'Date', url:'devhelper_date.do'}]},{label:'공용 컨트롤', url:'#', menuid:590, cn:[{label:'조직도', url:'devhelper_orgmap.do'}]},{label:'framework테스트', url:'#', menuid:600, cn:[{label:'다국어', url:'devhelper_dictionary.do'}]}];";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("admindevhelperleft", resultList);
		
		return mav;
	}
		
	/**
	 * 로그관리 메뉴 페이지 호출 처리 {strPage}에 들어가는 이름의 jsp파일 호출
	 * @param strPage
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "/logadmin_{strPage}.do", method = RequestMethod.GET)
	public ModelAndView logadminview(@PathVariable String strPage, Locale locale, Model model) {
		
		LOGGER.info("strPage : " + strPage);
		
		String returnURL = "log/" + strPage + ".admin";
		
		ModelAndView mav = new ModelAndView(returnURL);

		return mav;
	}
	
	/**
	 * 로그관리 Left Menu
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/adminlogleft.do", method = RequestMethod.GET)
	public ModelAndView adminLogLeft(Locale locale, Model model) throws Exception {
		
		String returnURL = "cmmn/menu/adminlogleft";
		//전체 메뉴에서 home의 left값과 left의 left값을 쿼리
	    CoviList resultList = new CoviList();
	    //resultList = authHelper.getCachedLeftMenu(SessionHelper.getSession("USERID"), "17", locale.getLanguage());
	    resultList = authHelper.getRedisCachedLeftMenu(SessionHelper.getSession("USERID"), "17", locale.getLanguage());
	    
		//String listdata = "[{label:'접속 로그', url:'logadmin_connectionlogview.do'},{label:'접속 실패 로그', url:'logadmin_connectionfalselogview.do'},{label:'성능 로그', url:'logadmin_performencelogview.do'},{label:'페이지 이동 로그', url:'logadmin_pagemovelogview.do'},{label:'에러 로그', url:'logadmin_errorlogview.do'},{label:'사용자 정보 처리 로그', url:'logadmin_userinfoforprocessinglogview.do'}];";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("adminlogleft", resultList);
		
		return mav;
	}
	
	/**
	 * 통계 통합
	 * @param strPage
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "/staticadmin_{strPage}.do", method = RequestMethod.GET)
	public ModelAndView staticadminview(@PathVariable String strPage, Locale locale, Model model) {
		String returnURL = "static/" + strPage + ".admin";
		
		ModelAndView mav = new ModelAndView(returnURL);

		return mav;
	}
	
	/**
	 * 통계 관리자 좌측
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/adminstaticleft.do", method = RequestMethod.GET)
	public ModelAndView adminStaticLeft(Locale locale, Model model) throws Exception {
		
		String returnURL = "cmmn/menu/adminstaticleft";
		//전체 메뉴에서 home의 left값과 left의 left값을 쿼리
	    CoviList resultList = new CoviList();
	    //resultList = authHelper.getCachedLeftMenu(SessionHelper.getSession("USERID"), "25", locale.getLanguage());
	    resultList = authHelper.getRedisCachedLeftMenu(SessionHelper.getSession("USERID"), "25", locale.getLanguage());
	    
		//String listdata = "[{label:'사용자 로그온 통계', url:'staticadmin_userlogonstatic.do'},{label:'접속시스템 통계', url:'staticadmin_usersystemstatic.do'},{label:'시스템 사용량 통계', url:'staticadmin_usepagestatic.do'},{label:'시스템 사용현황 관리', url:'#', cn:[{label:'시스템 사용현황 관리', url:'staticadmin_systemusagemanage.do'},{label:'현황 예외자 관리', url:'staticadmin_chargingexceptionmanage.do'}]}];";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("adminstaticleft", resultList);
		
		return mav;
	}
	
	/**
	 * 메뉴 관리 통합
	 * @param strPage
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "/menumanage_{strPage}.do", method = RequestMethod.GET)
	public ModelAndView usermenuadminview(@PathVariable String strPage, Locale locale, Model model) {
		
		LOGGER.info("strPage : " + strPage);
		
		String returnURL = "menumanage/" + strPage + ".admin";
		
		ModelAndView mav = new ModelAndView(returnURL);

		return mav;
	}
	
	/**
	 * 메뉴 관리 좌측
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/adminmenumanageleft.do", method = RequestMethod.GET)
	public ModelAndView adminUserMenuLeft(Locale locale, Model model) throws Exception {
		
		//전체 메뉴에서 home의 left값과 left의 left값을 쿼리
	    CoviList resultList = new CoviList();
	    //resultList = authHelper.getCachedLeftMenu(SessionHelper.getSession("USERID"), "10", locale.getLanguage());
	    resultList = authHelper.getRedisCachedLeftMenu(SessionHelper.getSession("USERID"), "10", locale.getLanguage());
	    
		String returnURL = "cmmn/menu/adminmenumanageleft";
		//String listdata = "[{label:'사용자 메뉴 관리', url:'menumanage_usermenuadmin.do'},{label:'관리자 메뉴 관리', url:'menumanage_adminmenuadmin.do'}];";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("adminmenumanageleft", resultList);
		
		return mav;
	}
	
	//관리자 홈
	@RequestMapping(value = "/home/adminhome.do")
	public ModelAndView adminHome(Locale locale, Model model) {

		String returnURL = "admin/home/adminhome";
		//
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	//시스템 통합
	@RequestMapping(value = "/systemadmin_{strPage}.do", method = RequestMethod.GET)
	public ModelAndView sysAdminview(@PathVariable String strPage, Locale locale, Model model) {
		String returnURL = "system/" + strPage + ".admin";
		
		ModelAndView mav = new ModelAndView(returnURL);

		return mav;
	}
	//시스템 관리자 좌측
	@RequestMapping(value = "/adminsystemleft.do", method = RequestMethod.GET)
	public ModelAndView sysAdminLeft(Locale locale, Model model) throws Exception {
		
		String returnURL = "cmmn/menu/adminsystemleft";
		//전체 메뉴에서 home의 left값과 left의 left값을 쿼리
	    CoviList resultList = new CoviList();
	    //resultList = authHelper.getCachedLeftMenu(SessionHelper.getSession("USERID"), "5", locale.getLanguage());
	    resultList = authHelper.getRedisCachedLeftMenu(SessionHelper.getSession("USERID"), "5", locale.getLanguage());
	    
		//String listdata = "[{label:'기초설정 관리', url:'systemadmin_baseconfigmanage.do'},{label:'다국어 관리', url:'systemadmin_dictionarymanage.do'},{label:'프로그램(모듈) 관리', url:'systemadmin_programmodulemanage.do'},{label:'도메인(회사) 관리', url:'systemadmin_domainmanage.do'},{label:'통합 보안 관리', url:'#', menuid:550, cn:[{label:'IP 접근제어 관리', url:'systemadmin_accessipmanage.do'}, {label:'보안관리', url:'systemadmin_accesssecuritymanage.do'}, {label:'장기 접속제어', url:'systemadmin_accessunusedmanage.do'}, {label:'패스워드 초기화', url:'systemadmin_accesspasswordresetmanage.do'}, {label:'암호 정책 관리', url:'systemadmin_passwordpolicymanage.do'}, {label:'보안코드 관리', url:'systemadmin_securitycodemanage.do'}]}];";
		//String listdata = "[{label:'기초설정 관리', url:'systemadmin_baseconfigmanage.do'},{label:'다국어 관리', url:'systemadmin_dictionarymanage.do'},{label:'프로그램(모듈) 관리', url:'systemadmin_programmodulemanage.do'},{label:'도메인(회사) 관리', url:'systemadmin_domainmanage.do'}];";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("adminsystemleft", resultList);
		
		return mav;
	}
	
	//시스템 관리
	@RequestMapping(value = "system/systemadmin.do", method = RequestMethod.GET)
	public ModelAndView sysAdmin(Locale locale, Model model) {
		String returnURL = "admin/system/systemadmin";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	//기초설정 관리
	@RequestMapping(value = "system/baseconfigmanage.do", method = RequestMethod.GET)
	public ModelAndView baseconfigmanage(Locale locale, Model model) {
		String returnURL = "admin/system/baseconfigmanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	//프로그램(모듈) 관리
	@RequestMapping(value = "system/programmodulemanage.do", method = RequestMethod.GET)
	public ModelAndView programemanage(Locale locale, Model model) {
		String returnURL = "admin/system/programmodulemanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	//다국어 관리
	@RequestMapping(value = "system/dictionarymanage.do", method = RequestMethod.GET)
	public ModelAndView dictionarymanage(Locale locale, Model model) {
		String returnURL = "admin/system/dictionarymanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	//도메인(회사) 관리
	@RequestMapping(value = "system/domainmanage.do", method = RequestMethod.GET)
	public ModelAndView domainmanage(Locale locale, Model model) {
		String returnURL = "admin/system/domainmanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	//IP 접근제어 관리
	@RequestMapping(value = "system/accessipmanage.do", method = RequestMethod.GET)
	public ModelAndView accessipmanage(Locale locale, Model model) {
		String returnURL = "admin/system/accessipmanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	//보안 관리
	@RequestMapping(value = "system/accesssecuritymanage.do", method = RequestMethod.GET)
	public ModelAndView accesssecuritymanage(Locale locale, Model model) {
		String returnURL = "admin/system/accesssecuritymanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	//장기 접속제어
	@RequestMapping(value = "system/accessunusedmanage.do", method = RequestMethod.GET)
	public ModelAndView accessunusedmanage(Locale locale, Model model) {
		String returnURL = "admin/system/accessunusedmanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	//패스워드 초기화
	@RequestMapping(value = "system/accesspasswordresetmanage.do", method = RequestMethod.GET)
	public ModelAndView accesspasswordresetmanage(Locale locale, Model model) {
		String returnURL = "admin/system/accesspasswordresetmanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	//암호 정책 관리
	@RequestMapping(value = "system/passwordpolicymanage.do", method = RequestMethod.GET)
	public ModelAndView passwordpolicymanage(Locale locale, Model model) {
		String returnURL = "admin/system/passwordpolicymanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	//보안코드 관리
	@RequestMapping(value = "system/securitycodemanage.do", method = RequestMethod.GET)
	public ModelAndView securitycodemanage(Locale locale, Model model) {
		String returnURL = "admin/system/securitycodemanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	

	// 통계 관리
	@RequestMapping(value = "static/staticadmin.do", method = RequestMethod.GET)
	public ModelAndView staticadmin(Locale locale, Model model) {
		String returnURL = "admin/static/staticadmin";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	// 사용자 로그온 통계
	@RequestMapping(value = "static/userlogonstatic.do", method = RequestMethod.GET)
	public ModelAndView userlogonstatic(Locale locale, Model model) {
		String returnURL = "admin/static/userlogonstatic";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	// 접속시스템 통계
	@RequestMapping(value = "static/usersystemstatic.do", method = RequestMethod.GET)
	public ModelAndView usersystemstatic(Locale locale, Model model) {
		String returnURL = "admin/static/usersystemstatic";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	// 시스템 사용량 통계
	@RequestMapping(value = "static/usepagestatic.do", method = RequestMethod.GET)
	public ModelAndView usepagestatic(Locale locale, Model model) {
		String returnURL = "admin/static/usepagestatic";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	// 시스템 사용현황 관리
	@RequestMapping(value = "static/systemusagemanage.do", method = RequestMethod.GET)
	public ModelAndView systemusagemanage(Locale locale, Model model) {
		String returnURL = "admin/static/systemusagemanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	// 현황 예외자 관리
	@RequestMapping(value = "static/chargingexceptionmanage.do", method = RequestMethod.GET)
	public ModelAndView chargingexceptionmanage(Locale locale, Model model) {
		String returnURL = "admin/static/chargingexceptionmanage";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	@RequestMapping(value = "common/getuuid.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap getUuid(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			String strResult = UUID.randomUUID().toString();
			
			returnList.put("resultData", strResult);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
		}
		catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
}
