package egovframework.covision.coviflow.legacy.util;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.annotation.Resource;

import org.apache.ibatis.session.SqlSessionFactory;
import org.json.simple.JSONArray;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Repository;

import egovframework.baseframework.data.CoviCommonRepository;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import org.egovframe.rte.psl.dataaccess.EgovAbstractMapper;

/**
 * Mybatis Mapper 설정 파일 정보
 * db.properties			> db.mapper.one.sql, db.mapper.one.datasource
 * context-datasource.xml	> dataSourceOne
 * mapper-one-config.xml	
 * 
 */
//JTA(Transaction) 사용시 아래 설정
public class CoviMapperLegacyFramework{
	
}
/*
@Repository("coviMapperLegacyFramework")
public class CoviMapperLegacyFramework extends EgovAbstractMapper implements CoviCommonRepository {
	
	@Resource(name = "sqlSessionLegacyFramework")
	public void setSqlSessionFactory(SqlSessionFactory sqlSession) {
		super.setSqlSessionFactory(sqlSession);
	}
	
	public CoviMap select(String id, CoviMap params) throws DataAccessException {

		CoviMap result;
		Object obj = getSqlSession().selectOne(id, params);
		
		if (obj != null) 
			result = (CoviMap)obj;
		else
			result = new CoviMap();
		
		
		return result;
	}

	public CoviList list(String id, CoviMap params) throws DataAccessException {
		CoviList result;
		
		@SuppressWarnings("rawtypes")
		List list = getSqlSession().selectList(id, params);

		if (list != null) 
			result = new CoviList(list);
		else
			result = new CoviList();

		return result;
	}
	
	
	public JSONArray arrayList(String id, CoviMap params) throws DataAccessException {
		JSONArray result;
		
		@SuppressWarnings("rawtypes")
		List list = (ArrayList) getSqlSession().selectList(id, params);
		
		if (list != null){
			result = new JSONArray();
			
			for(int i=0; i < list.size(); i++){
				result.add(list.get(i));
			}
			
		}else{
			result = new JSONArray();
		}
		return result;
	}
	
	public Set<String> hashSetList(String id, CoviMap params) throws Exception {
		Set<String> ret = new HashSet<>();
		
		CoviMap map = new CoviMap();
		
		@SuppressWarnings("rawtypes")
		ArrayList list = (ArrayList) getSqlSession().selectList(id, params);
		
		if (list != null){
			
			for(int i=0; i < list.size(); i++){
				
				map = (CoviMap) list.get(i);
				
				ret.add(map.getString("URL"));
				
			}
			
		}
		
		return ret;
	}
	

	// selectKey를 사용해서 키 값을 가져올 경우 사용한다.
	public Object insertWithPK(String id, CoviMap params) throws DataAccessException {
		Object result = getSqlSession().insert(id, params);
		return result;
	}
	
	public int insert(String id, CoviMap params) throws DataAccessException {
		return getSqlSession().insert(id, params);
	}

	public int update(String id, CoviMap params) throws DataAccessException {
		return getSqlSession().update(id, params);
	}

	public int delete(String id, CoviMap params) throws DataAccessException {
		return getSqlSession().delete(id, params);
	}

	// * count 같이 단일 숫자를 가져올때 사용.
	public long getNumber(String id, CoviMap params) throws DataAccessException {
		return (Long)getSqlSession().selectOne(id, params);
	}
	
	// * 단일 데이터를 가져올때 사용.
	public String getString(String id, CoviMap params) throws DataAccessException {
		return (String)getSqlSession().selectOne(id, params);
	}
	
}
*/