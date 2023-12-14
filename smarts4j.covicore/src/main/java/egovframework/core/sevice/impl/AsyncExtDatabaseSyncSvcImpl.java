package egovframework.core.sevice.impl;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Timestamp;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.collections.map.CaseInsensitiveMap;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.AsyncExtDatabaseSyncSvc;
import egovframework.core.sevice.DatabaseSyncSvc;
import egovframework.coviframework.service.ExtDatabasePoolSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


/**
 * Background Thread for Synchronize external databases.
 * @author hgsong
 */
@Service("asyncExtDatabaseSyncService")
public class AsyncExtDatabaseSyncSvcImpl extends EgovAbstractServiceImpl implements AsyncExtDatabaseSyncSvc {
	private static final Logger LOGGER = LogManager.getLogger(AsyncExtDatabaseSyncSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private ExtDatabasePoolSvc extDatabasePoolService;
	
	@Autowired
	private DatabaseSyncSvc databaseSyncService;
	
	@Async("executorExternalDatabaseSync")
	public void execute(final CoviMap targetInfo) throws Exception {
		String dupCheckKey = "Sync.Cache.Exe."+targetInfo.optString("TargetSeq");
		try {
			RedisShardsUtil.getInstance().save(dupCheckKey, "true");
			
			StringBuilder MYSQL_GET_DEF_VALUE_SQL = new StringBuilder();
			MYSQL_GET_DEF_VALUE_SQL.append("SELECT COLUMN_DEFAULT, COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS \r\n");
			MYSQL_GET_DEF_VALUE_SQL.append(" WHERE LOWER(TABLE_NAME) = ?");
			MYSQL_GET_DEF_VALUE_SQL.append(" AND LOWER(TABLE_SCHEMA) = ?");
			MYSQL_GET_DEF_VALUE_SQL.append(" AND COLUMN_DEFAULT IS NOT NULL");
			
			/*
			StringBuilder ORACLE_GET_DEF_VALUE_SQL = new StringBuilder();
			ORACLE_GET_DEF_VALUE_SQL.append("SELECT DATA_DEFAULT, COLUMN_NAME FROM DBA_TAB_COLS \r\n");
			ORACLE_GET_DEF_VALUE_SQL.append(" WHERE LOWER(TABLE_NAME) = ?");
			ORACLE_GET_DEF_VALUE_SQL.append(" AND LOWER(OWNER) = ?");
			ORACLE_GET_DEF_VALUE_SQL.append(" AND DATA_DEFAULT IS NOT NULL");
			*/
			
			// TODO...
			
			String connectionPoolName = targetInfo.getString("ConnectionPoolName");
			String srcDatabase = targetInfo.getString("SrcDatabase");
			String srcTableID = targetInfo.getString("SrcTableNm");
			String conditionSQL = targetInfo.getString("ConditionSQL");
			String domainID = targetInfo.getString("DomainID");
			String domainCode = targetInfo.getString("DomainCode");
			
			long startTime = System.currentTimeMillis();
			LOGGER.info("Start database sync : Domain : " + domainCode + ", tableName : " + srcDatabase + "." + srcTableID);
			
			CoviMap params = new CoviMap();
			boolean dataExists= false;
			
			// Get datasource from DBCP pool.
			Connection conn = null; // Poolable connection.
			PreparedStatement pstmt = null;
			PreparedStatement pstmt2 = null;
			ResultSet rs = null;
			ResultSet rs2 = null;
			ResultSetMetaData rsMetadata = null;
			try {
				conn = extDatabasePoolService.getConnection(connectionPoolName);
				
				if(conn == null) {
					LOGGER.error("Fail to get connection ["+ connectionPoolName +"]");
					return;
				}
				
				// 1. Make sql (select * from {tableID} where 1=1 {conditionSQL} Using dbcp pooled connection.
				final StringBuilder selectSql = new StringBuilder();
				selectSql.append("SELECT * FROM \n")
					.append(srcDatabase + "." + srcTableID + "\n")
					.append("WHERE 1=1 \n")
					.append(conditionSQL)
				;
				
				// 2. Get Data > ResultSet
				pstmt = conn.prepareStatement(selectSql.toString());
				LOGGER.debug("Connection : " + conn.toString());
				LOGGER.debug("Ext Table query : \n"+selectSql.toString());
				rs = pstmt.executeQuery();
				
				rsMetadata = rs.getMetaData();
				
				// 2-2. Get column default value
				CaseInsensitiveMap columnDefault = new CaseInsensitiveMap();
				pstmt2 = conn.prepareStatement(MYSQL_GET_DEF_VALUE_SQL.toString());
				pstmt2.setString(1, srcTableID);
				pstmt2.setString(2, srcDatabase);
				rs2 = pstmt2.executeQuery();
				while(rs2.next()) {
					Object col_def = rs2.getObject("COLUMN_DEFAULT");
					String col_name = rs2.getString("COLUMN_NAME");
					columnDefault.put(col_name, col_def);
				}
				
				// 3. Fetch ResultSet to ArrayList into params
				int columnCnt = rsMetadata.getColumnCount();
				String columnName = "";
				java.util.List<Hashtable<String, Object>> bulkData = new java.util.ArrayList<Hashtable<String, Object>>();
				java.util.List<String> columnList = new java.util.ArrayList<String>();
				
				// Set Column List
				for(int i = 1; i <= columnCnt; i++) {
					columnName = rsMetadata.getColumnName(i);
					columnList.add(columnName.toLowerCase());
				}
				
				while(rs.next()) {
					Hashtable<String, Object> map = new Hashtable<String, Object>();
					for(int i = 1; i <= columnCnt; i++) {
						columnName = rsMetadata.getColumnName(i);
						Object o = rs.getObject(i);
						if(o != null) {
							map.put(columnName.toLowerCase(), rs.getObject(i));
							if(o instanceof String && StringUtil.isBlank((String)o) && rsMetadata.isNullable(i) == ResultSetMetaData.columnNoNulls) {
								// if Non-null column but value is null then set value to default value....
								map.put(columnName.toLowerCase(), columnDefault.get(columnName.toLowerCase()));
							}
						}else {
							map.put(columnName.toLowerCase(), "");
						}
					}
					bulkData.add(map);
				}
				params.put("columnList", columnList);
				params.put("dataList", bulkData);
				
				dataExists = bulkData.size() > 0;
			}finally {
				extDatabasePoolService.close(conn, pstmt, pstmt2, rs, rs2);
			}
		
		
			// 4. Drop temp table ( 테이블 스키마 변경이 있을 수 있으므로 Drop 시킨다.)
			// 22.11.08. _sync 테이블 drop/create 제외하고 data만 Truncate 처리한다. ( 인덱스는 동일하게 생성 必 )
			try {
				coviMapperOne.update("sys.dbsync.dropTemp", targetInfo);
			}
			catch(DataAccessException de) {
				LOGGER.info("[DataAccessException] " + de.getLocalizedMessage());
			}
			catch(Exception e) {
				LOGGER.info(e.getLocalizedMessage());
			}
			
			// 22.11.08. _sync 테이블 drop/create 제외하고 data만 Truncate 처리한다.
			// coviMapperOne.update("sys.dbsync.createTemp", targetInfo);
			
			// 5-1. ResultSet to List
			// 5-2. Bulk insert into temp table
			
			String successMessage = "";
			if(dataExists) {
				params.put("TargetDatabase", targetInfo.optString("TargetDatabase"));
				params.put("TargetTableNm", targetInfo.optString("TargetTableNm"));
				
				// 2000 건정도씩 끊어처리
				@SuppressWarnings("unchecked")
				List<Hashtable<String, Object>> bulkData = (List<Hashtable<String, Object>>)params.get("dataList");
				
				int size = 1000;
				int totCnt = bulkData.size();
				for(int i = 0 ; i < totCnt; i++) {
					if(i > 0 && i % size == 0) {
						List subList = bulkData.subList(Math.max(0, i - size), i);
						params.put("dataList", subList);
						coviMapperOne.update("sys.dbsync.insertTemp", params);
					}
				}
				// Last
				int lastIdx = totCnt;// subList 의 endPoint: exclusive
				int delta = totCnt % size;
				List subList = bulkData.subList(Math.max(0, totCnt - delta), lastIdx);
				params.put("dataList", subList);
				coviMapperOne.update("sys.dbsync.insertTemp", params);
				
				// 6. Call Procedure. >> In procedure temp > real I/F Table.
				// Prepare OUT Parameter
				targetInfo.put("RtnCode", ""); 
				targetInfo.put("RtnMsg", "");
				coviMapperOne.update("sys.dbsync.callProcedure", targetInfo);
				
				// Read Out Parameters.
				String rtnCode = targetInfo.optString("RtnCode");
				String rtnMsg = targetInfo.optString("RtnMsg");
				long elapsedTime = System.currentTimeMillis() - startTime;
				
				if("-1".equals(rtnCode)) {
					LOGGER.error("[SP]rtnCode : " + rtnCode);
					LOGGER.error("[SP]rtnMsg : " + rtnMsg);
					
					throw new Exception("Procedure Call Error[" + rtnCode + "] " + rtnMsg);
				}else{
					LOGGER.info("[SP]rtnCode : " + rtnCode);
					LOGGER.info("[SP]rtnMsg : " + rtnMsg);
					successMessage = "Complete database sync : Domain : " + domainCode + ", tableName : " + srcDatabase + "." + srcTableID + ", elapsed time is " + elapsedTime + "ms";
				}
			}else {
				successMessage = "Complete database sync : Domain : " + domainCode + ", tableName : " + srcDatabase + "." + srcTableID + " / No data to process.";
			}
			
			LOGGER.info(successMessage);
			
			// sys_dbsync_target Update.
			params.put("LastStatus", "Success");
			params.put("TargetSeq", targetInfo.optString("TargetSeq"));
			databaseSyncService.updateTargetResult(params);
		
			// Log Table Insert
			Map<String, Object> logInfo = new Hashtable<String, Object>();
			logInfo.put("TargetSeq", targetInfo.optString("TargetSeq"));
			logInfo.put("Message", successMessage);
			logInfo.put("Level", "INFO");
			logInfo.put("LoggingTime", new Timestamp(System.currentTimeMillis()));
			coviMapperOne.update("sys.dbsync.insertLog", logInfo);
		} catch (Throwable t) {
			LOGGER.error("Error", t);
			
			// sys_dbsync_target Update.
			CoviMap params = new CoviMap();
			params.put("LastStatus", "Fail");
			params.put("TargetSeq", targetInfo.optString("TargetSeq"));
			databaseSyncService.updateTargetResult(params);
			
			// Log Table insert. (trace)
			StringWriter writer = new StringWriter();
			t.printStackTrace(new PrintWriter(writer));		// 231016_취약점 EXPOSURE_OF_SYSTEM_DATA 소명, 의도적인 PrintWriter 사용
			Map<String, Object> logInfo = new Hashtable<String, Object>();
			logInfo.put("TargetSeq", targetInfo.optString("TargetSeq"));
			logInfo.put("Message", new String(writer.toString().getBytes(StandardCharsets.UTF_8), 0, Math.min(writer.toString().getBytes(StandardCharsets.UTF_8).length - 1, 65535), StandardCharsets.UTF_8));
			logInfo.put("Level", "ERROR");
			logInfo.put("LoggingTime", new Timestamp(System.currentTimeMillis()));
			coviMapperOne.update("sys.dbsync.insertLog", logInfo);
		} finally {
			RedisShardsUtil.getInstance().remove(dupCheckKey);
		}
	}
}
