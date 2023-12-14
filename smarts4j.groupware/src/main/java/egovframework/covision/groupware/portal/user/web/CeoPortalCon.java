package egovframework.covision.groupware.portal.user.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.portal.user.service.CeoPortalSvc;

/**
 * @Class Name : CeoPortalCon.java
 * @Description : ceo 포탈 공통 컨테이너 Controller
 * @Modification Information 
 * @ 2017.06.19 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.19
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class CeoPortalCon {
	
	private Logger LOGGER = LogManager.getLogger(CeoPortalCon.class);
	
	@Autowired
	private CeoPortalSvc ceoPortalSvc;
	
	/**
	 * getDeptVacationList: 회사별 휴가 현황
	 * @return mav
	 * @throws Exception
	@RequestMapping(value = "mycontents/getMyContentSetWebpartList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMyContentSetWebpartList(HttpServletRequest request) throws Exception{
	 */
	@RequestMapping(value = "ceoPortal/getDeptVacationList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDeptVacationList(HttpServletRequest request) throws Exception {
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap(); 
			
			String companycode		= request.getParameter("companycode");
			params.put("companycode",companycode);
			resultList = ceoPortalSvc.getDeptVacationList(params);
			resultList.put("status",	Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		}
		
		return resultList;
	}

}
