package egovframework.covision.coviflow.legacy.service.impl;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import javax.annotation.Resource;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import org.json.XML;
import egovframework.baseframework.util.json.JSONParser;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.covision.coviflow.common.util.ChromeRenderManager;
import egovframework.covision.coviflow.legacy.service.FormCmmFunctionSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@Service("formCmmFunctionSvc")
public class FormCmmFunctionSvcImpl extends EgovAbstractServiceImpl implements FormCmmFunctionSvc{
	private static final Logger LOGGER = LogManager.getLogger(ChromeRenderManager.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@Override
	public CoviMap getFormInstAll(CoviMap params) throws Exception {
		
		return CoviSelectSet.coviSelectMapJSON(coviMapperOne.selectOne("legacy.formCmmFunction.selectFormInstAll", params));
		
		//CoviList list = coviMapperOne.list("legacy.formCmmFunction.selectFormInstAll", params);
		
		//CoviMap formInstDataObj = new CoviMap();

		//formInstDataObj.put("list",CoviSelectSet.coviSelectJSON(list, "FormInstID,Subject,BodyContext"));
		
		//return formInstDataObj;
		
	}
	
	@Override
	public CoviMap getFormInstData(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("legacy.formCmmFunction.selectFormInstData", params);
		
		CoviMap formInstDataObj = new CoviMap();

		formInstDataObj.put("list",CoviSelectSet.coviSelectJSON(list, "FormInstID,Subject,BodyContext"));
		
		return formInstDataObj;
		
	}

	@Override
	public String getDomainID(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("legacy.formCmmFunction.selectDomainID", params);
	}

	/* 
	 * 라이선스 인증서 발급 품의
	 * 매개변수(spParams)
	 * formPrefix
	 * bodyContext
	 * formInfoExt
	 * approvalContext
	 * preApproveprocsss
	 * apvResult
	 * docNumber
	 * approverId
	 * formInstID
	 * apvMode
	 * processID
	 * formHelperContext
	 * formNoticeContext
	 */
	@Override
	public void execWF_FORM_DRAFT_License(CoviMap spParams) throws Exception {
		
		//자바의 테이블로  변경 (.NET : COVI_FLOW_FORM_DEF..usp_wfform_RegisterDocumentNumber_Software
		try{
			if(spParams.optString("apvMode").equals("COMPLETE")){
				Calendar cal = Calendar.getInstance( );
				
				String serialNumber = "";
                String year = Integer.toString(cal.get(Calendar.YEAR));
                String month = Integer.toString(cal.get(Calendar.MONTH)+1);
				
                
                CoviMap params = new CoviMap();
				
				params.put("UNIT_CODE", "CO-LI" + year.substring(2,4)); //년 뒤에2자리 (2017->17) 인증번호
				params.put("FISCAL_YEAR",year);
				params.put("DOC_LIST_TYPE", "1");  //증가식
				params.put("UNIT_ABBR", "");
				params.put("CATEGORY_NUMBER","");
				
				int cnt = 0;
				cnt = coviMapperOne.insert("legacy.formCmmFunction.usp_wfform_RegisterDocumentNumber_Software", params);
				
				if(cnt<=0 || params.getString("SerialNumber").equals("") || params.get("SerialNumber")==null){
					throw new Exception("라이센스 번호가 발번되지 않았습니다.");
				}
				
			    //EX "CO-LI-151-0001"
				serialNumber = "0000" + params.getString("SerialNumber");
				serialNumber = serialNumber.substring(serialNumber.length()-4);
				CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
				bodyContext.put("SerialNumber",  ("CO-LI-" + year.substring(2, 4) + month + "-" + serialNumber));
				
				params.clear();
				params.put("BODYCONTEXT", new String( Base64.encodeBase64( bodyContext.toString().getBytes(StandardCharsets.UTF_8) ), StandardCharsets.UTF_8 ) );
				params.put("FIID", spParams.getInt("formInstID"));
				
				cnt = coviMapperOne.update("legacy.formCmmFunction.usp_form_UpdateBodyContext",params);
				
			}
		}catch(NullPointerException npE){
        	throw npE;
		}catch(Exception e){
        	throw e;
		}
	}

	@Override
	@Deprecated
	public void execWF_FORM_VACATION_REQUEST(CoviMap spParams) throws Exception {
		CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
		
        if(spParams.optString("apvMode").equals("COMPLETE") && RedisDataUtil.getBaseConfig("VACATION_INERLOCK","1").equals("Y")){
        	CoviMap param = new CoviMap();
    		param.put("FormInstID", spParams.getInt("formInstID"));
    		
    		CoviMap formInstData = coviMapperOne.select("legacy.formCmmFunction.selectFormInstDataForVac", param);
    		
        	String toDay = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
			
        	CoviList ja = new CoviList();
        	if (bodyContext.get("tblVacInfo") instanceof CoviMap) {
        		ja.add(bodyContext.getJSONObject("tblVacInfo"));
        	} else {
        		ja = bodyContext.getJSONArray("tblVacInfo");
        	}
        	
        	for (int i=0; i<ja.size(); i++) {
        		CoviMap jo = ja.getJSONObject(i);
        		
        		param.put("vacYear", bodyContext.getString("Sel_Year"));
        		param.put("urCode", bodyContext.getString("InitiatorCodeDisplay"));
        		param.put("urName", bodyContext.getString("InitiatorDisplay"));
        		param.put("vacFlag", jo.getString("VACATION_TYPE"));
        		param.put("sDate", jo.getString("_MULTI_VACATION_SDT"));
        		param.put("eDate", jo.getString("_MULTI_VACATION_EDT"));
        		param.put("vacDay", jo.getString("_MULTI_DAYS"));
        		param.put("reason", bodyContext.getString("VAC_REASON").replace("'","''"));
        		param.put("appDate", bodyContext.getString("InitiatedDate"));
        		param.put("endDate", toDay);
        		param.put("workItemID", formInstData.getInt("WorkItemID"));
        		param.put("processID", formInstData.getInt("ProcessID"));
        		param.put("gubun", "VACATION_APPLY");
        		param.put("deputyName", bodyContext.getString("DEPUTY_NAME"));//미사용, History 용으로 전달만
        		param.put("deputyCode", "");//미사용
        		
        		if(jo.containsKey("VACATION_OFF_TYPE")) { // 오전/오후 반차 구분 추가
        			param.put("vacOffFlag", jo.getString("VACATION_OFF_TYPE"));
        		}
        		
        		coviMapperOne.insert("legacy.formCmmFunction.insertVacationInfo", param);        			
        	}
        }
	}	
	
	@Override
	@Deprecated
	public void execWF_FORM_VACATION_CANCEL(CoviMap spParams) throws Exception {
		CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
		
    	if(spParams.optString("apvMode").equals("COMPLETE") && RedisDataUtil.getBaseConfig("VACATION_INERLOCK","1").equals("Y")){
    		CoviMap param = new CoviMap();
    		param.put("FormInstID", spParams.getInt("formInstID"));
    		
    		CoviMap resultMap = coviMapperOne.select("legacy.formCmmFunction.selectFormInstDataForVac", param);
    		
			String toDay = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
			
        	CoviList ja = new CoviList();
        	if (bodyContext.get("tblVacInfo") instanceof CoviMap) {
        		ja.add(bodyContext.getJSONObject("tblVacInfo"));
        	} else {
        		ja = bodyContext.getJSONArray("tblVacInfo");
        	}
        	
        	for (int i=0; i<ja.size(); i++) {
        		CoviMap jo = ja.getJSONObject(i);
        		
        		param.put("vacYear", bodyContext.getString("Sel_Year"));
        		param.put("urCode", bodyContext.getString("InitiatorCodeDisplay"));
        		param.put("urName", bodyContext.getString("InitiatorDisplay"));
        		param.put("vacFlag", jo.getString("VACATION_TYPE"));
        		param.put("sDate", jo.getString("_MULTI_VACATION_SDT"));
        		param.put("eDate", jo.getString("_MULTI_VACATION_EDT"));
        		param.put("vacDay", "-"+jo.getString("_MULTI_DAYS"));
        		param.put("reason", bodyContext.getString("VAC_REASON").replace("'","''"));
        		param.put("appDate", bodyContext.getString("InitiatedDate"));
        		param.put("endDate", toDay);
        		param.put("workItemID", resultMap.getInt("WorkItemID"));
        		param.put("processID", resultMap.getInt("ProcessID"));
        		param.put("gubun", "VACATION_CANCEL");
        		
        		if(jo.containsKey("VACATION_OFF_TYPE")) { // 오전/오후 반차 구분 추가
        			param.put("vacOffFlag", jo.getString("VACATION_OFF_TYPE"));
        		}
        		
        		coviMapperOne.insert("legacy.formCmmFunction.insertVacationInfo", param);
        	}
			
			//Description:	해당 휴가의 휴가취소신청서 기안 여부 업데이트 - COVI_FLOW_SI..VM_CancelStatus_U
    		param = new CoviMap();
    		param.put("RequestFIID", bodyContext.getString("HID_REQUEST_FIID")); //의미상 남겨놓음(휴가신청서의 FIID)
    		param.put("FormInstID", bodyContext.getString("HID_REQUEST_FIID"));
    		//param.put("CancelFIID", spParams.getInt("formInstID"));
    		
    		CoviMap formInstData = coviMapperOne.select("legacy.formCmmFunction.selectFormInstData", param);
    		String dbBodyContext = CoviSelectSet.coviSelectJSON(formInstData, "BodyContext").getJSONObject(0).getString("BodyContext");
        		
    		CoviMap dbBodyContextObj = CoviMap.fromObject( new String(Base64.decodeBase64(dbBodyContext), StandardCharsets.UTF_8));
    		dbBodyContextObj.remove("HID_REQUEST_FIID");
    		dbBodyContextObj.put("HID_CANCLE_FIID", spParams.getString("formInstID"));
    		
    		param.clear();
    		param.put("BODYCONTEXT", new String( Base64.encodeBase64( dbBodyContextObj.toString().getBytes(StandardCharsets.UTF_8) ),StandardCharsets.UTF_8 ) );
    		param.put("FIID", bodyContext.getString("HID_REQUEST_FIID"));
    		
    		int cnt =  coviMapperOne.update("legacy.formCmmFunction.usp_form_UpdateBodyContext", param);
              
    	}
	}
	
	//.NET의 저장프로시저를 사용하거나, DB에 BodyContext를 넣는 경우 XML 형식에 맞도록 변경한다. 
	public String convertJSONtoXML(String context,String type){
		
		org.json.JSONObject jsonObj = new org.json.JSONObject(context);
		
		if(type.equals("bodyContext")){
			jsonObj.put("INITIATED_DATE", jsonObj.getString("InitiatedDate"));
			jsonObj.put("INITIATOR_DATE_INFO", jsonObj.getString("InitiatedDate"));
			jsonObj.put("INITIATOR_OU_DP", jsonObj.getString("InitiatorOUDisplay"));
			jsonObj.put("INITIATOR_DP", jsonObj.getString("InitiatorDisplay"));
			jsonObj.put("INITIATOR_CODE_DP", jsonObj.getString("InitiatorCodeDisplay"));
			
			jsonObj.remove("InitiatedDate");
			jsonObj.remove("InitiatorOUDisplay");
			jsonObj.remove("InitiatorDisplay");
			jsonObj.remove("InitiatorCodeDisplay");
			
			if(jsonObj.has("SubTable1")){
				if(jsonObj.get("SubTable1") instanceof org.json.JSONArray){
					jsonObj.put("sub_table1", jsonObj.getJSONArray("SubTable1"));
				}else if(jsonObj.get("SubTable1") instanceof org.json.JSONObject){
					jsonObj.put("sub_table1", jsonObj.getJSONObject("SubTable1"));
				}else{
					jsonObj.put("sub_table1", jsonObj.getString("SubTable1"));
				}
				//jsonObj.remove("SubTable1");
			}
			
			if(jsonObj.has("SubTable2")){
				if(jsonObj.get("SubTable2") instanceof org.json.JSONArray){
					jsonObj.put("sub_table2", jsonObj.getJSONArray("SubTable2"));
				}else if(jsonObj.get("SubTable2") instanceof org.json.JSONObject){
					jsonObj.put("sub_table2", jsonObj.getJSONObject("SubTable2"));
				}else{
					jsonObj.put("sub_table2", jsonObj.getString("SubTable2"));
				}
				//jsonObj.remove("SubTable2");
			}
			
			if(jsonObj.has("SubTable3")){
				if(jsonObj.get("SubTable3") instanceof org.json.JSONArray){
					jsonObj.put("sub_table3", jsonObj.getJSONArray("SubTable3"));
				}else if(jsonObj.get("SubTable3") instanceof org.json.JSONObject){
					jsonObj.put("sub_table3", jsonObj.getJSONObject("SubTable3"));
				}else{
					jsonObj.put("sub_table3", jsonObj.getString("SubTable3"));
				}
				//jsonObj.remove("SubTable3");
			}
			
			if(jsonObj.has("SubTable4")){
				if(jsonObj.get("SubTable4") instanceof org.json.JSONArray){
					jsonObj.put("sub_table4", jsonObj.getJSONArray("SubTable4"));
				}else if(jsonObj.get("SubTable4") instanceof org.json.JSONObject){
					jsonObj.put("sub_table4", jsonObj.getJSONObject("SubTable4"));
				}else{
					jsonObj.put("sub_table4", jsonObj.getString("SubTable4"));
				}
				//jsonObj.remove("SubTable4");
			}
		}
		
		return XML.toString(jsonObj);
	}

	@Override
	public CoviMap getGovUsingStamp(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("legacy.formCmmFunction.selectGovUsingStamp", params);
		
		CoviMap govUsingStampObj = new CoviMap();
		govUsingStampObj.put("list",CoviSelectSet.coviSelectJSON(list));
		
		return govUsingStampObj;
	}

	@Override
	public String getBodyContextData(CoviMap params) {
		
		return coviMapperOne.selectOne("legacy.formCmmFunction.selectBodyContextData", params);
	}
	
	@Override
	public CoviMap getVacationData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("legacy.formCmmFunction.selectVacationData", params);
		
		CoviMap returnJo = new CoviMap();
		   
		returnJo.put("list",CoviSelectSet.coviSelectJSON(list, "VACDAY,DAYSREQ,DAYSCAN,USEDAYS,ATot"));
		
		return returnJo;
	}

	@Override
	public CoviList getFormBaseOS(CoviMap params) throws Exception {
		CoviList resultArray = new CoviList();
		
		CoviList list = coviMapperOne.list("legacy.formCmmFunction.selectFormBaseOS", params);
		
		for(Object obj : list){
			CoviMap map  = (CoviMap)obj;
			CoviMap row = new CoviMap();
			
			row.put("CODE_VALUE", map.getString("CODE_VALUE"));
			
			resultArray.add(row);
		}
		
		return resultArray;
	}	
	
	/*@Override
	public CoviList getVacationInfo(CoviMap params) throws Exception {
		CoviList returnArr = new CoviList();
		CoviList vacationInfo = CoviList.fromObject(params.getString("vacationInfo"));
		String userCode = SessionHelper.getSession("USERID");
		
		for(Object obj : vacationInfo){
			CoviMap vacationInfoObj = (CoviMap)obj;
			
			CoviMap paramMap = new CoviMap();
			paramMap.put("StartDate", vacationInfoObj.getString("_MULTI_VACATION_SDT"));
			paramMap.put("EndDate", vacationInfoObj.getString("_MULTI_VACATION_EDT"));
			paramMap.put("UserCode", userCode);
			
			if(vacationInfoObj.containsKey("VACATION_OFF_TYPE")) {
				paramMap.put("VacOffFlag", vacationInfoObj.getString("VACATION_OFF_TYPE"));	
			}
			
			CoviList list = coviMapperOne.list("legacy.formCmmFunction.selectVacationInfo", paramMap);
			CoviList listArr = CoviSelectSet.coviSelectJSON(list);
			if(listArr.size()>0){
				// 휴가취소가 되었는지 체크
				for(Object obj2 : listArr){
					CoviMap paramObj = (CoviMap)obj2;
					CoviMap paramMap2 = new CoviMap();
					paramMap2.put("UR_Code", paramObj.getString("UR_Code"));
					paramMap2.put("VacFlag", paramObj.getString("VacFlag"));
					paramMap2.put("VacOffFlag", paramObj.getString("VacOffFlag"));
					paramMap2.put("SDate", paramObj.getString("SDate"));
					paramMap2.put("EDate", paramObj.getString("EDate"));
					paramMap2.put("VacDay", paramObj.getString("VacDay"));
					paramMap2.put("GUBUN", paramObj.getString("GUBUN"));
					
					list = coviMapperOne.list("legacy.formCmmFunction.selectVacationCancelInfo", paramMap2);
					listArr = CoviSelectSet.coviSelectJSON(list, "UR_Code,VacFlag,Sdate,Edate,VacDay,GUBUN");	
				}
				
				if(listArr.size() == 0){
					returnArr.add(vacationInfoObj);
				}
			}
		}
		
		return returnArr;
	}*/
	
	@Override
	public CoviList getVacationInfo(CoviMap params) throws Exception {
		CoviList returnArr = new CoviList();
		CoviList vacationInfo = CoviList.fromObject(params.getString("vacationInfo"));
		String chkType = params.getString("chkType", "");
		
		String userCode = SessionHelper.getSession("USERID");
		
		for(Object obj : vacationInfo){
			CoviMap vacationInfoObj = (CoviMap)obj;
			
			CoviMap paramMap = new CoviMap();
			paramMap.put("StartDate", vacationInfoObj.getString("_MULTI_VACATION_SDT"));
			paramMap.put("EndDate", vacationInfoObj.getString("_MULTI_VACATION_EDT"));
			paramMap.put("STime", vacationInfoObj.getString("_MULTI_VACATION_STIME"));
			paramMap.put("ETime", vacationInfoObj.getString("_MULTI_VACATION_ETIME"));
			paramMap.put("UserCode", userCode);
			
			if(vacationInfoObj.containsKey("VACATION_OFF_TYPE")) {
				paramMap.put("VacOffFlag", vacationInfoObj.getString("VACATION_OFF_TYPE"));	
			}
			paramMap.put("VacFlag", vacationInfoObj.optString("VACATION_TYPE"));	
			
			
			long cnt = 0L;
			if("CANCEL".equals(chkType)) {
				// 휴가일체크(휴가취소신청시), 전체 휴가일
				cnt = coviMapperOne.getNumber("legacy.formCmmFunction.selectVacationCancelInfo", paramMap);
				if(cnt != 0){
					// warnning
					returnArr.add(vacationInfoObj);
				}
			}else {
				// 중복체크
				cnt = coviMapperOne.getNumber("legacy.formCmmFunction.selectVacationInfo", paramMap);	
				if(cnt > 0 ){
					returnArr.add(vacationInfoObj);
				}
			}
		}
		
		return returnArr;
	}	
	
	@Override
	public CoviMap getVacationProcessInfo(CoviMap paramMap) throws Exception {
		CoviMap returnObject = new CoviMap();
		
		CoviMap resultMap = coviMapperOne.selectOne("legacy.formCmmFunction.selectVacationProcessInfo", paramMap);
		
		returnObject.put("days", resultMap.getString("days"));
		returnObject.put("cnt", resultMap.getString("cnt"));
		
		return returnObject;
	}
	
	/**
	 * @Method setApvStatus 
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviMap setApvStatus(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		
		try {
			CoviMap bodyContext = CoviMap.fromObject(params.getString("bodyContext"));
			
			String expenceApplicationID = bodyContext.getString("ERPKey");
			String processID = params.getString("processID");
			String apvState = params.getString("apvMode");
			String ur_Code = params.getString("approverId");
			String comment = params.getString("comment");
			String domainID = params.getString("domainID");
			
			if(params.getString("formPrefix").indexOf("EACCOUNT_LEGACY") > -1) {
					// 상태값 변경에 따른 eAccounting 서비스 호출
					String accountURL = PropertiesUtil.getGlobalProperties().getProperty("account.legacy.path");
					String httpCommURL = "";
					
					CoviMap accountParam = new CoviMap();
					
					switch (apvState) {
						case "DRAFT":
							apvState = "D";
							break;
						case "COMPLETE":
							apvState = "E";
							break;
						case "REJECT":
							apvState = "R";
							break;
						case "OTHERSYSTEM":
							apvState = "P";
							break;
						case "ABORT":
						case "WITHDRAW":
							apvState = "C";
							break;
						case "CHARGEDEPT":
							apvState = "DC";
							break;
						default:
							break;
					}
					
					accountParam.put("ExpenceApplicationID", expenceApplicationID);
					accountParam.put("ProcessID", processID);
					accountParam.put("ApplicationStatus", apvState);
					accountParam.put("SessionUser", ur_Code);
					accountParam.put("Comment", comment);
					accountParam.put("DomainID", domainID);
					
					// 법인카드/모바일영수증 Active 값 update 
					httpCommURL = accountURL + "/expenceApplication/updateActive.do";
					HttpsUtil httpsUtil = new HttpsUtil();
					String strResult = httpsUtil.httpsClientWithRequest(httpCommURL, "POST", accountParam, "UTF-8", null);
					CoviMap resultObj = CoviMap.fromObject(strResult);
					if(!"SUCCESS".equals(resultObj.getString("status"))) {
						if(resultObj.has("message")) {
							throw new Exception(resultObj.getString("message"));
						} else {
							throw new Exception(DicHelper.getDic("msg_apv_030"));
						}
					}
			} else {
				//자금지출결의서는 상태값을 증빙별로 관리 (ERPKey에 ExpenceApplicationListID 값들이 저장되어 있음)
				if(!expenceApplicationID.equals("")) {
					CoviMap paramObj = new CoviMap();

					switch (apvState) {
					case "DRAFT":
					case "OTHERSYSTEM":
					case "CHARGEDEPT":
						apvState = "P";
						break;
					case "COMPLETE":
						apvState = "E";
						break;
					case "ABORT":
					case "REJECT":
					case "WITHDRAW":
						apvState = "W";
						break;
					default:
						apvState = "P";
						break;
					}
					
					// secure code.
					String [] expenceApplicationIDs = StringUtils.split(expenceApplicationID, ",");
					paramObj.put("ExpenceApplicationListIDs", expenceApplicationIDs);
					
					paramObj.put("CapitalProcessID", processID);
					paramObj.put("CapitalStatus", apvState);
					
					coviMapperOne.update("legacy.formCmmFunction.updateCapitalApvStatus", paramObj);
				}
			}
			
			resultList.put("status",	Return.SUCCESS);
		} catch(NullPointerException npE) {
			throw npE;
		} catch(Exception e) {
			throw e;
		}
		
		return resultList;
	}
	
	/**
	 * @Method createCapitalReportInfo 
	 * @param params
	 * @throws Exception
	 */
	public CoviMap createCapitalReportInfo(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		
		String apvState = params.getString("apvMode");
		String capitalStatus = "";
		String processID = params.getString("processID");
		String ur_Code = params.getString("approverId");
		String comment = params.getString("comment");
		
		CoviMap bodyContext = CoviMap.fromObject(params.getString("bodyContext"));
		
		String subject = bodyContext.getString("Subject");
		String expAppListIDs = bodyContext.getString("expAppListIDs");
		String initiatorCode = bodyContext.getString("InitiatorCodeDisplay");
		String initiatorDisplay = bodyContext.getString("InitiatorDisplay");
		String realPayDate = bodyContext.getString("RealPayDate");
		String realPayAmount = bodyContext.getString("TotalPayAmount"); //자금지출보고서의 총합계는 자금지출결의서에서 바인딩하는 자금지출보고 1건의 지출액과 동일
		String standardBriefID = bodyContext.getString("StandardBriefID");
		
		try {
			
			switch (apvState) {
			case "DRAFT":
			case "OTHERSYSTEM":
			case "CHARGEDEPT":
				capitalStatus = "RP";
				break;
			case "COMPLETE":
				capitalStatus = "R";
				break;
			case "ABORT":
			case "REJECT":
			case "WITHDRAW":
				capitalStatus = "W";
				break;
			default:
				capitalStatus = "RP";
				break;
			}
								
	    	String accountURL = PropertiesUtil.getGlobalProperties().getProperty("account.legacy.path");
			String httpCommURL = "";
			
			CoviMap accountParam = new CoviMap();
			accountParam.put("ProcessID", processID);
			accountParam.put("UR_Code", ur_Code);
			accountParam.put("Comment", comment);
			accountParam.put("ApvState", apvState);
			accountParam.put("CapitalStatus", capitalStatus);

			accountParam.put("Subject", subject);
			accountParam.put("expAppListIDs", expAppListIDs);
			accountParam.put("InitiatorCode", initiatorCode);
			accountParam.put("InitiatorDisplay", initiatorDisplay);
			accountParam.put("RealPayDate", realPayDate);
			accountParam.put("RealPayAmount", realPayAmount);
			accountParam.put("StandardBriefID", standardBriefID);
			
			httpCommURL = accountURL + "/expenceApplication/createCapitalReportInfo.do";
			HttpsUtil httpsUtil = new HttpsUtil();
			httpsUtil.httpsClientWithRequest(httpCommURL, "POST", accountParam, "UTF-8", null);
	    	
			resultList.put("status",	Return.SUCCESS);
		} catch(NullPointerException npE) {
			throw npE;
		} catch(Exception e) {
			throw e;
		}
				
		return resultList;
	}
	
	/**
	 * @Method saveRequestInfo 
	 * @param params
	 * @throws Exception
	 */
	public CoviMap saveRequestInfo(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap bodyContext = CoviMap.fromObject(params.getString("bodyContext"));
		String formInstanceID = params.getString("formInstID");
		String ur_Code = params.getString("approverId");
		String comment = params.getString("comment");
		
		String apvState = params.getString("apvMode");
		switch (apvState) {
		case "COMPLETE":
			apvState = "E";
			break;
		case "REJECT":
			apvState = "R";
			break;
		default:
			break;
		}		    	
		
		CoviMap paramObj = new CoviMap();
		paramObj.put("ApplicationStatus", apvState);
		paramObj.put("FormInstanceID", formInstanceID);
		paramObj.put("UR_CODE", ur_Code);
		paramObj.put("Comment", comment);
		paramObj.put("SessionUser", ur_Code);
		paramObj.put("setStatus", apvState); //이후 연동 용
				
		if(params.optString("formPrefix").equals("WF_FORM_EACCOUNT_REQ_VENDOR")) {
			try {
		    	String accountURL = PropertiesUtil.getGlobalProperties().getProperty("account.legacy.path");
				String httpCommURL = accountURL;			
				httpCommURL += "/baseInfo/saveVendorRequestDataApv.do";		//거래처 신청 

				paramObj.put("VendorApplicationID", "");
				paramObj.put("ApplicationType", bodyContext.getString("vendor_application_type"));
				paramObj.put("ApplicationTitle", bodyContext.getString("Subject"));
				paramObj.put("IsSearched", "N");
				if(bodyContext.optString("vendor_application_type").equals("BankChange")) {
					paramObj.put("IsNew", "");
					paramObj.put("VendorNo", bodyContext.getString("vendor_no"));
					paramObj.put("CorporateNo", "");
					paramObj.put("VendorName", bodyContext.getString("vendor_name"));
					paramObj.put("CEOName", "");
					paramObj.put("Industry", "");
					paramObj.put("Sector", "");
					paramObj.put("Address", "");
					paramObj.put("BankCode",  bodyContext.getString("bank_code"));
					paramObj.put("BankName",  bodyContext.getString("bank_name"));
					paramObj.put("BankAccountNo",  bodyContext.getString("bank_account"));
					paramObj.put("BankAccountName",  bodyContext.getString("bank_owner"));
					paramObj.put("PaymentCondition", "");
					paramObj.put("PaymentMethod", "");
					paramObj.put("VendorStatus", "");
					paramObj.put("IncomTax", "");
					paramObj.put("LocalTax", "");
				} else if(bodyContext.optString("vendor_application_type").equals("Organization")) {
					paramObj.put("IsNew", (bodyContext.optString("rdo_type_organization").equals("new")?"Y":"N"));
					paramObj.put("VendorNo", bodyContext.getString("organization_vendor_no"));
					paramObj.put("CorporateNo", "");
					paramObj.put("VendorName", bodyContext.getString("organization_vendor_name"));
					paramObj.put("CEOName", "");
					paramObj.put("Industry", "");
					paramObj.put("Sector", "");
					paramObj.put("Address", bodyContext.getString("organization_address"));
					paramObj.put("BankCode",  bodyContext.getString("organization_bank_code"));
					paramObj.put("BankName",  bodyContext.getString("organization_bank_name"));
					paramObj.put("BankAccountNo",  bodyContext.getString("organization_bank_account"));
					paramObj.put("BankAccountName",  bodyContext.getString("organization_bank_owner"));
					paramObj.put("PaymentCondition", bodyContext.getString("organization_pay_type"));
					paramObj.put("PaymentMethod", bodyContext.getString("organization_pay_method"));
					paramObj.put("VendorStatus", "");
					paramObj.put("IncomTax", "");
					paramObj.put("LocalTax", "");
				} else if(bodyContext.optString("vendor_application_type").equals("People")) {
					paramObj.put("IsNew", (bodyContext.optString("rdo_type_personal").equals("new")?"Y":"N"));
					paramObj.put("VendorNo", bodyContext.getString("personal_vendor_no"));
					paramObj.put("CorporateNo", "");
					paramObj.put("VendorName", bodyContext.getString("personal_vendor_name"));
					paramObj.put("CEOName", "");
					paramObj.put("Industry", "");
					paramObj.put("Sector", "");
					paramObj.put("Address", bodyContext.getString("personal_address"));
					paramObj.put("BankCode",  bodyContext.getString("personal_bank_code"));
					paramObj.put("BankName",  bodyContext.getString("personal_bank_name"));
					paramObj.put("BankAccountNo",  bodyContext.getString("personal_bank_account"));
					paramObj.put("BankAccountName",  bodyContext.getString("personal_bank_owner"));
					paramObj.put("PaymentCondition", bodyContext.getString("personal_pay_type"));
					paramObj.put("PaymentMethod", bodyContext.getString("personal_pay_method"));
					paramObj.put("VendorStatus", "");
					paramObj.put("IncomTax", bodyContext.getString("personal_incom_tax"));
					paramObj.put("LocalTax", bodyContext.getString("personal_local_tax"));
				} else if(bodyContext.optString("vendor_application_type").equals("Company")) {
					paramObj.put("IsNew", (bodyContext.optString("rdo_type_business").equals("new")?"Y":"N"));
					paramObj.put("VendorNo", bodyContext.getString("business_vendor_no"));
					paramObj.put("CorporateNo", bodyContext.getString("business_corporate_no"));
					paramObj.put("VendorName", bodyContext.getString("personal_vendor_name"));
					paramObj.put("CEOName", bodyContext.getString("business_ceo_name"));
					paramObj.put("Industry", bodyContext.getString("business_industry"));
					paramObj.put("Sector", bodyContext.getString("business_sector"));
					paramObj.put("Address", bodyContext.getString("business_address"));
					paramObj.put("BankCode",  bodyContext.getString("business_bank_code"));
					paramObj.put("BankName",  bodyContext.getString("business_bank_name"));
					paramObj.put("BankAccountNo",  bodyContext.getString("business_bank_account"));
					paramObj.put("BankAccountName",  bodyContext.getString("business_bank_owner"));
					paramObj.put("PaymentCondition", bodyContext.getString("business_pay_type"));
					paramObj.put("PaymentMethod", bodyContext.getString("business_pay_method"));
					paramObj.put("VendorStatus", "");
					paramObj.put("IncomTax", bodyContext.getString("personal_incom_tax"));
					paramObj.put("LocalTax", bodyContext.getString("personal_local_tax"));
				}
				
				String vendorRequestDataObj = paramObj.toString();
				CoviMap accountParam = new CoviMap();
				accountParam.put("vendorRequestDataObj", vendorRequestDataObj);

				HttpsUtil httpsUtil = new HttpsUtil();
		    	httpsUtil.httpsClientWithRequest(httpCommURL, "POST", accountParam, "UTF-8", null);
		    	
				resultList.put("status",	Return.SUCCESS);
			} catch(NullPointerException npE) {
				throw npE;
			} catch(Exception e) {
				throw e;
			}
		} else if(params.optString("formPrefix").equals("WF_FORM_EACCOUNT_REQ_CARD")) {
			try {
		    	String accountURL = PropertiesUtil.getGlobalProperties().getProperty("account.legacy.path");
				String httpCommURL = accountURL;			
				httpCommURL += "/baseInfo/saveCardApplicationDataApv.do";		//거래처 신청 

				paramObj.put("CardApplicationID", "");
				paramObj.put("ApplicationType", bodyContext.getString("card_application_type"));
				paramObj.put("ApplicationClass", (bodyContext.optString("card_application_type").equals("PrCardApp")?"PE":"CO"));
				paramObj.put("ApplicationTitle", bodyContext.getString("Subject"));
				paramObj.put("IsNew", "Y");
				if(bodyContext.optString("card_application_type").equals("CoCardLimitChange")) {
					paramObj.put("CardNo", bodyContext.getString("card_num"));
					paramObj.put("CardCompany", "");
					paramObj.put("ReissuanceType", "");
					paramObj.put("LimitType", bodyContext.getString("limit_type_combo"));
					paramObj.put("LimitAmountType", bodyContext.getString("change_amount_combo"));
					paramObj.put("LimitAmount", bodyContext.getString("change_amount"));
					paramObj.put("ChangeExpirationDate", bodyContext.getString("change_expiration_date"));
					paramObj.put("ApplicationStartDate", "");
					paramObj.put("ApplicationFinishDate", "");
					paramObj.put("ApplicationAmount", "");
					paramObj.put("ApplicationReason", bodyContext.getString("application_reason"));
				} else if(bodyContext.optString("card_application_type").equals("CoCardReissue")) {
					paramObj.put("CardNo", bodyContext.getString("card_num"));
					paramObj.put("CardCompany", "");
					paramObj.put("ReissuanceType", bodyContext.getString("reissuance_type"));
					paramObj.put("LimitType", "");
					paramObj.put("LimitAmountType", "");
					paramObj.put("LimitAmount", "");
					paramObj.put("ChangeExpirationDate", "");
					paramObj.put("ApplicationStartDate", "");
					paramObj.put("ApplicationFinishDate", "");
					paramObj.put("ApplicationAmount", "");
					paramObj.put("ApplicationReason", bodyContext.getString("application_reason"));
				} else if(bodyContext.optString("card_application_type").equals("CoCardNewissue")) {
					paramObj.put("CardNo", "");
					paramObj.put("CardCompany", "");
					paramObj.put("ReissuanceType", "");
					paramObj.put("LimitType", "");
					paramObj.put("LimitAmountType", "");
					paramObj.put("LimitAmount", "");
					paramObj.put("ChangeExpirationDate", "");
					paramObj.put("ApplicationStartDate", "");
					paramObj.put("ApplicationFinishDate", "");
					paramObj.put("ApplicationAmount", "");
					paramObj.put("ApplicationReason", bodyContext.getString("application_reason"));
				} else if(bodyContext.optString("card_application_type").equals("CoCardClose")) {
					paramObj.put("CardNo", bodyContext.getString("card_num"));
					paramObj.put("CardCompany", "");
					paramObj.put("ReissuanceType", "");
					paramObj.put("LimitType", "");
					paramObj.put("LimitAmountType", "");
					paramObj.put("LimitAmount", "");
					paramObj.put("ChangeExpirationDate", "");
					paramObj.put("ApplicationStartDate", "");
					paramObj.put("ApplicationFinishDate", "");
					paramObj.put("ApplicationAmount", "");
					paramObj.put("ApplicationReason", bodyContext.getString("application_reason"));
				} else if(bodyContext.optString("card_application_type").equals("PublicCardRequest")) {
					paramObj.put("CardNo", "");
					paramObj.put("CardCompany", "");
					paramObj.put("ReissuanceType", "");
					paramObj.put("LimitType", "");
					paramObj.put("LimitAmountType", "");
					paramObj.put("LimitAmount", "");
					paramObj.put("ChangeExpirationDate", "");
					paramObj.put("ApplicationStartDate", bodyContext.getString("start_date"));
					paramObj.put("ApplicationFinishDate", bodyContext.getString("end_date"));
					paramObj.put("ApplicationAmount", bodyContext.getString("application_amount"));
					paramObj.put("ApplicationReason", bodyContext.getString("application_reason"));
				} else if(bodyContext.optString("card_application_type").equals("PrCardApp")) {
					paramObj.put("CardNo", bodyContext.getString("card_num"));
					paramObj.put("CardCompany", bodyContext.getString("card_company"));
					paramObj.put("ReissuanceType", "");
					paramObj.put("LimitType", "");
					paramObj.put("LimitAmountType", "");
					paramObj.put("LimitAmount", "");
					paramObj.put("ChangeExpirationDate", "");
					paramObj.put("ApplicationStartDate", "");
					paramObj.put("ApplicationFinishDate", "");
					paramObj.put("ApplicationAmount", "");
					paramObj.put("ApplicationReason", bodyContext.getString("application_reason"));
				}
				
				String cardAppObj = paramObj.toString();
				CoviMap accountParam = new CoviMap();
				accountParam.put("cardAppObj", cardAppObj);

				HttpsUtil httpsUtil = new HttpsUtil();
		    	httpsUtil.httpsClientWithRequest(httpCommURL, "POST", accountParam, "UTF-8", null);
		    	
				resultList.put("status",	Return.SUCCESS);
			} catch(NullPointerException npE) {
				throw npE;
			} catch(Exception e) {
				throw e;		
			}
		}
		
		return resultList;
	}
	
	/**
	 * @Method saveBizTripRequestInfo 
	 * @param params
	 * @throws Exception
	 */
	public CoviMap saveBizTripRequestInfo(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap bodyContext = CoviMap.fromObject(params.getString("bodyContext"));
		String formInstanceID = params.getString("formInstID");
		String processID = params.getString("processID");
		String ur_Code = params.getString("approverId");
		String comment = params.getString("comment");
		
		String apvState = params.getString("apvMode");
		switch (apvState) {
		case "DRAFT":
			apvState = "D";
			break;
		case "COMPLETE":
			apvState = "E";
			break;
		case "REJECT":
			apvState = "R";
			break;
		case "OTHERSYSTEM":
			apvState = "P";
			break;
		case "ABORT":
		case "WITHDRAW":
			apvState = "C";
			break;
		case "CHARGEDEPT":
			apvState = "DC";
			break;
		default:
			break;
		}		    	
		
		CoviMap paramObj = new CoviMap();
		paramObj.put("ApplicationStatus", apvState);
		paramObj.put("FormInstanceID", formInstanceID);
		paramObj.put("ProcessID", processID);
		paramObj.put("UR_CODE", ur_Code);
		paramObj.put("Comment", comment);
		paramObj.put("SessionUser", ur_Code);
		paramObj.put("setStatus", apvState); //이후 연동 용
		
		try {
	    	String accountURL = PropertiesUtil.getGlobalProperties().getProperty("account.legacy.path");
			String httpCommURL = accountURL;			
			httpCommURL += "/bizTrip/saveBizTripRequestData.do"; 

			paramObj.put("BizTripType", bodyContext.getString("rdo_type_biztrip"));
			paramObj.put("ProjectCode", bodyContext.getString("PROJECT_NAME"));
			paramObj.put("ProjectName", bodyContext.getString("PROJECT_NAME_TEXT"));
			paramObj.put("RequestTitle", bodyContext.getString("Subject"));
			paramObj.put("RequestStatus", apvState);
			paramObj.put("RequestDate", bodyContext.getString("InitiatedDate"));
			paramObj.put("RequesterDeptID", bodyContext.getString("InitiatorOUCodeDisplay"));
			paramObj.put("RequesterDeptName", bodyContext.getString("InitiatorOUDisplay"));
			paramObj.put("RequesterID", bodyContext.getString("InitiatorCodeDisplay"));
			paramObj.put("RequesterName", bodyContext.getString("InitiatorDisplay"));
			paramObj.put("BusinessAreaType", bodyContext.getString("rdo_type_area"));
			paramObj.put("BusinessArea", bodyContext.getString("t_area"));
			paramObj.put("BusinessPurpose", bodyContext.getString("t_purpose"));
			paramObj.put("StartDate", bodyContext.getString("SDATE"));
			paramObj.put("EndDate", bodyContext.getString("EDATE"));
			paramObj.put("BusinessDay", bodyContext.getString("DAYS"));
			paramObj.put("WorkingDay", bodyContext.getString("working_day"));
			paramObj.put("RequestAmount", bodyContext.getString("a_sum_6")); //예상경비 총 합계
			
			String bizTripRequestDataObj = paramObj.toString();
			CoviMap accountParam = new CoviMap();
			accountParam.put("bizTripRequestDataObj", bizTripRequestDataObj);

			HttpsUtil httpsUtil = new HttpsUtil();
	    	httpsUtil.httpsClientWithRequest(httpCommURL, "POST", accountParam, "UTF-8", null);
	    	
			resultList.put("status",	Return.SUCCESS);
		} catch(NullPointerException npE) {
			throw npE;
		} catch(Exception e) {
			throw e;
		}
		
		return resultList;
	}
	
	/* 
	 * 사외접속 신청서(본사용)
	 * 매개변수(spParams)
	 * formPrefix
	 * bodyContext
	 * formInfoExt
	 * approvalContext
	 * preApproveprocsss
	 * apvResult
	 * docNumber
	 * approverId
	 * formInstID
	 * apvMode
	 * processID
	 * formHelperContext
	 * formNoticeContext
	 */
	@Override
	public void execWF_EXTERNAL_ACCESS_REQ(CoviMap spParams) throws Exception {		
		try{
			CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));

			if(spParams.optString("apvMode").equals("COMPLETE")){
                CoviMap params = new CoviMap();
				
                params.put("UserCode", bodyContext.getString("hidUR_Code")); // 사용자 코드
				params.put("SDATE", bodyContext.getString("SDATE")); // 시작일
				params.put("EDATE", bodyContext.getString("EDATE")); // 종료일
				params.put("GUBUN", bodyContext.getString("VDI_TYPE")); // OLD: 기존유지, NEW: 신규생성, DEL: 불필요				
				params.put("FIID", spParams.getInt("formInstID"));
				
				coviMapperOne.insert("legacy.formCmmFunction.insertConnectReqList", params);
			}
		} catch(NullPointerException npE) {
			throw npE;
		} catch(Exception e){
        	throw e;
		}
	}
	
	@Override
	@SuppressWarnings("unchecked")
	public CoviMap callOtherService(String params, String bodyContext, String DN_Code) throws Exception {
		CoviMap result = new CoviMap();
		StringUtil func = new StringUtil();
		
		String sURL = PropertiesUtil.getGlobalProperties().getProperty("form.legacy.path");
		String sConnectTimeout = PropertiesUtil.getGlobalProperties().getProperty("form.legacy.connectTimeout");
		String sReadTimeout = PropertiesUtil.getGlobalProperties().getProperty("form.legacy.readTimeout");
		int connectTimeout = 2000;
		int readTimeout = 3000;
		
		if(StringUtils.isNoneBlank(sConnectTimeout)) connectTimeout = Integer.parseInt(sConnectTimeout);
		if(StringUtils.isNoneBlank(sReadTimeout)) readTimeout = Integer.parseInt(sReadTimeout);
		
		if (StringUtils.isNotBlank(sURL)) {
			HttpURLConnection conn = null;
			BufferedReader br = null;
			OutputStream os = null;
			
			try {
				// SaaS 인경우 context path 가 회사별로 구분됨
				sURL = String.format(sURL, DN_Code.toLowerCase());
				
				URL url = new URL(sURL);
				conn = (HttpURLConnection) url.openConnection();
				conn.setDoOutput(true);
				conn.setRequestMethod("POST");
				conn.setRequestProperty("Content-Type", "application/x-www-form-urlencode");
				conn.setConnectTimeout(connectTimeout);
		        conn.setReadTimeout(readTimeout);
		        
				CoviMap input = new CoviMap();
				input.put("LegacyInfo", params);
				input.put("BodyContext", bodyContext);
				
				os = conn.getOutputStream();
				os.write(input.toString().getBytes(StandardCharsets.UTF_8));
				os.flush();
		
				if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
					if(conn.getResponseCode() == HttpURLConnection.HTTP_MOVED_TEMP) {
						String redirectedUrl = conn.getHeaderField("Location");
			            throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode() + ", redirectedURL: " + redirectedUrl);
					}
					else {
						throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode());
					}
				}
	
				// get result	
				try {
					br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
				} catch (FileNotFoundException e) {
					throw new FileNotFoundException("FileNotFound");
				} catch (IOException ioE) {
					throw ioE;
				} catch (Exception ex) {
					throw ex;
				}
				
				String inputLine = "";
				StringBuffer response = new StringBuffer();
				while (!func.f_NullCheck(inputLine = br.readLine()).equals("")) {
				    response.append(inputLine);
				}
	
				if(response.length() != 0){
					JSONParser parser = new JSONParser();
					Object returnedObj = parser.parse(response.toString());
					result.put("result", returnedObj);
					
					if(result.getJSONObject("result").optString("status").equalsIgnoreCase("FAIL")) {
						throw new RuntimeException(result.getJSONObject("result").getString("message"));
					}
				}
			} catch(NullPointerException npE) {
				throw npE;
			} catch(IOException ioE) {
				throw ioE;
			} catch(Exception e) {
				throw e;
			} finally {
				if(br != null) {
					try {
						br.close();
					}catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
				if(os != null) {
					try {
						os.close();
					}catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
				if(conn != null) {
					try{
						conn.disconnect();
					}catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
			}
		}
		
		return result;
	}

	@Override
	public void execAttendance(CoviMap spParams) throws Exception {		
		try{
			CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
			String jobStsName = "";
			
			if(spParams.optString("formPrefix").equalsIgnoreCase("WF_FORM_HOLIDAY_WORK")) { //휴일
				jobStsName = "H";
			} else { //연장
				jobStsName = "O";
			}
			
	        if(spParams.optString("apvMode").equals("COMPLETE")){
	        	CoviMap param = new CoviMap();
	    		param.put("FormInstID", spParams.getInt("formInstID"));
	    		CoviMap formInstData = coviMapperOne.select("legacy.formCmmFunction.selectFormInstData", param);
	        	
	        	CoviList ja = new CoviList();
	        	if (bodyContext.get("TBL_WORK_INFO") instanceof CoviMap) {
	        		ja.add(bodyContext.getJSONObject("TBL_WORK_INFO"));
	        	} else {
	        		ja = bodyContext.getJSONArray("TBL_WORK_INFO");
	        	}
	        	
	        	for (int i=0; i<ja.size(); i++) {
	        		CoviMap jo = ja.getJSONObject(i);
	        		param.put("UserCode", jo.getString("UserCode")); //사용자코드
	        		param.put("JobDate", jo.getString("JobDate")); //근무일
	        		param.put("JobStsName", jobStsName); //근무유형(연장/휴일)
	        		param.put("StartTime", jo.getString("StartTime").replace(":", "")); //시작시간
	        		param.put("EndTime", jo.getString("EndTime").replace(":", "")); //종료시간
	        		param.put("WorkTime", jo.getString("WorkTime").replace(":", "")); //근무인정시간
	        		param.put("Etc", jo.getString("Etc")); //비고
	        		param.put("BillName", formInstData.getString("Subject"));//걸재제목
	        		param.put("ProcessId", spParams.getString("processID"));//processid
	        		param.put("FormInstId", spParams.getInt("formInstID"));//formid
	        		param.put("CompanyCode", jo.getString("CompanyCode"));//회사코드
	        		param.put("RegisterCode", spParams.getString("approverId")); //등록자ID
	        		
	        		if(jobStsName.equals("O")) {
	        			param.put("IdleTime", jo.getString("IdleTime")); //유휴시간
	        		}
	        		
	        		coviMapperOne.insert("legacy.formCmmFunction.insertAttendanceMngExtensionHoliday", param);        			
	        	}
	        }
		}catch(NullPointerException npE){
        	throw npE;
		}catch(Exception e){
        	throw e;
		}
	}
	
	//근태관리 휴무일 체크
	@Override
	public CoviList attendanceHolidayCheck(CoviMap params) throws Exception {
		CoviList returnArr = new CoviList();
		CoviList workInfo = CoviList.fromObject(params.getString("workInfo"));
		
		for(Object obj : workInfo){
			CoviMap workInfoObj = (CoviMap)obj;
			
			CoviMap paramMap = new CoviMap();
			paramMap.put("UserCode", workInfoObj.getString("UserCode"));
			paramMap.put("CompanyCode", workInfoObj.getString("CompanyCode"));
			paramMap.put("TargetDate", workInfoObj.getString("JobDate"));
			
			String isHoliday = coviMapperOne.selectOne("legacy.formCmmFunction.selectAttendanceHolidayCheck", paramMap);
			
			if(!isHoliday.split("/")[0].equals("H")) {
				returnArr.add(workInfoObj);
			}
		}
		
		return returnArr;
	}	
	
	//근태관리 주 52시간 체크
	@Override
	public CoviList attendanceWorkTimeCheck(CoviMap params) throws Exception {
		CoviList returnArr = new CoviList();
		CoviList workInfo = CoviList.fromObject(params.getString("workInfo"));
		
		for(Object obj : workInfo){
			CoviMap workInfoObj = (CoviMap)obj;
//			int dayOfWeek = DateHelper.getDayOfWeek(workInfoObj.getString("JobDate"), "yyyy-MM-dd");
			
			CoviMap paramMap = new CoviMap();
			paramMap.put("UserCode", workInfoObj.getString("UserCode"));
			paramMap.put("CompanyCode", workInfoObj.getString("CompanyCode"));
			paramMap.put("TargetDate", workInfoObj.getString("JobDate"));
			paramMap.put("StartTime", workInfoObj.getString("StartTime").replaceAll( "[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]", ""));
			paramMap.put("EndTime", workInfoObj.getString("EndTime").replaceAll( "[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]", ""));
			paramMap.put("orgProcessId", params.getString("orgProcessId"));
//			workInfoObj.put("sWeekDate", DateHelper.getAddDate(workInfoObj.getString("JobDate"), "yyyy-MM-dd", 1-dayOfWeek, Calendar.DATE));
//			workInfoObj.put("eWeekDate", DateHelper.getAddDate(workInfoObj.getString("JobDate"), "yyyy-MM-dd", 7-dayOfWeek, Calendar.DATE));
			workInfoObj.put("workTimeCheck", coviMapperOne.selectOne("legacy.formCmmFunction.selectAttendanceWorkTimeCheck", paramMap));
			
			returnArr.add(workInfoObj);
		}
		
		return returnArr;
	}	
	
	@Override
	public CoviMap attendanceWorkTimeCheckOne(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap paramMap = new CoviMap();
//		int dayOfWeek = DateHelper.getDayOfWeek(params.getString("TargetDate"), "yyyy-MM-dd");
		
		paramMap.put("UserCode", params.getString("UserCode"));
		paramMap.put("CompanyCode", params.getString("CompanyCode"));
		paramMap.put("TargetDate", params.getString("TargetDate"));
		paramMap.put("StartTime", params.getString("StartTime").replaceAll( "[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]", ""));
		paramMap.put("EndTime", params.getString("EndTime").replaceAll( "[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]", ""));
		paramMap.put("orgProcessId", params.getString("orgProcessId"));
		
//		returnObj.put("sWeekDate", DateHelper.getAddDate(params.getString("TargetDate"), "yyyy-MM-dd", 1-dayOfWeek, Calendar.DATE));
//		returnObj.put("eWeekDate", DateHelper.getAddDate(params.getString("TargetDate"), "yyyy-MM-dd", 7-dayOfWeek, Calendar.DATE));
		returnObj.put("workTimeCheck", coviMapperOne.selectOne("legacy.formCmmFunction.selectAttendanceWorkTimeCheck", paramMap));
		
		return returnObj;
	}	
	
	@Override
	public String attendanceHolidayCheckOne(CoviMap params) throws Exception {
		String isHoliday = "";
		CoviMap paramMap = new CoviMap();
		
		paramMap.put("UserCode", params.getString("UserCode"));
		paramMap.put("CompanyCode", params.getString("CompanyCode"));
		paramMap.put("TargetDate", params.getString("TargetDate"));
		
		isHoliday = coviMapperOne.selectOne("legacy.formCmmFunction.selectAttendanceHolidayCheck", paramMap);
		
		return isHoliday;
	}

	@Override
	public int attendDayJobCheck(CoviMap params) throws Exception {
		int checkJob = 0;

		checkJob = coviMapperOne.selectOne("legacy.formCmmFunction.attendDayJobCheck", params);

		return checkJob;
	}
	
	@Override
	public void execCall(CoviMap spParams) throws Exception { //소명신청서
		try{
			CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));

			
	        if(spParams.optString("apvMode").equals("COMPLETE")){	        	
	        	CoviList ja = new CoviList();
	        	if (bodyContext.get("TBL_CALL_INFO") instanceof CoviMap) {
	        		ja.add(bodyContext.getJSONObject("TBL_CALL_INFO"));
	        	} else {
	        		ja = bodyContext.getJSONArray("TBL_CALL_INFO");
	        	}
	        	
	        	for (int i=0; i<ja.size(); i++) {
	        		CoviMap paramso = new CoviMap();
	        		CoviMap jo = ja.getJSONObject(i);
	        		paramso.put("UserCode", jo.getString("UserCode")); //사용자코드
	        		paramso.put("CallDate", jo.getString("CallDate")); //근무일
	        		if(jo.optString("Division").equals("출근시간")){  
	        			paramso.put("StartTime",jo.getString("hour")+jo.getString("min"));
	        		}else{
	        			paramso.put("EndTime",jo.getString("hour")+jo.getString("min"));
	        		}
	        		paramso.put("CompanyCode", jo.getString("CompanyCode"));
	        		paramso.put("Etc", jo.getString("Etc"));  //소명내용
	        		paramso.put("Subject", bodyContext.getString("Subject"));  //결재문서명
	        		paramso.put("processID", spParams.getInt("processID"));  //ProcessID
	        		paramso.put("FormID", spParams.getInt("formInstID"));  //FormID
	        		if(jo.containsKey("changeDate")){
	        			paramso.put("changeDate", jo.getString("changeDate")); //변경 날짜
	        		}else{
	        			paramso.put("changeDate", "");
	        		}	        
	        		
	        		coviMapperOne.insert("legacy.formCmmFunction.insertAttendanceSetCommute", paramso);        			
	        	}
	        }
		}catch(NullPointerException npE){
        	throw npE;
		}catch(Exception e){
        	throw e;
		}
		
	}

	@Override
	public String attendanceCommuteTime(CoviMap params) throws Exception {
		String commuteTime ="";
		CoviMap paramMap = new CoviMap();
		
		paramMap.put("UserCode", params.getString("UserCode"));
		paramMap.put("CompanyCode", params.getString("CompanyCode"));
		paramMap.put("TargetDate", params.getString("TargetDate"));
		paramMap.put("Division", params.getString("Division"));
		
		commuteTime = coviMapperOne.selectOne("legacy.formCmmFunction.selectAttendanceCommuteTime",paramMap);
		
		return commuteTime;
	}
	
	// 사업관리 프로젝트 코드 신청서만 발번규칙 변경함.
	@Override
	public CoviMap execWF_FORM_BIZMNT_PROJECTCODE(CoviMap spParams) throws Exception {
		CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
		CoviMap jsonBody = CoviMap.fromObject(bodyContext.getString("JSONBody"));
		String htmlBody = bodyContext.getString("HTMLBody");
		String mobileBody = "";
        
        CoviMap result = new CoviMap();
        String strResult = "";
        String projectCode = "";
        int projectNo = -1;
        
        String DivCd_Origin = "";
        
        try
        {
        	if(spParams.optString("apvMode").equals("COMPLETE")){
	        	// 변경 전 업무 타입 : MP(프로젝트), CP(프로젝트), HB(하랑-구축형), HI(하랑-IDC형), MA(유지보수), AD(Add-In),  RD(R&D), GE(회사일반), SA(Sales)
	            // 변경 후 업무 타입 : PJ(프로젝트), HR(하랑), MA(유지보수), AD(Add-In), RD(R&D), GE(회사일반), SA(Sales), WH(위하랑), HE(하랑E.IDC)
	        	
	        	// 번호대 5자리로 변경됨 [2017-04-28] 박경연
	        	switch(jsonBody.getString("projDivCd")){
	        	case "PJ": //프로젝트
	        	case "HR": //하랑
	        	case "WH": //위하랑
	        	case "HE": //하랑E.IDC, 2023.07.31 추가. hyungyu
	        	case "AD": //Add-In
	        		DivCd_Origin = "P";
	        		break;
	        	case "MA": //유지보수
	        		DivCd_Origin = "C";
	        		break;
	        	case "RD": //R&D
	        		DivCd_Origin = "R";
	        		break;
	        	case "GE": //회사일반
	        		DivCd_Origin = "G";
	        		break;
	        	case "SA": //Sales
	        		DivCd_Origin = "S";
	        		break;
        		default:
	        	}
	        	
    			String workReportURL = PropertiesUtil.getGlobalProperties().getProperty("groupware.legacy.path");
        		HttpsUtil httpsUtil = new HttpsUtil();
        		CoviMap workReportParam = new CoviMap();
            	
    			// 자바 업무보고 프로젝트 코드 INSERT
        		String httpCommURL = workReportURL+"/workreport/workreportjobwrite_approval.do";
        		workReportParam.put("jobName", jsonBody.getString("projNm").replace("'","''"));
        		workReportParam.put("jobDivision", DivCd_Origin);
        		workReportParam.put("useYN", "Y");
        		workReportParam.put("managerCode", jsonBody.getString("pmUserId"));
        		workReportParam.put("startDate", jsonBody.getString("startDt"));
        		workReportParam.put("endDate", jsonBody.getString("endDt"));
        		workReportParam.put("creatorCode", bodyContext.getString("InitiatorCodeDisplay"));
        		// 항목 추가
        		workReportParam.put("ProjectDivCode", jsonBody.getString("projDivCd"));
        		workReportParam.put("MappingID", 0); // MP에서 발번된 5자리 숫자 프로젝트 코드
        		
        		strResult = httpsUtil.httpsClientWithRequest(httpCommURL, "POST", workReportParam, "UTF-8", null);
        		projectCode = CoviMap.fromObject(strResult).getString("result");
        		result.put("projectCd", projectCode);
        		result.put("projectNm", workReportParam.getString("jobName"));
        		
        		// bodycontext 에 코드 업데이트
        		jsonBody.remove("projCd");
        		jsonBody.put("projCd", projectCode);
        		bodyContext.put("HTMLBody", htmlBody.replace("(※ 결재완료시 자동발부 됩니다.)", projectCode));
        		
        		if(bodyContext.has("MobileBody"))
        			bodyContext.put("MobileBody", mobileBody.replace("(※ 결재완료시 자동발부 됩니다.)", projectCode));
        		
        		CoviMap params = new CoviMap();
        		params.put("FormInstID", spParams.getString("formInstID"));
        		params.put("BodyContext", new String(Base64.encodeBase64(bodyContext.toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
        		coviMapperOne.update("admin.adminDocumentInfo.updateJwf_forminstanceData", params);
        	}        	
        }catch(NullPointerException npE){
        	execBizUpdateStatus_FAIL(spParams);
        	throw npE;
		}catch(Exception e){
        	execBizUpdateStatus_FAIL(spParams);
        	throw e;
		}
		
        return result;
	}
	
	@Override
	public void execBizUpdateStatus(CoviMap spParams) throws Exception {
		CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
		String apvState = spParams.getString("apvMode");
		
		String sURL = PropertiesUtil.getGlobalProperties().getProperty("bizmnt.legacy.path") + "/approval/updateStatus.do";
		
		switch (apvState) {
			case "DRAFT": // 기안
				apvState = "D";
				break;
			case "COMPLETE": // 완료
				apvState = "E";
				break;
			case "REJECT": // 반려
				apvState = "R";
				break;
			case "OTHERSYSTEM":
				break;
			case "ABORT":
			case "WITHDRAW": // 회추, 기안취소
				apvState = "C";
				break;
			case "CHARGEDEPT":
				break;
			default:
				break;
		}
		
		String inputParams = "";
		inputParams += "status=" + apvState;
		inputParams += "&key="+ bodyContext.getString("ERPKey");
		inputParams += "&processId=" + spParams.getString("processID");
		inputParams += "&approverId=" + spParams.getString("approverId");
		inputParams += "&orderNo=" + URLEncoder.encode(spParams.getString("docNumber"), "utf-8");
		
		if(spParams.containsKey("projectCd") && apvState.equals("E")) {
			inputParams += "&projectCd=" + spParams.getString("projectCd");
			inputParams += "&jobNo=" + spParams.getString("jobNo");
		}
				
		HttpURLConnectUtil url = new HttpURLConnectUtil();
		url.httpURLConnect(sURL, "POST", 15000, 10000, inputParams, "");	 
		
		// 연동 실패 시, 다시한번 상태값 F 로 업데이트 & throw
		if(url.getResponseType().equalsIgnoreCase("FAIL")) {
		//if(true) {
			inputParams = "";
			inputParams += "status=" + "F"; // 오류
			inputParams += "&key="+ bodyContext.getString("ERPKey");
			inputParams += "&processId=" + spParams.getString("processID");
			inputParams += "&approverId=" + spParams.getString("approverId");
			inputParams += "&orderNo=" + URLEncoder.encode(spParams.getString("docNumber"), "utf-8");
					
			HttpURLConnectUtil url2 = new HttpURLConnectUtil();
			url2.httpURLConnect(sURL, "POST", 15000, 10000, inputParams, "");	 
			
			throw new Exception("사업관리 - 상태값 연동 오류\n" + url.getResponseMessage());
		}
	}
	
	@Override
	public void execCrmUpdateStatus(CoviMap spParams) throws Exception {
		CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
		String apvState = spParams.getString("apvMode");
		
		String sURL = PropertiesUtil.getGlobalProperties().getProperty("crm.legacy.path") + "/approval/updateStatus.do";
		
		switch (apvState) {
			case "DRAFT": // 기안
				apvState = "D";
				break;
			case "COMPLETE": // 완료
				apvState = "E";
				break;
			case "REJECT": // 반려
				apvState = "R";
				break;
			case "OTHERSYSTEM":
				break;
			case "ABORT":
			case "WITHDRAW": // 회추, 기안취소
				apvState = "C";
				break;
			case "CHARGEDEPT":
				break;
			default:
				break;
		}
		
		String inputParams = "";
		inputParams += "status=" + apvState;
		inputParams += "&key="+ bodyContext.getString("ERPKey");
		inputParams += "&processId=" + spParams.getString("processID");
		inputParams += "&approverId=" + spParams.getString("approverId");
		inputParams += "&orderNo=" + URLEncoder.encode(spParams.getString("docNumber"), "utf-8");
		
		if(spParams.containsKey("projectCd") && apvState.equals("E")) {
			inputParams += "&projectCd=" + spParams.getString("projectCd");
			inputParams += "&jobNo=" + spParams.getString("jobNo");
		}
				
		HttpURLConnectUtil url = new HttpURLConnectUtil();
		url.httpURLConnect(sURL, "POST", 15000, 10000, inputParams, "");	 
		
		// 연동 실패 시, 다시한번 상태값 F 로 업데이트 & throw
		if(url.getResponseType().equalsIgnoreCase("FAIL")) {
		//if(true) {
			inputParams = "";
			inputParams += "status=" + "F"; // 오류
			inputParams += "&key="+ bodyContext.getString("ERPKey");
			inputParams += "&processId=" + spParams.getString("processID");
			inputParams += "&approverId=" + spParams.getString("approverId");
			inputParams += "&orderNo=" + URLEncoder.encode(spParams.getString("docNumber"), "utf-8");
					
			HttpURLConnectUtil url2 = new HttpURLConnectUtil();
			url2.httpURLConnect(sURL, "POST", 15000, 10000, inputParams, "");	 
			
			throw new Exception("CRM - 상태값 연동 오류\n" + url.getResponseMessage());
		}
	}
	
	// 사업관리 시스템 상태값만 ERROR로 업데이트 하는 함수
	public void execBizUpdateStatus_FAIL(CoviMap spParams) throws Exception {
		CoviMap bodyContext = CoviMap.fromObject(spParams.getString("bodyContext"));
		
		String sURL = PropertiesUtil.getGlobalProperties().getProperty("bizmnt.legacy.path") + "/approval/updateStatus.do";
				
		// 연동 실패 시, 다시한번 상태값 F 로 업데이트 & throw
		String inputParams = "";
		inputParams += "status=" + "F"; // 오류
		inputParams += "&key="+ bodyContext.getString("ERPKey");
		inputParams += "&processId=" + spParams.getString("processID");
		inputParams += "&orderNo=" + URLEncoder.encode(spParams.getString("docNumber"), "utf-8");
				
		HttpURLConnectUtil url2 = new HttpURLConnectUtil();
		url2.httpURLConnect(sURL, "POST", 15000, 10000, inputParams, "");
	}
	
	@Override
	public void execEAccountInsertProjectCode(CoviMap spParams) throws Exception {
		String accountURL = PropertiesUtil.getGlobalProperties().getProperty("account.legacy.path");
		String sURL = accountURL + "/baseCode/insertProjectCode.do";
				
		String inputParams = "";
		if(spParams.containsKey("projectCd") && spParams.containsKey("projectNm")) {
			inputParams += "projectCd=" + spParams.getString("projectCd");
			inputParams += "&projectNm=" + URLEncoder.encode(spParams.getString("projectNm"), "utf-8");
			
			HttpURLConnectUtil url = new HttpURLConnectUtil();
			url.httpURLConnect(sURL, "POST", 15000, 10000, inputParams, "");
		}	 
	}
	
	@Override
	public CoviMap getBaseCodeList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("legacy.formCmmFunction.selectBaseCodeList", params);
		
		CoviMap returnJo = new CoviMap();
		   
		returnJo.put("list",CoviSelectSet.coviSelectJSON(list, "Code,CodeName"));
		
		return returnJo;
	}
	
	@Override
	public void execAttendRequest(CoviMap spParams) throws Exception {
		try{
			String formPrefix = spParams.getString("formPrefix");
			boolean bSend=true;
			boolean bUpdateProcessVac = false;
			int WorkItemID =0;
			switch (formPrefix){
		        case "WF_FORM_CALL": //소명신청서
		        case "WF_FORM_HOLIDAY_WORK": //휴일근무신청서
				case "HOLIDAY_REPLACEMENT_WORK": //휴일대체근무신청서
		        case "WF_FORM_OVERTIME_WORK": //연장근무신청서
		        	if(!spParams.optString("apvMode").equals("COMPLETE")) {
		        		bSend = false;
		        	}
		        	break;
				 case "WF_FORM_VACATION_REQUEST2": // 휴가신청
				 case "WF_FORM_VACATIONCANCEL": // 휴가 취소 신청서
		        	if(!spParams.optString("apvMode").equals("COMPLETE") || !RedisDataUtil.getBaseConfig("VACATION_INERLOCK","1").equals("Y")) {
		        		bSend = false;
		        	}
		        	else{
		        		spParams.put("FormInstID", spParams.getInt("formInstID"));
		        		CoviMap formVacData = coviMapperOne.select("legacy.formCmmFunction.selectFormInstDataForVac", spParams);
		        		WorkItemID =formVacData.getInt("WorkItemID");
		        	}
		        	if(!spParams.optString("apvMode").equals("COMPLETE")) {
		        		bUpdateProcessVac = true;
		        	}
		        	break;
		        default:
		        	break;
			}
			if(bSend || bUpdateProcessVac){
				String sURL =PropertiesUtil.getGlobalProperties().getProperty("groupware.legacy.path") + "/attendAPI/requestApproval.do";
				
				CoviMap param = new CoviMap();
	    		param.put("FormInstID", spParams.getInt("formInstID"));
	    		CoviMap formInstData = coviMapperOne.select("legacy.formCmmFunction.selectFormInstData", param);
	    		//new String( Base64.encodeBase64( bodyContext.toString().getBytes() ) ) 
	    		
	    		String inputParams = "formPrefix="+spParams.getString("formPrefix");
				inputParams += "&bodyContext="+  URLEncoder.encode(new String(Base64.encodeBase64(spParams.getString("bodyContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8), "UTF-8");
	
				inputParams += "&BillName=" +   URLEncoder.encode(formInstData.getString("Subject"), "UTF-8");
				inputParams += "&ProcessId="+ spParams.getString("processID");
				inputParams += "&FormInstId=" + spParams.getString("formInstID");
				inputParams += "&RegisterCode=" + spParams.getString("approverId");
				inputParams += "&ApvMode=" + spParams.getString("apvMode");
				inputParams += "&WorkItemId=" + WorkItemID;
				
				HttpURLConnectUtil url2 = new HttpURLConnectUtil();
				url2.httpURLConnect(sURL, "POST", 15000, 10000, inputParams, "");
			}
		}catch(NullPointerException npE){
        	throw npE;
		}catch(Exception e){
        	throw e;
		}
	}
	
	@Override
	public CoviList getProjectName(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("legacy.formCmmFunction.selectProjectName", params);
		return CoviSelectSet.coviSelectJSON(list, "JOB_NO,JOB_NM,JOB_STATE_CD");
	}

	@Override
	public CoviMap saveCapitalResolution(CoviMap params) throws Exception {

		CoviMap resultList = new CoviMap();
		
		CoviMap bodyContext = CoviMap.fromObject(params.getString("bodyContext"));
		String processID = params.getString("processID");
		String formInstId = params.getString("formInstID");
		String strRealPayDate = bodyContext.getString("real_pay_date").replace("-", "");
		String strCorpCardAmount = bodyContext.getString("corpcard_sum");
		long corpCardAmount = Long.parseLong(strCorpCardAmount.replace(",", ""));
		String strAutoAmount = bodyContext.getString("auto_sum");
		long autoAmount = Long.parseLong(strAutoAmount.replace(",", ""));
		String strNormalAmount = bodyContext.getString("normal_sum");
		long normalAmount = Long.parseLong(strNormalAmount.replace(",", ""));
		String strCashAmount = bodyContext.getString("cash_sum");
		long cashAmount = Long.parseLong(strCashAmount.replace(",", ""));
		String strAccountAmount = bodyContext.getString("account_sum");
		long accountAmount = Long.parseLong(strAccountAmount.replace(",", ""));
		String strRealPayAmount = bodyContext.getString("total_sum");
		long realPayAmount = Long.parseLong(strRealPayAmount.replace(",", ""));

		CoviMap paramObj = new CoviMap();
		paramObj.put("FormInstId",formInstId);
		paramObj.put("ProcessId",processID);
		paramObj.put("RealPayDate", strRealPayDate);
		paramObj.put("CorpCardAmount", corpCardAmount);
		paramObj.put("AutoAmount", autoAmount);
		paramObj.put("NormalAmount", normalAmount);
		paramObj.put("CashAmount", cashAmount);
		paramObj.put("AccountAmount", accountAmount);
		paramObj.put("RealPayAmount", realPayAmount);
		
		try {
			coviMapperOne.insert("legacy.formCmmFunction.insertCapitalResolution", paramObj);
			
			resultList.put("status",	Return.SUCCESS);
		} catch(NullPointerException npE){
        	throw npE;
		} catch(Exception e) {
			throw e;
		}
		
		return resultList;
	}

	// 연장 / 휴일 근무시간
	@Override
	public CoviList attendanceRealWorkInfo(CoviMap params) throws Exception {
		CoviList returnArr = new CoviList();

		CoviList paramsArr = CoviList.fromObject(params.getString("paramsArr"));

		for(Object obj : paramsArr){
			CoviMap paramObj = (CoviMap)obj;

			CoviMap paramMap = new CoviMap();
			paramMap.put("UserName", paramObj.getString("UserName"));
			paramMap.put("UserCode", paramObj.getString("UserCode"));
			paramMap.put("JobDate", paramObj.getString("JobDate"));
			paramMap.put("CompanyCode", paramObj.getString("CompanyCode"));
			paramMap.put("ReqType", paramObj.getString("ReqType"));
			CoviMap returnMap = coviMapperOne.selectOne("legacy.formCmmFunction.attendanceRealWorkInfo", paramMap);

			if (returnMap != null) {
				paramObj.put("RealWorkInfo", CoviSelectSet.coviSelectMapJSON(returnMap));
			} else {
				paramObj.put("RealWorkInfo", null);
			}
			returnArr.add(paramObj);
		}

		return returnArr;
	}

	@Override
	@SuppressWarnings("unchecked")
	public CoviMap execHrManage(String params, String bodyContext) throws Exception {
		CoviMap result = new CoviMap();
		StringUtil func = new StringUtil();
		
		String sURL = PropertiesUtil.getGlobalProperties().getProperty("hrmanage.legacy.path") + "/hrCommon/executeLegacy.do";
		String sConnectTimeout = PropertiesUtil.getGlobalProperties().getProperty("form.legacy.connectTimeout");
		String sReadTimeout = PropertiesUtil.getGlobalProperties().getProperty("form.legacy.readTimeout");
		int connectTimeout = 2000;
		int readTimeout = 3000;
		
		if(StringUtils.isNoneBlank(sConnectTimeout)) connectTimeout = Integer.parseInt(sConnectTimeout);
		if(StringUtils.isNoneBlank(sReadTimeout)) readTimeout = Integer.parseInt(sReadTimeout);
		
		if (StringUtils.isNotBlank(sURL)) {
			HttpURLConnection conn = null;
			BufferedReader br = null;
			OutputStream os = null;
			
			try {							
				URL url = new URL(sURL);
				conn = (HttpURLConnection) url.openConnection();
				conn.setDoOutput(true);
				conn.setRequestMethod("POST");
				conn.setRequestProperty("Content-Type", "application/x-www-form-urlencode");
				conn.setConnectTimeout(connectTimeout);
		        conn.setReadTimeout(readTimeout);
		        
				CoviMap input = new CoviMap();
				input.put("HrmanageInfo", params);
				input.put("BodyContext", bodyContext);
				
				os = conn.getOutputStream();
				os.write(input.toString().getBytes(StandardCharsets.UTF_8));
				os.flush();
		
				if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
					if(conn.getResponseCode() == HttpURLConnection.HTTP_MOVED_TEMP) {
						String redirectedUrl = conn.getHeaderField("Location");
			            throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode() + ", redirectedURL: " + redirectedUrl);
					}
					else {
						throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode());
					}
				}
	
				// get result	
				try {
					br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
				} catch (FileNotFoundException e) {
					throw new FileNotFoundException("FileNotFound");
				} catch (IOException ioE) {
					throw ioE;
				} catch (Exception ex) {
					throw ex;
				}
				
				String inputLine = "";
				StringBuffer response = new StringBuffer();
				while (!func.f_NullCheck(inputLine = br.readLine()).equals("")) {
				    response.append(inputLine);
				}
	
				if(response.length() != 0){
					JSONParser parser = new JSONParser();
					Object returnedObj = parser.parse(response.toString());
					result.put("result", returnedObj);
					
					if(result.getJSONObject("result").optString("status").equalsIgnoreCase("FAIL")) {
						throw new RuntimeException(result.getJSONObject("result").getString("message"));
					}
				}
			} catch(IOException ioE) {
				throw ioE;
			} catch(NullPointerException npE) {
				throw npE;
			} catch(Exception e) {
				throw e;
			} finally {
				if(br != null) {
					try {
						br.close();
					}catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
				if(os != null) {
					try {
						os.close();
					}catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
				if(conn != null) {
					try {
						conn.disconnect();
					}catch(NullPointerException npE) {
						LOGGER.error(npE.getLocalizedMessage(), npE);
					}catch(Exception e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}
				}
			}
		}
		
		return result;		
	}
	
	
}

