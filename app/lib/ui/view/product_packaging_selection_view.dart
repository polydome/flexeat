import 'package:flexeat/domain/model/product_packaging.dart';
import 'package:flexeat/domain/repository/packaging_repository.dart';
import 'package:flexeat/ui/view/product_packaging_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductPackagingSelectionView extends StatelessWidget {
  final int articleId;
  final void Function(ProductPackaging productPackaging)? onSelected;

  const ProductPackagingSelectionView(
      {Key? key, required this.articleId, this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Select packaging",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(
            height: 250,
            child: FutureBuilder<List<ProductPackaging>>(
                initialData: const [],
                future: context
                    .read<PackagingRepository>()
                    .findProductPackagingsByArticleId(articleId),
                builder: (context, snapshot) {
                  return ListView.separated(
                      itemCount: snapshot.data?.length ?? 0,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              onSelected?.call(snapshot.requireData[index]);
                              Navigator.of(context).pop();
                            },
                            child: ProductPackagingView(
                                productPackaging: snapshot.requireData[index]),
                          ));
                }),
          ),
        ],
      ),
    );
  }
}
