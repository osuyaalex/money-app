import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProductDescription extends StatelessWidget {
  final dynamic products;
  const ProductDescription({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
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
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 25, 12, 12),
                    child: Container(
                      height: 450,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        image: products['itemImage'] != null ?DecorationImage(image: NetworkImage(products['itemImage']),fit: BoxFit.fill):
                            DecorationImage(image: NetworkImage(products['itemImageList'][0]), fit: BoxFit.fill)
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
