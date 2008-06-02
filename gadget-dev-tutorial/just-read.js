var viewer = {};                   // opensocial.Person
var owner = {};                    // opensocial.Person
var viewerFriends = {};            // opensocial.Collection
var onwerFriends = {};             // opensocial.Collection
var viewerBooks = {};              // {'books':[]}
var onwerBooks = {};               // {'books':[]}
var viewerFriendsBooks = {};       // {'id':{'books':[]}}
var bookList = ['a cashew nut', 'a peanut', 'a hazelnut', 'a red pistaschio nut'];

var dom = {};

function showBasic() {
  document.getElementById('me').innerHTML = "<b>" + viewer.getDisplayName() + "</b>";
  var html = new Array();
  viewerFriends.each(function(person) {
    html.push("<li><b>" + person.getDisplayName() + "</b></li>");
  });
  document.getElementById('friends').innerHTML = html.join('');
  document.getElementById('ownerName').innerHTML = owner.getDisplayName();
};

window.onClearBook = function() {
  var req = opensocial.newDataRequest();
  req.add(req.newUpdatePersonAppDataRequest('VIEWER', 'books', ''));
  req.send(function(data) {
    reloadAll();
  });
}

window.onReadBook = function(book) {
  var json = viewerBooks['books'];
  var books = [];
  try  {
    books = gadgets.json.parse(gadgets.util.unescapeString(json));
  } catch(e) {
    books = [];
  }

  var len = books.length;
  for (var i = 0; i < len; ++i) {
    if (book == books[i]) {
      alert("I've already read this book.");
      return;
    }
  }

  books.push(book);
  json = gadgets.json.stringify(books);

  var req = opensocial.newDataRequest();
  req.add(req.newUpdatePersonAppDataRequest('VIEWER', 'books', json));
  req.send(function(data) {
    reloadAll();
  });
};


function showAvailableBooks() {
  var html = new Array();
  var len = bookList.length;
  for (var i = 0; i < len; ++i) {
    var item = bookList[i];
    html.push("<li style='cursor:pointer' onclick=\"onReadBook(\'");
    html.push(item);
    html.push("\');\"><i>");
    html.push(item);
    html.push("</i></li>");
  }
  document.getElementById('allBooks').innerHTML = html.join('');
};

function showViewerBooks() {
  var html = new Array();
  var json = viewerBooks['books'];
  var books = [];
  try  {
    books = gadgets.json.parse(gadgets.util.unescapeString(json));
  } catch(e) {
    books = [];
  }
  var len = books.length;
  for (var i = 0; i < len; ++i) {
    var item = books[i];
    html.push("<li><i>");
    html.push(item);
    html.push("</i></li>");
  }
  document.getElementById('viewerBooks').innerHTML = html.join('');
};

function showOwnerBooks() {
  var html = new Array();
  var json = ownerBooks['books'];
  var books = [];
  try  {
    books = gadgets.json.parse(gadgets.util.unescapeString(json));
  } catch(e) {
    books = [];
  }
  var len = books.length;
  for (var i = 0; i < len; ++i) {
    var item = books[i];
    html.push("<li><i>");
    html.push(item);
    html.push("</i></li>");
  }
  document.getElementById('ownerBooks').innerHTML = html.join('');
};

function showFriendsBooks() {
  var html = new Array();
 
  for (var friendId in viewerFriendsBooks) {

    var data = viewerFriendsBooks[friendId];
    var friend = viewerFriends.getById(friendId);
    var json = data['books'];
    var books = [];
    try  {
      books = gadgets.json.parse(gadgets.util.unescapeString(json));
    } catch(e) {
      books = [];
    }
    html.push("<li><b>");
    html.push(friend.getDisplayName());
    html.push("</b><ul>");
    var len = books.length;
    for (var i = 0; i < len; ++i) {
      var item = books[i];
      html.push("<li><i>");
      html.push(item);
      html.push("</i></li>");
    }
    html.push("</ul></li>");
  }
  document.getElementById('friendsBooks').innerHTML = html.join('');
};

function reloadAll() {
  var req = new opensocial.DataRequest();
  req.add(req.newFetchPersonRequest('VIEWER'), 'v');
  req.add(req.newFetchPeopleRequest('VIEWER_FRIENDS'), 'vf');
  req.add(req.newFetchPersonRequest('OWNER'), 'o');
  req.add(req.newFetchPersonAppDataRequest('VIEWER', 'books'), 'vd');
  req.add(req.newFetchPersonAppDataRequest('VIEWER_FRIENDS', 'books'), 'vfd');
  req.add(req.newFetchPersonAppDataRequest('OWNER', 'books'), 'od');
  req.send(onReloadAll);
};

function onReloadAll(data) {
  viewer = data.get('v').getData() || {};
  owner = data.get('o').getData() || {};
  viewerFriends = data.get('vf').getData() || {};
  viewerBooks = data.get('vd').getData()[viewer.getId()] || {};  // {'books':[]}
  ownerBooks = data.get('od').getData()[owner.getId()] || {};  // {'books':[]}
  viewerFriendsBooks = data.get('vfd').getData() || {};          // {'id':{'books':[]}}

  showBasic();
  showAvailableBooks();
  showViewerBooks();
  showOwnerBooks();
  showFriendsBooks();
};

function init() {
  dom = document.getElementById('dom_handle');
  dom.innerHTML =
    "<u>Me: <span id='me'></u><br/>" +
    "<u>My Friends:</u><br><ul id='friends'></ul>" +
    "<u>Books I have read:</u> <a style='cursor:pointer' onclick='onClearBook();return false;'>Click to Clear</a><br><ul id='viewerBooks'></ul>" +
    "<u>Books <b id='ownerName'>[Owner Name]</b> has read:</u><br><ul id='ownerBooks'></ul>" +
    "<u>Books my friends have read:</u><br><ul id='friendsBooks'></ul>" +
    "<u>All Avaliable Books:</u><br><ul id='allBooks'></ul>";
  
  reloadAll();
};

init();

