package egovframework.core.sevice.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.lang.StringEscapeUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.service.CacheLoadService;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.SysDomainSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.vo.ObjectAcl;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("sysDomainService")
public class SysDomainSvcImpl extends EgovAbstractServiceImpl implements SysDomainSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private CacheLoadService cacheLoadSvc;

	@Override
	public CoviMap select(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("sys.domain.selectgridcnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("sys.domain.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DomainID,DomainCode,DomainURL,DisplayName,MemberOf,DomainPath,SortKey,IsUse,ActiveUser,ServiceUser,ServicePeriod,Description,RegistDate,DomainImagePath,DomainThemeCode"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectOne(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("sys.domain.selectone", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "DomainID,DomainCode,DomainURL,DomainType,MailDomain,IsCPMail,DisplayName,MultiDisplayName,MemberOf,DomainPath,SortKey,SortPath,IsUse,ActiveUser,ServiceUser,Description,RegistDate,ServiceStart,ServiceEnd,SubDomain,OrgSyncType,DomainRepName,DomainRepTel,DomainCorpTel,DomainImagePath,DomainZipcode,DomainAddress,Memo,DomainBannerPath,DomainBannerLink,DomainThemeCode,ChargerName,ChargerTel,ChargerID,ChargerEmail,IsUseGoogleSchedule,GoogleClientID,GoogleClientKey,GoogleRedirectURL,LicDomain,LicUserCount,LicExpireDate,LieExUserCount,LicEx1Date,EntireMailID"));
		return resultList;
	}
	
	@Override
	public CoviMap selectCode(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("sys.domain.selectCode", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DomainID,DomainCode,DomainURL,DisplayName,MultiDisplayName,ShortName,MultiShortName"));
		return resultList;
	}
	
	@Override
	public int insert(CoviMap paramDN) throws Exception {
		int chkDup = (int)coviMapperOne.getNumber("sys.domain.chkDuplicationObject", paramDN);
		int retCnt = 0;
		
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		StringUtil func = new StringUtil();
		
		CoviMap params;
		
		if(chkDup < 1){
			// #1. 도메인 생성 (sys_object_domain, sys_object INSERT)
			retCnt = coviMapperOne.insert("sys.domain.insertDomain", paramDN); 
			
			if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
				 coviMapperOne.insert("sys.domain.insertDomainSysObject", paramDN); 
			}
			
			// #2. Company 그룹 생성 (sys_object_group INSERT)
			coviMapperOne.insert("sys.domain.insertCascadeCompanyGroup", paramDN);
			
			// #3. 퇴직부서 생성  (sys_object_group, sys_object INSERT) 
			coviMapperOne.insert("sys.domain.insertRetireDept", paramDN);
			
			if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
				 coviMapperOne.insert("sys.domain.insertRetireDeptSysObjecct", paramDN); 
			}
			
			// #4.  임의 그룹 생성 (sys_object_group, sys_object INSERT) 
			coviMapperOne.insert("sys.domain.insertCascadeDivision", paramDN);
			
			if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
				 coviMapperOne.insert("sys.domain.insertCascadeDivisionObjectGroup", paramDN); 
			}
			
			// #5. Path Update ( [domain- SortPath], [group-SortPath, OUPath, GroupPath] ) 
			if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
				String path = coviMapperOne.selectOne("sys.domain.selectComDnSortPath", paramDN);
				
				paramDN.put("DoSortPath", path);
				
				coviMapperOne.update("sys.domain.updateAllPath", paramDN);
				
				List list = new ArrayList();
				
				list = coviMapperOne.list("sys.domain.selectAllPathList", paramDN);
				
				if(list.size() > 0 ){
					
					for(int i=0; i < list.size(); i++)
					{
						params = (CoviMap) list.get(i);
						
						coviMapperOne.update("sys.domain.updateAllPathCompanySort", params);
						
						coviMapperOne.update("sys.domain.updateAllPathCompanyGroup", params);
						
						coviMapperOne.update("sys.domain.updateAllPathCompanyOU", params);
						
					}
				 
				}
				
			}else{
				coviMapperOne.update("sys.domain.updateAllPath", paramDN);
			}
			
			// #6.  엑셀동기화 테이블에 회사 정보 생성
			if(paramDN.get("OrgSyncType").toString().equals("MANUAL")) {
				coviMapperOne.insert("sys.domain.insertCompanytoExcel", paramDN);				
			}
			
			// #7.   회사 기본 데이타 생성
			String sNewPassword = "";
			if(!RedisDataUtil.getBaseConfig("InitPassword").equals("")) {
				sNewPassword = RedisDataUtil.getBaseConfig("InitPassword");
//				sNewPassword ="1";
			}
			paramDN.put("Key", 	PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key")));
			paramDN.put("Password", sNewPassword);
			coviMapperOne.update("sys.domain.createInitCompanyData", paramDN);				
//			coviMapperOne.selectOne("sys.domain.createInitCompanyData", paramDN);				

				
			// Redis 권한 데이터 초기화
			RedisShardsUtil.getInstance().removeAll(paramDN.getString("DomainID"), RedisDataUtil.PRE_ACL + paramDN.getString("DomainID") + "_*");
			// Redis 기초설정 데이터 다시 만들기
			paramDN.put("domainId",paramDN.get("DomainID") );
			List<?> baseConfigList = cacheLoadSvc.selectBaseConfig(paramDN);
			RedisShardsUtil.getInstance().saveList(baseConfigList, RedisDataUtil.PRE_BASECONFIG, "_", "DomainID", "SettingKey");
			
		}else{
			retCnt = -1;
		}
		
		return retCnt;
	}
	
	@Override
	public int update(CoviMap paramDN) throws Exception {
		// #1. 도메인 정보 수정 (sys_object_domain UPDATE)
		int retCnt = coviMapperOne.update("sys.domain.updateDomain", paramDN);
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		StringUtil func = new StringUtil();
		
		// #2. 객체 정보 수정 (sys_object UPDATE)
		coviMapperOne.update("sys.domain.updateObject", paramDN);
		
		// #3. 그룹 정보 수정 (sys_object_group UPDATE)
		coviMapperOne.update("sys.domain.updateGroup", paramDN);

		// #4. 사용자 정보에 있는 도메인 정보 수정  (sys_object_user_basegroup UPDATE)
		coviMapperOne.update("sys.domain.updateUserBaseGroup", paramDN);
		
		// #5. Path Update 수정 ([group-OUPath])
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			List list = new ArrayList();
			list = coviMapperOne.list("sys.domain.selectAllPathList", paramDN);
			
			if(list.size() > 0 ){
				for(int i=0; i < list.size(); i++){
					paramDN = (CoviMap) list.get(i);
					coviMapperOne.update("sys.domain.updateAllPathCompanyOU", paramDN);
					
				}
			}
		}else {
			coviMapperOne.update("sys.domain.updateGroupOUPath", paramDN);
		}
	
		return 	retCnt;
	}

	@Override
	public int updateIsUse(CoviMap params) throws Exception {
		// #1. 도메인 사용 여부 수정 (sys_object_domain)
		int retCnt = coviMapperOne.update("sys.domain.updateDomainIsUse", params);

		// #2. 객체 사용 여부 수정 (sys_object_object)
		coviMapperOne.update("sys.domain.updateObjectIsUse", params);
		
		// #3. 그룹 사용 여부 수정 (sys_object_group)
		coviMapperOne.update("sys.domain.updateGroupIsUse", params);
		
		return retCnt;
	}
	
	@Override
	public int updateDomainInfo(CoviMap params) throws Exception {
		return coviMapperOne.update("sys.domain.updateDomainInfo", params);
	}
	
	@Override
	public int insertDomainGoogleSchedule(CoviMap params) throws Exception {
		return coviMapperOne.insert("sys.domain.insertDomainGoogleSchedule", params);
	}
	
	@Override
	public String insertDomainFolder(CoviMap params) throws Exception {
		coviMapperOne.insert("sys.domain.insertDomainFolder", params);
		
		String aclActionDataStr = "[{\"SubjectCode\":\""+params.getString("DomainCode")+"\",\"SubjectType\":\"CM\",\"AclList\":\"SCDMEVR\"}]";
		CoviList aclDataList = new CoviList();
		aclDataList.addAll((Collection) CoviList.fromObject(StringEscapeUtils.unescapeHtml(aclActionDataStr)));
		String folderID = params.getString("FolderID");
		
		CoviMap idParam = new CoviMap();
		idParam.put("FolderID", folderID);
		// Folder SortPath, FolderPath Update
		String sortPath = coviMapperOne.selectOne("sys.domain.selectComSortPathCreateS", idParam);
		String folderPath = coviMapperOne.selectOne("sys.domain.selectComObjectPathCreateS", idParam);
		idParam.put("SortPath", sortPath);
		idParam.put("FolderPath", folderPath);
		coviMapperOne.update("sys.domain.updateSortPath", idParam);
		coviMapperOne.update("sys.domain.updateFolderPath", idParam);

		//권한 데이터 저장
		if(!aclDataList.isEmpty()){
			CoviList aclDatas = new CoviList();
			for(Object obj : aclDataList){
				CoviMap aclDataObj = new CoviMap();
				aclDataObj.addAll((Map) obj);
				
				ObjectAcl aclObject = new ObjectAcl();
				aclObject.setObjectID(Integer.parseInt(folderID));
				aclObject.setObjectType("FD");
				aclObject.setSubjectType(aclDataObj.getString("SubjectType"));
				aclObject.setSubjectCode(aclDataObj.getString("SubjectCode"));
				aclObject.setAclList(aclDataObj.getString("AclList"));
				
				aclDatas.add(aclObject);
			}
			
			coviMapperOne.insert("framework.authority.insertACLList", aclDatas);
			
			// Redis 권한 데이터 초기화
			RedisShardsUtil.getInstance().removeAll(params.getString("DomainID"), RedisDataUtil.PRE_ACL + params.getString("DomainID") + "_*");
		}
		
		return folderID;
	}
	
	@Override
	public int updateDomainInfoDesign(CoviMap params) throws Exception {
		return coviMapperOne.update("sys.domain.updateDomainInfoDesign", params);
	}
	
	@Override
	public CoviMap selectDomainLicenseList(CoviMap params) throws Exception {
		CoviMap returnMap = new CoviMap();
		
		CoviList list = coviMapperOne.list("sys.domain.selectDomainLicenseList", params);
		returnMap.put("list", CoviSelectSet.coviSelectJSON(list, "LicSeq,LicName,Description,ServiceUser,ExtraExpiredate,ExtraServiceUser,LicUserCount,LicExUserCount,LicEx1Date,LicUsingCnt"));
		
		return returnMap;
	}
	
	@Override
	public CoviMap selectDomainLicAddList(CoviMap params) throws Exception {
		CoviMap returnMap = new CoviMap();
		
		CoviList list = coviMapperOne.list("sys.domain.selectDomainLicAddList", params);
		returnMap.put("list", CoviSelectSet.coviSelectJSON(list, "LicSeq,LicName,ModuleName,Description,ServiceUser,ExtraExpiredate,ExtraServiceUser"));
		
		return returnMap;
	}
	
	@Override
	public int saveDoaminLicInfo(CoviMap params) throws Exception {
		int cnt = coviMapperOne.update("sys.domain.insertDomainLic", params);
		
		return cnt;
	}
	
	@Override
	public int deleteDomainLic(CoviMap params) throws Exception {
		return coviMapperOne.delete("sys.domain.deleteDomainLic", params);
	}
	
}
