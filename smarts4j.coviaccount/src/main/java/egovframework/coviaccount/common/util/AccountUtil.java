package egovframework.coviaccount.common.util;

import java.lang.invoke.MethodHandles;
import java.text.DecimalFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Properties;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.FileUtil;
import net.sf.json.JSONNull;


@Component("AccountUtil")
public class AccountUtil  {
	
	private static final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	private Properties accountProperties = PropertiesUtil.getExtensionProperties();

	/**
	 * @Method Name : checkNull
	 * @Description : null값 체크
	 */
	public static Boolean checkNull(String inputVal) throws Exception {
		Boolean rtnVal = true;
		if(inputVal==null
				||"".equals(inputVal)){
			return rtnVal;
		}
		else{
			rtnVal = false;
		}
		return rtnVal;
	}

	/**
	 * @Method Name : setSearchPage
	 * @Description : 목록조회화면 페이징 파라메터 세팅 CoviMap
	 */
	public static CoviMap setSearchPage(HttpServletRequest request, CoviMap params) throws Exception {
		CoviMap returnVal = new CoviMap();
		// pageNo : 현재 페이지 번호
		// pageSize : 페이지당 출력데이타 수
		int pageSize = 1;
		int pageNo =  1;
		if (request.getParameter("pageSize") != null || StringUtil.replaceNull(request.getParameter("pageSize")).length() > 0){
			pageSize = Integer.parseInt(request.getParameter("pageSize"));	
		}
		if (request.getParameter("pageNo") != null || StringUtil.replaceNull(request.getParameter("pageNo")).length() > 0){
			pageNo = Integer.parseInt(request.getParameter("pageNo"));	
		}
		int pageOffset = (pageNo - 1) * pageSize;
		if(pageOffset < 0) {
			throw new Exception();
		}

		params.put("pageOffset", pageOffset);
		params.put("pageSize", pageSize);
		params.put("pageNo", pageNo);
		return returnVal;
	}

	/**
	 * @Method Name : jobjGetStr
	 * @Description : jsonobj에서 값 획득
	 */
	public static String jobjGetStr(CoviMap obj, String key) {
		String retVal = "";
		try{
			retVal = obj.optString(key);
		} catch(NullPointerException e){
			logger.error(e.getLocalizedMessage(), e);
		}
		catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
		}
		return retVal;
	}

	/**
	 * @Method Name : jobjGetInt
	 * @Description : jsonobj에서 값 획득
	 */
	public static int jobjGetInt(CoviMap obj, String key) {
		int retVal = -1;
		try{
			retVal = obj.optInt(key, -1);
		} catch(NullPointerException e){
			logger.error(e.getLocalizedMessage(), e);
		}
		catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
		}
		return retVal;
	}
	/**
	 * @Method Name : jobjGetObj
	 * @Description : jsonobj에서 값 획득
	 */
	public static Object jobjGetObj(CoviMap obj, String key) {
		Object retVal = null;
		try{
			if(!(obj.get(key) instanceof JSONNull))
				retVal = obj.get(key);
		} catch(NullPointerException e){
			logger.error(e.getLocalizedMessage(), e);
		}
		catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
		}
		return retVal;
	}

	/**
	 * @Method Name : listPageCount
	 * @Description : 페이징 처리
	 */
	public CoviMap listPageCount(int cnt, CoviMap param){
		CoviMap returnData = new CoviMap();
		try {
			int pageSize = 1;
			int pageNo =  param.getInt("pageNo");
			if (param.get("pageNo")!= null || param.get("pageSize") != null){
				pageSize = param.getInt("pageSize");
			}
			int pageOffset = (pageNo - 1) * pageSize;

			int pageCount = 1 + (cnt / pageSize);

			if( (cnt % pageSize) == 0){
				pageCount = pageCount - 1; 
			}
			int start =  (pageNo - 1) * pageSize + 1; 
			int end = start + pageSize -1;

			returnData.put("pageCount", pageCount);	//pageCount: 페이지 개수
			returnData.put("listCount", cnt);	//rowCount: 전체 Row 갯수 
			returnData.put("pageSize", pageSize);		
			returnData.put("pageOffset", pageOffset);	//DB 스크립트 내부 처리용 param: LIMIT #{pageSize} OFFSET #{pageOffset} 
			returnData.put("rowStart", start);		//rowStart	: Oracle 페이징처리용
			returnData.put("rowEnd", end);			//rowEnd	: Oracle 페이징처리용

		} catch(NullPointerException e){
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			returnData = new CoviMap();
		}
		return returnData;
	}

	/**
	 * @Method Name : getCardNumStr
	 * @Description : 카드번호 숨김처리
	 */
	public String getCardNumStr(String cardNum){
		return "**********" + cardNum.substring(10);
	}

	/**
	 * @Method Name : getAmountStr
	 * @Description : 금액 ,처리
	 */
	public String getAmountStr(String amount){
		String rtAmount = "";
		try {
			amount	= amount.replaceAll(",", "");
			amount	= Double.valueOf(amount).toString();

			DecimalFormat df = new DecimalFormat("#,###");
			rtAmount = df.format(Double.valueOf(amount));

		} catch(NullPointerException e){
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
			rtAmount = "0";
		}
		return rtAmount;
	}

	/**
	 * @Method Name : getPropertyInfo
	 * @Description : 프로퍼티 값 획득
	 */
	public String getPropertyInfo(String str){
		//accountProperties = property/account.properties
		return accountProperties.getProperty(str) == null ? "" : accountProperties.getProperty(str);
	}

	/**
	 * @Method Name : getBaseCodeInfo
	 * @Description : 기초코드값 획득
	 */
	public String getBaseCodeInfo(String strCodeGroup, String strCode){
		String returnValue = "";

		CoviList aprvType = RedisDataUtil.getBaseCode(strCodeGroup);
		for (int i=0; i<aprvType.size(); i++) {
			if(aprvType.getJSONObject(i).getString("Code").equalsIgnoreCase(strCode)) {
				if(aprvType.getJSONObject(i).containsKey("Reserved1")) {
					returnValue = aprvType.getJSONObject(i).getString("Reserved1");
				}
				break;
			}
		}

		return returnValue;		
	}

	/**
	 * @Method Name : getBaseCodeInfo
	 * @Description : 기초코드값 획득
	 */
	public String getBaseCodeInfo(String strCodeGroup, String strCode, String strDomainID){
		String returnValue = "";

		CoviList aprvType;
		try {
			aprvType = RedisDataUtil.getBaseCode(strCodeGroup, strDomainID);
			for (int i=0; i<aprvType.size(); i++) {
				if(aprvType.getJSONObject(i).getString("Code").equalsIgnoreCase(strCode)) {
					returnValue = aprvType.getJSONObject(i).getString("Reserved1");
					break;
				}
			}
		} catch(NullPointerException e){
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}

		return returnValue;		
	}

	/**
	 * @Method Name : addGetParam
	 * @Description : SAPOdata Get Parameter
	 */
	public String addGetParam(String pParams, String pParamName, String pParamValue,String pOper1, String pOper2){
		if(pParams.equals("")){
			pParams = pParamName+" "+pOper1+" '"+pParamValue+"'";
		}else{
			pParams =pParams +" " + pOper2 +" "+ pParamName+" "+pOper1+" '"+pParamValue+"'";
		}
		return pParams;
	}

	/**
	 * @Method Name : getDateFromJsonDate
	 * @Description : SAPOdata JSON Date to Java Date
	 */
	public Date getDateFromJsonDate(String pJsonDateString){
		Date resultDate = null;
		Pattern pattern = Pattern.compile("(?<=\\()(\\d+)(([-+])(\\d+))?(?=\\))");
		try{
			Matcher m = pattern.matcher(pJsonDateString);
			if (m.find()) {
				long timestamp = Long.parseLong(m.group(1));
				Integer minutes = null;
				Boolean addOrSubstract = null;
				if (m.group(2) != null) {
					addOrSubstract = "+".equals(m.group(3)); 
					if (m.group(4) != null) {
						minutes = Integer.parseInt(m.group(4));
					}
				}

				Calendar c = Calendar.getInstance();
				c.setTime(new Date(timestamp));
				if (minutes != null) {
					c.add(
							Calendar.MINUTE, 
							addOrSubstract != null ? 
									(addOrSubstract ? minutes : -minutes) : 0
							);
				}
				resultDate = c.getTime();
			}
		} catch(NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception ex){
			resultDate = null;
		}

		return resultDate;		
	}

	/**
	 * @Method Name : convertNullToSpace
	 * @Description : 파라미터 유형에 따라 null을 공백으로 처리
	 */
	public static Object convertNullToSpace(Object obj) {
		if(obj != null) {
			if(obj instanceof CoviList) {
				CoviList returnArray = new CoviList();
				CoviList clist = ((CoviList) obj);

				if (clist.size() > 0 && clist.get(0) != null) {
					Set<String> set = ((CoviMap)clist.get(0)).keySet();
					String[] keys = set.toArray(new String[set.size()]);

					for (int i = 0; i < clist.size(); i++) {
						CoviMap newObject = new CoviMap();
						CoviMap orgObject = (CoviMap)clist.get(i);

						for (int j=0 ; j < keys.length; j++) {
							String key = keys[j];
							Object value = orgObject.get(key);
							if (value == null) {
								newObject.put(key, "");
							} else {
								if(value instanceof CoviMap) {
									newObject.put(key, convertNullToSpace(value)); //key에 매핑되는 value가 CoviMap일 경우 다시 한 번 함수 태우기 
								} else if (value instanceof  java.sql.Date){
									java.text.SimpleDateFormat transFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
									String to = transFormat.format(value);
									newObject.put(key, to);
								} else {
									newObject.put(key, value);
								}
							}
						}
						returnArray.add(newObject);
					}
				}

				return returnArray;
			} else if (obj instanceof CoviMap) {
				CoviMap returnMap = new CoviMap();
				Set<String> set =((CoviMap)obj).keySet();
				String[] keys = set.toArray(new String[set.size()]);

				for (int j=0 ; j < keys.length; j++){
					String key = keys[j];
					Object value = ((CoviMap)obj).get(key);

					if (value == null) {
						returnMap.put(key, "");
					} else {
						if(value instanceof CoviMap) {
							returnMap.put(key, convertNullToSpace(value)); //key에 매핑되는 value가 CoviMap일 경우 다시 한 번 함수 태우기 
						} else if (value instanceof  java.sql.Date){
							java.text.SimpleDateFormat transFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
							String to = transFormat.format(value);
							returnMap.put(key, to);
						} else {
							returnMap.put(key, value);
						}
					}	
				}

				return returnMap;
			} else {
				CoviList returnArray = new CoviList();
				java.util.List clist = ((java.util.List) obj);

				if (clist.size() > 0 && clist.get(0) != null) {
					Set<String> set = ((CoviMap)clist.get(0)).keySet();
					String[] keys = set.toArray(new String[set.size()]);

					for (int i = 0; i < clist.size(); i++) {
						CoviMap newObject = new CoviMap();

						for (int j=0 ; j < keys.length; j++){
							String key = keys[j];
							Object value = ((CoviMap)clist.get(i)).get(key);

							if (value == null) {
								newObject.put(key, "");
							} else {
								if (value instanceof CoviMap) {
									newObject.put(key, convertNullToSpace(value)); //key에 매핑되는 value가 CoviMap일 경우 다시 한 번 함수 태우기 
								} else {
									if (value instanceof  java.sql.Date){
										java.text.SimpleDateFormat transFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
										String to = transFormat.format(value);
										newObject.put(key, to);
									} else {
										newObject.put(key, value);
									}
								}
							}
						}

						returnArray.add(newObject);
					}
				}		
				return returnArray;
			}
		} else {
			return obj;
		}
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
	
}
