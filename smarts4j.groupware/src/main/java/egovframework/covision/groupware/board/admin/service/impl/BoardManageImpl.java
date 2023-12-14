package egovframework.covision.groupware.board.admin.service.impl;

import java.net.URLDecoder;
import java.util.Stack;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.board.admin.service.BoardManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import egovframework.baseframework.util.json.JSONSerializer;

@Service("BoardManageSvc")
public class BoardManageImpl extends EgovAbstractServiceImpl implements BoardManageSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	
	/**
	 * @param params DomainID
	 * @description 도메인/회사 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDomainList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList domainList = ComUtils.getAssignedDomainID();
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("assignedDomain", domainList);
		
		CoviList list = coviMapperOne.list("admin.board.selectDomainList", params);
		CoviList companyList= CoviSelectSet.coviSelectJSON(list, "optionText,optionValue");
		
		resultList.put("list",companyList);
		
		return resultList;
	}
	
	/**
	 * @description 게시판/문서관리 메뉴 목록 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMenuList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.board.selectMenuList", params);
		CoviList menuList = CoviSelectSet.coviSelectJSON(list, "optionText,optionValue");
		
		resultList.put("list",menuList);
		return resultList;
	}
	
	/**
	 * @param params
	 * @param model
	 * @param request : DomainID
	 * @Description 게시 관리자 메뉴 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAdmin_LeftBoardMenu(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.board.selectAdmin_LeftBoardMenu", params);

		CoviMap resultList = new CoviMap();
		//컬럼명 명시
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MenuID,DomainID,DisplayName,URL,HasFolder,SortKey,Description"));
		return resultList;
	}
	
	/**
	 * @param params
	 * @param model
	 * @param request : DomainID
	 * @return CoviMap 게시 관리자 메뉴 조회
	 * @throws Exception
	 */
	@Override
	public CoviMap selectTreeFolderMenu(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.board.selectTreeFolderMenu", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		return resultList;
	}
	
	/**
	 * @param params
	 * @param model
	 * @param request : DomainID, MenuID, FolderID
	 * @return CoviMap 게시 관리자 메뉴 조회
	 * @throws Exception
	 */
	@Override
	public CoviMap selectFolderGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
 		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("admin.board.selectFolderGridCount", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
			resultList.put("page", page);
			resultList.put("cnt", cnt);
		}
		
		CoviList list = coviMapperOne.list("admin.board.selectFolderGridList",params);		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "FolderID,DomainID,MenuID,SortKey,DisplayName,MultiDisplayName,FolderType,FolderPath,IsDisplay,IsUse,DeleteDate,RegistDate,RegisterCode"));
		
		return resultList;
	}
	
	@Override
	public int selectNextSortKey(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.board.selectNextSortKey", params);
	}
	
	/**
	 * @description 폴더 타입 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectFolderTypeList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.board.selectFolderTypeList", params);
		CoviList folderTypeList = CoviSelectSet.coviSelectJSON(list, "optionText,optionValue");
		
		resultList.put("list",folderTypeList);
		return resultList;
	}
	
	/**
	 * @description 처리상태 목록 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectRequestStatusList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.board.selectRequestStatusList", params);
		CoviList statusList = CoviSelectSet.coviSelectJSON(list, "optionText,optionValue");
		
		resultList.put("list",statusList);
		return resultList;
	}
	
	
	/**
	 * @param params
	 * @description 보안등급 목록 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectSecurityLevelList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.board.selectSecurityLevelList", params);
		CoviList securityLevelList = CoviSelectSet.coviSelectJSON(list, "optionText,multiOptionText,optionValue");
		
		resultList.put("list",securityLevelList);
		return resultList;
	}

	/**
	 * @param params folderID
	 * @description 상위폴더의 SortPath, FolderPath 조회
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectPathInfo(CoviMap params) throws Exception{
		CoviMap result = new CoviMap();
		result.addAll(coviMapperOne.select("admin.board.selectPathInfo", params));
		return result;
	}
	
	/**
	 * @param params folderType
	 * @description 폴더 타입별 Default 데이터 조회(covi_smart4j.board_config_default)
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDefaultConfig(CoviMap params) throws Exception{
		CoviMap result = new CoviMap();
		result.addAll(coviMapperOne.select("admin.board.selectDefaultConfig", params));
		return result;
	}
	
	/**
	 * @param params folderID
	 * @description 게시판별 설정 데이터 조회(covi_smart4j.board_config)
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectBoardConfig(CoviMap params) throws Exception{
		CoviMap result = new CoviMap();
		result.addAll(coviMapperOne.select("admin.board.selectBoardConfig", params));
		return result;
	}
	
	@Override
	public int pasteBoard(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.pasteBoard", params);
	}
	
	@Override
	public int deleteBoard(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.deleteBoard", params);			//폴더/게시판 항목 삭제
	}
	
	@Override
	public int deleteLowerBoard(CoviMap params) throws Exception {
		int cnt = 0;
		//하위 게시판 검색
		params.put("folderIDs", coviMapperOne.select("admin.board.selectLowerFolderID", params).get("folderIDs"));
		params.put("folderIDArr", params.getString("folderIDs").split(","));
		if(params.get("folderIDs")!=null){
			cnt += coviMapperOne.update("admin.message.deleteMessageByFolder", params);	//폴더/게시판 삭제시 게시글도 연속 삭제
			cnt += coviMapperOne.update("admin.board.deleteLowerBoard", params);
			cnt += coviMapperOne.update("admin.board.updateCurrentFileSizeByFolder", params);
		}
		return cnt;
	}

	@Override
	public int createBoard(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.board.createBoard", params);
	}
	
	@Override
	public int createBoardConfig(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.board.createBoardConfig", params);
	}

	/**
	 * @param params folderID
	 * @description Grid 내부 표시/사용 버튼 선택시 업데이트
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int updateFlag(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateFlag", params);
	}
	
	/**
	 * @param params managerID
	 * @description Grid 내부 표시/사용 버튼 선택시 업데이트
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int updateDocNumberFlag(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateDocNumberFlag", params);
	}
	
	/**
	 * @param params folderID
	 * @description 폴더 복원
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int restoreFolder(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.restoreFolder", params);
	}

	/**
	 * @param params folderID, 기본설정 탭 항목
	 * @description 폴더/게시판 수정
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int updateBoard(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateBoard", params);
	}

	//사용자에서도 호출하여 사용할 수 있도록 BoardManageImple에 임의로 선언
	public void updateApprovalProcess(CoviMap params) throws Exception{
		CoviList activityArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("processActivityList"), "utf-8"));
		
		int processDefFlag = 0;
		if("".equals(params.get("processID")) ){
			params.put("objectType", params.get("objectType"));
			params.put("objectID", params.get("objectID"));
			params.put("displayName", params.get("displayName"));
			params.put("activityCnt", activityArray.size());	//게시 승인자 수
			params.put("registerCode", SessionHelper.getSession("USERID"));
			processDefFlag = coviMapperOne.insert("admin.board.createProcessDef", params);
		} else {
			params.put("activityCnt", activityArray.size());	//게시 승인자 수
			params.put("modifierCode", SessionHelper.getSession("USERID"));
			processDefFlag = coviMapperOne.update("admin.board.updateProcessDef", params);
		}
		
		if(processDefFlag>0){
			coviMapperOne.update("admin.board.deleteProcessActivityDef", params);	//activity 일괄삭제후 재등록
			for(int i=0;i<activityArray.size();i++){
				CoviMap fieldObj = activityArray.getJSONObject(i);
				params.put("actorRole", fieldObj.get("ActorRole"));	//링크 이름
				params.put("step", fieldObj.get("Step"));		//링크 URL
				params.put("subStep", fieldObj.get("SubStep"));
				params.put("activityType", fieldObj.get("ActivityType"));
				params.put("actorCode", fieldObj.get("ActorCode"));
				params.put("registerCode", SessionHelper.getSession("USERID"));
				coviMapperOne.insert("admin.board.createProcessActivityDef", params);
			}
		}
	}
	
	/**
	 * @param params folderID, 기본 옵션 설정탭, 확장옵션 설정탭 항목
	 * @description 폴더/게시판 옵션 수정
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int updateBoardConfig(CoviMap params) throws Exception {
		int configCnt = (int) coviMapperOne.getNumber("admin.board.selectBoardConfigCnt", params);
		
		if(configCnt <= 0){
			createBoardConfig(params);
		}
		
		int cnt = coviMapperOne.update("admin.board.updateBoardConfig", params);
		
		//게시글 업데이트 성공 후 승인프로세스 수행
		//문서관리의 경우 useOwnerProcess만 관리, useUserProcess는 사용자 정의 프로세스 이기때문에 게시판에서만 사용
		if(cnt > 0 && ("Y".equals(params.get("useUserProcess")) || "Y".equals(params.get("useOwnerProcess")))){
			//
			params.put("objectType","FD");
			params.put("objectID",params.get("folderID"));
			params.put("displayName", "게시 운영자정의 승인프로세스");	//CHECK: Fixed된 값으로 사용됨
			updateApprovalProcess(params);	//승인 프로세스 변경처리
		}
		return cnt;
	}

	/**
	 * @param params folderID
	 * @description 폴더/게시판 설명 조회
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectBoardDescription(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("desc", coviMapperOne.select("admin.board.selectBoardDescription", params));
		return result;
	}
	
	@Override
	public String selectContentsID(CoviMap params) throws Exception {
		String ContentsID = coviMapperOne.selectOne("admin.board.selectContentsID", params);
		return ContentsID;
	}
	
	//순서 변경용 게시판 SortKey 조회
	@Override
	public CoviMap selectTargetBoardSortKey(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("target", coviMapperOne.select("admin.board.selectTargetBoardSortKey", params));
		return result;
	}
		
	//폴더 순서변경 
	@Override
	public int updateBoardSortKey(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateBoardSortKey", params);
	}

	//게시판 설명 CRUD /////
	@Override
	public int createBoardDescription(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.board.createBoardDescription", params);
	}

	@Override
	public int updateBoardDescription(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateBoardDescription", params);
	}

	@Override
	public int deleteBoardDescription(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.board.deleteBoardDescription", params);
	}

	//본문양식 CRUD /////
	@Override
	public int createBodyForm(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.board.createBodyForm", params);
	}

	@Override
	public int deleteBodyForm(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.board.deleteBodyForm", params);
	}
	
	@Override
	public CoviMap selectBodyForm(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.board.selectBodyForm", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "BodyFormID,FormPath,FormName,IsInit"));
		return resultList;
	}

	//본문양식중 체크박스에 체크된 항목을 초기양식으로 설정, 그외의 본문양식 데이터는 전부 IsInit을 N으로 수정
	@Override
	public int updateBodyFormInit(CoviMap params) throws Exception {
		coviMapperOne.update("admin.board.updateBodyFormInitN", params);
		return coviMapperOne.update("admin.board.updateBodyFormInit", params);
	}
	
	//붙여넣을 폴더 하위의 sortkey 검색 
	public CoviMap selectTargetFolderSortKey(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("desc", coviMapperOne.select("admin.board.selectTargetFolderSortKey", params));
		return result;
	}

	//잘라내기한 원본 폴더
	@Override
	public int updateOrginalFolder(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateOrginalFolder", params);
	}

	//잘라내기한 원본 폴더의 하위 폴더 MenuId, SortPath, FolderPath 수정
	@Override
	public int updateLowerFolder(CoviMap params) throws Exception {
		int cnt = 0;
		
		Stack<String> stack = new Stack<>();
		stack.add(params.getString("orgFolderID"));
		
		// 하위 게시판 검색
		while (!stack.isEmpty()) {
			String folderID = stack.pop();
			
			params.put("folderID", folderID);
			
			String folderIDs = coviMapperOne.select("admin.board.selectLowerFolderID", params).getString("folderIDs");
			
			if (StringUtil.isNotNull(folderIDs)) {
				String folderIDArr[] = folderIDs.split(",");
				
				for (String f : folderIDArr) {
					stack.add(f);
				}
				
				params.put("folderIDArr", folderIDArr);
				cnt += coviMapperOne.update("admin.board.updateLowerFolder", params);
			}
		}
		
		return cnt;
	}

	//게시판 환경설정 팝업(속성)에서 담당자의 이름 조회
	@Override
	public CoviMap selectBoardOwnerName(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.board.selectBoardOwnerName", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "MultiDisplayName"));
		return resultList;
	}

	@Override
	public CoviMap selectMenuByDomainID(CoviMap params) throws Exception {
		return coviMapperOne.select("admin.board.selectMenuByDomainID", params);
	}

	@Override
	public CoviMap selectProcessPerformerList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("admin.board.selectProcessPerformerList", params);
		CoviList activityList = CoviSelectSet.coviSelectJSON(list, "ProcessID,ActorCode,ActorRole,ActivityType,DisplayName,DeptName");
		
		resultList.put("list",activityList);
		return resultList;
	}
	
	@Override
	public CoviMap selectProcessTarget(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("processDef", coviMapperOne.select("admin.board.selectProcessTarget", params));
		return result;
	}
	
	//소유권, 담당부서 변경
	@Override
	public int changeDocInfo(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.changeDocInfo", params);
	}
	
	//base code 목록 조회
	public CoviMap selectBaseCodeList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.board.selectBaseCodeList", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list",CoviSelectSet.coviSelectJSON(selList, "optionValue,optionText"));
		return resultList;
	}
	
	//문서번호 정보 조회
	@Override
	public CoviMap selectDocNumberInfo(CoviMap params) throws Exception{
		CoviList selList = new CoviList();
		selList = coviMapperOne.list("admin.board.selectDocNumberInfo", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list",CoviSelectSet.coviSelectJSON(selList, "ManagerID,DomainID,Seq,FieldType,FieldLength,LanguageCode,Separator,IsUse,CreateDate,DeleteDate"));
		return resultList;
	}
	
	//문서 번호 규칙 생성
	@Override
	public int createDocNumber(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.board.createDocNumber", params);
	}

	//문서 번호 규칙 수정
	@Override
	public int updateDocNumber(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateDocNumber", params);
	}
	
	//문서 번호 규칙 삭제
	@Override
	public int deleteDocNumber(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.deleteDocNumber", params);
	}
	
	//커뮤니티 목록 조회 (selectbox) 
	public CoviMap selectCommunityList(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		// 전체 리스트 조회
		selList = coviMapperOne.list("admin.board.selectCommunityList", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list",CoviSelectSet.coviSelectJSON(selList, "optionValue,optionText"));
		return resultList;
	}
	
	//커뮤니티 폴더목록 조회 (selectbox)
	public CoviMap selectCommunityFolderTypeList(CoviMap params, String type)throws Exception{
		CoviList selList = new CoviList();
		StringUtil func = new StringUtil();
		// 전체 리스트 조회
		
		if(func.f_NullCheck(type).equals("C")){
			selList = coviMapperOne.list("admin.board.selectCommunityNotRootFolderTypeList", params);
		}else{
			selList = coviMapperOne.list("admin.board.selectCommunityFolderTypeList", params);
		}
		
		CoviMap resultList = new CoviMap();
		resultList.put("list",CoviSelectSet.coviSelectJSON(selList, "optionValue,optionText"));
		return resultList;
	}
	
	//커뮤니티 탑메뉴 추가
	public int createCommunityTopMenu(CoviMap params) throws Exception {
		
		if(coviMapperOne.getNumber("admin.board.selectCommunityMenuTopCount", params) > 0){
			return 0;
		}else{
			return coviMapperOne.insert("admin.board.createCommunityMenuTop", params);
		}
		
	}
	
	//커뮤니티 권한 수정
	public boolean updateCommunityACL(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.update("admin.board.updateCommunityACL", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	//커뮤니티 권한 추가
	public boolean createCommunityACL(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.insert("admin.board.createCommunityACL", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	// 회사, 부서 등의 필드명 조회
	@Override
	public CoviMap selectFieldLangInfos(CoviMap params)throws Exception{
		CoviList selList = new CoviList();
		params.put("lang", SessionHelper.getSession("lang"));
		selList = coviMapperOne.list("admin.board.selectFieldLangInfos", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list",CoviSelectSet.coviSelectJSON(selList, "compNm,compSnm,deptNm,deptSnm,folderNm"));
		return resultList;
	}
	
	// 위선순위 상위, 하위로 변경.
	@Override
	public int updateFieldSeq(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateFieldSeq", params);
	}
	
	public CoviMap selectPrevNextField(CoviMap params) throws Exception {
		return coviMapperOne.select("admin.board.selectPrevNextField", params);
	}
	
	// 권한 상속 > 하위 폴더 목록 조회
	@Override
	public CoviList selectInheritedACLList(CoviMap params) throws Exception {
		return coviMapperOne.list("admin.board.selectInheritedACLList", params);
	}
	//만료일 일괄 수정
	@Override
	public int updateExpiredDay(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateExpiredDay", params);
	}
	
	// 확장옵션: 게시분류 담당자 수정
	@Override
	public int updateCategoryManager(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateCategoryManager", params);
	}	
}