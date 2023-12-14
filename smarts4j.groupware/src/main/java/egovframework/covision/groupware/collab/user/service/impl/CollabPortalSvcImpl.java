package egovframework.covision.groupware.collab.user.service.impl;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.covision.groupware.collab.user.service.CollabCommonSvc;
import egovframework.covision.groupware.collab.user.service.CollabPortalSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.util.SessionHelper;

import javax.annotation.Resource;

import java.util.List;

@Service("CollabPortalSvc")
public class CollabPortalSvcImpl extends EgovAbstractServiceImpl implements CollabPortalSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne; 
	
	@Autowired
	private CollabCommonSvc collabCommonSvc;

	
	private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");

	/**
	 * @param params
	 * @param model
	 * @param request : UserId
	 * @return CoviMap 프로젝트 정보
	 * @throws Exception
	 */
	@Override
	public CoviMap getPortalMain(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		params.put("myTodo", "Y");
		params.put("tagtype", "TAG");
		params.put("tagSeq", "TodayTask");
		
		//params.put("tagData", "((b.EndDate is null or b.EndDate <=  DATE_FORMAT(NOW(),'%Y%m%d')) AND B.TaskStatus != 'C')");
		if (params.get("tagtype") != null  && params.get("tagSeq") != null  && !params.getString("tagSeq").equals("")){
        	CoviMap tagMap = coviMapperOne.selectOne("collab.todo.getTagList",params.getString("tagSeq"));
        	String tagData = tagMap.getString("tagData");
        	params.put("tagData", tagData);
        }
	
		resultList.put("prjList",coviMapperOne.list("collab.common.getUserProject", params));
		resultList.put("deptList",coviMapperOne.list("collab.common.getUserTeam", params));
		resultList.put("myTaskCnt",coviMapperOne.selectOne("collab.todo.myTaskCnt", params));
		resultList.put("myFavorite",coviMapperOne.list("collab.todo.getMyFavorite", params));
		resultList.put("tmplList",coviMapperOne.list("collab.tmpl.getTmplList", params));
		resultList.put("myConf",coviMapperOne.selectOne("collab.common.getMyConf", params));
		
		params.put("sortColumn","Delay");
		params.put("sortDirection","DESC");
		resultList.put("myTaskList",coviMapperOne.list("collab.project.getProjectTask", params));

		

		return resultList;
	}


}
