package egovframework.coviframework.service.impl;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.vo.MessageVO;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.coviframework.util.MessageHelper;
import egovframework.coviframework.util.MessagingQueueManager;

import java.util.HashMap;

/**
 * @Class Name : MessageServiceImpl.java
 * @Description : 통합 메시지 처리
 * @Modification Information 
 * @ 2017.11.09 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017.11.09
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Service("messageService")
public class MessageServiceImpl extends EgovAbstractServiceImpl implements MessageService {

	private Logger LOGGER = LogManager.getLogger(MessageServiceImpl.class);
			
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public int insertMessagingData(final CoviMap params) throws Exception{
		boolean realTimeSendUse = "true".equals(PropertiesUtil.getGlobalProperties().getProperty("messaging.realtime.use"));
		boolean isRealTimeSend = true;
		try {
			// 스케쥴링을 통해 실행되는 경우 세션값을 구할 수 없어 1 => 0(그룹사 공융) 으로 변경함.
			String domainID = "0";
			if(params.getString("DomainID") == null || params.getString("DomainID").equals("")){
				params.put("DomainID", domainID);
			}
			//isSaas인 경우 각자의 서비스 url로 변경하기
			
			params.put("PopupURL", MessageHelper.replaceLinkUrl(params.getString("DomainID"), params.getString("PopupURL"), false));
			params.put("GotoURL", MessageHelper.replaceLinkUrl(params.getString("DomainID"), params.getString("GotoURL"), false));
			params.put("MobileURL", MessageHelper.replaceLinkUrl(params.getString("DomainID"), params.getString("MobileURL"), true));
					
			if (!params.getString("MediaType").isEmpty()) {
				params.put("mMediaType", params.getString("MediaType"));
			} else {
				String strMediaType = coviMapperOne.getString("framework.messaging.selectDefaultMediaType", params);
				params.put("MediaType", strMediaType);
				params.put("mMediaType", null);
			}
			params.put("ApproverCode", null);
			params.put("SubTotalCount", 0);
			params.put("SendCount", 0);
			params.put("MessageTarget", "{\"ReceiversCode\":\""+params.getString("ReceiversCode")+"\",\"ExceptersCode\":\""+params.getString("ExceptersCode")+"\"}");
			/* ########### 메세지 마스터에 정보 등록 ########### */
			if(realTimeSendUse) {
				if(params.get("ReservedDate") == null || (params.get("ReservedDate") instanceof String && params.getString("ReservedDate").equals(""))) {
					params.put("ThreadType", "RT"); // 실시간 단건전송 사용하는 데이터. (스케쥴러와 중복방지, 상태값으로 커버하기 어려움)
					isRealTimeSend = true;
				}else {
					isRealTimeSend = false;
				}
			}
			coviMapperOne.insert("framework.messaging.insertMsgData", params);
			params.put("MessagingID", params.get("LastMsgID"));

			/* ########### 메세지 타겟에 정보 등록 ########### */
			String[] ReceiversCodeArr = params.getString("ReceiversCode").split(";");
			params.put("ReceiversCode", ReceiversCodeArr);
			coviMapperOne.insert("framework.messaging.insertMsgData_Target", params);

			//대결
			if(params.get("MsgType").equals("Approval_DEPUTY")) {return coviMapperOne.insert("framework.messaging.insertMsgData_Sub", params);} 
			
			// 발신 메시지 대상 매체 여부
			if (StringUtil.isNotNull(params.get("MediaType"))) {
				//발송 제외자 설정
				if (!params.getString("ExceptersCode").equals("")){
					String[] ExceptersCodeArr = params.getString("ExceptersCode").split(";");
					if (ExceptersCodeArr.length>0) params.put("ExceptersCode", ExceptersCodeArr);
				}	
				
				insertMsgDataSub(params);
				coviMapperOne.insert("framework.messaging.updateMsgData_Sub", params);
			}

			/* ########### 통합 메세지 관련 승인필요 여부 체크 시작 ########### */
			params.put("URL", "" + params.get("MessageID"));
						
			//String strReciverCodes = coviMapperOne.getString("messaging.selectReciverCodes", params);
			String strReciverCodes = RedisDataUtil.getBaseConfigElement("ApproveMessaging", domainID, "SettingValue");
			int minEmailCountForNeedApproval = Integer.parseInt(RedisDataUtil.getBaseConfigElement("MinEmailCountForNeedApproval", domainID, "SettingValue"));// 무승인 최대 이메일 발송가능량
			int minSMSCountForNeedApproval = Integer.parseInt(RedisDataUtil.getBaseConfigElement("MinSMSCountForNeedApproval", domainID, "SettingValue"));// 무승인 최대 SMS 발송 가능량
			int minMessengerCountForNeedApproval = Integer.parseInt(RedisDataUtil.getBaseConfigElement("MinMessengerCountForNeedApproval", domainID, "SettingValue"));// 무승인 최대 LINK 발송 가능량
			int minAlarmCountForNeedApproval = Integer.parseInt(RedisDataUtil.getBaseConfigElement("MinAlarmCountForNeedApproval", domainID, "SettingValue"));// 무승인 최대 ALARMLIST 발송 가능량
			int minMDMCountForNeedApproval = Integer.parseInt(RedisDataUtil.getBaseConfigElement("MinMDMCountForNeedApproval", domainID, "SettingValue"));// 무승인 최대 MDM 발송 가능량
			
			params.put("ReciverCodes", strReciverCodes);
			params.put("intMinCountForEmail", minEmailCountForNeedApproval);
			params.put("intMinCountForSMS", minSMSCountForNeedApproval);
			params.put("intMinCountForMessenger", minMessengerCountForNeedApproval);
			params.put("intMinCountForTodoList", minAlarmCountForNeedApproval);
			params.put("intMinCountForMDM", minMDMCountForNeedApproval);
			
			// 승인 필요 유무 및 대상 건수 체크
			CoviMap map = (CoviMap) (coviMapperOne.list("framework.messaging.selectNeedApprovalNSendAmount", params)).get(0);
			params.put("NeedAuth", map.getString("NeedAuth"));
			params.put("SendAmount", map.getString("SendAmount"));

			// 삭제 되지 않은 데이터 중에서 현재 상태 및 발송 대상건수 체크
			if (!map.getString("SendAmount").equals("0") && !map.getString("SendAmount").equals("")) {
				coviMapperOne.update("framework.messaging.updateMsgApvStatus", params);
			} else { // 발송 건수가 없는 것은 바로 취소 처리함.
				coviMapperOne.update("framework.messaging.cancelMsg", params);
			}
			
			return params.getInt("MessagingID");
		} catch(NullPointerException e){	
			LOGGER.error("insertMessagingData Error [Message : " + e.getMessage() + "]");
			params.put("ErrorMessage", e.getLocalizedMessage()); // API 호출시 응답메시지로 활용토록 함.
			return -1;
		} catch (Exception ex) {
			LOGGER.error("insertMessagingData Error [Message : " + ex.getMessage() + "]");
			params.put("ErrorMessage", ex.getLocalizedMessage());
			return -1;
		} finally {
			// sys_messaging 데이터 입력(Commit)후 즉시 단건 처리용 Thread 를 생성한다.
			if(realTimeSendUse && isRealTimeSend) {
				final int MessagingID = params.getInt("MessagingID");
				TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
					@Override
					public void afterCommit() {
						final CoviMap param = new CoviMap();
						try {
							param.put("MessagingID", MessagingID);
							boolean success = MessagingQueueManager.getInstance().offer(param);
							if(!success) {
								throw new Exception("Messae Real-time queueing failed.");
							}
						} catch(NullPointerException e){	
							LOGGER.error(e.getLocalizedMessage(), e);
							coviMapperOne.update("framework.messaging.updateMsgThreadType", param);
						}catch(Exception e) {
							LOGGER.error(e.getLocalizedMessage(), e);
							// covicore 쪽 요청자체가 실패할 경우 스케쥴러가 처리할 수 있도록 threadtype 값을 변경한다.
							coviMapperOne.update("framework.messaging.updateMsgThreadType", param);
						}
					}
				});
			}
		}

	}

	private void insertMsgDataSub(CoviMap params) {
		CoviList list = coviMapperOne.list("framework.messaging.selectTargetMedia", params);
		for(Object obj : list){
			CoviMap coviParam = (CoviMap) obj;
			String target = coviParam.getString("ReceiverCode");
			for(String str : coviParam.optString("TargetMedia").split(";")) {
				if(!StringUtil.isNull(str)) {
					params.put("target", target);
					params.put("targetMedia", str);
					coviMapperOne.insert("framework.messaging.insertMsgData_Sub_individual", params);
				}
			}
		}

	}
	@Override
	public void updateMessagingData(CoviMap params) throws Exception {
		coviMapperOne.update("framework.messaging.updateMsgData", params);
	}

	@Override
	public void deleteMessagingData(CoviMap params) throws Exception {
		coviMapperOne.delete("framework.messaging.deleteMsgData_Sub", params);
		coviMapperOne.delete("framework.messaging.deleteMsgData_Target", params);
		coviMapperOne.delete("framework.messaging.deleteMsgData", params);
	}

	@Override
	public void updateMessagingState(int messagingState, String serviceType, String objectType, int objectID, String searchType) throws Exception {
		/**
		 * 메세지 상태 (
		 * 		1 : 전송대기, 
		 * 		2 : 결과대기, 
		 * 		3 : 완료, 
		 * 		4 : 취소, 
		 * 		5 : 오류
		 * )
		 * 
		 * SearchType : "LIKE", "EQ"
		 */
		
		CoviMap params = new CoviMap();
		params.put("MessagingState", messagingState);
		params.put("SearchType", searchType);
		params.put("ServiceType", serviceType);
		params.put("ObjectType", objectType);
		params.put("ObjectID", objectID);
		
		coviMapperOne.update("framework.messaging.updateMsgDataMessagingState", params);
	}
	
	@Override
	public void updateArrMessagingState(int messagingState, String serviceType, String objectType, CoviList arrObjectID, String searchType) throws Exception {
		/**
		 * 메세지 상태 (
		 * 		1 : 전송대기, 
		 * 		2 : 결과대기, 
		 * 		3 : 완료, 
		 * 		4 : 취소, 
		 * 		5 : 오류
		 * )
		 * 
		 * SearchType : "LIKE", "EQ"
		 */
		
		CoviMap params = new CoviMap();
		params.put("MessagingState", messagingState);
		params.put("SearchType", searchType);
		params.put("ServiceType", serviceType);
		params.put("ObjectType", objectType);
		params.put("arrObjectID", arrObjectID);
		
		coviMapperOne.update("framework.messaging.updateArrMsgDataMessagingState", params);
	}
	
    @Override
	public CoviMap getDicInfo(CoviMap params) throws Exception {
    	CoviMap returnMap = new CoviMap();
		
		CoviMap dicParams = new CoviMap(params);
		CoviList resultList = new CoviList();
		resultList = coviMapperOne.list("framework.messaging.selectDictionary", dicParams);
		
		for (int i = 0; i < resultList.size(); i++) {
			CoviMap dicMap = resultList.getMap(i);
			if(!"".equals(dicMap.getString("DicCode"))) returnMap.put(dicMap.getString("DicCode"), dicMap.getString("DicValue"));
		}
		if (dicParams.getString("formatterMap") != null && !"".equals(dicParams.getString("formatterMap"))) {
			returnMap.put("formatterMap", dicParams.getString("formatterMap"));
		}
	
		return returnMap;
	}
}
