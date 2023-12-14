package egovframework.core.sevice.impl;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;

import javax.annotation.Resource;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.core.sevice.SysBaseConfigSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("sysBaseConfigService")
public class SysBaseConfigSvcImpl extends EgovAbstractServiceImpl implements SysBaseConfigSvc {
	
	private Logger LOGGER = LogManager.getLogger(SysBaseConfigSvc.class);

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * 그리드에 사용할 데이터 Select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap select(CoviMap params) throws Exception {
		CoviMap page = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt = (int) coviMapperOne.getNumber("baseconfig.selectgridcnt", params);
			page = ComUtils.setPagingData(params,cnt);
			params.addAll(page);
		}	
		CoviList list = coviMapperOne.list("baseconfig.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ConfigID,BizSection,BizSectionName,DomainID,DisplayName,SettingKey,SettingValue,IsCheck,IsUse,ConfigType,ConfigName,Description,RegisterCode,RegisterName,ModifierCode,ModifyDate"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	/**
	 * 추가 시 데이터 Insert
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public Object insert(CoviMap params)throws Exception {
		return coviMapperOne.insertWithPK("baseconfig.insertgrid", params);
	}
	
	/**
	 * 추가 시 존재하면 업데이트
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public int insertMerge(CoviMap params)throws Exception {
		return coviMapperOne.update("baseconfig.insertMerge", params);
	}
	
	/**
	 * 수정 및 조회를 위한 단일 건 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectOne(CoviMap params) throws Exception {
		
		CoviMap map = coviMapperOne.select("baseconfig.selectone", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "ConfigID,BizSection,BizSectionName,DomainID,DisplayName,SettingKey,SettingValue,IsCheck,IsUse,ConfigType,ConfigName,Description,RegisterCode,RegisterName,ModifierCode,ModifyDate"));
		return resultList;
	}
	
	/**
	 * 데이터 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int update(CoviMap params)throws Exception {
		return coviMapperOne.update("baseconfig.updategrid", params);
	}
	
	/**
	 * 사용유무 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsUse(CoviMap params)throws Exception{
		return coviMapperOne.update("baseconfig.updateIsUse", params);
	};
	
	/**
	 * 데이터 삭제
	 * @param params - CoviMap
	 * @return int - delete 결과 상태
	 * @throws Exception
	 */
	@Override
	public int delete(CoviMap params)throws Exception {
		return coviMapperOne.delete("baseconfig.deletegrid", params);
	}

	@Override
	public int selectForCheckingDouble(CoviMap params) throws Exception {
		int cnt = (int) coviMapperOne.getNumber("baseconfig.selectForCheckingDouble", params);
		return cnt;
	}
	
	@Override
	public int selectForCheckingKey(CoviMap params) throws Exception {
		int cnt = (int) coviMapperOne.getNumber("baseconfig.selectForCheckingKey", params);
		return cnt;
	}

	@Override
	public CoviMap selectExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("baseconfig.selectgrid", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DisplayName,BizSectionName,SettingKey,SettingValue,ConfigType,ConfigName,Description,RegisterName,IsCheck,IsUse,RegistDate,ModifyDate"));
		
		return resultList;
	}
	
	// 엑셀 데이터 추출
	public ArrayList<ArrayList<Object>> extractionExcelData(CoviMap params, int headerCnt) throws Exception {
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
		} finally {
			if (file != null) {
				if(!file.delete()) {
					/* Do nothing.*/
					LOGGER.warn("Fail to delete file.");
				}
			}
			if (wb != null) {
				wb.close();
			}
		}
		
		return returnList;
	} 
	
	// 임시파일 생성
	public File prepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        
	        return tmp;
	    } catch (IOException ioE) {
	        if (tmp != null) {
	        	if(!tmp.delete()) {
	        		/* Do nothing.*/
	        		LOGGER.warn("Fail to delete file.");
	        	}
	        }
	        throw ioE;
	    }
	}
	
	//
	@Override
	public CoviMap checkExcelWorkInfoData(ArrayList<ArrayList<Object>> dataList) throws Exception {
		CoviMap returnJson = new CoviMap();
		
		//검증데이터 파싱
		CoviList exArry = new CoviList();
		
		String uploadYn = "Y"; //엑셀데이터에 문제가 없어야 업로드 가능하도록
		
		CoviList workcodeStr = RedisDataUtil.getBaseCode("WorkCode");
		CoviList unittermStr = RedisDataUtil.getBaseCode("UnitTerm");
		
		String attBaseWeek = RedisDataUtil.getBaseConfig("AttBaseWeek");
		
		for (int i=0;i< dataList.size();i++) {
			CoviMap exObj = new CoviMap();
			
			LOGGER.debug("######## dataList : "+dataList.get(i));
			ArrayList<Object> tempList = dataList.get(i);
			//<!-- 2022.01.04 nkpark 업로드 엑셀 약식 널 체크 공백 로우 체크
			if(tempList.size()!=5){
				continue;
			}
			boolean nullCk = false;
			for(int k=0;k<5;k++){
				String tempVal = String.valueOf(tempList.get(k));
				if(tempVal==null || tempVal.equals("")){
					nullCk = true;
					break;
				}
			}
			if(nullCk){continue;}
			//-->
			String ex_UserCode = String.valueOf(tempList.get(0));
			String ex_WorkWeek = String.valueOf(tempList.get(1));
			String ex_WorkRule = String.valueOf(tempList.get(2));
			String ex_MaxWorkRule = String.valueOf(tempList.get(3));
			String ex_ApplyDate = String.valueOf(tempList.get(4));
			
			//적용시점 데이터 날짜 유효성검사
			//String ApplyDate_valid = dateTypeValidCheck(ex_ApplyDate,"yyyy-MM-dd")?"Y":"N";

			exObj.put("UserCode",ex_UserCode);
			exObj.put("ApplyDate",ex_ApplyDate);
			exObj.put("ex_WorkWeek",ex_WorkWeek);
			exObj.put("ex_WorkRule",ex_WorkRule);
			exObj.put("ex_MaxWorkRule",ex_MaxWorkRule);
			//exObj.put("ApplyDate_valid",ApplyDate_valid);
			
			LOGGER.debug("ex_UserCode : "+ex_UserCode);
			LOGGER.debug("ex_ApplyDate : "+ex_ApplyDate);
			
			exArry.add(exObj);
		}
		
		CoviMap ckParams = new CoviMap();
		ckParams.put("workInfoList", exArry);
		ckParams.put("DN_ID", SessionHelper.getSession("DN_ID"));
		ckParams.put("lang", SessionHelper.getSession("lang"));
		
		//사용자와 적용시점 중복 불가 
		CoviList workInfoList = coviMapperOne.list("attend.adminSetting.chkWorkInfoDataValue", ckParams);
		/*for(int i=0;i<workInfoList.size();i++){
			CoviMap wMap = workInfoList.getMap(i);
			if("N".equals(wMap.get("userCode_validYn"))||"N".equals(wMap.get("applyDate_validYn")) 
					||"N".equals(wMap.get("WorkWeek_valid"))||"N".equals(wMap.get("WorkRule_valid"))
					||"N".equals(wMap.get("MaxWorkRule_valid"))||"N".equals(wMap.get("ApplyDate_valid"))){
				uploadYn = "N";
			}
		}*/
		
		returnJson.put("list", CoviSelectSet.coviSelectJSON(workInfoList, "UserCode,UserName,ApplyDate,WorkWeek,WorkTime,WorkCode,UnitTerm,WorkApplyDate,MaxWorkTime,MaxWorkCode,MaxUnitTerm,MaxWorkApplyDate,WorkWeek_valid,WorkRule_valid,MaxWorkRule_valid,ex_WorkWeek,ex_WorkRule,ex_MaxWorkRule,userCode_validYn,applyDate_validYn"));
		
		returnJson.put("uploadYn",uploadYn);
		return returnJson;
	} 
}
