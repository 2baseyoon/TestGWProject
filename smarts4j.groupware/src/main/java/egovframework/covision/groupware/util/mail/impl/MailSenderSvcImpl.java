package egovframework.covision.groupware.util.mail.impl;

import com.google.gson.Gson;
import egovframework.baseframework.base.Enums;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import egovframework.covision.groupware.community.user.service.CommunityUserSvc;
import egovframework.covision.groupware.util.mail.MailSenderSvc;
import egovframework.covision.groupware.vacation.user.service.VacationSvc;


import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.net.URLDecoder;

@Service("mailSenderSvc")
public class MailSenderSvcImpl extends EgovAbstractServiceImpl implements MailSenderSvc {

    private static Logger LOGGER = LogManager.getLogger(MailSenderSvcImpl.class);

    final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

    @Autowired
    CommunityUserSvc communitySvc;

    @Autowired
    private MessageService messageSvc;

    @Autowired
    private VacationSvc vacationSvc;

    @Override
    public CoviMap SendMailVacationPromotionInfoNotice(CoviMap mailForm, CoviMap vacConfig) throws Exception
    {
        CoviMap returnList = new CoviMap();
        CoviMap params = new CoviMap();

        try {
            String senderName = vacConfig.getString("MailSenderName");
            String senderMail = vacConfig.getString("MailSenderAddr");

            //CHECKED:base_object_user에서 sys_object_user로 테이블이 변경 되면 세션 추출해서 사용
            //메일 전송 테스트용 ID의 경우 실제 운영서버에 존재 하지 않으면 에러 출력됨
            //String senderMail = "gypark@covision.co.kr";
            //receiverCode = "[{\"Type\":\"UR\",\"Code\":\"sunnyhwang2\"},{\"Type\":\"UR\",\"Code\":\"kimhy2\"}]";
            String receiverCode = mailForm.getString("ReceiverInfo");
            String receiverMailAddress = mailForm.getString("ReceiverMailAddress");

            String ReqType  = mailForm.getString("ReqType");
            String subject  = makeMailFormVacationPromotionTitle(ReqType, vacConfig);
            String bodyText = makeMailFormVacationPromotionContents(ReqType, vacConfig);
            String pageMoveBtnContents = makeMailFormVacationPromotionPageMoveContents(ReqType, vacConfig, subject);

            params.put("senderName", senderName);
            params.put("senderMail", senderMail);
            params.put("subject", subject);
            params.put("CU_ID", 68);
            params.put("Code", "Invited");

            CoviList targetArray = new Gson().fromJson(URLDecoder.decode(receiverCode, "utf-8").replaceAll("&quot;", "\""), CoviList.class);

            CoviMap req = new CoviMap();
            req.put("lang", SessionHelper.getSession("lang"));
            req.put("year", DateHelper.getCurrentDay("yyyy"));
            if(targetArray.size()>0) {
                CoviMap targetObj = targetArray.getJSONObject(0);
                req.put("urCode",targetObj.getString("Code"));
                String domainCode = SessionHelper.getSession("DN_Code");
                if(domainCode==null || domainCode.equals("")){
                    domainCode = mailForm.getString("domainCode");
                }
                req.put("domainCode",domainCode);
                req.put("domainID", SessionHelper.getSession("DN_ID"));
                req.put("lang","ko");
                req.put("localCurrentDate", ComUtils.GetLocalCurrentDate(ComUtils.ServerDateFullFormat)); //timezone 적용 현재시간
            }
            CoviList targetUserPromotionInfo = vacationSvc.getVacationPromotionTargetUserInfo(req);
            CoviMap targetUserVacData = vacationSvc.getVacationInfoForHome(req);
            CoviList targetUserVacDataArr = new CoviList();
            if(targetUserVacData!=null){
                targetUserVacDataArr = (CoviList) targetUserVacData.get("list");
            }
            //System.out.println("#####targetUserVacDataArr:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(targetUserVacDataArr));

            String EnterDate = "";
            String YYYY = "";
            String TYEAR = "";
            String UR_Name = "";
            String UR_JobPosition = "";
            String EXP_YYYYMMDD = "";
            String EXP_MMDD = "";
            String TotVacDay = "";
            String UseVacDay = "";
            String RemainVacDay = "";
            //OneDateFrom,OneDateTo,OneDateRange,TwoDateTo,
            // LessOneDate9From,LessOneDate9To,LessOneDate9Range,
            // LessTwoDate9To,
            // LessOneDate2From,LessOneDate2To,LessOneDate2Range,
            // LessTwoDate2To
            if(targetUserPromotionInfo.size()>0){
                CoviMap jsonObject = (CoviMap)targetUserPromotionInfo.get(0);

                //System.out.println("#####jsonObject:"+new Gson().newBuilder().setPrettyPrinting().create().toJson(jsonObject));
                EnterDate = jsonObject.getString("EnterDate");
                YYYY = jsonObject.getString("YYYY");
                TYEAR = jsonObject.getString("TYEAR");
                UR_Name = jsonObject.getString("UR_Name");
                UR_JobPosition = jsonObject.getString("JobPositionName");
                if(ReqType.equals("090")){//1년 미만 근로자 1차
                    EXP_YYYYMMDD = dateFormatChange(jsonObject.getString("LessVacDateTo"),"YYYY년 MM월 DD일");
                    EXP_MMDD = dateFormatChange(jsonObject.getString("LessVacDateTo"),"MM월 DD일");
                }else if(ReqType.equals("091")){//1년 미만 근로자 1차
                    EXP_YYYYMMDD = dateFormatChange(jsonObject.getString("LessOneDate9To"),"YYYY년 MM월 DD일");
                    EXP_MMDD = dateFormatChange(jsonObject.getString("LessOneDate9To"),"MM월 DD일");
                }else if(ReqType.equals("092")){//1년 미만 근로자(1차) 미지정자 통보
                    EXP_YYYYMMDD = dateFormatChange(jsonObject.getString("LessTwoDate9To"),"YYYY년 MM월 DD일");
                    EXP_MMDD = dateFormatChange(jsonObject.getString("LessTwoDate9To"),"MM월 DD일");
                }else if(ReqType.equals("021")){//1년 미만 근로자 2차
                    EXP_YYYYMMDD = dateFormatChange(jsonObject.getString("LessOneDate2To"),"YYYY년 MM월 DD일");
                    EXP_MMDD = dateFormatChange(jsonObject.getString("LessOneDate2To"),"MM월 DD일");
                }else if(ReqType.equals("022")){//1년 미만 근로자 2차
                    EXP_YYYYMMDD = dateFormatChange(jsonObject.getString("LessTwoDate2To"),"YYYY년 MM월 DD일");
                    EXP_MMDD = dateFormatChange(jsonObject.getString("LessTwoDate2To"),"MM월 DD일");
                }else if(ReqType.equals("100")){//1년 이상 근로자
                    EXP_YYYYMMDD = dateFormatChange(jsonObject.getString("VacDateTo"),"YYYY년 MM월 DD일");
                    EXP_MMDD = dateFormatChange(jsonObject.getString("VacDateTo"),"MM월 DD일");
                }else if(ReqType.equals("101")){//1년 이상 근로자
                    EXP_YYYYMMDD = dateFormatChange(jsonObject.getString("OneDateTo"),"YYYY년 MM월 DD일");
                    EXP_MMDD = dateFormatChange(jsonObject.getString("OneDateTo"),"MM월 DD일");
                }else if(ReqType.equals("102")){//1년 이상 근로자
                    EXP_YYYYMMDD = dateFormatChange(jsonObject.getString("TwoDateTo"),"YYYY년 MM월 DD일");
                    EXP_MMDD = dateFormatChange(jsonObject.getString("TwoDateTo"),"MM월 DD일");
                }
            }

            if(targetUserVacDataArr.size()>0){
                CoviMap vacDataObj = (CoviMap) targetUserVacDataArr.get(0);
                TotVacDay = vacDataObj.getString("VacDay");
                UseVacDay = vacDataObj.getString("VacDayUse");
                RemainVacDay = vacDataObj.getString("RemainVacDay");
            }

            String returnStr = bodyText;
            returnStr = returnStr.replaceAll("&gt;", ">");
            returnStr = returnStr.replaceAll("&lt;", "<");
            //#{YYYY} #{UR_Name} #{EXP_YYYYMMDD} #{EXP_MMDD} #{TotVacDay} #{UseVacDay} #{RemainVacDay}
            if(returnStr.contains("#YYYY")){
                returnStr = returnStr.replaceAll("#YYYY",YYYY);
            }
            if(returnStr.contains("#EnterDate")){
                returnStr = returnStr.replaceAll("#EnterDate",EnterDate);
            }
            if(returnStr.contains("#TYEAR")){
                returnStr = returnStr.replaceAll("#TYEAR",TYEAR);
            }
            if(returnStr.contains("#UR_Name")){
                returnStr = returnStr.replaceAll("#UR_Name",UR_Name);
            }
            if(returnStr.contains("#UR_JobPosition")){
                returnStr = returnStr.replaceAll("#UR_JobPosition",UR_JobPosition);
            }
            if(returnStr.contains("#EXP_YYYYMMDD")){
                returnStr = returnStr.replaceAll("#EXP_YYYYMMDD",EXP_YYYYMMDD);
            }
            if(returnStr.contains("#EXP_MMDD")){
                returnStr = returnStr.replaceAll("#EXP_MMDD",EXP_MMDD);
            }
            if(returnStr.contains("#TotVacDay")){
                returnStr = returnStr.replaceAll("#TotVacDay",TotVacDay);
            }
            if(returnStr.contains("#UseVacDay")){
                returnStr = returnStr.replaceAll("#UseVacDay",UseVacDay);
            }
            if(returnStr.contains("#RemainVacDay")){
                returnStr = returnStr.replaceAll("#RemainVacDay",RemainVacDay);
            }

            String bodyTextStr = "";
            bodyTextStr = "<html>";
            bodyTextStr += "<table width='100%' bgcolor='#ffffff' cellpadding='0' cellspacing='0' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.2em; color:#444; margin:0; padding:0;\">";
            bodyTextStr += "<tbody>";
            bodyTextStr += "<tr>";
            bodyTextStr += "<td valign='middle' height='40' style='padding-left:26px;' bgcolor='#2b2e34'>";
            bodyTextStr += "<table width='90%' height='50' cellpadding='0' cellspacing='0' style='background:url(mail_top.gif) no-repeat top left;'>";
            bodyTextStr += "<tbody>";
            bodyTextStr += "<tr>";
            bodyTextStr += "<td style=\"font:bold 16px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">";
            bodyTextStr += subject;
            bodyTextStr += "</td>";
            bodyTextStr += "</tr>";
            bodyTextStr += "</tbody>";
            bodyTextStr += "</table>";
            bodyTextStr += "</td>";
            bodyTextStr += "</tr>";

            bodyTextStr += "<tr>";
            bodyTextStr += "<td style='padding:0 0 20px 20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
            bodyTextStr += "<div style='border-bottom:2px solid #f9f9f9; margin-right:20px;'>";
            bodyTextStr += "<div style=\"font:normal 15px dotum,'돋움', Apple-Gothic,sans-serif;border-bottom:1px solid #c2c2c2; height:30px; line-height:30px;\">";
            bodyTextStr += "<strong></strong>";
            bodyTextStr += "</div>";
            bodyTextStr += "</div>";
            bodyTextStr += "</td>";
            bodyTextStr += "</tr>";

            bodyTextStr += "<tr>";
            bodyTextStr += "<td align='left' valign='middle' height='109' bgcolor='' style='padding-left: 25px; border:1px solid #d4d4d4; border-top:0;'>";
            bodyTextStr += "<table cellpadding='0' cellspacing='0'>";
            bodyTextStr += "<tbody>";
            bodyTextStr += "<tr>";
            bodyTextStr += "<td align='center' height='32'>";
            bodyTextStr += "<span style=\"font:normal 12px dotum,'돋움'; color:#444444;\">"+returnStr+"</span>";
            bodyTextStr += "</td>";
            bodyTextStr += "</tr>";
            bodyTextStr += "</tbody>";
            bodyTextStr += "</table>";
            bodyTextStr += pageMoveBtnContents;
            bodyTextStr += "<br/></td>";
            bodyTextStr += "</tr>";
            bodyTextStr += "<tr>";
            bodyTextStr += "<td align='center' valign='middle' height='25' style=\"font:normal 12px dotum,'돋움', Apple-Gothic, 맑은 고딕, Malgun Gothic,sans-serif; color:#a1a1a1;\">";
            bodyTextStr += "Copyright <span style='font-weight:bold; color:#222222;'>"+ PropertiesUtil.getGlobalProperties().getProperty("copyright")+"</span> Corp. All Rights Reserved.";
            bodyTextStr += "</td>";
            bodyTextStr += "</tr>";
            bodyTextStr += "</tbody>";
            bodyTextStr += "</table>";
            bodyTextStr += "</html>";

            params.put("bodyText", bodyTextStr);

            /*System.out.println("#####senderName:"+senderName);
            System.out.println("#####senderMail:"+senderMail);
            System.out.println("#####receiverMailAddress:"+receiverMailAddress);
            System.out.println("#####subject:"+subject);*/
            //System.out.println("#####bodyText:"+bodyText);

            //communitySvc.communitySendSimpleMail(params);
           if(!MessageHelper.getInstance().sendSMTP(senderName, senderMail, receiverMailAddress, subject, bodyTextStr, true)){
                LOGGER.debug("SendMailVacationPromotionInfoNotice Failed");
               returnList.put("status", Enums.Return.FAIL);
               returnList.put("message", DicHelper.getDic("msg_FailedToSend"));
                return  returnList;
            }
            //알람 처리 미개발
            /*
            CoviMap FolderParams = new CoviMap();
            List list = new ArrayList();

            //TODO-COMMUNITY
            for(int i=0;i<targetArray.size();i++){
                CoviMap targetObj = targetArray.getJSONObject(i);

                params.put("musercode", targetObj.get("Code"));
                params.put("lang", "ko");

                list = communitySvc.sendMessagingListAdmin(params);

                if(list.size() > 0){
                    for(int j = 0; j < list.size(); j ++){
                        FolderParams = (CoviMap) list.get(j);

                        FolderParams.put("Category", "Community");
                        FolderParams.put("Title", "커뮤니티 : "+FolderParams.get("CommunityName")+" 커뮤니티 초대");
                        FolderParams.put("Message", FolderParams.get("CommunityName")+ "커뮤니티 초대 알림");
                        FolderParams.put("URL", "/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=user&CLBIZ=Community");
                        notifyCommunityAlarm(FolderParams);
                    }
                }
            }*/

            returnList.put("status", Enums.Return.SUCCESS);
            returnList.put("message", DicHelper.getDic("msg_Mail_SentMail"));
        } catch (NullPointerException ex) {
            LOGGER.debug("SendMailVacationPromotionInfoNotice Failed [" + ex.getMessage() + "]");
            LOGGER.error(ex.getLocalizedMessage(), ex);
            returnList.put("status", Enums.Return.FAIL);
            returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage(): DicHelper.getDic("msg_FailedToSend"));
        } catch (Exception ex) {
            LOGGER.debug("SendMailVacationPromotionInfoNotice Failed [" + ex.getMessage() + "]");
            LOGGER.error(ex.getLocalizedMessage(), ex);
            returnList.put("status", Enums.Return.FAIL);
            returnList.put("message", isDevMode.equalsIgnoreCase("Y")?ex.getMessage(): DicHelper.getDic("msg_FailedToSend"));
        }
        return returnList;
    }

    //날짜 출력 양식
    public String dateFormatChange(String date, String format){
        String rtn = format;
        String[] arrDate = date.split("-");
        rtn = rtn.replace("YYYY",arrDate[0]);
        rtn = rtn.replace("MM",arrDate[1]);
        rtn = rtn.replace("DD",arrDate[2]);
        return rtn;
    }

    //커뮤니티 알림 메시지 Parameter 셋팅
    public void notifyCommunityAlarm(CoviMap pNotifyParam) throws Exception {
        CoviMap notiParam = new CoviMap();
        notiParam.put("ObjectType", "CU");
        notiParam.put("ServiceType", "Community");
        notiParam.put("MsgType", pNotifyParam.get("Code"));						//커뮤니티 알림 코드
        notiParam.put("PopupURL", pNotifyParam.getString("URL"));
        notiParam.put("GotoURL", pNotifyParam.getString("URL"));
        notiParam.put("MobileURL", pNotifyParam.getString("MobileURL"));
        notiParam.put("OpenType", "PAGEMOVE");									//페이지 이동 처리
        notiParam.put("MessagingSubject", pNotifyParam.getString("Title"));
        notiParam.put("MessageContext", pNotifyParam.get("Message"));
        notiParam.put("ReceiverText", pNotifyParam.getString("Message"));
        notiParam.put("SenderCode", SessionHelper.getSession("USERID"));		//송신자 (세션 값 참조)
        notiParam.put("RegistererCode", SessionHelper.getSession("USERID"));
        notiParam.put("ReceiversCode", pNotifyParam.getString("UserCode"));		//조회된 수신자 코드
        notiParam.put("DomainID", SessionHelper.getSession("DN_ID"));
        MessageHelper.getInstance().createNotificationParam(notiParam);
        messageSvc.insertMessagingData(notiParam);
    }

    //연차 촉진 메일 발송 요청 타입별 타이틀 생성
    public String makeMailFormVacationPromotionTitle(String reqType, CoviMap vacConfig){
        String titleString = "";
        if(reqType.equals("090")){//1년 미만 근로자 1차
            titleString = vacConfig.getString("FormTitle090");
        }else if(reqType.equals("091")){//1년 미만 근로자 1차
            titleString = vacConfig.getString("FormTitle091");
        }else if(reqType.equals("092")){//1년 미만 근로자(1차) 미지정자 통보
            titleString = vacConfig.getString("FormTitle092");
        }else if(reqType.equals("021")){//1년 미만 근로자 2차
            titleString = vacConfig.getString("FormTitle021");
        }else if(reqType.equals("022")){//1년 미만 근로자 2차
            titleString = vacConfig.getString("FormTitle022");
        }else if(reqType.equals("100")){//1년 이상 근로자
            titleString = vacConfig.getString("FormTitle100");
        }else if(reqType.equals("101")){//1년 이상 근로자
            titleString = vacConfig.getString("FormTitle101");
        }else if(reqType.equals("102")){//1년 이상 근로자
            titleString = vacConfig.getString("FormTitle102");
        }
        return titleString;
    }

    //연차 촉진 메일 발송 요청 타입별 내용 생성
    public String makeMailFormVacationPromotionContents(String reqType, CoviMap vacConfig){
        String body = "";
        if(reqType.equals("090")){//1년 미만 근로자 1차
            body = vacConfig.getString("FormBody090");
        }else if(reqType.equals("091")){//1년 미만 근로자 1차
            body = vacConfig.getString("FormBody091");
        }else if(reqType.equals("092")){//1년 미만 근로자(1차) 미지정자 통보
            body = vacConfig.getString("FormBody092");
        }else if(reqType.equals("021")){//1년 미만 근로자 2차
            body = vacConfig.getString("FormBody021");
        }else if(reqType.equals("022")){//1년 미만 근로자 2차
            body = vacConfig.getString("FormBody022");
        }else if(reqType.equals("100")){//1년 이상 근로자
            body = vacConfig.getString("FormBody100");
        }else if(reqType.equals("101")){//1년 이상 근로자
            body = vacConfig.getString("FormBody101");
        }else if(reqType.equals("102")){//1년 이상 근로자
            body = vacConfig.getString("FormBody102");
        }
        return body;
    }

    //연차 촉진 타입별 바로가기 링크 주소 생성
    public String makeMailFormVacationPromotionPageMoveContents(String reqType, CoviMap vacConfig, String subject){
        String year = ComUtils.GetLocalCurrentDate("yyyy");
        String html = "";
        String link = "";
        String link2 = "";
        if(reqType.equals("090")){//1년 미만 근로자(1차) 미지정자 통보
            link = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=plan&empType=newEmp";
            html += "<table align='center' width='630' cellpadding='0' cellspacing='0' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='right' height='36' style='cursor:pointer;'>";
            html += "<table align='center' width='300' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>연차 유급휴가 일수 알림 및 사용계획서</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
        }else if(reqType.equals("091")){//1년 미만 근로자 1차
            link = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=request&empType=newEmpForNine";
            link2 = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=notification1&empType=newEmpForNine";
            html += "<table align='center' width='630' cellpadding='0' cellspacing='0' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='right' height='36' style='cursor:pointer;'>";
            html += "<table align='center' width='300' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>미사용 연차 유급휴가 일수 알림 및 사용시기 지정 요청서</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";

            html += "</td>";
            html += "<td align='left' width='10' height='36'>";
            html += "</td>";
            html += "<td align='left' height='36' style='cursor:pointer;'>";

            html += "<table align='center' width='280' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link2+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>연차 유급휴가 사용시기 작성 바로가기</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
        }else if(reqType.equals("092")){//1년 미만 근로자(1차) 미지정자 통보
            link = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=notification2&empType=newEmpForNine";
            html += "<table align='center' width='630' cellpadding='0' cellspacing='0' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='right' height='36' style='cursor:pointer;'>";
            html += "<table align='center' width='500' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>미사용 연차 유급휴가 사용시기 지정 통보 확인</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
        }else if(reqType.equals("021")){//1년 미만 근로자 2차
            link = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=request&empType=newEmpForTwo";
            link2 = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=notification1&empType=newEmpForTwo";
            html += "<table align='center' width='730' cellpadding='0' cellspacing='0' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='right' height='36' style='cursor:pointer;'>";
            html += "<table align='center' width='400' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>미사용 연차 유급휴가 일수 알림 및 사용시기 지정 요청서</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";

            html += "</td>";
            html += "<td align='left' width='10' height='36'>";
            html += "</td>";
            html += "<td align='left' height='36' style='cursor:pointer;'>";

            html += "<table align='center' width='280' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link2+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>연차 유급휴가 사용시기 작성 바로가기</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
        }else if(reqType.equals("022")){//1년 미만 근로자 2차
            link = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=notification2&empType=newEmpForTwo";
            html += "<table align='center' width='630' cellpadding='0' cellspacing='0' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='right' height='36' style='cursor:pointer;'>";
            html += "<table align='center' width='400' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>미사용 연차 유급휴가 사용시기 지정 통보 확인</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
        }else if(reqType.equals("100")){//1년 이상 근로자
            link = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=plan&empType=normal";
            html += "<table align='center' width='630' cellpadding='0' cellspacing='0' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='right' height='36' style='cursor:pointer;'>";
            html += "<table align='center' width='300' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>연차 유급휴가 일수 알림 및 연차사용계획서</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
        }else if(reqType.equals("101")){//1년 이상 근로자 1차
            link = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=request&empType=normal";
            link2 = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=notification1&empType=normal";
            html += "<table align='center' width='630' cellpadding='0' cellspacing='0' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<table align='center' width='630' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>미사용 연차 유급휴가 일수 알림 및 사용시기 지정 요청서</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";

            html += "<td align='left' width='10' height='36'  bgcolor='#ffffff'>&nbsp;";
            html += "</td>";

            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link2+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>연차 유급휴가 사용시기 작성 바로가기</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";

            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";

        }else if(reqType.equals("102")){//1년 이상 근로자
            link = "/groupware/vacation/goVacationPromotionPopup.do?year="+year+"&viewType=user&formType=notification2&empType=normal";
            html += "<table align='center' width='630' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='right' height='36' style='cursor:pointer;'>";
            html += "<table align='center' width='500' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;margin-top: 5px;padding: 0 15px 0 15px;'>";
            html += "<tbody>";
            html += "<tr>";
            html += "<td align='center' height='36' style='cursor:pointer;'>";
            html += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+link+"'>";
            html += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
            html += "<strong>미사용 연차 유급휴가 사용시기 지정 통보 확인</strong>";
            html += "</span>";
            html += "</a>";
            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";

            html += "</td>";
            html += "</tr>";
            html += "</tbody>";
            html += "</table>";
        }
        return html;
    }

}
