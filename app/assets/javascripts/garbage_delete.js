function doPost(e) {
  console.log(this)
  var json = JSON.parse(e.postData.contents);
  var access_token = ENV["LINE_CHANNEL_TOKEN"]
  data = event.events[0];
  replyToken = data.replyToken;
  if ('postback' == json.events[0].type) {
    var data = json.events[0].postback.data;

    // 送信されてきたデータを使った処理
    // 今回の場合、「visited」or「unvisited」の文字列と、神社の場所 ID が送信される。

    messages = [{'type': 'text', 'text': '行ったことがある神社を更新しました'}]; 

    UrlFetchApp.fetch(LINE_REPLY_URL, {
      'headers': {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + access_token,
      },
      'method': 'post',
      'payload': JSON.stringify({
        'replyToken': replyToken,
        'messages': messages,
      }),
    });
    return ContentService.createTextOutput(JSON.stringify({'content': 'post ok'})).setMimeType(ContentService.MimeType.JSON);
  }
}
