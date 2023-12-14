package egovframework.coviframework.service.impl;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.servlet.ServletContext;

import org.apache.commons.dbcp2.ConnectionFactory;
import org.apache.commons.dbcp2.DriverManagerConnectionFactory;
import org.apache.commons.dbcp2.PoolableConnection;
import org.apache.commons.dbcp2.PoolableConnectionFactory;
import org.apache.commons.dbcp2.PoolingDriver;
import org.apache.commons.pool2.impl.AbandonedConfig;
import org.apache.commons.pool2.impl.GenericObjectPool;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.ThreadContext;
import org.json.simple.parser.ParseException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.ContextStartedEvent;
import org.springframework.context.event.ContextStoppedEvent;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.sec.PBE;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.baseframework.util.json.JSONParser;
import egovframework.coviframework.service.ExtDatabasePoolSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.RedisLettuceSentinelUtil;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import io.lettuce.core.pubsub.RedisPubSubListener;

/**
 * Pooling[DBCP2] manager for External Database Sync.
 * @author hgsong
 */
@Service
public class ExtDatabasePoolSvcImpl extends EgovAbstractServiceImpl implements ExtDatabasePoolSvc {
	private static final Logger LOGGER = LogManager.getLogger(ExtDatabasePoolSvcImpl.class);

	public static final String CHANNELID = "ExtDbPoolEvent";
	public static final String PUBSUB_TYPE_RELOADALL = "RELOADALL";
	public static final String PUBSUB_TYPE_RELOAD = "RELOAD";
	public static final String PUBSUB_TYPE_DEL = "DEL";
	
	final String propEncKey = "ENC(tgb07whx2ZEtr6tcx7kN3a5/3TuBipVP)";
	String poolNamePrefix = "extdb";
	java.util.Map<String, String> poolNameMap = new HashMap<String, String>();
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	protected ServletContext sc;
	
	private RedisLettuceSentinelUtil lettuceUtil;
	private ExtDbPoolRedisPubSubListener listener;
	/**
	 * Execute when application initialized.
	 */
	@PostConstruct
	@Override
	public void init() {
		try {			
			// Pool initialize.
			// get datasource list
			CoviMap params = new CoviMap();
			CoviList list = coviMapperOne.list("framework.datasource.selectDatasource", params);
			CoviList arr = CoviSelectSet.coviSelectJSON(list);
			
			// Pre-Load Driver 
			Class.forName("org.apache.commons.dbcp2.PoolingDriver");
			
			for(int i = 0; arr != null && i < arr.size(); i++) {
				CoviMap info = (CoviMap)arr.get(i);
				initConnectionPool(info);
			}
			
			LOGGER.info(">>>> Success to initialize DBCP Pool.");
			
			RedisShardsUtil instance = RedisShardsUtil.getInstance();
			if(instance instanceof RedisLettuceSentinelUtil && listener == null) {
				lettuceUtil = (RedisLettuceSentinelUtil)instance;
				listener = new ExtDbPoolRedisPubSubListener();
				lettuceUtil.subscribe(ExtDatabasePoolSvcImpl.CHANNELID, listener);
				
				LOGGER.info("DBCP Pool Pub/Sub change listen started.");
			}
		} catch (SQLException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}
	
	/**
	 * Driver load.
	 * @param info
	 */
	private void loadDriver(CoviMap info) {
		try {
			Class.forName(info.optString("DriverClassName"));
		} catch (ClassNotFoundException e) {
			LOGGER.error("", e);
		}
	}
	
	/**
	 * Initialize and register Pool.
	 * @param info
	 * @throws SQLException
	 * @throws ClassNotFoundException
	 */
	private void initConnectionPool(CoviMap info) throws SQLException, ClassNotFoundException {
		CoviList bindTarget = info.optJSONArray("BindTarget");
		// 대상 Context 가 아닐 경우 Skip.
		// Target 지정이 되어있지 않은 경우 /covicore 는 Default 바인딩 함.
		if(bindTarget == null || bindTarget.size() == 0) {
			if(bindTarget == null) bindTarget = new CoviList();
			bindTarget.add("/covicore");
		}
		if(sc != null) {
			String contextPath = sc.getContextPath();
			if(!bindTarget.contains(contextPath)) {
				return;
			}
		}
		
		loadDriver(info);
		
		
		String connectionUri = info.optString("Url");
		String userName = info.optString("UserName");
		String encPassword = info.optString("Password");
		String userPassword = PBE.decode(encPassword, PropertiesUtil.getDecryptedProperty(propEncKey));
		String validationQuery = info.optString("ValidationQuery", "select 1");
		String poolName = info.optString("ConnectionPoolName");
		String datasourceSeq = info.optString("DatasourceSeq");
		
		int maxTotal = info.optInt("MaxTotal", GenericObjectPoolConfig.DEFAULT_MAX_TOTAL);
		int maxIdle = info.optInt("MaxIdle", GenericObjectPoolConfig.DEFAULT_MAX_IDLE);
		int minIdle = info.optInt("MinIdle", GenericObjectPoolConfig.DEFAULT_MIN_IDLE);
		long maxWaitMillis = info.optLong("MaxWaitMillis", GenericObjectPoolConfig.DEFAULT_MAX_WAIT_MILLIS);
		boolean testOnBorrow = info.optBoolean("TestOnBorrow", GenericObjectPoolConfig.DEFAULT_TEST_ON_BORROW);
		boolean testOnReturn = info.optBoolean("TestOnReturn", GenericObjectPoolConfig.DEFAULT_TEST_ON_RETURN);
		boolean testWhileIdle = info.optBoolean("TestWhileIdle", GenericObjectPoolConfig.DEFAULT_TEST_WHILE_IDLE);
		long timeBetweenEvictionRunsMillis = GenericObjectPoolConfig.DEFAULT_TIME_BETWEEN_EVICTION_RUNS_MILLIS;
		if(info.containsKey("TimeBetweenEvictionRunsMillis")) {
			timeBetweenEvictionRunsMillis = info.optLong("TimeBetweenEvictionRunsMillis", GenericObjectPoolConfig.DEFAULT_TIME_BETWEEN_EVICTION_RUNS_MILLIS);
		}
		
		ConnectionFactory connectionFactory = new DriverManagerConnectionFactory(connectionUri, userName, userPassword);
		PoolableConnectionFactory poolableConnectionFactory = new PoolableConnectionFactory(connectionFactory, null);
		
		// Pool configuration
		GenericObjectPoolConfig<PoolableConnection> poolConfig = new GenericObjectPoolConfig<PoolableConnection>();
		poolConfig.setMaxTotal(maxTotal);
		if(maxIdle > -1) {
			poolConfig.setMaxIdle(maxIdle);
		}
		if(minIdle > -1) {
			poolConfig.setMinIdle(minIdle);
		}
		poolConfig.setMaxWaitMillis(maxWaitMillis);
		poolConfig.setTestOnBorrow(testOnBorrow);
		poolConfig.setTestOnReturn(testOnReturn);
		poolConfig.setTestWhileIdle(testWhileIdle);
		poolConfig.setTimeBetweenEvictionRunsMillis(timeBetweenEvictionRunsMillis);
		poolConfig.setJmxEnabled(GenericObjectPoolConfig.DEFAULT_JMX_ENABLE);
		if(sc != null) {
			poolConfig.setJmxNamePrefix("ExtDataSource["+sc.getContextPath()+"][" + poolName + "]");
		}
		
		try {
			if(poolNameMap.containsKey(datasourceSeq)) {
				release(datasourceSeq);
			}
		} catch (SQLException e) {
			LOGGER.info(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.info(e.getLocalizedMessage(), e);
		}
		
		// Pool create
		@SuppressWarnings("resource")
		GenericObjectPool<PoolableConnection> connectionPool = new GenericObjectPool<PoolableConnection>(poolableConnectionFactory, poolConfig);
		// Setting AbandonedConfig
		AbandonedConfig abandonedConfig = new AbandonedConfig();
		
		boolean removeAbandonedOnMaintenance = false;
		if(info.containsKey("RemoveAbandonedOnMaintenance")) {
			removeAbandonedOnMaintenance = info.optBoolean("RemoveAbandonedOnMaintenance", false);
		}
		int removeAbandonedTimeout = 60;
		if(info.containsKey("RemoveAbandonedTimeout")) {
			removeAbandonedTimeout = info.optInt("RemoveAbandonedTimeout", 60);
		}
		
		abandonedConfig.setRemoveAbandonedOnMaintenance(removeAbandonedOnMaintenance);
		abandonedConfig.setRemoveAbandonedTimeout(removeAbandonedTimeout);
		connectionPool.setAbandonedConfig(abandonedConfig);
		
		poolableConnectionFactory.setValidationQuery(validationQuery);
		poolableConnectionFactory.setPool(connectionPool);
		
		// Class.forName("org.apache.commons.dbcp2.PoolingDriver");
		poolName = poolNamePrefix + poolName;
		poolNameMap.put(datasourceSeq, poolName);
		
		PoolingDriver driver = (PoolingDriver)DriverManager.getDriver("jdbc:apache:commons:dbcp:");
		driver.registerPool(poolName, connectionPool);
		
		LOGGER.info("Connection pool["+ poolName +"][" + connectionUri + "] is registered.");
	}
	
	
	/**
	 * Get Connection object from pool.
	 * @param poolName
	 */
	@Override
	public Connection getConnection(String poolName) {
		String jdbcUrl = "jdbc:apache:commons:dbcp:"+poolNamePrefix + poolName;
		try {
			return DriverManager.getConnection(jdbcUrl);
		} catch (SQLException e) {
			LOGGER.error("", e);
			return null;
		}
	}

	@Override
	public String getEncryptedPasswd(String plain) {
		return PBE.encode(plain, PropertiesUtil.getDecryptedProperty(propEncKey));
	}
	
	@Override
	public String getDecryptedPasswd(String enc) {
		return PBE.decode(enc, PropertiesUtil.getDecryptedProperty(propEncKey));
	}

	@Override
	public void close(AutoCloseable... resources) throws Exception {
		for(AutoCloseable res : resources) {
			if(res != null) try { res.close(); } catch (NullPointerException e) { LOGGER.error("ExtDatabasePoolSvcImpl.close", e); }catch (Exception e) { LOGGER.error("ExtDatabasePoolSvcImpl.close", e); }
		}
	}

	@Override
	public boolean release(String... datasourceSeqs) throws Exception {
		for(String seq : datasourceSeqs) {
			PoolingDriver driver = (PoolingDriver)DriverManager.getDriver("jdbc:apache:commons:dbcp:");
			String name = poolNameMap.get(seq);
			if(!StringUtil.isEmpty(name)) {
				driver.closePool(name);
				
				poolNameMap.remove(seq);
				
				if(lettuceUtil != null) {
					String byRedisEvent = ThreadContext.get("ByRedisEvent");
					if(byRedisEvent == null) {
						Map<String, String> param = new HashMap<String, String>();
						param.put("Action", ExtDatabasePoolSvcImpl.PUBSUB_TYPE_DEL);
						param.put("DatasourceSeq", seq);
						param.put("Publisher", sc.getContextPath());
						String message = new CoviMap(param).toJSONString();
						lettuceUtil.publish(ExtDatabasePoolSvcImpl.CHANNELID, message);
					}
				}
			}
		}
		return true;
	}

	/*********************************************
	 * Web Control. 
	 ********************************************/
	
	@Override
	public CoviMap selectDatasourceList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("framework.datasource.selectDatasourceCnt", params);
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("framework.datasource.selectDatasourceList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public CoviMap selectDatasource(CoviMap params) throws Exception {
		return coviMapperOne.select("framework.datasource.selectDatasource", params);
	}

	@Override
	public int insertDatasource(CoviMap params) throws Exception {
		params.put("newPwd", getEncryptedPasswd(params.getString("Password")));
		return coviMapperOne.insert("framework.datasource.insertDatasource", params);
	}

	@Override
	public int updateDatasource(CoviMap params) throws Exception {
		
		String prevPasswd = params.getString("PrevPassword");
		String passwd = params.getString("Password");
		if(passwd != null && StringUtil.isNotEmpty(passwd) && !passwd.equals(prevPasswd)) {
			params.put("newPwd", getEncryptedPasswd(passwd));
			params.put("chgPwd", "Y");
		}
		
		return coviMapperOne.update("framework.datasource.updateDatasource", params);
	}

	@Override
	public int deleteDatasource(CoviMap params) throws Exception {
		return coviMapperOne.delete("framework.datasource.deleteDatasource", params);
	}
	
	@Override
	public CoviList getDatasourceSelectData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("framework.datasource.selectDatasourceSelectData", params);
		return CoviSelectSet.coviSelectJSON(list);
	}
	
	@Override
	public void reload(String datasourceSeq) {
		if(datasourceSeq != null && !"".equals(datasourceSeq)) {
			try {
				// re-register (or new) pool specified name.
				CoviMap params = new CoviMap();
				params.put("datasourceSeq", datasourceSeq);
				CoviMap map = coviMapperOne.select("framework.datasource.selectDatasource", params);
				CoviMap info = CoviSelectSet.coviSelectMapJSON(map);
				
				initConnectionPool(info);
				if(lettuceUtil != null) {
					String byRedisEvent = ThreadContext.get("ByRedisEvent");
					if(byRedisEvent == null) {
						Map<String, String> param = new HashMap<String, String>();
						param.put("Action", ExtDatabasePoolSvcImpl.PUBSUB_TYPE_RELOAD);
						param.put("DatasourceSeq", datasourceSeq);
						param.put("Publisher", sc.getContextPath());
						String message = new CoviMap(param).toJSONString();
						lettuceUtil.publish(ExtDatabasePoolSvcImpl.CHANNELID, message);
					}
				}
			} catch (DataAccessException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (ClassNotFoundException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (SQLException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			}
		}else {
			// re-register (or new) all pools.
			init();
			if(lettuceUtil != null) {
				String byRedisEvent = ThreadContext.get("ByRedisEvent");
				if(byRedisEvent == null) {
					Map<String, String> param = new HashMap<String, String>();
					param.put("Action", ExtDatabasePoolSvcImpl.PUBSUB_TYPE_RELOADALL);
					param.put("Publisher", sc.getContextPath());
					String message = new CoviMap(param).toJSONString();
					lettuceUtil.publish(ExtDatabasePoolSvcImpl.CHANNELID, message);
				}
			}
		}
	}
	
	@Override
	public java.util.Map<String, String> getPoolNameMap() {
		return poolNameMap;
	}
	
	private class ExtDbPoolRedisPubSubListener implements RedisPubSubListener<String, String> {
		//ExtDatabasePoolSvc extDatabasePoolSvc = StaticContextAccessor.getBean(ExtDatabasePoolSvc.class);
		
		@Override
		public void message(String channel, String message) {
			try {
				if(!ExtDatabasePoolSvcImpl.CHANNELID.equals(channel)) {
					return;
				}
				
				CoviMap jo = (CoviMap)new JSONParser().parse(message);
				String publisher = (String)jo.get("Publisher");
				if(publisher != null && publisher.equals(ExtDatabasePoolSvcImpl.this.sc.getContextPath())) {
					LOGGER.debug("Publisher is self. skip operation.");
					return;
				}
				LOGGER.info("ExtDbPoolRedisPubSubListener cache Message arrived. " + message);
				
				ThreadContext.put("ByRedisEvent", Boolean.toString(true));
				String action = jo.optString("Action");
				// Reload All pools.
				if(message != null && ExtDatabasePoolSvcImpl.PUBSUB_TYPE_RELOADALL.equals(action)) {
					ExtDatabasePoolSvcImpl.this.reload(null);
				}
				// Reload Pool
				else if(message != null && ExtDatabasePoolSvcImpl.PUBSUB_TYPE_RELOAD.equals(action)) {
					String datasourceSeq = (String)jo.get("DatasourceSeq");
					ExtDatabasePoolSvcImpl.this.reload(datasourceSeq);
				}
				// Delete Pool (Release) 
				else if(message != null && ExtDatabasePoolSvcImpl.PUBSUB_TYPE_DEL.equals(action)) {
					String datasourceSeq = (String)jo.get("DatasourceSeq");
					ExtDatabasePoolSvcImpl.this.release(datasourceSeq);
				}
			} catch (ParseException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			}
		}

		@Override
		public void message(String pattern, String channel, String message) {
		}

		@Override
		public void subscribed(String channel, long count) {
		}

		@Override
		public void psubscribed(String pattern, long count) {
		}

		@Override
		public void unsubscribed(String channel, long count) {
		}

		@Override
		public void punsubscribed(String pattern, long count) {
		}
	}
	
	@Service
	public static class ContextListener implements ApplicationListener<ApplicationEvent> {
		@Autowired
		private ExtDatabasePoolSvc  extDatabasePoolSvc;
		
		@Override
		public void onApplicationEvent(ApplicationEvent event) {
			if(event instanceof ContextClosedEvent || event instanceof ContextStoppedEvent) {
				PoolingDriver driver;
				try {
					java.util.Map<String, String> poolNameMap = extDatabasePoolSvc.getPoolNameMap();
					
					driver = (PoolingDriver)DriverManager.getDriver("jdbc:apache:commons:dbcp:");
					for(Map.Entry<String, String> entry : poolNameMap.entrySet()) {
						String poolName = entry.getValue();
						if(!StringUtil.isEmpty(poolName)) {
							driver.closePool(poolName);
						}
					}
					poolNameMap.clear();
					poolNameMap = null;
				} catch (SQLException e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
			else if(event instanceof ContextStartedEvent || event instanceof ContextRefreshedEvent) {
				//getInstance(true);
			}
		}
	}
}
