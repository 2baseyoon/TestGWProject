package egovframework.coviframework.util;

import java.time.Duration;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.ContextStartedEvent;
import org.springframework.context.event.ContextStoppedEvent;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import io.lettuce.core.ClientOptions;
import io.lettuce.core.RedisClient;
import io.lettuce.core.RedisFuture;
import io.lettuce.core.RedisURI;
import io.lettuce.core.ScriptOutputType;
import io.lettuce.core.api.StatefulRedisConnection;
import io.lettuce.core.api.async.RedisAsyncCommands;
import io.lettuce.core.api.sync.RedisCommands;
import io.lettuce.core.pubsub.RedisPubSubListener;
import io.lettuce.core.pubsub.StatefulRedisPubSubConnection;
import io.lettuce.core.pubsub.api.async.RedisPubSubAsyncCommands;


public class RedisLettuceSentinelUtil extends RedisShardsUtil {
	private Logger LOGGER;
	private int COMMAND_TIMEOUT = 2500;

	private static final String REDIS_MODE_SENTINEL = "sentinel";
	private static final String REDIS_MODE_STANDALONE = "standalone";
	ObjectMapper mapperObj = new ObjectMapper();
	
	private RedisLettuceSentinelUtil() {
		this.LOGGER = LogManager.getLogger(RedisLettuceSentinelUtil.class);
		this.initConnection();
	}

	// SingleTon
	private volatile static RedisLettuceSentinelUtil uniqueInstance;
	public static RedisLettuceSentinelUtil getInstance() {
	      if(uniqueInstance == null) {
	          synchronized(RedisLettuceSentinelUtil.class) {
	             if(uniqueInstance == null) {
	                uniqueInstance = new RedisLettuceSentinelUtil(); 
	             }
	          }
	       }
	       return uniqueInstance;
	}
	
	RedisClient sentinelClient = null;
	StatefulRedisConnection<String, String> connection = null;
	StatefulRedisPubSubConnection<String, String> publishConnection = null;
	StatefulRedisPubSubConnection<String, String> subscribeConnection = null;
	private void initConnection() {
		
		String commandTimeoutVal = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getDBProperties().getProperty("db.lettuce.command.timeout"));
		if(commandTimeoutVal != null && !"".equals(commandTimeoutVal)) {
			COMMAND_TIMEOUT = Integer.parseInt(commandTimeoutVal);
		}
		String redisMode = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getDBProperties().getProperty("db.lettuce.redis.mode", REDIS_MODE_STANDALONE));
		String masterId = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getDBProperties().getProperty("db.redis.sentinel.masterid"));
		String passwd = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getDBProperties().getProperty("db.redis.password"));
		String isSSL = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getDBProperties().getProperty("db.redis.isUseSSL", "N"));
		Set<String> pKeys = PropertiesUtil.getDBProperties().stringPropertyNames();
		RedisURI.Builder redisUriBuilder = null;
		for(String key : pKeys) {
			if(key.startsWith("db.lettuce.sentinel.host")) {
				String hostInfo = PropertiesUtil.getDBProperties().getProperty(key);
				String host = hostInfo.split(":")[0];
				int port = Integer.parseInt(hostInfo.split(":")[1]);
				
				if(redisUriBuilder == null) {
					
					if(REDIS_MODE_STANDALONE.equals(redisMode)) {
						// Master 접속방식 사용하고 method 는 sentinel 용으로 같이 사용가능.
						redisUriBuilder = RedisURI.Builder.redis(host, port);
						break;
					}else {
						redisUriBuilder = RedisURI.Builder.sentinel(host, port, masterId);
					}
				}else {
					redisUriBuilder.withSentinel(host, port);
				}
			}
		}// end for
		
		redisUriBuilder.withPassword(passwd);
		if("Y".equals(isSSL)) {
			redisUriBuilder.withSsl(true);
		}
		RedisURI redisUri = redisUriBuilder.build();
		
		String autoReconnect = PropertiesUtil.getDBProperties().getProperty("db.lettuce.auto.reconnect", "true");

				
		sentinelClient = RedisClient.create(redisUri);
		LOGGER.error(">>> Lettuce ("+ redisMode +") Connecting....");
		
		long startTime = System.currentTimeMillis();
		
		sentinelClient.setOptions(ClientOptions.builder()
				.autoReconnect(Boolean.parseBoolean(autoReconnect))
				.pingBeforeActivateConnection(true)
				.build());
		
		connection = sentinelClient.connect();
		publishConnection = sentinelClient.connectPubSub();
		subscribeConnection = sentinelClient.connectPubSub();
		LOGGER.error(">>> Lettuce ("+ redisMode +") Connection created. elapsed time is " + (System.currentTimeMillis() - startTime) + "ms");
	}
	
	@Override
	public void close() {
		try {
			if(connection != null) connection.close();
			if(sentinelClient != null)sentinelClient.shutdown();
		}catch (Exception t) {
			LOGGER.error(t);
		}catch(Throwable t) {
			LOGGER.error(t);
		}
	}
	
	@Override
	public void save(String key, String value) {
		try {
			RedisCommands<String, String> syncCommands = connection.sync();
			syncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			syncCommands.set(key, value);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var8) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var8);
		}
	}

	@Override
	public void saveDicInfo(CoviMap pMap) {
		try {
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
			rMap.put("IsCaching", "Y");
			rMap.put("Description", pMap.get("Description"));
			rMap.put("DataStatus", pMap.get("DataStatus"));
			rMap.put("RegID", pMap.get("RegID"));
			rMap.put("ModID", pMap.get("ModID"));
			rMap.put("RegDate", System.currentTimeMillis());
			rMap.put("ModDate", System.currentTimeMillis());
			rMap.put("ReservedFullWord1", (Object) null);
			rMap.put("ReservedFullWord2", (Object) null);
			rMap.put("ReservedShortWord1", (Object) null);
			rMap.put("ReservedShortWord2", (Object) null);
			redisObj.putAll(rMap);
			String jsonResp = mapperObj.writeValueAsString(redisObj);
			
			RedisAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.set(rMap.get("DIC_Code").toString(), jsonResp);
			this.LOGGER.info(jsonResp);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var10) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var10);
		}

	}

	@Override
	public void saveDicList(List<?> list) {
		RedisAsyncCommands<String, String> asyncCommands = null;
		try {
			asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(false);// Pipelined
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			for (int i = 0; i < list.size(); ++i) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get("DIC_Code") == null) {
					throw new Exception();
				}

				String jsonResp = mapperObj.writeValueAsString(eMap);
				asyncCommands.set(eMap.get("DIC_Code").toString(), jsonResp);
			}
			asyncCommands.flushCommands();
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var10) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var10);
		} finally {
			if(asyncCommands != null)asyncCommands.setAutoFlushCommands(true);
		}

	}

	@Override
	public void saveList(List<?> list, String prefix, String colKey) {
		RedisAsyncCommands<String, String> asyncCommands = null;
		try {
			asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(false);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			for (int i = 0; i < list.size(); ++i) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get(colKey) == null) {
					throw new Exception();
				}

				String jsonResp = mapperObj.writeValueAsString(eMap);
				asyncCommands.set(prefix + eMap.get(colKey).toString(), jsonResp);
			}
			asyncCommands.flushCommands();
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var12) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var12);
		} finally {
			if(asyncCommands != null)asyncCommands.setAutoFlushCommands(true);
		}

	}

	@Override
	public void saveList(List<?> list, String prefix, String delimiter, String col1, String col2) {
		RedisAsyncCommands<String, String> asyncCommands = null;
		try {
			asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(false);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			for (int i = 0; i < list.size(); ++i) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get(col1) == null || eMap.get(col2) == null) {
					throw new Exception();
				}

				String jsonResp = mapperObj.writeValueAsString(eMap);
				asyncCommands.set(prefix + eMap.get(col1).toString() + delimiter + eMap.get(col2).toString(), jsonResp);
			}
			asyncCommands.flushCommands();
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var14) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var14);
		} finally {
			if(asyncCommands != null)asyncCommands.setAutoFlushCommands(true);
		}

	}

	@Override
	public void saveList(List<?> list, String prefix, String delimiter, String col1, String col2, String col3) {
		RedisAsyncCommands<String, String> asyncCommands = null;
		try {
			asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(false);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			for (int i = 0; i < list.size(); ++i) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get(col1) == null || eMap.get(col2) == null) {
					throw new Exception();
				}

				String jsonResp = mapperObj.writeValueAsString(eMap);
				asyncCommands.set(prefix + eMap.get(col1).toString() + delimiter + eMap.get(col2).toString() + delimiter + eMap.get(col3).toString(), jsonResp);
			}
			asyncCommands.flushCommands();
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var14) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var14);
		} finally {
			if(asyncCommands != null)asyncCommands.setAutoFlushCommands(true);
		}

	}
	
	@Override	
	public void remove(String key) {
		try {
			RedisAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			asyncCommands.del(key);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var7) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var7);
		}

	}

	@Override
	public void flushAll() {
		try {
			RedisAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(10000));
			asyncCommands.flushall();
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var6) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var6);
		}

	}

	@Override
	public boolean containsKey(String key) {
		boolean hasKey = false;
		if (this.get(key) != null) {
			hasKey = true;
		}
		return hasKey;
	}

	@Override
	public String get(String key) {
		try {
			RedisAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			RedisFuture<String> var = asyncCommands.get(key);
			String var5 = var.get();
			return var5;
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var8) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var8);
		}

		return null;
	}


	@Override
	public Set<String> keys(String key, String pattern) {
		try {
			RedisAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			List<String> var6 = asyncCommands.keys(pattern).get();
			return new HashSet<String>(var6);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var9) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var9);
		}

		return null;
	}

	@Override
	public void setex(String key, int seconds, String value) {
		try {
			RedisAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			asyncCommands.setex(key, seconds, value);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var9) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var9);
		}

	}

	@Override
	public void saveUserInfo(CoviMap pMap) {
		try {
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
			String jsonResp = mapperObj.writeValueAsString(redisObj);
			
			RedisCommands<String, String> syncCommands = connection.sync();
			syncCommands.set(rMap.get("UR_Code").toString() + rMap.get("UR_ID").toString(), jsonResp);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var10) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var10);
		}

	}

	@Override
	public void hset(String key, String field, String value) {
		try {
			RedisCommands<String, String> syncCommands = connection.sync();
			
			syncCommands.hset(key, field, value);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var9) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var9);
		}

	}

	@Override
	public String hget(String key, String field) {
		try {
			RedisAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			
			String var6 = asyncCommands.hget(key, field).get();
			return var6;
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var9) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var9);
		}

		return null;
	}

	@Override
	public void hmset(String key, Map<String, String> map) {
		try {
			RedisCommands<String, String> syncCommands = connection.sync();
			syncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			
			syncCommands.hmset(key, map);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var8) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var8);
		}

	}

	@Override
	public void setExpireTime(String pKey, int pExpireTime) {
		try {
			RedisAsyncCommands<String, String> asyncCommands = connection.async();
			
			asyncCommands.expire(pKey, pExpireTime);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisLettuceSentinelUtil", e);
		} catch (Exception var8) {
			this.LOGGER.error("RedisLettuceSentinelUtil", var8);
		}

	}

	@Override
	public void removeAll(String pattern) {
		String deleteScriptLUA = "local keys = redis.call('keys', '%s')  for i,k in ipairs(keys) do    local res = redis.call('del', k)  end";
		try {
			RedisAsyncCommands<String, String> asyncCommands = connection.async();
			
			asyncCommands.eval(String.format(deleteScriptLUA, pattern), ScriptOutputType.BOOLEAN, pattern);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisShardsUtil.removeAll", e);
		} catch (Exception var8) {
			this.LOGGER.error("RedisShardsUtil.removeAll", var8);
		}

	}

	// No need JEDIS SHARD On Redis Clustering environment 
	@Override
	public void removeAll(String key, String pattern) {
		removeAll(pattern);
	}

	/**
	 * Subscribe
	 * @param channel
	 * @param listener
	 */
	public void subscribe(String channel, RedisPubSubListener<String, String> listener) {
		try {
			RedisPubSubAsyncCommands<String, String> asyncCommands = subscribeConnection.async();
			
			subscribeConnection.addListener(listener);
			asyncCommands.subscribe(channel);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisShardsUtil.subscribe", e);
		} catch (Exception e) {
			this.LOGGER.error("RedisShardsUtil.subscribe", e);
		}
	}
	
	/**
	 * Publish
	 * @param channel
	 * @param value
	 */
	public void publish(String channel, String value) {
		try {
			RedisPubSubAsyncCommands<String, String> asyncCommands = publishConnection.async();
			
			asyncCommands.publish(channel, value);
		} catch (NullPointerException e) {
			this.LOGGER.error("RedisShardsUtil.publish", e);
		} catch (Exception e) {
			this.LOGGER.error("RedisShardsUtil.publish", e);
		}
	}
	
	@Service
	public static class LettuceShutdownHook implements ApplicationListener<ApplicationEvent> {
		@Override
		public void onApplicationEvent(ApplicationEvent event) {
			if(event instanceof ContextClosedEvent || event instanceof ContextStoppedEvent) {
				RedisShardsUtil.getInstance().close();
			}
			else if(event instanceof ContextStartedEvent || event instanceof ContextRefreshedEvent) {
				RedisShardsUtil.getInstance();
			}
		}
	}
}
