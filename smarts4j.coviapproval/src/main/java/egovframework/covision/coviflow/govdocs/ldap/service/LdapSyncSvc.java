package egovframework.covision.coviflow.govdocs.ldap.service;
import java.util.List;

import egovframework.baseframework.data.CoviMap;

public interface LdapSyncSvc {
	public void doFullUpdateLDAPData() throws Exception;
	
	public void doFullUpdateLDAPData2(List<CoviMap> list) throws Exception;
}


