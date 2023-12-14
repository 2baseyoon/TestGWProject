package egovframework.coviaccount.user.service.impl;

import javax.annotation.Resource;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.DeadlineSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("DeadlineSvc")
public class DeadlineSvcImpl extends EgovAbstractServiceImpl implements DeadlineSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * @Method Name : getDeadlineInfo
	 * @Description : 마감일자 정보 조회
	 */
	@Override
	public CoviMap getDeadlineInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list	= coviMapperOne.list("account.deadline.getDeadlineInfo", params);
		resultList.put("list",AccountUtil.convertNullToSpace(list));
		return resultList;
	}
	
	/**
	 * @Method Name : saveDeadlineInfo
	 * @Description : 마감일자 저장
	 */
	@Override
	public CoviMap saveDeadlineInfo(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		int cnt = (int) coviMapperOne.getNumber("account.deadline.getDeadlineCnt", params);
		if(cnt > 0) {
			coviMapperOne.update("account.deadline.updateDeadlineInfo", params);
		} else {
			coviMapperOne.insert("account.deadline.insertDeadlineInfo", params);
		}
		
		return resultList;
	}
}
