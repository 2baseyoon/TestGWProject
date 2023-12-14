package egovframework.covision.groupware.board.user.service.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.board.user.service.BoardCommonSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import egovframework.baseframework.util.PropertiesUtil;

@Service("BoardCommonSvc")
public class BoardCommonSvcImpl extends EgovAbstractServiceImpl implements BoardCommonSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne; 
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");

	/**
	 * @param params
	 * @param model
	 * @param request : DomainID, MenuID
	 * @return CoviMap 폴더/게시판 트리 메뉴 조회
	 * @throws Exception
	 */
	@Override
	public CoviMap selectTreeFolderMenu(CoviMap params) throws Exception {
//		params.put("folderIDs", coviMapperOne.list("user.board.selectFolderViewAuth", params));
		params.put("isSaaS", isSaaS);
		CoviList list = coviMapperOne.list("user.board.selectTreeFolderMenu", params);
		
		CoviList resultList = new CoviList();
		String checkFolderID = ";";
		
	    for(Object jsonObject : list){
			CoviMap folderData = (CoviMap) jsonObject;
			if(folderData.get("MemberOf") == null || (params.getString("communityID") != null && folderData.getString("MemberOf").equals("0")) || checkFolderID.indexOf(";" + folderData.get("MemberOf") + ";") > -1) {
				checkFolderID += folderData.get("FolderID") + ";";
				resultList.add(folderData);
			}
		}
		
		CoviMap result = new CoviMap();
		result.put("list", CoviSelectSet.coviSelectJSON(resultList));
		return result;
	}
	
	/**
	 * @param params UserCode
	 * @description 즐겨찾기 게시판(이전 관심게시) 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectFavoriteGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.board.selectFavoriteGridCount", params);
	}
	
	/**
	 * @param params UserCode
	 * @description 즐겨찾기 게시판(이전 관심게시) 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectFavoriteGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.board.selectFavoriteGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "FolderID,MultiDisplayName,FolderPath,RegistDate"));
		return resultList;
	}
	
	/**
	 * @param params DomainID, MenuID, FolderID
	 * @description 게시판 항목 선택시 상위 폴더 경로 표시 
	 * 				통합게시 분류 > 공지 > 
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectFolderPath(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("user.board.selectFolderPath", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DisplayName"));
		return resultList;
	}
	
	@Override
	public CoviMap selectUserDefFieldList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("user.board.selectUserDefFieldList",params);

		CoviList fieldList=CoviSelectSet.coviSelectJSON(list);
		
		for (int i = 0; fieldList.size() > i; i++) {
			CoviMap fieldObj = fieldList.getJSONObject(i);

			if (Integer.parseInt(fieldObj.getString("OptionCnt")) > 0) {
				params.put("userFormID", fieldObj.getString("UserFormID"));
				CoviList listOption = coviMapperOne.list("user.board.selectUserDefFieldOptionList",params);
				
				fieldObj.put("Option", CoviSelectSet.coviSelectJSON(listOption, "OptionID,UserFormID,OptionName,OptionValue,OptionCheck"));
			}
		}
		
		resultList.put("list", fieldList);
		return resultList;
	}
	
	@Override
	public CoviMap selectUserDefFieldOptionList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("user.board.selectUserDefFieldOptionList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "OptionID,UserFormID,OptionName,OptionValue,OptionCheck"));
		return resultList;
	}
	
	
	/**
	 * @param params DomainID, BizSection( 'Board', 'Doc' )
	 * @description 게시글 작성화면에서 게시판 목록 조회 기능 
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectBoardList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("isSaaS", isSaaS);
		CoviList list = coviMapperOne.list("user.board.selectBoardList", params);
		CoviList boardList= CoviSelectSet.coviSelectJSON(list, "optionText,optionValue,FolderID,FolderType,DisplayName");
		
		resultList.put("list",boardList);
		return resultList;
	}
	
	/**
	 * @param params DomainID, BizSection( 'Board', 'Doc' )
	 * @description 게시글 작성화면에서 게시판 목록 조회 기능 
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectSimpleBoardList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("user.board.selectSimpleBoardList", params);
		CoviList boardList= CoviSelectSet.coviSelectJSON(list, "optionText,optionValue,groupText,groupValue");
		
		resultList.put("list",boardList);
		return resultList;
	}
	
	/**
	 * @param params FolderID
	 * @description 게시판별 카테고리 목록 조회
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectCategoryList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("user.board.selectCategoryList", params);
		CoviList categoryList= CoviSelectSet.coviSelectJSON(list, "optionText,optionValue,MemberOf,MemberOfName");
		
		resultList.put("list",categoryList);
		return resultList;
	}
	
	/**
	 * @param params FolderID
	 * @description 본문양식 목록 조회
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectBodyFormList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("user.board.selectBodyFormList", params);
		CoviList formList= CoviSelectSet.coviSelectJSON(list, "optionText,optionValue");
		
		resultList.put("list",formList);
		return resultList;
	}
	
	/**
	 * @param params UserCode, lang
	 * @description 본문양식 목록 조회
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectRegistDeptList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList deptList= CoviSelectSet.coviSelectJSON(coviMapperOne.list("user.board.selectRegistDeptList", params), "optionText,optionValue");
		
		resultList.put("list",deptList);
		return resultList;
	}
	
	/**
	 * @param params UserCode, MessageID
	 * @description 수정 페이지 진입시 체크아웃
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateMessageCheckOut(CoviMap params) throws Exception {
		//체크인,아웃 히스토리에 체크아웃 기록 추가
		params.put("actType", "CheckOut");
		coviMapperOne.insert("user.message.createCheckInOutHistory", params);
		return coviMapperOne.update("user.message.updateMessageCheckOut", params);
	}
	
	/**
	 * @param params FolderID
	 * @description 처리 상태 목록 조회
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectProgressStateList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("user.board.selectProgressStateList", params);
		CoviList boardList= CoviSelectSet.coviSelectJSON(list, "optionText,optionValue");
		
		resultList.put("list",boardList);
		return resultList;
	}
	
	@Override
	public CoviMap selectMyInfoProfileBoardData(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.board.selectMyInfoProfileBoardData", params);
		CoviList boardList= CoviSelectSet.coviSelectJSON(list, "MessageID,FolderID,FolderName,Version,Subject,RegistDate,MenuID,MenuName,MenuURL");
		
		resultList.put("list",boardList);
		return resultList;
	}
	
	@Override
	public CoviMap selectBoardIsMobileSupport(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		
		CoviMap list = coviMapperOne.select("user.board.selectBoardMobileSupport", params);
		
		resultObj.put("isMobileSupport",list.get("isMobileSupport"));
		resultObj.put("status", Return.SUCCESS);
		
		return resultObj;
	}
	/**
	 * @Method selectUserBoardTreeData - 이관 게시판 목록 조회(전자결재 완료문서에서 사용)
	 * @작성자 Covision
	 * @작성일 2022. 8. 11.
	 * @param params
	 * @param store
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviList selectUserBoardTreeData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.board.selectUserBoardTreeData", params);
		return CoviSelectSet.coviSelectJSON(list, "FolderID,MemberOf,itemType,FolderType,FolderPath,MenuID,type,FolderName,MemberOf,DisplayName,SortPath,hasChild,OwnerFlag");
	}
}
