package egovframework.core.extention;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.core.util.OrgSyncDBConnect;

public class OrgInterfaceHR {
	private Logger LOGGER = LogManager.getLogger(OrgInterfaceHR.class);
	
	private OrgSyncDBConnect db_conn;
	private Connection con = null;
	private PreparedStatement ps = null;
	private ResultSet rs = null;
	
	Map<String, Object> returnMap;
	
	public OrgInterfaceHR() {}
	
	public Map<String, Object> getHRData() {
		LOGGER.debug("Dynamic class load...");
		this.returnMap = new HashMap<String, Object>();
		
		LOGGER.debug("Step 1. Connect to DB...");
		db_conn = OrgSyncDBConnect.getInstance();
		con = db_conn.getHRConnection();
			
		try {
			ps = con.prepareStatement("SELECT * FROM covi_smart4j.eum_orgperson;"); 
			rs = ps.executeQuery();
			returnMap.put("user", toArray(rs));
			
			ps = con.prepareStatement("SELECT * FROM covi_smart4j.eum_orgjobtitle;"); 
			rs = ps.executeQuery();
			returnMap.put("jobtitle", toArray(rs));
			
			ps = con.prepareStatement("SELECT * FROM covi_smart4j.eum_orgjobposition;"); 
			rs = ps.executeQuery();
			returnMap.put("jobposition", toArray(rs));
			
			ps = con.prepareStatement("SELECT * FROM covi_smart4j.eum_orgjoblevel;"); 
			rs = ps.executeQuery();
			returnMap.put("joblevel", toArray(rs));
			
			ps = con.prepareStatement("SELECT * FROM covi_smart4j.eum_orgdept;"); 
			rs = ps.executeQuery();
			returnMap.put("dept", toArray(rs));
			
			ps = con.prepareStatement("SELECT * FROM covi_smart4j.eum_orgaddjob;"); 
			rs = ps.executeQuery();
			returnMap.put("addjob", toArray(rs));
			
			returnMap.put("result", "success");
		}
		catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		catch (SQLException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} 
		catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		finally {
			if(rs != null) try { rs.close(); } catch (NullPointerException e) { LOGGER.error(e.getLocalizedMessage(), e); } catch(Exception e) { LOGGER.error(e.getLocalizedMessage(), e); }
			if(ps != null) try { ps.close(); } catch (NullPointerException e) { LOGGER.error(e.getLocalizedMessage(), e); } catch(Exception e) { LOGGER.error(e.getLocalizedMessage(), e); }
			if(con != null) try { con.close(); } catch (NullPointerException e) { LOGGER.error(e.getLocalizedMessage(), e); } catch(Exception e) { LOGGER.error(e.getLocalizedMessage(), e); }
		}

		LOGGER.debug("Step 4. Return result in Map...");
		return returnMap;
	}
	
	private List<Map<String, Object>> toArray(ResultSet rs) throws SQLException {
		List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
		 
		String[] columnNames = null;
		ResultSetMetaData rsmd = rs.getMetaData();
		int columnCount = rsmd.getColumnCount();
		columnNames = new String[columnCount];
		
		for(int i=1; i<=columnCount; i++) {
		    columnNames[i-1] = rsmd.getColumnName(i); 
		}
		
		while(rs.next()){
			Map<String, Object> rowdata = new HashMap<String, Object>();
			for (String columnName: columnNames) {
				rowdata.put(columnName, rs.getObject(columnName));
		    }
			rows.add(rowdata);
		}
		 
		return rows;
	}
}
