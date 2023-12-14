package egovframework.coviaccount.user.service.impl;

import java.lang.invoke.MethodHandles;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import net.sf.json.JSON;
import net.sf.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.ExchangeRateVO;
import egovframework.coviaccount.user.service.ExchangeRateSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


/**
 * @Class Name : ExchangeRateSvcImpl.java
 * @Description : 환율 정보 서비스 구현
 * @Modification Information
 * @author Covision
 */
@Service("ExchangeRateSvc")
public class ExchangeRateSvcImpl extends EgovAbstractServiceImpl implements ExchangeRateSvc {
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	/**
	 * @Method Name : getExchangeRatelist
	 * @Description : 환률정보 목록 조회
	 */
	@Override
	public CoviMap getExchangeRatelist(CoviMap params) throws Exception{
		
		CoviMap resultList	= new CoviMap();

		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;

		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt 	= (int) coviMapperOne.getNumber("account.exchangerate.getExchangeRatelistCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.exchangerate.getExchangeRatelist", params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);
		
		return resultList;
	}
	
	/**
	 * @Method Name : getExchangeRatePopupInfo
	 * @Description : 환률정보 상세 정보 조회
	 */
	@Override
	public CoviMap getExchangeRatePopupInfo(CoviMap params) throws Exception{
		CoviMap resultList 	= new CoviMap();
		
		CoviList list = coviMapperOne.list("account.exchangerate.getExchangeRatePopupInfo", params);
		
		resultList.put("list" , AccountUtil.convertNullToSpace(list));
		return resultList;
	}
	
	/**
	 * @Method Name : saveExchangeRateInfo
	 * @Description : 환률정보 정보 저장
	 */
	@Override
	public CoviMap saveExchangeRateInfo(CoviMap params)throws Exception{
		CoviMap resultList = new CoviMap();
		
		String exchangeRateID = params.get("exchangeRateID").toString();
		resultList.put("result","");
		if(exchangeRateID.equals("")){
			int check = (int)  coviMapperOne.getNumber("account.exchangerate.getExchangeRateCnt", params);
			if(check > 0){
				
				resultList.put("result", "code");
			}else{
				insertExchangeRateInfo(params);
			}
		}else{
			updateExchangeRateInfo(params);
		}
		return resultList;
	}
	
	/**
	 * @Method Name : insertExchangeRateInfo
	 * @Description : 환률정보 Insert
	 */
	public void insertExchangeRateInfo(CoviMap params)throws Exception{
		coviMapperOne.insert("account.exchangerate.insertExchangeRateInfo", params);
	}
	
	/**
	 * @Method Name : updateExchangeRateInfo
	 * @Description : 환률정보 Update
	 */
	public void updateExchangeRateInfo(CoviMap params) throws Exception {
		coviMapperOne.insert("account.exchangerate.updateExchangeRateInfo", params);
	}
	
	/**
	 * @Method Name : deleteExchangeRateInfo
	 * @Description : 환률정보 삭제
	 */
	public CoviMap deleteExchangeRateInfo(CoviMap params)throws Exception{
		CoviMap resultList = new CoviMap();
		
		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		if(!deleteStr.equals("")){
			String[] deleteArr = deleteStr.split(",");
			for(int i = 0; i < deleteArr.length; i++){
				CoviMap sqlParam 	= new CoviMap();
				sqlParam.put("exchangeRateID" , deleteArr[i]);
				deleteExchangeRate(sqlParam);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : getExchangeRateExcelList
	 * @Description : 환률정보 엑셀 다운로드
	 */
	public CoviMap getExchangeRateExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviList codeList = (CoviList) coviMapperOne.list("baseCode.selectOnlyCodeByCodeGroup", new CoviMap(new HashMap<String, String>() {{ put("codeGroup", "ExchangeNation"); }}));
		String[] pivotList = new String[codeList.size()];
		for (int i = 0; i < codeList.size(); i++) {
			pivotList[i] = codeList.getString(i);
		}
		params.put("pivotList", pivotList);
		
		CoviList list = coviMapperOne.list("account.exchangerate.exchangesList", params);
		int cnt = (int) coviMapperOne.getNumber("account.exchangerate.exchangesListCnt", params);
		resultList.put("list", list);	
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : deleteExchangeRate
	 * @Description : 환률정보 Delete
	 */
	public void deleteExchangeRate(CoviMap params) throws Exception {
		coviMapperOne.delete("account.exchangerate.deleteExchangeRateInfo", params);
	}
	
	/**
	 * @Method Name : exchangeRateSync
	 * @Description : 환률정보 동기화
	 */
	@Override
	public CoviMap exchangeRateSync(){

		CoviMap interfaceParam			= new CoviMap();
		CoviMap resultList			= new CoviMap();
		ExchangeRateVO exchangeRateVO	= null;
		
		try {
			//String syncType = accountUtil.getPropertyInfo("account.syncType.ExchangeRate");
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "ExchangeRate");
			
			interfaceParam.put("interFaceType",			syncType);
			interfaceParam.put("type",					"get");
	
			interfaceParam.put("daoClassName",			"ExchangeRateDao");
			interfaceParam.put("voClassName",			"ExchangeRateVO");
			interfaceParam.put("mapClassName",			"ExchangeRateMap");
	
			interfaceParam.put("daoSetFunctionName",	"setExchangeRateList");
			interfaceParam.put("daoGetFunctionName",	"getExchangeRateList");
			interfaceParam.put("voFunctionName",		"setAll");
			interfaceParam.put("mapFunctionName",		"getMap");
	
			switch (syncType) {
				case "DB":
					//syncType이 DB인 경우 이곳에 정의
					interfaceParam.put("type",		"get");
					interfaceParam.put("sqlName",	"accountInterFace.AccountSI.getInterFaceListExchangeRate");
					break;
		
				case "SOAP":
					//syncType이 SOAP인 경우 이곳에 정의
					break;
					
				case "SAP":
					//syncType이 SAP인 경우 이곳에 정의
					break;
					
				default:						
			}
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
	
			String sessionUser = SessionHelper.getSession("UR_Code");
	
			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				exchangeRateVO = (ExchangeRateVO) list.get(i);
				String exchangeRateDate	= exchangeRateVO.getExchangeRateDate();
				String usd	= exchangeRateVO.getUsd();
				String eur	= exchangeRateVO.getEur();
				String aed	= exchangeRateVO.getAed();
				String aud	= exchangeRateVO.getAud();
				String brl	= exchangeRateVO.getBrl();
				String cad	= exchangeRateVO.getCad();
				String chf	= exchangeRateVO.getChf();
				String cny	= exchangeRateVO.getCny();
				String jpy	= exchangeRateVO.getJpy();
				String sgd	= exchangeRateVO.getSgd();
				//데이터 구조가 다른 관계로  임시로 셋팅
				
				listInfo.put("UR_Code",				sessionUser);
				listInfo.put("exchangeRateDate",	exchangeRateDate);
				listInfo.put("usd",	usd);
				listInfo.put("eur",	eur);
				listInfo.put("aed",	aed);
				listInfo.put("aud",	aud);
				listInfo.put("brl",	brl);
				listInfo.put("cad",	cad);
				listInfo.put("chf",	chf);
				listInfo.put("cny",	cny);
				listInfo.put("jpy",	jpy);
				listInfo.put("sgd",	sgd);
				
				exchangeRateInterfaceSave(listInfo);
			}
			resultList.put("status",	getInterface.get("status"));
		} catch (NullPointerException e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}

	/**
	 * @Method Name : exchangeRateInterfaceSave
	 * @Description : 환률정보 동기화 저장
	 */
	private void exchangeRateInterfaceSave(CoviMap map) {
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("account.exchangerate.getExchangeRateCnt", map);

		if (cnt == 0) {
			coviMapperOne.insert("account.exchangerate.insertExchangeRateInfo", map);
		} else {
			coviMapperOne.update("account.exchangerate.updateExchangeRateInfoInterface", map);
		}
	}

	@Override
	public CoviMap exchangesList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		try {
			CoviList codeList = (CoviList) coviMapperOne.list("baseCode.selectOnlyCodeByCodeGroup", new CoviMap(new HashMap<String, String>() {{ put("codeGroup", "ExchangeNation"); }}));
			
			String[] pivotList = new String[codeList.size()];
			for (int i = 0; i < codeList.size(); i++) {
				pivotList[i] = codeList.getString(i);
			}
			
			int cnt			= 0;
			int pageNo		= Integer.parseInt(params.get("pageNo").toString());
			int pageSize	= Integer.parseInt(params.get("pageSize").toString());
			int pageOffset	= (pageNo - 1) * pageSize;
	
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("pageOffset",	pageOffset);
			params.put("pivotList", pivotList);
			
			cnt 	= (int) coviMapperOne.getNumber("account.exchangerate.exchangesListCnt", params);
			
			CoviMap page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);
		
			CoviList list	= coviMapperOne.list("account.exchangerate.exchangesList", params);
			
			resultList.put("list", AccountUtil.convertNullToSpace(list));
			resultList.put("page", page);
		
		}  catch (NullPointerException e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}  catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}

	@Override
	public CoviMap exchangesRegister(CoviMap params, CoviMap exchanges) throws Exception {
		
		CoviMap resultList = new CoviMap();
		
		try {
			params.put("exchangeRateDateStart", params.get("YYYYMMDD"));
			params.put("exchangeRateDateFinish", params.get("YYYYMMDD"));
			
			int cnt = (int) coviMapperOne.getNumber("account.exchangerate.exchangesListCnt", params);
			if (cnt > 0) {
				resultList.put("result", "code");
				return resultList;
			}
			
			for (Object key : exchanges.keySet()) {
				if (!"".equals(exchanges.get(key.toString()))) {
					params.put("CURRENCY", key);
					params.put("PRICE", exchanges.get(key));
					coviMapperOne.insert("account.exchangerate.exchangesRegister", params);
				}
			}
		} catch (NullPointerException e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}

	@Override
	public CoviMap exchangesModify(CoviMap params, CoviMap exchanges) throws Exception {
		CoviMap resultList = new CoviMap();
		
		try {
			coviMapperOne.delete("account.exchangerate.exchangesRemove", params);
			
			for (Object key : exchanges.keySet()) {
				if (!"".equals(exchanges.get(key.toString()))) {
					params.put("CURRENCY", key);
					params.put("PRICE", exchanges.get(key));
					coviMapperOne.update("account.exchangerate.exchangesRegister", params);
				}
			}
		} catch (NullPointerException e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}

	@Override
	public CoviMap exchangesRead(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		try {
			CoviList codeList = (CoviList) coviMapperOne.list("baseCode.selectOnlyCodeByCodeGroup", new CoviMap(new HashMap<String, String>() {{ put("codeGroup", "ExchangeNation"); }}));
			
			String[] pivotList = new String[codeList.size()];
			for (int i = 0; i < codeList.size(); i++) {
				pivotList[i] = codeList.getString(i);
			}
			params.put("pivotList", pivotList);
			
			resultList.put("dto", coviMapperOne.select("account.exchangerate.exchangesRead", params));
		} catch (NullPointerException e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}

	@Override
	public CoviMap exchangesRemove(CoviList params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		try {
			for (int i = 0; i < params.size(); i++) {
				CoviMap coviMap = new CoviMap(params.get(i));
				coviMapperOne.delete("account.exchangerate.exchangesRemove", coviMap);
			}
		} catch (NullPointerException e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
}
