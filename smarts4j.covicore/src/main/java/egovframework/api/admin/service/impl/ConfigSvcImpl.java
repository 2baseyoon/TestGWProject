package egovframework.api.admin.service.impl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider;
import org.springframework.context.annotation.ScannedGenericBeanDefinition;
import org.springframework.core.type.MethodMetadata;
import org.springframework.core.type.filter.AnnotationTypeFilter;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.api.admin.service.AuthorizationSvc;
import egovframework.api.admin.service.ConfigSvc;
import egovframework.api.admin.service.impl.AuthorizationSvcImpl;
import egovframework.coviframework.util.AccessURLUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.RedisLettuceSentinelUtil;
import egovframework.coviframework.util.StringUtil;

@Service
public class ConfigSvcImpl implements ConfigSvc {
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	AuthorizationSvc authorizationSvc;
	
	@Override
	public int insertToken(String domainID, String token) throws Exception {
		CoviMap param = new CoviMap();
		param.put("DomainID", domainID);
		param.put("Token", token);
		param.put("IsActive", "Y");
		param.put("RegisterCode", SessionHelper.getSession("UR_Code"));
		return coviMapperOne.insert("api.admin.config.insertToken", param);
	}

	@Override
	public CoviMap getTokenList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("api.admin.config.selectTokenListCnt", params);
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("api.admin.config.selectTokenList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public int updateToken(CoviMap params) throws Exception {
		params.put("ModifierCode", SessionHelper.getSession("UR_Code"));
		return coviMapperOne.insert("api.admin.config.updateToken", params);
	}

	@Override
	public int deleteToken(CoviMap params) throws Exception {
		String configIDs = params.getString("TokenID");
		String [] deleteIDs = org.apache.commons.lang3.StringUtils.split(configIDs, ",");
		for(int i = 0; deleteIDs != null && i < deleteIDs.length; i++) {
			params.put("ConfigID", deleteIDs[i]);
			coviMapperOne.delete("api.admin.config.deleteToken", params);
		}
		return 1;
	}

	/////// 설정관리
	@Override
	public CoviList getConfigListAll(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("api.admin.config.selectConfigListAll", params);
		
		return CoviSelectSet.coviSelectJSON(list);
	}
	@Override
	public CoviMap getConfigList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("api.admin.config.selectConfigListCnt", params);
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("api.admin.config.selectConfigList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap getConfig(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectMapJSON(coviMapperOne.select("api.admin.config.selectConfig", params));
	}
	
	@Override
	public int insertConfig(CoviMap params) throws Exception {
		params.put("RegisterCode", SessionHelper.getSession("UR_Code"));
		String systemType = "";
		String path = params.getString("Path");
		if(path != null && path.indexOf("/") > -1) {
			String [] pathArr = StringUtils.split(path, "/");
			if(pathArr != null && pathArr.length > 1) {
				systemType = pathArr[1];
			}
		}
		if(StringUtils.isEmpty(systemType)) {
			systemType = "unknown";
		}
		params.put("SystemType", systemType);
		return coviMapperOne.insert("api.admin.config.insertConfig", params);
	}
	
	@Override
	public int updateConfig(CoviMap params) throws Exception {
		params.put("ModifierCode", SessionHelper.getSession("UR_Code"));
		return coviMapperOne.insert("api.admin.config.updateConfig", params);
	}

	@Override
	public int updateConfigIsUse(CoviMap params) throws Exception {
		params.put("ModifierCode", SessionHelper.getSession("UR_Code"));
		return coviMapperOne.update("api.admin.config.updateConfigIsUse", params);
	}
	
	@Override
	public int deleteConfig(CoviMap params) throws Exception {
		String configIDs = params.getString("ConfigID");
		String [] deleteIDs = org.apache.commons.lang3.StringUtils.split(configIDs, ",");
		for(int i = 0; deleteIDs != null && i < deleteIDs.length; i++) {
			params.put("ConfigID", deleteIDs[i]);
			coviMapperOne.delete("api.admin.config.deleteConfig", params);
		}
		return 1;
	}

	@Override
	public void synchronizeConfig(CoviMap params) throws Exception {
		String domainID = params.getString("DomainID");
		String version = params.getString("Version");
		CoviList configListAll = getConfigListAll(params);
		
		String apiServerPath = PropertiesUtil.getGlobalProperties().getProperty("coviapi.legacy.path", "");
		if(StringUtils.isEmpty(apiServerPath)) {
			throw new Exception("globals.properties's coviapi.legacy.path value is empty.");
		}
		
		String apiDocUrl = apiServerPath + "/v3/api-docs?group=" + version;
		CoviMap result = new HttpClientUtil().httpRestAPIConnect(apiDocUrl, "json", "GET", "", new CoviMap());
		if(!"200".equals(result.optString("status"))) {
			throw new Exception("Fail to get api specification["+ apiDocUrl +"].");
		}
		
		CoviMap apiList = result.getJSONObject("body").getJSONObject("paths");
		
		Iterator<String> it = apiList.keys();
		 
		CoviList currentMappings = new CoviList();
		while(it.hasNext()) {
			String path = it.next();
			CoviMap info = apiList.getJSONObject(path);
			
			String basePath = getBasePath(path);
			String method = info.keys().next();
			CoviMap subInfo = info.getJSONObject(method);
			String name = subInfo.getString("summary");
			String desc = subInfo.getString("description");
			
			info.put("Path", basePath);
			info.put("DomainID", domainID);
			info.put("MultiDisplayName", name);
			info.put("Descriptions", desc);
			if(basePath != null && basePath.indexOf("/") > -1) {
				String [] pathArr = StringUtils.split(basePath, "/");
				if(pathArr != null && pathArr.length > 1) {
					info.put("SystemType", pathArr[1]); // approval, org ...
				}
			}
			if(StringUtils.isEmpty(info.getString("SystemType"))) {
				info.put("SystemType", "unknown");
			}
			info.put("ReqLimitPerDay", -1);
			info.put("RegisterCode", SessionHelper.getSession("UR_Code"));
			info.put("ModifierCode", SessionHelper.getSession("UR_Code"));
			
			currentMappings.add(info);
			
		}
		
		// 설정값만 없는 대상은 Insert.
		for(int i = 0; currentMappings != null && i < currentMappings.size(); i++) {
			CoviMap info = currentMappings.getJSONObject(i);
			boolean found = false;
			for(int k = 0; configListAll != null && k < configListAll.size(); k++) {
				CoviMap dbInfo = configListAll.getJSONObject(k);
				if(dbInfo.getString("Path", "").equals(info.getString("Path"))) {
					found = true;
					break;
				}
			}
			if(!found) {
				info.put("IsUse", "N");
				insertConfig(info);
			}
		}
		
		// 실제 메소드가 없는 설정은 삭제.
		for(int i = 0; configListAll != null && i < configListAll.size(); i++) {
			CoviMap info = configListAll.getJSONObject(i);
			boolean found = false;
			for(int k = 0; currentMappings != null && k < currentMappings.size(); k++) {
				CoviMap methodInfo = currentMappings.getJSONObject(k);
				if(methodInfo.getString("Path", "").equals(info.getString("Path", ""))) {
					found = true;
					break;
				}
			}
			if(!found) {
				deleteConfig(info);
			}
		}
	}

	@Override
	public CoviMap getIPSecureList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("api.admin.config.selectIPSecureListCnt", params);
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("api.admin.config.selectIPSecureList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public CoviMap getIPSecure(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectMapJSON(coviMapperOne.select("api.admin.config.selectIPSecure", params));
	}

	@Override
	public int insertIPSecure(CoviMap params) throws Exception {
		try {
			params.put("RegisterCode", SessionHelper.getSession("UR_Code"));
			return coviMapperOne.insert("api.admin.config.insertIPSecure", params);
		}finally {
			authorizationSvc.reloadIPSecureList();
		}
	}

	@Override
	public int updateIPSecure(CoviMap params) throws Exception {
		try {
			params.put("ModifierCode", SessionHelper.getSession("UR_Code"));
			return coviMapperOne.update("api.admin.config.updateIPSecure", params);
		}finally {
			authorizationSvc.reloadIPSecureList();
		}
	}

	@Override
	public int updateIPSecureIsUse(CoviMap params) throws Exception {
		try {
			params.put("ModifierCode", SessionHelper.getSession("UR_Code"));
			return coviMapperOne.update("api.admin.config.updateIPSecureIsUse", params);
		}finally {
			authorizationSvc.reloadIPSecureList();
		}
	}

	@Override
	public int deleteIPSecure(CoviMap params) throws Exception {
		try {
			return coviMapperOne.delete("api.admin.config.deleteIPSecure", params);
		}finally {
			authorizationSvc.reloadIPSecureList();
		}
	}

	@Override
	public CoviMap getRequestLogList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("api.admin.config.selectRequestLogCnt", params);
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("api.admin.config.selectRequestLogList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public CoviMap getRequestLog(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectMapJSON(coviMapperOne.select("api.admin.config.selectRequestLog", params));
	}

	@Override
	public CoviList getRequestStatList(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("api.admin.config.selectRequestStatList", params));
	}
	
	// path에서 버전정보 추출 ex) /api/v1/approval/form/data --> v1
	public String getVersion(String originPath) throws Exception {
		int startIdx = originPath.indexOf("/api/") + "/api/".length();
		String version = originPath.substring(startIdx, originPath.indexOf("/", startIdx));
		
		if(!version.startsWith("v")) version = "";
		
		return version;
	}
	
	// path에 버전정보 추가  ex) /api/approval/form/data --> /api/v1/approval/form/data
	public String getOriginPath(String basePath, String version) throws Exception {
		String originPath = basePath;
		if(StringUtil.isNotNull(version)) originPath = basePath.replace("/api/", "/api/" + version + "/");
		
		return originPath;
	}
	
	public String getBasePath(String originPath) throws Exception {
		return getBasePath(originPath, getVersion(originPath));
	}
	// path에서 버전정보 제거 ex) /api/v1/approval/form/data --> /api/approval/form/data
	public String getBasePath(String originPath, String version) throws Exception {
		String basePath = originPath;
		if(StringUtil.isNotNull(version)) basePath = originPath.replace(version + "/", "");
		
		return basePath;
	}
}
