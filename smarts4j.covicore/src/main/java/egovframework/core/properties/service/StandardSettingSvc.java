package egovframework.core.properties.service;

import java.util.List;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.core.properties.dto.StandardSettingListRequest;
import egovframework.core.properties.dto.StandardSettingSaveRequest;

public interface StandardSettingSvc {
	
	public CoviList selectCodeList(CoviMap params) throws Exception;
	
	public CoviList selectStandardCodeList(CoviMap params) throws Exception;
	
	public CoviMap list(StandardSettingListRequest standardSettingListRequest);
	
	public CoviMap save(StandardSettingSaveRequest standardSettingSaveRequest) throws Exception;
	
	public void delete(List<Integer> ids) throws Exception;
	
	public CoviMap findById(CoviMap params) throws Exception;

	public CoviList selectContextCodeList(CoviMap params) throws Exception;

	public CoviList selectInfraCodeList(CoviMap params) throws Exception;

}