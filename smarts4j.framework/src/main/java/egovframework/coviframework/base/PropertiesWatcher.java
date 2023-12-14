package egovframework.coviframework.base;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.nio.file.ClosedWatchServiceException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardWatchEventKinds;
import java.nio.file.WatchEvent;
import java.nio.file.WatchEvent.Kind;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import java.util.List;

import egovframework.coviframework.util.s3.AwsS3;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.ContextStartedEvent;
import org.springframework.context.event.ContextStoppedEvent;
import org.springframework.stereotype.Service;

import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.ComUtils;

/**
 * /covi_propery Directory 의 설정파일 Monitoring 및 Reload 클래스. ( java.nio WatchService 사용 )
 * @author hgsong
 *
 */
public class PropertiesWatcher {
	private static final Logger LOGGER = LogManager.getLogger(PropertiesWatcher.class);

	private static final String deploy_path = System.getProperty("DEPLOY_PATH");
	
	// SingleTon
	private volatile static PropertiesWatcher uniqueInstance;
	public static PropertiesWatcher getInstance() {
	      if(uniqueInstance == null) {
	          synchronized(PropertiesWatcher.class) {
	             if(uniqueInstance == null) {
	                uniqueInstance = new PropertiesWatcher(); 
	             }
	          }
	       }
	       return uniqueInstance;
	}
	
	private PropertiesWatcher() {
		initialize();
	}
	
	WatchService watchService = null;
	Thread t = null;
	private void initialize() {
		try {
			if(!"Y".equals(PropertiesUtil.getGlobalProperties().getProperty("properties.reload.used"))) {
				return;
			}
			
			watchService = FileSystems.getDefault().newWatchService();
			Path path = null;
			try {
				path = new File(URI.create("file://"+deploy_path.replace("\\", "/") + "/" + "covi_property")).toPath();
			}catch(java.lang.IllegalArgumentException e) {
				LOGGER.warn(e.getLocalizedMessage());
				try {
					path = Paths.get(deploy_path + File.separator + "covi_property");
				}catch(java.nio.file.InvalidPathException e2) {
					LOGGER.warn(e2.getLocalizedMessage());
					return;
				}
			}
	        if(!Files.exists(path)) {
	        	return;
	        }
	        path.register(watchService, StandardWatchEventKinds.ENTRY_MODIFY);

	        LOGGER.info("file watch service(covi_property) registerd.");
	        t = new Thread(new Runnable() {
				@Override
				public void run() {
					WatchKey watchKey = null;
					while(true) {
		                try {
		                    watchKey = watchService.take(); // Block Wait
		                } catch (InterruptedException e) {
		                    LOGGER.error(e.getLocalizedMessage(), e);
		                    break;
		                } catch (ClosedWatchServiceException e) {
		                	LOGGER.warn("ClosedWatchServiceException.");
		                	break;
		                }
		                if(watchKey == null) {
		                	continue;
		                }
		                List<WatchEvent<?>> events = watchKey.pollEvents();
		                for(WatchEvent<?> event : events) {
		                    Kind<?> kind = event.kind();
		                    Path paths = (Path)event.context();
		                    //System.out.println(paths.toAbsolutePath());//C:\...\...\test.txt
		                    if(kind.equals(StandardWatchEventKinds.ENTRY_MODIFY)) {
		                        String fileName = paths.getFileName().toString();
		                        switch (fileName) {
								case "globals.properties":
								case "db.properties":
								case "security.properties":
								case "extension.properties":
									
									LOGGER.info("[" + fileName + "] changed, reload properties.");
									PropertiesUtil.reloadProperties(fileName);
									break;
								case "govdocs.properties":
									
									LOGGER.info("[" + fileName + "] changed, reload properties.");
									ComUtils.reloadProperties(fileName);
									break;
									
								case "log4j2.xml":
									LOGGER.info("[" + fileName + "] changed, reload log4j2.xml.");
									((org.apache.logging.log4j.core.LoggerContext) LogManager.getContext(false)).reconfigure();
									break;

								case "s3.properties":
										LOGGER.info("[AWS S3][" + fileName + "] changed, reload s3 properties.");
										AwsS3.getInstance().reloadProperties(fileName);
										break;
								default:
									break;
								}
		                    }
		                }
		                
		                if(!watchKey.reset()) {
		                    try {
		                        watchService.close();
		                    } catch (IOException e) {
		                        LOGGER.warn("Error on watchService closing.", e);
		                        break;
		                    }
		                }
			        }
				}
				
			});
	        t.setName("covi_property properties File change watcher");
	        t.setDaemon(true);
	        t.start();
	        
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}finally {
			
		}
	}
	
	public void close() {
		if(watchService != null) {
			try {
				watchService.close();
				t.interrupt();
			} catch (IOException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			}
		}
	}
	
	@Service
	public static class ContextListener implements ApplicationListener<ApplicationEvent> {
		@Override
		public void onApplicationEvent(ApplicationEvent event) {
			if(event instanceof ContextClosedEvent || event instanceof ContextStoppedEvent) {
				getInstance().close();
			}
			else if(event instanceof ContextStartedEvent || event instanceof ContextRefreshedEvent) {
				getInstance();
			}
		}
	}
}
