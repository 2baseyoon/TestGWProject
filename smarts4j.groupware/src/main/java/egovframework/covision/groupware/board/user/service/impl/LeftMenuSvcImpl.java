package egovframework.covision.groupware.board.user.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.board.user.service.LeftMenuSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("LeftMenuSvc")
public class LeftMenuSvcImpl extends EgovAbstractServiceImpl implements LeftMenuSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap selectBoardLeftMenuList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.leftMenu.selectLeftMenu", params);
		CoviMap resultList = new CoviMap();
		//컬럼명 명시
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "idx,parent_idx,level,menu_name,url,sort_key,HasFolder,extend,use_yn"));
		return resultList;
	}
}
