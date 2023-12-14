package egovframework.coviaccount.interfaceUtil;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.invoke.MethodHandles;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoDestinationManager;
import com.sap.conn.jco.JCoException;
import com.sap.conn.jco.JCoFunction;
import com.sap.conn.jco.JCoTable;
import com.sap.conn.jco.ext.DestinationDataProvider;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviaccount.common.util.AccountUtil;

@Component("InterFaceSAP")
public class InterFaceSAP {

	private static final Logger LOGGER = LogManager.getLogger(InterFaceSAP.class);

	@Autowired
	private AccountUtil accountUtil;
	
	static CoviMap Obj	= new CoviMap();
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	public CoviMap interFaceSAP(CoviMap param){
		CoviMap rtObject		= new CoviMap();
		try{
			Properties connectProperties = new Properties();
			String ccfn		= accountUtil.getPropertyInfo("account.sap.connectionFileName");
			String ashost	= accountUtil.getPropertyInfo("account.sap.JCO_ASHOST");
			String sysnr	= accountUtil.getPropertyInfo("account.sap.JCO_SYSNR");
			String client	= accountUtil.getPropertyInfo("account.sap.JCO_CLIENT");
			String user		= accountUtil.getPropertyInfo("account.sap.JCO_USER");
			String passwd	= accountUtil.getPropertyInfo("account.sap.JCO_PASSWD");
			passwd = PropertiesUtil.getDecryptedProperty(passwd);
			String lang		= accountUtil.getPropertyInfo("account.sap.JCO_LANG");
			
			connectProperties.setProperty(DestinationDataProvider.JCO_ASHOST,	ashost);	// SAP 호스트 정보
			connectProperties.setProperty(DestinationDataProvider.JCO_SYSNR,	sysnr);		// 인스턴스번호
			connectProperties.setProperty(DestinationDataProvider.JCO_CLIENT,	client);	// SAP 클라이언트
			connectProperties.setProperty(DestinationDataProvider.JCO_USER,		user);		// SAP 유접명
			connectProperties.setProperty(DestinationDataProvider.JCO_PASSWD,	passwd);	// SAP 패스워드
			connectProperties.setProperty(DestinationDataProvider.JCO_LANG,		lang);		// 언어
			
			createDestinationDataFile(ccfn, connectProperties);
			
			rtObject = getTable(param);
			
		} catch (NullPointerException e) {
			Obj.put("errorLog",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			Obj.put("status",	Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			Obj.put("errorLog",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			Obj.put("status",	Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}finally{
			rtObject.put("errorLog",	rtString(Obj.get("errorLog")));
			rtObject.put("status",		rtString(Obj.get("status")));
		}
		return rtObject;
	}
	
	static void createDestinationDataFile(String destinationName, Properties connectProperties){
		File destCfg = new File(destinationName + ".JcoDestination");
		if(!destCfg.exists()){
			FileOutputStream fos = null; 
			try {
				fos = new FileOutputStream(destCfg,false);
				connectProperties.store(fos, "for test Only");
			} catch (IOException e) {
				throw new RuntimeException("Unable to create the destination files",e);
			} catch (Exception e) {
				throw new RuntimeException("Unable to create the destination files",e);
			} finally {
				if(fos != null) {
					try {
						fos.close();
					} catch (IOException e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
			}
		}
	}
	
	public CoviMap getTable(CoviMap params) throws JCoException{
		
		CoviMap rtObject		= new CoviMap();
		try {
			String ccfn					= accountUtil.getPropertyInfo("account.sap.connectionFileName");
			String daoClassName			= accountUtil.getPropertyInfo("account.interface.dao")	+ rtString(params.get("daoClassName"));
			String voClassName			= accountUtil.getPropertyInfo("account.interface.vo")	+ rtString(params.get("voClassName"));
			String mapClassName			= accountUtil.getPropertyInfo("account.interface.map")	+ rtString(params.get("mapClassName"));
			String daoSetFunctionName	= rtString(params.get("daoSetFunctionName"));
			String daoGetFunctionName	= rtString(params.get("daoGetFunctionName"));
			String voFunctionName		= rtString(params.get("voFunctionName"));
			String mapFunctionName		= rtString(params.get("mapFunctionName"));
			
			Class	mapCls		= Class.forName(mapClassName);
			Object	mapObj		= mapCls.newInstance();
			Method	mapMth		= mapCls.getMethod(mapFunctionName);
			CoviMap map			= (CoviMap) mapMth.invoke(mapObj);
			
			Class[]	daoTyp		= new Class[] {ArrayList.class};
			Class	daoCls		= Class.forName(daoClassName);
			Object	daoObj		= daoCls.newInstance();
			Method	daoSetMth	= daoCls.getMethod(daoSetFunctionName, daoTyp);
			Method	daoGetMth	= daoCls.getMethod(daoGetFunctionName);
			
			String tableName		= rtString(params.get("tableName"));
			String sapFunctionName	= rtString(params.get("sapFunctionName"));
			
			JCoDestination destination	= JCoDestinationManager.getDestination(ccfn);
			JCoFunction function		= destination.getRepository().getFunction(sapFunctionName);

			//setValue
			Map<String,Object> setValues = (Map<String, Object>) params.get("setValues");
			for(Map.Entry<String,Object> entry : setValues.entrySet()){
				String key = entry.getKey();
				String val = rtString(entry.getValue());
				function.getImportParameterList().setValue(key, val);
			}
			
			if(function == null){
				throw new RuntimeException(sapFunctionName + " not found in SAP");
			}
			
			function.execute(destination);
			
			//getValue
			ArrayList getValueResult	= new ArrayList();
			ArrayList getValues			= (ArrayList) params.get("getValues");
			for(int i=0; i<getValues.size(); i++){
				String val = rtString(getValues.get(i));
				getValueResult.add(function.getExportParameterList().getValue(val));
			}
			
			JCoTable codes = function.getTableParameterList().getTable(tableName);
			
			List list = new ArrayList();
			
			for(int i=0; i<codes.getNumRows(); i++){
				codes.setRow(i);
				CoviMap addObj	= new CoviMap();
				Map<String, Object> allMap = map;
				for(Map.Entry<String, Object> entry : allMap.entrySet()){
					String key = rtString(entry.getValue());
					String val = rtString(codes.getString(entry.getKey()));
					addObj.put(key,val);
				}
				list.add(addObj);
			}
			
			daoSetMth.invoke(daoObj, list);
			ArrayList returnList = (ArrayList) daoGetMth.invoke(daoObj);
			
			rtObject.put("IfCnt",		returnList.size());
			rtObject.put("list",		returnList);
			rtObject.put("getValue",	getValueResult);
			Obj.put("status",			Return.SUCCESS);
			
		} catch (NullPointerException e) {
			Obj.put("errorLog",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			Obj.put("status",	Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			Obj.put("errorLog",	"Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
			Obj.put("status",	Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return rtObject; 
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().replace("{", "").replace("}", "").trim();
		return rtStr;
	}
}
