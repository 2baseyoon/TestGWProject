package egovframework.covision.groupware.collab.user.service.impl;
import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.collab.user.service.CollabReportSvc;

@Service("CollabReportSvc")
public class CollabReportSvcImpl extends EgovAbstractServiceImpl implements CollabReportSvc {

    @Resource(name="coviMapperOne")
    private CoviMapperOne coviMapperOne;

    private String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N");

    /**
     * @param params
     * @return List<CoviMap> Task 리스트
     * @throws Exception
     */
    @Override
    public List<CoviMap> getUserTaskDayList(CoviMap params) throws Exception {
        return coviMapperOne.selectList("collab.report.getUserTaskDayList", params);
    }

    /**
     * @param params
     * @return int Task 리스트 count
     * @throws Exception
     */
    @Override
    public int getUserTaskDayListCnt(CoviMap params) throws Exception {
        return (int) coviMapperOne.getNumber("collab.report.getUserTaskDayListCnt", params);
    }

    /**
     * @param params
     * @return List<CoviMap> 일일업무보고 리스트
     * @throws Exception
     */
    @Override
    public List<CoviMap> getUserCollabReportDayList(CoviMap params) throws Exception {
        return coviMapperOne.selectList("collab.report.getUserCollabReportDayList", params);
    }

    /**
     * @param params
     * @return int 일일업무보고 리스트 count
     * @throws Exception
     */
    @Override
    public int getUserCollabReportDayListCnt(CoviMap params) throws Exception {
        return (int) coviMapperOne.getNumber("collab.report.getUserCollabReportDayListCnt", params);
    }

    /**
     * @param params
     * @return CoviMap 일일업무보고 상세
     * @throws Exception
     */
    @Override
    public CoviMap getUserCollabReportDay(CoviMap params) throws Exception {
        return coviMapperOne.selectOne("collab.report.getUserCollabReportDay", params);
    }

    /**
     * @param params
     * @return int 일일업무보고 등록
     * @throws Exception
     */
    @Override
    public int insertUserCollabReportDay(CoviMap params) throws Exception {
        return coviMapperOne.insert("collab.report.insertUserCollabReportDay", params);
    }

    /**
     * @param params
     * @return int 일일업무보고 수정
     * @throws Exception
     */
    @Override
    public int updateUserCollabReportDay(CoviMap params) throws Exception {
        return coviMapperOne.update("collab.report.updateUserCollabReportDay", params);
    }

    /**
     * @param params
     * @return int 일일업무보고 삭제
     * @throws Exception
     */
    @Override
    public int deleteUserCollabReportDay(CoviMap params) throws Exception {
        return coviMapperOne.delete("collab.report.deleteUserCollabReportDay", params);
    }

    /**
     * @param params
     * @return List<CoviMap> 주간업무보고 프로젝트 리스트
     * @throws Exception
     */
    @Override
    public List<CoviMap> getUserCollabReportWeekProjectList(CoviMap params) throws Exception {
        return coviMapperOne.selectList("collab.report.getUserCollabReportWeekProjectList", params);
    }

    /**
     * @param params
     * @return List<CoviMap> 주간업무보고 리스트
     * @throws Exception
     */
    @Override
    public List<CoviMap> getUserCollabReportWeekList(CoviMap params) throws Exception {
        return coviMapperOne.selectList("collab.report.getUserCollabReportWeekList", params);
    }

    /**
     * @param params
     * @return int 주간업무보고 리스트 count
     * @throws Exception
     */
    @Override
    public int getUserCollabReportWeekListCnt(CoviMap params) throws Exception {
        return (int) coviMapperOne.getNumber("collab.report.getUserCollabReportWeekListCnt", params);
    }

    /**
     * @param params
     * @return CoviMap 주간업무보고 상세
     * @throws Exception
     */
    @Override
    public CoviMap getUserCollabReportWeek(CoviMap params) throws Exception {
        return coviMapperOne.selectOne("collab.report.getUserCollabReportWeek", params);
    }

    /**
     * @param params
     * @return int 주간업무보고 등록
     * @throws Exception
     */
    @Override
    public int insertUserCollabReportWeek(CoviMap params) throws Exception {
        return coviMapperOne.insert("collab.report.insertUserCollabReportWeek", params);
    }

    /**
     * @param params
     * @return int 주간업무보고 수정
     * @throws Exception
     */
    @Override
    public int updateUserCollabReportWeek(CoviMap params) throws Exception {
        return coviMapperOne.update("collab.report.updateUserCollabReportWeek", params);
    }

    /**
     * @param params
     * @return int 주간업무보고 삭제
     * @throws Exception
     */
    @Override
    public int deleteUserCollabReportWeek(CoviMap params) throws Exception {
        return coviMapperOne.delete("collab.report.deleteUserCollabReportWeek", params);
    }

    /**
     * @param params
     * @return List<CoviMap> 일일업무보고 리스트
     * @throws Exception
     */
    @Override
    public List<CoviMap> getProjectReportDayList(CoviMap params) throws Exception {
        return coviMapperOne.selectList("collab.report.getProjectReportDayList", params);
    }

    /**
     * @param params
     * @return int 일일업무보고 리스트 count
     * @throws Exception
     
    @Override
    public int getProjectReportDayListCnt(CoviMap params) throws Exception {
        return (int) coviMapperOne.getNumber("collab.report.getProjectReportDayListCnt", params);
    }

    @Override
    public int getProjectReportWeekListCnt(CoviMap params) throws Exception {
        return (int) coviMapperOne.getNumber("collab.report.getProjectReportWeekListCnt", params);
    }
    
    */
    /**
     * @param params
     * @return List<CoviMap> 일일업무보고 리스트
     * @throws Exception
     */
    @Override
    public CoviMap getProjectReportWeekList(CoviMap params) throws Exception {
    	CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		if(params.containsKey("pageNo")) {
 			int cnt = 10; //collabReportSvc.getProjectReportDayListCnt(params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 		}
		
		CoviList list = coviMapperOne.list("collab.report.getProjectReportWeekList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,MultiDisplayName,UserName,ReportSeq,WeekRemark,NextPlan,StartDate,EndDate,ReporterCode,PrjType,PrjSeq"));
		
		return resultList;
    }
    
}