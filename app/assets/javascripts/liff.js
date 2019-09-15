$(window).on('load', function(){

  if (navigator.userAgent.indexOf("Line") !== -1) {

    // liffアプリ処理
    liff.init(function (data) {
      var userId = data.context.userId;
      yourProcess(userId);
    }, function(error) {
      window.alert(error);
    });

  } else {

    // PC上の処理
    var userId = 'U00f9eeb35c813996557c18e42fb6d334'
    yourProcess(userId);
  }
  if (navigator.userAgent.indexOf("Line") !== -1) {
    liff.sendMessages([
    {
      type: 'text',
      text: '<メッセージ>'
    }
  ]).then(function () {
    liff.closeWindow();
  });

} else {
  // PC上の処理
  console.log('complete sending')
}

document.getElementById('garbage_done').addEventListener('click', function () {
  // https://developers.line.me/ja/reference/liff/#liffsendmessages()
  liff.sendMessages([{
      type: 'text',
      text: "テキストメッセージの送信"
  }, {
      type: 'sticker',
      packageId: '2',
      stickerId: '144'
  }]).then(function () {
      window.alert("送信完了");
  }).catch(function (error) {
      window.alert("Error sending message: " + error);
  });
});
});