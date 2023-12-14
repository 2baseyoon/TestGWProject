package egovframework.covision.coviflow.govdocs.record.handler;

import java.io.BufferedWriter;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import egovframework.covision.coviflow.govdocs.vo.xml.ExchangeXmlVO;

public class XmlHandler {
	
	private static Logger LOGGER = LogManager.getLogger(XmlHandler.class);
	
	private XmlHandler() {
		throw new IllegalStateException("Utility class");
	}
	
	public static String makeXml(Object object, String xmlPath, String fileName){
		
		File fileDir = new File(xmlPath);
		if(!fileDir.isDirectory() && !fileDir.mkdir()) {
			LOGGER.debug("Failed to make directories.");
		}
		
	    try {	    	
	    	//xml 생성
		    StringWriter xml = new StringWriter();
		    xml.append("<?xml version=\"1.0\" encoding=\"EUC-KR\"?>\r");			
		    xml.append("<!DOCTYPE exchange SYSTEM \"../../../../conf/exchange.dtd\">\r");
		    
			xml.append( xmlMarshaller( object ).toString() );
			
			try(BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(xmlPath+File.separator+fileName), "EUC-KR"));)
			{
				writer.write(xml.toString());
			}
	      
		} catch (JAXBException|IOException e) {
			LOGGER.error(e.getMessage());
		}
		return xmlPath+File.separator+fileName;
	}

	/*
	 * 기록물철 관리 시스템에서 받은 파일 처리
	 * ex ) 
	 * 	I111020_NEW_CLASS_FILE_20160303150141.xml
	 *  I111020_NEW_UNIT_FILE_20140127142129.xml
	 */
	public static ExchangeXmlVO parseXml(String recvFileName) {
		LOGGER.info("Received File name : {}", recvFileName);
		
		File xmlFile = new File(recvFileName);
		String read = "";
		JAXBContext jc = null;
		
		if(xmlFile.isFile()){
			try {
				jc = JAXBContext.newInstance(ExchangeXmlVO.class);
				read = new String( Files.readAllBytes(Paths.get( xmlFile.getAbsolutePath() )) , "EUC-KR" );
		    	read = read.replaceFirst("<!DOCTYPE exchange SYSTEM \"../../../../conf/exchange.dtd\">", "" );
			} catch (JAXBException | IOException e ){
				LOGGER.error(e.getMessage());
				return null;
			}
			
			try{
				Unmarshaller unmarshaller = jc.createUnmarshaller();
				return (ExchangeXmlVO) unmarshaller.unmarshal(new ByteArrayInputStream( read.getBytes(StandardCharsets.UTF_8) ));
			} catch (JAXBException e) {
				LOGGER.error(e.getMessage());
				return null;
			}
		} else {
			return null;
		}
	}
	
	private static StringWriter xmlMarshaller(Object cls) throws JAXBException {
        StringWriter sw = new StringWriter();
        Marshaller jaxbMarshaller = JAXBContext.newInstance(cls.getClass()).createMarshaller();            
        jaxbMarshaller.setProperty(Marshaller.JAXB_ENCODING, "EUC-KR");
        jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
        jaxbMarshaller.setProperty(Marshaller.JAXB_FRAGMENT, true);
        jaxbMarshaller.marshal(cls, sw);            
		return sw;
	}
	
	
}
