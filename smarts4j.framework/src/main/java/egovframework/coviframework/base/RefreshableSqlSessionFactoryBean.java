package egovframework.coviframework.base;

import static org.springframework.util.Assert.notNull;
import static org.springframework.util.Assert.state;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

import org.apache.ibatis.builder.xml.XMLConfigBuilder;
import org.apache.ibatis.builder.xml.XMLMapperBuilder;
import org.apache.ibatis.executor.ErrorContext;
import org.apache.ibatis.mapping.Environment;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.apache.ibatis.transaction.TransactionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.transaction.SpringManagedTransactionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.core.NestedIOException;
import org.springframework.core.io.Resource;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import javax.sql.DataSource;

import egovframework.baseframework.util.PropertiesUtil;

/**
 * mybatis mapper 자동 감지 후 자동으로 서버 재시작이 필요 없이 반영
 */
public class RefreshableSqlSessionFactoryBean extends SqlSessionFactoryBean implements DisposableBean {
    private static final Logger log = LoggerFactory.getLogger(RefreshableSqlSessionFactoryBean.class);
    
    private SqlSessionFactory proxy;
    private int interval = 500;
    private Timer timer;
    private TimerTask task;
    private Resource[] mapperLocations;
    /**
     * 파일 감시 쓰레드가 실행중인지 여부.
     */
    private boolean running = false;
    private final ReentrantReadWriteLock rwl = new ReentrantReadWriteLock();
    private final Lock r = rwl.readLock();
    private final Lock w = rwl.writeLock();

    private Resource configLocation;
    Configuration configuration;
    private Properties configurationProperties;
    private DataSource dataSource;

    private TransactionFactory transactionFactory;
    private SqlSessionFactory sqlSessionFactory;
    private SqlSessionFactoryBuilder sqlSessionFactoryBuilder = new SqlSessionFactoryBuilder();
    //EnvironmentAware requires spring 3.1
    private String environment = SqlSessionFactoryBean.class.getSimpleName();
    
    @Override
    public void setConfiguration(Configuration configuration) {
    	super.setConfiguration(configuration);
        this.configuration = configuration;
    }
    @Override
    public void setConfigLocation(Resource configLocation) {
    	super.setConfigLocation(configLocation);
    	this.configLocation = configLocation;
    }
    @Override
    public void setConfigurationProperties(Properties sqlSessionFactoryProperties) {
    	super.setConfigurationProperties(sqlSessionFactoryProperties);
    	this.configurationProperties = sqlSessionFactoryProperties;
    }
    @Override
	public void setDataSource(DataSource dataSource) {
		super.setDataSource(dataSource);
		this.dataSource = dataSource;
	}
	@Override
	public void setTransactionFactory(TransactionFactory transactionFactory) {
		super.setTransactionFactory(transactionFactory);
		this.transactionFactory = transactionFactory;
	}
	@Override
	public void setEnvironment(String environment) {
		super.setEnvironment(environment);
		this.environment = environment;
	}
	@Override
	public void setSqlSessionFactoryBuilder(SqlSessionFactoryBuilder sqlSessionFactoryBuilder) {
		super.setSqlSessionFactoryBuilder(sqlSessionFactoryBuilder);
		this.sqlSessionFactoryBuilder = sqlSessionFactoryBuilder;
	}
	@Override
	protected SqlSessionFactory buildSqlSessionFactory() throws IOException {
		SqlSessionFactory factory =  super.buildSqlSessionFactory();
		
		// set Configuration for re-use
		setConfiguration(factory.getConfiguration());
		setConfigLocation(null);
		
		return factory;
	}
	public void setMapperLocations(Resource[] mapperLocations) {
        super.setMapperLocations(mapperLocations);
        this.mapperLocations = new Resource[mapperLocations.length];
        for (int i = 0; i < mapperLocations.length; ++i){
        	 this.mapperLocations[i] = (Resource)mapperLocations[i];
    	}
    }

    public void setInterval(int interval) {
        this.interval = interval;
    }

    /**
     * @throws Exception
     */
    public void refresh(List<Resource> modifiedResources) throws Exception {
        if (log.isInfoEnabled()) {
            log.info("refreshing sqlMapClient.");
        }
        w.lock();
        try {
            //super.afterPropertiesSet();
        	//afterPropertiesSet 호출시 sqlmap/{vendor]/ 하위 모든 xml 을 reload 하므로 수정된 xml 만 reload 하도록 변경.
        	
        	//SqlSessionFactoryBean.java 
            notNull(dataSource, "Property 'dataSource' is required");
            notNull(sqlSessionFactoryBuilder, "Property 'sqlSessionFactoryBuilder' is required");
            state((configuration == null && configLocation == null) || !(configuration != null && configLocation != null),
                      "Property 'configuration' and 'configLocation' can not specified with together");
            
        	Configuration targetConfiguration = null;
        	XMLConfigBuilder xmlConfigBuilder = null;
        	if (this.configuration != null) {
        		// by cached configuration.
        		targetConfiguration = this.configuration;
        		if (targetConfiguration.getVariables() == null) {
        			targetConfiguration.setVariables(this.configurationProperties);
        		}
        	} else if (this.configLocation != null) {
        		xmlConfigBuilder = new XMLConfigBuilder(this.configLocation.getInputStream(), null, this.configurationProperties);
        		targetConfiguration = xmlConfigBuilder.getConfiguration();
        	}

        	if (xmlConfigBuilder != null) {
        		try {
        			xmlConfigBuilder.parse();
        			log.debug("Parsed configuration file: '" + this.configLocation + "'");
        		} catch(NullPointerException e){	
        			throw new NestedIOException("Failed to parse config resource: " + this.configLocation, e);
        		} catch (Exception ex) {
        			throw new NestedIOException("Failed to parse config resource: " + this.configLocation, ex);
        		} finally {
        			ErrorContext.instance().reset();
        		}
        	}
        	
        	if(targetConfiguration == null) {
        		throw new Exception("Configuration is null.");
        	}
        	targetConfiguration.setEnvironment(new Environment(this.environment,
        			this.transactionFactory == null ? new SpringManagedTransactionFactory() : this.transactionFactory,
        					this.dataSource));

        	for (Resource mapperLocation : modifiedResources) {
        		if (mapperLocation == null) {
        			continue;
        		}

        		try (InputStream fis = mapperLocation.getInputStream();){
        			String resource = mapperLocation.toString();//mapperLocation.getFile().getAbsolutePath();
        			
    				//Clean up the original resources, update to your own StrictMap for convenience, and reload incrementally
    				String[] mapFieldNames = new String[]{
    					"mappedStatements", "caches",
    					"resultMaps", "parameterMaps",
    					"keyGenerators", "sqlFragments"
    				};
    				
    				for (String fieldName: mapFieldNames){
    					Field field = targetConfiguration.getClass().getDeclaredField(fieldName);
    					field.setAccessible(true);
    					Map<String, Object> map = ((Map<String, Object>)field.get(targetConfiguration));
    					// Configuration$StrictMap 은 update 를 막아놨으므로 HashMap 으로 바꿔치기 해놓음.
						Map<String, Object> newMap = new HashMap<String, Object>();
						
						for(Map.Entry<String, Object> entry : map.entrySet()) {
							try {
								newMap.put(entry.getKey(), entry.getValue());
							}catch(IllegalArgumentException ex){
								log.debug(ex.getLocalizedMessage(), ex);
							}
						}
//						for (Object key: map.keySet()){
//							try {
//								newMap.put(key, map.get(key));
//							}catch(IllegalArgumentException ex){
//								;;
//							}
//						}
						// Change Map Object
						field.set(configuration, newMap);
    				}
    				
    				//Clean up the loaded resource identifier so that it can be reloaded.
    				Field loadedResourcesField = targetConfiguration.getClass().getDeclaredField("loadedResources");
    				loadedResourcesField.setAccessible(true);
    				Set loadedResourcesSet = ((Set)loadedResourcesField.get(targetConfiguration));
    				loadedResourcesSet.remove(resource);
    				
        			// XML re-parsing 요청하여 statements 등 cache 다시 하도록 한다. (해당 xml 내용만)
        			XMLMapperBuilder xmlMapperBuilder = new XMLMapperBuilder(mapperLocation.getInputStream(),
        					targetConfiguration, mapperLocation.toString(), targetConfiguration.getSqlFragments());
        			xmlMapperBuilder.parse();
        		} catch(NullPointerException e){	
        			throw new NestedIOException("Failed to parse mapping resource: '" + mapperLocation + "'", e);
        		} catch (Exception e) {
        			throw new NestedIOException("Failed to parse mapping resource: '" + mapperLocation + "'", e);
        		} finally {
        			ErrorContext.instance().reset();
        		}
        		log.info("Parsed mapper file: '" + mapperLocation + "'");
        	}
        } finally {
            w.unlock();
        }
    }

    /**
     * 싱글톤 멤버로 SqlMapClient 원본 대신 프록시로 설정하도록 오버라이드.
     */
    public void afterPropertiesSet() throws Exception {
        super.afterPropertiesSet();
        setRefreshable();
    }

    private void setRefreshable() {
        proxy = (SqlSessionFactory) Proxy.newProxyInstance(SqlSessionFactory.class.getClassLoader(), new Class[] { SqlSessionFactory.class }, new InvocationHandler() {
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                // log.debug("method.getName() : " + method.getName());
                return method.invoke(getParentObject(), args);
            }
        });
        
        String useXmlRefresh = PropertiesUtil.getDBProperties().getProperty("db.session.factory.xml.reload", "N");
        if(!"Y".equals(useXmlRefresh)) {
        	return;
        }
        
        task = new TimerTask() {
            private Map<Resource, Long> map = new HashMap<Resource, Long>();
            List<Resource> modifiedResources = new ArrayList<Resource>();
            
            public void run() {
                if (isModified()) {
                    try {
                        refresh(modifiedResources);
            		} catch(NullPointerException e){	
                        log.error("caught exception", e);
                    } catch (Exception e) {
                        log.error("caught exception", e);
                    }
                }
            }

            private boolean isModified() {
                boolean retVal = false;
                if (mapperLocations != null) {
                	modifiedResources.clear();
                    for (int i = 0; i < mapperLocations.length; i++) {
                        Resource mappingLocation = mapperLocations[i];
                        retVal |= findModifiedResource(mappingLocation);
                    }
                }
                return retVal;
            }

            private boolean findModifiedResource(Resource resource) {
                boolean retVal = false;
                try {
                    long modified = resource.lastModified();
                    if (map.containsKey(resource)) {
                        long lastModified = ((Long) map.get(resource)).longValue();
                        if (lastModified != modified) {
                            map.put(resource, Long.valueOf(modified));
                            modifiedResources.add(resource);
                            retVal = true;
                        }
                    } else {
                        map.put(resource, Long.valueOf(modified));
                    }
                } catch (IOException e) {
                    log.error("caught exception", e);
                }
                if (retVal) {
                    if (log.isInfoEnabled()) {
                        log.info("modified files : " + modifiedResources);
                    }
                }
                return retVal;
            }
        };
        timer = new Timer(true);
        resetInterval();
    }

    private Object getParentObject() throws Exception {
        r.lock();
        try {
            return super.getObject();
        } finally {
            r.unlock();
        }
    }

    public SqlSessionFactory getObject() {
        return this.proxy;
    }

    public Class<? extends SqlSessionFactory> getObjectType() {
        return (this.proxy != null ? this.proxy.getClass() : SqlSessionFactory.class);
    }

    public boolean isSingleton() {
        return true;
    }

    public void setCheckInterval(int ms) {
        interval = ms;
        if (timer != null) {
            resetInterval();
        }
    }

    private void resetInterval() {
        if (running) {
            timer.cancel();
            running = false;
        }
        if (interval > 0) {
            timer.schedule(task, 0, interval);
            running = true;
        }
    }

    public void destroy() throws Exception {
        timer.cancel();
    }
}
