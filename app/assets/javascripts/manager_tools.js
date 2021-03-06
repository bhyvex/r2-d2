// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

function sendCanned(link) {
  var body = $(link).prev().val().split('\n').join('%0A').replace(/&/g, "%26");
  var fullName = $(link).closest('div.employee-container').find('h3').text();
  var email = $(link).closest('div.employee-container').find('.email-address').val();
  var month = $('div#month').text();
  var subject = "Salary Report %7C " + fullName + " - " + month;
  var link = "mailto:" + email + "?body=" + body + "&subject=" + subject;
  var cc = $('div#cc').text();
  if (cc.length > 0) link += "&cc=" + cc;
  var bcc = $('div#bcc').text();
  if (bcc.length > 0) link += "&bcc=" + bcc;
  window.open(link, "_self");
}

function sendWelcomeCanned() {
  var body = $('#canned').val().split('\n').join('%0A').replace(/&/g, "%26");
  var emails = $('#email_addresses').val();
  var subject = 'Welcome to Our Team'
  var link = 'mailto:' + emails + '?body=' + body + '&subject=' + subject;
  window.open(link, '_self');
}