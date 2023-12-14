package egovframework.covision.coviflow.legacy.service.impl;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.coviflow.legacy.service.LegacyInterfaceSvc;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.mapping.ParameterMap;
import org.apache.ibatis.mapping.ParameterMapping;
import org.apache.ibatis.mapping.ResultMap;
import org.apache.ibatis.mapping.ResultMapping;
import org.apache.ibatis.mapping.SqlCommandType;
import org.apache.ibatis.mapping.StatementType;
import org.apache.ibatis.scripting.defaults.RawSqlSource;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.apache.ibatis.type.JdbcType;
import egovframework.coviframework.service.ExtDatabasePoolSvc;


@Service
public class LegacyInterfaceSQLImpl extends LegacyInterfaceCommon implements LegacyInterfaceSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private ExtDatabasePoolSvc extDatabasePoolService;
	
	@Override
	public void call() throws Exception {
		this.logParam.get().put("ActionValue", legacyInfo.get().optString("SqlClause"));
		CoviMap result = executeSql(this.legacyInfo.get(), this.legacyParams.get());
	}

	/**
	 * 
	 * @param poolName - 관리자페이지 외부DB연계설정 Pool Name
	 * @param queryType - SQL,SP
	 * @param sqlType - SELECT,UPDATE,INSERT,DELETE
	 * @param sql - 실행 쿼리문
	 * @param parameter - 쿼리문의 파라미터 #{name}
	 * @return CoviMap.get(sqlType)
	 * @throws Exception
	 */
	@SuppressWarnings("resource")
	private CoviMap executeSql(CoviMap legacyInfo, CoviMap parameter) throws Exception {
		
		String DatasourceSeq = legacyInfo.optString("PoolName");	// 외부Db연계설정의 Pool Name
		CoviMap params = new CoviMap();
		params.put("datasourceSeq", DatasourceSeq);
		CoviMap map = coviMapperOne.select("framework.datasource.selectDatasource", params);
		String connectionPoolName = map.getString("ConnectionPoolName");
		
		String queryType = legacyInfo.optString("IfType");	// SQL,SP
		String sqlType = legacyInfo.optString("SqlType");	// SELECT,UPDATE,INSERT,DELETE
		String sql = legacyInfo.optString("SqlClause");			// 실행쿼리문
		if(sql != null && sql.endsWith(";")) {
			sql = sql.substring(0, sql.lastIndexOf(";"));
		}
		CoviMap result = new CoviMap();
		
		Connection conn = null; // Pooled connection.
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		Configuration configuration = null;
		SqlSessionFactory factory = null;
		SqlSession session = null;
		try {	
			// Get DBCP Connection from pool. 
			conn = extDatabasePoolService.getConnection(connectionPoolName);
			if(conn == null) {
				throw new Exception("[" + connectionPoolName + "] pool is not bound in this Context.");
			}
			// Make param, result statement setting.
			configuration = new Configuration();
			configuration.setCallSettersOnNulls(true); // null인 컬럼도 가져오는 설정 // configuration.isCallSettersOnNulls();
			configuration.setJdbcTypeForNull(JdbcType.NULL); //configuration.getJdbcTypeForNull();
			
			factory = new SqlSessionFactoryBuilder().build(configuration);
			
			// Unique sql id.
			String sqlName = UUID.randomUUID().toString();
			
			RawSqlSource sqlBuilder = new RawSqlSource(configuration, sql, Map.class); // java.util.Map.class
			
			if(queryType.equalsIgnoreCase("SP")) {
				sqlType = "UPDATE";
			}
			
			MappedStatement.Builder statementBuilder;
			switch(sqlType.toUpperCase()) {
				case "SELECT": statementBuilder = new MappedStatement.Builder( configuration, sqlName, sqlBuilder, SqlCommandType.SELECT ); break;
				case "UPDATE": statementBuilder = new MappedStatement.Builder( configuration, sqlName, sqlBuilder, SqlCommandType.UPDATE ); break;
				case "INSERT": statementBuilder = new MappedStatement.Builder( configuration, sqlName, sqlBuilder, SqlCommandType.INSERT ); break;
				case "DELETE": statementBuilder = new MappedStatement.Builder( configuration, sqlName, sqlBuilder, SqlCommandType.DELETE ); break;
				default: statementBuilder = new MappedStatement.Builder( configuration, sqlName, sqlBuilder, SqlCommandType.UNKNOWN ); break;
			}
			
			// statementType : STATEMENT, PREPARED(default), CALLABLE
			if(queryType.equalsIgnoreCase("SP")) {
				statementBuilder.statementType(StatementType.CALLABLE);
			}
			
			// Parameter type
			List<ParameterMapping> parameterMappings = new ArrayList<ParameterMapping>();
			ParameterMap.Builder inlineParameterMapBuilder = new ParameterMap.Builder(configuration, statementBuilder.id() + "-Inline", Map.class, parameterMappings); // java.util.Map.class
			statementBuilder.parameterMap(inlineParameterMapBuilder.build());
			
			
			// Result type
			List<ResultMapping> resultMappings = new ArrayList<ResultMapping>();
			List<ResultMap> resultMaps = new ArrayList<ResultMap>();
			switch(sqlType.toUpperCase()) {
				case "SELECT": resultMaps.add( new ResultMap.Builder( configuration, "", Map.class, resultMappings ).build( ) ); break;
				default: resultMaps.add( new ResultMap.Builder( configuration, "", Integer.class, resultMappings ).build( ) ); break;
			}
			statementBuilder.resultMaps(resultMaps);
			
			
			MappedStatement statement = statementBuilder.build();
			configuration.addMappedStatement( statement );
			// Parametered statement prepare end.

			// Prepare SqlSession using Connection.
			conn.setAutoCommit(false);
			session = factory.openSession(conn);
			
			// Execute Statement.
			switch(sqlType.toUpperCase()) {
				case "SELECT": 
					@SuppressWarnings("rawtypes")
					List list = session.selectList(sqlName, parameter);
					if (list != null) result.put(sqlType, new CoviList(list));
					else result.put(sqlType, new CoviList());
					break;
				case "UPDATE": 
					result.put(sqlType, session.update(sqlName, parameter));
					break;
				case "INSERT": 
					result.put(sqlType, session.insert(sqlName, parameter));
					break;
				case "DELETE": 
					result.put(sqlType, session.delete(sqlName, parameter));
					break;
				default :
					throw new Exception(sqlType +" is not supported.");
			}
			
			// 리턴값 체크
			String outStatusKey = legacyInfo.optString("OutStatusKey");			// RESULT - out status 키
			String outCompareType = legacyInfo.optString("OutCompareType");		// E - out parameter 비교조건 - E : 같을때 성공 , NE : 다를떄 성공
			String outCompareValue = legacyInfo.optString("OutCompareValue");	// S - out parameter 비교값
			String outMsgKey = legacyInfo.optString("OutMsgKey");				// MESSAGE - out message 키
			String rtnStatus = "";
			String rtnMessage = "";
			String errorMessage = "";
			if(!outStatusKey.isEmpty()) {
				rtnStatus = parameter.optString(outStatusKey);
				this.logParam.get().put("ResultCode", rtnStatus);
				errorMessage = "Error " + outStatusKey + "=" + rtnStatus;
				if(!outMsgKey.isEmpty()) {
					rtnMessage = parameter.optString(outMsgKey);
					this.logParam.get().put("ResultMessage", rtnMessage);
					errorMessage = errorMessage + " , " + outMsgKey + "=" + rtnMessage;
				}
				if(outCompareType.equalsIgnoreCase("E") && !rtnStatus.equals(outCompareValue)) {
					throw new Exception(errorMessage);
				}else if(outCompareType.equalsIgnoreCase("NE") && rtnStatus.equals(outCompareValue)) {
					throw new Exception(errorMessage);
				}
			}
			
			// Commit
			conn.commit();
		} catch(NullPointerException e){	
			if(conn != null) {
				conn.rollback();
			}
			result.put(sqlType, e.getMessage());
			throw e;
		}catch(Exception e) {
			// Rollback on error.
			//logger.error(e.getLocalizedMessage(), e);
			if(conn != null) {
				conn.rollback();
			}
			result.put(sqlType, e.getMessage());
			throw e;
		}finally {
			// Close resources.
			if(conn != null) {
				conn.setAutoCommit(true);
			}
			extDatabasePoolService.close(conn, pstmt, rs, session);
		}
		
		return result;
	}
	
	/*
	private void test() throws Exception {
		
		CoviMap legacyInfo = new CoviMap();
		legacyInfo.put("IfType","SQL");
		legacyInfo.put("PoolName","Pool-127");
		legacyInfo.put("SqlType","SELECT");
		legacyInfo.put("SqlClause","update covi_approval4j.legacy_test set legacysystem = #{ulegacysystem}, legacyform=#{ulegacyform} where id=#{id}");	
		legacyInfo.put("OutStatusKey","RESULT");
		legacyInfo.put("OutCompareType","E");
		legacyInfo.put("OutCompareValue","S");
		
		CoviMap params = new CoviMap();
		params.put("formid", "999");
		params.put("legacysystem", "TEST33");
		params.put("legacyform", "TESTFORM33");
		params.put("legacyurl", "");
		params.put("isuse", "Y");
		
		params.put("id", "22");
		params.put("ulegacysystem", "TEST44");
		params.put("ulegacyform", "TESTFORM44");
		params.put("did", "25");
		
		params.put("test_text","bbb");
		params.put("test_int","222");
		
		CoviMap result;
		// sql
		legacyInfo.put("SqlClause","select * from covi_approval4j.legacy_test where id = 100");
		result = executeSql(legacyInfo, params);		// empty
		legacyInfo.put("SqlClause","select * from covi_approval4j.legacy_test where id = #{id}");
		result = executeSql(legacyInfo, params);	// one
		legacyInfo.put("SqlClause","select * from covi_approval4j.legacy_test where id > #{id}");
		result = executeSql(legacyInfo, params);	// list
		legacyInfo.put("SqlClause","select * from covi_approval4j.jwf_forms where formid in ('73')");
		result = executeSql(legacyInfo, params);	// json,date
		legacyInfo.put("SqlType","INSERT");
		legacyInfo.put("SqlClause","insert into covi_approval4j.legacy_test(formid,legacysystem,legacyform,legacyurl,isuse) values(#{formid},#{legacysystem},#{legacyform},#{legacyurl},#{isuse})");
		result = executeSql(legacyInfo, params);
		legacyInfo.put("SqlType","UPDATE");
		legacyInfo.put("SqlClause","update covi_approval4j.legacy_test set legacysystem = #{ulegacysystem}, legacyform=#{ulegacyform} where id=#{id}");
		result = executeSql(legacyInfo, params);
		legacyInfo.put("SqlType","DELETE");
		legacyInfo.put("SqlClause","delete from covi_approval4j.legacy_test where id=#{did}");
		result = executeSql(legacyInfo, params);
		
		// procedure
		legacyInfo.put("IfType","SP");
		legacyInfo.put("SqlType","SELECT");
		legacyInfo.put("SqlClause","call covi_approval4j.sp_test_text(#{test_text},#{RESULT,mode=OUT,jdbcType=VARCHAR})");
		result = executeSql(legacyInfo, params);		// output in params
		legacyInfo.put("SqlClause","call covi_approval4j.sp_test_int(#{test_int},#{RESULT,mode=OUT,jdbcType=VARCHAR})");
		result = executeSql(legacyInfo, params);		// output in params
		legacyInfo.put("SqlClause","call covi_approval4j.sp_test_int(#{test_int},#{RESULT,mode=OUT,jdbcType=INTEGER})");
		result = executeSql(legacyInfo, params);		// output in params
		
		legacyInfo.put("SqlClause","call covi_approval4j.sp_test_text(#{test_text,mode=IN,jdbcType=VARCHAR},#{RESULT,mode=OUT,jdbcType=VARCHAR})");
		result = executeSql(legacyInfo, params);	// output in params
		legacyInfo.put("SqlClause","call covi_approval4j.sp_test_int(#{test_int,mode=IN,jdbcType=INTEGER},#{RESULT,mode=OUT,jdbcType=VARCHAR})");
		result = executeSql(legacyInfo, params);		// output in params
		legacyInfo.put("SqlClause","call covi_approval4j.sp_test_int(#{test_int,mode=IN,jdbcType=INTEGER},#{RESULT,mode=OUT,jdbcType=INTEGER})");
		result = executeSql(legacyInfo, params);		// output in params
		
		legacyInfo.put("SqlClause","CALL covi_approval4j.sp_test_list()");
		result = executeSql(legacyInfo, params);		// output in result(list)
		
	}
	*/
	
}
