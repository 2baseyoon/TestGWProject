package egovframework.covision.groupware.devwithgpt.user.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.devwithgpt.user.service.DevWithGPTSvc;

@Service("DevWithGPTService")
public class DevWithGPTSvcImpl implements DevWithGPTSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	/**
	 * gpt model 정보 (api key, 모델명)
	 */
	@Override
	public CoviMap getModelInfo(String domainID) {
		return coviMapperOne.selectOne("dev.with.gpt.getModelInfo", domainID);
	}
	/**
	 * gpt model에 전달할 요청 파라미터
	 */
	@Override
	public CoviMap getModelOption(String domainID) {
		return coviMapperOne.selectOne("dev.with.gpt.getModelOption", domainID);
	}
	/**
	 * gpt model에 등록된 질의 데이터 가져오기
	 */
	@Override
	public CoviMap getModelPrompt(String domainID) {
		return coviMapperOne.selectOne("dev.with.gpt.getModelPrompt", domainID);
	}
	/**
	 * gpt model에 요청할 질의 템플릿
	 */
	@Override
	public String getModelPrompt(String domainID, String promptType) {
		
		CoviMap resultMap = coviMapperOne.selectOne("dev.with.gpt.getModelPrompt", domainID);
		
		return resultMap.get(promptType).toString();
	}
	
	@Override
	public int updateModelInfo(CoviMap params) {
		return coviMapperOne.update("dev.with.gpt.updateModelInfo", params);
	}
	
	@Override
	public int updateModelOption(CoviMap params) {
		return coviMapperOne.update("dev.with.gpt.updateModelOption", params);
	}
	
	@Override
	public int updateModelPrompt(CoviMap params) {
		return coviMapperOne.update("dev.with.gpt.updateModelPrompt", params);
	}
	
	@Override
	public CoviMap getMonthUsage(CoviMap params) {
		return coviMapperOne.select("dev.with.gpt.getMonthUsage", params);
	}
	
	@Override
	public CoviList getPromptUsage(CoviMap params) {
		return coviMapperOne.list("dev.with.gpt.getPromptUsage", params);
	}
	
	@Override
	public CoviMap getUserUsage(CoviMap params) {
		CoviMap returnMap = new CoviMap();
		CoviMap page=null;
		
		if(params.get("pageNo") != null && params.get("pageSize") != null) {
			int cnt = (int) coviMapperOne.getNumber("dev.with.gpt.getUserCount" , params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}
		
		returnMap.put("page", page);
		returnMap.put("list", coviMapperOne.list("dev.with.gpt.getUserUsage", params));
		
		return returnMap;
	}
	
	@Override
	public int insertUsageLog(CoviMap params) {
		String userCode = SessionHelper.getSession("USERID");
		params.put("usercode", userCode);
		
		return coviMapperOne.insert("dev.with.gpt.insertUsageLog", params);
	}
}