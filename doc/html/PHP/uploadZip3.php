<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="../img/favicon.ico">

    <title>neurocelle.org</title>

    <!-- Bootstrap core CSS -->
    <link href="../bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="../css/cover.css" rel="stylesheet">
  </head>

  <body>

    <div class="site-wrapper">

      <div class="site-wrapper-inner">

        <div class="cover-container">

          <div class="masthead clearfix">
            <div class="inner">
              <h3 class="masthead-brand">MaAp Laboratories</h3>
              <nav class="nav nav-masthead">
                <a class="nav-link active" href="../index.html">Home</a>
                <a class="nav-link" href="../downloads.html">Downloads</a>
                <a class="nav-link" href="../docs.html">Docs</a>
                <a class="nav-link" href="../about.html">About</a>
              </nav>
            </div>
          </div>
		
		  <div class="inner cover">
			<h1 class="cover-heading">Neurocelle</h1>
 			<p class="lead">A Machine Learning Environment!</p>
			<hr>
			<br>
			<br>
			<!--
 			<form action=./PHP/uploadZip.php method="post" enctype="multipart/form-data">
		 		<label class="btn btn-default btn-file">
					<p>Upload your project file.<br>
					Or learn about upload possibilities at the <a href="tutorial.html">Tutorial</a> page.</p>
					<br>
		 			<input type="file" name="fileToUpload" id="fileToUpload">
 					<input type="submit" value="Upload File" name="submit">
 				</label>
			</form>
			-->
 			<form action=./uploadZip3.php method="post" enctype="multipart/form-data">
				<p>You can upload more files.<br>
				Or learn about other tricks in our <a href="../docs.html">documentation</a>.</p>
				<br>

		 		<label class="btn btn-default btn-file">
		 			<input type="file" name="fileToUpload" id="fileToUpload">
 				</label>
 				<input type="submit" value="Upload File" name="submit">
 			</form>
			<?php
				$location = "../../uploads/";
				$name = $_FILES["fileToUpload"]["name"];
				$tmp_name = $_FILES["fileToUpload"]["tmp_name"];
				$size = $_FILES["fileToUpload"]["size"];
				$type = $_FILES["fileToUpload"]["type"];
				$pos = strpos(substr($name,-4),'.') + 1;
				$ext = strtolower(substr(substr($name,-4),$pos));
				
				//echo $ext;
				
				
				// Testing ...	
				if(isset($name)){
					if(!empty($name) && ($ext == "zip" || $ext == "tar" || $ext == "gz" || $ext == "tgz")){// && $type == "application/zip"){
						// Can upload only .zip files until 10M.
						if(move_uploaded_file($tmp_name,$location.$name)){
							echo "<p>Your file was successfully uploaded!</p>";
							echo "<p>Please, wait for a custom report of your project file that will be sent to your email.</p>";
							
							//$oname = substr($name,0,strpos($name,"."));
							
							//passthru('mkdir ../../udata/'. $oname, $returnval);
							//passthru('cp ' . $location.$name . ' actions/' . $oname, $returnval);
							//passthru('cp ' . $location.$name . ' /home/leonel);
							//passthru('chmod 777 actions/' . $oname . '/' . $name, $returnval);
							//passthru('chmod 777 -R actions/', $returnval);
							
							// Command 'cd' doesn't works.
							//if($ext == 'zip'){
							//	passthru('unzip actions/' . $oname . '/' . $name . ' -d actions/' . $oname, $returnval);
							//} else {
							//	passthru('tar -zxvf actions/' . $oname . '/' . $name . ' -C actions/' . $oname, $returnval);
							//}
							
							// Matlab RUN!!
							//passthru('matlab -nojvm -r \'cd actions/' . $oname . '; '. $oname .'\'', $returnval);
							//exec('matlab -nojvm -r \'cd actions/' . $oname . '; '. $oname .'\' > actions/' . $oname . '/output');
							//passthru('pwd', $returnval);
							//echo $returnval;
							
							//passthru('./ncl;', $returnval);
							//passthru('echo "Msg atoumatica neurocelle" | mutt -s "Tretas" -c estrogonelda@hotmail.com estrogonelda@gmail.com -a actions/' . $oname . '/' . $name, $returnval);
							//echo "<hr/>".$returnval;
						}else{
							echo "Error while uploading file!" . "<br>";
						}
					}else{
						echo "<p>Unsupported file extension. Please, choose a .zip, .tar, .gz or .tgz file. </p>";
					}
				}else{
					echo "<br> File unset. It mustn't exceed 2 Mb!";
				}
			?>
		  </div>

          <div class="mastfoot">
            <div class="inner">
              <p>See the <a href="https://github.com/estrogonelda/neurocelle">neurocelle</a>
			  repository at GitHub, or contact us at <a href="https://github.com/estrogonelda">estrogonelda@gmail.com</a>.</p>
            </div>
          </div>

        </div>

      </div>

    </div>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://code.jquery.com/jquery-3.1.1.slim.min.js" integrity="sha384-A7FZj7v+d/sdmMqp/nOQwliLvUsJfDHW+k9Omg/a/EheAdgtzNs3hpfag6Ed950n" crossorigin="anonymous"></script>
    <script>window.jQuery || document.write('<script src="../bootstrap/assets/js/vendor/jquery.min.js"><\/script>')</script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js" integrity="sha384-DztdAPBWPRXSA/3eYEEUWrWCy7G5KFbe8fFjk5JAIxUYHKkDx6Qin1DkWx51bBrb" crossorigin="anonymous"></script>
    <script src="../bootstrap/dist/js/bootstrap.min.js"></script>
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="../bootstrap/assets/js/ie10-viewport-bug-workaround.js"></script>
  </body>
</html>
