package egovframework.covision.groupware.collab.user.service;

import egovframework.baseframework.data.CoviMap;




public interface CollabStatisSvc {
	//boardType: 나의 게시 하위 메뉴 게시판 항목
	CoviMap getStatisList(CoviMap params) throws Exception;
	CoviMap getStatisCurst(CoviMap params) throws Exception ;
	CoviMap getStatisUserCurst(CoviMap params) throws Exception;
	CoviMap getStatisStatusCurst(CoviMap params) throws Exception;	
	CoviMap getStatisUserData(CoviMap params) throws Exception ;
	CoviMap getStatisTeamCurst(CoviMap params) throws Exception;
}
