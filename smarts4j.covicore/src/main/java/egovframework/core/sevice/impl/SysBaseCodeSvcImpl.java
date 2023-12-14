package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.stereotype.Service;

import egovframework.core.sevice.SysBaseCodeSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("sysBaseCodeService")
public class SysBaseCodeSvcImpl extends EgovAbstractServiceImpl implements SysBaseCodeSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * 그리드에 사용할 데이터 Select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap select(CoviMap params) throws Exception {
		CoviMap page = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("basecode.selectgridcnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("basecode.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CodeID,BizSection,BizSectionName,DomainID,DisplayName,CodeGroup,Code,SortKey,IsUse,CodeName,Reserved1,Reserved2,Reserved3,ReservedInt,Description,RegisterCode,RegisterName,ModifierCode,ModifyDate"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	/**
	 * 추가 시 데이터 Insert
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public Object insert(CoviMap params)throws Exception {
		return coviMapperOne.insertWithPK("basecode.insertgrid", params);
	}
	
	/**
	 * 수정 및 조회를 위한 단일 건 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectOne(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("basecode.selectone", params);
		CoviMap resultList = new CoviMap();
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "CodeID,BizSection,BizSectionName,DomainID,DisplayName,CodeGroup,Code,SortKey,IsUse,CodeName,MultiCodeName,Reserved1,Reserved2,Reserved3,ReservedInt,Description,RegisterCode,RegisterName,ModifierCode,ModifyDate"));
		return resultList;
	}
	
	@Override
	public String selectOneString(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("basecode.selectone", params);
		//map -> json string으로 저장
		ObjectMapper mapperObj = new ObjectMapper();
		return mapperObj.writeValueAsString(map);
	}
	
	@Override
	public CoviMap selectOneObject(CoviMap params) throws Exception {
		return coviMapperOne.select("basecode.selectone", params);
	}
	
	/**
	 * 데이터 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int update(CoviMap params)throws Exception {
		return coviMapperOne.update("basecode.updategrid", params);
	}
	
	/**
	 * 사용유무 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsUse(CoviMap params)throws Exception{
		return coviMapperOne.update("basecode.updateIsUse", params);
	};
	
	/**
	 * 데이터 삭제
	 * @param params - CoviMap
	 * @return int - delete 결과 상태
	 * @throws Exception
	 */
	@Override
	public int delete(CoviMap params)throws Exception {
		return coviMapperOne.delete("basecode.deletegrid", params);
	}

	@Override
	public int selectForCheckingDouble(CoviMap params) throws Exception {
		int cnt = (int) coviMapperOne.getNumber("basecode.selectForCheckingDouble", params);
		return cnt;
	}

	@Override
	public CoviMap selectExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("basecode.selectgrid", params);

		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DisplayName,BizSectionName,CodeGroup,Code,CodeName,SortKey,Description,RegisterName,IsUse,RegistDate,ModifyDate"));
		return resultList;
	}
	
	@Override
	public CoviMap selectBaseCodeGroupObject(CoviMap params) throws Exception {
		CoviList map = coviMapperOne.list("basecode.selectBaseCodeGroup", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(map, "BizSection,BizSectionName"));
		return resultList;
	}
	
	@Override
	public CoviMap selectCodeGroupList(CoviMap params) throws Exception {
		CoviMap page = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("basecode.selectCodeGroupCnt", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("basecode.selectCodeGroupList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DomainID,DomainName,BizSectionName,CodeGroup,CodeGroupName"));
		resultList.put("page", page);
		
		return resultList;
	}
}
