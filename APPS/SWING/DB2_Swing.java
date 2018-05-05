import java.sql.* ;

import java.util.List;
import java.util.ArrayList;

import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import java.awt.*;  
import java.awt.event.*;
import java.awt.image.BufferedImage;
import javax.swing.*;
import javax.imageio.ImageIO;


public class DB2_Swing extends Frame implements WindowListener {
      
   private static final long serialVersionUID = 7526472295622776147L;   
   
   public static void main(String[] args) {      
      Build_GUI();
   }

   public static void Build_GUI() {

      ArrayList<String> char_list = new ArrayList<String>();

      Connection conn = dbConn();

      char_list = get_Data(conn, "SELECT c.Character FROM Characters c " +
                                 " ORDER BY c.Character", null);

      try {
          new DB2_Swing(char_list);
      } catch ( IOException ioe ) {            
          System.out.println(ioe.getMessage());            
      } catch ( SQLException sqe ) {            
          System.out.println(sqe.getMessage());            
      }       
   }
   

   public static Connection dbConn() {
      Connection conn = null;    

      try {
	  String url = "jdbc:db2://*****:48000/***";            
          String username = "***";
          String password  = "***";
          Class.forName("com.ibm.db2.jcc.DB2Driver");
          conn = DriverManager.getConnection(url, username, password);      
                     
      } catch ( SQLException err ) {            
          System.out.println(err.getMessage());            
      } catch (ClassNotFoundException e) {
          e.printStackTrace();
      }      
      return(conn);
   }

   public static List<Object> get_CharPic(Connection conn, String strSQL, String param){

      List<Object> dbList = new ArrayList<Object>(); 
   
      try {         
         PreparedStatement pstmt = conn.prepareStatement(strSQL);
         pstmt.setString(1, param);

         ResultSet rs = pstmt.executeQuery();

         rs.next();
         dbList.add(rs.getString(1));
         dbList.add(rs.getBinaryStream("Picture"));
         dbList.add(rs.getString(3));

      }      
      catch ( SQLException err ) {            
          System.out.println(err.getMessage());            
      }      
      return(dbList);      
   }
   
   public static ArrayList<String> get_Data(Connection conn, String strSQL, String param){

      ArrayList<String> dbList = new ArrayList<String>();      

      try {         
         PreparedStatement pstmt = conn.prepareStatement(strSQL);
         if (param != null) {
            pstmt.setString(1, param);
         }
         
         ResultSet rs = pstmt.executeQuery();
         while(rs.next()) {
            dbList.add(rs.getString(1));           
         }

      }      
      catch ( SQLException err ) {            
          System.out.println(err.getMessage());            
      }      
      return(dbList);      
   }
   
   public static void dbClose(Connection conn){
      try {
          conn.close();                            
      }          
      catch ( SQLException err ) {            
          System.out.println(err.getMessage());            
      }      
   }
   
   public static void runData(String charPick, JPanel guipanel, GridBagConstraints c) throws IOException, SQLException {

      List<Object> charpic_list = new ArrayList<Object>();
      ArrayList<String> qual_list = new ArrayList<String>();

      Connection conn = dbConn();

      charpic_list = get_CharPic(conn, "SELECT c.Character, c.Picture, c.Description " +
                                       " FROM Characters c " +
                                       " WHERE c.Character = ?", charPick);
      qual_list = get_Data(conn, "SELECT q.Quality FROM Qualities q " +
                                 "INNER JOIN Characters c ON c.ID = q.CharacterID " +
                                 "WHERE c.Character = ?", charpic_list.get(0).toString());


      if(guipanel.getComponentCount() > 3) {

         Component[] componentList = guipanel.getComponents();

         // REMOVE PREVIOUS CHARACTER AND QUALITIES
         for(Component cp : componentList){

            if (cp == componentList[0]) continue;
            if (cp == componentList[1]) continue;
            if (cp == componentList[2]) continue;

            guipanel.remove(cp);

         }
         guipanel.revalidate();
         guipanel.repaint();
      }

      Font ctrlFont = new Font("Arial", Font.PLAIN, 12);
      Font headFont = ctrlFont.deriveFont(18F);

      // CHARACTER IMAGE   
      JLabel imglbl = new JLabel(charpic_list.get(0).toString(), SwingConstants.CENTER);      
      imglbl.setFont(headFont);      
      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 2;
      guipanel.add(imglbl, c);
   
      InputStream blob = ((InputStream)charpic_list.get(1));
      BufferedImage buffimage = ImageIO.read(blob);

      ImageIcon imgIcon = new ImageIcon(buffimage);
      Image image = imgIcon.getImage(); 						
      Image newimg = image.getScaledInstance(350, 250,  java.awt.Image.SCALE_SMOOTH);
      imgIcon = new ImageIcon(newimg);

      JLabel imagelabel = new JLabel("", imgIcon, JLabel.LEFT);   

      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 3;
      guipanel.add(imagelabel, c);


      // DESCRIPTION LABEL
      JLabel desc_lbl = new JLabel("<html><body style='width:290px'>" + charpic_list.get(2).toString(), SwingConstants.CENTER);
      desc_lbl.setFont(ctrlFont);
      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 4;
      guipanel.add(desc_lbl, c);


      // QUALITY LABELS
      for (int i=0; i < qual_list.size(); i++){
	JLabel qual_lbl = new JLabel(qual_list.get(i), SwingConstants.LEFT);
	qual_lbl.setFont(headFont);
	c.fill = GridBagConstraints.HORIZONTAL;
	c.ipady = 0; 
	c.weighty = 0.05;      
	c.gridx = 0;
	c.gridy = i + 5;
	guipanel.add(qual_lbl, c);
      }  

      dbClose(conn);

   }

   public DB2_Swing(ArrayList<String> char_list) throws IOException, SQLException {

      // SUPER FRAME SETTINGS
      setTitle("Meekness Characters");    
      setSize(400, 850);
      JPanel guipanel = new JPanel(new GridBagLayout());
      GridBagConstraints c = new GridBagConstraints();
      add(guipanel);
            
      Font ctrlFont = new Font("Arial", Font.PLAIN, 12);
      Font headFont = ctrlFont.deriveFont(18F);
            
      // DB IMAGE      
      ImageIcon dbimgIcon = new ImageIcon("DB2.jpg");
      Image dbimage = dbimgIcon.getImage();
      Image newdbimg = dbimage.getScaledInstance(60, 70,  java.awt.Image.SCALE_SMOOTH);
      dbimgIcon = new ImageIcon(newdbimg);

      JLabel dbimagelabel = new JLabel("", dbimgIcon, JLabel.LEFT);      
      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 0;
      guipanel.add(dbimagelabel, c);

      JLabel dbimglbl = new JLabel("               DB2", SwingConstants.LEFT);      
      dbimglbl.setFont(headFont);      
      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 0;
      guipanel.add(dbimglbl, c);

      
      // CHARACTERS DROP DOWN
      Choice charChoice = new Choice();
      charChoice.setFont(ctrlFont);
      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 1;
      guipanel.add(charChoice, c);
      
      for (String i: char_list){
         charChoice.add(i);
      } 
      guipanel.add(charChoice, c);

      runData("Henry Corwin", guipanel, c);

      charChoice.addItemListener(new ItemListener(){ 
	 public void itemStateChanged(ItemEvent ie){           
             try {           
                runData(charChoice.getSelectedItem().toString(), guipanel, c);
             } catch ( IOException ioe ) {            
                System.out.println(ioe.getMessage());            
             } catch ( SQLException sqe ) {            
                System.out.println(sqe.getMessage());            
             }
         }            
      });

      addWindowListener(this);     
      setVisible(true);      

   }
     
   // WindowEvent handlers
   @Override
   public void windowClosing(WindowEvent evt) {
      // Terminate the program
      System.exit(0);                                                          
   }
   
   @Override public void windowOpened(WindowEvent evt) { }
   @Override public void windowClosed(WindowEvent evt) { }
   @Override public void windowIconified(WindowEvent evt) { }
   @Override public void windowDeiconified(WindowEvent evt) { }
   @Override public void windowActivated(WindowEvent evt) { }
   @Override public void windowDeactivated(WindowEvent evt) { }
}
