package egovframework.coviaccount.user.service.impl;

import java.util.ArrayList;
import java.util.Map;

import javax.annotation.Resource;

import net.sf.json.JSON;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.StoreCategoryManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("StoreCategoryManageSvc")
public class StoreCategoryManageSvcImpl extends EgovAbstractServiceImpl implements StoreCategoryManageSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	/**
	 * @Method Name : getStoreCategoryManagelist
	 * @Description : 업종 목록 조회
	 */
	@Override
	public CoviMap getStoreCategoryManagelist(CoviMap params) throws Exception {
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

		cnt		= (int) coviMapperOne.getNumber("account.storeCategory.getStoreCategoryManageListCnt" , params);
		
		page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list	= coviMapperOne.list("account.storeCategory.getStoreCategoryManageList", params);
		
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getStoreCategoryManageDetail
	 * @Description : 업종 상세 조회
	 */
	@Override
	public CoviMap getStoreCategoryManageDetail(CoviMap params) throws Exception {

		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();

		list = coviMapperOne.list("account.storeCategory.getStoreCategoryManageList",	params);
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		return resultList; 
	}
	
	/**
	 * @Method Name : saveStoreCategoryManageInfo
	 * @Description : 업종 저장
	 */
	@Override
	public CoviMap saveStoreCategoryManageInfo(CoviMap params)throws Exception {
		CoviMap resultObj	= new CoviMap();
		resultObj.put("status",	Return.SUCCESS);
		params.put("UserID", SessionHelper.getSession("UR_Code"));
		
		String CategoryID = rtString(params.get("CategoryID"));
		
		if(!CategoryID.equals("")){
			coviMapperOne.update("account.storeCategory.updateStoreCategoryManageInfo", params);
		}
		else{
			int cnt	= (int) coviMapperOne.getNumber("account.storeCategory.getStoreCategoryManageListCnt" , params);
			if(cnt==0)
				coviMapperOne.insert("account.storeCategory.insertStoreCategoryManageInfo", params);
			else
				resultObj.put("status", "DUP");
			
			
		}
		
		return resultObj;
	}
	
	/**
	 * @Method Name : deleteStoreCategoryManageInfoByAccountID
	 * @Description : 업종 삭제
	 */
	@Override
	public CoviMap deleteStoreCategoryManageInfo(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		
		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		if(!deleteStr.equals("")){
			String[] deleteArr = deleteStr.split(",");
			for(int i = 0; i < deleteArr.length; i++){
				CoviMap sqlParam	= new CoviMap();
				sqlParam.put("CategoryID", deleteArr[i]);
				coviMapperOne.update("account.storeCategory.deleteStoreCategoryManageInfo", sqlParam);
			}
		}
		return resultList;
	}
	
	
	/**
	 * @Method Name : storeCategoryManageExcelDownload
	 * @Description : 업종 엑셀 다운로드
	 */
	@Override
	public CoviMap storeCategoryManageExcelDownload(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviList list		= coviMapperOne.list("account.storeCategory.getStoreCategoryManageList", params);
		int cnt				= (int) coviMapperOne.getNumber("account.storeCategory.getStoreCategoryManageListCnt" , params);
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt); 
		return resultList;
	}
	/**
	 * @Method Name : StoreCategoryManageExcelUpload
	 * @Description : 엑셀 업로드
	 */
	@Override
	public CoviMap storeCategoryManageExcelUpload(CoviMap params) throws Exception {
		int rtn = 0;
		CoviMap resultList	= new CoviMap();
		String strCompare	= "";
		String aidStr		= "";
		
		ArrayList<ArrayList<Object>> dataList = accountExcelUtil.extractionExcelData(params, 1);	// 엑셀 데이터 추출

		params.put("UserID", SessionHelper.getSession("UR_Code"));
		
		for (ArrayList list : dataList) { // 추가
			String CompanyCode		= list.get(0) == null ? "" : list.get(0).toString();
			String CategoryCode		= list.get(2) == null ? "" : list.get(2).toString();
			String CategoryName 	= list.get(3) == null ? "" : list.get(3).toString();
			
			CoviMap searchStr 	= new CoviMap();
			
			
			params.put("CompanyCode", CompanyCode);
			params.put("CategoryCode", CategoryCode);
			params.put("CategoryName", CategoryName); 
			
			int cnt	= (int) coviMapperOne.getNumber("account.storeCategory.getStoreCategoryManageListCnt" , params);
			if(cnt>0)
			{
				
				resultList.put("err", "strCategoryCode");
				resultList.put("CategoryCode", CategoryCode);
				break;
			}
			coviMapperOne.update("account.storeCategory.insertStoreCategoryManageInfo", params);
			
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : rtString
	 * @Description : return String
	 */
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}

}
