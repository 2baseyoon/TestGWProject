package egovframework.covision.groupware.issueboard.user.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviMap;



public interface IssueMessageSvc {
	
	int uploadIssueMessage(CoviMap params, List<MultipartFile> mf) throws Exception;

	int selectNormalMessageGridCount(CoviMap params) throws Exception;

	CoviMap selectNormalMessageGridList(CoviMap params) throws Exception;

	CoviMap selectNormalMessageExcelList(CoviMap params) throws Exception;
	
	int createIssueMessage(CoviMap params, List<MultipartFile> mf) throws Exception;		//게시글 작성
	
	int updateIssueMessage(CoviMap params, List<MultipartFile> mf) throws Exception;		//게시글 수정
	
	CoviMap selectIssueMessageDetail(CoviMap params) throws Exception;		//게시물 상세보기 내용 조회
}
