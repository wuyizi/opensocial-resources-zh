#!/usr/bin/python
# -*- coding: UTF-8 -*-

import wsgiref.handlers
from google.appengine.ext import webapp
from google.appengine.ext import db

class Book(db.Model):
  title = db.StringProperty()

class OutputPage(webapp.RequestHandler):
  def get(self):
    # 读取参数所指定的返回个数，默认是10个
    count = self.request.get("c")
    if count:
      count = int(count)
    else:
      count = 10

    #从数据库中取出数据
    books = Book.all().fetch(count, 0)

    # 返回格式是JSON
    ret = []
    for book in books:
      ret.append("'" + book.title + "'")
    output = "{bookList: [" + ",".join(ret) + "]}"
    self.response.out.write(output)

class InputPage(webapp.RequestHandler):
  def get(self):
    # 输出提供输入的表格
    self.response.out.write("""
      <html><body><form action="/in" method="post">
        <textarea name="content" rows="10" cols="20"></textarea>
        <input type="submit" value="添加">
      </form></body></html>""")

  def post(self):
    # 将内容取出输入数据库
    content = self.request.get('content')
    list = content.splitlines(False)
    for item in list:
      book = Book()
      book.title = item
      book.put()
    self.redirect('/out')

class ClearPage(webapp.RequestHandler):
  def get(self):
    # 输出一个按钮
    self.response.out.write("""
      <html><body><form action="/clear" method="post">
        <input type="submit" value="清空">
      </form></body></html>""")

  def post(self):
    # 删除所有记录
    books = Book.all()
    for book in books:
      book.delete()
    self.redirect('/in')

class MainPage(webapp.RequestHandler):
  def get(self):
    self.response.out.write("""
      <html><body>
        <a href="/in">添加新书</a>
        <a href="/out">查看书架</a>
        <a href="/clear">清空书架</a>
      </body></html>""")

def main():
  # 服务器主入口
  application = webapp.WSGIApplication([
                                        ('/', MainPage),
                                        ('/in', InputPage),
                                        ('/out', OutputPage),
                                        ('/clear', ClearPage)],
                                        debug=True)
  wsgiref.handlers.CGIHandler().run(application)

if __name__ == "__main__":
  main()