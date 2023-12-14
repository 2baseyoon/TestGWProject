package egovframework.covision.groupware.privacy.user.service.impl;

import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.PrivateKey;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.annotation.Resource;
import javax.imageio.ImageIO;

import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;

import org.apache.commons.io.FilenameUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.sec.RSA;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ADAuthUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.coviframework.util.MultipartUtility;
import egovframework.covision.groupware.privacy.user.service.PrivacySvc;
import egovframework.covision.groupware.privacy.user.web.SettingVO;




@Service("privacySvc")
public class PrivacySvcImpl extends EgovAbstractServiceImpl implements PrivacySvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	AwsS3 awsS3 = AwsS3.getInstance();

	@Autowired
	private FileUtilService fileSvc;

	private Logger LOGGER = LogManager.getLogger(PrivacySvcImpl.class);
	
	// 개인환경 설정 > 기본정보
	@Override
	public CoviMap getUserPrivacySetting(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("groupware.privacy.selectUserPrivacySetting", params);		
		CoviMap resultList = new CoviMap();
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "UserID,UserCode,MailAddress,BirthDiv,BirthDate,IsBirthLeapMonth,ExternalMailAddress,Mobile,Fax,PhoneNumberInter,IPPhone,PhoneNumber,updateFileId,MultiCompanyName,MultiDeptName,Mail,AbsenseUseYN,AbsenseDuty,AbsenseTermStart,AbsenseTermEnd,AbsenseReason,AbsenseType,MultiJobPositionName,MultiJobTitleName,MultiDisplayName,absenseDutyText,updateFilePath,ChargeBusiness,PushAllowYN,PushAllowWeek,PushAllowStartTime,PushAllowEndTime"));	
		
		return resultList;
	}
	
	@Override
	public String selectUserAuthetication(CoviMap params) throws Exception{
		final String cryptoType = PropertiesUtil.getSecurityProperties().getProperty("cryptoType");
		StringUtil func = new StringUtil();
		String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
		String value = "";
		String id = (String) params.get("id");
		String password = (String)params.get("nowPassword");
		
		// 통합인증(Unify)의 경우는 이미 인증된 상태이기 떄문에 별도 체크 X 
		switch(PropertiesUtil.getSecurityProperties().getProperty("loginAuthType").toUpperCase()) {
			case "DB":
				if(func.f_NullCheck(cryptoType).equals("R")){
					password = RSA.decryptRsa((PrivateKey) params.get("__CoviRPK__"), password); 
				}else if(func.f_NullCheck(cryptoType).equals("A")){
					AES aes = new AES("", "P");
					
					password = aes.pb_decrypt(password);
				}
				
				params.put("id", id);
				params.put("password", password);
				params.put("aeskey",aeskey);
				
				value = (String) coviMapperOne.getString("common.login.selectUserAuthetication", params);
				
				break;
			case "AD":
				ADAuthUtil adAuthUtil = new ADAuthUtil();
				HashMap<String, Object> userInfo = adAuthUtil.getUserAuthetication(id, password);
				
				if(userInfo != null) {
					value = userInfo.get("sAMAccountName").toString();
				}
				
				break;
			default :
				break;
		}
		
		return value;
	}
	
	//겸직변경 정보 조회
	@Override
	public CoviMap getUserBaseGroupAll(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.privacy.selectUserBaseGroupAll", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "Seq,UserCode,CompanyName,CompanyCode,DeptName,DeptCode,JobLevelName,JobLevelCode"));	
		
		return resultList;
	}
	
	@Override
	public CoviMap getUseBaseGroup(CoviMap params) throws Exception{
		return coviMapperOne.select("groupware.privacy.selectUserBaseGroup", params);
	}
	
	@Override
	public CoviMap getUserGroupName(CoviMap params) throws Exception{
		return coviMapperOne.select("groupware.privacy.selectUserGroupName", params);
	}
	
	// 개인환경 설정 진입 시 본인 비밀번호 확인
	@Override
	public int checkPasswordCnt(CoviMap params) throws Exception{
		final String cryptoType = PropertiesUtil.getSecurityProperties().getProperty("cryptoType");

		StringUtil func = new StringUtil();
		String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
		
		CoviMap param = new CoviMap();
		String userID = SessionHelper.getSession("USERID");
		String logonID = SessionHelper.getSession("LogonID");
		String nowPassword = (String) params.get("nowPassword");

		param.put("userCode", userID);
		param.put("logonID", logonID);
		
		if(func.f_NullCheck(cryptoType).equals("R")){
			nowPassword = RSA.decryptRsa((PrivateKey) params.get("__CoviRPK__"), nowPassword); 
		}else if(func.f_NullCheck(cryptoType).equals("A")){
			AES aes = new AES("", "P");
			
			nowPassword = aes.pb_decrypt(nowPassword);
		}
					  
		param.put("nowPassword", nowPassword);
		param.put("aeskey", aeskey);
		
		return (int) coviMapperOne.getNumber("common.login.checkPasswordCnt", param);
	}
	
	// 개인환경 설정 > 기본정보 수정
	@Override
	public int updateUserInfo(CoviMap params) throws Exception {
		//String userId = params.getString("userId");
		//int retCnt = 0;
		//String photoPath = "";
		
/*		if (!params.getString("photoFileId").isEmpty()) {	// front 이미지
			CoviList fileJa = (CoviList) JSONSerializer.toJSON(params.getString("photoFileId"));			
			CoviList backFileJa = fileSvc.moveToBack(fileJa, "/GWStorage/Privacy/", "Privacy", userId, "NONE", "0");	// 프론트 TO 백
								
			params.put("photoFileId", backFileJa.getJSONObject(0).getString("FileID"));
			photoPath = "/GWStorage/Privacy/" + backFileJa.getJSONObject(0).getString("FilePath") + backFileJa.getJSONObject(0).getString("SavedName");
			params.put("photoPath", photoPath);
		}
		
		if (!params.getString("deleteFileId").isEmpty()) {	// back 이미지
			params.put("fileIdArr", params.getString("deleteFileId").split("\\,"));
			
			coviMapperOne.delete("framework.FileUtil.deleteFileDbByFileId", params);	// back 이미지 삭제
		}	*/	
		
		
		/*		retCnt = coviMapperOne.update("groupware.privacy.updateUserInfo", params);
		if(retCnt > 0){
			SessionHelper.setSession("PhotoPath", photoPath);
		}*/
		
		
		//change Timezone
		if(params.get("timeZoneCode") != null) {
			String timeZoneCode = params.getString("timeZoneCode");
			CoviList timeZoneCodeArray = RedisDataUtil.getBaseCode("TimeZone");
			
			for(Object obj : timeZoneCodeArray) {
				CoviMap timeZoneCodeObj = (CoviMap)obj;
				
				if(timeZoneCodeObj.getString("Code").equals(timeZoneCode)) {
					SessionHelper.setSession("UR_TimeZone", StringUtil.replaceNull(timeZoneCodeObj.getString("Reserved1"), "09:00:00"));
					SessionHelper.setSession("UR_TimeZoneCode", timeZoneCodeObj.getString("Code"));
					SessionHelper.setSession("UR_TimeZoneDisplay", ComUtils.ConvertToTimeZoneDisplay(timeZoneCodeObj.getString("Reserved2")));
				
					break;
				}
			}
		}
		
		
		return coviMapperOne.update("groupware.privacy.updateUserInfo", params);
	}
	
	// 개인환경 설정 > 부재설정 수정
	@Override
	public int updateUserAbsense(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.privacy.updateUserAbsense", params);
	}	
	
	// 개인환경 설정 > PUSH알림설정 수정
	@Override
	public int updateUserPush(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.privacy.updateUserPush", params);
	}
	
	// 개인환경 설정 > 테마 설정 수정
	@Override
	public int updateThemeType(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.privacy.updateThemeType", params);
	}
	
	// 개인환경설정 > 통합 메세징 설정 조회
	@Override
	public CoviMap getUserMessagingSetting(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList headerData = new CoviList();
		CoviList userSettingData = new CoviList();
		String lang = SessionHelper.getSession("lang");
		
		CoviList media = RedisDataUtil.getBaseCode("NotificationMedia"); //메세지 유형

		ArrayList<String> mediaCodes = new ArrayList<String>();
		for (int i=0; i< media.size(); i++) {
			if(media.getJSONObject(i).getString("Code").equalsIgnoreCase("NotificationMedia") ) continue;
			
			mediaCodes.add(media.getJSONObject(i).getString("Code"));
		}
		
		CoviList userSettingList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.privacy.selectUserMessagingSetting", params), 
				"CodeID,BizSection,CodeGroup,Code,CodeName,MultiCodeName,EnableMedia,EditableMedia,DefaultMedia,Description,ModifyDate,parentCodeName,parentMultiCodeName,MediaType,ModifyName");
		
		for (int i=0; i<userSettingList.size(); i++) {
			CoviMap dataObj = userSettingList.getJSONObject(i);
			
			CoviList tempJa = new CoviList();
			CoviMap tempJo = new CoviMap();

			String bizSection = dataObj.getString("BizSection");
			String enableMedia = dataObj.getString("EnableMedia"); //모든 발송 가능 매체 
			String editableMedia = dataObj.getString("EditableMedia"); // 사용자가 설정 가능한 매체 
			String defaultMedia = dataObj.getString("DefaultMedia");  // 초기설정값 
			String mediaType = dataObj.has("MediaType") ? dataObj.getString("MediaType") : "";
			
			dataObj.put("checkboxStatus", makeCheckboxString(enableMedia, editableMedia, defaultMedia, mediaType, mediaCodes)); // 체크박스 상태 문자열 가공
			
			int index = getIndexInArr("bizSection", bizSection, userSettingData);	// 카테고리 별 리스트 포함 여부 확인
			
			if (index == -1) { //카테고리가 들어가 있지 않을 경우 
				tempJa.add(dataObj);
				
				tempJo.put("bizSection", bizSection);
				tempJo.put("parentCodeName", DicHelper.getDicInfo(dataObj.getString("parentMultiCodeName"), lang));
				tempJo.put("modifyDate", dataObj.getString("ModifyDate"));
				tempJo.put("detail", tempJa);

				userSettingData.add(tempJo);
			} else { //카테고리가 들어가 있을 경우 - 해당 카테고리에 detail 에 추가 
				(userSettingData.getJSONObject(index)).getJSONArray("detail").add(dataObj);
			}
		}
		
		//category(업무영역) 별로 최상위 체크박스 체크 여부 지정
		for(int i = 0; i <userSettingData.size(); i++){
			CoviList detailArr = userSettingData.getJSONObject(i).getJSONArray("detail");

			HashMap<String, Integer> enableCount = new HashMap<String, Integer>(); 
			HashMap<String, Integer> editableCount= new HashMap<String, Integer>(); 
			HashMap<String, Integer> checkedCount= new HashMap<String, Integer>(); 
			
			for (String mediaCode : mediaCodes) {
				enableCount.put(mediaCode, 0);
				checkedCount.put(mediaCode, 0);
			}
			
			for(int j = 0;  j< detailArr.size(); j++){
				CoviMap detailObj = detailArr.getJSONObject(j);
				
				for (String mediaCode : mediaCodes) {
					if(detailObj.getString("EnableMedia").toUpperCase().contains(mediaCode.toUpperCase())){
						enableCount.put(mediaCode, enableCount.get(mediaCode)+1);
					}
					if(detailObj.getString("MediaType").toUpperCase().contains(mediaCode.toUpperCase())){
						checkedCount.put(mediaCode, checkedCount.get(mediaCode)+1);
					}
				}
			}
			
			for (String mediaCode : mediaCodes) {
				Integer ienablecnt = enableCount.get(mediaCode);
				Integer icheckedcnt = checkedCount.get(mediaCode);
				if(ienablecnt == 0){ //표시안함
					userSettingData.getJSONObject(i).put(mediaCode, "disabled"); //hidden
				//}else	if(checkedCount.get(mediaCode)==detailArr.size()){ //전체선택 상태
				}else if(icheckedcnt.equals(ienablecnt)){ //전체선택 상태
					userSettingData.getJSONObject(i).put(mediaCode, "checked");
				}else if(ienablecnt > 0 && icheckedcnt == 0){ // 전체 항목 체크 안됨
					userSettingData.getJSONObject(i).put(mediaCode, "unchecked");
				}else if(ienablecnt > 0 && icheckedcnt > 0){ // 부분선택 상태
					userSettingData.getJSONObject(i).put(mediaCode, "indeterminate");
				}
			}
		}
		
		for (int i=0; i< media.size(); i++) {
			int enableCount = 0;
			int checkedCount = 0;
			String mediaCode = media.getJSONObject(i).getString("Code");
			
			if(mediaCode.equalsIgnoreCase("NotificationMedia")) continue;
			
			CoviMap headerObj = new CoviMap();
			headerObj.put("Code", mediaCode);
			headerObj.put("CodeName", DicHelper.getDicInfo(media.getJSONObject(i).getString("MultiCodeName"), lang));
			for(int j = 0; j <userSettingData.size(); j++){
				CoviMap userSettingObj = userSettingData.getJSONObject(j);
				
				if(userSettingObj.getString( mediaCode ) .equalsIgnoreCase("checked") ){
					checkedCount++;
					enableCount++;
				}else if(! userSettingObj.getString( mediaCode ) .equalsIgnoreCase("disabled") ){
					enableCount++;
				}
			}
			
			if(enableCount == 0){ //표시안함
				headerObj.put( "State", "disabled");  //hidden
			//}else	if(checkedCount == userSettingData.size()){ //전체선택 상태
			}else	if(checkedCount == enableCount){ //전체선택 상태
				headerObj.put( "State", "checked");
			}else if(enableCount> 0 && checkedCount == 0){ // 전체 항목 체크 안됨
				headerObj.put( "State", "unchecked");
			}else if(enableCount > 0 && checkedCount> 0){ // 부분선택 상태
				headerObj.put("State", "indeterminate");
			}
			
			headerData.add(headerObj);
		}
		
		params.put("userCode", SessionHelper.getSession("USERID"));
		params.put("seq", SessionHelper.getSession("URBG_ID"));
		CoviMap map = coviMapperOne.select("groupware.privacy.selectUserPrivacySetting", params);		
		
		resultList.put("header", headerData);
		resultList.put("data", userSettingData);
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "UserID,UserCode,MailAddress,BirthDiv,BirthDate,ExternalMailAddress,Mobile,Fax,PhoneNumberInter,IPPhone,PhoneNumber,updateFileId,CompanyName,DeptName,Mail,AbsenseUseYN,AbsenseDuty,AbsenseTermStart,AbsenseTermEnd,AbsenseReason,AbsenseType,JobPositionName,JobTitleName,DisplayName,absenseDutyText,updateFilePath,ChargeBusiness,PushAllowYN,PushAllowWeek,PushAllowStartTime,PushAllowEndTime"));	
		
		return resultList;
	}
	
	// 포탈 목록조회
	@Override
	public CoviList selectMyPortalList(Set<String> authorizedObjectCodeSet, String userID) throws Exception {
		String[] aclPortalArr = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
		CoviList list = new CoviList();
		
		if(aclPortalArr.length > 0){
			CoviMap params = new CoviMap();
			params.put("aclPortalArr", aclPortalArr);
			params.put("lang", SessionHelper.getSession("lang"));
			
			list = coviMapperOne.list("user.portal.selectMyPortalList", params);
		}
		
		return list;
	}
	

	// 리스트 포함 여부 확인
	private int getIndexInArr(String key, String id, CoviList ja) throws Exception {
		int index = -1;
		for (int i=0; i<ja.size(); i++) {
			if (id.equals(ja.getJSONObject(i).get(key))) {
				index = i;
				
				break;	
			}
		}
		
		return index;
	}
	
	// 체크박스 상태 문자열 가공
	private String makeCheckboxString(String enableMedia, String editableMedia, String defaultMedia, String mediaType, ArrayList<String> strArr) throws Exception {
		// 1;2;3;4 : 1-Code, 2-체크박스 보임 여부, 3-체크박스 수정가능 여부, 4-체크박스 체크 여부
		String returnStr = "";
		StringBuffer buf = new StringBuffer();
		for (int i=0; i< strArr.size(); i++) {
			String str = strArr.get(i).toUpperCase();
			
			if (i > 0) buf.append(",");
			buf.append(str).append(";");
			
			buf.append(enableMedia.contains(str)? "Y":"N").append(";");
			buf.append(editableMedia.contains(str)? "Y":"N").append(";");
			buf.append(mediaType.contains(str)? "Y":"N");
		}
		returnStr = buf.toString();
		return returnStr;
	}
	
	// 개인환경설정 > 통합 메세징 설정
	@Override
	public int updateUserMessagingSetting(CoviMap params) throws Exception {
		SettingVO settingVO = (SettingVO) params.get("settingVO");
		String reqTr = settingVO.getReqTr();
		int cnt = 0;
		
		if (reqTr.equals("head") || reqTr.equals("body")) {
			cnt = coviMapperOne.update("groupware.privacy.updateUserMessagingSettings", params);
		} else {
			cnt = coviMapperOne.update("groupware.privacy.updateUserMessagingSetting", params); 
		}
		
		return cnt;
	}
	
	// 개인환경설정 > 통합 메세징 설정 > 모두 초기화
	@Override
	public int deleteUserMessagingSetting(CoviMap params) throws Exception {
		return coviMapperOne.update("groupware.privacy.deleteUserMessagingSetting", params);
	}
	
	// 개인환경설정 > 접속이력
	@Override
	public CoviMap getConnectionLogList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("groupware.privacy.selectConnectionLogListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
			resultList.put("page", page);
			resultList.put("cnt", cnt);
		}
		
		CoviList list = coviMapperOne.list("groupware.privacy.selectConnectionLogList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "days,LogonDate,LogoutDate,LogonID"));
		
		return resultList;
	}
	
	// 사이트맵 > 메인메뉴 설정 팝업
	@Override
	public int updateTopMenuManage(CoviMap params) throws Exception {
		int cnt = coviMapperOne.update("groupware.privacy.updateTopMenuManage", params); 
		
		return cnt;
	}
	
	// 개인환경설정 > 기념일 관리
	@Override
	public CoviMap getAnniversaryList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("groupware.privacy.selectAnniversaryListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
			resultList.put("page", page);
			resultList.put("cnt", cnt);
		}
		
		CoviList list = coviMapperOne.list("groupware.privacy.selectAnniversaryList", params);		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "MessageID,AnniDate,AnniDateTypeText,AnniDateType,Subject,Priority,dDay,PriorityText,alarmDay,AlarmYN,Description,IsLeapMonth"));
		
		return resultList;
	}
	
	// 개인환경설정 > 기념일 관리 > 추가
	@Override
	public int insertAnniversary(CoviMap params) throws Exception {
		return coviMapperOne.insert("groupware.privacy.insertAnniversary", params);
	}
	
	// 개인환경설정 > 기념일 관리 > 수정
	@Override
	public int updateAnniversary(CoviMap params) throws Exception {
		return coviMapperOne.insert("groupware.privacy.updateAnniversary", params);
	}
	
	// 개인환경설정 > 기념일 관리 > 삭제
	@Override
	public int deleteAnniversary(CoviMap params) throws Exception {
		return coviMapperOne.insert("groupware.privacy.deleteAnniversary", params);
	}
	
	// 개인환경설정 > 기념일 관리 > 기념일 가져오기 > 엑셀 업로드
	@Override
	public int insertAnniversaryByExcel(CoviMap params) throws Exception {
		ArrayList<CoviMap> dataList = extractionExcelData(params, 0);	// 엑셀 데이터 추출
		params.put("dataList", dataList);
		
		return coviMapperOne.insert("groupware.privacy.insertAnniversaryByExcel", params);
	}
	
	// 임시파일 생성
	private File prepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        
	        return tmp;
	    } catch (IOException ioE) {
	        if (tmp != null){
	        	if(tmp.delete()) {
	        		LOGGER.info("file : " + tmp.toString() + " delete();");
	        	}
	        }
	        
	        throw ioE;
	    }
	}
	
	// 엑셀 데이터 추출
	private ArrayList<CoviMap> extractionExcelData(CoviMap params, int headerIndex) throws Exception {
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = null;
		InputStream inputStream = null;
		if(awsS3.getS3Active()){
			inputStream = mFile.getInputStream();
		}else {
			file = prepareAttachment(mFile);
		}
		ArrayList<CoviMap> returnList = new ArrayList<>();
		Workbook wb = null;
		try {
			if(awsS3.getS3Active()){
				wb = WorkbookFactory.create(inputStream);
			}else {
				wb = WorkbookFactory.create(file);
			}
			Sheet sheet = wb.getSheetAt(0);
			
			CoviMap tempJo = null;
			Iterator<Row> rowIterator = sheet.iterator();
			int cellNum = 0;
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				int rowNum = row.getRowNum();
				
				if (rowNum == headerIndex) {
					cellNum = row.getLastCellNum();	
				} else if (rowNum > headerIndex) {	// header 제외
					tempJo = new CoviMap();
					
					for (int colNum=0; colNum<cellNum; colNum++) {
						String key = "";
						switch (colNum) {
							case 0 : key = "anniDate"; break;
							case 1 : key = "anniDateType"; break;
							case 2 : key = "subject"; break;
							case 3 : key = "priority"; break;
							case 4 : key = "alarmPeriod"; break;
							case 5 : key = "description"; break;
							case 6 : key = "alarmYn"; break;
							default : break;
						}
						
						Cell cell = row.getCell(colNum, Row.CREATE_NULL_AS_BLANK);
						switch (cell.getCellType()) {
							case Cell.CELL_TYPE_BOOLEAN : tempJo.put(key, cell.getBooleanCellValue()); break;
							case Cell.CELL_TYPE_NUMERIC : tempJo.put(key, (int)cell.getNumericCellValue()); break;
							case Cell.CELL_TYPE_STRING : tempJo.put(key, cell.getStringCellValue()); break;
							case Cell.CELL_TYPE_FORMULA : tempJo.put(key, cell.getCellFormula()); break;
							default : tempJo.put(key, ""); break;
						}
					}
					
					returnList.add(tempJo);
				}
			}
		} catch (IOException e) {
			LOGGER.debug(e);
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		} finally {
			if (wb != null) { try { wb.close(); } catch (IOException ex) { LOGGER.error(ex.getLocalizedMessage(), ex); } }
			if (awsS3.getS3Active()) {
				if (inputStream != null) { try { inputStream.close(); } catch (IOException ex) { LOGGER.error(ex.getLocalizedMessage(), ex); } }
			} else {
				if (file != null) {
					if (file.delete()) {
						LOGGER.info("file : " + file.toString() + " delete();");
					}
				}
			}
		}
		
		return returnList;
	}

	// 개인환경설정 > 기본정보 > 이미지업로드
	@Override
	public CoviMap updateUserImage(CoviMap params) throws Exception {
		int cnt = 0;
		FileOutputStream out = null;
		CoviMap result = new CoviMap();
		
		try {
			String userCode = SessionHelper.getSession("UR_Code");
			String path = RedisDataUtil.getBaseConfig("ProfileImageFolderPath");
			String companyCode = SessionHelper.getSession("DN_Code");
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);

			if(awsS3.getS3Active(companyCode)){
				// 1. 파일 생성(리사이즈, 원본)
				MultipartFile mFile = (MultipartFile) params.get("uploadfile");
				String dir = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path;
				String key = dir+userCode + "_org.jpg";
				awsS3.upload(mFile.getInputStream(), key, mFile.getContentType(), mFile.getSize());

				String thum_key = dir+userCode + ".jpg";
				fileSvc.makeThumb(thum_key, mFile.getInputStream(), FilenameUtils.getExtension(mFile.getName()));
			}else {
				// 0. 디렉토리, 파일 체크
				File dir = new File(FileUtil.checkTraversalCharacter(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path));
				if (!dir.exists()){
					if(dir.mkdirs()) {
						LOGGER.info("path : " + dir + " mkdirs();");
					}
				}

				File existFile = new File(dir, userCode);
				if (existFile.exists()) {
					try {
						if(existFile.delete()) {
							LOGGER.info("file : " + existFile.toString() + " delete();");
						}

						File orgFile = new File(dir, userCode + "_org");
						if(orgFile.exists()) {
							if(orgFile.delete()) {
								LOGGER.info("file : " + orgFile.toString() + " delete();");
							}
						}
					} catch (NullPointerException e) {
						LOGGER.error(e.getLocalizedMessage(), e);
					}  catch (Exception ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
					}					
				}

				// 1. 파일 생성(리사이즈, 원본)
				MultipartFile mFile = (MultipartFile) params.get("uploadfile");
				File file = new File(dir, userCode + "_org.jpg");
				mFile.transferTo(file);

				Image src = ImageIO.read(file);
				BufferedImage resizeImage = new BufferedImage(200, 200, BufferedImage.TYPE_INT_RGB);
				resizeImage.getGraphics().drawImage(src.getScaledInstance(200, 200, Image.SCALE_SMOOTH), 0, 0, null);
				out = new FileOutputStream(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path + userCode + ".jpg");
				ImageIO.write(resizeImage, "jpg", out);
			}

		    
			// 2. photoPath 업데이트
			params.put("photoPath", backStorage + path + userCode + ".jpg");
			params.put("userCode", userCode);
			
			cnt = coviMapperOne.update("groupware.privacy.updateUserPhotoPath", params);
			
			// 3. 세션
			SessionHelper.setSession("PhotoPath", backStorage + path + userCode + ".jpg");
				
			result.put("photoPath", params.getString("photoPath"));
			result.put("cnt", cnt);
	
		} catch (IOException e) {
			LOGGER.debug(e);
		} catch (NullPointerException e) {
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		} finally {
			if (out != null) { try { out.flush(); out.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
		}
		
		return result; 
	}
	
	public boolean removeGmail(CoviMap params) throws Exception {
		int cnt = 0;
		boolean flag = false;
		
		cnt = coviMapperOne.delete("groupware.privacy.removeGmail", params);
		
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	@Override
	public boolean getTSSyncTF() throws Exception {
		boolean bReturn;
		bReturn = RedisDataUtil.getBaseConfig("IsSyncTimeSquare").equals("Y") ? true : false;
		return bReturn;
	}

	/**
	 * 타임스퀘어 계정존재 여부 조회
	 * @param params - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public boolean getUsersyncexistuser(CoviMap params) throws Exception {
		boolean bReturn = false;
		String apiURL = null;
		String sMode = "syncexistuser?d=";
		String method = "GET";
		
		try {
			String sUsername = params.get("UserCode").toString();
			
			sUsername = java.net.URLEncoder.encode(sUsername, java.nio.charset.StandardCharsets.UTF_8.toString());
			
			apiURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			LOGGER.debug(apiURL);
			apiURL = apiURL + "{" + "\"username\":\"" +sUsername + "\"" + "}";
			CoviMap jObj = getJson(apiURL, method);
			
			if(jObj.get("returnCode").toString().equals("0"))
			{
				if(jObj.get("userstatus").toString().equals("false"))
					bReturn = false;
				else
					bReturn = true;
			}else
			{
				bReturn = false;
				LOGGER.error(jObj.toString()); //print error context
			}
		} catch (NullPointerException e) {
			LOGGER.error("TimeSquare getUsersyncexistuser Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare getUsersyncexistuser Error [" + params.get("UserCode") + "]" + "[Message : " +  e.getMessage() + "]");
		}
		return bReturn;
	}
	
	
	/**
	 * 타임스퀘어 사용자 사진 변경
	 * @param params - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int setUserPhoto(CoviMap params) throws Exception {
		int bReturn = 0;
		String sMode = "syncimage";

		if(!params.getString("PhotoPath").equals("")) {
			String userCode = params.getString("UserCode");
			final String path = RedisDataUtil.getBaseConfig("ProfileImageFolderPath");
			String companyCode = SessionHelper.getSession("DN_Code");
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);

			if(awsS3.getS3Active(companyCode)){
				String dir = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path;
				String key = dir + "/"+ userCode;
				String oriKey = dir + "/"+ userCode+ "_org";
				if(awsS3.exist(key)){
					awsS3.delete(key);
				}
				if(awsS3.exist(oriKey)){
					awsS3.delete(oriKey);
				}
				if (params.get("FileInfo") != null && !params.get("FileInfo").equals("")) {
					MultipartFile mFile = (MultipartFile) params.get("FileInfo");
					String oriKey2 = dir + "/"+ userCode+ "_org.jpg";
					awsS3.upload(mFile.getInputStream(), oriKey2, mFile.getContentType(), mFile.getSize());
				}

			}else {
				File dir = new File(FileUtil.checkTraversalCharacter(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path));
				if (!dir.exists()) {
					if (dir.mkdirs()) {
						LOGGER.info("path : " + dir + " mkdirs();");
					}
				}

				File existFile = new File(dir, userCode);
				if (existFile.exists()) {					
					try {
						if (existFile.delete()) {
							LOGGER.info("file : " + existFile.toString() + " delete();");
						}

						File orgFile = new File(dir, userCode + "_org");
						if(orgFile.exists()) {
							if (orgFile.delete()) {
								LOGGER.info("file : " + orgFile.toString() + " delete();");
							}
						}
					} catch (NullPointerException ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
					} catch (Exception ex) {
						LOGGER.error(ex.getLocalizedMessage(), ex);
					}
				}

				if (params.get("FileInfo") != null && !params.get("FileInfo").equals("")) {
					MultipartFile mFile = (MultipartFile) params.get("FileInfo");
					File file = new File(dir, userCode + "_org.jpg");
					mFile.transferTo(file);
				}
			}
			
			String username = params.get("LogonID").toString();
			String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path + userCode  + ".jpg";
			String requestURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			String charset = "UTF-8";
			
			try	{
				MultipartUtility multipart = new MultipartUtility(requestURL, charset);
				
				multipart.addFormField("username", userCode);
				if(awsS3.getS3Active(companyCode)){
					AwsS3Data awsS3Data = awsS3.downData(filePath);
					try (InputStream is = awsS3Data.getContentStream();){
						multipart.addFilePart("image", is, awsS3Data.getName());
					}
				}else {
					multipart.addFilePart("image", new File(FileUtil.checkTraversalCharacter(filePath)));
				}
				List<String> response = multipart.finish();	        
				
				if(LOGGER.isDebugEnabled()) {
					for (String line : response) {	            
						LOGGER.debug(line);
					}
				}
				bReturn = 0;
			} catch(IOException ex) {
				bReturn = 2;
				LOGGER.error(ex.getLocalizedMessage(), ex);
			} catch(NullPointerException ex) {
				bReturn = 2;
				LOGGER.error(ex.getLocalizedMessage(), ex);
			} catch(Exception ex) {
				bReturn = 2;
				LOGGER.error(ex.getLocalizedMessage(), ex);
			}
		}
		return bReturn;
	}
	
	public CoviMap getJson(String encodedUrl, String method) throws Exception {
		CoviMap resultList = new CoviMap();
		HttpURLConnectUtil url= new HttpURLConnectUtil();
		String sMethod = method;
		
		try {
			if(sMethod.equals("POST")) {resultList = url.httpConnect(encodedUrl,sMethod,10000,10000,"xform","Y");}
			else if(sMethod.equals("GET")) {resultList = url.httpConnect(encodedUrl,sMethod,10000,10000,"xform","Y");}
		} catch(NullPointerException ex) {
			throw ex;
		} catch(Exception ex) {
			throw ex;
		} finally {
			url.httpDisConnect();
		}
		
		return resultList;
	}
}
