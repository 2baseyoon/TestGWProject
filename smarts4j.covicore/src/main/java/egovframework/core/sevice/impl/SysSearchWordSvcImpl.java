package egovframework.core.sevice.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.core.sevice.SysSearchWordSvc;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.SessionHelper;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("sysSearchWordService")
public class SysSearchWordSvcImpl extends EgovAbstractServiceImpl implements SysSearchWordSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public int selectListCount(CoviMap params) throws Exception {
		int cnt = coviMapperOne.selectOne("searchword.selectListCount", params);
		return cnt;
	}

	@Override
	public CoviList selectList(CoviMap params) throws Exception {
		CoviList resultList = new CoviList();
		params.put("lang", SessionHelper.getSession("lang"));
		
		CoviList list = coviMapperOne.list("searchword.selectList", params);
		resultList = CoviSelectSet.coviSelectJSON(list, "SearchWordID,SearchWord,SearchCnt,SearchDate,RecentlyPoint,DomainID,DomainName,System,CreateDate");
		
		return resultList;
	}

	@Override
	public void insertData(CoviMap params) throws Exception {
		coviMapperOne.insert("searchword.insertData", params);
	}

	@Override
	public void updateData(CoviMap params) throws Exception {
		coviMapperOne.update("searchword.updateData", params);
	}

	@Override
	public void deleteData(CoviMap params) throws Exception {
		coviMapperOne.delete("searchword.deleteData", params);
		
	}
	
	@Override
	public CoviMap selectData(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		
		CoviList list = coviMapperOne.list("searchword.selectData", params);
		resultObj =CoviSelectSet.coviSelectJSON(list, "SearchWordID,SearchWord,SearchCnt,SearchDate,RecentlyPoint,DomainID,System,CreateDate").getJSONObject(0);
		
		return resultObj;
	}

	@Override
	public void insertSearchData(CoviMap params) throws Exception {
		
		CoviMap map = coviMapperOne.select("searchword.selectSearchWord", params);
		
		if(!map.isEmpty()){
			// 마지막 검색일자가 현재일자보다 15일 이전에 검색 되었다면 최근 포인트 1로 초기화
			// 마지막 검색일자가 현재일로부터 15일이 지나지 않았다면 최근 포인트 +1
			
			String searchDate = map.getString("SearchDate");
			int recentlyPoint = 1;
			if(DateHelper.diffDate(DateHelper.strToDate(DateHelper.getCurrentDay("yyyy-MM-dd")), DateHelper.strToDate(searchDate, "yyyy-MM-dd")) <= 15){
				recentlyPoint = map.getInt("RecentlyPoint")+1;
			}
			
			params.put("SearchCnt", map.getInt("SearchCnt")+1);
			params.put("RecentlyPoint", recentlyPoint);
			params.put("SearchDate", DateHelper.getCurrentDay("yyyy-MM-dd"));
			coviMapperOne.insert("searchword.updateRecentlyPoint", params);
		}else{
			params.put("SearchCnt", 1);
			params.put("RecentlyPoint", 1);
			params.put("SearchDate", DateHelper.getCurrentDay("yyyy-MM-dd"));
			params.put("CreateDate", DateHelper.getCurrentDay("yyyy-MM-dd"));
			coviMapperOne.insert("searchword.insertData", params);
		}
	}
	
	public CoviMap checkDouble(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		
		CoviMap map = coviMapperOne.select("searchword.selectSearchWord", params);

		returnList.put("duplicated", (map.isEmpty()) ? "N" : "Y");
		returnList.put("result", "ok");
		returnList.put("status", Return.SUCCESS);
		
		return returnList;
	}
}
