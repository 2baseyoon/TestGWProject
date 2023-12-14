package egovframework.coviframework.util;

import java.text.SimpleDateFormat;
import java.net.URLDecoder;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import net.sf.json.JSONNull;


import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFFormulaEvaluator;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;

//import org.egovframe.rte.rex.gds.service.GoodsVO;

/**
 * 엑셀파일을 생성하는 클래스를 정의한다.
 * @author 실행환경 개발팀 신혜연
 * @since 2011.07.11
 * @version 1.0
 * @see 
 * <pre>
 *  == 개정이력(Modification Information) ==
 *   
 *   수정일      수정자           수정내용
 *  -------    --------    ---------------------------
 *   2011.07.11  신혜연          최초 생성
 *   2016			 박경연			필요에 맞게 수정
 * </pre>
 */
public class ExcelDownload extends CoviAbstractExcelView {

	/**
	 * 엑셀파일을 설정하고 생성한다.
	 * @param model
	 * @param wb
	 * @param request
	 * @param response
	 * @throws Exception
	 */
	@Override
	protected void buildExcelDocument(Map<String, Object> model,
			HSSFWorkbook wb, HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		
		HSSFCell cell = null;
		String title = (String) model.get("title");
		String[] headerName = (String[]) model.get("headerName");
		ArrayList<String>  headerKey = new ArrayList<String>(); 
		String[] headerTypes = new String[headerName.length];
		if ( model.get("headerType") != null){
			
			String headerType = (String) model.get("headerType");
			headerTypes = headerType.split("\\|");
		}
		
		if (model.get("headerKey") != null){
			String[] headerKeys = (String[]) model.get("headerKey");
			for(String name : headerKeys){
				headerKey.add(name);
			}
		}
		
		HSSFSheet sheet = null;
		
		if(!model.containsKey("sheetName")) {
			String sheetName = title;
			String browser = FileUtil.getBrowser(request);
			if (browser.equals("MSIE") || browser.equals("Chrome")) {
				sheetName = URLDecoder.decode(title, "UTF-8");
			} else {
				sheetName = new String(title.getBytes("8859_1"), "UTF-8");
			}
			sheet = wb.createSheet(sheetName);
		} else {
			sheet = wb.createSheet((String)model.get("sheetName"));
		}
		
		//HSSFSheet sheet = wb.createSheet(sheetName);
		sheet.setDefaultColumnWidth((short) 20);
        //sheet.setColumnWidth((short) 1, (short) (256 * 20));
		
		CellStyle style = wb.createCellStyle();
		Font font = wb.createFont();
		style.setFillForegroundColor(HSSFColor.GREY_40_PERCENT.index);	// 헤더 배경 색깔 설정
		style.setFillPattern(CellStyle.SOLID_FOREGROUND);
		font.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);			// 헤더 글씨 설정
        font.setColor(HSSFColor.WHITE.index);
        style.setFont(font);
        style.setBorderRight(HSSFCellStyle.BORDER_THIN);              //테두리 설정   
        style.setBorderLeft(HSSFCellStyle.BORDER_THIN);   
        style.setBorderTop(HSSFCellStyle.BORDER_THIN);   
        style.setBorderBottom(HSSFCellStyle.BORDER_THIN);
		
		// put text in first cell
		//cell = getCell(sheet, 0, 0);
		//setText(cell, "Error Log View");
 
		// set header information
		int i = 0, j = 0;
		
		//HSSFRow header = sheet.createRow(0);
		HSSFCell header = null;
		
		for(String name : headerName){
			/*header.createCell(i).setCellValue(name);
			header.getCell(i).setCellStyle(style);*/
			
			header= getCell(sheet, 0, i);
			header.setCellStyle(style);
			
			setText(header , name);
			i++;
		}
		
		/*setText(getCell(sheet, 1, 0), "유형");
		setText(getCell(sheet, 1, 1), "발생일시");
		setText(getCell(sheet, 1, 2), "Page");
		setText(getCell(sheet, 1, 3), "Message");
		setText(getCell(sheet, 1, 4), "사용자");
		setText(getCell(sheet, 1, 5), "성명");
		setText(getCell(sheet, 1, 6), "부서명");
		setText(getCell(sheet, 1, 7), "IP 주소");
		setText(getCell(sheet, 1, 8), "서버명");*/

		CoviList jArray = new CoviList();
		jArray = (CoviList) model.get("list");
		
		//i = jArray.size() - 1;
		i=0;
		DateFormat  df = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
		String useTimeZone = RedisDataUtil.getBaseConfig("useTimeZone");//타임존 사용영부
		String urTimeZone =SessionHelper.getSession("UR_TimeZone");		//사용자 타임존 
		for(Object obj : jArray){
			CoviMap jObj = new CoviMap();
			jObj = (CoviMap) obj;
			Iterator<?> keys = jObj.keys();
			if (headerKey.size() > 0) keys = headerKey.iterator(); 	//headerkey가 들어오면 사용
			
			j = 0;

			while(keys.hasNext()){
				String key = (String)keys.next();
				cell = getCell(sheet, 1 + i, j);
				
				//setText(cell, (String) jObj.get(key));
				//내용 생성 부분 다국어 처리
				String val = "";
				if (jObj.get(key) != null) val =jObj.get(key).toString();

				if (useTimeZone.equalsIgnoreCase("Y") && headerTypes.length> j && headerTypes[j] != null && headerTypes[j].equals("DateTime")){
					val = ComUtils.TransLocalTime(val, ComUtils.UR_DateFullFormat, urTimeZone);
				}
				
				if (headerTypes.length> j && headerTypes[j] != null && headerTypes[j].equals("Numeric")){
					setNumeric(cell, val);
				}
				else{
					setText(cell, val);
				}	
				
				/*if(i == 0)
					wb.getSheetAt(0).autoSizeColumn(j);*/
				
				j++;
			}
			
			/*cell = getCell(sheet, 1 + i, 0);
			setText(cell, (String) jObj.get("ErrorType"));
			
			cell = getCell(sheet, 1 + i, 1);
			setText(cell, (String) jObj.get("EventDate"));
			
			cell = getCell(sheet, 1 + i, 2);
			setText(cell, (String) jObj.get("PageURL"));
			
			cell = getCell(sheet, 1 + i, 3);
			setText(cell, (String) jObj.get("ErrorMessage"));
			
			cell = getCell(sheet, 1 + i, 4);
			setText(cell, (String) jObj.get("LogID"));
			
			cell = getCell(sheet, 1 + i, 5);
			setText(cell, (String) jObj.get("UR_Name"));
			
			cell = getCell(sheet, 1 + i, 6);
			setText(cell, (String) jObj.get("DEPT_Name"));
			
			cell = getCell(sheet, 1 + i, 7);
			setText(cell, (String) jObj.get("IPAddress"));
			
			cell = getCell(sheet, 1 + i, 8);
			setText(cell, (String) jObj.get("MachineName"));*/
			
			//i--;
			i++;
		}

		Date today = new Date();
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
		
		response.setHeader("Content-Disposition", "attachment; filename=" + dateFormat.format(today)+"_"+title + "_excel.xls");
		//response.setHeader("Content-Disposition", "inline; filename=" + dateFormat.format(today)+"_"+title + "_excel.xlsx");
	}
	
}
