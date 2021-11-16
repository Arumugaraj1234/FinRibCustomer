import 'package:finandrib/models/network_response.dart';
import 'package:finandrib/screens/order_confirmation_screen.dart';
import 'package:finandrib/support_files/constants.dart';
import 'package:finandrib/support_files/data_services.dart';
import 'package:finandrib/support_files/network_services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DateDetail {
  String day;
  String date;
  String month;
  bool isSelected;
  String fullDate;
  bool isDisabled;

  DateDetail(
      {this.day,
      this.date,
      this.month,
      this.isSelected,
      this.fullDate,
      this.isDisabled});
}

class TimeSlot {
  int id;
  String name;
  bool isEligible;
  bool isSelected;

  TimeSlot({this.id, this.name, this.isEligible, this.isSelected});
}

enum DeliveryType { scheduledDelivery, expressDelivery }

class DeliveryTypeScreen extends StatefulWidget {
  @override
  _DeliveryTypeScreenState createState() => _DeliveryTypeScreenState();
}

class _DeliveryTypeScreenState extends State<DeliveryTypeScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _expressDeliveryCharge = 15;
  DeliveryType _deliveryType = DeliveryType.scheduledDelivery;
  List<DateDetail> _datesToShow = [];
  double _walletAmount = 0;

  List<TimeSlot> _timeSlotsArray = [
    TimeSlot(
        id: 1, name: '07:00 AM - 09:00 AM', isEligible: true, isSelected: true),
    TimeSlot(
        id: 2,
        name: '09:00 AM - 11:00 AM',
        isEligible: true,
        isSelected: false),
    TimeSlot(
        id: 4,
        name: '11:00 AM - 01:00 PM',
        isEligible: true,
        isSelected: false),
    TimeSlot(
        id: 5,
        name: '01:00 PM - 03:00 PM',
        isEligible: true,
        isSelected: false),
    TimeSlot(
        id: 6,
        name: '03:00 PM - 05:00 PM',
        isEligible: true,
        isSelected: false),
    TimeSlot(
        id: 7, name: '05:00 PM - 07:00 PM', isEligible: true, isSelected: false)
  ];

  List<TimeSlot> _reqTimeSlotArray = [];

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _getWalletAmount() async {
    NetworkResponse response = await NetworkServices.shared.getCustomerInfo();
    double amount = 0;
    if (response.code == 1) {
      double resData = response.data;
      amount = resData;
    }
    setState(() {
      _walletAmount = amount;
    });
  }

  void getAllDates() {
    DateTime currentDate = DateTime.now();
    for (int i = 0; i < 5; i++) {
      DateTime date = currentDate.add(Duration(days: i));
      var formatter = new DateFormat('dd-MMM-yyyy');
      String formattedDate = formatter.format(date);
      print(formattedDate); // 2016-01-25
      var dayFormatter = new DateFormat('E');
      String day = dayFormatter.format(date);
      var dateOnlyFormatter = new DateFormat('dd');
      String dateOnly = dateOnlyFormatter.format(date);
      var monthFormatter = new DateFormat('MMM');
      String month = monthFormatter.format(date);
      bool isSelected;
      if (i == 0) {
        isSelected = true;
      } else {
        isSelected = false;
      }
      DateDetail dateDetail = DateDetail(
          day: day.toUpperCase(),
          date: dateOnly,
          month: month.toUpperCase(),
          isSelected: isSelected,
          fullDate: formattedDate,
          isDisabled: false);
      _datesToShow.add(dateDetail);
    }
    print(_datesToShow);
    _setTimeSlot();
  }

  void _setDatesSelectionState(int index) {
    if (index == 0) {
      _setTimeSlot();
    } else {
      setState(() {
        _reqTimeSlotArray = _timeSlotsArray;
      });
    }

    for (var i = 0; i < _datesToShow.length; i++) {
      if (i == index) {
        setState(() {
          _datesToShow[i].isSelected = true;
        });
      } else {
        setState(() {
          _datesToShow[i].isSelected = false;
        });
      }
      setState(() {
        _datesToShow[i].isDisabled = false;
      });
    }
  }

  void _setTimeSlot() {
    DateTime currentTime = DateTime.now();
    DateTime time0700 =
        DateTime(currentTime.year, currentTime.month, currentTime.day, 7, 00);
    DateTime time0900 =
        DateTime(currentTime.year, currentTime.month, currentTime.day, 9, 00);
    DateTime time1100 =
        DateTime(currentTime.year, currentTime.month, currentTime.day, 11, 00);
    DateTime time1300 =
        DateTime(currentTime.year, currentTime.month, currentTime.day, 13, 00);
    DateTime time1500 =
        DateTime(currentTime.year, currentTime.month, currentTime.day, 15, 00);
    DateTime time1700 =
        DateTime(currentTime.year, currentTime.month, currentTime.day, 17, 00);
    DateTime time1900 =
        DateTime(currentTime.year, currentTime.month, currentTime.day, 19, 00);

    List<TimeSlot> temp = [];
    if (currentTime.isBefore(time0700)) {
      print('Time is before 07:00 AM');
      temp = _timeSlotsArray;
    } else if ((currentTime.isAfter(time0700) ||
            currentTime.isAtSameMomentAs(time0700)) &&
        currentTime.isBefore(time0900)) {
      print('Time is between 07:00 AM  to 09:00 AM');
      temp = [
        TimeSlot(
            id: 1,
            name: '07:00 AM - 09:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 2,
            name: '09:00 AM - 11:00 AM',
            isEligible: true,
            isSelected: true),
        TimeSlot(
            id: 4,
            name: '11:00 AM - 01:00 PM',
            isEligible: true,
            isSelected: false),
        TimeSlot(
            id: 5,
            name: '01:00 PM - 03:00 PM',
            isEligible: true,
            isSelected: false),
        TimeSlot(
            id: 6,
            name: '03:00 PM - 05:00 PM',
            isEligible: true,
            isSelected: false),
        TimeSlot(
            id: 7,
            name: '05:00 PM - 07:00 PM',
            isEligible: true,
            isSelected: false)
      ];
    } else if ((currentTime.isAtSameMomentAs(time0900) ||
            currentTime.isAfter(time0900)) &&
        currentTime.isBefore(time1100)) {
      print('Time is between 09:00 AM to 11:00 AM');

      temp = [
        TimeSlot(
            id: 1,
            name: '07:00 AM - 09:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 2,
            name: '09:00 AM - 11:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 4,
            name: '11:00 AM - 01:00 PM',
            isEligible: true,
            isSelected: true),
        TimeSlot(
            id: 5,
            name: '01:00 PM - 03:00 PM',
            isEligible: true,
            isSelected: false),
        TimeSlot(
            id: 6,
            name: '03:00 PM - 05:00 PM',
            isEligible: true,
            isSelected: false),
        TimeSlot(
            id: 7,
            name: '05:00 PM - 07:00 PM',
            isEligible: true,
            isSelected: false)
      ];
    } else if ((currentTime.isAtSameMomentAs(time1100) ||
            currentTime.isAfter(time1100)) &&
        currentTime.isBefore(time1300)) {
      print('Time is between 11:00 AM to 01:00 PM');
      temp = [
        TimeSlot(
            id: 1,
            name: '07:00 AM - 09:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 2,
            name: '09:00 AM - 11:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 4,
            name: '11:00 AM - 01:00 PM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 5,
            name: '01:00 PM - 03:00 PM',
            isEligible: true,
            isSelected: true),
        TimeSlot(
            id: 6,
            name: '03:00 PM - 05:00 PM',
            isEligible: true,
            isSelected: false),
        TimeSlot(
            id: 7,
            name: '05:00 PM - 07:00 PM',
            isEligible: true,
            isSelected: false)
      ];
    } else if ((currentTime.isAtSameMomentAs(time1300) ||
            currentTime.isAfter(time1300)) &&
        currentTime.isBefore(time1500)) {
      print('Time is between 01:00 PM to 03:00 PM');
      temp = [
        TimeSlot(
            id: 1,
            name: '07:00 AM - 09:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 2,
            name: '09:00 AM - 11:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 4,
            name: '11:00 AM - 01:00 PM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 5,
            name: '01:00 PM - 03:00 PM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 6,
            name: '03:00 PM - 05:00 PM',
            isEligible: true,
            isSelected: true),
        TimeSlot(
            id: 7,
            name: '05:00 PM - 07:00 PM',
            isEligible: true,
            isSelected: false)
      ];
    } else if ((currentTime.isAtSameMomentAs(time1500) ||
            currentTime.isAfter(time1500)) &&
        currentTime.isBefore(time1700)) {
      print('Time is between 03:00 PM to 05:00 PM');
      temp = [
        TimeSlot(
            id: 1,
            name: '07:00 AM - 09:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 2,
            name: '09:00 AM - 11:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 4,
            name: '11:00 AM - 01:00 PM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 5,
            name: '01:00 PM - 03:00 PM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 6,
            name: '03:00 PM - 05:00 PM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 7,
            name: '05:00 PM - 07:00 PM',
            isEligible: true,
            isSelected: true)
      ];
    } else {
      print('No more time slots');
      temp = [
        TimeSlot(
            id: 1,
            name: '07:00 AM - 09:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 2,
            name: '09:00 AM - 11:00 AM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 4,
            name: '11:00 AM - 01:00 PM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 5,
            name: '01:00 PM - 03:00 PM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 6,
            name: '03:00 PM - 05:00 PM',
            isEligible: false,
            isSelected: false),
        TimeSlot(
            id: 7,
            name: '05:00 PM - 07:00 PM',
            isEligible: false,
            isSelected: false)
      ];
    }

    setState(() {
      _reqTimeSlotArray = temp;
    });
  }

  void _onTimeSlotSelected(int index) {
    if (_reqTimeSlotArray[index].isEligible) {
      for (var i = 0; i < 5; i++) {
        if (i == index) {
          setState(() {
            _reqTimeSlotArray[index].isSelected = true;
          });
        } else {
          setState(() {
            _reqTimeSlotArray[i].isSelected = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getAllDates();
    _getWalletAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            'Delivery Type',
            style: kTextStyleAppBarTitle,
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        'Select Delivery Type',
                        style: kTextStyleCalibri300.copyWith(fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width - 90) /
                                        2,
                                height:
                                    (MediaQuery.of(context).size.width - 90) /
                                        2,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 3,
                                        spreadRadius: 2,
                                        offset: Offset(0, 0),
                                      )
                                    ]),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'images/truck_icon.png'),
                                                    fit: BoxFit.fill)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrange,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'SCHEDULED DELIVERY',
                                            style:
                                                kTextStyleCalibri600.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                          ),
                                          Text(
                                            'FREE',
                                            style: kTextStyleCalibriBold
                                                .copyWith(fontSize: 12),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _setDatesSelectionState(0);
                                  setState(() {
                                    _deliveryType =
                                        DeliveryType.scheduledDelivery;
                                  });
                                },
                                child: Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 90) /
                                          2,
                                  height:
                                      (MediaQuery.of(context).size.width - 90) /
                                          2,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, right: 5.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        _deliveryType ==
                                                DeliveryType.scheduledDelivery
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: Colors.deepOrange,
                                        size: 25.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Stack(
                            children: [
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width - 90) /
                                        2,
                                height:
                                    (MediaQuery.of(context).size.width - 90) /
                                        2,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 3,
                                        spreadRadius: 2,
                                        offset: Offset(0, 0),
                                      )
                                    ]),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'images/bike_icon.png'),
                                                    fit: BoxFit.fill)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrange,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'EXPRESS DELIVERY',
                                            style:
                                                kTextStyleCalibri600.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                          ),
                                          Text(
                                            '$kMoneySymbol$_expressDeliveryCharge',
                                            style: kTextStyleCalibriBold
                                                .copyWith(fontSize: 12),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _deliveryType =
                                        DeliveryType.expressDelivery;
                                    for (DateDetail date in _datesToShow) {
                                      setState(() {
                                        date.isDisabled = true;
                                        date.isSelected = false;
                                      });
                                    }

                                    setState(() {
                                      _reqTimeSlotArray = [
                                        TimeSlot(
                                            id: 1,
                                            name: '07:00 AM - 09:00 AM',
                                            isEligible: false,
                                            isSelected: false),
                                        TimeSlot(
                                            id: 2,
                                            name: '09:00 AM - 11:00 AM',
                                            isEligible: false,
                                            isSelected: false),
                                        TimeSlot(
                                            id: 4,
                                            name: '11:00 AM - 01:00 PM',
                                            isEligible: false,
                                            isSelected: false),
                                        TimeSlot(
                                            id: 5,
                                            name: '01:00 PM - 03:00 PM',
                                            isEligible: false,
                                            isSelected: false),
                                        TimeSlot(
                                            id: 6,
                                            name: '03:00 PM - 05:00 PM',
                                            isEligible: false,
                                            isSelected: false),
                                        TimeSlot(
                                            id: 7,
                                            name: '05:00 PM - 07:00 PM',
                                            isEligible: false,
                                            isSelected: false)
                                      ];
                                    });
                                  });
                                },
                                child: Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 90) /
                                          2,
                                  height:
                                      (MediaQuery.of(context).size.width - 90) /
                                          2,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, right: 5.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        _deliveryType ==
                                                DeliveryType.expressDelivery
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: Colors.deepOrange,
                                        size: 25.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        'Select Delivery Date',
                        style: kTextStyleCalibri300.copyWith(fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Container(
                        height: 310.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 0), // changes position of shadow
                              ),
                            ],
                            color: Colors.white),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 20),
                              child: Container(
                                height: 100,
                                child: Row(
                                  children: [
                                    DateCard(
                                      dateToShow: _datesToShow[0],
                                      onSelect: () {
                                        if (!_datesToShow[0].isDisabled) {
                                          _setDatesSelectionState(0);
                                        }
                                      },
                                    ),
                                    DateCard(
                                      dateToShow: _datesToShow[1],
                                      onSelect: () {
                                        if (!_datesToShow[1].isDisabled) {
                                          _setDatesSelectionState(1);
                                        }
                                      },
                                    ),
                                    DateCard(
                                      dateToShow: _datesToShow[2],
                                      onSelect: () {
                                        if (!_datesToShow[2].isDisabled) {
                                          _setDatesSelectionState(2);
                                        }
                                      },
                                    ),
                                    DateCard(
                                      dateToShow: _datesToShow[3],
                                      onSelect: () {
                                        if (!_datesToShow[3].isDisabled) {
                                          _setDatesSelectionState(3);
                                        }
                                      },
                                    ),
                                    DateCard(
                                      dateToShow: _datesToShow[4],
                                      onSelect: () {
                                        if (!_datesToShow[4].isDisabled) {
                                          _setDatesSelectionState(4);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              TimeSlotCard(
                                                timeSlot: _reqTimeSlotArray[0],
                                                onPressed: () {
                                                  _onTimeSlotSelected(0);
                                                },
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              TimeSlotCard(
                                                timeSlot: _reqTimeSlotArray[2],
                                                onPressed: () {
                                                  _onTimeSlotSelected(2);
                                                },
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              TimeSlotCard(
                                                timeSlot: _reqTimeSlotArray[4],
                                                onPressed: () {
                                                  _onTimeSlotSelected(4);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              TimeSlotCard(
                                                timeSlot: _reqTimeSlotArray[1],
                                                onPressed: () {
                                                  _onTimeSlotSelected(1);
                                                },
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              TimeSlotCard(
                                                timeSlot: _reqTimeSlotArray[3],
                                                onPressed: () {
                                                  _onTimeSlotSelected(3);
                                                },
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              TimeSlotCard(
                                                timeSlot: _reqTimeSlotArray[5],
                                                onPressed: () {
                                                  _onTimeSlotSelected(5);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40.0,
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      color: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Total',
                                style: kTextStyleCalibri600.copyWith(
                                    fontSize: 16.0, color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '$kMoneySymbol ${dataServices.selectedProductsTotalPrice}',
                                style: kTextStyleCalibri600.copyWith(
                                    fontSize: 16.0, color: Colors.deepOrange),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
                    Expanded(
                      child: Container(
                        color: Colors.deepOrange,
                        height: double.infinity,
                        child: FlatButton(
                          onPressed: () {
                            //dataServices.setWalletAmount(_walletAmount);
                            dataServices.setPromoOffer(null);
                            if (_deliveryType ==
                                DeliveryType.scheduledDelivery) {
                              DateDetail selectedDate;
                              TimeSlot selectedTimeSlot;
                              for (DateDetail date in _datesToShow) {
                                if (date.isSelected) {
                                  selectedDate = date;
                                  break;
                                }
                              }
                              for (TimeSlot timeSlot in _reqTimeSlotArray) {
                                if (timeSlot.isSelected) {
                                  selectedTimeSlot = timeSlot;
                                  break;
                                }
                              }

                              if (selectedDate != null &&
                                  selectedTimeSlot != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return OrderConfirmationScreen(
                                        deliveryType: _deliveryType,
                                        selectedDate: selectedDate,
                                        selectedTimeSlot: selectedTimeSlot);
                                  }),
                                );
                              } else {
                                _showSnackBar(
                                    'Please select the date & time slot of delivery');
                              }
                            } else {
                              //dataServices.setDeliveryCharge(15);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return OrderConfirmationScreen(
                                      deliveryType: _deliveryType);
                                }),
                              );
                            }
                          },
                          child: Text(
                            'PROCEED',
                            style: kTextStyleCalibriBold.copyWith(
                                fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

class DateCard extends StatelessWidget {
  final DateDetail dateToShow;
  final Function onSelect;

  DateCard({this.dateToShow, this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onSelect,
        child: Container(
          decoration: BoxDecoration(
            color: dateToShow.isSelected ? Colors.deepOrange : Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    dateToShow.month,
                    style: kTextStyleCalibri600.copyWith(
                        color: (dateToShow.isDisabled == false)
                            ? (dateToShow.isSelected
                                ? Colors.white
                                : Colors.black)
                            : Colors.grey,
                        fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    dateToShow.date,
                    style: kTextStyleCalibriBold.copyWith(
                        fontSize: 25,
                        color: (dateToShow.isDisabled == false)
                            ? (dateToShow.isSelected
                                ? Colors.white
                                : Colors.black)
                            : Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    dateToShow.day,
                    style: kTextStyleCalibri600.copyWith(
                        color: (dateToShow.isDisabled == false)
                            ? (dateToShow.isSelected
                                ? Colors.white
                                : Colors.black)
                            : Colors.grey,
                        fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeSlotCard extends StatelessWidget {
  final TimeSlot timeSlot;
  final Function onPressed;

  TimeSlotCard({this.timeSlot, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            color: timeSlot.isSelected ? Colors.deepOrange : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Center(
              child: Text(
                timeSlot.name,
                style: kTextStyleCalibri300.copyWith(
                  fontSize: 13,
                  color: timeSlot.isSelected
                      ? Colors.white
                      : (timeSlot.isEligible ? Colors.black : Colors.black26),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
