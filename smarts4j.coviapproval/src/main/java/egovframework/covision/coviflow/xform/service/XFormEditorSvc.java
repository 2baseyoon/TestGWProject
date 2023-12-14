package egovframework.covision.coviflow.xform.service;

import java.util.Map;

import egovframework.baseframework.data.CoviMap;


public interface XFormEditorSvc {
	public String getHTMLFormFile(String fileName, String formCompanyCode) throws Exception;
	public String getJSFormFile(String fileName, String formCompanyCode) throws Exception;
	public CoviMap selectFormList(Map<String, String> paramMap) throws Exception;
	public String createHTMLFormFile(String htmlFileName, String htmlFileContent, String formCompanyCode, String formDomainID) throws Exception;
	public String createJSFormFile(String jsFileName, String jsFileContent, String formCompanyCode, String formDomainID)throws Exception;
	public String setTemplate(String mode, CoviMap params) throws Exception;
	public String getEncrypt(String encryptStr)throws Exception;
}
