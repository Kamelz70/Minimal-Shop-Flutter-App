import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imgURLFocusNode = FocusNode();
  bool _isInit = false;
  bool _isLoading = false;
  //to use the controller before submitting form, others handled by the form
  final _imgURLController = TextEditingController();

  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };
  //key to interact with form from our function submit
  final _formKey = GlobalKey<FormState>();
  Product _editedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  @override
  void initState() {
    super.initState();
    //attach listener to the controller on initState
    _imgURLFocusNode.addListener(_updateImgURL);
  }

  @override
  void didChangeDependencies() {
    if (_isInit == true) {
      return;
    } else {
      super.didChangeDependencies();
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);

        _initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          //Don't need to set now, have to use controller
          'imageUrl': null,
        };
      }
      _imgURLController.text = _editedProduct.imageUrl;
      _isInit = true;
    }
  }

  //dispose for memory leak avoidance
  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imgURLFocusNode.removeListener(_updateImgURL);
    _imgURLFocusNode.dispose();
  }

  //listener to update image when url changes, needs to be attached
  void _updateImgURL() {
    {
      if ((!_imgURLController.text.startsWith('http') &&
              !_imgURLController.text.startsWith('https')) ||
          (!_imgURLController.text.endsWith('.png') &&
              !_imgURLController.text.startsWith('.jpeg') &&
              !_imgURLController.text.endsWith('.jpg'))) {
        return;
      }
    }
    if (!_imgURLFocusNode.hasFocus) {
      setState(() {});
    }
  }

  // to save form
  // void _saveForm() {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   final isValid = _formKey.currentState.validate();
  //   if (!isValid) {
  //     return;
  //   }
  //   _formKey.currentState.save();
  //   if (_editedProduct.id.isEmpty) {
  //     Provider.of<Products>(context, listen: false)
  //         .addProduct(_editedProduct)
  //         .catchError((error) {
  //       return showDialog<Null>(
  //         context: context,
  //         builder: (ctx) => AlertDialog(
  //           title: Text('An Error occured :${error.toString()}'),
  //           actions: [
  //             TextButton(
  //                 child: Text('Okay'),
  //                 onPressed: () {
  //                   Navigator.of(ctx).pop();
  //                 }),
  //           ],
  //         ),
  //       );
  //     }).then((_) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       Navigator.of(context).pop();
  //     });
  //   } else {
  //     Provider.of<Products>(context, listen: false)
  //         .updateProduct(_editedProduct);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     Navigator.of(context).pop();
  //   }
  //   //Navigator.of(context).pop();
  // }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    if (_editedProduct.id.isEmpty) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An Error occured :${error.toString()}'),
            actions: [
              TextButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  }),
            ],
          ),
        );
      }
      //finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    } else {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct);
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    //Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Title",
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (val) {
                        //when submitted, go to next focus node which is price
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: val,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Fill this field';
                        }
                        return null;
                      },
                      initialValue: _initValues['title'],
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Price",
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (val) {
                        //when submitted, go to next focus node which is price
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      focusNode: _priceFocusNode,
                      onSaved: (val) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(val),
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please Enter a Price';
                        }
                        if (double.tryParse(val) == null) {
                          return 'Please Enter a Valid number';
                        }
                        if (double.parse(val) <= 0) {
                          return 'Please Enter a price bigger than 0';
                        }

                        return null;
                      },
                      initialValue: _initValues['price'],
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (val) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: val,
                          price: _editedProduct.price,
                          isFavorite: _editedProduct.isFavorite,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please Enter a Description';
                        }
                        return null;
                      },
                      initialValue: _initValues['description'],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imgURLController.text.isEmpty
                              ? Text("Enter URL", textAlign: TextAlign.center)
                              : FittedBox(
                                  child: Image.network(_imgURLController.text),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (val) {
                              _saveForm();
                            },
                            controller: _imgURLController,
                            focusNode: _imgURLFocusNode,
                            //Needed in new versions of flutter to catch new input
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onSaved: (val) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                isFavorite: _editedProduct.isFavorite,
                                imageUrl: val,
                              );
                            },
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Please Enter a URL';
                              }
                              if (!val.startsWith('http') &&
                                  !val.startsWith('https')) {
                                return 'Please Enter a valid url';
                              }
                              if (!val.endsWith('.png') &&
                                  !val.startsWith('.jpeg') &&
                                  !val.endsWith('.jpg')) {
                                return 'Please Enter a URL for an image';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
