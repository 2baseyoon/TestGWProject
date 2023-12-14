package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;

public interface EACTaxSvc {
	public CoviMap EACTaxExcelUpload(CoviMap params) throws Exception;
	public CoviMap getEACTaxMapList(CoviMap params) throws Exception;
	public CoviMap getEACTaxByCompanyList(CoviMap params) throws Exception;
	public CoviMap EACTaxAutoMapping(CoviMap params) throws Exception;
	public CoviMap EACTaxInitial(CoviMap params) throws Exception;
	public CoviMap registTaxMap(CoviMap params) throws Exception;
	public CoviMap searchTaxMapListExcelDownload(CoviMap params) throws Exception;
	public CoviMap searchTaxByCompanyListExcelDownload(CoviMap params) throws Exception;
}
