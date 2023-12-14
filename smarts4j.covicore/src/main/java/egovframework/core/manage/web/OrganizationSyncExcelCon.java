package egovframework.core.manage.web;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;








import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import egovframework.core.manage.service.OrganizationSyncExcelSvc;
import egovframework.core.sevice.OrgSyncManageSvc;
import egovframework.core.web.OrgSyncCon;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;


/**
 * @Class Name : OrganizationExcelSyncCon.java
 * @Description : 조직관리
 * @Modification Information 
 * @ 2016.05.03 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.07
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class OrganizationSyncExcelCon {
	private Logger LOGGER = LogManager.getLogger(OrganizationSyncExcelCon.class);
	
	@Autowired
	private OrganizationSyncExcelSvc OrganizationSyncExcelSvc;
	@Autowired
	private OrgSyncManageSvc orgSyncManageSvc;

	

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private boolean isSaaS = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N"));
	private String licSection = "Y";
	
	/**
	 * 계열사 엑셀동기화 대상여부 확인
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/checkSyncCompany.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkSyncCompany(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("DomainID", request.getParameter("DomainID"));
			
			CoviMap checkObject = OrganizationSyncExcelSvc.checkSyncCompany(params);
			if ("invalid".equals(checkObject.get("result"))) {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "회사 정보가 유효하지 않습니다.");
				if (checkObject.get("list") != null) returnObj.put("list", checkObject.get("list"));
			}
			else {
				returnObj.put("list", checkObject.get("list"));
				returnObj.put("result", "ok");
				returnObj.put("status", Return.SUCCESS);
				returnObj.put("message", "조회되었습니다");
			}
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
			
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	

	/**
	 * @Method Name : uploadDeptExcelSyncData
	 * @Description : 엑셀업로드(부서)
	 */
	@RequestMapping(value = "manage/conf/uploadDeptExcelSyncData.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap uploadDeptExcelSyncData(HttpServletRequest request
													,@RequestParam(value="uploadfile", required=false) MultipartFile uploadfile
													, @RequestParam Map<String, Object> param){
		String indexArr[] = new String[12];
		
		String strDomainID;
		//CoviList listData = new CoviList();
		//CoviMap mapData;
		CoviMap params = new CoviMap();
		CoviMap resultObj = new CoviMap();
		CoviMap returnObj = new CoviMap();
		CoviMap mapTemp= new CoviMap();
		String prefix = "";
		String strCompanyCode;
		String strTemp1 = "";
		String strTemp2 = "";
		CoviList listMailDomain = new CoviList();
		try {
			params.putAll(param);
			listMailDomain = RedisDataUtil.getBaseCode("MailDomain", params.getString("DomainID"));
			//excel_orgdept 초기화
			params.put("syncCompanyCode",params.get("CompanyCode"));
			OrganizationSyncExcelSvc.deleteExcelorgdept(params);
			strCompanyCode = params.getString("CompanyCode");
			
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////
			mapTemp.put("uploadfile",	uploadfile);
			ArrayList<ArrayList<Object>> dataList = extractionExcelData(mapTemp, 0);	// 엑셀 데이터 추출
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////			
			if(isSaaS)prefix = strCompanyCode+"_";
			for (int i=0;i< dataList.size();i++) {
				ArrayList<Object> tempList = dataList.get(i);
				String[] tempArr = tempList.toArray(new String[0]);
				/*mapData = new CoviMap();
				for(int j = 0; j < tempArr.length; j++) {
					if(i == 0) {
						if(tempArr[j].toUpperCase().equals("GROUPCODE")) {
							indexArr[j] = "GroupCode";
						} else if (tempArr[j].toUpperCase().equals("COMPANYCODE")) {
							indexArr[j] = "CompanyCode";
						} else if (tempArr[j].toUpperCase().equals("MEMBEROF")) {
							indexArr[j] = "MemberOf";
						} else if (tempArr[j].toUpperCase().equals("DISPLAYNAME")) {
							indexArr[j] = "DisplayName";
						} else if (tempArr[j].toUpperCase().equals("MULTIDISPLAYNAME")) {
							indexArr[j] = "MultiDisplayName";
						} else if (tempArr[j].toUpperCase().equals("SORTKEY")) {
							indexArr[j] = "SortKey";
						} else if (tempArr[j].toUpperCase().equals("ISUSE")) {
							indexArr[j] = "IsUse";
						} else if (tempArr[j].toUpperCase().equals("ISHR")) {
							indexArr[j] = "IsHR";
						} else if (tempArr[j].toUpperCase().equals("ISDISPLAY")) {
							indexArr[j] = "IsDisplay";
						} else if (tempArr[j].toUpperCase().equals("ISMAIL")) {
							indexArr[j] = "IsMail";
						} else if (tempArr[j].toUpperCase().equals("PRIMARYMAIL")) {
							indexArr[j] = "PrimaryMail";
						} else if (tempArr[j].toUpperCase().equals("MANAGERCODE")) {
							indexArr[j] = "ManagerCode";
						}
					} else {
						mapData.put(indexArr[j], tempArr[j]);
					}
				}
				if(i == 0) { 
					continue;
				}*/
				if (!strCompanyCode.equalsIgnoreCase(tempArr[1])) 
					continue;

				//listData.add(mapData);
				if (tempArr[0] == null || tempArr[0].toUpperCase().equals(DicHelper.getDic("lbl_DeptCode"))) //GROUPCODE
					continue;
				
				params = new CoviMap();
				
				if(tempArr.length < 9) {
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", DicHelper.getDic("msg_noDeptValue"));
					break;
				}
				strTemp1=tempArr[0];
				if(!"".equals(prefix))
					strTemp1=tempArr[0].replace(prefix, "");

				if (strTemp1.isEmpty() || strTemp1.equals("")
				|| tempArr[1].isEmpty() || tempArr[1].equals("")
				|| tempArr[2].isEmpty() || tempArr[2].equals("")
				|| tempArr[3].isEmpty() || tempArr[3].equals("")
				|| tempArr[6].isEmpty() || tempArr[6].equals("")
				|| tempArr[7].isEmpty() || tempArr[7].equals("")
				|| tempArr[8].isEmpty() || tempArr[8].equals("")) 
				{
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", DicHelper.getDic("msg_noDeptValue"));
					break;
				}
				
				strTemp1=tempArr[0];
				strTemp2=tempArr[2];
				if(strTemp1.indexOf(prefix) == -1) strTemp1=prefix + strTemp1;
				if(!strTemp2.equalsIgnoreCase(strCompanyCode))//최상위X
					if(strTemp2.indexOf(prefix) == -1) strTemp2=prefix + strTemp2;
				if(tempArr.length >= 9) {
					params.put("GroupCode", strTemp1);
					params.put("CompanyCode", tempArr[1]);
					params.put("MemberOf", strTemp2);
					params.put("DisplayName", tempArr[3]);
					params.put("MultiDisplayName", tempArr[4].isEmpty() ? tempArr[3] + ";;;;;;;;;" : tempArr[4]);
					params.put("SortKey", tempArr[5].isEmpty() ? "99999" : tempArr[5]);
					params.put("IsUse", tempArr[6]);
					params.put("IsHR", tempArr[7]);
					params.put("IsDisplay", tempArr[8]);
					params.put("IsMail","N");
				}
				if(tempArr.length >= 11&&"Y".equals(tempArr[9])) {
					params.put("IsMail", tempArr[9]);
					strTemp2 = tempArr[10];
					if(strTemp2.isEmpty()||strTemp2.indexOf("@") ==-1) {
						resultObj.put("result", "FAIL");
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", "["+tempArr[3]+"]" + DicHelper.getDic("msg_valid_mailDomain"));
						break;
					}
					mapTemp = searchMapfromList(listMailDomain,"CodeName",strTemp2.split("@")[1]);
					if(mapTemp.size()==0){
						resultObj.put("result", "FAIL");
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", "["+tempArr[3]+"]" + DicHelper.getDic("msg_valid_mailDomain"));
						break;
					}
					params.put("PrimaryMail", strTemp2);
				} else {
					params.put("PrimaryMail", "");
				}
				if(tempArr.length >= 12) {
					params.put("ManagerCode", tempArr[11] != null && !tempArr[11].equals("") ? tempArr[11] : "");
				}
			
				
				CoviMap dupObj = checkDuplicateDept(params);
				if(dupObj.get("status").toString().equalsIgnoreCase("FAIL")) {
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", dupObj.get("message").toString());
					break;
				} else {
					resultObj = OrganizationSyncExcelSvc.insertFileDataDept(params);						
				}
				
				if (!resultObj.getString("result").equals("OK")) {
					return resultObj;
				}
			}

			if ("OK".equals(resultObj.getString("result"))) {
				// excel table -> compare table
				returnObj = OrganizationSyncExcelSvc.syncCompareObjectForExcel("DEPT");
				int compareGroupCnt = returnObj.getInt("compareGroupCnt");
				int compareUserCnt = returnObj.getInt("compareUserCnt");

				if (compareGroupCnt >= 0 && compareUserCnt >= 0) {
					//returnObj.put("list", listData);
					returnObj.put("result", "ok");

					returnObj.put("status", Return.SUCCESS);
					returnObj.put("message", "조회 성공");
				} else {
					returnObj.put("status", Return.SUCCESS);
					returnObj.put("message", "동기화 대상이 존재하지 않습니다.");
				}
			} else return returnObj;

		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnObj;
	}
	
	/**
	 * @Method Name : uploadUserExcelSyncData
	 * @Description : 엑셀업로드(사용자)
	 */
	@RequestMapping(value = "manage/conf/uploadUserExcelSyncData.do", method=RequestMethod.POST)
	public	@ResponseBody CoviMap uploadUserExcelSyncData(HttpServletRequest request
													,@RequestParam(value="uploadfile", required=true) MultipartFile uploadfile
													, @RequestParam Map<String, Object> param){
		String indexArr[] = new String[30];
		//CoviList listData = new CoviList();
		//CoviMap mapData;
		CoviMap params = new CoviMap();
		CoviMap resultObj = new CoviMap();
		CoviMap returnObj = new CoviMap();
		CoviMap mapTemp= new CoviMap();
		String prefix = "";
		String strCompanyCode;
		String strTemp1 = "";
		String strTemp2 = "";
		CoviList listMailDomain = new CoviList();
		CoviList licenseList = new CoviList();
		CoviMap mapLicense = new CoviMap();
		try {
			params.putAll(param);
			strCompanyCode = params.getString("CompanyCode");
			listMailDomain = RedisDataUtil.getBaseCode("MailDomain", params.getString("DomainID"));
			params.put("licSection", licSection);
			params.put("searchGUBUN", "DOMAINID");
			licenseList = (CoviList) OrganizationSyncExcelSvc.selectLicenseList(params).get("list");
			
			params.put("syncCompanyCode",params.get("CompanyCode"));
			//excel_orgdept 초기화
			OrganizationSyncExcelSvc.deleteExcelorguser(params);
			
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////
			mapTemp.put("uploadfile",	uploadfile);
			ArrayList<ArrayList<Object>> dataList = extractionExcelData(mapTemp, 0);	// 엑셀 데이터 추출
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////	
			if(isSaaS)prefix = strCompanyCode+"_";
			for (int i = 0; i < dataList.size(); i++) {
				ArrayList<Object> tempList = dataList.get(i);
				String[] tempArr = tempList.toArray(new String[0]);
				mapLicense = new CoviMap();
				/*mapData = new CoviMap();
				for (int j = 0; j < tempArr.length; j++) {
					if (i == 0) {
						if (tempArr[j].toUpperCase().equals("LICSEQ")) {
							indexArr[j] = "LicSeq";
						} else if (tempArr[j].toUpperCase().equals("USERCODE")) {
							indexArr[j] = "UserCode";
						} else if (tempArr[j].toUpperCase().equals("COMPANYCODE")) {
							indexArr[j] = "CompanyCode";
						} else if (tempArr[j].toUpperCase().equals("DEPTCODE")) {
							indexArr[j] = "DeptCode";
						} else if (tempArr[j].toUpperCase().equals("LOGONID")) {
							indexArr[j] = "LogonID";
						} else if (tempArr[j].toUpperCase().equals("LOGONPW")) {
							indexArr[j] = "LogonPW";
						} else if (tempArr[j].toUpperCase().equals("EMPNO")) {
							indexArr[j] = "EmpNo";
						} else if (tempArr[j].toUpperCase().equals("DISPLAYNAME")) {
							indexArr[j] = "DisplayName";
						} else if (tempArr[j].toUpperCase().equals("MULTIDISPLAYNAME")) {
							indexArr[j] = "MultiDisplayName";
						} else if (tempArr[j].toUpperCase().equals("JOBPOSITIONCODE")) {
							indexArr[j] = "JobPositionCode";
						} else if (tempArr[j].toUpperCase().equals("JOBTITLECODE")) {
							indexArr[j] = "JobTitleCode";
						} else if (tempArr[j].toUpperCase().equals("JOBLEVELCODE")) {
							indexArr[j] = "JobLevelCode";
						} else if (tempArr[j].toUpperCase().equals("SORTKEY")) {
							indexArr[j] = "SortKey";
						} else if (tempArr[j].toUpperCase().equals("ISUSE")) {
							indexArr[j] = "IsUse";
						} else if (tempArr[j].toUpperCase().equals("ISHR")) {
							indexArr[j] = "IsHR";
						} else if (tempArr[j].toUpperCase().equals("ISDISPLAY")) {
							indexArr[j] = "IsDisplay";
						} else if (tempArr[j].toUpperCase().equals("USEMAILCONNECT")) {
							indexArr[j] = "UseMailConnect";
						} else if (tempArr[j].toUpperCase().equals("ENTERDATE")) {
							indexArr[j] = "EnterDate";
						} else if (tempArr[j].toUpperCase().equals("RETIREDATE")) {
							indexArr[j] = "RetireDate";
						} else if (tempArr[j].toUpperCase().equals("BIRTHDIV")) {
							indexArr[j] = "BirthDiv";
						} else if (tempArr[j].toUpperCase().equals("BIRTHDATE")) {
							indexArr[j] = "BirthDate";
						} else if (tempArr[j].toUpperCase().equals("PHOTOPATH")) {
							indexArr[j] = "PhotoPath";
						} else if (tempArr[j].toUpperCase().equals("MAILADDRESS")) {
							indexArr[j] = "MailAddress";
						} else if (tempArr[j].toUpperCase().equals("EXTERNALMAILADDRESS")) {
							indexArr[j] = "ExternalMailAddress";
						} else if (tempArr[j].toUpperCase().equals("CHARGEBUSINESS")) {
							indexArr[j] = "ChargeBusiness";
						} else if (tempArr[j].toUpperCase().equals("PHONENUMBERINTER")) {
							indexArr[j] = "PhoneNumberInter";
						} else if (tempArr[j].toUpperCase().equals("PHONENUMBER")) {
							indexArr[j] = "PhoneNumber";
						} else if (tempArr[j].toUpperCase().equals("MOBILE")) {
							indexArr[j] = "Mobile";
						} else if (tempArr[j].toUpperCase().equals("FAX")) {
							indexArr[j] = "Fax";
						} else if (tempArr[j].toUpperCase().equals("USEMESSENGERCONNECT")) {
							indexArr[j] = "UseMessengerConnect";
						}
					} else {
						mapData.put(indexArr[j], tempArr[j]);
					}
				}*/
				if(i == 0) { 
					continue;
				}

				if (!strCompanyCode.equalsIgnoreCase(tempArr[2])) 
					continue;

				if (tempArr[1].toUpperCase().equals(DicHelper.getDic("lbl_User_Id"))) //USERCODE
					continue;
				
				params = new CoviMap();
				if(tempArr.length < 17) {
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", DicHelper.getDic("msg_noUserValue"));
					break;
				}
				strTemp1=tempArr[1];
				if(!"".equals(prefix))
					strTemp1=tempArr[1].replace(prefix, "");

				if (strTemp1.isEmpty() || strTemp1.equals("")
					|| tempArr[0].isEmpty() || tempArr[0].equals("")
					|| tempArr[2].isEmpty() || tempArr[2].equals("")
					|| tempArr[3].isEmpty() || tempArr[3].equals("")
					|| tempArr[4].isEmpty() || tempArr[4].equals("")
					|| tempArr[6].isEmpty() || tempArr[6].equals("")
					|| tempArr[7].isEmpty() || tempArr[7].equals("")
					|| tempArr[13].isEmpty() || tempArr[13].equals("")
					|| tempArr[14].isEmpty() || tempArr[14].equals("")
					|| tempArr[15].isEmpty() || tempArr[15].equals("")
					|| tempArr[16].isEmpty() || tempArr[16].equals("")) 
				{
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", DicHelper.getDic("msg_noUserValue"));
					break;
				} 
				mapLicense = searchMapfromList(licenseList,"LicSeq",tempArr[0]);
				if(mapLicense.size()==0){
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", "["+tempArr[1]+"]"+DicHelper.getDic("msg_ValidLicense"));
					break;
				}
				strTemp1=tempArr[1];
				strTemp2=tempArr[3];
				if(strTemp1.indexOf(prefix) == -1) strTemp1=prefix + strTemp1;
				if(!strTemp2.equalsIgnoreCase(strCompanyCode))//최상위X
					if(strTemp2.indexOf(prefix) == -1) strTemp2=prefix + strTemp2;

				if(tempArr.length >= 17) {
					params.put("LicSeq", tempArr[0]);
					params.put("UserCode", strTemp1);
					params.put("CompanyCode", tempArr[2]);
					params.put("DeptCode", strTemp2);
					params.put("LogonID", tempArr[4]);
					params.put("LogonPW", tempArr[5].isEmpty() ? RedisDataUtil.getBaseConfig("InitPassword",params.getString("DomainID")) : tempArr[5]);
					params.put("EmpNo", tempArr[6]);
					params.put("DisplayName", tempArr[7]);
					params.put("MultiDisplayName", tempArr[8].isEmpty() ? tempArr[7] + ";;;;;;;;;" : tempArr[8]);
					params.put("JobPositionCode", tempArr[9].isEmpty() ? "" : tempArr[9]);
					params.put("JobTitleCode", tempArr[10].isEmpty() ? "" : tempArr[10]);
					params.put("JobLevelCode", tempArr[11].isEmpty() ? "" : tempArr[11]);
					params.put("SortKey", tempArr[12].isEmpty() ? "99999" : tempArr[12]);
					params.put("IsUse", tempArr[13]);
					params.put("IsHR", tempArr[14]);
					params.put("IsDisplay", tempArr[15]);
				}
				if(tempArr.length >= 18) {
					params.put("EnterDate", tempArr[17].isEmpty() ? "" : tempArr[17]);
				}
				if(tempArr.length >= 19) {
					params.put("RetireDate", tempArr[18].isEmpty() ? "" : tempArr[18]);
				}
				if(tempArr.length >= 20) {
					params.put("BirthDiv", tempArr[19].isEmpty() ? "" : tempArr[19]);
				}
				if(tempArr.length >= 21) {
					params.put("BirthDate", tempArr[20].isEmpty() ? "" : tempArr[20]);
				}
				if(tempArr.length >= 22) {
					params.put("PhotoPath", tempArr[21].isEmpty() ? "" : tempArr[21]);
				}
				if("N".equals(mapLicense.getString("LicMail"))) {
					if(tempArr[16].isEmpty()){
						tempArr[16] = "N";						
					}
					params.put("UseMailConnect", "N");
					params.put("MailAddress", "");
				}
				
				if(tempArr.length >= 23) {
					//if(tempArr[16].equalsIgnoreCase("Y")&&!tempArr[22].isEmpty()){
					if(tempArr[16].equalsIgnoreCase("Y")){
						List<Map<String, Object>> listMap = listMailDomain; 
						String mailDomail = listMap.get(0).get("CodeName").toString();
						if(!tempArr[22].isEmpty()){
							strTemp2 = tempArr[22].indexOf("@") > 0 ? tempArr[22] : tempArr[22] + "@" + mailDomail;
						}else{
							strTemp2 = strTemp1 + "@" + mailDomail;
						}
						
						if(strTemp2.indexOf("@") ==-1) {
							resultObj.put("result", "FAIL");
							returnObj.put("status", Return.FAIL);
						}
						params.put("UseMailConnect", "Y");
						params.put("MailAddress", strTemp2);
					}else{
						params.put("UseMailConnect", "N");
						params.put("MailAddress", "");
					}
				}
				if(tempArr.length >= 24) {
					params.put("ExternalMailAddress", tempArr[23].isEmpty() ? "" : tempArr[23]);
				}
				if(tempArr.length >= 25) {
					params.put("ChargeBusiness", tempArr[24].isEmpty() ? "" : tempArr[24]);
				}
				if(tempArr.length >= 26) {
					params.put("PhoneNumberInter", tempArr[25].isEmpty() ? "" : tempArr[25]);
				}
				if(tempArr.length >= 27) {
					params.put("PhoneNumber", tempArr[26].isEmpty() ? "" : tempArr[26]);
				}
				if(tempArr.length >= 28) {	
					params.put("Mobile", tempArr[27].isEmpty() ? "" : tempArr[27]);
				}
				if(tempArr.length >= 29) {
					params.put("Fax", tempArr[28].isEmpty() ? "" : tempArr[28]);
				}
				if(tempArr.length >= 30) {
					params.put("UseMessengerConnect", tempArr[29].isEmpty() ? "" : tempArr[29]);
				}

				CoviMap dupObj = checkDuplicateUser(params); 
				if(dupObj.get("status").toString().equalsIgnoreCase("FAIL")) {
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", dupObj.get("message").toString());
					break;
				} else {
					resultObj = OrganizationSyncExcelSvc.insertFileDataUser(params);
				}
				
				
				if (!resultObj.getString("result").equals("OK")) {
					return resultObj;
				}
				
			}
			
			if ("OK".equals(resultObj.getString("result"))) {
				// excel table -> compare table
				returnObj = OrganizationSyncExcelSvc.syncCompareObjectForExcel("USER");
				int compareGroupCnt = returnObj.getInt("compareGroupCnt");
				int compareUserCnt = returnObj.getInt("compareUserCnt");

				if (compareGroupCnt >= 0 && compareUserCnt >= 0) {
					//returnObj.put("list", listData);
					returnObj.put("result", "ok");

					returnObj.put("status", Return.SUCCESS);
					returnObj.put("message", "조회 성공");
				} else {
					returnObj.put("status", Return.SUCCESS);
					returnObj.put("message", "동기화 대상이 존재하지 않습니다.");
				}
			} else return returnObj;
			
		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	/**
	 * selectImportedOrgDeptList : 엑셀 파일 읽어오기
	 * 미사용!
	 * @param request
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	//@SuppressWarnings("unchecked")
	@RequestMapping(value = "manage/conf/selectImportedOrgDeptList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectImportedOrgDeptList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		String strData;
		String arrData[];
		String indexArr[] = new String[12];
		String strDomainID;
		CoviList listData = new CoviList();
		CoviMap mapData;
		CoviMap params = new CoviMap();
		CoviMap resultObj = new CoviMap();
		CoviMap returnObj = new CoviMap();
		CoviMap mapTemp;
		String prefix = "";
		String strCompanyCode;
		String strTemp1 = "";
		String strTemp2 = "";
		CoviList listMailDomain = new CoviList();
		try {
			strData = StringUtil.replaceNull(request.getParameter("objectData"), "");
			arrData = strData.split("§");
			strDomainID = StringUtil.replaceNull(request.getParameter("DomainID"), "");
			params.put("DomainID", strDomainID);
			CoviList domainInfoList = (CoviList) OrganizationSyncExcelSvc.checkSyncCompany(params).get("list");
			mapTemp = (CoviMap)domainInfoList.get(0);
			params.putAll(mapTemp);
			params.put("syncCompanyCode",params.get("CompanyCode"));
			listMailDomain = RedisDataUtil.getBaseCode("MailDomain", strDomainID);
			//excel_orgdept 초기화
			OrganizationSyncExcelSvc.deleteExcelorgdept(params);
			
			//get Domain info
			//strCompanymaildomain = RedisDataUtil.getBaseConfig("IndiMailDomain", strDomainID);
			strCompanyCode = mapTemp.getString("CompanyCode");
			if(isSaaS)
				prefix = strCompanyCode+"_";
			for (int i = 0; i < arrData.length; i++) {
				String tempArr[] = arrData[i].split("†");
				mapData = new CoviMap();
				for(int j = 0; j < tempArr.length; j++) {
					if(i == 0) {
						if(tempArr[j].toUpperCase().equals("GROUPCODE")) {
							indexArr[j] = "GroupCode";
						} else if (tempArr[j].toUpperCase().equals("COMPANYCODE")) {
							indexArr[j] = "CompanyCode";
						} else if (tempArr[j].toUpperCase().equals("MEMBEROF")) {
							indexArr[j] = "MemberOf";
						} else if (tempArr[j].toUpperCase().equals("DISPLAYNAME")) {
							indexArr[j] = "DisplayName";
						} else if (tempArr[j].toUpperCase().equals("MULTIDISPLAYNAME")) {
							indexArr[j] = "MultiDisplayName";
						} else if (tempArr[j].toUpperCase().equals("SORTKEY")) {
							indexArr[j] = "SortKey";
						} else if (tempArr[j].toUpperCase().equals("ISUSE")) {
							indexArr[j] = "IsUse";
						} else if (tempArr[j].toUpperCase().equals("ISHR")) {
							indexArr[j] = "IsHR";
						} else if (tempArr[j].toUpperCase().equals("ISDISPLAY")) {
							indexArr[j] = "IsDisplay";
						} else if (tempArr[j].toUpperCase().equals("ISMAIL")) {
							indexArr[j] = "IsMail";
						} else if (tempArr[j].toUpperCase().equals("PRIMARYMAIL")) {
							indexArr[j] = "PrimaryMail";
						} else if (tempArr[j].toUpperCase().equals("MANAGERCODE")) {
							indexArr[j] = "ManagerCode";
						}
					} else {
						mapData.put(indexArr[j], tempArr[j]);
					}
				}
				if(i == 0) { 
					continue;
				}
				if (!strCompanyCode.equalsIgnoreCase(tempArr[1])) 
					continue;

				listData.add(mapData);
				if (tempArr[0] == null || tempArr[0].toUpperCase().equals("GROUPCODE"))
					continue;
				
				params = new CoviMap();
				
				if(tempArr.length < 9) {
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", "msg_noDeptValue");
					break;
				}
				strTemp1=tempArr[0];
				if(!"".equals(prefix))
					strTemp1=tempArr[0].replace(prefix, "");

				if (strTemp1.isEmpty() || strTemp1.equals("")
				|| tempArr[1].isEmpty() || tempArr[1].equals("")
				|| tempArr[2].isEmpty() || tempArr[2].equals("")
				|| tempArr[3].isEmpty() || tempArr[3].equals("")
				|| tempArr[6].isEmpty() || tempArr[6].equals("")
				|| tempArr[7].isEmpty() || tempArr[7].equals("")
				|| tempArr[8].isEmpty() || tempArr[8].equals("")) 
				{
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", "msg_noDeptValue");
					break;
				}
				
				strTemp1=tempArr[0];
				strTemp2=tempArr[2];
				if(strTemp1.indexOf(prefix) == -1) strTemp1=prefix + strTemp1;
				if(!strTemp2.equalsIgnoreCase(strCompanyCode))//최상위X
					if(strTemp2.indexOf(prefix) == -1) strTemp2=prefix + strTemp2;
				if(tempArr.length >= 9) {
					params.put("GroupCode", strTemp1);
					params.put("CompanyCode", tempArr[1]);
					params.put("MemberOf", strTemp2);
					params.put("DisplayName", tempArr[3]);
					params.put("MultiDisplayName", tempArr[4].isEmpty() ? tempArr[3] + ";;;;;;;;;" : tempArr[4]);
					params.put("SortKey", tempArr[5].isEmpty() ? "99999" : tempArr[5]);
					params.put("IsUse", tempArr[6]);
					params.put("IsHR", tempArr[7]);
					params.put("IsDisplay", tempArr[8]);
					params.put("IsMail","N");
				}
				if(tempArr.length >= 11) {
					params.put("IsMail", tempArr[9]);
					strTemp2 = tempArr[10];
					if(strTemp2.isEmpty()||strTemp2.indexOf("@") ==-1) {
						resultObj.put("result", "FAIL");
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", strTemp2 + "|msg_valid_mailDomain");
						break;
					}
					mapTemp = searchMapfromList(listMailDomain,"CodeName",strTemp2.split("@")[1]);
					if(mapTemp.size()==0){
						resultObj.put("result", "FAIL");
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", strTemp2 + "|msg_valid_mailDomain");
						break;
					}
					params.put("PrimaryMail", strTemp2);
				} else {
					params.put("PrimaryMail", "");
				}
				if(tempArr.length >= 12) {
					params.put("ManagerCode", tempArr[11] != null && !tempArr[11].equals("") ? tempArr[11] : "");
				}
			
				
				CoviMap dupObj = checkDuplicateDept(params);
				if(dupObj.get("status").toString().equalsIgnoreCase("FAIL")) {
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", dupObj.get("message").toString());
					break;
				} else {
					resultObj = OrganizationSyncExcelSvc.insertFileDataDept(params);						
				}
				
				if (!resultObj.getString("result").equals("OK")) {
					return resultObj;
				}
			}

			if ("OK".equals(resultObj.getString("result"))) {
				// excel table -> compare table
				returnObj = OrganizationSyncExcelSvc.syncCompareObjectForExcel("DEPT");
				int compareGroupCnt = returnObj.getInt("compareGroupCnt");
				int compareUserCnt = returnObj.getInt("compareUserCnt");

				if (compareGroupCnt >= 0 && compareUserCnt >= 0) {
					returnObj.put("list", listData);
					returnObj.put("result", "ok");

					returnObj.put("status", Return.SUCCESS);
					returnObj.put("message", "조회 성공");
				} else {
					returnObj.put("status", Return.SUCCESS);
					returnObj.put("message", "동기화 대상이 존재하지 않습니다.");
				}
			} else return returnObj;

		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnObj;
	}
	/**
	 * selectImportedOrgUserList : 엑셀 파일 읽어오기
	 * 미사용!
	 * @param request
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked" })
	@RequestMapping(value = "manage/conf/selectImportedOrgUserList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap selectImportedOrgUserList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters

		String strData;
		String arrData[];
		String indexArr[] = new String[30];

		CoviList listData = new CoviList();
		CoviMap mapData;
		CoviMap params = new CoviMap();
		CoviMap resultObj = new CoviMap();
		CoviMap returnObj = new CoviMap();
		CoviMap mapTemp;
		String prefix = "";
		String strDomainID;
		String strCompanyCode;
		String strTemp1 = "";
		String strTemp2 = "";
		String tempArr[];
		CoviList listMailDomain = new CoviList();
		CoviList licenseList = new CoviList();
		CoviMap mapLicense = new CoviMap();
		try {
			strData = StringUtil.replaceNull(request.getParameter("objectData"), "");
			arrData = strData.split("§");
			strDomainID = StringUtil.replaceNull(request.getParameter("DomainID"), "");
			listMailDomain = RedisDataUtil.getBaseCode("MailDomain", strDomainID);
			params.put("DomainID", strDomainID);
			params.put("licSection", licSection);
			CoviList domainInfoList = (CoviList) OrganizationSyncExcelSvc.checkSyncCompany(params).get("list");
			licenseList = (CoviList) OrganizationSyncExcelSvc.selectLicenseList(params).get("list");
			mapTemp = (CoviMap)domainInfoList.get(0);
			
			params.putAll(mapTemp);
			params.put("syncCompanyCode",params.get("CompanyCode"));
			//excel_orgdept 초기화
			OrganizationSyncExcelSvc.deleteExcelorguser(params);
			
			//get Domain info
			strCompanyCode = mapTemp.getString("CompanyCode");


			
			if(isSaaS)
				prefix = strCompanyCode+"_";
			for (int i = 0; i < arrData.length; i++) {
				mapLicense = new CoviMap();
				tempArr = arrData[i].split("†");
				mapData = new CoviMap();
				for (int j = 0; j < tempArr.length; j++) {
					if (i == 0) {
						if (tempArr[j].toUpperCase().equals("LICSEQ")) {
							indexArr[j] = "LicSeq";
						} else if (tempArr[j].toUpperCase().equals("USERCODE")) {
							indexArr[j] = "UserCode";
						} else if (tempArr[j].toUpperCase().equals("COMPANYCODE")) {
							indexArr[j] = "CompanyCode";
						} else if (tempArr[j].toUpperCase().equals("DEPTCODE")) {
							indexArr[j] = "DeptCode";
						} else if (tempArr[j].toUpperCase().equals("LOGONID")) {
							indexArr[j] = "LogonID";
						} else if (tempArr[j].toUpperCase().equals("LOGONPW")) {
							indexArr[j] = "LogonPW";
						} else if (tempArr[j].toUpperCase().equals("EMPNO")) {
							indexArr[j] = "EmpNo";
						} else if (tempArr[j].toUpperCase().equals("DISPLAYNAME")) {
							indexArr[j] = "DisplayName";
						} else if (tempArr[j].toUpperCase().equals("MULTIDISPLAYNAME")) {
							indexArr[j] = "MultiDisplayName";
						} else if (tempArr[j].toUpperCase().equals("JOBPOSITIONCODE")) {
							indexArr[j] = "JobPositionCode";
						} else if (tempArr[j].toUpperCase().equals("JOBTITLECODE")) {
							indexArr[j] = "JobTitleCode";
						} else if (tempArr[j].toUpperCase().equals("JOBLEVELCODE")) {
							indexArr[j] = "JobLevelCode";
						} else if (tempArr[j].toUpperCase().equals("SORTKEY")) {
							indexArr[j] = "SortKey";
						} else if (tempArr[j].toUpperCase().equals("ISUSE")) {
							indexArr[j] = "IsUse";
						} else if (tempArr[j].toUpperCase().equals("ISHR")) {
							indexArr[j] = "IsHR";
						} else if (tempArr[j].toUpperCase().equals("ISDISPLAY")) {
							indexArr[j] = "IsDisplay";
						} else if (tempArr[j].toUpperCase().equals("USEMAILCONNECT")) {
							indexArr[j] = "UseMailConnect";
						} else if (tempArr[j].toUpperCase().equals("ENTERDATE")) {
							indexArr[j] = "EnterDate";
						} else if (tempArr[j].toUpperCase().equals("RETIREDATE")) {
							indexArr[j] = "RetireDate";
						} else if (tempArr[j].toUpperCase().equals("BIRTHDIV")) {
							indexArr[j] = "BirthDiv";
						} else if (tempArr[j].toUpperCase().equals("BIRTHDATE")) {
							indexArr[j] = "BirthDate";
						} else if (tempArr[j].toUpperCase().equals("PHOTOPATH")) {
							indexArr[j] = "PhotoPath";
						} else if (tempArr[j].toUpperCase().equals("MAILADDRESS")) {
							indexArr[j] = "MailAddress";
						} else if (tempArr[j].toUpperCase().equals("EXTERNALMAILADDRESS")) {
							indexArr[j] = "ExternalMailAddress";
						} else if (tempArr[j].toUpperCase().equals("CHARGEBUSINESS")) {
							indexArr[j] = "ChargeBusiness";
						} else if (tempArr[j].toUpperCase().equals("PHONENUMBERINTER")) {
							indexArr[j] = "PhoneNumberInter";
						} else if (tempArr[j].toUpperCase().equals("PHONENUMBER")) {
							indexArr[j] = "PhoneNumber";
						} else if (tempArr[j].toUpperCase().equals("MOBILE")) {
							indexArr[j] = "Mobile";
						} else if (tempArr[j].toUpperCase().equals("FAX")) {
							indexArr[j] = "Fax";
						} else if (tempArr[j].toUpperCase().equals("USEMESSENGERCONNECT")) {
							indexArr[j] = "UseMessengerConnect";
						}
					} else {
						mapData.put(indexArr[j], tempArr[j]);
					}
				}
				if(i == 0) { 
					continue;
				}

				if (!strCompanyCode.equalsIgnoreCase(tempArr[2])) 
					continue;

				if (tempArr[1].toUpperCase().equals("USERCODE")) 
					continue;
				
				params = new CoviMap();
				if(tempArr.length < 17) {
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", "msg_noUserValue");
					break;
				}
				strTemp1=tempArr[1];
				if(!"".equals(prefix))
					strTemp1=tempArr[1].replace(prefix, "");

				if (strTemp1.isEmpty() || strTemp1.equals("")
					|| tempArr[0].isEmpty() || tempArr[0].equals("")
					|| tempArr[2].isEmpty() || tempArr[2].equals("")
					|| tempArr[3].isEmpty() || tempArr[3].equals("")
					|| tempArr[4].isEmpty() || tempArr[4].equals("")
					|| tempArr[6].isEmpty() || tempArr[6].equals("")
					|| tempArr[7].isEmpty() || tempArr[7].equals("")
					|| tempArr[13].isEmpty() || tempArr[13].equals("")
					|| tempArr[14].isEmpty() || tempArr[14].equals("")
					|| tempArr[15].isEmpty() || tempArr[15].equals("")
					|| tempArr[16].isEmpty() || tempArr[16].equals("")) 
				{
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", "msg_noUserValue");
					break;
				} 
				mapLicense = searchMapfromList(licenseList,"LicSeq",tempArr[0]);
				if(mapLicense.size()==0){
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", tempArr[1]+"|msg_ValidLicense");
					break;
				}
				strTemp1=tempArr[1];
				strTemp2=tempArr[3];
				if(strTemp1.indexOf(prefix) == -1) strTemp1=prefix + strTemp1;
				if(!strTemp2.equalsIgnoreCase(strCompanyCode))//최상위X
					if(strTemp2.indexOf(prefix) == -1) strTemp2=prefix + strTemp2;

				if(tempArr.length >= 17) {
					params.put("LicSeq", tempArr[0]);
					params.put("UserCode", strTemp1);
					params.put("CompanyCode", tempArr[2]);
					params.put("DeptCode", strTemp2);
					params.put("LogonID", tempArr[4]);
					params.put("LogonPW", tempArr[5].isEmpty() ? RedisDataUtil.getBaseConfig("InitPassword",strDomainID) : tempArr[5]);
					params.put("EmpNo", tempArr[6]);
					params.put("DisplayName", tempArr[7]);
					params.put("MultiDisplayName", tempArr[8].isEmpty() ? tempArr[7] + ";;;;;;;;;" : tempArr[8]);
					params.put("JobPositionCode", tempArr[9].isEmpty() ? "" : tempArr[9]);
					params.put("JobTitleCode", tempArr[10].isEmpty() ? "" : tempArr[10]);
					params.put("JobLevelCode", tempArr[11].isEmpty() ? "" : tempArr[11]);
					params.put("SortKey", tempArr[12].isEmpty() ? "99999" : tempArr[12]);
					params.put("IsUse", tempArr[13]);
					params.put("IsHR", tempArr[14]);
					params.put("IsDisplay", tempArr[15]);
				}
				if(tempArr.length >= 18) {
					params.put("EnterDate", tempArr[17].isEmpty() ? "" : tempArr[17]);
				}
				if(tempArr.length >= 19) {
					params.put("RetireDate", tempArr[18].isEmpty() ? "" : tempArr[18]);
				}
				if(tempArr.length >= 20) {
					params.put("BirthDiv", tempArr[19].isEmpty() ? "" : tempArr[19]);
				}
				if(tempArr.length >= 21) {
					params.put("BirthDate", tempArr[20].isEmpty() ? "" : tempArr[20]);
				}
				if(tempArr.length >= 22) {
					params.put("PhotoPath", tempArr[21].isEmpty() ? "" : tempArr[21]);
				}
				if("N".equals(mapLicense.get("LicMail")))
					tempArr[16] = "N";
				params.put("UseMailConnect", "N");
				params.put("MailAddress", "");
				if(tempArr.length >= 23) {
					if(tempArr[16].equalsIgnoreCase("Y")&&!tempArr[22].isEmpty()){
						strTemp2 = tempArr[22];
						if(strTemp2.indexOf("@") ==-1) {
							resultObj.put("result", "FAIL");
							returnObj.put("status", Return.FAIL);
							returnObj.put("message", strTemp2 + "|msg_valid_mailDomain");
							break;
						}

						mapTemp = searchMapfromList(listMailDomain,"CodeName",strTemp2.split("@")[1]);
						if(mapTemp.size()==0){
							resultObj.put("result", "FAIL");
							returnObj.put("status", Return.FAIL);
							returnObj.put("message", strTemp2 + "|msg_valid_mailDomain");
							break;
						}
						params.put("UseMailConnect", "Y");
						params.put("MailAddress", strTemp2);
						
					}
				}
				if(tempArr.length >= 24) {
					params.put("ExternalMailAddress", tempArr[23].isEmpty() ? "" : tempArr[23]);
				}
				if(tempArr.length >= 25) {
					params.put("ChargeBusiness", tempArr[24].isEmpty() ? "" : tempArr[24]);
				}
				if(tempArr.length >= 26) {
					params.put("PhoneNumberInter", tempArr[25].isEmpty() ? "" : tempArr[25]);
				}
				if(tempArr.length >= 27) {
					params.put("PhoneNumber", tempArr[26].isEmpty() ? "" : tempArr[26]);
				}
				if(tempArr.length >= 28) {	
					params.put("Mobile", tempArr[27].isEmpty() ? "" : tempArr[27]);
				}
				if(tempArr.length >= 29) {
					params.put("Fax", tempArr[28].isEmpty() ? "" : tempArr[28]);
				}
				if(tempArr.length >= 30) {
					params.put("UseMessengerConnect", tempArr[29].isEmpty() ? "" : tempArr[29]);
				}

				CoviMap dupObj = checkDuplicateUser(params); 
				if(dupObj.get("status").toString().equalsIgnoreCase("FAIL")) {
					resultObj.put("result", "FAIL");
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", dupObj.get("message").toString());
					break;
				} else {
					resultObj = OrganizationSyncExcelSvc.insertFileDataUser(params);
				}
				
				
				if (!resultObj.getString("result").equals("OK")) {
					return resultObj;
				}
				
			}
			
			if ("OK".equals(resultObj.getString("result"))) {
				// excel table -> compare table
				returnObj = OrganizationSyncExcelSvc.syncCompareObjectForExcel("USER");
				int compareGroupCnt = returnObj.getInt("compareGroupCnt");
				int compareUserCnt = returnObj.getInt("compareUserCnt");

				if (compareGroupCnt >= 0 && compareUserCnt >= 0) {
					returnObj.put("list", listData);
					returnObj.put("result", "ok");

					returnObj.put("status", Return.SUCCESS);
					returnObj.put("message", "조회 성공");
				} else {
					returnObj.put("status", Return.SUCCESS);
					returnObj.put("message", "동기화 대상이 존재하지 않습니다.");
				}
			} else return returnObj;
			
		} catch (NullPointerException e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/** 미사용
	 * 엑셀동기화 - 부서
	 * @param req
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	/*@RequestMapping(value = "manage/conf/syncExcelDataDept.do", method = { RequestMethod.GET,RequestMethod.POST })
	public @ResponseBody CoviMap syncExcelDataDept(MultipartHttpServletRequest req, HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviList resultList = new CoviList();

		try {
			//로그 추가
			OrgSyncCon orgSyncCon = new OrgSyncCon();
			orgSyncManageSvc.insertLogList();
			
			if(RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {
				orgSyncCon.syncGroup("DEPT", "INSERT");
				orgSyncCon.syncGroup("DEPT", "UPDATE");
				orgSyncCon.syncGroup("DEPT", "DELETE");
			}
			
			if(RedisDataUtil.getBaseConfig("IsSyncTimeSquare").equals("Y")) {
				if(RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {
					orgSyncCon.syncGroup("DEPT", "INSERT");
					orgSyncCon.syncGroup("DEPT", "UPDATE");
					orgSyncCon.syncGroup("DEPT", "DELETE");
				}
			}
			
			if(RedisDataUtil.getBaseConfig("IsSyncIndi").equals("Y")) {
				if(RedisDataUtil.getBaseConfig("IsDBDeptSync").equals("Y")) {
					orgSyncCon.syncGroup("DEPT", "INSERT");
					orgSyncCon.syncGroup("DEPT", "UPDATE");
					orgSyncCon.syncGroup("DEPT", "DELETE");
				}
			}
			
			
//			boolean breturn = false;
//			// 세션정보
//			String strCompanymaildomain = RedisDataUtil.getBaseConfig("IndiMailDomain");
//
//			CoviMap params = new CoviMap();
//			CoviMap params2 = new CoviMap();
//
//			int index = 0;
//			while (req.getParameter("Data[" + index + "].GroupCode") != null) {
//
//				params.put("syncType", req.getParameter("Data[" + index + "].SyncType"));
//				params.put("searchType", "GroupCodeSync");
//				params.put("searchText", req.getParameter("Data[" + index + "].GroupCode"));
//				
//				resultList = (CoviList) OrganizationSyncExcelSvc.getExcelTempDeptDataList(params).get("list");
//				
//				params2.put("GroupCode", req.getParameter("Data[" + index + "].GroupCode"));
//				params2.put("CompanyCode", resultList.getJSONObject(0).getString("CompanyCode"));
//				params2.put("MemberOf", resultList.getJSONObject(0).getString("MemberOf"));
//				params2.put("DisplayName", resultList.getJSONObject(0).getString("DisplayName"));
//				params2.put("MultiDisplayName", resultList.getJSONObject(0).getString("MultiDisplayName"));
//				params2.put("SortKey", resultList.getJSONObject(0).getString("SortKey"));
//				params2.put("IsUse", resultList.getJSONObject(0).getString("IsUse"));
//				params2.put("IsHR", resultList.getJSONObject(0).getString("IsHR"));
//				params2.put("IsDisplay", resultList.getJSONObject(0).getString("IsDisplay"));
//				params2.put("IsMail", resultList.getJSONObject(0).getString("IsMail"));
//				params2.put("PrimaryMail", resultList.getJSONObject(0).getString("PrimaryMail"));
//				params2.put("ManagerCode", resultList.getJSONObject(0).getString("ManagerCode"));
//
//				returnObj = OrganizationSyncExcelSvc.insertFileDataDept(params);
//				
//				if (returnObj.getString("result") != "OK") {
//					return returnObj;
//				}
//				breturn = true;
//				index++;
//			}
//
//			if (breturn) {
//				// excel_orgdept -> compare_object_group
//				//OrganizationSyncExcelSvc.syncCompareObjectForExcel();
//			}

		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return returnObj;
	}*/

	/**
	 * 부서 대상 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/getExcelTempDeptList.do", method = { RequestMethod.GET,RequestMethod.POST })
	public @ResponseBody CoviMap getExcelTempDeptList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();		
		
		CoviMap otherCompanyParams = new CoviMap();
		otherCompanyParams.put("CompanyCode", StringUtil.replaceNull(request.getParameter("companyCode"), ""));
		
		int iReturn = OrganizationSyncExcelSvc.deleteOtherCompany(otherCompanyParams);

		// 정렬 및 페이징
		String strSort = StringUtil.replaceNull(request.getParameter("sortBy"), "");
		String strsyncType = StringUtil.replaceNull(request.getParameter("syncType"), "");
		String strsearchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		String strsearchText = StringUtil.replaceNull(request.getParameter("searchText"), "");
		
		String strSortColumn = "GroupCode";
		String strSortDirection = "ASC";
		String strPageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
		String strPageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");

		if (strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}		

		try {
			CoviMap params = new CoviMap();
			params.put("syncType", strsyncType.equals("A") ? "" : strsyncType);
			params.put("searchType", strsearchType != null && !strsearchType.equals("") ? strsearchType : "");
			params.put("searchText", strsearchText != null && !strsearchText.equals("") ? ComUtils.RemoveSQLInjection(strsearchText, 100) : "");
			
			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
			
			params.put("pageNo", strPageNo);
			params.put("pageSize", strPageSize);
			
			CoviMap resultList = OrganizationSyncExcelSvc.getExcelTempDeptDataList(params);

			returnList.put("page", resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}

	/**
	 * 사용자 대상 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/getExcelTempUserList.do", method = { RequestMethod.GET,RequestMethod.POST })
	public @ResponseBody CoviMap getExcelTempUserList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		CoviMap page = new CoviMap();
		CoviMap params2 = new CoviMap();
		String strCompanyCode = request.getParameter("companyCode");
		params2.put("CompanyCode",strCompanyCode);
		
		int iReturn = OrganizationSyncExcelSvc.deleteOtherCompany(params2);

		// 정렬 및 페이징
		String strSort = StringUtil.replaceNull(request.getParameter("sortBy"), "");
		String strsyncType = StringUtil.replaceNull(request.getParameter("syncType"), "");
		String strsearchType = StringUtil.replaceNull(request.getParameter("searchType"), "");
		String strsearchText = StringUtil.replaceNull(request.getParameter("searchText"), "");		
		
		String strSortColumn = "UserCode";
		String strSortDirection = "ASC";
		String strPageNo = StringUtil.replaceNull(request.getParameter("pageNo"), "1");
		String strPageSize = StringUtil.replaceNull(request.getParameter("pageSize"), "10");

		if (strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
		
		try {
			CoviMap params = new CoviMap();

			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
			params.put("syncType", "A".equals(strsyncType) ? "" : strsyncType);
			
			params.put("searchType", strsearchType != null && !strsearchType.equals("") ? strsearchType : "");
			params.put("searchText", strsearchText != null && !strsearchText.equals("") ? ComUtils.RemoveSQLInjection(strsearchText, 100) : "");

			params.put("pageNo", strPageNo);
			params.put("pageSize", strPageSize);			
			
			CoviMap excelTempUserDataList = OrganizationSyncExcelSvc.getExcelTempUserDataList(params);

			returnList.put("page", excelTempUserDataList.get("page"));
			returnList.put("list", excelTempUserDataList.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * 선택한 부서 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/deleteSelectDept.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteSelectDept(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String strDeleteData = StringUtil.replaceNull(request.getParameter("deleteData"), "");
		int result = 0;
		
		try {
			CoviMap params = new CoviMap();
			
			for(int i = 0; i < strDeleteData.split(",").length; i++) {
				String DeleteDataArr[] = strDeleteData.split(",");
				String deleteObject = DeleteDataArr[i];
				
				params.put("GroupCode",deleteObject);
				
				result = OrganizationSyncExcelSvc.deleteSelectDept(params);
			}
			
			if(result > 0) {			
				returnList.put("object", result);
				returnList.put("result", "ok");
	
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "삭제되었습니다");
			} else {
				returnList.put("object", result);
				returnList.put("result", "FAIL");
	
				returnList.put("status", Return.FAIL);
				returnList.put("message", "삭제되었습니다");			
			}
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * 선택한 사용자 삭제
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "manage/conf/deleteSelectUser.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteSelectUser(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		String strDeleteData = StringUtil.replaceNull(request.getParameter("deleteData"), "");
		int result = 0;
		
		try {
			CoviMap params = new CoviMap();
			
			for(int i = 0; i < strDeleteData.split(",").length; i++) {
				String DeleteDataArr[] = strDeleteData.split(",");
				String deleteObject = DeleteDataArr[i];
				
				params.put("UserCode",deleteObject);
				
				result = OrganizationSyncExcelSvc.deleteSelectUser(params);
			}
			
			if(result > 0) {			
				returnList.put("object", result);
				returnList.put("result", "ok");
	
				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "삭제되었습니다");
			} else {
				returnList.put("object", result);
				returnList.put("result", "FAIL");
	
				returnList.put("status", Return.FAIL);
				returnList.put("message", "삭제되었습니다");			
			}
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * 대상 데이터 초기화
	 */
	@RequestMapping(value = "manage/conf/deleteTemp.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteTemp(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		int result = 0;
		
		try {
			result = OrganizationSyncExcelSvc.deleteTemp();
			
			if(result > 0) {			
				returnList.put("object", result);
				returnList.put("result", "ok");

				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "삭제되었습니다");
			} else {
				returnList.put("object", result);
				returnList.put("result", "FAIL");

				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "삭제할 대상이 존재하지 않습니다");			
			}
		} catch (NullPointerException e){
			result = 0;
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			result = 0;
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * 전체 초기화
	 */
	@RequestMapping(value = "manage/conf/deleteAll.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteAll(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		int result = 0;
		
		try {
			CoviMap params = new CoviMap();
			params.put("DomainID", request.getParameter("DomainID"));
			params.put("Type", request.getParameter("Type"));
			
			result = OrganizationSyncExcelSvc.deleteAll(params);
			
			if(result > 0) {			
				returnList.put("object", result);
				returnList.put("result", "ok");

				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "삭제되었습니다");
			} else {
				returnList.put("object", result);
				returnList.put("result", "FAIL");

				returnList.put("status", Return.SUCCESS);
				returnList.put("message", "삭제할 대상이 존재하지 않습니다");			
			}
		} catch (NullPointerException e){
			result = 0;
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			result = 0;
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	 * 부서 데이터  GroupCode, 메일주소 validation 체크
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public CoviMap checkDuplicateDept(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		
		String pattern1 = ".*[\\{\\}\\[\\]?.,;:|\\)*~`!^\\-+┼<>@\\#$%&\\\\(\\=\\'\"]+.*";
		String pattern2 = ".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*";
		String pattern3 = ".*[\\{\\}\\[\\]?,;:|\\)*~`!^\\+┼<>\\#$%&\\\\(\\=\\'\\\"]+.*";
		String pattern4 = ".*[\\{\\}\\[\\]?.,;:|*~`!^\\+┼<>@\\#$%&\\=\\'\\\"]+.*";
		
		try {
			//GroupCode
			params.put("dupType", "Excel");
			CoviList dup1 = (CoviList) OrganizationSyncExcelSvc.selectIsDupDeptCode(params).get("list");
			
			if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "["+params.get("GroupCode").toString() +"]"+ DicHelper.getDic("msg_EXIST_GRCODE"));
				return returnList;
			}
			
			if(Pattern.matches(pattern1, params.get("GroupCode").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "["+params.get("GroupCode").toString()+"]" + DicHelper.getDic("msg_specialNotAllowed"));
				return returnList;
			}
			
			if(Pattern.matches(pattern2, params.get("GroupCode").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "["+params.get("GroupCode").toString()+"]" + DicHelper.getDic("msg_KoreanNotAllowed"));
				return returnList;
			}
			
			//메일주소
			if(!params.get("PrimaryMail").toString().equals("")) {
				params.put("MailAddress", params.get("PrimaryMail").toString());
				params.put("Code", params.get("GroupCode").toString());
				
				dup1 = (CoviList) orgSyncManageSvc.selectIsDuplicateMail(params).get("list"); 
				
				if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "["+params.get("PrimaryMail").toString() +"]"+ DicHelper.getDic("msg_exist_mailaddress"));
					return returnList;
				}
				
				if(Pattern.matches(pattern3, params.get("PrimaryMail").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "["+params.get("PrimaryMail").toString() +"]"+ DicHelper.getDic("msg_specialNotAllowed"));
					return returnList;
				}
				
				if(Pattern.matches(pattern2, params.get("PrimaryMail").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "["+params.get("PrimaryMail").toString()+"]" + DicHelper.getDic("msg_KoreanNotAllowed"));
					return returnList;
				}
			}
			
			//부서명
			if(!params.get("DisplayName").toString().equals("")) {
				if(Pattern.matches(pattern4, params.get("DisplayName").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "["+params.get("DisplayName").toString()+"]"+ DicHelper.getDic("msg_specialNotAllowed"));
					return returnList;
				}
			}
			
			//상위부서
			if(!params.get("MemberOf").toString().equals("")) {
				if(params.get("MemberOf").toString().equals(params.get("GroupCode").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "["+params.get("GroupCode").toString()+"]" + DicHelper.getDic("msg_SameCodeMemberOf"));
					return returnList;
				}
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "SUCCESS");
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	public CoviMap searchMapfromList(CoviList list,String strKey, String strValue){
		CoviMap mapReturn=new CoviMap();
		try{
			for(int i=0;i<list.size();i++){
				CoviMap map = (CoviMap)list.get(i);
				if(map.get(strKey).equals(strValue))
				{
					mapReturn = map;
					break;
				}
			}
		} catch (NullPointerException e){
			mapReturn.put("status", Return.FAIL);
			mapReturn.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			mapReturn.put("status", Return.FAIL);
			mapReturn.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return mapReturn;
	}
	/**
	 * 사용자 데이터  UserCode, LogonID, 사번, 메일주소 validation 체크
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public CoviMap checkDuplicateUser(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		
		String pattern1 = ".*[\\{\\}\\[\\]?,;:|\\)*~`!^\\-+┼<>@\\#$%&\\\\(\\=\\'\\\"]+.*";
		String pattern2 = ".*[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]+.*";
		String pattern3 = ".*[\\{\\}\\[\\]?,;:|\\)*~`!^\\+┼<>\\#$%&\\\\(\\=\\'\\\"]+.*";
		
		try {
			//UserCode
			params.put("IsSaaS", isSaaS?"Y":"N");
			params.put("dupType", "Excel");
			params.put("Type", "UserCode");
			params.put("Code", params.get("UserCode").toString());
			
			CoviList dup1 = (CoviList) OrganizationSyncExcelSvc.selectIsDupUserCode(params).get("list");
			
			if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "["+params.get("UserCode").toString() +"]"+ DicHelper.getDic("msg_EXIST_URCODE"));
				return returnList;
			}
			
			if(Pattern.matches(pattern1, params.get("UserCode").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "["+params.get("UserCode").toString() +"]"+ DicHelper.getDic("msg_specialNotAllowed"));
				return returnList;
			}
			
			if(Pattern.matches(pattern2, params.get("UserCode").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "["+params.get("UserCode").toString()+"]" + DicHelper.getDic("msg_KoreanNotAllowed"));
				return returnList;
			}
			
			//LogonID
			params.put("Type", "LogonID");
			params.put("Code", params.get("LogonID").toString());
			
			dup1 = (CoviList) OrganizationSyncExcelSvc.selectIsDupUserCode(params).get("list");
			
			if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message","["+ params.get("LogonID").toString() +"]"+ DicHelper.getDic("msg_EXIST_LogonID"));
				return returnList;
			}
			
			if(Pattern.matches(pattern3, params.get("LogonID").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message","["+ params.get("LogonID").toString() +"]"+ DicHelper.getDic("msg_specialNotAllowed"));
				return returnList;
			}
			
			if(Pattern.matches(pattern2, params.get("LogonID").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message","["+ params.get("LogonID").toString() +"]"+ DicHelper.getDic("msg_KoreanNotAllowed"));
				return returnList;
			}
			
			//사번
			params.put("Type", "UserEmpNo");
			params.put("Code", params.get("EmpNo").toString());
			
			dup1 = (CoviList) OrganizationSyncExcelSvc.selectIsDupUserCode(params).get("list");
			
			if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", "["+params.get("EmpNo").toString() +"]"+ DicHelper.getDic("msg_EXIST_EMPNO"));
				return returnList;
			}
			
			if(Pattern.matches(pattern1, params.get("EmpNo").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message","["+ params.get("EmpNo").toString() +"]"+ DicHelper.getDic("msg_specialNotAllowed"));
				return returnList;
			}
			
			if(Pattern.matches(pattern2, params.get("EmpNo").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message","["+ params.get("EmpNo").toString() +"]"+ DicHelper.getDic("msg_KoreanNotAllowed"));
				return returnList;
			}
			
			//메일주소
			if(!params.get("MailAddress").toString().equals("")) {
				params.put("MailAddress", params.get("MailAddress").toString());
				params.put("Code", params.get("UserCode").toString());
				
				dup1 = (CoviList) orgSyncManageSvc.selectIsDuplicateMail(params).get("list"); 
				
				if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
					returnList.put("status", Return.FAIL);
					returnList.put("message","["+ params.get("MailAddress").toString() +"]"+ DicHelper.getDic("msg_exist_mailaddress"));
					return returnList;
				}
				
				if(Pattern.matches(pattern3, params.get("MailAddress").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message","["+ params.get("MailAddress").toString()+"]" + DicHelper.getDic("msg_specialNotAllowed"));
					return returnList;
				}
				
				if(Pattern.matches(pattern2, params.get("MailAddress").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", "["+params.get("MailAddress").toString()+"]" + DicHelper.getDic("msg_KoreanNotAllowed"));
					return returnList;
				}
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "SUCCESS");
			
		} catch (NullPointerException e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

	// 엑셀 데이터 추출
	public ArrayList<ArrayList<Object>> extractionExcelData(CoviMap params, int headerCnt) throws Exception {
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = prepareAttachment(mFile);	// 파일 생성
		ArrayList<ArrayList<Object>> returnList = new ArrayList<>();
		ArrayList<Object> tempList = null;
		Workbook wb = null;
		
		try {
			wb = WorkbookFactory.create(file);
			Sheet sheet = wb.getSheetAt(0);
			
			Iterator<Row> rowIterator = sheet.iterator();
			
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				
				tempList = new ArrayList<>();
				String case_value = "";
				int celllength = (int)row.getLastCellNum(); // 열의 총 개수 
				
				for(int c=0; c<celllength; c++){
					Cell cellNo = row.getCell(c);
				 
					if (cellNo == null || cellNo.getCellType() == Cell.CELL_TYPE_BLANK) {
						// CELL_TYPE_BLANK로만 체크할 경우 비어있는 셀을 놓칠 수 있다.
					case_value = "";
					tempList.add(case_value);
					}else {
						switch(cellNo.getCellType()){
							case Cell.CELL_TYPE_STRING:
								tempList.add(cellNo.getStringCellValue());
								break;
							case Cell.CELL_TYPE_NUMERIC:
								if(DateUtil.isCellDateFormatted(cellNo)) {
									Date date = cellNo.getDateCellValue();
									String value = new SimpleDateFormat("yyyy-MM-dd").format(date);
									tempList.add(value);
								}else{
									cellNo.setCellType(Cell.CELL_TYPE_STRING);
									tempList.add(cellNo.getStringCellValue());
								}
								break;
							default :
								break;
						}
					}
				}	

				returnList.add(tempList); 
				 
//				if (row.getRowNum() > (headerCnt - 1)) {	// header 제외
//					tempList = new ArrayList<>();
//					Iterator<Cell> cellIterator = row.cellIterator();
//					while (cellIterator.hasNext()) {
//						Cell cell = cellIterator.next();
//						if(cell.getCellType()==Cell.CELL_TYPE_NUMERIC){
//							if( DateUtil.isCellDateFormatted(cell)) {
//                				Date date = cell.getDateCellValue();
//                				String value = new SimpleDateFormat("yyyy-MM-dd").format(date);
//    							tempList.add(value);
//                			}else{
//                				cell.setCellType(Cell.CELL_TYPE_STRING);
//    							tempList.add(cell.getStringCellValue());
//                			}
//						}
//						else{
//							cell.setCellType(Cell.CELL_TYPE_STRING);
//							tempList.add(cell.getStringCellValue());
//						}
//					}
//					
//					returnList.add(tempList);
//				}
			}
		} finally {
			if (file != null) {
				if(!file.delete()) {
					/* Do nothing.*/
					LOGGER.warn("Fail to delete file.");
				}
			}
			if (wb != null) {
				wb.close();
			}
		}
		
		return returnList;
	} 
	
	// 임시파일 생성
	public File prepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        
	        return tmp;
	    } catch (IOException ioE) {
	        if (tmp != null) {
	        	if(!tmp.delete()) {
	        		/* Do nothing.*/
	        		LOGGER.warn("Fail to delete file.");
	        	}
	        }
	        throw ioE;
	    }
	}
}
