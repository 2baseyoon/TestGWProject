package egovframework.covision.groupware.collab.user.service.impl;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.collab.user.service.CollabStatisSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import egovframework.coviframework.util.ComUtils;
import java.util.List;

@Service("CollabStatisSvc")
public class CollabStatisSvcImpl extends EgovAbstractServiceImpl implements CollabStatisSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne; 
	
	
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");

	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 리스트
	 * @throws Exception
	 */
	@Override
	public CoviMap getStatisList(CoviMap params) throws Exception {
		CoviMap cmap = new CoviMap();
		//CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap page=null;
		if (SessionHelper.getSession("isCollabAdmin").equals("ADMIN")){
			params.put("isAdmin", "Y");
		}
		else{
			params.put("includeViewer", "Y");
		}
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt	= 0;
			cnt = (int) coviMapperOne.getNumber("collab.common.getUserProjectCnt" , params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}	
		
		cmap.put("page", page);
		cmap.put("prjList",coviMapperOne.list("collab.common.getUserProject", params));
		return cmap;
		
	}
	
	//프로젝트 상태별 현황
	@Override
	public CoviMap getStatisCurst(CoviMap params) throws Exception {
		CoviMap cmap = new CoviMap();
		//CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap page=null;
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt	= 0;
			cnt = (int) coviMapperOne.getNumber("collab.statis.getStatisCurstListCnt" , params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}

		cmap.put("page", page);
		cmap.put("prjList",coviMapperOne.list("collab.statis.getStatisCurstList", params));
		return cmap;
		
	}
	
	//사용자별 현항
	@Override
	public CoviMap getStatisUserCurst(CoviMap params) throws Exception {
		CoviMap cmap = new CoviMap();
		//CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap page=null;
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt	= 0;
			cnt = (int) coviMapperOne.getNumber("collab.statis.getStatisUserCurstCnt" , params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}	
		
		cmap.put("page", page);
		cmap.put("dataList",coviMapperOne.list("collab.statis.getStatisUserCurst", params));
		return cmap;
		
	}
	

	//사용자별 현항
	@Override
	public CoviMap getStatisUserData(CoviMap params) throws Exception {
		//oviMap returnMap = new CoviMap();
		
		java.util.ArrayList<Object> filter = new java.util.ArrayList<>((List)coviMapperOne.selectList("collab.project.getTeamMember", params));
		CoviList taskData = new CoviList();
		for (int i = 0; i < filter.size(); ++i) {
			CoviMap taskMap = new CoviMap();
			taskMap.put("prjSeq","");
			taskMap.put("mode",params.get("mode"));
			taskMap.put("startDate",params.get("startDate"));
			taskMap.put("endDate",params.get("endDate"));
			taskMap.put("groupKey", "Member");
			taskMap.put("groupCode", ((CoviMap)filter.get(i)).get("UserCode"));

			int cnt = (int) coviMapperOne.getNumber("collab.statis.getStatisStatusCurstCnt", taskMap);
	        CoviMap page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
			CoviMap dataMap = new CoviMap();
			dataMap.put("key", filter.get(i));
			dataMap.put("list", coviMapperOne.list("collab.statis.getStatisStatusCurst", taskMap));
			dataMap.put("page", page);
			taskData.add(dataMap);
				
		}

        CoviMap  resultMap = new CoviMap();
        resultMap.put("taskData", taskData);
        resultMap.put("taskFilter", filter);
		return resultMap;
	}
		
	//사용자별 상태별 현항
	@Override
	public CoviMap getStatisStatusCurst(CoviMap params) throws Exception {
		CoviMap cmap = new CoviMap();
		//CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap page=null;

		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt	= 0;
			cnt = (int) coviMapperOne.getNumber("collab.statis.getStatisStatusCurstCnt" , params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}	
		
		cmap.put("page", page);
		cmap.put("dataList",coviMapperOne.list("collab.statis.getStatisStatusCurst", params));
		return cmap;
		
	}
	
	//팀별 현항
	@Override
	public CoviMap getStatisTeamCurst(CoviMap params) throws Exception {
		CoviMap cmap = new CoviMap();
		//CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap page=null;
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt	= 0;
			cnt = (int) coviMapperOne.getNumber("collab.statis.getStatistTeamCurstCnt" , params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}	
		
		cmap.put("page", page);
		cmap.put("dataList",coviMapperOne.list("collab.statis.getStatistTeamCurst", params));
		return cmap;
	}	
			
}
