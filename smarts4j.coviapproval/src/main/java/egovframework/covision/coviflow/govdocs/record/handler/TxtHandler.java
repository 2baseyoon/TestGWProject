package egovframework.covision.coviflow.govdocs.record.handler;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class TxtHandler {
	
	private static final Logger LOGGER = LogManager.getLogger(TxtHandler.class);
	
	/*
	 * CoviMap 데이터를 TXT 파일에 쓰기한다.
	 */
	public static void writeTxt(String filePath, String fileName, CoviMap coviMap, Object object, String newLine){
		
		String fileFullPath = filePath + fileName;
		
		File fileDir = new File(filePath);
		if(!fileDir.isDirectory() && !fileDir.mkdirs()) {
			LOGGER.debug("Failed to make directories.");
		}
		
		File txtFile = new File(fileFullPath);
		try {
			if(!txtFile.isFile() && !txtFile.createNewFile()) {
				LOGGER.debug("Failed to create new File.");
			}
		} catch (IOException e) {
			 LOGGER.debug(e);
		}
		
		try(
			BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(txtFile, true), "EUC-KR"));
		){
			if(null != object && null != coviMap && coviMap.size() > 0){
				copyDataMapToVo(coviMap, object);
				if("Y".equals(newLine)){
					bw.newLine();
				}
				bw.write(getFieldString(object));
				bw.flush();
			}
		} catch(IOException ioe){
			LOGGER.error(ioe.getLocalizedMessage(), ioe);
		} 
	}
	
	public static void writeTxt(String filePath, String fileName, CoviList coviList, Object object){
		if(!coviList.isEmpty()){
			for(int i = 0 ; i < coviList.size() ; i++){
				String newLine = "N";
				
				CoviMap coviMap = coviList.getMap(i);
				if(i > 0){
					newLine = "Y";
				}
				writeTxt(filePath, fileName, coviMap, object, newLine);
			}
		} else {
			writeTxt(filePath, fileName, new CoviMap(), object, "N");
		}
	}
	
	/*
	 * CoviMap에 담겨져 있는 데이터를 VO객체로 옮긴다.
	 */
	private static boolean copyDataMapToVo(CoviMap coviMap, Object object){
		LOGGER.info("CoviMap data transfer to ClassName = {}", object.getClass());
		
		boolean result = true;
		try{
			
			Class<?> cls = object.getClass();
			Field[] fields = cls.getDeclaredFields();
			
			for(int i = 0; i < fields.length ; i++){
				Field field = fields[i];
				
				String fieldName = field.getName();
				String mapKey =fieldName.toUpperCase();
				String mapValue = (String) coviMap.get(mapKey);
				
				if(null == mapValue){
					mapValue = "";
				}
				try{
					mapValue = mapValue.trim();
					Method method = cls.getMethod("set" + upperFirstLetter(fieldName), String.class);
					method.setAccessible(true);
					method.invoke(object, mapValue);
				} catch (NoSuchMethodException|IllegalAccessException|IllegalArgumentException|InvocationTargetException e) {
					LOGGER.error(e.getMessage(), e);
					result = false;
				}
			}
			
		} catch(SecurityException se){
			result = false;
		} 
		
		LOGGER.info("CoviMap data transfer Complete");
		return result;
	}
	
	
	
	/*
	 * 문자열의 첫글자를 대문자로 변환
	 */
	private static String upperFirstLetter(String letter){
		if(letter == null || letter.length() == 0 ){
			return letter;
		}
		return letter.substring(0,1).toUpperCase() + letter.substring(1);
	}
	
	/*
	 * Object의 필드 데이터를 구분자로 구분하여 String 반환
	 */
	private static String getFieldString(Object object){
		StringBuffer fieldString = new StringBuffer();
		
		try{
			
			Class<?> cls = object.getClass();
			Field[] fields = cls.getDeclaredFields();
			
			for(int i = 0; i < fields.length ; i++){
				Field field = fields[i];
				String fieldName = field.getName();
				
				try{
					Method method = cls.getMethod("get" + upperFirstLetter(fieldName), null);
					method.setAccessible(true);
					String fieldValue = (String) method.invoke(object, null);
					
					//구분자  null
					if(i > 0){
						fieldString.append("\u0000");
					}
					fieldString.append(fieldValue);
					
				} catch (NoSuchMethodException|IllegalAccessException|IllegalArgumentException|InvocationTargetException e) {
					LOGGER.error(e.getMessage());
				}
				
			}
			
		} catch(SecurityException se){
			LOGGER.error(se.getMessage(), se);
		} 

		return fieldString.toString();
	}
}
