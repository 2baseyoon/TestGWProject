package egovframework.covision.groupware.workreport.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.workreport.service.WorkDaySettingService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("WorkDaySettingService")
public class WorkDaySettingServiceImpl extends EgovAbstractServiceImpl implements WorkDaySettingService {

	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap selectList(CoviMap params) throws Exception {
		CoviList resultList = null;
		
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
 		
		if(params.containsKey("pageNo")) {
			int resultCnt = (int) coviMapperOne.getNumber("groupware.workreport.selectSetWorkTimeCnt", params);
		 	page = ComUtils.setPagingData(params, resultCnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
			returnObj.put("cnt", resultCnt);
		}
		
		resultList = coviMapperOne.list("groupware.workreport.selectSetWorkTimeList", params);
		returnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "year,month,workday,registdate,modifydate"));
		
		return returnObj;
	}

	@Override
	public CoviMap selectOne(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public CoviMap insert(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		CoviMap duplicate = coviMapperOne.select("groupware.workreport.cntWorkTimeSetting", params);
		int duplicateCnt = duplicate.getInt("CNT");
		
		if(duplicateCnt == 0) {
			// 중복이 아니라면
			returnCnt = coviMapperOne.insert("groupware.workreport.insertWorkTimeSetting", params);
			
			if(returnCnt == 1) resultObj.put("result", "OK");
			else resultObj.put("result", "FAIL");
		} else {
			// 중복
			resultObj.put("result", "EXIST");
		}
		return resultObj;
	}

	@Override
	public int delete(CoviMap params) throws Exception {
		int returnCnt = 0;
		returnCnt = coviMapperOne.delete("groupware.workreport.deleteWorkTimeSetting", params);
		return returnCnt;
	}

	@Override
	public int update(CoviMap params) throws Exception {
		int returnCnt = 0;
		returnCnt = coviMapperOne.update("groupware.workreport.updateWorkTimeSetting", params);
		return returnCnt;
	}
	
}
