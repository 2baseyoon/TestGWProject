package egovframework.covision.groupware.bizcard.user.service;

import java.util.List;

import egovframework.baseframework.data.CoviMap;


public interface BizCardManageService {
	//명함 등록
	public CoviMap insertBizCardPerson(CoviMap params) throws Exception;
	//명함 수정
	public CoviMap updateBizCardPerson(CoviMap params) throws Exception;
	//명함 조회
	public CoviMap selectBizCardPerson(CoviMap params) throws Exception;
	//명함 카드보기(간략조회)
	public CoviMap selectBizCardPersonView(CoviMap params) throws Exception;
	
	//업체 등록
	public CoviMap insertBizCardCompany(CoviMap params) throws Exception;
	//업체 수정
	public CoviMap updateBizCardCompany(CoviMap params) throws Exception;
	//업체 조회
	public CoviMap selectBizCardCompany(CoviMap params) throws Exception;
	//업체 카드보기(간략조회)
	public CoviMap selectBizCardCompanyView(CoviMap params) throws Exception;
	//업체 존재 여부 조회(이름으로)
	public CoviMap selectBizCardCompanyCnt(CoviMap params) throws Exception;
	
	//전화 조회
	public CoviMap selectBizCardPhone(CoviMap params) throws Exception;
	//이메일 조회
	public CoviMap selectBizCardEmail(CoviMap params) throws Exception;
	
	//전화 등록
	public CoviMap insertBizCardPhone(List<CoviMap> phoneList) throws Exception;
	//이메일 등록
	public CoviMap insertBizCardEmail(List<CoviMap> emailList) throws Exception;
	//기념일 등록
	public CoviMap insertBizCardAnniversary(CoviMap params) throws Exception;
	
	/*//전화 수정
	public CoviMap updateBizCardPhone(List<CoviMap> phoneList) throws Exception;
	//이메일 수정
	public CoviMap updateBizCardEmail(List<CoviMap> emailList) throws Exception;
	//기념일 수정
	public CoviMap updateBizCardAnniversary(CoviMap params) throws Exception;*/
	
	//전화 삭제
	public CoviMap deleteBizCardPhone(CoviMap params) throws Exception;
	//이메일 삭제
	public CoviMap deleteBizCardEmail(CoviMap params) throws Exception;
	//기념일 삭제
	public CoviMap deleteBizCardAnniversary(CoviMap params) throws Exception;
	
	//이미지 경로 수정(등록)
	public CoviMap updateBizCardImagePath(CoviMap params) throws Exception;
	//연락처 삭제
	public CoviMap deleteBizCard(CoviMap params) throws Exception;
	
	
	//유사 목록 조회
	public CoviMap selectBizCardSimilarList(CoviMap params) throws Exception;
	//유사 목록 통합(삭제 및 생성)
	public int orgainizeBizCard(CoviMap params) throws Exception;
	
	
}