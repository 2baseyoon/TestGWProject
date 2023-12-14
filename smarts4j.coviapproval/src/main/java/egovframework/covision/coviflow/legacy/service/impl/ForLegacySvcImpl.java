package egovframework.covision.coviflow.legacy.service.impl;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.binary.Base64;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.mapping.ParameterMap;
import org.apache.ibatis.mapping.ParameterMapping;
import org.apache.ibatis.mapping.ResultMap;
import org.apache.ibatis.mapping.ResultMapping;
import org.apache.ibatis.mapping.SqlCommandType;
import org.apache.ibatis.scripting.defaults.RawSqlSource;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.apache.ibatis.type.JdbcType;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.base.TokenParserHelper;
import egovframework.coviframework.service.ExtDatabasePoolSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.SessionCommonHelper;
import egovframework.covision.coviflow.admin.service.RuleManagementSvc;
import egovframework.covision.coviflow.common.util.ChromeRenderManager;
import egovframework.covision.coviflow.form.service.ApvProcessSvc;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.legacy.service.ForLegacySvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("forLegacyService")
public class ForLegacySvcImpl extends EgovAbstractServiceImpl implements ForLegacySvc{
	
	private static final Logger LOGGER = LogManager.getLogger(ChromeRenderManager.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private RuleManagementSvc ruleManageSvc;
	
	@Autowired
	private ApvProcessSvc apvProcessSvc;
	
	@Autowired
	private FormSvc formSvc;
	
	@Autowired
	private ExtDatabasePoolSvc extDatabasePoolService;
	
	private String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
	
	@Override
	public CoviMap getRuleApvLine(CoviMap params) throws Exception {
		
		String userID = SessionHelper.getSession("USERID");
		String deptID = SessionHelper.getSession("DEPTID");
		CoviList ruleItemList =  ruleManageSvc.getApvRuleListForForm(params).getJSONArray("list");
		
		// 겸직 중복 제거 (같은 역할일 때만 중복 제거)
		if(!ruleItemList.isEmpty()){
			for(int i=0; i<ruleItemList.size(); i++){
				for(int j=i; j<ruleItemList.size(); j++){
					if((j != i && ruleItemList.getJSONObject(i).optString("ApvType").equalsIgnoreCase(ruleItemList.getJSONObject(j).getString("ApvType"))
							&& (
									/*(ruleItemList.getJSONObject(i).optString("ObjectType").equalsIgnoreCase("person") && ruleItemList.getJSONObject(i).optString("ObjectType").equalsIgnoreCase(ruleItemList.getJSONObject(j).getString("ObjectType"))
											&& ruleItemList.getJSONObject(i).optString("UR_Code").equalsIgnoreCase(ruleItemList.getJSONObject(j).getString("UR_Code"))) ||
									(!ruleItemList.getJSONObject(i).optString("ObjectType").equalsIgnoreCase("person")  && ruleItemList.getJSONObject(i).optString("ObjectType").equalsIgnoreCase(ruleItemList.getJSONObject(j).getString("ObjectType"))
											&& ruleItemList.getJSONObject(i).optString("grCode").equalsIgnoreCase(ruleItemList.getJSONObject(j).getString("grCode")))*/
									(ruleItemList.getJSONObject(i).optString("ObjectType").equalsIgnoreCase("person") && ruleItemList.getJSONObject(i).optString("UR_Code").equalsIgnoreCase(ruleItemList.getJSONObject(j).getString("UR_Code"))) ||
									(!ruleItemList.getJSONObject(i).optString("ObjectType").equalsIgnoreCase("person")  && ruleItemList.getJSONObject(i).optString("grCode").equalsIgnoreCase(ruleItemList.getJSONObject(j).getString("grCode")))
								)
						) || (ruleItemList.getJSONObject(j).optString("ObjectType").equalsIgnoreCase("person") && ruleItemList.getJSONObject(j).optString("UR_Code").equalsIgnoreCase(userID))){
						ruleItemList.remove(j);
						--j;
					}
				}
			}
		}
		
		int listSize = ruleItemList.size();
		
		String deptName = SessionHelper.getSession("DEPTNAME");
		
		CoviMap returnApvLine = new CoviMap();
		CoviMap oSteps = new CoviMap();
		CoviList aSteps = new CoviList();
		CoviList aDivisions = new CoviList();
		CoviList aCCinfos = new CoviList();
		
		// 기안자에 대한 Division
		CoviMap defaultDivision = new CoviMap();
		CoviMap defaultDivisionTk = new CoviMap();
		CoviMap initStep = new CoviMap();
		CoviMap initOU = new CoviMap();
		CoviMap initPerson = new CoviMap();
		CoviMap initPersonTk = new CoviMap();
		
		defaultDivision.put("divisiontype", "send");
		defaultDivision.put("name", DicHelper.getDic("lbl_apv_circulation_sent"));				// 발신
		defaultDivision.put("oucode", deptID);
		defaultDivision.put("ouname", deptName);
		
		defaultDivisionTk.put("status", "inactive");
		defaultDivisionTk.put("result", "inactive");
		defaultDivisionTk.put("kind", "send");
		defaultDivisionTk.put("datereceived", DateHelper.getCurrentDay("yyyy-MM-dd HH:mm:ss"));
	
		defaultDivision.put("taskinfo", defaultDivisionTk);
		
		// 기안자 Step
		initStep.put("unittype", "person");
		initStep.put("routetype", "approve");
		initStep.put("name", DicHelper.getDic("lbl_apv_writer"));									// 기안자
		
		initOU.put("code", deptID);
		initOU.put("name", deptName);
		
		initPerson.put("code", userID);
		initPerson.put("name", SessionHelper.getSession("USERNAME"));
		initPerson.put("position", SessionHelper.getSession("UR_JobPositionCode") + ";" + SessionHelper.getSession("UR_JobPositionName"));
		initPerson.put("title", SessionHelper.getSession("UR_JobTitleCode") + ";" + SessionHelper.getSession("UR_JobTitleName"));
		initPerson.put("level", SessionHelper.getSession("UR_JobLevelCode") + ";" + SessionHelper.getSession("UR_JobLevelName"));
		initPerson.put("oucode", deptID);
		initPerson.put("ouname", deptName);
		initPerson.put("sipaddress", SessionHelper.getSession("UR_Mail"));
		
		initPersonTk.put("status", "inactive");
		initPersonTk.put("result", "inactive");
		initPersonTk.put("kind", "charge");
		initPersonTk.put("datereceived", DateHelper.getCurrentDay("yyyy-MM-dd HH:mm:ss"));
		
		initPerson.put("taskinfo", initPersonTk);
		
		initOU.put("person", initPerson);
		
		initStep.put("ou", initOU);
		
		aSteps.add(initStep);
		
		defaultDivision.put("step", aSteps);
		
		aDivisions.add(defaultDivision);
		
		for(int i = 0; i < listSize; i++){
			CoviMap item = ruleItemList.getJSONObject(i);
			
			String sApvType = item.getString("ApvType");
			String sStep_UnitType = item.getString("ObjectType");
			String sStep_Name = "";
			String sStep_RouteType = "";
			String sStep_AllotType = "";
			String sTaskinfo_Kind = "";
			
			switch (sApvType) {
			case "approve":
	            sStep_Name = DicHelper.getDic("lbl_apv_normalapprove");			// 일반결재
	            sStep_RouteType = "approve";
	            sTaskinfo_Kind = "normal";
	            break;
            case "assist":
                sStep_Name = DicHelper.getDic("lbl_apv_assist");						// 반려합의
                sStep_RouteType = "assist";
                sTaskinfo_Kind = "normal";
                sStep_AllotType = "serial";
                break;
            case "assist-parallel":
                sStep_Name = DicHelper.getDic("lbl_apv_assist");						// 반려합의
                sStep_RouteType = "assist";
                sTaskinfo_Kind = "normal";
                sStep_AllotType = "parallel";
                break;
            case "consult":
                sStep_Name = DicHelper.getDic("lbl_apv_consent");				//  개인합의
                sStep_RouteType = "consult";
                sTaskinfo_Kind = "consult";
                sStep_AllotType = "serial";
                break;
            case "consult-parallel":
                sStep_Name = DicHelper.getDic("lbl_apv_consent");				//  개인합의
                sStep_RouteType = "consult";
                sTaskinfo_Kind = "consult";
                sStep_AllotType = "parallel";
                break;
            case "receive":
            	if(!sStep_UnitType.equalsIgnoreCase("role")){
                	sStep_Name = DicHelper.getDic("lbl_apv_normalapprove");		// 일반결재
            	}else{
            		sStep_Name = DicHelper.getDic("lbl_apv_charge_approve");	// 담당결재
            	}
                sStep_RouteType = "receive";
                sTaskinfo_Kind = "normal";
                break;
            case "ccinfo":
                break;
            default:
			}
			
			if(!sApvType.equalsIgnoreCase("ccinfo")){
				
				CoviMap oStep = new CoviMap();
				CoviMap oStepTask = new CoviMap();
				CoviMap oOU = new CoviMap();
                CoviMap oPerson = new CoviMap();
                CoviMap oPersonTask = new CoviMap();
				
				boolean bStep = true;
				
				if(sStep_AllotType.equalsIgnoreCase("parallel") && i > 0){
					if(ruleItemList.getJSONObject(i - 1).getString("ApvType").indexOf("parallel") > -1){
						bStep = false;
					}
				}
				
				if(bStep){
					oStep.put("name", sStep_Name);
					oStep.put("unittype", sStep_UnitType);
					oStep.put("routetype", sStep_RouteType);
					if (!sStep_AllotType.equalsIgnoreCase("")) {
						oStep.put("allottype", sStep_AllotType);
                    }
					
                    if (sStep_RouteType.equalsIgnoreCase("consult") || sStep_RouteType.equalsIgnoreCase("assist")) {
                    	oStepTask.put("kind", sTaskinfo_Kind);
                    	oStepTask.put("status", "inactive");
                    	oStepTask.put("result", "inactive");
                        
                    	oStep.put("taskinfo", oStepTask);
                    }
				}
				
				oOU.put("name", item.getString("grName"));
				oOU.put("code", item.getString("grCode"));
                
                if (sStep_UnitType.equalsIgnoreCase("person")) {
                    oPerson.put("ouname", item.getString("grName"));
                    oPerson.put("oucode", item.getString("grCode"));
                    oPerson.put("name", item.getString("UR_Name"));
                    oPerson.put("code", item.getString("UR_Code"));
                    
                    oPerson.put("title", item.getString("JobTitleCode") + ";" + item.getString("JobTitleName"));
                    oPerson.put("position", item.getString("JobPositionCode") + ";" + item.getString("JobPositionName"));
                    oPerson.put("level", item.getString("JobLevelCode") + ";" + item.getString("JobLevelName"));
                    oPerson.put("sipaddress", item.getString("ExternalMailAddress"));
                    
                    oPersonTask.put("kind", sTaskinfo_Kind);
                    oPersonTask.put("status", "inactive");
                    oPersonTask.put("result", "inactive");

                    oPerson.put("taskinfo", oPersonTask);
                    
                	oOU.put("person", oPerson);
                } else if ("role".equals(sStep_UnitType)) {
                	oPerson.put("ouname", item.getString("grName"));
                	oPerson.put("oucode", item.getString("grCode"));
                	oPerson.put("name", item.getString("grName"));
                	oPerson.put("code", item.getString("grCode"));
                	
                    oPersonTask.put("kind", sTaskinfo_Kind);
                    oPersonTask.put("status", "pending");
                    oPersonTask.put("result", "pending");
                    
                    oPerson.put("taskinfo", oPersonTask);
                    
                    oOU.put("role", oPerson);
                } else {
                	oPersonTask.put("kind", sTaskinfo_Kind);
                    oPersonTask.put("status", "inactive");
                    oPersonTask.put("result", "inactive");

                    oOU.put("taskinfo", oPersonTask);
                }
                
                oStep.put("ou", oOU);
                
				if (sApvType.equalsIgnoreCase("receive")){
					CoviMap oDivision = new CoviMap();
					CoviMap oDivisionTask = new CoviMap();
					// division
					// 수신일때만 새로 만듦.

					oDivision.put("name", DicHelper.getDic("lbl_apv_charge_approve"));	// 담당결재
					oDivision.put("divisiontype", "receive");
					
					if(sStep_UnitType.equalsIgnoreCase("role")){
						oDivision.put("ouname", (sStep_UnitType.equalsIgnoreCase("person") ? item.getString("UR_Name") : item.getString("grName")));
						oDivision.put("oucode", (sStep_UnitType.equalsIgnoreCase("person") ? item.getString("UR_Code") : item.getString("grCode")));
					}
					
					oDivisionTask.put("kind", "receive");
					oDivisionTask.put("status", "inactive");
					oDivisionTask.put("result", "inactive");

					oDivision.put("taskinfo", oDivisionTask);
					oDivision.put("step", oStep);
					
					aDivisions.add(oDivision);
					
				}else{
					if(bStep){
						aDivisions.getJSONObject(0).getJSONArray("step").add(oStep);
					}
					else{
						for(Object obj: aDivisions.getJSONObject(0).getJSONArray("step")){
							CoviMap step = (CoviMap) obj;
							if(step.has("allottype") && step.optString("allottype").equalsIgnoreCase("parallel")){
								if(step.get("ou") instanceof CoviList){
									CoviList ou = step.getJSONArray("ou");
									ou.add(oStep.getJSONObject("ou"));
								}else if(step.get("ou") instanceof CoviMap){
									CoviList ous = new CoviList();
									CoviMap ou = step.getJSONObject("ou");
									ous.add(ou);
									ous.add(oStep.getJSONObject("ou"));
									step.put("ou", ous);
								}
							}
						}
					}
				}
            } else {
                //ccinfo
                CoviMap oCCinfo  = new CoviMap();
                
                oCCinfo.put("belongto", "sender");
                oCCinfo.put("datereceived", "");

                //ou
                CoviMap oOU = new CoviMap();
                
                oOU.put("name", item.getString("grName"));
                oOU.put("code", item.getString("grCode"));

                if (sStep_UnitType.equalsIgnoreCase("person")) {
                	CoviMap oPerson = new CoviMap();
                	
                    oPerson.put("ouname", item.getString("grName"));
                    oPerson.put("oucode", item.getString("grCode"));
                    oPerson.put("name", item.getString("UR_Name"));
                    oPerson.put("code", item.getString("UR_Code"));                            	

                    oPerson.put("title", item.getString("JobTitleCode") + ";" + item.getString("JobTitleName"));
                    oPerson.put("position", item.getString("JobPositionCode") + ";" + item.getString("JobPositionName"));
                    oPerson.put("level", item.getString("JobLevelCode") + ";" + item.getString("JobLevelName"));
                    oPerson.put("sipaddress", item.getString("ExternalMailAddress"));
                    
                	oOU.put("person", oPerson);
                }

                oCCinfo.put("ou", oOU);
                
                aCCinfos.add(oCCinfo);
            }
		}
		
		if(!aCCinfos.isEmpty()){
			oSteps.put("ccinfo", aCCinfos);
		}
	
		if(aDivisions.size() == 1){
			oSteps.put("division", aDivisions.getJSONObject(0));
		}else if(aDivisions.size() > 1){
			oSteps.put("division", aDivisions);
		}
			
		returnApvLine.put("steps", oSteps);
		
		return returnApvLine;
	}

	@Override
	public CoviMap getJobFunctionData(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		CoviMap resultMap = coviMapperOne.select("form.forLegacy.selectJobFunctionData", params);
		returnObj = CoviSelectSet.coviSelectJSON(resultMap, "JobFunctionData").getJSONObject(0);
		
		return returnObj;
	}
	
	@Override
	public CoviMap goFormLink(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String url = "";
		String key = params.optString("key");
		String mode = params.getString("mode");
		String processID = params.getString("processID");
		String legacyFormID = params.getString("legacyFormID");
		String dataType = params.getString("dataType");
		String isTempSaveBtn = params.getString("isTempSaveBtn");
		String bodyContextStr = params.getString("bodyContext");
		
		CoviMap bodyContext = new CoviMap();
		
		if(bodyContextStr != null && !bodyContextStr.equals("")){
			bodyContext = CoviMap.fromObject(bodyContextStr);
		}
		
		String htmlBodyStr = "";
		String mobileBodyStr = "";
		CoviMap bodyJson = null;
		
		if(mode.equalsIgnoreCase("DRAFT")){
			url = PropertiesUtil.getGlobalProperties().getProperty("openForm.path") + "?formPrefix="+legacyFormID+"&mode="+mode+"&isLegacy=Y";
			
			if(isTempSaveBtn != null && !isTempSaveBtn.equals("")){
				url += "&isTempSaveBtn=" + isTempSaveBtn; 
			}
			
			if(dataType != null && !dataType.equals("")){
				if(dataType.equalsIgnoreCase("ALL")){
					htmlBodyStr = bodyContext.getString("HTMLBody");
					if(bodyContext.has("MobileBody"))
						mobileBodyStr = bodyContext.getString("MobileBody");
					bodyJson = bodyContext.getJSONObject("JSONBody");
				}else if(dataType.equalsIgnoreCase("HTML")){
					htmlBodyStr = bodyContext.getString("HTMLBody");
					if(bodyContext.has("MobileBody"))
						mobileBodyStr = bodyContext.getString("MobileBody");
				}else if(dataType.equalsIgnoreCase("JSON")){
					bodyJson = bodyContext.getJSONObject("JSONBody");
				}
				
				url += "&legacyDataType=" + dataType; 
			}
			
			// 키값은 기본으로 추가
			bodyContext.put("LegacySystemKey",key);
			
			returnObj.putOrigin("bodyContext", bodyContext.toString());
			returnObj.put("HTMLBody", htmlBodyStr);
			returnObj.put("MobileBody", mobileBodyStr);
			returnObj.put("JSONBody", bodyJson);
		}else{
			url = PropertiesUtil.getGlobalProperties().getProperty("openForm.path") + "?mode="+mode+"&processID="+processID;
		}
		
		returnObj.put("URL", url);
		
		return returnObj;
	}
	
	@Override
	public CoviMap goFormLink_GWDB(CoviMap params) throws Exception {
		//params - SystemCode, Key, Mode, IsTempSaveBtn
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("status","S");
		
		CoviList legacyList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("form.forLegacy.selectDraftLegacyList", params));		
		if(legacyList.size() == 0) {
			returnObj.put("status","E");
			returnObj.put("message","데이터가 없습니다.");
			return returnObj;
		}
		CoviMap legacyInfo = legacyList.getMap(0);
		
		String url = "";
		String key = params.optString("Key");
		String systemCode = params.optString("SystemCode");
		String mode = params.optString("Mode");
		String isTempSaveBtn = params.optString("IsTempSaveBtn");
		
		String empno = legacyInfo.optString("EMPNO");
		String deptId = legacyInfo.optString("DEPT_ID");
		String legacyFormID = legacyInfo.optString("FORM_PREFIX");
		String dataType = legacyInfo.optString("DATA_TYPE");
		String subject = legacyInfo.optString("SUBJECT");
		CoviMap bodyContext = legacyInfo.optJSONObject("BODY_CONTEXT");
		
		String htmlBodyStr = "";
		String mobileBodyStr = "";
		CoviMap bodyJson = null;
		
	
		url = PropertiesUtil.getGlobalProperties().getProperty("openForm.path") + "?formPrefix="+legacyFormID+"&mode="+mode+"&isLegacy=Y";
		
		if(isTempSaveBtn != null && !isTempSaveBtn.equals("")){
			url += "&isTempSaveBtn=" + isTempSaveBtn; 
		}
		
		if(dataType != null && !dataType.equals("")){
			if(dataType.equalsIgnoreCase("ALL")){
				htmlBodyStr = bodyContext.getString("HTMLBody");
				if(bodyContext.has("MobileBody"))
					mobileBodyStr = bodyContext.getString("MobileBody");
				bodyJson = bodyContext.getJSONObject("JSONBody");
			}else if(dataType.equalsIgnoreCase("HTML")){
				htmlBodyStr = bodyContext.getString("HTMLBody");
				if(bodyContext.has("MobileBody"))
					mobileBodyStr = bodyContext.getString("MobileBody");
			}else if(dataType.equalsIgnoreCase("JSON")){
				bodyJson = bodyContext.getJSONObject("JSONBody");
			}
			url += "&legacyDataType=" + dataType; 
		}
		
		// 연동시스템정보는 기본으로 추가
		bodyContext.put("LegacySystemKey",key);
		bodyContext.put("SystemCode",systemCode);
		
		returnObj.putOrigin("bodyContext", bodyContext.toString());
		returnObj.put("HTMLBody", htmlBodyStr);
		returnObj.put("MobileBody", mobileBodyStr);
		returnObj.put("JSONBody", bodyJson);
		returnObj.put("legacyFormID", legacyFormID);
		returnObj.put("subject", subject);
		returnObj.put("dataType", dataType);
		returnObj.put("empno", empno);
		returnObj.put("deptId", deptId);
		returnObj.put("URL", url);
		
		return returnObj;
	}
	
	@Override
	public CoviMap goFormLink_EXTDB(CoviMap params) throws Exception {
		// params - SystemCode, Key, Mode, IsTempSaveBtn, DataType
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("status","S");
		
		try {
			String url = "";
			String key = params.optString("Key");
			String systemCode = params.optString("SystemCode");
			String mode = params.optString("Mode");
			String isTempSaveBtn = params.optString("IsTempSaveBtn");
			String dataType = params.optString("DataType");
			CoviMap bodyContext = new CoviMap();
			String htmlBodyStr = "";
			String mobileBodyStr = "";
			CoviMap bodyJson = null;
			
			// 외부시스템 정보 조회
			CoviList legacyInfos = CoviSelectSet.coviSelectJSON(coviMapperOne.list("form.forLegacy.selectDraftLegacyTarget", params));		
			if(legacyInfos.size() == 0) {
				throw new Exception("연동시스템 정보가 없습니다.");
			}
			CoviMap legacyInfo = legacyInfos.getMap(0);
			String datasourceSeq = legacyInfo.optString("DatasourceSeq");	// 외부DB 연계설정의 Pool
			String dataTableName = legacyInfo.optString("DataTableName");	// 연동시스템 데이터 테이블 명
			String dataTableKeyName = legacyInfo.optString("DataTableKeyName");	// 연동시스템 데이터 테이블 키컬럼
			String subjectKeyName = legacyInfo.optString("SubjectKeyName");	// 연동시스템 데이터 테이블 제목 키컬럼
			String empnoKeyName = legacyInfo.optString("EmpnoKeyName");	// 연동시스템 데이터 테이블 기안자사번 키컬럼
			String deptKeyName = legacyInfo.optString("DeptKeyName");	// 연동시스템 데이터 테이블 기안자부서코드 키컬럼
			String multiTableName = legacyInfo.optString("MultiTableName");	// 연동시스템 멀티로우 테이블명
			String multiTableKeyName = legacyInfo.optString("MultiTableKeyName");	// 연동시스템 멀티로우 테이블키
			String legacyFormID = legacyInfo.optString("FormPrefix");
			
			if(StringUtil.isEmpty(dataTableName) || StringUtil.isEmpty(dataTableKeyName) || StringUtil.isEmpty(subjectKeyName) || StringUtil.isEmpty(empnoKeyName)) {
				throw new Exception("연동시스템 테이블 정보가 부족합니다.");
			}
			
			// 연동시스템 데이터 테이블 조회
			CoviList tb_DATAs = new CoviList();
			CoviList tb_MULTIs = new CoviList();
			CoviMap sqlParam = new CoviMap();
			sqlParam.put("Key", key);
			
			StringBuffer sbSQL_data = new StringBuffer();
			sbSQL_data.append(String.format(" SELECT * FROM %s ", dataTableName));
			sbSQL_data.append(String.format(" WHERE %s = #{Key} ", dataTableKeyName));
			tb_DATAs = gwtEXTDB_Data(datasourceSeq, sbSQL_data.toString(), sqlParam);
			
			// 연동시스템 멀티로우 테이블 조회
			if(StringUtil.isNotEmpty(multiTableName) && StringUtil.isNotEmpty(multiTableKeyName)) {
				StringBuffer sbSQL_multi = new StringBuffer();
				sbSQL_multi.append(String.format(" SELECT * FROM %s ", multiTableName));
				sbSQL_multi.append(String.format(" WHERE %s = #{Key} ", multiTableKeyName));
				tb_MULTIs = gwtEXTDB_Data(datasourceSeq, sbSQL_multi.toString(), sqlParam);
			}
			
			if(tb_DATAs.size() == 0) {
				throw new Exception("연동시스템에 데이터가 없습니다.");
			}
			
			// 기본정보 및 BodyContext 데이터 생성
			CoviMap tb_DATA = new CoviMap(tb_DATAs.get(0));
			String empno = tb_DATA.optString(empnoKeyName);
			String deptId = tb_DATA.optString(deptKeyName);
			String subject = tb_DATA.optString(subjectKeyName);
			url = PropertiesUtil.getGlobalProperties().getProperty("openForm.path") + "?formPrefix="+legacyFormID+"&mode="+mode+"&isLegacy=Y";
			if(isTempSaveBtn != null && !isTempSaveBtn.equals("")){
				url += "&isTempSaveBtn=" + isTempSaveBtn; 
			}
			//bodyContext.putAll(tb_DATA); // 키값을 대문자로 하기위해 반복문으로 변경
			Iterator<String> keys_DATA = tb_DATA.keys();
			while(keys_DATA.hasNext()) {
				String key_DATA = keys_DATA.next();
				bodyContext.put(key_DATA.toUpperCase(), tb_DATA.optString(key_DATA));
			}
			
			// BodyContext 멀티로우 데이터 생성
			if(tb_MULTIs.size() > 0) {
				String multiRowKey = multiTableName.toUpperCase();
				if(multiRowKey.indexOf(".") > -1) multiRowKey = multiRowKey.substring(multiRowKey.lastIndexOf(".")+1, multiRowKey.length()).toUpperCase();
				
				//bodyContext.put(multiRowKey, tb_MULTIs); // 키값을 대문자로 하기위해 반복문으로 변경
				CoviList body_MULTIs = new CoviList();
				for (int i = 0; i < tb_MULTIs.size(); i++) {
					CoviMap tb_MULTI = new CoviMap(tb_MULTIs.get(i));
					CoviMap body_MULTI = new CoviMap();
					Iterator<String> keys_MULTI = tb_MULTI.keys();
					while(keys_MULTI.hasNext()) {
						String key_MULTI = keys_MULTI.next();
						body_MULTI.put(key_MULTI.toUpperCase(), tb_MULTI.optString(key_MULTI));
					}
					body_MULTIs.add(body_MULTI);
				}
				bodyContext.put(multiRowKey, body_MULTIs);
			}
			
			// 연동시스템정보는 기본으로 추가
			bodyContext.put("LegacySystemKey",key);
			bodyContext.put("SystemCode",systemCode);
						
			if(dataType != null && !dataType.equals("")){
				if(dataType.equalsIgnoreCase("ALL")){
					htmlBodyStr = bodyContext.getString("HTMLBody");
					if(bodyContext.has("MobileBody"))
						mobileBodyStr = bodyContext.getString("MobileBody");
					bodyJson = bodyContext.getJSONObject("JSONBody");
				}else if(dataType.equalsIgnoreCase("HTML")){
					htmlBodyStr = bodyContext.getString("HTMLBody");
					if(bodyContext.has("MobileBody"))
						mobileBodyStr = bodyContext.getString("MobileBody");
				}else if(dataType.equalsIgnoreCase("JSON")){
					bodyJson = bodyContext.getJSONObject("JSONBody");
				}
				url += "&legacyDataType=" + dataType; 
			}
			
			returnObj.putOrigin("bodyContext", bodyContext.toString());
			returnObj.put("HTMLBody", htmlBodyStr);
			returnObj.put("MobileBody", mobileBodyStr);
			returnObj.put("JSONBody", bodyJson);
			returnObj.put("legacyFormID", legacyFormID);
			returnObj.put("subject", subject);
			returnObj.put("dataType", dataType);
			returnObj.put("empno", empno);
			returnObj.put("deptId", deptId);
			returnObj.put("URL", url);
			
		} catch (NullPointerException npE) {
			returnObj.put("status","E");
			returnObj.put("message",npE.getMessage());
		} catch(Exception e) {
			returnObj.put("status","E");
			returnObj.put("message",e.getMessage());
		}
		
		return returnObj;
	}
	
	public CoviList gwtEXTDB_Data(String datasourceSeq, String sql, CoviMap sqlParam) throws Exception {
		CoviList legacyResult;
		
		// 외부연계 DB 접속 정보 조회(sys_datasource)
		CoviMap params_DS = new CoviMap();
		params_DS.put("datasourceSeq", datasourceSeq);
		CoviMap legacyDS = coviMapperOne.select("framework.datasource.selectDatasource", params_DS);
		String connectionPoolName = legacyDS.getString("ConnectionPoolName");
		
		// 외부시스템 DB 접속 및 데이터 조회
		Connection conn = null; // Pooled connection.
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		Configuration configuration = null;
		SqlSessionFactory factory = null;
		SqlSession session = null;
		
		try {	
			// Get DBCP Connection from pool. 
			conn = extDatabasePoolService.getConnection(connectionPoolName);
			if(conn == null) {
				throw new Exception("[" + connectionPoolName + "] pool is not bound in this Context.");
			}
			// Make param, result statement setting.
			configuration = new Configuration();
			configuration.setCallSettersOnNulls(true); // null인 컬럼도 가져오는 설정 // configuration.isCallSettersOnNulls();
			configuration.setJdbcTypeForNull(JdbcType.NULL); //configuration.getJdbcTypeForNull();
			
			factory = new SqlSessionFactoryBuilder().build(configuration);
			
			// Unique sql id.
			String sqlName = UUID.randomUUID().toString();
			
			RawSqlSource sqlBuilder = new RawSqlSource(configuration, sql, Map.class); // java.util.Map.class
			MappedStatement.Builder statementBuilder;
			statementBuilder = new MappedStatement.Builder( configuration, sqlName, sqlBuilder, SqlCommandType.SELECT ); //select일때
			
			// Parameter type
			List<ParameterMapping> parameterMappings = new ArrayList<ParameterMapping>();
			ParameterMap.Builder inlineParameterMapBuilder = new ParameterMap.Builder(configuration, statementBuilder.id() + "-Inline", Map.class, parameterMappings); // java.util.Map.class
			statementBuilder.parameterMap(inlineParameterMapBuilder.build());
			
			// Result type
			List<ResultMapping> resultMappings = new ArrayList<ResultMapping>();
			List<ResultMap> resultMaps = new ArrayList<ResultMap>();
			resultMaps.add( new ResultMap.Builder( configuration, "", Map.class, resultMappings ).build( ) ); // select일때
			statementBuilder.resultMaps(resultMaps);
			
			MappedStatement statement = statementBuilder.build();
			configuration.addMappedStatement( statement );
			// Parametered statement prepare end.
			
			// Prepare SqlSession using Connection.
			//conn.setAutoCommit(false);
			session = factory.openSession(conn);
			
			// Execute Statement.
			@SuppressWarnings("rawtypes")
			List list = session.selectList(sqlName, sqlParam);
			if (list == null) {
				throw new Exception("연동시스템 데이터조회에 실패했습니다.");
			}
			else {
				legacyResult = new CoviList(list);
			}
		} catch (NullPointerException npE) {
			//if(conn != null) { conn.rollback(); }
			throw npE;
		} catch(Exception e) {
			//if(conn != null) { conn.rollback(); }
			throw e;
		}finally {
			// Close resources.
			//if(conn != null) { conn.setAutoCommit(true); }
			try {
				extDatabasePoolService.close(conn, pstmt, rs, session);
			}catch(NullPointerException npE) {
				LOGGER.error(npE.getLocalizedMessage(), npE);
			}catch(Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			}
		}
				
		return legacyResult;
	}

	@Override
	public CoviMap draftForLegacy(CoviMap params, List<MultipartFile> mf) throws Exception {
		CoviMap formObj = new CoviMap();
		
		// 기안에 필요한 데이터 세팅
		params.put("isFile", !mf.isEmpty());
		formObj = makeFormObj(params);
		
		// 본문 저장관련해서 호출 분리함.
		CoviMap processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);
		
		return draftForLegacy(formObj, processFormDataReturn);
	}
	@Override
	public CoviMap draftForLegacy(CoviMap formObj, CoviMap processFormDataReturn) throws Exception {
		/*CoviMap formObj = new CoviMap();
		
		// 기안에 필요한 데이터 세팅
		params.put("isFile", !mf.isEmpty());
		formObj = makeFormObj(params);
		String reqFormInstID = formObj.optString("FormInstID"); 
		// 본문 저장관련해서 호출 분리함.
		CoviMap processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);
		*/
		
		// 기안 및 승인
		String formInstID = apvProcessSvc.doProcess(formObj, processFormDataReturn);
		//문서발번 처리
		if(!formInstID.equals("")) {
			apvProcessSvc.updateFormInstDocNumber(formInstID);
		}
		
		return formObj;
	}

	@Override
	public boolean isLegacyFormCheck(String legacyFormID) {
		return isLegacyFormCheck(legacyFormID, SessionHelper.getSession("DN_Code"));
	}
	@Override
	public boolean isLegacyFormCheck(String legacyFormID, String dn_code) {
		CoviMap params = new CoviMap();
		params.put("legacyFormID", legacyFormID);
		params.put("DN_Code", dn_code);
		params.put("isSaaS", PropertiesUtil.getGlobalProperties().getProperty("isSaaS"));
		
		int cnt = coviMapperOne.selectOne("form.forLegacy.selectLegacyForm", params);
		
		return (cnt > 0);
	}
	
	@Override
	public CoviMap makeFormObj(CoviMap params) throws Exception{
		CoviMap returnObj = new CoviMap();
		
		String legacyFormID = params.getString("legacyFormID");
		
		CoviMap processDescription = new CoviMap();
		CoviMap approvalLine = CoviMap.fromObject(params.getString("apvline"));
		CoviMap formInfoExt = new CoviMap();
		CoviMap formData = new CoviMap();
		CoviMap docInfo = new CoviMap();
		
		params.put("formPrefix", legacyFormID);
		CoviMap formInfoData = formSvc.selectForm(params).getJSONArray("list").getJSONObject(0);
		
		CoviMap formInfoExtData = formInfoData.getJSONObject("ExtInfo");
		
		String formID = formInfoData.getString("FormID");
		String schemaID = formInfoData.getString("SchemaID");
		String formName = formInfoData.getString("FormName");
		String subject = params.getString("subject");
		String docClassID = formInfoExtData.getString("DocClassID");
		String docClassName = formInfoExtData.getString("DocClassName");
		String saveTerm = formInfoExtData.getString("PreservPeriod");
		String docLevel = formInfoExtData.getString("SecurityGrade");
		
		params.put("schemaID", schemaID);
		CoviMap schemeData = formSvc.selectFormSchema(params).getJSONArray("list").getJSONObject(0).getJSONObject("SchemaContext");
		
		String processDefinitionID = schemeData.getJSONObject("pdef").getString("value");
		
		// 세션이 아닌, 파라미터의 empno(loginid)기준으로 조회해오도록 수정함.
		CoviMap params_ur = new CoviMap();
		params_ur.put("UR_Code", params.getString("empno"));
		if(params.containsKey("deptcode"))
			params_ur.put("DeptCode", params.getString("deptcode"));
		// deptcode가 없으면 본직 정보로 기안됨, 겸직정보가 필요하면 deptcode(파라미터 deptId) 넘겨야됨
		CoviMap list = coviMapperOne.select("form.org_person.selectUserInfo", params_ur);
		
		String deptCode = list.optString("DEPTCODE");
		String deptName = list.optString("MULTIDEPTNAME");
		String userCode = list.optString("USERCODE");
		String userName = list.optString("MULTIDISPLAYNAME");
		String entcode = list.optString("COMPANYCODE");
		String entname = list.optString("COMPANYNAME");
		String deptFullPath = list.optString("GROUPPATH");
		String regionID = list.optString("REGIONCODE");
		String lang = params.optString("lang");
		if(lang.equals("")) lang = list.optString("LANGUAGECODE");
		
		String appliedDate = DateHelper.getCurrentDay("yyyy-MM-dd HH:mm:ss");
		
		CoviMap bodyContext = CoviMap.fromObject(params.getString("bodyContext"));
		bodyContext.put("InitiatorDisplay", DicHelper.getDicInfo(userName, lang));
		bodyContext.put("InitiatorOUDisplay", DicHelper.getDicInfo(deptName, lang));
		bodyContext.put("LegacySystemKey", params.optString("key"));
		
		processDescription.put("FormInstID", "");
		processDescription.put("FormID", formID);
		processDescription.put("FormName", formName);
		processDescription.put("FormSubject", subject);
		processDescription.put("IsSecureDoc", "N");
		processDescription.put("IsFile", Boolean.TRUE.equals(params.get("isFile")) ? "Y" : "N");
		processDescription.put("FileExt", "");
		processDescription.put("IsComment", params.getString("apvline").indexOf("comment") > -1 ? "Y" : "N");
		processDescription.put("ApproverCode", "");
		processDescription.put("ApproverName", "");
		processDescription.put("ApprovalStep", "");
		processDescription.put("ApproverSIPAddress", "");
		processDescription.put("IsReserved", "N");
		processDescription.put("ReservedGubun", "");
		processDescription.put("ReservedTime", "");
		processDescription.put("Priority", "3");
		processDescription.put("IsModify", "N");
		processDescription.put("BusinessData1", "APPROVAL");
		processDescription.put("BusinessData2", "");
		processDescription.put("BusinessData3", "");
		processDescription.put("BusinessData4", "");
		processDescription.put("BusinessData5", "");
		processDescription.put("BusinessData6", "");
		processDescription.put("BusinessData7", "");
		processDescription.put("BusinessData8", "");
		processDescription.put("BusinessData9", "");
		processDescription.put("BusinessData10", "");
		
		if(legacyFormID.indexOf("EACCOUNT") > -1) {
			processDescription.put("BusinessData1", "ACCOUNT");
			processDescription.put("BusinessData2", params.getString("key"));
			// long amountSum = 0;
			Double amountSum = 0d;
			CoviList evidList = bodyContext.getJSONObject("JSONBody").getJSONArray("pageExpenceAppEvidList");
			for(int i = 0; i < evidList.size(); i++) {
				amountSum += evidList.getJSONObject(i).getDouble("divSum");
			}
			processDescription.put("BusinessData3", new DecimalFormat("#########.##").format(amountSum));
			processDescription.put("BusinessData4", evidList.getJSONObject(0).getJSONArray("divList").getJSONObject(0).getString("UsageComment"));
			if(bodyContext.getJSONObject("JSONBody").get("Sub_UR_Code") != null && bodyContext.getJSONObject("JSONBody").get("Sub_UR_Name") != null) {
				processDescription.put("BusinessData5", bodyContext.getJSONObject("JSONBody").get("Sub_UR_Code")+"^^^"+bodyContext.getJSONObject("JSONBody").get("Sub_UR_Name")); 
			}
		}
		
		//
		docInfo.put("DocNo", "");
		docInfo.put("ReceiveNo", "");
		docInfo.put("dpdsn", "");
		docInfo.put("DocClassID", docClassID);
		docInfo.put("DocClassName", docClassName);
		docInfo.put("SaveTerm", saveTerm);
		docInfo.put("AppliedYear", DateHelper.getCurrentDay("yyyy"));
		docInfo.put("AppliedDate", appliedDate);
		docInfo.put("DocLevel", docLevel);
		docInfo.put("IsPublic", "N");
		docInfo.put("deptcode", deptCode);
		docInfo.put("deptpath", deptFullPath);
		docInfo.put("AttachFile", "");
		
		//
		formInfoExt.put("scOPub", schemeData.getJSONObject("scOPub").optString("isUse").equalsIgnoreCase("Y") ? "True" : "False" );
		formInfoExt.put("scIPub", schemeData.getJSONObject("scIPub").optString("isUse").equalsIgnoreCase("Y") ? "True" : "False");
		formInfoExt.put("scABox", schemeData.getJSONObject("scABox").getString("isUse"));
		formInfoExt.put("scRPBox", schemeData.getJSONObject("scRPBox").getString("isUse"));
		formInfoExt.put("scJFBox", schemeData.getJSONObject("scJFBox").getString("isUse"));
		formInfoExt.put("scJFBoxV", schemeData.getJSONObject("scJFBox").getString("value"));
		formInfoExt.put("scAutoReview", schemeData.getJSONObject("scAutoReview").getString("isUse"));			//TODO scAutoReview
		formInfoExt.put("IsUseDocNo", schemeData.getJSONObject("scDNum").optString("isUse").equalsIgnoreCase("Y") ? "True" : "False");
		formInfoExt.put("DocInfo", docInfo);
		formInfoExt.put("rejectedto", schemeData.getJSONObject("scRJTO").optString("isUse").equalsIgnoreCase("Y") ? "true" : "false");
		formInfoExt.put("IsLegacy", schemeData.getJSONObject("scLegacy").optString("isUse").equalsIgnoreCase("Y") ? schemeData.getJSONObject("scLegacy").getString("value") : "");
		formInfoExt.put("entcode", entcode);
		formInfoExt.put("entname", entname);
		formInfoExt.put("docnotype", schemeData.getJSONObject("scDNum").getString("value"));
		formInfoExt.put("ConsultOK", schemeData.getJSONObject("scConsultOK").optString("isUse").equalsIgnoreCase("Y") ? "true" : "false");
		formInfoExt.put("IsSubReturn", schemeData.getJSONObject("scDCooReturn").optString("isUse").equalsIgnoreCase("Y") ? "true" : "false");
		formInfoExt.put("IsDeputy", "false");
		formInfoExt.put("IsReUse", "");
		formInfoExt.put("scDocBoxRE", schemeData.getJSONObject("scDocBoxRE").getString("isUse"));
		formInfoExt.put("nCommitteeCount", "2");
		formInfoExt.put("IsReserved", "False");
		formInfoExt.put("scASSBox", schemeData.getJSONObject("scASSBox").getString("isUse"));
		formInfoExt.put("scPreDocNum", schemeData.getJSONObject("scPreDocNum").getString("isUse"));
		formInfoExt.put("scDistDocNum", schemeData.has("scDistDocNum") ? schemeData.getJSONObject("scDistDocNum").getString("isUse") : "N");
		formInfoExt.put("scBatchPub", schemeData.has("scBatchPub") ? schemeData.getJSONObject("scBatchPub").getString("isUse") : "");
		
	    //문서번호발번정규식추가 2019.08.26
		if(schemeData.containsKey("scDNumExt")) {
			formInfoExt.put("scDNumExt", schemeData.getJSONObject("scDNumExt").optString("isUse").equalsIgnoreCase("Y") ? schemeData.getJSONObject("scDNumExt").getString("value") : "false");
		} else {
			formInfoExt.put("scDNumExt", "false");
		}
		
		String ruleItemInfo = "";
		if(bodyContext.getJSONObject("JSONBody").containsKey("RuleItemInfo")) {
			ruleItemInfo = bodyContext.getJSONObject("JSONBody").getString("RuleItemInfo");
		}
		formInfoExt.put("RuleItemInfo", ruleItemInfo);
		
		//담당업무함 스키마 데이터 변경
		String scChgr = params.optString("scChgrValue");
		schemeData.getJSONObject("scChgr").put("value", scChgr);
		if(StringUtil.isNotNull(scChgr)) {
			schemeData.getJSONObject("scChgr").put("isUse", "Y");
		}
		
		// JFID
		if (schemeData.getJSONObject("scChgr").optString("isUse").equalsIgnoreCase("Y")) {
			formInfoExt.put("JFID", schemeData.getJSONObject("scChgr").getString("value"));
	    } else if (schemeData.getJSONObject("scChgrEnt").optString("isUse").equalsIgnoreCase("Y")) {
	        if (!schemeData.getJSONObject("scChgrEnt").optString("value").equals("")) {
	            CoviMap chgrEntObj =schemeData.getJSONObject("scChgrEnt").getJSONObject("value");
	            if(chgrEntObj.has("ENT_"+entcode) && !chgrEntObj.getString("ENT_"+entcode).equals("")){
	            	formInfoExt.put("JFID", chgrEntObj.getString("ENT_"+entcode));
	            }
	        }
	    } else if (schemeData.getJSONObject("scChgrReg").optString("isUse").equalsIgnoreCase("Y")) {
	        if (!schemeData.getJSONObject("scChgrReg").optString("value").equals("")) {
	        	CoviMap chgrRegObj =schemeData.getJSONObject("scChgrReg").getJSONObject("value");
	            if(chgrRegObj.has("REG_"+regionID) && !chgrRegObj.getString("REG_"+regionID).equals("")){
	            	formInfoExt.put("JFID", chgrRegObj.getString("REG_"+regionID));
	            }
	        }
	    }
		
		// ChargeOU
		if (schemeData.getJSONObject("scChgrOU").optString("isUse").equalsIgnoreCase("Y")) {
			formInfoExt.put("ChargeOU", schemeData.getJSONObject("scChgrOU").getString("value"));
	    } else if (schemeData.getJSONObject("scChgrOUEnt").optString("isUse").equalsIgnoreCase("Y")) {
	        if (!schemeData.getJSONObject("scChgrOUEnt").optString("value").equals("")) {
	            CoviMap chgrOUEntObj =schemeData.getJSONObject("scChgrOUEnt").getJSONObject("value");
	            int itemLeng = chgrOUEntObj.getJSONObject("ENT_"+entcode).getJSONArray("item").size();
	            String valueStr = "";
	            if (itemLeng > 0) {
	            	for(int i =0; i<itemLeng; i++){
	            		if (i > 0) valueStr += "^";
	            		valueStr = chgrOUEntObj.getJSONObject("ENT_"+entcode).getJSONArray("item").getJSONObject(i).getString("AN") + "@" + chgrOUEntObj.getJSONObject("ENT_"+entcode).getJSONArray("item").getJSONObject(i).getString("DN");
	            	}
	            	formInfoExt.put("ChargeOU", valueStr);
	            }
	            
	        }
	    } else if (schemeData.getJSONObject("scChgrOUReg").optString("isUse").equalsIgnoreCase("Y")) {
	    	if (!schemeData.getJSONObject("scChgrOUReg").optString("value").equals("")) {
	    		CoviMap chgrOURegObj =schemeData.getJSONObject("scChgrOUReg").getJSONObject("value");
	    		int itemLeng = chgrOURegObj.getJSONObject("REG_"+regionID).getJSONArray("item").size();
	    		String valueStr = "";
	            if (itemLeng > 0) {
	            	for(int i =0; i<itemLeng; i++){
	            		if (i > 0) valueStr += "^";
	                    valueStr = chgrOURegObj.getJSONObject("REG_"+regionID).getJSONArray("item").getJSONObject(i).getString("AN") + "@" + chgrOURegObj.getJSONObject("REG_"+regionID).getJSONArray("item").getJSONObject(i).getString("DN");
	                }
	            }
	        }
	    }
		
		
		// ChargePerson
		if (schemeData.getJSONObject("scChgrPerson").optString("isUse").equalsIgnoreCase("Y")) {
	        String chargePersonStr = schemeData.getJSONObject("scChgrPerson").getString("value");
	        StringBuffer retChgrPerson = new StringBuffer();
	        
	        if (!chargePersonStr.equals("")) {
	        	CoviMap chargePersonObj = CoviMap.fromObject(chargePersonStr.split("@@")[2]);

	        	int itemLeng = chargePersonObj.getJSONArray("item").size();
	            if (itemLeng > 0) {
	                for(int i=0; i<itemLeng; i++){
	                    if (i > 0) {
	                        retChgrPerson.append("^");
	                    }

	                    retChgrPerson.append(chargePersonObj.getJSONArray("item").getJSONObject(i).getString("AN")
	                        + '@' + chargePersonObj.getJSONArray("item").getJSONObject(i).getString("DN")
	                        + '@' + chargePersonObj.getJSONArray("item").getJSONObject(i).getString("GR_Code"));
	                }
	                formInfoExt.put("ChargePerson", retChgrPerson.toString());
	            }
	        }
		}
		
		//
		formData.put("BodyContext", bodyContext);
		formData.put("InitiatorName", userName);
		formData.put("InitiatorID", userCode);
		formData.put("InitiatorUnitName", deptName);
		formData.put("InitiatorUnitID", deptCode);
		formData.put("AttachFileInfo", params.containsKey("AttachFileInfo") ? params.getJSONObject("AttachFileInfo").toString() : "");
		formData.put("AppliedDate", appliedDate);
		formData.put("IsPublic", "");
		formData.put("AppliedTerm", "");
		formData.put("ReceiveNo", "");
		formData.put("ReceiveNames", "");
		formData.put("ReceiptList", "");
		formData.put("DocClassID", docClassID);
		formData.put("EntCode", entcode);
		formData.put("EntName", entname);
		formData.put("DocSummary", "");
		formData.put("DocLinks", "");
		formData.put("DocNo", "");
		formData.put("DocClassName", docClassName);
		formData.put("DocLevel", docLevel);
		formData.put("SaveTerm", saveTerm);
		formData.put("Subject", subject);
		formData.put("RuleItemInfo", ruleItemInfo);
		
		//
		returnObj.put("processID", "");
		returnObj.put("parentprocessID", "");
		returnObj.put("taskID", "");
		returnObj.put("processDefinitionID", processDefinitionID);
		returnObj.put("subkind", "");
		returnObj.put("performerID", "");
		returnObj.put("mode", "DRAFT");
		returnObj.put("gloct", "");
		returnObj.put("dpid", deptCode);
		returnObj.put("usid", userCode);
		returnObj.put("sabun", "");
		returnObj.put("dpid_apv", deptCode);
		returnObj.put("dpdn_apv", deptName);
		returnObj.put("usdn", userName);
		returnObj.put("dpdsn", "");
		returnObj.put("FormID", formID);
		returnObj.put("FormName", formName);
		returnObj.put("FormPrefix", legacyFormID);
		returnObj.put("BodyType", "HTML");
		returnObj.put("Revision", formInfoData.getString("Revision"));
		returnObj.put("FormInstID", "");
		returnObj.put("formtempID", "");
		returnObj.put("UserCode", "");
		returnObj.put("SchemaID", schemaID);
		returnObj.put("FileName", formInfoData.getString("FormName"));
		if(processDescription.optString("BusinessData1").equals("APPROVAL")) {
			returnObj.put("FormTempInstBoxID", "");
		} else {
			returnObj.put("FormTempInstBoxID", processDescription.getString("BusinessData1")+"_"+params.getString("key"));
		}
		returnObj.put("FormInstID_response", "");
		returnObj.put("FormInstID_spare", "");
		returnObj.put("editMode", "N");
		returnObj.put("ProcessDescription", processDescription);
		returnObj.put("ApprovalLine", approvalLine);
		returnObj.put("FormInfoExt", formInfoExt);
		returnObj.put("Priority", "3");
		returnObj.put("actionMode", "");
		returnObj.put("actionComment", params.getString("actionComment"));
		returnObj.put("actionComment_Attach", "[]");
		returnObj.put("signimagetype", params.getString("signImage"));
		returnObj.put("FormData", formData);
		
		return returnObj;
	}
	
	@Override
	public CoviMap getFormLegacyInfo(String processID) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap param = new CoviMap();
		param.put("processID", processID);
		
		CoviMap resultMap = coviMapperOne.select("form.forLegacy.selectLegacyFormInfo", param);
		returnObj = CoviSelectSet.coviSelectJSON(resultMap, "Mode,FormPrefix").getJSONObject(0);
		
		return returnObj;
	}
	
	public String selectUserMailAddress(String id){
		String value = "";
		CoviMap params = new CoviMap();
		params.put("id", id);
		
		value = coviMapperOne.getString("common.login.selectUserMailAddress", params);
		return value;
	}
	
	@Override
	public CoviMap checkAuthetication(String authType, String id, String password, String locale) throws Exception
	{
		return checkAuthetication(authType, id, password, locale, "");
	}
	@Override
	public CoviMap checkAuthetication(String authType, String id, String password, String locale, String deptId) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		/*
		 * 인증 처리를 세분화 할 것
		 * */
	
			//account 획득
			CoviMap params = new CoviMap();
			params.put("id", id);
			params.put("deptId", deptId);
			params.put("password", password);
			params.put("lang", locale);
			params.put("aeskey", aeskey);
			
			CoviMap account  = new CoviMap();
			
			if("SSO".equals(authType) || "SAML".equals(authType) || "OAUTH".equals(authType)){
				account = coviMapperOne.select("common.login.selectSSO", params);
			}else{
				account = coviMapperOne.select("common.login.select", params);
			}
			coviMapperOne.update("common.login.updateUserInfo", account);	//로그온 회수 증가 및 세션ID갱신
			
			CoviMap resultListMap = new CoviMap();
			resultListMap.put("account", account);

			resultList.put("map", resultListMap.get("account"));
			
			resultList.put("account", account);

			resultList.put("status", "OK");
		
		
		return resultList;
	}
	
	public String checkSSO(String opType){
		String value = "";
		CoviMap params = new CoviMap();
		
		switch(opType){
		 case "SERVER":
			params.put("Code", "sso_server");
			break;
		 case "DAY":
			params.put("Code","sso_expiration_day");
			break;
		 case "URL":
			params.put("Code","sso_sp_url");
			break;	
		 case "ACS":
			params.put("Code","sso_acs_url");
			break;
		 case "SPACS":
			params.put("Code","sso_spacs_url");
			break;	
		 case "RS":
			params.put("Code","sso_rs_url");
			break;			
		 default: 
			 params.put("Code","sso_storage_path");
			 break;
		}
		params.put("DomainID", "0");
		value = coviMapperOne.getString("common.login.selectSSOValue", params);
		return value;
	}
	
	public boolean insertTokenHistory(String key, String urId, String urName, String urCode, String empNo, String maxAge, String type, String assertion_id )throws Exception{
		CoviMap params = new CoviMap();
		
		params.put("token", key);
		params.put("urid", urId);
		params.put("urname", urName);
		params.put("urcode", urCode);
		params.put("empno", empNo);
		params.put("maxage", maxAge);
		params.put("type", type);
		params.put("assertion_id", assertion_id);
		
		int cnt = coviMapperOne.insert("common.login.ssoTokenHistory", params);
		return (cnt > 0);
	}
	
	@Override
	public String setFormLegacyLogin(HttpServletResponse response, HttpSession session, String legacyLogonID, String legacyDeptCode, boolean isMobile, String lang) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CookiesUtil cUtil = new CookiesUtil();
		TokenParserHelper tokenParserHelper = new TokenParserHelper();
		TokenHelper tokenHelper = new TokenHelper();
		
		String paramId = legacyLogonID;
		String authType = "SSO"; 
		String paramPwd = "";
		String paramLang = lang;
		String status = "";
		
		String urNm = "";
		String urCode = "";
		String urEmpNo = "";
		String samlID= "";
		
		resultList = checkAuthetication(authType, paramId, paramPwd, paramLang, legacyDeptCode);
		status = resultList.optString("status");
		CoviMap account = (CoviMap) resultList.get("account");
		
		//인증 성공 시
		if (status.equals("OK")) {
			
			String date = checkSSO("DAY");
			String key = tokenHelper.setTokenString(paramId,date,paramPwd,paramLang,account.optString("UR_Mail"),account.optString("DN_Code"),account.optString("UR_EmpNo"),account.optString("DN_Name"),account.optString("UR_Name"),account.optString("UR_Mail"),account.optString("GR_Code"),account.optString("GR_Name"),account.optString("Attribute"),account.optString("DN_ID"));
			
			String accessDate = tokenHelper.selCookieDate(date,"");

			// DB에서 Subdomain 사용하지 않는 경우를 고려하여 설정값 가져오도록 수정
			//cUtil.setCookies(response, key, accessDate,account.optString("SubDomain"));
			cUtil.setCookies(response, key, accessDate,PropertiesUtil.getSecurityProperties().getProperty("token.cok.domain"));
			
			String decodKey = tokenHelper.getDecryptToken(key);
		    String maxAge = tokenParserHelper.parserJsonMaxAge(decodKey);
		    
			//Token 저장.
			if(insertTokenHistory(key, samlID, urNm, urCode, urEmpNo, maxAge, "I", "")){
				status = "SUCCESS";
				
				//세션 생성
				session.getServletContext().setAttribute(key, account.optString("UR_ID"));
				session.setAttribute("KEY", key);
				session.setAttribute("USERID", account.optString("UR_ID"));
				session.setAttribute("LOGIN", "Y");		
				
				SessionCommonHelper.makeSession(account.optString("UR_ID"), account, isMobile, key);
				//SessionHelper.setSession("SSO", authType);
				if(account.optString("LanguageCode").equals("")) { // 사용자정보에 다국어 코드가 없는경우 ko로 고정
					SessionHelper.setSimpleSession("lang", "ko", isMobile, key);
					SessionHelper.setSimpleSession("LanguageCode", "ko", isMobile, key);
				}
				if(StringUtil.isNotNull(paramLang)) { // 파라미터로 다국어 코드를 받은경우 받은값으로 변경
					SessionHelper.setSimpleSession("lang", paramLang, isMobile, key);
					SessionHelper.setSimpleSession("LanguageCode", paramLang, isMobile, key);
				}
					
				// 일회성으로 세션 생성&유지
				//SessionHelper.setSession("OneTimeLogon", "Y", false);
				SessionHelper.setSimpleSession("OneTimeLogon", "Y", isMobile, key);
				
				// 접속로그 생성
				LoggerHelper.connectLogger();
			}
		}
		
		return status;
	}

	@Override
	public void changeBodyContext(CoviMap params) throws Exception {
		String formInstID = "";
		int revision = 0;
		String mode = params.getString("mode");
		String userCode = params.getString("userCode");
		String bodyContextStr = params.getString("bodyContext");
		CoviMap bodyContext = new CoviMap();
		
		if(mode.equalsIgnoreCase("PROCESS")){
			formInstID = coviMapperOne.selectOne("form.forLegacy.selectFormInstID", params);
		}else if(mode.equalsIgnoreCase("COMPLETE")){
			formInstID = coviMapperOne.selectOne("form.forLegacy.selectFormInstID_archive", params);
		}
		params.put("FormInstID", formInstID);
		
		//BodyConext 수정 (HTMLBody나 JSONBody 있을 경우 해당 내용만 변경)
		if(bodyContextStr != null && !bodyContextStr.equals("")){
			bodyContext = CoviMap.fromObject(bodyContextStr);
			
			if(bodyContext.has("HTMLBody") || bodyContext.has("JSONBody")){
				String oldBodyContextStr = coviMapperOne.selectOne("form.forLegacy.selectBodyContext", params);
				oldBodyContextStr = new String(Base64.decodeBase64(oldBodyContextStr.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
				
				CoviMap oldBodyContext = CoviMap.fromObject(oldBodyContextStr);
				
				oldBodyContext.put("HTMLBody", bodyContext.getString("HTMLBody"));
				oldBodyContext.put("JSONBody", bodyContext.getString("JSONBody"));
				
				if(bodyContext.has("MobileBody")) {
					oldBodyContext.put("MobileBody", bodyContext.getString("MobileBody"));
				}
				
				bodyContext = oldBodyContext;
			}
		}
		
		if(!formInstID.equals("")){
			// Form History 데이터 INSERT
			revision = coviMapperOne.selectOne("form.formhistory.selectReivision", params);
			
			params.put("FieldName", "BodyContext");
			params.put("FieldType", "");
			params.put("Revision", revision);
			params.put("RegID", userCode);
			params.put("ModID", userCode);
			coviMapperOne.insert("form.formhistory.insertFromFormInstance", params);
			
			// BodyContext 데이터 UPDATE
			params.put("FieldValue", new String(Base64.encodeBase64(bodyContext.toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
			params.put("LastModifierID", userCode);
			coviMapperOne.update("form.forminstance.updateRevision", params);
			
			// Description 데이터 UPDATE
			coviMapperOne.update("form.forLegacy.updateModifyProcessDesc", params);
			coviMapperOne.update("form.forLegacy.updateModifyCirculationDesc", params);
			
			//if(mode.equalsIgnoreCase("COMPLETE")){
			//	coviMapperOne.update("form.forLegacy.updateModifyProcessDesc_archive", params);
			//}
		}
	}
	
	@Override
	public CoviMap selectDraftLegacySystemList(CoviMap params) throws Exception {				
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("form.forLegacy.selectDraftLegacySystemCnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		
		list = coviMapperOne.list("form.forLegacy.selectDraftLegacySystemList", params);		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", pagingData);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectDraftLegacySystemData(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("form.forLegacy.selectDraftLegacySystem", params);		
		CoviMap resultList = new CoviMap();		
		CoviList list = (CoviList)CoviSelectSet.coviSelectJSON(map);
		resultList.put("map", list);	
		
		return resultList;
	}
	
	@Override
	public int insertDraftLegacySystemData(CoviMap params) throws Exception {
		return coviMapperOne.insert("form.forLegacy.insertDraftLegacySystem", params);
	}
	
	@Override
	public int updateDraftLegacySystemData(CoviMap params) throws Exception {
		return coviMapperOne.update("form.forLegacy.updateDraftLegacySystem", params);
	}
	
	@Override
	public int deleteDraftLegacySystemData(CoviMap params) throws Exception {
		return coviMapperOne.delete("form.forLegacy.deleteDraftLegacySystem", params);
	}
	
	@Override
	public CoviMap selectDraftLegacyList(CoviMap params) throws Exception {				
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		list = coviMapperOne.list("form.forLegacy.selectDraftLegacyList", params);		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectDraftSampleList(CoviMap params) throws Exception {				
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		list = coviMapperOne.list("form.forLegacy.selectDraftSampleList", params);		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		
		return resultList;
	}
	
	
	
	@Override
	public CoviMap selectLogonID(String empno, String logonId) throws Exception {
		// 사번으로 LogonID 조회해오기
		CoviMap params = new CoviMap();
		params.put("empNo", empno);
		params.put("logonId", logonId);
		
		CoviMap resultMap = coviMapperOne.select("form.forLegacy.selectLogonID", params);
		return CoviSelectSet.coviSelectJSON(resultMap, "LogonID,DeptCode").getJSONObject(0);
	}
	
	@Override
	public CoviMap selectLogonID(String userCode) throws Exception {
		// 사번으로 LogonID 조회해오기
		CoviMap params = new CoviMap();
		params.put("usercode", userCode);
		
		CoviMap resultMap = coviMapperOne.select("form.forLegacy.selectLogonID", params);
		return CoviSelectSet.coviSelectJSON(resultMap, "LogonID,DeptCode").getJSONObject(0);
	}
	
	@Override
	public CoviMap selectLogonIDByDept(String empno, String logonId, String deptId) throws Exception {
		// 사번으로 LogonID 조회해오기
		CoviMap params = new CoviMap();
		params.put("empNo", empno);
		params.put("logonId", logonId);
		params.put("deptId", deptId);
		
		CoviMap resultMap = coviMapperOne.select("form.forLegacy.selectLogonID", params);
		return CoviSelectSet.coviSelectJSON(resultMap, "LogonID,DeptCode").getJSONObject(0);
	}
	
	@Override
	public CoviMap selectLogonIDByDept(String userCode, String deptId) throws Exception {
		// 사번으로 LogonID 조회해오기
		CoviMap params = new CoviMap();
		params.put("usercode", userCode);
		params.put("deptId", deptId);
		
		CoviMap resultMap = coviMapperOne.select("form.forLegacy.selectLogonID", params);
		return CoviSelectSet.coviSelectJSON(resultMap, "LogonID,DeptCode").getJSONObject(0);
	}
	
	
	/* 기간계에서 넘겨받을 결재선 예시)
	 * 발신부서 type : Approve , P_P_Consult , P_S_Consult , D_P_Consult , D_S_Consult , P_P_Assist , P_S_Assist , D_P_Assist , D_S_Assist
	 * 수신부서 type : Rec_Dept
	 * 접수, 재기안시 결재선 division[0]의 type을 redraft로 다시 받을 것!! division[1] 불필요. 접수는 결재선없을시 세션사용자로 처리
		division : [
			{
				index : 1
				type : send / redraft
				step : [
					{
						index : 1
						type : Approve/D_S_Consult/P_P_Assist
						userCode
						deptCode
					},
					{
						index : 2
						type : D_P_Consult  //부서(병렬)합의
						deptCode
					},
					{
						index : 2
						type : D_P_Consult //부서(병렬)합의
						deptCode
					},
					{
						index : 3
						type : Approve/DeptConsult
						userCode
						deptCode
					}
				]
			},
			{
				index : 2
				type : receive
				step : [
					{
						index : 1
						type : Rec_Dept
						userCode
						deptCode
					}
				]
			}
		]
		ccinfo : [
			{
				type : before/after
				kind : send/receive
				userCode
				deptCode
			}
		]*/
	@Override
	public CoviMap getApvLineForDraft(CoviMap params) throws Exception {
		String userID = params.optString("userID");
		String deptID = params.optString("deptID");
		String deptName = "";
		CoviList divisionArr = new CoviList();
		CoviList ccinfoArr = new CoviList();
		try {
			if(params.containsKey("APRV_LINE")){
				CoviMap aprvObj = params.getJSONObject("APRV_LINE");
				if(aprvObj.containsKey("division")) {
					if(aprvObj.get("division") instanceof CoviList){
						divisionArr = (CoviList) aprvObj.get("division");
					}else{
						divisionArr.add(aprvObj.getJSONObject("division"));
					}
				}
				if(aprvObj.containsKey("ccinfo")) {
					if(aprvObj.get("ccinfo") instanceof CoviList){
						ccinfoArr = (CoviList) aprvObj.get("ccinfo");
					}else{
						ccinfoArr.add(aprvObj.getJSONObject("ccinfo"));
					}
				}
			}
		}catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		CoviMap initiatorMap = null;
		String strEmpNo = params.optString("empNo");

		CoviMap userInfo = new CoviMap();
		userInfo.put("empNo", strEmpNo);
		userInfo.put("UserCode", userID);
		initiatorMap = coviMapperOne.select("form.forLegacy.selectUserInfoDetail", userInfo);
		deptID = initiatorMap.optString("DeptCode");
		deptName = initiatorMap.optString("DeptName");
		
		//SchemaContext 협조자 최종결재 사용 옵션체크. SchemaContext.scLastAssistDraft.isUse
		CoviMap schemaContextInfo = coviMapperOne.select("form.forLegacy.selectSchemaContext", params);
		boolean scLastAssistDraft = false;
		if(!schemaContextInfo.isEmpty() && schemaContextInfo.getJSONObject("SchemaContext").containsKey("scLastAssistDraft")) {
			scLastAssistDraft = "Y".equals(schemaContextInfo.getJSONObject("SchemaContext").getJSONObject("scLastAssistDraft").optString("isUse")) ? true : false;
		}
		
		CoviMap returnApvLine = new CoviMap();
		CoviMap oSteps = new CoviMap();
		CoviList aSteps = new CoviList();
		CoviList aDivisions = new CoviList();
		CoviList aCCinfos = new CoviList();
		
		String adivType = "send";
		String adivName = DicHelper.getDic("lbl_apv_circulation_sent");
		
		// 기안자에 대한 Division
		CoviMap defaultDivision = new CoviMap();
		CoviMap defaultDivisionTk = new CoviMap();
		if(divisionArr != null && !divisionArr.isEmpty() && "redraft".equals(divisionArr.getJSONObject(0).optString("type"))) {
			adivType = "receive";
			DicHelper.getDic("lbl_apv_charge_approve");
			defaultDivision.put("processID", params.optString("processID"));
			defaultDivision.put("processDescID", params.optString("processDescID"));
		}
		defaultDivision.put("divisiontype", adivType);
		defaultDivision.put("name", adivName);
		defaultDivision.put("oucode", deptID);
		defaultDivision.put("ouname", deptName);
		
		defaultDivisionTk.put("status", "pending");
		defaultDivisionTk.put("result", "pending");
		defaultDivisionTk.put("kind", adivType);
		defaultDivisionTk.put("datereceived", DateHelper.getCurrentDay("yyyy-MM-dd hh:mm:ss"));
	
		defaultDivision.put("taskinfo", defaultDivisionTk);
		defaultDivision.put("step", aSteps);
		aDivisions.add(defaultDivision);
		
		//수신처 Division
		CoviMap oDivision = null;
		
        if(divisionArr != null && !divisionArr.isEmpty()) {
        	for(int i=0; i<divisionArr.size(); i++){
        		CoviMap divMap = divisionArr.getJSONObject(i);
        		String strdivType = divMap.optString("type");
    			if(divMap.containsKey("step")) {
    				CoviList stepList = new CoviList();
					if(divMap.get("step") instanceof CoviList){
						stepList = (CoviList) divMap.get("step");
					}else{
						stepList.add(divMap.getJSONObject("step"));
					}
					
					for(int j=0; j<stepList.size(); j++){
						CoviMap stepMap = stepList.getJSONObject(j);
				    	int sIndex = stepMap.optInt("index", 0); // 결재순서
						String sAppTypeCode = stepMap.optString("type"); // 결재타입코드
						String sUserCode = stepMap.optString("userCode"); // 결재자 사번
						String sComCode = stepMap.optString("deptCode"); // 결재자 부서 코드
						//유저코드와 부서코드 둘다 빈값일경우 처리
						if(StringUtil.isNull(sUserCode) && StringUtil.isNull(sComCode)){
							continue;
						}
						//마지막결재선 체크
						if(j == stepList.size()-1) {
							if(sAppTypeCode.contains("Consult")) {
								throw new Exception("결재선에 합의는 마지막에 올수 없습니다.");
							}else if(sAppTypeCode.contains("Assist") && !scLastAssistDraft) {
								throw new Exception("결재선에 협조는 마지막에 올수 없습니다. 협조자 최종결재 사용시 옵션을 확인해주세요.");
							}
						}
						
						String sStep_UnitType = "person";
						String sStep_Name = DicHelper.getDic("lbl_apv_app"); // 결재
						String sStep_RouteType = "approve";
						String sStep_AllotType = "serial";
						String sTaskinfo_Kind = "normal";
						if(sAppTypeCode.startsWith("D")) sStep_UnitType = "ou";
						if(sAppTypeCode.contains("P_Assist") || sAppTypeCode.contains("P_Consult")) sStep_AllotType = "parallel";
						
			            if (sAppTypeCode.contains("Assist")) { //협조
			            	sStep_RouteType = "assist";
			            	sTaskinfo_Kind = "assist";
			            	
			            	if(sAppTypeCode.equals("D_P_Assist")) sStep_Name = DicHelper.getDic("lbl_apv_DeptAssist2"); //부서협조(병렬)
			            	else if(sAppTypeCode.equals("D_S_Assist")) sStep_Name = DicHelper.getDic("lbl_apv_DeptAssist"); //부서협조
			            	else if(sAppTypeCode.equals("P_P_Assist")) sStep_Name = DicHelper.getDic("lbl_apv_assist_2"); //개인협조(병렬)
			            	else sStep_Name = DicHelper.getDic("lbl_apv_assist"); //개인협조
			            }else if (sAppTypeCode.contains("Consult")) { //합의
			            	sStep_RouteType = "consult";
			            	sTaskinfo_Kind = "consult";
			            	
			            	if(sAppTypeCode.equals("D_P_Consult")) sStep_Name = DicHelper.getDic("lbl_apv_DeptConsent_2"); //부서협의(병렬)
			            	else if(sAppTypeCode.equals("D_S_Consult")) sStep_Name = DicHelper.getDic("lbl_apv_DeptConsent"); //부서합의
			            	else if(sAppTypeCode.equals("P_P_Consult")) sStep_Name = DicHelper.getDic("lbl_apv_Par"); //병렬합의
			            	else sStep_Name = DicHelper.getDic("lbl_apv_Seq"); //순차합의
			            }else if(sAppTypeCode.contains("Rec_")) {//수신처
			            	sStep_RouteType = "receive";
			            	
			            	if(sAppTypeCode.equals("Rec_Dept")) {
			            		sStep_UnitType = "ou";
			            		sStep_Name = DicHelper.getDic("lbl_apv_ChargeDept_Rec");	//담당부서 수신
			            	}else {
			            		sStep_Name = DicHelper.getDic("lbl_apv_charge_approve");	// 담당결재
			            	}
			            }
			            
						CoviMap params_ur = new CoviMap();
						params_ur.put("UserCode", sUserCode);
						params_ur.put("DeptCode", sComCode); 
						
						CoviMap item = new CoviMap(); 
						if(sStep_UnitType.equals("person")) {
							item = coviMapperOne.select("form.forLegacy.selectUserInfoDetail", params_ur);
						}else {
							item = coviMapperOne.select("form.forLegacy.selectDeptInfoDetail", params_ur);
						}
						if(item.isEmpty()) { //결재자 정보가 없는경우
							continue;	
						}
			            
						String sStatus = "inactive";
						String sResult = "inactive";
						if(("send".equals(strdivType) || "redraft".equals(strdivType)) && j==0){
							sStep_Name = DicHelper.getDic("lbl_apv_writer");
							sTaskinfo_Kind = "charge";
							sStatus = "pending";
							sResult = "pending";
						}
						
			            CoviMap oStep = new CoviMap();
			            CoviMap oStepTask = new CoviMap();
			            CoviMap oOU = new CoviMap();
			            CoviMap oPerson = new CoviMap();
			            CoviMap oPersonTask = new CoviMap();
			            			            
						oStep.put("name", sStep_Name);
						oStep.put("unittype", sStep_UnitType);
						oStep.put("routetype", sStep_RouteType);
						if (sStep_RouteType.equalsIgnoreCase("consult") || sStep_RouteType.equalsIgnoreCase("assist")) { //합의,협조
		                	oStepTask.put("kind", sTaskinfo_Kind);
		                	oStepTask.put("status", "inactive");
		                	oStepTask.put("result", "inactive");
		                	oStep.put("taskinfo", oStepTask);
		                	oStep.put("allottype", sStep_AllotType);
		                }
						if (sStep_UnitType.equalsIgnoreCase("person")) {
			                oPerson.put("ouname", item.getString("DeptName"));
			                oPerson.put("oucode", item.getString("DeptCode"));
			                oPerson.put("name", item.getString("UserName"));
			                oPerson.put("code", item.getString("UserCode"));
			                oPerson.put("title", item.getString("JobTitleCode") + ";" + item.getString("MultiJobTitleName"));
			                oPerson.put("position", item.getString("JobPositionCode") + ";" + item.getString("MultiJobPositionName"));
			                oPerson.put("level", item.getString("JobLevelCode") + ";" + item.getString("MultiJobLevelName"));
			                oPerson.put("sipaddress", item.getString("MailAddress"));
			                
			                oPersonTask.put("kind", sTaskinfo_Kind);
			                oPersonTask.put("status", sStatus);
			                oPersonTask.put("result", sResult);
			                oPerson.put("taskinfo", oPersonTask);
			            	oOU.put("person", oPerson);
						} else {
							oPersonTask.put("kind", sTaskinfo_Kind);
						    oPersonTask.put("status", "inactive");
						    oPersonTask.put("result", "inactive");
						    oOU.put("taskinfo", oPersonTask);
						}
						oOU.put("name", item.getString("DeptName"));
						oOU.put("code", item.getString("DeptCode"));
						
			            if(sStep_AllotType.equals("parallel") && j>1) { //병렬타입
			            	CoviList oOUlist = new CoviList();
			            	CoviMap prevObj = stepList.getJSONObject(j-1);
			            	int sPrevIndex = prevObj.optInt("index");
			            	if(sPrevIndex == sIndex) {
			            		CoviMap prevOUobj = aDivisions.getJSONObject(0).getJSONArray("step").getJSONObject(sPrevIndex-1);
			            		if(prevOUobj.get("ou") instanceof CoviMap) {
			            			oOUlist.add(prevOUobj.getJSONObject("ou"));
			            		}else {
			            			oOUlist = prevOUobj.getJSONArray("ou");
			            		}
			            		aDivisions.getJSONObject(0).getJSONArray("step").remove(sPrevIndex-1);
			            	}
			            	oOUlist.add(oOU);
			            	oStep.put("ou", oOUlist);
			            }else {
			            	oStep.put("ou", oOU);
			            }
			            
			            if(strdivType.equalsIgnoreCase("receive")){ // 수신일때만 새로 만듦.
			            	oDivision = new CoviMap();
			            	CoviMap oDivisionTask = new CoviMap();
			            	oDivision.put("name", sStep_Name);
			            	oDivision.put("divisiontype", "receive");
			            	oDivision.put("ouname", (sStep_UnitType.equalsIgnoreCase("person") ? item.getString("UserName") : item.getString("DeptName")));
			            	oDivision.put("oucode", (sStep_UnitType.equalsIgnoreCase("person") ? item.getString("UserCode") : item.getString("DeptCode")));
			            	
			            	oDivisionTask.put("kind", "receive");
			            	oDivisionTask.put("status", "inactive");
			            	oDivisionTask.put("result", "inactive");
			            	oDivision.put("taskinfo", oDivisionTask);
			            	oDivision.put("step", oStep);
			            }else{
			            	aDivisions.getJSONObject(0).getJSONArray("step").add(oStep);
			            }
					}
    			}
			}	
		}
        if(adivType.equals("receive")) { //재기안시, 기안부서결재선 셋팅
        	aDivisions.add(0, params.getJSONObject("ApprovalLine").getJSONObject("steps").getJSONArray("division").getJSONObject(0));
        }
        
        if(oDivision != null && !oDivision.isEmpty()){
        	aDivisions.add(oDivision);
        }
        if(params.optString("mode").equals("TEMPSAVE")) {//임시저장시 기안자 제외
        	if(aDivisions.getJSONObject(0).get("step") instanceof CoviList) {
        		aDivisions.getJSONObject(0).getJSONArray("step").remove(0); 
        	}else {
        		aDivisions.getJSONObject(0).remove("step"); 
        	}
        }
        oSteps.put("division", (aDivisions.size() > 1) ? aDivisions : aDivisions.getJSONObject(0));
		
		//참조
		if(ccinfoArr != null && !ccinfoArr.isEmpty()) {
			for(Object Obj: ccinfoArr){
				CoviMap ccObj = (CoviMap)Obj;
				CoviMap item = new CoviMap();;
				CoviMap params_ur = new CoviMap();
				params_ur.put("UserCode", ccObj.optString("userCode"));
				params_ur.put("DeptCode", ccObj.optString("deptCode"));
				String ccType = "USER";
				if(ccObj.containsKey("userCode") && StringUtil.isNotEmpty(ccObj.optString("userCode"))) {
					item = coviMapperOne.select("form.forLegacy.selectUserInfoDetail", params_ur);
				}else {
					ccType = "DEPT";
					item = coviMapperOne.select("form.forLegacy.selectDeptInfoDetail", params_ur);
				}
				if(item.isEmpty()) { //결재자 정보가 없는경우
					continue;	
				}
				
                CoviMap oCCinfo  = new CoviMap();
                String strBelongto = "receive".equals(ccObj.optString("kind")) ? "receiver" : "sender";
                oCCinfo.put("belongto", strBelongto);
                oCCinfo.put("sendername", initiatorMap.optString("UserName"));
                oCCinfo.put("senderid", initiatorMap.optString("UserCode"));
                if(ccObj.optString("type").equals("Before")) {
                	oCCinfo.put("beforecc", "y");
                }
	            oCCinfo.put("datereceived", "");

	            CoviMap oOU = new CoviMap();
                oOU.put("name", item.getString("DeptName"));
                oOU.put("code", item.getString("DeptCode"));
                if(ccType.equals("USER")) {
                	CoviMap oPerson = new CoviMap();
                    oPerson.put("ouname", item.getString("DeptName"));
                    oPerson.put("oucode", item.getString("DeptCode"));
                    oPerson.put("name", item.getString("UserName"));
                    oPerson.put("code", item.getString("UserCode"));                            	
	                oOU.put("person", oPerson);
                }
                oCCinfo.put("ou", oOU);
                aCCinfos.add(oCCinfo);
				
				if(!aCCinfos.isEmpty()){
					if(ccinfoArr.size() > 1) {
						oSteps.put("ccinfo", aCCinfos);
					}else {
						oSteps.put("ccinfo", aCCinfos.get(0));
					}
				}
			}
		}
		returnApvLine.put("steps", oSteps);
		
		return returnApvLine;
	}
}
