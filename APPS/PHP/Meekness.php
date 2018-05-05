<html>
<head><title>Meekness</title></head>
<link rel="stylesheet" type="text/css" href="style.css"/>

<body>

  <div class="basic-grey">
    <h1>Meekness Characters</h1>
  <?php

    // DEFINE FUNCTIONS
    function dbConnect() {

	$host='*****';
	$database='***';
	$username='***';
	$password='***';

	# open connection
	$conn = new PDO("mysql:host=$host;port=3306;dbname=$database",$username,$password);
	$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        return $conn;	    
    }

    function getChar($dbh, $orig) {
        
        # query character image and quote
	$sql = "SELECT c.`Character`, c.Description, c.Quote, c.Picture FROM Characters c WHERE c.ID = ?";

	$STH = $dbh->prepare($sql);
        $STH->bindParam(1, $orig, PDO::PARAM_INT);
        $STH->execute();

        $row = $STH->fetch(PDO::FETCH_ASSOC);

        return array(base64_encode($row['Picture']), $row['Description'], $row['Quote']);

    }

    function getQual($dbh, $orig) {

        # query qualities
        $sql = "SELECT q.Quality FROM Characters c " .
               "INNER JOIN Qualities q ON q.CharacterID = c.ID " . 
	       "WHERE c.ID = ?";

      	$STH = $dbh->prepare($sql);
        $STH->bindParam(1, $orig, PDO::PARAM_INT);
        $STH->execute();
 
        $qualities = [];

        $STH->setFetchMode(PDO::FETCH_ASSOC);

        while($row = $STH->fetch()) {
            $qualities[] = $row['Quality'];
        }

        return $qualities;

    }

    function dbClose($dbh) {
	# close the connection
	$dbh = null;
    }



    // BUILD FORM
    $dbh = dbConnect();

    # query all characters 
    $sql = "SELECT `ID`, `Character` FROM Characters ORDER BY `Character`";
    $STH = $dbh->query($sql);

  ?>
  
    <form name="meekform" class="smart-green" action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post">
       <h2>Character</h2>
          <select name="meekchar" onchange="this.form.submit()">
  <?php 
       
	  # fetch results
	  while($row = $STH->fetch(PDO::FETCH_ASSOC)) {
  ?>
              <option value="<?php echo $row["ID"]; ?>"><?php echo $row["Character"]; ?></option>
  <?php
          }

    dbClose($dbh);

  ?>
          </select>
       <input type="hidden" name="isSubmit" value="true">
    </form>

  <?php

    if (isset($_POST['isSubmit'])) { 

        $dbh = dbConnect();
        $output = getChar($dbh, $_POST['meekchar']);
  ?>

        <img src="data:image/jpeg;base64, <?php echo $output[0]; ?>" alt="Meek Character" height="300" width="400">
        <h3>Description</h3>
        <p><?php echo $output[1]; ?></p>
        <h3>Quote</h3>
        <p><?php echo $output[2]; ?></p>

        <h3>Qualities</h3>
        <ul>
  <?php
         
         $output = getQual($dbh, $_POST['meekchar']);

         # fetch results
         foreach($output as $qual) {
  ?>
	    <li><?php echo $qual; ?></li>

  <?php
     	 }
  	 dbClose($dbh);

  ?>
	 </ul>

  <?php

   } else {

        $dbh = dbConnect();
        $output = getChar($dbh, 25);
  ?>

        <img src="data:image/jpeg;base64, <?php echo $output[0]; ?>" alt="Meek Character" height="300" width="400">
        <h3>Description</h3>
        <p><?php echo $output[1]; ?></p>
        <h3>Quote</h3>
        <p><?php echo $output[2]; ?></p>

        <h3>Qualities</h3>
        <ul>
  <?php
         
         $output = getQual($dbh, 25);

         # fetch results
         foreach($output as $qual) {
  ?>
	    <li><?php echo $qual; ?></li>

  <?php
     	 }
  	 dbClose($dbh);

  ?>
	 </ul>

  <?php

   }
  ?>

     </div>

  </body>
</html>
