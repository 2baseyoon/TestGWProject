package egovframework.covision.groupware.board.admin.service.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.board.admin.service.CategoryManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("CategoryManageSvc")
public class CategoryManageImpl extends EgovAbstractServiceImpl implements CategoryManageSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * @param params folderID
	 * @description 카테고리 리스트 조회
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public CoviMap selectCategoryList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("admin.board.selectCategoryList", params);
		CoviList optionList= CoviSelectSet.coviSelectJSON(list, "optionText,optionValue");
		resultList.put("list",optionList);
		
		return resultList;
	}

	/**
	 * @param params folderID
	 * @description 카테고리 추가
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int createCategory(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.createCategory", params);
	}

	/**
	 * @param params categoryID
	 * @description 카테고리 표시명 수정
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int updateCategory(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateCategory", params);
	}
	
	/**
	 * @param params categoryID
	 * @description 카테고리 추가이후 sortpath, categorypath 업데이트
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int updateCategoryPath(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.updateCategoryPath", params);
	}

	/**
	 * @param params categoryID
	 * @description 카테고리 Row 삭제
	 * @return CoviMap 
	 * @throws Exception
	 */
	@Override
	public int deleteCategory(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.board.deleteCategory", params);
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
