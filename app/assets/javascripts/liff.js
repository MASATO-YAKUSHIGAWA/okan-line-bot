window.onload = function (e) {
  liff.init(function (data) {
      initializeApp(data);
  });
};

function initializeApp(data) {

  document.getElementById('g_line_id').value = data.context.userId; //line_idをhiddn_fieldへ代入
  $('#garbage_content__form').parsley(); //バリデーション
  document.getElementById('garbage_done').addEventListener('click', function () { 
    var wday_idx = document.getElementById("wday_selecter").selectedIndex;
    var wday = document.getElementById("wday_selecter").options[wday_idx].text; //曜日の取得
    var nth_idx = document.getElementById("nth_selecter").selectedIndex;
    var nth = document.getElementById("nth_selecter").options[nth_idx].text; //第何週の取得
    var type_idx = document.getElementById("type_selecter").selectedIndex;
    var g_type = document.getElementById("type_selecter").options[type_idx].text; //種類の取得
        liff.sendMessages([{  //選択した項目をメッセージ送信
        type: 'text',
        text: `種類：${g_type} \n週：${nth} \n曜日：${wday}`
    }])
    if(wday_idx == "0" && nth_idx == "0" && type_idx == "0"){

      return false;
    }
  })

  document.getElementById('garbage_done').addEventListener('click', function () { //LIFFを閉じる
  liff.closeWindow();
  })

  if (events[0].postback.data){
  messages = [{'type': 'text', 'text': '行ったことがある神社を更新しました'}]; 
  }
}


