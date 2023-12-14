package egovframework.covision.coviflow.xform.service.impl;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;
import egovframework.covision.coviflow.common.util.ApprovalUtil;
import egovframework.covision.coviflow.form.web.ApvProcessCon;
import egovframework.covision.coviflow.xform.service.XFormEditorSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("xformEditorService")
public class XFormEditorSvcImpl extends EgovAbstractServiceImpl implements XFormEditorSvc{
	
	private static final Logger LOGGER = LogManager.getLogger(ApvProcessCon.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	AwsS3 awsS3 = AwsS3.getInstance();
	
	@Override
	public String getHTMLFormFile(String fileName, String formCompanyCode) throws Exception {
		String resultStr = "";
		StringBuffer tempStr = new StringBuffer();
		String filePath = ApprovalUtil.getTemplatePath(formCompanyCode) + fileName;
		
		//파일 존재여부 체크
		if(!fileUtilSvc.fileIsExistsBoolean(filePath)){ //if(!checkFileExist(fileName, formCompanyCode)){
			return "ERROR";
		}
		BufferedReader br = null;
		FileInputStream fis = null;
		try{
			if(awsS3.getS3Active()) {
				String s3key = filePath;
				AwsS3Data s3Data = awsS3.downData(s3key);
				br = new BufferedReader(new InputStreamReader(s3Data.getContentStream(), StandardCharsets.UTF_8));
			}else {
				fis = new FileInputStream(filePath);
				br = new BufferedReader(new InputStreamReader(fis, StandardCharsets.UTF_8));
			}
			
			String str = null;
			while((str=br.readLine())!=null){
				if (str.indexOf("window.onload") > -1 || str.indexOf("progress.js") > -1) {
				} else {
					if (str.indexOf("setFields") > -1 && str.indexOf("n setFields") == -1) {
						str = str.replace(" ", "").replace(":dField)",":menu.dField)");
						str = str.replace(" ", "").replace(":cField)",":menu.cField)");
					} else if (str.indexOf("\"btLine\"") > -1) {
						str = str.replace("\"btLine\"", "\"btLineForm\"");
					} else if (str.indexOf("\"btRecDept\"") > -1) {
						str = str.replace("\"btRecDept\"", "\"btRecDeptForm\"");
					} else if (str.indexOf("\"btCc\"") > -1) {
						str = str.replace("\"btCc\"", "\"btCcForm\"");
					}
					tempStr.append(str + "\r\n");
				}
			}
			resultStr = tempStr.toString().trim();
			
		} catch(IOException ioE){
			resultStr = "ERROR";
		} catch(Exception e){
			resultStr = "ERROR";
		} finally {
			if(br != null) {
				try {
					br.close();
				} catch (IOException e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}catch (Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			if(fis != null) {
				try {
					fis.close();
				} catch (IOException e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}catch (Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}
		
		return resultStr;
	}

	@Override
	public String getJSFormFile(String fileName, String formCompanyCode) throws Exception {
		String resultStr = "";
		StringBuffer tempStr = new StringBuffer();
		String filePath = ApprovalUtil.getTemplatePath(formCompanyCode) + fileName;
		
		//파일 존재여부 체크
		if(!fileUtilSvc.fileIsExistsBoolean(filePath)){
			return "ERROR";
		}
		BufferedReader br = null;
		FileInputStream fis = null;
		try{
			if(awsS3.getS3Active()) {
				String s3key = filePath;
				AwsS3Data s3Data = awsS3.downData(s3key);
				br = new BufferedReader(new InputStreamReader(s3Data.getContentStream(), StandardCharsets.UTF_8));
			}else {
				fis = new FileInputStream(filePath);
				br = new BufferedReader(new InputStreamReader(fis, StandardCharsets.UTF_8));
			}
			
			String str = null;
			
			while((str=br.readLine())!=null){
				tempStr.append(str + "\r\n");
			}
			
			resultStr = tempStr.toString().trim();
			
		}catch(IOException ioE){
			resultStr = "ERROR";
		}catch(Exception e){
			resultStr = "ERROR";
		}finally {
			if(br != null) {
				try{
					br.close();
				} catch(NullPointerException npE){ 
					LOGGER.error("XFormEditorSvcImpl.getJSFormFile", npE); 
				} catch(Exception ex){ 
					LOGGER.error("XFormEditorSvcImpl.getJSFormFile", ex); 
					}
			}
			if(fis != null) {
				try {
					fis.close();
				} catch (IOException e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}catch (Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}
		
		return resultStr;
	}

	@Override
	public CoviMap selectFormList(Map<String, String> paramMap) throws Exception {
		CoviMap resultList = new CoviMap(); //resultList: 함수 결과 값 (return 값)
		CoviList usableList = new CoviList(); //usableList: Form 목록 중 실제 파일이 존재하는 목록
		
		CoviList list = coviMapperOne.list("xform.xformEditor.selectFormList", new CoviMap(paramMap));
		//allFormList: 전체 Form 목록(실제 파일 존재 여부 확인 X, 단순히 JWF_Forms 목록 조회)
		CoviList allFormList = CoviSelectSet.coviSelectJSON(list);
		
		@SuppressWarnings("unchecked")
		Iterator<CoviMap> it = allFormList.iterator();
		
		while(it.hasNext()){
		   CoviMap obj = (CoviMap)it.next();
		  
		   String filePath = ApprovalUtil.getTemplatePath(obj.getString("CompanyCode")) + obj.getString("FileName");
		   if( fileUtilSvc.fileIsExistsBoolean(filePath) ){
			   usableList.add(obj);
		   }
		}
		
		resultList.put("list", usableList);
		
		return resultList;
	}
	
	/*
	public boolean checkFileExist(String fileName, String formCompanyCode) throws Exception{
		
		File templatefile =new File(getTemplatePath(formCompanyCode)+fileName);
		
		return templatefile.exists();
	}
	*/

	@Override
	public String createHTMLFormFile(String htmlFileName, String htmlFileContent, String formCompanyCode, String formDomainID) throws Exception {
		String resultStr = "";
		String filePath = ApprovalUtil.getTemplatePath(formCompanyCode) + htmlFileName;
		
		//파일 존재여부 체크
		if(!fileUtilSvc.fileIsExistsBoolean(filePath)){
			return "ERROR";
		}
		
		BufferedWriter bw = null;
		try{
			// Redis 데이터 업데이트하기 위해서 삭제
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			
			
			String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
			String formTemplateKeySuffix = "_formTemplate_"+ htmlFileName;
			if("Y".equals(isSaaS) && !StringUtil.isEmpty(formDomainID)) {
				formTemplateKeySuffix = "_formTemplate" + formDomainID + "_" + htmlFileName;
			}
			
			//instance.remove("ko_formTemplate_"+htmlFileName);
			//instance.remove("en_formTemplate_"+htmlFileName);
			//instance.remove("ja_formTemplate_"+htmlFileName);
			//instance.remove("zh_formTemplate_"+htmlFileName);
			instance.remove("ko"+formTemplateKeySuffix);
			instance.remove("en"+formTemplateKeySuffix);
			instance.remove("ja"+formTemplateKeySuffix);
			instance.remove("zh"+formTemplateKeySuffix);
			
			if(awsS3.getS3Active()) {
				byte[] htmlBytes = changeSpecialCharacter(htmlFileContent).getBytes("UTF8");
				try(InputStream is = new ByteArrayInputStream(htmlBytes)){
					awsS3.upload(is, filePath, "text/html", htmlBytes.length);
				}
			}else {
				bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(filePath), "UTF8"));
				bw.write(changeSpecialCharacter(htmlFileContent));
			}
			
			resultStr = "ok";
		}catch(IOException ioE){
			resultStr = "ERROR";
		}catch(Exception e){
			resultStr = "ERROR";
		}finally {
			if(bw != null) {
				try{
					bw.close();
				} catch(NullPointerException npE){
					LOGGER.error("XFormEditorSvcImpl.createHTMLFormFile", npE); 
				} catch(Exception ex){ 
					LOGGER.error("XFormEditorSvcImpl.createHTMLFormFile", ex); 
				}
			}
		}
		
		return resultStr;
	}

	@Override
	public String createJSFormFile(String jsFileName, String jsFileContent, String formCompanyCode, String formDomainID) throws Exception {
		String resultStr = "";
		String filePath = ApprovalUtil.getTemplatePath(formCompanyCode) + jsFileName;
		
		//파일 존재여부 체크
		if(!fileUtilSvc.fileIsExistsBoolean(filePath)){
			return "ERROR";
		}
		
		BufferedWriter bw = null;
		try{
			// Redis 데이터 업데이트하기 위해서 삭제
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			
			String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
			String formTemplateKeySuffix = "_formTemplate_"+ jsFileName;
			if("Y".equals(isSaaS) && !StringUtil.isEmpty(formDomainID)) {
				formTemplateKeySuffix = "_formTemplate" + formDomainID + "_" + jsFileName;
			}
			
//			instance.remove("ko_formTemplate_"+jsFileName);
//			instance.remove("en_formTemplate_"+jsFileName);
//			instance.remove("ja_formTemplate_"+jsFileName);
//			instance.remove("zh_formTemplate_"+jsFileName);
			instance.remove("ko"+formTemplateKeySuffix);
			instance.remove("en"+formTemplateKeySuffix);
			instance.remove("ja"+formTemplateKeySuffix);
			instance.remove("zh"+formTemplateKeySuffix);
			
			if(awsS3.getS3Active()) {
				byte[] jsBytes = changeSpecialCharacter(jsFileContent).getBytes("UTF8");
				try(InputStream is = new ByteArrayInputStream(jsBytes)){
					awsS3.upload(is, filePath, "text/html", jsBytes.length);
				}
			}else {
				bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(filePath), "UTF8"));
				bw.write(changeSpecialCharacter(jsFileContent));
			}
			
			resultStr = "ok";
		}catch(IOException ioE){
			resultStr = "ERROR";
		}catch(Exception e){
			resultStr = "ERROR";
		}finally {
			if(bw != null) {
				try{
					bw.close();
				} catch(NullPointerException ex){ 
					LOGGER.error("XFormEditorSvcImpl.createJSFormFile", ex); 
				} catch(Exception ex){ 
					LOGGER.error("XFormEditorSvcImpl.createJSFormFile", ex); 
				}
			}
		}
		
		return resultStr;
	}
	
	//JSON 형식으로 넘어올 경우 특수문자 처리 
	public String changeSpecialCharacter(String content) throws Exception {
		if(content == null)
			return null;
		
		String returnStr = content;
		//returnStr = returnStr.replaceAll("&#34;", "");
		//returnStr = returnStr.replaceAll("\"", "");
		returnStr = returnStr.replaceAll("&quot;", "\"");
		returnStr = returnStr.replaceAll("&apos;", "'");
		returnStr = returnStr.replaceAll("&gt;", ">");
		returnStr = returnStr.replaceAll("&lt;", "<");
		returnStr = returnStr.replaceAll("&nbsp;", " ");
		returnStr = returnStr.replaceAll("&amp;", "&");
		//returnStr = returnStr.replaceAll("<br>", "\n");
		
		return returnStr;
	}

	//운영체제에 따른 양식 템플릿 저장 경로 return 
	/*
	public String getTemplatePath(String formCompanyCode) throws Exception {
		String path ="";
		if(OS.indexOf("win")>=0){
			path = PropertiesUtil.getGlobalProperties().getProperty("templateWINDOW.path");
			path = path.replace("/", File.separator);
		}else if(OS.indexOf("nix")>=0 || OS.indexOf("nux")>=0 || OS.indexOf("aix")>=0){
			path = PropertiesUtil.getGlobalProperties().getProperty("templateUNIX.path");
		}
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
		String templateBasePath = StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("isSaaStemplateForm.Path"),"");
		
		if( isSaaS.equals("Y") && templateBasePath.indexOf("{0}") > 0 ) {
			path = templateBasePath.replace("{0}", formCompanyCode);
		}
		return path.trim();
	}
	*/
	
	@Override
	public String setTemplate(String mode, CoviMap params) throws Exception {
		String resultStr ="";
		CoviMap resultList = new CoviMap();
		
		
		/**
		 * mode: 자주 사용하는 template 작업 구분 값
		 * LIST : 템플릿 전체 목록 조회
		 * SELECT : 특정 템플릿의 html 내용 조회
		 * SAVE : 템플릿 저장
		 * DELETE : 템플릿 삭제	
		**/
		
		params.put("templateHTML",changeSpecialCharacter(params.getString("templateHTML"))); //templateHTML 특수문자 변환
		
		try{
			if(mode.equals("LIST")){
				
				CoviList list = coviMapperOne.list("xform.xformEditor.selectTemplateList", params);
				resultList.put("Table", CoviSelectSet.coviSelectJSON(list, "TemplateID,TemplateName"));
				resultStr = resultList.toString();
				
			}else if(mode.equals("SELECT")){
				
				CoviMap map = coviMapperOne.select("xform.xformEditor.selectTemplateData", params);
				resultList.put("Table", CoviSelectSet.coviSelectJSON(map, "TemplateID,TemplateName,TemplateHTML"));
				resultStr = map.getString("TemplateHTML");
				
			}else if(mode.equals("SAVE")){
				
				coviMapperOne.insert("xform.xformEditor.insertTemplateData",params);
				resultStr = "OK";
				
			}else if(mode.equals("DELETE")){
				
				coviMapperOne.insert("xform.xformEditor.deleteTemplateData",params);
				resultStr = "OK";
				
			}
			
		}catch(NullPointerException npE){
			resultStr = "ERROR";
			LOGGER.error("XFormEditorSvcImpl", npE);
		}catch(Exception e){
			resultStr = "ERROR";
			LOGGER.error("XFormEditorSvcImpl", e);
		}
		
		return resultStr;
	}

	@Override
	public String getEncrypt(String encryptStr) throws Exception {
		String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
		return new AES(aeskey, "N").encrypt(changeSpecialCharacter(encryptStr));
	}

}
