package egovframework.coviaccount.user.service.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.StandardBriefSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("StandardBriefSvc")
public class StandardBriefSvcImpl extends EgovAbstractServiceImpl implements StandardBriefSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	/**
	 * @Method Name : getStandardBrieflist
	 * @Description : 표준적요 목록 조회
	 */
	@Override
	public CoviMap getStandardBrieflist(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		cnt		= (int) coviMapperOne.getNumber("account.standardBrief.getStandardBrieflistCnt" , params);
		
		page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list	= coviMapperOne.list("account.standardBrief.getStandardBriefList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getStandardBriefDetail
	 * @Description : 표준적요 상세 조회
	 */
	@Override
	public CoviMap getStandardBriefDetail(CoviMap params) throws Exception {

		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();

		list = coviMapperOne.list("account.standardBrief.getStandardBriefDetail",	params);
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		return resultList; 
	}
	
	/**
	 * @Method Name : saveStandardBriefInfo
	 * @Description : 표준적요 저장
	 */
	@Override
	public CoviMap saveStandardBriefInfo(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		ArrayList<Map<String, Object>> infoList	= (ArrayList<Map<String, Object>>) params.get("infoArr");
		ArrayList<Map<String, Object>> delList	= (ArrayList<Map<String, Object>>) params.get("delArr");
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		if(!infoList.isEmpty()){
			for(int i=0;i<infoList.size();i++){
				CoviMap infoListParam = new CoviMap(infoList.get(i));
				
				String standardBriefID		= infoListParam.get("standardBriefID")		== null ? "" : infoListParam.get("standardBriefID").toString();
				String standardBriefName	= infoListParam.get("standardBriefName")	== null ? "" : infoListParam.get("standardBriefName").toString();
				String standardBriefDesc	= infoListParam.get("standardBriefDesc")	== null ? "" : infoListParam.get("standardBriefDesc").toString();
				String isUse				= infoListParam.get("isUse")				== null ? "" : infoListParam.get("isUse").toString();
				String isUseSimp			= infoListParam.get("isUseSimp")			== null ? "" : infoListParam.get("isUseSimp").toString();
				String ctrlCode				= infoListParam.get("ctrlCode")				== null ? "" : infoListParam.get("ctrlCode").toString();
				String isfile				= infoListParam.get("isfile")				== null ? "" : infoListParam.get("isfile").toString();
				String isdocLink			= infoListParam.get("isdocLink")			== null ? "" : infoListParam.get("isdocLink").toString();
				
				params.put("standardBriefID",	standardBriefID);
				params.put("standardBriefName",	standardBriefName);
				params.put("standardBriefDesc",	standardBriefDesc);
				params.put("isUse",				isUse);
				params.put("isUseSimp",			isUseSimp);
				params.put("ctrlCode",			ctrlCode);
				params.put("isfile",			isfile);
				params.put("isdocLink",			isdocLink);
				
				if(standardBriefID.equals("")){
					insertStandardBriefInfo(params);
				}else{
					updateStandardBriefInfo(params);	
				}
			}
		}
		
		if(!delList.isEmpty()){
			for(int i=0;i<delList.size();i++){
				CoviMap delListParam = new CoviMap(delList.get(i));
				
				String standardBriefID	= delListParam.get("standardBriefID")	== null ? "" : delListParam.get("standardBriefID").toString();
				params.put("standardBriefID",	standardBriefID);
				deleteStandardBriefInfo(params);
			}
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : insertStandardBriefInfo
	 * @Description : 표준적요 Insert
	 */
	public void insertStandardBriefInfo(CoviMap params)throws Exception {
		coviMapperOne.insert("account.standardBrief.insertStandardBriefInfo", params);
	}
	
	/**
	 * @Method Name : updateStandardBriefInfo
	 * @Description : 표준적요 Update
	 */
	public void updateStandardBriefInfo(CoviMap params)throws Exception {
		coviMapperOne.update("account.standardBrief.updateStandardBriefInfo", params);
	}
	
	/**
	 * @Method Name : deleteStandardBriefInfoByAccountID
	 * @Description : 표준적요 삭제
	 */
	@Override
	public CoviMap deleteStandardBriefInfoByAccountID(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		
		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		if(!deleteStr.equals("")){
			String[] deleteArr = deleteStr.split(",");
			for(int i = 0; i < deleteArr.length; i++){
				CoviMap sqlParam	= new CoviMap();
				sqlParam.put("accountID", deleteArr[i]);
				deleteStandardBriefByAccountID(sqlParam);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : deleteStandardBriefByAccountID
	 * @Description : 표준적요 Delete by Account ID
	 */
	public void deleteStandardBriefByAccountID(CoviMap params)throws Exception {
		coviMapperOne.delete("account.standardBrief.deleteStandardBriefByAccountID", params);
	}
	
	/**
	 * @Method Name : deleteStandardBriefInfo
	 * @Description : 표준적요 Delete
	 */
	public void deleteStandardBriefInfo(CoviMap params)throws Exception {
		coviMapperOne.delete("account.standardBrief.deleteStandardBriefInfo", params);
	}
	
	/**
	 * @Method Name : standardBriefExcelDownload
	 * @Description : 표준적요 엑셀 다운로드
	 */
	@Override
	public CoviMap standardBriefExcelDownload(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviList list		= coviMapperOne.list("account.standardBrief.getStandardBriefExcelList", params);
		int cnt				= (int) coviMapperOne.getNumber("account.standardBrief.getStandardBrieflistCnt" , params);
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : standardBriefExcelUpload
	 * @Description : 표준적요 엑셀 업로드
	 */
	@Override
	public CoviMap standardBriefExcelUpload(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		ArrayList<ArrayList<Object>> dataList = accountExcelUtil.extractionExcelData(params, 1);	// 엑셀 데이터 추출
		ArrayList<CoviMap> dataInfoList = new ArrayList<>();
		String userCode = SessionHelper.getSession("UR_Code");
		
		if(dataList == null || dataList.isEmpty()) {
			return resultList;
		}
		
		for(ArrayList<Object> list : dataList) {
			CoviMap excelInfo = new CoviMap();
			String companyCode = list.get(7) == null ? "" : list.get(7).toString();
			String accountCode = list.get(0) == null ? "" : list.get(0).toString();
			String starndardBriefName = list.get(2) == null ? "" : list.get(2).toString();

			excelInfo.put("UR_Code",userCode);
			excelInfo.put("accountCode",accountCode);
			excelInfo.put("companyCode",companyCode);
			
			// 계정유무 확인
			if(!(dataInfoList.stream()
					.filter(obj -> obj.getString("accountCode").equals(accountCode) && obj.getString("companyCode").equals(companyCode))
					.distinct().count() > 0)) {
				int cnt = (int) coviMapperOne.getNumber("account.standardBrief.chkStandardBriefAccountCode" , excelInfo);
				if(cnt == 0) {
					resultList.put("err", "accountCode");
					return resultList;
				}
			}

			String accountID = coviMapperOne.selectOne("account.standardBrief.getStandardBriefAccountID" , excelInfo);
			excelInfo.put("accountID",accountID);
			excelInfo.put("standardBriefName", starndardBriefName);
			
			dataInfoList.add(excelInfo);
		}
		
		//계정 중복제거
		String[] accIdArr = dataInfoList.stream()
								.map(obj -> obj.get("accountID"))
								.distinct()
								.toArray(String[]::new);
		
		//엑셀 계정별 표준적요명 중복 체크
		for(int i = 0; i < accIdArr.length; i++) {
			String accId = accIdArr[i];
			
			String[] sbNameArr = dataInfoList.stream()
								.filter(obj -> accId.equals(obj.getString("accountID")))
								.map(obj -> obj.get("standardBriefName"))
								.toArray(String[]::new);
			
			int uniqSbNameCnt = Arrays.stream(sbNameArr)
								.distinct()
								.toArray(String[]::new)
								.length;
			
			if(sbNameArr.length > uniqSbNameCnt) {
				resultList.put("err", "standardBriefName");
				return resultList;
			}
		}
		
		CoviMap chkParam = new CoviMap();
		chkParam.put("accountID", accIdArr);
		
		// index | (0) = 계정코드 | (1) = 계정명 | (2) = 표준적요명 | (3) = 표준적요설명 | (4) = 사용여부  | (5) = 간편신청 사용여부
		// 4번 index 미사용 (쿼리안함)
		coviMapperOne.delete("account.standardBrief.deleteStandardBriefByAccountIDExcel", chkParam); 	 // 삭제
		
		for (ArrayList<Object> list : dataList) {
			CoviMap dataParam = dataInfoList.get(dataList.indexOf(list));
			
			String standardBriefDesc = list.get(3) == null ? "" : list.get(3).toString();
			String isUse 			 = list.get(4).equals("예") ? "Y" : list.get(5).equals("아니오") ? "N" : "";
			String isUseSimp 		 = list.get(5).equals("예") ? "Y" : list.get(6).equals("아니오") ? "N" : "";
			
			dataParam.put("standardBriefDesc", standardBriefDesc);
			dataParam.put("isUse", isUse);
			dataParam.put("isUseSimp", isUseSimp);

			// 표준적요 Insert.
			insertStandardBriefInfo(dataParam);
		}
		
		return resultList;
	}
}
