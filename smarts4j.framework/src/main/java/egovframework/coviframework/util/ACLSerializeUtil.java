package egovframework.coviframework.util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import org.apache.commons.codec.binary.Base64;

import egovframework.coviframework.vo.ACLMapper;

public class ACLSerializeUtil {
	public String serializeObj(ACLMapper aclMap) throws IOException {
		byte[] serialized;
	    try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
	        try (ObjectOutputStream oos = new ObjectOutputStream(baos)) {
	            oos.writeObject(aclMap);
	            // serializedMember -> 직렬화된 member 객체 
	            serialized = baos.toByteArray();
	        }
	    }
	    
	    // 바이트 배열로 생성된 직렬화 데이터를 base64로 변환
	    return Base64.encodeBase64String(serialized);
	}
	
	public ACLMapper deserializeObj(String serializedStr) throws IOException, ClassNotFoundException {
		ACLMapper aclMap = null;
		byte[] serialized = Base64.decodeBase64(serializedStr);
	    try (ByteArrayInputStream bais = new ByteArrayInputStream(serialized)) {
	        try (ObjectInputStream ois = new ObjectInputStream(bais)) {
	            // 역직렬화된 Member 객체를 읽어온다.
	            Object objectAclMap = ois.readObject();
	            aclMap = (ACLMapper) objectAclMap;
	        }
	    }
	    
	    return aclMap;
	}
}
