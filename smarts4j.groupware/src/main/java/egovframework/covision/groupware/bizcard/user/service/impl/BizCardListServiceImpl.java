package egovframework.covision.groupware.bizcard.user.service.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.bizcard.user.service.BizCardListService;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BizCardListService")
public class BizCardListServiceImpl extends EgovAbstractServiceImpl implements BizCardListService{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectBizCardFavoriteList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardFavoriteListCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			returnObj.put("page", page);
 			returnObj.put("cnt", cnt);
 		}
		
		CoviList selList = coviMapperOne.list("groupware.bizcard.selectBizCardFavoriteList", params);		
		returnObj.put("list", CoviSelectSet.coviSelectJSON(selList, "BizCardType,BizCardID,Name,PhoneNum,HomePhoneNum,EMAIL,ComName,ComPhoneNum,FaxNum,EtcNum,DirectNum,PhoneName,JobTitle,ShareType,IsFavorite,Date,ImagePath,DeptName,RegisterID"));
		
		return returnObj;
	}
	
	@Override
	public CoviMap selectBizCardPersonList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList listData = null;
		
		if(params.containsKey("pageNo")) {
			int cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardPersonListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
		 	returnObj.put("cnt", cnt);
		}
		
		listData = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.bizcard.selectBizCardPersonList", params), "BizCardType,BizCardID,Name,PhoneNum,HomePhoneNum,EMAIL,ComName,ComPhoneNum,FaxNum,EtcNum,DirectNum,PhoneName,JobTitle,IsFavorite,Date,ShareType,ImagePath,DeptName");		
		returnObj.put("list", listData);
		
		return returnObj;
	}
	
	@Override
	public CoviMap selectBizCardCompanyList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList listData = null;
		
		if(params.containsKey("pageNo")) {
			int cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardCompanyListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
		 	returnObj.put("cnt", cnt);
		}
		
		listData = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.bizcard.selectBizCardCompanyList", params), "BizCardID,GroupID,ComName,ComRepName,EMAIL,PhoneNum,ComAddress,Date,ImagePath");
		returnObj.put("list", listData);
		
		return returnObj;
	}
	
	@Override
	public CoviMap getCallFuncDivList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviList resultList = null;
		long resultCnt = coviMapperOne.getNumber("groupware.bizcard.selectCallFuncDivCnt", params);
		resultList = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.bizcard.selectCallFuncDivList", params), "code,name,refcnt");
		returnObj.put("list", resultList);
		returnObj.put("cnt", resultCnt);
		
		return returnObj;
	}

	@Override
	public int relocateBizCardList(CoviMap params) throws Exception {
		int cnt = 0;
		String[] bizCardIDs = (String[]) params.get("BizCardID");
		
		for(String bizCardID : bizCardIDs) {
			params.put("BizCardID", bizCardID);
			coviMapperOne.insert("groupware.bizcard.insertBizCardList", params);
			
			//핸드폰 데이터 존재시, insert
			cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardPhoneCnt", params);
			if(cnt > 0){
				cnt = coviMapperOne.insert("groupware.bizcard.insertBizCardPhoneList", params);
			}	
			//이메일 데이터 존재시, insert
			cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardEmailCnt", params);
			if(cnt > 0){
				cnt = coviMapperOne.insert("groupware.bizcard.insertBizCardEmailList", params);
			}
			//기념일 데이터 존재시, insert
			cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardAnniverCnt", params);
			if(cnt > 0){
				cnt = coviMapperOne.insert("groupware.bizcard.insertBizCardAnniverList", params);
			}
			//즐겨찾기 데이터 존재시, insert
			cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardFavoriteCnt", params);
			if(cnt > 0){
				cnt = coviMapperOne.insert("groupware.bizcard.insertBizCardFavoriteList", params);
			}
		}
		
		if(params.get("Mode").toString().equalsIgnoreCase("M")){
			params.put("BizCardID", bizCardIDs);
			cnt = delete(params);
		}
		return cnt;
	}

	@Override
	public int delete(CoviMap params) throws Exception {
		int cnt = 0;

		cnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardList", params);
		if(!params.get("TypeCode").toString().equalsIgnoreCase("C")){
			cnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardFav", params);
		}
		cnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardPhoneList", params);
		cnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardEmailList", params);
		cnt = coviMapperOne.delete("groupware.bizcard.deleteBizCardAnniversaryList", params);

		return cnt;
	}
	
	@Override
	public int deleteOne(CoviMap params) throws Exception {
		int cnt = 0;

		cnt = (int)coviMapperOne.delete("groupware.bizcard.deleteBizCardOne", params);
		if(!params.get("TypeCode").toString().equalsIgnoreCase("C")){
			cnt = (int)coviMapperOne.delete("groupware.bizcard.deleteBizCardFavOne", params);
		}
		cnt = (int)coviMapperOne.delete("groupware.bizcard.deleteBizCardPhoneOne", params);
		cnt = (int)coviMapperOne.delete("groupware.bizcard.deleteBizCardEmailOne", params);
		cnt = (int)coviMapperOne.delete("groupware.bizcard.deleteBizCardAnniversaryOne", params);

		return cnt;
	}
	
	@Override
	public int deleteGroupOne(CoviMap params) throws Exception {
		return (int)coviMapperOne.delete("groupware.bizcard.deleteBizCardGroupOne", params);
	}
	@Override
	public int deleteGroup(CoviMap params) throws Exception {
		return (int)coviMapperOne.delete("groupware.bizcard.deleteBizCardGroup", params);
	}

	@Override
	public int insertIntoFavoriteList(CoviMap params) throws Exception {
		return (int)coviMapperOne.insert("groupware.bizcard.insertIntoFavoriteList", params);
	}
	
	@Override
	public int deleteFromFavoriteList(CoviMap params) throws Exception {
		return (int)coviMapperOne.delete("groupware.bizcard.deleteFromFavoriteList", params);
	}
	@Override
	public CoviMap selectBizCardAllList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList listData = null;
 		
		if(params.containsKey("pageNo")) {
			int cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardAllListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
		 	returnObj.put("cnt", cnt);
		}
		
		listData = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.bizcard.selectBizCardAllList", params), "BizCardType,BizCardID,Name,OrderNo,PhoneNum,HomePhoneNum,EMAIL,ComName,ComPhoneNum,FaxNum,EtcNum,DirectNum,PhoneName,JobTitle,IsFavorite,MemberCnt,Date,ShareType,ImagePath,DeptName,RegisterID,RegisterName,RegistDate");
		returnObj.put("list", listData);
		
		return returnObj;
	}
	@Override
	public CoviMap selectBizCardGroupList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList listData = null;
 		
		if(params.containsKey("pageNo")) {
			int cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardGroupListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
		 	returnObj.put("cnt", cnt);
		}
		
		listData = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.bizcard.selectBizCardGroupList", params), "BizCardType,ShareType,GroupID,Groupname,OrderNo,MemberCnt,Date");		
		returnObj.put("list", listData);
		
		return returnObj;
	}

	@Override
	public CoviMap selectBizCardExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		String sField = ""; // 항목 설정
		CoviList list = null;
		int cnt = 0;
		
		if(params.get("shareType").toString().equalsIgnoreCase("C")){
			sField = "ComName,ComRepName,EMAIL,PhoneNum,ComAddress";
			list = CoviSelectSet.coviSelectJSON(coviMapperOne.list("selectBizCardCompanyList",params), sField);
			cnt = (int) coviMapperOne.getNumber("selectBizCardCompanyListCnt", params);
		} else if(params.get("shareType").toString().equalsIgnoreCase("F")){
			sField = "IsFavorite,Name,PhoneNum,EMAIL,ComName,ComPhoneNum,JobTitle,ShareType";
			list = CoviSelectSet.coviSelectJSON(coviMapperOne.list("selectBizCardFavoriteList",params), sField);
			cnt = (int) coviMapperOne.getNumber("selectBizCardFavoriteListCnt", params);
		} else { //P(개인), D(부서), U(회사), A(전체) 
			sField = "IsFavorite,Name,PhoneNum,EMAIL,ComName,ComPhoneNum,JobTitle,ShareType";
			list = CoviSelectSet.coviSelectJSON(coviMapperOne.list("selectBizCardPersonList",params), sField);
			cnt = (int) coviMapperOne.getNumber("selectBizCardPersonListCnt", params);
		}
		
		resultList.put("list", list);
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	@Override
	public CoviMap selectBizCardGroupMemberList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
		
		CoviList listDataMember = null;
		int cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardGroupMemberListCnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		listDataMember = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.bizcard.selectBizCardGroupMemberList", params), "BizCardType,GroupID,Name,EMAIL");

		returnObj.put("page", page);
		returnObj.put("listMember", listDataMember);
		
		return returnObj;					
	}
	
	@Override
	public CoviMap selectBizCardOrgMapList(CoviMap params) throws Exception {
		CoviMap returnObj = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList listData = null;
		CoviList listDataMember = null;
		
		if(params.containsKey("pageNo")) {
			int cnt = (int)coviMapperOne.getNumber("groupware.bizcard.selectBizCardOrgMapListCnt", params);
		 	page = ComUtils.setPagingData(params,cnt);
		 	params.addAll(page);
		 	returnObj.put("page", page);
		 	returnObj.put("cnt", cnt);
		}
		
		listData = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.bizcard.selectBizCardOrgMapList", params), "BizCardType,ShareType,ID,Name,DeptName,Email");

		if(params.get("itemType").toString().equalsIgnoreCase("GR") && listData.size() > 0){
			String groupIDs = "";
			StringBuffer buf = new StringBuffer();
			for (int i = 0; i < listData.size(); i++)
			{
				buf.append(listData.getJSONObject(i).getString("ID")).append(",");
			}
			groupIDs = buf.toString();
			CoviMap params2 = new CoviMap();
			params2.put("groupIDs", groupIDs.split(","));
			params2.put("hasEmail", params.get("hasEmail").toString());
		
			listDataMember = CoviSelectSet.coviSelectJSON(coviMapperOne.list("groupware.bizcard.selectBizCardOrgMapListGroupMember", params2), "GroupID,Name,Email,Type,UserID");
		}
		
		returnObj.put("list", listData);
		returnObj.put("listMember", listDataMember);
		
		return returnObj;
	}
}
