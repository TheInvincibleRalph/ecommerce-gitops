<?php
require_once dirname(__DIR__) . '/db.php';

if ((isset($_POST['your_name']) && $_POST['your_name'] != '') && (isset($_POST['your_email']) && $_POST['your_email'] != '')) {
    $yourName = mysqli_real_escape_string($con, $_POST['your_name']);
    $yourEmail = mysqli_real_escape_string($con, $_POST['your_email']);
    $yourPhone = mysqli_real_escape_string($con, $_POST['your_phone']);
    $comments = mysqli_real_escape_string($con, $_POST['comments']);
    $sql = "INSERT INTO contact_form_info (name, email, phone, comments) VALUES ('".$yourName."','".$yourEmail."', '".$yourPhone."', '".$comments."')";
    if (!$result = mysqli_query($con, $sql)) {
        die('There was an error running the query [' . mysqli_error($con) . ']');
    } else {
        echo "Thank you! We will contact you soon";
    }
} else {
    echo "Please fill Name and Email";
}
?>
