package egovframework.covision.groupware.collab.user.service;

import egovframework.baseframework.data.CoviMap;

import java.util.List;

public interface CollabTmplSvc {

    //상단 업무 통계
	CoviMap getTmplRequestList(CoviMap params) throws Exception;
	CoviMap approvalTmplRequest (CoviMap reqMap, List objList)  throws Exception;
	CoviMap rejectTmplRequest (CoviMap reqMap, List objList)  throws Exception;
	CoviMap deleteTmplRequest (CoviMap reqMap, List objList)  throws Exception;
	CoviMap getTmplList (CoviMap reqMap)  throws Exception;
	CoviMap getTmplMain(CoviMap params) throws Exception;
	
	int changeTmplTaskOrder(CoviMap params, List ordTask) throws Exception;

	CoviMap addTmplSection(CoviMap params) throws Exception;
	CoviMap saveTmplSection(CoviMap params) throws Exception;
	int deleteTmplSection(CoviMap params) throws Exception;
	int deleteTmpl(CoviMap params) throws Exception;

	int addTmplTask(CoviMap params) throws Exception;
	int deleteTmplTask(CoviMap params) throws Exception;
	int saveTmplTask(CoviMap params) throws Exception;

	int copyTmplTask(CoviMap params) throws Exception ;
	CoviMap getTmplTask(CoviMap params) throws Exception ;

}
