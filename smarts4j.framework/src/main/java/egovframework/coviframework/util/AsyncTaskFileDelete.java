package egovframework.coviframework.util;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.s3.AwsS3;

@Service("asyncTaskFileDelete")
public class AsyncTaskFileDelete {
	private Logger LOGGER = LogManager.getLogger(AsyncTaskFileDelete.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	AwsS3 awsS3 = AwsS3.getInstance();
	
	@Async("coviExecutorFileDelete")
	public void delete(CoviMap params, String sessionCompanyCode) throws Exception{
		long startTime = System.currentTimeMillis();
		try {
			params.put("IsDeleted", "Y");
			CoviList fileList = coviMapperOne.list("framework.FileUtil.selectAttachAll", params);
			List<String> fileIdArr = new ArrayList<String>();
			// Insert history
			for (int i = 0; i < fileList.size(); i++) {
				CoviMap fileObj = fileList.getJSONObject(i);
				String companyCode = fileObj.optString("CompanyCode").equals("") ? sessionCompanyCode : fileObj.optString("CompanyCode");
				String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileObj.optString("StorageFilePath").replace("{0}", companyCode);
				String filePath = fileObj.getString("FilePath");
				String savedName = fileObj.getString("SavedName");
				
				if(StringUtils.isNoneBlank(filePath) && StringUtils.isNoneBlank(savedName)){
					
					String fullPath = backServicePath + filePath + savedName;
					deleteFile(fullPath);
					String ext = FilenameUtils.getExtension(savedName);
					if(ext.equalsIgnoreCase("jpg")||ext.equalsIgnoreCase("jpeg")||ext.equalsIgnoreCase("png")||ext.equalsIgnoreCase("gif")||ext.equalsIgnoreCase("bmp")){
						deleteFile(backServicePath + filePath + FilenameUtils.getBaseName(savedName) + "_thumb.jpg");
			        }
					
					fileIdArr.add(fileObj.optString("FileID"));
				}
			}
			
			if(fileIdArr != null && fileIdArr.size() > 0) {
				CoviMap param = new CoviMap();
				param.put("fileIdArr", fileIdArr);
				deleteComplete(param);// FileID
			}
			
			long elapsedTime = System.currentTimeMillis() - startTime;
			String message = "Complete File[ Param : "+ params.toString() +"] Delete. Elapsed " +  elapsedTime + "ms";
			LOGGER.info(message);

		} catch (NullPointerException ex) { 
			LOGGER.error(ex.getLocalizedMessage(), ex);
		} catch (Exception ex) {
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}
	}

	public void deleteFile(String filePath)throws Exception{
		if(awsS3.getS3Active()){
			awsS3.delete(filePath);
			LOGGER.info("[AWS S3]file : " + filePath + " delete();");
		}else {
			File backFile = new File(filePath);

			if (backFile.isFile()) {
				if (backFile.delete()) {
					LOGGER.info("file : " + backFile.toString() + " delete();");
				} else {
					//삭제 실패시 Logging
					LOGGER.error("Fail on deleteFile() : " + filePath);
					throw new Exception("deleteFile error.");
				}
			}
		}
	}
	
	@Transactional
	private void deleteComplete(CoviMap params) {
		// fileid
		coviMapperOne.delete("framework.FileUtil.deleteFileDbByFileId", params); // sysfile 삭제
	}
}
