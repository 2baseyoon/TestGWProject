package egovframework.coviframework.util;

import java.time.Duration;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.codehaus.jackson.map.ObjectMapper;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import io.lettuce.core.ReadFrom;
import io.lettuce.core.RedisFuture;
import io.lettuce.core.RedisURI;
import io.lettuce.core.ScriptOutputType;
import io.lettuce.core.cluster.ClusterClientOptions;
import io.lettuce.core.cluster.ClusterTopologyRefreshOptions;
import io.lettuce.core.cluster.RedisClusterClient;
import io.lettuce.core.cluster.api.StatefulRedisClusterConnection;
import io.lettuce.core.cluster.api.async.RedisAdvancedClusterAsyncCommands;
import io.lettuce.core.cluster.api.sync.RedisAdvancedClusterCommands;


public class RedisLettuceClusterUtil extends RedisShardsUtil {
	private Logger LOGGER;
	private int COMMAND_TIMEOUT = 2500;
	
	private RedisLettuceClusterUtil() {
		this.LOGGER = LogManager.getLogger(RedisLettuceClusterUtil.class);
		this.initConnection();
	}

	// SingleTon
	private volatile static RedisLettuceClusterUtil uniqueInstance;
	public static RedisLettuceClusterUtil getInstance() {
	      if(uniqueInstance == null) {
	          synchronized(RedisLettuceClusterUtil.class) {
	             if(uniqueInstance == null) {
	                uniqueInstance = new RedisLettuceClusterUtil(); 
	             }
	          }
	       }
	       return uniqueInstance;
	}
	
	RedisClusterClient clusterClient = null;
	StatefulRedisClusterConnection<String, String> connection = null;
	private void initConnection() {
		String commandTimeoutVal = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getDBProperties().getProperty("db.lettuce.command.timeout"));
		if(commandTimeoutVal != null && !"".equals(commandTimeoutVal)) {
			COMMAND_TIMEOUT = Integer.parseInt(commandTimeoutVal);
		}
		
		String passwd = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getDBProperties().getProperty("db.redis.password"));
		List<RedisURI> redisURIs = new ArrayList<RedisURI>();
		Set<String> pKeys = PropertiesUtil.getDBProperties().stringPropertyNames();
		for(String key : pKeys) {
			if(key.startsWith("db.lettuce.cluster.host")) {
				String hostInfo = PropertiesUtil.getDBProperties().getProperty(key);
				String host = hostInfo.split(":")[0];
				String port = hostInfo.split(":")[1];
				RedisURI redisUri = RedisURI.Builder.redis(host).withPassword(passwd).withPort(Integer.parseInt(port)).build();
				redisURIs.add(redisUri);
			}
		}
		String readFromReplica = PropertiesUtil.getDBProperties().getProperty("db.lettuce.read.from.replica", "true");
		String autoReconnect = PropertiesUtil.getDBProperties().getProperty("db.lettuce.auto.reconnect", "true");

				
		clusterClient = RedisClusterClient.create(redisURIs);
		LOGGER.error(">>> Lettuce Cluster Connecting....");
		
		long startTime = System.currentTimeMillis();
		ClusterTopologyRefreshOptions topologyRefreshOptions = ClusterTopologyRefreshOptions.builder()	
				.enableAllAdaptiveRefreshTriggers()
				.build();
		
		clusterClient.setOptions(ClusterClientOptions.builder()
				.topologyRefreshOptions(topologyRefreshOptions)
				.autoReconnect(Boolean.parseBoolean(autoReconnect))
				.pingBeforeActivateConnection(true)
				.build());
		
		connection = clusterClient.connect();
		LOGGER.error(">>> Lettuce Cluster Connection created. elapsed time is " + (System.currentTimeMillis() - startTime) + "ms");
		
		// Write on Master , Read from Slave.
		if(Boolean.parseBoolean(readFromReplica)) {
			connection.setReadFrom(ReadFrom.REPLICA_PREFERRED);
		}
	}
	
	@Override
	public void close() {
		try {
			if(connection != null) connection.close();
			if(clusterClient != null)clusterClient.shutdown();
		} catch(Exception e){
			LOGGER.error(e);
		}catch(Throwable t) {
			LOGGER.error(t);
		}
	}
	
	@Override
	public void save(String key, String value) {
		try {
			RedisAdvancedClusterCommands<String, String> syncCommands = connection.sync();
			syncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			syncCommands.set(key, value);
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var8) {
			this.LOGGER.error("RedisLettuceUtil", var8);
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
			ObjectMapper mapperObj = new ObjectMapper();
			String jsonResp = mapperObj.writeValueAsString(redisObj);
			
			RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			asyncCommands.set(rMap.get("DIC_Code").toString(), jsonResp);
			this.LOGGER.info(jsonResp);
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var10) {
			this.LOGGER.error("RedisLettuceUtil", var10);
		}

	}

	@Override
	public void saveDicList(List<?> list) {
		RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = null;
		try {
			asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(false);// Pipelined
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			for (int i = 0; i < list.size(); ++i) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get("DIC_Code") == null) {
					throw new Exception();
				}

				ObjectMapper mapperObj = new ObjectMapper();
				String jsonResp = mapperObj.writeValueAsString(eMap);
				asyncCommands.set(eMap.get("DIC_Code").toString(), jsonResp);
			}
			asyncCommands.flushCommands();
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var10) {
			this.LOGGER.error("RedisLettuceUtil", var10);
		} finally {
			if(asyncCommands != null)asyncCommands.setAutoFlushCommands(true);
		}

	}

	@Override
	public void saveList(List<?> list, String prefix, String colKey) {
		RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = null;
		try {
			asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(false);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			for (int i = 0; i < list.size(); ++i) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get(colKey) == null) {
					throw new Exception();
				}

				ObjectMapper mapperObj = new ObjectMapper();
				String jsonResp = mapperObj.writeValueAsString(eMap);
				asyncCommands.set(prefix + eMap.get(colKey).toString(), jsonResp);
			}
			asyncCommands.flushCommands();
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var12) {
			this.LOGGER.error("RedisLettuceUtil", var12);
		} finally {
			if(asyncCommands != null)asyncCommands.setAutoFlushCommands(true);
		}

	}

	@Override
	public void saveList(List<?> list, String prefix, String delimiter, String col1, String col2) {
		RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = null;
		try {
			asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(false);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			for (int i = 0; i < list.size(); ++i) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get(col1) == null || eMap.get(col2) == null) {
					throw new Exception();
				}

				ObjectMapper mapperObj = new ObjectMapper();
				String jsonResp = mapperObj.writeValueAsString(eMap);
				asyncCommands.set(prefix + eMap.get(col1).toString() + delimiter + eMap.get(col2).toString(), jsonResp);
			}
			asyncCommands.flushCommands();
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var14) {
			this.LOGGER.error("RedisLettuceUtil", var14);
		} finally {
			if(asyncCommands != null)asyncCommands.setAutoFlushCommands(true);
		}

	}

	@Override
	public void saveList(List<?> list, String prefix, String delimiter, String col1, String col2, String col3) {
		RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = null;
		try {
			asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(false);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			for (int i = 0; i < list.size(); ++i) {
				CoviMap eMap = (CoviMap) list.get(i);
				if (eMap.get(col1) == null || eMap.get(col2) == null) {
					throw new Exception();
				}

				ObjectMapper mapperObj = new ObjectMapper();
				String jsonResp = mapperObj.writeValueAsString(eMap);
				asyncCommands.set(prefix + eMap.get(col1).toString() + delimiter + eMap.get(col2).toString() + delimiter + eMap.get(col3).toString(), jsonResp);
			}
			asyncCommands.flushCommands();
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var14) {
			this.LOGGER.error("RedisLettuceUtil", var14);
		} finally {
			if(asyncCommands != null)asyncCommands.setAutoFlushCommands(true);
		}

	}
	@Override	
	public void remove(String key) {
		try {
			RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			asyncCommands.del(key);
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var7) {
			this.LOGGER.error("RedisLettuceUtil", var7);
		}

	}

	@Override
	public void flushAll() {
		try {
			RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(10000));
			asyncCommands.flushall();
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var6) {
			this.LOGGER.error("RedisLettuceUtil", var6);
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
			RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			RedisFuture<String> var = asyncCommands.get(key);
			String var5 = var.get();
			return var5;
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var8) {
			this.LOGGER.error("RedisLettuceUtil", var8);
		}

		return null;
	}


	@Override
	public Set<String> keys(String key, String pattern) {
		try {
			RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			List<String> var6 = asyncCommands.keys(pattern).get();
			return new HashSet<String>(var6);
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var9) {
			this.LOGGER.error("RedisLettuceUtil", var9);
		}

		return null;
	}

	@Override
	public void setex(String key, int seconds, String value) {
		try {
			RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			asyncCommands.setex(key, seconds, value);
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var9) {
			this.LOGGER.error("RedisLettuceUtil", var9);
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
			ObjectMapper mapperObj = new ObjectMapper();
			String jsonResp = mapperObj.writeValueAsString(redisObj);
			
			RedisAdvancedClusterCommands<String, String> syncCommands = connection.sync();
			syncCommands.set(rMap.get("UR_Code").toString() + rMap.get("UR_ID").toString(), jsonResp);
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var10) {
			this.LOGGER.error("RedisLettuceUtil", var10);
		}

	}

	@Override
	public void hset(String key, String field, String value) {
		try {
			RedisAdvancedClusterCommands<String, String> syncCommands = connection.sync();
			syncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			
			syncCommands.hset(key, field, value);
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var9) {
			this.LOGGER.error("RedisLettuceUtil", var9);
		}

	}

	@Override
	public String hget(String key, String field) {
		try {
			RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			
			String var6 = asyncCommands.hget(key, field).get();
			return var6;
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var9) {
			this.LOGGER.error("RedisLettuceUtil", var9);
		}

		return null;
	}

	@Override
	public void hmset(String key, Map<String, String> map) {
		try {
			RedisAdvancedClusterCommands<String, String> syncCommands = connection.sync();
			syncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			
			syncCommands.hmset(key, map);
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var8) {
			this.LOGGER.error("RedisLettuceUtil", var8);
		}

	}

	@Override
	public void setExpireTime(String pKey, int pExpireTime) {
		try {
			RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			
			asyncCommands.expire(pKey, pExpireTime);
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var8) {
			this.LOGGER.error("RedisLettuceUtil", var8);
		}

	}

	@Override
	public void removeAll(String pattern) {
		String deleteScriptLUA = "local keys = redis.call('keys', '%s')  for i,k in ipairs(keys) do    local res = redis.call('del', k)  end";
		try {
			RedisAdvancedClusterAsyncCommands<String, String> asyncCommands = connection.async();
			asyncCommands.setAutoFlushCommands(true);
			asyncCommands.setTimeout(Duration.ofMillis(COMMAND_TIMEOUT));
			
			asyncCommands.eval(String.format(deleteScriptLUA, pattern), ScriptOutputType.BOOLEAN, pattern);
		} catch(NullPointerException e){	
			this.LOGGER.error("RedisLettuceUtil", e);
		} catch (Exception var8) {
			this.LOGGER.error("RedisShardsUtil.removeAll", var8);
		}

	}

	// No need JEDIS SHARD On Redis Clustering environment 
	@Override
	public void removeAll(String key, String pattern) {
		removeAll(pattern);
	}

	public static class LettuceShutdownHook implements ServletContextListener {

		@Override
		public void contextDestroyed(ServletContextEvent arg0) {
			RedisShardsUtil.getInstance().close();
		}

		@Override
		public void contextInitialized(ServletContextEvent arg0) {
		}
	}
}
