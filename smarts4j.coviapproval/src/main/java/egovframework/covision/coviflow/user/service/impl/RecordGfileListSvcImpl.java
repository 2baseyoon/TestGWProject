package egovframework.covision.coviflow.user.service.impl;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;

import javax.annotation.Resource;



import org.apache.commons.lang.StringUtils;
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
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.coviflow.user.service.RecordGfileListSvc;
import egovframework.covision.coviflow.user.service.SeriesListSvc;

@Service("recordGfileListSvc")
public class RecordGfileListSvcImpl extends EgovAbstractServiceImpl implements RecordGfileListSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private SeriesListSvc seriesListSvc;
	
	Logger LOGGER = LogManager.getLogger(RecordGfileListSvcImpl.class);
	@Override
	public CoviMap selectRecordGFileListData(CoviMap params, String headerCode) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("user.record.gfile.selectRecordGFileListDataCnt", params);
			page = egovframework.coviframework.util.ComUtils.setPagingData(params, cnt);
 			params.addAll(page);

 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}
		
		CoviList list = coviMapperOne.list("user.record.gfile.selectRecordGFileListData", params);
		if(headerCode.equals("")){
			headerCode = "RecordDeptCode,RecordProductName,ProductYear,SeriesName,SeriesCode,RecordSeq,RecordCount,RecordSubject,RecordType,RecordTypeTxt,EndYear,KeepPeriod,KeepPeriodTxt,KeepMethod,KeepMethodTxt,KeepPlace,KeepPlaceTxt,RecordClass,RecordClassTxt,EditCheck,EditCheckTxt,RecordRegisteredCount,RecordPageCount,RecordFileCount,TakeoverCheck,TakeoverCheckTxt,RecordClassNum,SeriesPath,RecordStatus,RecordStatusTxt,ProvideYN,WorkCharger,RCnt,ProvideEndDate,AutoYearYN";
		}
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, headerCode));
		return resultList;
	}
	
	@Override
	public CoviMap selectRecordHistoryList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("user.record.gfile.selectRecordHistoryListCnt", params);
			page = egovframework.coviframework.util.ComUtils.setPagingData(params, cnt);
 			params.addAll(page);

 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}
		
		CoviList list = coviMapperOne.list("user.record.gfile.selectRecordHistoryList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GFileHistoryID,ModifyReason,ModifierName,ModifyDate,BeforeSubject,AfterSubject,BeforeType,AfterType,BeforeTypeTxt,AfterTypeTxt,BeforeKeepPeriod,AfterKeepPeriod,BeforeKeepPeriodTxt,AfterKeepPeriodTxt"));
		return resultList;
	}
	
	@Override
	public CoviMap selectBaseYearList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.record.gfile.selectBaseYearList", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "BaseYear"));
		
		return resultList;
	}
	
	@Override
	public int insertRecordGFileData(CoviMap params) throws Exception {
		return coviMapperOne.insert("user.record.gfile.insertRecordGFileData", params);
	}
	
	@Override
	public int insertRecordGFileByYear(CoviMap params) throws Exception {
		return coviMapperOne.insert("user.record.gfile.insertRecordGFileByYear", params);
	}
	
	@Override
	public int insertRecordGFileByYearSchedule(CoviMap params) throws Exception {
		return coviMapperOne.insert("user.record.gfile.insertRecordGFileByYearSchedule", params);
	}
	
	@Override
	public int updateRecordGFileData(CoviMap params) throws Exception {
		int result = coviMapperOne.insert("user.record.gfile.insertRecordGFileHistory", params);
		result += coviMapperOne.update("user.record.gfile.updateRecordGFileData", params);
		return result;
	}
	
	@Override
	public int updateRecordStatus(CoviMap params) throws Exception {
		return coviMapperOne.update("user.record.gfile.updateRecordStatus", params);
	}
	
	@Override
	public int updateExtendWork(CoviMap params) throws Exception {
		return coviMapperOne.update("user.record.gfile.updateExtendWork", params);
	}
	
	@Override
	public int updateRecordTakeover(CoviMap params) throws Exception {
		int result = coviMapperOne.update("user.record.gfile.updateRecordTakeover", params);
		
		params.put("ModifyReason", "인계");
		coviMapperOne.insert("user.record.gfile.insertRecordGFileHistory", params);
		coviMapperOne.insert("user.record.gfile.insertRecordTakeover", params);
		coviMapperOne.update("user.record.gfile.updateDocTakeover", params);		
		
		params.put("ModifyReason", "인수");
		coviMapperOne.insert("user.record.gfile.insertRecordGFileHistory", params);
		
		return result;
	}
	
	@Override
	public int recordGFileExcelUpload(CoviMap params) throws Exception {
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = prepareAttachment(mFile);	// 파일 생성
		Workbook wb = null;
		ArrayList<CoviMap> returnList = new ArrayList<>();
		
		try {
			wb = WorkbookFactory.create(file);
			Sheet sheet = wb.getSheetAt(0);
			
			CoviMap tempJo = null;
			Iterator<Row> rowIterator = sheet.iterator();
			int cellNum = 0;
			
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				int rowNum = row.getRowNum();
				
				if (rowNum == 0) {
					cellNum = row.getLastCellNum();	
				} else if (rowNum > 0) {	// header 제외
					tempJo = new CoviMap();
					CoviMap subParams = new CoviMap();
					
					for (int colNum=0; colNum<cellNum; colNum++) {
						String key = "";
						switch (colNum) {
							case 0	: key = "RecordDeptCode"; break;
							case 1	: key = "RecordProductName"; break;
							case 2	: key = "RecordSubject"; break;
							case 3	: key = "SeriesName"; break;
							case 4	: key = "SeriesCode"; break;
							case 5	: key = "RecordSeq"; break;
							case 6	: key = "RecordCount"; break;
							case 7	: key = "ProductYear"; break;
							case 8	: key = "RecordType"; break;
							case 9	: key = "EndYear"; break;
							case 10	: key = "KeepPeriod"; break;
							case 11	: key = "KeepMethod"; break;
							case 12	: key = "KeepPlace"; break;
							case 13	: key = "RecordClass"; break;
							case 14	: key = "EditCheck"; break;
							case 15	: key = "RecordRegisteredCount"; break;
							case 16	: key = "RecordPageCount"; break;
							case 17	: key = "RecordFileCount"; break;
							case 18	: key = "TakeoverCheck"; break;
							default : key = ""; break;
						}
						
						Cell cell = row.getCell(colNum, Row.CREATE_NULL_AS_BLANK);
						switch (cell.getCellType()) {
							case Cell.CELL_TYPE_BOOLEAN : tempJo.put(key, Boolean.toString(cell.getBooleanCellValue())); break;
							case Cell.CELL_TYPE_NUMERIC : tempJo.put(key, Integer.toString((int)cell.getNumericCellValue())); break;
							case Cell.CELL_TYPE_STRING : tempJo.put(key, cell.getStringCellValue()); break;
							case Cell.CELL_TYPE_FORMULA : tempJo.put(key, cell.getCellFormula()); break;
							default : tempJo.put(key, ""); break;
						}
					}
					
					if(tempJo.getString("SeriesCode") != null && !"".equals(tempJo.getString("SeriesCode"))){
						subParams.put("SeriesCode", tempJo.getString("SeriesCode"));
						subParams.put("BaseYear", tempJo.getString("ProductYear"));
						String seriesPath = seriesListSvc.getSeriesPath(subParams);
						String recordClassNum =   tempJo.getString("RecordDeptCode")
												+ tempJo.getString("SeriesCode")
												+ tempJo.getString("ProductYear")
												+ StringUtils.leftPad(tempJo.getString("RecordSeq"), 6, "0")
												+ StringUtils.leftPad(tempJo.getString("RecordCount"), 3, "0");
						
						tempJo.put("RecordClassNum", recordClassNum);
						tempJo.put("SeriesPath", seriesPath);
						if(seriesPath != null && !seriesPath.equals(""))
							returnList.add(tempJo);
					}
				}
			}
		} catch (ArrayIndexOutOfBoundsException aioobE) {
			LOGGER.error(aioobE.getLocalizedMessage(), aioobE);
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if(wb != null) {wb.close();}
			if (file != null) {
			    if(file.delete()) {
			    	params.put("filedeleteResult", "true");
			    }
			}
		}
		
		params.put("dataList", returnList);
		params.put("userCode", SessionHelper.getSession("USERID"));
		return coviMapperOne.insert("user.record.gfile.insertRecordGFileByExcel", params);
	}
	
	// 임시파일 생성
	private File prepareAttachment(final MultipartFile mFile) throws IOException {
		File tmp = null;
		
		try {
			tmp = File.createTempFile("upload", ".tmp");
			mFile.transferTo(tmp);
			
			return tmp;
		} catch (IOException ioE) {
			if (tmp != null) {
				if(tmp.delete()) {
					//;
				}else {
					throw new IOException ("delete error.");
				}
			}
			throw ioE;
		}
	}
	
	@Override
	public String selectRecordSeq(CoviMap params) throws Exception {
		String lastRecordSeq = coviMapperOne.selectOne("user.record.gfile.selectRecordSeq", params);
		int recordSeq = 1;
		
		if(lastRecordSeq != null){
			recordSeq = Integer.parseInt(lastRecordSeq) + 1;
		}
		
		return String.format("%06d", recordSeq);
	}
	
	@Override
	public CoviMap selectRecordGFileTreeData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.record.gfile.selectRecordGFileTreeData", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		return resultList;
	}

	@Override
	public int insertRecordGFileIntergrationHistory(CoviMap params) throws Exception {
		return coviMapperOne.insert("user.record.gfile.insertRecordGFileIntergrationHistory", params);
	}
	
	@Override
	public int updateDocIntergration(CoviMap params) throws Exception {
		return coviMapperOne.update("user.record.gfile.updateDocIntergration", params);
	}
}
