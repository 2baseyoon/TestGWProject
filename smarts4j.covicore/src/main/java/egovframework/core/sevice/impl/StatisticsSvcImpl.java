package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.core.sevice.StatisticsSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("statisticsService")
public class StatisticsSvcImpl extends EgovAbstractServiceImpl implements StatisticsSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	//과금예외자
	@Override
	public CoviMap selectChargingException(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticChargingException.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		CoviList list = coviMapperOne.list("sys.StaticChargingException.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CE_ID,DN_NAME,NAME,DEPTNAME,JOBLEVNAME,STARTDATE,ENDDATE,REGDATE,COMMENT"));
		return resultList;
	}

	@Override
	public Object insertChargingException(CoviMap params) throws Exception {
		return coviMapperOne.insertWithPK("sys.StaticChargingException.insertgrid", params);
	}

	@Override
	public int deleteChargingException(CoviMap params) throws Exception {
		return coviMapperOne.delete("sys.StaticChargingException.deletegrid", params);
	}
	
	//사용량
	@Override
	public CoviMap selectUsage(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.SystemGetUsageStatic.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		CoviList list = coviMapperOne.list("sys.SystemGetUsageStatic.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DN_ID,DN_Code,YEAR,MONTH,DN_Code,DN_Name,DN_Name_Simple,UserCount,UseDayCount,NoConUserCount,NewUserCount,UseRate,RegisterName,RegisterName_Simple,RegID,RegDate"));
		return resultList;
	}
	
	//페이지 사용량
	@Override
	public CoviMap selectPage(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUsePageStatic.selectPageCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		CoviList list = coviMapperOne.list("sys.StaticUsePageStatic.selectPage", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,UseCount,UserCount,CoCnt"));
		return resultList;
	}

	@Override
	public CoviMap selectSystem(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUsePageStatic.selectSystemCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("sys.StaticUsePageStatic.selectSystem", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,UseCount,UserCount,CoCnt"));
		return resultList;
	}

	@Override
	public CoviMap selectService(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUsePageStatic.selectServiceCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("sys.StaticUsePageStatic.selectService", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,UseCount,UserCount,CoCnt"));
		return resultList;
	}
	
	//사용자 로그인
	@Override
	public CoviMap selectPerHour(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUserLogonStatic.selectPerHourCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("sys.StaticUserLogonStatic.selectPerHour", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,Cnt,CoCnt"));
		return resultList;
	}

	@Override
	public CoviMap selectPerDays(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUserLogonStatic.selectPerDaysCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}

		CoviList list = coviMapperOne.list("sys.StaticUserLogonStatic.selectPerDays", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,Cnt,CoCnt"));
		return resultList;
	}
	
	@Override
	public CoviMap selectPerDay(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUserLogonStatic.selectPerDayCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}

 		CoviList list = coviMapperOne.list("sys.StaticUserLogonStatic.selectPerDay", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,Cnt,CoCnt"));
		return resultList;
	}

	@Override
	public CoviMap selectPerMonth(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUserLogonStatic.selectPerMonthCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("sys.StaticUserLogonStatic.selectPerMonth", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,Cnt,CoCnt"));
		return resultList;
	}
	
	//사용자 환경
	@Override
	public CoviMap selectBrowser(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUserSystemStatic.selectBrowserCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("sys.StaticUserSystemStatic.selectBrowser", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,Cnt,CoCnt"));
		return resultList;
	}

	@Override
	public CoviMap selectOS(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUserSystemStatic.selectOSCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("sys.StaticUserSystemStatic.selectOS", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,Cnt,CoCnt"));
		return resultList;
	}

	@Override
	public CoviMap selectResolution(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUserSystemStatic.selectResolutionCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("sys.StaticUserSystemStatic.selectResolution", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,Cnt,CoCnt"));
		return resultList;
	}

	@Override
	public CoviMap selectRegion(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.StaticUserSystemStatic.selectRegionCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("sys.StaticUserSystemStatic.selectRegion", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Items,Cnt,CoCnt"));
		return resultList;
	}
	
	
}
