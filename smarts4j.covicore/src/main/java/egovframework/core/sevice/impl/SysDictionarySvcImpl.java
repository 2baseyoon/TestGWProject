package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.stereotype.Service;

import egovframework.core.sevice.SysDictionarySvc;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpURLConnectUtil;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("sysDictionaryService")
public class SysDictionarySvcImpl extends EgovAbstractServiceImpl implements SysDictionarySvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	// 그리드에 사용할 데이터 Select
	@Override
	public CoviMap selectGrid(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("admin.sys.DictionaryManage.selectgridcnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("admin.sys.DictionaryManage.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DicID,DomainID,DicCode,DicSection,DisplayName,KoShort,KoFull,EnShort,EnFull,JaShort,JaFull,ZhShort,ZhFull,Lang1Short,Lang1Full,Lang2Short,Lang2Full,Lang3Short,Lang3Full,Lang4Short,Lang4Full,Lang5Short,Lang5Full,Lang6Short,Lang6Full,ReservedStr,ReservedInt,IsUse,IsCaching,Description,RegisterCode,RegisterName,ModifierCode,ModifyDate"));
		return resultList;
	}
	
	// 추가 시 데이터 Insert
	@Override
	public Object insert(CoviMap params)throws Exception {
		return coviMapperOne.insertWithPK("admin.sys.DictionaryManage.insert", params);
	}
	
	// 수정 및 조회를 위한 단일 건 조회
	@Override
	public CoviMap selectOne(CoviMap params) throws Exception {
		
		CoviMap map = coviMapperOne.select("admin.sys.DictionaryManage.selectone", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "DicID,DomainID,DicCode,DicSection,KoShort,KoFull,EnShort,EnFull,JaShort,JaFull,ZhShort,ZhFull,IsUse,Description,RegisterCode,RegistDate,ModifierCode,ModifyDate"));
		return resultList;
	}

	// redis cache를 위한 단일건 문자열 조회
	@Override
	public String selectOneString(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.sys.DictionaryManage.selectone", params);
		//map -> json string으로 저장
		ObjectMapper mapperObj = new ObjectMapper();
		return mapperObj.writeValueAsString(map);
	}
	
	// redis cache를 위한 단일건 Map 조회
	@Override
	public CoviMap selectOneObject(CoviMap params) throws Exception {
		return coviMapperOne.select("admin.sys.DictionaryManage.selectone", params);
	}
	
	// 수정 시 데이터 update
	@Override
	public int update(CoviMap params)throws Exception {
		return coviMapperOne.update("admin.sys.DictionaryManage.update", params);
	}
	
	// 사용유무 update
	@Override
	public int updateIsUse(CoviMap params)throws Exception{
		return coviMapperOne.update("admin.sys.DictionaryManage.updateIsUse", params);
	};
	
	// 데이터 삭제
	@Override
	public int delete(CoviMap params)throws Exception {
		return coviMapperOne.delete("admin.sys.DictionaryManage.delete", params);
	}

	// 엑셀 다운로드 데이터 조회
	@Override
	public CoviMap selectExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.sys.DictionaryManage.selectgrid", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DicSection,DisplayName,DicCode,KoFull,EnFull,JaFull,ZhFull,RegisterName,IsUse,ModifyDate"));		
		return resultList;
	}
	
	// 네이버 번역 API
	@Override
	public String translate(String sourceLang, String targetLang, String pText)	throws Exception {
		String ret = "";
		/*
		 * 네이버 기계번역 API 연결 계정 정보
		 * covision_ywcho@naver.com
		 * 본인확인용 ywcho@covision.co.kr
		 * 비번 : Covi@ZC!rj
		 * */
	
		HttpURLConnectUtil url = new HttpURLConnectUtil();
		
		CoviMap resJson = url.translateAPI(sourceLang, targetLang, pText);
			
		ret = resJson.getJSONObject("message").getJSONObject("result").getString("translatedText");

		return ret;
	}
	
}
