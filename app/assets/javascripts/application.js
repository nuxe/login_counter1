// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

$(document).ready(function () {

	$("#logout_button").hide();


	$("#logout_button").click(function () {
		$("#top_message").text("Please Enter Your Credentials Below");
		$("#Login_Form").show()
		$("#user_user").val("")
		$("#user_password").val("")
		$("#logout_button").hide();
	})

	$("#login_button").click(function(){
		sendAjax_login('/users/login')
	});

	// bind to the submit event of our form
	$("#add_button").click(function(){
		sendAjax_add('/users/add')
	});

	function sendAjax_login (url) {
		var userName = $("#user_user").val()
		var passWord = $("#user_password").val()

	    var json_params = {"user":userName, "password":passWord}
		request = $.ajax({
			  url: url,
			  type: 'POST',	
	          dataType: 'json',
	          data: json_params,
	          success: function  (argument) {		

	     var errCode = argument["errCode"]
		var output = "";
		$("#bottom_message").text(output);

		if (errCode == 1) {
			var count = argument["count"];
			output = "Welcome " + userName + " You have logged in  " + count + " times.";
			$("#bottom_message").text(output);
			output = "Welcome " + userName
			$("#Login_Form").hide()
			$("#logout_button").show()
		} else if (errCode == -1) {
			var count = argument["count"];
			output = "You have logged in  " + 2 + " times.";
			$("#bottom_message").text(output);
			output = "Welcome " + userName
			$("#Login_Form").hide()
			$("#logout_button").show()
		} else if (errCode == -2) {
			output = "User name already exists";
		} else if (errCode == -3) {
			output = "Usernme too long/empty";
		} else if (errCode == -4) {
			output = "Password too long";
		}

		$("#top_message").text(output);
		$("#top_message").css("font-weight","Bold");
		$("#bottom_message").css("font-weight","Bold");

	          	
	          }
	    });
	}


	function sendAjax_add (url) {
		var userName = $("#user_user").val()
		var passWord = $("#user_password").val()

	    var json_params = {"user":userName, "password":passWord}
		request = $.ajax({
			  url: url,
			  type: 'POST',	
	          dataType: 'json',
	          data: json_params,
	          success: function  (argument) {

	     var errCode = argument["errCode"]
		var output = "";
		$("#bottom_message").text(output);

		if (errCode == 1) {
			var count = argument["count"];
			output = "Welcome " + userName + " You have logged in  " + count + " times.";
			$("#bottom_message").text(output);
			output = "Welcome " + userName
			$("#Login_Form").hide()
			$("#logout_button").show()
		} else if (errCode == -1) {
			var count = argument["count"];
			output = "You have logged in  " + 2 + " times.";
			$("#bottom_message").text(output);
			output = "Welcome " + userName
			$("#Login_Form").hide()
			$("#logout_button").show()
		} else if (errCode == -2) {
			output = "User name already exists";
		} else if (errCode == -3) {
			output = "Usernme too long/empty";
		} else if (errCode == -4) {
			output = "Password too long";
		}

		$("#top_message").text(output);
		$("#top_message").css("font-weight","Bold");
		$("#bottom_message").css("font-weight","Bold");
	          }
	    });
	}

	

});
