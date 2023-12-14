package egovframework.core.manage.service.impl;

import javax.annotation.Resource;




import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.core.manage.service.UserLockManageSvc;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("UserLockManageSvc")
public class UserLockManageSvcImpl extends EgovAbstractServiceImpl implements UserLockManageSvc{
	
	@Autowired
	AuthorityService authSvc;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * 그리드에 사용할 데이터 Select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getUserLock(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
            int cnt     =  (int) coviMapperOne.getNumber("userlock.getUserLockCnt", params);
            page = ComUtils.setPagingCoviData(params, cnt);
            params.addAll(page);
		}

        resultList.put("list",  coviMapperOne.list("userlock.getUserLock", params));
        resultList.put("page", page);

		return resultList;
	}
	
	//히스코리 관련
	public int insertUserLockHistory(CoviMap reqMap) throws Exception {
		return coviMapperOne.insert("userlock.insertUserLockHistory", reqMap);
	}

	@Override
	public CoviMap getUserLockHistory(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
            int cnt     =  (int) coviMapperOne.getNumber("userlock.getUserLockHistoryCnt", params);
            page = ComUtils.setPagingCoviData(params, cnt);
            params.addAll(page);
		}

        resultList.put("list",  coviMapperOne.selectList("userlock.getUserLockHistory", params));
        resultList.put("page", page);

		return resultList;
	}
	
}
