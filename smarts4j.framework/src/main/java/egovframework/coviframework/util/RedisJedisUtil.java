package egovframework.coviframework.util;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.net.ssl.SSLParameters;
import javax.net.ssl.SSLSocketFactory;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.cache.annotation.Cacheable;

import redis.clients.jedis.JedisPoolConfig;
import redis.clients.jedis.JedisShardInfo;
import redis.clients.jedis.ScanParams;
import redis.clients.jedis.ScanResult;
import redis.clients.jedis.ShardedJedis;
import redis.clients.jedis.ShardedJedisPool;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.redis.ShardedJedisReturnedCallback;
import egovframework.baseframework.data.redis.ShardedJedisTemplate;
import egovframework.baseframework.util.InitRedis;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;


public class RedisJedisUtil extends RedisShardsUtil {
	private Logger LOGGER = LogManager.getLogger(RedisJedisUtil.class);
	
	private static ShardedJedisPool pool = null;
	private static ShardedJedisTemplate template;

	private RedisJedisUtil(){
		initPools();
	}
	
	public static class RedisShardHolder{
		public static final RedisShardsUtil INSTANCE = new RedisJedisUtil();
	}
	
	public static RedisShardsUtil getInstance() {
		return RedisShardHolder.INSTANCE;
	}

	/*
	 * https://github.com/sid2656/utils_redis/blob/master/code/redis/src/main/resources/db.properties
	 * 
	 * */

	private void initPools(){
		if (pool == null) {
			try {
				JedisPoolConfig config = new JedisPoolConfig();
				//변수들을 properties로 뺄 것
				config.setMaxTotal(InitRedis.REDIS_TOTAL);
				config.setMaxIdle(InitRedis.REDIS_IDLE);
				config.setMaxWaitMillis(InitRedis.REDIS_WAIT);
				config.setTestOnBorrow(InitRedis.REDIS_BORROW);
				config.setTestOnReturn(InitRedis.REDIS_RETURN);
				
				String strHosts = InitRedis.SERVER_HOSTS;
				String strPorts = InitRedis.SERVER_PORTS;
				String[] hosts = strHosts.split(",");
				String[] ports = strPorts.split(",");
				
				String isSSL = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getDBProperties().getProperty("db.redis.isUseSSL", "N"));
				SSLSocketFactory sslSocketFactory = (SSLSocketFactory) SSLSocketFactory.getDefault();
				SSLParameters sslParameters = new SSLParameters();
				sslParameters.setEndpointIdentificationAlgorithm("HTTPS");
				sslParameters.setProtocols(new String[]{"TLSv1.2"});
				
				if (hosts.length > ports.length) {
					throw new Exception("서버 수가 맞지 않음.");
				}else{
					List<JedisShardInfo> list = new LinkedList<JedisShardInfo>();
					for (int i = 0; i < hosts.length; i++) {
//						JedisShardInfo shardinfo = new JedisShardInfo(hosts[i], Integer.valueOf(ports[i]), InitRedis.SERVER_USERNAME);
						JedisShardInfo shardinfo = null;
						if("Y".equals(isSSL)) {
							//shardinfo = new JedisShardInfo("rediss://" + hosts[i] + ":" + ports[i], sslSocketFactory, sslParameters, null);
							shardinfo = new JedisShardInfo(hosts[i], Integer.parseInt(ports[i]), 10*1000, InitRedis.SERVER_USERNAME, true, sslSocketFactory, sslParameters, null);
						} else {
							shardinfo = new JedisShardInfo(hosts[i], Integer.parseInt(ports[i]), 10*1000, InitRedis.SERVER_USERNAME);
						}

						shardinfo.setPassword(InitRedis.SERVER_PASSWORD);
						
						list.add(shardinfo);
					}

					pool = new ShardedJedisPool(config, list);
					
					//template = new ShardedJedisTemplate();
			        //template.setShardedJedisPool(pool);
				}
			} catch(NullPointerException e){	
				LOGGER.error("RedisShardsUtil", e);
			} catch (Exception e) {
				LOGGER.error("RedisShardsUtil", e);
			}
		}
	}

	/**
	 * 
	 * save
	 *
	 * @author sid
	 * @param key
	 * @param value
	 * @return
	 */
	@Override
	public void save(String key, String value) {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			jedis.set(key, value);
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
	}
	
	/**
	 * @param	jObj 
	 * @type	JSonObject
	 * @Data	
	 */
	@Override
	public void saveDicInfo(CoviMap pMap){
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			//Redis 추가된 다국어 항목 부분 동기화
			CoviMap rMap = new CoviMap();
			CoviMap redisObj = new CoviMap();
			rMap.put("DicSection", pMap.get("DicSection"));
			rMap.put("DN_ID", "".equals(pMap.get("DN_ID")) ? "0" : pMap.get("DN_ID"));
			rMap.put("DIC_Code", pMap.get("DIC_Code"));
			rMap.put("DIC_Name", pMap.get("DIC_Name"));
			rMap.put("KoShortWord", pMap.get("Ko"));
			rMap.put("KoFullWord", pMap.get("Ko"));
			rMap.put("EnShortWord", pMap.get("En"));
			rMap.put("EnFullWord", pMap.get("En"));
			rMap.put("JaShortWord", pMap.get("Ja"));
			rMap.put("JaFullWord", pMap.get("Ja"));
			rMap.put("ZhShortWord", pMap.get("Zh"));
			rMap.put("ZhFullWord", pMap.get("Zh"));
			rMap.put("IsUse", pMap.get("IsUse"));
			rMap.put("IsCaching","Y");
			rMap.put("Description",  pMap.get("Description"));
			rMap.put("DataStatus",  pMap.get("DataStatus"));
			rMap.put("RegID", pMap.get("RegID"));
			rMap.put("ModID", pMap.get("ModID"));
			rMap.put("RegDate", System.currentTimeMillis());
			rMap.put("ModDate", System.currentTimeMillis());
			rMap.put("ReservedFullWord1",null);
			rMap.put("ReservedFullWord2",null);
			rMap.put("ReservedShortWord1",null);
			rMap.put("ReservedShortWord2",null);
			redisObj.putAll(rMap);
			
			jedis.pipelined();
			//map -> json string으로 저장
			ObjectMapper mapperObj = new ObjectMapper();
			String jsonResp = mapperObj.writeValueAsString(redisObj);
			jedis.set(rMap.get("DIC_Code").toString(), jsonResp);
			LOGGER.info(jsonResp);
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
	}
	@Override
	public void saveDicList(List<?> list) {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			jedis.pipelined();
			
			for (int i = 0; i < list.size(); i++) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get("DIC_Code") == null) {
					throw new Exception();
				}
				
				//map -> json string으로 저장
				ObjectMapper mapperObj = new ObjectMapper();
				String jsonResp = mapperObj.writeValueAsString(eMap);
				
				jedis.set(eMap.get("DIC_Code").toString(), jsonResp);
			}
			
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
	}
	@Override
	public void saveList(List<?> list, String prefix, String colKey) {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			
			jedis.pipelined();
			
			for (int i = 0; i < list.size(); i++) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get(colKey) == null) {
					throw new Exception();
				}
				
				//map -> json string으로 저장
				ObjectMapper mapperObj = new ObjectMapper();
				String jsonResp = mapperObj.writeValueAsString(eMap);
				
				jedis.set(prefix + eMap.get(colKey).toString(), jsonResp);
			}
			
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
	}
	
	@Override
	public void saveList(List<?> list, String prefix, String delimiter, String col1, String col2) {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			jedis.pipelined();
			
			for (int i = 0; i < list.size(); i++) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get(col1) == null || eMap.get(col2) == null) {
					throw new Exception();
				}
				
				//map -> json string으로 저장
				ObjectMapper mapperObj = new ObjectMapper();
				String jsonResp = mapperObj.writeValueAsString(eMap);
				
				jedis.set(prefix + eMap.get(col1).toString() + delimiter + eMap.get(col2).toString(), jsonResp);
			}
			
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
	}
	
	@Override
	public void saveList(List<?> list, String prefix, String delimiter, String col1, String col2, String col3) {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			jedis.pipelined();
			
			for (int i = 0; i < list.size(); i++) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get(col1) == null || eMap.get(col2) == null) {
					throw new Exception();
				}
				
				//map -> json string으로 저장
				ObjectMapper mapperObj = new ObjectMapper();
				String jsonResp = mapperObj.writeValueAsString(eMap);
				
				jedis.set(prefix + eMap.get(col1).toString() + delimiter + eMap.get(col2).toString() + delimiter + eMap.get(col3).toString(), jsonResp);
			}
			
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
	}
	
	/**
	 * 
	 * remove
	 *
	 * @author sid
	 * @param key
	 * @return
	 */
	@Override
	public void remove(String key) {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			jedis.del(key);
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
	}
	
	@Override
	public void flushAll() {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			jedis.getShard("ALL").flushAll();
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
	}

	/**
	 * containsKey
	 * 
	 * @param key
	 * @return
	 */
	@Override
	public boolean containsKey(String key) {
		boolean hasKey = false;
		
		if(get(key) != null) {
			hasKey = true;
		}
		
		return hasKey;
	}
	
	/**
	 * 
	 * get
	 *
	 * @author sid
	 * @param key
	 * @return
	 */
	@Override
	public String get(String key) {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			return jedis.get(key);
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
		return null;
	}
	
	/**
	 * 미사용 확인
	 * getKeyTag
	 * @param key
	 * @return
	 */
	public String getKeyTag(String key) {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			return jedis.getKeyTag(key);
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
		return null;
	}
	
	@Override
	public Set<String> keys(String key, String pattern) {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			return jedis.getShard(key).keys(pattern);
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
		return null;
	}
	
	/**
	 * 
	 * setex
	 * 
	 * @param key
	 * @param seconds
	 * @param value
	 * @exception @since
	 *                1.0.0
	 */
	@Override
	public void setex(String key, int seconds, String value) {
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			jedis.setex(key.getBytes("utf-8"), seconds, value.getBytes("utf-8"));
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally {
			if(jedis != null)jedis.close();
		}
	}
	
	/**
	 * @param	jObj 
	 * @type	JSonObject
	 * @Data	
	 */
	@Override
	public void saveUserInfo(CoviMap pMap){
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
			
			//Redis 추가된 다국어 항목 부분 동기화
			CoviMap rMap = new CoviMap();
			CoviMap redisObj = new CoviMap();
			
			rMap.put("DN_ID", "".equals(pMap.get("DN_ID")) ? "0" : pMap.get("DN_ID"));
			rMap.put("LanguageCode", pMap.get("LanguageCode"));
			rMap.put("LogonID", pMap.get("LanguageCode"));
			rMap.put("UR_ID", pMap.get("UR_ID"));
			rMap.put("UR_Code", pMap.get("UR_Code"));
			rMap.put("UR_EmpNo", pMap.get("UR_EmpNo"));
			rMap.put("UR_Name", pMap.get("UR_Name"));
			rMap.put("UR_Mail", pMap.get("UR_Mail"));
			rMap.put("UR_JobPositionCode", pMap.get("UR_JobPositionCode"));
			rMap.put("UR_JobPositionName", pMap.get("UR_JobPositionName"));
			rMap.put("UR_JobTitleCode", pMap.get("UR_JobTitleCode"));
			rMap.put("UR_JobTitleName", pMap.get("UR_JobTitleName"));
			rMap.put("UR_JobLevelCode", pMap.get("UR_JobLevelCode"));
			rMap.put("UR_JobLevelName", pMap.get("UR_JobLevelName"));
			rMap.put("UR_ManagerCode", pMap.get("UR_ManagerCode"));
			rMap.put("UR_ManagerName", pMap.get("UR_ManagerName"));
			rMap.put("UR_IsManager", pMap.get("UR_IsManager"));
			rMap.put("DN_Code", pMap.get("DN_Code"));
			rMap.put("DN_Name", pMap.get("DN_Name"));
			rMap.put("GR_Code", pMap.get("GR_Code"));
			rMap.put("GR_Name", pMap.get("GR_Name"));
			rMap.put("GR_GroupPath", pMap.get("GR_GroupPath"));
			rMap.put("GR_FullName", pMap.get("GR_FullName"));
			
			redisObj.putAll(rMap);
			
			jedis.pipelined();
			
			//map -> json string으로 저장
			ObjectMapper mapperObj = new ObjectMapper();
			String jsonResp = mapperObj.writeValueAsString(redisObj);
			jedis.set(rMap.get("UR_Code").toString()+rMap.get("UR_ID").toString(), jsonResp);
			
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil", e);
		} finally { 
			if(jedis != null)jedis.close();
		}
	}
	
	@Override
	public void hset(String key, String field, String value) {
	    ShardedJedis jedis = null;
	    try {
	        jedis = pool.getResource();
	        jedis.hset(key, field, value);
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
	    } catch (Exception e) {
	        LOGGER.error("RedisShardsUtil", e);
	    } finally {
	    	if(jedis != null)jedis.close();
	    }
	}

	@Override
	public String hget(String key, String field) {
	    ShardedJedis jedis = pool.getResource();
	    try {
	        return jedis.hget(key, field);
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
	    } catch (Exception e) {
	        LOGGER.error("RedisShardsUtil", e);
	    } finally {
	    	if(jedis != null)jedis.close();
	    }
	    return null;
	}
	
	@Override
	public void hmset(String key, Map<String, String> map) {
        ShardedJedis jedis = null;
        try {
            jedis = pool.getResource();
            jedis.hmset(key, map);
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
        } catch (Exception e) {
            LOGGER.error("RedisShardsUtil", e);
        } finally {
        	if(jedis != null)jedis.close();
        }
    }
	
	@Override
	public void setExpireTime(String pKey, int pExpireTime) {
		ShardedJedis jedis = null;
        try {
            jedis = pool.getResource();
            jedis.expire(pKey, pExpireTime);
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil", e);
        } catch (Exception e) {
            LOGGER.error("RedisShardsUtil", e);
        } finally {
            if(jedis != null)jedis.close();
        }
	}
	
	@Override
	public void removeAll(String pattern){
        String deleteScriptLUA = "local keys = redis.call('keys', '%s')" +
                "  for i,k in ipairs(keys) do" +
                "    local res = redis.call('del', k)" +
                "  end";
		ShardedJedis jedis = null;
		try {
			jedis = pool.getResource();
	        jedis.getShard("").eval(String.format(deleteScriptLUA, pattern));
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil.removeAll", e);
	    } catch (Exception e) {
	        LOGGER.error("RedisShardsUtil.removeAll", e);
	    } finally {
	    	if(jedis != null)jedis.close();
	    }
	}
	
	@Override
	public void removeAll(String key, String pattern){
		ShardedJedis jedis = null;
		Set<String> matchingKeys = new HashSet<>();
		ScanParams params = new ScanParams();
		params.match(pattern);
		
		try {
			jedis = pool.getResource();
			String nextCursor = "0";

		    do {
		        ScanResult<String> scanResult = jedis.getShard(key).scan(nextCursor, params);
		        List<String> keys = scanResult.getResult();
		        nextCursor = scanResult.getStringCursor();

		        matchingKeys.addAll(keys);

		    } while(!nextCursor.equals("0"));
		    
		    if(matchingKeys.size() > 0){
		    	jedis.getShard(key).del(matchingKeys.toArray(new String[matchingKeys.size()]));	
		    }
			
		} catch(NullPointerException e){	
			LOGGER.error("RedisShardsUtil.removeAll", e);
		} catch (Exception e) {
			LOGGER.error("RedisShardsUtil.removeAll", e);
		} finally {
			if(jedis != null)jedis.close();
		}
	}

	@Override
	public void close() {
	}
}
