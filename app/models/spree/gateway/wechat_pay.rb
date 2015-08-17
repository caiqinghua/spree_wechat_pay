module Spree
  class Gateway::WechatPay < Gateway
    preference :appId, :string
    preference :appKey, :string
    preference :partnerId, :string
    preference :partnerKey, :string
    preference :secret, :string
    preference :iconUrl, :string
    preference :returnHost, :string

    def supports?(source)
      true
    end

    def purchase(amount, express_checkout, gateway_options={})
      Class.new do
        def success?; true; end
        def authorization; nil; end
      end.new
    end

    def auto_capture?
      true
    end

    def capture(amount, response_code, gateway_options)
      ActiveMerchant::Billing::Response.new(true, 'WechatPay:#{response_code}', {}, test: false)
    end

    def source_required?
      false
    end

    def method_type
      'wechatpay'
    end

  end
end
