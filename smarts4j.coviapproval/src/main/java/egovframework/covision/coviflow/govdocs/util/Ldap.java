package egovframework.covision.coviflow.govdocs.util;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

import javax.naming.Context;
import javax.naming.NamingEnumeration;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;
import javax.naming.ldap.Control;
import javax.naming.ldap.InitialLdapContext;
import javax.naming.ldap.LdapContext;
import javax.naming.ldap.PagedResultsControl;
import javax.naming.ldap.PagedResultsResponseControl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;

public class Ldap {
	Logger LOGGER = LogManager.getLogger(Ldap.class);
			
	private LdapContext ctx; 
	private SearchControls searchCtls;
	private ArrayList<CoviMap> arr = new ArrayList<>();	
	private Hashtable<String, Object> env = new Hashtable<String, Object>(11);
	private int pageSize = 1000;

	public Ldap() throws Exception {
		this.env.put(Context.INITIAL_CONTEXT_FACTORY,"com.sun.jndi.ldap.LdapCtxFactory");
		this.env.put(Context.PROVIDER_URL,"ldap://"+PropertiesUtil.getGlobalProperties().getProperty("ldap.path"));
		this.initSearchCtls();
		this.initContext();
	}
	
	public Ldap(String url) throws Exception {		
		this.env.put(Context.INITIAL_CONTEXT_FACTORY,"com.sun.jndi.ldap.LdapCtxFactory");
		this.env.put(Context.PROVIDER_URL, "ldap://"+url);
		this.initSearchCtls();
		this.initContext();	
	}
	
	private void initSearchCtls() {
		this.searchCtls = new SearchControls();
		this.searchCtls.setSearchScope(SearchControls.ONELEVEL_SCOPE);
		this.searchCtls.setCountLimit(0);			
		this.searchCtls.setReturningAttributes( new String []{ "ouCode","ouOrder","ucOrgFullName","ou","topouCode","repouCode","parentouCode","ouLevel","ucChieftitle","ouReceiveDocumentYN" } );
	}
	
	private void initContext() {
		try {
			this.ctx = new InitialLdapContext(this.env, null);
			this.ctx.setRequestControls(new Control[] { new PagedResultsControl(this.pageSize, Control.NONCRITICAL) });
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} 
	}
	
	public List<SearchResult> listByPOu(String dn,String pou)throws Exception  {
		
		List<SearchResult> rtnList = new ArrayList<SearchResult>();
		String searchFilter = "(&(&(objectClass=ucOrg2)(!(ou=people)))(parentOuCode="+pou+"))";
		byte[] cookie = null;
		do {
			NamingEnumeration<SearchResult> results = this.ctx.search(dn.replaceAll("/", "\\\\/"), searchFilter,this.searchCtls);
			while (results != null && results.hasMore()) {
		      rtnList.add(results.next());
		    }
			Control[] controls = this.ctx.getResponseControls();
		    if (controls != null) {
			    if(controls[0] instanceof PagedResultsResponseControl) {
		          PagedResultsResponseControl prrc = (PagedResultsResponseControl) controls[0];
		          cookie = prrc.getCookie();
		        }
		    }
		    ctx.setRequestControls(new Control[] { new PagedResultsControl(pageSize, cookie, Control.CRITICAL) });
		} while (cookie != null);
		return rtnList;
	}
	
	public int countByPou( String dn,String ouCode ) {
		try {
			return this.listByPOu(dn, ouCode).size();
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			return 0;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return 0;
		}
	}
	
	public ArrayList<CoviMap> listByTreeData(String dn,String pou,String pouName,String stepStr) throws Exception{		
		try {
			List<SearchResult> answer = this.listByPOu(dn,pou);
			CoviMap hm;
			for( SearchResult item : answer ) {
				hm = new CoviMap();
				Attributes attrs = item.getAttributes();
				String thisOuCode =  ((Attribute)attrs.get("ouCode")).get(0).toString();
				String thisOuName =  ((Attribute)attrs.get("ou")).get(0).toString();
				String thisStep = null == stepStr ? pouName+" > "+thisOuName : stepStr+" > "+thisOuName;
				int cnt = this.countByPou( item.getNameInNamespace(),thisOuCode );
				for(String key : this.searchCtls.getReturningAttributes() ) {
					hm.put( key ,  null != attrs.get(key) ? attrs.get(key).get(0).toString() : "" );
				}
				hm.put("parentouName", pouName); 
				hm.put("dn", item.getNameInNamespace());
				hm.put("subCount", String.valueOf(cnt));
				hm.put("ouOrder",  hm.getString("ouOrder").length() > 0 ? Integer.valueOf( hm.getString("ouOrder") ).toString() : "0" );
				hm.put("ouStep",  thisStep );			
				hm.put("ouReceiveDocumentYN", null == hm.get("ouReceiveDocumentYN") 
					? "N"  
					: hm.getString("ouReceiveDocumentYN").trim().length() > 0 ? hm.getString("ouReceiveDocumentYN").trim() : "N" 
				);			
				this.arr.add(hm);
				if( ((Attribute)attrs.get("parentouCode")).get(0).toString().equals("0000000") ) { 
					LOGGER.debug(thisOuName + " / " + cnt);
				} 
				if( cnt > 0 ) this.listByTreeData( item.getNameInNamespace(), thisOuCode, thisOuName, thisStep );
			}
		}catch (NullPointerException npE) {
			throw new Exception();
		}catch (Exception e) {
			throw new Exception();
		}
		return this.arr;
	}
	
	public ArrayList<CoviMap> fullData()throws Exception{
		ArrayList<CoviMap> rtn = this.listByTreeData("o=government of korea,c=kr", "0000000", "대한민국", null);
		this.ctx.close();
		return rtn;		
	}
}
