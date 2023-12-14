package egovframework.coviframework.util;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.apache.ibatis.executor.resultset.ResultSetHandler;
import org.apache.ibatis.plugin.Intercepts;
import org.apache.ibatis.plugin.Invocation;
import org.apache.ibatis.plugin.Plugin;
import org.apache.ibatis.plugin.Signature;

/**
 * CoviQueryInterceptor
 * @author hgsong
 */
@Intercepts({@Signature(type= ResultSetHandler.class, method = "handleResultSets", args = {java.sql.Statement.class})})
public class CoviQueryInterceptor implements org.apache.ibatis.plugin.Interceptor  {

	@Override
	@SuppressWarnings("resource")
	public Object intercept(Invocation invocation) throws Throwable {
		Statement statement = null;
		ResultSet rs = null;
		try {
			Boolean isSaveColumnInfo = CoviThreadContextHolder.isSaveColumnInfo();
			if(isSaveColumnInfo != null && Boolean.compare(isSaveColumnInfo, Boolean.valueOf("True")) == 0) {
				
				Object[] args = invocation.getArgs();
				statement = (Statement) args[0];
				rs = statement.getResultSet();
				
				if (rs != null) {
					ResultSetMetaData rsmd = rs.getMetaData();
					int columnCount = rsmd.getColumnCount();
					List<Map<String, String>> metaData = new ArrayList<Map<String, String>>();
					for (int i = 1; i <= columnCount; i++) {
						Map<String, String> columnMeta = new LinkedHashMap<String, String>();
						String columnName = rsmd.getColumnName(i);
						String columnLabel = rsmd.getColumnLabel(i);
						String columnType = rsmd.getColumnTypeName(i);
						columnMeta.put("columnName", columnName);
						columnMeta.put("columnLabel", columnLabel);
						columnMeta.put("columnType", columnType);
						metaData.add(columnMeta);
					}
					
					CoviThreadContextHolder.setCurrentColumnInfo(metaData);
				}
			}

			return invocation.proceed();
		}finally {
			if(rs != null) {
				rs.close();
			}
			if(statement != null) {
				statement.close();
			}
		}
	}

	@Override
	public Object plugin(Object target) {
		return Plugin.wrap(target, this);
	}

	@Override
	public void setProperties(Properties properties) {
	}
}
