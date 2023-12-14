package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

/**
 * @Class Name : FileUtilSvc.java
 * @Description : 파일관리 
 * @Modification Information 
 * @ 2017.07.20 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 07.20
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
public interface FileUtilSvc {
	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception;
	public CoviMap selectImageFileData(CoviMap params) throws Exception;
	public CoviMap selectFileData(CoviMap params) throws Exception;
	public int insertFileDb(CoviMap params) throws Exception;
}
