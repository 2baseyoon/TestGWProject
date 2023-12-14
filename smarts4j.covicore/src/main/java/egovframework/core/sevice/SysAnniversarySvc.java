package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;


public interface SysAnniversarySvc {

	CoviMap getAnniversaryList(CoviMap params) throws Exception;

	CoviMap getAnniversaryData(CoviMap params) throws Exception;

	void updateAnniversaryData(CoviMap params) throws Exception;

	void insertAnniversaryData(CoviMap params) throws Exception;

	int checkAnniversaryData(CoviMap params) throws Exception;

	void deleteAnniversary(CoviMap params) throws Exception;
	
	void insertGoogleAnniversaryData(CoviMap params) throws Exception;
}
