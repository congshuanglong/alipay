alipay
======

支付宝的支付接口包
======

Alipay（支付宝)库文件,使用方法如下:
alipay_uri = Alipay::Merchant.new do |m|
  m.return_url = 'hello'
  m.show_url='http://www.baidu.com'
  m.subject = 'goodsName'
  m.body = 'theBodyOfTheGoods'
  m.out_trade_no = '20091009143121'
  m.price = 20.34
  m.quantity = 4
end.uri

