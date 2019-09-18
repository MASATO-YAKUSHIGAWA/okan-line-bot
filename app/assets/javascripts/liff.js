window.onload = function (e) {
  liff.init(function (data) {
      initializeApp(data);
  });
};
function initializeApp(data) {
  $('#garbage_content__form').parsley(); //バリデーション
  document.getElementById('g_line_id').value = data.context.userId; //line_idをhiddn_fieldへ代入
  document.getElementById('garbage_done').addEventListener('click', function () { 
    var wday_idx = document.getElementById("wday_selecter").selectedIndex;
    var wday = document.getElementById("wday_selecter").options[wday_idx].text; //曜日の取得
    var f_nth_idx = document.getElementById("1st_nth_selecter").selectedIndex;
    var f_nth = document.getElementById("1st_nth_selecter").options[f_nth_idx].text; //第何週の取得
    var s_nth_idx = document.getElementById("2nd_nth_selecter").selectedIndex;
    var s_nth = document.getElementById("2nd_nth_selecter").options[s_nth_idx].text; //第何週の取得    
    var type_idx = document.getElementById("type_selecter").selectedIndex;
    var g_type = document.getElementById("type_selecter").options[type_idx].text; //種類の取得

      if( wday_idx != 0 && f_nth_idx != 0 && type_idx != 0 && s_nth_idx == 0){ //バリデーション
          liff.sendMessages([{  //選択した項目をメッセージ送信
          type: 'text',
          text: `種類：${g_type} \n週    ：${f_nth} \n曜日：${wday}`
      }])
      
      liff.closeWindow();
    }

    if( wday_idx != 0 && f_nth_idx != 0 && type_idx != 0 && s_nth_idx != 0){ //バリデーション
          liff.sendMessages([{  //選択した項目をメッセージ送信
          type: 'text',
          text: `種類：${g_type} \n週    ：${f_nth} \n週    ：${s_nth} \n曜日：${wday}`
      }])
      
      liff.closeWindow();
    }
  })
}


