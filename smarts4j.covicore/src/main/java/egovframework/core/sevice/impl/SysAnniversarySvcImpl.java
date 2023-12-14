package egovframework.core.sevice.impl;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DateHelper;
import egovframework.core.sevice.SysAnniversarySvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("sysAnniversaryService")
public class SysAnniversarySvcImpl extends EgovAbstractServiceImpl implements SysAnniversarySvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getAnniversaryList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap(); 
		 
		int cnt = (int) coviMapperOne.getNumber("sys.anniversary.selectAnniversaryListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("sys.anniversary.selectAnniversaryList",params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "CalendarID,SolarDate,DN_ID,LunarDate,AnniversaryType,Anniversary,MultiDisplayName"));
		resultList.put("page",page);
		
		return resultList;
	}

	@Override
	public CoviMap getAnniversaryData(CoviMap params) throws Exception {
		CoviMap anniversary = new CoviMap();
		anniversary.addAll(coviMapperOne.select("sys.anniversary.selectAnniversaryData", params));
		
		return anniversary;
	}

	@Override
	public void updateAnniversaryData(CoviMap params) throws Exception {
		coviMapperOne.update("sys.anniversary.updateAnniversaryData", params);
		
	}

	@Override
	public void insertAnniversaryData(CoviMap params) throws Exception {
		if(params.getString("isRepeat").equalsIgnoreCase("Y")){
			List<String> arrSolarDate = new ArrayList();
			
			Date solarDate = DateHelper.strToDate(params.getString("solarDate"));
			int year = Integer.parseInt( DateHelper.convertDateFormat(params.getString("solarDate"), "yyyy-MM-dd", "yyyy") );
			String monthAndDay = DateHelper.convertDateFormat(params.getString("solarDate"), "yyyy-MM-dd", "MM-dd");
			
			for(int i = 0 ; i < params.getInt("repeatCnt"); i++){
				arrSolarDate.add(year + i + "-" + monthAndDay);
			}
			params.put("arrSolarDate", arrSolarDate);
		}
		
		if(params.getString("domainID").equals("0")){
			coviMapperOne.update("sys.anniversary.insertGroupAnniversaryData", params);
		}else{
			coviMapperOne.insert("sys.anniversary.insertCompanyAnniversaryData", params);
		}
		
	}

	@Override
	public int checkAnniversaryData(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("sys.anniversary.checkAnniversaryData", params);
	}

	@SuppressWarnings("unchecked")
	@Override
	public void deleteAnniversary(CoviMap params) throws Exception {
		CoviList deleteCalendars = new CoviList();
		String[] delData = params.getString("deleteData").split(",");
		
		for(int i = 0 ; i < delData.length; i++){
			if(!delData[i].isEmpty()){
				CoviMap delObj = new CoviMap();
				delObj.put("calendarID", delData[i].split("[|]")[0]);
				delObj.put("domainID", delData[i].split("[|]")[1]);
				
				deleteCalendars.add(delObj);
			}
		}
		params.put("deleteCalendars", deleteCalendars);
		
		coviMapperOne.delete("sys.anniversary.deleteAnniversaryData", params);
	}
	
	@Override
	public void insertGoogleAnniversaryData(CoviMap params) throws Exception {
		if(params.getString("domainID").equals("0")){
			coviMapperOne.update("sys.anniversary.insertGroupAnniversaryData", params);
		}else{
			int checkAnniversary = checkAnniversaryData(params);
			
			if(checkAnniversary == 0) {
				coviMapperOne.insert("sys.anniversary.insertCompanyAnniversaryData", params);
			}
		}
	}
	
}
