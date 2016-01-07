require 'spec_helper'


RSpec.describe Spree::WechatpayController, type: :controller do

  describe "POST #notify" do
    notify_data = {
      
        return_code: "<![CDATA[SUCCESS]]>", 
        result_code: "<![CDATA[SUCCESS]]>", 
        appid: "<![CDATA[wx2421b1c4370ec43b]]>", 
        attach: "<![CDATA[支付测试]]>", 
        bank_type: "<![CDATA[CFT]]>", 
        out_trade_no: '<![CDATA[1409811653]]>', 
        total_fee: '1'
    }
    
    it "return fail when wechat notify return_code is success" do
      request.env['RAW_POST_DATA'] = notify_data
      response = lambda { post :notify, :use_route => :spree }
      request.env.delete('RAW_POST_DATA')
      expect(response).to have_http_status(:success)
    end
    
  end

end
