package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.StampManagerSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("stampManagerService")
public class StampManagerSvcImpl extends EgovAbstractServiceImpl implements StampManagerSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getStampList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.stampManage.selectStempListCnt", params);
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.stampManage.selectStempList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", pagingData);
		
		return resultList;
	}	

	@Override
	public CoviMap getStampData(CoviMap params) throws Exception {		
		CoviMap map = coviMapperOne.select("admin.stampManage.selectStempData", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map));	
		
		return resultList;
	}
	
	//등록
	@Override
	public int insertStampData(CoviMap params) throws Exception {
		int cnt; 
		// 대표직인은 하나밖에 사용할수없으므로 
		// @UseYn이 Y로 들어오면 다른 행의 USEYN은 N으로 업데이트
		if("Y".equals(params.get("UseYn"))){
			cnt = coviMapperOne.update("admin.stampManage.PreprocessingStempData", params);
		}		
		cnt = coviMapperOne.insert("admin.stampManage.insertStempData", params);
		return cnt;
	}
	
	//삭제
	@Override
	public int deleteStampData(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.stampManage.deleteStempData", params);
	}
	
	//수정
	@Override
	public int updateStampData(CoviMap params) throws Exception {
		int cnt; 
		
		// 대표직인은 하나밖에 사용할수없으므로 
		// @UseYn이 Y로 들어오면 다른 행의 USEYN은 N으로 업데이트
		if("Y".equals(params.get("UseYn"))){
			cnt = coviMapperOne.update("admin.stampManage.PreprocessingStempData", params);
		}
		cnt =  coviMapperOne.update("admin.stampManage.updateStampData", params);
		return cnt;
	}
	
	//직인 사용 여부 변경
	@Override
	public int setUseStampUse(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.stampManage.setUseStampUse", params);
	}
}
