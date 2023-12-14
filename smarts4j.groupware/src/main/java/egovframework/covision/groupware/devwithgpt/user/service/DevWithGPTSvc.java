package egovframework.covision.groupware.devwithgpt.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface DevWithGPTSvc {
	public CoviMap getModelInfo(String domainID);
	
	public CoviMap getModelOption(String domainID);
	
	public CoviMap getModelPrompt(String domainID);
	public String getModelPrompt(String domainID, String promptType);
	
	public CoviMap getMonthUsage(CoviMap params);
	public CoviList getPromptUsage(CoviMap params);
	public CoviMap getUserUsage(CoviMap params);
	
	public int updateModelInfo(CoviMap params);
	public int updateModelOption(CoviMap params);
	public int updateModelPrompt(CoviMap params);
	
	public int insertUsageLog(CoviMap params);
}