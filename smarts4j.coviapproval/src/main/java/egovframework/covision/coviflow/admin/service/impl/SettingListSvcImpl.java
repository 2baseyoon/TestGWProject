package egovframework.covision.coviflow.admin.service.impl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Set;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.SettingListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("SettingListSvc")
public class SettingListSvcImpl extends EgovAbstractServiceImpl implements SettingListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getSettingListData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("admin.settingList.selectSettingListCnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("admin.settingList.selectSettingList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SettingID,SettingType,SettingKey,SettingName,SettingValue,Description"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public void synchronizeSetting() throws Exception {
		int settingIDSeq = 1;
    	CoviList list = coviMapperOne.list("admin.settingList.selectApprovalSetting", null);
    	
    	coviMapperOne.delete("admin.settingList.deleteApprovalSetting", null);
    	
    	if(!list.isEmpty()){
    		CoviMap selectData = list.getJSONObject(0);

    		CoviList settingInfos = new CoviList();
    		CoviMap ExtInfo = CoviSelectSet.coviSelectMapJSON(selectData, "ExtInfo");
    		CoviMap SchemaContext = CoviSelectSet.coviSelectMapJSON(selectData, "SchemaContext");
    		
    		if(ExtInfo.containsKey("ExtInfo")) {
    			ExtInfo = ExtInfo.getJSONObject("ExtInfo");
    		}
    		
    		if(SchemaContext.containsKey("SchemaContext")) {
    			SchemaContext = SchemaContext.getJSONObject("SchemaContext");
    		}
    		
    		Iterator<?> keys = ExtInfo.keys();
    		while (keys.hasNext()) {
    			String key = (String) keys.next();
    			CoviMap settingInfo = new CoviMap();
    			
    			settingInfo.put("SettingID", settingIDSeq);
    			settingInfo.put("SettingType", "Form");
    			settingInfo.put("SettingKey", key);
    			settingInfo.put("SettingName", DicHelper.getDic("lbl_apv_setform_" + key));
    			settingInfo.put("Description", DicHelper.getDic("lbl_apv_setform_" + key + "_desc"));
    			
    			settingInfos.add(settingInfo);
    			settingIDSeq++;
    		}
    		
    		keys = SchemaContext.keys();
    		while (keys.hasNext()) {
    			String key = (String) keys.next();
    			
    			if(key.toLowerCase().startsWith("sc")) {
    				CoviMap settingInfo = new CoviMap();

        			settingInfo.put("SettingID", settingIDSeq);
        			settingInfo.put("SettingType", "Schema");
        			settingInfo.put("SettingKey", key);
        			settingInfo.put("SettingName", DicHelper.getDic("lbl_apv_setschema_" + key));
        			settingInfo.put("Description", DicHelper.getDic("lbl_apv_setschema_" + key + "_desc"));
        			
        			settingInfos.add(settingInfo);
        			settingIDSeq++;
    			}
    		}
    		
    		coviMapperOne.insert("admin.settingList.insertApprovalSettingList", settingInfos);
    	}
	}
}
