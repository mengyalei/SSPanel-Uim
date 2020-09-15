<div class="row">
    <div class="col-lg-6 col-md-6">
        <p class="card-heading">Stripe 充值</p>
        <div class="form-group form-group-label">
            <label class="floating-label">金额</label>
            <input class="form-control" id="price" type="text">
        </div>
    </div>
    <div class="col-lg-6 col-md-6">
        <div class="h5 margin-top-sm text-black-hint" id="qrarea"></div>
    </div>
</div>
<div class="card-action">
    <div class="card-action-btn pull-left">
        <button class="btn btn-flat waves-attach" onclick="stripe('alipay')">
            支付宝
        </button>
        <button class="btn btn-flat waves-attach" onclick="stripe('wechat')">
            微信
        </button>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/gh/davidshimjs/qrcodejs@gh-pages/qrcode.min.js"></script>
<script>
function stripe(type) {
  var price = $('#price').val();
  var pid = 0;
  if (isNaN(price) || price <= 0) {
    if (isNaN(price)) {
      $("#result").modal();
      $$.getElementById('msg').innerHTML = '请输入正确的金额！'
    }else if (price <= 0) {
      $("#result").modal();
      $$.getElementById('msg').innerHTML = '金额不能是0元或负数！'
    }
  } else {
    $.ajax({
      type: "POST",
      url: "/user/payment/purchase",
      dataType: "json",
      data: {
        price: price,
        type: type
      },
      success: function (data) {
        if (data.errcode == 0) {
          if (type == 'alipay') {
              $("#readytopay").modal('hide');
              $$.getElementById('msg').innerHTML = '正在跳转到 Stripe 支付...'
              window.location.href = data.url;
          } else if (type == 'wechat') {
            pid = data.pid;
            $$.getElementById('qrarea').innerHTML = '<div class="text-center"><p>请扫描二维码支付</p><a id="qrcode" style="padding-top:10px;display:inline-block"></a></div>'
            $("#readytopay").modal('hide');
            new QRCode("qrcode", {
                render: "canvas",
                width: 200,
                height: 200,
                text: encodeURI(data.url)
            });
            setTimeout(f, 1200);
          } else if (type == 'creditCard') {
            stripejs.redirectToCheckout({
              sessionId: data.checkoutSessionId
            }).then(function (result) {
              console.log('Failed to process payment.');
            });
          }
        } else {
          $("#result").modal();
          $$.getElementById('msg').innerHTML = data.errmsg;
        }
      }
    });
  }
  function f() {
    $.ajax({
      type: "POST",
      url: "/payment/status",
      dataType: "json",
      data: {
        pid: pid
      },
      success: function (data) {
        if (data.result) {
            //console.log(data);
            $("#result").modal();
            $$.getElementById('msg').innerHTML = '充值成功';
            window.setTimeout("location.href=window.location.href", {$config['jump_delay']});
        }
      },
      error: function (jqXHR) {
        console.log(jqXHR);
      }
    });
    tid = setTimeout(f, 1000); //循环调用触发setTimeout
  }
}
</script>