package egovframework.coviaccount.user.service.impl;

import java.util.ArrayList;
import java.util.Map;

import javax.annotation.Resource;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.CodeManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

/**
 * @author Covision
 *
 */
@Service("CodeManageSvc")
public class CodeManageSvcImpl extends EgovAbstractServiceImpl implements CodeManageSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * @Method Name : getCodeSearchGroupList
	 * @Description : 증빙별코드매핑 그룹 목록 조회
	 */
	@Override
	public CoviMap getCodeSearchGroupList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list			= coviMapperOne.list("account.codemanage.getCodeSearchGroupList", params);
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getCodeSearchList
	 * @Description : 증빙별코드매핑 목록 조회
	 */
	@Override
	public CoviMap getCodeSearchList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list			= coviMapperOne.list("account.codemanage.getCodeSearchList", params);
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		
		return resultList; 
	}
	
	/**
	 * @Method Name : saveCodeManageInfo
	 * @Description : 증빙별코드매핑 저장
	 */
	@Override
	public CoviMap saveCodeManageInfo(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		ArrayList<Map<String, Object>> infoList	= (ArrayList<Map<String, Object>>) params.get("infoArr");
		ArrayList<Map<String, Object>> delList	= (ArrayList<Map<String, Object>>) params.get("delArr");
				
		if(infoList.size() > 0){			
			for(int i=0;i<infoList.size();i++){
				CoviMap infoListParam = new CoviMap(infoList.get(i));
				
				String proofTaxMappID = infoListParam.get("proofTaxMappID") == null ? "" : infoListParam.get("proofTaxMappID").toString();
				
				if(proofTaxMappID.equals("")){
					infoListParam.put("UR_Code", SessionHelper.getSession("UR_Code"));
					infoListParam.put("companyCode", params.getString("companyCode"));
					infoListParam.put("proofCode", params.getString("proofCode"));
					insertCodeManageInfo(infoListParam);
				}
			}
		}
		
		if(delList.size() > 0){
			for(int i=0;i<delList.size();i++){
				CoviMap delListParam = new CoviMap(delList.get(i));
				String proofTaxMappID = delListParam.get("proofTaxMappID") == null ? "" : delListParam.get("proofTaxMappID").toString();
				params.put("proofTaxMappID",	proofTaxMappID);
				deleteCodeManageInfo(params);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : insertCodeManageInfo
	 * @Description : 증빙별코드매핑 Insert
	 */
	public void insertCodeManageInfo(CoviMap params)throws Exception {
		coviMapperOne.insert("account.codemanage.insertCodeManageInfo", params);
	}
	
	/**
	 * @Method Name : deleteCodeManageInfo
	 * @Description : Update
	 */
	public void deleteCodeManageInfo(CoviMap params)throws Exception {
		coviMapperOne.insert("account.codemanage.deleteCodeManageInfo", params);
	}
}
