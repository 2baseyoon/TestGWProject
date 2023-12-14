package egovframework.covision.groupware.attend.user.util;

import java.util.regex.Pattern;















import com.nhncorp.lucy.security.xss.markup.Description;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;

/**
 * @author sjhan0418
 * {@link Description}
 */
public class IpCheckUtils {

	
	public static long paseLongIp(String ip){
		String[] ipAddrTemp = ip.split("\\.");
		long ipLong = (Long.parseLong(ipAddrTemp[0])<< 24)
				+(Long.parseLong(ipAddrTemp[1])<< 16)
				+(Long.parseLong(ipAddrTemp[2])<< 8)
				+(Long.parseLong(ipAddrTemp[3]));
		
		return ipLong;
	}
	
	public static boolean ipRangeCheck(String startIp , String EndIp , String chkIp){
		
		if(
				checkIpValid(startIp)
				&&checkIpValid(EndIp)
				&&checkIpValid(chkIp)
		){
			long startIpLong = paseLongIp(startIp);
			long endIpLong = paseLongIp(EndIp);
			long chkIpLong = paseLongIp(chkIp);

			if(
					chkIpLong >= startIpLong && chkIpLong <= endIpLong
			){
				return true;
			}else{
				return false;
			}
		}else{
			return false;
		}
	}
	
	@SuppressWarnings("unchecked")
	public static CoviMap ipRangeCheck(String[] ipArray  , String chkIp){
		
		CoviMap returnJson = new CoviMap();
		
		try{
			boolean flag = false;
			if(ipArray.length>0){
				for(int i=0;i<ipArray.length;i++){
					String[] ip = ipArray[i].split(",");
					if(ipRangeCheck(ip[0],ip[1],chkIp)){
						flag = true;
						break;
					}
				}
			}
			returnJson.put("status", Return.SUCCESS);
			returnJson.put("ipFlag", flag);
		} catch(ArrayIndexOutOfBoundsException e){
			returnJson.put("status", Return.FAIL);
		} catch(NullPointerException e){
			returnJson.put("status", Return.FAIL);
		} catch(Exception e){
			returnJson.put("status", Return.FAIL);
		}

		return returnJson;
	}
	
	public static boolean checkIpValid(String ip){
		String validIp = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$";
		if (!Pattern.matches(validIp, ip )) {
			return false;
		}else{
			return true;
		}
	}
}
