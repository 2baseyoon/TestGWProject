package egovframework.coviframework.util;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.HashMap;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;

import com.nhncorp.lucy.security.xss.markup.Description;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;

import java.util.List;
import java.util.Map;

import org.apache.poi.hssf.util.HSSFColor;

import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;

import java.util.StringTokenizer ;

/**
 * @author sjhan0418
 * {@link Description}
 */
public class ExcelUtil {
	private static final Logger LOGGER = LogManager.getLogger(ExcelUtil.class);
	
	public static SXSSFWorkbook makeExcelFile( String excelTitle, List<HashMap>  lstColInfo, List<?> lstList){
		
		SXSSFWorkbook workbook;		// 엑셀 Workbook
		workbook = new SXSSFWorkbook();
		
		Sheet sheet = workbook.createSheet("sheet1");

  		// Font
		Font ttlFont = workbook.createFont();
		ttlFont.setFontHeightInPoints((short)20); //폰트 크기
		ttlFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD); //폰트 굵게

  		
		int x		= 0;
		int y		= 2;
		
		//헤더 만들기
		Row row = sheet.createRow(1); // create a row
		CellStyle ttlStyle= workbook.createCellStyle();
		ttlStyle.setFillForegroundColor(HSSFColor.LEMON_CHIFFON.index);
		ttlStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
		ttlStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
		ttlStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);
		ttlStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
		ttlStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
		ttlStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
		ttlStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		ttlStyle.setFont(ttlFont); //폰트 스타일 적용
		
		CellStyle lstCStyle= workbook.createCellStyle();
		lstCStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		CellStyle lstRStyle= workbook.createCellStyle();
		lstRStyle.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
		CellStyle lstLStyle= workbook.createCellStyle();
		lstLStyle.setAlignment(HSSFCellStyle.ALIGN_LEFT);
		
		
		Cell cell = row.createCell(1,HSSFCell.CELL_TYPE_STRING); // create a numeric cell
		cell.setCellValue(excelTitle);
		cell.setCellStyle(ttlStyle);
		for (int i = 0; i < lstColInfo.size()-1; i++) {
			cell = row.createCell(i+2,HSSFCell.CELL_TYPE_STRING); // create a numeric cell
			cell.setCellStyle(ttlStyle);
		}
		row.setHeight((short)(20*50));
		sheet.addMergedRegion(new CellRangeAddress(1, 1, 1, lstColInfo.size()));
		
		makeHeaderData(workbook, sheet, y++, lstColInfo);
		Object data = "";

		for (int j=0; j < lstList.size(); j++)
		{
			row = sheet.createRow(y++); // create a row
			Map<String, Object> dataMap =  new HashMap<String, Object>();
			
			
			/*if (lstList.get(j) instanceof egovframework.baseframework.util.json.JSONObject) { 
				egovframework.baseframework.util.json.JSONObject jsonObj = (egovframework.baseframework.util.json.JSONObject)lstList.get(j);
				try {
					dataMap = new ObjectMapper().readValue(jsonObj.toString(), Map.class);
				} catch (IOException e) {
			        LOGGER.error(e.getLocalizedMessage(), e);
			    }
			}	
			else{*/
				dataMap = (HashMap<String, Object>)lstList.get(j);
			//}

			DateFormat  df = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
			String useTimeZone = RedisDataUtil.getBaseConfig("useTimeZone");//타임존 사용영부
			String urTimeZone =SessionHelper.getSession("UR_TimeZone");		//사용자 타임존 
			for (int i = 0; i < lstColInfo.size(); i++) {
				HashMap hColInfo = (HashMap)lstColInfo.get(i);
	
				String format = (String)hColInfo.get("colFormat");
				String type = (String)hColInfo.get("colType");
				String column = (String)hColInfo.get("colKey");
				String align = (String)hColInfo.get("colAlign");
				HashMap colCode = (HashMap)hColInfo.get("colCode");
				int cellIdx = i+1;
				
				if (dataMap.get(column) != null){
					if (type!= null && type.toUpperCase().equals("I"))		
					{	
						cell = row.createCell(cellIdx,HSSFCell.CELL_TYPE_NUMERIC); // create a numeric cell
						if (dataMap.get(column) instanceof Integer) { 
							cell.setCellValue((int)dataMap.get(column));
						}else{
							cell.setCellValue(Integer.parseInt(dataMap.get(column).toString()));
						}
					}	
					else if (type!= null &&  type.toUpperCase().equals("F"))		
					{	
						cell = row.createCell(cellIdx,HSSFCell.CELL_TYPE_NUMERIC); // create a numeric cell
						if (dataMap.get(column) instanceof Integer) { 
							cell.setCellValue((int)dataMap.get(column));
						}else{
							cell.setCellValue(Float.parseFloat(dataMap.get(column).toString()));
						}
					}	
					else if (type!= null &&  type.toUpperCase().equals("D"))		
					{	
						cell = row.createCell(cellIdx,HSSFCell.CELL_TYPE_NUMERIC); // create a numeric cell
						cell.setCellValue(Double.parseDouble((String)dataMap.get(column)));
					}	
					else 
					{
						cell = row.createCell(cellIdx,HSSFCell.CELL_TYPE_STRING); // create a numeric cell
						if (dataMap.get(column) != null )			data = dataMap.get(column);
						else data = "";
						String val = data.toString();
						
						if (format != null){
							switch (format){
								case "DATE":
									val = ComUtils.ConvertDateFormat(val, "-");
									break;
								case "CODE":
									if (colCode.get(val) != null) {
										val = (String)colCode.get(val);
									}
									break;
								case "DATETIME"	:
									if (useTimeZone.equalsIgnoreCase("Y")){
										val = ComUtils.TransLocalTime(val, ComUtils.UR_DateFullFormat, urTimeZone);
									}
									break;
								case "MULTICODE":
									String[] multiVal = StringUtils.split(val,";");
									val = "";
									StringBuffer valBuf = new StringBuffer();
									for (int k=0; k<multiVal.length; k++){
										//val += (k>0?";":"");
										valBuf.append(k>0?";":"");
										if (colCode.get(multiVal[k]) != null) {
											//val +=(String)colCode.get(multiVal[k]);
											valBuf.append((String)colCode.get(multiVal[k]));
										}else{
											//val +=multiVal[k];
											valBuf.append(multiVal[k]);
										}
									}
									val = valBuf.toString();
									break;	
								case "USERCOUNT":
									StringTokenizer strUs = new StringTokenizer(val,"|");
									if (strUs.countTokens()>0) {
										StringTokenizer strDesc = new StringTokenizer(strUs.nextToken(),"^");
										if (strDesc.countTokens()>0) {
											strDesc.nextToken();
											val = strDesc.nextToken()+ (strUs.hasMoreTokens()?" 외"+(strUs.countTokens()):"");
										}
									}
									break;
								default : break;
							}
						}
						if(val != null && !val.isEmpty() && val.length() > 32767) val = val.substring(0,32767); // 엑셀 셀 최대허용 길이(32767)
						cell.setCellValue(val);
					}
				}	
				else{
					cell = row.createCell(cellIdx,HSSFCell.CELL_TYPE_STRING); // create a numeric cell
				}
				if (align != null ){
					switch (align){
						case "CENTER":
							cell.setCellStyle(lstCStyle);
							break;
						case "RIGHT":
							cell.setCellStyle(lstRStyle);
							break;
						default:
							cell.setCellStyle(lstLStyle);
							break;
					}
				}	else{
					cell.setCellStyle(lstLStyle);
				}
			}
			row.setHeight((short)(7*50));
		}

		for (int i=0; i<lstColInfo.size(); i++)
		{
			HashMap hColInfo = (HashMap)lstColInfo.get(i);
			String width = (String)hColInfo.get("colWith");
			int cellIdx = i+1;
			if (width != null){
				sheet.setColumnWidth(cellIdx, (short)(Integer.parseInt(width)*50) ); 
			}	
		}

		return workbook;
	}

	public static void  makeHeaderData(SXSSFWorkbook workbook, Sheet sheet, int r1, List<HashMap>	 lstColInfo)
	{
		// Header Style
		Font ttlFont= workbook.createFont(); //폰트 객체 생성
		ttlFont.setFontHeightInPoints((short)11); //폰트 크기
		ttlFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD); //폰트 굵게

		CellStyle ttlStyle= workbook.createCellStyle();
		ttlStyle.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
		ttlStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
		ttlStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
		ttlStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);
		ttlStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
		ttlStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
		ttlStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		ttlStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
		ttlStyle.setFont(ttlFont); //폰트 스타일 적용
		ttlStyle.setWrapText(true);
				
		Row row = sheet.createRow(r1)	;
		for (int i = 0; i < lstColInfo.size(); i++) {
			
			Cell cell = row.createCell(i+1);
			HashMap hColInfo = (HashMap)lstColInfo.get(i);
			
			cell.setCellValue((String)hColInfo.get("colName"));
			cell.setCellStyle(ttlStyle);
		}
	}
	

}
