package egovframework.covision.groupware.collab.user.service.impl;

import javax.annotation.Resource;

import egovframework.baseframework.util.SessionHelper;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.collab.user.service.CollabHistSvc;

@Service("CollabHistSvc")
public class CollabHistSvcImpl extends EgovAbstractServiceImpl implements CollabHistSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	/**
	 * @Method Name : getTmplRequestList
	 * @Description : 근무제 조회
	 */
	@Override 
	public CoviMap getTaskHistList(CoviMap params) {
		CoviMap resultList	= new CoviMap();
		CoviMap page = new CoviMap();
		CoviList list = new CoviList();

		params.put("lang", SessionHelper.getSession("lang"));
		
		if(params.containsKey("pageNo")) {
			int cnt	= (int) coviMapperOne.getNumber("collab.hist.getTaskHistListCnt" , params);
			page = ComUtils.setPagingCoviData(params, cnt);
			params.addAll(page);
			resultList.put("page", page);
		}	
		
		list = coviMapperOne.list("collab.hist.getTaskHistList", params);
		resultList.put("list", list);
		
		return resultList; 
	}
	
}
