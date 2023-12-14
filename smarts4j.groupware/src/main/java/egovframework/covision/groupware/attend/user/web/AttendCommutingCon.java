package egovframework.covision.groupware.attend.user.web;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.attend.user.service.AttendAdminSettingSvc;
import egovframework.covision.groupware.attend.user.service.AttendCommonSvc;
import egovframework.covision.groupware.attend.user.service.AttendCommutingSvc;
import egovframework.covision.groupware.attend.user.service.AttendReqSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;
import egovframework.covision.groupware.attend.user.util.IpCheckUtils;

@Controller
@RequestMapping("/attendCommute")
public class AttendCommutingCon {
	
	private Logger LOGGER = LogManager.getLogger(AttendCommutingCon.class);
	
	
	@Autowired
	AttendCommutingSvc attendCommutingSvc;
	
	@Autowired
	AttendReqSvc attendReqSvc;
	@Autowired
	AttendAdminSettingSvc attendAdminSettingSvc;
	@Autowired
	AttendCommonSvc attendCommonSvc;

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**  
	  * @Method Name : setCommute
	  * @작성일 : 2020. 4. 13.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 출/퇴근 처리  ( 현재시간  ) 
	  * 		Channel 별 사용여부 / IP 제한 / 좌표 제한
	  * @param request
	  * @param response
	  * @return 
	  * @throws Exception 
	  */
	@RequestMapping(value = "/setCommute.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setCommute(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		try {
			String commuteType = request.getParameter("commuteType");//출근(S)퇴근(E)
			//String commuteTime = request.getParameter("commuteTime");//출퇴근시간
			String commuteTime =  ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss");//출퇴근 시간 ( 현재시간 ( TIMEZONE) )
			String commuteChannel = request.getParameter("commuteChannel");//출퇴근 구분 ( W/M/S )
			String commutePointX = request.getParameter("commutePointX");
			String commutePointY = request.getParameter("commutePointY");
			String commuteChangeYn = request.getParameter("commuteChangeYn")==null?"N":request.getParameter("commuteChangeYn");
			String commuteIp = request.getHeader("X-FORWARDED-FOR");
			
			String companyCode = SessionHelper.getSession("DN_Code");
			String userCode = SessionHelper.getSession("USERID");
			String targetDate = request.getParameter("targetDate");
			
			if (commuteIp == null){ commuteIp = request.getRemoteAddr(); }
			
			CoviMap mngMstObj = attendAdminSettingSvc.getAttendMngMst();
			
			/**
			 * attendance mng mst 기본 출 퇴근 설정 정보 확인
			 * */
			String attSeq = mngMstObj.getString("AttSeq");
			String pcUseYn = mngMstObj.getString("PcUseYn");	//pc사용여부
			String mobileUseYn = mngMstObj.getString("MobileUseYn");	//mobile사용여부
			String othYn = mngMstObj.getString("OthYn");	//secom if 사용여부
			String ipYn = mngMstObj.getString("IpYn");	//아이피 제한 사용여부
			
			/**
			 * channel 별 사용 여부 활성화 확인
			 * */
			boolean commuteFlag = false;
			CoviMap channelObj = channelCheck(commuteChannel,pcUseYn,mobileUseYn,othYn);
			if(channelObj.getBoolean("result")){
				/** 
				 * ip제한 확인
				 * */
				if("Y".equals(ipYn)){ 
					//ip제한 리스트
					CoviMap ipParams = new CoviMap();
					ipParams.put("AttSeq", attSeq);
					CoviList ipList = attendAdminSettingSvc.getIpList(ipParams);
					
					for(int i=0;i<ipList.size();i++){
						CoviMap ipObj = ipList.getMap(i);
						String sIp = ipObj.getString("SIp");
						String eIp = ipObj.getString("EIp");
						String PcUsedYn = ipObj.getString("PcUsedYn");	//pc 제한 여부
						String MobeilUsedYn = ipObj.getString("MobileUsedYn"); //mobile 제한 여부
						
						if(
								("W".equals(commuteChannel)&&"Y".equals(PcUsedYn))	//PC출퇴근 시 PC 제한
								||("M".equals(commuteChannel)&&"Y".equals(MobeilUsedYn))) //MOBILE출퇴근 시  MOBILE 제한
						{
							if(IpCheckUtils.ipRangeCheck(sIp,eIp,commuteIp)){
								commuteFlag = true;
								break;
							}
						}
					}
				}else{
					commuteFlag = true;
				} 
			}else{
				//channel 별 사용 여부 활성화 확인
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", channelObj.getString("msg"));
				return returnObj;
			}

			if(commuteFlag){
				CoviMap params = new CoviMap();
				params.put("CommuteType",commuteType);
				params.put("CompanyCode",companyCode);
				params.put("UserCode",userCode);
				params.put("RegUserCode",userCode);
				params.put("TargetDate",targetDate);
 
				if("S".equals(commuteType)){
					//출근
					params.put("StartTime",commuteTime);
					params.put("StartChannel",commuteChannel);
					params.put("StartPointX",commutePointX);
					params.put("StartPointY",commutePointY);
					params.put("StartIpAddr",commuteIp);
					params.put("StartChangeYn",commuteChangeYn);
					
				}else if("E".equals(commuteType)){
					//퇴근
					params.put("EndTime",commuteTime);
					params.put("EndChannel",commuteChannel);
					params.put("EndPointX",commutePointX);
					params.put("EndPointY",commutePointY);
					params.put("EndIpAddr",commuteIp);
					params.put("EndChangeYn",commuteChangeYn);
				}
				
				/**
				 * 좌표 제한 확인
				 * 근무 일정 직출/직퇴 가능 거리 확인  (모바일 제한 )
				 * */
				if("M".equals(commuteChannel)){
					if (RedisDataUtil.getBaseConfig("AttendanceMobileMapUsedYn").equals("Y")){
						CoviMap pointObj = attendCommutingSvc.chkCommuteAllowRadius(companyCode,userCode,targetDate,commuteType,commutePointX,commutePointY);
						if(!"SUCCESS".equals(pointObj.getString("status"))){
							returnObj.put("status", Return.FAIL); 
							returnObj.put("message", pointObj.get("msg"));
							returnObj.put("type", pointObj.get("type"));
							return returnObj;
						} 
					}	
				}
				
				//attendance commuting history 저장 
				CoviMap resultCommute = attendCommutingSvc.setCommuteTime(params);
				
				/*출퇴근 불가*/   
				if(!"SUCCESS".equals(resultCommute.getString("status"))){
					returnObj.put("status", Return.FAIL); 
					returnObj.put("message", resultCommute.getString("msg"));
					return returnObj; 
				}   
				
				returnObj.put("status", Return.SUCCESS); 
				return returnObj;
			}else{ 
				//channel 별 사용 여부 활성화 확인
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", DicHelper.getDic("msg_n_att_ipNotUsed")); //사용 가능한 IP대역을 벗어났습니다.
				return returnObj; 
			}
			 
		} catch(NullPointerException e) { 
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			return returnObj;
		} catch(Exception e) { 
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
			return returnObj;
		}
	}
	
	/**
	  * @Method Name : channelCheck
	  * @작성일 : 2020. 4. 13.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 채널 사용 가능 정보 조회
	  * @param channel
	  * @param pcUseYn
	  * @param mobileUseYn
	  * @param othYn
	  * @return
	  */
	public CoviMap channelCheck(String channel,String pcUseYn,String mobileUseYn,String othYn) throws Exception{
		CoviMap resultObj = new CoviMap();
		boolean channelFlag = false;
		String msg = "";
		if("W".equals(channel)){//PC등록 
			if("Y".equals(pcUseYn)){//PC사용여부 비활성화
				channelFlag = true;
			}else{
				msg = DicHelper.getDic("msg_att_pc_not_used");
			}
		}else if("M".equals(channel)){//MOBILE등록
			if("Y".equals(mobileUseYn)){
				channelFlag = true;
			}else{ 
				msg = DicHelper.getDic("msg_att_mobile_not_used");
			}
		}else if("S".equals(channel)){//SECOM등록
			if("Y".equals(othYn)){ 
				channelFlag = true;
			}else{
				msg = DicHelper.getDic("msg_att_if_not_used");
			}
		}
		resultObj.put("result", channelFlag);
		resultObj.put("msg", msg);
		return resultObj;
	}

	/**
	  * @Method Name : getCommuteBtnStatus
	  * @작성일 : 2020. 4. 16.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 출퇴근 버튼 상태 
	  * @param request
	  * @param response
	  * @param commuteChannel 출퇴근 채널( W:홈페이지 / M:모바일 )
	  * @return
	  */
	@RequestMapping(value = "/getCommuteBtnStatus.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getCommuteBtnStatus(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		
		try {
			String commuteChannel = request.getParameter("commuteChannel");
			//근태 기초 설정
			CoviMap mngMstObj = attendAdminSettingSvc.getAttendMngMst();
			boolean btnFlag = false;
			if(
					(
							"Y".equals(mngMstObj.getString("PcUseYn"))
							&& "W".equals(commuteChannel)
					)||(
							"Y".equals(mngMstObj.getString("MobileUseYn"))
							&& "M".equals(commuteChannel)
					)
			){
				//PC / mobile 사용
				btnFlag = true;
			}
			
			if(btnFlag){
				
				
				CoviMap params = new CoviMap();
				params.put("UserCode", SessionHelper.getSession("USERID"));
				params.put("TargetDate", ComUtils.GetLocalCurrentDate("yyyy-MM-dd"));
				params.put("TargetDateTime", ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"));
				//미퇴근 건 조회
				params.put("EndTimeIsNull","Y");
				
				String commuteStatus = ""; //출퇴근 상태
				String startTime = ""; //출근시간
				String endTime = ""; //퇴근시간
				String startSts = ""; // 출근상태
				String endSts = ""; // 퇴근상태

				String targetDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
				
				CoviMap commuteMstEndIsNull = attendCommutingSvc.getCommuteMstData(params);

				if("SUCCESS".equals(commuteMstEndIsNull.getString("status"))){
					if(!commuteMstEndIsNull.containsKey("data")){

						//미퇴근 제외
						params.put("EndTimeIsNull","N");
						CoviMap commuteMst = attendCommutingSvc.getCommuteMstData(params);
						
						if(!commuteMst.containsKey("data")){
							commuteStatus = "S";
						}else{
							CoviMap mstObj = commuteMst.getJSONObject("data");
							
							startTime = mstObj.getString("StartTime");
							endTime = mstObj.getString("EndTime");
							
							startSts = mstObj.getString("StartSts");
							endSts = mstObj.getString("EndSts");
							String attendStatus = mstObj.getString("AttendStatus");
							
							if(!"".equals(startSts) && !"".equals(endSts)){
								if("Y".equals(attendStatus)){
									//System.out.println("퇴근완료");
									commuteStatus = "O"; 
								} else if("lbl_adstandby".equals(endSts)) { // 승인요청인 경우,
									commuteStatus = "O"; 
								}
								else if("lbl_ApprovalDeny".equals(endSts)){ // 승인거부인 경우, 퇴근하기 버튼 활성화
									commuteStatus = "E";	
								} else {
									//System.out.println("퇴근하기 ( 다시 퇴근하기 )");
									commuteStatus = "EE";
								}
							}else if(!"".equals(startSts)){
								//System.out.println("퇴근하기");
								commuteStatus = "E";	
							}else if(!"".equals(endSts)){
								//System.out.println("출근하기");
								commuteStatus = "S"; 
							} 
						} 
					}else { 
						//System.out.println("미퇴근 퇴근");
						CoviMap mstObj = commuteMstEndIsNull.getJSONObject("data");
						startTime = mstObj.getString("StartTime"); 
						endTime = mstObj.getString("EndTime"); 
						commuteStatus = "SE";
						targetDate =  mstObj.getString("TargetDate");
						
						startSts = mstObj.getString("StartSts");
						endSts = mstObj.getString("EndSts");
						
						LocalDate now = LocalDate.now();
						DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
				        String nowDate = now.format(formatter);
						
				        if(targetDate.equals(nowDate)) {
				        	commuteStatus = "E";
				        } else {
				        	commuteStatus = "SE";
				        }
					}
				}
				String btnLabel = ""; //출퇴근 버튼명
				String atSts = ""; //출퇴근상태
				CoviList btnStsList = RedisDataUtil.getBaseCode("CommuteBtnStatus");
				for(int i=0;i<btnStsList.size();i++){
					CoviMap codeObj = btnStsList.getMap(i);
					if(commuteStatus.equals(codeObj.getString("Reserved1"))){
						btnLabel = codeObj.getString("Reserved2");
						atSts = codeObj.getString("Reserved3");
					}
				} 
				returnObj.put("result", "ok");
				returnObj.put("targetDate", targetDate);
				returnObj.put("btnLabel", btnLabel);
				returnObj.put("atSts", atSts);
				returnObj.put("startSts", startSts);
				returnObj.put("endSts", endSts);
				returnObj.put("startTime", startTime);
				returnObj.put("endTime", endTime);
				returnObj.put("commuteStatus",commuteStatus); 
				
				params.put("ValidYn", "Y");
				CoviMap jobList = attendAdminSettingSvc.getOtherJobList(params);
				returnObj.put("jobList",jobList.get("list"));
			}
		} catch(NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e); 
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e); 
		}
		return returnObj;
	}

	


	/**
	  * @Method Name : setCommuteMng
	  * @작성일 : 2020. 5. 8.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 근태기록  추가/수정/삭제
	  * @param request
	  * @param response
	  * @return
	  */
	@RequestMapping( value= "/setCommuteMng.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setCommuteMng(HttpServletRequest request, HttpServletResponse response) {
		CoviMap returnObj = new CoviMap();
		try{
			String targetDate = request.getParameter("targetDate");
			String userCode = request.getParameter("userCode");
			String startDate = request.getParameter("startDate");
			String endDate = request.getParameter("endDate");
			String etc = request.getParameter("etc");
			String type = request.getParameter("type");
			String companyCode = SessionHelper.getSession("DN_Code");
			String regUserCode = SessionHelper.getSession("USERID");
			String commuteChannel = request.getParameter("commuteChannel");
			String commuteIp = request.getHeader("X-FORWARDED-FOR");
			
			if (commuteIp == null){ 
				commuteIp = request.getRemoteAddr(); 
			}

			CoviMap params = new CoviMap();
			params.put("TargetDate", targetDate);
			params.put("UserCode", userCode);
			params.put("RegUserCode", regUserCode);
			params.put("StartDate", startDate);
			params.put("StartAddr", commuteIp);
			params.put("EndDate", endDate);
			params.put("EndAddr", commuteIp);
			params.put("CommuteChannel", commuteChannel);
			params.put("Etc", etc);
			params.put("Type", type);
			params.put("CompanyCode", companyCode);
			
			attendCommutingSvc.setCommuteMng(params);
			
			returnObj.put("status", Return.SUCCESS);
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);  
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);  
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	/**
	  * @Method Name : goCommutingAlram 
	  * @작성일 : 2020. 5. 19.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 출퇴근 팝업
	  * @param request
	  * @param locale
	  * @param model
	  * @return
	  * @throws Exception
	  */
	@RequestMapping(value = "/goCommutingAlram.do", method = RequestMethod.GET)
	public ModelAndView goCommutingAlram(HttpServletRequest request, Locale locale, Model model) throws Exception{
		ModelAndView mav = new ModelAndView("user/attend/AttendCommutingAlram");
		
		String commuteType = request.getParameter("commuteType");
		String targetDate = request.getParameter("targetDate");
		mav.addObject("commuteType",commuteType);	
		mav.addObject("targetDate",targetDate);	 
		
		return mav;
	}
	
	@RequestMapping(value = "/setMemJobSts.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap setMemJobSts(HttpServletRequest request, HttpServletResponse response
			,@RequestParam Map<String, Object> parameters) {
		CoviMap returnList = new CoviMap();
		try {
//			List ReqData = makeRequestList(map);
			CoviMap params = new CoviMap();
			params.put("ValidYn", "Y");
			params.put("JobStsSeq", request.getParameter("JobStsSeq"));
			CoviList jobList = attendCommonSvc.getOtherJobList(params); 
			CoviMap jobMap = (CoviMap)jobList.get(0);
			String ReqStatus = "ApprovalRequest";
			
			if (jobMap.getString("ReqMethod").equals("None")){	//승인없음이면
				ReqStatus = "Approval";
			}
			
			List ReqData = new ArrayList<>();
			Map detailMap = new java.util.HashMap<>();
			detailMap.put("WorkDate", request.getParameter("JobDate"));
			detailMap.put("JobStsSeq", request.getParameter("JobStsSeq"));
			detailMap.put("JobStsName", jobMap.getString("JobStsName"));
			detailMap.put("StartTime", request.getParameter("StartTime"));
			detailMap.put("EndTime", request.getParameter("EndTime"));
			
			detailMap.put("Comment", request.getParameter("Etc"));
			
			detailMap.put("UserCode", SessionHelper.getSession("USERID"));
			detailMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));

			ReqData.add(detailMap);
			
			
			params.put("ReqType", "J");
			params.put("ReqGubun", "C");
			params.put("ReqMethod", jobMap.getString("ReqMethod"));
			
			params.put("UserCode", SessionHelper.getSession("USERID"));
			params.put("RegisterCode", SessionHelper.getSession("USERID"));
			params.put("CompanyCode", SessionHelper.getSession("DN_Code"));
			params.put("ReqTitle", jobMap.getString("JobStsName") + "신청서");
			params.put("ReqStatus", ReqStatus);
			String reqDataStr = AttendUtils.getJsonArrayFromList(ReqData).toString();
			reqDataStr = reqDataStr.replace("\"","\\\"");
			params.put("ReqDataStr", reqDataStr);
			params.put("Comment", request.getParameter("Etc"));
			CoviMap obj = attendReqSvc.requestJobStatus(params, ReqData, ReqStatus);
			returnList.put("status", Return.SUCCESS);
		} catch(NullPointerException e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnList;
	}
}
