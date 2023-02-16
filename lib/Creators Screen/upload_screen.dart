import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isMultiFileSelected = false;
  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            toolbarHeight: MediaQuery.of(context).size.height*0.1,
            flexibleSpace: LayoutBuilder(
                builder: (context, constraints){
                  return FlexibleSpaceBar(
                    background: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset('assets/images/Logo.svg'),
                            Row(
                              children: [
                                SvgPicture.asset('assets/icons/Search.svg'),
                                const SizedBox(
                                  width: 20,
                                ),
                                SvgPicture.asset('assets/icons/Menu.svg'),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 30, bottom: 20),
                    child: Text('Upload Artwork',
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w700,
                        fontSize: 23
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(30)
                      ),
                      child: Center(
                        child: SvgPicture.asset('assets/icons/Group 26.svg'),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _isMultiFileSelected,
                        onChanged: (value) {
                          setState(() {
                            _isMultiFileSelected = value!;
                          });
                        },
                        side: BorderSide(
                          color: Colors.grey.shade500
                        ),
                      ),
                      Text('Multi-File',
                        style: GoogleFonts.epilogue(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 90,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        itemBuilder: (context, index){

                        },
                      itemCount: 3,
                    )
                  )
                ],
              ),
            ) ,
          )
        ],
      )
    );
  }
}
