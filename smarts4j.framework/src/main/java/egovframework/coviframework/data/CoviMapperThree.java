package egovframework.coviframework.data;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.annotation.Resource;

import org.apache.ibatis.session.SqlSessionFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Repository;

import egovframework.baseframework.util.SessionHelper;
import org.egovframe.rte.psl.dataaccess.EgovAbstractMapper;

import egovframework.baseframework.data.CoviCommonRepository;
import egovframework.baseframework.data.CoviMapperOne;

/**
 * Mybatis Mapper 설정 파일 정보
 * db.properties			> db.mapper.three.sql, db.mapper.three.datasource
 * context-datasource.xml	> dataSourceThree
 * mapper-three-config.xml	
 * 
 */
@Repository("coviMapperThree")
public class CoviMapperThree extends CoviMapperOne implements CoviCommonRepository {
	
	@Resource(name = "sqlSessionThree")
	public void setSqlSessionFactory(SqlSessionFactory sqlSession) {
		super.setSqlSessionFactory(sqlSession);
	}
}
