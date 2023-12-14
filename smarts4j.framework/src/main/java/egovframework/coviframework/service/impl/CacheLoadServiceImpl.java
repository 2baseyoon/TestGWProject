package egovframework.coviframework.service.impl;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.service.CacheLoadService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("cacheLoadService")
public class CacheLoadServiceImpl extends EgovAbstractServiceImpl implements CacheLoadService {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviList selectDicCache(CoviMap param) throws Exception {
		return coviMapperOne.list("cache.dic.selectintoredis", param);
	}
	
	//관리자 메뉴
	@Override
	public CoviList selectAdminMenuCache(CoviMap param) throws Exception {
		return coviMapperOne.list("cache.menu.selectAdminMenu", param);
	}

	// 사용자 메뉴
	@Override
	public CoviList selectUserMenuCache(CoviMap param) throws Exception {
		return coviMapperOne.list("cache.menu.selectUserMenu", param);
	}
	
	//base_config
	@Override
	public CoviMap getBaseConfig(CoviMap params) throws Exception {		
		CoviList list = coviMapperOne.list("cache.baseconfig.select", params);		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "key,value"));		
		return resultList;
	}
	
	//수정된 캐쉬처리 시작
	@Override
	public CoviList selectDic(CoviMap param) throws Exception {
		return coviMapperOne.list("framework.cache.selectDic", param);
	}
	
	//base_config
	@Override
	public CoviList selectBaseConfig(CoviMap param) throws Exception {		
		return coviMapperOne.list("framework.cache.selectBaseConfig", param);		
	}
	
	//base_code
	@Override
	public CoviList selectBaseCode(CoviMap param) throws Exception {		
		return coviMapperOne.list("framework.cache.selectBaseCode", param);		
	}
	
	@Override
	public Map<String, String> selectSyncType() throws Exception {
		Map<String, String> aclSyncMap = new HashMap<String, String>();
		// MN, PT 바로 생성
		// FD에 대한 내용은 ObjectType List만큼 생성
		aclSyncMap.put("MN", UUID.randomUUID().toString());
		aclSyncMap.put("PT", UUID.randomUUID().toString());
		
		CoviList list = coviMapperOne.list("framework.cache.selectObjectType", null);
		
		for(int i = 0; i < list.size(); i++) {
			CoviMap map = list.getMap(i);
			aclSyncMap.put("FD_" + map.getString("ObjectType").toUpperCase(), UUID.randomUUID().toString());
		}
		
		return aclSyncMap;
	}
	
	//base_code
	@Override
	public CoviList selectDomain(CoviMap param) throws Exception {
		return coviMapperOne.list("framework.cache.selectDomain", param);		
	}
	
	//권한 관리할 메뉴
	@Override
	public CoviList selectAuthMenu() throws Exception {		
		return coviMapperOne.list("framework.cache.selectAuthMenu", null);		
	}

	//권한 관리할 url
	@Override
	public CoviList selectAuditUrl() throws Exception {		
		return coviMapperOne.list("framework.cache.selectAuditUrl", null);		
	}
	//수정된 캐쉬처리 끝
}
