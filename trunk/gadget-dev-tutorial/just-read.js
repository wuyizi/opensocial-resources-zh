var viewer;                   // 类型：opensocial.Person
var viewerFriends;            // 类型：opensocial.Collection
var viewerBooks;              // 类型：{'books': json}

var owner;                    // 类型：opensocial.Person
var onwerBooks;               // 类型：{'books': json}
var viewerFriendsBooks;       // 类型：{id: {'books': json}}

var bookList = ['西游记', '三国演义', '水浒传', '红楼梦'];

/* 可点击的书名 */
function bookHTML(book) {
  return "<li style='cursor:pointer' onclick=\"onReadBook(\'" + book + "\');\">" + 
         "<i>" + book + "</i></li>";
};

/* 显示书架里的书名 */
function showAvailableBooks() {
  var html = new Array();
  var len = bookList.length;
  for (var i = 0; i < len; ++i) {
    html.push(bookHTML(bookList[i]));
  }
  document.getElementById('allBooks').innerHTML = html.join('');
};


/* 显示自己已读过的书 */
function showViewerBooks() {

  /* 解析当前数据 */
  var json = viewerBooks['books'];
  var books;
  try  {
    books = gadgets.json.parse(gadgets.util.unescapeString(json)) || [];
  } catch(e) {
    books = [];
  }

  /* 显示书名 */
  var html = new Array();
  var len = books.length;
  for (var i = 0; i < len; ++i) {
    html.push("<li><i>" + books[i] + "</i></li>");
  }
  document.getElementById('viewerBooks').innerHTML = html.join('');
};


/* 显示对方已读过的书 */
function showOwnerBooks() {
  /* 解析当前数据 */
  var json = ownerBooks['books'];
  var books = [];
  try  {
    books = gadgets.json.parse(gadgets.util.unescapeString(json)) || [];
  } catch(e) {
    books = [];
  }
  
  /* 显示书名 */
  var html = new Array();
  var len = books.length;
  for (var i = 0; i < len; ++i) {
    html.push(bookHTML(books[i]));
  }
  document.getElementById('ownerBooks').innerHTML = html.join('');
};


/* 显示朋友已读过的书 */
function showFriendsBooks() {
  var html = new Array();
 
  /* 遍历每个朋友 */
  for (var friendId in viewerFriendsBooks) {
    var data = viewerFriendsBooks[friendId];
    var friend = viewerFriends.getById(friendId);
    
    /* 解析数据 */
    var json = data['books'];
    var books = [];
    try  {
      books = gadgets.json.parse(gadgets.util.unescapeString(json)) || [];
    } catch(e) {
      books = [];
    }
    
    /* 显示书名 */
    html.push("<li>" + friend.getDisplayName() + "<ul>");
    var len = books.length;
    for (var i = 0; i < len; ++i) {
      html.push(bookHTML(bookList[i]));
    }
    html.push("</ul></li>");
  }
  document.getElementById('friendsBooks').innerHTML = html.join('');
};


function postReadActivity(book) {
  var title = "读了" + book;
  var params = {};
  params[opensocial.Activity.Field.TITLE] = title;
  var activity = opensocial.newActivity(params)
  opensocial.requestCreateActivity(activity, opensocial.CreateActivityPriority.HIGH, function() {});
};

/* 处理书名点击响应 */
window.onReadBook = function(book) {

  /* 解析当前数据 */
  var json = viewerBooks['books'];
  var books;
  try  {
    books = gadgets.json.parse(gadgets.util.unescapeString(json)) || [];
  } catch(e) {
    books = [];
  }

  /* 检查是否已经读过 */
  var len = books.length;
  for (var i = 0; i < len; ++i) {
    if (book == books[i]) {
      alert("我已经读过" + book + "了");
      return;
    }
  }

  /* 串行化新的数据 */
  books.push(book);
  json = gadgets.json.stringify(books);

  /* 发送更新请求 */
  var req = opensocial.newDataRequest();
  req.add(req.newUpdatePersonAppDataRequest('VIEWER', 'books', json));
  req.send(function(dataResponse) {
    alert("我读了" + book);
    /* 更新后刷新所有数据 */
    reloadAll();
  });

  postReadActivity(book);
};


/* 显示基本信息 */
function showBasic() {
  /* 显示 VIEWER 名字 */
  document.getElementById('me').innerHTML = viewer.getDisplayName();

  /* 显示 VIEWER 的朋友名字 */
  var html = new Array();
  viewerFriends.each(function(friend) {
    html.push(friend.getDisplayName() + ", ");
  });
  document.getElementById('friends').innerHTML = html.join('');
  
  /* 显示 OWNER 的名字 */
  document.getElementById('ownerName').innerHTML = owner.getDisplayName();
};


/* 发送 Opensocial API 请求 */
function reloadAll() {
  var req = new opensocial.DataRequest();
  req.add(req.newFetchPersonRequest('VIEWER'), 'v');
  req.add(req.newFetchPeopleRequest('VIEWER_FRIENDS'), 'vf');
  req.add(req.newFetchPersonAppDataRequest('VIEWER', 'books'), 'vd');

  req.add(req.newFetchPersonRequest('OWNER'), 'o');
  req.add(req.newFetchPersonAppDataRequest('OWNER', 'books'), 'od');
  req.add(req.newFetchPersonAppDataRequest('VIEWER_FRIENDS', 'books'), 'vfd');

  req.send(onReloadAll);
};


/* 处理 Opensocial API 响应 */
function onReloadAll(dataResponse) {

  /* 获取数据 */
  viewer = dataResponse.get('v').getData() || {};
  viewerFriends = dataResponse.get('vf').getData() || {};
  viewerBooks = dataResponse.get('vd').getData()[viewer.getId()] || {};  // {'books': json}

  owner = dataResponse.get('o').getData() || {};
  ownerBooks = dataResponse.get('od').getData()[owner.getId()] || {};  // {'books': json}
  viewerFriendsBooks = dataResponse.get('vfd').getData() || {};  // {id:{'books': json}}
  
  /* 显示数据 */
  showBasic();
  showAvailableBooks();
  showViewerBooks();
  showOwnerBooks();
  showFriendsBooks();
};

/* 处理清空按钮响应 */
window.onClearBooks = function() {
  var req = opensocial.newDataRequest();
  req.add(req.newUpdatePersonAppDataRequest('VIEWER', 'books', null));
  req.send(function(dataResponse) {
    alert("清空了");
    /* 更新后刷新所有数据 */
    reloadAll();
  });
}


function initDOM() {
  document.getElementById('dom_handle').innerHTML = 

  "<div id='main'>" +
  "<b>我：</b>" +
  "<p id='me'></p>" +
  "<b>我的朋友：</b>" +
  "<p id='friends'></p>" +
  "<b>我读过的书：</b>" +
  "<u style='cursor:pointer' onclick='onClearBooks();'>[清空]</u>" +
  "<ul id='viewerBooks'></ul>" +
  "<b id='ownerName'></b><b>读过的书：</b>" +
  "<ul id='ownerBooks'></ul>" +
  "<b>我的朋友读过的书：</b>" +
  "<ul id='friendsBooks'></ul>" +
  "<b>书架：</b>" +
  "<ul id='allBooks'></ul>" +
  "</div>";
}

/* Gadget 执行入口 */
function init() {
  initDOM();
  reloadAll();
};

init();

