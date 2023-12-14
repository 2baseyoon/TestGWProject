package egovframework.covision.groupware.workreport.service.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.workreport.service.WorkReportOSManageService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("WorkReportOSManageService")
public class WorkReportOSManageServiceImpl extends EgovAbstractServiceImpl implements WorkReportOSManageService {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	
	@Override
	public CoviMap selectOutSourcing(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
 		
		if(params.containsKey("pageNo")) {
		 	int cnt = (int)coviMapperOne.getNumber("groupware.admin.workreport.countOutsourcing", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
			resultList.put("page", page);
			resultList.put("cnt", cnt);
		}
		
		CoviList list = null;
		list = coviMapperOne.list("groupware.admin.workreport.selectOutsourcing", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "OUR_Code,Name,GradeKind,FirstCode,FirstName,WorkSubject"));
		
		return resultList;
	}
	
	@Override
	public CoviMap setOutSourcing(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		int cnt = 0;
		String strMode = params.get("mode").toString();


		if(strMode.equals("Reg")){
			coviMapperOne.insert("groupware.admin.workreport.insertOutSourcing", params);
		}
		else if(strMode.equals("Edit")){
			coviMapperOne.update("groupware.admin.workreport.updateOutSourcing", params);
		}
		
		// 결과 반환 - 여기까지 오류가 없었으면 정상진행
		CoviMap result = new CoviMap();
		result.put("result", "success");
		return result;
	}
	
	@Override
	public CoviMap selectOSGrade(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;

		list = coviMapperOne.list("groupware.admin.workreport.selectOSGrade", params);
	
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GradeID,MemberType,GradeKind"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectOurSourcingDetail(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;

		list = coviMapperOne.list("groupware.admin.workreport.selectOurSourcingDetail", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "OUR_Code,Name,Age,GradeKind,RegistCode,WorkSubject,FirstCode,FirstName,SecondCode,SecondName,Role,ContractStartDate,ContractEndDate,ContractState,Seq,ExProjectYN"));
		
		return resultList;
	}
	
	@Override
	public int deleteOutSourcing(CoviMap params) throws Exception {
		return coviMapperOne.delete("groupware.admin.workreport.deleteOutsourcing", params);
	}
	
	@Override
	public CoviList selectOSCalendarInfo(CoviMap params) throws Exception {
		return CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.workreport.selectOSCalendarInfo", params)
				, "CalID,Year,Month,Day,WeekOfMonth,StartDate,EndDate,WorkReportID,UR_Code");
	}
	
	@Override
	public CoviMap selectOutSourcingManage(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
 		
		if(params.containsKey("pageNo")) {
		 	int cnt = (int)coviMapperOne.getNumber("groupware.admin.workreport.countOutsourcingManage", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
			resultList.put("page", page);
			resultList.put("cnt", cnt);
		}
		CoviList list = null;
		list = coviMapperOne.list("groupware.admin.workreport.selectOutsourcingManage", params);		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "OUR_Code,Name,Age,GradeKind,RegistCode,WorkSubject,FirstCode,FirstName,SecondCode,SecondName,Role,ContractStartDate,ContractEndDate,ContractState,Seq,ExProjectYN"));
		
		return resultList;
	}
}
