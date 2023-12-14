package egovframework.covision.groupware.portal.admin.web;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.portal.admin.service.LayoutManageSvc;

/**
 * @Class Name : LayoutManageCon.java
 * @Description : 레이아웃 관리의 클라이언트 요청 처리
 * @Modification Information 
 * @ 017.05.29 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.05.29
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class LayoutManageCon {
	
	private Logger LOGGER = LogManager.getLogger(LayoutManageCon.class);
	
	@Autowired
	private LayoutManageSvc layoutManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * getLayoutSearchTypeData - 레이아웃 관리 검색 조건 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	/*@RequestMapping(value = "portal/getLayoutSearchTypeData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLayoutSearchTypeData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList searchTypeList = new CoviList();
		
		try {
			//검색조건 SelectBox Binding Data
			CoviMap itme = new CoviMap();
			itme.put("optionValue", "");
			itme.put("optionText", DicHelper.getDic("lbl_selection")); //선택
			searchTypeList.add(itme);
			
			itme.put("optionValue", "DisplayName");
			itme.put("optionText", DicHelper.getDic("lbl_PortalManage_02")); //레이아웃
			searchTypeList.add(itme);
			
			itme.put("optionValue", "RegisterName");
			itme.put("optionText", DicHelper.getDic("lbl_Register")); //등록자
			searchTypeList.add(itme);
			
			returnData.put("searchType",searchTypeList);
			returnData.put("status", Return.SUCCESS);
			
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}*/
	
	
	/**
	 * getlayoutList - 레이아웃 목록 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/getLayoutList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getlayoutList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			String searchType = request.getParameter("searchType");
			String searchWord = request.getParameter("searchWord");
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
			
			CoviMap params = new CoviMap();
			params.put("searchType", searchType);
			params.put("searchWord", ComUtils.RemoveSQLInjection(searchWord, 100));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			
			resultList = layoutManageSvc.getLayoutList(params);

			returnData.put("page", resultList.get("page"));
			returnData.put("list",resultList.get("list"));
			returnData.put("status", Return.SUCCESS);
			
		} catch (ArrayIndexOutOfBoundsException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
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
	 * changeLayoutIsDefault - 레이아웃 기본 여부 변경
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/changeLayoutIsDefault.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap changeLayoutIsDefault(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			String layoutID  = request.getParameter("layoutID"); //삭제할 레이아웃 ID
			
			CoviMap params = new CoviMap();
			
			params.put("layoutID",layoutID);
			layoutManageSvc.changeLayoutIsDefault(params);
			
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
	 * goLayoutManageSetPopup : 레이아웃 관리 - 레이아웃 관리 설정 팝업 표시 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/goLayoutManageSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goLayoutManageSetPopup(Locale locale, Model model) {
		String returnURL = "admin/portal/LayoutManageSetPopup";
		
		return (new ModelAndView(returnURL));
	}
	

	/**
	 * insertLayoutData : 레이아웃 관리 - 레이아웃 추가
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "portal/insertLayoutData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap insertLayoutData(MultipartHttpServletRequest req,HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			MultipartFile fileInfo = req.getFile("thumbnail");       
			String userID = SessionHelper.getSession("USERID");
			String layoutName = req.getParameter("layoutName");  
			String sortKey = req.getParameter("sortKey");  
			String layoutHTML = req.getParameter("layoutHTML");  
			String settingLayoutHTML = req.getParameter("settingLayoutHTML");  
			String isDefault = req.getParameter("isDefault");  
			String isCommunity = req.getParameter("isCommunity");  
			
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");			
			
			String filePath;
			String rootPath;
			String savePath;
			String companyCode = SessionHelper.getSession("DN_Code");
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
			if(osType.equals("WINDOWS"))
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			filePath = RedisDataUtil.getBaseConfig("LayoutThumbnail_SavePath");
			savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("LayoutThumbnail_SavePath");
			
			CoviMap params = new CoviMap();
			if(fileInfo != null){
				long fileSize = fileInfo.getSize();
			
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()) {
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 파일 중복명 처리
	                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
					
	                // 본래 파일명
	                String originalfileName = fileInfo.getOriginalFilename(); 
	                
	                String genId = yyyyMMddhhmmssSSS+"_"+FilenameUtils.getBaseName(originalfileName);
	                
	                // 저장되는 파일 이름
	                String saveFileName = "layout_" + genId + "." + FilenameUtils.getExtension(originalfileName);
	                
	                filePath += saveFileName;
	                savePath += saveFileName; // 저장 될 파일 경로
	                
	                //한글명저장	                 
	                savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
	                fileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
		            params.put("layoutThumbnail", filePath);
				}else{
					params.put("layoutThumbnail","");
				}
				
			}else{
				params.put("layoutThumbnail","");
			}
			
			params.put("userID", userID);
			params.put("layoutName", layoutName);
			params.put("sortKey", sortKey);
			params.put("layoutHTML", layoutHTML);
			params.put("settingLayoutHTML", settingLayoutHTML);
			params.put("isDefault", isDefault);
			params.put("isCommunity", isCommunity);
						
			layoutManageSvc.insertLayoutData(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	
	
	/**
	 * updateLayoutData : 레이아웃 관리 - 레이아웃 수정
	 * @param locale
	 * @param model
	 * @return mav
	 */	
	@RequestMapping(value = "portal/updateLayoutData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap updateLayoutData(MultipartHttpServletRequest req,HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
	
		CoviMap returnList = new CoviMap();
		
		try {
			MultipartFile fileInfo = req.getFile("thumbnail");       
			String userID = SessionHelper.getSession("USERID");
			String layoutID = req.getParameter("layoutID");  
			String layoutName = req.getParameter("layoutName");  
			String sortKey = req.getParameter("sortKey");  
			String layoutHTML = req.getParameter("layoutHTML");  
			String settingLayoutHTML = req.getParameter("settingLayoutHTML");  
			String isDefault = req.getParameter("isDefault");  
			String isCommunity = req.getParameter("isCommunity");  
			
			String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");			
			
			String filePath;						
			String rootPath;
			String savePath;
			String companyCode = SessionHelper.getSession("DN_Code");
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
			if(osType.equals("WINDOWS"))
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachWINDOW.path");
			else
				rootPath = PropertiesUtil.getGlobalProperties().getProperty("attachUNIX.path");
			
			filePath = RedisDataUtil.getBaseConfig("LayoutThumbnail_SavePath");
			savePath = rootPath + backStorage + RedisDataUtil.getBaseConfig("LayoutThumbnail_SavePath");
			
			CoviMap params = new CoviMap();
			if(fileInfo != null){
				long fileSize = fileInfo.getSize();
			
				if(fileSize > 0){
					File realUploadDir = new File(FileUtil.checkTraversalCharacter(savePath));
					//폴더가없을 시 생성
					if(!realUploadDir.exists()){
						if(realUploadDir.mkdirs()) {
							LOGGER.info("path : " + realUploadDir + " mkdirs();");
						}
					}
					
					// 파일 중복명 처리
	                String yyyyMMddhhmmssSSS = DateHelper.getCurrentDay("yyyyMMddhhmmssSSS");
					
	                // 본래 파일명
	                String originalfileName = fileInfo.getOriginalFilename(); 
	                
	                String genId = yyyyMMddhhmmssSSS+"_"+FilenameUtils.getBaseName(originalfileName);
	                
	                // 저장되는 파일 이름
	                String saveFileName = "layout_" + genId + "." + FilenameUtils.getExtension(originalfileName);
	                
	                filePath += saveFileName;
	                savePath += saveFileName; // 저장 될 파일 경로
	                
	                //한글명저장	                 
	                savePath = new String(savePath.getBytes(StandardCharsets.UTF_8),"UTF-8");
	                fileInfo.transferTo(new File(FileUtil.checkTraversalCharacter(savePath))); // 파일 저장
		            params.put("layoutThumbnail", filePath);
				}
				
			}
			
			params.put("userID", userID);
			params.put("layoutID", layoutID);
			params.put("layoutName", layoutName);
			params.put("sortKey", sortKey);
			params.put("layoutHTML", layoutHTML);
			params.put("settingLayoutHTML", settingLayoutHTML);
			params.put("isDefault", isDefault);
			params.put("isCommunity", isCommunity);
						
			layoutManageSvc.updateLayoutData(params);
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
		} catch (IOException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	
	/**
	 * deletePortalData - 레이아웃 관리 - 레이아웃 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/deleteLayoutData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deletePortalData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String[] layoutID  = StringUtil.replaceNull(request.getParameter("layoutID"), "").split(";"); //삭제할 포탈 ID
			StringBuilder notRemove = new StringBuilder("");
			int removeCnt = 0;
			CoviMap params = new CoviMap();
			
			int cnt = 0;
			for(int i = 0; i < layoutID.length; i++){
				params.put("layoutID",layoutID[i]);
				cnt = layoutManageSvc.checkUsing(params);
				if(cnt<=0){
					removeCnt+=layoutManageSvc.deleteLayoutData(params);
				}else{
					notRemove.append(layoutID[i]).append(";");
				}
			}
			if(!notRemove.toString().equals("")){
				notRemove = new StringBuilder(notRemove.substring(0,notRemove.length()-1));
			}
			
			returnData.put("remove", removeCnt);
			returnData.put("notRemove", notRemove.toString());
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
	 * getLayoutData - 레이아웃 정보조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "portal/getLayoutData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getLayoutData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			String layoutID  = request.getParameter("layoutID"); 
			
			CoviMap params = new CoviMap();
			params.put("layoutID", layoutID);
			
			resultList = layoutManageSvc.getLayoutData(params);
			
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
}
