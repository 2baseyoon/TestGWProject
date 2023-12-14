package egovframework.covision.groupware.collab.user.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.covision.groupware.collab.user.service.CollabTodoSvc;
import egovframework.covision.groupware.collab.user.web.CollabTodoCon;

@Service("CollabTodoSvc")
public class CollabTodoSvcImpl extends EgovAbstractServiceImpl implements CollabTodoSvc {

    @Resource(name="coviMapperOne")
    private CoviMapperOne coviMapperOne;

    private Logger logger = LogManager.getLogger(CollabTodoCon.class);

    // 나중에 공통 메세지 프로퍼티로 변경
    private String result ="관리자에게 문의 하세요.";

    @Override
    public CoviMap myTaskStat(Map<String, Object> params) {
        CoviMap coviMap = putCoviMap(params);
        return coviMapperOne.select("collab.todo.myTaskCnt", coviMap);
    }

    @Override
    public CoviList tag(Map<String, Object> params) {
        CoviMap coviMap = putCoviMap(params);
        coviMap.put("lang", SessionHelper.getSession("lang"));
        
        CoviList resultList = coviMapperOne.list("collab.todo.tag", coviMap);
        CoviList returnList = new CoviList();
        
        for(int i=0; i<resultList.size(); i++) {
        	CoviMap tagMap = resultList.getMap(i);
        	tagMap.put("TagName", DicHelper.getDic("COLLAB_TAG_" + tagMap.getString("TagSeq")));
        	
        	returnList.add(tagMap);
        }
        
        
        return returnList;
    }

    @Override
    public String orderUpd(Map<String, Object> params) {

        try {
            List<Map<String,Object>> paramMap = new ObjectMapper().readValue(params.get("list").toString(), new TypeReference<List<Map<String,Object>>>() {
            });
            CoviMap coviMap = putCoviMap();
            coviMap.put("list",paramMap);
            coviMapperOne.update("orderUpd", coviMap);
            result = "변경되었습니다.";
            return result;
        } catch (NullPointerException e) {
        	logger.error(e.getLocalizedMessage(), e);
        	return result;
        } catch (Exception e) {
        	logger.error(e.getLocalizedMessage(), e);
        	return result;
        }
    }

    private CoviMap putCoviMap(Map<String, Object> params) {
        params.put("userCode", SessionHelper.getSession("USERID"));
        params.put("companyCode", SessionHelper.getSession("DN_Code"));
        params.put("lang", SessionHelper.getSession("lang"));
        CoviMap coviMap = new CoviMap();
        coviMap.addAll(params);
        return coviMap;
    }

    private CoviMap putCoviMap() {
        CoviMap coviMap = new CoviMap();
        coviMap.put("userCode", SessionHelper.getSession("USERID"));
        coviMap.put("companyCode", SessionHelper.getSession("DN_Code"));
        coviMap.put("lang", SessionHelper.getSession("lang"));
        return coviMap;
    }


//    public void myTaskListDummy(){
//        CoviMap map = new CoviMap();
//        for(int i = 5 ; i < 7 ; i ++){
//            map.put("a",i);
//            map.put("b",'T');
//            coviMapperOne.insert("collab.todo.dummy3",map);addProjectTaskManager
//        }
//        map.put("c","");
//        map.put("d","");
//        map.put("e","");
//        map.put("f","");
//        map.put("g","");
//        map.put("h","");

        //    coviMapperOne.insert("collab.todo.dummy2",map);
//    }
}
