package egovframework.coviaccount.user.service.impl;

import javax.annotation.Resource;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.ManagerSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

/**
 * @Class Name : ManagerSvcImpl.java
 * @Description : 담당자 관리 서비스 구현
 * @Modification Information
 * @author Covision
 * 
 */

/**
 * @author Covision
 *
 */
@Service("ManagerSvc")
public class ManagerSvcImpl extends EgovAbstractServiceImpl implements ManagerSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	/**
	 * @Method Name : getManagerList
	 * @Description : 담당자 관리 목록 조회
	 */
	@Override
	public CoviMap getManagerList(CoviMap params) throws Exception {
		
		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap page = new CoviMap();
		
		int cnt	= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt = (int) coviMapperOne.getNumber("account.manager.getManagerListCnt" , params);
		
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list	= coviMapperOne.list("account.manager.getManagerList", params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);
		return resultList;
	}
	
	/**
	 * @Method Name : saveManagerInfo
	 * @Description : 담당자 관리 저장
	 */
	@Override
	public CoviMap saveManagerInfo(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		resultList.put("result" , "");
		
		String managerID = params.getString("ManagerID");
		if("".equals(managerID)){
			int check = (int) coviMapperOne.getNumber("account.manager.getManagerCnt" , params);
			if(check > 0){
				resultList.put("result" , "code");
			}else{
				insertManagerInfo(params);
			}
		}else{
			updateManagerInfo(params);
		}
		return resultList;
		
	}

	/**
	 * @Method Name : insertManagerInfo
	 * @Description : 담당자 관리 Insert
	 */
	public void insertManagerInfo(CoviMap params) throws Exception{
		coviMapperOne.insert("account.manager.insertManagerInfo", params);
	}

	/**
	 * @Method Name : updateManagerInfo
	 * @Description : 담당자 관리 Update
	 */
	public void updateManagerInfo(CoviMap params) throws Exception{
		coviMapperOne.insert("account.manager.updateManagerInfo", params);
	}
	
	/**
	 * @Method Name : deleteManagerInfo
	 * @Description : 담당자 관리 삭제
	 */
	@Override
	public CoviMap deleteManagerInfo(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		if(!deleteStr.equals("")){
			String[] deleteArr = deleteStr.split(",");
			for(int i = 0; i < deleteArr.length; i++){
				CoviMap sqlParam 	= new CoviMap();
				sqlParam.put("managerID" , deleteArr[i]);
				deleteManager(sqlParam);
				
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : deleteManager
	 * @Description : 담당자 관리 Delete
	 */
	public void deleteManager(CoviMap params){
		coviMapperOne.delete("account.manager.deleteManagerInfo" , params);
	}
	
	/**
	 * @Method Name : managerExcelDownload
	 * @Description : 담당자 관리 엑셀 다운로드
	 */
	@Override
	public CoviMap managerExcelDownload(CoviMap params) throws Exception {
		CoviMap resultList 	= new CoviMap();
		CoviList list = coviMapperOne.list("account.manager.managerExcelDownload", params);
		int cnt 				= (int) coviMapperOne.getNumber("account.manager.getManagerListCnt" , params);
		String headerKey 		= params.get("headerKey").toString();
		resultList.put("list", accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt" , cnt);
		return resultList;
	}

	/**
	 * @Method Name : searchManagerInfo
	 * @Description : 담당자 관리 상세정보 조회
	 */
	@Override
	public CoviMap searchManagerInfo(CoviMap params) throws Exception {
		CoviMap resultList 	= new CoviMap();

		CoviMap managerInfo = coviMapperOne.selectOne("account.manager.selectManagerInfo", params);
		
		resultList.put("result" , AccountUtil.convertNullToSpace(managerInfo));
		return resultList;
	}
}
