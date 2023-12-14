package egovframework.coviframework.cache;

import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.CacheLoadService;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import java.util.UUID;

/**
 * @Class Name : CachingBean.java
 * @Description : 다국어, 기초설정, 기초코드 데이터를 redis에 저장
 * @Modification Information 
 * @ 2016.07.04 최초생성
 *
 * @author 코비젼 연구소
 * @since 2016. 07.04
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
public class CachingBean implements InitializingBean, DisposableBean {
	
	private Logger LOGGER = LogManager.getLogger(CachingBean.class);
	
	@Autowired
	private CacheLoadService cacheLoadSvc;

	@Override
	public void destroy() throws Exception {
	}
	
	@Override
	public void afterPropertiesSet() throws Exception {
	}

	@SuppressWarnings({ "unused" })
	private void openRedisCache() throws Exception {
		try {
			
			/*
			 * 다국어 캐쉬 개선 방향 - http://www.pretechsol.com/2014/06/java-ehcache-simple-example.html#.VzRhDoSyNBc
			 * serializable 클래스를 이용한 데이터 정리
			 * cachedic과 같은 하나의 다국어용 캐쉬를 생성
			 * ReloadableResource에서 dn, dic_code로 filtering해서 해당되는 캐쉬값을 리턴하도록 수정 할 것
			 * */
			
			//redis를 이용한 caching
			/* 성능상의 이슈 존재
			 * 일반적인 10649건의 save 50~60초
			 * pipeline 사용 시 20~30초
			 * 개발환경 시 다국어 캐쉬 load를 끄는 옵션 생성 db.redis.isDicCached
			 * 
			 * single, sharding에 대한 구분 처리
			 * single, template를 사용 시, spring annotation기반의 cache 설정이 가능해 짐.
			 * sharding, template 사용 시 spring annotation기반의 cache 사용은 이슈 있음
			 * 현재는 sharding, template를 사용하지 않는 구성.
			*/
			
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			boolean isDicCached = Boolean.parseBoolean(PropertiesUtil.getDBProperties().getProperty("db.redis.isDicCached"));
		
			//다국어 캐쉬
			if(isDicCached){
				//instance.removeAll(RedisDataUtil.PRE_DICTIONARY + "*");
				List<?> diclist = cacheLoadSvc.selectDic(null);
				instance.saveList(diclist, RedisDataUtil.PRE_DICTIONARY, "_", "DomainID", "DicCode");
				instance.save(RedisDataUtil.PRE_BASECONFIG + "SYNC_KEY", UUID.randomUUID().toString());
				LOGGER.info("Redis 내 다국어(sys_base_dictionary)를 삭제 후 재 캐쉬하였습니다.");
			}
			
			//기초설정 캐쉬
			//instance.removeAll(RedisDataUtil.PRE_BASECONFIG + "*");
			List<?> baseConfigList = cacheLoadSvc.selectBaseConfig(null);
			instance.saveList(baseConfigList, RedisDataUtil.PRE_BASECONFIG, "_", "DomainID", "SettingKey");
			instance.save(RedisDataUtil.PRE_BASECONFIG + "SYNC_KEY", UUID.randomUUID().toString());
			LOGGER.info("Redis 내 기초설정(sys_base_config)을 삭제 후 재 캐쉬하였습니다.");
						
			//기초코드 캐쉬
			//instance.removeAll(RedisDataUtil.PRE_BASECODE + "*");
			List<?> baseCodelist = cacheLoadSvc.selectBaseCode(null);
			instance.saveList(baseCodelist, RedisDataUtil.PRE_BASECODE,  "_", "DomainID", "CodeGroup", "Code");
			LOGGER.info("Redis 내 기초코드(sys_base_code)를 삭제 후 재 캐쉬하였습니다.");
			
			//auth sync 대상 syncKey 캐시
			Map<String, String> aclSyncMap = cacheLoadSvc.selectSyncType();
			CoviList domainList = cacheLoadSvc.selectDomain(null);
			for(int i = 0; i < domainList.size(); i++) {
				CoviMap domainInfo = domainList.getMap(i);
				instance.hmset(RedisDataUtil.PRE_H_ACL + domainInfo.getString("DomainID") + "_SYNC_MAP", aclSyncMap);
			}
			LOGGER.info("Redis 내  aclSyncMap을 캐쉬하였습니다.");
			
			//라이선스 캐시 제거
			//instance.removeAll(RedisDataUtil.PRE_LICENSE + "*");
			LOGGER.info("Redis 내  라이선스 정보를 삭제하였습니다.");
			
			//권한 메뉴 전체 목록 
			instance.removeAll(RedisDataUtil.PRE_AUTH_MENU+"*");
			List<?> authMenu = cacheLoadSvc.selectAuthMenu();
			instance.saveList(authMenu,RedisDataUtil.PRE_AUTH_MENU,  "_", "UrlKey", "MenuID");
			LOGGER.info("Redis 권한 메뉴를  삭제 후 재 캐쉬하였습니다.");

			//2차 권한 설정 사용여부
			String isAuditUrl = PropertiesUtil.getSecurityProperties().getProperty("audit.url.used");
			if (isAuditUrl!=null && isAuditUrl.equals("Y")){
				//감시할 URL  전체 목록 
				List<?> auditUrl = cacheLoadSvc.selectAuditUrl();
				instance.saveList(auditUrl,RedisDataUtil.PRE_AUDIT_URL,  "Url");
				//LOGGER.info("Redis 감시할  url를  삭제 후 재 캐쉬하였습니다.");
			}	
			
		} catch (NullPointerException e) {
			LOGGER.error("egovframework.coviframework.cache.CachingBean", e);
		} catch (Exception e) {
			LOGGER.error("egovframework.coviframework.cache.CachingBean", e);
		}
				
	}
}
