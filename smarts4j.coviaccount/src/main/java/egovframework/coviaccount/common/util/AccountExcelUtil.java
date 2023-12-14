package egovframework.coviaccount.common.util;

import java.io.File;
import java.io.IOException;
import java.lang.invoke.MethodHandles;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;




import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

@Component("AccountExcelUtil")
public class AccountExcelUtil  {
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	/**
	 * 엑셀 데이터 추출 
	 * 헤더명 지정 없이 list로 추출
	 */
	public ArrayList<ArrayList<Object>> extractionExcelData(CoviMap params, int headerCnt) throws Exception {
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = prepareAttachment(mFile);	// 파일 생성
		Workbook wb = null;
		ArrayList<ArrayList<Object>> returnList = new ArrayList<>();
		
		try {
			wb = WorkbookFactory.create(file);
			Sheet sheet = wb.getSheetAt(0);
			
			ArrayList<Object> tempList = null;
			Iterator<Row> rowIterator = sheet.iterator();
			
			int lastCellNum = 0;
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				
				if (row.getRowNum() > (headerCnt - 1)) {	// header 제외
					if(lastCellNum == 0) {
						lastCellNum = row.getLastCellNum();
					}
					
					tempList = new ArrayList<>();
					for(int colNum = 0; colNum < lastCellNum; colNum++) {
						Cell cell = row.getCell(colNum, Row.CREATE_NULL_AS_BLANK);
						
						switch (cell.getCellType()) {
						case Cell.CELL_TYPE_BOOLEAN :
							tempList.add(cell.getBooleanCellValue());
							break;
						case Cell.CELL_TYPE_NUMERIC : 
							tempList.add((int)cell.getNumericCellValue());
							break;
						case Cell.CELL_TYPE_STRING : 
							tempList.add(cell.getStringCellValue());
							break;
						case Cell.CELL_TYPE_FORMULA : 
							tempList.add(cell.getCellFormula());
							break;
						case Cell.CELL_TYPE_BLANK:
							tempList.add("");
							break;
						default :
							break;
						}
					}
					
					returnList.add(tempList);
				} else {  
					lastCellNum =  row.getLastCellNum(); // header의 cell 수만큼 for문 돌도록
				}
			}
		} catch (IOException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		} finally { 
			if( wb != null ) { wb.close(); }
			if (file != null && Files.deleteIfExists(file.toPath())) {
				logger.info("extractionExcelData : file delete();");
			}
		}
		
		return returnList;
	}

	/**
	 * 엑셀 데이터 추출 
	 * 헤더명 입력시 map형태로 추출
	 */
	public List<Map<String, Object>> extractionExcelDataMap(CoviMap params, int headerCnt, String[] headerList) throws Exception {
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = prepareAttachment(mFile);	// 파일 생성
		ArrayList<Map<String, Object>> returnList = new ArrayList<>();
		Workbook wb = null;
		
		try {
			wb = WorkbookFactory.create(file);
			Sheet sheet = wb.getSheetAt(0);
			
			Map<String, Object> tempMap = null; 
			Iterator<Row> rowIterator = sheet.iterator();
			
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				
				if (row.getRowNum() > (headerCnt - 1)) {	// header 제외
					tempMap = new HashMap<>(); 
					int cnt = 0;
					for(int colNum = 0; colNum < row.getLastCellNum(); colNum++) {
						Cell cell = row.getCell(colNum, Row.CREATE_NULL_AS_BLANK);
						
						switch (cell.getCellType()) {
						case Cell.CELL_TYPE_BOOLEAN :
							tempMap.put(getHeader(headerList, cnt), cell.getBooleanCellValue());
							break;
						case Cell.CELL_TYPE_NUMERIC : 
							tempMap.put(getHeader(headerList, cnt), cell.getNumericCellValue());
							break;
						case Cell.CELL_TYPE_STRING : 
							tempMap.put(getHeader(headerList, cnt), cell.getStringCellValue());
							break;
						case Cell.CELL_TYPE_FORMULA : 
							tempMap.put(getHeader(headerList, cnt), cell.getCellFormula());
							break;
						default :
							break;
						}
						
						cnt++;
					}
					returnList.add(tempMap);
				}
			}
		} catch (IOException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		} finally {
			if( wb != null ) { wb.close(); }
			if (file != null && Files.deleteIfExists(file.toPath())) {
				logger.info("extractionExcelDataMap : file delete();");
			}
		}
		
		return returnList;
	}
	
	// 임시파일 생성
	private File prepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        
	        return tmp;
	    } catch (IOException ioE) {
			if (tmp != null && Files.deleteIfExists(tmp.toPath())) {
				logger.info("prepareAttachment : tmp delete();");
			}	    	
	        
	        throw ioE;
	    }
	}

	private String getHeader(String[] headerList, int cnt){
		String returnStr = "header"+cnt;
		if(headerList.length-1 >cnt){
			if(headerList[cnt] != null
					&& !"".equals(headerList[cnt])){
				returnStr = headerList[cnt];
			}
		}
		return returnStr;
	}
	
	/**
	 * JSON For Excel 
	 */
	public static CoviList selectJSONForExcel(CoviList clist, String str) throws Exception {
		String[] cols = str.split(",");

		CoviList returnArray = new CoviList();

		if (null != clist && !clist.isEmpty()) {
			for (int i = 0; i < clist.size(); i++) {
				CoviMap newObject = new CoviMap();

				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();
					String colStr	= cols[j].trim();
					String colValue	= "";
					while (iter.hasNext()) {
						Object ar = iter.next();
						if (ar.equals(colStr)) {
							colValue = clist.getMap(i).getString(colStr);
							break;
						}
					}
					newObject.put(colStr, colValue);
				}
				returnArray.add(newObject);
			}
		}
		return returnArray;
	}
}
