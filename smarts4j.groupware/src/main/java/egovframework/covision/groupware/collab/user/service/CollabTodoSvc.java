package egovframework.covision.groupware.collab.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

public interface CollabTodoSvc {

    //상단 업무 통계
	CoviMap myTaskStat(Map<String, Object> params);

    CoviList tag(Map<String, Object> params);

    //나의업무 오더순위 변경
    String orderUpd(Map<String,Object> params) throws IOException;
    //void jobListDummy();
}
