package egovframework.covision.groupware.board.admin.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
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
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.board.admin.service.UserDefFieldManageSvc;

/**
 * @Class Name : UserDefFieldManageCon.java
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
public class UserDefFieldManageCon {
	
	private Logger LOGGER = LogManager.getLogger(UserDefFieldManageCon.class);
	
	@Autowired
	private AuthHelper authHelper;
	
	@Autowired
	UserDefFieldManageSvc userDefFieldManageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * selectUserDefFieldGridList : 확장옵션 - 사용자 정의 필드 Grid 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectUserDefFieldGridList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserDefFieldGridList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap resultList = new CoviMap();

		try {
			String folderID = request.getParameter("folderID");
			String sortKey = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[0];
			String sortDirec = request.getParameter("sortBy")==null?"":request.getParameter("sortBy").split(" ")[1];
		
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("sortColumn", ComUtils.RemoveSQLInjection(sortKey, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(sortDirec, 100));
			
			resultList = userDefFieldManageSvc.selectUserDefFieldGridList(params);
	
			returnData.put("list", resultList.get("list"));
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
	 * createUserDefField : 확장옵션 - 사용자 정의 필드 추가
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/createUserDefField.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap createUserDefField(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String folderID = request.getParameter("folderID");				//FolderID
			String fieldName = request.getParameter("fieldName");			//FieldName
			String fieldType = request.getParameter("fieldType");			//필드 타입
			String fieldSize = request.getParameter("fieldSize");			//필드 크기
			String fieldLimitCnt = request.getParameter("fieldLimitCnt");	//제한 설정
			String isList = request.getParameter("isList");					//목록 표시
			String isOption = StringUtil.replaceNull(request.getParameter("isOption"), "N");				//옵션 사용 여부
			String isCheckVal = request.getParameter("isCheckVal");			//필수 여부
			String isSearchItem = request.getParameter("isSearchItem");		//검색항목
			CoviList optionArr = CoviList.fromObject(StringEscapeUtils.unescapeHtml(request.getParameter("optionStr")));  //필드 옵션 항목  ex) [{"optionName": 옵션1,"optionCheck":"Y/N"},...]
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("fieldName", fieldName);
			params.put("fieldType", fieldType);
			params.put("fieldSize", fieldSize);
			params.put("fieldLimitCnt", fieldLimitCnt);
			params.put("isList", isList);
			params.put("isOption", isOption);
			params.put("isCheckVal", isCheckVal);
			params.put("isSearchItem", isSearchItem);
			
			//해당항목에서의 최대값으로...조회
			int sortKey = userDefFieldManageSvc.selectUserDefFieldGridCount(params);
			params.put("sortKey", sortKey+1);
			
			int cnt = userDefFieldManageSvc.createUserDefField(params);
			if(cnt>0){
				if(isOption.equals("Y")){	//필드 옵션 사용 여부 
					CoviMap optionParams = new CoviMap();
					for (int i = 0; i < optionArr.size(); i++) {
						CoviMap optionObj = optionArr.getJSONObject(i);
						optionParams.put("optionName",optionObj.getString("optionName"));
						optionParams.put("optionValue", i);
						optionParams.put("sortKey", i);
						optionParams.put("userFormID", params.get("userFormID"));
						optionParams.put("folderID", folderID);
						optionParams.put("optionCheck",optionObj.getString("optionCheck"));
						userDefFieldManageSvc.createUserDefOption(optionParams);
					}
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
	 * editUserDefField : 확장옵션 - 사용자 정의 필드 수정
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/updateUserDefField.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap editUserDefField(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String userFormID = request.getParameter("userFormID");			//UesrFormID
			String folderID = request.getParameter("folderID");				//FolderID
			String fieldName = request.getParameter("fieldName");			//FieldName
			String fieldType = request.getParameter("fieldType");			//필드 타입
			String fieldSize = request.getParameter("fieldSize");			//필드 크기
			String fieldLimitCnt = request.getParameter("fieldLimitCnt");	//제한 설정
			String isList = request.getParameter("isList");					//목록 표시
			String isOption = StringUtil.replaceNull(request.getParameter("isOption"), "N");				//옵션 사용 여부
			String isCheckVal = request.getParameter("isCheckVal");			//필수 여부
			String isSearchItem = request.getParameter("isSearchItem");		//검색항목
			CoviList optionArr = CoviList.fromObject(StringEscapeUtils.unescapeHtml(request.getParameter("optionStr")));		//필드 옵션 항목  ex) [{"optionName": 옵션1,"optionCheck":"Y/N"},...]
			
			CoviMap params = new CoviMap();
			params.put("userFormID", userFormID);
			params.put("folderID", folderID);
			params.put("fieldName", fieldName);
			params.put("fieldType", fieldType);
			params.put("fieldSize", fieldSize);
			params.put("fieldLimitCnt", fieldLimitCnt);
			params.put("isList", isList);
			params.put("isOption", isOption);
			params.put("isCheckVal", isCheckVal);
			params.put("isSearchItem", isSearchItem);
			
			int cnt = userDefFieldManageSvc.updateUserDefField(params);		//사용자 정의 필드 정보 업데이트
			if(cnt>0){
				if(isOption.equals("Y")){	//필드 옵션 사용 여부 
					userDefFieldManageSvc.deleteUserDefFieldOption(params);	//필드 옵션이 존재할경우 기존 필드옵션 삭제 처리 이후 새로 등록
					CoviMap optionParams = new CoviMap();
					for (int i = 0; i < optionArr.size(); i++) {
						CoviMap optionObj = optionArr.getJSONObject(i);
						optionParams.put("optionName",optionObj.getString("optionName"));
						optionParams.put("optionValue", i);
						optionParams.put("sortKey", i);
						optionParams.put("userFormID", params.get("userFormID"));
						optionParams.put("folderID", folderID);
						optionParams.put("optionCheck",optionObj.getString("optionCheck"));
						userDefFieldManageSvc.createUserDefOption(optionParams);
					}
				} else {
					userDefFieldManageSvc.deleteUserDefFieldOption(params);
				}
			}
			userDefFieldManageSvc.restoreUserDefFieldValue(params);

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
	 * editUserDefField : 확장옵션 - 사용자 정의필드 데이터 재생성
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/dataRemakeUserDefField.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap dataRemakeUserDefField(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();

		try {
			String folderID = request.getParameter("folderID");				//FolderID
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			
			userDefFieldManageSvc.restoreUserDefFieldValue(params);
			
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
	 * selectUserDefFieldOptionList : 확장옵션 - 사용자정의 필드Grid의 행을 선택할 경우 필드 옵션 조회
	 * @param request
	 * @param response
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/selectUserDefFieldOptionList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectUserDefFieldOptionList(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String folderID = request.getParameter("folderID");
			String userFormID = request.getParameter("userFormID");
			
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("userFormID", userFormID);
			params.put("lang", SessionHelper.getSession("lang"));

			//이전의 폴더 ID 경로 조회
			result = (CoviList) userDefFieldManageSvc.selectUserDefFieldOptionList(params).get("list");
			
		    returnData.put("optionList",result);
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
	 * deleteUserDefOption : 필드 옵션 삭제 - 수정/필드 삭제시 옵션데이터 삭제
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deleteUserDefOption.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteUserDefOption(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviList result = new CoviList();
		try {
			String optionID = request.getParameter("optionID");
			
			CoviMap params = new CoviMap();
			params.put("optionID", optionID);

			userDefFieldManageSvc.deleteUserDefFieldOption(params);
			
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
	 * deleteUserDefField : 확장옵션 - 사용자정의 필드Grid에서 체크된 항목 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnData
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/deleteUserDefField.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap deleteUserDefField(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		
		try {
			String[] userFormIDs = StringUtil.replaceNull(request.getParameter("userFormIDs"), "").split(";");
			String folderID = request.getParameter("folderID");
			
			CoviMap params = new CoviMap();
			params.put("userFormIDs", userFormIDs);
			params.put("folderID", folderID);
			
			
			userDefFieldManageSvc.deleteUserDefField(params);			//board_userform
			
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
	
	
	@RequestMapping(value = "admin/moveUserDefField.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap moveUserDefField(HttpServletRequest request, HttpServletResponse response) throws Exception{
		CoviMap returnData = new CoviMap();
		CoviMap result = new CoviMap();
		try {
			String folderID = request.getParameter("folderID");
			String sortKey = request.getParameter("sortKey");
			String userFormID = request.getParameter("userFormID");
			String mode = request.getParameter("mode");
				
			CoviMap params = new CoviMap();
			params.put("folderID", folderID);
			params.put("orgSortKey", sortKey);
			params.put("userFormID", userFormID);
			params.put("mode", mode);
			
			result = (CoviMap) userDefFieldManageSvc.selectTargetUserDefFieldSortKey(params).get("target");	//순서 변경할 sortkey 조회
			if(!result.isEmpty()){	//최상위 혹은 최하위에 해당하거나 순서 변경을 할 대상을 찾지 못할경우의 처리 
				//현재 sortkey를 검색된 sortkey로 update
				params.put("sortKey", result.get("SortKey"));

				CoviMap targetParams = new CoviMap();
				targetParams.put("userFormID", result.get("UserFormID"));
				targetParams.put("sortKey", sortKey);

				userDefFieldManageSvc.exchangeUserDefFieldSortKey(params, targetParams);
			} else {
				returnData.put("message", DicHelper.getDic("msg_gw_UnableChangeSortKey"));
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
}
