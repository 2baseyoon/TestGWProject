package egovframework.core.manage.service;


import javax.xml.transform.TransformerException;

import org.w3c.dom.Document;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface ComTableManageSvc {
	public void init() throws Exception;
	
	public CoviMap selectComTableManageList(CoviMap params) throws Exception;
	public CoviMap selectComTableManageData(CoviMap params) throws Exception;
	public int insertComTableManageData(CoviMap params) throws Exception;
	public int updateComTableManageData(CoviMap params) throws Exception;
	public int deleteComTableManageData(CoviMap params) throws Exception;
	public String getComTableQuerySample(String dbVendor) throws Exception;
	public CoviMap execComTableQuery(CoviMap params_config, CoviMap params_query) throws Exception;
	public int updateComTableQuery(CoviMap params) throws Exception;
	public CoviMap selectComTableFieldData(CoviMap params) throws Exception;
	public int insertComTableField(CoviMap params) throws Exception;
	public int updateComTableField(CoviMap params) throws Exception;
	public int deleteComTableField(CoviMap params) throws Exception;
	public int setComTableField(CoviMap params, CoviList fieldList, CoviList oldFieldKey) throws Exception;
	public CoviMap selectComTableList(CoviMap params) throws Exception;
	
	public CoviMap convertQueryAndValidation(String xmldata, String namespace, String dbVendor) throws Exception;
	public String convertDocumentToString(Object doc) throws TransformerException;
	public Document convertStringToDocument(String xmlStr) throws Exception;
	public void putComTableQueryCache(CoviMap params_config) throws Exception;
	public void removeComTableQueryCache(CoviMap params_config) throws Exception;
	public String utf8ToBase64(String strUtf8) throws Exception;
	public CoviList base64ToUtf8(CoviList list, String target) throws Exception;
	public CoviMap base64ToUtf8(CoviMap map, String target) throws Exception;
	public String base64ToUtf8(String strBase64) throws Exception;
}

