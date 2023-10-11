import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:futsal/service/Other_Service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'home.dart';



class BookingPage extends StatefulWidget {
  BookingPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _BookingPageState createState() => _BookingPageState();
}



class _BookingPageState extends State<BookingPage> {
  var name = '';
  var address = '';
  var time = '';
  String displayDate = '';
  DateTime selectedDate;
  var phone = '';
  var bookedDate = [];
  var availableDate = [];
  var isEmpty = true;
  var time_slot = [];
  var timeArray = [];
  var cost = 0;
  var discount = {};
  var payAmount = 0;
  Razorpay razorpay;
  var isPaid;


  getId() async{

    // Get User Id
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = (json.decode(prefs.getString('user')));
    phone = user['phone'];
    print(phone);
  }



  getTime() async{
    // Get All Time Slot
    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("settings").doc('time_slot').get();
    if(ds.exists) {
      var dt = jsonDecode(jsonEncode(ds.data()));
      time_slot = dt['time_slot'];
    }

    // Get Discount Details
    DocumentSnapshot ds1 = await FirebaseFirestore.instance.collection("settings").doc('discount').get();
    if(ds1.exists) {
      var dt = jsonDecode(jsonEncode(ds1.data()));
      setState(() {
        discount = dt;
      });
    }

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Razorpay Config
    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);


    getId();
    getTime();
  }

  // Razorpay Config
  void openCheckout(payAmount, paid){
    this.payAmount = payAmount;
    this.isPaid = paid;
    var options = {
      "key" : "rzp_test_SEueD02o0Y4wf7",
      "amount": payAmount * 100,
      "name": name,
      "description": "Payment",
      "prefill": {
        "contact": phone,
        "email": "demo@gmail.com"
      },
      "external": {
        "wallets": ["paytm"]
      },
      "send_sms_hash": true,
      // "order_id": '1234',
      "theme": {
        "color": "#3399cc"
      }
    };
    try{
      razorpay.open(options);
    }catch(e){
    }
  }


  // Razorpay Config
  void handlerPaymentSuccess(PaymentSuccessResponse response){
    print('PaymentSuccess');
    print(response.paymentId);
    setData(response);
  }
  // Razorpay Config
  void handlerErrorFailure(PaymentFailureResponse response){
    print('ErrorFailure');
    moreService().toaster('Payment Failed', Colors.red);
  }
  // Razorpay Config
  void handlerExternalWallet(ExternalWalletResponse response){
    print('ExternalWallet');
  }

  // Razorpay Config
  setData(res) async {
    var id = DateTime.now().millisecondsSinceEpoch;
    Map<String,dynamic> data = {
      "name": name,
      "address": address,
      "date": displayDate,
      "dt": selectedDate.toString(),
      "slot":timeArray,
      "register_on": id,
      "phone_number": phone,
      "current_status": "Upcoming",
      "full_paid": isPaid,
      "type": "Turf",
      "amount": payAmount,
      "paymentId": res.paymentId
    };
    CollectionReference collectionsReference = FirebaseFirestore.instance.collection('mybooking');
    collectionsReference.doc(id.toString()).set(data);
    var iid = displayDate.split('/').join('');
    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("date").doc(iid.toString()).get();
    var timeList = timeArray.map((e) => e['time']).toList();
    if(ds.exists){
      for(var i in timeList){
        var data = [];
        bookedDate.add(i);
        CollectionReference collectionsReference1 = FirebaseFirestore.instance.collection('date');
        collectionsReference1.doc(iid.toString()).update({"date": bookedDate});
      }
    }
    else{
      CollectionReference collectionsReference1 = FirebaseFirestore.instance.collection('date');
      collectionsReference1.doc(iid.toString()).set({"date": timeList});
    }

    setState(() {
      name = '';
      displayDate = '';
      address = '';
      time = '';
      cost = 0;
      timeArray = [];
    });
    moreService().toaster('Successfully Registered', Colors.green);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => HomePage()),
            (route) => false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // Razorpay Config
    razorpay.clear();
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              child: Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Image.network(
                      'https://images.financialexpress.com/2020/11/football.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if(discount['percentage'] != null)
                    Text('Offer: Get ${discount['percentage']}% of Discount on Above ₹${discount['amount']} Booking', style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: TextEditingController(text: name.toString()),
                    decoration: InputDecoration(
                      labelText: "Name",
                    ),
                    style: TextStyle(
                    ),
                    onChanged: (val) {
                      name = val;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: TextEditingController(text: address.toString()),
                    decoration: InputDecoration(
                      labelText: "Address",
                    ),
                    onChanged: (val) {
                      address = val;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    onTap: (){
                      // Select Date and Check for Available Slot
                      if(selectedDate.toString() == 'null'){
                        selectedDate = DateTime.now().add(Duration(days: 1));
                      };
                      _selectDate(context);
                      print(selectedDate.toString());
                    },
                    readOnly: true,
                    controller: TextEditingController(text: displayDate.toString()),
                    decoration: InputDecoration(
                      labelText: "Date of Booking",
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: TextEditingController(text: time.toString()),
                    decoration: InputDecoration(
                      labelText: "Available Slot",
                    ),
                    readOnly: true,
                    onTap: (){
                      print('availableDate');
                      print(availableDate);
                      Dialog('service', availableDate,context);
                    },
                  ),

                  const SizedBox(height: 20.0),
                  MaterialButton(
                    child: Text("Continue With Payment (₹${cost})"),
                    color: Colors.pink,
                    onPressed: () async {
                      // Check Validation
                      if(name.isEmpty || displayDate.isEmpty || address.isEmpty || timeArray.isEmpty){
                        moreService().toaster('Please Fill all the Data', Colors.red);
                      }
                      else{
                        // Payment offers
                        confirmDialog(context);
                      }
                      FocusScope.of(context).unfocus();
                    },
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Payment offers
  void confirmDialog(context){
    var _radioSelected = 1;
    var dis = 0;
    var total = 0;
    if(discount['amount'] != null){
      if(cost >= discount['amount']){
        setState(() {
          dis = (cost * (discount['percentage']/100)).toInt();
          total = cost - dis;
        });
      }
      else{
        total = cost;
      }
    }else{
      setState(() {
        total = cost;
      });
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                            child: Text('Pay ₹${cost}'),
                            color: Colors.green,
                            textColor: Colors.white, // foreground
                            onPressed: () async {
                              var tt = 0;
                              var fullpaid;
                              if(_radioSelected == 1){
                                tt = total;
                                fullpaid = true;
                              }
                              else{
                                tt = ((total)*(25/100)).toInt();
                                fullpaid = false;
                              }
                              openCheckout(tt, fullpaid);
                            }
                        )
                      ],
                    ),
                  ],
                  contentPadding: EdgeInsets.all(10),
                  title: new Text('Booking'),
                  content: Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery
                            .of(context)
                            .size
                            .height * .5),
                    // color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(dis != 0)Text('Discount:(${cost} - ${dis} = ${total})'),
                          RadioListTile(
                            title: Text('Pay Full Amount ₹${total.toString()}'),
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            value: 1,
                            groupValue: _radioSelected,
                            onChanged: (value) {
                              setState(() {
                                _radioSelected = value;
                              });
                            },
                          ),
                          RadioListTile(
                            title: Text('Pay 25% Amount ₹${((total)*(25/100)).toInt().toString()}'),
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            value: 2,
                            groupValue: _radioSelected,
                            onChanged: (value) {
                              setState(() {
                                _radioSelected = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  // Select Available Slot
  void Dialog(service, list, context){
    settime(){
      setState(() {
        time = time;
        timeArray = timeArray;
        cost = cost;
      });
    }
    var task = [];
    print('list');
    print(list);
    task = list;
    showDialog(
        barrierDismissible: isEmpty?true:false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  actions: [
                    WillPopScope(
                      onWillPop: () async => isEmpty?true:false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                              child: Text('Select'),
                              color: Colors.green,
                              textColor: Colors.white, // foreground
                              onPressed: () {
                                setState((){
                                  setState(() {
                                    cost = 0;
                                    timeArray = task.where((element) => element['status'] == true).toList();
                                    print(timeArray);
                                    time = '('+timeArray.map((e) => e['time']).join(') - (') + ')';
                                    for(var i=0;timeArray.length > i;i++){
                                      cost = cost + num.parse(timeArray[i]['cost']);
                                    }
                                  });
                                  print(cost);
                                });
                                settime();
                                Navigator.pop(context);
                              }
                          )
                        ],
                      ),
                    )
                  ],
                  contentPadding: EdgeInsets.all(10),
                  title: new Text('Available Slot'),
                  content: isEmpty?
                  Container(
                    height: MediaQuery.of(context).size.height * .5,
                    child: Center(
                      child: Text('No Available Slots'),
                    ),
                  )
                      :Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * .5),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for(var i in task)
                            ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(i['time'], style: TextStyle(color: Colors.black87),),
                                  (i['status'] == null)?Text(''):(i['status'] == false)?Text(''):Icon(Icons.check, color: Colors.green,)
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  time = i['time'];
                                  if(i['status'] == null){
                                    setState(() {
                                      i['status'] = true;
                                    });
                                  }
                                  else{
                                    if(i['status'] == false){
                                      setState(() {
                                        i['status'] = true;
                                      });
                                    }
                                    else{
                                      setState(() {
                                        i['status'] = false;
                                      });
                                    }
                                  }

                                });

                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }
          );
        }
    );
  }


  // Select Date and Check for Available Slot
  Future<void> _selectDate(BuildContext context) async {
    var date = DateTime.now();
    selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: date.add(Duration(days: 1)), 
      lastDate: date.add(new Duration(days: 30)),
    );
    setState(() {
      cost = 0;
      timeArray = [];
      time = '';
      selectedDate = selectedDate;
      displayDate = (selectedDate.day.toString() +'/'+ selectedDate.month.toString() + "/"+selectedDate.year.toString());
    });
    setDate(displayDate);
  }
  setDate(display) async{
    await EasyLoading.show(
      status: 'Checking available slot',
      maskType: EasyLoadingMaskType.black,
    );
    var data = [];
    var iid = display.split('/').join('');
    setState(() {
      isEmpty = true;
    });
    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("date").doc(iid.toString()).get();
    if(ds.exists){
      var dt = jsonDecode(jsonEncode(ds.data()));
      setState(() {
        data = dt['date'];
        bookedDate = data;
      });
      var allDate = json.decode(json.encode(time_slot));
      for(var i in bookedDate){
        setState(() {
          allDate.removeWhere((item) => item['time'] == i);
        });
        print(allDate);
      }
      setState(() {
        availableDate = allDate;
        if(availableDate.isNotEmpty){
          isEmpty = false;
        }
      });
    }
    else{
      var allDate = json.decode(json.encode(time_slot));
      setState(() {
        isEmpty = false;
        availableDate = allDate;
      });
    }
    EasyLoading.dismiss();
  }
}