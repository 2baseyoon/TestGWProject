package egovframework.covision.coviflow.admin.service;


import java.util.List;

import egovframework.baseframework.data.CoviMap;

public interface JobFunctionSvc {
	public CoviMap selectJobFunctionGrid(CoviMap params) throws Exception;
	public CoviMap selectJobFunctionMemberGrid(CoviMap params) throws Exception;
	public CoviMap selectJobFunctionData(CoviMap params) throws Exception;
	public CoviMap selectJobFunctionMemberData(CoviMap params) throws Exception;
	public CoviMap selectJobFunctionAllMember(CoviMap params) throws Exception;
	public int insertJobFunction(CoviMap params) throws Exception;
	public int deleteJobFunction(CoviMap params) throws Exception;
	public int updateJobFunction(CoviMap params) throws Exception;
	public int insertJobFunctionMember(CoviMap params) throws Exception;
	public int updateJobFunctionMember(CoviMap params)throws Exception;
	public int deleteJobFunctionMember(CoviMap params)throws Exception;
	public List selectJobFunctionCode(String entCode) throws Exception;	
}

