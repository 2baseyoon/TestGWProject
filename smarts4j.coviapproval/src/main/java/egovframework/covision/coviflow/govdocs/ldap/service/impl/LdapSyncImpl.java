package egovframework.covision.coviflow.govdocs.ldap.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.coviflow.govdocs.ldap.service.LdapSyncSvc;
import egovframework.covision.coviflow.govdocs.util.Ldap;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.covision.coviflow.common.util.RequestHelper;

@Service("ldapSyncService")
public class LdapSyncImpl extends EgovAbstractServiceImpl implements LdapSyncSvc{
	
	private Logger LOGGER = LogManager.getLogger(LdapSyncImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public void doFullUpdateLDAPData() throws Exception {
		
		Ldap ldap = new Ldap("152.99.57.130");//doc.dir.go.kr IP로 문서유통 LDAP 서버
		List<CoviMap> list = ldap.fullData();		
		
		String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") +	"/approval"; 
		String httpCommURL = approvalURL + "/ldap/ldapFullSyncData.do";
		CoviMap params = new CoviMap(); 
		params.put("list",  list);
		
		RequestHelper.sendPOST(httpCommURL, params);
	}
	
	@Override
	public void doFullUpdateLDAPData2(List<CoviMap> list) throws Exception{
		CoviMap map = new CoviMap(); 
		int interval = 1000;
		coviMapperOne.delete("service.ldap.deleteLDAPTempAll", null);
		for(int i = 0, tot = list.size(); i < tot; i += interval){
			List subList = list.subList( i , (i+interval) < tot ? (i+interval) :  list.size() );
			map.put("list", subList);
			map.put("size", subList.size()-1);
			coviMapperOne.insert("service.ldap.insertLDAPTemp", map);
		}
		coviMapperOne.delete("service.ldap.deleteLDAPAll", null);
		coviMapperOne.insert("service.ldap.insertLDAPCopy", null);	
		//동기화된 문서유통수신처애 없는 개인배포 groupmember 삭제
		coviMapperOne.delete("service.ldap.deletePrivateDistributionMemberLDAP", null);
		//groupmember가 하나도 없는 group 삭제
		coviMapperOne.delete("service.ldap.deletePrivateDistributionLDAP", null);
	}
	
}
