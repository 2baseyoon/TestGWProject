package egovframework.coviaccount.user.service.impl;

import java.lang.invoke.MethodHandles;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.CorpcardVO;
import egovframework.coviaccount.user.service.BaseCodeSvc;
import egovframework.coviaccount.user.service.CorpCardSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("CorpCardSvc")
public class CorpCardSvcImpl extends EgovAbstractServiceImpl implements CorpCardSvc {
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	@Autowired
	private BaseCodeSvc baseCodeSvc;
	
	/**
	 * @Method Name : getCorpCardList
	 * @Description : 카드 등록 관리 목록 조회
	 */
	@Override
	public CoviMap getCorpCardList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt		= (int) coviMapperOne.getNumber("account.corpcard.getCorpCardListCnt" , params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.corpcard.getCorpCardList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getCardNoChk
	 * @Description : 카드 등록 관리 카드 번호 체크
	 */
	@Override
	public CoviMap getCardNoChk(CoviMap params) throws Exception {

		CoviMap resultList	= new CoviMap();
		int cnt	= 0;
		cnt		= (int) coviMapperOne.getNumber("account.corpcard.getCardNoChk" , params);
		
		if(cnt == 0){
			resultList.put("result",	"ok");
		}else{
			resultList.put("result",	"fail");
		}
		return resultList; 
	}
	
	/**
	 * @Method Name : getCorpCardDetail
	 * @Description : 카드 등록 관리 상세 정보 조회
	 */
	@Override
	public CoviMap getCorpCardDetail(CoviMap params) throws Exception {

		CoviMap resultList	= new CoviMap();

		CoviList infoList	= coviMapperOne.list("account.corpcard.getCorpCardDetail",		params);
		CoviList userlist	= coviMapperOne.list("account.corpcard.getCorpCardUserDetail",	params);
		resultList.put("infoList",	AccountUtil.convertNullToSpace(infoList));
		resultList.put("userlist",	AccountUtil.convertNullToSpace(userlist));
		
		return resultList; 
	}
	
	/**
	 * @Method Name : saveCorpCardInfo
	 * @Description : 카드 등록 관리 정보 저장
	 */
	@Override
	public CoviMap saveCorpCardInfo(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		
		ArrayList<Map<String, Object>> ownerUserList		= (ArrayList<Map<String, Object>>) params.get("ownerUserArr");
		ArrayList<Map<String, Object>> ownerUserDelArrList	= (ArrayList<Map<String, Object>>) params.get("ownerUserDelArr");
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		String corpCardID = rtString(params.get("corpCardID"));
		
		if(corpCardID.equals("")){
			corpCardID = insertCorpCardInfo(params);
		}else{
			updateCorpCardInfo(params);
		}
		
		if(!ownerUserList.isEmpty()){
			for(int i=0;i<ownerUserList.size();i++){
				CoviMap infoListParam = new CoviMap(ownerUserList.get(i));
				
				String corpCardSearchUserID	= infoListParam.get("corpCardSearchUserID")	== null ? "" : infoListParam.get("corpCardSearchUserID").toString();
				infoListParam.put("corpCardID",	corpCardID);
				infoListParam.put("UR_Code",	SessionHelper.getSession("UR_Code"));
				
				if(corpCardSearchUserID.equals("")){
					insertCorpCardUserInfo(infoListParam);
				}else{
					updateCorpCardUserInfo(infoListParam);	
				}
			}
		}
		
		if(!ownerUserDelArrList.isEmpty()){
			for(int i=0;i<ownerUserDelArrList.size();i++){
				CoviMap delListParam = new CoviMap(ownerUserDelArrList.get(i));
				deleteCorpCardUserInfo(delListParam);
			}
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : updateCorpCardNo
	 * @Description : 카드 등록 관리 카드번호 변경
	 */
	@Override
	public CoviMap updateCorpCardNo(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		coviMapperOne.update("account.corpcard.updateCorpCardNo", params);
		return resultList;
	}
	
	/**
	 * @Method Name : insertCorpCardInfo
	 * @Description : 카드 등록 관리 Insert
	 */
	public String insertCorpCardInfo(CoviMap params)throws Exception {
		coviMapperOne.insert("account.corpcard.insertCorpCardInfo", params);
		return rtString(params.get("corpCardID"));
	}
	
	/**
	 * @Method Name : updateCorpCardInfo
	 * @Description : 카드 등록 관리 Update
	 */
	public void updateCorpCardInfo(CoviMap params)throws Exception {
		coviMapperOne.update("account.corpcard.updateCorpCardInfo", params);
	}
	
	/**
	 * @Method Name : deleteCorpCard
	 * @Description : 카드 등록 관리 삭제
	 */
	@Override
	public CoviMap deleteCorpCard(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		
		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		if(!deleteStr.equals("")){
			String[] deleteArr = deleteStr.split(",");
			for(int i = 0; i < deleteArr.length; i++){
				CoviMap sqlParam	= new CoviMap();
				sqlParam.put("corpCardID", deleteArr[i]);
				deleteCorpCardInfo(sqlParam);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : insertCorpCardUserInfo
	 * @Description : 카드 등록 관리 유저 정보 Insert
	 */
	public void insertCorpCardUserInfo(CoviMap params)throws Exception {
		if(rtString(params.get("corpCardID")).length() > 0){
			coviMapperOne.insert("account.corpcard.insertCorpCardUserInfo", params);
		}
	}
	
	/**
	 * @Method Name : updateCorpCardUserInfo
	 * @Description : 카드 등록 관리 유저 정보 Update
	 */
	public void updateCorpCardUserInfo(CoviMap params)throws Exception {
		coviMapperOne.update("account.corpcard.updateCorpCardUserInfo", params);
	}
	
	/**
	 * @Method Name : deleteCorpCardUserInfo
	 * @Description : 카드 등록 관리 유저 정보 Delete
	 */
	public void deleteCorpCardUserInfo(CoviMap params)throws Exception {
		coviMapperOne.delete("account.corpcard.deleteCorpCardUserInfo", params);
	}
	
	/**
	 * @Method Name : deleteCorpCardInfo
	 * @Description : 카드 등록 관리 정보 삭제
	 */
	public void deleteCorpCardInfo(CoviMap params)throws Exception {
		coviMapperOne.delete("account.corpcard.deleteCorpCardReturnList", params);
		coviMapperOne.delete("account.corpcard.deleteCorpCardUserInfoByCorpCardID", params);
		coviMapperOne.delete("account.corpcard.deleteCorpCardInfo", params);
	}
	
	/**
	 * @Method Name : deleteCorpCardUserInfoByCorpCardID
	 * @Description : 카드 등록 관리 유저 정보 삭제 
	 */
	public void deleteCorpCardUserInfoByCorpCardID(CoviMap params)throws Exception {
		coviMapperOne.delete("account.corpcard.deleteCorpCardUserInfoByCorpCardID", params);
	}
	
	/**
	 * @Method Name : corpCardExcelDownload
	 * @Description : 카드 등록 관리 엑셀 다운로드
	 */
	@Override
	public CoviMap corpCardExcelDownload(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviList list		= coviMapperOne.list("account.corpcard.getcorpCardExcelList", params);
		int cnt				= (int) coviMapperOne.getNumber("account.corpcard.getCorpCardListCnt" , params);
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : corpCardExcelUpload
	 * @Description : 카드 등록 관리 엑셀 업로드
	 */
	@Override
	public CoviMap corpCardExcelUpload(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		ArrayList<ArrayList<Object>> dataList = accountExcelUtil.extractionExcelData(params, 1);	// 엑셀 데이터 추출
		
		int row = 1;
		String rowMsg = DicHelper.getDic("ACC_msg_excel_row");
		
		// 엑셀 업로드 파일의 데이터가 존재하지 않습니다.
		if(dataList.size() == 0) {
			resultList.put("err", "zeroErr");
			resultList.put("message", DicHelper.getDic("ACC_msg_excel_zeroErr"));
			return resultList;
		}
		
		try {
			for (ArrayList<Object> list : dataList) { // 추가
				String companyCode = StringUtil.replaceNull(list.get(0).toString()); //회사명
				String cardCompany = StringUtil.replaceNull(list.get(1).toString()); //카드사명
				String cardNo = StringUtil.replaceNull(list.get(2).toString()); //카드번호
				String cardClass = StringUtil.replaceNull(list.get(3).toString()); //카드유형
				String cardStatus = StringUtil.replaceNull(list.get(4).toString()); //카드상태
				String empNo = StringUtil.replaceNull(list.get(5).toString()); //소유자사번
				String vendorNo = StringUtil.replaceNull(list.get(6).toString());//지급처
				String issueDate = StringUtil.replaceNull(list.get(7).toString());//발급일자
				String payDate = StringUtil.replaceNull(list.get(8).toString()); //지불일
				String expirationDate = StringUtil.replaceNull(list.get(9).toString()); //만료일자
				String limitAmount = StringUtil.replaceNull(list.get(10).toString()); //한도금액
				String note = StringUtil.replaceNull(list.get(11).toString());//비고
	
				CoviMap saveParams = new CoviMap();
				saveParams.put("UR_Code", SessionHelper.getSession("UR_Code"));
				saveParams.put("cardNo", cardNo); 
	
				CoviMap searchStr		= new CoviMap();
				searchStr.put("codeGroup", "CompanyCode");
				searchStr.put("codeName", companyCode);
				companyCode = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 회사코드
				
				// 회사가 존재하지 않습니다.
				if("".equals(companyCode) || companyCode == null) {
					resultList.put("err", "companyErr");
					resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("ACC_msg_excel_companyErr"));
					return resultList;
				}
	
				// 검색조건에 회사코드 추가
				searchStr.put("companyCode", companyCode);
				
				searchStr.put("codeGroup", "CardCompany");
				searchStr.put("codeName", cardCompany);
				cardCompany = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 카드회사
				
				searchStr.put("codeGroup", "CardClass");
				searchStr.put("codeName", cardClass);
				cardClass = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 카드유형
				
				searchStr.put("codeGroup", "CardStatus");
				searchStr.put("codeName", cardStatus);
				cardStatus = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 카드상태
				
				//이미 등록되어있는 ReceiptID이면 업데이트
				CoviMap cardObj =  coviMapperOne.select("account.corpcard.getCorpCardList", saveParams); // ID체크(등록/수정)
				saveParams.put("companyCode", companyCode); 
				saveParams.put("cardCompany", cardCompany); 
				saveParams.put("cardClass", cardClass); 
				saveParams.put("cardStatus", cardStatus);
				saveParams.put("vendorNo", vendorNo); 
				saveParams.put("issueDate", issueDate.replaceAll("\\.", "")); 
				saveParams.put("payDate", payDate); 
				saveParams.put("expirationDate", expirationDate.replaceAll("/", "")); 
				saveParams.put("limitAmountType", ""); 
				saveParams.put("limitAmount", limitAmount); 
				saveParams.put("note", note); 
				
				// 소유자 코드 조회
				String ownerUserCode = coviMapperOne.selectOne("account.corpcard.getUserCode", empNo);
				saveParams.put("ownerUserCode", ownerUserCode); 
	
				if(cardObj.size() == 0){ // 추가
					//Object corpCardID = (int)coviMapperOne.insertWithPK("account.corpcard.insertCorpCardInfo", saveParams);
					coviMapperOne.insert("account.corpcard.insertCorpCardInfo", saveParams);
					String corpCardID = saveParams.getString("corpCardID");
	
					saveParams.put("corpCardID", corpCardID);
					coviMapperOne.insert("account.corpcard.insertCorpCardUserInfo", saveParams);
				} else{ // 수정
					String corpCardID = cardObj.getString("CorpCardID");
					saveParams.put("corpCardID", corpCardID);
					coviMapperOne.update("account.corpcard.updateCorpCardInfo", saveParams);
					if (!ownerUserCode.equals("")){
						CoviMap userMap = coviMapperOne.select("account.corpcard.getCorpCardUserDetail", saveParams);
						if (userMap.size() == 0 ){
							coviMapperOne.insert("account.corpcard.insertCorpCardUserInfo", saveParams);
						}
					}	
				}
				row++;
			}
		} catch (SQLException e) {
			resultList.put("err", "rowErr");
			resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("msg_apv_030"));
			return resultList;
		} catch (Exception e) {
			resultList.put("err", "rowErr");
			resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("msg_apv_030"));
			return resultList;
		}
		return resultList;
	}
	
	/**
	 * @Method Name : corpCardSync
	 * @Description : 카드 등록 관리 동기화
	 */
	@Override
	public CoviMap corpCardSync(){

		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		CorpcardVO corpcardVO	= null;

		try{
			//String syncType = accountUtil.getPropertyInfo("account.syncType.Corpcard");
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "CorpCard");
			
			interfaceParam.put("interFaceType",			syncType);
	
			interfaceParam.put("daoClassName",			"CorpcardDao");
			interfaceParam.put("voClassName",			"CorpcardVO");
			interfaceParam.put("mapClassName",			"CorpcardMap");
	
			interfaceParam.put("daoSetFunctionName",	"setCorpcardList");
			interfaceParam.put("daoGetFunctionName",	"getCorpcardList");
			interfaceParam.put("voFunctionName",		"setAll");
			interfaceParam.put("mapFunctionName",		"getMap");
	
			switch (syncType) {
				case "DB":
					//syncType이 DB인 경우 이곳에 정의
					interfaceParam.put("type",		"get");
					//interfaceParam.put("sqlName",	StringUtil.replaceNull(accountUtil.getPropertyInfo("account.searchDBName.Corpcard"),"accountInterFace.AccountSI.getInterFaceListCorpcard"));
					interfaceParam.put("sqlName",	StringUtil.replaceNull(accountUtil.getBaseCodeInfo("eAccDBName", "CorpCard"),"accountInterFace.AccountSI.getInterFaceListCorpcard"));
					break;
		
				case "SOAP":
					//syncType이 SOAP인 경우 이곳에 정의
					break;
					
				case "SAP":
					//syncType이 SAP인 경우 이곳에 정의
					break;
				default:
			}
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
	
			String cardNoCHK	= "";
			
			CoviList infoList		= new CoviList();
			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				corpcardVO = (CorpcardVO) list.get(i);
				String companyCode			= corpcardVO.getCompanyCode();		//회사코드
				String cardNo				= corpcardVO.getCardNo();			//카드번호
				String cardCompany			= corpcardVO.getCardCompany();		//카드회사
				String cardClass			= corpcardVO.getCardClass();		//카드유형#공통코드
				String cardStatus			= corpcardVO.getCardStatus();		//카드상태#공통코드
				String ownerUserCode		= corpcardVO.getOwnerUserCode();	//소유자코드
				String vendorNo				= corpcardVO.getVendorNo();			//지급처등록번호
				String issueDate			= corpcardVO.getIssueDate();		//발급일자
				String payDate				= corpcardVO.getPayDate();		//발급일자
				String expirationDate		= corpcardVO.getExpirationDate();	//만료년월
				String limitAmountType		= corpcardVO.getLimitAmountType();	//한도금액타입
				String limitAmount			= corpcardVO.getLimitAmount();		//한도금액
				String note					= corpcardVO.getNote();				//비고
				String searchUserUserCode	= corpcardVO.getSearchUserUserCode();
				
				if(cardNoCHK.equals("")){
					cardNoCHK = cardNo;
				}
	
				//데이터 구조가 다른 관계로  임시로 셋팅
				companyCode		= "TEOS";
				expirationDate	= expirationDate.replaceAll("/", "");
				issueDate		= issueDate.replaceAll("-", "");
				cardNo			= cardNo.replaceAll("[^0-9]", "");
				
				listInfo.put("companyCode",			companyCode);
				listInfo.put("cardNo",				cardNo);
				listInfo.put("cardCompany",			cardCompany);
				listInfo.put("cardClass",			cardClass);
				listInfo.put("cardStatus",			cardStatus);
				listInfo.put("ownerUserCode",		ownerUserCode);
				listInfo.put("vendorNo",			vendorNo);
				listInfo.put("issueDate",			issueDate);
				listInfo.put("payDate",				payDate);
				listInfo.put("expirationDate",		expirationDate);
				listInfo.put("limitAmountType",		limitAmountType);
				listInfo.put("limitAmount",			limitAmount);
				listInfo.put("note",				note);
				listInfo.put("searchUserUserCode",	searchUserUserCode);
				
				if((i+1) == list.size()){
					infoList.add(listInfo);
					corpcardInterfaceSave(infoList);
				}else{
					if(cardNoCHK.equals(cardNo)){
						infoList.add(listInfo);
					}else{
						corpcardInterfaceSave(infoList);
						
						infoList		= new CoviList();
						infoList.add(listInfo);
						cardNoCHK = cardNo;
					}
				}
			}
			resultList.put("status",	getInterface.get("status"));
		} catch (NullPointerException e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}

	/**
	 * @Method Name : corpcardInterfaceSave
	 * @Description : 카드 등록 관리 동기화 저장
	 */
	private void corpcardInterfaceSave(CoviList list) {
		try {
			CoviList	corpCardList	= null;
			CoviMap		corpCardInfo	= null;
			String		corpCardID		= "";
			String		userCode			= SessionHelper.getSession("UR_Code");
			
			for(int i=0; i<list.size(); i++){
				CoviMap map = (CoviMap) list.get(i);
				map.put("UR_Code", userCode);
				if(i == 0){
					//act_corp_card
					corpCardList = coviMapperOne.list("account.corpcard.corpcardInterfaceInfo", map);
					if (corpCardList.isEmpty()){
						corpCardID = insertCorpCardInfo(map);
						map.put("corpCardID", corpCardID);
					} else {
						corpCardInfo	= (CoviMap) corpCardList.get(0);
						corpCardID		= rtString(corpCardInfo.get("CorpCardID"));
						map.put("corpCardID", corpCardID);
						updateCorpCardInfo(map);
					}
					
					deleteCorpCardUserInfoByCorpCardID(map);
				}
				map.put("ownerUserCode", rtString(map.get("searchUserUserCode")));
				insertCorpCardUserInfo(map);
			}
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
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

	@Override
	public CoviMap getCorpCardHistoryList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt		= (int) coviMapperOne.getNumber("account.corpcard.getCorpCardReturnCnt" , params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.corpcard.getCorpCardReturnList", params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}

	@Override
	public CoviMap saveCorpCardReturnInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		coviMapperOne.update("account.corpcard.insertCorpCardReturnInfo", params);
		return resultList;
	}

	@Override
	public CoviMap updateCorpCardReturnInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		coviMapperOne.update("account.corpcard.updateCorpCardReturnInfo", params);
		return resultList;
	}

	@Override
	public CoviMap updateCorpCardReturnStatus(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		coviMapperOne.update("account.corpcard.updateCorpCardReturnStatus", params);
		return resultList;
	}

	@Override
	public CoviMap getReleaseUserInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		CoviList list = coviMapperOne.list("account.corpcard.getCorpCardReleaseUserInfo", params);
		resultList.put("list", list);
		
		return resultList;
	}

	@Override
	public CoviMap deleteCorpCardReturnYN(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		if(!deleteStr.equals("")){
			String[] deleteArr = deleteStr.split(",");
			for(int i = 0; i < deleteArr.length; i++){
				CoviMap sqlParam	= new CoviMap();
				sqlParam.put("corpCardReturnID", deleteArr[i]);
				deleteCorpCardReturnYNInfo(sqlParam);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : deleteCorpCardReturnYNInfo
	 * @Description : 카드 불출 대장 정보 삭제
	 */
	public void deleteCorpCardReturnYNInfo(CoviMap params)throws Exception {
		CoviMap map	= coviMapperOne.selectOne("account.corpcard.getCorpCardReturnDeleteInfo", params); //corpcardReturnID
		String returnDate = map.get("ReturnDate") == null ? "" : map.get("ReturnDate").toString();

		if(returnDate.equals("")){
			params.put("corpCardID", map.get("CorpCardID"));
			params.put("ReleaseYN", "N");
			coviMapperOne.update("account.corpcard.updateCorpCardReturnStatus", params);
		}
		coviMapperOne.delete("account.corpcard.deleteCorpCardReturnYNInfo", params);
	}
}
