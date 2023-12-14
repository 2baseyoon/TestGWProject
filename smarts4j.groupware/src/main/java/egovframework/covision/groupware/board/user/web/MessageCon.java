package egovframework.covision.groupware.board.user.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;

import org.apache.commons.fileupload.disk.DiskFileItem;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.multipart.commons.CommonsMultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.ExcelUtil;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.auth.BoardAuth;
import egovframework.covision.groupware.board.admin.service.BoardManageSvc;
import egovframework.covision.groupware.board.admin.service.MessageManageSvc;
import egovframework.covision.groupware.board.user.service.BoardCommonSvc;
import egovframework.covision.groupware.board.user.service.MessageACLSvc;
import egovframework.covision.groupware.board.user.service.MessageSvc;
import egovframework.covision.groupware.util.BoardUtils;

import egovframework.baseframework.util.json.JSONSerializer;
import java.net.URLDecoder;

/**
 * @Class Name : MessageCon.java
 * @Description : [사용자] 통합게시 - 게시물 조회/관리
 * @Modification Information 
 * @ 2017.06.01 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.01
 * @version 1.0
 * Copyright (C) by Covision All right reserved.
 */
@Controller
public class MessageCon {
	
	private Logger LOGGER = LogManager.getLogger(MessageCon.class);
	
	@Autowired
	private MessageSvc messageSvc;
	
	@Autowired
	MessageACLSvc messageACLSvc;
	
	@Autowired
	MessageManageSvc messageManageSvc;
	
	@Autowired
	private FileUtilService fileSvc;
	
	@Autowired
	AuthorityService authSvc;
	
	@Autowired
	BoardManageSvc boardManageSvc;

	
	@Autowired
	BoardCommonSvc boardCommonSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private static String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");
	
	// Contents -  Folder Grid 조회 //
	
	/**
	 * 게시글 조회자 목록 팝업 호출
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "board/goMessageViewerListPopup.do", method = RequestMethod.GET)
	public ModelAndView goMessageViewerListPopup(HttpServletRequest request, Locale locale, Model model) {
		String returnURL = "board/boardmanage/messageViewerListPopup";
		
		ModelAndView mav = new ModelAndView(returnURL);
				
		return mav;
	}
	
	/**
	 * 문서관리 개정이력 팝업
	 * @param request HttpServletRequest
	 * @param locale Locale
	 * @param model Model
	 * @return mav ModelAndView
	 */
	@RequestMapping(value = "board/goDocInOutHistoryListPopup.do", method = RequestMethod.GET)
	public ModelAndView goDocInOutHistoryListPopup(HttpServletRequest request, Locale locale, Model model) {
		return new ModelAndView("user/board/DocInOutHistoryListPopup");
	}
	
	/**
	 * 게시글 엑셀 다운로드
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return mav ModelAndView
	 */
	@RequestMapping(value = "board/messageListExcelDownload.do" , method = RequestMethod.GET)
	public void messageListExcelDownload(HttpServletResponse response, HttpServletRequest request) {
		
		SXSSFWorkbook resultWorkbook = null;
		CoviMap resultList = new CoviMap();
		try {
			String bizSection = request.getParameter("bizSection");
			String boardType = StringUtil.replaceNull(request.getParameter("boardType"), "");
			String folderType = request.getParameter("folderType");
			String boxType = request.getParameter("boxType");
			String domainID = request.getParameter("domainID");
			String menuID = request.getParameter("menuID");
			String folderID = request.getParameter("folderID");
			String useUserForm = StringUtil.replaceNull(request.getParameter("useUserForm"), "");
			String ufColumn = request.getParameter("ufColumn");
			String searchType = request.getParameter("searchType");
			String searchText = request.getParameter("searchText");
			String startDate = StringUtil.replaceNull(request.getParameter("startDate"),"");
			String endDate = StringUtil.replaceNull(request.getParameter("endDate"),"");
			String approvalStatus = request.getParameter("approvalStatus");
		    String readSearchType = request.getParameter("readSearchType");
			String searchFolderIDs = request.getParameter("searchFolderIDs");
			String grCode = request.getParameter("grCode");
			String multiCategory = request.getParameter("multiCategory");
			
			String sortKey = request.getParameter("sortKey");
			String sortDirec = request.getParameter("sortWay");
			
			String communityID = request.getParameter("communityID");
			
			String menuCode = request.getParameter("menuCode");
			
			// 보안등급 및 열람권한에 맞는 목록 조회 여부
			String IsUseListRestriction = RedisDataUtil.getBaseConfig("IsUseListRestriction", SessionHelper.getSession("DN_ID"));

			CoviMap params = new CoviMap();
			
			params.put("bizSection", bizSection);
			params.put("boardType", boardType);
			params.put("folderType", folderType);
			params.put("boxType", boxType);
			params.put("domainID", domainID);
			params.put("menuID", menuID);
			params.put("folderID", folderID);
			params.put("useUserForm", useUserForm);
			params.put("ufColumn", ufColumn);
			params.put("searchType", searchType);
			params.put("searchText", ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("startDate", startDate);
			params.put("endDate", endDate);
			params.put("approvalStatus", approvalStatus);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("groupCode", SessionHelper.getSession("GR_Code"));
			params.put("communityID", communityID);
		    params.put("readSearchType", readSearchType);
			params.put("searchFolderIDs", searchFolderIDs);
			params.put("grCode", grCode);
			params.put("multiCategory", multiCategory);
			params.put("IsUseListRestriction", "".equals(IsUseListRestriction) ? "N" : IsUseListRestriction); // 보안등급 및 열람권한 조건에 맞는 목록 표시 여부
			params.put("groupPath", SessionHelper.getSession("GR_GroupPath").split(";"));
			params.put("userSecurityLevel", SessionHelper.getSession("SecurityLevel"));
			params.put("excelDown", "Y");
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			// 다차원 분류
			if(params.get("searchFolderIDs") != null && !params.get("searchFolderIDs").equals("")){
				params.put("searchFolderIDArr", Arrays.asList(params.getString("searchFolderIDs").split(",")));
			}
			
			// 다중 카테고리
			if(params.get("multiCategory") != null && !params.get("multiCategory").equals("")){
				params.put("multiCategoryList", Arrays.asList(params.getString("multiCategory").split(";")));
			}
			
			params.put("isSaaS", isSaaS);
			if ("N".equals(isSaaS) && menuCode != null) {
				String orgRootMenuID = RedisDataUtil.getBaseConfig(menuCode, "0");
				params.put("orgRootMenuID", orgRootMenuID);
			}
			
			String excelTitle = "";
			if("DistributeDoc".equals(boardType)){	//배포 문서함
				resultList = messageSvc.selectDistributeGridExcelList(params);
				excelTitle = "Doc";
			} else if(!"Normal".equals(boardType) && !"Doc".equals(boardType)){	//신고, 잠금, 삭제/만료, 수정요청, 내가작성한게시, 예약게시
				BoardUtils.getViewAclData(params);		//sys_object_acl: View 권한을 가지고 있는 게시판 ID 설정
				resultList = messageSvc.selectMessageExcelList(params);
			} else {
				//1:1게시의 경우 게시글 담당자만 조회 가능하도록 OwnerCode항목 split하여 조건문 생성 
				if("OneToOne".equals(folderType)){
					String[] ownerList = messageSvc.selectMessageOwner(params).getString("OwnerCode").split(";");
					params.put("messageOwner", ownerList);
				}
				resultList = messageSvc.selectNormalMessageExcelList(params);
			}
			
			switch (boardType){
			case "MyOwnWrite":	//내가 작성한 게시
				excelTitle = DicHelper.getDic("lbl_MyWriteMsg");
				break;
			case "MyBooking":		//예약 게시
				excelTitle = DicHelper.getDic("lbl_resource_MyBooking");
				break;
			case "RequestModify":  //승인요청
				excelTitle = DicHelper.getDic("lbl_doc_requestBox");
				break;
			case "Scrap":		//스크랩
				excelTitle = DicHelper.getDic("MN_16");
				break;
			case "OnWriting":	//작성중
				excelTitle = DicHelper.getDic("MN_17");
				break;
			case "Approval":	//승인
				excelTitle = DicHelper.getDic("CPMail_mail_approvalReq");
				break;
				
			case "Doc":
			case "DocAuth":	//문서권한
			case "DistributeDoc":	//문서 배포
			case "CheckIn":	
			case "CheckOut":
			case "DocOwner":
			case "DocFavorite":
			case "DocTotal":
				excelTitle = DicHelper.getDic("ACC_lbl_doc");//"Board_" + boardType;
				break;
			case "Normal":
			default:
				excelTitle = request.getParameter("excelTitle") == null? DicHelper.getDic("CPMail_IntergratedPublishing"):request.getParameter("excelTitle");//"Board_" + boardType;
				break;
			}

			Date today = new Date();
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
	        String FileName = "Board_"+boardType+"_"+dateFormat.format(today);
	        FileName = FileName.replaceAll("[\\r\\n]", "");
	        
	        CoviMap configMap = new CoviMap();
	        configMap = boardManageSvc.selectBoardConfig(params);

	        List<HashMap> colInfo = BoardUtils.getBoardExcelItem(boardType, configMap);;
	        if ("Normal".equals(boardType) && "Y".equals(useUserForm)){
	        	
	        	CoviList formList = (CoviList) boardCommonSvc.selectUserDefFieldList(params).get("list");
	        	int userIdx = 2;
	        	for (int j=0; j< formList.size(); j++){
	        		CoviMap formMap = formList.getJSONObject(j);
	        		
	        		if (formMap.getString("IsList").equals("Y")){
	        			HashMap colDtl = new HashMap<String, String>();
	        			colDtl.put("colName",formMap.getString("FieldName")); 
	        			colDtl.put("colWith","150"); 
	        			colDtl.put("colKey","UF_Value"+j);
	        			colDtl.put("colKeyImp","UF_Value"+formMap.getString("UserFormID"));//사용자 옵션 실제 키
	        			
	        			if (formMap.getString("IsOption").equals("Y")){
	        				HashMap colDtlOpt= new HashMap();
		        			CoviList formOptArray = formMap.getJSONArray("Option");
		        			
		        			for (int k=0; k< formOptArray.size(); k++){
		        				CoviMap formOpt = formOptArray.getJSONObject(k);
		        				colDtlOpt.put(formOpt.getString("OptionValue"),formOpt.getString("OptionName"));
		        			}
		        			colDtl.put("colCode",colDtlOpt);
		        			colDtl.put("colFormat","MULTICODE");
	        			}
	        			colInfo.add(userIdx++,colDtl);
	        		}
	        	}	
	        }
	        
	        if (configMap != null && configMap.getString("SortCols") != null && !configMap.getString("SortCols").equals("")){
	        	List<HashMap> colTmpInfo = new java.util.ArrayList<HashMap>();
	        	String[] arrList = configMap.getString("SortCols").split(",");
	        	
	        	for (int i=0; i < arrList.length; i++){	//컨텐츠 앱인 경우 엑셀 순서를 재조정할 수 있다.
	        		for(int j=0; j < colInfo.size(); j++){
	        			HashMap hColInfo = (HashMap)colInfo.get(j);
	        			if (((String)hColInfo.get("colKey")).equals(arrList[i]) 	
	        					|| (hColInfo.get("colKeyImp")!= null && ((String)hColInfo.get("colKeyImp")).equals("UF_Value"+arrList[i]))){
	        				colTmpInfo.add(hColInfo);
	        				break;
	        			}
	        		}
	        	}
	        	colInfo = colTmpInfo;
	        }
    		
			resultWorkbook = ExcelUtil.makeExcelFile(excelTitle, colInfo, (List)resultList.get("list"));
			
			response.setHeader("Content-Disposition", "attachment;fileName=\""+FileName+".xlsx\";");    
			resultWorkbook.write(response.getOutputStream());
			resultWorkbook.dispose(); 
			try { resultWorkbook.close(); } 
			catch(IOException ignore) {LOGGER.error(ignore.getLocalizedMessage(), ignore);}
			catch(Exception ignore) {LOGGER.error(ignore.getLocalizedMessage(), ignore);}
	    } catch (IOException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (NullPointerException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (ParseException e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } catch (Exception e) {
	    	LOGGER.error(e.getLocalizedMessage(), e);
	    } finally {
	        if(resultWorkbook != null) { try { resultWorkbook.close(); }catch(IOException ioe) {LOGGER.error(ioe.getLocalizedMessage(), ioe);}}
	    }
    }
	
	/**
	 * 게시글 목록 조회
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/selectMessageGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			String boardType = request.getParameter("boardType");		//게시판 타입: Normal, 신고, 잠금, 삭제/만료, 수정요청 게시 통계
			String bizSection = request.getParameter("bizSection");			
			String communityId = request.getParameter("communityID");
			
			// 보안등급 및 열람권한에 맞는 목록 조회 여부
			String IsUseListRestriction = RedisDataUtil.getBaseConfig("IsUseListRestriction", SessionHelper.getSession("DN_ID"));
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			params.put("groupCode", SessionHelper.getSession("GR_Code", isMobile));
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			params.put("bizSection", bizSection);
			params.put("IsUseListRestriction", "".equals(IsUseListRestriction) ? "N" : IsUseListRestriction); // 보안등급 및 열람권한 조건에 맞는 목록 표시 여부
			params.put("userSecurityLevel", SessionHelper.getSession("SecurityLevel"));
			params.put("groupPath", SessionHelper.getSession("GR_GroupPath").split(";"));
			params.put("boardType", boardType);
			
			BoardUtils.setRequestParam(request, params);

			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			// 다차원 분류
			if(params.get("searchFolderIDs") != null && !params.get("searchFolderIDs").equals("")){
				params.put("searchFolderIDArr", Arrays.asList(params.getString("searchFolderIDs").split(",")));
			}
			
			// 다중 카테고리
			if(params.get("multiCategory") != null && !params.get("multiCategory").equals("")){
				params.put("multiCategoryList", Arrays.asList(params.getString("multiCategory").split(";")));
			}
			
			if("DistributeDoc".equals(boardType)){	//배포 문서함
				int cnt = messageSvc.selectDistributeGridCount(params);
				params.addAll(ComUtils.setPagingData(params,cnt));
				
				resultList = messageSvc.selectDistributeGridList(params);
			} else if(!"Normal".equals(boardType) && !"Doc".equals(boardType)){	//신고, 잠금, 삭제/만료, 수정요청, 내가작성한게시, 예약게시
				params.put("CommunityID", communityId);
				BoardUtils.getViewAclData(params);		//sys_object_acl: View 권한을 가지고 있는 게시판 ID 설정

				int cnt = messageSvc.selectMessageGridCount(params);
				params.addAll(ComUtils.setPagingData(params,cnt));
				
				resultList = messageSvc.selectMessageGridList(params);
			} else {
				//1:1게시의 경우 게시글 담당자만 조회 가능하도록 OwnerCode항목 split하여 조건문 생성 
				if("OneToOne".equals(params.get("folderType"))){
					String[] ownerList = messageSvc.selectMessageOwner(params).getString("OwnerCode").split(";");
					params.put("messageOwner", ownerList);
				}
				
				// 보안등급 및 열람권한에 맞는 목록 조회 여부를 사용할 때, 관리자 또는 게시판 관리자는 조건과 상관없이 모든 게시물을 조회한다.
				if("Y".equalsIgnoreCase(IsUseListRestriction)) {
					// 게시판 운영자는 해당 폴더의 모든 게시글 조회 가능
						String folderOwnerCode = StringUtil.replaceNull(messageACLSvc.selectFolderOwnerCode(params), "");
						
						if(folderOwnerCode.indexOf(params.getString("userCode") + ";") != -1) {
							params.put("IsUseListRestriction", "N");
						}
				}
				
				int cnt = messageSvc.selectNormalMessageGridCount(params);
				params.addAll(ComUtils.setPagingData(params,cnt));
				
				resultList = messageSvc.selectNormalMessageGridList(params);
			}
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
	
	/**
	 * 게시글 목록 팝업
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/selectSearchMessageGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectSearchMessageGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		try {
			String bizSection = request.getParameter("bizSection");
			String menuID = request.getParameter("menuID");
			String communityID = request.getParameter("communityID");
			String mode = StringUtil.replaceNull(request.getParameter("mode"), "");
			
			CoviMap params = new CoviMap();
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("bizSection", bizSection);
			params.put("menuID", menuID);
			params.put("communityID", communityID);
			
			BoardUtils.setRequestParam(request, params);
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate",ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate",ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			BoardUtils.getViewAclData(params);			//sys_object_acl: View 권한을 가지고 있는 게시판 ID 설정
			int cnt = messageSvc.selectSearchMessageGridCount(params);
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			resultList = messageSvc.selectSearchMessageGridList(params);
			
			if(mode.equals("Approval")){
				CoviList resultArr = resultList.getJSONArray("list");
				
				for(int i = 0; i < resultArr.size(); i++){
					CoviMap jObj = (CoviMap)resultArr.getJSONObject(i);
					
					if(!jObj.getString("FileCnt").equals("0")){
						CoviMap fileParams = new CoviMap();
						
						fileParams.put("ServiceType", bizSection);
						fileParams.put("ObjectID", jObj.getString("FolderID"));
						fileParams.put("ObjectType", "FD");
						fileParams.put("MessageID", jObj.getString("MessageID"));
						fileParams.put("Version", jObj.getString("Version"));
						
						resultArr.getJSONObject(i).put("Files", fileSvc.selectAttachAll(fileParams));
					}
				}
				
				resultList.put("list", resultArr);
			}
			
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
	
	// Contents - 게시글 Grid 조회 종료 //
	
	/**
	 * 이전글/다음글 조회
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/selectPrevNextMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectPrevNextMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			// 보안등급 및 열람권한에 맞는 목록 조회 여부
			String IsUseListRestriction = RedisDataUtil.getBaseConfig("IsUseListRestriction", SessionHelper.getSession("DN_ID"));
			
			CoviMap params = new CoviMap();
			
			params.put("domainID", SessionHelper.getSession("DN_ID", isMobile));
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			params.put("IsUseListRestriction", IsUseListRestriction);
			params.put("userSecurityLevel", SessionHelper.getSession("SecurityLevel"));
			params.put("groupPath", SessionHelper.getSession("GR_GroupPath").split(";"));
			BoardUtils.setRequestParam(request, params);
			BoardUtils.getViewAclData(params); //sys_object_acl: View 권한을 가지고 있는 게시판 ID 설정
			
			//timezone 적용 날짜변환
			if(params.get("startDate") != null && !params.get("startDate").equals("")){
				params.put("startDate", ComUtils.TransServerTime(params.get("startDate").toString() + " 00:00:00"));
			}
			if(params.get("endDate") != null && !params.get("endDate").equals("")){
				params.put("endDate", ComUtils.TransServerTime(params.get("endDate").toString() + " 23:59:59"));
			}
			
			// categoryID가 null(문자열)로 넘어오는 현상 처리
			if (StringUtil.isNull(params.get("categoryID"))) {
				params.remove("categoryID");
			}
			
			CoviMap resultNext;
			CoviMap resultPrev;
			
			//다음글 조회
			if (params.has("nextMessageID")) {
				CoviMap nextMessageParam = new CoviMap();
				nextMessageParam.put("messageID", params.getString("nextMessageID"));
				nextMessageParam.put("version", params.getString("nextMessageVer"));
				resultNext = messageSvc.getMessageInfo(nextMessageParam);
				resultNext.put("RNUM", (int)Float.parseFloat((String)params.get("rNum"))+1);
				returnData.put("next", resultNext);
			}
			else {
				params.put("pageSize", 1);
				
				if(params.has("readSearchType") && "unread".equals(params.getString("readSearchType"))) {
					params.put("pageOffset", (int)Float.parseFloat((String)params.get("rNum"))-1);
					params.put("rowStart", (int)Float.parseFloat((String)params.get("rNum")));
					params.put("rowEnd", (int)Float.parseFloat((String)params.get("rNum")));
				} else {
					params.put("pageOffset", (int)Float.parseFloat((String)params.get("rNum")));
					params.put("rowStart", (int)Float.parseFloat((String)params.get("rNum"))+1);
					params.put("rowEnd", (int)Float.parseFloat((String)params.get("rNum"))+1);
				}
				
				if (!"UserForm".equals(params.getString("searchType"))) {
					params.put("useUserForm", "N");
				}
				
				if ("Normal".equals(params.getString("boardType"))) {
					resultNext =  messageSvc.selectNormalMessageGridList(params);
				} else if("Total".equals(params.getString("boardType"))) {
					params.remove("useTopNotice");
					params.remove("useUserForm");
					params.remove("folderID");
					
					resultNext =  messageSvc.selectMessageGridList(params);
				} else {
					params.remove("useTopNotice");
					params.remove("useUserForm");
					
					resultNext =  messageSvc.selectMessageGridList(params);
				}
				if(((CoviList)resultNext.get("list")).size()>0)
					returnData.put("next", ((CoviList)resultNext.get("list")).get(0));
			}
			
			
			
			//이전글 조회
			if (params.has("prevMessageID")) {
				CoviMap prevMessageParam = new CoviMap();
				prevMessageParam.put("messageID", params.getString("prevMessageID"));
				prevMessageParam.put("version", params.getString("prevMessageVer"));
				resultPrev = messageSvc.getMessageInfo(prevMessageParam);
				resultPrev.put("RNUM", (int)Float.parseFloat((String)params.get("rNum"))-1);
				returnData.put("prev", resultPrev);
			}
			else {
				if((int)Float.parseFloat((String)params.get("rNum")) > 1){
					params.put("pageSize", 1);
					params.put("pageOffset", (int)Float.parseFloat((String)params.get("rNum"))-2);
					
					params.put("rowStart", (int)Float.parseFloat((String)params.get("rNum"))-1);
					params.put("rowEnd", (int)Float.parseFloat((String)params.get("rNum"))-1);
					if("Normal".equals(params.getString("boardType"))){
						resultPrev =  messageSvc.selectNormalMessageGridList(params);
					}
					else
					{
						resultPrev =  messageSvc.selectMessageGridList(params);
					}
					if(((CoviList)resultPrev.get("list")).size()>0)
						returnData.put("prev",((CoviList)resultPrev.get("list")).get(0));
				}
			}
			
			returnData.put("status", Return.SUCCESS);
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NumberFormatException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	/**
	 * 게시 작성/임시저장
	 * @param request MultipartHttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnList JSONObject
	 */
	@RequestMapping(value = "board/createMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createMessage(MultipartHttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params); // parameter 자동 할당
			
			if (params.has("communityId")) {
				params.replace("bizSection", "Community");
			}
			if (BoardUtils.getWriteAuth(params)) {
				List<MultipartFile> mf = request.getFiles("files");
				
				if(!FileUtil.isEnableExtention(mf)){
					returnList.put("status", Return.FAIL);
					returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
					return returnList;
				}
				
				params.put("domainID", SessionHelper.getSession("DN_ID"));
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("groupCode", SessionHelper.getSession("GR_Code"));
				
				// bodyText 길이 1000자로 제한
				params.put("bodyText", ComUtils.substringBytes(params.getString("bodyText"), 1000));
				
				// 예약 게시일
				if(params.get("reservationDate") != null && !params.get("reservationDate").equals("")){
					params.put("reservationLocalDate",ComUtils.TransServerTime(params.get("reservationDate").toString())); 
				}
				
				// 만료일 timezone 적용
				if(params.has("expiredDate") && params.get("expiredDate") != null && !params.get("expiredDate").equals("") && !params.get("expiredDate").equals("9999-12-31 00:00:00")){
					params.put("expiredDate", ComUtils.TransServerTime(params.get("expiredDate").toString())); 
				} else {
					params.put("expiredDate", "9999-12-31 00:00:00");
				}
				
				// 팝업공지 시작/종료일 
				if(params.get("popupStartDate") != null && !params.get("popupStartDate").equals("")){
					params.put("popupStartDate",ComUtils.TransServerTime(params.get("popupStartDate").toString()));
				}
				
				if(params.get("popupEndDate") != null && !params.get("popupEndDate").equals("")){
					params.put("popupEndDate",ComUtils.TransServerTime(params.get("popupEndDate").toString()));
				}
				
				// 상단공지 시작/종료일
				if(params.get("topStartDate") != null && !params.get("topStartDate").equals("")){
					params.put("topStartDate",ComUtils.TransServerTime(params.get("topStartDate").toString()));
				}
				
				if(params.get("topEndDate") != null && !params.get("topEndDate").equals("")){
					params.put("topEndDate",ComUtils.TransServerTime(params.get("topEndDate").toString()));
				}
				
				int cnt = messageSvc.createMessage(params, mf);
				
				if(cnt > 0){
					returnList.put("status", Return.SUCCESS);
					returnList.put("messageID", params.get("messageID"));
					returnList.put("message", "저장되었습니다.");
				} else {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "저장에 실패했습니다.");
				}
			}
			else{
				returnList.put("status", Return.FAIL);//msg_noWriteAuth
				returnList.put("message", DicHelper.getDic("msg_noWriteAuth"));
			}
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			returnList.put("detailMsg", e.getCause().getMessage());
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			returnList.put("detailMsg", e.getCause().getMessage());
		}
		return returnList;
	}
	
	/**
	 * 간편작성
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnList JSONObject
	 */
	@RequestMapping(value = "board/createSimpleMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createSimpleMessage(HttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			String domainID = SessionHelper.getSession("DN_ID");
			params.put("domainID", domainID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("groupCode", SessionHelper.getSession("GR_Code"));
			
			params.put("objectID", params.get("folderID"));
			params.put("objectType", "FD");
			params.put("isInherited", "Y");
			params.put("isApproval", "N");
			params.put("useSecurity", "N");
			params.put("isPopup", "N");
			params.put("isTop", "N");
			params.put("isUserForm", "N");
			params.put("useScrap", "N");
			params.put("useReplyNotice", "N");
			params.put("useCommNotice", "N");
			params.put("useRSS", "N");
			params.put("securityLevel", RedisDataUtil.getBaseConfig("DefaultSecurityLevel",domainID));
			params.put("fileCnt", 0);
			// bodyText 길이 1000자로 제한
			params.put("bodyText", ComUtils.substringBytes(params.getString("bodyText"), 1000));
			params.put("bodySize", params.getString("bodyText").length());
			
			params.put("userCode", SessionHelper.getSession("USERID"));
			CoviMap configMap = boardManageSvc.selectBoardConfig(params);
			
			if(params.getString("bizSection").equalsIgnoreCase("Board") && configMap.getString("UseMessageAuth").equalsIgnoreCase("Y")) {
				CoviList aclArray = authSvc.selectACL(params);
				params.put("aclList", aclArray.toString());
			}
			
			if(params.getString("folderType").equalsIgnoreCase("Anonymous")) {
				params.put("useAnonym", "Y");
			}
			
			int cnt = messageSvc.createSimpleMessage(params);
			
			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("messageID", params.get("messageID"));
				returnList.put("message", "저장되었습니다.");
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "저장에 실패했습니다.");
			}
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
	 * 메일 게시판 이관
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnList JSONObject
	 */
	@RequestMapping(value = "board/createMailToMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createMailToMessage(HttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			String domainID = SessionHelper.getSession("DN_ID");
			int fileCnt = 0;
			List<MultipartFile> mf = new ArrayList<MultipartFile>();
			
			params.put("domainID", domainID);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("groupCode", SessionHelper.getSession("GR_Code"));
			params.put("serviceType", SessionHelper.getSession("Board"));
			
			CoviMap requestParams = new CoviMap();
			requestParams.putAll(params);
			
			boolean writeAuth = BoardAuth.getWriteAuth(params);
			
			if(!writeAuth) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_noWriteAuth"));
			}
			else {
				if(!requestParams.getString("attachFileList").equals("")){
					CoviList attachFileList = requestParams.getJSONArray("attachFileList");
					fileCnt += attachFileList.size();
					
					for(int i = 0; i < attachFileList.size(); i++){
						CoviMap fileInfo = attachFileList.getJSONObject(i);
						String filePath = fileInfo.getString("saveFilePath") +"/"+ fileInfo.getString("saveNewFileName");
						
						File file = new File(FileUtil.checkTraversalCharacter(filePath));
						DiskFileItem fileItem = new DiskFileItem("file", Files.probeContentType(file.toPath()), false, fileInfo.getString("saveFileName"), (int) file.length() , file.getParentFile());
						
						try (InputStream input = new FileInputStream(file); OutputStream os = fileItem.getOutputStream();) {
							IOUtils.copy(input, os);
							
							MultipartFile multipartFile = new CommonsMultipartFile(fileItem);
							mf.add(multipartFile);
						}
					}
				}
				
				params.put("objectID", params.get("folderID"));
				params.put("objectType", "FD");
				params.put("isInherited", "Y");
				params.put("isApproval", "N");
				params.put("useSecurity", "N");
				params.put("isPopup", "N");
				params.put("isTop", "N");
				params.put("fileInfos", "[]");
				params.put("isUserForm", "N");
				params.put("useScrap", "N");
				params.put("useReplyNotice", "N");
				params.put("useCommNotice", "N");
				params.put("useRSS", "N");
				params.put("securityLevel", RedisDataUtil.getBaseConfig("DefaultSecurityLevel",domainID));
				params.put("fileCnt", fileCnt);
				params.put("bodyInlineImage", params.getString("bodyInlineImage"));
				params.put("backgroundImage", params.getString("backgroundImage"));
				params.put("isMailToBoardYn", "Y");
				// bodyText 길이 1000자로 제한
				params.put("bodyText", ComUtils.substringBytes(params.getString("bodyText"), 1000));
				params.put("bodySize", params.getString("bodyText").length());
				params.put("frontStorageURL", RedisDataUtil.getBaseConfig("CommonGWServerURL") + RedisDataUtil.getBaseConfig("FrontStorage"));
				
				params.put("userCode", SessionHelper.getSession("USERID"));
				CoviMap configMap = boardManageSvc.selectBoardConfig(params);
				
				if(params.getString("bizSection").equalsIgnoreCase("Board") && configMap.getString("UseMessageAuth").equalsIgnoreCase("Y")) {
					CoviList aclArray = authSvc.selectACL(params);
					params.put("aclList", aclArray.toString());
				}
				
				int cnt = messageSvc.createMailToMessage(params, mf);
				
				if(cnt > 0){
					returnList.put("status", Return.SUCCESS);
					returnList.put("messageID", params.get("messageID"));
					returnList.put("message", "저장되었습니다.");
				} else {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "저장에 실패했습니다.");
				}
			}
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
	 * 게시 수정
	 * @param request MultipartHttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnList JSONObject
	 */
	@RequestMapping(value = "board/updateMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateMessage(MultipartHttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			List<MultipartFile> mf = request.getFiles("files");
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
			
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			// bodyText 길이 1000자로 제한
			params.put("bodyText", ComUtils.substringBytes(params.getString("bodyText"), 1000));
			
			boolean bModifyFlag = BoardUtils.getModifyAuth(params);
			int cnt  = 0;
			if (bModifyFlag){
				// 예약 게시일
				if(params.get("reservationDate") != null && !params.get("reservationDate").equals("")){
					params.put("reservationDate",ComUtils.TransServerTime(params.get("reservationDate").toString())); 
				}
				// 만료일 timezone 적용
				if(params.get("expiredDate") != null && !params.get("expiredDate").equals("") && !params.get("expiredDate").equals("9999-12-31 00:00:00")){
					params.put("expiredDate",ComUtils.TransServerTime(params.get("expiredDate").toString())); 
				}
				
				// 팝업공지 시작/종료일 
				if(params.get("popupStartDate") != null && !params.get("popupStartDate").equals("")){
					params.put("popupStartDate",ComUtils.TransServerTime(params.get("popupStartDate").toString()));
				}
				if(params.get("popupEndDate") != null && !params.get("popupEndDate").equals("")){
					params.put("popupEndDate",ComUtils.TransServerTime(params.get("popupEndDate").toString()));
				}
				// 상단공지 시작/종료일
				if(params.get("topStartDate") != null && !params.get("topStartDate").equals("")){
					params.put("topStartDate",ComUtils.TransServerTime(params.get("topStartDate").toString()));
				}
				if(params.get("topEndDate") != null && !params.get("topEndDate").equals("")){
					params.put("topEndDate",ComUtils.TransServerTime(params.get("topEndDate").toString()));
				}
				cnt = messageSvc.updateMessage(params, mf);
			}
			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("messageID", params.get("messageID"));
				returnList.put("message", DicHelper.getDic("msg_37"));			//저장 되었습니다.
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_sns_03"));		//저장 중 오류가 발생했습니다.
				if (bModifyFlag == false){
					returnList.put("message", DicHelper.getDic("msg_sns_03")+"["+DicHelper.getDic("msg_UNotEditAuth")+"]");		//저장 중 오류가 발생했습니다.
				}
			}
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
	 * 임시 저장 게시물 등록
	 * @param request MultipartHttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnList JSONObject
	 */
	@RequestMapping(value = "board/tempSaveMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap tempSaveMessage(MultipartHttpServletRequest request, HttpServletResponse response) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			List<MultipartFile> mf = request.getFiles("files");
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnList;
			}
			
			String ReservedStr1 = request.getParameter("ReservedStr1");
			
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("groupCode", SessionHelper.getSession("GR_Code"));
			params.put("ReservedStr1", ReservedStr1);
			
			// bodyText 길이 1000자로 제한
			params.put("bodyText", ComUtils.substringBytes(params.getString("bodyText"), 1000));
			
			// 예약 게시일
			if(params.get("reservationDate") != null && !params.get("reservationDate").equals("")){
				params.put("reservationLocalDate",ComUtils.TransServerTime(params.get("reservationDate").toString())); 
			}
			// 만료일 timezone 적용
			if(params.get("expiredDate") != null && !params.get("expiredDate").equals("") && !params.get("expiredDate").equals("9999-12-31 00:00:00")){
				params.put("expiredDate",ComUtils.TransServerTime(params.get("expiredDate").toString())); 
			}
			
			// 팝업공지 시작/종료일 
			if(params.get("popupStartDate") != null && !params.get("popupStartDate").equals("")){
				params.put("popupStartDate",ComUtils.TransServerTime(params.get("popupStartDate").toString()));
			}
			if(params.get("popupEndDate") != null && !params.get("popupEndDate").equals("")){
				params.put("popupEndDate",ComUtils.TransServerTime(params.get("popupEndDate").toString()));
			}
			// 상단공지 시작/종료일
			if(params.get("topStartDate") != null && !params.get("topStartDate").equals("")){
				params.put("topStartDate",ComUtils.TransServerTime(params.get("topStartDate").toString()));
			}
			if(params.get("topEndDate") != null && !params.get("topEndDate").equals("")){
				params.put("topEndDate",ComUtils.TransServerTime(params.get("topEndDate").toString()));
			}
			
			messageSvc.deleteTempMessage(params);
			int cnt = messageSvc.createMessage(params, mf);
			
			if(cnt > 0){
				returnList.put("status", Return.SUCCESS);
				returnList.put("messageID", params.get("messageID"));
				returnList.put("message", DicHelper.getDic("msg_37"));			//저장 되었습니다.
			} else {
				returnList.put("status", Return.FAIL);
				returnList.put("message", DicHelper.getDic("msg_sns_03"));		//저장 중 오류가 발생했습니다.
			}
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			returnList.put("detailMsg", e.getCause().getMessage());
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			returnList.put("detailMsg", e.getCause().getMessage());
		}
		
		return returnList;
	}
	
	/**
	 * 게시글 삭제
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/deleteMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //삭제할 포탈 ID
			String version[]  = StringUtil.replaceNull(request.getParameter("version"), "").split(";"); //삭제할 버전
			String bizSection = request.getParameter("bizSection");
			String comment = request.getParameter("comment");
			String CSMU = request.getParameter("CSMU");
			String communityId = request.getParameter("communityId");
			String registIP = request.getRemoteHost();
			String folderID = request.getParameter("folderID");
			
			boolean bDeleteFlag = false;
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();

				params.put("bizSection", bizSection);
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("version",version[i]);
				params.put("folderID", folderID);
				
				bDeleteFlag = BoardUtils.getDeleteAuth(params);
				if (!bDeleteFlag){
					break;
				}
			}
			
			if (bDeleteFlag){
				for(int i = 0; i < messageID.length; i++){
					CoviMap params = new CoviMap();
	
					params.put("bizSection", bizSection);
					params.put("userCode", SessionHelper.getSession("USERID"));
					params.put("messageID",messageID[i]);
					params.put("CSMU",CSMU);
					params.put("communityId",communityId);
					params.put("historyType", "Delete");
					params.put("comment", comment);
					params.put("registIP", registIP);
					params.put("folderID", folderID);
					
					messageSvc.deleteMessage(params);			//게시글 삭제
					//messageManageSvc.createHistory(params);			//삭제 기록 추가
					//삭제하는 게시글의 file size를 board_config에 가감 처리
				}
				returnData.put("status", Return.SUCCESS);
			}
			else{
				returnData.put("status", Return.FAIL);//msg_noWriteAuth
				returnData.put("message", DicHelper.getDic("msg_noDeleteACL"));
			}
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
	 * 게시글 이동 처리
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 */
	@RequestMapping(value = "board/moveMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap moveMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //Message ID
			String version[]  = StringUtil.replaceNull(request.getParameter("version"), "").split(";"); //삭제할 버전
			String folderID = request.getParameter("folderID");
			String orgFolderID[] = StringUtil.replaceNull(request.getParameter("orgFolderID"), "").split(";"); //원본 폴더 ID
			String bizSection = request.getParameter("bizSection");
			String comment = request.getParameter("comment");
			String registIP = request.getRemoteHost();
			
			boolean bMoveFlag = false;
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();

				params.put("messageID", messageID[i]);
				params.put("version", version[i]);
				params.put("folderID", folderID);
				params.put("orgFolderID", orgFolderID[i]);
				params.put("bizSection", bizSection);
				params.put("userCode", SessionHelper.getSession("USERID"));
				
				bMoveFlag = BoardUtils.getMoveAuth(params);
				if (!bMoveFlag){
					break;
				}
			}
			
			if (bMoveFlag){
				for(int i = 0; i < messageID.length; i++){
					CoviMap params = new CoviMap();
					params.put("bizSection", bizSection);
					params.put("userCode", SessionHelper.getSession("USERID"));
					params.put("messageID",messageID[i]);
					params.put("version", version[i]);
					params.put("folderID", folderID);
					params.put("orgFolderID", orgFolderID[i]);
					params.put("comment", comment);
					params.put("historyType", "Move");
					params.put("registIP", registIP);
					
					messageSvc.moveMessage(params);			//게시글 이동
				}
				
				returnData.put("status", Return.SUCCESS);
			} else {
				returnData.put("status", Return.FAIL);//msg_noWriteAuth
				returnData.put("message", DicHelper.getDic("msg_noDeleteACL"));
			}		
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
	 * 게시글 복사
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/copyMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap copyMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //Message ID
			String version[]  = StringUtil.replaceNull(request.getParameter("version"), "").split(";"); //Version
			String folderID = request.getParameter("folderID");
			String orgFolderID[] = StringUtil.replaceNull(request.getParameter("orgFolderID"), "").split(";"); //원본 폴더 ID
			String bizSection = request.getParameter("bizSection");
			String comment = request.getParameter("comment");
			String registIP = request.getRemoteHost();
			String useAnonym[] = StringUtil.replaceNull(request.getParameter("useAnonym"), "").split(";"); //useAnonym
			String creatorName[] = StringUtil.replaceNull(request.getParameter("creatorName"), "").split(";"); //creatorName
			
			boolean bCopyFlag = false;
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();

				params.put("messageID", messageID[i]);
				params.put("version", version[i]);
				params.put("folderID", folderID);
				params.put("orgFolderID", orgFolderID[i]);
				params.put("bizSection", bizSection);
				params.put("userCode", SessionHelper.getSession("USERID"));
				
				bCopyFlag = BoardUtils.getCopyAuth(params);
				if (!bCopyFlag){
					break;
				}
			}
			
			if (bCopyFlag){
				for(int i = 0; i < messageID.length; i++){
					CoviMap params = new CoviMap();
					params.put("bizSection", bizSection);
					params.put("userCode", SessionHelper.getSession("USERID"));
					params.put("orgMessageID",messageID[i]);
					params.put("folderID", folderID);
					params.put("orgFolderID", orgFolderID[i]);
					params.put("comment", comment);
					params.put("historyType", "Copy");
					params.put("registIP", registIP);
					
					//업로드 파일 조회용 parameter 설정
					params.put("ServiceType", bizSection);
					params.put("ObjectID", orgFolderID[i]);
					params.put("ObjectType", "FD");
					params.put("MessageID", messageID[i]);
					params.put("version", version[i]);
					params.put("useAnonym", useAnonym[i]);
					params.put("creatorName", creatorName[i]);
					
					params.put("fileInfos", JSONSerializer.toJSON(fileSvc.selectAttachAll(params)));	//upload파일은 같이 조회
					
					messageSvc.copyMessage(params);			//게시글 복사
				}	
				
				returnData.put("status", Return.SUCCESS);
			} else {
				returnData.put("status", Return.FAIL);//msg_noWriteAuth
				returnData.put("message", DicHelper.getDic("msg_noCopyACL"));
			}
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
	 * 게시글 스크랩
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/scrapMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap scrapMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("version", params.getString("Version"));
			
			messageSvc.scrapMessage(params);			//게시글 스크랩
			
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
	 * 게시글 신고
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/reportMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap reportMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("registIP", request.getRemoteHost());
			params.put("historyType", "Report");
			
			int chk = messageSvc.checkExistReport(params);	//중복 신고 체크 
			
			if(chk > 0 ){
				returnData.put("message", DicHelper.getDic("msg_AlreadySingo"));	//이미 신고처리 하셨습니다.
			} else {
				messageSvc.reportMessage(params);			//게시글 신고
				returnData.put("message", DicHelper.getDic("msg_SingoProcessed"));	//신고처리 하였습니다.
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
	 * 게시글 수정 요청
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/requestModifyMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap requestModifyMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("registIP", request.getRemoteHost());
			params.put("requestStatus", "Ready");
			
			messageSvc.requestModifyMessage(params);			//게시글 신고
//			returnData.put("message", DicHelper.getDic("msg_RequestModifyProcessed"));	//수정요청 하였습니다.
			returnData.put("message", "수정요청 하였습니다.");
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
	 * 승인 요청 게시물: 승인
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/acceptMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap acceptMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //MessageID
			String processID[] = StringUtil.replaceNull(request.getParameter("processID"), "").split(";"); //ProcessID
			String comment = request.getParameter("comment");
			String bizSection = request.getParameter("bizSection");
			String registIP = request.getRemoteHost();
			
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("bizSection", bizSection);
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("processID", processID[i]);
				params.put("comment", comment);
				params.put("historyType", "Approval");
				params.put("registIP", registIP);
				
				messageSvc.acceptMessage(params);			//게시글 승인
			}
			returnData.put("message", DicHelper.getDic("msg_Approved"));	//승인 완료
			
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
	 * 승인 요청 게시물: 거부
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/rejectMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap rejectMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //MessageID
			String processID[] = StringUtil.replaceNull(request.getParameter("processID"), "").split(";"); //ProcessID
			String comment = request.getParameter("comment");
			String bizSection = request.getParameter("bizSection");
			String registIP = request.getRemoteHost();
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("bizSection", bizSection);
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("processID", processID[i]);
				params.put("comment", comment);
				params.put("historyType", "Return");
				params.put("registIP", registIP);
				
				messageSvc.rejectMessage(params);			//게시글 삭제
			}
			returnData.put("message", DicHelper.getDic("msg_Processed"));	//처리 완료.
			
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
	 * 태그 목록 조회, 게시작성 페이지에서 표시
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectMessageTagList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageTagList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			resultList = messageSvc.selectMessageTagList(params);
			
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
	
	/**
	 * 링크 목록 조회, 게시 작성페이지에서 표시
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/selectMessageLinkList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageLinkList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			resultList = messageSvc.selectMessageLinkList(params);
			
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
	
	/**
	 * 게시글 상세보기 및 파일 목록 조회, 수정시 데이터 조회
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/selectMessageDetail.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMessageDetail(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap configData = messageSvc.selectMessageDetail(params);
			
			//업로드 파일 조회용 parameter 설정
			params.put("ObjectType", "FD");
			params.put("ObjectID", configData.get("FolderID"));
			params.put("ServiceType", configData.get("ServiceType"));
			params.put("MessageID", configData.get("MessageID"));
			params.put("Version", configData.get("Version"));
			
			
			/* 폴더 아이디 체크
			 * 1. parameter로 들어온 FolderID와 MessageID로 조회된 FolderID가 동일하지 않을때
			 * 2. parameter로 들어온 FolderID와 MessageID로 조회된 MultiFolderIDs(다차원 분류 폴더 아이디)에 속하지 않을때 */
			if(!params.get("ServiceType").equals("Doc") && !params.get("folderID").equals(configData.getString("FolderID"))
				&& configData.getString("MultiFolderIDs").indexOf(params.getString("folderID")) == -1){
				returnData.put("message", "PARAMETER_MANIPULATION");					//실패 처리 관련 message parameter 추가
				returnData.put("list", configData);
				returnData.put("fileList", fileSvc.selectAttachAll(params));	//upload파일은 같이 조회
				returnData.put("status", Return.FAIL);
			} else {
				returnData.put("list", configData);
				returnData.put("fileList", fileSvc.selectAttachAll(params));	//upload파일은 같이 조회
				returnData.put("status", Return.SUCCESS);
			}
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
	 * 파일목록 조회
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/selectFileList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectFileList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			//업로드 파일 조회용 parameter 설정
			params.put("ServiceType", request.getParameter("bizSection"));
			params.put("ObjectID", request.getParameter("folderID"));
			params.put("ObjectType", "FD");
			params.put("MessageID", request.getParameter("messageID"));
			params.put("Version", request.getParameter("version"));
			
			returnData.put("fileList", fileSvc.selectAttachAll(params));	//upload파일은 같이 조회
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
	 * 사용자정의 필드 설정 값 조회
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/selectUserDefFieldValue.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserDefFieldValue(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			//messageID, version
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			resultList = messageSvc.selectUserDefFieldValue(params);
			
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
	
	@RequestMapping(value = "board/updateUserDefFieldValue.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateUserDefFieldValue(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnMap = new CoviMap();
		CoviMap params = new CoviMap();
		
		String registIP = request.getRemoteHost();
		String userFormID = request.getParameter("userFormID");
		String fieldValue = request.getParameter("fieldValue");
		String userFormIndex = request.getParameter("userFormIndex");
		String userFormValue = request.getParameter("userFormValue");
		
		try {
			params.put("folderID", request.getParameter("folderID"));
			params.put("messageID", request.getParameter("messageID"));
			params.put("version", request.getParameter("version"));
			params.put("userFormID", userFormID);
			params.put("fieldValue", fieldValue);
			params.put("userFormIndex", userFormIndex);
			params.put("userFormValue", userFormValue);
			
			params.put("historyType", "ChangeOption");
			params.put("comment", "UserFormID["+userFormID+"] -> " + fieldValue);
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("registIP", registIP);
			params.put("domainID", SessionHelper.getSession("DN_ID"));
			
			returnMap = messageSvc.updateUserDefFieldValueOne(params);
		} catch (NullPointerException e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnMap.put("status", Return.FAIL);
			returnMap.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnMap;
	}
	
	/**
	 * 문서게시글 체크아웃 상태 변경
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/updateCheckOutState.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateCheckOutState(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			params.put("registIP", request.getRemoteHost());
			
			int chk = messageSvc.selectMessageCheckOutStatus(params);	//체크아웃 여부확인
			
			if(chk > 0 ){
				messageSvc.updateCheckOutState(params);			//게시글 체크아웃 상태 변경
				returnData.put("message", DicHelper.getDic("msg_Processed"));	//처리 되었습니다
			} else {
				if(params.get("actType").equals("Out") && params.get("actType").equals("Renew")){
					returnData.put("message", DicHelper.getDic("AlreadyCheckOut"));	//확인후 작성
				} else {
					returnData.put("message", DicHelper.getDic("AlreadyCheckIn"));	//
				}
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
	 * 본문 양식 데이터 조회
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @return returnData JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/selectBodyFormData.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBodyFormData(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		FileInputStream fis = null;
		InputStreamReader isr = null;
		String s;
		try {
			CoviMap params = new CoviMap();
			//messageID, version
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			//String formPath = messageSvc.selectBodyFormData(params).getString("FormPath");
			//String companyCode = SessionHelper.getSession("DN_Code");
			CoviMap formInfo = messageSvc.selectBodyFormData(params);
			String fullPath = formInfo.getString("FullPath");
			String companyCode = formInfo.getString("CompanyCode");
			String formExtention = formInfo.getString("Extention");
			
	        // 
	        //fis = new FileInputStream(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + File.separator + formPath);
			fis = new FileInputStream(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fullPath);
	        isr = new InputStreamReader(fis);
	        // inputStreamReader에서 해당 파일의 케릭터셋 추출
	        s = isr.getEncoding();
	         
	        String bodyForm = IOUtils.toString(fis, s);
	        
			returnData.put("bodyForm", bodyForm);
			returnData.put("formExtention", formExtention);
			returnData.put("status", Return.SUCCESS);
		} catch (IOException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} finally {
			if(fis!=null) {
	        	 try {
	        		 fis.close();
	        	 } catch (IOException e) {
	        		 LOGGER.error(e.getLocalizedMessage(), e);
	        	 }
	         }
	            
	         if(isr!=null) {
	        	 try {
	        		 isr.close();
	        	 } catch (IOException e) {
	        		 LOGGER.error(e.getLocalizedMessage(), e);
	        	 }
	         }
		}
		
		return returnData;
	}
	
	/**
	 * 컨텐츠 본문 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectContentMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectContentMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			returnData.put("data", messageSvc.selectContentMessage(params));
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
	 * 게시 버전별 이력 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectRevisionHistory.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectRevisionHistory(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			resultList = messageSvc.selectRevisionHistory(params);
			
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
	
	/**
	 * 체크인 이력 목록 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectCheckInHistoryGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectCheckInHistoryGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			int cnt = messageSvc.selectDocInOutHistoryGridCount(params);
			params.addAll(ComUtils.setPagingData(params,cnt));
			
			resultList = messageSvc.selectDocInOutHistoryGridList(params);
			
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
	
	/**
	 * 연결글 정보 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectLinkedMessageList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectLinkedMessageList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			
			resultList = messageSvc.selectLinkedMessageList(params);
			
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
	
	/**
	 * 피드 연결글 정보 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectLinkedFeedMessageList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectLinkedFeedMessageList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
			
			StringUtil func = new StringUtil();
			if(!func.f_NullCheck(dbType).equals("oracle") || !func.f_NullCheck(dbType).equals("tibero")){
				CoviMap params = new CoviMap();
				BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
				resultList = messageSvc.selectLinkedFeedMessageList(params);
			}
						
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
	
	/**
	 * 
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/distributeDoc.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap distributeDoc(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			int cnt = messageSvc.distributeDoc(params);
			
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
	 * 웹파트 - 공지 게시판 게시글 조회
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectNoticeMessageList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectNoticeMessageList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		//messageID, folderID 사용예정
		try {
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode",userDataObj.getString("USERID"));
			params.put("domainID", userDataObj.getString("DN_ID"));
			params.put("lang", userDataObj.getString("lang"));
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", "Board", "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			params.put("bizSection", "Board");
			params.put("isSaaS", isSaaS);
			
			// 웹파트의 경우 pageSize를 받아서 목록 갯수 제한.
			if (params.get("pageSize") != null && !params.get("pageSize").equals("")) {
				if (StringUtil.isNumeric((String)params.get("pageSize"))) {
					params.put("pageSize", Integer.parseInt((String)params.get("pageSize")));
				}
			}
			
			resultList = messageSvc.selectNoticeMessageList(params);
			
			returnData.put("list", resultList.get("list"));
			returnData.put("cnt", resultList.get("cnt"));
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
	 * 웹파트 - 최근게시 ( 최근게시 옵션이 표시 게시판만 조회 )
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectLatestMessageList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectLatestMessageList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("userCode", userDataObj.getString("USERID"));
			params.put("lang",userDataObj.getString("lang"));
			
			if (isMobile) params.put("isMobileSupport","Y");

			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", params.getString("bizSection"), "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			params.put("messageCount", Integer.parseInt(params.getString("messageCount")));
			
			resultList = messageSvc.selectLatestMessageList(params);
			
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
	
	/**
	 * 웹파트 - 팝업공지 게시
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectPopupNoticeList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectPopupNoticeList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviList resultList = new CoviList();
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			String bizSection = StringUtil.replaceNull(request.getParameter("bizSection"), "");
			String userCode = userDataObj.getString("USERID");
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", bizSection, "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			CoviMap params = new CoviMap();
			params.put("folderACLArr", objectArray);
			params.put("jobSeq", userDataObj.get("URBG_ID"));
			params.put("bizSection", bizSection);
			params.put("objectType", "FD");
			params.put("userCode", userCode);
			params.put("groupPath", groupPath);
			
			CoviList popupList = (CoviList) messageSvc.selectPopupNoticeList(params).get("list");
			
			for(Object obj : popupList) {
				CoviMap msgObj = (CoviMap)obj;
				params.put("messageID", msgObj.getString("MessageID"));
				params.put("version", msgObj.getString("Version"));
				params.put("folderID", msgObj.getString("FolderID"));
				
				boolean bReadFlag = false;
				
				if (bizSection.equals("Community") && !msgObj.getString("MenuID").equals(request.getParameter("communityID"))) {
					bReadFlag = false;
				} else if ("Y".equals(userDataObj.getString("isAdmin"))) {		//관리자
					bReadFlag = true;
				} else if (msgObj.getString("FolderOwnerCode").indexOf(userCode+";") != -1) {	//게시판 담당자
					bReadFlag = true;
				} else if (userCode.equals(msgObj.getString("CreatorCode"))) {					//작성자
					bReadFlag = true;
				} else if (userCode.equals(msgObj.getString("OwnerCode"))) {						//문서 소유자
					bReadFlag = true;
				} else {
					//상세권한(메시지권한) 옵션을 사용중일 때는 board_message_acl 테이블에서 권한 체크
					if ("Y".equals(msgObj.getString("UseMessageAuth"))) {
						CoviList aclArray = (CoviList) messageACLSvc.selectMessageAclList(params).get("list");
						
						bReadFlag = messageACLSvc.checkAclShard("TargetType", "R", aclArray);
					} else {
						bReadFlag = true;
					}
					
					//열람권한 사용 시
					if ("Y".equals(msgObj.getString("UseMessageReadAuth"))) {
						int cnt = messageACLSvc.selectMessageReadAuthCount(params); 
						int allCount = messageACLSvc.selectMessageReadAuthListCnt(params);
						
						if (allCount > 0 && cnt < 1) {  //지정된 열람권한이 있으나 현 사용자에게 권한이 없을 경우 읽기 권한 X 
							bReadFlag = false;
						}
					}
				}
				
				if (bReadFlag) {
					resultList.add(msgObj);
				}
			}
			
			returnData.put("list", resultList);
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
	 * [본사운영] 품질관리 - SCC 연동: 게시 등록 API 
	 * @param request
	 * @param response
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "board/createSCCMessage.do", method = {RequestMethod.POST, RequestMethod.GET})
	public void createSCCMessage(HttpServletRequest request, HttpServletResponse response ) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		PrintWriter out = response.getWriter();
		String callback = request.getParameter("callback");
		
		try {
			String domainID = "1";
			String useSCCBoard = RedisDataUtil.getBaseConfig("useSCCBoard", domainID);		 // SCC 연동 사용여부
			
			if(!useSCCBoard.equalsIgnoreCase("Y")) {
				returnObj.put("result", Return.FAIL);
				returnObj.put("message", "BaseConfig 'useSCCBoard' value is not 'Y' \r\n"
											+ "[useSCCBoard = "+ useSCCBoard + "]");
				
				out.write(callback + "(" + returnObj + ")");
				return ;
			}
			
			CoviMap params = new CoviMap();
			String type = "Error";
			String sccKey = request.getParameter("key");
			String sccType = Objects.toString(request.getParameter("sccType"), "CS");				// CS팀: CS, 하랑: HR (default: CS)
			String folderType = request.getParameter("folderType");
			String subject = request.getParameter("subject");
			String projectName = request.getParameter("projectName");
			String categoryID = request.getParameter("categoryID");
			String bodyText = request.getParameter("bodyText");
			String ownerCode = request.getParameter("ownerCode");

			String folderID = RedisDataUtil.getBaseCodeDic("SCC_"+type+"_BoardID", folderType, "ko");			 // 에러게시판 Folder ID 
			
			if(StringUtils.isEmpty(folderID)) {
				returnObj.put("result", Return.FAIL);
				returnObj.put("message", "The folder type or setting value is incorrect.\r\n"
											+ "[folderType = "+ folderType + "]");
				
				out.write(callback + "(" + returnObj + ")");
				return ;
			}
			
			bodyText = "<a href='" + bodyText + "' target='_blank' style='text-decoration:underline;' >SCC Link</a>";
			
			params.put("sccKey", sccKey);
			params.put("sccType", sccType);
			params.put("mode", "create");
			params.put("bizSection", "Board");
			params.put("ownerCode", ownerCode);
			params.put("userCode", ownerCode);
			params.put("categoryID", categoryID);
			params.put("msgState", "C");
			params.put("msgType", "O");
			params.put("step", "0");
			params.put("depth", "0");
			params.put("folderID", folderID);
			params.put("folderType", folderType);
			params.put("menuID", RedisDataUtil.getBaseConfig("QualityControl", domainID));
			params.put("subject", subject);
			params.put("projectName", projectName);
			params.put("body", bodyText);
			params.put("bodyText", bodyText);
			params.put("objectType", "FD");
			params.put("isInherited", "Y");
			params.put("isApproval", "N");
			params.put("useSecurity", "N");
			params.put("isPopup", "N");
			params.put("isTop", "N");
			params.put("isUserForm", "N");
			params.put("useScrap", "N");
			params.put("useReplyNotice", "N");
			params.put("useCommNotice", "N");
			params.put("useRSS", "N");
			params.put("securityLevel", RedisDataUtil.getBaseConfig("DefaultSecurityLevel",domainID));
			params.put("fileCnt", 0);
			// bodyText 길이 1000자로 제한
			params.put("bodyText", ComUtils.substringBytes(params.getString("bodyText"), 1000));
			params.put("bodySize", params.getString("bodyText").length());
			
			CoviMap configMap = boardManageSvc.selectBoardConfig(params);
			
			if(params.getString("bizSection").equalsIgnoreCase("Board") && configMap.getString("UseMessageAuth").equalsIgnoreCase("Y")) {
				CoviList aclArray = authSvc.selectACL(params);
				params.put("aclList", aclArray.toString());
			}
			
			if(configMap.getString("UseUserForm").equalsIgnoreCase("Y")) {
				params.put("isUserForm", "Y");
			}
			
			int cnt = messageSvc.createSCCMessage(params);
			
			if(cnt > 0){
				String url =  PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
				url += String.format("/%s/%s/%s","groupware", "layout", "board_BoardView.do");	// {Domain}/groupware/layout/board_BoardView.do
				url += "?CLSYS=board&CLMD=user&CLBIZ=Board";
				url += String.format("&menuID=%s&version=1&folderID=%s&messageID=%s", params.get("menuID"), params.get("folderID"), params.get("messageID")) ;
				url += "&viewType=List&boardType=Normal&startDate=&endDate=&sortBy=&searchText=&searchType=Subject&page=1&pageSize=10";
				
				returnObj.put("result", Return.SUCCESS);
				returnObj.put("message", "Success [MessageID = " + params.get("messageID") + "]");
				returnObj.put("url", url);
			} else {
				returnObj.put("result", Return.FAIL);
				returnObj.put("message", "no insert Data");
			}
		} catch (IOException e) {
			returnObj.put("result", Return.FAIL);
			returnObj.put("message", e.getMessage() == null ? e.toString() : e.getMessage());
		} catch (NullPointerException e) {
			returnObj.put("result", Return.FAIL);
			returnObj.put("message", e.getMessage() == null ? e.toString() : e.getMessage());
		}catch (Exception e) {
			returnObj.put("result", Return.FAIL);
			returnObj.put("message", e.getMessage() == null ? e.toString() : e.getMessage());
		} finally {
			if (out != null) { 
				try { out.flush(); out.close(); } 
				catch (NullPointerException ex) { LOGGER.error(ex.getLocalizedMessage(), ex); }
				catch (Exception ex) { LOGGER.error(ex.getLocalizedMessage(), ex); }
			}
		}
		
		if(out != null) {
			out.write(callback + "(" + returnObj + ")");
		}else {
			throw new Exception ("response.getWriter is null.");
		}
		return ;
	}
	
	/**
	 * 문서 이관 API (결재에서 호출함 - baseonfig DocTransferURL)
	 * @param request HttpServletRequest
	 * @param response HttpServletResponse
	 * @param requestParams JSONObject
	 * @throws Exception Exception
	 */
	@RequestMapping(value = "board/transferMessage.do", method = RequestMethod.POST)
	public void transferMessage(HttpServletRequest request, HttpServletResponse response, @RequestBody CoviMap requestParams) throws Exception
	{
		AwsS3 awsS3 = AwsS3.getInstance();
		try {
			//String apvAttPath = RedisDataUtil.getBaseConfig("ApprovalAttach_SavePath");
			List<MultipartFile> mf = new ArrayList<MultipartFile>();
			int fileCnt = 1;
					
			if(!requestParams.getString("fileInfoList").equals("")){
				CoviList fileInfoList = requestParams.getJSONArray("fileInfoList");
				String companyCode = requestParams.getString("DN_Code");
				fileCnt += fileInfoList.size();
				
				CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(fileInfoList); // 기존 파일의 storage정보조회 (fileid 필수)
				
				for(int i = 0; i < fileInfoList.size(); i++){
					CoviMap fileInfo = fileInfoList.getJSONObject(i);
					String fileID = fileInfo.getString("FileID");
					CoviMap fileStorageInfo = (CoviMap)fileStorageInfos.get(fileID); // 오류발생을 위해 fileid 유무 체크 안함(필수값이므로 없는시스템은 추가 필요)
					companyCode = fileStorageInfo.optString("CompanyCode").equals("") ? companyCode : fileStorageInfo.optString("CompanyCode");
					//String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + apvAttPath + fileInfo.getString("FilePath") + fileInfo.getString("SavedName");
					String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileStorageInfo.optString("StorageFilePath").replace("{0}", companyCode) + fileStorageInfo.optString("FileFilePath") + fileStorageInfo.optString("SavedName");
					
					if(awsS3.getS3Active()){
						AwsS3Data awsS3Data = awsS3.downData(filePath);
						MultipartFile multipartFile = new MockMultipartFile(awsS3Data.getName(), awsS3Data.getContentStream());
						mf.add(multipartFile);
					}else {

						File file = new File(FileUtil.checkTraversalCharacter(filePath));
						DiskFileItem fileItem = new DiskFileItem("file", Files.probeContentType(file.toPath()), false, fileInfo.getString("FileName"), (int) file.length() , file.getParentFile());

						try (InputStream input = new FileInputStream(file); OutputStream os = fileItem.getOutputStream();) {
							IOUtils.copy(input, os);

							MultipartFile multipartFile = new CommonsMultipartFile(fileItem);
							mf.add(multipartFile);
						}
					}
				}
			}
			if(awsS3.getS3Active()){
				String key = requestParams.getString("pdfPath");
				AwsS3Data awsS3Data = awsS3.downData(key);
				MultipartFile multipartFile = new MockMultipartFile(awsS3Data.getName(), awsS3Data.getContentStream());
				mf.add(multipartFile);
			}else {
				File file = new File(FileUtil.checkTraversalCharacter(requestParams.getString("pdfPath")));
				DiskFileItem fileItem = new DiskFileItem("file", Files.probeContentType(file.toPath()), false, requestParams.getString("subject") + ".pdf", (int) file.length(), file.getParentFile());

				try (InputStream input = new FileInputStream(file); OutputStream os = fileItem.getOutputStream();){
					IOUtils.copy(input, os);

					MultipartFile multipartFile = new CommonsMultipartFile(fileItem);
					mf.add(multipartFile);
				}
			}
			
			if(!FileUtil.isEnableExtention(mf)){
				return;
			}
			
			Calendar cal = Calendar.getInstance();
			SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			cal.add(Calendar.YEAR, 3);
			
			CoviMap params = new CoviMap();
			
			params.put("userCode", requestParams.getString("userCode"));
			params.put("folderID", requestParams.getString("folderID"));
			CoviMap configMap = boardManageSvc.selectBoardConfig(params);
			
			params.put("objectID", requestParams.getString("folderID"));
			params.put("objectType", "FD");
			params.put("inheritedObjectID", requestParams.getString("folderID"));
			
			CoviList aclList = new CoviList();
			
			// 폴더 권한
			CoviList authList = authSvc.selectACL(params);
			
			// 결제에서 넘어오는 권한
			CoviList messageAuthList = requestParams.getJSONArray("messageAuth");
			
			// 보안(기밀) 문서 여부에 따른 권한 설정
			if("N".equals(requestParams.getString("isSecureDoc")) || StringUtil.isEmpty(requestParams.getString("isSecureDoc"))) {  
				params.put("isInherited", "Y");
				
				for(int i = 0; i < authList.size(); i++){
					CoviMap auth = authList.getJSONObject(i);
					CoviMap aclObj = new CoviMap();
					String acl = "";
					
					if(auth.getString("AclList").indexOf("S") > -1) acl += "S"; else acl += "_";
					if(auth.getString("AclList").indexOf("C") > -1) acl += "C"; else acl += "_";
					if(auth.getString("AclList").indexOf("D") > -1) acl += "D"; else acl += "_";
					if(auth.getString("AclList").indexOf("M") > -1) acl += "M"; else acl += "_";
					if(auth.getString("AclList").indexOf("E") > -1) acl += "E"; else acl += "_";
					if(auth.getString("AclList").indexOf("R") > -1) acl += "R"; else acl += "_";
					
					aclObj.put("TargetType", auth.getString("SubjectType"));
					aclObj.put("TargetCode", auth.getString("SubjectCode"));
					aclObj.put("DisplayName", auth.getString("SubjectName"));
					aclObj.put("AclList", acl);
					aclObj.put("IsSubInclude", auth.getString("IsSubInclude"));
					aclObj.put("InheritedObjectID", auth.getString("InheritedObjectID"));
					
					// 폴더 권한 추가
					aclList.add(aclObj);
				}
			} else {
				params.put("isInherited", "N");
				
				for(int i = 0; i < messageAuthList.size(); i++){
					CoviMap messageAuth = messageAuthList.getJSONObject(i);
					
					// 결재선 사용자만 권한 추가
					if("UR".equals(messageAuth.getString("TargetType"))) {
						aclList.add(messageAuth);
					}
				}
			}
			
			// 중복 ACL 데이터 처리
			for(int i = 0; i < aclList.size(); i++){
				CoviMap aclObj = aclList.getJSONObject(i);
				
				for(int j = 0; j < aclList.size(); j++){
					CoviMap subAclObj = aclList.getJSONObject(j);
					if(i != j
						&& aclObj.getString("TargetCode").equals(subAclObj.getString("TargetCode"))
						&& aclObj.getString("TargetType").equals(subAclObj.getString("TargetType"))
						&& aclObj.getString("AclList").equals(subAclObj.getString("AclList"))){
						aclList.remove(j);
					}
				}
			}

			params.put("mode", "create");
			params.put("bizSection", "Doc");
			params.put("domainID", requestParams.getString("DNID"));			
			params.put("subject", requestParams.getString("subject"));
			params.put("registDept", requestParams.getString("registDept"));
			params.put("groupCode", requestParams.getString("groupCode"));
			params.put("ownerCode", requestParams.getString("ownerCode"));
			params.put("aclList", aclList.toString());
			params.put("fileCnt", fileCnt);
			params.put("fileInfos", "[]");
			params.put("msgType", "N");
			params.put("msgState", "C");
			params.put("isApproval", "N");
			params.put("isAutoDocNumber", configMap.getString("UseAutoDocNumber"));
			params.put("docNumber", requestParams.getString("number"));
			params.put("keepyear", "3");
			params.put("expiredDate", format.format(cal.getTime()));
			params.put("seq", "0");
			params.put("step", "0");
			params.put("depth", "0");
			params.put("bodySize", "0");
			params.put("bodyText", "");
			params.put("body", "");
			params.put("securityLevel", "256");
			params.put("registDate", requestParams.getString("registDate"));
			params.put("useSecurity", requestParams.getString("isSecureDoc")); // 결재문서 기밀여부
			
			// 세션이없는경우(결재에서 문서이관) sys_file에 registercode,companycode 안들어가는 문제 (파일저장 경로도 잘못됨)
			RequestContextHolder.getRequestAttributes().setAttribute("DN_Code", requestParams.optString("DN_Code"), RequestAttributes.SCOPE_REQUEST);
			RequestContextHolder.getRequestAttributes().setAttribute("USERID", requestParams.optString("userCode"), RequestAttributes.SCOPE_REQUEST);
			
			messageSvc.createMessage(params, mf);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw new IOException(e);
		} catch (ParseException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw new Exception(e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw new Exception(e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			throw new Exception(e);
		}
		
		return;
	}
	
	/**
	 * 링크사이트 게시글 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectSystemLinkBoardList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectSystemLinkBoardList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			
			params.put("userCode", SessionHelper.getSession("USERID", isMobile));
			params.put("domainID", SessionHelper.getSession("DN_ID", isMobile));
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			
			CoviMap systemLinkBoardList = messageSvc.selectSystemLinkBoardList(params);
			CoviList systemLinkBoardArr = systemLinkBoardList.getJSONArray("list");
			CoviList resultArr = new CoviList();
			
			for(int i = 0; i < systemLinkBoardArr.size(); i++){
				CoviMap resultObj = systemLinkBoardArr.getJSONObject(i);
				CoviMap fileParams = new CoviMap();
				
				fileParams.put("ServiceType", "Board");
				fileParams.put("ObjectID", resultObj.getString("FolderID"));
				fileParams.put("ObjectType", "FD");
				fileParams.put("MessageID", resultObj.getString("MessageID"));
				fileParams.put("Version", resultObj.getString("Version"));
				
				resultObj.put("fileList", fileSvc.selectAttachAll(fileParams));
				
				resultArr.add(resultObj);
			}
			
			returnData.put("list", resultArr);
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
	 * 게시판 그룹명 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectBoardGroupName.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectBoardGroupName(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			
			String result = messageSvc.selectBoardGroupName(params);
			
			returnData.put("GroupName", result);
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
	 * 문서 다중분류 정보가저오기
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "board/getMultiFolderName.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getMultiFolderName(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap params = new CoviMap();
			String multiFolderIDs = StringUtil.replaceNull(request.getParameter("MultiFolderIDs"), "").replaceAll(";", ",");
			
			params.put("lang", SessionHelper.getSession("lang", isMobile));
			params.put("multiFolderIDs", multiFolderIDs);
			params.put("multiFolderIDArr", multiFolderIDs.split(","));
			
			String result = messageSvc.selectMultiFolderName(params);
			
			returnData.put("result", result);
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
	 * 게시 분류 목록 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "board/selectTypeList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectTypeList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			CoviMap params = new CoviMap();
			
			BoardUtils.setRequestParam(request, params);
			params.put("userCode", userDataObj.getString("USERID"));
			params.put("domainID", userDataObj.getString("DN_ID"));
			params.put("lang", userDataObj.getString("lang"));
			
			Set<String> authorizedObjectCodeSet = ACLHelper.getACL(userDataObj, "FD", params.getString("bizSection"), "V");
			String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
			
			params.put("aclDataArr", objectArray);
			params.put("jobSeq", SessionHelper.getSession().get("URBG_ID"));
			params.put("objectType", "FD");
			
			returnData.put("list", messageSvc.selectTypeList(params));
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
	 * 게시글 잠금 처리
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "board/lockMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap lockMessage(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String messageID[]  = StringUtil.replaceNull(request.getParameter("messageID"), "").split(";"); //삭제할 포탈 ID
			String comment = request.getParameter("comment");
			String registIP = request.getRemoteHost();
			
			
			for(int i = 0; i < messageID.length; i++){
				CoviMap params = new CoviMap();
				params.put("userCode", SessionHelper.getSession("USERID"));
				params.put("messageID",messageID[i]);
				params.put("historyType", "Lock");
				params.put("comment", comment);
				params.put("registIP", registIP);
				//하위의 폴더 ID 경로 조회
				messageManageSvc.lockLowerMessage(params);		//하위 게시글 일괄 잠금처리
				messageManageSvc.lockMessage(params);			//원본 게시글 잠금처리
				messageManageSvc.createHistory(params);			//처리 이력 추가
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
	 * 전자결재 문서 이관 API (일반게시등록)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "board/approvalTransferMessage.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap approvalTransferMessage(HttpServletRequest request, HttpServletResponse response, @RequestBody CoviMap requestParams) throws Exception
	{
		CoviMap returnData = new CoviMap();
		try {
			String apvAttPath = RedisDataUtil.getBaseConfig("ApprovalAttach_SavePath");
			List<MultipartFile> mf = new ArrayList<MultipartFile>();
			int fileCnt = 0;
			CoviList  fileInfoList = new CoviList();
			if(!requestParams.getString("fileInfoList").equals("")){
				fileInfoList = requestParams.getJSONArray("fileInfoList");
				fileCnt += fileInfoList.size();
			}
			
			Calendar cal = Calendar.getInstance();
			SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			cal.add(Calendar.YEAR, 3);
			
			CoviMap params = new CoviMap();
			
			params.put("userCode", requestParams.getString("userCode"));
			params.put("folderID", requestParams.getString("folderID"));
			CoviMap configMap = boardManageSvc.selectBoardConfig(params);
			
			params.put("objectID", requestParams.getString("folderID"));
			params.put("objectType", "FD");
			params.put("serviceType", SessionHelper.getSession("Board"));
			params.put("inheritedObjectID", requestParams.getString("folderID"));
			
			boolean writeAuth = BoardAuth.getWriteAuth(params);
			
			if(!writeAuth) {
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_noWriteAuth"));
			}
			else {
				CoviList authList = authSvc.selectACL(params);
				CoviList aclList = new CoviList();
				CoviList messageAuthList = requestParams.getJSONArray("messageAuth");
	
				for(int i = 0; i < authList.size(); i++){
					CoviMap auth = authList.getJSONObject(i);
					CoviMap aclObj = new CoviMap();
					String acl = "";
					
					if(auth.getString("AclList").indexOf("S") > -1) acl += "S"; else acl += "_";
					if(auth.getString("AclList").indexOf("C") > -1) acl += "C"; else acl += "_";
					if(auth.getString("AclList").indexOf("D") > -1) acl += "D"; else acl += "_";
					if(auth.getString("AclList").indexOf("M") > -1) acl += "M"; else acl += "_";
					if(auth.getString("AclList").indexOf("E") > -1) acl += "E"; else acl += "_";
					if(auth.getString("AclList").indexOf("R") > -1) acl += "R"; else acl += "_";
					
					aclObj.put("TargetType", auth.getString("SubjectType"));
					aclObj.put("TargetCode", auth.getString("SubjectCode"));
					aclObj.put("DisplayName", auth.getString("SubjectName"));
					aclObj.put("AclList", acl);
					aclObj.put("IsSubInclude", auth.getString("IsSubInclude"));
					aclObj.put("InheritedObjectID", auth.getString("InheritedObjectID"));
					
					aclList.add(aclObj);
				}
				
				for(int i = 0; i < messageAuthList.size(); i++){
					CoviMap messageAuth = messageAuthList.getJSONObject(i);
					aclList.add(messageAuth);
				}
				
				// 중복 acl 데이터 처리
				for(int i = 0; i < aclList.size(); i++){
					CoviMap aclObj = aclList.getJSONObject(i);
					
					for(int j = 0; j < aclList.size(); j++){
						CoviMap subAclObj = aclList.getJSONObject(j);
						if(i != j
							&& aclObj.getString("TargetCode").equals(subAclObj.getString("TargetCode"))
							&& aclObj.getString("TargetType").equals(subAclObj.getString("TargetType"))
							&& aclObj.getString("AclList").equals(subAclObj.getString("AclList"))){
							aclList.remove(j);
						}
					}
				}
				
				params.put("mode", "create"); // 신규등록
				params.put("bizSection", "Board");
				params.put("domainID", requestParams.getString("DNID"));
				params.put("subject", requestParams.getString("subject"));
				params.put("registDept", requestParams.getString("registDept")); // 문서관리: 등록, 담당 부서명
				params.put("groupCode", requestParams.getString("groupCode"));
				params.put("ownerCode", requestParams.getString("ownerCode")); // 게시소유자코드
				params.put("aclList", aclList.toString());
				params.put("fileCnt", fileCnt);
				params.put("fileInfos", fileInfoList.toString()); // upload파일은 같이 조회
				params.put("approvalPath", apvAttPath); // 전자결재 게시등록
				params.put("msgType", "A"); // 'A' 전자결재
				params.put("msgState", "C"); // 'C' 등록
				params.put("isInherited", "Y"); // 폴더 상속
				params.put("useAnonym", "N"); // 익명사용여부
				params.put("isTop", "N"); // 상단공지 여부
				params.put("isApproval", "N"); // 승인 프로세스 사용여부
				params.put("isUserForm", "N"); // 임의양식 사용여부
				params.put("useScrap", "N"); // 스크랩 허용여부
				params.put("useReplyNotice", "N"); // 답글알림사용여부
				params.put("useCommNotice", "N"); // 덧글알림사용여부
				params.put("useRSS", "N"); // RSS 허용여부
				params.put("useSecurity", "N"); // 보안글 여부
				params.put("securityLevel", "256"); // 보안등급
				params.put("isAutoDocNumber", configMap.getString("UseAutoDocNumber")); 
				params.put("docNumber", requestParams.getString("number"));
				params.put("keepyear", "3");
				params.put("expiredDate", format.format(cal.getTime())); // 만료일, 폐기일자 ( 문서관리: 개정시 폐기일자 업데이트 )
				params.put("seq", "0");
				params.put("step", "0");
				params.put("depth", "0");
				params.put("body", requestParams.getString("body"));
				params.put("bodyText", ComUtils.substringBytes(requestParams.getString("bodyText"), 1000));
				params.put("bodySize", requestParams.getString("bodyText").length());
				params.put("registDate", requestParams.getString("registDate")); // 등록일시
				
				messageSvc.createMessage(params, mf);
				
				returnData.put("status", Return.SUCCESS);
			}
		} catch (ParseException e) {
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
	
	@RequestMapping(value = "board/selectRequestAuthMessageInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectRequestAuthMessageInfo(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
			params.put("lang", SessionHelper.getSession("lang"));
			
			CoviMap msgData = messageSvc.selectRequestAuthMessageInfo(params);
			
			returnData.put("msgData", msgData);
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
	
	// 웹파트 추천영상 데이터 조회
	@RequestMapping(value = "board/selectMovieBoardList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectMovieBoardList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap param = new CoviMap();
			param.put("lang", SessionHelper.getSession("lang"));
			param.put("userCode", SessionHelper.getSession("USERID"));
			param.put("folderID", StringUtil.replaceNull(request.getParameter("folderID"), ""));
			param.put("localCurrentDate", ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss", 0, SessionHelper.getSession("UR_TimeZone")));
			
			returnList.put("list", messageSvc.selectMovieBoardList(param).get("list"));
			returnList.put("status", Return.SUCCESS);
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
	
	// 게시 목록에서 파일 다운로드 및 미리보기 시도 시 조회자 추가
	@RequestMapping(value = "board/createFileDownloadToMessageReader.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createFileDownloadToMessageReader(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("bizSection", request.getParameter("bizSection"));
			params.put("folderID", request.getParameter("folderID"));
			params.put("messageID", request.getParameter("messageID"));
			params.put("version", request.getParameter("version"));
			params.put("userCode", SessionHelper.getSession("USERID"));
			
			messageSvc.createFileDownloadToMessageReader(params);
			
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
