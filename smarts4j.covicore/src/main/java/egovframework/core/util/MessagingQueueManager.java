package egovframework.core.util;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;

@Service("MessagingQueueManager")
public class MessagingQueueManager {
	private Logger LOGGER = LogManager.getLogger(MessagingQueueManager.class);
	
	@Resource(name = "asyncTaskMessaing")
	private AsyncTaskMessaing asyncTaskMessaing;
	
	
	public MessagingQueueManager() {
	}
	
	public boolean offer(String messagingID) {
		try {
			CoviMap object = new CoviMap();
			object.put("MessagingID", messagingID);
			asyncTaskMessaing.execute(object);
			return true;
		} catch (NullPointerException e) {
			LOGGER.error("", e);
			return false;
		} catch (Exception e) {
			LOGGER.error("", e);
			return false;
		}
	}
	
	
}
