package egovframework.core.util;

import java.util.concurrent.atomic.AtomicLong;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.core.sevice.MessageManageSvc;


/**
 * AsyncTaskMessaing *
 */
@Service("asyncTaskMessaing")
public class AsyncTaskMessaing{
	private Logger log = LogManager.getLogger(AsyncTaskMessaing.class);
	
	private AtomicLong completedTaskCnt = new AtomicLong(0L);
	private AtomicLong accumulatedCompletedTime = new AtomicLong(0L);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private MessageManageSvc messageMgrSvc;
	
	private final Long startTime = System.currentTimeMillis();
	
	@Async("coviExecutorForMessaging")
	public void execute(CoviMap obj) throws Exception{
		int messagingID = obj.getInt("MessagingID");
		try {
			long startTime = System.currentTimeMillis();
			
			// messagingId 기준으로 db 단건 조회하여 처리하기.
			
			// 1) Mail 도착 제외 알림처리
			// 알림 대상 조회  및 알림 대상 상태 변경 (대기  → 진행) 
			CoviMap targetMsgObj = messageMgrSvc.sendMessagingBefore(String.valueOf(messagingID));
			// 알림 발송
			messageMgrSvc.sendMessaging(targetMsgObj);
			// 해당 메시지건만 상태 바로 처리
			messageMgrSvc.updateMsgCnt(targetMsgObj);
			messageMgrSvc.updateMsgFailCompeleteStatus(obj);
			
			// sys_messaging_sub 에 재처리필요건이 있을 경우 threadtype 을 초기화 하여 스케쥴러가 재시도 할 수 있도록 한다.
			messageMgrSvc.updateMsgSendType(obj);
			
			
			long elapsedTime = System.currentTimeMillis() - startTime;
			log.info("Message["+messagingID+"] Sending complete. Elapsed " +  elapsedTime + "ms");
			
			completedTaskCnt.incrementAndGet();
			accumulatedCompletedTime.addAndGet(elapsedTime);
		} 
		catch (NullPointerException ne) {
			log.error(ne.getLocalizedMessage(), ne);
			
			//DB처리중 오류발생할 경우 스케쥴러가 처리할 수 있도록 threadtype 값을 변경한다.
			messageMgrSvc.updateMsgThreadType(messagingID);
		}
		catch (Exception ex) {
			log.error(ex.getLocalizedMessage(), ex);
			
			//DB처리중 오류발생할 경우 스케쥴러가 처리할 수 있도록 threadtype 값을 변경한다.
			messageMgrSvc.updateMsgThreadType(messagingID);
		}
	}
	
	/**
	 * Unit : milliseconds
	 * @return
	 */
	public long getAverageElapsedTime() {
		return completedTaskCnt.get() > 0 ? accumulatedCompletedTime.get() / completedTaskCnt.get() : 0;
	}
	
	public long getServerStarted() {
		return startTime;
	}
}