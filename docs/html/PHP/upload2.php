<?php
	$location = "uploads/";
	$name = $_FILES["fileToUpload"]["name"];
	$tmp_name = $_FILES["fileToUpload"]["tmp_name"];
	$size = $_FILES["fileToUpload"]["size"];
	$type = $_FILES["fileToUpload"]["type"];
	$ext = strtolower(substr($name,strpos($name,".")+1));

	echo $type;
	
	
	// Testing ...	
	if(isset($name)){
		if(!empty($name) && $ext == "zip" && $type == "application/zip"){
			// Can upload only .zip files until 10M.
			if(move_uploaded_file($tmp_name,$location.$name)){
				echo "File uploaded!" . "<br>";
			}else{
				echo "Error while uploading file!" . "<br>";
			}
		}else{
			echo "Please, choose a .zip file" . "<br>";
		}
	}else{
		echo "<br> File unset.";
	}
?>

