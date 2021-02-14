let host = '89.79.127.216';
let port = 9001;
let topic = 'smarthome/info/#';
let reconnectTimeout = 3000;
let mqtt;
let previousMsg;

function MQTTconnect() {
    mqtt = new Paho.MQTT.Client(host, port, '/ws', "mqtt_panel" + parseInt(Math.random() * 1000, 10));
    let options = {
        timeout: 3,
	      userName: "brazil",
	      password: "inpoland2021",
        useSSL: false,
        cleanSession: true,
        onSuccess: onConnect,
        onFailure: function (message) {
            $('#status').html("Connection failed: " + message.errorMessage + "Retrying...")
                .attr('class', 'alert alert-danger');
            setTimeout(MQTTconnect, reconnectTimeout);
        }
    };

    mqtt.onConnectionLost = onConnectionLost;
    mqtt.onMessageArrived = onMessageArrived;

    $('#walert').addClass('hidden');
    $('#walert').hide()

    mqtt.connect(options);
};

function onButton(but) {
    let message
    let date = new Date();
    if (but != 'form'){
      message = new Paho.MQTT.Message(but);
      if (but == "beep" || but == "on" || but == "off")
          message.destinationName = "smarthome/cmd/alarm";
      else
          message.destinationName = "smarthome/cmd/led";
      mqtt.send(message);
    }
    else {
      if ($('#wform').val() == '') {
          $('#walert').addClass('hidden');
          $('#walert').hide()
      }
      message = new Paho.MQTT.Message($('#wform').val());
      message.destinationName = "smarthome/info/welcome";
      message.retained = true;
      mqtt.send(message);
      $('#wform').val('');
    }
    message = new Paho.MQTT.Message(date.toLocaleString());
    message.destinationName = "smarthome/info/activity";
    message.retained = true;
    mqtt.send(message);
}

function onConnect() {
    $('#status').html('Connected to ' + host + ':' + port)
        .attr('class', 'alert alert-success');
    mqtt.subscribe(topic, { qos: 0 });
    $('#topic').html(topic);
};

function onConnectionLost(response) {
    setTimeout(MQTTconnect, reconnectTimeout);
    $('#status').html("Connection lost. Reconnecting...")
        .attr('class', 'alert alert-warning');
};

function onMessageArrived(message) {
    let topic = message.destinationName;
    let payload = message.payloadString;
    if (typeof previousMsg !== 'undefined') {

        $('#previousmsg').html(previousMsg);
    }
    previousMsg = topic + ':  ' + payload;
    $('#message').html(topic + ':  ' + payload);
    let topics = topic.split('/');
    let area = topics[2];

    switch (area) {
        case 'device1':
            if (payload == 'online') {
                $('#label1').text('Online');
                $('#label1').removeClass('badge-danger').addClass('badge-success');
            } else {
                $('#label1').text('Offline');
                $('#label1').removeClass('badge-success').addClass('badge-danger');
            }
            break;
        case 'device2':
            if (payload == 'online') {
                $('#label2').text('Online');
                $('#label2').removeClass('badge-danger').addClass('badge-success');
            } else {
                $('#label2').text('Offline');
                $('#label2').removeClass('badge-success').addClass('badge-danger');
            }
            break;
          case 'device3':
              if (payload == 'online') {
                  $('#label3').text('Online');
                  $('#label3').removeClass('badge-danger').addClass('badge-success');
              } else {
                  $('#label3').text('Offline');
                  $('#label3').removeClass('badge-success').addClass('badge-danger');
              }
              break;
          case 'alarm':
              switch(payload) {
                  case 'triggered':
                      $('#label5').text('TRIGGERED!!!');
                      $('#label5').removeClass('badge-secondary badge-warning').addClass('badge-danger');
                      break;
                  case 'on':
                      $('#label5').text('Armed');
                      $('#label5').removeClass('badge-danger badge-secondary').addClass('badge-warning');
                      $('#label5').css({'color': 'white'});
                      break;
                  case 'off':
                      $('#label5').text('Sleeping');
                      $('#label5').removeClass('badge-danger badge-warning').addClass('badge-secondary');
                      break;
              }
        case 'ledstate':
            switch(payload) {
                case '0':
                    $('#label4').text('Led OFF');
                    $('#label4').removeClass('badge-primary badge-info badge-success').addClass('badge-danger');
                    break;
                case '1':
                    $('#label4').text('Led Mode 1');
                    $('#label4').removeClass('badge-danger badge-primary badge-info').addClass('badge-success');
                    break;
                case '2':
                    $('#label4').text('Led Mode 2');
                    $('#label4').removeClass('badge-danger badge-primary badge-success').addClass('badge-info');
                    break;
                case '3':
                    $('#label4').text('Led Mode 3');
                    $('#label4').removeClass('badge-danger badge-info badge-success').addClass('badge-primary');
                    break;
            }
            break;
        case 'temp1':
            $('#temperature1').html('Sensor value: ' + payload + ' °C');
            break;
        case 'temp2':
            $('#temperature2').html('Sensor value: ' + payload + ' °C');
            break;
        case 'water':
            $('#water').html('Sensor value: ' + payload);
            break;
        case 'welcome':
            if (payload == '') {
                $('#walert').addClass('hidden');
                $('#walert').hide()
            }
            else {
              $('#welcome').html(payload);
              $('#walert').removeClass('hidden');
              $('#walert').show();
            }
            break;
        case 'activity':
            $('#activity').html(payload);
            break;
        default:
            console.log('Error: Data do not match the MQTT topic.');
            break;
    }
};


$(function () {
  $('#wform').on('keypress', function(e){
    if (e.keyCode == 13){
      e.preventDefault();
      onButton('form');
      $('#wform').val('');
    }

  });
});


$(document).ready(function () {
    MQTTconnect();
});
$(function () {
    $('.alert').on('close.bs.alert', function (e) {
        console.log('closed');
        e.preventDefault();
        $('#walert').addClass('hidden');
        $('#walert').hide()
    });
});
