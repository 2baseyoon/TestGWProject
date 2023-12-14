package egovframework.coviframework.util;

import java.util.HashMap;
import java.util.Hashtable;

import javax.naming.Context;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;
import javax.naming.ldap.InitialLdapContext;
import javax.naming.ldap.LdapContext;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.util.PropertiesUtil;

public class ADAuthUtil {
	private static final Logger LOGGER = LogManager.getLogger(ADAuthUtil.class);
			
	public HashMap<String, Object> getUserAuthetication(String pLogonID, String pUserPW) {
		HashMap<String, Object> resultMap = null;
		
		try {
			String url = PropertiesUtil.getSecurityProperties().getProperty("loginLDAP.URL");				// LDAP URL
			String domain = PropertiesUtil.getSecurityProperties().getProperty("loginLDAP.Domain"); 		// 회사명이 domain.com이라면 DOMAIN
			String searchBase = PropertiesUtil.getSecurityProperties().getProperty("loginLDAP.SearhBase");  // 검색대상 tree
			
			SearchControls sc = new SearchControls();
			sc.setSearchScope(SearchControls.SUBTREE_SCOPE);
			// sc.setReturningAttributes(new String[] { "cn", "pwdLastSet"});

			Hashtable<String, String> env = new Hashtable<String, String>();
			env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
			env.put(Context.PROVIDER_URL, url);
			env.put(Context.SECURITY_AUTHENTICATION, "simple");
			env.put(Context.SECURITY_PRINCIPAL, pLogonID + "@" + domain);
			env.put(Context.SECURITY_CREDENTIALS, pUserPW);

			LdapContext ctx = new InitialLdapContext(env, null);
			NamingEnumeration<?> results = ctx.search(searchBase, "sAMAccountName=" + pLogonID, sc);

			while (results.hasMoreElements()) {
				SearchResult sr = (SearchResult) results.next();
				Attributes attrs = sr.getAttributes();
				
				if (attrs != null) {
					resultMap = new HashMap<String, Object>();
					NamingEnumeration<?> ne = attrs.getAll();
					while (ne.hasMore()) {
						Attribute attr = (Attribute) ne.next();
						resultMap.put(attr.getID(), attr.get());
					}
					ne.close();
				}
			}
		} catch (NamingException e) {
			//System.out.println(e.getMessage());
			LOGGER.error(e.getLocalizedMessage(), e);
			resultMap = null;
		}
		
		return resultMap;
	}
}
