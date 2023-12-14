package egovframework.core.sevice.impl;

import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.LocalStorageSyncSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("localStorageSyncSvc")
public class LocalStorageSyncSvcImpl extends EgovAbstractServiceImpl implements LocalStorageSyncSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	@SuppressWarnings("unchecked")
	public CoviMap getSyncTargetList(CoviMap params, CoviMap userDataObj) throws Exception {
		String langCode = userDataObj.getString("lang");
		String domainId = userDataObj.getString("DN_ID");
		
		params.put("langCode", langCode);
		
		// GENERAL 도메인 다국어 데이터 조회
		params.put("domainId", "0");
		List<CoviMap> dictionary0 = coviMapperOne.selectList("sys.local.storage.sync.selectSyncTarget", params);
		
		// 사용자 도메인 다국어 데이터 조회
		params.put("domainId", domainId);
		List<CoviMap> dictionary1 = coviMapperOne.selectList("sys.local.storage.sync.selectSyncTarget", params);

		// 동기화 시간 조회
//		String syncTime = coviMapperOne.selectOne("sys.local.storage.sync.selectSyncTime");
		
		CoviMap dataMap = new CoviMap();
		String key = "";
		String value = "";
		
		if (dictionary0 != null) {
			for (CoviMap dic0 : dictionary0) {
				key = dic0.getString("DicCode");
				
				if (StringUtil.isNotNull(key)) {
					value = dic0.getString("Message");
					dataMap.put(key, value);
				}
			}
		}
		
		if (dictionary1 != null) {
			for (CoviMap dic1 : dictionary1) {
				key = dic1.getString("DicCode");
				
				if (StringUtil.isNotNull(key)) {
					value = dic1.getString("Message");
					dataMap.put(key, value);
				}
			}
		}
	
		CoviMap dicData = new CoviMap();
		
		StringBuilder sb = new StringBuilder();

		String dicCode = null;
		String dicMsg = null;
		String dicItem = null;
		
		String dicSeparator = "†";
		String msgSeparator = "§";
		
		Iterator<String> keys = dataMap.keySet().iterator();
		
		while (keys.hasNext()) {
			sb.append(dicSeparator);
			
			dicCode = keys.next();
			dicMsg = dataMap.getString(dicCode);
			dicItem = dicCode + msgSeparator + dicMsg;
			
			sb.append(dicItem);
		}
		
		String dicDataKey = "Dictionary";
		String dicDataValue = sb.toString();
		
		dicData.put(dicDataKey, dicDataValue);
		
/*		dicDataKey = "DictionarySyncTime";
		dicDataValue = syncTime;
		
		dicData.put(dicDataKey, dicDataValue);
*/		
		dicData.put("DictionaryLang", langCode);
		
		return dicData;
	}

}
