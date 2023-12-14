package egovframework.covision.groupware.bizcard.user.util;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.LogManager;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.covision.groupware.util.BoardUtils;
import ezvcard.VCard;
import ezvcard.parameter.EmailType;
import ezvcard.parameter.TelephoneType;
import ezvcard.property.Anniversary;
import ezvcard.property.Organization;



public class BizCardUtils {
	
	/**
	 * @param clist
	 * @param str
	 * @return JSONArray
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public static CoviList coviSelectJSONForExcel(CoviList clist, String str) throws Exception {
		String[] cols = str.split(",");

		CoviList returnArray = new CoviList();

		if (null != clist && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {

				CoviMap newObject = new CoviMap();

				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();

					while (iter.hasNext()) {
						Object ar = iter.next();
						if (ar.equals(cols[j].trim())) {
							newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
						}
					}
				}
				returnArray.add(newObject);
			}
		}
		return returnArray;
	}
	
	/**
	 * @param clist
	 * @param str
	 * @param fileType
	 * @return StringBuilder
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public static StringBuilder coviSelectJSONForCSV(CoviList clist, String str, String fileType) throws Exception {
		String[] cols = str.split(",");
		int[] colsNum = new int[cols.length];
		
		String headerStr;
		if(fileType.equals("CSV_EX")) {
			headerStr = "이름,성,중간 이름,전체 이름,애칭,전자 메일 주소,주소(집),구/군/시(집),우편 번호(집),시/도(집),국가(집),전화,집 팩스,휴대폰,개인 웹 페이지,주소(회사),구/군/시(회사),우편 번호(회사),시/도(회사),국가(회사),회사 웹 페이지,회사 전화,회사 팩스,호출기,회사,직함,부서,사무실,메모,기념일,메신저";
			for(int a = 0; a < cols.length; a++) {
				switch(cols[a]) {
				case "Name": colsNum[a] = 3; break;
				case "EMAIL": colsNum[a] = 5; break;
				case "HomePhone": colsNum[a] = 11; break;
				case "CellPhone": colsNum[a] = 13; break;
				case "ComAddress": colsNum[a] = 15; break;
				case "ComZipcode": colsNum[a] = 17; break;
				case "ComWebSite": colsNum[a] = 20; break;
				case "ComPhone": colsNum[a] = 21; break;
				case "FAX": colsNum[a] = 22; break;
				case "ComName": colsNum[a] = 24; break;
				case "JobTitle": colsNum[a] = 25; break;
				case "DeptName": colsNum[a] = 26; break;
				case "Memo": colsNum[a] = 28; break;
				case "AnniversaryText": colsNum[a] = 29; break;
				case "MessengerID": colsNum[a] = 30; break;
				default : break;
				}
			}
		} else {
			headerStr = "호칭(영문),이름,중간 이름,성,호칭(한글),회사,부서,직함,근무지 주소 번지,근무지 번지 2,근무지 번지 3,근무지 구/군/시,근무지 시/도,근무지 우편 번호,근무지 국가,집 번지,집 번지 2,집 번지 3,집 주소 구/군/시,집 주소 시/도,집 주소 우편 번호,집 주소 국가,기타 번지,기타 번지 2,기타 번지 3,기타 구/군/시,기타 시/도,기타 우편 번호,기타 국가,비서 전화 번호,근무지 팩스,근무처 전화,근무처 전화 2,다시 걸 전화,카폰,회사 대표 전화,집 팩스,집 전화 번호,집 전화 2,ISDN,휴대폰,기타 팩스,기타 전화,호출기,기본 전화,무선 전화,TTY/TDD 전화,텔렉스,거리,기념일,메신저,관리자 이름,국가,근무처 주소 사서함,기타 주소 사서함,디렉터리 서버,머리글자,메모,배우자,범주 항목,비서 이름,비용 정보,사무실 위치,사용자 1,사용자 2,사용자 3,사용자 4,생일,성별,숨김,언어,우선 순위,우편물 종류,웹 페이지,인터넷 약속 있음/약속 없음,자녀,전자 메일 주소,전자 메일 유형,전자 메일 표시 이름,전자 메일 2 주소,전자 메일 2 유형,전자 메일 2 표시 이름,전자 메일 3 주소,전자 메일 3 유형,전자 메일 3 표시 이름,주민 등록 번호,중심어,직업,집 주소 사서함,추천인,취미,ID 번호";
			for(int a = 0; a < cols.length; a++) {
				switch(cols[a]) {
				case "Name": colsNum[a] = 1; break;
				case "ComName": colsNum[a] = 5; break;
				case "DeptName": colsNum[a] = 6; break;
				case "JobTitle": colsNum[a] = 7; break;
				case "ComAddress": colsNum[a] = 8; break;
				case "ComZipcode": colsNum[a] = 13; break;
				case "FAX": colsNum[a] = 30; break;
				case "ComPhone": colsNum[a] = 31; break;
				case "HomePhone": colsNum[a] = 37; break;
				case "CellPhone": colsNum[a] = 40; break;
				case "MessengerID": colsNum[a] = 50; break;
				case "Memo": colsNum[a] = 57; break;
				case "AnniversaryText": colsNum[a] = 49; break;
				case "ComWebSite": colsNum[a] = 73; break;
				case "EMAIL": colsNum[a] = 76; break;
				default : break;
				}
			}
		}
		
		String[] headers = headerStr.split(",");

		StringBuilder returnString = new StringBuilder();

		if (null != clist && clist.size() > 0) {
			returnString.append(headerStr);
			for (int i = 0; i < clist.size(); i++) {
				returnString.append("\r\n");
				
				String newString = "";
				List<String> newStringArr = new ArrayList<String>();
				for(int j = 0; j < headers.length; j++) {
					boolean colsEmpty = true;					
					for (int k = 0; k < cols.length; k++) {
						if(j == colsNum[k]) {
							if(cols[k].equals("Memo")) {
								newStringArr.add(clist.getMap(i).getString(cols[k]).replaceAll("\\r\\n", "|"));
							} else {
								newStringArr.add(clist.getMap(i).getString(cols[k]));
							}							
							colsEmpty = false;
						}
					}
					
					if(colsEmpty) {
						newStringArr.add("");
					}
					
					if(newStringArr.size() > 0) {
						newString = StringUtils.join(newStringArr, ",");
					}
				}
				returnString.append(newString);
			}
		} else {
			returnString.append(headerStr);
		}
		
		return returnString;
	}
	
	@SuppressWarnings({ "static-access" })
	public static StringBuilder coviSelectJSONForVCF(CoviList clist) throws Exception {
		StringBuilder returnString = new StringBuilder();

		if (null != clist && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {
				CoviMap bizcardInfo = clist.getMap(i);
				VCard vCard = new VCard();
				
				// 버젼
				vCard.setVersion(vCard.getVersion().V4_0);
				
				// 이름
				vCard.setFormattedName(bizcardInfo.getString("Name"));
				
				// 기념일
				if(StringUtils.isNotBlank(bizcardInfo.getString("AnniversaryText"))) {
					Anniversary anniversary = null;
					try {
						anniversary = new Anniversary(java.text.DateFormat.getDateInstance().parse(bizcardInfo.getString("AnniversaryText"))); 
					} catch (ParseException e) {
						LogManager.getLogger(BizCardUtils.class).debug(e);
						//
					}
					
					vCard.setAnniversary(anniversary);
				}
				
				// 이메일
				for(String email : bizcardInfo.getString("EMAIL").split(":")) {
					vCard.addEmail(email, EmailType.INTERNET);
				}
				
				// 핸드폰
				for(String telPhone : bizcardInfo.getString("TelPhone").split(":")) {
					vCard.addTelephoneNumber(telPhone, TelephoneType.CELL);
				}
				
				// 자택전화
				for(String homePhone : bizcardInfo.getString("HomePhone").split(":")) {
					vCard.addTelephoneNumber(homePhone, TelephoneType.HOME);
				}
				
				// 사무실전화
				for(String cellPhone : bizcardInfo.getString("CellPhone").split(":")) {
					vCard.addTelephoneNumber(cellPhone, TelephoneType.WORK);
				}
				
				// 팩스
				for(String fax : bizcardInfo.getString("FAX").split(":")) {
					vCard.addTelephoneNumber(fax, TelephoneType.FAX);
				}
				
				Organization org = new Organization();
				// 회사
				org.getValues().add(bizcardInfo.getString("ComName"));
				// 부서
				org.getValues().add(bizcardInfo.getString("DeptName"));
				vCard.setOrganization(org);
				
				// 직책
				vCard.addTitle(bizcardInfo.getString("JobTitle"));
				
				returnString.append(vCard.write());
			}
		}
		
		return returnString;
	}
}
