import java.util.*;

import java.io.File;
import java.io.BufferedReader;
import java.io.InputStreamReader;

import java.io.IOException;
import java.io.FileNotFoundException;

public class All_Swing {      

     public static void main(String[] args) throws IOException, FileNotFoundException, InterruptedException {
        
        String currentDir = new File("").getAbsolutePath();

        List<String[]> dbjars = new ArrayList<String[]>();
        dbjars.add(new String[]{"Oracle", "ojdbc6.jar"});
        dbjars.add(new String[]{"SQLServer", "mssql-jdbc-6.2.2.jre8.jar"});
        dbjars.add(new String[]{"DB2", "db2jcc4.jar"});
        dbjars.add(new String[]{"Postgres", "postgresql-42.2.2.jar"});
        dbjars.add(new String[]{"MySQL", "mysql-connector-java-5.1.45-bin.jar"});
        dbjars.add(new String[]{"SQLite", "sqlite-jdbc-3.21.0.jar"});
        dbjars.add(new String[]{"Mongo", "mongo-java-driver-3.4.3.jar"});

	List<String> command = new ArrayList<String>();

        for (int i=0; i < dbjars.size(); i++){ 
            command = new ArrayList<String>();
            command.add("java");
            command.add("-cp");
	    command.add(".:" + currentDir + ":/usr/lib/jvm/java-8-oracle/lib/" + dbjars.get(i)[1]);
	    command.add(dbjars.get(i)[0] + "_Swing");

	    ProcessBuilder pb = new ProcessBuilder(command);		
    	    Process p = pb.start();
			
	    InputStreamReader esr = new InputStreamReader(p.getErrorStream());
	    BufferedReader errStreamReader = new BufferedReader(esr);
        }

     }

}
