package egovframework.covision.groupware.board.user.web;

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
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.board.user.service.LeftMenuSvc;

/**
 * @Class Name : LeftMenuCon.java
 * @Description : 게시판 Left Menu Controller
 * @Modification Information 
 * @ 2017.07.26 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 07.26
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class LeftMenuCon {
	
	private Logger LOGGER = LogManager.getLogger(LeftMenuCon.class);
	
	@Autowired
	LeftMenuSvc leftMenuSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 좌측 메뉴 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectBoardLeftMenu.do", method = RequestMethod.GET)
	public @ResponseBody CoviMap selectBoardLeftMenu(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			String bizSection = request.getParameter("bizSection");
			
			CoviMap params = new CoviMap();
			params.put("bizSection", bizSection);	//게시판 메뉴타입: Board
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			resultList = leftMenuSvc.selectBoardLeftMenuList(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			returnData.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
}
