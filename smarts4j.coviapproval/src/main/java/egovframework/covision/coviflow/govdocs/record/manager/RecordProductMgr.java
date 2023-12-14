package egovframework.covision.coviflow.govdocs.record.manager;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.govdocs.record.AbstractRecordManager;
import egovframework.covision.coviflow.govdocs.record.handler.AuthHandler;
import egovframework.covision.coviflow.govdocs.record.handler.XmlHandler;
import egovframework.covision.coviflow.govdocs.service.GovRecordSyncSvc;
import egovframework.covision.coviflow.govdocs.vo.txt.RecordDocVO;
import egovframework.covision.coviflow.govdocs.vo.txt.RecordGfileHistVO;
import egovframework.covision.coviflow.govdocs.vo.txt.RecordGfileVO;
import egovframework.covision.coviflow.govdocs.vo.txt.RecordPageVO;
import egovframework.covision.coviflow.govdocs.vo.xml.ExchangeXmlVO;
import egovframework.covision.coviflow.govdocs.vo.xml.TransFileVO;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/*
 * 생산현황 보고 송수신 처리
 */
public class RecordProductMgr extends AbstractRecordManager {
	
	private Logger LOGGER = LogManager.getLogger(RecordProductMgr.class);
	
	private String workDiv = "product";
	private String workFilePath;
	
	public RecordProductMgr(GovRecordSyncSvc govRecordSyncSvc, AuthHandler auth) {
		super(govRecordSyncSvc, auth);
	}

	@Override
	public String getWorkDiv() {
		return this.workDiv;
	}
	
	@Override
	public String executeSendFile(String endYear, String recordDeptCode, String recordClassNum, String[] recordClassNumArr){
		String result = "";
		
		dataFileList = new ArrayList<TransFileVO>();
		attachFileList = new ArrayList<TransFileVO>();
		
		if(null != recordClassNum && !"".equals(recordClassNum)){
			recordClassNumArr = new String[]{recordClassNum};
		} 
		
		if(selectRecordFileList(recordClassNumArr)){
			
			try {
				CoviMap params = new CoviMap();
				
				params.put("recordStatus", "0");
				params.put("recordClassNumArr", recordClassNumArr);
				
				govRecordSyncSvc.updateRecordGfileStatus(params);
			} catch (NullPointerException npE) {
				LOGGER.error(npE.getMessage());
			} catch (Exception e) {
				LOGGER.error(e.getMessage());
			}
			
			if(null != recordDeptCode && !"".equals(recordDeptCode)){
				this.recordDeptCode = recordDeptCode;
			} else {
				if(recordClassNum != null && !recordClassNum.isEmpty())
					this.recordDeptCode = recordClassNum.substring(0, 7);
			}
			
			//workFilePath = getWorkFilePath("send");
			String RMSTransType = RedisDataUtil.getBaseConfig("RMSTransType_PROD");	// send / receive
			workFilePath = getWorkFilePath(RMSTransType);	// 20210318 RMS 답변으로 send > receive 로 변경 위해 수정
			
			RecordGfileVO gfileVo = new RecordGfileVO();
			addSendFiles("PROD_GFILE", workFilePath, gFileList, gfileVo);
			
			RecordDocVO docVo = new RecordDocVO();
			addSendFiles("PROD_DOC", workFilePath, docList, docVo);
			
			RecordPageVO pageVo = new RecordPageVO();
			addSendFiles("PROD_PAGE", workFilePath, docPageList, pageVo);
			
			RecordGfileHistVO gfileHistVo = new RecordGfileHistVO();
			addSendFiles("PROD_GFILEHIST", workFilePath, gFileHist, gfileHistVo);
			
			createExternalFile("PROD_", workFilePath);
			
			ExchangeXmlVO xmlVo = getRecordXml(this.dataFileList);
	    	xmlVo.setYear(endYear);
	    	xmlVo.setOrgCode(this.recordDeptCode);
	    	xmlVo.setWorkCode("PROD_REPORT");
	    	
	    	String xmlFileName = getFileName("PROD_REPORT", "xml");
			XmlHandler.makeXml(xmlVo, workFilePath, xmlFileName);
			result = sendFile(workFilePath + xmlFileName);
			
			if("00000".equals(result)){
				try {
					
					CoviMap params = new CoviMap();
					
					params.put("recordStatus", "3");
					params.put("recordClassNumArr", recordClassNumArr);
					
					govRecordSyncSvc.updateRecordGfileStatus(params);
				} catch (NullPointerException npE) {
					LOGGER.error(npE.getMessage());
				} catch (Exception e) {
					LOGGER.error(e.getMessage());
				}
			} else {
				try {
					
					CoviMap params = new CoviMap();
					
					params.put("recordStatus", "8");
					params.put("recordClassNumArr", recordClassNumArr);
					
					govRecordSyncSvc.updateRecordGfileStatus(params);
				} catch (NullPointerException npE) {
					LOGGER.error(npE.getMessage());
				} catch (Exception e) {
					LOGGER.error(e.getMessage());
				}
			}
		} else {
			result = "999999";
		}
		
		return result;
	}

	/*
	 * 처리기관코드_PROD_ACCEPT_YYYYMMDDhhmmss.xml
	 * 처리기관코드_PROD_RETURN_YYYYMMDDhhmmss.xml
	 */
	@Override
	public void receiveFile(String recvFileName) {
		if(null != recvFileName && !"".equals(recvFileName)){
			String[] recvFilesNameArr = recvFileName.split("_", -1);
			
			if(recvFilesNameArr.length > 0){
				if(("RETURN").equals(recvFilesNameArr[2])){
					List<TransFileVO> fileList = null;
					
					recvFileName = getRecvFilePath() + recvFilesNameArr[0] + "/" + recvFileName;
					ExchangeXmlVO xmlVo = XmlHandler.parseXml(recvFileName);
					
					fileList = xmlVo.getFileList();
					
					if(!fileList.isEmpty()){
						
						String[] fieldName = new String[]{"recordDeptCode", "productYear", "seriesCode", "recordSeq", "recordCount"};
						
						for(TransFileVO file : fileList){
							String recvTxtFileName = file.getName();
							String recvTxtFilePath = recvFileName.substring(0, recvFileName.lastIndexOf("/") + 1);
							
							LOGGER.debug(file.getName());
							
							try{
								File recvTxtFile = new File(recvTxtFilePath + recvTxtFileName);
								try(
										FileInputStream fis = new FileInputStream(recvTxtFile);
										InputStreamReader is = new InputStreamReader(fis, "EUC-KR");
										BufferedReader br = new BufferedReader(is);
										){
									String readLine = "";
									while((readLine = br.readLine()) != null){
										String[] claasifyData = readLine.split("\u0000");
										CoviMap param = new CoviMap();
										
										for (int ii = 0; ii < fieldName.length; ii++) {
											param.put(fieldName[ii], getValue(claasifyData, ii));
										}
										param.put("recordStatus", "6");
										govRecordSyncSvc.updateRecordGfileStatus(param);
									}
								}
							} catch(FileNotFoundException e){
								LOGGER.error(e.getMessage());
							} catch (IOException e) {
								LOGGER.error(e.getMessage());
							} catch (Exception e){
								LOGGER.error(e.getMessage());
							}
							
						}
						
					}
				}
			} 
		} 
	}
	
	private String getRecvFilePath(){
		String filePath = "";
		Properties prop = new Properties();
		try{
			LOGGER.info("config.properties path : " + System.getProperty("user.home") + "config.properties");
			try (FileInputStream fis = new FileInputStream(new File(FileUtil.checkTraversalCharacter(System.getProperty("user.home")), "config.properties"));){
				prop.load(fis);
			}
			
			String workDir = prop.getProperty("setting.rootPath");
			String rcCode = prop.getProperty("setting.rcCode");
			
			filePath = workDir + "/" + rcCode + "/" + "receive/product/";  
			
		} catch(FileNotFoundException ffe){
			LOGGER.debug(ffe);
		} catch(IOException ioe){
			LOGGER.debug(ioe);
		}
		
		return filePath;
	}
}


