
jQuery(function($){
  $.datepicker.regional['de'] = {
    clearText: 'löschen', 
    clearStatus: 'aktuelles Datum löschen',
    closeText: 'schließen', 
    closeStatus: 'ohne Änderungen schließen',
    prevText: '&#x3c;zurück', 
    prevStatus: 'letzten Monat zeigen',
    nextText: 'Vor&#x3e;', 
    nextStatus: 'nächsten Monat zeigen',
    currentText: 'heute', 
    currentStatus: '',
    monthNames: ['Januar','Februar','März','April','Mai','Juni',
    'Juli','August','September','Oktober','November','Dezember'],
    monthNamesShort: ['Jan','Feb','Mär','Apr','Mai','Jun',
    'Jul','Aug','Sep','Okt','Nov','Dez'],
    monthStatus: 'anderen Monat anzeigen', 
    yearStatus: 'anderes Jahr anzeigen',
    weekHeader: 'Wo', 
    weekStatus: 'Woche des Monats',
    dayNames: ['Sonntag','Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag'],
    dayNamesShort: ['So','Mo','Di','Mi','Do','Fr','Sa'],
    dayNamesMin: ['So','Mo','Di','Mi','Do','Fr','Sa'],
    dayStatus: 'Setze DD als ersten Wochentag', 
    dateStatus: 'Wähle D, M d',
    dateFormat: 'dd.mm.yy', 
    firstDay: 1, 
    initStatus: 'Wähle ein Datum', 
    isRTL: false
  };
  $.datepicker.setDefaults($.datepicker.regional['de']);
});


datePick = function(elem)
{
  jQuery(elem).datepicker( { 
    dateFormat: 'yy-mm-dd',
    onSelect: function(dateText, inst) { 	
      var sgrid = $("#etikett")[0];
      sgrid.triggerToolbar();
    }
  } )	;
}

  
function get_selected_ids() {
  //ausgewählte IDs zum Löschen/Drucken aus Cookie holen, falls gesetzt.
  if ($.cookie("jqsel_grid_id") !== null) {
    var ids = $.cookie("jqsel_grid_id");
    ids = $.evalJSON(ids);
    gr = new Array();
    $.each(ids, function(index, value) {
      gr.push(value.id);
    })

  } else {
    gr = jQuery("#etikett").jqGrid('getGridParam','selarrrow'); 
  }
  
  return (gr);
    
}
       
$(document).ready(function() {
  
  //Pager
  jQuery("#etikett").jqGrid('navGrid','#pager_etikett',{
    edit:false,
    add:false,
    del:false,
    search:false
  });

  //Filter zurücksetzen
  jQuery("#etikett").jqGrid('navButtonAdd','#pager_etikett',
  {
    caption:"Filter zurücksetzen", 
    onClickButton:function()     {
      var grid = $("#etikett");
      grid[0].clearToolbar();
    }
  }); 
  
  


  //ausgewählte drucken
  $('#print_selected').click(function() {
    gr = get_selected_ids();
    window.open(print_path+ "?id="+gr);
    if( gr.length != 0 ) { 
      $.ajax({
        url: print_path, 
        data: {
          id: gr
        }
      });     
      clean_up();
    }
    else alert("Bitte eine Zeile auswählen!");
    $('#etikett').trigger('reloadGrid');

  });



  //ausgewählte löschen
  $('#delete').click(function(){ 			    
    gr = get_selected_ids();
    
    if( gr.length != 0 ) { 

      jQuery("#etikett").jqGrid('delGridRow',gr,{ 
        afterComplete : function(response){ 
          if (response.statusText == "success") {
            $("span.message").remove();
            $("span.error").prepend("<span class='message'> " + gr.length+
              " Signatur(en) erfolgreich gelöscht. </span>");
           $("span.message").delay(1800).fadeOut(600);
          } else {
            $("span.error").html("Fehler beim Löschen.");
          }      
        
        } 
      }); 
            
      $("td.delmsg").html("Sie haben <strong>"+ gr.length +"</strong> Signatur(en) <br />" +
        "ausgewählt. Wirklich löschen?");

      clean_up();
    }
    else alert("Bitte eine Zeile auswählen!");
    $('#etikett').trigger('reloadGrid');
  });



  //Toolbar initialisieren
  $('#etikett').jqGrid('filterToolbar',  {
    stringResult : true,
    searchOnEnter : true
  });

});

//Beim Verlassen der Ansicht die Auswahl aufheben und Cookie löschen
$(window).unload(function() {
  clean_up();
});


/*
* Initialisiert das Cookie zum Speichern der selektierten Zeilen.
*
* Gespeichert wird die jqGrid-ID der ausgewaehlten Zeile. Die Daten werden im JSON-
* Format im Cookie abgelegt.
*/
var cookie_init = function() {
  selected_jq_ids = $.cookie('jqsel_grid_id');
  if (selected_jq_ids != null) {
    currentGridIds = new Array();
    currentGridIds = $('#etikett').getDataIDs();
    selected_jq_ids_array = new Array();
    var encoded = $.cookie("jqsel_grid_id");
    selected_jq_ids_array = $.evalJSON(encoded);
    var e;
    var i;
    for (e=0; e < currentGridIds.length; e++) {
      for (i=0; i < selected_jq_ids_array.length; i++) {
        if (selected_jq_ids_array[i].id == currentGridIds[e]) {
          // Falls etwas ausgewaehlt ist, die Auswahl aber nicht im  Cookie
          // verzeichnet ist -> Auswahl aufheben.
               
          $('#etikett').setSelection(selected_jq_ids_array[i].id,false);
        }
      }
    }
  }
}

/*
* Speichern/Loeschen in/aus Cookie bei Auswahl bzw. Abwahl einer Zeile.
*/
var cookie_selected = function(id,selected) {

  // Wenn noch kein Cookie existiert und etwas ausgewaehlt wurde...
  if($.cookie('jqsel_grid_id') == null && selected == true) {
    var jsel = [{
      id:id
    }];
    
    var encoded = $.toJSON(jsel);
    $.cookie("jqsel_grid_id", encoded);
  }
  // Wenn schon ein Cookie existiert und etwas an- oder abgewaehlt wurde...
  else {
    encoded = $.cookie("jqsel_grid_id");
    selected_jq_ids_array = new Array();
    selected_jq_ids_array = $.evalJSON(encoded);

    // Zeile ausgewaehlt.
    if(selected == true) {
      selected_jq_ids_array.push({
        id:id
      });

    }
    // Zeile abgewaehlt.
    else {
      // Eintrag aus dem Array loeschen.
      // Id des zu loeschenden Eintrags finden.
      var delete_id;
      for (i=0; i < selected_jq_ids_array.length; i++) {
        if (selected_jq_ids_array[i].id == id) {
          delete_id = i;
        }
      }
      // Eintrag loeschen.
      selected_jq_ids_array.splice(delete_id, 1);
    }
    // Cookie komplett loeschen, falls die Auwahl leer ist.
    if(selected_jq_ids_array.length == 0) {
      $.cookie("jqsel_grid_id", null);
    }
    else {
      encoded = $.toJSON(selected_jq_ids_array);
      $.cookie("jqsel_grid_id", encoded);
    }
  }

}

/*
* Cookie loeschen und ausgewaehlte Zeilen abwaehlen.
*/
function clean_up() {
  $.cookie('jqsel_grid_id', null);
  $("#etikett").resetSelection();
}

