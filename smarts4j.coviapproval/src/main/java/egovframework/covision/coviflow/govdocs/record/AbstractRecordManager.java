package egovframework.covision.coviflow.govdocs.record;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.covision.coviflow.govdocs.record.handler.AuthHandler;
import egovframework.covision.coviflow.govdocs.record.handler.TxtHandler;
import egovframework.covision.coviflow.govdocs.service.GovRecordSyncSvc;
import egovframework.covision.coviflow.govdocs.vo.txt.RecordDocHistVO;
import egovframework.covision.coviflow.govdocs.vo.txt.RecordSprecordVO;
import egovframework.covision.coviflow.govdocs.vo.xml.ExchangeXmlVO;
import egovframework.covision.coviflow.govdocs.vo.xml.TransFileVO;

public abstract class AbstractRecordManager {
	
	private static String RCCODE = "B500003";
	private AuthHandler auth;
	
	protected GovRecordSyncSvc govRecordSyncSvc;
	protected String recordDeptCode;
	protected List<TransFileVO> dataFileList;
	protected List<TransFileVO> attachFileList;
	
	protected CoviList gFileList;
	protected CoviList docList;
	protected CoviList docPageList;
	protected CoviList gFileHist;
	
	protected AbstractRecordManager(GovRecordSyncSvc govRecordSyncSvc, AuthHandler auth){
		this.govRecordSyncSvc = govRecordSyncSvc;
		this.auth = auth;
	}
	
	public abstract String executeSendFile(String endYear, String recordDeptCode, String recordClassNum, String[] recordClassNumArr);
	
	
	//기록물철 이관 대상 기본 조회
	protected boolean selectRecordFileList(String[] recordClassNumArr){
		boolean result = true;
		try{
			CoviMap params = new CoviMap();
			params.put("recordClassNumArr", recordClassNumArr);
			
			gFileList = govRecordSyncSvc.selectRecordGFileData(params);
			docList = govRecordSyncSvc.selectRecordDocList(params);
			docPageList = govRecordSyncSvc.selectRecordDocPageList(params);
			gFileHist = govRecordSyncSvc.selectRecordHistoryList(params);
		} catch(NullPointerException npE){
			result = false;
		} catch(Exception e){
			result = false;
		}
		return result;
	}
	
	//한국투자공사는 아래의 데이터가 관리되고 있지 않아서 강제로 빈파일을 만들어준다.
	protected void createExternalFile(String workType, String workFilePath){
		RecordDocHistVO docHistVo = new RecordDocHistVO();
		addSendFiles(workType + "DOCHIST", workFilePath, new CoviMap(), docHistVo);
		RecordSprecordVO sprecordVo = new RecordSprecordVO();
		addSendFiles(workType + "SPRECORD", workFilePath, new CoviMap(), sprecordVo);
		/*RecordDistVO distVo = new RecordDistVO();
		addSendFiles(workType + "DIST", workFilePath, new CoviMap(), distVo);*/
	}
	
	public abstract String getWorkDiv();
	public abstract void receiveFile(String fileFullPath);
	
	public String getFileName(String jobType, String fileExt){
		SimpleDateFormat sdf = new SimpleDateFormat("yyMMddHHmmss");
		String timeStamp = sdf.format(new Date());
		return this.recordDeptCode + "_" + jobType + "_" + timeStamp + "." + fileExt;
	}
	
	private void addFileList(String fileName){
		TransFileVO tfVo = new TransFileVO();
		String RMSTransType = RedisDataUtil.getBaseConfig("RMSTransType");	// send / receive
		String filePath = getWorkFilePath(RMSTransType);	// 20210318 RMS 답변으로 send > receive 로 변경 위해 수정
		
		tfVo.setPath(filePath);
		tfVo.setName(fileName);
		
		File file = new File(filePath + File.separator + fileName);
		if(file.isFile()){
			long fileSize = file.length();
			tfVo.setSize("" + fileSize);
		} else {
			tfVo.setSize("0");
		}
		dataFileList.add(tfVo);
	}

	public void addSendFiles(String jobType, String filePath, CoviMap coviMap, Object object){
		String fileFullName = writeMapToTxt(filePath, jobType, coviMap, object);
		addFileList(fileFullName);
	}
	
	
	public void addSendFiles(String jobType, String filePath, CoviList coviList, Object object){
		String fileFullName = writeListToTxt(filePath, jobType, coviList, object);
		addFileList(fileFullName);
	}
	
	public ExchangeXmlVO getRecordXml(List<TransFileVO> sendFiles){
		ExchangeXmlVO xmlVo = new ExchangeXmlVO();
		
		xmlVo.setWorkDiv(getWorkDiv());
		xmlVo.setRcCode(auth.getRcCode()); //@ 주석처리
		xmlVo.setRcCode("");
		xmlVo.setOnePlatformYN("N");
		xmlVo.setOnLineYN("Y");
		xmlVo.setKey(auth.getKey());  //@ 주석처리
		xmlVo.setKey("");
		
		
		xmlVo.setSend(auth.getServerConfig("SEND"));
		xmlVo.setReceive(auth.getServerConfig("RECV"));
		xmlVo.setFileList(sendFiles);
		
		return xmlVo;
	}
	
	protected String writeMapToTxt(String filePath, String jobType, CoviMap coviMap, Object object){
		String fileName = getFileName(jobType, "txt");
		TxtHandler.writeTxt(filePath, fileName, coviMap, object, "N");
		return fileName;		
	}
	
	protected String writeListToTxt(String filePath, String jobType, CoviList covList, Object object){
		String fileName = getFileName(jobType, "txt");
		TxtHandler.writeTxt(filePath, fileName, covList, object);
		return fileName;		
	}
	
	
	/*
	 * Gr 모듈 연동에서 사용되는 파일 패스 경로 리턴
	 * ex : 
	 * 	C:\devp\stor\gr\B500003\send\product\I121171
	 *  C:\devp\stor\gr\B500003\send\transfer\I121171
	 */
	protected String getWorkFilePath(String transType){
		return this.auth.getWorkDir() + "/" + RCCODE + "/" + transType + "/" + getWorkDiv() + "/" + this.recordDeptCode + "/";
	}
	
	protected String getValue(String[] dataArr, int idx) {
		if(null != dataArr && dataArr.length > idx){
			return dataArr[idx];
		} else {
			return "";
		}
    }
	
	protected String sendFile(String filePath) {
		return auth.callSendFile(filePath);
    }
}
