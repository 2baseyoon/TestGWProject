package egovframework.covision.coviflow.common.util;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

import org.apache.commons.codec.binary.Base64;

import com.jayway.jsonpath.JsonPath;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.XSSUtils;

public class ComUtils {

	// json string db에 넣을 시 처리(mybatis에서 $바인딩으로 처리하거나, #바인딩 처리시는 아래함수 통해 single
	// quotation 추가)
	public static String addSingleQuote(String str) {
		return "'" + str + "'";
	}

	// uuid 생성
	public static String getUUID() {
		return UUID.randomUUID().toString().toUpperCase();
	}

	// 구분(SubKind) 다국어 처리와 결재단계 표시값 변경 처리를 위한 메소드
	@SuppressWarnings("unchecked")
	public static CoviList coviSelectJSONForApprovalList(String listType, CoviList clist, String str) throws Exception {
		String lang = SessionHelper.getSession("lang");		//다국어 처리용 세션 lang
		String[] cols = str.split(",");
		CoviMap subKindDic = setSubKindDic();

		CoviList returnArray = new CoviList();

		if (null != clist && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {

				CoviMap newObject = new CoviMap();

				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();

					while (iter.hasNext()) {
						Object ar = iter.next();
						// String ar = (String)iter.next();
						if (ar.equals(cols[j].trim())) {
							if (ar.equals("SubKind")) {
								if(listType.equalsIgnoreCase("D") && clist.getMap(i).getString(cols[j]).equals("C") && str.indexOf("CirculationBoxID") < 0  )				// 부서 합의
									newObject.put(cols[j], subKindDic.getString(clist.getMap(i).getString(cols[j]) + "_consent"));
								else if((listType.equalsIgnoreCase("") ||  str.indexOf("CirculationBoxID") > -1 ) && clist.getMap(i).getString(cols[j]).equals("C") )		
									newObject.put(cols[j], subKindDic.getString(clist.getMap(i).getString(cols[j]) + "_circulate"));
								else
									newObject.put(cols[j], Objects.toString(subKindDic.getString(clist.getMap(i).getString(cols[j])), clist.getMap(i).getString(cols[j]) ));	// 없을 경우 그대로 보냄
							} else if (ar.equals("ApprovalStep")) {
								if(!clist.getMap(i).getString(cols[j]).equals("") && clist.getMap(i).getString(cols[j]) != null && clist.getMap(i).getString(cols[j]).indexOf("_") > -1){
									String[] approvalStep = clist.getMap(i).getString(cols[j]).split("_");
									newObject.put(cols[j], approvalStep[1] + "/" + approvalStep[0]);
								}else{
									newObject.put(cols[j], "");
								}
							} else if (ar.equals("InitiatorName") || ar.equals("InitiatorUnitName") || ar.equals("FormName") || ar.equals("SubUserName")) {
								newObject.put(cols[j], DicHelper.getDicInfo(clist.getMap(i).getString(cols[j]), lang));
							} else if (ar.equals("Created") || ar.equals("EndDate") || ar.equals("StartDate") || ar.equals("Finished") || ar.equals("InitiatedDate") || ar.equals("RegDate") || ar.equals("CreatedDate")) { // 날짜컬럼 타임존 적용(서버시간 => 로컬시간)
								newObject.put(cols[j], egovframework.coviframework.util.ComUtils.TransLocalTime(clist.getMap(i).getString(cols[j])));
							} else {
								newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
							}
						}
					}
				}
				returnArray.add(newObject);
			}
		}
		return returnArray;
	}
	
	// 구분(SubKind) 다국어 처리를 위한 메소드
	@SuppressWarnings("unchecked")
	public static CoviList coviSelectJSONForApprovalGroupList(String searchGroupType, String mode, CoviList clist, String str) throws Exception {
		String[] cols = str.split(",");
		CoviMap subKindDic = setSubKindDic();

		CoviList returnArray = new CoviList();
		
		String listType = "";
		
		if(mode.equalsIgnoreCase("TCINFO") || mode.equalsIgnoreCase("DEPTTCINFO")) {
			listType = "C";
		} else if(mode.equalsIgnoreCase("DEPTCOMPLETE") || mode.equalsIgnoreCase("SENDERCOMPLETE") || mode.equalsIgnoreCase("RECEIVE") || mode.equalsIgnoreCase("DEPTPROCESS") || mode.equalsIgnoreCase("RECEIVECOMPLETE") || mode.equalsIgnoreCase("DEPTTCINFO")) {
			listType = "D";
		}

		if (null != clist && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {

				CoviMap newObject = new CoviMap();

				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();

					while (iter.hasNext()) {
						Object ar = iter.next();
						if (ar.equals(cols[j].trim())) {
							if(searchGroupType.equals("SubKind")) {
								if (ar.equals("fieldName")) {
									if(listType.equalsIgnoreCase("D") && clist.getMap(i).getString(cols[j]).equals("C"))				// 부서 합의
										newObject.put(cols[j], subKindDic.getString(clist.getMap(i).getString(cols[j]) + "_consent"));
									else if(!listType.equalsIgnoreCase("D") && clist.getMap(i).getString(cols[j]).equals("C") )		
										newObject.put(cols[j], subKindDic.getString(clist.getMap(i).getString(cols[j]) + "_circulate"));
									else
										newObject.put(cols[j], Objects.toString(subKindDic.getString(clist.getMap(i).getString(cols[j])), clist.getMap(i).getString(cols[j]) ));	// 없을 경우 그대로 보냄
								} else {
									newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
								}
							} else {
								newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
							}
						}
					}
				}
				returnArray.add(newObject);
			}
		}
		return returnArray;
	}

	// 구분 다국어값 가져오는 메소드
	public static CoviMap setSubKindDic() throws Exception {
		CoviMap rSubKinds = new CoviMap();

		rSubKinds.put("T000", "lbl_apv_app"); // 결재 - 결재
		rSubKinds.put("T001", "lbl_apv_ITrans"); // 시행 - 시행
		rSubKinds.put("T002", "lbl_apv_ITrans"); // 시행 - 시행
		rSubKinds.put("T003", "lbl_apv_OfficialSeal"); // 직인 - 직인
		rSubKinds.put("T004", "lbl_apv_reject_consent"); // 협조 - 반려합의
		rSubKinds.put("T005", "lbl_apv_review"); // 후결 - 후결
		rSubKinds.put("T006", "lbl_apv_reading"); // 열람 - 열람
		rSubKinds.put("T007", "lbl_apv_via"); // 경유 - 경유
		rSubKinds.put("T008", "lbl_apv_charge"); // 담당 - 담당
		rSubKinds.put("T009", "lbl_apv_consent"); // 합의 - 개인합의
		rSubKinds.put("T010", "lbl_apv_preview"); // 예고 - 예고
		rSubKinds.put("T011", "lbl_apv_charge"); // 담당 - 담당
		rSubKinds.put("T012", "lbl_apv_charge"); // 담당 - 담당
		rSubKinds.put("T013", "lbl_apv_cc"); // 참조 - 참조
		rSubKinds.put("T014", "lbl_apv_notice2"); // 통지 - 통지
		rSubKinds.put("T015", "lbl_apv_reject_consent"); // 협조 - 반려합의
		rSubKinds.put("T016", "lbl_apv_audit"); // 감사 - 감사
		rSubKinds.put("T017", "lbl_apv_law"); // 감사(준법) - 준법
		rSubKinds.put("T018", "lbl_apv_PublicInspect"); // 공람 - 공람
		rSubKinds.put("T019", "lbl_apv_Confirm"); // 확인 - 확인
		rSubKinds.put("T020", "lbl_apv_cc"); // 참조 - 참조
		rSubKinds.put("T021", "lbl_apv_app"); // 참조 - 결재
		rSubKinds.put("T023", "lbl_apv_consultation"); // 검토
		rSubKinds.put("A", "lbl_apv_consult"); // 품의함 - 품의함
		rSubKinds.put("R", "lbl_apv_receive"); // 수신 - 수신
		rSubKinds.put("S", "lbl_apv_send"); // 발신 - 발신
		rSubKinds.put("E", "lbl_apv_receive"); // 접수 - 수신
		rSubKinds.put("REQCMP", "lbl_apv_receive"); // 신청처리 - 수신
		rSubKinds.put("P", "lbl_apv_send"); // 발신 - 발신
		rSubKinds.put("SP", "lbl_apv_reading"); // 열람 - 열람
		rSubKinds.put("C_circulate", "btn_apv_Circulate"); // 회람 - 회람
		rSubKinds.put("C_consent", "lbl_apv_tit_consent"); // 부서합의 - 합의
		rSubKinds.put("AS", "lbl_apv_reject_consent"); // 부서협조 - 협조
		rSubKinds.put("AD", "lbl_apv_audit"); // 부서감사 - 감사
		rSubKinds.put("AE", "lbl_apv_law"); // 부서감사(준법) - 준법
		rSubKinds.put("0", "btn_apv_AReference"); // 참조 - 사후참조
		rSubKinds.put("1", "btn_apv_CReference"); // 참조 - 사전참조
		rSubKinds.put("2", "btn_apv_Circulate"); // 열람 - 회람
		rSubKinds.put("T", "lbl_apv_Temporary"); // 임시
		rSubKinds.put("W", "btn_apv_Withdraw"); // 회수
		rSubKinds.put("T022", "lbl_apv_confirmor"); // 개인-수신공람
		rSubKinds.put("RE", "lbl_apv_confirmor"); // 부서-수신공람
		rSubKinds.put("AA", "lbl_apv_receive"); // 부서협조/부서합의/부서감사 - 수신
		
		rSubKinds.put("", "");

		StringBuffer subKindDicCode = new StringBuffer();
		
		for (Iterator<String> keys = rSubKinds.keys(); keys.hasNext();) {
			subKindDicCode.append(rSubKinds.getString(keys.next()) + ";");
		}

		CoviList dicobj = DicHelper.getDicAll(subKindDicCode.toString());

		Iterator<String> keys1 = rSubKinds.keys();
		while(keys1.hasNext()) {
			String key1 = keys1.next();
			
			String dicKey = rSubKinds.getString(key1);
			String dicVal = dicobj.getJSONObject(0).getString(dicKey);
			if(dicVal != null && !dicVal.equals("")) {
				rSubKinds.put(key1, dicVal);
			}
		}

		return rSubKinds;
	}
	
	// 첨부파일 토큰 수정용 함수
	public static CoviMap changeCommentFileInfos(CoviMap apvLineObj) throws Exception {
		// 문서유통-Offline 등록 양식인 경우 결재선 없음
		if(apvLineObj.isEmpty()) return apvLineObj;
		
		CoviMap root = (CoviMap)apvLineObj.get("steps");
		Object divisionObj = root.get("division");
		CoviList divisions = new CoviList();
		if(divisionObj instanceof CoviMap){
			CoviMap divisionJsonObj = (CoviMap)divisionObj;
			divisions.add(divisionJsonObj);
		} else {
			divisions = (CoviList)divisionObj;
		}
		
		// 기안 전 문서는 division이 없음.
		if(divisions == null) return apvLineObj;
		
		for(int i = 0; i < divisions.size(); i++)
		{
			CoviMap division = (CoviMap)divisions.get(i);
				
			Object stepO = division.get("step");
			CoviList steps = new CoviList();
			if(stepO instanceof CoviMap){
				CoviMap stepJsonObj = (CoviMap)stepO;
				steps.add(stepJsonObj);
			} else {
				steps = (CoviList)stepO;
			}
			
			String unitType = "";
			
			for(int j = 0; j < steps.size(); j++)
			{
				unitType = "";
				
				CoviMap s = (CoviMap)steps.get(j);
				
				unitType = (String)s.get("unittype");
				
				//jsonarray와 jsonobject 분기 처리
				Object ouObj = s.get("ou");
				CoviList ouArray = new CoviList();
				if(ouObj instanceof CoviList){
					ouArray = (CoviList)ouObj;
				} else {
					ouArray.add((CoviMap)ouObj);
				}
				
				for(int z = 0; z < ouArray.size(); z++)
				{
					CoviMap ouObject = (CoviMap)ouArray.get(z);
					CoviMap taskObject = new CoviMap();
					
					if(ouObject.containsKey("person")){
						Object personObj = ouObject.get("person");
						CoviList persons = new CoviList();
						if(personObj instanceof CoviMap){
							CoviMap jsonObj = (CoviMap)personObj;
							persons.add(jsonObj);
						} else {
							persons = (CoviList)personObj;
						}
						
						for(int pIdx = 0; pIdx < persons.size(); pIdx ++) {
							CoviMap personObject = (CoviMap)persons.get(pIdx);
							taskObject = (CoviMap)personObject.get("taskinfo");
							
							// 의견첨부가 있는 경우
							if(taskObject.containsKey("comment_fileinfo")){
								Object commnetObj = taskObject.get("comment_fileinfo");
								CoviList comments = new CoviList();
								if(commnetObj instanceof CoviMap){
									CoviMap jsonObj = (CoviMap)commnetObj;
									comments.add(commnetObj);
								} else {
									comments = (CoviList)commnetObj;
								}
								
								/* 형태 참고
								 "comment_fileinfo": [
			                     {
			                       "name": "Damage report_3nd ship_3.pdf",
			                       "id": "1013882",
			                       "savedname": "20200407022411521_Damage report_3nd ship_3.pdf"
			                     }], */
								for(int c=0; c<comments.size(); c++) { // 첨부 토큰 변경하기
									CoviMap tmpObj = (CoviMap)comments.get(c);
									tmpObj.put("FileID", tmpObj.getString("id"));
								}
								
								taskObject.remove("comment_fileinfo");
								taskObject.put("comment_fileinfo", FileUtil.getFileTokenArray(comments));
							}
							
							if(personObject.containsKey("consultation")){ //검토
								Object consultPersonObj = personObject.get("consultation");
								CoviList consultPersons = new CoviList();
								if(consultPersonObj instanceof CoviMap){
									CoviMap jsonConsultPersonObj = (CoviMap)consultPersonObj;
									consultPersons.add(jsonConsultPersonObj);
								} else {
									consultPersons = (CoviList)consultPersonObj;
								}
								
								for(int cIdx = 0; cIdx < consultPersons.size(); cIdx ++) {
									CoviMap consultationObj = (CoviMap)consultPersons.get(cIdx);
									Object cUserObj = consultationObj.get("consultusers");
									CoviList cUserList = new CoviList();
									if(cUserObj instanceof CoviMap){
										CoviMap consultObj = (CoviMap)cUserObj;
										cUserList.add(consultObj);
									} else {
										cUserList = (CoviList)cUserObj;
									}
									
									for(int uIdx = 0; uIdx < cUserList.size(); uIdx ++) {
										CoviMap userObject = (CoviMap)cUserList.get(uIdx);
										CoviMap consultUsersTaskObject = (CoviMap)userObject.get("taskinfo");
									
										if(consultUsersTaskObject.containsKey("comment_fileinfo")){
											Object cCommentObj = consultUsersTaskObject.get("comment_fileinfo");
											CoviList cComments = new CoviList();
											if(cCommentObj instanceof CoviMap){
												cComments.add((CoviMap)cCommentObj);
											} else {
												cComments = (CoviList)cCommentObj;
											}
	
											for(int c=0; c<cComments.size(); c++) { // 첨부 토큰 변경하기
												CoviMap tmpCObj = (CoviMap)cComments.get(c);
												tmpCObj.put("FileID", tmpCObj.getString("id"));
											}
											consultUsersTaskObject.remove("comment_fileinfo");
											consultUsersTaskObject.put("comment_fileinfo", FileUtil.getFileTokenArray(cComments));
										}
									}
								}
							}
							
							personObject.remove("taskinfo");
							personObject.put("taskinfo", taskObject);
						}
						
						ouObject.remove("person");
						if(persons.size() > 1) {
							ouObject.put("person", persons);	
						} else {
							ouObject.put("person", (CoviMap)persons.get(0));
						}
					}
					
					s.remove("ou");
					if(ouArray.size() > 1) {
						s.put("ou", ouArray);
					} else {
						s.put("ou", (CoviMap)ouArray.get(0));
					}
				}	      
			}
			
			division.remove("step");
			if(steps.size() > 1) {
				division.put("step", steps);
			} else {
				division.put("step", (CoviMap)steps.get(0));
			}
		}
		
		root.remove("division");
		if(divisions.size() > 1) {
			root.put("division", divisions);
		} else {
			root.put("division", (CoviMap)divisions.get(0));
		}
		
		apvLineObj.put("steps", root);
		
		return apvLineObj;
	}

	/**
	 * 결재문서 XSS처리 (에디터, 기안연동 html파라미터 제외)(의견은 base64 decode 후 처리)
	 * @param formStr
	 * @return
	 * @throws Exception
	 */
	public static CoviMap removeFormXSS(String formStrOrigin) throws Exception {
		String formStr = XSSUtils.XSSFilter(formStrOrigin, true); // true : json인 경우 \" 로 escape되어있어서 의도치 않은 문자열이 제거되므로 추가
		
		CoviMap formObj = CoviMap.fromObject(formStr, false);
		CoviMap formObjOrigin = CoviMap.fromObject(formStrOrigin, false); // false : 에디터 html escape문자 유지
		
		// 본문 에디터(FormData > BodyContext > tbContentElement), 기안연동html파라미터(FormData > BodyContext > HTMLBody,MobileBody,JSONHtml) 예외처리
		if(formObj.containsKey("FormData")) {
			CoviMap formData = formObj.optJSONObject("FormData");
			if(formData.containsKey("BodyContext")) {
				CoviMap bodyContext = formData.optJSONObject("BodyContext");
				if(bodyContext.containsKey("tbContentElement")) {
					bodyContext.putOrigin("tbContentElement", JsonPath.read(formObjOrigin, "$.FormData.BodyContext.tbContentElement").toString());
				}
				if(bodyContext.containsKey("HTMLBody")) {
					bodyContext.putOrigin("HTMLBody", JsonPath.read(formObjOrigin, "$.FormData.BodyContext.HTMLBody").toString());
				}
				if(bodyContext.containsKey("MobileBody")) {
					bodyContext.putOrigin("MobileBody", JsonPath.read(formObjOrigin, "$.FormData.BodyContext.MobileBody").toString());
				}
				if(bodyContext.containsKey("JSONHtml")) {
					bodyContext.putOrigin("JSONHtml", JsonPath.read(formObjOrigin, "$.FormData.BodyContext.JSONHtml").toString());
				}
			}
		}
		// 의견은 base64 decode 후 처리
		if(formObj.containsKey("actionComment")) {
			String actionComment = formObjOrigin.optString("actionComment");
			actionComment = new String(Base64.decodeBase64(actionComment), StandardCharsets.UTF_8);
			actionComment = XSSUtils.XSSFilter(actionComment);
			actionComment = Base64.encodeBase64String(actionComment.getBytes(StandardCharsets.UTF_8));
			formObj.putOrigin("actionComment",actionComment);
		}
		
		return formObj;
	}
}
