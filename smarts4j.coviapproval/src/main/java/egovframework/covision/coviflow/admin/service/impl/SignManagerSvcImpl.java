package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.SignManagerSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("signManagerService")
public class SignManagerSvcImpl extends EgovAbstractServiceImpl implements SignManagerSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getSignList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.signManager.selectSignListCnt", params);

		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);		
		list = coviMapperOne.list("admin.signManager.selectSignList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,USER_SIGN,UR_Name,DEPT_Name,JobLevelName,JobTitleName,JobPositionName,DEPT_Code,EntCode"));
		resultList.put("page", pagingData);

		return resultList;
	}	

	@Override
	public CoviMap getSignData(CoviMap params) throws Exception {		
		CoviMap map = coviMapperOne.select("admin.signManager.selectSignData", params);		
		return CoviSelectSet.coviSelectMapJSON(map);
	}

	//등록
	@Override
	public int insertSignData(CoviMap params) throws Exception {
		// 전체 서명이미지 사용여부 N으로 업데이트 후, Y로 insert
		coviMapperOne.update("user.signRegistration.insertUserSignUseN",params);
		return coviMapperOne.insert("admin.signManager.insertSignData", params);
	}
		
	//삭제
	@Override
	public int deleteSignImage(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.signManager.deleteSignImage", params);
	}	
	
	// 대표 사인 변경
	@Override
	public int changeUseSign(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.signManager.changeUseSign", params);
	}
	
	// 대표 사인 변경 (기존 Y -> N)
	@Override
	public int releaseUseSign(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.signManager.releaseUseSign", params);
	}
}
