package egovframework.covision.coviflow.govdocs.util;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.ThreadContext;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.common.util.ChromeRenderManager;
import egovframework.covision.coviflow.govdocs.service.ApprovalGovDocSvc;



/**
 * AsyncTaskEdmsTransfer *
 */
@Service("asyncTaskOpenDocConverter")
public class AsyncTaskOpenDocConverter{
	
	private Logger LOGGER = LogManager.getLogger(AsyncTaskOpenDocConverter.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private FileUtilService fileUtilService;
	
	/**
	 * 본문 컨버젼
	 * 상태값 : CONVERROR
	 */
	@Transactional
	@Async("executorOpenDocConvert")
	public void executeOpenDocConvert(final CoviMap spParams) throws Exception{
		CoviMap param = new CoviMap();
		String formInstID = spParams.getString("formInstID");
		
		spParams.put("formInstID", formInstID);

		CoviMap mainDocInfo = coviMapperOne.selectOne("form.formLoad.selectFormInstance", spParams);
		CoviMap openDocInfo = coviMapperOne.select("user.govDoc.openDoc.selectOpenDoc", spParams);
		param.put("DOC_MNGE_CARD_ID", formInstID);
		try {
			String subject = openDocInfo.getString("SJ");
			Map<String, String> paramMap = new HashMap<>();
			
			// 2. Convert DEXT5 Filtered HTML to PDF
			String bodyContextStr = new String(Base64.decodeBase64(mainDocInfo.getString("BodyContext")),StandardCharsets.UTF_8);
			CoviMap bodyContext = CoviMap.fromObject(bodyContextStr);
			String filterHtml = bodyContext.getString("tbContentElementHWP");// DEXT5 Editor Filter 를 통한 HTML 임.
		    //본문 內 개인정보 비식별처리...
			filterHtml = PrivacyInfoMaskingUtil.getMaskContents(filterHtml);
			bodyContext.put("tbContentElementHWP", filterHtml);
			bodyContextStr = bodyContext.toString();
			
			String companyCode = mainDocInfo.getString("EntCode");
			ThreadContext.put("EN_Code", companyCode);
			
			// 시행문변환
			/**
			CoviMap docInfo = CoviMap.fromObject( paramMap.get("bodyContext") );
			docInfo.put("ENFORCEDATE"		, paramMap.get("enForceDate") );
			docInfo.put("SaveTerm"			, "");
			coviMap.put("requestMode"		, paramMap.get("requestMode"));
			docInfo.put("publicationCode"	, paramMap.get("publicationCode"));
			docInfo.put("publicationValue"	, paramMap.get("publicationValue"));
			coviMap.put("BODY_CONTEXT"		, Base64.encodeBase64String(docInfo.toString().getBytes("UTF-8")) );
			coviMap.put("RECEIVER_NAME"		, paramMap.get("receiverName"));
			coviMap.put("PROCESS_SUBJECT"	, paramMap.get("processSubject"));
			coviMap.put("APPROVAL_CONTEXT"	, paramMap.get("approvalContext"));
			coviMap.put("DOC_NUMBER"		, paramMap.get("docNumber"));				
			coviMap.put("INITIATOR_ID"		, paramMap.get("initiatorID"));
			 */
			
			LinkedMultiValueMap<String, String> sihengParamMap = new LinkedMultiValueMap<>();
			sihengParamMap.add("requestMode", "PREVIEW");
			
			// bodyContext 가공.
			String oppYn = openDocInfo.getString("OPP_YN"); // 1NNNNNNNN
			String disclosureCode = oppYn.substring(0,1);
			Map<String, String> disclosureInfo = new Hashtable<String, String>();
			disclosureInfo.put("1", "공개");
			disclosureInfo.put("2", "부분공개");
			disclosureInfo.put("3", "비공개");
			
			
			sihengParamMap.add("enForceDate"		, mainDocInfo.getString("CompletedDate"));// 완료일자
			sihengParamMap.add("publicationCode"	, oppYn);
			sihengParamMap.add("publicationValue"	, disclosureInfo.get(disclosureCode));
			
			sihengParamMap.add("bodyContext", bodyContextStr);
			sihengParamMap.add("receiverName", mainDocInfo.getString("ReceiveNames"));
			sihengParamMap.add("processSubject", subject);
			sihengParamMap.add("approvalContext", openDocInfo.getString("APPROVALCONTEXT"));
			sihengParamMap.add("docNumber", mainDocInfo.getString("DOC_NO_NM"));
			sihengParamMap.add("initiatorID", mainDocInfo.getString("InitiatorID"));
			
			CoviMap 	returnObj 	= new CoviMap();
		    RestTemplate restTemplate = new RestTemplate();
		    try {
		    	returnObj = restTemplate.postForObject(PropertiesUtil.getGlobalProperties().getProperty("govDoc.path")+"govdocs/service/govDocsPreview.do", sihengParamMap, CoviMap.class);	    	
		    	if( returnObj.get("status").equals("INTERNAL_SERVER_ERROR") ) throw new Exception();
		    }catch (NullPointerException npE) {
		    	LOGGER.error(npE.getLocalizedMessage(), npE);
		    	throw new Exception(npE.getLocalizedMessage());
			}catch (Exception e) {
		    	LOGGER.error(e.getLocalizedMessage(), e);
		    	throw new Exception(e.getLocalizedMessage());
			}
		    String sihengOutDocHtml = returnObj.getString("content");

		    paramMap.clear();
		    
			// 직인이미지 제거.
		    Document htmlDoc = Jsoup.parse(sihengOutDocHtml);
		    Element body = htmlDoc.body();
			String sealAlt = ComUtils.getProperties("govdocs.properties").getProperty("content.seal.alt", "xxx");
			Elements imgs = body.select("img[alt="+sealAlt+"]");
			if(imgs != null && imgs.size() == 1) {
				imgs.get(0).remove();
			}
			sihengOutDocHtml = htmlDoc.toString(); 
		    
		    StringBuffer buf = new StringBuffer();
		    // 가운데 정렬사용.
		    buf.append("<table style='"+ComUtils.getProperties("govdocs.properties").getProperty("opendoc.siheng.pdf.wrapper.style")+"'><tr><td>");
		    buf.append(sihengOutDocHtml);
		    buf.append("</td></tr></table>");
		    
			paramMap.put("txtHtml", buf.toString());
			CoviMap pdfResult = ChromeRenderManager.getInstance(false).createPdf(paramMap);
			String saveFileName = pdfResult.optString("saveFileName");
			String savePath = pdfResult.optString("savePath");

			String docFilePath = savePath + saveFileName;
			
			// pdf Temp file to BackStorage
			List<MultipartFile> mf_contents = new ArrayList<>(1);
			File file = new File(docFilePath);
			if(!file.exists()) {
				throw new Exception("File Make Failed.");
			}
			
			// Temp 파일 그대로 사용한다.
			String contentType = "text/plain";
			String pdfFileName = subject + ".pdf";
			byte[] content = Files.readAllBytes(Paths.get(docFilePath));
			MultipartFile mf = new MockMultipartFile(pdfFileName, saveFileName, contentType, content);
			mf_contents.add(mf);
			
			
			String fileOppYn = "N";
			//String oppYn = openDocInfo.getString("OPP_YN");
			switch(oppYn.substring(0, 1)) {
			case "1" :
				fileOppYn = "Y";
				break;
			case "2" :
				fileOppYn = "N"; // 공개가 아니면 파일은 비공개처리함.
				break;
			case "3" :
				fileOppYn = "N";
				break;
			default : break;
			}
			
			
			CoviMap docFileInfo = new CoviMap();
			if (mf_contents != null && mf_contents.size() > 0) {
				//CoviMap fileObj = FileUtil.fileUpload(mf_contents);
				String bizSection = "Approval_OpenDoc";
				String messageId = formInstID;
				String uploadPath = bizSection + File.separator;// 일단 현재는 serviceType 과 servicePath 가 같아야 공통파일다운로드를 사용할 수 있음.
				String objectId = formInstID;
				String objectType = "PDF";
				
				// 문서재변환이 발생할 수있으므로 기존파일 (Garbage) 삭제처리.
				CoviMap fileCoviMap = coviMapperOne.select("user.govDoc.openDoc.selectGovOpenDocFile", param); // PDF 파일경로 조회
				if(fileCoviMap != null && !"".equals(fileCoviMap.getString("FILE_PATH"))) {
					String prevSavePath = fileCoviMap.getString("FILE_PATH");
					File delFile = new File(prevSavePath);
					if(delFile.exists() && !delFile.delete()) {
						LOGGER.error("Error on delete previous pdf file.");
					}
					//데이터 삭제 처리
					String fileId = fileCoviMap.getString("FILE_ID");
//					fileCoviMap.clear();
//					fileCoviMap.put("fileIdArr",new ArrayList<>(java.util.Arrays.asList(fileId)));
//					coviMapperOne.delete("framework.FileUtil.deleteFileDbByFileId", fileCoviMap);
					fileUtilService.deleteFileByID(fileId,false);
				}
		    	
		    	
		    	// PDF 파일 업로드 (Back Storage)
				CoviList fileInfos = fileUtilService.uploadToBack(null, mf_contents, uploadPath , bizSection, objectId, objectType, messageId);
				if(fileInfos != null && !fileInfos.isEmpty()) {
					String uploadedFileId = fileInfos.getJSONObject(0).getString("FileID");
					String uploadedFilePath = fileInfos.getJSONObject(0).getString("FilePath");
					String uploadedFileSaveName = fileInfos.getJSONObject(0).getString("SavedName");
					String uploadedFileSize = fileInfos.getJSONObject(0).getString("Size");
					String uploadedCompanyCode = fileInfos.getJSONObject(0).getString("CompanyCode");
					String uploadedStorageID = fileInfos.getJSONObject(0).getString("StorageID");
					
					docFileInfo.put("DOC_MNGE_CARD_ID", formInstID);
					docFileInfo.put("FILE_SE_CD", "본문");
					docFileInfo.put("FILE_ID", uploadedFileId);
					docFileInfo.put("FILE_NM", pdfFileName);
					docFileInfo.put("FILE_MG", uploadedFileSize);
					docFileInfo.put("FILE_ORDR", 0);
					docFileInfo.put("FILE_OPP_YN", fileOppYn);// 공개여부
					
					CoviMap storageInfo = FileUtil.getStorageInfo(uploadedStorageID);
					//String finalFilePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + uploadPath + uploadedFilePath + uploadedFileSaveName;
					String finalFilePath = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + storageInfo.optString("FilePath").replace("{0}", uploadedCompanyCode) + uploadedFilePath + uploadedFileSaveName;
					docFileInfo.put("FILE_PATH", finalFilePath);// 파일절대경로 , 실시간 파일연계시 사용.
				}else {
					throw new Exception("");
				}
			}
			
			// Delete/Insert Files Informations.
			CoviList fileList = new CoviList();
			fileList.add(docFileInfo);
			
			// 첨부파일
			CoviList attachFileList = null;
			CoviMap fileQueryParam = new CoviMap();
			fileQueryParam.put("MessageID", formInstID);
			fileQueryParam.put("ServiceType", "Approval");
			CoviMap fileListObj = fileUtilService.selectAttachFileAll(fileQueryParam);
			attachFileList = fileListObj.getJSONArray("list");
			for(int i = 0; attachFileList != null && i < attachFileList.size(); i++) {
				CoviMap fileInfo = new CoviMap();
				
				
				// FileID,StorageID,ServiceType,ObjectID,ObjectType,MessageID,Version,SaveType,LastSeq,Seq,FilePath,FileName,SavedName,Extention,Size,ThumWidth,ThumHeight,Description,RegistDate,RegisterCode
				
				String fileId = attachFileList.getJSONObject(i).getString("FileID");
				String filePath = attachFileList.getJSONObject(i).getString("FilePath");
				String savedName = attachFileList.getJSONObject(i).getString("SavedName");
				String fileCompanyCode = attachFileList.getJSONObject(i).getString("CompanyCode");
				// filePath : Full path.
				//String APPV_SAVE_PATH = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + RedisDataUtil.getBaseConfig("ApprovalAttach_SavePath");
				//String fullPath = APPV_SAVE_PATH + filePath + savedName;
				String APPV_SAVE_PATH = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + attachFileList.getJSONObject(i).getString("StorageFilePath").replace("{0}", companyCode) ;
				String fullPath = APPV_SAVE_PATH + filePath + savedName;
				String fileName = attachFileList.getJSONObject(i).getString("FileName");
				String fileSize = attachFileList.getJSONObject(i).getString("Size");
				
				fileInfo.put("DOC_MNGE_CARD_ID", formInstID);
				fileInfo.put("FILE_SE_CD", "첨부");
				fileInfo.put("FILE_ID", fileId);
				fileInfo.put("FILE_NM", fileName);
				fileInfo.put("FILE_MG", fileSize);
				fileInfo.put("FILE_ORDR", i);
				fileInfo.put("FILE_OPP_YN", fileOppYn);
				fileInfo.put("FILE_PATH", fullPath);
				fileList.add(fileInfo);
			}
			// Complete PDF Convert.
			coviMapperOne.delete("user.govDoc.openDoc.deleteGovOpenDocFiles", param);
			for(int i = 0; fileList != null && i < fileList.size(); i++) {
				coviMapperOne.insert("user.govDoc.openDoc.insertGovOpenDocFiles", fileList.get(i));
			}
			
			param.put("STATE", ApprovalGovDocSvc.OPENDOC_STATE_CONVCOMPLETE);
			coviMapperOne.update("user.govDoc.openDoc.updateState", param);
		}catch(NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			param.put("DOC_MNGE_CARD_ID", formInstID);
			param.put("STATE", ApprovalGovDocSvc.OPENDOC_STATE_CONVERROR);//Error
			
			String resultMsg = ExceptionUtils.getStackTrace(npE);
			param.put("RESULTMSG", resultMsg);//Error
			coviMapperOne.update("user.govDoc.openDoc.updateState", param);
		}catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			param.put("DOC_MNGE_CARD_ID", formInstID);
			param.put("STATE", ApprovalGovDocSvc.OPENDOC_STATE_CONVERROR);//Error
			
			String resultMsg = ExceptionUtils.getStackTrace(e);
			param.put("RESULTMSG", resultMsg);//Error
			coviMapperOne.update("user.govDoc.openDoc.updateState", param);
		}finally {
			ThreadContext.clearMap();
		}
	}

}