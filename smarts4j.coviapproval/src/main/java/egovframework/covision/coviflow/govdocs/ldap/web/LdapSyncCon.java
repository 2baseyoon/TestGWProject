package egovframework.covision.coviflow.govdocs.ldap.web;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.covision.coviflow.common.util.RequestHelper;
import egovframework.covision.coviflow.govdocs.ldap.service.LdapSyncSvc;


@Controller
public class LdapSyncCon {
	private Logger LOGGER = LogManager.getLogger(LdapSyncCon.class);

	@Autowired
	private LdapSyncSvc ldapSyncSvc;
	
	/**
	 * ldapFullSync - Ldap 조직도 전체 동기화
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "ldap/ldapFullSync.do" )
	public @ResponseBody CoviMap ldapFullSync(@RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		try {
			ldapSyncSvc.doFullUpdateLDAPData();
			
			returnList.put("status", Return.SUCCESS);	
		}catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
        	returnList.put("status", Return.FAIL);			
		}catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
        	returnList.put("status", Return.FAIL);			
		}
        return returnList;
	}
	
	/**
	 * ldapFullSync - Ldap 조직도 전체 동기화
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 */
	@RequestMapping(value = "ldap/ldapFullSyncData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap ldapFullSyncData(@RequestBody CoviMap formObj) throws Exception  {
		CoviMap returnList = new CoviMap();
		try {
			@SuppressWarnings("unchecked")
			List<CoviMap> list = (List<CoviMap>) formObj.get("list");
			
			ldapSyncSvc.doFullUpdateLDAPData2(list);
			
			returnList.put("status", Return.SUCCESS);	
		}catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
        	returnList.put("status", Return.FAIL);			
		}catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
        	returnList.put("status", Return.FAIL);			
		}
		return returnList;
	}

}
