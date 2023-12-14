package egovframework.coviaccount.interfaceUtil;

import java.io.UnsupportedEncodingException;
import java.lang.invoke.MethodHandles;
import java.lang.reflect.Method;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviframework.util.HttpClientUtil;



@Component("InterFaceSAPOdata")
public class InterFaceSAPOdata {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	public CoviMap getInterFaceSAPOdata(CoviMap param){
		CoviMap rtObject		= new CoviMap();
		try{
			
			//String auth = RedisDataUtil.getBaseConfig("SAPOdataAuthID").toString() + ":" +RedisDataUtil.getBaseConfig("SAPOdataAuthPWD").toString();
			String auth = accountUtil.getPropertyInfo("account.sapodata.AuthID") + ":" + accountUtil.getPropertyInfo("account.sapodata.AuthPWD");
			
			byte[] encodedAuth = Base64.encodeBase64(auth.getBytes(StandardCharsets.ISO_8859_1));
			String authHeader = "Basic " + new String(encodedAuth, StandardCharsets.UTF_8);
			
			String url = makeAPIURL(param);
			
			ArrayList returnList = callSAPOdata(url,authHeader,param);
			
			rtObject.put("IfCnt",	returnList.size());
			rtObject.put("list",	returnList);
			rtObject.put("status",	Return.SUCCESS);
		} catch (NullPointerException e) {
			rtObject.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		 catch (Exception e) {
			rtObject.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return rtObject;
	}
	
	public CoviMap setInterFaceSAPOdata(CoviMap param){
		CoviMap rtObject		= new CoviMap();
		try{

			String auth = accountUtil.getPropertyInfo("account.sapodata.UniTAXAuthID") + ":" + accountUtil.getPropertyInfo("account.sapodata.UniTAXAuthPWD");
			
			byte[] encodedAuth = Base64.encodeBase64(auth.getBytes(StandardCharsets.ISO_8859_1));
			String authHeader = "Basic " + new String(encodedAuth, StandardCharsets.UTF_8);
			
			String url = makeAPIURL(param);
			
			ArrayList returnList = callSAPOdata(url,authHeader,param);
			
			rtObject.put("IfCnt",	returnList.size());
			rtObject.put("list",	returnList);
			rtObject.put("status",	Return.SUCCESS);
		} catch (NullPointerException e) {
			rtObject.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtObject.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return rtObject;
	}
	
	private ArrayList callSAPOdata(String url, String authHeader, CoviMap param){
		ArrayList returnList = new ArrayList(); 
		CoviMap result = new CoviMap();
		String chkStr = "";
		try {
			
			String daoClassName			= accountUtil.getPropertyInfo("account.interface.dao")	+ rtString(param.get("daoClassName"));
			String voClassName			= accountUtil.getPropertyInfo("account.interface.vo")	+ rtString(param.get("voClassName"));
			String mapClassName			= accountUtil.getPropertyInfo("account.interface.map")	+ rtString(param.get("mapClassName"));
			String daoSetFunctionName	= rtString(param.get("daoSetFunctionName"));
			String daoGetFunctionName	= rtString(param.get("daoGetFunctionName"));
			String voFunctionName		= rtString(param.get("voFunctionName"));
			String mapFunctionName		= rtString(param.get("mapFunctionName"));
			String type = rtString(param.get("type"));
					
			HttpClientUtil httpClient = new HttpClientUtil();
			
			if(type.equals("get") || type.equals("")) {
				ArrayList rtList	= new ArrayList();
				
				Class	mapCls	= Class.forName(mapClassName);
				Object	mapObj	= mapCls.newInstance();
				Method	mapMth	= mapCls.getMethod(mapFunctionName);
				CoviMap map		= (CoviMap) mapMth.invoke(mapObj);
				
				Class[]	voTyp	= new Class[] {CoviMap.class};
				Class	voCls	= Class.forName(voClassName);
				Method	voMth	= voCls.getMethod(voFunctionName,voTyp);
				
				Class[]	daoTyp	= new Class[] {ArrayList.class};
				Class	daoCls	= Class.forName(daoClassName);
				Object	daoObj	= daoCls.newInstance();
				Method	daoSetMth	= daoCls.getMethod(daoSetFunctionName, daoTyp);
				Method	daoGetMth	= daoCls.getMethod(daoGetFunctionName);
				result = httpClient.httpRestAPIConnect(url, "", "GET", "", authHeader);
				
				if(result.get("body") == null){ //Error
					return returnList;
				} else {
					result = (CoviMap)result.get("body");
				}
				
				if(result.get("error") != null) { //Fail
					
				} else if(result.get("d") != null) { //Success
					result = result.getJSONObject("d");
					if(result.get("results") != null) {
						CoviList resultlist = (CoviList)result.get("results");
						for(Object resultobject : resultlist){								
							CoviMap resultJObject = (CoviMap) resultobject;
							Map<String, Object> allMap = resultJObject;	
							CoviMap addObj	= new CoviMap();
							Object	voObj	= voCls.newInstance();			
							
							for(String mapKey : allMap.keySet()){
								if(map.containsKey(mapKey)){
									String val = rtString(resultJObject.get(mapKey));
									String key = rtString(map.get(mapKey));
									addObj.put(key, val);
								}				
							}
							voMth.invoke(voObj, addObj);
							rtList.add(voObj);
						}
						daoSetMth.invoke(daoObj, rtList);					
						returnList = (ArrayList) daoGetMth.invoke(daoObj);
					}
				}
			} else if(type.equals("set")) {
				String getParam = param.get("SAPOdataParam").toString();
				result = httpClient.httpRestAPIConnect(url, "json", "PATCH", getParam, authHeader);
			}
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return returnList;
	}
	
	private String makeAPIURL(CoviMap param){
		//String url = RedisDataUtil.getBaseConfig("SAPOdataAPIURL").toString();
		String url = accountUtil.getPropertyInfo("account.sapodata.APIURL");
		String getMethod = param.get("SAPOdataFuntionName").toString();
		String getParam = param.get("SAPOdataParam").toString();
		String type = rtString(param.get("type"));
		try {
			//phm
			if(type.equals("get") || type.equals("")) {
				url = url + "/" + getMethod + "?$format=json&$filter="+URLEncoder.encode(getParam, "UTF-8");
			} else if(type.equals("set")) { //전자세금계산서 추가 인터페이스 연동 (코비젼 -> 보령)
				// url: 		https://cedg280588ed.jp1.hana.ondemand.com:443
				// getMethod: 	UniTAX/Service/ZDTV3T_AP.xsodata/AP_HEAD(BUKRS='4310',BUPLA='1000',ISSUE_DATE='20181218',INV_SEQ='1800000000')
				url = accountUtil.getPropertyInfo("account.sapodata.UniTAXURL");
				url = url + "/" + getMethod; 
			}
			url = url.replaceAll("\\+", "%20")
			.replaceAll("\\%21", "!")
			.replaceAll("\\%27", "'")
			.replaceAll("\\%28", "(")
			.replaceAll("\\%29", ")")
			.replaceAll("\\%7E", "~");
		} catch (UnsupportedEncodingException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return url;
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().replace("{", "").replace("}", "").trim();
		return rtStr;
	}
}
