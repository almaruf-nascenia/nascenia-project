var ready, set_positions;

set_positions = function(){
    // loop through and give each task a data-pos
    // attribute that holds its position in the DOM
    $('.panel.panel-default').each(function(i){
        $(this).attr("data-pos",i+1);
    });
}

ready = function(){
    $('.sortable').sortable({
        cursor: "move",
        placeholder: "sortable-placeholder",
        update: function(e, ui) {
            var updated_order = $(".sortable").sortable('toArray', {attribute: "project"});
            // send the updated order via ajax
            console.log(updated_order);
            $.ajax({
                type: "post",
                url: '/projects/sortable',
                data: { order: updated_order }
            });
        }
    });
}

$(document).ready(ready);
/**
 * if using turbolinks
 */
$(document).on('page:load', ready);


function showAddDeveloperDialog(pro_id) {
    $.ajax({
        url: "/projects/" +pro_id + "/dev_list",
        type: 'get',
        dataType: 'script'
    });
}

function createTeam(){
    $("#addDeveloperDialog").modal('hide');
    $("#createTeamForm").submit();
}