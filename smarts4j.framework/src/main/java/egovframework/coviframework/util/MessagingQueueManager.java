package egovframework.coviframework.util;

import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;


/**
 * 
 * @author hgsong
 */
public class MessagingQueueManager {
	private static final Logger LOGGER = LogManager.getLogger(MessagingQueueManager.class);
	
	// SingleTon
	private volatile static MessagingQueueManager uniqueInstance;
	public static MessagingQueueManager getInstance() {
	      if(uniqueInstance == null) {
	          synchronized(MessagingQueueManager.class) {
	             if(uniqueInstance == null) {
	                uniqueInstance = new MessagingQueueManager(); 
	             }
	          }
	       }
	       return uniqueInstance;
	}
	
	private MessagingQueueManager() {
		initialize();
	}
	
	private void initialize() {
	}
	
	public boolean offer(final CoviMap object) {
		try {
			
			if(!"true".equals(PropertiesUtil.getGlobalProperties().getProperty("messaging.realtime.use"))) {
				return true;
			}
			// covicore call
			ExecutorService es = Executors.newCachedThreadPool();
			Future<Boolean> future = es.submit(() -> { 
				Thread.sleep(100); //interrupt 발생시 exception 던질 수 있도록 
				try {
					CoviMap obj = new CoviMap();
					if(object.containsKey("MessagingID") && object.getInt("MessagingID") > 0) {
						obj.put("MessagingID", object.getInt("MessagingID"));
						Map<String, Object> result = new HttpsUtil().httpsClientConnectResponse(PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/covicore/messaging/queueMessage.do", "POST", obj, "UTF-8", "");
						if(result != null && result.get("STATUSCODE") != null && (Integer)result.get("STATUSCODE") == 200) {
							return Boolean.valueOf(true); 
						}else {
							String jsonResponseStr = (String)result.get("MESSAGE");
							if(jsonResponseStr != null) {
								LOGGER.warn(jsonResponseStr);
							}
							throw new Exception("/covicore/messaging/queueMessage.do Failed. response code is " + result.get("STATUSCODE"));
						}
					}else {
						throw new Exception("MessageID is Blank.");
					}
				} catch(NullPointerException e){	
					LOGGER.error(e.getLocalizedMessage(), e);
					return Boolean.valueOf(false);
				} catch (Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
					// Covicore 호출에 실패한 경우  ThreadType 값 초기화 하여 스케쥴러처리 되도록 함.
					return Boolean.valueOf(false);
				}
				
			});
			
			return future.get();
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return false;
		}
	}
}
