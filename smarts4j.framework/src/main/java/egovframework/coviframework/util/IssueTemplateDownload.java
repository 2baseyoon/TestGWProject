package egovframework.coviframework.util;

import java.awt.Color;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
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
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.Comment;
import org.apache.poi.ss.usermodel.DataValidation;
import org.apache.poi.ss.usermodel.DataValidationConstraint;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.RichTextString;
import org.apache.poi.ss.util.CellRangeAddressList;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFColor;
import org.apache.poi.xssf.usermodel.XSSFDataValidation;
import org.apache.poi.xssf.usermodel.XSSFDataValidationConstraint;
import org.apache.poi.xssf.usermodel.XSSFDataValidationHelper;
import org.apache.poi.xssf.usermodel.XSSFFont;
import org.apache.poi.xssf.usermodel.XSSFRichTextString;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.RedisDataUtil;

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
public class IssueTemplateDownload extends IssueAbstractExcelView {

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
			XSSFWorkbook wb, HttpServletRequest request,
			HttpServletResponse response) throws Exception {

		XSSFCell cell = null;
		String title = (String) model.get("title");
		String[] headerName = (String[]) model.get("headerName");
		 
		XSSFSheet sheet = wb.createSheet(title);
		sheet.setDefaultColumnWidth((short) 20);
		sheet.setDisplayGridlines(false);
		
		// set header information
		int i = 0, j = 0;
		
		//HSSFRow header = sheet.createRow(0);
		XSSFCell header = null;
		
		//셀 크기
        int columnWidth[] = {4,11,13,11,20,19,10,21,15,18,11,10,18};
        
		for(String name : headerName){
			
			XSSFCellStyle style = wb.createCellStyle();
			
			XSSFColor myColor = null;
			
			switch(i){
				case 1: case 4: case 9: myColor = new XSSFColor(new java.awt.Color(255,242,204)); break;
				case 2: case 3: myColor = new XSSFColor(new java.awt.Color(226,239,218)); break;
				default: myColor = new XSSFColor(Color.YELLOW); break;
			}
			
			style.setFillForegroundColor(myColor);
			
			style.setFillPattern(XSSFCellStyle.SOLID_FOREGROUND);
	        style.setBorderRight(XSSFCellStyle.BORDER_THIN);              //테두리 설정   
	        style.setBorderLeft(XSSFCellStyle.BORDER_THIN);   
	        style.setBorderTop(XSSFCellStyle.BORDER_THIN);   
	        style.setBorderBottom(XSSFCellStyle.BORDER_THIN);
	        style.setAlignment(XSSFCellStyle.ALIGN_CENTER);
	        style.setVerticalAlignment(XSSFCellStyle.VERTICAL_CENTER);
	        Font font = wb.createFont();
	        font.setFontHeightInPoints(Integer.valueOf(9).shortValue());
	        style.setFont(font);

	        sheet.setColumnWidth(i, columnWidth[i]*256);
	        
			header= getCell(sheet, 0, i);
			header.setCellStyle(style);
			
			setText(header , name);

			i++;
		}
		
		for(int a=1; a<=10; a++){
			for(int b=0;b<=12;b++){
				
				XSSFCellStyle style = wb.createCellStyle();
				
		        XSSFColor myColor = null;
		        
				switch(b){
					case 1: case 4: case 9: myColor = new XSSFColor(new java.awt.Color(255,242,204)); break;
					case 2: case 3: myColor = new XSSFColor(new java.awt.Color(226,239,218)); break;
					default: myColor = new XSSFColor(Color.WHITE); break;
				}
				
				style.setFillForegroundColor(myColor);
				
				style.setFillPattern(XSSFCellStyle.SOLID_FOREGROUND);
		        style.setBorderRight(XSSFCellStyle.BORDER_THIN);              //테두리 설정   
		        style.setBorderLeft(XSSFCellStyle.BORDER_THIN);   
		        style.setBorderTop(XSSFCellStyle.BORDER_THIN);   
		        style.setBorderBottom(XSSFCellStyle.BORDER_THIN);
		        style.setAlignment(XSSFCellStyle.ALIGN_CENTER);
		        style.setVerticalAlignment(XSSFCellStyle.VERTICAL_CENTER);
		        Font font = wb.createFont();
		        font.setFontHeightInPoints(Integer.valueOf(9).shortValue());
		        style.setFont(font);
				
				if(b==0){
					header= getCell(sheet, a, 0);
					header.setCellStyle(style);
					setInt(header , a);
				}else{
					header= getCell(sheet, a, b);
					header.setCellStyle(style);
					setText(header , "");	
				}
			}
		}
		
		CoviList jArray = new CoviList();
		jArray = (CoviList) model.get("list");
		
		i=0;
		
		for(Object obj : jArray){
			CoviMap jObj = new CoviMap();
			jObj = (CoviMap) obj;
			
			Iterator<?> keys = jObj.keys();
			
			j = 0;

			while(keys.hasNext()){
				String key = (String)keys.next();
				cell = getCell(sheet, 1 + i, j);
				setText(cell, jObj.get(key).toString());
				
				j++;
			}
			
			i++;
		}
		
		String comment[] = RedisDataUtil.getBaseConfig("IssueBoard_ExcelTemplate_Memo","0").split(";"); 
		
		for(int r=0;r<13;r++){
			if(!comment[r].equals("")){
				addComment(wb, sheet, 0, r, "the author", comment[r]);	
			}
		}
		
		
		Date today = new Date();
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
		
		XSSFDataValidationHelper dvHelper = new XSSFDataValidationHelper(sheet); 
		XSSFDataValidationConstraint dvConstraint = (XSSFDataValidationConstraint) 
		dvHelper.createExplicitListConstraint(new String[]{"진행중", "완료"}); 
		CellRangeAddressList addressList = new CellRangeAddressList(1, 10, 10, 10); 
		XSSFDataValidation validation = (XSSFDataValidation)dvHelper.createValidation(dvConstraint, addressList); 
		validation.setShowErrorBox(true); 
		sheet.addValidationData(validation); 
		
		title = URLEncoder.encode(title, "UTF-8");
		title = title.replaceAll("\\+", "%20");
		response.setHeader("Content-Disposition", "attachment; filename=" + title + "_" + dateFormat.format(today) + ".xlsx");
	}

}
