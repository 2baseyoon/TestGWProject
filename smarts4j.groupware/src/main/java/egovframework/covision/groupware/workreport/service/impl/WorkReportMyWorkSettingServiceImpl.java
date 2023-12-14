package egovframework.covision.groupware.workreport.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.workreport.service.WorkReportMyWorkSettingService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("MyWorkSettingService")
public class WorkReportMyWorkSettingServiceImpl extends EgovAbstractServiceImpl implements WorkReportMyWorkSettingService {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public String setMyWorkList(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		String resultMsg = "FAIL";
		int cnt = 0;
		// 등록 전 중복검사
		cnt = (int)coviMapperOne.getNumber("groupware.workreport.duplicateOSGrade", params);
		// 중복검사 성공 시 등록
		if(cnt == 0) {
			coviMapperOne.insert("groupware.workreport.insertOSGrade", params);
			resultMsg = "OK";
		} else {
			resultMsg = "EXIST";
		}
		
		return resultMsg;
	}
	
	@Override
	public CoviMap selectMyWorkDivision(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		int cnt = 0;
			
		cnt = (int)coviMapperOne.getNumber("groupware.admin.workreport.countWorkDivision",params);
		list = coviMapperOne.list("groupware.admin.workreport.listWorkDivision",params);

		resultList.put("cnt", cnt);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "divisionCode,displayName"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectMyWorkProject(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		int cnt = 0;
			
		cnt = (int)coviMapperOne.getNumber("groupware.admin.workreport.countWorkJob",params);
		list = coviMapperOne.list("groupware.admin.workreport.listWorkJob",params);
		
		resultList.put("cnt", cnt);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "JobID,JobName,JobDivision"));

		return resultList;
	}
	
	@Override
	public CoviMap selectMyWorkMyJob(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		list = coviMapperOne.list("groupware.admin.workreport.listWorkMyJob",params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UR_Code,JobID,JobName,JobDivision,TypeCode,DisplayName"));

		return resultList;
	}
	
	@Override
	public CoviMap setMyJob(CoviMap params) throws Exception {
		

		if(params.get("newcode") != null)
		{
			coviMapperOne.insert("groupware.admin.workreport.insertMyJob", params);
		}
		if(params.get("delcode") != null)
		{
			coviMapperOne.delete("groupware.admin.workreport.deleteMyJob", params);
		}
		
		// 결과 반환 - 여기까지 오류가 없었으면 정상진행
		CoviMap result = new CoviMap();
		result.put("result", "success");
		return result;
	}
	
	@Override
	public CoviMap selectCategory(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		
		list = coviMapperOne.list("groupware.admin.workreport.listWorkJobCategory",params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "typeCode,displayName,DivisionCode"));

		return resultList;
	}
}
