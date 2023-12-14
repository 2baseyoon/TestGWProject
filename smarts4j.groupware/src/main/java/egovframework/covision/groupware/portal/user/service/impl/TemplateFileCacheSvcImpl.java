package egovframework.covision.groupware.portal.user.service.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.groupware.portal.user.service.TemplateFileCacheSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



// 테스트 주석
@Service("templateFileCacheService")
public class TemplateFileCacheSvcImpl extends EgovAbstractServiceImpl implements TemplateFileCacheSvc{

	private Logger LOGGER = LogManager.getLogger(TemplateFileCacheSvcImpl.class);
	
	@Override
	public String readAllText(String lang, String file, String encoding) throws IOException{
		String[] bits = file.split("/");
		String fileName = bits[bits.length-1];
		String layoutTemplateKey = lang+"_"+"portal_"+fileName;
		
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		String isSaveRedisTemplate = PropertiesUtil.getDBProperties().getProperty("db.redis.isSaveRedisPortal");
		String lineSeparator = System.getProperty("line.separator");
		
		if(isSaveRedisTemplate.equals("false") || instance.get(layoutTemplateKey) == null){		// 개발시에만 false
				File js = new File(FileUtil.checkTraversalCharacter(file));
				if(!js.exists()){
					return "";
				}
				
				try(BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), encoding))) {
					StringBuilder builder = new StringBuilder();
					String sCurrentLine;
					
					while ((sCurrentLine = br.readLine()) != null) {
						builder.append(sCurrentLine + lineSeparator);
					}
					String text = builder.toString();
					Pattern p = Pattern.compile("<spring:message[^>]*code=[\"']?([^>\"']+)[\"']?[^>]*(/>|></spring>|></spring:message>)");
					Matcher m = p.matcher(text);
					
					StringBuffer result = new StringBuffer(text.length());
					while(m.find()){
						String key = m.group(1).replace("Cache.", "");
						//tempDic 부분을 redis 다국어 가져 오는 걸로 대체
						m.appendReplacement(result, DicHelper.getDic(key, lang));
					}
					m.appendTail(result);
					
					if(isSaveRedisTemplate.equals("true")){
						instance.save(layoutTemplateKey, result.toString());
						LOGGER.debug("Portal is cached in redis");
					}
					
					return result.toString();
				}
		}else{
			return instance.get(layoutTemplateKey);
		}
	}
}
