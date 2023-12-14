package egovframework.covision.coviflow.xform.service.impl;

import java.util.Iterator;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.covision.coviflow.xform.service.XFormEditorWebServiceSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("xformEditorWebServiceService")
public class XFormEditorWebServiceSvcImpl extends EgovAbstractServiceImpl implements XFormEditorWebServiceSvc{
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectMethodList(String connectStr) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		HttpURLConnectUtil url = new HttpURLConnectUtil();
		
		resultList = url.httpXFormConnect(connectStr,"POST");
		
		returnList.put("Method", resultList.get("Method"));
		
		return returnList;
	}
	
	@Override
	public CoviMap selectParamList(String connectStr, String tableName) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		HttpURLConnectUtil url = new HttpURLConnectUtil();
		
		resultList = url.httpXFormConnect(connectStr,"POST");
		
        CoviList paramList = CoviList.fromObject(resultList.getString("Param"));
        
        CoviList usableList = new CoviList();
        
        @SuppressWarnings("unchecked")
		Iterator<CoviMap> it = paramList.iterator();
		
		while(it.hasNext()){
		   CoviMap obj = (CoviMap)it.next();
		  
		   if(obj.optString("TABLE").equals(tableName)){
			   usableList.add(obj);
		   }
		}
		
        returnList.put("Param", usableList);
		
        return returnList;
	}
	
	
	public String decrypt(String str) throws Exception{
		String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
		return new AES(aeskey, "N").decrypt(str);
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
}
