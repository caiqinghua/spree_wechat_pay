module Spree
  class WechatpayController < StoreController
    #ssl_allowed
    skip_before_action :verify_authenticity_token, only: [:notify]
    skip_before_action :authenticate_user!, only: [:notify]

    def js_api_params
      order = current_order
      @params = {
        body: "#{order.line_items[0].product.name.slice(0,30)}等#{order.line_items.count}件",
        out_trade_no: "#{order.number}_#{Time.now.to_i.to_s}",
        total_fee: (order.total * 100).to_i,
        spbill_create_ip: request.remote_ip,
        notify_url: '/wechatpay/notify',
        trade_type: 'JSAPI', # could be "JSAPI", "NATIVE" or "APP",
        openid: current_user.uid # required when trade_type is `JSAPI`
      }

      @params = WxPay::Service.invoke_unifiedorder @params
      @params = WxPay::Service::generate_jsapi_pay_req @params['prepay_id']
      render json: @params
    end

    def notify
      result = Hash.from_xml(request.body.read)["xml"]

      logger.info "[wechatpay]#{result}"

      if WxPay::Sign.verify?(result)

        order = Spree::Order.find_by(number: result["out_trade_no"].split('_')[0])
        render xml: {return_code: "FAIL", return_msg: "找不到相应的订单"}.to_xml(root: 'xml', dasherize: false) unless order

        wechatpay_method_id = Spree::PaymentMethod.find_by(type: "Spree::Gateway::WechatPay").try(:id)
        wechat_payments = order.payments.where(payment_method_id: wechatpay_method_id)
        wechat_payments.each do |wechat_payment|
          next if wechat_payment.currency == result["fee_type"] && wechat_payment.money.money.cents == result["cash_fee"]
          wechat_payment.capture!
          wechat_payment.response_code = result["transaction_id"]
          render xml: {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
          return
        end
        render xml: {return_code: "FAIL", return_msg: "找不到相应的支付"}.to_xml(root: 'xml', dasherize: false)
      else
        render xml: {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
      end
    end

  end
end