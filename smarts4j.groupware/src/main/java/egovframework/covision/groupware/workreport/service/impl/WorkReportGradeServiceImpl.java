package egovframework.covision.groupware.workreport.service.impl;

import java.util.List;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.workreport.service.WorkReportGradeService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("WorkReportGradeService")
public class WorkReportGradeServiceImpl extends EgovAbstractServiceImpl implements WorkReportGradeService {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public String insertOutSourcingGrade(CoviMap params) throws Exception {
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
	public CoviMap selectOutSourcingGrade(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		int cnt = 0;
		
		cnt = (int)coviMapperOne.getNumber("groupware.workreport.countOSGrade", params);
		list = coviMapperOne.list("groupware.workreport.listOSGrade", params);
		
		resultList.put("cnt", cnt);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GradeID,ApplyYear,MemberType,GradeKind,MonthPrice,DayPrice,MonthPriceEx,GradeSeq"));
		
		return resultList;
	}
	
	@Override
	public int deleteOutSourcingGrade(CoviMap params) throws Exception {
		return coviMapperOne.delete("groupware.workreport.deleteOSGrade", params);
	}
	
	@Override
	public int modifyOutSourcingGrade(List<CoviMap> paramList) throws Exception {
		int totalCnt = 0;
		
		for(CoviMap param : paramList) {
			totalCnt += coviMapperOne.update("groupware.workreport.updateOSGrade", param);
		}
		
		return totalCnt;
	}
	
	@Override
	public int reuseOutSourcingGrade(CoviMap params) throws Exception {
		return coviMapperOne.insert("groupware.workreport.reuseOSGrade", params);
	}
	
	
	// 정직원-------------------------------
	@Override
	public CoviMap selectRegularGrade(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		CoviMap resultList = new CoviMap();
		CoviList list = null;
		int cnt = 0;
		
		cnt = (int)coviMapperOne.getNumber("groupware.admin.workreport.countRegGrade", params);
		list = coviMapperOne.list("groupware.admin.workreport.listRegGrade", params);
		
		resultList.put("cnt", cnt);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GradeID,ApplyYear,MemberType,GradeKind,MonthPrice,DayPrice,MonthPriceEx,GradeSeq"));
		
		return resultList;
	}
	
	@Override
	public int reuseRegularGrade(CoviMap params) throws Exception {
		return coviMapperOne.insert("groupware.admin.workreport.reuseRegGrade", params);
	}
	
	@Override
	public int deleteRegularGrade(CoviMap params) throws Exception {
		return coviMapperOne.delete("groupware.admin.workreport.deleteRegGrade", params);
	}
	
	@Override
	public int modifyRegularGrade(List<CoviMap> paramList) throws Exception {
		int totalCnt = 0;
		
		for(CoviMap param : paramList) {
			totalCnt += coviMapperOne.update("groupware.admin.workreport.updateRegGrade", param);
		}
		
		return totalCnt;
	}
	
	@Override
	public String insertRegularGrade(CoviMap params) throws Exception {
		// TODO Auto-generated method stub
		String resultMsg = "FAIL";
		int cnt = 0;
		// 등록 전 중복검사
		cnt = (int)coviMapperOne.getNumber("groupware.admin.workreport.duplicateRegGrade", params);
		// 중복검사 성공 시 등록
		if(cnt == 0) {
			coviMapperOne.insert("groupware.admin.workreport.insertRegGrade", params);
			resultMsg = "OK";
		} else {
			resultMsg = "EXIST";
		}
		
		return resultMsg;
	}
}
