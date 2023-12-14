package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.core.sevice.SysThemeSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("sysThemeService")
public class SysThemeSvcImpl extends EgovAbstractServiceImpl implements SysThemeSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap select(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("sys.theme.selectThemeCount", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("sys.theme.selectThemeList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ThemeID,DomainID,DisplayName,SortKey,Theme,ThemeType,ThemeName,IsUse,IsThemeChange,IsSkinChange,BgColor,BgImage,Description,RegID,ModID,ModDate"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectOne(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("sys.theme.selectone", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "ThemeID,DomainID,SortKey,ThemeCode,ThemeType,ThemeName,MultiDisplayName,IsUse,Discription,RegID,Description"));
		return resultList;
	}
	
	@Override
	public CoviMap selectCode(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("sys.theme.selectCode", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ThemeID,DomainID,ThemeCode,MultiDisplayName"));
		return resultList;
	}

	@Override
	public int insert(CoviMap params) throws Exception {
		int chkDup = (int)coviMapperOne.getNumber("sys.theme.chkDuplication", params);
		int retCnt = 0;
		
		if(chkDup < 1){
			retCnt = coviMapperOne.insert("sys.theme.insertTheme", params); 			
		}else{
			retCnt = -1;
		}
		
		return retCnt;
	}
	
	@Override
	public int update(CoviMap params) throws Exception {
		int retCnt = coviMapperOne.update("sys.theme.updateTheme", params);
		
		return 	retCnt;
	}
	
	@Override
	public int delete(CoviMap params) throws Exception {
		int retCnt = coviMapperOne.delete("sys.theme.deleteTheme", params);
		
		return 	retCnt;
	}

	@Override
	public int updateIsUse(CoviMap params) throws Exception {
		int retCnt = coviMapperOne.update("sys.theme.updateIsUse", params);

		return retCnt;
	}

	@Override
	public int changeSortKey(CoviMap params) throws Exception {
		int retCnt = coviMapperOne.update("sys.domain.changeSortKey",params);
		return retCnt;
	}
	
}
