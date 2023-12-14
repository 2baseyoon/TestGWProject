package egovframework.core.sevice.impl;

import java.net.URLDecoder;

import javax.annotation.Resource;



import egovframework.baseframework.util.json.JSONSerializer;

import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;

import egovframework.core.sevice.ControlSvc;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("controlService")
public class ControlSvcImpl extends EgovAbstractServiceImpl implements ControlSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public int selectLikeCount(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("common.control.selectLike", params);
	}
	
	/**
	 * 추가 시 데이터 Insert
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public int insertLike(CoviMap params)throws Exception {
		return coviMapperOne.insert("common.control.insertLike", params);
	}

	
	/**
	 * insertSubscription
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public int insertSubscription(CoviMap params)throws Exception {
		return coviMapperOne.insert("common.control.insertSubscription", params);
	}
	
	//추가 전 중복 체크
	@Override
	public int checkDuplicateSubscription(CoviMap params) throws Exception{
		return (int)coviMapperOne.getNumber("common.control.checkDuplicateSubscription", params);
	}
	
	//구독중인 폴더 내부 게시글, 일정글 조회
	@Override
	public CoviMap selectSubscriptionList(CoviMap params) throws Exception {
		CoviList clist = coviMapperOne.list("common.control.selectSubscriptionList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(clist, "SubscriptionID,PrimaryID,SecondaryID,TargetServiceType,TargetID,MenuID,Subject,Description,RegisterCode,FolderName,RegisterName,PhotoPath,RegistDate,CreateDate,CommentCnt,RecommendCnt,FileID,StartDate,EndDate,Place,IsRepeat,RepeatID"));
		return resultList;
	}
	
	//구독중인 폴더 목록 조회
	@Override
	public CoviMap selectSubscriptionFolderList(CoviMap params) throws Exception {
		CoviList clist = coviMapperOne.list("common.control.selectSubscriptionFolderList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(clist, "SubscriptionID,TargetServiceType,FolderID,FolderPath,FolderName"));
		return resultList;
	}
	
	//구독목록 삭제
	public int deleteSubscription(CoviMap params) throws Exception {
		return coviMapperOne.delete("common.control.deleteSubscription", params);
	}
	
	public int deleteSubscriptionAll(CoviMap params) throws Exception {
		return coviMapperOne.delete("common.control.deleteSubscriptionAll", params);
	}
	
	/***** 즐겨찾기 메뉴  *****/
	
	@Override
	public int insertFavoriteMenu(CoviMap params)throws Exception {
		return coviMapperOne.insert("common.control.insertFavoriteMenu", params);
	}
	
	//추가 전 중복 체크
	@Override
	public int checkDuplicateFavoriteMenu(CoviMap params) throws Exception{
		return (int)coviMapperOne.getNumber("common.control.checkDuplicateFavoriteMenu", params);
	}
	
	//구독중인 폴더 내부 게시글, 일정글 조회
	@Override
	public CoviMap selectFavoriteMenuList(CoviMap params) throws Exception {
		CoviList clist = coviMapperOne.list("common.control.selectFavoriteMenuList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(clist, "FavoriteID,TargetServiceType,TargetObjectType,TargetURL,TargetID,DisplayName,RegisterCode,FolderName,RegisterName,RegistDate,CreateDate,CommentCnt,RecommendCnt,FileID,StartDate,EndDate,Place,IsRepeat"));
		return resultList;
	}
	
	//즐겨찾기 메뉴 삭제
	public int deleteFavoriteMenu(CoviMap params) throws Exception {
		return coviMapperOne.delete("common.control.deleteFavoriteMenu", params);
	}
	
	//일정관리용 전체삭제
	public int deleteFavoriteMenuAll(CoviMap params) throws Exception {
		return coviMapperOne.delete("common.control.deleteFavoriteMenuAll", params);
	}
		

	/**
	 * 연락처 추가
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public int insertContact(CoviMap params)throws Exception {
		return coviMapperOne.insert("common.control.insertContact", params);
	}
	
	/**
	 * 연락처 삭제
	 * @param params - CoviMap (SelectedType, SelectedCode)
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public int deleteContact(CoviMap params)throws Exception {
		return coviMapperOne.delete("common.control.deleteContact", params);
	}
	
	@Override 
	public int checkDuplicateContact(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("common.control.checkDuplicateContact", params);
	}
	
	// 연락처 조회
	@Override
	public CoviMap selectContactNumberList(CoviMap params) throws Exception {
		String lang = SessionHelper.getSession("lang");
		params.put("lang", lang);
		
		CoviList clist = coviMapperOne.list("common.control.selectContactNumberList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(clist, "UserCode,SelectedCode,SelectedType,DisplayName,PhotoPath,MailAddress,Mobile,intPhoneNumber,intMobile,JobPositionName,infoText,MultiJobPositionName,MultiJobLevelName,MultiJobTitleName"));
		return resultList;
	}

	//퀵메뉴(즐겨찾기 메뉴) 설정 값 조회
	@Override
	public CoviMap selectQuickMenuConf(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		String strConfObj =  coviMapperOne.getString("common.control.selectUserQuickMenuConf", params);
		
		if(strConfObj != null && !strConfObj.equals("")){
			returnObj = CoviMap.fromObject(strConfObj);
		}
		
		return returnObj;
	}
	
	//퀵메뉴(즐겨찾기 메뉴) 설정 값 Update
	@Override
	public void updateUserConf(CoviMap params) throws Exception {
		coviMapperOne.update("common.control.updateUserQuickMenuConf", params);
	}

	//통합알림 목록 조회
	@Override
	public CoviList selectIntegratedList(CoviMap params) throws Exception {
		// 신규 알림 N 처리
		coviMapperOne.update("common.control.updateIntegratedIsNew", params);
		
		int limitCount = 0;
		try {
			String strLimitCount = RedisDataUtil.getBaseConfig("PortalAlarmLimitCnt");
			limitCount = Integer.parseInt(strLimitCount);
		}
		catch(NumberFormatException ex) {
			limitCount = 50;
		}
		catch(Exception ex) {
			limitCount = 50;
		}
		
		params.put("limitCount", limitCount);		
		CoviList clist = coviMapperOne.list("common.control.selectIntegratedList", params);
		 
		return CoviSelectSet.coviSelectJSON(clist, "AlarmID,Category,Title,URL,PusherCode,MsgType,PusherName,PusherJobLevel,ReceivedDate,IsRead,FormPrefix,Message,ReservedStr2");
	}
	
	//통합 알림 읽음 처리
	@Override
	public void updateAlarmIsRead(CoviMap params) throws Exception {
		coviMapperOne.update("common.control.updateAlarmIsRead", params);
	}

	//통합 알림 전체 삭제
	@Override
	public void deleteAllAlarm(CoviMap params) throws Exception {
		coviMapperOne.update("common.control.deleteAllAlarm", params);
	}
	
	@Override
	public void deleteEachAlarm(CoviMap params) throws Exception {
		coviMapperOne.update("common.control.deleteEachAlarm", params);
	}
	
	// Todo 조회
	@Override
	public CoviMap selectTodoList(CoviMap params) throws Exception {
		CoviList clist = coviMapperOne.list("common.control.selectTodoList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(clist, "TodoID,Title,URL,Description,IsComplete,ModifyDate,MessageType,modifyDateText"));
		return resultList;
	}
	
	// Todo 추가
	@Override
	public int insertTodo(CoviMap params)throws Exception {
		return coviMapperOne.insert("common.control.insertTodo", params);
	}
	
	// Todo 수정
	@Override
	public int updateTodo(CoviMap params) throws Exception {
		params.put("todoIdArr", params.getString("todoId").split("\\,"));
		
		return coviMapperOne.update("common.control.updateTodo", params);
	}
	
	// Todo 삭제
	@Override
	public void deleteTodo(CoviMap params) throws Exception {
		coviMapperOne.update("common.control.deleteTodo", params);
		
	}
		
    public int sendSimpleMail(CoviMap params) throws Exception{
    	String lang = SessionHelper.getSession("lang");
    	CoviList targetArray = (CoviList) JSONSerializer.toJSON(URLDecoder.decode(params.getString("receiverCode"), "utf-8"));
		
    	for(int i=0;i<targetArray.size();i++){
			CoviMap targetObj = targetArray.getJSONObject(i);
			
			String senderName = params.getString("senderName");
			String senderMail = params.getString("senderMail");
			String subject = params.getString("subject");
			String bodyText = params.getString("bodyText");
			MessageHelper.getInstance().sendSMTP(senderName, senderMail, targetObj.getString("ReceiverMail"), subject, bodyText, true); 
		}
    	return 0;
    }
    
    //재전송
    public boolean changePassword(CoviMap params) throws Exception{
    	String lang = SessionHelper.getSession("lang");
    	
    	boolean flag = false;
    	StringUtil func = new StringUtil();
    	
    	CoviMap userParams = new CoviMap();
    	CoviMap resultList = new CoviMap();
    	
    	int cnt = 0;
    	int error = 0;
    	
		boolean isSync = false;
		boolean IsSyncAD_MP = false;
		String apiURL = null;
		String sMode = "?job=modifyPass";
		
		userParams = (CoviMap) coviMapperOne.select("common.login.selectSSO", params); 
		/*String sDomain = null;*/
		String key = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key")); 
		params.put("id", userParams.getString("UR_Code"));

		String reMsg = "";
		
		try {
			cnt = coviMapperOne.update("common.control.changePassword", params);
			if(cnt > 0){
				
				String body = "TRUE";
				
				if(RedisDataUtil.getBaseConfig("isUseExchMail").equals("Y") && RedisDataUtil.getBaseConfig("isUseMail").equals("Y")) {
					IsSyncAD_MP = RedisDataUtil.getBaseConfig("PassADIsUse").equals("Y") ? true : false;
					if(IsSyncAD_MP)
					{
						
						// 토큰 발급 서비스 사용을 위한 param
						CoviMap param = new CoviMap();
						
						// param 세팅
						param.put("userID", userParams.getString("LogonID"));
						param.put("LogonID", userParams.getString("LogonID"));
						param.put("UserCode", userParams.getString("UR_Code"));
						param.put("isAdmin", "N");
						param.put("newPass", params.getString("LogonPassword"));
						param.put("SamAccountName", userParams.getString("UR_Mail").split("@")[0]);
						
						String pToken = ComUtils.jwtToken(param);
						
						String url = RedisDataUtil.getBaseConfig("Exch_mailSvcUrl") + "/WebSite/base/controls/externalwebservice.asmx";
						String bodydata = "<?xml version='1.0' encoding='utf-8'?>";
						bodydata += "<soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>";
						bodydata += "<soap:Body>";
						bodydata += "<SetADPassword xmlns='http://tempuri.org/'>";
						bodydata += "<pToken>"+pToken+"</pToken>";
						bodydata += "</SetADPassword>";
						bodydata += "</soap:Body>";
						bodydata += "</soap:Envelope>";
						
						HttpClientUtil httpClient = new HttpClientUtil();
						
						resultList = httpClient.httpClientNetConnect(url, bodydata, "POST");
						
						int status = (int) resultList.get("status");
						
						reMsg = resultList.get("body").toString().toLowerCase();
						
						/*if (status == 200 && (func.f_NullCheck(reMsg).equals("true") || func.f_NullCheck(reMsg).equals("success"))) {*/
						if (status == 200 && (reMsg.indexOf("true") > -1 || reMsg.indexOf("success") > -1)) {
							body = "TRUE";
						}else{
							body = "FLASE";
						}
						
					}
				} else {
					isSync = RedisDataUtil.getBaseConfig("IsSyncAD",userParams.get("DN_ID").toString()).equals("Y") ? true : false;			
					if(isSync)
					{
							/*String url = PropertiesUtil.getGlobalProperties().getProperty("password.service.url") + "?" + "pStrCN="+params.get("id").toString()
								+"&pStrOldPW="+userParams.getString("LogonPW")+"&pStrNewPW="+params.getString("LogonPassword");
						
							HttpClientUtil httpClient = new HttpClientUtil();
							
							resultList = httpClient.httpRestAPIConnect(url, "", "POST", "", "");*/
							
							String url = PropertiesUtil.getGlobalProperties().getProperty("password.service.url");
							String bodydata = "<?xml version='1.0' encoding='utf-8'?>";
							bodydata += "<soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>";
							bodydata += "<soap:Body>";
							bodydata += "<initADPassword xmlns='http://tempuri.org/'>";
							bodydata += "<userID>"+params.get("id").toString()+"</userID>";
							bodydata += "<logonPW>"+params.getString("LogonPassword")+"</logonPW>";
							bodydata += "</initADPassword>";
							bodydata += "</soap:Body>";
							bodydata += "</soap:Envelope>";
							
							HttpClientUtil httpClient = new HttpClientUtil();
							
							resultList = httpClient.httpClientNetConnect(url, bodydata, "POST");
							
							int status = (int) resultList.get("status");
							reMsg = resultList.get("body").toString().toLowerCase();
							
							if (status == 200 && (func.f_NullCheck(reMsg).equals("true") || func.f_NullCheck(reMsg).equals("success"))) {
								body = "TRUE";
							}else{
								body = "FLASE";
							}
					
					}
				}
				
				if (body.indexOf("TRUE") > -1 || body.indexOf("true") > -1) {
				
					isSync = RedisDataUtil.getBaseConfig("IsSyncIndi",userParams.get("DN_ID").toString()).equals("Y") ? true : false;
								
					if(isSync && userParams.getString("UseMailConnect").equals("Y"))
					{
						apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL", userParams.get("DN_ID").toString()) + sMode;
						
						/*sDomain = userParams.get("DomainURL").toString();*/
						
						String sLogonID = userParams.get("MailAddress").toString();
						
						//String sLogonPW = URLEncoder.encode(params.get("LogonPassword").toString(),"UTF-8");
						
						String sLogonPW = params.get("LogonPassword").toString();
/*						String sLogonPW = URLEncoder.encode(new String(Base64.encodeBase64(aes.encrypt(params.get("LogonPassword").toString()).getBytes())));
*/						
						if(!func.f_NullCheck(sLogonID).equals("")){
							String id = sLogonID.split("@")[0];
							String dn = sLogonID.split("@")[1];
							
							apiURL = apiURL + "&id="+id+"&domain="+dn+"&pw="+sLogonPW;
							
							//apiURL = apiURL + "&id="+sLogonID+"&pw="+sLogonPW;
							
							HttpURLConnectUtil url= new HttpURLConnectUtil();
							
							CoviMap jObj = url.httpConnect(apiURL,"POST",10000,10000,"xform","Y");
							
							if(jObj.get("returnCode").toString().equals("0")&&"SUCCESS".equals(jObj.get("returnMsg")))
							{
								flag = true;			
							}else
							{
								//2019.07 패스워드 자릴수 24 --> 8자리 제한 시 인디메일 패스워드 암복호화 오류 발생으로 무조건 true로 변경함
								//flag = false;
								flag = true;
							}
							
							url.httpDisConnect();
						}else{
							flag = true;	
						}
		
					}else{
						flag = true;		
					}
				}else{
					flag = false;
				}
			}else{
				flag = false;
			}
		
		}
		catch (DataAccessException e) {
			flag = false;
			error = 1;
		}
		catch (Exception e) {
			flag = false;
			error = 1;
		}
		finally{
			if(cnt > 0 && error == 0 && flag){
				params.put("adminCode", "SuperAdmin");
				
				String pw =  params.get("LogonPassword").toString();
				
				String bodyText = "";
				
				String receptionMail = params.get("receptionMail").toString();
				String receptionMobile = params.get("receptionMobile").toString();
				
				if(func.f_NullCheck(receptionMail).equals("Y")){
					bodyText = "<html>";
						bodyText += "<table width='100%' bgcolor='#ffffff' cellpadding='0' cellspacing='0' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.2em; color:#444; margin:0; padding:0;\">";
							bodyText += "<tbody>";
								bodyText += "<tr>";
									bodyText += "<td valign='middle' height='40' style='padding-left:26px;' bgcolor='#2b2e34'>";
										bodyText += "<table width='90%' height='50' cellpadding='0' cellspacing='0' style='background:url(mail_top.gif) no-repeat top left;'>";
											bodyText += "<tbody>";
												bodyText += "<tr>";
													bodyText += "<td style=\"font:bold 16px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">";
													bodyText += "System";
													bodyText += "</td>";
												bodyText += "</tr>";
											bodyText += "</tbody>";
										bodyText += "</table>";
									bodyText += "</td>";
								bodyText += "</tr>";	
								bodyText += "<tr>";
									bodyText += "<td bgcolor='#ffffff' style='padding:20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
										bodyText += "<table width='100%' cellpadding='0' cellspacing='0'>";
											bodyText += "<tbody>";
												bodyText += "<tr>";
													bodyText += "<td valign='bottom' bgcolor='#f9f9f9' style='padding:17px 0 5px 20px;'>";
														bodyText += "<span style=\"font:bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; color:#444;\">["+DicHelper.getDic("msg_tempPasswordGuidInfo",lang) +"]</span>";
													bodyText += "</td>";
												bodyText += "</tr>";
												bodyText += "<tr>";
													bodyText += "<td valign='bottom' bgcolor='#f9f9f9' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; padding:0 0 15px 20px; color:#444;\">";
														bodyText += (DicHelper.getDic("msg_tempPasswordResetComplete",lang)).replace("{0}", pw)+"<br>";
														bodyText += DicHelper.getDic("msg_afterLoginChangePassword",lang);
													bodyText += "</td>";
												bodyText += "</tr>";
											bodyText += "</tbody>";
										bodyText += "</table>";
									bodyText += "</td>";
								bodyText += "</tr>";
								bodyText += "<tr>";
									bodyText += "<td style='padding:0 0 20px 20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
										bodyText += "<div style='border-bottom:2px solid #f9f9f9; margin-right:20px;'>";
											bodyText += "<div style=\"font:normal 15px dotum,'돋움', Apple-Gothic,sans-serif;border-bottom:1px solid #c2c2c2; height:30px; line-height:30px;\">";
												bodyText += "<strong></strong>";
											bodyText += "</div>";
										bodyText += "</div>";
									bodyText += "</td>";
								bodyText += "</tr>";	
								bodyText += "<tr style='height:130px;'>";
									bodyText += "<td style='padding:0 20px 20px 20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
									bodyText += "</td>";
								bodyText += "</tr>";
								bodyText += "<tr>";
									bodyText += "<td align='center' valign='middle' height='109' bgcolor='' style='border:1px solid #d4d4d4; border-top:0;'>";
										bodyText += "<table cellpadding='0' cellspacing='0'>";
											bodyText += "<tbody>";
												bodyText += "<tr>";
													bodyText += "<td align='center' height='32'>";
														bodyText += "<span style=\"font:normal 12px dotum,'돋움'; color:#444444;\">"+(DicHelper.getDic("msg_PLZLogOnSmart",lang)).replace("{0}", RedisDataUtil.getBaseConfig("ApplicationName"))+"</span>";
													bodyText += "</td>";
												bodyText += "</tr>";
											bodyText += "</tbody>";
										bodyText += "</table>";
										bodyText += "<table width='140' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;'>";
											bodyText += "<tbody>";
												bodyText += "<tr>";
													bodyText += "<td align='center' height='36' style='cursor:pointer;'>";
														bodyText += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+MessageHelper.replaceLinkUrl(userParams.get("DN_ID").toString(), PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"),false)+"'>";
															bodyText += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
																bodyText += "<strong>"+DicHelper.getDic("btn_GWShortcut",lang)+"</strong>";
															bodyText += "</span>";
														bodyText += "</a>";
													bodyText += "</td>";
												bodyText += "</tr>";	
											bodyText += "</tbody>";	
										bodyText += "</table>";			
									bodyText += "</td>";					
								bodyText += "</tr>";			
								bodyText += "<tr>";
									bodyText += "<td align='center' valign='middle' height='25' style=\"font:normal 12px dotum,'돋움', Apple-Gothic, 맑은 고딕, Malgun Gothic,sans-serif; color:#a1a1a1;\">";
										bodyText += "Copyright <span style='font-weight:bold; color:#222222;'>"+PropertiesUtil.getGlobalProperties().getProperty("copyright")+"</span> Corp. All Rights Reserved.";
									bodyText += "</td>";
								bodyText += "</tr>";	
							bodyText += "</tbody>";
						bodyText += "</table>";
					bodyText += "</html>";
					
					
					
					LoggerHelper.auditLogger(params.get("id").toString(), "S", "SMTP", PropertiesUtil.getExtensionProperties().getProperty("mail.mailUrl"), bodyText, "ExternalMailAddress");
					MessageHelper.getInstance().sendSMTP(DicHelper.getDic("lbl_admin",lang), PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail"), params.getString("emailAddress"), DicHelper.getDic("msg_tempPasswordGuidInfo",lang), bodyText, true); 
				}
				
				if(func.f_NullCheck(receptionMobile).equals("Y")){
					String message = "";
					
					message = (DicHelper.getDic("msg_tempPasswordResetComplete",lang)).replace("{0}", pw);
					LoggerHelper.auditLogger(params.get("id").toString(), "S", "MDM", RedisDataUtil.getBaseConfigElement("MDM_ServiceURL", userParams.get("DN_ID").toString(), "SettingValue"), message, "");
					MessageHelper.getInstance().sendPushByUserID(params.get("id").toString(), message);
				}
			
			}
		}
		return flag;
    	
    }
    
    public int checkUserCnt(CoviMap params)throws Exception{
    	int cnt = 0;
    	
    	cnt = (int) coviMapperOne.getNumber("common.control.checkUserCnt", params);
    	
    	return cnt;
    }

	
    public int externalMailCnt(CoviMap params)throws Exception{
    	int cnt = 0;
    	
    	cnt = (int) coviMapperOne.getNumber("common.control.externalMailCnt", params);
    	
    	return cnt;
    }
    
    public CoviMap recentOTP(CoviMap params) throws Exception{   	
    	CoviMap returnObj = coviMapperOne.select("common.control.recentOTP", params);
		return returnObj;

    }
    
    public boolean createTwoFactor(CoviMap params) throws Exception{
    	boolean flag = false;
    
    	int cnt=0;
    	
    	cnt = (int) coviMapperOne.update("common.control.createTwoFactor", params);
		
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
    	
    	return flag;
    }
    
    /**
     * FIDO 요청정보 생성
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
    @Override
    public int createFido(CoviMap params) throws Exception{
    	String userCode = coviMapperOne.selectOne("fido.selectUserCode", params);
    	params.put("userCode", userCode);
    	return (int) coviMapperOne.insert("fido.createFido", params);
    }
    
    /**
     * FIDO 인증 상태 변경
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
    @Override
    public int updateFidoStatus(CoviMap params)throws Exception{
    	return (int) coviMapperOne.update("fido.updateFidoStatus", params);
    }
    
    /**
     * FIDO 인증상태 조회
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
    @Override
    public String selectFidoStatus(CoviMap params) throws Exception{
    	return coviMapperOne.selectOne("fido.selectFidoStatus", params);
    }
    
    /**
     * FIDO AuthToken 값 추가
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
    @Override
    public int updateAuthToken(CoviMap params) throws Exception {
    	return (int) coviMapperOne.update("fido.updateAuthToken", params);
    }

    
    //기기 사용여부 체크
    public boolean isUseDevice(CoviMap params)throws Exception{
    	boolean flag = false;
    	
    	return flag;
    }
    
    @Override
	public CoviMap selectObjectOne_UR(CoviMap params) throws Exception {
		CoviList clist = coviMapperOne.list("common.control.selectObjectOne_UR", params);
		CoviMap resultList = new CoviMap();
		
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		StringUtil func = new StringUtil();
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			resultList.put("list", CoviSelectSet.coviSelectJSON(clist, params.getString("fields").replaceAll("A.UserCode", "UserCode").replaceAll(" ", "").toUpperCase()));
		}
		else {
			resultList.put("list", CoviSelectSet.coviSelectJSON(clist, params.getString("fields").replaceAll("A.UserCode", "UserCode")));
		}
		
		return resultList;
	}
    
    @Override
	public CoviMap selectObjectOne_GR(CoviMap params) throws Exception {
		CoviList clist = coviMapperOne.list("common.control.selectObjectOne_GR", params);
		CoviMap resultList = new CoviMap();
		
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		StringUtil func = new StringUtil();
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			resultList.put("list", CoviSelectSet.coviSelectJSON(clist, params.getString("fields").replaceAll(" ", "").toUpperCase()));
		}
		else {
			resultList.put("list", CoviSelectSet.coviSelectJSON(clist, params.getString("fields")));
		}

		return resultList;
	}
    
    @Override
	public CoviMap selectObjectOne_DN(CoviMap params) throws Exception {
		CoviList clist = coviMapperOne.list("common.control.selectObjectOne_DN", params);
		CoviMap resultList = new CoviMap();
		
		String dbType = PropertiesUtil.getDBProperties().getProperty("db.mapper.one.sql");
		StringUtil func = new StringUtil();
		if(func.f_NullCheck(dbType).equals("oracle") || func.f_NullCheck(dbType).equals("tibero")){
			resultList.put("list", CoviSelectSet.coviSelectJSON(clist, params.getString("fields").replaceAll(" ", "").toUpperCase()));
		}
		else {
			resultList.put("list", CoviSelectSet.coviSelectJSON(clist, params.getString("fields")));
		}
		
		return resultList;
	}
}
