package egovframework.covision.coviflow.user.service.impl;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.Map;
import java.util.Arrays;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;


import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.coviflow.user.service.SeriesListSvc;

@Service("seriesListSvc")
public class SeriesListSvcImpl extends EgovAbstractServiceImpl implements SeriesListSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	Logger LOGGER = LogManager.getLogger(SeriesListSvcImpl.class);
			
	@Override 
	public CoviMap selectBaseYearList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList baseYearList = coviMapperOne.list("user.series.selectBaseYearList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(baseYearList, "BaseYear"));
		
		return resultList; 
	}

	@Override 
	public CoviMap getSubDeptList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		params.put("CompanyCode", SessionHelper.getSession("DN_Code")); 
		params.put("UserCode", SessionHelper.getSession("USERID"));
		
		int adminCnt = coviMapperOne.selectOne("user.series.selectGroupMemberList", params);
		if(adminCnt > 0) {
			params.put("JobTitleCode", "Admin");
			params.put("isAdmin", "Y");
			resultList.put("isAdmin", "Y");
		}else{
			params.put("isAdmin", "N");
			resultList.put("isAdmin", "N");
		}
		
		CoviList subDeptList = coviMapperOne.list("user.series.getSubDeptList", params);
		resultList.put("subDeptList", CoviSelectSet.coviSelectJSON(subDeptList, "GroupID,GroupCode,CompanyCode,GroupType,MemberOf,DisplayName,MultiDisPlayName,TransMultiDisplayName,SortDepth"));
		
		return resultList; 
	}
	
	@Override 
	public CoviMap getFunctionLevel(CoviMap params) throws Exception {
		String level = params.getString("level");
		
		CoviMap resultList = new CoviMap();
		params.put("CompanyCode", SessionHelper.getSession("DN_Code")); 
		params.put("UserCode", SessionHelper.getSession("USERID"));
		
		int adminCnt = coviMapperOne.selectOne("user.series.selectGroupMemberList", params);
		if(adminCnt > 0) {
			params.put("JobTitleCode", "Admin");
			params.put("isAdmin", "Y");
			resultList.put("isAdmin", "Y");
		}else{
			params.put("isAdmin", "N");
			resultList.put("isAdmin", "N");
		}
		CoviList levelList = null;
		if(level.equals("1")) {
			levelList = coviMapperOne.list("user.series.getFunctionLevelList1", params);
		}else if(level.equals("2")) {
			levelList = coviMapperOne.list("user.series.getFunctionLevelList2", params);
		}else {
			levelList = coviMapperOne.list("user.series.getFunctionLevelList3", params);
		}
		  
		resultList.put("levelList", CoviSelectSet.coviSelectJSON(levelList, "functioncode,functionname"));
		
		return resultList; 
	}	
	
	@Override
	public CoviMap selectSeriesListData(CoviMap params, String headerCode) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("user.series.selectSeriesListDataCnt", params);
			page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			
 			resultList.put("page", page);
 		}
		
		CoviList list = coviMapperOne.list("user.series.selectSeriesListData", params);
		if(headerCode.equals("")){
			headerCode = "SeriesCode,SeriesName,SeriesDescription,SFCode,DeptCode,DeptName,KeepPeriod,KeepPeriodTxt,KeepPeriodReason,KeepMethod,KeepMethodTxt,KeepPlace,KeepPlaceTxt,JobType,JobTypeTxt,ApplyDate,MappingID,BaseYear,UnitTaskType,UnitTaskTypeTxt";
		}
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, headerCode));
		return resultList;
	}
	
	@Override
	public CoviMap selectSeriesFunctionListData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("user.series.selectSeriesFunctionListDataCnt", params);
			page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			
 			resultList.put("page", page);
 		}
		
		CoviList list = coviMapperOne.list("user.series.selectSeriesFunctionListData", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FunctionCode,FunctionName,FunctionLevel,ParentFunctionCode,ParentFunctionName,Sort"));
		return resultList;
	}
	
	@Override
	public CoviMap selectSeriesSearchList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(params.containsKey("pageNo")) {
			int cnt = (int) coviMapperOne.getNumber("user.series.selectSeriesSearchListCnt", params);
			page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
 			params.addAll(page);

 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}
		
		CoviList list = coviMapperOne.list("user.series.selectSeriesSearchList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SeriesCode,SeriesName,DeptCode,DeptName"));
		return resultList;
	}
	
	@Override
	public CoviMap selectSeriesSearchTreeData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.series.selectSeriesSearchTreeData", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SFCode,SFName,SFParentCode,SFLevel"));
		
		return resultList;
	}
	
	@Override
	public CoviMap seriesExcelUpload(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		MultipartFile mFile = (MultipartFile) params.get("uploadfile");
		File file = prepareAttachment(mFile);	// 파일 생성
		Workbook wb = null;
		ArrayList<CoviMap> returnList = new ArrayList<>();
		CoviMap tempJo = null;
		try {
			wb = WorkbookFactory.create(file);
			Sheet sheet = wb.getSheetAt(0);
			
			Iterator<Row> rowIterator = sheet.iterator();
			int cellNum = 0;
			
			while (rowIterator.hasNext()) {
				Row row = rowIterator.next();
				int rowNum = row.getRowNum();
				
				if (rowNum == 0) {
					cellNum = row.getLastCellNum();	
				} else if (rowNum > 0) {	// header 제외
					tempJo = new CoviMap();
					
					for (int colNum=0; colNum<cellNum; colNum++) {
						String key = "";
						switch (colNum) {
							case 0	: key = "ProcessDateTime"; break;
							case 1	: key = "ApplyDate"; break;
							case 2	: key = "DeptCode"; break;
							case 3	: key = "DeptName"; break;
							case 4	: key = "TempSeriesCode"; break;
							case 5	: key = "SmallFunctionCode"; break;
							case 6	: key = "SeriesCode"; break;
							case 7	: key = "SeriesName"; break;
							case 8	: key = "SeriesDescription"; break;
							case 9	: key = "KeepPeriod"; break;
							case 10	: key = "KeepPeriodReason"; break;
							case 11	: key = "KeepMethod"; break;
							case 12	: key = "KeepPlace"; break;
							case 13	: key = "JobType"; break;
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
					
					if(checkNull(tempJo.getString("ProcessDateTime"))		//처리일시
						|| checkNull(tempJo.getString("ApplyDate"))			//적용기준일
						|| checkNull(tempJo.getString("DeptCode"))			//처리과기관코드
						|| checkNull(tempJo.getString("SmallFunctionCode"))	//소기능코드
						|| checkNull(tempJo.getString("SeriesCode"))		//단위업무코드
						|| checkNull(tempJo.getString("KeepPeriod"))		//보존기간
						|| checkNull(tempJo.getString("KeepMethod"))		//보존방법
						|| checkNull(tempJo.getString("KeepPlace"))			//보존장소
						|| checkNull(tempJo.getString("JobType"))){			//사용여부
						resultList.put("err","nullErr");
						return resultList;
					} else {
						Calendar cal = Calendar.getInstance();
						tempJo.put("BaseYear", cal.get(Calendar.YEAR));
						
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
		coviMapperOne.insert("user.series.insertSeriesByExcel", params);
		coviMapperOne.insert("user.series.insertSeriesMappingByExcel", params);
		
		return resultList;
	}
	
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
	
	@Override
	public int insertSeriesData(CoviMap params) throws Exception {
		params.put("SeriesCode", makeSeriesCode(params.getString("UnitTaskType")));
		int result = coviMapperOne.insert("user.series.insertSeriesData", params);
		String[] deptName = (String[])params.get("ArrDeptName");
		int idx = 0;
		
		for (String deptCode : (String[])params.get("ArrDeptCode")){
			params.put("DeptName", deptName[idx++]);
			params.put("DeptCode", deptCode);
			coviMapperOne.insert("user.series.insertSeriesMappingData", params);
		}
		
		return result;
	}
	
	@Override
	public int insertSeriesByYear(CoviMap params) throws Exception {
		int result = coviMapperOne.insert("user.series.insertSeriesByYear", params);
		coviMapperOne.insert("user.series.insertSeriesMappingByYear", params);
		return result;
	}
	
	@Override
	public int updateSeriesData(CoviMap params) throws Exception {
		int result = coviMapperOne.update("user.series.updateSeriesData", params);
		coviMapperOne.update("user.series.updateSeriesMappingData", params);
		coviMapperOne.update("user.series.updateMappingSeriesNameData", params);
		return result;
	}

	@Override
	public int updateRevokeSeries(CoviMap params) throws Exception {
		int result = coviMapperOne.update("user.series.updateRevokeSeries", params);
		coviMapperOne.update("user.series.updateRevokeDeleteData", params);
		return result;
	}
	
	@Override
	public int updateRestoreSeries(CoviMap params) throws Exception {
		int result = coviMapperOne.update("user.series.updateRestoreData", params);
		coviMapperOne.update("user.series.updateRestoreSeries", params);
		return result;
	}
	
	@Override
	public int updateSyncSeries(CoviMap params) throws Exception {
		int result = coviMapperOne.update("user.series.updateSyncSeries", params);
		
		//한투소스 동기화로직(커스텀사항으로 한투는 직접 DB연결하여 list 동기화함..  
		/*CoviList unitList = coviMapperOne.list("rms.series.selectZZUnitList", params);
		CoviList orgUnitList = coviMapperOne.list("rms.series.selectZZOrgUnitList", params);
		CoviList clssList = coviMapperOne.list("rms.series.selectZZClssList", params);
		
		if(!unitList.isEmpty()){
			for(int i = 0; i < unitList.size(); i++){
				CoviMap unitMap = unitList.getMap(i);
				unitMap.put("BaseYear", params.get("BaseYear"));
				coviMapperOne.update("user.series.KICupdateSyncSeries", unitMap);
				result++;
			}
		}
		
		if(!unitList.isEmpty()){
			for(int i = 0; i < orgUnitList.size(); i++){
				CoviMap orgUnitMap = orgUnitList.getMap(i);
				orgUnitMap.put("BaseYear", params.get("BaseYear"));
				coviMapperOne.update("user.series.KICupdateSyncSeriesMapping", orgUnitMap);
				result++;
			}
		}
		
		if(!clssList.isEmpty()){
			coviMapperOne.delete("user.series.KICdeleteSyncSeriesFunc", null);
			for(int i = 0; i < clssList.size(); i++){
				CoviMap clssMap = clssList.getMap(i);
				coviMapperOne.insert("user.series.KICinsertSyncSeriesFunc", clssMap);
				result++;
			}
		}*/
		
		return result;
	}
	
	@Override
	public String getSeriesPath(CoviMap params) throws Exception {
		int seriesCnt = coviMapperOne.selectOne("user.series.selectSeriesPathCnt", params);
		params.put("FunctionCnt", seriesCnt);
		return coviMapperOne.selectOne("user.series.selectSeriesPath", params);
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
	
	private String makeSeriesCode(String gubun){
		String returnCode = gubun;
		CoviMap params = new CoviMap();
		params.put("gubun", gubun);
		
		String lastSeriesCode = coviMapperOne.selectOne("user.series.selectSeriesCode", params);
		int seriesNum = 1;
		
		if(lastSeriesCode != null){
			seriesNum = Integer.parseInt(lastSeriesCode.substring(2, lastSeriesCode.length())) + 1;
		}
		
		returnCode += String.format("%06d", seriesNum);
		
		return returnCode;
	}
}
