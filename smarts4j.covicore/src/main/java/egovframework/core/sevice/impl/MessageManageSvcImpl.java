package egovframework.core.sevice.impl;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Pattern;

import javax.annotation.Resource;







import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import egovframework.core.sevice.MessageManageSvc;
import egovframework.core.util.MessagingQueueManager;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.sec.EUMAES;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import egovframework.coviframework.util.DateHelper;

@Service("MessageManageService")
public class MessageManageSvcImpl extends EgovAbstractServiceImpl implements
		MessageManageSvc {

	private Logger LOGGER = LogManager.getLogger(MessageManageSvcImpl.class);

	@Resource(name = "coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private MessagingQueueManager queueManager;
	
	// 기본기능
	/**
	 * selectMasterMessageList : 통합 메세징 마스터 메시지 목록 조회
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMasterMessageList(CoviMap params) throws Exception {

		// Com_A_MessagingMasterList_R
		CoviList list = coviMapperOne.list("messaging.selectmastermsglist",
				params);
		int cnt = (int) coviMapperOne.getNumber(
				"messaging.selectmastermsglistcnt", params);

		CoviMap resultList = new CoviMap();
		resultList
				.put("list",
						CoviSelectSet
								.coviSelectJSON(
										list,
										"MessagingID,ServiceType,MsgType,MessagingSubject,DisplayName,DeptName,RegisterCode,MessagingState,SubTotalCount,SendCount,FailCnt,ProcessTime,ReservedDate,RegistDate"));
		resultList.put("cnt", cnt);
		return resultList;
	}

	/**
	 * selectMessagingSubData : 통합메세징 관련 서브 정보 조회
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessagingSubData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("messaging.selectmsgsubdatacnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		// Com_A_MessagingSubList_R
		CoviList list = coviMapperOne.list("messaging.selectmsgsubdata", params);

		resultList.put("list",
						CoviSelectSet
								.coviSelectJSON(
										list,
										"SubSeq,MediaType,SubID,DisplayName,GroupName,Mobile,MailAddress,SendDate,SuccessState,RetryCount,ResultMessage"));
		return resultList;
	}

	/**
	 * initMessagingData : 통합메세징 초기화
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int initMessagingData(CoviMap params) throws Exception {
		int iReturn = 0;
		try {
			// Com_A_MessagingInit_U

			// 초기화 (deprecated.)
			if (params.getInt("Mode") == 0) {
				iReturn += coviMapperOne.update("messaging.initmsgdata_init", params);
				iReturn += coviMapperOne.update("messaging.initmsgdata_initsub", params);
			}
			// 재발송(전송이 실패한 것만 재발송), 재발송을 위해선 초기화를 해야 잡스케줄러가 재발송을 진행함
			// 바로 큐에 넣어버리자.
			else {
				if("true".equals(PropertiesUtil.getGlobalProperties().getProperty("messaging.realtime.use"))) {
					params.put("ThreadType", "RT"); // 실시간 단건전송 사용하는 데이터. (스케쥴러와 중복방지, 상태값으로 커버하기 어려움)
				}
				iReturn += coviMapperOne.update("messaging.initmsgdata_retry", params);
				iReturn += coviMapperOne.update("messaging.initmsgdata_retryfail", params);
				iReturn += coviMapperOne.update("messaging.initmsgdata_retryfinal", params);
			}
		} catch (NullPointerException ex) {
			LOGGER.error("initMessagingData Error [ObjectCode : "
					+ params.get("MessagingID") + "] " + "[Message : "
					+ ex.getMessage() + "]");
		} catch (Exception ex) {
			LOGGER.error("initMessagingData Error [ObjectCode : "
					+ params.get("MessagingID") + "] " + "[Message : "
					+ ex.getMessage() + "]");
		} finally {
			// sys_messaging 데이터 입력(Commit)후 즉시 단건 처리용 Thread 를 생성한다.
			TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
				@Override
				public void afterCommit() {
					// covicore 호출이므로 direct 호출.
					queueManager.offer(params.getString("MessagingID"));
				}
			});
		}

		return iReturn;
	}


	/**
	 * updateMessagingData : 통합메세징 관련 정보 수정
	 * 
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int updateMessagingData(CoviMap params) throws Exception {
		int iReturn = 0;

		try {
			// Com_C_Messaging_U
			if (!params.getString("MessagingIDs").isEmpty()) {
				String msgArr[] = null;
				msgArr = params.getString("MessagingIDs").split(";");
				for (String msgID : msgArr) {
					params.put("MessagingID", msgID);
					iReturn = coviMapperOne.update(
							"messaging.updatemessagingdata", params);
				}
			}
		} catch (NullPointerException ex) {
			LOGGER.error("updateMessagingData Error [ObjectCode : "
					+ params.get("MessagingID") + "] " + "[Message : "
					+ ex.getMessage() + "]");
			LOGGER.error("updateMessagingData Error [ObjectCode : "
					+ params.get("MessagingID") + "] " );
			LOGGER.error(ex.getLocalizedMessage(), ex);
		} catch (Exception ex) {
			LOGGER.error("updateMessagingData Error [ObjectCode : "
					+ params.get("MessagingID") + "] " + "[Message : "
					+ ex.getMessage() + "]");
			LOGGER.error("updateMessagingData Error [ObjectCode : "
					+ params.get("MessagingID") + "] " );
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}

		return iReturn;
	}

	/**
	 * deleteMessagingData : 통합메세징 관련 정보 삭제
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int deleteMessagingData(CoviMap params) throws Exception {
		int iReturn = 0;
		String DeleteMsgArr[] = null;

		try {
			// Com_C_Messaging_D

			// 특정한 SubID가 있으면 해당하는 것만 삭제
			if (params.getInt("SubID") > 0) {
				DeleteMsgArr = params.getString("SubID").split(";");
				for (String msgID : DeleteMsgArr) {
					params.put("SubID", msgID);
					iReturn = coviMapperOne.update(
							"messaging.deletemsgdata_partsub", params);
					iReturn = coviMapperOne.update(
							"messaging.updatemsgdata_status", params);
				}
			}
			// SubID가 0이면 MessagingID 관련된 것들 모두 전체삭제
			else {
				DeleteMsgArr = params.getString("MessagingID").split(";");
				for (String msgID : DeleteMsgArr) {
					params.put("MessagingID", msgID);
					iReturn = coviMapperOne.update(
							"messaging.deletemsgdata_fullsub", params);
					iReturn = coviMapperOne.update(
							"messaging.deletemsgdata_fulltarget", params);
					iReturn = coviMapperOne.update(
							"messaging.deletemsgdata_full", params);
				}
			}

		} catch (NullPointerException ex) {
			LOGGER.error("deleteMessagingData Error [ObjectCode : "
					+ params.get("MessagingID") + "] " + "[Message : "
					+ ex.getMessage() + "]");
			LOGGER.error("deleteMessagingData Error [ObjectCode : "
					+ params.get("MessagingID") + "] ");
			LOGGER.error(ex.getLocalizedMessage(), ex);
		} catch (Exception ex) {
			LOGGER.error("deleteMessagingData Error [ObjectCode : "
					+ params.get("MessagingID") + "] " + "[Message : "
					+ ex.getMessage() + "]");
			LOGGER.error("deleteMessagingData Error [ObjectCode : "
					+ params.get("MessagingID") + "] ");
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}

		return iReturn;
	}

	/**
	 * selectMessagingApprovalList : 통합메세징 관련 발송 승인 목록
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMessagingApprovalList(CoviMap params)
			throws Exception {

		// Com_C_MessagingApprovalList_R
		CoviList list = coviMapperOne.list("messaging.selectmsgapprovallist",
				params);
		int cnt = (int) coviMapperOne.getNumber(
				"messaging.selectmsgapprovallistcnt", params);

		CoviMap resultList = new CoviMap();
		resultList
				.put("list",
						CoviSelectSet
								.coviSelectJSON(
										list,
										"MessagingID,ServiceType,MsgType,MessagingSubject,ReceiverText,MediaType,SenderCode,RegistDate"));
		resultList.put("cnt", cnt);
		return resultList;
	}

	/**
	 * updateMessagingPartialApproval : 통합메세징 관련 발송 승인 요청 시 부분 승인
	 * 
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int updateMessagingPartialApproval(CoviMap params) throws Exception {
		int iReturn = 0;

		try {
			// Com_C_MessagingPartialApproval_U
			iReturn += coviMapperOne.update(
					"messaging.updatemsgpartialapproval_sub", params);
			iReturn += coviMapperOne.update(
					"messaging.updatemsgpartialapproval", params);
		} catch (NullPointerException ex) {
			LOGGER.error("updateMessagingPartialApproval Error [ObjectCode : "
					+ params.get("MessagingID") + "] " + "[Message : "
					+ ex.getMessage() + "]");
			LOGGER.error("updateMessagingPartialApproval Error [ObjectCode : "
					+ params.get("MessagingID") + "] ");
			LOGGER.error(ex.getLocalizedMessage(), ex);
		} catch (Exception ex) {
			LOGGER.error("updateMessagingPartialApproval Error [ObjectCode : "
					+ params.get("MessagingID") + "] " + "[Message : "
					+ ex.getMessage() + "]");
			LOGGER.error("updateMessagingPartialApproval Error [ObjectCode : "
					+ params.get("MessagingID") + "] ");
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}

		return iReturn;
	}

	/**
	 * 
	 * @param params
	 */
	private void makeRetryParameters(CoviMap params) {
		// 미디어 타입별 재전송 횟수
		//int smsRetryCount = StringUtil.parseInt(RedisDataUtil.getBaseConfig("SMSRetryCount"), 4);
		int mailRetryCount = StringUtil.parseInt(RedisDataUtil.getBaseConfig("MailRetryCount"), 4);
		int messengerRetryCount = StringUtil.parseInt(RedisDataUtil.getBaseConfig("MessengerRetryCount"), 4);
		int mdmRetryCount = StringUtil.parseInt(RedisDataUtil.getBaseConfig("MDMRetryCount"), 4);
		
		// 미디어 타입별 1회 발송시 최대 전송 대상수
		//int maxSMSCountForOnce = StringUtil.parseInt(RedisDataUtil.getBaseConfig("MaxSMSCountForOnce"), 200);
		int maxEmailCountForOnce = StringUtil.parseInt(RedisDataUtil.getBaseConfig("MaxEmailCountForOnce"), 200);
		int maxMessengerCountForOnce = StringUtil.parseInt(RedisDataUtil.getBaseConfig("MaxMessengerCountForOnce"), 200);
		int maxMDMCountForOnce = StringUtil.parseInt(RedisDataUtil.getBaseConfig("MaxMDMCountForOnce"), 200);
		
		//params.put("SMSRetryCount", smsRetryCount);
		params.put("MailRetryCount", mailRetryCount);
		params.put("MessengerRetryCount", messengerRetryCount);
		params.put("MDMRetryCount", mdmRetryCount);
		
		//params.put("MaxSMSCountForOnce", maxSMSCountForOnce);
		params.put("MaxEmailCountForOnce", maxEmailCountForOnce);
		params.put("MaxMessengerCountForOnce", maxMessengerCountForOnce);
		params.put("MaxMDMCountForOnce", maxMDMCountForOnce);
	}
	
	/* 부가기능 */
	/**
	 * 통합메세징 발송전 처리사항 (전체 진행상태 및 지연건 처리만 담당한다) - 실시간 발송로직과 중복처리 방지.
	 * [스케쥴러 호출시 사용]
	 */
	@Override
	public CoviMap sendMessagingBefore(CoviMap params) throws Exception {
		makeRetryParameters(params);
		
		// [전체 진행된 상태 처리]
		// 발송 건수 업데이트: 결과 대기 상태의 메세징 발송 대상자 수(SubTotalCount), 성공 건수(SendCount), 실패건수(FailCnt) 업데이트
		coviMapperOne.update("messaging.updateMsgCnt", params);
		
		// 완료 처리 (오류): 모든 대상 처리 완료한 메세징 완료 또는 오류로 상태 변경
		coviMapperOne.update("messaging.updateMsgFailCompeleteStatus", params);
		
		// 지연건에 대한 발송 취소 (sys_messaging 대상): 30분(일반)/5시간(지연대상) 발송되지 않은 알림 취소 처리
		coviMapperOne.update("messaging.updateMsgDelay", params);
		
		// 지연건에 대한 실패 처리 (sys_messaging_sub 대상): 진행 상태가 10분 이상 유지된 알림 실패 처리
		coviMapperOne.update("messaging.updateMsgSubDelay", params);

		return targetSendMessaging(params);
	}
	
	/**
	 * 통합메세징 발송전 처리사항
	 * [단건 처리용 (실시간 큐방식)]
	 * @param messagingID
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap sendMessagingBefore(String messagingID) throws Exception {
		CoviMap params = new CoviMap();
		if(messagingID != null) {
			params.put("MessagingID", messagingID);
		}

		makeRetryParameters(params);
		
		CoviMap targetMsgObj = targetSendMessaging(params);
		targetMsgObj.putAll(params);
		return targetMsgObj;
	}
	
	/**
	 * 공통함수 [대상선정작업]
	 * @param params
	 * @return
	 * @throws Exception
	 */
	private CoviMap targetSendMessaging(CoviMap params) throws Exception {
		// [발송 대상 메시지 선정]
		// 마스터 테이블 발송중으로 상태 변경 (1 -> 2)
		coviMapperOne.update("messaging.updateMsgStatus_Master", params);
		
		// [발송 메체별 대상 선정]
		// SMS 발송 대상 선정
		// if(listSMS.size() > 0) {
		//		coviMapperOne.update("messaging.updateMsgStatus_SMS", params);
		// }
		
		CoviMap targetMsgObj = getMessagingBefore(params);
		//CoviList listSMS = targetMsgObj.getJSONArray("SMS");
		CoviList listMAIL = targetMsgObj.getJSONArray("MAIL");
		CoviList listMESSENGER = targetMsgObj.getJSONArray("MESSENGER");
		CoviList listMDM = targetMsgObj.getJSONArray("MDM");
		
		// MAIL 발송 대상 선정
		if(listMAIL.size() > 0) {
			coviMapperOne.update("messaging.updateMsgStatus_MAIL", params);
		}
		
		// MESSENGER 발송 대상 선정
		if(listMESSENGER.size() > 0) {
			coviMapperOne.update("messaging.updateMsgStatus_MESSENGER", params);
		}

		// MDM 발송 대상 선정
		if(listMDM.size() > 0) {
			coviMapperOne.update("messaging.updateMsgStatus_MDM", params);
		}
		// ALARM 발송 대상 선정
		coviMapperOne.update("messaging.updateMsgStatus_ALARM", params);
		
		// [발송대상 반환, 또는 처리]
		// ALARM 발송 대상 처리(insert)
		coviMapperOne.insert("messaging.insertMsgSendList_ALARM", params);
		// ALARM 발송 대상 처리(update)
		coviMapperOne.insert("messaging.updateMsgSendList_ALARM", params);
		
		return targetMsgObj;
	}
	
	@Override
	public CoviMap getMessagingBefore(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviList list = new CoviList();
		
		// [발송대상 반환, 또는 처리]
		// SMS 발송대상 반환
		// list = coviMapperOne.list("messaging.selectMsgSendList_SMS", params);
		// returnObj.put("SMS", CoviSelectSet.coviSelectJSON(list, "MessagingID,SubID,MediaType,MsgType,ServiceType,ObjectID,ObjectType,MessageID,MessagingSubject,SenderMobile,SenderCode,LanguageCode,ReceiverMobile"));
		
		// MAIL 발송대상 반환
		list = coviMapperOne.list("messaging.selectMsgSendList_MAIL", params);
		returnObj.put("MAIL", CoviSelectSet.coviSelectJSON(list, "MessagingID,SubID,MediaType,MsgType,ServiceType,ObjectID,ObjectType,MessageID,MessagingSubject,ReceiverText,MessageContext,XSLPath,GotoURL,MobileURL,ReservedStr3,ReservedStr4,RegistDate,SenderEmail,SenderCode,SenderName,SenderGroup,CompanySortKey,LanguageCode,ReceiverEmail,ReceiverCode,ReceiverName,ReceiverTimeZone,DomainID,ReservedStr1,ReservedStr2,ReservedStr3"));
		
		// MESSENGER 발송 대상 반환
		list = coviMapperOne.list("messaging.selectMsgSendList_MESSANGER", params);
		returnObj.put("MESSENGER", CoviSelectSet.coviSelectJSON(list, "MessagingID,SubID,MediaType,MsgType,ServiceType,ObjectID,ObjectType,MessageID,MessagingSubject,ReceiverText,MessageContext,XSLPath,GotoURL,MobileURL,ReservedStr3,ReservedStr4,RegistDate,SenderEmail,SenderCode,SenderName,SenderGroup,CompanySortKey,LanguageCode,ReceiverEmail,ReceiverCode,ReceiverName,ReservedStr1,DomainID,ReservedStr2,ReservedStr3"));
		
		// MDM 발송 대상 반환
		list = coviMapperOne.list("messaging.selectMsgSendList_MDM", params);
		returnObj.put("MDM", CoviSelectSet.coviSelectJSON(list, "MessagingID,SubID,MediaType,MsgType,ServiceType,ObjectID,ObjectType,MessageID,MessagingSubject,ReceiverText,MessageContext,XSLPath,GotoURL,MobileURL,ReservedStr3,ReservedStr4,RegistDate,SenderEmail,SenderCode,SenderName,SenderGroup,CompanySortKey,LanguageCode,ReceiverEmail,ReceiverCode,ReceiverName,TimeZoneCode,PushAllowYN,PushAllowWeek,PushAllowStartTime,PushAllowEndTime,DomainID,ReservedStr1,ReservedStr2,ReservedStr3"));
		
		return returnObj;
	}

	// 통합메세징(그룹대상) 발송후 처리사항(SvcImpl로 이동)
	@Override
	public int sentMessagingGroup(CoviList params) throws Exception {

		int intReturn = 0;
		String strSuccSubIDs = "";
		String strMessagingID = "";
		CoviMap msgParam;

		for (Object obj : params) {

			CoviMap paramObj = new CoviMap();
			paramObj.addAll((CoviMap) obj);

			if (!paramObj.getString("ResultMessage").equals("")) {
				try {
					msgParam = new CoviMap();
					msgParam.put("SubID", paramObj.getString("SubID"));
					msgParam.put("MessagingID",	paramObj.getString("MessagingID"));
					msgParam.put("MediaType", paramObj.getString("MediaType"));
					msgParam.put("ResultMessage", paramObj.getString("ResultMessage"));
					// Com_S_MessagingSentFail_U
					intReturn = coviMapperOne.update("messaging.updatemsgsentfail", msgParam);
				} catch (NullPointerException ex) {
					try {
						msgParam = new CoviMap();
						msgParam.put("SubID", paramObj.getString("SubID"));
						msgParam.put("MessagingID",	paramObj.getString("MessagingID"));
						msgParam.put("MediaType", paramObj.getString("MediaType"));
						msgParam.put("ResultMessage", ex.getMessage());
						// Com_S_MessagingSentFail_U
						intReturn = coviMapperOne.update("messaging.updatemsgsentfail", msgParam);
					} catch (NullPointerException ex2) {
						LOGGER.error("sentMessagingGroup Error [통합메시징 실패로그 기록 중 오류]");
					} catch (Exception ex2) {
						LOGGER.error("sentMessagingGroup Error [통합메시징 실패로그 기록 중 오류]");
					}
				} catch (Exception ex) {
					try {
						msgParam = new CoviMap();
						msgParam.put("SubID", paramObj.getString("SubID"));
						msgParam.put("MessagingID",	paramObj.getString("MessagingID"));
						msgParam.put("MediaType", paramObj.getString("MediaType"));
						msgParam.put("ResultMessage", ex.getMessage());
						// Com_S_MessagingSentFail_U
						intReturn = coviMapperOne.update("messaging.updatemsgsentfail", msgParam);
					} catch (NullPointerException ex2) {
						LOGGER.error("sentMessagingGroup Error [통합메시징 실패로그 기록 중 오류]");
					} catch (Exception ex2) {
						LOGGER.error("sentMessagingGroup Error [통합메시징 실패로그 기록 중 오류]");
					}
				}
			} else // 성공시 일괄로 처리하기 위해 문자열로 묶음.
			{
				if ("".equals(strSuccSubIDs)) {
					strSuccSubIDs = paramObj.getString("SubID");
					strMessagingID = paramObj.getString("MessagingID");
				} else {
					strSuccSubIDs += ";" + paramObj.getString("SubID");
				}
			}
		}

		// 성공에 대한 일괄 처리
		if (!strSuccSubIDs.equals("")) {
			msgParam = new CoviMap();
			msgParam.put("SubID", strSuccSubIDs.split(";"));
			msgParam.put("MessagingID", strMessagingID);
			// Com_S_MessagingSent_U
			intReturn += coviMapperOne.update("messaging.updatemsgsent_sub", msgParam);
//			intReturn += coviMapperOne.update("messaging.updatemsgsent",msgParam);
		}

		return intReturn;
	}

	/*
	 * //통합메세징에 사용할 조직도용 Node 조회(미사용 메서드로 사료됨)
	 * 
	 * @Override public CoviMap getNodeList(CoviMap params) throws Exception
	 * { CoviMap resultList = null; CoviList list = null;
	 * 
	 * try{ resultList = new CoviMap(); list =
	 * coviMapperOne.list("organization.synchronize.selectLogList", params);
	 * 
	 * resultList.put("list", CoviSelectSet.coviSelectJSON(list,
	 * "datatype,insertdate,Insertcnt,Updatecnt,Deletecnt"));
	 * resultList.put("cnt", list.size()); } catch(Exception e){}
	 * 
	 * return resultList; }
	 */

	/* InternalWebService */
	// 통합 메세징 관련 서비스( 매체별 처리 : 송신 및 결과 처리를 각 매체별로 처리 )
	@Override
	public CoviMap sendMessaging(CoviMap targetMsgObj) throws Exception {
		
		CoviMap returnObj = new CoviMap();
		
		StringBuilder strBulider = new StringBuilder(100);
		StringBuilder strReturn = new StringBuilder("<response>");
		int intTotal = 0;
		int intOK = 0;
		int intFail = 0;
		
		try {			
			
			// 매체 전송 후 프로세스에 사용 될 테이블 정의
			CoviList listProcess = new CoviList();
						
			//CoviList listSMS = targetMsgObj.getJSONArray("SMS");
			CoviList listMAIL = targetMsgObj.getJSONArray("MAIL");
			CoviList listMESSENGER = targetMsgObj.getJSONArray("MESSENGER");
			CoviList listMDM = targetMsgObj.getJSONArray("MDM");
			
			LOGGER.info(String.format("sendMessaging target [Mail: %d, Messenger: %d, MDM: %d]", listMAIL.size(), listMESSENGER.size(), listMDM.size()));
			
			/*
			//1. SMS 전송 (listSMS)
			if(!(listSMS.isEmpty()) && listSMS.size() > 0) {
				
			    int intRowCount = listSMS.size();
			    String strSubject = "";
			    String strSenderMobile = "";
			    String strReceivers = "";
	            String strReceiverMobile = "";
	            String strSystemId = "";
	            String strSericeCode = "";
	            String strSystemCode = "";
	            	            
	            String strLangType = "";
	        
	            strReturn = strReturn + "<result MediaType='SMS'>";
	            listProcess.clear();
	            
				for(Object msg : listSMS){
					CoviMap listProcessTemp = new CoviMap();//dr
					try {
						intTotal++;
						strBulider.setLength(0);
												
						CoviMap smsParams = new CoviMap();
						CoviMap smsObj = new CoviMap();
						smsObj = (CoviMap) msg;
						
						// 매체 전송 후 프로세스에 사용
						listProcessTemp.put("MessagingID", smsObj.get("MessagingID"));
						listProcessTemp.put("SubID", smsObj.get("SubID"));
						listProcessTemp.put("MediaType", smsObj.get("MediaType"));
						listProcessTemp.put("ResultMessage", "");
						
						strSubject = ""; // 제목
						strSenderMobile = RedisDataUtil.getBaseConfig("ITOPhoneNumber").toString(); //발신자 번호
						strReceivers = "1"; //받는 사람 수 (각각 보내서 1로 지정)
						strReceiverMobile = "^" + smsObj.get("ReceiverMobile").toString().replaceAll("-", ""); //수신자번호
						strSericeCode = ""; // serice_cd
						strSystemId = ""; // 시스템 ID
						strSystemCode = ""; //system_cd
	                    strLangType = smsObj.get("LanguageCode").toString();// 수신자 언어 타입
	                    
	                    strBulider.append("[" + DicHelper.getDic("TodoCategory_" + smsObj.get("ServiceType").toString(), strLangType) + "-" + DicHelper.getDic("TodoMsgType_" + smsObj.get("MsgType").toString(), strLangType)+ "] "); //[게시>새글등록알림] <= [서비스 영역 > 알림메시지 유형] 
                        strBulider.append(smsObj.get("MessagingSubject").toString() + System.getProperty("line.separator")); //연차사용 촉진 공지 <= 제목(Title)
                        if (smsObj.get("ObjectID").toString() != "" && smsObj.get("ObjectID").toString() != "0" && smsObj.get("ObjectType").toString() != "")
                        {
                            strBulider.append(System.getProperty("line.separator") + "- " + DicHelper.getDic(smsObj.get("ObjectType").toString() + "_" + smsObj.get("ObjectID").toString(), strLangType));
                        }
                        
                        smsParams.put("subject", "");
                        smsParams.put("callback", strSenderMobile);
                        smsParams.put("receivers", strReceivers);
                        smsParams.put("reciverInfos", strReceiverMobile);
                        smsParams.put("systemId", strSystemId);
                        smsParams.put("sericeCode", strSericeCode);
                        smsParams.put("systemCode", strSystemCode);
                        smsParams.put("message", strBulider.toString().replace("\n", " "));
                        smsParams.put("isMms", "N");
                        
                        //SMS 기능이 개발되지 않아서 보류
                        //sServ.Send_SMS(smsParams);// 한명 씩 SMS 발송 

                        if (sendSMS(smsParams)) {
                        	intOK++;
                        } else {
                        	intFail++;
                            listProcessTemp.put("ResultMessage", "SMS 발송 실패!!");
                        }
	                    
					} catch (Exception e) {
						LOGGER.error("sendMessaging SMS Error [ObjectCode : " +  "[Message : " +  e.getMessage() + "]");
						intFail++;
						listProcessTemp.put("ResultMessage", e.getMessage());
					} finally {
                        listProcess.add(listProcessTemp);
                    }
				}//for
				
				// 성공 메세지
                strReturn = strReturn + "<OK><![CDATA[SMS(" + Integer.toString(intTotal) + ") OK:" + Integer.toString(intOK) + ", Fail:" + Integer.toString(intFail) + "]]></OK></result>";

                // 매체 전송 후 처리사항
                if (!(listProcess.isEmpty()) && listProcess.size() > 0)
                {
                    sentMessagingGroup(listProcess);
                }
                
			}//IF - SMS
			*/
			
			//2. MAIL 전송 (listMAIL)
			if(!listMAIL.isEmpty()) {
				
				listProcess.clear();//dt
				
				strReturn.append("<result MediaType='MAIL'>");
				intTotal = 0;
                intOK = 0;
                intFail = 0;
                
                String strSenderEmail = "";
                String strSenderName = "";
                String strMessagingSubject = "";
                String strMessageContext = "";
                String strGotoURL = "";
                String strMobileURL = "";
                String strReceiverEmail = "";
                String strServiceType = "";
                String strServiceName = "";
                String strMsgType = "";
                String strRegistDate = "";
                String strLangType = "ko";
                String strMenuName = "";
                String strReCommentType = "";
                String strReCommentName = "";
                String strParentReCommentID = "";//대댓글의 상위 댓글ID
	            
				for(Object msg : listMAIL){		
					
					CoviMap listProcessTemp = new CoviMap();//dr
					
					try {
						intTotal++;
						
						strBulider.setLength(0);
												
						CoviMap mailObj = (CoviMap) msg;
						
						// 매체 전송 후 프로세스에 사용
						listProcessTemp.put("MessagingID", mailObj.get("MessagingID"));
						listProcessTemp.put("SubID", mailObj.get("SubID"));
						listProcessTemp.put("MediaType", mailObj.get("MediaType"));
						listProcessTemp.put("ResultMessage", "");
						
						strSenderEmail = mailObj.getString("SenderEmail");
						
                        // 발송자 메일 유효성 검사
                        if (isValidEmail(strSenderEmail)){
                        	// 매체 전송 시 사용
                        	strLangType = mailObj.getString("LanguageCode");
                            strSenderName = DicHelper.getDicInfo(mailObj.getString("SenderName"), strLangType);
                            strReceiverEmail = mailObj.getString("ReceiverEmail");
                            String strDomainID = mailObj.getString("DomainID");
                            strMenuName = mailObj.getString("ReservedStr1");
                            strReCommentType = mailObj.getString("ReservedStr2");
                            strParentReCommentID = mailObj.getString("ReservedStr3");
                            
                            // 메일 제목 : [게시-새글등록알림] 연차사용 촉진 공지
                            strServiceType = mailObj.getString("ServiceType");
                            
                            if("CommunitySurvey".equals(strServiceType)){
                            	strServiceType = "CommunitySurvey";
                            }
                            
                            // 통합게시에서 메뉴이름으로 메일 타이틀 처리(이지뷰,통합게시,품질관리)
                            if("Board".equals(strServiceType) || "Doc".equals(strServiceType)) {
								if(strMenuName != null && !"".equals(strMenuName)) {
									strServiceName = strMenuName;
								}else {
									strServiceName = RedisDataUtil.getBaseCodeDic("TodoCategory", strServiceType, strLangType);//DicHelper.getDic("TodoCategory_" + strServiceType, strLangType);
								}
							}else {
								strServiceName = RedisDataUtil.getBaseCodeDic("TodoCategory", strServiceType, strLangType);
							}
                            
                            strMsgType = RedisDataUtil.getBaseCodeDic("TodoMsgType", mailObj.getString("MsgType"), strLangType);
                            strReCommentName = RedisDataUtil.getBaseCodeDic("TodoMsgType", strReCommentType, strLangType);//답글
                            strMessagingSubject = convertOutputValue(mailObj.getString("MessagingSubject"));
                            
                            strGotoURL = mailObj.getString("GotoURL");
                            strMobileURL = mailObj.getString("MobileURL");
                            strRegistDate = ComUtils.TransLocalTime(mailObj.getString("RegistDate"), "yyyy-MM-dd HH:mm:ss", mailObj.getString("ReceiverTimeZone"));
                            
                            //pDesc 처리
                            String strMsgDesc=null;
                            String strParentReComment = "";//대댓글의 상위 댓글
                            
                            switch (mailObj.getString("MsgType")) {
	                            case "Comment":
	                            	CoviMap commentParam = new CoviMap();
	                            	
	                            	if(strReCommentType != null && !"".equals(strReCommentType)) {
	                            		commentParam.put("commentID",strParentReCommentID);
	                            		strParentReComment=coviMapperOne.selectOne("selectUserComment",commentParam);
	                            	}
		                            	commentParam.put("commentID",mailObj.getString("MessageID"));
		                            	strMsgDesc=coviMapperOne.selectOne("selectUserComment",commentParam);
	                            	break;
	                            default: 
	                            	CoviMap Param = new CoviMap();
	                            	
	                            	if(strReCommentType != null && !"".equals(strReCommentType)) {
	                            		Param.put("commentID",strParentReCommentID);
	                            		strParentReComment=coviMapperOne.selectOne("selectUserComment",Param);
	                            	}
	                            	if (!mailObj.getString("MessageContext").equals("") && !strMessagingSubject.equals(mailObj.getString("MessageContext")))
		                            	strMsgDesc=mailObj.getString("MessageContext");
	                            	else
		                            	strMsgDesc=strMsgType;
	                            	break;
                            }
                            // 본문 처리
                            if(strServiceType.equalsIgnoreCase("Approval")||strServiceType.equalsIgnoreCase("WorkReport") || strServiceType.equalsIgnoreCase("Mail")){
                            	strMessageContext = mailObj.getString("MessageContext");
                            } else {
                            	strMessageContext = MessageHelper.getInstance().makeDefaultMessageContext(strServiceName, strMsgType, strMsgDesc, strMessagingSubject, strSenderName, strRegistDate, strGotoURL, strMobileURL, strServiceType, strDomainID, strLangType, strReCommentName, strReCommentType, strParentReComment);	
                            }
                            
                            String strDic = mailObj.getString("ReservedStr4");
                            if (!"".equals(strDic)) {
                            	CoviMap dicMap = CoviMap.fromObject(strDic);
                                CoviMap formatterMap = dicMap.getJSONObject("formatterMap");
                                dicMap.remove("formatterMap");
                                Iterator<String> keys = dicMap.keySet().iterator();
                                while (keys.hasNext()){
                                    String key = keys.next();
                                    String convertedStr = DicHelper.getDicInfo(dicMap.getString(key), strLangType);
                                    if (formatterMap.get(key) != null) {
                                    	ArrayList<String> formatteredList = (ArrayList<String>) formatterMap.get(key);
                                    	for (int i = 0; i < formatteredList.size(); i++) {
                                    		String argIndex = "{".concat(String.valueOf(i)).concat("}");
                                    		String argDicCode = (String) formatteredList.get(i);
                                    		String argDicValue = DicHelper.getDicInfo(dicMap.getString(argDicCode), strLangType);
                                    		if ("".equals(argDicValue)) argDicValue = argDicCode;
                                    		convertedStr = convertedStr.replace(argIndex, argDicValue);
                                    	}
                                    }
                                    strMessageContext = strMessageContext.replace("§"+key+"§", convertedStr);
                                    strMessagingSubject = strMessagingSubject.replace("§"+key+"§", convertedStr);
                                }
                            }
                            
                            if(strReCommentType != null && !"".equals(strReCommentType)) {
                            	strBulider.append("[");
                                strBulider.append(strServiceName);
                                strBulider.append("-");
                                strBulider.append(strReCommentName);
                                strBulider.append("] ");
                                strBulider.append(strMessagingSubject);
                            }else {
                            	strBulider.append("[");
                                strBulider.append(strServiceName);
                                strBulider.append("-");
                                strBulider.append(strMsgType);
                                strBulider.append("] ");
                                strBulider.append(strMessagingSubject);
                            }
                            
                        	if (MessageHelper.getInstance().sendSMTP(strSenderName, strSenderEmail, strReceiverEmail, strBulider.toString(), strMessageContext, true)) {
                                intOK++;
                            } else {
                            	intFail++;
                            	listProcessTemp.put("ResultMessage", "MAIL 발송 실패!!");
                            }
                        }
                        else {
                        	strSenderEmail = PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail").split(";")[0];
                            strSenderName = PropertiesUtil.getGlobalProperties().getProperty("AppName") + "(" + PropertiesUtil.getGlobalProperties().getProperty("SiteName") + ")";
                            listProcessTemp.put("ResultMessage", "MAIL 발송 실패 - 발송자 메일 유효성 오류");
    						intFail++;
                        }
                    } catch (NullPointerException e) {
                    	LOGGER.error("sendMessaging Mail Error [Message : " +  e.getMessage() + "]");
						listProcessTemp.put("ResultMessage", e.getMessage());
						intFail++;
            		} catch (Exception e) {
						LOGGER.error("sendMessaging Mail Error [Message : " +  e.getMessage() + "]");
						listProcessTemp.put("ResultMessage", e.getMessage());
						intFail++;
					} finally {
                        listProcess.add(listProcessTemp);
                    }
				}//for
				
				// 성공 메세지
                strReturn.append("<OK><![CDATA[MAIL(" + Integer.toString(intTotal) + ") OK:" + Integer.toString(intOK) + ", Fail:" + Integer.toString(intFail) + "]]></OK></result>");

                // 매체 전송 후 처리사항
                if (!(listProcess.isEmpty()) && listProcess.size() > 0)
                {
                    sentMessagingGroup(listProcess);
                }
                
			}
			
			//3. MDM 전송 (listMDM)
			if(!(listMDM.isEmpty()) && listMDM.size() > 0) {
				
				intTotal = 0;
				intOK = 0;
				intFail = 0;
				strReturn.append("<result MediaType='MDM'>");
				listProcess.clear();

				String strLangType = "ko";
				
				for(Object msg : listMDM){
					CoviMap listProcessTemp = new CoviMap();//dr
					try {
						intTotal++;
						strBulider.setLength(0);
												
						CoviMap mdmObj = (CoviMap) msg;
						// 매체 전송 후 프로세스에 사용
						listProcessTemp.put("MessagingID", mdmObj.get("MessagingID"));
						listProcessTemp.put("SubID", mdmObj.get("SubID"));
						listProcessTemp.put("MediaType", mdmObj.get("MediaType"));
						listProcessTemp.put("ResultMessage", "");
						
						String strReCommentType = mdmObj.getString("ReservedStr2");
						String strServiceName = RedisDataUtil.getBaseCodeDic("TodoCategory" , mdmObj.get("ServiceType").toString(), strLangType);
						if("CommunitySurvey".equals(mdmObj.get("ServiceType"))){
							mdmObj.put("ServiceType","Survey");
						}
						
						boolean sendFlag = true;
						if (mdmObj.getString("PushAllowYN").equals("Y")||(RedisDataUtil.getBaseConfig("MDMAllowWeek") != null && !RedisDataUtil.getBaseConfig("MDMAllowWeek").equals(""))){
							sendFlag = checkAllowTime(mdmObj);
						}
						if (sendFlag == false){
							listProcessTemp.put("ResultMessage", "Not Allow Time");
							intFail++;
							continue;
						}
						
						// 수신자 언어 타입
						strLangType = mdmObj.get("LanguageCode").toString();
						//if (RedisDataUtil.getBaseConfig("MessagingMDMSendType", mdmObj.getString("CompanySortKey")) != null && RedisDataUtil.getBaseConfig("MessagingMDMSendType", mdmObj.getString("CompanySortKey")).equalsIgnoreCase("LINK") && !mdmObj.getString("MobileURL").isEmpty()){
						if (RedisDataUtil.getBaseConfig("MessagingMDMSendType") != null && RedisDataUtil.getBaseConfig("MessagingMDMSendType").equalsIgnoreCase("LINK") && !mdmObj.getString("MobileURL").isEmpty()){
							// [게시-새글등록알림] 연차사용 촉진 공지 - 경영관리팀 게시판
							// 2017.08.23 커뮤니티 회원메시지 경우 컨텐츠포함
							//if (mdmObj.getString("ServiceType").equalsIgnoreCase("Mail")) {
							//	strBulider.append("LINK|" + convertOutputValue(mdmObj.get("MessagingSubject").toString()) + "\"");
							//} else {
							if (mdmObj.getString("ServiceType").equalsIgnoreCase("Community") && mdmObj.getString("MsgType").equalsIgnoreCase("CuMemberContact") ){
								strBulider.append("LINK|[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType" , mdmObj.get("MsgType").toString(), strLangType) + "] \"" + convertOutputValue(mdmObj.get("MessagingSubject").toString()) + " " + convertOutputValue(mdmObj.get("ReceiverText").toString()) + "\""); 
							} else {
								strBulider.append("LINK|[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType" , mdmObj.get("MsgType").toString(), strLangType) + "] \"" + convertOutputValue(mdmObj.get("MessagingSubject").toString()) + "\"");
							}
							if (  mdmObj.get("ObjectID") != null &&  mdmObj.get("ObjectType") != null &&  !mdmObj.getString("ObjectID").isEmpty()  && !"0".equals(mdmObj.getString("ObjectID")) && !mdmObj.getString("ObjectType").isEmpty()){
								strBulider.append(" - " +  DicHelper.getDic(mdmObj.get("ObjectType").toString() + "_" + mdmObj.get("ObjectID").toString(), strLangType));
							}
							//}
							// URL
							strBulider.append("|" + MessageHelper.replaceLinkUrl(mdmObj.getString("DomainID"), PropertiesUtil.getGlobalProperties().getProperty("mobile.smart4j.path"),true)+ mdmObj.get("MobileURL").toString());
						} else {
							// [게시-새글등록알림] 연차사용 촉진 공지 - 경영관리팀 게시판
							// 2017.08.23 커뮤니티 회원메시지 경우 컨텐츠포함
							//if (mdmObj.getString("ServiceType").equalsIgnoreCase("Mail")) {
							//	strBulider.append(convertOutputValue(mdmObj.get("MessagingSubject").toString()) + "\"");
							//} else {
							if (mdmObj.getString("ServiceType").equalsIgnoreCase("Community") && mdmObj.getString("MsgType").equalsIgnoreCase("CuMemberContact") ){
								strBulider.append("[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType", mdmObj.get("MsgType").toString(), strLangType) + "] \"" + convertOutputValue(mdmObj.get("MessagingSubject").toString()) + " " + convertOutputValue(mdmObj.get("ReceiverText").toString()) + "\"");
							} else {
								if(strReCommentType != null && !"".equals(strReCommentType)) {//답글
									strBulider.append("[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType" , strReCommentType, strLangType) + "] \"" + convertOutputValue(mdmObj.get("MessagingSubject").toString()) + "\"");
								}else {
									strBulider.append("[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType" , mdmObj.get("MsgType").toString(), strLangType) + "] \"" + convertOutputValue(mdmObj.get("MessagingSubject").toString()) + "\"");
								}
							}

							if (  mdmObj.get("ObjectID") != null &&  !mdmObj.getString("ObjectID").isEmpty() && !mdmObj.getString("ObjectID").equals("0") && !mdmObj.getString("ObjectID").equals("null")  
									&& mdmObj.get("ObjectType") != null &&  !mdmObj.getString("ObjectType").isEmpty() && !mdmObj.getString("ObjectType").equals("0") && !mdmObj.getString("ObjectType").equals("null"))
							{
								strBulider.append(" - " + DicHelper.getDic(mdmObj.get("ObjectType").toString() + "_" + mdmObj.get("ObjectID").toString(), strLangType));
							}
							//}
						}
						
						//MDMUtils.SendPush_UserID
						
						//PUSH 전송전 badge 개수 조회 (통합알림 조건과 동일)
						CoviMap pushParam = new CoviMap();
						pushParam.put("userID", mdmObj.get("ReceiverCode"));
						
						//뱃지 카운트 조회
						String badgeCount = coviMapperOne.selectOne("messaging.selectBadgeCount", pushParam);
						
						/*if (MessageHelper.getInstance().sendPushByUserID(mdmObj.get("ReceiverCode").toString(), strBulider.toString(), badgeCount)){
							intOK++;
						} else {
							intFail++;
							listProcessTemp.put("ResultMessage", "Mobile Push 발송 실패!!");
						}*/
						MessageHelper.getInstance().sendPushByUserID(mdmObj.get("ReceiverCode").toString(), strBulider.toString(), badgeCount);
						intOK++;
					} catch (NullPointerException e) {
						LOGGER.error("sendMessaging MDM Error [ObjectCode : " +  "[Message : " +  e.getMessage() + "]");
						intFail++;
						listProcessTemp.put("ResultMessage", e.getMessage());
					} catch (Exception e) {
						LOGGER.error("sendMessaging MDM Error [ObjectCode : " +  "[Message : " +  e.getMessage() + "]");
						intFail++;
						listProcessTemp.put("ResultMessage", e.getMessage());
					} finally {
						/*
						LOGGER.info(" MDM listProcessTemp Count : " + listProcessTemp.size());
						LOGGER.info(" MESSAGE listProcess Count : " + listProcess.size());
						*/
						listProcess.add(listProcessTemp);
					}
				}

				// 성공 메세지
				strReturn.append("<OK><![CDATA[MDM(" + Integer.toString(intTotal) + ") OK:" + Integer.toString(intOK) + ", Fail:" + Integer.toString(intFail) + "]]></OK></result>");

				// 매체 전송 후 처리사항
				if (!(listProcess.isEmpty()) && listProcess.size() > 0){
					sentMessagingGroup(listProcess);
				}
				
			}//IIF - MDM
			
			//4. 이음 메신저 전송 (listMESSENGER)
			if(!(listMESSENGER.isEmpty()) && listMESSENGER.size() > 0) {
				
				intTotal = 0;
				intOK = 0;
				intFail = 0;
				strReturn.append("<result MediaType='MESSENGER'>");
				listProcess.clear();
				
				HttpClientUtil httpClient = new HttpClientUtil();
				String strLangType = "ko";
				String notificationMessenger = RedisDataUtil.getBaseConfig("UseNotificationMessenger");
				if(notificationMessenger == null || notificationMessenger.equals("") || notificationMessenger.equals("eumtalk")) {
					for(Object msg : listMESSENGER){
						CoviMap listProcessTemp = new CoviMap();
						try {
							intTotal++;
							strBulider.setLength(0);
							
							CoviMap paramsObj = new CoviMap();
							CoviMap targetObj = new CoviMap();
							CoviList targetArr = new CoviList();
							String eumServerUrl = RedisDataUtil.getBaseConfig("eumServerUrl");
							String eumNoticeKey = RedisDataUtil.getBaseConfig("eumNoticeKey");
							String eumNoticeType = RedisDataUtil.getBaseConfig("eumNoticeType");
							StringBuilder subStrBulider = new StringBuilder(100);
							
							CoviMap msgObj = new CoviMap();
							msgObj = (CoviMap) msg;
							
							String strServiceName = RedisDataUtil.getBaseCodeDic("TodoCategory" , msgObj.get("ServiceType").toString(), strLangType);
							if("CommunitySurvey".equals(msgObj.get("ServiceType"))) {
								msgObj.put("ServiceType", "Survey");
							}
							
							// 매체 전송 후 프로세스에 사용
							listProcessTemp.put("MessagingID", msgObj.get("MessagingID"));
							listProcessTemp.put("SubID", msgObj.get("SubID"));
							listProcessTemp.put("MediaType", msgObj.get("MediaType"));
							listProcessTemp.put("ResultMessage", "");
							
							// 수신자 언어 타입
							strLangType = msgObj.get("LanguageCode").toString();
							if(eumNoticeType.equals("LINK")){
								if (msgObj.getString("ServiceType").equalsIgnoreCase("Community") && msgObj.getString("MsgType").equalsIgnoreCase("CuMemberContact") ){
									subStrBulider.append("[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType" , msgObj.get("MsgType").toString(), strLangType) + "] " + convertOutputValue(msgObj.get("MessagingSubject").toString()) + " " + convertOutputValue(msgObj.get("ReceiverText").toString()));
								} else {
									subStrBulider.append("[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType" , msgObj.get("MsgType").toString(), strLangType) + "] " + convertOutputValue(msgObj.get("MessagingSubject").toString()));
								}
								
								if (  msgObj.get("ObjectID") != null &&  !msgObj.getString("ObjectID").isEmpty() && !msgObj.getString("ObjectID").equals("0") && !msgObj.getString("ObjectID").equals("null")  
										&& msgObj.get("ObjectType") != null &&  !msgObj.getString("ObjectType").isEmpty() && !msgObj.getString("ObjectType").equals("0") && !msgObj.getString("ObjectType").equals("null"))
								{
									subStrBulider.append(" - " + DicHelper.getDic(msgObj.get("ObjectType").toString() + "_" + msgObj.get("ObjectID").toString(), strLangType));
								}
								
								CoviMap jObj = new CoviMap();
								CoviMap jsonObj = new CoviMap();
								
								// eum sso 연결 url로 변경
								String eumPlanStr = msgObj.getString("ReceiverCode")+"|";
								String eumToken = "";
								try{
								    EUMAES aes = new EUMAES("", "M");
								    eumToken = aes.encrypt(eumPlanStr);
								} catch (NullPointerException e) {
									eumToken = "";
								} catch(Exception e){
									eumToken = "";
								}
								
								String gotoUrl =	msgObj.get("GotoURL").toString();
								if (!eumToken.equals("")){
									gotoUrl =	MessageHelper.replaceLinkUrl(msgObj.getString("DomainID"), PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"),false)+
											"/covicore/eumLogin.do?EumToken="+eumToken+
											"&ReturnURL="+	URLEncoder.encode(gotoUrl, "UTF-8").replaceAll("&amp;", "&");;
								}
								jsonObj.put("name", DicHelper.getDic("lbl_goToPage", strLangType));
								jsonObj.put("type", "link");
								jsonObj.put("data", gotoUrl);
								
								jObj.put("title", subStrBulider.toString());
								jObj.put("context", subStrBulider.toString());
								jObj.put("func", jsonObj);
								
								//strBulider.append("\"");
								strBulider.append(jObj.toString().replaceAll("\"", "\\\""));
								//strBulider.append("\"");
							}else{
								if (msgObj.getString("ServiceType").equalsIgnoreCase("Community") && msgObj.getString("MsgType").equalsIgnoreCase("CuMemberContact") ){
									strBulider.append("[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType" , msgObj.get("MsgType").toString(), strLangType) + "] " + convertOutputValue(msgObj.get("MessagingSubject").toString()) + " " + convertOutputValue(msgObj.get("ReceiverText").toString()));
								} else {
									strBulider.append("[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType" , msgObj.get("MsgType").toString(), strLangType) + "] " + convertOutputValue(msgObj.get("MessagingSubject").toString()));
								}
								
								if (  msgObj.get("ObjectID") != null &&  !msgObj.getString("ObjectID").isEmpty() && !msgObj.getString("ObjectID").equals("0") && !msgObj.getString("ObjectID").equals("null")  
										&& msgObj.get("ObjectType") != null &&  !msgObj.getString("ObjectType").isEmpty() && !msgObj.getString("ObjectType").equals("0") && !msgObj.getString("ObjectType").equals("null"))
								{
									strBulider.append(" - " + DicHelper.getDic(msgObj.get("ObjectType").toString() + "_" + msgObj.get("ObjectID").toString(), strLangType));
								}
							}
							
							targetObj.put("targetCode", msgObj.get("ReceiverCode"));
							targetObj.put("targetType", "UR");
							targetArr.add(targetObj);
							
							paramsObj.setConvertJSONObject(false);
							paramsObj.put("SubjectCode", eumNoticeKey);
							paramsObj.put("targets", targetArr);
							paramsObj.put("message", strBulider.toString());
							
							// EUM 알림 전송
							CoviMap result = new CoviMap();
							result = httpClient.httpRestAPIConnect(eumServerUrl+"/server/na/notice", "json", "POST", paramsObj.toString(), "");
	
							if(CoviMap.fromObject(result.toString()).getString("status").equals("SUCCESS")){
								intOK++;
							}else{
								intFail++;
							}
							
						} catch (NullPointerException e) {
							LOGGER.error("sendMessaging MESSENGER Error [ObjectCode : " +  "[Message : " +  e.getMessage() + "]");
							intFail++;
							listProcessTemp.put("ResultMessage", e.getMessage());
						} catch (Exception e) {
							LOGGER.error("sendMessaging MESSENGER Error [ObjectCode : " +  "[Message : " +  e.getMessage() + "]");
							intFail++;
							listProcessTemp.put("ResultMessage", e.getMessage());
						} finally {
							listProcess.add(listProcessTemp);
						}
					}
				}else if(notificationMessenger.equals("teams")){
					// Teams 알림 사용시
					for(Object msg : listMESSENGER){
						CoviMap listProcessTemp = new CoviMap();
						try {
							intTotal++;
							strBulider.setLength(0);
							
							CoviMap paramsObj = new CoviMap();
							CoviMap targetObj = new CoviMap();
							CoviList targetArr = new CoviList();
							String teamsServerUrl = RedisDataUtil.getBaseConfig("teamsServerUrl");
							StringBuilder subStrBulider = new StringBuilder(100);
							
							CoviMap msgObj = new CoviMap();
							msgObj = (CoviMap) msg;
							
							String strServiceName = RedisDataUtil.getBaseCodeDic("TodoCategory" , msgObj.get("ServiceType").toString(), strLangType);
	                        if("CommunitySurvey".equals(msgObj.get("ServiceType"))) {
	                        	msgObj.put("ServiceType", "Survey");
	                        }
							
							// 매체 전송 후 프로세스에 사용
							listProcessTemp.put("MessagingID", msgObj.get("MessagingID"));
							listProcessTemp.put("SubID", msgObj.get("SubID"));
							listProcessTemp.put("MediaType", msgObj.get("MediaType"));
							listProcessTemp.put("ResultMessage", "");
							
							// 수신자 언어 타입
							strLangType = msgObj.get("LanguageCode").toString();

							if (msgObj.getString("ServiceType").equalsIgnoreCase("Community") && msgObj.getString("MsgType").equalsIgnoreCase("CuMemberContact") ){
								subStrBulider.append("[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType" , msgObj.get("MsgType").toString(), strLangType) + "] " + convertOutputValue(msgObj.get("MessagingSubject").toString()) + " " + convertOutputValue(msgObj.get("ReceiverText").toString()));
							} else {
								subStrBulider.append("[" + strServiceName + "-" + RedisDataUtil.getBaseCodeDic("TodoMsgType" , msgObj.get("MsgType").toString(), strLangType) + "] " + convertOutputValue(msgObj.get("MessagingSubject").toString()));
							}
							
							if (  msgObj.get("ObjectID") != null &&  !msgObj.getString("ObjectID").isEmpty() && !msgObj.getString("ObjectID").equals("0") && !msgObj.getString("ObjectID").equals("null")  
									&& msgObj.get("ObjectType") != null &&  !msgObj.getString("ObjectType").isEmpty() && !msgObj.getString("ObjectType").equals("0") && !msgObj.getString("ObjectType").equals("null"))
							{
								subStrBulider.append(" - " + DicHelper.getDic(msgObj.get("ObjectType").toString() + "_" + msgObj.get("ObjectID").toString(), strLangType));
							}
							String strGotoURL = msgObj.getString("GotoURL");
							String strReserved1 = "";
							String strReserved2 = "";
							String strReserved3 = "";
							String strReserved4 = "";
							String strParam = "";
							int nTempIndex = -1;
							switch(msgObj.getString("MsgType").toUpperCase()) {
								case "APPROVAL_APPROVAL":
									strParam = "processid=";
                                    nTempIndex = strGotoURL.toLowerCase().indexOf(strParam);
                                    if (nTempIndex > -1)
                                    {
                                        nTempIndex += strParam.length();
                                        strReserved1 = strGotoURL.substring(nTempIndex);
                                        nTempIndex = strReserved1.indexOf("&");
                                        if (nTempIndex > -1)
                                        {
                                            strReserved1 = strReserved1.substring(0, nTempIndex);
                                        }
                                    }
									break;
								case "SCHEDULEATTENDANCE":
									strParam = "eventid=";
                                    nTempIndex = strGotoURL.toLowerCase().indexOf(strParam);
                                    if (nTempIndex > -1)
                                    {
                                        nTempIndex += strParam.length();
                                        strReserved1 = strGotoURL.substring(nTempIndex);
                                        nTempIndex = strReserved1.indexOf("&");
                                        if (nTempIndex > -1)
                                        {
                                            strReserved1 = strReserved1.substring(0, nTempIndex);
                                        }
                                    }
									break;
								case "APPROVALREQUEST_RESOURCE":
									strParam = "eventid=";
                                    nTempIndex = strGotoURL.toLowerCase().indexOf(strParam);
                                    if (nTempIndex > -1)
                                    {
                                        nTempIndex += strParam.length();
                                        strReserved1 = strGotoURL.substring(nTempIndex);
                                        nTempIndex = strReserved1.indexOf("&");
                                        if (nTempIndex > -1)
                                        {
                                            strReserved1 = strReserved1.substring(0, nTempIndex);
                                        }
                                    }
									strParam = "dateid=";
                                    nTempIndex = strGotoURL.toLowerCase().indexOf(strParam);
                                    if (nTempIndex > -1)
                                    {
                                        nTempIndex += strParam.length();
                                        strReserved2 = strGotoURL.substring(nTempIndex);
                                        nTempIndex = strReserved2.indexOf("&");
                                        if (nTempIndex > -1)
                                        {
                                            strReserved2 = strReserved2.substring(0, nTempIndex);
                                        }
                                    }
									strParam = "resourceid=";
                                    nTempIndex = strGotoURL.toLowerCase().indexOf(strParam);
                                    if (nTempIndex > -1)
                                    {
                                        nTempIndex += strParam.length();
                                        strReserved3 = strGotoURL.substring(nTempIndex);
                                        nTempIndex = strReserved3.indexOf("&");
                                        if (nTempIndex > -1)
                                        {
                                            strReserved3 = strReserved3.substring(0, nTempIndex);
                                        }
                                    }
									strParam = "isrepeateall=";
                                    nTempIndex = strGotoURL.toLowerCase().indexOf(strParam);
                                    if (nTempIndex > -1)
                                    {
                                        nTempIndex += strParam.length();
                                        strReserved4 = strGotoURL.substring(nTempIndex);
                                        nTempIndex = strReserved4.indexOf("&");
                                        if (nTempIndex > -1)
                                        {
                                            strReserved4 = strReserved4.substring(0, nTempIndex);
                                        }
                                    }
									break;
									
								default : break;
							}
							
							paramsObj.setConvertJSONObject(false);
							paramsObj.put("UR_Code", msgObj.get("ReceiverCode"));
							paramsObj.put("ServiceType",  msgObj.getString("ServiceType"));
							paramsObj.put("MsgType",  msgObj.getString("MsgType"));
							paramsObj.put("Title",  subStrBulider.toString());
							paramsObj.put("Message", msgObj.getString("ReceiverText"));
							paramsObj.put("URL",  strGotoURL);
							paramsObj.put("Width",  "1200");
							paramsObj.put("Height",  "800");
							paramsObj.put("Reserved1", strReserved1);
							paramsObj.put("Reserved2", strReserved2);
							paramsObj.put("Reserved3", strReserved3);
							paramsObj.put("Reserved4", strReserved4);

							// Teams 알림 전송
							CoviMap result = new CoviMap();
							result = httpClient.httpRestAPIConnect(teamsServerUrl+"/api/notify", "json", "POST", paramsObj.toString(), "");
	
							if(CoviMap.fromObject(result.toString()).getString("status").equals("SUCCESS")){
								intOK++;
							}else{
								intFail++;
							}
							
						} catch (NullPointerException e) {
							LOGGER.error("sendMessaging MESSENGER Error [ObjectCode : " +  "[Message : " +  e.getMessage() + "]");
							intFail++;
							listProcessTemp.put("ResultMessage", e.getMessage());
						} catch (Exception e) {
							LOGGER.error("sendMessaging MESSENGER Error [ObjectCode : " +  "[Message : " +  e.getMessage() + "]");
							intFail++;
							listProcessTemp.put("ResultMessage", e.getMessage());
						} finally {
							listProcess.add(listProcessTemp);
						}
					}
				}
				// 성공 메세지
				strReturn.append("<OK><![CDATA[MESSENGER(" + Integer.toString(intTotal) + ") OK:" + Integer.toString(intOK) + ", Fail:" + Integer.toString(intFail) + "]]></OK></result>");
				
				// 매체 전송 후 처리사항
				if (!(listProcess.isEmpty()) && listProcess.size() > 0){
					sentMessagingGroup(listProcess);
				}
			}//IIF - MESSENGER
			
		} catch (NullPointerException ex) {
			strReturn = new StringBuilder("<response><result><![CDATA[Fail:Reason:" + ex.getMessage() + "]]></result>");
			LOGGER.error("sendMessaging Error [ObjectCode : " +  "[Message : " +  ex.getMessage() + "]]");
			LOGGER.error(ex.getLocalizedMessage(), ex);
		} catch(Exception ex)
		{
			strReturn = new StringBuilder("<response><result><![CDATA[Fail:Reason:" + ex.getMessage() + "]]></result>");
			LOGGER.error("sendMessaging Error [ObjectCode : " +  "[Message : " +  ex.getMessage() + "]]");
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}
		
		if (strReturn.toString().equals("<response>"))
        {
            strReturn.append("처리할 메시징이 없습니다.");
        }
		
		strReturn.append("</response>");
		
		// 정상 발송된 수
		returnObj.put("Result", strReturn.toString());
		return returnObj;
	}

	public static String convertOutputValue(String pValue) {
		pValue = pValue.replaceAll("&amp;", "&");
		pValue = pValue.replaceAll("&lt;", "<");
		pValue = pValue.replaceAll("&gt;", ">");
		pValue = pValue.replaceAll("&quot;", "\"");
		pValue = pValue.replaceAll("&apos;", "'");
		pValue = pValue.replaceAll("&#x2F;", "\\");
		pValue = pValue.replaceAll("&nbsp;", " ");

		return pValue;
	}

	public static boolean isValidEmail(String pEmail) {
		return Pattern.matches("^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}"
				+ "\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\"
				+ ".)+))([a-zA-Z]{2,6}|[0-9]{1,3})(\\]?)$", pEmail);
	}

	public static boolean checkAllowTime(CoviMap jObject) throws Exception{
		String allowWeek = RedisDataUtil.getBaseConfig("MDMAllowWeek");
		String allowStart = RedisDataUtil.getBaseConfig("MDMAllowStartTime");
		String allowEnd = RedisDataUtil.getBaseConfig("MDMAllowEndTime");
		
		
		if (jObject.getString("PushAllowYN").equals("Y")){	//내것이 설정되어 있으면 내정보로
			allowWeek = jObject.getString("PushAllowWeek");
			allowStart = jObject.getString("PushAllowStartTime");
			allowEnd = jObject.getString("PushAllowEndTime");
		}
		
		String sFormat="yyyy-MM-dd HH:mm";
		String serverDate = ComUtils.TransLocalTime(ComUtils.GetLocalCurrentDate(sFormat), sFormat,jObject.getString("TimeZoneCode"));
		int iWeek = DateHelper.getDayOfWeek(serverDate, sFormat);
		String serverTime = ComUtils.removeMaskAll(serverDate.split(" ")[1]);
		
		if (allowWeek.substring(iWeek-2, iWeek-1).equals("0")) return false;
		if (Integer.parseInt(serverTime) < Integer.parseInt(allowStart) 
				|| Integer.parseInt(serverTime) > Integer.parseInt(allowEnd)) return false;
				
		return true;
	}

	
	@Override
	public CoviMap selectBaseCode() throws Exception {
		CoviMap params = new CoviMap();

		params.put("CodeGroup", "NotificationMedia");
		params.put("DomainID", "0");

		CoviList list = coviMapperOne.list("messaging.selectbasecode", params);

		CoviMap resultList = new CoviMap();
		resultList
				.put("list",
						CoviSelectSet
								.coviSelectJSON(
										list,
										"CodeID,BizSection,CodeGroup,Code,SortKey,IsUse,CodeName,MultiCodeName,Reserved1,Reserved2,Reserved3,ReservedInt,Description,RegisterCode,RegistDate,ModifierCode,ModifyDate"));
		return resultList;
	}

	
	@Override
	public int setMessagingType(CoviMap params) throws Exception{
		return coviMapperOne.insert("messaging.setMessagingType",params);

	}

	/// <summary>
    /// Mail Summery Items Node 생성
    /// </summary>
    /// <param name="pNodes">노드데이터 ex) 다국어키1†데이터다국어¶다국어키1†데이터다국어¶다국어키1†데이터다국어</param>
    /// <param name="LangType">사용자 언어 타입</param>
    /// <returns>Summery Item Nodes</returns>
    private void GetSummeryItemNodes(String pNodes, String pLangType, StringBuilder pBulder)
    {
        if (!pNodes.equals(""))
        {
            for(String str : pNodes.split("¶"))
            {
                if (!str.equals("") && str.split("†").length > 1)
                {
                    pBulder.append("<ITEM><SUMMARYNM><![CDATA[");
                    pBulder.append(DicHelper.getDic(str.split("†")[0], pLangType));
                    pBulder.append("]]></SUMMARYNM><SUMMARYV><![CDATA[");
                    pBulder.append(DicHelper.getDic(str.split("†")[1], pLangType));
                    pBulder.append("]]></SUMMARYV></ITEM>");
                }
            }
        }
    }

    //badge 개수 조회
    @Override
    public String selectBadgeCount(String pUserID) throws Exception{
    	CoviMap params = new CoviMap();
    	params.put("userID", pUserID);
    	return coviMapperOne.getString("messaging.selectBadgeCount", params);
    }
    
    // 발송 메시지 조회
 	@Override
 	public CoviMap selectMessagingList(CoviMap params) throws Exception {
 		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("messaging.selectMessagingListCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 		}

 		CoviList list = coviMapperOne.list("messaging.selectMessagingList", params);
 		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
 		
 		return resultList;
 	}
 	
 	/**
	 * deleteMessagingType : 메시지유형관리 삭제
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int deleteMessagingType(CoviMap params) throws Exception {
		int iReturn = 0;
		String DeleteMsgArr[] = null;

		try {
			DeleteMsgArr = params.getString("CodeID").split(";");
			for (String msgID : DeleteMsgArr) {
				params.put("CodeID", msgID);
				
				iReturn = coviMapperOne.delete("messaging.deletemsgtype", params);
			}

		} catch (NullPointerException ex) {
			LOGGER.error("deleteMessagingType Error [ObjectCode : "
					+ params.get("MessagingID") + "] " + "[Message : "
					+ ex.getMessage() + "]");
			LOGGER.error("deleteMessagingType Error [ObjectCode : "
					+ params.get("MessagingID") + "] ");
			LOGGER.error(ex.getLocalizedMessage(), ex);
		} catch (Exception ex) {
			LOGGER.error("deleteMessagingType Error [ObjectCode : "
					+ params.get("MessagingID") + "] " + "[Message : "
					+ ex.getMessage() + "]");
			LOGGER.error("deleteMessagingType Error [ObjectCode : "
					+ params.get("MessagingID") + "] ");
			LOGGER.error(ex.getLocalizedMessage(), ex);
		}

		return iReturn;
	}
 	
	/**
	 * 실시간 전송후 상태값 처리를 바로 하도록 함.
	 */
	@Override
	public int updateMsgCnt (CoviMap params) throws Exception {
		// 발송 건수 업데이트: 결과 대기 상태의 메세징 발송 대상자 수(SubTotalCount), 성공 건수(SendCount), 실패건수(FailCnt) 업데이트
		return coviMapperOne.update("messaging.updateMsgCnt", params);
	}
	
	@Override
	public int updateMsgFailCompeleteStatus (CoviMap params) throws Exception {
		// 완료 처리 (오류): 모든 대상 처리 완료한 메세징 완료 또는 오류로 상태 변경
		return coviMapperOne.update("messaging.updateMsgFailCompeleteStatus", params);
	}
	
	@Override
	public int updateMsgSendType (CoviMap params) throws Exception {
		return coviMapperOne.update("messaging.updatemsgsendtype", params);
	}

	@Override
	public int updateMsgThreadType(int messagingID) throws Exception {
		CoviMap param = new CoviMap();
		param.put("MessagingID", messagingID);
		return coviMapperOne.update("messaging.updateMsgThreadType", param);
	}
}
