package egovframework.covision.groupware.collab.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

import java.util.List;



public interface CollabReportSvc {

    List<CoviMap> getUserTaskDayList(CoviMap params) throws Exception;
    int getUserTaskDayListCnt(CoviMap params) throws Exception;
    List<CoviMap> getUserCollabReportDayList(CoviMap params) throws Exception;
    int getUserCollabReportDayListCnt(CoviMap params) throws Exception;
    CoviMap getUserCollabReportDay(CoviMap params) throws Exception;

    int insertUserCollabReportDay(CoviMap params) throws Exception;
    int updateUserCollabReportDay(CoviMap params) throws Exception;
    int deleteUserCollabReportDay(CoviMap params) throws Exception;

    List<CoviMap> getUserCollabReportWeekProjectList(CoviMap params) throws Exception;
    List<CoviMap> getUserCollabReportWeekList(CoviMap params) throws Exception;
    int getUserCollabReportWeekListCnt(CoviMap params) throws Exception;
    CoviMap getUserCollabReportWeek(CoviMap params) throws Exception;

    int insertUserCollabReportWeek(CoviMap params) throws Exception;
    int updateUserCollabReportWeek(CoviMap params) throws Exception;
    int deleteUserCollabReportWeek(CoviMap params) throws Exception;

    CoviMap getProjectReportWeekList(CoviMap params) throws Exception;
    
    List<CoviMap> getProjectReportDayList(CoviMap params) throws Exception;
//    int getProjectReportDayListCnt(CoviMap params) throws Exception;
//    int getProjectReportWeekListCnt(CoviMap params) throws Exception;
    
}
