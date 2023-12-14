package egovframework.covision.groupware.attend.user.util;

import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import egovframework.coviframework.util.DicHelper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFColor;

import egovframework.baseframework.util.json.JSONParser;

import com.nhncorp.lucy.security.xss.markup.Description;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;

import javax.servlet.http.HttpServletRequest;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ComUtils;

import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.hssf.util.HSSFColor;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

/**
 * @author sjhan0418
 * {@link Description}
 */
public class AttendUtils {
	private static final Logger LOGGER = LogManager.getLogger(AttendUtils.class);
	
	/**request값을 key와 value로 추가한다.*/
	public static CoviMap requestToCoviMap(HttpServletRequest request)
	{ 
		CoviMap coviMap = new CoviMap();
		
		Enumeration en = request.getParameterNames();
		
		while (en.hasMoreElements())
		{
			String key = (String)en.nextElement();
			String value = request.getParameter(key);
			
			if (key != null && value != null)
			{
				coviMap.put(key, value);
			}
		}
		
		String sortColumn		= "";
		String sortDirection	= "";	
		if(request.getParameter("sortBy") != null ){
			String sortBy = request.getParameter("sortBy");
			sortColumn		= sortBy.split(" ")[0];
			sortDirection	= sortBy.split(" ")[1];
		}
				
		coviMap.put("sortColumn",	ComUtils.RemoveSQLInjection(sortColumn, 100));
		coviMap.put("sortDirection",	ComUtils.RemoveSQLInjection(sortDirection, 100));
		
		return coviMap;
	}	
	
	public static CoviMap setPagingData(int pageNo, int pageSize, int rowCount){
//		int pageSize = 1;
		int pageOffset = (pageNo - 1) * pageSize;
		
		CoviMap page = new CoviMap();
		
		page.put("pageNo", pageNo);
		page.put("pageSize", pageSize);

		int pageCount = 1 + (rowCount / pageSize);
		
		if( (rowCount % pageSize) == 0){
			pageCount = pageCount - 1; 
		}
		int start =  (pageNo - 1) * pageSize + 1; 
		int end = start + pageSize -1;
		
		page.put("pageCount", pageCount);	//pageCount: 페이지 개수
		page.put("listCount", rowCount);	//rowCount: 전체 Row 갯수 
		page.put("pageSize", pageSize);		
		page.put("pageOffset", pageOffset);	//DB 스크립트 내부 처리용 param: LIMIT #{pageSize} OFFSET #{pageOffset} 
		page.put("rowStart", start);		//rowStart	: Oracle 페이징처리용
		page.put("rowEnd", end);			//rowEnd	: Oracle 페이징처리용
		return page;
	}

    public static int nvlInt(Object value, int mov)
    {
    	// MODIFY [2019-01-06] value type 이 Integer 인 경우 추가
    	if(value instanceof Integer) {
    		return (int) value;
    	}
    	
    	if(value instanceof Long) {
    		return ((Long) value).intValue();
    	}

		//if (value == null || "".equals((String)value))
		if (value == null || "".equals(String.valueOf(value)))
			return mov;
		//return Integer.parseInt((String)value);
		return Integer.parseInt(String.valueOf(value));
    }
    
    public static String nvlString(Object value, String mov)
    {
    	// MODIFY [2019-01-06] value type 이 Integer 인 경우 추가
        if (value == null || "".equals((String)value))
            return mov;
        
    	if(value instanceof String) {
    		return (String) value;
    	}
        return (String)value;
    }

    public static Object nvl(Object value, String mov)
    {
    	// MODIFY [2019-01-06] value type 이 Integer 인 경우 추가
        if (value == null )
            return mov;
        
        return value;
    }

    
    public static CoviMap pagingJson(int page,int pageSize,int rowSize,int totalCnt){
		
		CoviMap pageJson = new CoviMap();
		
		int pageoffset = (page - 1)*pageSize;
		int totalPageCnt = totalCnt%pageSize == 0 ? totalCnt/pageSize : totalCnt/pageSize +1;
		
		int startPage = ((page-1) / rowSize )*rowSize + 1; 
		int endPage = ((page-1)/rowSize + 1)*rowSize;
		endPage = endPage > totalPageCnt ? totalPageCnt : endPage;
		
		int beforePage = page > 1 ? page - 1 : 1;
		int nextPage = page < totalPageCnt ? page + 1 : totalPageCnt;
		
		int beginPage = 1;
		int lastPage = totalPageCnt;
		
		
		pageJson.put("page", page);
		pageJson.put("pageSize", pageSize);
		pageJson.put("rowSize", rowSize);
		pageJson.put("totalCnt", totalCnt);
		pageJson.put("pageoffset", pageoffset);
		pageJson.put("totalPageCnt", totalPageCnt);
		pageJson.put("startPage", startPage);
		pageJson.put("endPage", endPage);
		pageJson.put("beforePage", beforePage);
		pageJson.put("nextPage", nextPage);
		pageJson.put("beginPage", beginPage);
		pageJson.put("lastPage", lastPage);
		
		return pageJson;
		
	}

	/**
     * Map을 json으로 변환한다.
     *
     * @param map Map<String, Object>.
     * @return JSONObject.
     */
    public static CoviMap getJsonStringFromMap( Map<String, Object> map )
    {
        CoviMap jsonObject = new CoviMap();
        for( Map.Entry<String, Object> entry : map.entrySet() ) {
            String key = entry.getKey();
            Object value = entry.getValue();
            jsonObject.put(key, value);
        }
        
        return jsonObject;
    }

    /**
     * List<Map>을 jsonArray로 변환한다.
     *
     * @param list List<Map<String, Object>>.
     * @return JSONArray.
     */
    public static CoviList getJsonArrayFromList( List<Map<String, Object>> list )
    {
        CoviList jsonArray = new CoviList();
        for( Map<String, Object> map : list ) {
            jsonArray.add( getJsonStringFromMap( map ) );
        }
        
        return jsonArray;
    }


    public static String removeMaskAll(String sVal){
//    	String match = "[:/-]";
//    	String match = "[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]";
   	 	String match = "[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]";
    	String sRet = sVal.replaceAll(match,"");
    	return sRet;
    }
    
    public static String maskTime(String time){
		String str = removeMaskAll(time);

		if (str.length() < 4) return str;

		if (str.length() == 4)
		{
			return str.substring(0, 2) + ":" + str.substring(2, 4);
		}
		else
		{
//			if (str.length() < 6) time = AttendUtils.paddingStr(str, "R", "0", 6);

			return str.substring(0, 2) + ":" + str.substring(2, 4) + ":" + str.substring(4, 6);
		}
	}

    public static String maskDate(String date){
		String str = removeMaskAll(date);

		if (str.length() < 4) return str;

		if (str.length() == 4){
			return str.substring(0, 2) + "." + str.substring(2, 4);
		}
		else if (str.length() == 6){
			return str.substring(0, 4) + "." + str.substring(4, 6);
		}
		else if (str.length() == 8)	{
			return str.substring(0, 4) + "." + str.substring(4, 6) + "." + str.substring(6, 8);
		}
		return date;
	}
    
    public static String convertSecToStr(Object oVal, String sFormat){
		String sRet = "";
    	if (oVal == null || "null".equals(oVal)) return "";
		String sVal = "";
		if (oVal.getClass().equals(Integer.class)){
			sVal = String.valueOf(oVal);
		}else {
			sVal = oVal.toString();
		}
		int a = 0;
    	if (sVal.equals(""))    		return "";
    	
    	double iVal=Double.parseDouble(sVal);
		double iHour	 ;
		double iMinute  ; 
		double iSec     ;
		
//		double iVal = Integer.parseInt(sVal); 
		if (iVal == 0) {
			iHour = 0;
			iMinute = 0;
		}
		else{
			iHour	 = Math.floor(iVal / 60);
			iMinute  = Math.floor((iVal- 60*iHour));
			iSec     = iVal - (60*iHour) - (iMinute);
		}
		if ("H".equals(sFormat)){
			boolean appendedH = false;
			if (iHour > 0)	{
				sRet = String.valueOf((int)iHour)+"h";
				appendedH = true;
			}
			if (iMinute>0 ) {
				if(appendedH){sRet+=" ";}
				sRet+=String.valueOf((int)iMinute)+"m";
			}
		}else if ("h".equals(sFormat)){
			boolean appendedH = false;
			if (iHour > 0)	{
				sRet = String.valueOf((int)iHour)+"h";
				appendedH = true;
			}
			if (iMinute>0 ) {
				if(appendedH){sRet+=" ";}
				sRet+=String.valueOf((int)iMinute)+"m";
			}
			if (iHour == 0 && iMinute == 0)	{
				sRet+= "0";
			}
		}else if ("hh".equals(sFormat)){
			boolean appendedH = false;
			if (iHour > 0)	{
				sRet = String.valueOf((int)iHour)+"h";
				appendedH = true;
			}
			if (iMinute>0 ) {
				if(appendedH){sRet+=" ";}
				sRet+=String.valueOf((int)iMinute)+"m";
			}
			if (iHour == 0 && iMinute == 0)	{
				sRet+= "0h";
			}
		}
		else{
			sRet =  (iHour<10?"0":"")  +    String.valueOf((int)iHour) + ":";
			sRet += (iMinute<10?"0":"") +   String.valueOf((int)iMinute) ;
		
		}
		return sRet;
    }
    
    public static String getRequestName(String reqMethod){
    	return DicHelper.getDic(reqMethod.equals("None")?"lbl_Registor":"lbl_att_approval");
    }
    
	// 임시파일 생성
	public static File prepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        
	        return tmp;
	    } catch (NullPointerException ex) {
	    	if (tmp != null) {
	        	if(!tmp.delete()) {
	        		LOGGER.debug("Fail to delete file : " + tmp.getAbsolutePath());
	        	}
	        }
	        
	        throw ex;
	    } catch (IOException ioE) {
	        if (tmp != null) {
	        	if(!tmp.delete()) {
	        		LOGGER.debug("Fail to delete file : " + tmp.getAbsolutePath());
	        	}
	        }
	        
	        throw ioE;
	    } catch (Exception e) {
	    	if (tmp != null) {
	        	if(!tmp.delete()) {
	        		LOGGER.debug("Fail to delete file : " + tmp.getAbsolutePath());
	        	}
	        }
	        
	        throw e;
	    }
	}

	
 // 엑셀 데이터 추출
	 public static  ArrayList<ArrayList<Object>> extractionExcelData(CoviMap params, int headerCnt) throws Exception {
 		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
 		File file = prepareAttachment(mFile);	// 파일 생성
 		ArrayList<ArrayList<Object>> returnList = new ArrayList<>();
 		ArrayList<Object> tempList = null;
 		
 		Workbook wb = null;
 		try {
 			wb = WorkbookFactory.create(file);
 			Sheet sheet = wb.getSheetAt(0);
 			
 			Iterator<Row> rowIterator = sheet.iterator();
 			while (rowIterator.hasNext()) {
 				Row row = rowIterator.next();
 				
 				if (row.getRowNum() > (headerCnt - 1)) {	// header 제외
 					tempList = new ArrayList<>();
 					Iterator<Cell> cellIterator = row.cellIterator();
 					while (cellIterator.hasNext()) {
 						Cell cell = cellIterator.next();
 						
 						switch (cell.getCellType()) {
 						case Cell.CELL_TYPE_BOOLEAN :
 							tempList.add(cell.getBooleanCellValue());
 							break;
 						case Cell.CELL_TYPE_NUMERIC : 
 							tempList.add(cell.getNumericCellValue());
 							break;
 						case Cell.CELL_TYPE_STRING : 
 							tempList.add(cell.getStringCellValue());
 							break;
 						case Cell.CELL_TYPE_FORMULA : 
 							tempList.add(cell.getCellFormula());
 							break;
 						default :
 							break;
 						}
 					}
 					
 					returnList.add(tempList);
 				}
 			}
 		} catch (IOException e) {
 			LOGGER.debug(e);
 		} catch (NullPointerException e) {
 			LOGGER.debug(e);
 		} catch (Exception e) {
 			LOGGER.debug(e);
 		} finally {
 			if (file != null) {
 				if(!file.delete()) {
 					LOGGER.debug("Fail to delete file : " + file.getAbsolutePath());
 				}
 			}
			if (wb != null) {
				try {
					wb.close();
				} catch (NullPointerException ex) {
					LOGGER.error(ex.getLocalizedMessage(), ex);
				} catch (IOException ioe) {
					LOGGER.error(ioe.getLocalizedMessage(), ioe);
				} catch (Exception ex) {
					LOGGER.error(ex.getLocalizedMessage(), ex);
				}
			}
 		}
 		
 		return returnList;
 	}
	 
	 /*주소로 지도 검색*/
	 public static String locationCoordAPI(String addr, String admCd, String rnMgtSn, String udrtYn, String buldMnnm, String buldSlno) throws Exception{
		 return locationCoordAPI(addr, admCd, rnMgtSn, udrtYn, buldMnnm, buldSlno,"PARCEL");
	 }
	 public static String locationCoordAPI(String addr, String admCd, String rnMgtSn, String udrtYn, String buldMnnm, String buldSlno, String addrType) throws Exception{
		HttpURLConnection conn = null;
		StringBuffer sb = new StringBuffer();
		String responseMsg = "";

		StringUtil func = new StringUtil();
		int statusCode = 404;
		String VMapApiKey = RedisDataUtil.getBaseConfig("VMapApiKey");
		
		BufferedReader br = null;
		try {
			//지번 검색
			String apiUrl = "http://api.vworld.kr/req/address?service=address&request=GetCoord&version=2.0&crs=EPSG:4326"
						+"&refine=true&simple=false&format=json"
						+"&type="+addrType+"&address="+URLEncoder.encode(addr, "UTF-8")
						+"&key="+VMapApiKey;
				
			URL url = new URL(apiUrl);
			
			conn = (HttpURLConnection) url.openConnection();
			
			conn.setDoOutput(true);
			conn.setRequestMethod("POST");
			
			//get result
			br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
			
			String tempStr = null;
			while (true) {
				tempStr = br.readLine();
				if (tempStr == null)
					break;
				sb.append(tempStr); // 응답결과 JSON 저장
			}
			
			
			statusCode = conn.getResponseCode();
			
		} catch (IOException e) {
			statusCode = 500;
			responseMsg = e.toString();
		} catch (NullPointerException e) {
			statusCode = 500;
			responseMsg = e.toString();
		} catch (Exception e) {
			statusCode = 500;
			responseMsg = e.toString();
		}finally{
			if (br != null) { try { br.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (conn != null) {
				conn.disconnect();
				conn = null;
			}
		}
		
		return sb.toString();
		
	}
	
	 //좌표로 주소 검색
	 public static String locationAddressAPI(String x, String y) throws Exception{
		HttpURLConnection conn = null;
		StringBuffer sb = new StringBuffer();
		String responseMsg = "";
		String apiUrl = "";
		CoviMap params = new CoviMap();
		StringUtil func = new StringUtil();
		String RequestDate = func.getCurrentTimeStr();
		int statusCode = 404;
		String VMapApiKey = RedisDataUtil.getBaseConfig("VMapApiKey");
		
		BufferedReader br = null;
		try {
			apiUrl = "http://api.vworld.kr/req/address?service=address&request=GetAddress&version=2.0&crs=EPSG:4326"
					+"&refine=true&simple=false&format=json"
					+"&type=PARCEL&point="+x+","+y
					+"&key="+VMapApiKey;
				
			URL url = new URL(apiUrl);
			
			conn = (HttpURLConnection) url.openConnection();
			
			conn.setDoOutput(true);
			conn.setRequestMethod("POST");
			
			//get result
			br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
			
			String tempStr = null;
			while (true) {
				tempStr = br.readLine();
				if (tempStr == null)
					break;
				sb.append(tempStr); // 응답결과 JSON 저장
			}
			
			statusCode = conn.getResponseCode();
			
		} catch (IOException e) {
			statusCode = 500;
			responseMsg = e.toString();
		} catch (NullPointerException e) {
			statusCode = 500;
			responseMsg = e.toString();
		} catch (Exception e) {
			statusCode = 500;
			responseMsg = e.toString();
		}finally{
			if (br != null) { try { br.close(); } catch (IOException ioe) { LOGGER.error(ioe.getLocalizedMessage(), ioe); } }
			if (conn != null) {
				conn.disconnect();
				conn = null;
			}
		}
		
		return sb.toString();
		
	}
	 
	 //주소정보 조회
	 public static String getCommuteAddr(String x,String y){
		String returnStr = null;

		try{
			if( x != null && y != null ){
				String locationStr = locationAddressAPI(x, y);
				JSONParser parser = new JSONParser();
				CoviMap locationObj = (CoviMap) parser.parse(locationStr);
				CoviMap res = (CoviMap) locationObj.get("response");
				
				//System.out.println(res);
				if("OK".equals(res.get("status"))){
					CoviList result = (CoviList) res.get("result");
					CoviMap resultObj = (CoviMap) result.get(0);
					returnStr = String.valueOf(resultObj.get("text"));
				}
			}

		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return returnStr;
	}
	 
	public static void  writeExcelHeaderData(Row row, int colIdx, ArrayList<?>	 colInfo, Font ttlFont, CellStyle ttlStyle)
	{
		ttlFont.setFontHeightInPoints(Integer.valueOf(10).shortValue()); //폰트 크기
		ttlFont.setColor(HSSFColor.GREY_80_PERCENT.index);

		ttlStyle.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
		ttlStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
		ttlStyle.setBorderTop(CellStyle.BORDER_THIN);
		ttlStyle.setBorderRight(CellStyle.BORDER_THIN);
		ttlStyle.setBorderBottom(CellStyle.BORDER_THIN);
		ttlStyle.setBorderLeft(CellStyle.BORDER_THIN);
		ttlStyle.setAlignment(CellStyle.ALIGN_CENTER);
		ttlStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
		ttlStyle.setFont(ttlFont); //폰트 스타일 적용
		ttlStyle.setWrapText(true);

		try{
			for (int i = 0; i < colInfo.size(); i++) {
				Cell cell = row.createCell(i+colIdx);
				cell.setCellValue((String)((HashMap)colInfo.get(i)).get("colName"));
				cell.setCellStyle(ttlStyle);
			}	
		} catch (NullPointerException e){
			LOGGER.debug(e);
		} catch (Exception e){
			LOGGER.debug(e);
		}
	}
	
	public static void writeExcelRowData(Row row, int colIdx,  ArrayList<?> colInfo, HashMap colVal, Font textFont,CellStyle textStyle){
		textFont.setFontHeightInPoints(Integer.valueOf(10).shortValue()); //폰트 크기
		textFont.setColor(HSSFColor.GREY_80_PERCENT.index);
		textStyle.setFont(textFont); //폰트 스타일 적용
		try{
			for (int i = 0; i < colInfo.size(); i++) {
				Cell cell = row.createCell(i+colIdx);
				HashMap cols =(HashMap)colInfo.get(i);
				
				String key = (String)cols.get("colKey");
				String val =colVal.get(key)==null?"":colVal.get(key).toString();
				if (cols.get("colFormat") != null){
					switch ((String)cols.get("colFormat")){
						case "H":
							val = AttendUtils.convertSecToStr(val,"H");
							break;
						default 	:
							break;
					}
				}
				cell.setCellValue(val);
				cell.setCellStyle(textStyle);
			}	
		} catch (NullPointerException e){
			LOGGER.debug(e);
		} catch (Exception e){
			LOGGER.debug(e);
		}
	}

	
	public static void writeExcelCellData(Row row, int colIdx, String val, Font textFont,CellStyle textStyle){
		if(val==null){
			val = "";
		}
		textFont.setFontHeightInPoints(Integer.valueOf(10).shortValue()); //폰트 크기
		textFont.setColor(HSSFColor.GREY_80_PERCENT.index);
		textStyle.setFont(textFont); //폰트 스타일 적용
		Cell cell = row.createCell(colIdx);
		cell.setCellValue(val);
		cell.setCellStyle(textStyle);
	}

	public static void writeExcelCellSumData(Row row, int colIdx, String val, Font textFont, XSSFCellStyle cs1){
		if(val==null){
			val = "";
		}
		textFont.setFontHeightInPoints(Integer.valueOf(10).shortValue()); //폰트 크기
		textFont.setColor(HSSFColor.GREY_80_PERCENT.index);
		cs1.setFillForegroundColor(new XSSFColor(new java.awt.Color(230,230,230)));
		cs1.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cs1.setBorderBottom(BorderStyle.THIN);
		cs1.setBorderTop(BorderStyle.THIN);
		cs1.setBorderLeft(BorderStyle.THIN);
		cs1.setBorderRight(BorderStyle.THIN);
		cs1.setAlignment(HorizontalAlignment.CENTER);
		cs1.setVerticalAlignment(VerticalAlignment.CENTER);
		cs1.setFont(textFont);
		cs1.setWrapText(true);
		Cell cell = row.createCell(colIdx);
		cell.setCellValue(val);
		cell.setCellStyle(cs1);
	}


	public static void writeExcelCellValData(Row row, int colIdx, String val, Font textFont, XSSFCellStyle cs1){
		 if(val==null){
			 val = "";
		 }
		textFont.setFontHeightInPoints(Integer.valueOf(10).shortValue()); //폰트 크기
		textFont.setColor(HSSFColor.GREY_80_PERCENT.index);
		cs1.setFillForegroundColor(new XSSFColor(new java.awt.Color(254,254,254)));
		cs1.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cs1.setBorderBottom(BorderStyle.THIN);
		cs1.setBorderTop(BorderStyle.THIN);
		cs1.setBorderLeft(BorderStyle.THIN);
		cs1.setBorderRight(BorderStyle.THIN);
		cs1.setAlignment(HorizontalAlignment.CENTER);
		cs1.setVerticalAlignment(VerticalAlignment.CENTER);
		cs1.setFont(textFont);
		cs1.setWrapText(true);
		Cell cell = row.createCell(colIdx);
		cell.setCellValue(val);
		cell.setCellStyle(cs1);
	}

	public static void writeExcelCellDynamicHeaderData(Row row, int colIdx, String val, Font textFont,CellStyle textStyle){
		if(val==null){
			val = "";
		}
		textStyle.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
		textStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
		textStyle.setBorderTop(CellStyle.BORDER_THIN);
		textStyle.setBorderRight(CellStyle.BORDER_THIN);
		textStyle.setBorderBottom(CellStyle.BORDER_THIN);
		textStyle.setBorderLeft(CellStyle.BORDER_THIN);
		textStyle.setAlignment(CellStyle.ALIGN_CENTER);
		textStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
		textStyle.setFont(textFont); //폰트 스타일 적용
		textStyle.setWrapText(true);

		Cell cell = row.createCell(colIdx);
		cell.setCellValue(val);
		cell.setCellStyle(textStyle);
	}

	/**
	  * @Method Name : chkPointDistance
	  * @작성일 : 2020. 4. 16.
	  * @작성자 : sjhan0418
	  * @변경이력 : 
	  * @Method 설명 : 좌표간 제한거리 확인 ( meter 단위 환산!! ) 
	  * @param lon1 지점 1 경도
	  * @param lat1 지점 1 위도 
	  * @param lon2 지점 2 경도
	  * @param lat2 지점 2 위도
	  * @param distance 비교거리
	  * @return
	  */
	public static boolean chkPointDistance(double lon1 ,double lat1 ,double lon2 , double lat2, int distance ){
       double dist = getPointDistance(lon1, lat1, lon2, lat2);
       
       if(dist <= distance){
       	return true;
       }else{
       	return false;
       }
	}
	
	public static double getPointDistance(double lon1 ,double lat1 ,double lon2 , double lat2){
		
		double unit =  1609.344;	//meter단위 환산
/*
		System.out.println("lon1 :"+lon1);
		System.out.println("lat1 :"+lat1);
		System.out.println("lon2 :"+lon2);
		System.out.println("lat2 :"+lat2);
*/		
		double theta = lon1 - lon2;
		double dist = 
				Math.sin(Math.toRadians(lat1)) * 
				Math.sin(Math.toRadians(lat2)) + 
				Math.cos(Math.toRadians(lat1)) * 
				Math.cos(Math.toRadians(lat2)) * 
				Math.cos(Math.toRadians(theta));
		dist = Math.acos(dist);
		dist = Math.toDegrees(dist);
		dist = dist * 60 * 1.1515;
       
       dist = dist * unit;
       return dist;
	}


	public static int getCurrentWeekOfYear(int year, int month, int day)  {
		String attBaseWeek = RedisDataUtil.getBaseConfig("AttBaseWeek");
		Calendar calendar = Calendar.getInstance(Locale.KOREA);
		switch (attBaseWeek){
			case "1":
				calendar.setFirstDayOfWeek(Calendar.SUNDAY);
				break;
			case "2":
				calendar.setFirstDayOfWeek(Calendar.MONDAY);
				break;
			case "3":
				calendar.setFirstDayOfWeek(Calendar.TUESDAY);
				break;
			case "4":
				calendar.setFirstDayOfWeek(Calendar.WEDNESDAY);
				break;
			case "5":
				calendar.setFirstDayOfWeek(Calendar.THURSDAY);
				break;
			case "6":
				calendar.setFirstDayOfWeek(Calendar.FRIDAY);
				break;
			case "7":
				calendar.setFirstDayOfWeek(Calendar.SATURDAY);
				break;
			default:
				calendar.setFirstDayOfWeek(Calendar.MONDAY);
				break;
		}

		calendar.set(year, month-1, day);
		return   calendar.get(Calendar.WEEK_OF_YEAR);
	}

	public static int getMaxWeekOfYear(int year)  {
		Calendar calendar = Calendar.getInstance(Locale.KOREA);
		calendar.set(year, 0, 1);
		return   calendar.getActualMaximum( Calendar.WEEK_OF_YEAR );
	}

	public static String vacNameConvertor(String ampm, String vacCodeNames, String type, int idx){
		String rtn = "";
		if(ampm!=null&&ampm.indexOf("|")>-1&&vacCodeNames!=null&&vacCodeNames.indexOf("|")>-1){
			String[] arrAmPm = ampm.split("\\|");
			String[] arrVacCodeNames = vacCodeNames.split("\\|");
			int amCnt = 0;
			int pmCnt = 0;
			for(int i=0;i<arrVacCodeNames.length;i++){
				if(arrAmPm[i].equals(type)){
					if(arrAmPm[i].equals("AM") && amCnt==idx) {
						rtn = arrVacCodeNames[i];
						break;
					}
					if(arrAmPm[i].equals("PM")&& pmCnt==idx) {
						rtn = arrVacCodeNames[i];
						break;
					}
				}
				if(arrAmPm[i].equals("AM")){amCnt++;}
				if(arrAmPm[i].equals("PM")){pmCnt++;}
			}
		}else{
			rtn = vacCodeNames;
		}
		return rtn;
	}
	
	/**
	 * StartDate, EndDate 사이 날짜 배열 구하기
	 * 
	 * @param startDate
	 * @param endDate
	 * @return
	 */
	public static List<String> getDatesBetweenTwoDates(String pStartDate, String pEndDate) {
		List<String> returnDates = new ArrayList<String>();
		
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

		LocalDate startDate = LocalDate.parse(pStartDate, formatter);
		LocalDate endDate = LocalDate.parse(pEndDate, formatter);
		
		long numOfDaysBetween = ChronoUnit.DAYS.between(startDate, endDate) + 1;
		
		List<LocalDate> dates = IntStream.iterate(0, i -> i + 1).limit(numOfDaysBetween).mapToObj(i -> startDate.plusDays(i)).collect(Collectors.toList());
		
		for(int i = 0; i < dates.size(); i++) {
			returnDates.add(dates.get(i).format(formatter));
		}
		
		return returnDates;
	}
}
