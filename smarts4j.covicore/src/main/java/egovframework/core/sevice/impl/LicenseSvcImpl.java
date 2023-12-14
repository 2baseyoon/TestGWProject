package egovframework.core.sevice.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.LicenseHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.LicenseSvc;
import egovframework.coviframework.util.ComUtils;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("licenseService")
public class LicenseSvcImpl extends EgovAbstractServiceImpl implements LicenseSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getConnectionLogList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("license.manage.selectConnectionLogListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("license.manage.selectConnectionLogList",params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "IPAddress,OS,Browser,LogonDate,LogoutDate"));
		resultList.put("page",page);
		
		return resultList;
	}

	@Override
	public CoviMap getLicenseInfo() throws Exception {
		String domainID = SessionHelper.getSession("DN_ID");
		String domainCode = SessionHelper.getSession("DN_Code");
		String domainUrl = SessionHelper.getSession("DN_Url");
		return getLicenseInfo(domainID, domainCode, domainUrl);
	}
	public CoviMap getLicenseInfo(String domainID) throws Exception {
		CoviMap params = new CoviMap();
		params.put("DomainID", domainID);
		CoviMap map = coviMapperOne.select("sys.domain.selectone", params);

		return getLicenseInfo(domainID, map.getString("DomainCode"), map.getString("DomainUrl"));	
	}
	@Override
	public CoviMap getLicenseInfo(String domainID, String domainCode, String domainUrl) throws Exception {
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");
		
		CoviMap resultList = new CoviMap();
		CoviMap params = new CoviMap();
		
		//SaaS 프로젝트 아닌 경우에는 최상위 도메인에서만 라이선스 관리 
		if(isSaaS.equalsIgnoreCase("Y")){
			params.put("domainCode", domainCode);
		}
		
		final String LIC_USERCOUNT = LicenseHelper.getDecryptedProperty(LicenseHelper.getLicenseInfo("LicUserCount", domainID), domainUrl, "LIUC");
		final String LIC_EXUSERCOUNT = LicenseHelper.getDecryptedProperty(LicenseHelper.getLicenseInfo("LieExUserCount", domainID), domainUrl, "LIExUC");
		final String LIC_EXPIRED = LicenseHelper.getDecryptedProperty(LicenseHelper.getLicenseInfo("LicExpireDate", domainID), domainUrl, "LIUP");
		final String LIC_EX1DATE = LicenseHelper.getDecryptedProperty(LicenseHelper.getLicenseInfo("LicEx1Date", domainID), domainUrl, "LIEx1UP");
		
		int activeUserCnt = (int) coviMapperOne.getNumber("license.manage.selectActiveUserCnt", params); 
		String licenseInfo = LIC_USERCOUNT 
				+ "(~" + DateHelper.convertDateFormat(LIC_EXPIRED, "yyyyMMdd", "yyyy-MM-dd") + ")";
		
		if(!StringUtil.nullToZero(LIC_EXUSERCOUNT).equals("0") && !LIC_EX1DATE.equals("")) {
			licenseInfo += " + " + LIC_EXUSERCOUNT 
					+ "(~" + DateHelper.convertDateFormat(LIC_EX1DATE, "yyyyMMdd", "yyyy-MM-dd") + ")";
		}
		CoviMap licenseData = new CoviMap();
		licenseData.put("LIC_USERCOUNT", LIC_USERCOUNT);
		licenseData.put("LIC_EXUSERCOUNT", LIC_EXUSERCOUNT);
		licenseData.put("LIC_EXPIRED", LIC_EXPIRED);
		licenseData.put("LIC_EX1DATE", LIC_EX1DATE);
		
		resultList.put("activeUserCnt", activeUserCnt);
		resultList.put("licenseInfo", licenseInfo);
		resultList.put("licenseData", licenseData);
		
		return resultList;
	}
	
	
	public CoviMap getLicenseManageList(CoviMap params) throws Exception {
		CoviMap resultMap = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("license.manage.selectLicenseManageListCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("license.manage.selectLicenseManageList",params);
		for (int i=0; i < list.size(); i++){
			CoviMap map = (CoviMap)list.get(i);
			String desModule =  map.getString("LicModule");
			String[] licModule = StringUtil.toTokenArray(PropertiesUtil.getDecryptedProperty(desModule),"|");
			StringBuffer sb = new StringBuffer();
			for (int j=0; j < licModule.length;j++){
				String code = licModule[j];
				String codeName = RedisDataUtil.getBaseCodeDic("BizSection", code, "ko");
				if (j>0) sb.append("/");
				sb.append(codeName);
			}	
			map.put("LicModule", sb.toString());
		}
		
		resultMap.put("list", list);
		resultMap.put("page", page);
		
		return resultMap;
	}
	
	public CoviMap getLicenseManageInfo(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("license.manage.selectLicenseManageInfo", params);
	}
	
	public CoviMap getLicensePortal(CoviMap params) throws Exception {
		CoviMap resultMap = new CoviMap();
		
		CoviList list = coviMapperOne.list("license.manage.selectLicensePortal",params);
		resultMap.put("list", CoviSelectSet.coviSelectJSON(list, "PortalID,CompanyCode,DisplayName"));
		
		return resultMap;
	}
	
	public int getDupLicenseName(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("license.manage.selectDupLicenseNameCnt", params);
	}
	
	public int addLicenseInfo(CoviMap params) throws Exception {
		int cnt = coviMapperOne.insert("license.manage.addLicenseInfo", params);
		
//		coviMapperOne.insert("license.manage.addLicenseBizSection", params);
		
		return cnt;
	}
	
	public int editLicenseInfo(CoviMap params) throws Exception {
		int cnt = coviMapperOne.update("license.manage.editLicenseInfo", params);
		
//		coviMapperOne.delete("license.manage.deleteLicenseBizSection", params);
//		coviMapperOne.insert("license.manage.addLicenseBizSection", params);
		
		return cnt;
	}
	
	public int deleteLicense(CoviMap params) throws Exception {
		return coviMapperOne.update("license.manage.deleteLicense", params);
	}
	
	public CoviMap getUserInfo(CoviMap params) throws Exception {
		CoviMap resultMap = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("framework.license.selectLicenseUserInfoCnt", params);
		
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list;
		list = coviMapperOne.list("framework.license.selectLicenseUserInfoList", params);
		
		// RowNumber의 경우 Oracle/Tibero의 공통 페이징을 쓰기 위해 RNUM으로 지정. 
		resultMap.put("list", CoviSelectSet.coviSelectJSON(list, "RNUM,UserName,LogonID,DeptName,IsUse,UserCode,LicSeq,DomainID"));
		resultMap.put("page", page);
		
		return resultMap;	
	}
	
	public CoviMap getLicenseInfoCnt(CoviMap params) throws Exception {
		CoviMap resultMap = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("framework.license.selectLicenseUserCnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		resultMap.put("page", page);
		
		return resultMap;
	}
	
	public CoviMap getLicenseAddUser(CoviMap params) throws Exception {
		CoviMap resultMap = new CoviMap();
		CoviMap page = new CoviMap();
		int cnt = (int) coviMapperOne.getNumber("framework.license.selectLicenseAddUserCnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("framework.license.selectLicenseAddUserList", params);
		resultMap.put("list", CoviSelectSet.coviSelectJSON(list, "UserName,LogonID,DeptName,UserCode"));
		resultMap.put("page", page);
		
		return resultMap;
	}
	
	public int insertUserLicense(CoviMap params) throws Exception {
		return coviMapperOne.insert("framework.license.insertUserLicense", params);
	}
	
	public int deleteUserLicense(CoviMap params) throws Exception {
		return coviMapperOne.delete("framework.license.deleteUserLicense", params);
	}
}
