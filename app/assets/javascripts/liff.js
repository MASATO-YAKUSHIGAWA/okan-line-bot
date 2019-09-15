window.onload = function (e) {
  liff.init(function (data) {
      initializeApp(data);
  });
};

function initializeApp(data) {
  document.getElementById('g_line_id').value = data.context.userId; //line_idをhiddn_fieldへ代入

  document.getElementById('garbage_done').addEventListener('click', function () { //選択した項目をメッセージ送信
    var wday_idx = document.getElementById("wday_selecter").selectedIndex;
    var wday = document.getElementById("wday_selecter").options[wday_idx].text; //曜日の取得
    var nth_idx = document.getElementById("nth_selecter").selectedIndex;
    var nth = document.getElementById("nth_selecter").options[nth_idx].text; //第何週の取得
    var type_idx = document.getElementById("type_selecter").selectedIndex;
    var g_type = document.getElementById("type_selecter").options[type_idx].text; //種類の取得
        liff.sendMessages([{
        type: 'text',
        text: `曜日：${wday} \n週：${nth} \n種類：${g_type}`
    }])
  })

  document.getElementById('garbage_done').addEventListener('click', function () { //LIFFを閉じる
  liff.closeWindow();
  })
}