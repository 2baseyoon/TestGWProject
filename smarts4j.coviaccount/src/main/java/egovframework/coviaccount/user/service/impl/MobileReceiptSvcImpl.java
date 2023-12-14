package egovframework.coviaccount.user.service.impl;

import java.util.Arrays;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.MobileReceiptSvc;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("MobileReceiptSvcSvc")
public class MobileReceiptSvcImpl extends EgovAbstractServiceImpl implements MobileReceiptSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private FileUtilService fileUtil;
	
	//MobileReceipt - Start
	
	/**
	 * @Method Name : getMobileReceiptList
	 * @Description : 모바일 영수증 등록내역 목록 조회
	 */
	@Override
	public CoviMap getMobileReceiptList(CoviMap params) throws Exception {
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
		
		cnt		= (int) coviMapperOne.getNumber("account.mobileReceipt.getMobileReceiptListCnt" , params);
		
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);

		list	= coviMapperOne.list("account.mobileReceipt.getMobileReceiptList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getMobileReceiptExcelList
	 * @Description : 모바일 영수증 등록내역 엑셀 다운로드
	 */
	@Override
	public CoviMap getMobileReceiptExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviList list		= coviMapperOne.list("account.mobileReceipt.getMobileReceiptExcelList", params);
		int cnt				= (int) coviMapperOne.getNumber("account.mobileReceipt.getMobileReceiptListCnt" , params);
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	//MobileReceipt - End
	
	//MobileReceiptUser - Start

	/**
	 * @Method Name : getMobileReceiptUserList
	 * @Description : 모바일 영수증 등록내역 [사용자] 목록 조회
	 */
	@Override
	public CoviMap getMobileReceiptUserList(CoviMap params) throws Exception {
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
		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));
		
		cnt		= (int) coviMapperOne.getNumber("account.mobileReceipt.getMobileReceiptUserListCnt" , params);
		
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list	= coviMapperOne.list("account.mobileReceipt.getMobileReceiptUserList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getMobileReceiptUserExcelList
	 * @Description : 모바일 영수증 등록내역 [사용자] 엑셀 다운로드
	 */
	@Override
	public CoviMap getMobileReceiptUserExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		CoviList list		= coviMapperOne.list("account.mobileReceipt.getMobileReceiptUserExcelList", params);
		int cnt				= (int) coviMapperOne.getNumber("account.mobileReceipt.getMobileReceiptUserListCnt" , params);
		String headerKey	= params.get("headerKey").toString();
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	//MobileReceiptUser - End
	
	/**
	 * @Method Name : deleteMobileReceipt
	 * @Description : 모바일 영수증 삭제
	 */
	@Override
	public CoviMap deleteMobileReceipt(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		
		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		coviMapperOne.delete("account.mobileReceipt.deleteMobileReceipt", params);
		return resultList;
	}

	@Override
	public CoviMap save(CoviMap params) throws Exception {
		CoviList uploadFileList = CoviList.fromObject(Arrays.asList(new CoviMap() {{
			this.put("FileName", params.get("fileName"));
			this.put("FrontAddPath", params.get("frontAddPath"));
			this.put("SavedName", params.get("savedName"));
			this.put("Size", params.get("size"));
		}}));
		CoviList uploadFiles = fileUtil.moveToBack(uploadFileList, "EAccount/", "EAccount", "0", "NONE", "0", false);
		params.put("receiptFileId", uploadFiles.getJSONObject(0).getString("FileID"));
		params.put("registerId", SessionHelper.getSession("UR_Code"));
		coviMapperOne.insert("account.mobileReceipt.insertMobileReceipt", params);
		
		return new CoviMap() {{ 
			this.put("status", "SUCCESS");
		}};
	}
}
