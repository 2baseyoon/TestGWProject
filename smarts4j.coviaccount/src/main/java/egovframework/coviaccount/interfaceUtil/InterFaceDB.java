package egovframework.coviaccount.interfaceUtil;

import java.lang.invoke.MethodHandles;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviaccount.common.util.AccountUtil;

@Component("InterFaceDB")
public class InterFaceDB {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	public CoviMap getInterFaceDB(CoviMap param){
		
		CoviMap rtObject		= new CoviMap();
		try{
			
			String daoClassName			= accountUtil.getPropertyInfo("account.interface.dao")	+ rtString(param.get("daoClassName"));
			String voClassName			= accountUtil.getPropertyInfo("account.interface.vo")	+ rtString(param.get("voClassName"));
			String mapClassName			= accountUtil.getPropertyInfo("account.interface.map")	+ rtString(param.get("mapClassName"));
			String daoSetFunctionName	= rtString(param.get("daoSetFunctionName"));
			String daoGetFunctionName	= rtString(param.get("daoGetFunctionName"));
			String voFunctionName		= rtString(param.get("voFunctionName"));
			String mapFunctionName		= rtString(param.get("mapFunctionName"));
			
			String sqlName		= rtString(param.get("sqlName"));
			String sql			= sqlName;
			
			ArrayList list		= coviMapperOne.list(sql, param);
			ArrayList rtList	= new ArrayList();
			
			Class	mapCls		= Class.forName(mapClassName);
			Object	mapObj		= mapCls.newInstance();
			Method	mapMth		= mapCls.getMethod(mapFunctionName);
			CoviMap map			= (CoviMap) mapMth.invoke(mapObj);
			
			Class[]	voTyp		= new Class[] {CoviMap.class};
			Class	voCls		= Class.forName(voClassName);
			Method	voMth		= voCls.getMethod(voFunctionName,voTyp);
			
			Class[]	daoTyp		= new Class[] {ArrayList.class};
			Class	daoCls		= Class.forName(daoClassName);
			Object	daoObj		= daoCls.newInstance();
			Method	daoSetMth	= daoCls.getMethod(daoSetFunctionName, daoTyp);
			Method	daoGetMth	= daoCls.getMethod(daoGetFunctionName);
			
			for(int i=0; i<list.size(); i++){
				Object	voObj		= voCls.newInstance();
				CoviMap addObj		= new CoviMap();
				CoviMap upperObj	= new CoviMap();
				Map<String, Object> info = (CoviMap) list.get(i);
				
				for(Map.Entry<String, Object> entry : info.entrySet()){
					String allMapKey = rtString(entry.getKey()).toUpperCase();
					String allMapVal = rtString(entry.getValue()).toUpperCase();
					upperObj.put(allMapKey, allMapVal);
				}
				
				Map<String, Object> allMap = map;
				for(Map.Entry<String, Object> entry : allMap.entrySet()){
					String allMapKey = rtString(entry.getKey());
					String allMapVal = rtString(entry.getValue());
					addObj.put(allMapVal, rtString(upperObj.get(allMapKey.toUpperCase())));
				}
				voMth.invoke(voObj, addObj);
				rtList.add(voObj);
			}
			
			daoSetMth.invoke(daoObj, rtList);
			ArrayList returnList = (ArrayList) daoGetMth.invoke(daoObj);
			
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
	
	public CoviMap setInterFaceDB(CoviMap param){
	
		CoviMap rtObject		= new CoviMap();
		
		try{
			int cntInsert	= 0;
			int cntUpdate	= 0;
			int cntDelete	= 0;
			String msg 		= "";
			
			String mapClassName		= accountUtil.getPropertyInfo("account.interface.map") + rtString(param.get("mapClassName"));
			String mapFunctionName	= rtString(param.get("mapFunctionName"));
			
			String cntKeySql		= rtString(param.get("cntKeySql"));
			String insertSql		= rtString(param.get("insertSql"));
			String updateSql		= rtString(param.get("updateSql"));
			String deleteSql		= rtString(param.get("deleteSql"));
			
			List interFaceList				= (List) param.get("interFaceList");
			CoviList interFaceSaveList		= new CoviList();
			CoviList interFaceDeleteList	= new CoviList();
			
			for(int i=0; i<interFaceList.size(); i++){
				Map<String, Object> info	= (CoviMap) interFaceList.get(i);
				CoviMap params				= makeSetInterFaceDBMap(mapClassName,mapFunctionName,info);
				String type					= rtString(params.get("interFaceSetType"));
				
				/**	TYPE
				 * 	S : SAVE [INSET, UPDATE]
				 * 	D : DELETE
				 */
				if(type.equals("S")){
					interFaceSaveList.add(info);
				}else if(type.equals("D")){
					interFaceDeleteList.add(info);
				}
			}
			
			/**
			 * SAVE [INSET, UPDATE]
			 */
			if(interFaceSaveList.size() > 0){
				for(int i=0; i<interFaceSaveList.size(); i++){
					Map<String, Object> info	= (CoviMap) interFaceSaveList.get(i);
					CoviMap params				= makeSetInterFaceDBMap(mapClassName,mapFunctionName,info);
					
					int cnt = interFaceCntKey(cntKeySql, params);
					
					if(cnt > 0){
						if(updateSql.length() > 0){
							interFaceUpdateInfo(updateSql,params);
							cntUpdate += 1;
						}
					}else{
						if(insertSql.length() > 0){
							interFaceInsertInfo(insertSql,params);
							cntInsert += 1;
						}
					}
				}
				
				if(cntInsert > 0){
					msg += " cntInsert : " + String.valueOf(cntInsert);
				}
				
				if(cntUpdate > 0){
					msg += " cntUpdate : " + String.valueOf(cntUpdate);
				}
			}
			
			/**
			 * DELETE
			 */
			if(deleteSql.length() > 0 && interFaceDeleteList.size() > 0){
				for(int i=0; i<interFaceDeleteList.size(); i++){
					Map<String, Object> info	= (CoviMap) interFaceDeleteList.get(i);
					CoviMap params				= makeSetInterFaceDBMap(mapClassName,mapFunctionName,info);
					interFaceInsertInfo(deleteSql,params);
					cntDelete += 1;
				}
				msg += " cntDelete : " + String.valueOf(cntDelete);
			}
			
			rtObject.put("msg",		msg);
			rtObject.put("IfCnt",	cntInsert + cntUpdate + deleteSql);
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
	
	private CoviMap makeSetInterFaceDBMap(String mapClassName,String mapFunctionName, Map<String, Object> info){
		CoviMap returnMap = new CoviMap();
		
		try {
			Class	mapCls			= Class.forName(mapClassName);
			Object	mapObj			= mapCls.newInstance();
			Method	mapMth			= mapCls.getMethod(mapFunctionName);
			CoviMap map				= (CoviMap) mapMth.invoke(mapObj);
			
			CoviMap upperObj	= new CoviMap();
			for(Map.Entry<String, Object> entry : info.entrySet()){
				String allMapKey = rtString(entry.getKey()).toUpperCase();
				String allMapVal = rtString(entry.getValue()).toUpperCase();
				upperObj.put(allMapKey, allMapVal);
			}
			
			Map<String, Object> allMap = map;
			for(Map.Entry<String, Object> entry : allMap.entrySet()){
				String allMapKey = rtString(entry.getKey());
				String allMapVal = rtString(entry.getValue());
				returnMap.put(allMapKey, rtString(upperObj.get(allMapVal.toUpperCase())));
			}
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return returnMap;
	}
	
	private int interFaceCntKey(String sql,CoviMap params) throws Exception {
		int rtInt	= 0;
		rtInt	= (int) coviMapperOne.getNumber(sql, params);
		return rtInt;
	}
	
	private void interFaceInsertInfo(String sql,CoviMap params) throws Exception {
		coviMapperOne.insert(sql, params);
	}
	
	private void interFaceUpdateInfo(String sql,CoviMap params) throws Exception {
		coviMapperOne.update(sql, params);
	}
	
	private void interFaceDeleteInfo(String sql,CoviMap params) throws Exception {
		coviMapperOne.delete(sql, params);
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().replace("{", "").replace("}", "").trim();
		return rtStr;
	}
}
