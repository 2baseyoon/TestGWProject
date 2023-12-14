package egovframework.coviaccount.interfaceUtil;

import java.lang.invoke.MethodHandles;
import java.util.ArrayList;
import java.util.Map.Entry;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;

@Component("InterfaceUtil")
public class InterfaceUtil  {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

	@Autowired
	private InterFaceDB interFaceDB;

	@Autowired
	private InterFaceSOAP interFaceSOAP;
	
	@Autowired
	private InterFaceSAP interFaceSAP;
	
	@Autowired
	private InterFaceSAPOdata interFaceSAPOdata;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private InterfaceSaveLog interfaceSaveLog;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	public CoviMap startInterface(CoviMap param){
		CoviMap rtObject	= new CoviMap();
		CoviMap logInfo		= new CoviMap();
		
		logInfo.put("CompanyCode",	"");
		logInfo.put("ifTargetType",	"");	//인터페이스대상종류
		logInfo.put("ifMethodName",	"");	//인터페이스 메소드명
		logInfo.put("ifRecvType",	"");	//인터페이스 전송방향(S:전송, R:수신)
		logInfo.put("ifType",		"");	//인터페이스 방식 종류(DB, SOAP, SAP)
		logInfo.put("ifCnt",		"");	//인터페이스 처리 건수
		logInfo.put("ifStatus",		"");	//인터페이스 상태(S:성공, F:실패)
		logInfo.put("errorLog",		"");	//에러로그
		
		try {
			String companyCode 		= rtString(param.get("CompanyCode"));
			String interFaceType	= rtString(param.get("interFaceType"));
			String daoClassName		= rtString(param.get("daoClassName"));
			String type 			= rtString(param.get("type"));
			
			logInfo.put("CompanyCode",	companyCode);
			logInfo.put("ifTargetType",	daoClassName);
			logInfo.put("ifType",		interFaceType);
			
			switch (interFaceType) {
				case "DB":
					/**	type : value
					 * 	get/set
					 */
					logInfo.put("ifMethodName",	"TYPE DB");
					
					if(type.equals("get")){
						logInfo.put("ifRecvType",	"R");
						rtObject = interFaceDB.getInterFaceDB(param);
						
					}else if(type.equals("set")){
						logInfo.put("ifRecvType",	"S");
						rtObject = interFaceDB.setInterFaceDB(param);
						
					}else{
						rtObject.put("errorLog",	"DB Type Value null");
						rtObject.put("status",		Return.FAIL);
					}
					
					break;
	
				case "SOAP":
					logInfo.put("ifRecvType",	"R");
					logInfo.put("ifMethodName",	rtString(param.get("soapName")));
					rtObject	= interFaceSOAP.getInterFaceSOAP(param);
					break;
					
				case "SAP":
					logInfo.put("ifRecvType",	"R");
					logInfo.put("ifMethodName",	rtString(param.get("sapFunctionName")));
					rtObject = interFaceSAP.interFaceSAP(param);
					break;
					
				case "SAPOdata":
					if(type.equals("get")|| type.equals("")){
						logInfo.put("ifRecvType",	"R");
						logInfo.put("ifMethodName",	rtString(param.get("SAPOdataFuntionName")));
						rtObject = interFaceSAPOdata.getInterFaceSAPOdata(param);
						
					}else if(type.equals("set")){
						logInfo.put("ifRecvType",	"S");
						logInfo.put("ifMethodName",	rtString(param.get("SAPOdataFuntionName")));
						rtObject = interFaceSAPOdata.setInterFaceSAPOdata(param);
						
					}
					break;
					
				default:
					rtObject.put("errorLog",	"InterFace Type Value null");
					rtObject.put("status",	Return.FAIL);
					break;
			}
			
		} catch (NullPointerException e) {
			rtObject.put("errorLog",	"Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
			rtObject.put("status",		Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			rtObject.put("errorLog",	"Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
			rtObject.put("status",		Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}finally{
			logInfo.put("ifStatus",	rtIfStatus(rtObject.get("status")));
			logInfo.put("errorLog",	rtString(rtObject.get("errorLog")));
			logInfo.put("ifCnt",	rtNumber(rtObject.get("IfCnt")));
			rtObject.put("list",	rtArrayList(rtObject.get("list")));
			
			interfaceSaveLog.saveAccountInterFaceLog(logInfo);
		}
		
		return rtObject;
	}
	
	private String rtIfStatus(Object obj){
		String rtStr	= "";
		String strFAIL	= Return.FAIL.toString();
		if(rtString(obj).equals(strFAIL)){
			rtStr = "F";
		}else{
			rtStr = "S";
		}
		return rtStr;
	}
	
	private ArrayList rtArrayList(Object obj){
		ArrayList list = null;
		list = obj == null ? new ArrayList() : (ArrayList) obj;
		return list;
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
	
	private int rtNumber(Object obj){
		int rtInt = 0;
		try {
			rtInt = Integer.parseInt(obj.toString().trim());
		} catch (NullPointerException e) {
			rtInt = 0;
		} catch (Exception e) {
			rtInt = 0;
		}
		return rtInt;
	}
	private String getDomainId(String companyCode) {
		CoviMap params = new CoviMap();
		params.put("CompanyCode", companyCode);
		CoviMap map = coviMapperOne.selectOne("baseCode.selectDomainCheck", params);
		if(map != null) {
			return map.getString("DomainID");
		}
		return "";
	}
	
	// [SaaS]
	public void setDomainInfo(java.util.Map<String, String> paramMap, CoviMap params) {
		for(Entry<String, String> entry : paramMap.entrySet()) {
			params.put(entry.getKey(), entry.getValue());
		}
		
		String companyCode = "";
		boolean isSaaS = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N"));
		
		// query from session.
		String sessionUserId = SessionHelper.getSession("UR_Code");
		if(!StringUtils.isEmpty(sessionUserId)) {
			// 사용자 호출시. parameter 에 선택한 회사코드(CompanyCode,eAccounting Code) 가 들어있음.
			companyCode = params.getString("CompanyCode");
			String domainId = getDomainId(companyCode);
			if(domainId.equals("")) companyCode = ""; // companycode를 ${CompanyCodePrefix}로 이용하므로 유효성 체크
			params.put("DN_ID", domainId);
			params.put("CompanyCode", companyCode);
		} else {
			// 스케쥴러 호출시. 도메인단위로 호출되며, 해당도메인 내 회사코드(CompanyCode,eAccounting Code)만큼 처리
			String domainId = params.getString("DN_ID"); // Scheduler 에서 넘어오는 Parameters : DN_ID, DN_Code.
			companyCode = params.getString("DN_Code"); 
			String tmpDomainId = getDomainId(companyCode);
			if(tmpDomainId.equals("")) companyCode = ""; // companycode를 ${CompanyCodePrefix}로 이용하므로 유효성 체크
			params.put("DN_ID", domainId); 
			params.put("CompanyCode", companyCode);
		}
		
		if(!StringUtils.isEmpty(companyCode) && isSaaS) {
			params.put("CompanyCodePrefix", ComUtils.RemoveSQLInjection(companyCode, 100) + "_");
		}
	}
	
	public static void setCurrentRequestAttr(String key, Object value) {
	    ServletRequestAttributes requestAttr = (ServletRequestAttributes)RequestContextHolder.getRequestAttributes();
	    if(requestAttr != null) {
	    	HttpServletRequest request = requestAttr.getRequest();
	    	request.setAttribute(key, value);
	    }
	}
	public static Object getCurrentRequestAttr(String key) {
	    ServletRequestAttributes requestAttr = (ServletRequestAttributes)RequestContextHolder.getRequestAttributes();
	    if(requestAttr != null) {
	    	HttpServletRequest request = requestAttr.getRequest();
	    	return request.getAttribute(key);
	    }
	    return null;
	}
}
