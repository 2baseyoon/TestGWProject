package egovframework.covision.groupware.portal.admin.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.portal.admin.service.LayoutManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("layoutManagerService")
public class LayoutManageSvcImpl extends EgovAbstractServiceImpl implements LayoutManageSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getLayoutList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("admin.portal.selectLayoutListCnt", params);
			page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			resultList.put("page", page);
		}
		
		CoviList list = coviMapperOne.list("admin.portal.selectLayoutList", params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "LayoutID,DisplayName,IsDefault,IsCommunity,SortKey,LayoutThumbnail,RegistDate,MultiDisplayName")); 
		
		return resultList;
	}
	
	@Override
	public CoviMap getLayoutData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("admin.portal.selectLayoutData", params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "DisplayName,IsDefault,IsCommunity,SortKey,LayoutThumbnail,LayoutTag,SettingLayoutTag")); 
		
		return resultList;
	}
	
	@Override
	public int changeLayoutIsDefault(CoviMap params) throws Exception {
		int retCnt = 0;
		
		retCnt = coviMapperOne.update("admin.portal.updateLayoutIsDefault", params);
		
		return retCnt;
	}

	@Override
	public int insertLayoutData(CoviMap params) throws Exception {
		int retCnt = 0;
		
		retCnt = coviMapperOne.insert("admin.portal.insertLayoutData", params);
		
		return retCnt;
	}

	@Override
	public int deleteLayoutData(CoviMap delParam) throws Exception {
		int retCnt = 0;
		
		retCnt = coviMapperOne.delete("admin.portal.deleteLayoutData", delParam);
		
		return retCnt;
	}

	@Override
	public int checkUsing(CoviMap params) throws Exception {
		int retCnt = 0;
		
		retCnt = (int)coviMapperOne.getNumber("admin.portal.checkUsing", params);
		
		return retCnt;
	}

	@Override
	public int updateLayoutData(CoviMap params) throws Exception {
		int retCnt = 0;
		
		retCnt = coviMapperOne.update("admin.portal.updateLayoutData", params);
		
		return retCnt;
	}

	

	
}
