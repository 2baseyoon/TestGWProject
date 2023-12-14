package egovframework.covision.coviflow.govdocs.record.manager;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.List;
import java.util.Properties;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.govdocs.record.AbstractRecordManager;
import egovframework.covision.coviflow.govdocs.record.handler.AuthHandler;
import egovframework.covision.coviflow.govdocs.record.handler.XmlHandler;
import egovframework.covision.coviflow.govdocs.service.GovRecordSyncSvc;
import egovframework.covision.coviflow.govdocs.vo.xml.ExchangeXmlVO;
import egovframework.covision.coviflow.govdocs.vo.xml.TransFileVO;

public class RecordClassifyMgr extends AbstractRecordManager {
	private Logger LOGGER = LogManager.getLogger(RecordClassifyMgr.class);
	private String workDiv = "classify";

	public RecordClassifyMgr(GovRecordSyncSvc govRecordSyncSvc, AuthHandler auth) {
		super(govRecordSyncSvc, auth);
	}

	@Override
	public String getWorkDiv() {
		return this.workDiv;
	}

	@Override
	public String executeSendFile(String baseYear, String recordDeptCode, String recordClassNum,
			String[] recordClassNumArr) {
		return "";
	}

	/*
	 * 처리기관코드_NEW_UNIT_FILE_YYYYMMDDhhmmss.xml
	 * 처리기관코드_NEW_CLASS_FILE_YYYYMMDDhhmmss.xml
	 */
	@Override
	public void receiveFile(String recvFileName) {
		if (null != recvFileName && !"".equals(recvFileName)) {
			List<TransFileVO> fileList = null;

			ExchangeXmlVO xmlVo = XmlHandler.parseXml(recvFileName);
			fileList = xmlVo.getFileList();

			if (!fileList.isEmpty()) {
				CoviList params = new CoviList();
				String[] fieldName = new String[] { "processDateTime", "applyDate", "deptCode", "deptName",
						"tempSeriesCode", "Lfnamecode", "Lfname", "Mfnamecode", "Mfname", "sfCode", "Sfname",
						"seriesCode", "seriesName", "seriesDescription", "keepPeriod", "keepPeriodReason", "keepMethod",
						"keepPlace", "provisionRecordStatus", "provisionRecordPeriod", "expectedFrequency",
						"openPurpose", "specialListLocation", "specialList1", "specialList2", "specialList3",
						"jobType" };

				for (TransFileVO file : fileList) {
					String recvTxtFileName = file.getName();
					String recvTxtFilePath = recvFileName.substring(0, recvFileName.lastIndexOf("/") + 1);
					File recvTxtFile = new File(recvTxtFilePath + recvTxtFileName);
					try (FileInputStream fis = new FileInputStream(recvTxtFile);
							InputStreamReader is = new InputStreamReader(fis, "EUC-KR");
							BufferedReader br = new BufferedReader(is);) {

						String readLine = "";
						while ((readLine = br.readLine()) != null) {
							String[] claasifyData = readLine.split("\u0000");
							CoviMap param = new CoviMap();

							for (int ii = 0; ii < fieldName.length; ii++) {
								param.put(fieldName[ii], getValue(claasifyData, ii));
							}
							param.put("BaseYear", xmlVo.getYear());

							params.add(param);
						}

					} catch (IOException fe) {
						LOGGER.error("{} :  {}", this.getClass().getCanonicalName(), fe.getLocalizedMessage());
					}

				}

				try {
					govRecordSyncSvc.updateSyncSeries(params);
				} catch (NullPointerException npE) {
					LOGGER.error("{} :  {}", this.getClass().getCanonicalName(), npE.getLocalizedMessage());
				} catch (Exception e) {
					LOGGER.error("{} :  {}", this.getClass().getCanonicalName(), e.getLocalizedMessage());
				}
			}

		}
	}

	private String getRecvFilePath(String recvFileName) {
		String filePath = "";
		Properties prop = new Properties();
		try {

			LOGGER.info("config.properties path : {}/config.properties", System.getProperty("user.home"));
			try (FileInputStream fis = new FileInputStream(
					new File(FileUtil.checkTraversalCharacter(System.getProperty("user.home")), "config.properties"))) {
				prop.load(fis);
			}

			String workDir = prop.getProperty("setting.rootPath");
			String rcCode = prop.getProperty("setting.rcCode");

			filePath = workDir + "/" + rcCode + "/" + "receive/classify/";

		} catch (IOException ioe) {
			LOGGER.error("{} :  {}", this.getClass().getCanonicalName(), ioe.getLocalizedMessage());
		}

		return filePath;
	}

}
