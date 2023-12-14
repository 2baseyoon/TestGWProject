package egovframework.covision.groupware.workreport.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.workreport.service.WorkManageService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("WorkManageService")
public class WorkManageServiceImpl extends EgovAbstractServiceImpl implements WorkManageService{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public int checkDuplicateCode(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = (int)coviMapperOne.getNumber("groupware.workreport.duplicateCate", params);
		
		return cnt;
	}

	@Override
	public int insertWorkCategorie(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = (int)coviMapperOne.insert("groupware.workreport.insertCate", params);
		
		return cnt;
	}
	
	@Override
	public int deleteCateCode(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = (int)coviMapperOne.delete("groupware.workreport.deleteCate", params);
		
		return cnt;
	}

	@Override
	public CoviMap getCateTypeList(CoviMap params) throws Exception {
		CoviList resultList = null;
		
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
 		
		if(params.containsKey("pageNo")) {
			int resultCnt = (int) coviMapperOne.getNumber("groupware.workreport.selectCateTypeCnt", params);
		 	page = ComUtils.setPagingData(params, resultCnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
		 	returnObj.put("cnt", resultCnt);
		}
		
		resultList = coviMapperOne.list("groupware.workreport.selectCateTypeList", params);
		returnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "code,name,refcnt"));
		
		return returnObj;
	}

	@Override
	public CoviMap getCateDivList(CoviMap params) throws Exception {
		CoviList resultList = null;
		
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
 		
		if(params.containsKey("pageNo")) {
			int resultCnt = (int) coviMapperOne.getNumber("groupware.workreport.selectCateDivCnt", params);
		 	page = ComUtils.setPagingData(params, resultCnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
			returnObj.put("cnt", resultCnt);
		}
		
		resultList = coviMapperOne.list("groupware.workreport.selectCateDivList", params);
		returnObj.put("list", CoviSelectSet.coviSelectJSON(resultList, "code,name,refcnt"));
		
		return returnObj;
	}
	
	@Override
	public CoviMap getCateTypeSelList(CoviMap params) throws Exception {
		CoviList selList = null;
		// 전체 리스트 조회
		selList = coviMapperOne.list("groupware.workreport.selectCateTypeSelList", params);
		
		CoviMap returnObj = new CoviMap();
		returnObj.put("list", CoviSelectSet.coviSelectJSON(selList, "code,name"));
		
		return returnObj;
	}
	
	@Override
	public CoviMap setDivisionWorkType(CoviMap params) throws Exception {
		// 입력
		if(params.get("newcode") != null)
			coviMapperOne.insert("groupware.workreport.insertDivisionDefaultType", params);
		// 삭제
		if(params.get("delcode") != null)
			coviMapperOne.delete("groupware.workreport.deleteDivisionDefaultType", params);
		// 결과 반환 - 여기까지 오류가 없었으면 정상진행
		CoviMap result = new CoviMap();
		result.put("result", "success");
		return result;
	}
	
	
	@Override
	public int insertWork(CoviMap params) throws Exception {
		// 추가
		int cnt = coviMapperOne.insert("groupware.workreport.insertWork", params);
		return cnt;
	}
	
	@Override
	public int selectWorkJobNumber(CoviMap params) throws Exception {
		int cnt = (int)coviMapperOne.getNumber("groupware.workreport.selectWorkJobNumber", params);
		return cnt;
	}
	
	@Override
	public CoviMap selectWorkList(CoviMap params) throws Exception {
		CoviList list = null;
		
		CoviMap result = new CoviMap();
		CoviMap page = new CoviMap();
 		
		if(params.containsKey("pageNo")) {
		 	int cnt = (int)coviMapperOne.getNumber("groupware.workreport.selectWorkJobCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
		 	result.put("page", page);
			result.put("cnt", cnt);
		}
		
		list = coviMapperOne.list("groupware.workreport.selectWorkJobList", params);
		result.put("list", CoviSelectSet.coviSelectJSON(list, "JobID,JobName,JobDivision,ManagerCode,IsUse,CreateDate,CreatorCode,ManagerName,JobDivisionName"));
		
		return result;
	}
	
	@Override
	public int changeUseYN(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		return coviMapperOne.update("groupware.workreport.updateWorkUseYn", params);
	}
	
	@Override
	public int deleteWorkJob(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		return coviMapperOne.delete("groupware.workreport.deleteWorkJob", params);
	}
	
	@Override
	public CoviMap selectOneWorkJob(CoviMap params) throws Exception {
		CoviMap returnJob = new CoviMap();
		CoviMap objJob = new CoviMap();
		objJob.addAll(coviMapperOne.select("groupware.workreport.selectOneWorkJob", params));
		
		returnJob.put("job", objJob);
		
		return returnJob;
	}
	
	@Override
	public int updateWork(CoviMap params) throws Exception {
		// 수정
		int cnt = coviMapperOne.update("groupware.workreport.updateWork", params);
		return cnt;
	}
	
	@Override
	public CoviMap insertApprover(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		CoviMap duplicate = coviMapperOne.select("groupware.workreport.cntApproverSetting", params);
		int duplicateCnt = duplicate.getInt("CNT");
		
		if(duplicateCnt == 0) {
			// 중복이 아니라면
			returnCnt = coviMapperOne.insert("groupware.workreport.insertApproverSetting", params);
			
			if(returnCnt == 1) resultObj.put("result", "OK");
			else resultObj.put("result", "FAIL");
		} else {
			// 중복
			resultObj.put("result", "EXIST");
		}
		return resultObj;
	}
	
	@Override
	public CoviMap selectApproverList(CoviMap params) throws Exception {
		CoviList list = null;
		
		CoviMap result = new CoviMap();
		CoviMap page = new CoviMap();
		
		String strGRCode = params.getString("grCode");
		String strGroupPath = null;
		if(strGRCode != null && !strGRCode.equals("")) {
			strGroupPath = coviMapperOne.select("groupware.workreport.selectGroupPath", params).getString("groupPath");
		}
		
		String[] arrGroupPath = null;
		
		if(strGroupPath != null && !strGroupPath.equals(""))
			arrGroupPath = strGroupPath.split(";");
		
		params.put("groupPath", arrGroupPath);
 		
		if(params.containsKey("pageNo")) {
		 	int cnt = (int)coviMapperOne.getNumber("groupware.workreport.selectApproverCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
		 	result.put("page", page);
			result.put("cnt", cnt);
		}
		
		list = coviMapperOne.list("groupware.workreport.selectApproverList", params);
		result.put("list", CoviSelectSet.coviSelectJSON(list, "ApproverNo,UR_Code,GR_Code,urName,grName"));
		
		return result;
	}
	
	@Override
	public int deleteApprover(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		return coviMapperOne.delete("groupware.workreport.deleteApproverSetting", params);
	}

	@Override
	public String createWorkWithNumber(CoviMap params) throws Exception {
		String strJobName = params.getString("jobName");
		String strJobDivision = params.getString("jobDivision");
		String strUseYN = params.getString("useYN");
		String strManagerCode = params.getString("managerCode");
		String strStartDate = params.getString("startDate");
		String strEndDate = params.getString("endDate");
		String strCreatorCode = params.getString("creatorCode");
		String strMappingID = params.getString("MappingID");
		String strProjectDivCode = params.getString("ProjectDivCode");
		String year = params.getString("year");
		
		//int cnt = workManageService.selectWorkJobNumber(params);
		int cnt = (int)coviMapperOne.getNumber("groupware.workreport.selectWorkJobNumber", params);
		
		String formattedSerialNumber = String.format("%04d", cnt);
		String displayNumber = strProjectDivCode + "-" + year + "-" + formattedSerialNumber;
		
		params.clear();
		params.put("jobName", strJobName);
		params.put("jobDivision", strJobDivision);
		params.put("useYN", strUseYN);
		params.put("managerCode", strManagerCode);
		params.put("creatorCode", strCreatorCode);
		params.put("startDate", strStartDate);
		params.put("endDate", strEndDate);
		params.put("ProjectCode", displayNumber);
		params.put("MappingID", strMappingID);
		
		// 서비스 호출
		//workManageService.insertWork(params);
		coviMapperOne.insert("groupware.workreport.insertWork", params);
		
		return displayNumber;
	}
	
	
}
