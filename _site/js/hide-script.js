$(function () {
  $(".hiding-example-toggle").html("<i class=\"fa fa-eye-slash\"></i>");
});

$(function() {
  $(".hiding-example-toggle").click(function() {
    var button = $(this);
    var exampleContent = $(this).parent().find(".hiding-example-content");
    if (exampleContent.css("display") == "none") {
      exampleContent.css("display", "block");
      button.html("<i class=\"fa fa-eye\"></i>");
    } else {
      exampleContent.css("display", "none");
      button.html("<i class=\"fa fa-eye-slash\"></i>");
    }
  });
});
