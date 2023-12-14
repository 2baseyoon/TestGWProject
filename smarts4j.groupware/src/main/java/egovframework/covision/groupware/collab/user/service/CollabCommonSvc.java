package egovframework.covision.groupware.collab.user.service;

import egovframework.baseframework.data.CoviMap;

import egovframework.baseframework.data.CoviList;


public interface CollabCommonSvc {
	//boardType: 나의 게시 하위 메뉴 게시판 항목
	CoviMap getUserProject(CoviMap params) throws Exception;
	String getUserAuthType() throws Exception;
	CoviList getDeptListByAuth() throws Exception;
}
