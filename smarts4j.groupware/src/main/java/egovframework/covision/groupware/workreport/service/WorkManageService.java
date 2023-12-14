package egovframework.covision.groupware.workreport.service;


import egovframework.baseframework.data.CoviMap;

public interface WorkManageService {
	int checkDuplicateCode(CoviMap params) throws Exception;
	int insertWorkCategorie(CoviMap params) throws Exception;
	CoviMap getCateTypeList(CoviMap params) throws Exception;
	CoviMap getCateDivList(CoviMap params) throws Exception;
	int deleteCateCode(CoviMap params) throws Exception;
	CoviMap getCateTypeSelList(CoviMap params) throws Exception;
	int insertWork(CoviMap params) throws Exception;
	CoviMap selectWorkList(CoviMap params) throws Exception;
	int changeUseYN(CoviMap params) throws Exception;
	int deleteWorkJob(CoviMap params) throws Exception;
	CoviMap selectOneWorkJob(CoviMap params) throws Exception;
	int updateWork(CoviMap params) throws Exception;
	CoviMap setDivisionWorkType(CoviMap params) throws Exception;
	CoviMap insertApprover(CoviMap params) throws Exception;
	CoviMap selectApproverList(CoviMap params) throws Exception;
	int deleteApprover(CoviMap params) throws Exception;
	/**
	 * @deprecated 번호발번은 기존코드번호값 기준으로 처리하므로 단독조회는 중복발번 소지가 있음 
	 */
	int selectWorkJobNumber(CoviMap params) throws Exception;
	String createWorkWithNumber(CoviMap params) throws Exception;
}
