package egovframework.covision.groupware.board.user.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.covision.groupware.board.user.service.MessageFavoriteSvc;
import egovframework.covision.groupware.util.BoardUtils;

/**
 * @Class Name : MessageFavoriteCon.java
 * @Description : [사용자] 통합게시 - 게시물 즐겨찾기 관심
 * @Modification Information 
 * @ 2017.08.03 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 08.03
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class MessageFavoriteCon {
	
	private Logger LOGGER = LogManager.getLogger(MessageFavoriteCon.class);
	
	@Autowired
	private AuthHelper authHelper;
	
	@Autowired
	MessageFavoriteSvc messageFavoriteSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 즐겨찾기 게시 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectFavoriteGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectFavoriteGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("lang", SessionHelper.getSession("lang"));
			
			int cnt = messageFavoriteSvc.selectFavoriteGridCount(params);	//조회항목 count
			params.addAll(ComUtils.setPagingData(params,cnt));			//페이징 parameter set
			
			resultList = messageFavoriteSvc.selectFavoriteGridList(params);
			
			returnData.put("page", params);
			returnData.put("list", resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
	
	@RequestMapping(value = "board/createFavorite.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createCategory(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String folderID = request.getParameter("folderID");		//FolderID
			String displayName = request.getParameter("displayName");//표시 이름
			String sortKey = request.getParameter("sortKey");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("displayName", displayName);
			params.put("sortKey", sortKey);
			
			messageFavoriteSvc.createFavorite(params);
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnData;
	}
	
	/**
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/deleteFavorite.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteCategory(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String[] folderIDs = StringUtil.replaceNull(request.getParameter("folderIDs"), "").split(";");
			
			CoviMap params = new CoviMap();
			params.put("folderIDs", folderIDs);
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			messageFavoriteSvc.deleteFavorite(params);
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnData;
	}
}
