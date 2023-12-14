package egovframework.covision.groupware.board.admin.web;

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
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.covision.groupware.board.admin.service.CategoryManageSvc;

/**
 * @Class Name : CategoryManageCon.java
 * @Description : [관리자] 업무시스템 - 게시 관리 - 폴더/게시판 환경설정 - 확장옵션설정 탭
 * @Modification Information 
 * @ 2017.06.13 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.13
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class CategoryManageCon {
	
	private Logger LOGGER = LogManager.getLogger(CategoryManageCon.class);
	
	@Autowired
	private AuthHelper authHelper;
	
	@Autowired
	CategoryManageSvc categoryManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 게시판 대분류/소분류 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectCategoryList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCategoryList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			String memberOf = request.getParameter("memberOf");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("memberOf", memberOf);

			//이전의 폴더 ID 경로 조회
			result = (CoviList) categoryManageSvc.selectCategoryList(params).get("list");
			
		    returnData.put("categoryList",result);
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
	 * 게시판 대분류/소분류 추가
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/createCategory.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createCategory(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String folderID = request.getParameter("folderID");		//FolderID
			String memberOf = StringUtil.replaceNull(request.getParameter("memberOf"), "");		//상위 폴더ID
			String displayName = request.getParameter("displayName");//표시 이름
			String sortKey = request.getParameter("sortKey");
			String sortPath = request.getParameter("sortPath");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("memberOf", memberOf);
			params.put("displayName", displayName);
			params.put("sortKey", sortKey);
			
			int cnt = categoryManageSvc.createCategory(params);
			if(cnt>0){
				//category의 현재
				if(memberOf.isEmpty()){
					params.put("categoryPath", params.get("categoryID"));
					params.put("sortPath", String.format("%015d", Integer.parseInt(sortKey))+";");
				} else {
					params.put("categoryPath", memberOf+";"+params.get("categoryID"));
					params.put("sortPath", sortPath + String.format("%015d", Integer.parseInt(sortKey))+";");
				}
				categoryManageSvc.updateCategoryPath(params);
			}
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
	 * 게시판 대분류/소분류 수정
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/updateCategory.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateCategory(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String categoryID = request.getParameter("categoryID");		//categoryID
			String displayName = request.getParameter("displayName");	//표시 이름
			
			CoviMap params = new CoviMap();
			params.put("categoryID", categoryID);
			params.put("displayName", displayName);
			
			categoryManageSvc.updateCategory(params);
			
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
	 * 게시판 대분류/소분류 삭제
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deleteCategory.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteCategory(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String categoryID = request.getParameter("categoryID");		//categoryID
			
			CoviMap params = new CoviMap();
			params.put("categoryID", categoryID);
			
			//게시글에 설정된 CategoryID 초기화 이후 삭제처리
			categoryManageSvc.initMessageCategoryID(params);
			categoryManageSvc.deleteCategory(params);
			
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
}
