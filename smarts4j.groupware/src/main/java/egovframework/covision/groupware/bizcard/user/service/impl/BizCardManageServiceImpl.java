package egovframework.covision.groupware.bizcard.user.service.impl;

import java.util.List;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.bizcard.user.service.BizCardManageService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BizCardManageService")
public class BizCardManageServiceImpl extends EgovAbstractServiceImpl implements BizCardManageService {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	//명함 등록, 수정, 조회
	@Override
	public CoviMap insertBizCardPerson(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("groupware.bizcard.insertBizCardPerson", params);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap updateBizCardPerson(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.update("groupware.bizcard.updateBizCardPerson", params);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap selectBizCardPerson(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.bizcard.selectBizCardPerson", params);
		CoviMap result = new CoviMap();
		result.put("person", CoviSelectSet.coviSelectJSON(list, "ImagePath,Name,ShareType,GroupID,MessengerID,CompanyId,DeptName,JobTitle,Memo,CompanyName,AnniversaryText,RegisterID"));
		return result;
	}
	
	@Override
	public CoviMap selectBizCardPersonView(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.bizcard.selectBizCardPersonView", params);
		CoviMap result = new CoviMap();
		result.put("person", CoviSelectSet.coviSelectJSON(list, "ImagePath,Name,DeptName,JobTitle,Memo,MessengerID,CompanyName,AnniversaryText,CellPhone,TelPhone,Email"));
		return result;
	}
	
	//업체 등록, 수정, 조회
	@Override
	public CoviMap insertBizCardCompany(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("groupware.bizcard.insertBizCardCompany", params);
		
		if(returnCnt == 1) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap updateBizCardCompany(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.update("groupware.bizcard.updateBizCardCompany", params);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap selectBizCardCompanyCnt(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.bizcard.selectBizCardCompanyCnt", params);
		CoviMap result = new CoviMap();
		result.put("company", CoviSelectSet.coviSelectJSON(list, "Cnt,BizCardID"));
		return result;
	}
	
	@Override
	public CoviMap selectBizCardCompany(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.bizcard.selectBizCardCompany", params);
		CoviMap result = new CoviMap();
		result.put("company", CoviSelectSet.coviSelectJSON(list, "ImagePath,GroupID,ComName,ComRepName,ComZipCode,ComAddress,ComWebSite,Memo,AnniversaryText"));
		return result;
	}
	
	@Override
	public CoviMap selectBizCardCompanyView(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.bizcard.selectBizCardCompanyView", params);
		CoviMap result = new CoviMap();
		result.put("company", CoviSelectSet.coviSelectJSON(list, "ImagePath,ComName,ComZipCode,ComAddress,Memo,ComWebSite,AnniversaryText,TelPhone,FAX,Email"));
		return result;
	}
	
	
	//전화, 이메일, 기념일 등록, 수정, 조회
	@Override
	public CoviMap selectBizCardPhone(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.bizcard.selectBizCardPhone", params);
		CoviMap result = new CoviMap();
		result.put("list", CoviSelectSet.coviSelectJSON(list, "SeqID,PhoneType,PhoneNumber,PhoneName"));
		return result;
	}
	
	@Override
	public CoviMap selectBizCardEmail(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("groupware.bizcard.selectBizCardEmail", params);
		CoviMap result = new CoviMap();
		result.put("list", CoviSelectSet.coviSelectJSON(list, "SeqID,Email"));
		return result;
	}
	
	@Override
	public CoviMap insertBizCardPhone(List<CoviMap> phoneList) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("groupware.bizcard.insertBizCardPhone", phoneList);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap insertBizCardEmail(List<CoviMap> emailList) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("groupware.bizcard.insertBizCardEmail", emailList);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap insertBizCardAnniversary(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("groupware.bizcard.insertBizCardAnniversary", params);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap deleteBizCardPhone(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardPhone", params);
		
		if(returnCnt == 1) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap deleteBizCardEmail(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardEmail", params);
		
		if(returnCnt == 1) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap deleteBizCardAnniversary(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardAnniversary", params);
		
		if(returnCnt == 1) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	/*@Override
	public CoviMap updateBizCardPhone(List<CoviMap> phoneList) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.update("groupware.bizcard.updateBizCardPhone", phoneList);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap updateBizCardEmail(List<CoviMap> emailList) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.update("groupware.bizcard.updateBizCardEmail", emailList);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap updateBizCardAnniversary(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.update("groupware.bizcard.updateBizCardAnniversary", params);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}*/	
	
	@Override
	public CoviMap updateBizCardImagePath(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("groupware.bizcard.updateBizCardImagePath", params);
		
		if(returnCnt == 1) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	@Override
	public CoviMap deleteBizCard(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.delete("groupware.bizcard.deleteBizCard", params);
		
		if(returnCnt == 1) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}

	
	@Override
	public CoviMap selectBizCardSimilarList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
		
		CoviList listData = null;

		if(params.containsKey("pageNo")) {
			int cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardSimilarListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
		 	returnObj.put("cnt", cnt);
		}
		
		listData = coviMapperOne.list("groupware.bizcard.selectBizCardSimilarList", params);
		returnObj.put("list", CoviSelectSet.coviSelectJSON(listData, "BizCardID,Name,CompanyID,JobTitle,ShareType,RegisterID,RegDeptCode,RegComCode,ComName,PhoneNum,EMAIL,Target,ImagePath"));
		
		return returnObj;
	}
	
	@Override
	public int orgainizeBizCard(CoviMap params) throws Exception {
		int cnt = 0;
		
		//bizCard List 삭제
		cnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardList", params); 
		cnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardFav", params);
		cnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardPhoneList", params);
		cnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardEmailList", params);
		
		//bizCard 정보 변경
		if(params.get("PhoneChkY") != null){
			cnt = coviMapperOne.insert("groupware.bizcard.insertOrganizationBizCardPhone", params);
		}
		if(params.get("EmailChkY") != null){
			cnt = coviMapperOne.update("groupware.bizcard.insertOrganizationBizCardEmail", params);
		}
		
		return cnt;
	}
}
