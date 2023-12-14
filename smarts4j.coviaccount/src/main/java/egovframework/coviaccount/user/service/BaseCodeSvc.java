package egovframework.coviaccount.user.service;


import egovframework.baseframework.data.CoviMap;


/**
 * @Class Name : BaseCodeSvc.java
 * @Description : 기초코드 서비스
 * @Modification Information 
 * @author CSH
 * @ 2018.05.08 최초생성
 */
public interface BaseCodeSvc {
	

	public CoviMap searchBaseCode(CoviMap params) throws Exception;
	public CoviMap searchBaseCodeView(CoviMap params) throws Exception;
	public CoviMap searchBaseCodeDetail(CoviMap params) throws Exception;
	public CoviMap searchBaseCodeExcel(CoviMap params) throws Exception;
	
	public int checkCompanyCodeIsUse(CoviMap params);
	public int changeBaseCodeIsUse(CoviMap params)throws Exception;
	public int deleteBaseCodeList(CoviMap params)throws Exception;
	public int deleteBaseGrpCodeList(CoviMap params)throws Exception;
	
	public CoviMap insertBaseCode(CoviMap params)throws Exception;
	public CoviMap updateBaseCode(CoviMap params)throws Exception;

	public CoviMap uploadExcelBaseCode(CoviMap params) throws Exception;
	
	public CoviMap getCodeListByCodeGroup(CoviMap params) throws Exception;
	public CoviMap getBaseCodeName(CoviMap params) throws Exception;

	public CoviMap syncBaseCode(CoviMap params)throws Exception;
		
	public int selectIOCodeMaxSortKey()throws Exception;
	
	public String selectBaseCodeByCodeName(CoviMap params)throws Exception;

}