$(document).ready(function() {
  $('#per_page_selector').on('change', function(){
     $('#per_page_button').trigger('click');
  });
  var questionList = $('#question-list.votable')
  questionList.on('click', '.voting .vote:not(.myvote)', function() {
    var questionEl = $(this).parents('li')
    var question = questionEl.data()
    var url = "/rounds/" + question.round + "/questions/" +  question.id + "/vote"
    var value = $(this).hasClass('vote-down') ? -1 : 1
    questionEl.spin()
    $.post(url, {value: value, page:  question.page}).done(function(result) {
      $('#question_'+result.id).replaceWith(result.html)
    }).always(function() {
      questionEl.spin(false)
    }).fail(function(jqXHR, textStatus, errorThrown) {
      alert('Vote could not be saved.')
    });
  });
})
