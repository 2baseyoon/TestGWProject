package egovframework.covision.groupware.board.admin.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.board.admin.service.UserDefFieldManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("UserDefFieldManageSvc")
public class UserDefFieldManageImpl extends EgovAbstractServiceImpl implements UserDefFieldManageSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	

	/**
	 * @param params folderID
	 * @description 사용자 정의 필드 Grid 데이터 조회
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectUserDefFieldGridList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.board.selectUserDefFormGridList",params);
		
		resultList.put("list",list);
		return resultList;
	}
	
	@Override
	public int selectUserDefFieldGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("admin.board.selectUserDefFormGridCount", params);
	}
	
	/**
	 * 사용자 정의 필드 Grid의 선택한 행에 해당하는 옵션 조회
	 * @param params folderID, userFormID
	 * @return CoviMap 
	 * @throws Exception
	 */
	public CoviMap selectUserDefFieldOptionList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.board.selectUserDefFieldOptionList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "OptionID,SortKey,OptionName,MultiDisplayName,OptionValue,OptionCheck"));
		return resultList;
	}
	
	/**
	 * 사용자 정의 필드 Grid의 선택한 행에 해당하는 옵션 조회
	 * @param params folderID, userFormID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int createUserDefField(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.board.createUserDefField", params);
	}
	
	/**
	 * 사용자 정의 필드 옵션 생성
	 * @param params folderID, userFormID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int createUserDefOption(CoviMap params) throws Exception {
		return coviMapperOne.insert("admin.board.createUserDefFieldOption", params);
	}
	
	/**
	 * 사용자 정의 필드 옵션 수정
	 * @param params folderID, userFormID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int updateUserDefField(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateUserDefField", params);
	}
	
	/**
	 * 사용자 정의 필드 삭제
	 * @param params folderID, userFormID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int deleteUserDefField(CoviMap params) throws Exception {
		int result = coviMapperOne.delete("admin.board.deleteUserDefField", params);;
		if (result > 0) {
			deleteUserDefFieldOption(params);		//board_userform_option
			restoreUserDefFieldValue(params);		// board_message_userform_value 테이블의 데이터 재생성
		}
		return result;
	}
	
	/**
	 * 사용자 정의 필드 옵션 삭제
	 * @param params folderID, userFormID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int deleteUserDefFieldOption(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.board.deleteUserDefFieldOption", params);
	}
	
	/**
	 * 사용자 정의 필드 설정값 삭제
	 * @param params folderID, userFormID
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int deleteBoardMessageUserFormValue(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.board.deleteBoardMessageUserFormValue", params);
	}

	/**
	 * 사용자정의 필드 sortkey 조회
	 * @param params folderID, userFormID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectTargetUserDefFieldSortKey(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		result.put("target", coviMapperOne.select("admin.board.selectTargetUserDefFieldSortKey", params));
		return result;
	}

	/**
	 * 사용자 정의 필드 sortkey 수정
	 * @param params folderID, userFormID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int updateUserDefFieldSortKey(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateUserDefFieldSortKey", params);
	}

	/**
	 * 사용자 정의 필드 순서로 필드 값 정렬하여 저장
	 * @param params folderID
	 * @return int 
	 * @throws Exception
	 */
	@Override
	public int restoreUserDefFieldValue(CoviMap params) throws Exception {
		deleteBoardMessageUserFormValue(params);
		int result = coviMapperOne.insert("admin.board.restoreBoardMessageUserformValue", params);
		
		return result;
	}

	/**
	 * 사용자 정의 필드 sortkey 순서 변경
	 * @param params folderID, targetParams folderID
	 * @return int 
	 * @throws Exception
	 */
	@Override
	public int exchangeUserDefFieldSortKey(CoviMap params, CoviMap targetParams) throws Exception {
		updateUserDefFieldSortKey(params);
		updateUserDefFieldSortKey(targetParams);
		int result = restoreUserDefFieldValue(params);
		return result;
	}
}
