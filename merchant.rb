require 'iconv'
require 'net/http'
require 'uri'
module Alipay
  class Merchant
    GATEWAY='http://www.alipay.com/cooperate/gateway.do'
    NOTIFY_HTTP_VERIFY ='http://notify.alipay.com/trade/notify_query.do'
    NOTIFY_HTTPS_VERIFY ='https://www.alipay.com/cooperate/gateway.do'
    TRANSPORT ='http'
    SIGN_TYPE ='MD5'
    INPUT_CHARSET='UTF-8'
    KEY='pojyh234234234234234234qp4jeoz' # 密码
    CONFIG = {
            :service=>'create_direct_pay_by_user',
            :partner=>'208232342349770', # partner_id
            :payment_type=>'1',
            :paymethod=>'bankPay',
            :defaultbank=>'SDB',
            :seller_email=>'example@example.com', # partner_email 卖家email
            :seller_id=>'',
            :it_b_pay=>'',
            :royalty_type=>'',
            :royalty_parameters=>'',
            }
    ATTRIBUTES=[:notify_url, :return_url, :show_url, :subject, :body, :out_trade_no, :price, :total_fee, :quantity, :buyer_email, :buyer_id]
    ARGUMENTS =CONFIG.keys + ATTRIBUTES
    attr_accessor *ATTRIBUTES

    def initialize(options={}, & block)
      options.each { |attr, value| instance_eval "self.#{attr}='#{value}'" }
      yield(self)
    end

    #购买商品的URI
    def uri
      options = parameters
      type, sign = sign(SIGN_TYPE, options)
      "#{GATEWAY}?%s&sign=#{sign}&sign_type=#{type}" % options.map { |k, v| k.to_s + '=' +v.to_s }.join('&')
    end

    #验证通知的正确性
    def self.notify_verify(options={})
      notify_url = URI.parse("#{NOTIFY_HTTP_VERIFY}?partner=#{CONFIG[:partner]}&notify_id=#{options[:notify_id]}")
      {"true"=>true, "false"=>false}[Net::HTTP.get(notify_url)]
    end

    private
    #sanitize the parameters
    def parameters
      configs=ARGUMENTS-ATTRIBUTES
      @params=CONFIG.dup.delete_if { |k, v| !configs.include?(k) }
      ATTRIBUTES.each do |a|
        @params.merge!(a => send(a))
      end
      @params.store(:_input_charset, INPUT_CHARSET)
      @params.delete_if { |k, v| v.nil? || v=="" }
    end

    #请求参数按照参数名字符升序排列，如果有重复参数名，那么重复的参数再按照参数值的字符升序排列
    #所有参数（除了sign和sign_type）按照上面的排序用&连接起来，格式是:p1=v1&p2=v2
    def sign(sign_type, options={})
      type = sign_type.to_s.upcase
      if type.eql?('md5')
        key = options.sort { |k1, k2| k1.to_s<=>k2.to_s }.map { |k, v| k.to_s + '=' + v.to_s }.join('&')
        return type, Digest::MD5.hexdigest(key+Alipay::Merchant::KEY)
      else
        raise "unimplement other algorithm!"
      end
    end
  end
end
