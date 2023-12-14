package egovframework.covision.groupware.collab.user.service;

import egovframework.baseframework.data.CoviMap;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;


public interface CollabHistSvc {
	CoviMap getTaskHistList(CoviMap params) throws Exception;
}
