
package proc.util;

import java.util.*;
import java.sql.*;
import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import org.apache.commons.io.IOUtils;
import org.apache.commons.codec.binary.Base64;


public class MeeknessData {

   public static Connection dbConn() {

      Connection conn = null;  

      try {
          String url = "jdbc:postgresql://*****:5432/meekness?user=***&password=***&ssl=false";        

          Class.forName("org.postgresql.Driver");
          conn = DriverManager.getConnection(url, pg_user, pg_pwd);
                     
      } catch ( SQLException err ) {            
          System.out.println(err.getMessage());            
      } catch (ClassNotFoundException e) {
          e.printStackTrace();
      }      

      return(conn);

   }

   public static void dbClose(Connection conn){
      try {
          conn.close();                            
      }          
      catch ( SQLException err ) {            
          System.out.println(err.getMessage());            
      }      
   }

   public static List<String[]> charDropDown() {

      List<String[]> cboList = new ArrayList<String[]>(); 
      Connection conn = dbConn();  
     
      try {
          String strSQL = "SELECT c.ID, c.Character FROM Characters c ORDER BY c.Character";
          PreparedStatement pstmt = conn.prepareStatement(strSQL);
          ResultSet rs = pstmt.executeQuery();

          while (rs.next()) {
	      cboList.add(new String[] {Integer.toString(rs.getInt("ID")), rs.getString("Character")});
          }

      } catch ( SQLException err ) {            
          System.out.println(err.getMessage());            
      } finally {
          dbClose(conn);
      }
      return(cboList);   
  }


   public List<String> getChar(int i){

         List<String> charList = new ArrayList<String>(); 
         Connection conn = dbConn();  
     
	 String strSQL = "SELECT c.Character, c.Description, c.Quote, c.Picture FROM Characters c WHERE c.ID = ?";

         try { 
	      PreparedStatement pstmt = conn.prepareStatement(strSQL);
              pstmt.setInt(1, i);

	      ResultSet rs = pstmt.executeQuery();

	      rs.next();
	      rs.getString(1);

              InputStream blob = ((InputStream) rs.getBinaryStream("Picture"));
              byte[] returnBytes = IOUtils.toByteArray(blob);

	      StringBuilder sb = new StringBuilder();
	      sb.append("data:image/jpeg;base64,");
	      sb.append(Base64.encodeBase64String(returnBytes));

	      String imgData = sb.toString();
              String descData = rs.getString(2);
              String quoteData = (rs.getString(3) == null) ? "" : rs.getString(3);

              charList.add(imgData);
              charList.add(descData);
              charList.add(quoteData);

	      rs.close();
	      pstmt.close();
 
	 } catch ( SQLException err ) {            
	     System.out.println(err.getMessage());           
	 } catch ( IOException ioe ) {            
             System.out.println(ioe.getMessage());            
         } finally {
             dbClose(conn);
         }

         return charList;
   }

   public List<String> getQual(int i){

         List<String> l = new ArrayList<String>();
         Connection conn = dbConn();  

     	 String strSQL = "SELECT q.Quality " +
	                 " FROM Characters c INNER JOIN Qualities q" + 
		         "  ON q.CharacterID = c.ID" + 
		         " WHERE c.ID = ?";

         try { 
	      PreparedStatement pstmt = conn.prepareStatement(strSQL);
              pstmt.setInt(1, i);

	      ResultSet rs = pstmt.executeQuery();

	      while (rs.next()) {
	         l.add(rs.getString("Quality"));
     	      }

	 } catch ( SQLException err ) {            
	     System.out.println(err.getMessage());          
	 } finally {
             dbClose(conn);
         }

         return l;

   }
    
   public List<String[]> getMatchChars(int i){

         List<String[]> l = new ArrayList<String[]>();
         Connection conn = dbConn();       

	 String strSQL = "WITH cte AS " + 
                         "  (SELECT c.ID, c.Character, q.Quality " +
                         "   FROM Characters c " +
                         "   INNER JOIN Qualities q ON c.ID = q.CharacterID) " +
                         " " +
                         "SELECT c2.ID, c2.Character As MatchChar " +
                         "FROM cte c1 " +
                         "INNER JOIN cte c2 ON c1.Quality = c2.Quality " +
                         "WHERE c1.ID = ? AND c2.ID <> ? " +
                         "GROUP BY c1.Character, c2.ID, c2.Character " +
                         "ORDER BY Count(*) DESC";

         try { 

	      PreparedStatement pstmt = conn.prepareStatement(strSQL);
              pstmt.setInt(1, i);
              pstmt.setInt(2, i);

	      ResultSet rs = pstmt.executeQuery();

	      while (rs.next()) {
	         l.add(new String[] {Integer.toString(rs.getInt("ID")), rs.getString("MatchChar")});
     	      }

	 } catch ( SQLException err ) {            
	     System.out.println(err.getMessage());          
	 } finally {
             dbClose(conn);
         }

         return l;

   }

   public List<String> getMatchQuals(int i){

         List<String> l = new ArrayList<String>();
         Connection conn = dbConn();    

	 String strSQL = "WITH cte AS " + 
                         "  (SELECT c.ID, c.Character, q.Quality " +
                         "   FROM Characters c " +
                         "   INNER JOIN Qualities q ON c.ID = q.CharacterID) " +
                         " " +
                         "SELECT c1.Quality As MatchQual " +
                         "FROM cte c1 " +
                         "INNER JOIN cte c2 ON c1.Quality = c2.Quality " +
                         "WHERE c1.ID = ? AND c2.ID <> ? " +
                         "GROUP BY c1.Quality " +
                         "ORDER BY Count(*) DESC";

         try { 

	      PreparedStatement pstmt = conn.prepareStatement(strSQL);
              pstmt.setInt(1, i);
              pstmt.setInt(2, i);

	      ResultSet rs = pstmt.executeQuery();

	      while (rs.next()) {
	         l.add(rs.getString("MatchQual"));
     	      }

	 } catch ( SQLException err ) {            
	     System.out.println(err.getMessage());          
	 } finally {
             dbClose(conn);
         }

         return l;

   }

}
