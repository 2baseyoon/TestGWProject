package egovframework.covision.legacy.base.service.impl;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.legacy.base.service.CommonSvc;


@Service("commonService")
public class CommonSvcImpl extends EgovAbstractServiceImpl implements CommonSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	private Logger LOGGER = LogManager.getLogger(CommonSvcImpl.class);
	
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
		CoviList list = coviMapperOne.list("user.board.selectTreeFolderMenu", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "itemType,FolderID,MenuID,FolderType,FolderPath,MemberOf,DisplayName,SortPath,hasChild,FolderName,type,OwnerFlag"));
		return resultList;
	}

}
