package egovframework.coviaccount.user.service.impl;

import java.util.ArrayList;
import java.util.Map;

import javax.annotation.Resource;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviaccount.common.service.CommonSvc;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.BizTripSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("BizTripSvc")
public class BizTripSvcImpl extends EgovAbstractServiceImpl implements BizTripSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private CommonSvc commonSvc;
		
	/**
	 * @Method Name : saveBizTripRequest
	 * @Description : 출장신청 내역 저장
	 */
	@Override
	public CoviMap saveBizTripRequest(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviMap coviParams = new CoviMap();
		coviParams.addAll(params);
		
		coviParams.put("CompanyCode", commonSvc.getCompanyCodeOfUser(params.getString("SessionUser")));
		
		int chk = (int)coviMapperOne.getNumber("biztrip.selectBizTripChk", coviParams);

		int cnt = 0;
		if(chk != 0) {
			cnt = coviMapperOne.update("biztrip.updateBizTripRequest", coviParams);
		} else {
			cnt = coviMapperOne.insert("biztrip.insertBizTripRequest", coviParams);
		}
		
		resultObj.put("status", "S");
		resultObj.put("cnt", cnt);		
		
		return resultObj;
	}
	

	/**
	* @Method Name : searchBizTripList
	* @Description : 출장 신청/정산 현황
	*/
	@Override
	public CoviMap searchBizTripList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
				
		cnt = (int)coviMapperOne.getNumber("biztrip.selectBizTripListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("biztrip.selectBizTripList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		return resultList;
	}
	
	/**
	* @Method Name : bizTripExcelDownload
	* @Description : 엑셀 다운로드
	*/
	@Override
	public CoviMap bizTripExcelDownload(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("biztrip.selectBizTripListExcel", params);
		int cnt = (int)coviMapperOne.getNumber("biztrip.selectBizTripListCnt", params);
		
		String headerKey	= params.get("headerKey").toString();
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}

	/**
	* @Method Name : getBizTripRequestInfo
	* @Description : 출장신청서 정보 조회
	*/
	@Override
	public CoviMap getBizTripRequestInfo(CoviMap params) throws Exception {
		CoviMap resultObj	= new CoviMap();
		
		CoviMap returnObj = (CoviMap) AccountUtil.convertNullToSpace(coviMapperOne.selectOne("biztrip.selectBizTripRequestInfo", params));

		resultObj.put("data", returnObj);
		resultObj.put("status", "S");
		
		return resultObj;
	}
	
	/**
	 * @Method Name : exceptBizTripApplication
	 * @Description : 출장 정산 제외 처리
	 */
	@Override
	public CoviMap exceptBizTripApplication(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		ArrayList<Map<String, Object>> chkList	= (ArrayList<Map<String, Object>>) params.get("chkList");
		
		if(chkList.size() > 0){
			for(int i=0; i <chkList.size(); i++){
				CoviMap info = new CoviMap(chkList.get(i));
				params.put("BizTripRequestID", info.get("BizTripRequestID"));
				
				coviMapperOne.update("biztrip.exceptBizTripApplication", params);
			}
		}
		return resultList;
	}
}
