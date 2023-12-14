package egovframework.core.web;

import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import egovframework.core.sevice.OrgSyncExcelSvc;
import egovframework.core.sevice.OrgSyncManageSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;



/**
 * @Class Name : OrgSyncExcelCon.java
 * @Description : 엑셀동기화
 * @Modification Information @ 2019.09.19 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 04.07
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class OrgSyncExcelCon {
	private Logger LOGGER = LogManager.getLogger(OrgSyncExcelCon.class);
	
	@Autowired
	private OrgSyncExcelSvc orgSyncExcelSvc;
	@Autowired
	private OrgSyncManageSvc orgSyncManageSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	private boolean isSaaS = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N"));

	/**
	 * 계열사 엑셀동기화 대상여부 확인
	 * 
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "admin/orgmanage/checkSyncCompany.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkSyncCompany(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();

		try {
			CoviMap params = new CoviMap();
			params.put("CompanyCode", request.getParameter("CompanyCode"));
			
			CoviMap checkObject = orgSyncExcelSvc.checkSyncCompany(params);
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
		}
		catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} 
		catch (NullPointerException e) {
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
	 * getImportedOrgDeptList : 엑셀 파일 읽어오기
	 * 
	 * @param request
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "admin/orgmanage/getImportedOrgDeptList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getImportedOrgDeptList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		String strData = StringUtil.replaceNull(request.getParameter("objectData"), "");
		String arrData[] = strData.split("§");
		String indexArr[] = new String[12];

		CoviList listData = new CoviList();
		CoviMap mapData;
		CoviMap params = new CoviMap();
		params.put("syncCompanyCode", StringUtil.replaceNull(request.getParameter("companyCode"), ""));
		params.put("CompanyCode", StringUtil.replaceNull(request.getParameter("companyCode"), ""));
		CoviMap resultObj = new CoviMap();
		CoviMap returnObj = new CoviMap();

		try {
			//excel_orgdept 초기화
			orgSyncExcelSvc.deleteExcelorgdept(params);
			
			//get Domain info
			CoviList domainInfoList = (CoviList) orgSyncExcelSvc.checkSyncCompany(params).get("list");
			String sDomainID = domainInfoList.getJSONObject(0).getString("DomainID");
			String strCompanymaildomain = RedisDataUtil.getBaseConfig("IndiMailDomain", sDomainID);
			
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
				if(i >= 1) { //(pageSize * (pageNo-1) + 1) && i <= (pageSize * pageNo)
					listData.add(mapData);
				}
				
				if (i > 0 && tempArr[0] != null && !tempArr[0].toUpperCase().equals("GROUPCODE")) {
					params = new CoviMap();
					
					if(tempArr.length < 9) {
						resultObj.put("result", "FAIL");
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", "msg_noDeptValue");
						break;
					} else if (tempArr[0].isEmpty() || tempArr[0].equals("")
							|| tempArr[1].isEmpty() || tempArr[1].equals("")
							|| tempArr[2].isEmpty() || tempArr[2].equals("")
							|| tempArr[3].isEmpty() || tempArr[3].equals("")
							|| tempArr[6].isEmpty() || tempArr[6].equals("")
							|| tempArr[7].isEmpty() || tempArr[7].equals("")
							|| tempArr[8].isEmpty() || tempArr[8].equals("")) {
						
						resultObj.put("result", "FAIL");
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", "msg_noDeptValue");
						break;
					} else {
						if(tempArr.length >= 9) {
							params.put("GroupCode", tempArr[0]);
							params.put("CompanyCode", tempArr[1]);
							params.put("MemberOf", tempArr[2]);
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
							params.put("PrimaryMail", tempArr[10].isEmpty() && tempArr[9].equalsIgnoreCase("Y") ? 
									tempArr[0] + "@" + strCompanymaildomain : tempArr[10].indexOf("@") > 0 ? tempArr[10] : tempArr[10] + "@" + strCompanymaildomain);
						} else {
							params.put("PrimaryMail", "");
						}
						if(tempArr.length >= 12) {
							params.put("ManagerCode", tempArr[11] != null && !tempArr[11].equals("") ? tempArr[11] : "");
						}
					}
					
					if(request.getParameter("companyCode").equalsIgnoreCase(params.get("CompanyCode").toString())) {
						CoviMap dupObj = checkDuplicateDept(params);
						if(dupObj.get("status").toString().equalsIgnoreCase("FAIL")) {
							resultObj.put("result", "FAIL");
							returnObj.put("status", Return.FAIL);
							returnObj.put("message", dupObj.get("message").toString());
							break;
						} else {
							resultObj = orgSyncExcelSvc.insertFileDataDept(params);						
						}
					}
					
					if (!resultObj.getString("result").equals("OK")) {
						return resultObj;
					}
				}
			}

			if ("OK".equals(resultObj.getString("result"))) {
				// excel table -> compare table
				returnObj = orgSyncExcelSvc.syncCompareObjectForExcel("DEPT");
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

		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnObj;
	}
	
	/**
	 * getImportedOrgDeptListSaaS : 엑셀 파일 읽어오기 - SaaS
	 * 
	 * @param request
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "admin/orgmanage/getImportedOrgDeptListSaaS.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getImportedOrgDeptListSaaS(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		String strData = StringUtil.replaceNull(request.getParameter("objectData"), "");
		String arrData[] = strData.split("§");
		String indexArr[] = new String[12];

		CoviList listData = new CoviList();
		CoviMap mapData;
		CoviMap params = new CoviMap();
		params.put("syncCompanyCode", StringUtil.replaceNull(request.getParameter("companyCode"), ""));
		params.put("CompanyCode", StringUtil.replaceNull(request.getParameter("companyCode"), ""));
		CoviMap resultObj = new CoviMap();
		CoviMap returnObj = new CoviMap();

		try {
			//excel_orgdept 초기화
			orgSyncExcelSvc.deleteExcelorgdept(params);
			
			//get Domain info
			CoviList domainInfoList = (CoviList) orgSyncExcelSvc.checkSyncCompany(params).get("list");
			String sDomainID = domainInfoList.getJSONObject(0).getString("DomainID");
			String strCompanymaildomain = RedisDataUtil.getBaseConfig("IndiMailDomain",sDomainID);
			
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
				if(i >= 1) { //(pageSize * (pageNo-1) + 1) && i <= (pageSize * pageNo)
					listData.add(mapData);
				}
				
				if (i > 0 && tempArr[0] != null && !tempArr[0].toUpperCase().equals("GROUPCODE")) {
					params = new CoviMap();
					
					if(tempArr.length < 9) {
						resultObj.put("result", "FAIL");
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", "msg_noDeptValue");
						break;
					} else if (tempArr[0].replace(StringUtil.replaceNull(request.getParameter("companyCode"), "") + "_", "").isEmpty() || tempArr[0].equals("")
							|| tempArr[1].isEmpty() || tempArr[1].equals("")
							|| tempArr[2].isEmpty() || tempArr[2].equals("")
							|| tempArr[3].isEmpty() || tempArr[3].equals("")
							|| tempArr[6].isEmpty() || tempArr[6].equals("")
							|| tempArr[7].isEmpty() || tempArr[7].equals("")
							|| tempArr[8].isEmpty() || tempArr[8].equals("")) {
						
						resultObj.put("result", "FAIL");
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", "msg_noDeptValue");
						break;
					} else {
						if(tempArr.length >= 9) {
							params.put("GroupCode", tempArr[0].indexOf(request.getParameter("companyCode")+"_") > -1 ? 
									tempArr[0] : request.getParameter("companyCode")+"_"+tempArr[0]);
							params.put("CompanyCode", tempArr[1]);
							params.put("MemberOf", tempArr[2].equalsIgnoreCase(request.getParameter("companyCode")) 
									? tempArr[2] : tempArr[2].indexOf(request.getParameter("companyCode")+"_") > -1 
											? tempArr[2] : request.getParameter("companyCode")+"_"+tempArr[2]);
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
							params.put("PrimaryMail", tempArr[10].isEmpty() && tempArr[9].equalsIgnoreCase("Y") ? 
									tempArr[0] + "@" + strCompanymaildomain : tempArr[10].indexOf("@") > 0 ? tempArr[10] : tempArr[10] + "@" + strCompanymaildomain);
						} else {
							params.put("PrimaryMail", "");
						}
						if(tempArr.length >= 12) {
							params.put("ManagerCode", tempArr[11] != null && !tempArr[11].equals("") ? tempArr[11] : "");
						}
					}
					
					if(request.getParameter("companyCode").equalsIgnoreCase(params.get("CompanyCode").toString())) {
						CoviMap dupObj = checkDuplicateDept(params);
						if(dupObj.get("status").toString().equalsIgnoreCase("FAIL")) {
							resultObj.put("result", "FAIL");
							returnObj.put("status", Return.FAIL);
							returnObj.put("message", dupObj.get("message").toString());
							break;
						} else {
							resultObj = orgSyncExcelSvc.insertFileDataDept(params);						
						}
					}
					
					if (!resultObj.getString("result").equals("OK")) {
						return resultObj;
					}
				}
			}

			if ("OK".equals(resultObj.getString("result"))) {
				// excel table -> compare table
				returnObj = orgSyncExcelSvc.syncCompareObjectForExcel("DEPT");
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

		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnObj;
	}

	/**
	 * getImportedOrgUserList : 엑셀 파일 읽어오기
	 * 
	 * @param request
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked" })
	@RequestMapping(value = "admin/orgmanage/getImportedOrgUserList.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getImportedOrgUserList(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters

		String strData = StringUtil.replaceNull(request.getParameter("objectData"), "");
		String arrData[] = strData.split("§");
		String indexArr[] = new String[29];

		CoviList listData = new CoviList();
		CoviMap mapData;
		CoviMap params = new CoviMap();
		params.put("syncCompanyCode", StringUtil.replaceNull(request.getParameter("companyCode"), ""));
		params.put("CompanyCode", StringUtil.replaceNull(request.getParameter("companyCode"), ""));
		CoviMap resultObj = new CoviMap();
		CoviMap returnObj = new CoviMap();

		try {
			//excel_orguser 초기화
			orgSyncExcelSvc.deleteExcelorguser(params);
			
			//get Domain info
			CoviList domainInfoList = (CoviList) orgSyncExcelSvc.checkSyncCompany(params).get("list");
			String sDomainID = domainInfoList.getJSONObject(0).getString("DomainID");
			String strCompanymaildomain = RedisDataUtil.getBaseConfig("IndiMailDomain",sDomainID);
			
			for (int i = 0; i < arrData.length; i++) {
				String tempArr[] = arrData[i].split("†");
				mapData = new CoviMap();
				for (int j = 0; j < tempArr.length; j++) {
					if (i == 0) {
						if (tempArr[j].toUpperCase().equals("USERCODE")) {
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
						} 
						//else if (tempArr[j].toUpperCase().equals("MANAGERCODE")) {
						//	indexArr[j] = "ManagerCode";
						//}
						else if (tempArr[j].toUpperCase().equals("USEMESSENGERCONNECT")) {
							indexArr[j] = "UseMessengerConnect";
						}
					} else {
						mapData.put(indexArr[j], tempArr[j]);
					}
				}
				if (i >= 1) { // (pageSize * (pageNo-1) + 1) && i <= (pageSize * pageNo)
					listData.add(mapData);
				}
				
				if (i > 0 && !tempArr[0].toUpperCase().equals("USERCODE")) {
					params = new CoviMap();
					
					if(tempArr.length < 16) {
						resultObj.put("result", "FAIL");
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", "msg_noUserValue");
						break;
					} else if (tempArr[0].isEmpty() || tempArr[0].equals("")
							|| tempArr[1].isEmpty() || tempArr[1].equals("")
							|| tempArr[2].isEmpty() || tempArr[2].equals("")
							|| tempArr[3].isEmpty() || tempArr[3].equals("")
							|| tempArr[5].isEmpty() || tempArr[5].equals("")
							|| tempArr[6].isEmpty() || tempArr[6].equals("")
							|| tempArr[12].isEmpty() || tempArr[12].equals("")
							|| tempArr[13].isEmpty() || tempArr[13].equals("")
							|| tempArr[14].isEmpty() || tempArr[14].equals("")
							|| tempArr[15].isEmpty() || tempArr[15].equals("")) {
						
						resultObj.put("result", "FAIL");
						returnObj.put("status", Return.FAIL);
						returnObj.put("message", "msg_noUserValue");
						break;
					} else {
						if(tempArr.length >= 16) {
							params.put("UserCode", tempArr[0]);
							params.put("CompanyCode", tempArr[1]);
							params.put("DeptCode", tempArr[2]);
							params.put("LogonID", tempArr[3]);
							params.put("LogonPW", tempArr[4].isEmpty() ? RedisDataUtil.getBaseConfig("InitPassword",sDomainID) : tempArr[4]);
							params.put("EmpNo", tempArr[5]);
							params.put("DisplayName", tempArr[6]);
							params.put("MultiDisplayName", tempArr[7].isEmpty() ? tempArr[6] + ";;;;;;;;;" : tempArr[7]);
							params.put("JobPositionCode", tempArr[8].isEmpty() ? "" : tempArr[8]);
							params.put("JobTitleCode", tempArr[9].isEmpty() ? "" : tempArr[9]);
							params.put("JobLevelCode", tempArr[10].isEmpty() ? "" : tempArr[10]);
							params.put("SortKey", tempArr[11].isEmpty() ? "99999" : tempArr[11]);
							params.put("IsUse", tempArr[12]);
							params.put("IsHR", tempArr[13]);
							params.put("IsDisplay", tempArr[14]);
						}
						if(tempArr.length >= 17) {
							params.put("EnterDate", tempArr[16].isEmpty() ? "" : tempArr[16]);
						}
						if(tempArr.length >= 18) {
							params.put("RetireDate", tempArr[17].isEmpty() ? "" : tempArr[17]);
						}
						if(tempArr.length >= 19) {
							params.put("BirthDiv", tempArr[18].isEmpty() ? "" : tempArr[18]);
						}
						if(tempArr.length >= 20) {
							params.put("BirthDate", tempArr[19].isEmpty() ? "" : tempArr[19]);
						}
						if(tempArr.length >= 21) {
							params.put("PhotoPath", tempArr[20].isEmpty() ? "" : tempArr[20]);
						}
						if(tempArr.length >= 22) {
							params.put("UseMailConnect", tempArr[15].equalsIgnoreCase("Y") && tempArr[21].isEmpty() ? "N" : tempArr[15]);
							params.put("MailAddress", tempArr[21].isEmpty() && tempArr[15].equals("Y") ? 
									"" : tempArr[21].indexOf("@") > 0 ? tempArr[21] : tempArr[21] + "@" + strCompanymaildomain);
						} else {
							params.put("UseMailConnect", "N");
							params.put("MailAddress", "");
						}
						if(tempArr.length >= 23) {
							params.put("ExternalMailAddress", tempArr[22].isEmpty() ? "" : tempArr[22]);
						}
						if(tempArr.length >= 24) {
							params.put("ChargeBusiness", tempArr[23].isEmpty() ? "" : tempArr[23]);
						}
						if(tempArr.length >= 25) {
							params.put("PhoneNumberInter", tempArr[24].isEmpty() ? "" : tempArr[24]);
						}
						if(tempArr.length >= 26) {
							params.put("PhoneNumber", tempArr[25].isEmpty() ? "" : tempArr[25]);
						}
						if(tempArr.length >= 27) {	
							params.put("Mobile", tempArr[26].isEmpty() ? "" : tempArr[26]);
						}
						if(tempArr.length >= 28) {
							params.put("Fax", tempArr[27].isEmpty() ? "" : tempArr[27]);
						}
						//if(tempArr.length >= 29) {
						//	params.put("ManagerCode", tempArr[28].isEmpty() ? "" : tempArr[28]);
						//}
						if(tempArr.length >= 29) {
							params.put("UseMessengerConnect", tempArr[28].isEmpty() ? "" : tempArr[28]);
						}
					}
					
					if(request.getParameter("companyCode").equalsIgnoreCase(params.get("CompanyCode").toString())) {
						CoviMap dupObj = checkDuplicateUser(params); 
						if(dupObj.get("status").toString().equalsIgnoreCase("FAIL")) {
							resultObj.put("result", "FAIL");
							returnObj.put("status", Return.FAIL);
							returnObj.put("message", dupObj.get("message").toString());
							break;
						} else {
							resultObj = orgSyncExcelSvc.insertFileDataUser(params);
						}
					}
					
					if (!resultObj.getString("result").equals("OK")) {
						return resultObj;
					}
				}
			}
			
			if ("OK".equals(resultObj.getString("result"))) {
				// excel table -> compare table
				returnObj = orgSyncExcelSvc.syncCompareObjectForExcel("USER");
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
			
		} catch (ArrayIndexOutOfBoundsException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception e){
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * getImportedOrgUserListSaaS : 엑셀 파일 읽어오기 - SaaS
	 * 
	 * @param request
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked" })
	@RequestMapping(value = "admin/orgmanage/getImportedOrgUserListSaaS.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getImportedOrgUserListSaaS(HttpServletRequest request, @RequestParam Map<String, String> paramMap) throws Exception {
		// Parameters

		String strData = StringUtil.replaceNull(request.getParameter("objectData"), "");
		String arrData[] = strData.split("§");
		String indexArr[] = new String[29];

		CoviList listData = new CoviList();
		CoviMap mapData;
		CoviMap params = new CoviMap();
		params.put("syncCompanyCode", StringUtil.replaceNull(request.getParameter("companyCode"), ""));
		params.put("CompanyCode", StringUtil.replaceNull(request.getParameter("companyCode"), ""));
		CoviMap resultObj = new CoviMap();
		CoviMap returnObj = new CoviMap();
		
		CoviMap checkObject = orgSyncExcelSvc.checkSyncCompany(params);
		if ("invalid".equals(checkObject.get("result"))) {
			resultObj.put("status", Return.FAIL);
			resultObj.put("message", "CompanyCode is invalid.");
			return resultObj;
		}
		else {
			try {
				//excel_orguser 초기화
				orgSyncExcelSvc.deleteExcelorguser(params);
				
				//get Domain info
				CoviList domainInfoList = (CoviList) checkObject.get("list");
				String sDomainID = domainInfoList.getJSONObject(0).getString("DomainID");
				String tempCompanyMailDomain = RedisDataUtil.getBaseConfig("IndiMailDomain",sDomainID);
				// 220126, jkele2, IndiMailDomain 기초설정값에 메일도메인을 ;로 여러개 셋팅한 경우 제일 앞에 도메인을 사용하도록 수정
				String[] arrCompanyMailDomain = tempCompanyMailDomain.split(";");
				String strCompanymaildomain = arrCompanyMailDomain[0];
				
				for (int i = 0; i < arrData.length; i++) {
					String tempArr[] = arrData[i].split("†");
					mapData = new CoviMap();
					for (int j = 0; j < tempArr.length; j++) {
						if (i == 0) {
							if (tempArr[j].toUpperCase().equals("USERCODE")) {
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
							} /*else if (tempArr[j].toUpperCase().equals("MANAGERCODE")) {
								indexArr[j] = "ManagerCode";
							}*/ else if (tempArr[j].toUpperCase().equals("USEMESSENGERCONNECT")) {
								indexArr[j] = "UseMessengerConnect";
							}
						} else {
							mapData.put(indexArr[j], tempArr[j]);
						}
					}
					if (i >= 1) { // (pageSize * (pageNo-1) + 1) && i <= (pageSize * pageNo)
						listData.add(mapData);
					}
					
					if (i > 0 && !tempArr[0].toUpperCase().equals("USERCODE")) {
						params = new CoviMap();
						String _companyCode = StringUtil.replaceNull(request.getParameter("companyCode"), "");
						
						if(tempArr.length < 16) {
							resultObj.put("result", "FAIL");
							returnObj.put("status", Return.FAIL);
							returnObj.put("message", "msg_noUserValue");
							break;
						} 
						else if (tempArr[0].replace(StringUtil.replaceNull(request.getParameter("companyCode"), "") + "_", "").isEmpty() || tempArr[0].equals("")
								|| tempArr[1].isEmpty() || tempArr[1].equals("")
								|| tempArr[2].isEmpty() || tempArr[2].equals("")
								|| tempArr[3].isEmpty() || tempArr[3].equals("")
								|| tempArr[5].isEmpty() || tempArr[5].equals("")
								|| tempArr[6].isEmpty() || tempArr[6].equals("")
								|| tempArr[12].isEmpty() || tempArr[12].equals("")
								|| tempArr[13].isEmpty() || tempArr[13].equals("")
								|| tempArr[14].isEmpty() || tempArr[14].equals("")
								|| tempArr[15].isEmpty() || tempArr[15].equals("")) {
							
							resultObj.put("result", "FAIL");
							returnObj.put("status", Return.FAIL);
							returnObj.put("message", "msg_noUserValue");
							break;
						} 
						else {
							if(tempArr.length >= 16) {
								// UserCode에 회사코드_ 가 있는 경우 그대로 사용, 없는 경우 회사코드_ 뒤에 붙여 코드 생성.
								params.put("UserCode", // 220126, jklee2, CompanyCode가 업로드되었는데 왜 요청 파라미터의 CompanyCode를 사용하는지?
									(tempArr[0].indexOf(_companyCode+"_") > -1) ? 
										tempArr[0] : _companyCode+"_"+tempArr[0]
								);
								params.put("CompanyCode", tempArr[1]);
								params.put("DeptCode", 
									(tempArr[2].equalsIgnoreCase(_companyCode)) ? 
										tempArr[2] : 
										(tempArr[2].indexOf(_companyCode+"_") > -1) ? 
											tempArr[2] : _companyCode+"_"+tempArr[2]
								);
								
								// 메일주소형태로 입력된 경우 입력값 사용, 아닌 경우 @회사 도메인을 추가하여 logonid 생성
								params.put("LogonID", tempArr[3].indexOf("@") > 0 ? tempArr[3] : tempArr[3] + "@" + strCompanymaildomain);
								params.put("LogonPW", tempArr[4].isEmpty() ? RedisDataUtil.getBaseConfig("InitPassword",sDomainID) : tempArr[4]);
								params.put("EmpNo", tempArr[5]);
								params.put("DisplayName", tempArr[6]);
								params.put("MultiDisplayName", tempArr[7].isEmpty() ? tempArr[6] + ";;;;;;;;;" : tempArr[7]);
								params.put("JobPositionCode", tempArr[8].isEmpty() ? "" : tempArr[8]);
								params.put("JobTitleCode", tempArr[9].isEmpty() ? "" : tempArr[9]);
								params.put("JobLevelCode", tempArr[10].isEmpty() ? "" : tempArr[10]);
								params.put("SortKey", tempArr[11].isEmpty() ? "99999" : tempArr[11]);
								params.put("IsUse", tempArr[12]);
								params.put("IsHR", tempArr[13]);
								params.put("IsDisplay", tempArr[14]);
							}
							if(tempArr.length >= 17) {
								params.put("EnterDate", tempArr[16].isEmpty() ? "" : tempArr[16]);
							}
							if(tempArr.length >= 18) {
								params.put("RetireDate", tempArr[17].isEmpty() ? "" : tempArr[17]);
							}
							if(tempArr.length >= 19) {
								params.put("BirthDiv", tempArr[18].isEmpty() ? "" : tempArr[18]);
							}
							if(tempArr.length >= 20) {
								params.put("BirthDate", tempArr[19].isEmpty() ? "" : tempArr[19]);
							}
							if(tempArr.length >= 21) {
								params.put("PhotoPath", tempArr[20].isEmpty() ? "" : tempArr[20]);
							}
							if(tempArr.length >= 22) {
								params.put("UseMailConnect", tempArr[15].equals("Y") && tempArr[21].isEmpty() ? "N" : tempArr[15]);
								params.put("MailAddress", tempArr[21].isEmpty() && tempArr[15].equals("Y") ? 
										"" : tempArr[21].indexOf("@") > 0 ? tempArr[21] : tempArr[21] + "@" + strCompanymaildomain);
							} else {
								params.put("UseMailConnect", "N");
								params.put("MailAddress", "");
							}
							if(tempArr.length >= 23) {
								params.put("ExternalMailAddress", tempArr[22].isEmpty() ? "" : tempArr[22]);
							}
							if(tempArr.length >= 24) {
								params.put("ChargeBusiness", tempArr[23].isEmpty() ? "" : tempArr[23]);
							}
							if(tempArr.length >= 25) {
								params.put("PhoneNumberInter", tempArr[24].isEmpty() ? "" : tempArr[24]);
							}
							if(tempArr.length >= 26) {
								params.put("PhoneNumber", tempArr[25].isEmpty() ? "" : tempArr[25]);
							}
							if(tempArr.length >= 27) {	
								params.put("Mobile", tempArr[26].isEmpty() ? "" : tempArr[26]);
							}
							if(tempArr.length >= 28) {
								params.put("Fax", tempArr[27].isEmpty() ? "" : tempArr[27]);
							}
//							if(tempArr.length >= 29) {
//								params.put("ManagerCode", tempArr[28].isEmpty() ? "" : tempArr[28]);
//							}
							if(tempArr.length >= 29) {
								params.put("UseMessengerConnect", tempArr[28].isEmpty() ? "" : tempArr[28]);
							}
						}
						
						if(_companyCode.equalsIgnoreCase(params.get("CompanyCode").toString())) {
							CoviMap dupObj = checkDuplicateUser(params); 
							if(dupObj.get("status").toString().equalsIgnoreCase("FAIL")) {
								resultObj.put("result", "FAIL");
								returnObj.put("status", Return.FAIL);
								returnObj.put("message", dupObj.get("message").toString());
								break;
							} 
							else {
								resultObj = orgSyncExcelSvc.insertFileDataUser(params);
							}
						}
						else {
							resultObj.put("status", Return.FAIL);
							resultObj.put("message", "등록하려는 회사코드가 사용자의 회사코드와 다릅니다.");
							return resultObj;
						}
						
						if (!resultObj.getString("result").equals("OK")) {
							return resultObj;
						}
					}
				}
				
				if ("OK".equals(resultObj.getString("result"))) {
					// excel table -> compare table
					returnObj = orgSyncExcelSvc.syncCompareObjectForExcel("USER");
					int compareGroupCnt = returnObj.getInt("compareGroupCnt");
					int compareUserCnt = returnObj.getInt("compareUserCnt");
	
					if (/*compareGroupCnt >= 0 &&*/ compareUserCnt >= 0) {
						returnObj.put("list", listData);
						returnObj.put("result", "ok");
						returnObj.put("status", Return.SUCCESS);
						returnObj.put("message", "조회 성공");
					} 
					else {
						returnObj.put("status", Return.SUCCESS);
						returnObj.put("message", "동기화 대상이 존재하지 않습니다.");
					}
				} 
				else { return returnObj; }
			} 
			catch (ArrayIndexOutOfBoundsException e) {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			} 
			catch (NullPointerException e) {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			}
			catch (Exception e){
				LOGGER.error(e.getLocalizedMessage(), e);
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
			}
	
			return returnObj;
		}
	}

	/** 미사용
	 * 엑셀동기화 - 부서
	 * @param req
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	/*@RequestMapping(value = "admin/orgmanage/syncExcelDataDept.do", method = { RequestMethod.GET,RequestMethod.POST })
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
//				resultList = (CoviList) orgSyncExcelSvc.getExcelTempDeptDataList(params).get("list");
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
//				returnObj = orgSyncExcelSvc.insertFileDataDept(params);
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
//				//orgSyncExcelSvc.syncCompareObjectForExcel();
//			}

		} catch (NullPointerException e) {
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
	@RequestMapping(value = "admin/orgmanage/getExcelTempDeptList.do", method = { RequestMethod.GET,RequestMethod.POST })
	public @ResponseBody CoviMap getExcelTempDeptList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		CoviMap page = new CoviMap();
		CoviMap params2 = new CoviMap();
		String strCompanyCode = request.getParameter("companyCode");
		params2.put("CompanyCode",strCompanyCode);
		
		int iReturn = orgSyncExcelSvc.deleteOtherCompany(params2);

		// 정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strsyncType = StringUtil.replaceNull(request.getParameter("syncType"), "");
		String strsearchType = request.getParameter("searchType");
		String strsearchText = request.getParameter("searchText");
		String strSortColumn = "GroupCode";
		String strSortDirection = "ASC";
		String strPageNo = request.getParameter("pageNo");
		String strPageSize = request.getParameter("pageSize");

		if (strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
 

		try {
			CoviMap params = new CoviMap();

			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
			params.put("syncType", strsyncType.equals("A") ? "" : strsyncType);
			params.put("searchType", strsearchType != null && !strsearchType.equals("") ? strsearchType : "");
			params.put("searchText", strsearchText != null && !strsearchText.equals("") ? ComUtils.RemoveSQLInjection(strsearchText, 100) : "");
 
			CoviMap jobjResult = orgSyncExcelSvc.getExcelTempDeptDataList(params);
 
			returnList.put("page", jobjResult.get("page"));
			returnList.put("list", jobjResult.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
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
	@RequestMapping(value = "admin/orgmanage/getExcelTempUserList.do", method = { RequestMethod.GET,RequestMethod.POST })
	public @ResponseBody CoviMap getExcelTempUserList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList resultList = new CoviList();
		CoviMap page = new CoviMap();
		CoviMap params2 = new CoviMap();
		String strCompanyCode = request.getParameter("companyCode");
		params2.put("CompanyCode",strCompanyCode);
		
		int iReturn = orgSyncExcelSvc.deleteOtherCompany(params2);

		// 정렬 및 페이징
		String strSort = request.getParameter("sortBy");
		String strsyncType = request.getParameter("syncType");
		String strsearchType = request.getParameter("searchType");
		String strsearchText = request.getParameter("searchText");
		String strSortColumn = "UserCode";
		String strSortDirection = "ASC";
		String strPageNo = request.getParameter("pageNo");
		String strPageSize = request.getParameter("pageSize");

		if (strSort != null && !strSort.isEmpty()) {
			strSortColumn = strSort.split(" ")[0];
			strSortDirection = strSort.split(" ")[1];
		}
 

		try {
			CoviMap params = new CoviMap();

			params.put("pageNo", request.getParameter("pageNo"));
			params.put("pageSize", request.getParameter("pageSize"));
			params.put("sortColumn", ComUtils.RemoveSQLInjection(strSortColumn, 100));
			params.put("sortDirection", ComUtils.RemoveSQLInjection(strSortDirection, 100));
			params.put("syncType", "A".equals(strsyncType) ? "" : strsyncType);
			params.put("searchType", strsearchType != null && !strsearchType.equals("") ? strsearchType : "");
			params.put("searchText", strsearchText != null && !strsearchText.equals("") ? ComUtils.RemoveSQLInjection(strsearchText, 100) : "");

			CoviMap jobjResult =  orgSyncExcelSvc.getExcelTempUserDataList(params);

			returnList.put("page", jobjResult.get("page"));
			returnList.put("list", jobjResult.get("list"));
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (ArrayIndexOutOfBoundsException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y") ? e.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException e) {
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
	@RequestMapping(value = "admin/orgmanage/deleteSelectDept.do", method=RequestMethod.POST)
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
				
				result = orgSyncExcelSvc.deleteSelectDept(params);
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
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
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
	@RequestMapping(value = "admin/orgmanage/deleteSelectUser.do", method=RequestMethod.POST)
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
				
				result = orgSyncExcelSvc.deleteSelectUser(params);
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
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
	
	/**
	 * 대상 데이터 초기화
	 */
	@RequestMapping(value = "admin/orgmanage/deleteTemp.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteTemp(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		int result = 0;
		
		try {
			result = orgSyncExcelSvc.deleteTemp();
			
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
		} catch (NullPointerException e) {
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
	@RequestMapping(value = "admin/orgmanage/deleteAll.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap deleteAll(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		int result = 0;
		
		try {
			CoviMap params = new CoviMap();
			params.put("syncCompanyCode", request.getParameter("syncCompanyCode"));
			
			result = orgSyncExcelSvc.deleteAll(params);
			
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
		} catch (NullPointerException e) {
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
			CoviList dup1 = (CoviList) orgSyncExcelSvc.selectIsDupDeptCode(params).get("list");
			
			if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("GroupCode").toString() + "|msg_EXIST_GRCODE");
				return returnList;
			}
			
			if(Pattern.matches(pattern1, params.get("GroupCode").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("GroupCode").toString() + "|msg_specialNotAllowed");
				return returnList;
			}
			
			if(Pattern.matches(pattern2, params.get("GroupCode").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("GroupCode").toString() + "|msg_KoreanNotAllowed");
				return returnList;
			}
			
			//메일주소
			if(!params.get("PrimaryMail").toString().equals("")) {
				params.put("MailAddress", params.get("PrimaryMail").toString());
				params.put("Code", params.get("GroupCode").toString());
				
				dup1 = (CoviList) orgSyncManageSvc.selectIsDuplicateMail(params).get("list"); 
				
				if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", params.get("PrimaryMail").toString() + "|msg_exist_mailaddress");
					return returnList;
				}
				
				if(Pattern.matches(pattern3, params.get("PrimaryMail").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", params.get("PrimaryMail").toString() + "|msg_specialNotAllowed");
					return returnList;
				}
				
				if(Pattern.matches(pattern2, params.get("PrimaryMail").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", params.get("PrimaryMail").toString() + "|msg_KoreanNotAllowed");
					return returnList;
				}
			}
			
			//부서명
			if(!params.get("DisplayName").toString().equals("")) {
				if(Pattern.matches(pattern4, params.get("DisplayName").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", params.get("DisplayName").toString() + "|msg_specialNotAllowed");
					return returnList;
				}
			}
			
			//상위부서
			if(!params.get("MemberOf").toString().equals("")) {
				if(params.get("MemberOf").toString().equals(params.get("GroupCode").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", params.get("GroupCode").toString() + "|msg_SameCodeMemberOf");
					return returnList;
				}
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "SUCCESS");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
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
			params.put("dupType", "Excel");
			params.put("Type", "UserCode");
			params.put("Code", params.get("UserCode").toString());
			
			CoviList dup1 = (CoviList) orgSyncExcelSvc.selectIsDupUserCode(params).get("list");
			
			if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("UserCode").toString() + "|msg_EXIST_URCODE");
				return returnList;
			}
			
			if(Pattern.matches(pattern1, params.get("UserCode").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("UserCode").toString() + "|msg_specialNotAllowed");
				return returnList;
			}
			
			if(Pattern.matches(pattern2, params.get("UserCode").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("UserCode").toString() + "|msg_KoreanNotAllowed");
				return returnList;
			}
			
			//LogonID
			params.put("Type", "LogonID");
			params.put("Code", params.get("LogonID").toString());
			
			dup1 = (CoviList) orgSyncExcelSvc.selectIsDupUserCode(params).get("list");
			
			if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("LogonID").toString() + "|msg_EXIST_LogonID");
				return returnList;
			}
			
			if(Pattern.matches(pattern3, params.get("LogonID").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("LogonID").toString() + "|msg_specialNotAllowed");
				return returnList;
			}
			
			if(Pattern.matches(pattern2, params.get("LogonID").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("LogonID").toString() + "|msg_KoreanNotAllowed");
				return returnList;
			}
			
			//사번
			params.put("Type", "UserEmpNo");
			params.put("Code", params.get("EmpNo").toString());
			
			if(isSaaS) dup1 = (CoviList) orgSyncExcelSvc.selectIsDupUserCode(params).get("list");
			else dup1 = (CoviList) orgSyncManageSvc.selectIsDuplicateUserCode(params).get("list");
			
			if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("EmpNo").toString() + "|msg_EXIST_EMPNO");
				return returnList;
			}
			
			if(Pattern.matches(pattern1, params.get("EmpNo").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("EmpNo").toString() + "|msg_specialNotAllowed");
				return returnList;
			}
			
			if(Pattern.matches(pattern2, params.get("EmpNo").toString())) {
				returnList.put("status", Return.FAIL);
				returnList.put("message", params.get("EmpNo").toString() + "|msg_KoreanNotAllowed");
				return returnList;
			}
			
			//메일주소
			if(!params.get("MailAddress").toString().equals("")) {
				params.put("MailAddress", params.get("MailAddress").toString());
				params.put("Code", params.get("UserCode").toString());
				
				dup1 = (CoviList) orgSyncManageSvc.selectIsDuplicateMail(params).get("list"); 
				
				if(Integer.parseInt(dup1.getJSONObject(0).getString("isDuplicate")) > 0) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", params.get("MailAddress").toString() + "|msg_exist_mailaddress");
					return returnList;
				}
				
				if(Pattern.matches(pattern3, params.get("MailAddress").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", params.get("MailAddress").toString() + "|msg_specialNotAllowed");
					return returnList;
				}
				
				if(Pattern.matches(pattern2, params.get("MailAddress").toString())) {
					returnList.put("status", Return.FAIL);
					returnList.put("message", params.get("MailAddress").toString() + "|msg_KoreanNotAllowed");
					return returnList;
				}
			}
			
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "SUCCESS");
			
		} catch (NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}

}
