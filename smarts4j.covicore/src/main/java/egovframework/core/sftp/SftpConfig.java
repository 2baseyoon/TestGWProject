package egovframework.core.sftp;


import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Vector;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.jcraft.jsch.Channel;
import com.jcraft.jsch.ChannelSftp;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;
import com.jcraft.jsch.SftpException;

public class SftpConfig {
	private Logger LOGGER = LogManager.getLogger(SftpConfig.class);
	
	private Session session = null;
	private Channel channel = null;
	private ChannelSftp channelSftp = null;
	
	 /**
     * 서버와 연결에 필요한 값들을 가져와 초기화 시킴
     *
     * @param host
     *            서버 주소
     * @param userName
     *            접속에 사용될 아이디
     * @param password
     *            비밀번호
     * @param port
     *            포트번호
     */
    public void init(String host, String userName, String password, int port) {
        JSch jsch = new JSch();
        try {
            session = jsch.getSession(userName, host, port);
            session.setPassword(password);

            java.util.Properties config = new java.util.Properties();
            config.put("StrictHostKeyChecking", "no");
            session.setConfig(config);
            session.connect();

            channel = session.openChannel("sftp");
            channel.connect();
        } catch (JSchException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        }

        channelSftp = (ChannelSftp) channel;

    }

    /**
     * 하나의 파일을 업로드 한다.
     *
     * @param dir
     *            저장시킬 주소(서버)
     * @param file
     *            저장할 파일
     */
    public void upload(String dir, File file) {

        FileInputStream in = null;
        try {
            in = new FileInputStream(file);
            channelSftp.cd(dir);
            channelSftp.put(in, file.getName());
        } catch (SftpException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        } catch (FileNotFoundException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        } finally {
            try {
            	if(in != null) in.close();
            } catch (IOException e) {
            	LOGGER.error(e.getLocalizedMessage(), e);
            }
        }
    }

    /**
     * 하나의 파일을 다운로드 한다.
     *
     * @param dir
     *            저장할 경로(서버)
     * @param downloadFileName
     *            다운로드할 파일
     * @param path
     *            저장될 공간
     */
    public void download(String dir, String downloadFileName, String path) {
        InputStream in = null;
        FileOutputStream out = null;
        try {
            channelSftp.cd(dir);
            in = channelSftp.get(downloadFileName);
           
            out = new FileOutputStream(new File(path));
            int i;

            while ((i = in.read()) != -1) {
                out.write(i);
            }
        }catch (SftpException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        } catch (IOException e) {
        	LOGGER.error(e.getLocalizedMessage(), e);
        } finally {
            try {
            	if(out != null) out.close();
            	if(in != null) in.close();
            } catch (IOException e) {
            	LOGGER.error(e.getLocalizedMessage(), e);
            }

        }

    }
    
    /**
     * 인자로 받은 경로의 파일 리스트를 리턴한다.
     * @param path
     * @return
     */
    public Vector<ChannelSftp.LsEntry> getFileList(String path) {
    	
    	Vector<ChannelSftp.LsEntry> list = null;
    	try {
    		channelSftp.cd(path);
    		list = channelSftp.ls(".");
		} catch (SftpException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			return null;
		}
    	
    	return list;
    }
    
    /**
     * 서버와의 연결을 끊는다.
     */
    public void disconnection() {
        channelSftp.quit();

    }
}