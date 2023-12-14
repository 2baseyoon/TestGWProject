package egovframework.core.sevice.impl;

import java.util.Iterator;
import java.util.Set;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.core.sevice.MenuAdminMenuSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("menuAdminMenuService")
public class MenuAdminMenuSvcImpl extends EgovAbstractServiceImpl implements MenuAdminMenuSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * 그리드에 사용할 데이터 Select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap select(CoviMap params, int pno) throws Exception {
		
		/*
		 * select 해 온 list를 tree형태의 데이터로 만드는 코드 필요
		 * */
		
		CoviList clist = coviMapperOne.list("menu.admin.selectgrid", params);
		//int cnt = (int) coviMapperOne.getNumber("sys.baseconfig.selectgridcnt", params);

		
		CoviMap resultList = new CoviMap();
		resultList.put("list", drawTree(clist, "CN_ID,ContainerType,Alias,DisplayName,LinkSystem,MemberOf,ContainerPath,SortKey,SortPath,IsURL,IsUse,RegDate,ChildCount,PgSection,PGName,PG_ID,ProgramURL,DIC_ID,koShortWord,enShortWord,jaShortWord,zhShortWord,ReservedShortWord1,ReservedShortWord2", pno));
		//resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * 추가 시 데이터 Insert
	 * @param params - CoviMap
	 * @return Object
	 * @throws Exception
	 */
	@Override
	public Object insert(CoviMap paramCN, String paramGR, CoviMap paramDic)throws Exception {
		Object retObj = null;
		
		//AOP로 transaction 처리가 걸려 있는 곳(impl)
		/*
		 * 확인 후 처리 할 잔여사항
		 * 1. Alias 중복체크
		 * Top / TopSub 메뉴는 Alias를 반드시 지정해야 함.
		 * Top / TopSub 메뉴의 경우 Alias가 Top 메뉴들 간에서 유일해야 함. -> Alias 중복 체크
		 * 2. SortPath, ContainerPath가 필요한 경우 Function 정리가 필요
		 * */
		
		CoviMap params = new CoviMap();
		params.put("memberOf", paramCN.get("memberOf"));
		//1. SortKey 값 가져오기
		int maxSortKey = (int)coviMapperOne.getNumber("menu.admin.selectMaxSortKey", params);
		paramCN.put("sortKey", maxSortKey + 1); //Sortkey 생성 로직을 삽입할 것
		//2. CN insert
		retObj = coviMapperOne.insert("menu.admin.insertCN", paramCN);
		String cnID = paramCN.get("CN_ID").toString();
		//3. 다국어 insert
		paramDic.put("dicCode", "CN_" + cnID);
		retObj = coviMapperOne.insert("menu.admin.insertDic", paramDic);
		//4. 권한 insert
		//반복문 구현이 필요
		String[] arrGR = paramGR.split("[;]");
		for (String gr : arrGR) {
			if (gr != null && gr.length() != 0) {
				CoviMap grMap = new CoviMap();
				grMap.put("cnID", Integer.parseInt(cnID));
				grMap.put("grID", Integer.parseInt(gr));
				retObj = coviMapperOne.insert("menu.admin.insertGR", grMap);	
			}
		}
		
		return retObj;
	}
	
	/**
	 * 수정 및 조회를 위한 단일 건 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectOne(CoviMap params) throws Exception {
		
		CoviMap map = coviMapperOne.select("menu.admin.selectone", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "CN_ID,ContainerType,Alias,DisplayName,MemberOf,ContainerPath,SortKey,IsURL,URL,RegDate,PGName,ProgramURL,PgSection,ProgramURL,ProgramType,PgDescription,Description,DIC_ID,koShortWord,enShortWord,jaShortWord,zhShortWord,ReservedShortWord1,ReservedShortWord2"));
		return resultList;
	}
	
	/**
	 * 수정 및 조회를 위한 단일 건 조회
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAuth(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("menu.admin.selectAuth", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GrID,GrName,GrType"));
		return resultList;
	}
	
	/**
	 * 데이터 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public Object update(CoviMap paramCN, String paramGR, CoviMap paramDic)throws Exception {
		Object retObj = null;
		
		String cnID = paramCN.get("cnID").toString();
		String[] arrGR = paramGR.split("[;]");
		
		//1. CN update
		retObj = coviMapperOne.update("menu.admin.updateCN", paramCN);
		//2. 다국어 update
		retObj = coviMapperOne.update("menu.admin.updateDic", paramDic);
		//3. 권한 update 
		//delete -> insert
		//반복문 구현이 필요
		//delete
		CoviMap grDelMap = new CoviMap();
		grDelMap.put("cnID", Integer.parseInt(cnID));
		retObj = coviMapperOne.delete("menu.admin.deleteGR", grDelMap);
		//insert
		for (String gr : arrGR) {
			if (gr != null && gr.length() != 0) {
				CoviMap grAddMap = new CoviMap();
				grAddMap.put("cnID", Integer.parseInt(cnID));
				grAddMap.put("grID", Integer.parseInt(gr));
				retObj = coviMapperOne.insert("menu.admin.insertGR", grAddMap);	
			}
		}
		
		return retObj;
	}
	
	/**
	 * 사용유무 update
	 * @param params - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public Object updateIsUse(CoviMap params)throws Exception{
		
		/*
		 * 1. 해당 메뉴 - O
		 * 2. 하위 메뉴
		 * 3. 해당 메뉴의 다국어 - X
		 * 4. 하위 메뉴의  다국어  - X
		 * */
		//하위 메뉴의 CN_ID 가져오기
		String cnID = params.get("cnID").toString();
		String isUse = params.get("isUse").toString();
		
		CoviMap paramMember = new CoviMap();
		paramMember.put("cnID", Integer.parseInt(cnID));
		
		CoviList clist = coviMapperOne.list("menu.admin.selectMember", paramMember);
		
		String cnIDs = "";
		if(null != clist && clist.size() > 0){
			for(int i=0; i < clist.size(); i++){
				if(i==0){
					cnIDs = "," + clist.getMap(i).getString("CN_ID");
				}else{
					cnIDs = cnIDs + "," + clist.getMap(i).getString("CN_ID");
				}
			}
		}
		
		CoviMap paramIsUse = new CoviMap();
		paramIsUse.put("cnIDs", cnID + cnIDs);
		paramIsUse.put("isUse", isUse);
		
		return coviMapperOne.update("menu.admin.updateIsUse", paramIsUse);
	};
	
	/**
	 * 데이터 삭제
	 * @param params - CoviMap
	 * @return int - delete 결과 상태
	 * @throws Exception
	 */
	@Override
	public int delete(CoviMap params)throws Exception {
		return coviMapperOne.delete("menu.admin.delete", params);
	}
	
	private static CoviList drawTree(CoviList clist, String str, int memberOf) throws Exception {
		CoviList returnArray = new CoviList();
		String [] cols = str.split(",");
		
		/*
		 * ContainerPath 값이 빈값인 경우 - 1 depth
		 * MemberOf 값이 0인 경우 - 1 depth
		 * 1 depth를 먼저 그리고,
		 * 
		 * */
		if(null != clist && clist.size() > 0){
			
				for(int i=0; i < clist.size(); i++){
					
					CoviMap newObject = new CoviMap();
					
					//1 depth만 그림
					if ( Integer.parseInt(clist.getMap(i).getString("MemberOf")) == memberOf){
						for(int j=0; j < cols.length; j++){
							Set<String> set = clist.getMap(i).keySet();
							Iterator<String> iter = set.iterator();
							
							while(iter.hasNext()){   
								Object ar = iter.next();
								//String ar = (String)iter.next();
								if(ar.equals(cols[j].trim())){
									newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
								}
							}
							
							//open:true, subTree:[]
							//open 옵션의 동작여부 불분명 확인이 필요
							newObject.put("open", false);
							
							//expand 아이콘의 표시 여부를 결정
							if(Integer.parseInt(clist.getMap(i).getString("ChildCount")) > 0){
								newObject.put("__subTree", true);
							} else{
								newObject.put("__subTree", false);
							}
						}
						returnArray.add(newObject);
					}
				}
			}
		return returnArray;
	}
	
}
