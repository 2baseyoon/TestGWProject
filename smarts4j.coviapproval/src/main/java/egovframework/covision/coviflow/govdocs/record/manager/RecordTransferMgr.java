package egovframework.covision.coviflow.govdocs.record.manager;

//

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.govdocs.record.AbstractRecordManager;
import egovframework.covision.coviflow.govdocs.record.handler.AuthHandler;
import egovframework.covision.coviflow.govdocs.record.handler.PdfHandler;
import egovframework.covision.coviflow.govdocs.record.handler.XmlHandler;
import egovframework.covision.coviflow.govdocs.service.GovRecordSyncSvc;
import egovframework.covision.coviflow.govdocs.vo.txt.RecordDocVO;
import egovframework.covision.coviflow.govdocs.vo.txt.RecordGfileHistVO;
import egovframework.covision.coviflow.govdocs.vo.txt.RecordGfileVO;
import egovframework.covision.coviflow.govdocs.vo.txt.RecordPageVO;
import egovframework.covision.coviflow.govdocs.vo.xml.ExchangeXmlVO;
import egovframework.covision.coviflow.govdocs.vo.xml.TransFileVO;

/*
 * 전자기록물이관 송수신 처리
 */
public class RecordTransferMgr extends AbstractRecordManager {
	
	private Logger LOGGER = LogManager.getLogger(RecordTransferMgr.class);
	
	private String workDiv = "transfer";
	private String workFilePath;
	private String workFilePath_FILE;
	 
	public RecordTransferMgr(GovRecordSyncSvc govRecordSyncSvc, AuthHandler auth) {
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
			CoviMap params = new CoviMap();
			params.put("recordClassNumArr", recordClassNumArr);
			try {
				
				try {
					params.put("recordStatus", "0");
					govRecordSyncSvc.updateRecordGfileStatus(params);
				} catch (NullPointerException npE) {
					LOGGER.error(npE.getMessage());
				} catch (Exception e) {
					LOGGER.error(e.getMessage());
				}
				
				if(null != recordDeptCode && !"".equals(recordDeptCode)){
					this.recordDeptCode = recordDeptCode;
				} else {
					this.recordDeptCode = recordClassNum.substring(0, 7);
				}
				
				//workFilePath = getWorkFilePath("send");
				String RMSTransType = RedisDataUtil.getBaseConfig("RMSTransType_TRANS");	// send / receive
				
				workFilePath = getWorkFilePath(RMSTransType);	// 20210318 RMS 답변으로 send > receive 로 변경 위해 수정
				//@ workFilePath="C:/eGovFrame-3.5.1/AS-IS/";  //.txt 파일 생성경로
				
				RecordGfileVO gfileVo = new RecordGfileVO();
				addSendFiles("TRANS_GFILE", workFilePath, gFileList, gfileVo);
				
				RecordDocVO docVo = new RecordDocVO();
				addSendFiles("TRANS_DOC", workFilePath, docList, docVo);
				
				RecordGfileHistVO gfileHistVo = new RecordGfileHistVO();
				addSendFiles("TRANS_GFILEHIST", workFilePath, gFileHist, gfileHistVo);
				
				createExternalFile("TRANS_", workFilePath);

				RecordPageVO pageVo = new RecordPageVO();
				addSendFiles("TRANS_PAGE", workFilePath, docPageList, pageVo);
				
				// TRANSLIST의 endYear를 1년 더하여 전송처리를 위한 기초설정 추가
				String useTRANSLISTAddYear = RedisDataUtil.getBaseConfig("Use_TRANSLIST_AddYear");	// 년도 더하기 사용여부 사용시 연도 + 1
				//String TRANS_Temp_endYear = endYear;
				
				ExchangeXmlVO xmlVo1 = getRecordXml(this.dataFileList);
				if(useTRANSLISTAddYear.equals("Y")) {
					int transTempEndYear = Integer.parseInt(endYear);
					transTempEndYear = transTempEndYear + 1;
					String afterTransYear = Integer.toString(transTempEndYear);
					xmlVo1.setYear(afterTransYear);
				}
				else {
					xmlVo1.setYear(endYear);
				}
				xmlVo1.setOrgCode(this.recordDeptCode);
				xmlVo1.setWorkCode("TRANS_LIST");
				
				String xmlFileName = getFileName("TRANS_LIST", "xml");
				XmlHandler.makeXml(xmlVo1, workFilePath, xmlFileName);
				result = sendFile(workFilePath + xmlFileName); //@ 주석처리
				
				//if("00000".equals(result)){
					
					if(!gFileList.isEmpty()){
						createTransferEfile();
					}
					
					ExchangeXmlVO xmlVo2 = getRecordXml(this.attachFileList);
					xmlVo2.setYear(endYear);
					xmlVo2.setOrgCode(this.recordDeptCode);
					xmlVo2.setWorkCode("TRANS_EFILE");
					
					String xmlEFileName = getFileName("TRANS_EFILE", "xml");
					XmlHandler.makeXml(xmlVo2, workFilePath, xmlEFileName);
					result = sendFile(workFilePath + xmlEFileName);
					
					LOGGER.debug("*****CHKMARO****** xmlEFileName : {}", xmlEFileName);
					
					if("00000".equals(result)){
						
						try {
							params.put("recordStatus", "4");
							govRecordSyncSvc.updateRecordGfileStatus(params);
						} catch (NullPointerException npE) {
							LOGGER.error(npE.getMessage());
						} catch (Exception e) {
							LOGGER.error(e.getMessage());
						}
					}
					
				//} 
				
				if(!"00000".equals(result)){
					try {
						params.put("recordStatus", "9");
						govRecordSyncSvc.updateRecordGfileStatus(params);
					} catch (NullPointerException npE) {
						LOGGER.error(npE.getMessage());
					} catch (Exception e) {
						LOGGER.error(e.getMessage());
					}
				}
				
				ExchangeXmlVO xmlVo3 = getRecordXml(new ArrayList<>());
				xmlVo3.setYear(endYear);
				xmlVo3.setOrgCode(this.recordDeptCode);
				xmlVo3.setWorkCode("TRANS_END");
				
				String xmlEndFileName = getFileName("TRANS_END", "xml");
				XmlHandler.makeXml(xmlVo3, workFilePath, xmlEndFileName);
				
				
				sendFile(workFilePath + xmlEndFileName);
				
			} catch (NullPointerException npE) {
				try {
					params.put("recordStatus", "9");
					govRecordSyncSvc.updateRecordGfileStatus(params);
				} catch (NullPointerException npE2) {
					LOGGER.error(npE2.getMessage());
				} catch (Exception e2) {
					LOGGER.error(e2.getMessage());
				}
			} catch (Exception e) {
				try {
					params.put("recordStatus", "9");
					govRecordSyncSvc.updateRecordGfileStatus(params);
				} catch (NullPointerException npE) {
					LOGGER.error(npE.getMessage());
				} catch (Exception e2) {
					LOGGER.error(e2.getMessage());
				}
			}
			
		} else {
			result = "99999";
		}
		return result;
	}
	
	/*
	 * 첨부파일을 특정 Directory로 복사하고 이름을 변경처리한다.
	 	F2.2 기록물건(본문)	
			- 기록물건 생산(접수)년도(4)+생산(접수)등록번호(13)+기록물분리등록번호(2)+'N'.확장자
		F2.3 기록물건(첨부)							
			- 기록물건 생산(접수)년도(4)+생산(접수)등록번호(13)+첨부파일일련번호(2)+‘S'.확장자
		- PRODUCTYEAR + PRODUCTNUM	
			
		coviMap, coviList1, coviList2
	 */
	public void createTransferEfile(){
		String RMSTransType_FILE = RedisDataUtil.getBaseConfig("RMSTransType_FILE");	// send / receive
		workFilePath_FILE = getWorkFilePath(RMSTransType_FILE);	// 20210318 RMS 답변으로 send > receive 로 변경 위해 수정
		
		int docSize = 0;
		String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
		String storagePath = "";
		
		try{
			CoviMap params = new CoviMap();
			params.put("saveType", "FILE");
			params.put("serviceType", "Approval");
			params.put("osType", osType);
			
			CoviMap storageInfo = govRecordSyncSvc.selectStorageInfo(params);
			storagePath = (String) storageInfo.get("Path");
		} catch(NullPointerException npE){
			LOGGER.error(npE.getMessage());
		} catch(Exception e){
			LOGGER.error(e.getMessage());
		}
		
		if(!docList.isEmpty()){
			
			docSize = docList.size();
			for(int i = 0; i < docSize; i++){
				CoviMap docMap = (CoviMap) docList.get(i);
				
				String recordClassNum = (String) docMap.get("RECORDCLASSNUM");
				String productYear = (String) docMap.get("PRODUCTYEAR");
				String productNum = (String) docMap.get("PRODUCTNUM");
				String workFileName = productYear + productNum;

				//본문 PDF 파일 생성
				long pdfFileSize = 0;
				String pdfFileName = workFileName + "00N.pdf";
				
				String appPath = RedisDataUtil.getBaseConfig("SynapRootPath");
				String pdfUrl = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + PropertiesUtil.getGlobalProperties().getProperty("gov.pdf.url");
				
				String approvalDocLink = (String) docMap.get("APPROVALDOCLINK");
				String[] approvalDocLinkArr = approvalDocLink.split("&");
				
				pdfUrl = pdfUrl + "?" + approvalDocLinkArr[1];
				pdfFileSize = PdfHandler.makeHtmlToPdf(osType, appPath, pdfUrl, workFilePath_FILE, recordClassNum, pdfFileName);
				
				TransFileVO nFile = new TransFileVO();
				nFile.setPath(workFilePath_FILE);
				nFile.setName(recordClassNum + "/" + pdfFileName);
				nFile.setSize(Long.toString(pdfFileSize));
				attachFileList.add(nFile);
				
				LOGGER.debug("*****CHKMARO****** pdfFileName : {}", pdfFileName);
				LOGGER.debug("*****CHKMARO****** docPageList START IN : ");
				
				//첨부파일 COPY 및 이름 변경 처리
				if(!docPageList.isEmpty()){
					
					int attSize = docPageList.size();
					for(int j = 0; j < attSize; j++){
						CoviMap fileMap = docPageList.getMap(j);
						String recordClassNum1 = (String) fileMap.get("RECORDCLASSNUM");
						String productNum1 = (String) fileMap.get("PRODUCTNUM");
						
						if(recordClassNum.equals(recordClassNum1) && productNum.equals(productNum1)){
							String workFileName1 = productYear + productNum;
							
							String filePath = fileMap.getString("FILEPATH");
							//String fileName = (String) fileMap.getString("FILENAME");
							String fileName = fileMap.getString("SAVEDNAME");
							String fileSeq = fileMap.getString("FILESEQ");
							
							String fileExt = fileMap.getString("EXTENTION");
							
							String moveFileName = workFileName1 + getAttachNum(Integer.parseInt(fileSeq)) + "S";
							
							LOGGER.debug("*****CHKMARO****** docPageList FILENAME : {}", moveFileName);
							
							if(fileCopy(storagePath + filePath, fileName, workFilePath_FILE + recordClassNum, moveFileName, fileExt)){
								LOGGER.debug("*****CHKMARO****** fileCopy IN START1 : CHK ");
								LOGGER.debug("*****CHKMARO****** fileCopy IN START2 : {}", workFilePath_FILE);
								TransFileVO sFile = new TransFileVO();
								sFile.setPath(workFilePath_FILE);
								sFile.setName(recordClassNum + "/" + moveFileName + "." + fileExt);
								
								LOGGER.debug("*****CHKMARO****** fileCopy FILEFULLPATH : {}", workFilePath_FILE + recordClassNum + "/" + moveFileName + "." + fileExt);
								
								File sizeFile = new File(workFilePath_FILE + recordClassNum + "/" + moveFileName + "." + fileExt);
								sFile.setSize(Long.toString(sizeFile.length()));
								attachFileList.add(sFile);
								
								LOGGER.debug("*****CHKMARO****** fileCopy END ");
							}
						}
					}
					
				}
				
				
				LOGGER.debug("*****CHKMARO****** docPageList START OUT : ");
				
			}
		}
		
		
				
	}
	
	/*
	 * 첨부파일 순번을 리턴한다.
	 */
	private String getAttachNum(int idx){
		return String.format("%02d", idx);
	}
	
	/*
	 * 첨부파일을 send directory로 copy 및 rename 처리 한다.
	 */
	private boolean fileCopy(String filePath, String fileName, String moveFilePath, String moveFileName, String fileExt){
		boolean result = false;
		
		File srcFile = new File(filePath + fileName);
		File desFile = new File(moveFilePath);
		
		LOGGER.debug("*****CHKMARO****** fileCopy1 : {}{}", filePath, fileName);
		LOGGER.debug("*****CHKMARO****** fileCopy2 : {}", moveFilePath);
		
		if(!desFile.isDirectory() && !desFile.mkdirs()) {
			LOGGER.debug("Failed to make directories.");
		}
		
		LOGGER.debug("*****CHKMARO****** fileCopy3 : MKDIR AFTER ");
		
		desFile = new File(moveFilePath + File.separator + moveFileName + "." + fileExt);
		
		if (srcFile.exists()) {
			try {
				LOGGER.debug("*****CHKMARO****** copyFile START");
				FileUtils.copyFile(srcFile, desFile);
				
				LOGGER.debug("*****CHKMARO****** copyFile END");
				result = true;
			} catch (IOException e) {
				LOGGER.debug("*****CHKMARO****** ERROR : {}", e);
				LOGGER.error(e.getMessage());
			}
        }
		
		LOGGER.debug("*****CHKMARO****** fileCopy4 : copyFile AFTER ");
		
		return result;
	}
	
	
	/*
	 */
	@Override
	public void receiveFile(String recvFileName) {
		if(null != recvFileName && !"".equals(recvFileName)){
			String[] recvFilesNameArr = recvFileName.split("_", -1);
			
			if(recvFilesNameArr.length > 0 && ("RETURN").equals(recvFilesNameArr[2])){
				List<TransFileVO> fileList = null;
				
				recvFileName = getRecvFilePath() + recvFilesNameArr[0] + "/" + recvFileName;
				ExchangeXmlVO xmlVo = XmlHandler.parseXml(recvFileName);
				
				fileList = xmlVo.getFileList();
				
				if(!fileList.isEmpty()){
					
					String[] fieldName = new String[]{"recordDeptCode", "productYear", "seriesCode", "recordSeq", "recordCount"};
					
					for(TransFileVO file : fileList){
						String recvTxtFileName = file.getName();
						String recvTxtFilePath = recvFileName.substring(0, recvFileName.lastIndexOf("/") + 1);
						
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
								param.put("recordStatus", "7");
								govRecordSyncSvc.updateRecordGfileStatus(param);
							}
						} catch(IOException e){
							LOGGER.error(e.getMessage());
						} catch(NullPointerException npe){
							LOGGER.error(npe.getMessage());
						} catch (Exception e){
							LOGGER.error(e.getMessage());
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
			LOGGER.info("config.properties path : " + System.getProperty("user.home") + "/" + "config.properties");
			try (FileInputStream fis = new FileInputStream(new File(FileUtil.checkTraversalCharacter(System.getProperty("user.home")), "config.properties"))){
				prop.load(fis);
			}
			
			String workDir = prop.getProperty("setting.rootPath");
			String rcCode = prop.getProperty("setting.rcCode");
			
			filePath = workDir + "/" + rcCode + "/" + "receive/transfer/";  
		} catch(IOException e){
			LOGGER.error(e.getMessage());
		}
		
		return filePath;
	}
}


