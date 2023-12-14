package egovframework.coviframework.util;

import java.io.File;
import java.io.PrintWriter;
import java.io.StringWriter;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.service.FileEncryptor;


@Service("asyncTaskFileEncryptor")
public class AsyncTaskFileEncryptor {
	private Logger log = LogManager.getLogger(AsyncTaskFileEncryptor.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Async("coviExecutorFileEncrypt")
	public void encrypt(File source, String companyCode, CoviMap obj) throws Exception{
		String isUse = PropertiesUtil.getSecurityProperties().getProperty("file.encryptor.bean.use", "");
		if(!"Y".equals(isUse)) {
			return;
		}
		
		long startTime = System.currentTimeMillis();
		try {
			String fileID = obj.getString("FileID");
			
			// Insert history
			insertEncryptionInfo(obj);
			
			FileEncryptor.getInstance().encrypt(source, companyCode);
			
			long elapsedTime = System.currentTimeMillis() - startTime;
			String message = "Complete File["+fileID+"] Encryption. Elapsed " +  elapsedTime + "ms";
			log.info(message);
			
			
			obj.put("Status", "COMPLETE");
			obj.putOrigin("ElapsedTime", elapsedTime);
			obj.putOrigin("Message", message);

			// Insert history
			updateEncryptionInfo(obj);
		} catch(NullPointerException e){	
			log.error(e.getLocalizedMessage(), e);
			long elapsedTime = System.currentTimeMillis() - startTime;
			
			//StringWriter sw = new StringWriter();
		    //PrintWriter pw = new PrintWriter(sw);
			//e.printStackTrace(pw);
			
			obj.put("Status", "FAIL");
			obj.putOrigin("Message", e.getMessage());
			obj.putOrigin("ElapsedTime", elapsedTime);
			updateEncryptionInfo(obj);
		} catch (Exception ex) {
			log.error(ex.getLocalizedMessage(), ex);
			long elapsedTime = System.currentTimeMillis() - startTime;
			
			//StringWriter sw = new StringWriter();
		    //PrintWriter pw = new PrintWriter(sw);
			//ex.printStackTrace(pw);
			
			obj.put("Status", "FAIL");
			obj.putOrigin("Message", ex.getMessage());
			obj.putOrigin("ElapsedTime", elapsedTime);
			updateEncryptionInfo(obj);
		}
	}
	
	@Transactional
	private void insertEncryptionInfo(CoviMap params) {
		// encid, fileid, filename, status, registercode, registdate
		coviMapperOne.update("framework.FileUtil.insertEncryption", params);
	}
	
	@Transactional
	private void updateEncryptionInfo(CoviMap params) {
		// encid, fileid, filename, status, registercode, registdate
		coviMapperOne.update("framework.FileUtil.updateEncryptionStatus", params);
		if("COMPLETE".equals(params.optString("Status"))) {
			coviMapperOne.update("framework.FileUtil.updateSysFileEncrypted", params);
		}
	}
}
