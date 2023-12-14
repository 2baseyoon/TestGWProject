package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.core.sevice.FileUtilSvc;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

/**
 * @Class Name : FileUtilSvcImpl.java
 * @Description : 파일관리 
 * @Modification Information 
 * @ 2017.07.20 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 07.20
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Service("fileUtilSvc")
public class FileUtilSvcImpl extends EgovAbstractServiceImpl implements FileUtilSvc{

	private Logger LOGGER = LogManager.getLogger(FileUtilSvcImpl.class);

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap selectExcelData(CoviMap params, String queryID, String headerKey) throws Exception {
		CoviList list = coviMapperOne.list("common.excelDownload."+queryID, params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, headerKey));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectFileData(CoviMap params)throws Exception{
		CoviMap 	resultList 	= new CoviMap();
		CoviList 	list 		= null;
		//
		list = coviMapperOne.list("sys.FileUtil.selectFileData", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FileID,SaveType,FilePath,FormInstID,FileName,SavedName"));
		//
		return resultList;
	}
	
	@Override
	public CoviMap selectImageFileData(CoviMap params) throws Exception {
		return coviMapperOne.select("sys.FileUtil.selectImageFileData", params);
	}
	
	@Override
	public int insertFileDb(CoviMap params)throws Exception{
		int cnt = coviMapperOne.insert("sys.FileUpload.insertFileDb", params);
		return cnt;
	}
}
