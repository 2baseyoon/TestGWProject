package egovframework.covision.coviflow.store.service.impl;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.fileupload.disk.DiskFileItem;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.commons.CommonsMultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;
import egovframework.covision.coviflow.store.service.StoreAdminFormSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("storeAdminFormService")
public class StoreAdminFormSvcImpl extends EgovAbstractServiceImpl implements StoreAdminFormSvc{
	private static final Logger LOGGER = LogManager.getLogger(StoreAdminFormSvcImpl.class);
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviList selectFormsCategoryList(CoviMap params) throws Exception {
		CoviList list = new CoviList();
		
		list = coviMapperOne.list("store.adminForm.selectFormsCategoryList", params);
		return CoviSelectSet.coviSelectJSON(list);
	}
	
	@Override
	public CoviMap selectStoreFormList(CoviMap params, boolean paging) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(paging) {
			int cnt = (int) coviMapperOne.getNumber("store.adminForm.selectStoreFormListCnt", params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}
		
		CoviList list = coviMapperOne.list("store.adminForm.selectStoreFormList", params);
		if(params.containsKey("headerkey")) {
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, params.getString("headerkey")));
		}else {
			resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		}
		resultList.put("page",page);
		
		return resultList;
	}	
	
	@Override
	public CoviMap storeAdminPurchaseListData(CoviMap params, boolean paging) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(paging) {
			int cnt = (int) coviMapperOne.getNumber("store.adminForm.StoreAdminPurchaseListDataCnt", params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}
		CoviList list = coviMapperOne.list("store.adminForm.StoreAdminPurchaseListData", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page",page);
		
		return resultList;
	}	
	
	@Override
	public int updateIsUseForm(CoviMap params) throws Exception {
		return coviMapperOne.update("store.adminForm.updateIsUseForm", params);
	}

	@Override
	public CoviMap getStoreCategorySelectbox(CoviMap params) throws Exception {
		CoviList list = new CoviList();
		CoviMap resultList = new CoviMap();
		
		list = coviMapperOne.list("store.adminForm.getStoreCategorySelectbox", params);
		resultList.put("list", list);
		
		return resultList;
	}

	@Override
	public int storeInsertFormData(CoviMap pObj, CoviList flist) throws Exception {
		int cnt = coviMapperOne.insert("store.adminForm.insertStoreItemsData", pObj);
		
		if(cnt > 0) {
			coviMapperOne.insert("store.adminForm.insertFormData", pObj);
			String storedFormID = pObj.optString("StoredFormID");
			
			CoviList uploadFiles = fileUtilSvc.moveToBack(flist, "", "AppStore", "0", "0", storedFormID, false);
	
			CoviMap cMap = new CoviMap();
			for(Object fObj : uploadFiles) {
				CoviMap fileObj = (CoviMap)fObj;
				Boolean isMobileFile = FilenameUtils.getBaseName(fileObj.optString("FileName")).endsWith("_MOBILE");
				
				if(isMobileFile && fileObj.optString("Extention").equalsIgnoreCase("html")) {
					cMap.put("MobileFormHtmlFileID", fileObj.optString("FileID")); 
				}else if(isMobileFile && fileObj.optString("Extention").equalsIgnoreCase("js")) {
					cMap.put("MobileFormJsFileID", fileObj.optString("FileID")); 
				}else if(fileObj.optString("Extention").equalsIgnoreCase("html")) { 
					cMap.put("FormHtmlFileID", fileObj.optString("FileID")); 
				}else if(fileObj.optString("Extention").equalsIgnoreCase("js")) {
					cMap.put("FormJsFileID", fileObj.optString("FileID")); 
				}else if(fileObj.optString("SaveType").equalsIgnoreCase("IMAGE")) { 
					cMap.put("ThumbnailFileID", fileObj.optString("FileID")); 
				}
			}
			cMap.put("RevisionNo", "0");
			cMap.put("StoredFormID", storedFormID);
			
			coviMapperOne.insert("store.adminForm.insertStoreFormRevData", cMap);
			coviMapperOne.update("store.adminForm.updateStoredFormRevID", cMap);
		}
		return cnt;
	}
	
	@Override
	public int storeUpdateFormData(CoviMap pObj, CoviList flist) throws Exception {
		CoviMap currentInfo = coviMapperOne.select("store.adminForm.getStoreFormData", pObj);
		pObj.put("StoreItemID", currentInfo.getString("StoreItemID"));
		int cnt = coviMapperOne.update("store.adminForm.updateStoreItemsData", pObj); // free, price
		if(cnt > 0) {
			coviMapperOne.update("store.adminForm.updateFormData", pObj);
			String storedFormID = pObj.optString("StoredFormID");
			String storedFormRevID = pObj.optString("StoredFormRevID");
			
			CoviMap cMap = new CoviMap();
			if(flist != null && flist.size() > 0) {
				CoviList uploadFiles = fileUtilSvc.moveToBack(flist, "", "AppStore", "0", "0", storedFormID, false);
				
				for(Object fObj : uploadFiles) {
					CoviMap fileObj = (CoviMap)fObj;
					Boolean isMobileFile = FilenameUtils.getBaseName(fileObj.optString("FileName")).endsWith("_MOBILE");
					
					if("Y".equals(pObj.optString("MobileFormYN")) && isMobileFile && fileObj.optString("Extention").equalsIgnoreCase("html")) {
						cMap.put("MobileFormHtmlFileID", fileObj.optString("FileID")); 
					}else if("Y".equals(pObj.optString("MobileFormYN")) && isMobileFile && fileObj.optString("Extention").equalsIgnoreCase("js")) {
						cMap.put("MobileFormJsFileID", fileObj.optString("FileID")); 
					}else if(fileObj.optString("Extention").equalsIgnoreCase("html")) { 
						cMap.put("FormHtmlFileID", fileObj.optString("FileID")); 
					}else if(fileObj.optString("Extention").equalsIgnoreCase("js")) {
						cMap.put("FormJsFileID", fileObj.optString("FileID")); 
					}else if(fileObj.optString("SaveType").equalsIgnoreCase("IMAGE")) { 
						cMap.put("ThumbnailFileID", fileObj.optString("FileID")); 
					}
				}
			}
			
			cMap.put("StoredFormID", storedFormID);
			cMap.put("StoredFormRevID", storedFormRevID);

			if(pObj.optBoolean("bVerUp")) {
				long revisionNo = currentInfo.optLong("RevisionNo", -1L) + 1L;
				cMap.put("RevisionNo", revisionNo);
				
				// Upload 된 파일이 없을 경우 이전버젼의 파일을 복제한다.
				if(!cMap.containsKey("FormHtmlFileID")) {
					String fileID = currentInfo.getString("FormHtmlFileID");
					String newFileID = copyFile(fileID, storedFormID);
					cMap.put("FormHtmlFileID", newFileID);
				}
				if(!cMap.containsKey("FormJsFileID")) {
					String fileID = currentInfo.getString("FormJsFileID");
					String newFileID = copyFile(fileID, storedFormID);
					cMap.put("FormJsFileID", newFileID);
				}
				if(!cMap.containsKey("ThumbnailFileID")) {
					String fileID = currentInfo.getString("ThumbnailFileID");
					String newFileID = copyFile(fileID, storedFormID);
					cMap.put("ThumbnailFileID", newFileID);
				}
				if("Y".equals(pObj.optString("MobileFormYN")) && !cMap.containsKey("MobileFormHtmlFileID") && currentInfo.get("MobileFormHtmlFileID") != null) {
					String fileID = currentInfo.getString("MobileFormHtmlFileID");
					String newFileID = copyFile(fileID, storedFormID);
					cMap.put("MobileFormHtmlFileID", newFileID);
				}
				if("Y".equals(pObj.optString("MobileFormYN")) && !cMap.containsKey("MobileFormJsFileID") && currentInfo.get("MobileFormJsFileID") != null) {
					String fileID = currentInfo.getString("MobileFormJsFileID");
					String newFileID = copyFile(fileID, storedFormID);
					cMap.put("MobileFormJsFileID", newFileID);
				}
				
				coviMapperOne.insert("store.adminForm.insertStoreFormRevData", cMap);
				coviMapperOne.update("store.adminForm.updateStoredFormRevID", cMap); // 최종버젼 Update
			}else {
				coviMapperOne.update("store.adminForm.updateStoreFormRevData", cMap);
			}
		}
		return cnt;
	}
	
	private String copyFile(String fileID, String storedFormID) throws Exception {
		CoviMap param = new CoviMap();
		param.put("fileID", fileID);
		CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(fileID); // 기존 파일의 storage정보조회
		CoviMap fileStorageInfo = fileStorageInfos.getJSONObject(fileID);
		String companyCode = SessionHelper.getSession("DN_Code");
		companyCode = fileStorageInfo.optString("CompanyCode").equals("") ? companyCode : fileStorageInfo.optString("CompanyCode");
		String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileStorageInfo.optString("StorageFilePath").replace("{0}", companyCode) + fileStorageInfo.optString("FileFilePath") + fileStorageInfo.optString("SavedName");
		
		if(!new File(filePath).exists()) {
			throw new FileNotFoundException(filePath);
		}
		
		List<MultipartFile> mockedFileList = new ArrayList<MultipartFile>();
		AwsS3 awsS3 = AwsS3.getInstance();
		if(awsS3.getS3Active(companyCode)){
			AwsS3Data downFile = awsS3.downData(filePath);
			MultipartFile multipartFile = new MockMultipartFile(downFile.getName(), downFile.getContentStream());// 최종 MultipartFile.transferTo 처리시 close 처리함.
			mockedFileList.add(multipartFile);

		}else {
			File file = new File(filePath);
			DiskFileItem fileItem = new DiskFileItem("file", Files.probeContentType(file.toPath()), false, fileStorageInfo.getString("FileName"), (int) file.length() , file.getParentFile());
			try (InputStream input = new FileInputStream(file); OutputStream os = fileItem.getOutputStream();){
				IOUtils.copy(input, os);

				MultipartFile multipartFile = new CommonsMultipartFile(fileItem);
				mockedFileList.add(multipartFile);
			}
		}
		CoviList uploadFiles = fileUtilSvc.uploadToBack(null, mockedFileList, "", "AppStore", "0", "0", storedFormID, false);
		return uploadFiles.getJSONObject(0).getString("FileID");
	}
	
	@Override
	public int storeFormDuplicateCheck(CoviMap pObj) throws Exception {
		int cnt = (int) coviMapperOne.getNumber("store.adminForm.storeFormDuplicateCheck", pObj);
		
		return cnt;
	}
	
	@Override
	public CoviMap getStoreFormData(CoviMap params) throws Exception {		
		CoviMap returnData = coviMapperOne.select("store.adminForm.getStoreFormData", params);		

		return returnData;
	}

	@Override
	public CoviList getStoreFormRevList(CoviMap params) throws Exception {
		CoviList returnData = coviMapperOne.list("store.adminForm.getStoreFormRevList", params);		
		return returnData;
	}

	@Override
	public long getCategoryFormCnt(CoviMap params) throws Exception {
		return coviMapperOne.getNumber("store.adminForm.selectStoreFormListCnt", params);
	}
}
