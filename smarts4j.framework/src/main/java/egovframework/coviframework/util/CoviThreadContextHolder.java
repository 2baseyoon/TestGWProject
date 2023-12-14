package egovframework.coviframework.util;

import java.util.List;
import java.util.Map;

import org.springframework.core.NamedThreadLocal;

/**
 * ThreadContext 필요시 사용. 
 * Spring 의 RequestContextHolder 는 ServeltRequest 용 Map<String, String> 으로 제한적임.
 * 일반 Thread 호환하여 사용필요시 ThreadLocal 변수 및 Getter, Setter 선언하여 사용 가능.
 * @author hgsong
 */
public class CoviThreadContextHolder {
	private static final ThreadLocal<Boolean> isSaveColumnInfo = new NamedThreadLocal<Boolean>("Whether save urrent sql metadata");
	private static final ThreadLocal<List<Map<String, String>>> columnInfoList = new NamedThreadLocal<List<Map<String, String>>>("Current sql metadata");
	
	public static void setIsSaveColumnInfo(Boolean isUse) {
		isSaveColumnInfo.set(isUse);
	}
	public static void setCurrentColumnInfo(List<Map<String, String>> data) {
		columnInfoList.set(data);
	}
	
	
	public static Boolean isSaveColumnInfo() {
		return isSaveColumnInfo.get();
	}
	public static List<Map<String, String>> getCurrentColumnInfo() {
		return columnInfoList.get();
	}

	public static void removeIsSaveColumnInfo() {
		isSaveColumnInfo.remove();
	}
	public static void removeCurrentColumnInfo() {
		columnInfoList.remove();
	}
	
	
	/**
	 * Remove all threadLocal.
	 * when using thread pool
	 */
	public static void remove() {
		columnInfoList.remove();
		isSaveColumnInfo.remove();
		// ...
	}
}
