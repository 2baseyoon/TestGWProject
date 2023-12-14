package egovframework.covision.legacy.data;
////// Legacy Framework Sample MAPPER

import egovframework.baseframework.data.*;
import org.egovframe.rte.psl.dataaccess.EgovAbstractMapper;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.annotation.Resource;
import org.apache.ibatis.session.SqlSessionFactory;
import egovframework.baseframework.data.CoviList;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Repository;

@Repository("CoviMapperLegacyOne")
public class CoviMapperLegacyOne extends EgovAbstractMapper
{
	 @Resource(name = "sessionLegacyOne")
	  public void setSqlSessionFactory(SqlSessionFactory sqlSession) { super.setSqlSessionFactory(sqlSession); }
	 
	  public CoviMap select(String id, CoviMap params) throws DataAccessException {
	    CoviMap result;
	    Object obj = getSqlSession().selectOne(id, params);
	    
	    if (obj != null) {
	      result = (CoviMap)obj;
	    } else {
	      result = new CoviMap();
	    } 
	    
	    return result;
	  }

	  public CoviList list(String id, CoviMap params) throws DataAccessException {
	    CoviList result;
	    List list = getSqlSession().selectList(id, params);
	    
	    if (list != null) {
	      result = new CoviList(list);
	    } else {
	      result = new CoviList();
	    } 
	    return result;
	  }

	  public CoviList arrayList(String id, CoviMap params) throws DataAccessException {
	    CoviList result;
	    List list = (ArrayList)getSqlSession().selectList(id, params);
	    
	    if (list != null) {
	      result = new CoviList();
	      
	      for (int i = 0; i < list.size(); i++) {
	        result.add(list.get(i));
	      }
	    } else {
	      
	      result = new CoviList();
	    } 
	    return result;
	  }
	  
	  public Set<String> hashSetList(String id, CoviMap params) throws Exception {
	    Set<String> ret = new HashSet<String>();
	    
	    CoviMap map = new CoviMap();

	    ArrayList list = (ArrayList)getSqlSession().selectList(id, params);
	    
	    if (list != null)
	    {
	      for (int i = 0; i < list.size(); i++) {
	        
	        map = (CoviMap)list.get(i);
	        
	        ret.add(map.getString("URL"));
	      } 
	    }

	    return ret;
	  }

	  public Object insertWithPK(String id, CoviMap params) throws DataAccessException { return Integer.valueOf(getSqlSession().insert(id, params)); }
	  public int insert(String id, CoviMap params) throws DataAccessException { return getSqlSession().insert(id, params); }
	  public int update(String id, CoviMap params) throws DataAccessException { return getSqlSession().update(id, params); }
	  public int delete(String id, CoviMap params) throws DataAccessException { return getSqlSession().delete(id, params); }
	  public long getNumber(String id, CoviMap params) throws DataAccessException { return ((Long)getSqlSession().selectOne(id, params)).longValue(); }
	  public String getString(String id, CoviMap params) throws DataAccessException { return (String)getSqlSession().selectOne(id, params); }
	
}