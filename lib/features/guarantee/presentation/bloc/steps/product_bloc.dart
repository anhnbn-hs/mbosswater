// Save state for step 1 - Product

import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';

class ProductBloc extends Cubit<Product?> {
  ProductBloc(super.initialState);

  Product? product;

  void emitProduct(Product product) {
    this.product = product;
    emit(product);
  }

  void reset(){
    product = null;
    emit(null);
  }
}
