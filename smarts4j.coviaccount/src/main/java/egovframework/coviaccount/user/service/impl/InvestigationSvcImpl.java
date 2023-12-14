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
import egovframework.coviaccount.user.service.InvestigationSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

/**
 * @Class Name : InvestigationSvcImpl.java
 * @Description : 경조사 관리 서비스 구현
 * @Modification Information
 * @author Covision
 * 
 */

/**
 * @author Covision
 *
 */
@Service("InvestigationSvc")
public class InvestigationSvcImpl extends EgovAbstractServiceImpl implements InvestigationSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	/**
	 * @Method Name : getInvestList
	 * @Description : 경조사 관리 목록 조회
	 */
	@Override
	public CoviMap getInvestigationList(CoviMap params) throws Exception {
		
		CoviMap resultList	= new CoviMap();
		
		int cnt	= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt = (int) coviMapperOne.getNumber("investigation.selectInvestigationList" , params);
		
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("investigation.selectInvestigationListCnt", params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);
		return resultList;
	}
	
	/**
	 * @Method Name : getInvestigationListExcel
	 * @Description : 경조사 관리 엑셀 다운로드
	 */
	@Override
	public CoviMap getInvestigationListExcel(CoviMap params) throws Exception {
		CoviMap resultList 	= new CoviMap();
		CoviList list = coviMapperOne.list("investigation.selectInvestigationListExcel", params);
		int cnt = (int) coviMapperOne.getNumber("investigation.selectInvestigationListCnt" , params);
		String headerKey = params.get("headerKey").toString();
		resultList.put("list", accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt" , cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : saveInvestInfo
	 * @Description : 경조사 관리 저장
	 */
	@Override
	public CoviMap saveInvestInfo(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("userCode", SessionHelper.getSession("UR_Code"));
		resultList.put("result" , "");
		
		String InvestigationID = params.getString("investigationID");
		if("".equals(InvestigationID)){
			int check = (int) coviMapperOne.getNumber("investigation.selectInvestigationCnt" , params);
			if(check > 0){
				resultList.put("result" , "code");
			}else{
				insertInvestInfo(params);
			}
		}else{
			updateInvestInfo(params);
		}
		return resultList;
		
	}

	/**
	 * @Method Name : insertInvestInfo
	 * @Description : 경조사 관리 Insert
	 */
	public void insertInvestInfo(CoviMap params) throws Exception{
		coviMapperOne.insert("investigation.insertInvestInfo", params);
	}

	/**
	 * @Method Name : updateInvestInfo
	 * @Description : 경조사 관리 Update
	 */
	public void updateInvestInfo(CoviMap params) throws Exception{
		coviMapperOne.update("investigation.updateInvestInfo", params);
	}
	
	/**
	 * @Method Name : deleteInvestInfo
	 * @Description : 경조사 관리 삭제
	 */
	@Override
	public CoviMap deleteInvestInfo(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		if(!deleteStr.equals("")){
			String[] deleteArr = deleteStr.split(",");
			for(int i = 0; i < deleteArr.length; i++){
				CoviMap sqlParam 	= new CoviMap();
				sqlParam.put("investigationID" , deleteArr[i]);
				deleteInvest(sqlParam);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : deleteInvest
	 * @Description : 경조사 관리 Delete
	 */
	public void deleteInvest(CoviMap params){
		coviMapperOne.delete("investigation.deleteInvestInfo" , params);
	}

	/**
	 * @Method Name : getInvestigationInfo
	 * @Description : 경조사 관리 상세정보 조회
	 */
	@Override
	public CoviMap getInvestigationInfo(CoviMap params) throws Exception {
		CoviMap resultList 	= new CoviMap();

		CoviMap InvestInfo = coviMapperOne.selectOne("investigation.selectInvestigationInfo", params);
		
		resultList.put("result" , AccountUtil.convertNullToSpace(InvestInfo));
		return resultList;
	}

	/**
	 * @Method Name : getInvestItemCombo
	 * @Description : 경조항목 selectbox 데이터 조회
	 */
	@Override
	public CoviMap getInvestItemCombo(CoviMap params) throws Exception {
		CoviMap resultList 	= new CoviMap();

		CoviList InvestInfo = coviMapperOne.list("investigation.selectInvestItemCombo", params);
		
		resultList.put("result" , AccountUtil.convertNullToSpace(InvestInfo));
		return resultList;
	}
	
	/**
	 * @Method Name : getInvestTargetCombo
	 * @Description : 경조대상 selectbox 데이터 조회
	 */
	@Override
	public CoviMap getInvestTargetCombo(CoviMap params) throws Exception {
		CoviMap resultList 	= new CoviMap();

		CoviList InvestInfo = coviMapperOne.list("investigation.selectInvestTargetCombo", params);
		
		resultList.put("result" , AccountUtil.convertNullToSpace(InvestInfo));
		return resultList;
	}
	
	@Override
	public Object getInvestCrtr() throws Exception {		
		return coviMapperOne.selectOne("investigation.selectInvestCrtr");
	}
	
	/**
	 * @Method Name : getInvestigationUseList
	 * @Description : 경조사비 사용 목록 조회
	 */
	@Override
	public CoviMap getInvestigationUseList(CoviMap params) throws Exception {
		
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
		
		cnt = (int) coviMapperOne.getNumber("investigation.selectInvestigationUseListCnt" , params);
		
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list	= coviMapperOne.list("investigation.selectInvestigationUseList", params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);
		return resultList;
	}
	
	/**
	 * @Method Name : getInvestigationListExcel
	 * @Description : 경조사 관리 엑셀 다운로드
	 */
	@Override
	public CoviMap getInvestigationUseListExcel(CoviMap params) throws Exception {
		CoviMap resultList 	= new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("investigation.selectInvestigationUseListCnt" , params);
		
		CoviList list = coviMapperOne.list("investigation.selectInvestigationUseListExcel", params);
		
		String headerKey = params.get("headerKey").toString();
		
		resultList.put("list", accountExcelUtil.selectJSONForExcel(list, headerKey));
		resultList.put("cnt" , cnt);
		return resultList;
	}
}
