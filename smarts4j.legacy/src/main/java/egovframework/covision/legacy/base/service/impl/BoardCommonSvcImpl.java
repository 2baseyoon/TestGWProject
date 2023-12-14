package egovframework.covision.legacy.base.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.legacy.base.service.BoardCommonSvc;
import egovframework.covision.legacy.data.CoviMapperLegacyOne;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

//LEGACY FRAMEWORK DataSource Example

@Service("BoardCommonSvc")
public class BoardCommonSvcImpl extends EgovAbstractServiceImpl implements BoardCommonSvc{

	@Resource(name="CoviMapperLegacyOne")
	private CoviMapperLegacyOne legacyDB;

	/**
	 * @param params
	 * @param model
	 * @param request : DomainID, MenuID
	 * @return CoviMap 폴더/게시판 트리 메뉴 조회
	 * @throws Exception
	 */
	@Override
	public CoviMap selectTreeFolderMenu(CoviMap params) throws Exception {
		CoviList list = legacyDB.list("user.board.selectTreeFolderMenu", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "itemType,FolderID,MenuID,FolderType,FolderPath,MemberOf,DisplayName,SortPath,hasChild,FolderName,type,OwnerFlag"));
		return resultList;
	}
	
}
