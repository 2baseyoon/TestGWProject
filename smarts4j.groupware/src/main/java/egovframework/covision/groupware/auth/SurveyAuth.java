package egovframework.covision.groupware.auth;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.survey.user.service.SurveySvc;
import egovframework.covision.groupware.survey.user.web.SurveyVO;

public class SurveyAuth {
	
	/**
	 * 설문 결과공개 대상자 권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getReadAuth(CoviMap params) throws Exception{
		params.put("userId", SessionHelper.getSession("USERID"));
		SurveySvc surveySvc = StaticContextAccessor.getBean(SurveySvc.class);
		String flag= surveySvc.getSurveyTargetViewRead(params);
		if (flag.equals("Y")) return true;
		else return false;
	}
	
	/**
	 * 설문 삭제권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getDeleteAuth(CoviMap params){
		boolean bDeleteAuth = false;
		
		try {
			SurveySvc surveySvc = StaticContextAccessor.getBean(SurveySvc.class);
			
			setParameter(params);
			
			String userCode = params.getString("userCode");
			String surveyID = params.getString("surveyIdArr[]");
			
			// TODO: surveyID[]로 파라미터 여러 개 들어오는 이슈 사항있음(HashMap 구조 상 key가 같으면 value가 뒤집어 씌어짐)
			/*for(int i = 0; i < surveyIDArr.length; i++) {
				params.put("surveyID", surveyIDArr[i]);
				
				CoviMap surveyInfo = surveySvc.selectSurveyInfoData(params);
				
				if(surveyInfo.getString("RegisterCode").equals(userCode)){
					bDeleteAuth = true;
				}
			}*/
			
			params.put("surveyID", surveyID);
			
			CoviMap surveyInfo = surveySvc.selectSurveyInfoData(params);
			
			if(surveyInfo.getString("RegisterCode").equals(userCode)){
				bDeleteAuth = true;
			}
			
			return bDeleteAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}

	/**
	 * 설문 수정권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getModifyAuth(CoviMap params){
		try {
			SurveySvc surveySvc = StaticContextAccessor.getBean(SurveySvc.class);
			
			setParameter(params);
			
			String userCode = params.getString("userCode");
			CoviMap surveyInfo = surveySvc.selectSurveyInfoData(params);
			
			if(!surveyInfo.getString("RegisterCode").equals(userCode)){
				return false;
			}
			
			return true;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 설문 참여권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getJoinAuth(CoviMap params){
		boolean bJoinFlag = false;
		
		try {
			SurveySvc surveySvc = StaticContextAccessor.getBean(SurveySvc.class);
			
			setParameter(params);
			if (params.getString("viewType").equals("preview")) return true;
			String userCode = params.getString("userCode");
			
			params.put("targetType", "");
			
			CoviList attendCodeList = surveySvc.selectAttendanceCodeList(params);
			
			for (int i = 0; i < attendCodeList.size(); i++) {
				CoviMap attCode = attendCodeList.getMap(i);
				
				if(attCode.containsValue(userCode)){
					return true;
				}
			}
			
			if(!bJoinFlag) {			// 등록자가 참석자에 포함되어 있지 않는 경우, 관리자 권한 확인  
				bJoinFlag = SurveyAuth.getAdminAuth(params);
			}

			return bJoinFlag;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 설문 관리자권한(시스템 관리자, 설문 등록자)
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getAdminAuth(CoviMap params){
		boolean bAdminAuth = false;
		
		try {
			SurveySvc surveySvc = StaticContextAccessor.getBean(SurveySvc.class);
			
			setParameter(params);
			
			// 삭제 권한 체크
			if(params.getString("state").equals("del")){
				return getDeleteAuth(params);
			}
			
			String userCode = params.getString("userCode");
			CoviMap surveyInfo = surveySvc.selectSurveyInfoData(params);
			
			if ("Y".equals(SessionHelper.getSession("isAdmin"))) {
				bAdminAuth = true;
			} else if(surveyInfo.getString("RegisterCode").equals(userCode)){
				bAdminAuth = true;
			}
			
			return bAdminAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 설문 상태변경권한
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getUpdateStateAuth(CoviMap params){
		// 설문상태 (A:작성중, B:검토대기, D:검토거부, C:승인대기, X:승인거부, F:진행중, G:설문종료)
		boolean bStateAuth = false;
		
		try {
			SurveySvc surveySvc = StaticContextAccessor.getBean(SurveySvc.class);
			
			setParameter(params);
			
			String userCode = params.getString("userCode");
			String surveyID = params.getString("surveyIdArr[]");
			
			params.put("surveyID", surveyID);
			
			CoviMap surveyInfo = surveySvc.selectSurveyInfoData(params);
			
			if ("Y".equals(SessionHelper.getSession("isAdmin"))) {
				bStateAuth = true;
			} else if(params.getString("state").equals("del")) { // 삭제 권한 체크
				bStateAuth = getDeleteAuth(params);
			} else if("CFX".indexOf(params.getString("state")) > -1 && surveyInfo.getString("ApproverCode").equals(userCode)) { // 승인
				bStateAuth = true;
			} else if(params.getString("state").equals("G") && surveyInfo.getString("RegisterCode").equals(userCode)) { // 설문 종료 권한 체크
				bStateAuth = true;
			}
			
			return bStateAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	/**
	 * 설문 결과공개 대상자 권한 체크
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public static boolean getResultViewAuth(CoviMap params){
		boolean bResultViewAuth = false;
		
		try {
			SurveySvc surveySvc = StaticContextAccessor.getBean(SurveySvc.class);
			
			setParameter(params);
			
			String resultViewAuthFlag = surveySvc.getSurveyTargetViewRead(params);
			
			if ("Y".equals(resultViewAuthFlag)) {				
				return true;
			}
			
			// 해당 유저가 결과공개 대상자가 아닐 경우, 시스템 관리자 및 설문 등록자 권한 추가 체크
			bResultViewAuth = getAdminAuth(params);
			
			return bResultViewAuth;
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
	}
	
	public static boolean isJoinSurvey(CoviMap params) {
		boolean isJoin = false;
		try {
			SurveySvc surveySvc = StaticContextAccessor.getBean(SurveySvc.class);
			
			CoviMap resultMap = surveySvc.getSurveyRespondent(params);
			
			isJoin = !resultMap.isEmpty();
			
		} catch(NullPointerException e) {
			return false;
		} catch(Exception e) {
			return false;
		}
		
		return isJoin;
	}
	
	private static void setParameter(CoviMap params) throws Exception {
		if(StringUtil.isNotNull(params.getString("surveyInfo"))){
			CoviMap surveyInfoObj = CoviMap.fromObject(params.getString("surveyInfo"));
			params.put("surveyID", surveyInfoObj.getString("surveyID"));
		}
		
		if(StringUtil.isNotNull(params.getString("surveyId"))){
			params.put("surveyID", params.getString("surveyId"));
		}
		
		params.put("lang", SessionHelper.getSession("lang"));
		params.put("userCode", SessionHelper.getSession("USERID"));
		params.put("userId", SessionHelper.getSession("USERID"));
	}
}
