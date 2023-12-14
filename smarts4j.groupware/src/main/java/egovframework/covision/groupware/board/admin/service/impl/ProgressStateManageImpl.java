package egovframework.covision.groupware.board.admin.service.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.board.admin.service.ProgressStateManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("ProgressStateManageSvc")
public class ProgressStateManageImpl extends EgovAbstractServiceImpl implements ProgressStateManageSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * 진행상태 리스트 조회
	 * @param params folderID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectProgressStateList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.board.selectProgressStateList", params);
		CoviList optionList= CoviSelectSet.coviSelectJSON(list, "optionText,optionValue");
		
		resultList.put("list",optionList);
		return resultList;
	}

	/**
	 * 진행상태 추가
	 * @param params folderID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int createProgressState(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.createProgressState", params);
	}

	/**
	 * 진행상태 표시명 수정
	 * @param params categoryID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int updateProgressState(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateProgressState", params);
	}
	

	/**
	 * @param params categoryID
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int deleteProgressState(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.deleteProgressState", params);
	}
	
	/**
	 * @param params categoryID
	 * @description 삭제하는 카테고리 ID를 사용하는 게시글의 CategoryID 컬럼 NULL처리
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int initMessageCategoryID(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.initMessageCategoryID", params);
	}

}
