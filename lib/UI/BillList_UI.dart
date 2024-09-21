import 'package:academy_manager/API/BillList_API.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BillList extends StatefulWidget {
  const BillList({super.key});

  @override
  State<BillList> createState() => _BillListState();
}

class _BillListState extends State<BillList> {
  BilllistApi _api = BilllistApi();
  String? name;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeData();
  }

  _initializeData() async{
    name = await _api.getName();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(subjects: ['미적분', '영어', '국어'],),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name.toString() +"님 청구서 목록",
                  style: TextStyle(fontSize: 24.sp),
                ),
                18.verticalSpace,
                Expanded(
                  child: Container(
                    width: 320.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        children: _getBillList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getBillList(){
    return [
      ListTile(
        title: Text(
          name.toString() + "(수강반)\nTotal: ₩300,000"
        ),
        trailing: Text("미납부", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
        onTap: (){

        },
      ),
      ListTile(
        title: Text(
            name.toString() + "(수강반)\nTotal: ₩700,000"
        ),
        trailing: Text("납부", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
        onTap: (){

        },
      ),
    ];
  }
}
