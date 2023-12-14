package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface SysDomainSvc {
	public CoviMap select(CoviMap params) throws Exception;
	public CoviMap selectCode(CoviMap params) throws Exception;
	public CoviMap selectOne(CoviMap params) throws Exception;
	public int insert(CoviMap paramDN) throws Exception;
	public int update(CoviMap paramDN)throws Exception;
	public int updateIsUse(CoviMap params)throws Exception;
	public int updateDomainInfo(CoviMap params) throws Exception;
	public int insertDomainGoogleSchedule(CoviMap params) throws Exception;
	public String insertDomainFolder(CoviMap params) throws Exception;
	public int updateDomainInfoDesign(CoviMap params) throws Exception;
	
	public CoviMap selectDomainLicenseList(CoviMap params) throws Exception;
	public CoviMap selectDomainLicAddList(CoviMap params) throws Exception;
	public int saveDoaminLicInfo(CoviMap params) throws Exception;

	public int deleteDomainLic(CoviMap params) throws Exception;
}
