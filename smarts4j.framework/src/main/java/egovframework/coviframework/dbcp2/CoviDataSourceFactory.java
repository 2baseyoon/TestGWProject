package egovframework.coviframework.dbcp2;

import egovframework.baseframework.sec.SEED;
import egovframework.baseframework.util.PropertiesUtil;

import org.apache.tomcat.dbcp.dbcp2.BasicDataSourceFactory;

import javax.naming.Context;
import javax.naming.Name;
import javax.naming.RefAddr;
import javax.naming.Reference;
import javax.naming.StringRefAddr;

import java.util.Enumeration;
import java.util.Hashtable;

/**
 * tomcat 8+ dbcp2 용임.
 * tomcat jdbc (DataSourceFactory) 방식은 baseframework 사용
 * @author hgsong
 *
 */
public class CoviDataSourceFactory extends BasicDataSourceFactory {


    @Override
	public Object getObjectInstance(Object obj, Name name, Context nameCtx, Hashtable<?, ?> environment) throws Exception {
        Reference ref = (Reference)obj;
        
        Reference clone = new Reference(ref.getClassName());
        
        Enumeration<RefAddr> refAddrs = ref.getAll();
        while (refAddrs.hasMoreElements()) {
            RefAddr ra = refAddrs.nextElement();
            if(ra != null) {
            	String key = ra.getType();
            	String value = ra.getContent().toString();
            	
            	if (ra != null) {
            		if("username".equals(key) || "password".equals(key)) {
            			ra = new StringRefAddr(key, decrypt(value));
            		}
            		clone.add(ra);
            	}
            }
        }
    	
    	return super.getObjectInstance(clone, name, nameCtx, environment);
	}

	private String decrypt(String originStr) throws Exception {
        String _decryStr = "";
        _decryStr = SEED.getSeedDecrypt(
                originStr,
                SEED.getSeedRoundKey( PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("sec.tripledes.key") ) )
        );

        return _decryStr;
    }

}
