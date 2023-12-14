package egovframework.coviframework.util.s3;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.SdkClientException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.AmazonS3URI;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ListObjectsV2Request;
import com.amazonaws.services.s3.model.ListObjectsV2Result;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.CopyObjectRequest;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.util.IOUtils;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.web.multipart.MultipartFile;
import java.io.File;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Date;
import java.util.Objects;
import java.util.Properties;

import static egovframework.baseframework.util.PropertiesUtil.getFileProperties;

public class AwsS3 {
	private static final Logger LOGGER = LogManager.getLogger(AwsS3.class);

	//Amazon-s3-sdk
	private Properties propS3Domain;
	public AmazonS3 s3Client;
	public String   accessKey = "AKIAWB4ZQU2LUKF3BBRZ";//"AKIA6HTTQF4JSQBB34ST";
	public String   secretKey = "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";//"zOCagiZdwN1gDdBOfY1HTFcYtrBifJhw/GrUDJP0";
	public Regions  clientRegion = Regions.AP_NORTHEAST_2;
	public String   bucket = "covi-dev-s3-01-bucket";//"covi-test-s3-bucket";
	//s3.ap.url=s3://arn:aws:s3:ap-northeast-2:416396912279:accesspoint/covi-dev-s3-01-ap
	public boolean  s3Active = false;
	public String   s3ApUrl = "https://covi-dev-s3-01-ap-416396912279.s3-accesspoint.ap-northeast-2.amazonaws.com";
	public AwsS3() {
		createS3Client();
	}

	public String getAccessKey(){
		return this.accessKey;
	}
	public String getSecretKey(){
		return this.secretKey;
	}
	public Regions getClientRegion(){
		return this.clientRegion;
	}
	public String getBucket(){
		return this.bucket;
	}
	public AmazonS3 getS3Client(){
		return this.s3Client;
	}

	public boolean getS3Active(){
		String use = getS3Properties().getProperty(SessionHelper.getSession("DN_Code"));
		if(use!=null && use.equals("Y")) {
			return this.s3Active;
		}else{
			return false;
		}
	}

	public boolean getS3Active(String dnCode){
		if(dnCode==null || dnCode.equals("")){
			dnCode = SessionHelper.getSession("DN_Code");
		}
		String use = getS3Properties().getProperty(dnCode);
		//System.out.println("[AWS S3]getS3Active(dnCode):"+use);
		if(use!=null && !use.equals("") && use.equals("Y")) {
			return this.s3Active;
		}else{
			return false;
		}
	}
	public String getS3ApUrl(String key){
		return urlConv(this.s3ApUrl+"/"+key);
	}
	public String getS3ApUrl(){
		return urlConv(this.s3ApUrl);
	}

	//singleton pattern
	static volatile AwsS3 instance = null;

	public static AwsS3 getInstance() {
		if (instance == null) {
			synchronized(AwsS3.class) {
				if (instance == null) {
					instance = new AwsS3();
				}
			}
		}
		return instance;
	}

	//aws S3 client 생성
	public void createS3Client() {

		String accessKey = PropertiesUtil.getGlobalProperties().getProperty("s3.accessKey", "");
		String secretKey = PropertiesUtil.getGlobalProperties().getProperty("s3.secretKey", "");
		String s3ApUrl   = PropertiesUtil.getGlobalProperties().getProperty("s3.ap.url", "");
		String bucket    = PropertiesUtil.getGlobalProperties().getProperty("s3.bucket", "");
		if(s3ApUrl!=null && s3ApUrl.contains(".")){
			String[] arrS3APURL = s3ApUrl.split("\\.");
			if(arrS3APURL.length==5){
				this.s3ApUrl = s3ApUrl;
				this.accessKey = accessKey;
				this.secretKey = secretKey;
				this.bucket = bucket;
				//https://covi-dev-s3-01-ap-416396912279.
				// s3-accesspoint.
				// ap-northeast-2.
				// amazonaws.
				// com
				clientRegion = choiceRedion(arrS3APURL[2]);
				if(!Objects.equals(this.bucket, "") && !Objects.equals(this.accessKey, "") && !Objects.equals(this.secretKey, "")) {

					this.s3Active = true;

				}else{
					erroPrint(AwsS3Error.s3ap_url_error);
				}
			}else{
				erroPrint(AwsS3Error.s3ap_url_error);
			}

			AWSCredentials credentials = new BasicAWSCredentials(this.accessKey, this.secretKey);
			this.s3Client = AmazonS3ClientBuilder
					.standard()
					.withCredentials(new AWSStaticCredentialsProvider(credentials))
					.withRegion(clientRegion)
					.build();
		}

	}

	public void upload(File file, String key) {
		if(key.contains("//")){
			key = key.replaceAll("//","/");
		}
		key = key.replaceAll("\\\\","/"); // for Windows
		uploadToS3(new PutObjectRequest(this.bucket, key, file));
	}

	public void upload(InputStream is, String key, String contentType, long contentLength) {
		if(key.contains("//")){
			key = key.replaceAll("//","/");
		}
		key = key.replaceAll("\\\\","/"); // for Windows
		ObjectMetadata objectMetadata = new ObjectMetadata();
		objectMetadata.setContentType(contentType);
		objectMetadata.setContentLength(contentLength);

		uploadToS3(new PutObjectRequest(this.bucket, key, is, objectMetadata));
	}

	//PutObjectRequest는 Aws S3 버킷에 업로드할 객체 메타 데이터와 파일 데이터로 이루어져있다.
	private void uploadToS3(PutObjectRequest putObjectRequest) {

		try {
			this.s3Client.putObject(putObjectRequest);
			LOGGER.debug(String.format("[AWS S3][%s] upload complete%n", putObjectRequest.getKey()));

		} catch (AmazonServiceException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (SdkClientException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}

	/**
	 * @param key
	 * @return
	 * @throws SdkClientException
	 * @throws IOException
	 * 
	 * @deprecated use Stream from downData(String key) because Usage of large heap.
	 */
	 @Deprecated
	public byte[] down (String key) throws SdkClientException, IOException {
		LOGGER.debug("[AWS S3]down key:"+key);
		if(key.contains("//")){
			key = key.replaceAll("//","/");
		}
		S3Object fullObject = this.s3Client.getObject(new GetObjectRequest(bucket, key));
		return IOUtils.toByteArray(fullObject.getObjectContent());
	}



	@SuppressWarnings("resource")
	public AwsS3Data downData (String key) throws SdkClientException, IOException {
		LOGGER.debug("[AWS S3]down key:"+key);
		if(key.contains("//")){
			key = key.replaceAll("//","/");
		}
		key = key.replaceAll("\\\\","/"); // for Windows
		String fileName = key.substring(key.lastIndexOf("/") + 1);
		String parentPath = key.substring(0, key.lastIndexOf("/"));
		AwsS3Data awsS3Data = new AwsS3Data();
		S3Object fullObject = this.s3Client.getObject(new GetObjectRequest(bucket, key));
		//byte[] 는 Heap 사용문제로 사용하지 않고 Stream 을 사용하고 파일사이즈는 ObjectMetadata 를 활용하도록 한다.
		//byte[] contentByte = IOUtils.toByteArray(fullObject.getObjectContent());
		//awsS3Data.setLength(contentByte.length);
		//awsS3Data.setContent(contentByte);
		awsS3Data.setParentPath(parentPath);
		awsS3Data.setContentType(fullObject.getObjectMetadata().getContentType());
		awsS3Data.setName(fileName);
		awsS3Data.setContentStream(fullObject.getObjectContent());
		awsS3Data.setLength(fullObject.getObjectMetadata().getContentLength());
		
		return awsS3Data;
	}

	public boolean exist (String key)  {
		if(key.contains("//")){
			key = key.replaceAll("//","/");
		}
		key = key.replaceAll("\\\\","/"); // for Windows
		return this.s3Client.doesObjectExist(bucket, key);
	}

	public void copy(String orgKey, String copyKey) {
		try {
        	orgKey = orgKey.replaceAll("\\\\","/"); // for Windows
        	copyKey = copyKey.replaceAll("\\\\","/"); // for Windows
			//Copy 객체 생성
			CopyObjectRequest copyObjRequest = new CopyObjectRequest(
					this.bucket,
					orgKey,
					this.bucket,
					copyKey
					);
			//Copy
			this.s3Client.copyObject(copyObjRequest);

			LOGGER.debug(String.format("Finish copying [%s] to [%s]%n", orgKey, copyKey));

		} catch (AmazonServiceException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (SdkClientException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}

    public void move(String orgKey, String copyKey) {
        try {
        	orgKey = orgKey.replaceAll("\\\\","/"); // for Windows
        	copyKey = copyKey.replaceAll("\\\\","/"); // for Windows
            //Copy 객체 생성
            CopyObjectRequest copyObjRequest = new CopyObjectRequest(
                    this.bucket,
                    orgKey,
                    this.bucket,
                    copyKey
            );
            //Copy
            this.s3Client.copyObject(copyObjRequest);

            //delete
            DeleteObjectRequest deleteObjRequest = new DeleteObjectRequest(this.bucket, orgKey);
            this.s3Client.deleteObject(deleteObjRequest);
            
            LOGGER.debug(String.format("Finish copying [%s] to [%s]%n", orgKey, copyKey));

        } catch (AmazonServiceException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        } catch (SdkClientException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        }
    }
    
	public void delete(String key) {
		try {
			key = key.replaceAll("\\\\","/"); // for Windows
        	
			//Delete 객체 생성
			DeleteObjectRequest deleteObjectRequest = new DeleteObjectRequest(this.bucket, key);
			//Delete
			this.s3Client.deleteObject(deleteObjectRequest);
			LOGGER.debug(String.format("[%s] deletion complete%n", key));

		} catch (AmazonServiceException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (SdkClientException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}

	public void erroPrint(AwsS3Error errorCode){
		StringBuilder msg = new StringBuilder(); 
		switch (errorCode){
		case s3ap_url_error :
			msg.append("┌──────────────────────────────────────────────────────────────────────────────┐").append("\n");
			msg.append("│                        AWS S3 createS3 Client Error                          │").append("\n");
			msg.append("├──────────────────────────────────────────────────────────────────────────────┤").append("\n");
			msg.append("│ DEPLOY_PATH -> globals.properties check!!                                    │").append("\n");
			msg.append("│ ex) s3.accessKey=AKIAWB4ZQU2LUKF3BBRZ                                        │").append("\n");
			msg.append("│ ex) s3.secretKey=Y2L8i61ggBKPyncI4QYP8uJOVpkrs/vtBwOpWkvl                    │").append("\n");
			msg.append("│ ex) s3.bucket=covi-dev-s3-01-bucket                                          │").append("\n");
			msg.append("│ ex) s3.ap.url=https://covi-dev-s3-01-bucket.s3.ap-northeast-2.amazonaws.com  │").append("\n");
			msg.append("│ ex) attachAwsS3.path=GWStorage/                                              │").append("\n");
			msg.append("│ ex) frontAwsS3.path=FrontStorage/                                            │").append("\n");
			msg.append("└──────────────────────────────────────────────────────────────────────────────┘").append("\n");
			LOGGER.error(msg.toString());
			break;
		case s3Setting_print:
			msg.append("┌──────────────────────────────────────────────────────────────────────────────┐").append("\n");
			msg.append("│                        AWS S3 Configuration Info.                            │").append("\n");
			msg.append("├──────────────────────────────────────────────────────────────────────────────┤").append("\n");
			msg.append("│ DEPLOY_PATH -> globals.properties check!!                                    │").append("\n");
			msg.append("│ ex) s3.accessKey="+this.accessKey).append("\n");
			msg.append("│ ex) s3.secretKey="+this.secretKey).append("\n");
			msg.append("│ ex) s3.bucket="+this.bucket).append("\n");
			msg.append("│ ex) s3.ap.url="+this.s3ApUrl).append("\n");
			msg.append("└──────────────────────────────────────────────────────────────────────────────┘").append("\n");
			LOGGER.info(msg.toString());
			break;

		}
	}

	public Regions choiceRedion(String regionStr){
		String regionStr2 = regionStr.toUpperCase();
		Regions rtnRegions = null;
		switch (regionStr2){
		case "AP-NORTHEAST-2":
			rtnRegions = Regions.AP_NORTHEAST_2;
			break;
		case "AP-NORTHEAST-1":
			rtnRegions = Regions.AP_NORTHEAST_1;
			break;
		case "AP-NORTHEAST-3":
			rtnRegions = Regions.AP_NORTHEAST_3;
			break;
		case "AP-SOUTHEAST-1":
			rtnRegions = Regions.AP_SOUTHEAST_1;
			break;
		case "AP-SOUTHEAST-2":
			rtnRegions = Regions.AP_SOUTHEAST_2;
			break;
		case "AP-SOUTHEAST-3":
			rtnRegions = Regions.AP_SOUTHEAST_3;
			break;
		case "SA-EAST-1":
			rtnRegions = Regions.SA_EAST_1;
			break;
		case "CN-NORTH-1":
			rtnRegions = Regions.CN_NORTH_1;
			break;
		case "CN-NORTHWEST-1":
			rtnRegions = Regions.CN_NORTHWEST_1;
			break;
		case "CA-CENTRAL-1":
			rtnRegions = Regions.CA_CENTRAL_1;
			break;
		case "ME-SOUTH-1":
			rtnRegions = Regions.ME_SOUTH_1;
			break;
		case "AF_SOUTH_1":
			rtnRegions = Regions.AF_SOUTH_1;
			break;
		case "US_ISO_EAST_1":
			rtnRegions = Regions.US_ISO_EAST_1;
			break;
		case "US_ISOB_EAST_1":
			rtnRegions = Regions.US_ISOB_EAST_1;
			break;
		case "US_ISO_WEST_1":
			rtnRegions = Regions.US_ISO_WEST_1;
			break;
		case "AP_SOUTH_1":
			rtnRegions = Regions.AP_SOUTH_1;
			break;
		case "AP_EAST_1":
			rtnRegions = Regions.AP_EAST_1;
			break;
		case "EU_SOUTH_1":
			rtnRegions = Regions.EU_SOUTH_1;
			break;
		case "EU_NORTH_1":
			rtnRegions = Regions.EU_NORTH_1;
			break;
		case "EU_CENTRAL_1":
			rtnRegions = Regions.EU_CENTRAL_1;
			break;
		case "US_EAST_1":
			rtnRegions = Regions.US_EAST_1;
			break;
		case "US_EAST_2":
			rtnRegions = Regions.US_EAST_2;
			break;
		case "US_WEST_1":
			rtnRegions = Regions.US_WEST_1;
			break;
		case "US_WEST_2":
			rtnRegions = Regions.US_WEST_2;
			break;
		case "EU_WEST_1":
			rtnRegions = Regions.EU_WEST_1;
			break;
		case "EU_WEST_2":
			rtnRegions = Regions.EU_WEST_2;
			break;
		case "EU_WEST_3":
			rtnRegions = Regions.EU_WEST_3;
			break;
		default:
			throw new IllegalStateException("Unexpected value: " + regionStr2);
		}
		return rtnRegions;
	}

	public enum AwsS3Error {
		s3ap_url_error,
		s3Setting_print
	}

	public String urlConv(String url){
		String rtn = url;
		AmazonS3URI amazonS3URI = new AmazonS3URI(rtn);
		rtn = amazonS3URI.getURI().toString().replaceAll(" ","+");
		return rtn;
	}

    public ListObjectsV2Result getFileList(String folderPath) {
    	folderPath = folderPath.replaceAll("\\\\","/"); // for Windows
    	ListObjectsV2Request listObjectsV2Request = new ListObjectsV2Request().withBucketName(this.bucket).withPrefix(folderPath);
        return this.s3Client.listObjectsV2(listObjectsV2Request);
    }

    public ObjectMetadata getFileObject(String key) {
    	key = key.replaceAll("\\\\","/"); // for Windows
    	return this.s3Client.getObjectMetadata(this.bucket, key);
    }
    
    public Date getLastModified(String key) {
    	key = key.replaceAll("\\\\","/"); // for Windows
    	return new Date(this.s3Client.getObjectMetadata(this.bucket, key).getLastModified().getTime());
    }
    
    public long getContentLength(String key) {
    	key = key.replaceAll("\\\\","/"); // for Windows
        ObjectMetadata metadata = this.s3Client.getObjectMetadata(this.bucket, key);
        return metadata.getContentLength();
    }
    
	public File multipartToFile(MultipartFile mfile) throws  IOException{
		File file = new File(mfile.getOriginalFilename());
		if(!file.createNewFile()) {
			LOGGER.debug("Failed to make file.");
		}
		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(file);
			fos.write(mfile.getBytes());
		} finally {
			if(fos != null) {
				fos.close();
			}
		}
		return file;
	}

	public File multipartToFile(MultipartFile mfile, String fname) throws  IOException{
		File file = new File(fname);
		if(!file.createNewFile()) {
			LOGGER.debug("Failed to make file.");
		}
		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(file);
			fos.write(mfile.getBytes());
		} finally {
			if(fos != null) {
				fos.close();
			}
		}

		return file;
	}

	public File multipartToFileV2(MultipartFile mfile) throws IllegalStateException, IOException {
		File file = new File(mfile.getOriginalFilename());
		mfile.transferTo(file);
		return file;
	}

	public File multipartToFileV2(MultipartFile mfile, String fname) throws IllegalStateException, IOException {
		File file = new File(fname);
		mfile.transferTo(file);
		return file;
	}


	public Properties getS3Properties() {
		if (propS3Domain == null) {
			propS3Domain = getFileProperties("s3.properties");
		}

		return propS3Domain;
	}

	public void reloadProperties(String filename) {
		if(propS3Domain != null) {
			propS3Domain.remove(filename);
		}
		propS3Domain = getFileProperties(filename);
	}

}
