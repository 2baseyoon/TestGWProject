package egovframework.coviaccount.user.service.impl;

import java.lang.invoke.MethodHandles;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.apache.http.client.methods.HttpHead;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.api.client.http.HttpHeaders;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.BaseCodeVO;
import egovframework.coviaccount.user.service.BaseCodeSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



/**
 * @Class Name : BaseCodeSvcImpl.java
 * @Description : 기초코드 서비스 구현
 * @Modification Information 
 * @author CSH
 * @ 2018.05.08 최초생성
 */
@Service("baseCodeService")
public class BaseCodeSvcImpl extends EgovAbstractServiceImpl implements BaseCodeSvc {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Resource(name="AccountExcelUtil")
	private AccountExcelUtil excelUtil;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;

	@Autowired
	private InterfaceUtil interfaceUtil;
	
	/**
	* @Method Name : callInsertBaseCode
	* @Description : 코드 추가
	*/
	private int callInsertBaseCode(CoviMap params) throws Exception {
		
		int rtnVal = 0;
		String isGroup = params.getString("IsGroup");
		if("Y".equals(isGroup)){
			params.put("Code", params.getString("CodeGroup"));
			params.put("CodeName", params.getString("CodeGroupName"));
			params.put("SortKey", "0");
		}else{
			params.put("CodeGroup", params.getString("CodeGroupCombo"));
			
			int grpCk = (int) coviMapperOne.getNumber("baseCode.checkBaseCodeGrpDetail", params);

			if(grpCk==0){
				return -3;
			}
		}

		String codeGroup = params.getString("CodeGroup");
		String code = params.getString("Code");
		String codeName = params.getString("CodeName");
		String sortKey = params.getString("SortKey");
		
		if(AccountUtil.checkNull(codeGroup)
				||AccountUtil.checkNull(code)
				||AccountUtil.checkNull(codeName)
				||AccountUtil.checkNull(sortKey)){
			rtnVal = -1;
		}else{
			int duplCnt = (int)coviMapperOne.getNumber("baseCode.selectBaseCodeDuplCnt", params);
			if(duplCnt != 0){
				return -2;
			}
			rtnVal = coviMapperOne.insert("baseCode.insertBaseCode", params);
		}
		return rtnVal;
	}

	
	/**
	* @Method Name : searchBaseCode
	* @Description : 코드 목록 조회
	*/
	@Override
	public CoviMap searchBaseCode(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt = (int)coviMapperOne.getNumber("baseCode.selectBaseCodeCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("baseCode.selectBaseCode", params);
				
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "BaseCodeID,CompanyCode,CompanyName,CodeGroup,CodeGroupName,Code,CodeName,IsUse,ModifierID,ModifierName,ModifyDate,IsGroup,SortKey"));
		resultList.put("page", page);
		//resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	* @Method Name : searchBaseCodeView
	* @Description : 코드 목록 조회
	*/
	@Override
	public CoviMap searchBaseCodeView(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt = (int)coviMapperOne.getNumber("baseCode.selectBaseCodeViewCnt", params);
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		CoviList list = coviMapperOne.list("baseCode.selectBaseCodeView", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "BaseCodeID,CompanyCode,CompanyName,CodeGroup,CodeGroupName,Code,CodeName,IsUse,ModifierID,ModifierName,ModifyDate,IsGroup,SortKey,RegistDate,Reserved1"));
		resultList.put("page", page);
		//resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	* @Method Name : searchBaseCodeDetail
	* @Description : 코드 상세 조회
	*/
	@Override
	public CoviMap searchBaseCodeDetail(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.selectOne("baseCode.selectBaseCodeDetail", params);
		CoviMap resultMap = new CoviMap();
		resultMap.put("result",AccountUtil.convertNullToSpace(map));
		return resultMap;
	}
	
	/**
	* @Method Name : searchBaseCodeExcel
	* @Description : 엑셀다운로드용 코드 조회
	*/
	@Override
	public CoviMap searchBaseCodeExcel(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list		= coviMapperOne.list("baseCode.selectBaseCodeExcel", params);
		int cnt				= (int) coviMapperOne.getNumber("baseCode.selectBaseCodeCnt" , params);
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	/**
	* @Method Name : changeBaseCodeIsUse
	* @Description : 회사코드 사용여부 변경전 체크
	*/
	@Override
	public int checkCompanyCodeIsUse(CoviMap params) {
		return (int) coviMapperOne.getNumber("baseCode.selectCompanyCodeIsUseCnt" , params);
	}
	
	/**
	* @Method Name : changeBaseCodeIsUse
	* @Description : 기초코드 사용여부 스위치
	*/
	@Override
	public int changeBaseCodeIsUse(CoviMap params) throws Exception {
		return coviMapperOne.update("baseCode.changeBaseCodeIsUse", params);
	}

	/**
	* @Method Name : deleteBaseCodeList
	* @Description : 기초코드 삭제
	*/
	@Override
	public int deleteBaseCodeList(CoviMap params) throws Exception {
		return coviMapperOne.delete("baseCode.deleteBaseCodeList", params);
	}

	/**
	* @Method Name : deleteBaseGrpCodeList
	* @Description : 기초코드 그룹삭제
	* 				그룹삭제시 하위코드 모두 삭제
	*/
	public int deleteBaseGrpCodeList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("baseCode.selectBaseGrpCode4Delete", params);

		String grpCdList = "";
		StringBuffer buf = new StringBuffer();
		for (int i = 0; i < list.size(); i++) {
			CoviMap setParam = (CoviMap) list.get(i);
			if(i==0){
				buf.append("'").append(setParam.getString("Code")).append("'");
			}else{
				buf.append(",'").append(setParam.getString("Code")).append("'");
			}
		}
		grpCdList = buf.toString();
		//params.put("grpCdList", grpCdList);
		if(grpCdList != null && !grpCdList.equals("")) params.put("grpCdList", grpCdList.split(","));
		int cnt = coviMapperOne.delete("baseCode.deleteBaseGrpCodeList", params);
		return cnt;
	}

	/**
	* @Method Name : insertBaseCode
	* @Description : 기초코드 삽입
	*/
	@Override
	public CoviMap insertBaseCode(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();

		CoviMap setParam = new CoviMap();
		
		setParam.put("CompanyCode", jobjGetStr(params,"CompanyCode"));
		
		setParam.put("CodeGroup", jobjGetStr(params,"CodeGroup"));
		setParam.put("CodeGroupName", jobjGetStr(params,"CodeGroupName"));
		setParam.put("CodeGroupCombo", jobjGetStr(params,"CodeGroupCombo"));
		setParam.put("Code", jobjGetStr(params,"Code"));
		setParam.put("CodeName", jobjGetStr(params,"CodeName"));
		
		setParam.put("IsGroup", jobjGetStr(params,"IsGroup"));
		setParam.put("IsUse", jobjGetStr(params,"IsUse"));
		setParam.put("SortKey", jobjGetStr(params,"SortKey"));
		setParam.put("SessionUser", jobjGetStr(params,"SessionUser"));
		
		setParam.put("Description", jobjGetStr(params,"Description"));
		setParam.put("Reserved1", jobjGetStr(params,"Reserved1"));
		setParam.put("Reserved2", jobjGetStr(params,"Reserved2"));
		setParam.put("Reserved3", jobjGetStr(params,"Reserved3"));
		setParam.put("Reserved4", jobjGetStr(params,"Reserved4"));
		setParam.put("ReservedInt", jobjGetStr(params,"ReservedInt"));

		int cnt = callInsertBaseCode(setParam);
		
		if(cnt==-1){
			resultObj.put("status", "V");
		}
		else if(cnt==-2){
			resultObj.put("status", "D");
		}
		else if(cnt==-3){
			resultObj.put("status", "G");
		}
		else{
			resultObj.put("insertCnt", cnt);
			resultObj.put("status", "S");
		}
		
		return resultObj;
	}
	
	/**
	* @Method Name : updateBaseCode
	* @Description : 기초코드 수정
	*/
	@Override
	public CoviMap updateBaseCode(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();

		CoviMap setParam = new CoviMap();
		setParam.put("CompanyCode", jobjGetStr(params,"CompanyCode"));
		
		setParam.put("CodeGroup", jobjGetStr(params,"CodeGroup"));
		setParam.put("CodeGroupName", jobjGetStr(params,"CodeGroupName"));
		setParam.put("Code", jobjGetStr(params,"Code"));
		setParam.put("CodeName", jobjGetStr(params,"CodeName"));
		setParam.put("IsGroup", jobjGetStr(params,"IsGroup"));
		
		setParam.put("IsUse", jobjGetStr(params,"IsUse"));
		setParam.put("SortKey", jobjGetStr(params,"SortKey"));
		setParam.put("SessionUser", jobjGetStr(params,"SessionUser"));

		setParam.put("Description", jobjGetStr(params,"Description"));
		setParam.put("Reserved1", jobjGetStr(params,"Reserved1"));
		setParam.put("Reserved2", jobjGetStr(params,"Reserved2"));
		setParam.put("Reserved3", jobjGetStr(params,"Reserved3"));
		setParam.put("Reserved4", jobjGetStr(params,"Reserved4"));
		setParam.put("ReservedInt", jobjGetStr(params,"ReservedInt"));
		
		int cnt = 0;
		if("Y".equals(params.getString("IsGroup"))){
			cnt = coviMapperOne.update("baseCode.updateBaseGrpCode", params);
			resultObj.put("status", "S");
		}
		else
		{
			cnt = coviMapperOne.update("baseCode.updateBaseCode", params);
			resultObj.put("status", "S");
		}
		resultObj.put("updateCnt", cnt);
		return resultObj;
	}
	
	/**
	* @Method Name : uploadExcelBaseCode
	* @Description : 기초코드 엑셀 업로드
	*/
	@Override
	public CoviMap uploadExcelBaseCode(CoviMap params) throws Exception {

		ArrayList<ArrayList<Object>> dataList = accountExcelUtil.extractionExcelData(params, 1);
		
		CoviMap resultObj = new CoviMap();
		int chkCnt = 0;
		int sortCnt = 0;
		String chkStr = "";
		// index | (0) = 회사코드 | (1) = 회사명 | (2) = 코드그룹여부 | (3) = 코드그룹 | (4) = 코드그룹명 | (5) = 코드 | (6) = 코드명 | (7) = 사용여부 |
		ArrayList<ArrayList<Object>> subList = new ArrayList();
		for(int i = 0 ; i < dataList.size() ; i++){
			if(dataList.get(i).get(2).toString().equals("Y")){
				subList.add(dataList.get(i));
				sortCnt = 0;
				for(int j = 0 ; j < dataList.size(); j++){
					if(!dataList.get(j).get(2).toString().equals("Y") 
							&& dataList.get(i).get(3).toString().equals(dataList.get(j).get(3).toString())){
						sortCnt++;
						dataList.get(j).add(8, sortCnt);
						subList.add(dataList.get(j));
					}
				}
			}
		}
		for(int i= 0 ; i < dataList.size(); i++){
			sortCnt = 0;
			if(!dataList.get(i).get(2).toString().equals("Y")){
				for(int j = 0 ; j < subList.size(); j++){
					if(dataList.get(i).get(5).toString().equals(subList.get(j).get(5).toString()) 
							&& dataList.get(i).get(3).toString().equals(subList.get(j).get(3).toString())){
						chkCnt++;
					}
				}
				if(chkCnt == 0){
					sortCnt++;
					dataList.get(i).add(8, sortCnt);
					subList.add(dataList.get(i));
					for(int j = 0 ; j < dataList.size(); j++){
						if(!dataList.get(i).get(5).toString().equals(dataList.get(j).get(5).toString()) 
								&& dataList.get(i).get(3).toString().equals(dataList.get(j).get(3).toString())){
							sortCnt++;
							dataList.get(j).add(8, sortCnt);
							subList.add(dataList.get(j));
						}
					}
				}else{
					chkCnt = 0;
				}
			}
		}
		
		StringBuffer buf = new StringBuffer();
		for (List obj : subList) {
			int cnt = 0;
			String companyCode	= obj.get(0).toString();
			String isGroup		= obj.get(2).toString();
			String codeGroup	= obj.get(3).toString();
			String code 	 	= obj.get(5).toString();
			if("Y".equals(isGroup)){
				if(AccountUtil.checkNull(codeGroup)){
					resultObj.put("status", "V");
					return resultObj;
				}
				
				params.put("CompanyCode", companyCode);
				params.put("CodeGroup", codeGroup);
				params.put("Code", code);
				int duplCnt = (int)coviMapperOne.getNumber("baseCode.selectBaseCodeDuplCnt", params);
				
				if(duplCnt == 0 ){
					buf.append(codeGroup).append("','");// chkStr += CodeGroup +"','";
				}else{
					resultObj.put("status", "D");
					return resultObj;
				}
			}
		}
		chkStr =  buf.toString();
		
		for (List obj : subList) {
			int cnt = 0;
			
			String isGroup = obj.get(2).toString();
			if("Y".equals(isGroup)){
				params.put("CompanyCode",	obj.get(0).toString());
				params.put("IsGroup",		obj.get(2).toString());
				params.put("CodeGroup" ,	obj.get(3).toString());
				params.put("CodeGroupName",	obj.get(4).toString());
				params.put("IsUse",			obj.get(7).toString());
				params.put("Code",			obj.get(3).toString());
				params.put("CodeName",		obj.get(4).toString());
				params.put("SortKey",		"0");
			}else{
				params.put("CompanyCode",	obj.get(0).toString());
				params.put("IsGroup",		obj.get(2).toString());
				params.put("CodeGroup",		obj.get(3).toString());
				params.put("Code",			obj.get(5).toString());
				params.put("CodeName",		obj.get(6).toString());
				params.put("IsUse",			obj.get(7).toString());
				params.put("SortKey",		obj.get(8).toString());
				
				int grpCk = (int) coviMapperOne.getNumber("baseCode.checkBaseCodeGrpDetail", params);
				if(grpCk==0){
					if(chkStr.length() == 0){
						resultObj.put("status", "G");
						return resultObj;
					}else{
						String grpStr = chkStr.substring(0, chkStr.length()-3);
						String[] grpChk;
						grpChk = grpStr.split("','");
						for (int i = 0; i < grpChk.length; i ++){
							if(!obj.get(3).toString().equals(grpChk[i])){
								cnt =  -3;
								resultObj.put("status", "G");
								return resultObj;
							}
						}
					}
				}
			}

			String codeGroup = obj.get(3).toString();
			String code = params.getString("Code");
			String codeName = params.getString("CodeName");
			String sortKey = params.getString("SortKey");
			if(	AccountUtil.checkNull(codeGroup)	||
				AccountUtil.checkNull(code)			||
				AccountUtil.checkNull(codeName)		||
				AccountUtil.checkNull(sortKey)){
				cnt = -1;
				resultObj.put("status", "V");
				return resultObj;
			}else{
				int duplCnt = (int)coviMapperOne.getNumber("baseCode.selectBaseCodeDuplCnt", params);
				
				if(duplCnt != 0){
					cnt = -2;
					resultObj.put("status", "D");
					return resultObj;
				}
			}
			
			String subStr = "'";
			String newStr = "";
			newStr = obj.get(3).toString() + "," + obj.get(5).toString();
			if(subStr.indexOf(newStr) == -1){
				subStr += newStr+"'";
			}else{
				resultObj.put("status", "T");
				return resultObj;
			}
				
			if(cnt==-1){
				resultObj.put("status", "V");
				return resultObj;
			}else if(cnt==-2){
				resultObj.put("status", "D");
				return resultObj;
			}else if(cnt==-3){
				resultObj.put("status", "G");
				return resultObj;
			}
		}
		
		// index | (0) = 회사코드 | (1) = 회사명 | (2) = 코드그룹여부 | (3) = 코드그룹 | (4) = 코드그룹명 | (5) = 코드 | (6) = 코드명 | (7) = 사용여부 | 
		for (List obj : subList) {
			params.put("SessionUser", SessionHelper.getSession("UR_Code"));
			String isGroup = obj.get(2).toString();
			if("Y".equals(isGroup)){
				params.put("CompanyCode",	obj.get(0).toString());
				params.put("IsGroup",		obj.get(2).toString());
				params.put("CodeGroupName",	obj.get(4).toString());
				params.put("CodeGroup",		obj.get(3).toString());
				params.put("IsUse",			obj.get(7).toString());
				params.put("Code",			obj.get(3).toString());
				params.put("CodeName",		obj.get(4).toString());
				params.put("SortKey",		"0");
			}else{
				params.put("CompanyCode",	obj.get(0).toString());
				params.put("IsGroup",	obj.get(2).toString());
				params.put("CodeGroup",	obj.get(3).toString());
				params.put("Code",		obj.get(5).toString());
				params.put("CodeName",	obj.get(6).toString());
				params.put("IsUse",		obj.get(7).toString());
				params.put("SortKey",	obj.get(8).toString());
			}
			coviMapperOne.insert("baseCode.insertBaseCode", params);
			
			resultObj.put("status", "S");
		}
		return resultObj;
	}
	
	
	/**
	* @Method Name : jobjGetStr
	* @Description : JSON에서 값 획득
	* 				값이 없을시 에러가 발생하여 함수화
	*/
	private String jobjGetStr(CoviMap obj, String key) {
		String retVal = "";
		try{
			retVal = obj.getString(key);
		}
		catch(NullPointerException e){
			logger.error(e.getLocalizedMessage(), e);
		}
		catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
		}
		return retVal;
	}
	
	/**
	* @Method Name : jobjGetObj
	* @Description : JSON에서 값 획득
	* 				값이 없을시 에러가 발생하여 함수화
	* 				AccountUtil 로 이동
	*/
	private Object jobjGetObj(CoviMap obj, String key) {
		Object retVal = "";
		try{
			retVal = obj.get(key);
		}
		catch(NullPointerException e){
			logger.error(e.getLocalizedMessage(), e);
		}
		catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
		}
		return retVal;
	}

	/**
	* @Method Name : getCodeListByCodeGroup
	* @Description : 코드그룹에 속한 코드 목록 전체 조회
	*/
	@Override
	public CoviMap getCodeListByCodeGroup(CoviMap params) throws Exception {

		CoviList list = coviMapperOne.list("baseCode.selectCodeListByCodeGroup", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}

	/**
	* @Method Name : getBaseCodeName
	* @Description : code 값 통해 codename 반환
	*/
	@Override
	public CoviMap getBaseCodeName(CoviMap params) throws Exception {
		String CodeName = "";
		if(params.getString("codeGroup").equals("INVEST")) {
			CodeName = coviMapperOne.selectOne("baseCode.selectInvestBaseCodeNameByCode", params);
		} else {
			CodeName = coviMapperOne.selectOne("baseCode.selectBaseCodeNameByCode", params);
		}

		CoviMap resultList = new CoviMap();
		resultList.put("CodeName", CodeName == null ? "" : CodeName);
		return resultList;
	}
	
	/**
	* @Method Name : syncBaseCode
	* @Description : 기초코드 동기화
	*/
	@Override
	public CoviMap syncBaseCode(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		String viewCd = jobjGetStr(params,"viewCd");
		CoviList dataList = new CoviList();
		String fullViewCd = "";
		String fullViewNm = "";
		
		
		
		if("CC".equals(viewCd)){
			fullViewCd = "CompanyCode";
			//dataList = 회사코드 인터페이스 데이터 획득
		}
		else if("PT".equals(viewCd)){
			fullViewCd = "PayType";
			//dataList = 지급조건 인터페이스 데이터 획득
		}
		else if("TC".equals(viewCd)){
			fullViewCd = "TaxCode";
			//dataList = 세금코드 인터페이스 데이터 획득
		}
		else if("PM".equals(viewCd)){
			fullViewCd = "PayMethod";
			//dataList = 지급방법 인터페이스 데이터 획득
		}
		else if("IO".equals(viewCd)){
			fullViewCd = "IOCode";
			//dataList = WBS 인터페이스 데이터 획득
			internalOrderSync();
		}
		else if("OP".equals(viewCd)) {
			fullViewCd = "Opinet";
			opinetSync();
		}
		else{
			dataList = new CoviList();
		}
		
		
		if(!dataList.isEmpty()){
			//동기화 전 코드그룹 존재여부 확인후 없으면 코드그룹 생성
			CoviMap grpParam = new CoviMap();
			grpParam.put("CodeGroup", fullViewCd);
			int grpCk = (int) coviMapperOne.getNumber("baseCode.checkBaseCodeGrpDetail", grpParam);
			if(grpCk==0){
				grpParam.put("Code", fullViewCd);
				grpParam.put("SortKey", "0");
				grpParam.put("IsGroup", "Y");
				grpParam.put("IsUse", "Y");
				grpParam.put("CodeName", fullViewCd);
				grpParam.put("SessionUser", SessionHelper.getSession("UR_Code"));
	
				coviMapperOne.insert("baseCode.insertBaseCode", grpParam);
			}
			
			
			for(int i = 0 ; i < dataList.size() ; i++){
				CoviMap getItem = dataList.getMap(i);
				coviMapperOne.insert("baseCode.insertBaseCode", getItem);
			}
		}
		return resultObj;
	}
	
	public void opinetSync() throws Exception {
		CoviMap resultList = new CoviMap();
		RestTemplate restTemplate = new RestTemplate();
		
		try {
			JsonNode jsonNode = new ObjectMapper()
				.readTree(restTemplate.getForObject("http://www.opinet.co.kr/api/avgRecentPrice.do?out=json&prodcd=B027&code=F220523161", String.class))
				.get("RESULT")
				.get("OIL");
			
			for (int i = 0; i < jsonNode.size(); i++) {
				CoviMap coviMap = new CoviMap();
				coviMap.put("CompanyCode", "ORGROOT".equals(SessionHelper.getSession("DN_Code")) ? "ALL" : SessionHelper.getSession("DN_Code"));
				coviMap.put("CodeGroup", "Opinet"); 
				coviMap.put("Code", jsonNode.get(i).get("DATE").asText());
				coviMap.put("IsGroup", "N");
				coviMap.put("IsUse", "Y");
				coviMap.put("SortKey", "1");
				coviMap.put("CodeName", jsonNode.get(i).get("DATE").asText());
				coviMap.put("Reserved1", jsonNode.get(i).get("PRICE").asText());
				coviMap.put("Reserved2", jsonNode.get(i).get("PRODCD").asText());
				coviMap.put("SessionUser", SessionHelper.getSession("UR_Code"));
				int cnt = (int) coviMapperOne.getNumber("baseCode.selectBaseCodeDuplCnt", coviMap);
				if (cnt == 0) {
					coviMapperOne.insert("baseCode.insertBaseCode", coviMap);
				}
			}
		} catch(NullPointerException e){
			resultList.put("status", Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			resultList.put("status", Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
	}
	
	public CoviMap internalOrderSync() throws Exception {
		CoviMap interfaceParam		= new CoviMap();
		CoviMap resultList		= new CoviMap();
		BaseCodeVO baseCodeVO		= null;
		
		try{
			//String syncType = accountUtil.getPropertyInfo("account.syncType.BaseCodeIO");			
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "BaseCodeIO");
			
			interfaceParam.put("interFaceType",			syncType);
			interfaceParam.put("daoClassName",			"BaseCodeDao");
			interfaceParam.put("voClassName",			"BaseCodeVO");
			interfaceParam.put("mapClassName",			"BaseCodeMap");
	
			interfaceParam.put("daoSetFunctionName",	"setBaseCodeList");
			interfaceParam.put("daoGetFunctionName",	"getBaseCodeList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			switch (syncType) {
				case "DB":
					//searchProperty이 DB인 경우 이곳에 정의
					break;
		
				case "SOAP":
					//searchProperty이 SOAP인 경우 이곳에 정의
					break;
					
				case "SAP":
					//searchProperty이 SAP인 경우 이곳에 정의
						String pernr	= "";
						String logid	= "";
						String ename	= "";
						String bukrs	= "";
						String scrno	= "";
						String no_mask	= "";
						String spras	= "";
						String i_aufnr	= "";
						String i_auart	= "";
						String i_ktext	= "";
		
						CoviMap setValues = new CoviMap();
						
						setValues.put("PERNR",		pernr);
						setValues.put("LOGID",		logid);
						setValues.put("ENAME",		ename);
						setValues.put("BUKRS",		bukrs);
						setValues.put("SCRNO",		scrno);
						setValues.put("NO_MASK",	no_mask);
						setValues.put("SPRAS",		spras);
						setValues.put("I_AUFNR",	i_aufnr);
						setValues.put("I_AUART",	i_auart);
						setValues.put("I_KTEXT",	i_ktext);
		
						ArrayList getValues = new ArrayList();
						//getValues.add("get1");
						//getValues.add("get2");
						//getValues.add("get3");
						interfaceParam.put("mapFunctionName",	"getSapMap");
						interfaceParam.put("tableName",			"");
						interfaceParam.put("sapFunctionName",	"ZFI_IF_F6001_SEND");
						interfaceParam.put("setValues",			setValues);
						interfaceParam.put("getValues",			getValues);
					break;
				case "SAPOdata":
					//syncType이 SAPOdata인 경우 이곳에 정의
					String sGetParam = "";
					interfaceParam.put("mapFunctionName",		"getSapODataIOMap");					
					sGetParam = accountUtil.addGetParam(sGetParam,"CompanyCode",RedisDataUtil.getBaseConfig("SAPCompanyCode", SessionHelper.getSession("DN_ID")),"eq","and");
					sGetParam = accountUtil.addGetParam(sGetParam,"ControllingArea","A000","eq","and");			
					interfaceParam.put("SAPOdataFuntionName", "API_FINWBSELEMENT_SRV/A_FinWBSElement");
					interfaceParam.put("SAPOdataParam", sGetParam);								
					break;
				default :
					break;
			}
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
			
			ArrayList list = (ArrayList) getInterface.get("list");
			
			String sessionUser = SessionHelper.getSession("UR_Code");			
			int iListSize = list.size();			
			for (int i = 0; i < iListSize; i++) {
				CoviMap listInfo = new CoviMap();
				
				baseCodeVO = (BaseCodeVO) list.get(i);
				String totalCount		= baseCodeVO.getTotal();
				
				String baseCodeID		= baseCodeVO.getBaseCodeID();
				String codeGroup		= baseCodeVO.getCodeGroup();
				String code				= baseCodeVO.getCode();
				String codeName			= baseCodeVO.getCodeName();
				String isGroup			= baseCodeVO.getIsGroup();
				String isUse			= baseCodeVO.getIsUse();
				String sortKey			= baseCodeVO.getSortKey();
				String description		= baseCodeVO.getDescription();
				String reserved1		= baseCodeVO.getReserved1();
				String reserved2		= baseCodeVO.getReserved2();
				String reserved3		= baseCodeVO.getReserved3();
				String reserved4		= baseCodeVO.getReserved4();
				String reservedInt		= baseCodeVO.getReservedInt();
				String reservedFloat	= baseCodeVO.getReservedFloat();
				String isSync			= baseCodeVO.getIsSync();
				String registerID		= baseCodeVO.getRegisterID();
				String registDate		= baseCodeVO.getRegistDate();
				String modifierID		= baseCodeVO.getModifierID();
				String modifyDate		= baseCodeVO.getModifyDate();
				String total			= baseCodeVO.getTotal();        
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				if(codeGroup.equals(""))
					codeGroup = "IOCode";
				
				if(isUse.equals(""))
					isUse = "Y";
				
				if(isGroup.equals(""))
					isGroup = "N";
				
				if(description.equals(""))
					description= codeName;
				
				listInfo.put("BaseCodeID",		baseCodeID);
				listInfo.put("CodeGroup",		codeGroup);
				listInfo.put("Code",			code);
				listInfo.put("CodeName",		codeName);
				listInfo.put("IsGroup",			isGroup);
				listInfo.put("IsUse",			isUse);
				listInfo.put("SortKey",			sortKey);
				listInfo.put("Description",		description);
				listInfo.put("Reserved1",		reserved1);
				listInfo.put("Reserved2",		reserved2);
				listInfo.put("Reserved3",		reserved3);
				listInfo.put("Reserved4",		reserved4);
				listInfo.put("ReservedInt",		reservedInt);
				listInfo.put("ReservedFloat",	reservedFloat);
				listInfo.put("IsSync",			isSync);
				listInfo.put("RegisterID",		registerID);
				listInfo.put("RegistDate",		registDate);
				listInfo.put("ModifierID",		modifierID);
				listInfo.put("ModifyDate",		modifyDate);
				listInfo.put("SessionUser",		sessionUser);
				
				baseCodeInterfaceSave(listInfo);
			}
			resultList.put("status",	getInterface.get("status"));
		} catch(NullPointerException e){
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
					
		return resultList;
		
	}
	
	/**
	 * @Method Name : baseCodeInterfaceSave
	 * @Description : BasCode 동기화 저장
	 */
	private void baseCodeInterfaceSave(CoviMap map) {
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("baseCode.getBaseCodeInterfaceSaveCnt", map);

		if (cnt == 0) {
			coviMapperOne.insert("baseCode.baseCodeInterfaceInsert", map);
		} else {
			coviMapperOne.update("baseCode.baseCodeInterfaceUpdate", map);
		}
	}

	/**
	 * @Method Name : selectIOCodeMaxSortKey
	 * @Description : IOCode SortKey 최대값
	 */
	public int selectIOCodeMaxSortKey() throws Exception {
		int cnt = 0;
		
		cnt = (int) coviMapperOne.getNumber("baseCode.selectMaxSortKey", null);
		
		return cnt;
	}
	
	public String selectBaseCodeByCodeName(CoviMap params) throws Exception {
		return coviMapperOne.getString("baseCode.selectBaseCodeByCodeName", params);
	}
}
